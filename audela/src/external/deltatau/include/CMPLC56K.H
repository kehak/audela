/*
        File: cmplc56k.h

        PMAC Compiled PLC Motorola DSP 56000 defines

        Author(s):      Ed Lay

        08/03/93      EBL     Created

        Change log:

          Date       Rev     Who         Description
        ---------    -----   -----   -----------------------------------------
        01/11/4              EBL     Changes for windows DLL
        02/09/4              EBL     Changes for integer math & size of 56k used
        03/08/5              EBL     ADD LADDER FUNCTION BLOCK CODE

*/
//

//***************************************************************
//**  Instruction Defines **
//***************************************************************

#define JSR             0x0D0000
#define JSRL            0x0BF080
#define MOVItoN4        0x3C0000 // MOV IMMEDIATE SHORT TO REG 'N4'
#define MOVILtoN4       0x74F400 // MOV IMMEDIATE LONG  TO REG 'N4'
#define MOVItoR1        0x61F400 // MOV IMMEDIATE LONG  TO REG 'R1'
#define MOVItoR2        0x62F400 // MOVE #LONG_ADDR,R2
#define MOVEAtoXR2      0x565A00 // MOVE A,X:(R2)+
#define MOVER2toXSM     0x620000 // MOVE R2,X:ADDR short + ADDR << 8
#define MOVER2toYSM     0x6A0000 // MOVE R2,Y:ADDR short + ADDR << 8
#define MOVItoR4        0x64F400 // MOV IMMEDIATE LONG  TO REG 'R4'
#define MOVIStoR4       0x340000 // MOV IMMEDIATE SHORT TO REG 'R4'
#define MOVItoB1        0x55F400 // MOV IMMEDIATE LONG  TO REG 'B1'
#define MOVIStoB1       0x2D0000 // MOV IMMEDIATE SHORT TO REG 'B1'
#define MOVItoR5        0x65F400 // MOV IMMEDIATE LONG  TO REG 'R5'
#define MOVEMR4toP      0x077094 // MOVEM R4,P:$ADDR
#define MOVEMPtoR4      0x07F094 // MOVEM P:$ADDR,R4
                                 //
                                 //      56K code for ADDRESS command
                                 //
#define MOVEMPtoX0      0x07F084 // MOVEM P:$ADDR,X0
#define MOVEMPtoA       0x07F08E // MOVEM P:$ADDR,A
#define MOVIStoA        0x2E0000 // MOV IMMEDIATE SHORT TO REG 'A'
#define NOTAISX1        0x250017 // NOT A #SDATA,X1
#define ANDX0A          0x200046 // AND X0,A
#define ORX1A           0x200062 // OR  X1,A
#define MOVEMA1toP      0x07708C // MOVEM A1,P:#$ADDR
#define ANDILA          0x0140C6 // AND #$7FFFF,A
#define ORILA           0x0140C2 // OR #$7FFFF,A
                                 //
                                 //      56K code for CMD ^ command
                                 //
#define MOVIStoA1       0x2C0000 // MOVE IMMEDIATE SHORT TO REG 'A1'
#define MOVA1XR3        0x545B00 // MOVE  A1,X:(R3)+
                                 //
                                 //      56K code for String commands SEND, SENDP, SENDS, CMD
                                 //
#define MOVEMR4toP      0x077094 // MOVEM R4,P:$ADDR
#define MOVEYMtoA       0x5EF000 // MOVE Y:$ADDR,A ADDR = CMD_STACK
#define MOVEYSMtoA      0x5E8000 // MOVE Y:$SADDR,A + $SADDR << 8
#define TSTAItoX1       0x45F403 // TST A        #ADDRofSTRING,X1
#define TSTAItoR1       0x61F403 // TST A        #ADDRofSTRING,R1
#define MOVEMR1toA      0x07D98E // MOVEM   P:(R1)+,A
#define ADDX1AItoX0     0x24FF60 // ADD X1,A     #$FF,X0
#define ANDX0toB        0x20004E // AND X0,B
#define ADDBtoA         0x200010 // ADD B,A
#define MOVEA1toYM      0x5C7000 // MOVE A1,Y:$CMD_STACK
#define CLRB_R5toR4     0x22B41B // CLR B        R5,R4
#define MOVER4toR5      0x229500 // MOVE         R4,R5
#define MOVEMPtoB1      0x07F08D // MOVEM P:$C.S ADDR,B1
#define MOVEMPtoB       0x07F08F // MOVEM P:$C.S ADDR,B
#define MOVEYR5toR5     0x6DE500 // MOVE Y:(R5),R5
#define MOVEYR5toR1     0x69E500 // MOVE Y:(R5),R1
#define MOVXP_BASEtoR5  0x65A400 // MOVE X:P_BASE,R5
                                 //
                                 //      56K code for Q Write
                                 //
#define MOVEMPRtoR5     0x07ED95 // MOVEM P:(R5+N5),R5
#define MOVItoN5        0x3D0000 // MOVE #QNUM,N5 ; where QNUM < 256
#define MOVILtoN5       0x75F400 // MOVE #QNUM,N5 ; LONG MOVE
#define MOVEILtoN5      0x75F400 // MOVE #QNUM,N5 ; LONG MOVE
#define MOVEILtoM5      0x05F425 // MOVE #$3FF,M5
#define MOVEAtoR5N5     0x486D00 // MOVE A,L:(R5+N5)
#define MOVEM4toM5      0x0465A4 // MOVE M4,M5
                                 //
                                 //      56K code for Q Read
                                 //
#define MOVELR5N5toA    0x48ED00 // MOVE L:(R5+N5),A
#define MOVELR5N5toX    0x42ED00 // MOVE L:(R5+N5),X
#define MOVELR5toX      0x42E500 // MOVE L:(R5),X
                                 //
                                 //      Lnn L-Variable code
                                 //
#define NOTA            0x200017 // NOT  A ; for "=" compare need the NOT
#define MOV0toA0        0x280000 // MOVE    #0,A0   ; CLR LSB OF A REG
#define NEGA            0x200036 // NEG  A
#define ANDX1A          0x200066 // AND  X1,A
#define ADDX1A          0x200060 // ADD  X1,A
#define EORX1A          0x200063 // EOR  X1,A also used on compare
#define SUBX1A          0x200064 // SUB  X1,A
#define ANDY1A          0x200076 // AND  Y1,A
#define ANDY1B          0x20007E // AND  Y1,B
#define EORY1B          0x20007B // EOR  Y1,B
#define EORY1A          0x200073 // EOR  Y1,A
#define ORY1B           0x20007A // OR   Y1,B
#define ORY1AB0toB      0x212F72 // OR   Y1,A   B0,B
#define ADDBtoA         0x200010 // ADD  B,A
#define MOVXADRtoX0     0x44F000 // MOVE X:$ADDR,X0
#define MOVXADRtoX1     0x45F000 // MOVE X:$ADDR,X1
#define MOVXADRtoA      0x56F000 // MOVE X:$ADDR,A
#define MOVXADRtoB      0x57F000 // MOVE X:$ADDR,B
#define MOVXSADRtoA     0x568000 // MOVE X:$SADDR,A  + SADDR << 8
#define MOVILtoY1       0x47F400 // MOV IMMEDIATE LONG TO REG 'Y1'
#define MOVItoY1        0x270000 // MOV IMMEDIATE SHORT TO REG 'Y1'
#define MOVEB0toX0      0x212400 // MOVE    B0,X0
#define MOVEA1toX0      0x218400 // MOVE    A1,X0
#define MOVEB1toA       0x21AE00 // MOVE    B1,A
#define MOVEB1toX1      0x21A500 // MOVE    B1,X1
#define MPYX0Y1AtoX1    0x2185C0 // MPY     X0,Y1,A   A1,X1
#define MPYX0Y1BIStoY1  0x2700C8 // MPY     X0,Y1,B   #<,Y1
#define MPYX0Y1BILtoY1  0x47F4C8 // MPY     X0,Y1,B   #>,Y1
#define MPYX0Y1A        0x2000C0 // MPY     X0,Y1,A
#define MPYX0Y1B        0x2000C8 // MPY     X0,Y1,B
#define MOVEA1toY1      0x218700 // MOVE    A1,Y1
#define MPYX1Y1A        0x2000F0 // MPY     X1,Y1,A
#define ASRA            0x200022 // ASR     A
#define MOVEA0toA       0x210E00 // MOVE    A0,A  SIGN EXTEND
#define MOVEA1toA       0x218E00 // MOVE    A1,A  SIGN EXTEND
#define MOVEB1toX1      0x21A500 // MOVE    B1,X1
#define LRSA            0x200023 // LSR     A
#define LSRInA          0x0C1EC0 // LSR     #n,A  + n << 1
#define CLRAA1toX1      0x218513 // CLR     A  A1,X1  ; LOAD CONSTANT 0
#define MOVA1toX1       0x218500 // MOVE    A1,X1 ; MOVE CURRENT A1 to X1
#define MOV1toA1        0x2C0100 // MOVE    #1,A1     ; LOAD CONSTANT 1
#define MOVEA1toXM      0x547000 // MOVE    A1,X:$MEM_ADDR
#define MOVEA1toSXM     0x540000 // MOVE    A1,X:$MEM_ADDR + SHORT MEM << 8
#define MOVEA1toSYM     0x5C0000 // MOVE    A1,Y:$MEM_ADDR + SHORT MEM << 8
#define BCLRXMEM        0x0A7000 // BCLR    #0,X:$D000
                                 // 0x0A7017          BCLR    #23,X:$D000
                                 // 0x0A7057          BCLR    #23,Y:$D000
#define BSETXMEM        0x0A7020 // BSET    #0,X:$D000
                                 //
                                 //      Other 56K code
                                 //
#define MOVEMPRtoR1     0x07ED91 // MOVEM P:(R5+N5),R1
#define MOVILtoA        0x56F400 // MOV IMMEDIATE LONG TO REG 'A'
#define MOVILtoA0       0x50F400 // MOV IMMEDIATE LONG TO REG 'A0'
#define MOVILtoX1       0x45F400 // MOV IMMEDIATE LONG TO REG 'X1'
#define MOVILtoX0       0x44F400 // MOV IMMEDIATE LONG TO REG 'X0'
#define MOVM5toX1       0x254000 // MOV IMMED .5 mantisa to X1
#define MOVPQtoA        0x48F000 // MOV P or Q TO A ( MOVE L:P000 ,A )
#define MOVPQtoX        0x42F000 // MOV P or Q TO X ( MOVE L:P000 ,X )
#define MOVAtoPQ        0x487000 // MOV A to P     ( MOVE A,L:P000 )
#define MOVAtoSTK       0x487F00 // MOV A to STACK ( MOVE A,L:-(R7) )
#define MOVXtoSTK       0x427F00 // MOV X to STACK ( MOVE X,L:-(R7) )
#define MOVSTKtoX       0x42DF00 // MOV STACK to X ( MOVE L:(R7)+,X )
#define MOVI79toM1      0x054FA1 // MOVE #79,M1
#define MOVM0toM1       0x0461A0 // MOVE M0,M1
#define SUBX0A          0x200044 // SUB  X0,A
#define JCC             0x0AF0A0 // JCC Carry Clr
#define JGE             0x0AF0A1 // JMP >=
#define JNE             0x0AF0A2 // JMP !=
#define JGT             0x0AF0A7 // JMP >
#define JCS             0x0AF0A8 // JCS Carry Set
#define JLT             0x0AF0A9 // JMP <
#define JEQ             0x0AF0AA // JMP =
#define JLE             0x0AF0AF // JMP <=
#define JMP             0x0AF080 // JMP LONG
#define RTS             0x00000C // RET from S/R
#define NOP             0        // NOP
#define BEQ             0x05A400 // BEQ + ( offset )
#define BRA             0x050C00 // BRA + ( offset )

//***************************************************************
//**  Conditional JMP Flag Defines **
//***************************************************************

#define JMP_TRUE        0x1000000 // Conditional JMP True flag
#define JMP_FALSE       0x2000000
#define IFWHL_START     0x4000000 // If - While Start Flag
#define ANDOR_START     0x8000000 // AND - OR CMD Start Flag
#define ENDWCODE        6         // End While code 56k locations

//****************************************************************************
//
//**    Defines for strings types for 56k code
//
//****************************************************************************

#define CMD             0 // Code for 1st word of string
#define SENDP           0x10
#define SENDS           0x20
#define SEND            0x30
//
//**    Defines for strings types for 56k Turbo code
//
#define TSENDP          0x14
#define TSENDR          0x24
#define TSENDS          0x34
#define TSENDA          0x44
#define TSENDM          0x54
#define TCMD            0x84

//***************************************************************
//**  Function Addresses **
//***************************************************************
#define I_SUB           0x0040CE
#define M_SUB           0x0040D6
#define P_SUB           0x0040DE
#define Q_SUB           0x0040E3
#define FSIN            0x000A2E
#define FCOS            0x000AC5
#define FTAN            0x000AF2
#define FABS            0x0008D9
#define FASIN           0x000BC3
#define FACOS           0x000BD0
#define FATAN           0x000BE9
#define FSQRT           0x000A01
#define FEXP            0x000D4A
#define FLN             0x000CDD
#define FINT            0x000DCD
#define FATAN2          0x000BDA

//***************************************************************
//**  Operator Addresses **
//***************************************************************

#define FADD_XA         0x0008E2
#define FSUB_XA         0x000918
#define FMPY_XA         0x00093E
#define FDIV_XA         0x000975
#define FOR_XA          0x0009D5
#define FEOR_XA         0x0009DB
#define FAND_XA         0x0009CF
#define FMOD_XA         0x0009A0
#define FSUB_AX         0x0008E1
#define FDIV_AX         0x000967
#define FMOD_AX         0x000993

//***************************************************************
//**  Other Addresses **
//***************************************************************

#define I_READ 0x001B23
#define M_READ 0x0015F7
#define I_WRITE 0x001B5F
#define M_WRITE 0x001768

#define FNEG            0x0008DD
#define FCMP_XA         0x000922
#define PACK            0x000DF4
#define UNPACK          0x000DE5
#define PLCENADIS       0x001C1C
#define PLCQ_BASE       0x005B29
#define MOVPDISP        0x00222F
#define FTOAF           0x000EF8

//***************************************************************
//** Addresses that do not change **
//***************************************************************

#define PBUFFER         0x1000

//#define QBUFFER         0x1400
#define PLCBUFFER       0x8000
#define PLCJMPOFF       0x20
#define PLCRETOFF       PLCJMPOFF + 2 * 32 // number of PLCC's * 2
// #define PLCJMP          PLCBUFFER + PLCJMPOFF
// #define PLCRET          PLCBUFFER + PLCRETOFF
// #define PLCSTART        PLCRET + 2         // allow room for size of mem used
// #define PLCCSIZE        PLCRET + 1         // PLCC size stored by compiler
#define PLCCEXSIZE      98                 // PLCC Executive size
#define PLCEND          16
#define DISPLAY         0x000780           // Display Buffer Addr
#define FPTEN           0x0007DE           // FPTEN Address Table
#define CMD_STACK       0x00075A           // PMAC PLC CMD Stack
#define PLCREQ          0x031              // TURB0 PLC CMD Stack(X: PLCn, Y: PLC0 )
#define PLC_IN_PTR      0x032              // TURB0 PLC INP END PTR(X: PLCn, Y: PLC0 )
#define PLCN_BUFFER     0x1600             // TURBO PLCn1..31 BUFFER
#define PLC0_BUFFER     0x1500             // TURBO PLC 0 BUFFER
#define TDISPLAY        0x001080           // TURBO Display Buffer Addr
#define TFPTEN          0x0010DE           // TURBO FPTEN Address Table



