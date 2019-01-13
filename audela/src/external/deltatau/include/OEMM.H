///////////////////////////////////////////////////////////////////////////
//    File: OEMM.H
//
//        Header file for common defines used by the OEM.
//
//
///////////////////////// Naming Conventions //////////////////////////////
//
// 1. At beginning of macro name:
//
//  A. VARIABLE
//
//    CS  = DPRAM Command/Status related value matching that used by DLL.
//    ES  = DPRAM Error/Status related value matching that used by DLL.
//    PC  = PC DPRAM related value used by DLL.
//    VS  = DPRAM Value/Status related value matching that used by DLL.
//
//  B. INPUTS
//
//    FS = Float switch or Foot switch.
//    LS = Limit switch.
//    PB = Push Button.
//    PS = Pressure switch.
//    PX = Proximity switch.
//    SS = Selector switch.
//
//  C. OUTPUTS
//
//    CL = Coil.
//    LT = Light
//    SL = Solenoid.
//
// 2. At end of macro name:
//
//    ADR = Address
//    OFS = Offset
//    BM  = Bit Map
//    M   = PMAC 'M' pointer
//    L   = PLCC L-Varible
//
/////////////////// Default PMAC/PC Variable Locations ////////////////////
//
// Function    | M Var Range | P Var Range / L Var Range | Prog Name   | DPRAM Addr
// ---------------------------------------------------------------------------------------
// Address.h   : M0..M279    :             :             : DLL         :
// ------------:--------------------------------------------------------------------------
// Oemm.h      : M280..M339  :             :             : Predefine common used variables
//----------------------------------------------------------------------------------------
// Oem.h       : M340..Mxxxx :             :             : For PLC usage
//----------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////

#ifndef OEMM_H
#define OEMM_H

///////////////////////////////////////////////////////////////////////////
// Timers
///////////////////////////////////////////////////////////////////////////
#define TIMER_1_M    M280
#define TIMER_1_ADR  Y:$0700,0,24,s

#define TIMER_2_M    M281
#define TIMER_2_ADR  X:$0700,0,24,s

#define TIMER_3_M    M282
#define TIMER_3_ADR  Y:$0701,0,24,s

#define TIMER_4_M    M283
#define TIMER_4_ADR  X:$0701,0,24,s


///////////////////////////////////////////////////////////////////////////////
// Interupts
////////////////////////////////////////////////////////////////////////
#define EQU1_M              M284
#define INTR_SEQ_MM         M284=1M284=0
#define EQU1B_M             M285
#define EQU2_M              M286

#define VME_INT_LEVEL_M          M287
#define VME_INT_VECTOR_M         M288
// ACC 34 stuff -----------------------------------------------------------

#define ACC34_1A            M290        // Acc-34 #1 Port A
#define ACC34_1B            M291        // Acc-34 #1 Port B
#define ACC34_2A            M292        // Acc-34 #2 Port A
#define ACC34_2B            M293        // Acc-34 #2 Port B
#define ACC34_3A            M294        // Acc-34 #3 Port A
#define ACC34_3B            M295        // Acc-34 #3 Port B
#define ACC34_4A            M296        // Acc-34 #4 Port A
#define ACC34_4B            M297        // Acc-34 #4 Port B
#define ACC34_5A            M298        // Acc-34 #5 Port A
#define ACC34_5B            M299        // Acc-34 #5 Port B
#define ACC34_6A            M300        // Acc-34 #6 Port A
#define ACC34_6B            M301        // Acc-34 #6 Port B
#define ACC34_7A            M302        // Acc-34 #7 Port A
#define ACC34_7B            M303        // Acc-34 #7 Port B
#define ACC34_8A            M304        // Acc-34 #8 Port A
#define ACC34_8B            M305        // Acc-34 #8 Port B

//////////////////////////////////////////////////////////////////////
// NC Panel Definitions
//////////////////////////////////////////////////////////////////////
// Y:$FFC1 THUMBWHEEL PORT
#define CPANEL_IN_ADR       DP:$1001   // Use the memory space of P1
#define CPANEL_IN_M         M306
#define CPANEL_TEMP         P260

#define IO_STATE_M          M307
///////// USE THESE DEFINES AND NOT THE ONES BELOW FOR PMAC 2's ////
//      #define IO_STATE_ADR       Y:$C082,8,8  // PMAC 2
//      #define IO_DATA_ADR        Y:$C082,0,8  // PMAC 2
////////////////////////////////////////////////////////////////////
#define IO_STATE_ADR       Y:$FFC1,8,8  // PMAC 1
#define IO_DATA_ADR        Y:$FFC1,0,8  // PMAC 1
#define IO_DATA_M           M308
#define IO_TEMP             P262
#define IO_TEMP2            P263



#define SS_MODE_PREV        P291

#define SS_JOG_M            M309
#define SS_MODE_M           M310
#define SS_AXIS_M           M311
#define SS_FEED_M           M312
#define SS_ROVRD_M          M313
#define SS_SPND_M           M314
#define SS_FOVRD_M          M315
#define SS_SOVRD_M          M316

#define SS_JOG_ADR          Y:$1001,0,4,U
#define SS_MODE_ADR         Y:$1001,4,4,U
#define SS_AXIS_ADR         Y:$1001,8,4,U
#define SS_FEED_ADR         Y:$1001,12,4,U
#define SS_ROVRD_ADR        X:$1001,0,4,U
#define SS_SPND_ADR         X:$1001,4,4,U
#define SS_FOVRD_ADR        X:$1001,8,4,U
#define SS_SOVRD_ADR        X:$1001,12,4,U

SS_JOG_M->SS_JOG_ADR
SS_MODE_M->SS_MODE_ADR
SS_AXIS_M->SS_AXIS_ADR
SS_FEED_M->SS_FEED_ADR
SS_ROVRD_M->SS_ROVRD_ADR
SS_SPND_M->SS_SPND_ADR
SS_FOVRD_M->SS_FOVRD_ADR
SS_SOVRD_M->SS_SOVRD_ADR


#define HANDLE_DATA_M       M317
#define HANDLE_DATA_ADR     Y:$0770,0,24,S


// Homing Defines //////////////////////////////////////////////////////////

#define HOME_COMPLETE_1_M       M320
#define HOME_COMPLETE_2_M       M321
#define HOME_COMPLETE_3_M       M322
#define HOME_COMPLETE_4_M       M323
#define HOME_COMPLETE_5_M       M324
#define HOME_COMPLETE_6_M       M325
#define HOME_COMPLETE_7_M       M326
#define HOME_COMPLETE_8_M       M327


// Motion Defines //////////////////////////////////////////////////////////
// These are used to determine PMAC's current motion mode.
//
// MODE     MOTION_MODE MOTION_EXT
//              & 3
//--------------------------------
// RAPID        2           0
// LINEAR       0           0
// CIR1         1           0
// CIR2         3           0
// SPLINE1      1           1
// PVT          0           1

#define MOTION_MODE_M           M330
#define MOTION_MODE_ADR         Y:$0817,0,4
#define MOTION_EXT_M            M331
#define MOTION_EXT_ADR          Y:$0817,4,1

#define MOTION2_MODE_M          M332
#define MOTION2_MODE_ADR        Y:$08D7,0,4
#define MOTION2_EXT_M           M333
#define MOTION2_EXT_ADR         Y:$08D7,4,1

#define IN_POSITION_M           M334
#define IN_POSITION_ADR         Y:$0817,17,1
#define IN_POSITION2_M          M335
#define IN_POSITION2_ADR        Y:$08D7,17,1

MOTION_MODE_M->MOTION_MODE_ADR
MOTION_EXT_M->MOTION_EXT_ADR
MOTION2_MODE_M->MOTION2_MODE_ADR
MOTION2_EXT_M->MOTION2_EXT_ADR
IN_POSITION_M->IN_POSITION_ADR
IN_POSITION2_M->IN_POSITION2_ADR

#define  CONT_MOTION_REQ_M      M336
#define  CONT_MOTION_REQ_ADR    X:$818,4,1
#define  CONT_MOTION2_REQ_M     M337
#define  CONT_MOTION2_REQ_ADR   X:$8D8,4,1
CONT_MOTION_REQ_M->CONT_MOTION_REQ_ADR
CONT_MOTION2_REQ_M->CONT_MOTION2_REQ_ADR

// General Defines /////////////////////////////////////
// Misc storage used by various programs. Stored here to
// prevent cross multiple reference and save space.
#define TEMP                Q31
#define MIRROR_FLAG         Q32
#define X_INTER_PT          Q33
#define Y_INTER_PT          Q34
#define Z_INTER_PT          Q35
#define X_RPLANE            Q36
#define FULL_RETRACT        Q37
#define DELTA_D             Q38
#define D_FINISH            Q39
#define D_MINIMUM           Q40
#define TAN_ALPHA           Q41
#define TAPER               Q42
#define D_PREVIOUS          Q43
#define CHAMFER_SIZE        Q44
#define CHAMFER_LEADS       Q45
#define THREAD_HT           Q46
#define SAVED_TIMEBASE_FLAG Q47
#define DWELL_TIME          Q48
#define C_POS               Q49
#define X_RELIEF            Q50
#define Z_RELIEF            Q51
#define X_PECK              Q52
#define Z_PECK              Q53
#define X_START             Q54
#define Z_START             Q55
#define X_PECK_CLEARANCE    Q56
#define Z_PECK_CLEARANCE    Q57
#define X_DEPTH             Q58
#define DISABLE_OVRD        Q59
#define CHANGE_STATE        Q60
#define LEFT_TURRET         Q61
#define SPINDLE_WAS_ON      Q62
#define NEW_TOOL            Q63
#define CUR_TOOL            Q64
#define SPINDLE_RPM_PREV    Q65
#define CUTING_FEED_MODE    Q66
#define THREAD_FEED_MODE    Q67
#define DRYRUN_FEED_MODE    Q68
#define CANNED_CYCLE_MODE   Q69
#define REPEATS             Q70
#define SUBROUTINE          Q71
#define FIRST_PECK          Q72
#define MINIMUM_PECK        Q73
#define NEXT_PECK           Q74
#define X_POS               Q75
#define Y_POS               Q76
#define Z_POS               Q77
#define Z_RPLANE            Q78
#define SPND_SPEED_DETECT   Q79
#define SAVED_TIMEBASE      Q80
#define SAVED_SLEWRATE      Q81
#define SPINDLE_DIR         Q82
#define STEP                Q83
#define ANGLE               Q84
#define RADIUS              Q85
#define START_ANGLE         Q86
#define X_CENTER            Q87
#define Y_CENTER            Q88
#define NUM_HOLES           Q89
#define ABS_MODE            Q90
#define SPND_ORIENT_ANGLE   Q91
#define X_PULLBACK          Q92
#define Y_PULLBACK          Q93
#define INIT_POINT_RETURN   Q94
#define PECK                Q95
#define PECK_CLEARANCE      Q96
#define Z_DEPTH             Q97
#define Z_CPLANE            Q98
#define Z_SPLANE            Q99

#define DEFAULT_PECK_CLEAR  0.125
#define ZERO_TOL            0.0001

// Q Variables Passed to "Canned Cycles"////////////////////////////////////
// These variables are described in manual under "READ" command description
#define A_ARG_Q             Q101
#define B_ARG_Q             Q102
#define C_ARG_Q             Q103
#define D_ARG_Q             Q104
#define E_ARG_Q             Q105
#define F_ARG_Q             Q106
#define G_ARG_Q             Q107
#define H_ARG_Q             Q108
#define I_ARG_Q             Q109
#define J_ARG_Q             Q110
#define K_ARG_Q             Q111
#define L_ARG_Q             Q112
#define M_ARG_Q             Q113
#define N_ARG_Q             Q114
#define O_ARG_Q             Q115
#define P_ARG_Q             Q116
#define Q_ARG_Q             Q117
#define R_ARG_Q             Q118
#define S_ARG_Q             Q119
#define T_ARG_Q             Q120
#define U_ARG_Q             Q121
#define V_ARG_Q             Q122
#define W_ARG_Q             Q123
#define X_ARG_Q             Q124
#define Y_ARG_Q             Q125
#define Z_ARG_Q             Q126
#define S_CODE_Q            Q127


// Assignments /////////////////////////////////////////////////////////////

; Current status values variables
VS_CURRENT_BLOCK_M->VS_CURRENT_BLOCK_ADR
VS_CURRENT_BLOCK2_M->VS_CURRENT_BLOCK2_ADR
VS_LAST_BLOCK_M->VS_CURRENT_BLOCK_ADR
VS_LAST_BLOCK2_M->VS_CURRENT_BLOCK2_ADR
VS_CURRENT_PROG_M->VS_CURRENT_PROG_ADR
VS_CURRENT_PROG2_M->VS_CURRENT_PROG2_ADR
VS_SPINDLE_RPM_M->VS_SPINDLE_RPM_ADR
VS_SPINDLE_MAX_RPM_M->VS_SPINDLE_MAX_RPM_ADR
VS_SPINDLE_CMD_RPM_M->VS_SPINDLE_CMD_RPM_ADR
VS_SPINDLE_ACT_RPM_M->VS_SPINDLE_ACT_RPM_ADR
VS_SPINDLE_CSS_UNITS_M->VS_SPINDLE_CSS_UNITS_ADR
VS_SPINDLE_CSS_M->VS_SPINDLE_CSS_ADR
VS_SPINDLE_MAX_LIM_M->VS_SPINDLE_MAX_LIM_ADR
VS_SPINDLE_COUNTS_REV_M->VS_SPINDLE_COUNTS_REV_ADR
VS_GEAR_RATIO_M->VS_GEAR_RATIO_ADR
VS_SPINDLE_OVERRIDE_M->VS_SPINDLE_OVERRIDE_ADR
VS_TURRET_TOOL_M->VS_TURRET_TOOL_ADR
VS_TURRET2_TOOL_M->VS_TURRET2_TOOL_ADR
VS_TURRET_POT_M->VS_TURRET_POT_ADR
VS_TURRET2_POT_M->VS_TURRET2_POT_ADR
VS_TOOL_NUMBER_M->VS_TOOL_NUMBER_ADR
VS_TOOL_NUMBER2_M->VS_TOOL_NUMBER2_ADR
VS_TOOL_NEXT_M->VS_TOOL_NEXT_ADR
VS_TOOL_NEXT2_M->VS_TOOL_NEXT2_ADR
VS_HANDLE_LINC_M->VS_HANDLE_LINC_ADR
VS_JOG_STEP_M->VS_JOG_STEP_ADR
VS_HAND_STEP_M->VS_HAND_STEP_ADR
VS_SEMAPHORE_M->VS_SEMAPHORE_ADR
VS_SEMAPHORE2_M->VS_SEMAPHORE2_ADR
VS_FEED_OVERRIDE_M->VS_FEED_OVERRIDE_ADR
VS_FEED_OVERRIDE2_M->VS_FEED_OVERRIDE2_ADR
VS_RAPID_OVERRIDE_M->VS_RAPID_OVERRIDE_ADR
VS_RAPID_OVERRIDE2_M->VS_RAPID_OVERRIDE2_ADR
VS_THREAD_LEAD_M->VS_THREAD_LEAD_ADR
VS_THREAD_LEAD2_M->VS_THREAD_LEAD2_ADR
VS_TOOL_OFFSET_M->VS_TOOL_OFFSET_ADR

VS_GGROUP0_1_M->VS_GGROUP0_1_ADR
VS_GGROUP1_1_M->VS_GGROUP1_1_ADR
VS_GGROUP2_1_M->VS_GGROUP2_1_ADR
VS_GGROUP3_1_M->VS_GGROUP3_1_ADR
VS_GGROUP4_1_M->VS_GGROUP4_1_ADR
VS_GGROUP5_1_M->VS_GGROUP5_1_ADR
VS_GGROUP6_1_M->VS_GGROUP6_1_ADR
VS_GGROUP7_1_M->VS_GGROUP7_1_ADR
VS_GGROUP8_1_M->VS_GGROUP8_1_ADR
VS_GGROUP9_1_M->VS_GGROUP9_1_ADR
VS_GGROUP10_1_M->VS_GGROUP10_1_ADR
VS_GGROUP11_1_M->VS_GGROUP11_1_ADR
VS_GGROUP12_1_M->VS_GGROUP12_1_ADR
VS_GGROUP13_1_M->VS_GGROUP13_1_ADR
VS_GGROUP14_1_M->VS_GGROUP14_1_ADR
VS_GGROUP15_1_M->VS_GGROUP15_1_ADR
VS_GGROUP16_1_M->VS_GGROUP16_1_ADR
VS_GGROUP17_1_M->VS_GGROUP17_1_ADR
VS_GGROUP18_1_M->VS_GGROUP18_1_ADR
VS_GGROUP19_1_M->VS_GGROUP19_1_ADR
VS_GGROUP20_1_M->VS_GGROUP20_1_ADR
VS_GGROUP21_1_M->VS_GGROUP21_1_ADR
VS_GGROUP22_1_M->VS_GGROUP22_1_ADR
VS_GGROUP23_1_M->VS_GGROUP23_1_ADR
VS_GGROUP24_1_M->VS_GGROUP24_1_ADR
VS_GGROUP0_2_M->VS_GGROUP0_2_ADR
VS_GGROUP1_2_M->VS_GGROUP1_2_ADR
VS_GGROUP2_2_M->VS_GGROUP2_2_ADR
VS_GGROUP3_2_M->VS_GGROUP3_2_ADR
VS_GGROUP4_2_M->VS_GGROUP4_2_ADR
VS_GGROUP5_2_M->VS_GGROUP5_2_ADR
VS_GGROUP6_2_M->VS_GGROUP6_2_ADR
VS_GGROUP7_2_M->VS_GGROUP7_2_ADR
VS_GGROUP8_2_M->VS_GGROUP8_2_ADR
VS_GGROUP9_2_M->VS_GGROUP9_2_ADR
VS_GGROUP10_2_M->VS_GGROUP10_2_ADR
VS_GGROUP11_2_M->VS_GGROUP11_2_ADR
VS_GGROUP12_2_M->VS_GGROUP12_2_ADR
VS_GGROUP13_2_M->VS_GGROUP13_2_ADR
VS_GGROUP14_2_M->VS_GGROUP14_2_ADR
VS_GGROUP15_2_M->VS_GGROUP15_2_ADR
VS_GGROUP16_2_M->VS_GGROUP16_2_ADR
VS_GGROUP17_2_M->VS_GGROUP17_2_ADR
VS_GGROUP18_2_M->VS_GGROUP18_2_ADR
VS_GGROUP19_2_M->VS_GGROUP19_2_ADR
VS_GGROUP20_2_M->VS_GGROUP20_2_ADR
VS_GGROUP21_2_M->VS_GGROUP21_2_ADR
VS_GGROUP22_2_M->VS_GGROUP22_2_ADR
VS_GGROUP23_2_M->VS_GGROUP23_2_ADR
VS_GGROUP24_2_M->VS_GGROUP24_2_ADR

VS_A_REL_M->VS_A_REL_ADR
VS_B_REL_M->VS_B_REL_ADR
VS_C_REL_M->VS_C_REL_ADR
VS_X_REL_M->VS_X_REL_ADR
VS_Y_REL_M->VS_Y_REL_ADR
VS_Z_REL_M->VS_Z_REL_ADR
VS_U_REL_M->VS_U_REL_ADR
VS_V_REL_M->VS_V_REL_ADR
VS_W_REL_M->VS_W_REL_ADR
VS_A_REL2_M->VS_A_REL2_ADR
VS_B_REL2_M->VS_B_REL2_ADR
VS_C_REL2_M->VS_C_REL2_ADR
VS_X_REL2_M->VS_X_REL2_ADR
VS_Y_REL2_M->VS_Y_REL2_ADR
VS_Z_REL2_M->VS_Z_REL2_ADR
VS_U_REL2_M->VS_U_REL2_ADR
VS_V_REL2_M->VS_V_REL2_ADR
VS_W_REL2_M->VS_W_REL2_ADR
VS_A_ABS_M->VS_A_ABS_ADR
VS_B_ABS_M->VS_B_ABS_ADR
VS_C_ABS_M->VS_C_ABS_ADR
VS_X_ABS_M->VS_X_ABS_ADR
VS_Y_ABS_M->VS_Y_ABS_ADR
VS_Z_ABS_M->VS_Z_ABS_ADR
VS_U_ABS_M->VS_U_ABS_ADR
VS_V_ABS_M->VS_V_ABS_ADR
VS_W_ABS_M->VS_W_ABS_ADR
VS_A_ABS2_M->VS_A_ABS2_ADR
VS_B_ABS2_M->VS_B_ABS2_ADR
VS_C_ABS2_M->VS_C_ABS2_ADR
VS_X_ABS2_M->VS_X_ABS2_ADR
VS_Y_ABS2_M->VS_Y_ABS2_ADR
VS_Z_ABS2_M->VS_Z_ABS2_ADR
VS_U_ABS2_M->VS_U_ABS2_ADR
VS_V_ABS2_M->VS_V_ABS2_ADR
VS_W_ABS2_M->VS_W_ABS2_ADR
VS_A_MUL_M->VS_A_MUL_ADR
VS_B_MUL_M->VS_B_MUL_ADR
VS_C_MUL_M->VS_C_MUL_ADR
VS_X_MUL_M->VS_X_MUL_ADR
VS_Y_MUL_M->VS_Y_MUL_ADR
VS_Z_MUL_M->VS_Z_MUL_ADR
VS_U_MUL_M->VS_U_MUL_ADR
VS_V_MUL_M->VS_V_MUL_ADR
VS_W_MUL_M->VS_W_MUL_ADR
VS_A_MUL2_M->VS_A_MUL2_ADR
VS_B_MUL2_M->VS_B_MUL2_ADR
VS_C_MUL2_M->VS_C_MUL2_ADR
VS_X_MUL2_M->VS_X_MUL2_ADR
VS_Y_MUL2_M->VS_Y_MUL2_ADR
VS_Z_MUL2_M->VS_Z_MUL2_ADR
VS_U_MUL2_M->VS_U_MUL2_ADR
VS_V_MUL2_M->VS_V_MUL2_ADR
VS_W_MUL2_M->VS_W_MUL2_ADR
VS_X_RCEN_M->VS_X_RCEN_ADR
VS_Y_RCEN_M->VS_Y_RCEN_ADR
VS_Z_RCEN_M->VS_Z_RCEN_ADR
VS_X_RCEN2_M->VS_X_RCEN2_ADR
VS_Y_RCEN2_M->VS_Y_RCEN2_ADR
VS_Z_RCEN2_M->VS_Z_RCEN2_ADR
VS_NLABEL_M->VS_NLABEL_ADR
VS_NLABEL2_M->VS_NLABEL2_ADR

; Assign Error pointers
ES_PC_CLOCK_M->ES_PC_CLOCK_ADR
ES_ERR_FATAL_M->ES_ERR_FATAL_ADR
ES_ERR_STOP_M->ES_ERR_STOP_ADR
ES_ERR_WARN_M->ES_ERR_WARN_ADR
ES_ERR_WARN2_M->ES_ERR_WARN2_ADR
ES_ERR_MSG_M->ES_ERR_MSG_ADR
ES_ERR_MSG2_M->ES_ERR_MSG2_ADR

// Command / Status variables
CS_STATUS1_M->CS_STATUS1_ADR
CS_STATUS2_M->CS_STATUS2_ADR
CS_STATUS3_M->CS_STATUS3_ADR
CS_STATUS4_M->CS_STATUS4_ADR
CS_STATUS5_M->CS_STATUS5_ADR
CS_STATUS6_M->CS_STATUS6_ADR
CS_STATUS7_M->CS_STATUS7_ADR
CS_STATUS8_M->CS_STATUS8_ADR
CS_COMMAND1_M->CS_COMMAND1_ADR
CS_COMMAND2_M->CS_COMMAND2_ADR
CS_COMMAND3_M->CS_COMMAND3_ADR
CS_COMMAND4_M->CS_COMMAND4_ADR
CS_COMMAND5_M->CS_COMMAND5_ADR
CS_COMMAND6_M->CS_COMMAND6_ADR
CS_COMMAND7_M->CS_COMMAND7_ADR
CS_COMMAND8_M->CS_COMMAND8_ADR

ACC34_1A->TWS:1
ACC34_1B->TWS:6
// ACC34_2A->TWS:17
// ACC34_2B->TWS:22
// ACC34_3A->TWS:33
// ACC34_3B->TWS:38
// ACC34_4A->TWS:49
// ACC34_4B->TWS:54

IN_1_M->IN_1_ADR
IN_2_M->IN_2_ADR
IN_3_M->IN_3_ADR
IN_4_M->IN_4_ADR
IN_5_M->IN_5_ADR
IN_6_M->IN_6_ADR
IN_7_M->IN_7_ADR
IN_8_M->IN_8_ADR
OUT_1_M->OUT_1_ADR
OUT_2_M->OUT_2_ADR
OUT_3_M->OUT_3_ADR
OUT_4_M->OUT_4_ADR
OUT_5_M->OUT_5_ADR
OUT_6_M->OUT_6_ADR
OUT_7_M->OUT_7_ADR
OUT_8_M->OUT_8_ADR

IN_1_CHNG_M->IN_1_CHNG_ADR
IN_2_CHNG_M->IN_2_CHNG_ADR
IN_3_CHNG_M->IN_3_CHNG_ADR
IN_4_CHNG_M->IN_4_CHNG_ADR
IN_5_CHNG_M->IN_5_CHNG_ADR
IN_6_CHNG_M->IN_6_CHNG_ADR
IN_7_CHNG_M->IN_7_CHNG_ADR
IN_8_CHNG_M->IN_8_CHNG_ADR
OUT_1_CHNG_M->OUT_1_CHNG_ADR
OUT_2_CHNG_M->OUT_2_CHNG_ADR
OUT_3_CHNG_M->OUT_3_CHNG_ADR
OUT_4_CHNG_M->OUT_4_CHNG_ADR
OUT_5_CHNG_M->OUT_5_CHNG_ADR
OUT_6_CHNG_M->OUT_6_CHNG_ADR
OUT_7_CHNG_M->OUT_7_CHNG_ADR
OUT_8_CHNG_M->OUT_8_CHNG_ADR

CPANEL_IN_M->CPANEL_IN_ADR
IO_STATE_M->IO_STATE_ADR         // Control Panel Selector
IO_DATA_M->IO_DATA_ADR           // Control Panel 8 bits
HANDLE_DATA_M->HANDLE_DATA_ADR   // Storage for handle word

//  Assign DLL selectors
//  Status
S_MODE_M->S_MODE_ADR
S_AXIS_M->S_AXIS_ADR
S_JOG_M->S_JOG_ADR
S_FEED_M->S_FEED_ADR
S_DIST_M->S_DIST_ADR
S_SOVRD_M->S_SOVRD_ADR
S_SPND_M->S_SPND_ADR
S_FOVRD_M->S_FOVRD_ADR
S_ROVRD_M->S_ROVRD_ADR
S_COORD_M->S_COORD_ADR
S_HOME_M->S_HOME_ADR
S_GEAR_M->S_GEAR_ADR
S_ERROR_M->S_ERROR_ADR
S_CLNT_M->S_CLNT_ADR
S_MACHINE_M->S_MACHINE_ADR
S_MOTION_M->S_MOTION_ADR
S_TIMEBASE_M->S_TIMEBASE_ADR
S_PROG_STATUS_M->S_PROG_STATUS_ADR



//  Command
C_MODE_M->C_MODE_ADR
C_AXIS_M->C_AXIS_ADR
C_JOG_M->C_JOG_ADR
C_FEED_M->C_FEED_ADR
C_DIST_M->C_DIST_ADR
C_SOVRD_M->C_SOVRD_ADR
C_SPND_M->C_SPND_ADR
C_FOVRD_M->C_FOVRD_ADR
C_ROVRD_M->C_ROVRD_ADR
C_COORD_M->C_COORD_ADR
C_HOME_M->C_HOME_ADR
C_GEAR_M->C_GEAR_ADR
C_ERROR_M->C_ERROR_ADR
C_CLNT_M->C_CLNT_ADR
C_MACHINE_M->C_MACHINE_ADR
C_MOTION_M->C_MOTION_ADR
C_TIMEBASE_M->C_TIMEBASE_ADR
C_PROG_STATUS_M->C_PROG_STATUS_ADR

HOME_COMPLETE_1_M->Y:$814,10,1
HOME_COMPLETE_2_M->Y:$8D4,10,1
HOME_COMPLETE_3_M->Y:$994,10,1
HOME_COMPLETE_4_M->Y:$A54,10,1
HOME_COMPLETE_5_M->Y:$B14,10,1
HOME_COMPLETE_6_M->Y:$BD4,10,1
HOME_COMPLETE_7_M->Y:$C94,10,1
HOME_COMPLETE_8_M->Y:$D54,10,1

TIMER_1_M->TIMER_1_ADR
TIMER_2_M->TIMER_2_ADR
TIMER_3_M->TIMER_3_ADR
TIMER_4_M->TIMER_4_ADR

// Set interrupts
/////////////////////////////////////////////////////////////////////
// USE THESE DEFINES FOR PMAC 2's
// EQU1_M->X:$C005,11           //  IRQ5 SendReady// PMAC 2
// EQU1B_M->X:$C005,12          //  IRQ5 Data Bit// PMAC 2
/////////////////////////////////////////////////////////////////////
EQU1_M->X:$C000,13          //  IRQ5 // PMAC 1
EQU2_M->X:$C004,13          //  IRQ6


VME_INT_LEVEL_M->X:$E00B,0,24
VME_INT_VECTOR_M->X:$E00C,0,24


#endif



