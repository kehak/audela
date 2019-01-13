///////////////////////////////////////////////////////////////////////////
//
//  File: oem.h
//
//    Generic and test.
//
//
// 1. At beginning of macro name:
//
// A. VARIABLE
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
//    BM  = Bit Mask
//    M   = PMAC 'M' pointer
//    L   = PLCC L-Varible
//
/////////////////// Default PMAC/PC Variable Locations ////////////////////
//
// Function    | M Var Range | P Var Range / L Var Range | Prog Name   | DPRAM Addr
// ---------------------------------------------------------------------------------------
// Address.h   : M0..M279    :             :             : DLL         :
//-------------:--------------------------------------------------------------------------
// Oemm.h      : M280..M339  :             :             : Predefine common used variables
//----------------------------------------------------------------------------------------
// Oem.h       : M340..M469 :             :             : For Delta Tau PLC usage
//----------------------------------------------------------------------------------------


#ifndef OEM_H
#define OEM_H

//-----------------------------------------
// SPINDLE.PLC M,P & L Variable Definitions
//-----------------------------------------
// M340 .. M359, P340..P359, L340..359
#define JOG_CW      CMD"#4j+"
#define JOG_CCW     CMD"#4j-"
#define JOG_STOP    CMD"#4j/"

#define SPINDLE_MOTOR_VEL     M340
#define SPINDLE_MOTOR_VEL_ADR X:$E7,0,24,S
#define SPINDLE_CSS_POS       M341
#define SPINDLE_CSS_POS_ADR   D:$2B
#define SPINDLE_DAC_M         M342
#define SPINDLE_DAC_ADR       Y:$C00A,8,16,S
#define SPINDLE_ENA_M         M343
#define SPINDLE_ENA_ADR       X:$C00C,14,1

SPINDLE_MOTOR_VEL->SPINDLE_MOTOR_VEL_ADR
SPINDLE_CSS_POS->SPINDLE_CSS_POS_ADR
SPINDLE_DAC_M->SPINDLE_DAC_ADR
SPINDLE_ENA_M->SPINDLE_ENA_ADR

#define SPINDLE_TEMP        P340
#define SPINDLE_ERR_ALLOWED P341
#define LAST_SPND_DIR       P342
#define LAST_CMD_RPM        P343
#define RTIF                P344
#define SPINDLE_CSS_RADIUS  P345
#define CSS_OFFSET          P347
#define VOLTS_PER_RPM       P348
#define SPINDLE_MIN_RPM     P359

#define SPINDLE_JOG_SPEED   I422

//----------------------------------------
// Timebase Pointer Defines PLC 2 OVRD.PLC
//----------------------------------------
// M360..M379,P360..P379, X,Y memory space $772 - $774
// To assign cutting timebase: TIMEBASE_M = CUTTING_TIMEBASE
// To assign rapid timebase  : TIMEBASE_M = RAPID_TIMEBASE
// To assign thread timebase : TIMEBASE_M = THREAD_TIMEBASE

#define TIMEBASE_M              M360 // I193
#define TIMEBASE_ADR            X:$807,0,16,U
#define TIMEBASE2_M             M361 // I293
#define TIMEBASE2_ADR           X:$8C7,0,16,U

#define CUTTING_TIMEBASE_M      M362
#define CUTTING_TIMEBASE_ADR    X:$806,0,24,S
#define CUTTING_TIMEBASE        $0806
#define CUTTING_TIMEBASE2_M     M363
#define CUTTING_TIMEBASE2_ADR   X:$8C6,0,24,S
#define CUTTING_TIMEBASE2       $08C6

#define RAPID_TIMEBASE_M        M364
#define RAPID_TIMEBASE_ADR      X:$0772,0,24,S // I10 units
#define RAPID_TIMEBASE          $0772
#define RAPID_TIMEBASE2_M       M365
#define RAPID_TIMEBASE2_ADR     X:$0773,0,24,S // I10 units
#define RAPID_TIMEBASE2         $0773

#define THREAD_TIMEBASE_M       M366
#define THREAD_TIMEBASE_ADR     Y:$072A,0,24,S
#define THREAD_TIMEBASE         $072B
#define THREAD_PROC_BITS_M      M367
#define THREAD_PROC_BITS_ADR    Y:$072A,16,8
#define THREAD_SCALE_M          M368
#define THREAD_SCALE_ADR        Y:$072B,0,24,S

#define FPR_TIMEBASE            $0774
#define FPR_TIMEBASE_M          M369
#define FPR_TIMEBASE_ADR        X:$0774,0,24,S
#define SPND_TIMEBASE_M         M370
#define SPND_TIMEBASE_ADR       X:$0729,0,24,S
#define FPR_SCALE_M             M371
#define FPR_SCALE_ADR           Y:$0729,0,24,S

#define CS1_TIMEBASE_UNITS_I    I190
#define TIME_BASE_SLEW_I        I194
#define MAX_SLEW                8388607
#define MED_SLEW                4250
#define MINUTES_MS              60000
#define TIMEBASE_FROZEN         $90

#define THREAD_MODE             P360

TIMEBASE_M->TIMEBASE_ADR
CUTTING_TIMEBASE_M->CUTTING_TIMEBASE_ADR
RAPID_TIMEBASE_M->RAPID_TIMEBASE_ADR
TIMEBASE2_M->TIMEBASE2_ADR
CUTTING_TIMEBASE2_M->CUTTING_TIMEBASE2_ADR
RAPID_TIMEBASE2_M->RAPID_TIMEBASE2_ADR
THREAD_PROC_BITS_M->THREAD_PROC_BITS_ADR
THREAD_SCALE_M->THREAD_SCALE_ADR
THREAD_TIMEBASE_M->THREAD_TIMEBASE_ADR
FPR_TIMEBASE_M->FPR_TIMEBASE_ADR
SPND_TIMEBASE_M->SPND_TIMEBASE_ADR
FPR_SCALE_M->FPR_SCALE_ADR

// Commanded Position Defines /////////////////////////////////////////////

#define X_CMD_POS_M         M372
#define Y_CMD_POS_M         M373
#define Z_CMD_POS_M         M374
#define X_CMD_POS_ADR       L:$081F // Coord sys &1 X commanded position
#define Y_CMD_POS_ADR       L:$0820 // Coord sys &1 Y commanded position
#define Z_CMD_POS_ADR       L:$0821 // Coord sys &1 Z commanded position
#define X2_CMD_POS_M        M375
#define Y2_CMD_POS_M        M376
#define Z2_CMD_POS_M        M377
#define X2_CMD_POS_ADR      L:$08DF // Coord sys &2 X commanded position
#define Y2_CMD_POS_ADR      L:$08E0 // Coord sys &2 Y commanded position
#define Z2_CMD_POS_ADR      L:$08E1 // Coord sys &2 Z commanded position
#define Z_ACT_POS_M         M378
#define Z_ACT_POS_ADR       D:$00A3

#define Z_ERR               P361


X_CMD_POS_M->X_CMD_POS_ADR
Y_CMD_POS_M->Y_CMD_POS_ADR
Z_CMD_POS_M->Z_CMD_POS_ADR
X2_CMD_POS_M->X2_CMD_POS_ADR
Y2_CMD_POS_M->Y2_CMD_POS_ADR
Z2_CMD_POS_M->Z2_CMD_POS_ADR
Z_ACT_POS_M->Z_ACT_POS_ADR


//------------------------------------------------------
// HOME.PMC prog 3 and HOME.PLC PLC Variable Definitions
//------------------------------------------------------
// M380..M399, P380..P399
#define MOTOR_1              1                    ; 1st bit represents motor 1
#define MOTOR_2              2                    ; 2nd bit represents motor 2
#define MOTOR_3              4                    ; 3rd bit represents motor 3
#define MOTOR_4              8                    ; 4th bit represents motor 4
#define MOTOR_5            $10                    ; 5th bit represents motor 5
#define MOTOR_6            $20                    ; 6th bit represents motor 6
#define MOTOR_7            $40                    ; 7th bit represents motor 7
#define MOTOR_8            $80                    ; 8th bit represents motor 8
#define POS_LIMIT_DISABLE  $20000                 ; Mask for position limits
#define AMP_FAULT_DISABLE  $100000                ; Mask for amp fault

#define HOME_FLAG_1          M380                 ; Home switch for motor 1
#define HOME_FLAG_1_ADR      X:$C000,20,1
#define HOME_FLAG_2          M381                 ; Home switch for motor 2
#define HOME_FLAG_2_ADR      X:$C004,20,1
#define HOME_FLAG_3          M382                 ; Home switch for motor 3
#define HOME_FLAG_3_ADR      X:$C008,20,1
#define HOME_FLAG_4          M383                 ; Home switch for motor 4
#define HOME_FLAG_4_ADR      X:$C00C,20,1
#define HOME_FLAG_5          M384                 ; Home switch for motor 5
#define HOME_FLAG_5_ADR      X:$C010,20,1
#define HOME_FLAG_6          M385                 ; Home switch for motor 6
#define HOME_FLAG_6_ADR      X:$C014,20,1
#define HOME_FLAG_7          M386                 ; Home switch for motor 7
#define HOME_FLAG_7_ADR      X:$C018,20,1
#define HOME_FLAG_8          M387                 ; Home switch for motor 8
#define HOME_FLAG_8_ADR      X:$C01C,20,1

HOME_FLAG_1->HOME_FLAG_1_ADR
HOME_FLAG_2->HOME_FLAG_2_ADR
HOME_FLAG_3->HOME_FLAG_3_ADR
HOME_FLAG_4->HOME_FLAG_4_ADR
HOME_FLAG_5->HOME_FLAG_5_ADR
HOME_FLAG_6->HOME_FLAG_6_ADR
HOME_FLAG_7->HOME_FLAG_7_ADR
HOME_FLAG_8->HOME_FLAG_8_ADR

#define DES_VEL_ZERO_1_M     M388
#define DES_VEL_ZERO_1_ADR   X:$3D,13,1
#define DES_VEL_ZERO_2_M     M389
#define DES_VEL_ZERO_2_ADR   X:$79,13,1
#define DES_VEL_ZERO_3_M     M390
#define DES_VEL_ZERO_3_ADR   X:$B5,13,1
#define DES_VEL_ZERO_4_M     M391
#define DES_VEL_ZERO_4_ADR   X:$F1,13,1
#define DES_VEL_ZERO_5_M     M392
#define DES_VEL_ZERO_5_ADR   X:$12D,13,1
#define DES_VEL_ZERO_6_M     M393
#define DES_VEL_ZERO_6_ADR   X:$169,13,1
#define DES_VEL_ZERO_7_M     M394
#define DES_VEL_ZERO_7_ADR   X:$1A5,13,1
#define DES_VEL_ZERO_8_M     M395
#define DES_VEL_ZERO_8_ADR   X:$1F1,13,1


DES_VEL_ZERO_1_M->DES_VEL_ZERO_1_ADR
DES_VEL_ZERO_2_M->DES_VEL_ZERO_2_ADR
DES_VEL_ZERO_3_M->DES_VEL_ZERO_3_ADR
DES_VEL_ZERO_4_M->DES_VEL_ZERO_4_ADR
DES_VEL_ZERO_5_M->DES_VEL_ZERO_5_ADR
DES_VEL_ZERO_6_M->DES_VEL_ZERO_6_ADR
DES_VEL_ZERO_7_M->DES_VEL_ZERO_7_ADR
DES_VEL_ZERO_8_M->DES_VEL_ZERO_8_ADR



#define PREV_USER_2_STATE   P380

////////////////////////////////////////////////////////////////////////////
// macro definitions for TIMERTIC.PLC (plcc 1) reserves M400..M415, P400..P415
//       This is a Compiled PLC                         L0..L100
////////////////////////////////////////////////////////////////////////////

//****************************************************************************
//           "TIMERTIC.PLC" Header Files
//  Description: Defines "TIMERTIC.PLC" & temporary variables.
//               Many of these variables use the PMAC "UBUFFER" memory.
//               The "DEFINE UBUFFER < size >" must be sent to the PMAC
//               and SAVED for this area of memory to protected from being
//               over-written by the PMAC.
//               Memory $9FF0 to $9FFF is reserved for future PLCC Function Block
//               use.
//
//               Y:$9FFF is the PLCC Function Block FB start address in
//               the UBUFFER memory and is used by the PLCC FB's
//
//               X:$9FFF is the PLCC Function Block FB Timer .TS start address
//               in the UBUFFER memory and is used by the PLCC FB's Timers
//               TON, TOF, and TP.
//
//               Y:$9FFE is the PLCC Function Block FB Timer Tic value.
//               It is updated by the "TIMERTIC.PLC".
//****************************************************************************
//
//  Resource Use: L0..100, M400..M415, P400..P415
//  When used with Wizdom's Paradym 31 UBUFFER memory from $9FC0 to $9FFD
//  is reserved for PMAC NC, TIMERTIC.PLC and Temporary Variable use.
//
//****************************************************************************
//
//  Temporary L & M Variables:
//  -------------------------
//
//  ANY USER PLCs or PLCC can assign their temporary variables to these
//            variables.  Users are incouraged to use these variables to
//            maximize the use of PMAC memory and M, L & P variables.
//
//  Rules of Use:
//  ------------
//  1. They are temporary storage and are not necessarily retained
//     after exiting the PLC or PLCC.
//
//  2. They cannot be used in a WHILE loop if its value is needed on the
//     multiple passes of the loop since the PLC is exited at the ENDWHILE
//     on each pass of the WHILE loop.
//     EX. #define COUNT IL24T1
//         COUNT = 5
//         WHILE( COUNT > 0
//            COUNT = COUNT -1
//         ENDWHILE     // Each pass exit here so another PLC can use IL24T1
//
//****************************************************************************
//
//  26 x 24 bit signed Temp. L-Variables ( 13 x 48 bits used )
//
#define IL24T1      L1
#define IL24T2      L2
#define IL24T3      L3
#define IL24T4      L4
#define IL24T5      L5
#define IL24T6      L6
#define IL24T7      L7
#define IL24T8      L8
#define IL24T9      L9
#define IL24T10     L10
#define IL24T11     L11
#define IL24T12     L12
#define IL24T13     L13
#define IL24T14     L14
#define IL24T15     L15
#define IL24T16     L16
#define IL24T17     L17
#define IL24T18     L18
#define IL24T19     L19
#define IL24T20     L20
#define IL24T21     L21
#define IL24T22     L22
#define IL24T23     L23
#define IL24T24     L24
#define IL24T25     L25
#define IL24T26     L26
//
//  26 x 24 bit signed Temp. L-Variables Addresses
//
L1->Y:$9FEF,0,24,S
L2->X:$9FEF,0,24,S
L3->Y:$9FEE,0,24,S
L4->X:$9FEE,0,24,S
L5->Y:$9FED,0,24,S
L6->X:$9FED,0,24,S
L7->Y:$9FEC,0,24,S
L8->X:$9FEC,0,24,S
L9->Y:$9FEB,0,24,S
L10->X:$9FEB,0,24,S
L11->Y:$9FEA,0,24,S
L12->X:$9FEA,0,24,S
L13->Y:$9FE9,0,24,S
L14->X:$9FE9,0,24,S
L15->Y:$9FE8,0,24,S
L16->X:$9FE8,0,24,S
L17->Y:$9FE7,0,24,S
L18->X:$9FE7,0,24,S
L19->Y:$9FE6,0,24,S
L20->X:$9FE6,0,24,S
L21->Y:$9FE5,0,24,S
L22->X:$9FE5,0,24,S
L23->Y:$9FE4,0,24,S
L24->X:$9FE4,0,24,S
L25->Y:$9FE3,0,24,S
L26->X:$9FE3,0,24,S
//
//  48 x 1 bit Booleans Temp. L-Variables
//
#define BL1T1       L27
#define BL1T2       L28
#define BL1T3       L29
#define BL1T4       L30
#define BL1T5       L31
#define BL1T6       L32
#define BL1T7       L33
#define BL1T8       L34
#define BL1T9       L35
#define BL1T10      L36
#define BL1T11      L37
#define BL1T12      L38
#define BL1T13      L39
#define BL1T14      L40
#define BL1T15      L41
#define BL1T16      L42
#define BL1T17      L43
#define BL1T18      L44
#define BL1T19      L45
#define BL1T20      L46
#define BL1T21      L47
#define BL1T22      L48
#define BL1T23      L49
#define BL1T24      L50
#define BL1T25      L51
#define BL1T26      L52
#define BL1T27      L53
#define BL1T28      L54
#define BL1T29      L55
#define BL1T30      L56
#define BL1T31      L57
#define BL1T32      L58
#define BL1T33      L59
#define BL1T34      L60
#define BL1T35      L61
#define BL1T36      L62
#define BL1T37      L63
#define BL1T38      L64
#define BL1T39      L65
#define BL1T40      L66
#define BL1T41      L67
#define BL1T42      L68
#define BL1T43      L69
#define BL1T44      L70
#define BL1T45      L71
#define BL1T46      L72
#define BL1T47      L73
#define BL1T48      L74
//
//  48 x 1 bit Booleans Temp. L-Variables Addresses
//
L27->Y:$9FE2,0
L28->Y:$9FE2,1
L29->Y:$9FE2,2
L30->Y:$9FE2,3
L31->Y:$9FE2,4
L32->Y:$9FE2,5
L33->Y:$9FE2,6
L34->Y:$9FE2,7
L35->Y:$9FE2,8
L36->Y:$9FE2,9
L37->Y:$9FE2,10
L38->Y:$9FE2,11
L39->Y:$9FE2,12
L40->Y:$9FE2,13
L41->Y:$9FE2,14
L42->Y:$9FE2,15
L43->Y:$9FE2,16
L44->Y:$9FE2,17
L45->Y:$9FE2,18
L46->Y:$9FE2,19
L47->Y:$9FE2,20
L48->Y:$9FE2,21
L49->Y:$9FE2,22
L50->Y:$9FE2,23
L51->X:$9FE2,0
L52->X:$9FE2,1
L53->X:$9FE2,2
L54->X:$9FE2,3
L55->X:$9FE2,4
L56->X:$9FE2,5
L57->X:$9FE2,6
L58->X:$9FE2,7
L59->X:$9FE2,8
L60->X:$9FE2,9
L61->X:$9FE2,10
L62->X:$9FE2,11
L63->X:$9FE2,12
L64->X:$9FE2,13
L65->X:$9FE2,14
L66->X:$9FE2,15
L67->X:$9FE2,16
L68->X:$9FE2,17
L69->X:$9FE2,18
L70->X:$9FE2,19
L71->X:$9FE2,20
L72->X:$9FE2,21
L73->X:$9FE2,22
L74->X:$9FE2,23
//
//  4 x 24 bit signed Temp. L & M Variable Unions
//                          Used to convert L->M or M->L Variables
//                          & are the same memory location.
#define ILM24T1     L75
#define ILM24T2     L76
#define ILM24T3     L77
#define ILM24T4     L78
//
//  4 x 24 bit signed Temp. L & M Variable Unions
//                          Used to convert L->M or M->L
//                          & are the same memory location.

#define IML24T1     M400
#define IML24T2     M401
#define IML24T3     M402
#define IML24T4     M403
//
//  4 x 24 bit signed Temp. L & M Variable Unions Addresses
//                          Used to convert L->M or M->L
//
L75->Y:$9FE1,0,24,S
L76->X:$9FE1,0,24,S
L77->Y:$9FE0,0,24,S
L78->X:$9FE0,0,24,S

M400->Y:$9FE1,0,24,S
M401->X:$9FE1,0,24,S
M402->Y:$9FE0,0,24,S
M403->X:$9FE0,0,24,S
//
//  8 x 48 bit Float Temp. P-Variables
//
#define FP48T1      P400
#define FP48T2      P401
#define FP48T3      P402
#define FP48T4      P403
#define FP48T5      P404
#define FP48T6      P405
#define FP48T7      P406
#define FP48T8      P407
//**************************************************************
//
//  End of Temporary L, P & M Variables
//
//**************************************************************
//**************************************************************
//
//  Start Permanent "TIMERTIC.PLC" L & M Variables
//
//**************************************************************

#define NCPLCTMTIC  L0      // L PLCC TIME TIC COMMON M-L VAR 24 BIT
#define NCPLCTMTIC_ADR      Y:$9FFE,0,24,S

#define PREVTIME    L79     // L VAR 24 BIT previous SERVOTIME
#define PREVTIME_ADR        Y:$9FDF,0,24,S

#define SERVOTIME   L80     // L VAR 24 BIT
#define SERVOTIME_ADR       X:$0,0,24,S

#define SCANCNT     L81     // L VAR 24 BIT SCAN AVERAGE COUNT
#define SCANCNT_ADR         X:$9FDF,0,24,S

#define NCPLCTMTIC_M  M404  // M PLCC TIME TIC COMMON M-L VAR 24 BIT
#define NCPLCTMTIC_M_ADR    Y:$9FFE,0,24,S

#define FDT_SUM     P408    // M 48 bit float - SCAN DT SUM
#define SERVOTMSF   P409    // M 48 bit float - Converts servo time to msec
#define RESTIME     P410    // M 48 bit float - Residual fractional PLC Scan Delta Time

;
; Define temporary variable use
;
#define SERVOTMP IL24T1         // GLOBAL TEMP VARIABLES
#define DT_L     ILM24T2        // UNION L & M 24 INTEGER
#define DT_M     IML24T2        // UNION M & L 24 INTEGER
#define FDT      FP48T1         // FLOAT 48 BIT TEMP
#define IDT      FP48T2         // FLOAT 48 BIT TEMP
#define IRESTIME FP48T3         // FLOAT 48 BIT TEMP

;***************************************************************************
; Clears UBUFFER up to $9FFC
;
#define ZERO_PTR        M405    // !!! IF CHANGE, MUST CHANGE ZERO_INDX_ADR !!
#define ZERO_PTR_ADR    L:$9FFC
#define ZERO_INDX       L82
#define ZERO_INDX_ADR   Y:$BD95,0,16,U  // DEFINE ADDRESS OF M405
#define PMAC_RAM_END    L83
#define PMAC_RAM_END_ADR   X:$F3F,0,16,U  // DEFINE ADDRESS OF END OF PMAC RAM BUF
#define END_OF_USER_BUF $9FFD
;***************************************************************************

ZERO_PTR->ZERO_PTR_ADR
ZERO_INDX->ZERO_INDX_ADR
PMAC_RAM_END->PMAC_RAM_END_ADR
NCPLCTMTIC->NCPLCTMTIC_ADR
NCPLCTMTIC_M->NCPLCTMTIC_M_ADR
SERVOTIME->SERVOTIME_ADR
PREVTIME->PREVTIME_ADR
SCANCNT->SCANCNT_ADR
ES_PMACTMTIC_M->ES_PMACTMTIC_ADR
ES_SCANAVE_M->ES_SCANAVE_ADR
ES_SCANMAX_M->ES_SCANMAX_ADR

//**************************************************************
//  TIMERTIC PLCC END
//
#define TIMERTIC_PLCC 1         // TIMER TIC PLCC NUMBER
//
//**************************************************************


////////////////////////////////////////////////////////////////////////////
// macro definitions for PUNSET reserves M416..M437
////////////////////////////////////////////////////////////////////////////
#define AXIS_DEF_OFS1_M     M416
#define AXIS_DEF_OFS2_M     M417
#define AXIS_DEF_OFS3_M     M418
#define AXIS_DEF_OFS4_M     M419
#define AXIS_DEF_OFS5_M     M420
#define AXIS_DEF_OFS6_M     M421
#define AXIS_DEF_OFS7_M     M422
#define AXIS_DEF_OFS8_M     M423
#define AXIS_DEF_OFS1_ADR   L:$825
#define AXIS_DEF_OFS2_ADR   L:$8E5
#define AXIS_DEF_OFS3_ADR   L:$9A5
#define AXIS_DEF_OFS4_ADR   L:$A65
#define AXIS_DEF_OFS5_ADR   L:$B25
#define AXIS_DEF_OFS6_ADR   L:$BE5
#define AXIS_DEF_OFS7_ADR   L:$CA5
#define AXIS_DEF_OFS8_ADR   L:$D65

AXIS_DEF_OFS1_M->AXIS_DEF_OFS1_ADR
AXIS_DEF_OFS2_M->AXIS_DEF_OFS2_ADR
AXIS_DEF_OFS3_M->AXIS_DEF_OFS3_ADR
AXIS_DEF_OFS4_M->AXIS_DEF_OFS4_ADR
AXIS_DEF_OFS5_M->AXIS_DEF_OFS5_ADR
AXIS_DEF_OFS6_M->AXIS_DEF_OFS6_ADR
AXIS_DEF_OFS7_M->AXIS_DEF_OFS7_ADR
AXIS_DEF_OFS8_M->AXIS_DEF_OFS8_ADR

#define POS_BIAS1_M       M424
#define POS_BIAS2_M       M425
#define POS_BIAS3_M       M426
#define POS_BIAS4_M       M427
#define POS_BIAS5_M       M428
#define POS_BIAS6_M       M429
#define POS_BIAS7_M       M430
#define POS_BIAS8_M       M431

#define POS_BIAS1_ADR     D:$813
#define POS_BIAS2_ADR     D:$8D3
#define POS_BIAS3_ADR     D:$993
#define POS_BIAS4_ADR     D:$A53
#define POS_BIAS5_ADR     D:$B13
#define POS_BIAS6_ADR     D:$BD3
#define POS_BIAS7_ADR     D:$C93
#define POS_BIAS8_ADR     D:$D53

POS_BIAS1_M->POS_BIAS1_ADR
POS_BIAS2_M->POS_BIAS2_ADR
POS_BIAS3_M->POS_BIAS3_ADR
POS_BIAS4_M->POS_BIAS4_ADR
POS_BIAS5_M->POS_BIAS5_ADR
POS_BIAS6_M->POS_BIAS6_ADR
POS_BIAS7_M->POS_BIAS7_ADR
POS_BIAS8_M->POS_BIAS8_ADR

#define U_CMD_POS_M       M432
#define V_CMD_POS_M       M433
#define W_CMD_POS_M       M434
#define A_CMD_POS_M       M435
#define B_CMD_POS_M       M436
#define C_CMD_POS_M       M437

#define U_CMD_POS_ADR     L:$81C
#define V_CMD_POS_ADR     L:$81D
#define W_CMD_POS_ADR     L:$81E
#define A_CMD_POS_ADR     L:$819
#define B_CMD_POS_ADR     L:$81A
#define C_CMD_POS_ADR     L:$81B

U_CMD_POS_M->U_CMD_POS_ADR
V_CMD_POS_M->V_CMD_POS_ADR
W_CMD_POS_M->W_CMD_POS_ADR
A_CMD_POS_M->A_CMD_POS_ADR
B_CMD_POS_M->B_CMD_POS_ADR
C_CMD_POS_M->C_CMD_POS_ADR


////////////////////////////////////////////////////////////////////////////
// macro definitions for HANDLE.PLC (plc 4) reserves M440..M469, P440..P469
////////////////////////////////////////////////////////////////////////////

#define TARGET_POS_1        P440    // The new position for an incremental jog
#define TARGET_POS_2        P441    // which is performed every 100 ms in counts
#define TARGET_POS_3        P442
#define TARGET_POS_4        P443    // The new position for an incremental jog
#define TARGET_POS_5        P444    // which is performed every 100 ms in counts
#define TARGET_POS_6        P445
#define TARGET_POS_7        P446
#define TARGET_POS_8        P447

#define HANDLE_FACTOR_1     P448    // Scale factor for handling a change in
#define HANDLE_FACTOR_2     P449    // handle counts
#define HANDLE_FACTOR_3     P450
#define HANDLE_FACTOR_4     P451    // Scale factor for handling a change in
#define HANDLE_FACTOR_5     P452    // handle counts
#define HANDLE_FACTOR_6     P453
#define HANDLE_FACTOR_7     P454
#define HANDLE_FACTOR_8     P455

#define INIT_HANDLE         P456    // Flag for initializing the handwheel
#define HANDLE_CHANGE       P457    // The change in counts of the handwheel
#define PREV_HANDLE_COUNT   P458    // The handle counts for previous PLC scan

#define PREV_1_JOG_SPEED        P459
#define PREV_2_JOG_SPEED        P460
#define PREV_3_JOG_SPEED        P461
#define PREV_4_JOG_SPEED        P462
#define PREV_5_JOG_SPEED        P463
#define PREV_6_JOG_SPEED        P464
#define PREV_7_JOG_SPEED        P465
#define PREV_8_JOG_SPEED        P466

#define TARGET_POS1_M       M440     // The position to perform incremental jog.
#define TARGET_POS1_ADR     L:$82B   // For use with the CMD"J=*"
#define TARGET_POS2_M       M441
#define TARGET_POS2_ADR     L:$8EB
#define TARGET_POS3_M       M442
#define TARGET_POS3_ADR     L:$9AB
#define TARGET_POS4_M       M443
#define TARGET_POS4_ADR     L:$A6B
#define TARGET_POS5_M       M444
#define TARGET_POS5_ADR     L:$B2B
#define TARGET_POS6_M       M445
#define TARGET_POS6_ADR     L:$BEB
#define TARGET_POS7_M       M446
#define TARGET_POS7_ADR     L:$CAB
#define TARGET_POS8_M       M447
#define TARGET_POS8_ADR     L:$D6B


#define DESIRED_POS1_M      M448    // The current commanded position used for
#define DESIRED_POS1_ADR    D:$28   // initialization
#define DESIRED_POS2_M      M449
#define DESIRED_POS2_ADR    D:$64
#define DESIRED_POS3_M      M450
#define DESIRED_POS3_ADR    D:$A0
#define DESIRED_POS4_M      M451    // The current commanded position used for
#define DESIRED_POS4_ADR    D:$DC   // initialization
#define DESIRED_POS5_M      M452
#define DESIRED_POS5_ADR    D:$118
#define DESIRED_POS6_M      M453
#define DESIRED_POS6_ADR    D:$154
#define DESIRED_POS7_M      M454
#define DESIRED_POS7_ADR    D:$190
#define DESIRED_POS8_M      M455
#define DESIRED_POS8_ADR    D:$1CC

// See PAGE 8-11 of PMAC Software Reference
// ----------------------------------------
//                  Axis Label
//
//   Motor No.  |  X or U or A or B or C |   Y or V   |  Z or W
//    --------------------------------------------------------------
//        1     |      L:$822            |   L:$823   |     L:$824
//        2     |      L:$8E2            |   L:$8E3   |     L:$8E4
//        3     |      L:$9A2            |   L:$9A3   |     L:$9A4
//        4     |      L:$A62            |   L:$A63   |     L:$A64
//        5     |      L:$B22            |   L:$B23   |     L:$B24
//        6     |      L:$BE2            |   L:$BE3   |     L:$BE4
//        7     |      L:$CA2            |   L:$CA3   |     L:$CA4
//        8     |      L:$D62            |   L:$D63   |     L:$D64
//
//   Pulses per units is on a motor basis. The addresses are currently set up to
//   use motor 1 as X, motor 2 as Y, motor 3 as Z. It may be necessary to alter
//   the motor addresses if so use the chart above to choose the appropiate
//   address for the pulses per unit address.

#define PULSES_PER_UNIT_1      M456
#define PULSES_PER_UNIT1_ADR   L:$822       // Motor 1 is axis X
#define PULSES_PER_UNIT_2      M457
#define PULSES_PER_UNIT2_ADR   L:$8E3       // Motor 2 is axis Y
#define PULSES_PER_UNIT_3      M458
#define PULSES_PER_UNIT3_ADR   L:$9A4       // Motor 3 is axis Z
#define PULSES_PER_UNIT_4      M459
#define PULSES_PER_UNIT4_ADR   L:$A63
#define PULSES_PER_UNIT_5      M460
#define PULSES_PER_UNIT5_ADR   L:$B24
#define PULSES_PER_UNIT_6      M461
#define PULSES_PER_UNIT6_ADR   L:$BE2
#define PULSES_PER_UNIT_7      M462
#define PULSES_PER_UNIT7_ADR   L:$CA2
#define PULSES_PER_UNIT_8      M463
#define PULSES_PER_UNIT8_ADR   L:$D62


#define HANDLE_COUNT_M      M464            // The address of the handle counter
#define HANDLE_COUNT_ADR    Y:$0770,0,24,S

DESIRED_POS1_M->DESIRED_POS1_ADR
DESIRED_POS2_M->DESIRED_POS2_ADR
DESIRED_POS3_M->DESIRED_POS3_ADR
DESIRED_POS4_M->DESIRED_POS4_ADR
DESIRED_POS5_M->DESIRED_POS5_ADR
DESIRED_POS6_M->DESIRED_POS6_ADR
DESIRED_POS7_M->DESIRED_POS7_ADR
DESIRED_POS8_M->DESIRED_POS8_ADR

TARGET_POS1_M->TARGET_POS1_ADR
TARGET_POS2_M->TARGET_POS2_ADR
TARGET_POS3_M->TARGET_POS3_ADR
TARGET_POS4_M->TARGET_POS4_ADR
TARGET_POS5_M->TARGET_POS5_ADR
TARGET_POS6_M->TARGET_POS6_ADR
TARGET_POS7_M->TARGET_POS7_ADR
TARGET_POS8_M->TARGET_POS8_ADR

HANDLE_COUNT_M->HANDLE_COUNT_ADR
PULSES_PER_UNIT_1->PULSES_PER_UNIT1_ADR
PULSES_PER_UNIT_2->PULSES_PER_UNIT2_ADR
PULSES_PER_UNIT_3->PULSES_PER_UNIT3_ADR
PULSES_PER_UNIT_4->PULSES_PER_UNIT4_ADR
PULSES_PER_UNIT_5->PULSES_PER_UNIT5_ADR
PULSES_PER_UNIT_6->PULSES_PER_UNIT6_ADR
PULSES_PER_UNIT_7->PULSES_PER_UNIT7_ADR
PULSES_PER_UNIT_8->PULSES_PER_UNIT8_ADR

#endif

