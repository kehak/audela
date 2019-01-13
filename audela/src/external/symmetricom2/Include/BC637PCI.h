//***************************************************************************
//
// BC637PCI.h
//
// Version 10.0.0
//
// BCPCI API definitions
//
// Copyright (c) Symmetricom - 2009
//
//***************************************************************************

#ifndef __BC637PCI_H__
#define __BC637PCI_H__

// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the BC637PCI_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// BC637PCI_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef BC637PCI_EXPORTS
#define BC637PCI_API __declspec(dllexport)
#else
#define BC637PCI_API __declspec(dllimport)
#endif

// Have to figure out how to support fastcall in x64.
#ifdef _WIN32
#define BC637PCI_CONV WINAPI
#else
#ifdef _WIN64
#define BC637PCI_CONV __fastcall
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

//***************************************************************************
// TimeData Data Structure
//***************************************************************************
typedef struct _TimeData {
    INT tmformat;       // Time format (i.e. bin or bcd)
    INT year;           // Current year data
    INT leapyear;       // 1 = true 0 = false
    INT utcctl;         // Enable/Disable UTC info usage
    INT leapsec;        // Current leap second count
    INT leapevt;        // Current leap second event type (1=ins,0=no,-1=del)
    INT leapevttm;      // Scheduled time for leap second event
    SHORT locoff;       // Local time offset
    UCHAR lhlfhr;       // Local time offset half hour flag
    long int pdelay;    // Phase delay
    INT dlight;         // IEEE Daylight Savings Flag 
    INT localt;         // Local Time Flag Enable/Disable
} TimeData;

//***************************************************************************
// TimeCodeData Data Structure
//***************************************************************************
typedef struct _TimeCodeData {
    INT format;         // Time Code Decode Type 
    INT modulation;     // Time Code Decode Modulation
    INT gencode;        // Time Code Generator Type
    SHORT genoffset;    // Time Code Generator Offset
    UCHAR ghfhr;        // Time Code Gen Offset half Hour flag 0/1
} TimeCodeData;

//***************************************************************************
// TimeCodeDataEx Data Structure
//***************************************************************************
typedef struct _TimeCodeDataEx {
    INT inputFormat;    // Time Code Decode Type
    INT inputSubType;   // Input Time Code SubType, supported on V2 hardware
    INT modulation;     // Time Code Decode Modulation
    INT outputFormat;   // Time Code Generator Type
    INT outputSubType;  // Output Time Code SubType, supported on V2 hardware
    SHORT genoffset;    // Time Code Generator Offset
    UCHAR ghfhr;        // Time Code Gen Offset half Hour flag 0/1
} TimeCodeDataEx;

//***************************************************************************
// OscData Data Structure
//***************************************************************************
typedef struct _OscData {
    INT BattStat;       // Real Time Clock Battery status
    INT ClkSrc;         // Selected Clock input
    INT DisCtl;         // Disciplining Enable/Disable
    float DisKval;      // Disciplining Filter Constant
    SHORT DisGain;      // Disciplining Gain
    SHORT DacVal;       // DAC Value
    INT JamCtl;         // Jamsynch Enable/Disable
    INT JamWin;         // Jamsynch Window
    INT PhzCtl;         // Phase Enable/Disable
    INT PhzLmt;         // Phase Shift Limit
    LONG AdjClk;        // Advance/Retard Clock Value
} OscData;

//***************************************************************************
// OtherData Data Structure
//***************************************************************************
typedef struct _OtherData {
    INT mode;           // Selected Reference mode
    INT hbtmode;        // Heartbeat/Periodic mode (0=async,1=sync)
    INT hbtcnt1;        // Heartbeat/Periodic n1
    INT hbtcnt2;        // Heartbeat/Periodic n2
    INT freq;           // Current freq output (1,5,10MHz)
    INT evtctl;         // Enable/Disable events
    INT evtsense;       // Event trigger on edge (1=falling,0=rising)
    INT evtlock;        // Enable/Disable event capture lockout
    INT evtsrc;         // Event trigger source (0=evt,1=hbt)
} OtherData;

//***************************************************************************
// OtherDataEx Data Structure
//***************************************************************************
typedef struct _OtherDataEx {
    INT mode;           // Selected Reference mode
    INT hbtmode;        // Heartbeat/Periodic mode (0=async,1=sync)
    INT hbtcnt1;        // Heartbeat/Periodic n1
    INT hbtcnt2;        // Heartbeat/Periodic n2
    INT freq;           // Current freq output (1,5,10MHz)
    INT evtctl;         // Enable/Disable event
    INT evtsense;       // Event trigger on edge (1=falling,0=rising)
    INT evtlock;        // Enable/Disable event capture lockout
    INT evtsrc;         // Event trigger source (0=evt,1=hbt)
    INT evt2ctl;        // Enable/Disable event2
    INT evt2sense;      // Event2 trigger on edge (1=falling,0=rising)
    INT evt2lock;       // Enable/Disable event2 capture lockout
    INT evt3ctl;        // Enable/Disable event3
    INT evt3sense;      // Event3 trigger on edge (1=falling,0=rising)
    INT evt3lock;       // Enable/Disable event3 capture lockout
} OtherDataEx;

//***************************************************************************
// OtherDataEx Data Structure
//***************************************************************************
typedef struct _EventsData {
    INT evtsrc;         // Event trigger source (0=evt,1=hbt)
    INT evtctl;         // Enable/Disable events
    INT evtsense;       // Event trigger on edge (1=falling,0=rising)
    INT evtlock;        // Enable/Disable event capture lockout
    INT evt2ctl;        // Enable/Disable event2
    INT evt2sense;      // Event2 trigger on edge (1=falling,0=rising)
    INT evt2lock;       // Enable/Disable event2 capture lockout
    INT evt3ctl;        // Enable/Disable event3
    INT evt3sense;      // Event3 trigger on edge (1=falling,0=rising)
    INT evt3lock;       // Enable/Disable event3 capture lockout
} EventsData;

//***************************************************************************
// VerData Data Structure
//***************************************************************************
typedef struct _VerData {
    INT majver;         // Major Version Number
    INT minver;         // Minor Version Number
    INT month;          // Month of build
    INT day;            // Day of build
    INT year;           // Year of build
    UCHAR byt1;         // DT Number "D"
    UCHAR byt2;         // DT Number "T"
    UCHAR byt3;         // DT Number "6"
    UCHAR byt4;         // DT Number "0"
    UCHAR byt5;         // DT Number "0"
    UCHAR byt6;         // DT Number "0"
    UCHAR byt7;         // DT Number "A,B,C..."
    UCHAR byt8;         // DT Number "."
    UCHAR byt9;         // DT Number "1,2.."
    UCHAR byt10;        // DT Number "1,2.."
    UCHAR byt11;        // DT Number "1,2.."
} VerData;

//***************************************************************************
// ManufData Data Structure
//***************************************************************************
typedef struct _ManufData
{
    INT BootCfg;        // Boot Configration
    INT Assembly;       // Assembly Part Number
    INT HwFab;          // Hardware Fab Number
    ULONG Serial;       // Hardware Serial Number
    UCHAR model1;       // Model 'B'
    UCHAR model2;       // Model 'C'
    UCHAR model3;       // Model '6'
    UCHAR model4;       // Model '3'
    UCHAR model5;       // Model '5' or '7'
    UCHAR model6;       // Model 'P'
    UCHAR model7;       // Model 'C'
    UCHAR model8;       // Model 'I'
} ManufData;

//***************************************************************************
// GpsPkt Data Structure
//***************************************************************************
typedef struct _GpsPkt {
    UCHAR id;           // GPS Packet ID Byte
    UCHAR len;          // GPS Packet Data Length
    UCHAR *data;        // GPS Packet Data Area Pointer
} GpsPkt;

//***************************************************************************
// pcidata Data Structure
//***************************************************************************
typedef struct _pcidata {
    USHORT majorVer;        // driver major version number
    USHORT minorVer;        // minor version number
    ULONG busType;          // type of bus, see INTERFACE_TYPE
    ULONG busNumber;        // number of bus: 0
    ULONG ioIncrement;      // priority boast
    ULONG portMin;          // minimum port address
    ULONG portMax;          // maximum port address
    ULONG memMin;           // minimum memory address
    ULONG memMax;           // maximum memory address
    ULONG interruptVector;  // interrupt vector
    ULONG interruptLevel;   // interrupt level, section 1 data
    ULONG portMin1;         // minimum port address
    ULONG portMax1;         // maximum port address
    ULONG memMin1;          // minimum memory address
    ULONG memMax1;          // maximum memory address
} pcidata;

//***************************************************************************
// pcicfg Config Structure
//***************************************************************************
typedef struct _pcicfg {    // PCI Configuration Register
    USHORT VendorID;        // PCI device vendor ID
    USHORT DeviceID;        // PCI device device ID
    USHORT Command;         // PCI Command Register
    USHORT Status;          // PCI Status Register
    UCHAR RevID;            // PCI Revision ID
    INT ClassCode;          // PCI Class Code  
    USHORT SubVenID;        // PCI Subsytem vendor ID
    USHORT SubID;           // PCI Subsystem ID
    UCHAR IntLine;          // PCI Interrupt Line
    UCHAR IntPin;           // PCI Interrupt Pin
} pcicfg;

//***************************************************************************
// pOffs offset Structure
//***************************************************************************
typedef struct _pOffs {
    INT pIn;            // DPRAM Input Packet Area
    INT pOut;           // DPRAM Output Packet Area
    INT pGPS;           // DPRAM GPS Output Packet Area
    INT pYear;
} pOffs;

//***************************************************************************
// IAFStruct IAF Data Structure
//***************************************************************************
typedef struct _IAFStruct {
    UCHAR SignByte;
    UCHAR HoldByte;
    UCHAR Seconds;
    UCHAR Minutes;
    UCHAR Hours;
    INT Ctrl_LSB;
    INT Ctrl_MSB;
} IAFStruct;

//***************************************************************************
// Return Codes 
//***************************************************************************
#define RC_OK                   (0)
#define RC_ERROR                (-1)

// Return code from calling a function supported in V2+ only hardware.
#define RC_HW_V1                (-2)

//***************************************************************************
// Register Offsets
//***************************************************************************
#define PCI_OFFSET_CTL          0x10
#define PCI_OFFSET_ACK          0x14
#define PCI_OFFSET_INT_MASK     0x18
#define PCI_OFFSET_INT_STAT     0x1C

//***************************************************************************
// SET_MODE SELECTS
//***************************************************************************
#define MODE_IRIG               0x00
#define MODE_FREE               0x01
#define MODE_1PPS               0x02
#define MODE_RTC                0x03
#define MODE_GPS                0x06

//***************************************************************************
// SET_TCODE SELECTS INPUT FORMAT
//***************************************************************************
#define TCODE_IRIG_A            'A'
#define TCODE_IRIG_B            'B'
// Note: In V1 hardware, 2137 was defined as 'C'. On V2 hardware, this is
// defined as '2'. The 'C' should be used on V1 hardware when calling
// bcSetTcIn(), which is modified to send command 'C' instead of '2'.
//#define TCODE_2137            'C'
#define TCODE_NASA36            'N'
#define TCODE_XR3               'X'
#define TCODE_IEEE              'I'

//***************************************************************************
// ADDITIONAL TIME CODE TYPE FOR V2 HARDWARE
//***************************************************************************
#define TCODE_2137              '2'
#define TCODE_IRIG_E            'E'
#define TCODE_IRIG_G            'G'
#define TCODE_IRIG_e            'e'

//***************************************************************************
// IRIG TIME CODE SUB TYPE.
// The sub type is used when calling
//
//   bcSetTcInEx (UCHAR TcIn, UCHAR SubType, UCHAR mod)
//   bcSetGenCodeEx (UCHAR GenTc, UCHAR SubType)
//
// For time code with no sub type, please input TCODE_IRIG_SUBTYPE_NONE
// as 'SubType'. See 'bcSetTcInEx()' comment.
//***************************************************************************

//***************************************************************************
// This is for time code with no sub type.
//***************************************************************************
#define TCODE_IRIG_SUBTYPE_NONE 0

//***************************************************************************
// Sub type 'Y' can be used with IRIG A, B, E, e
//   AY - IRIG A with year
//   BY - IRIG B with year
//   EY - IRIG E 1000 with year
//   eY - IRIG E 100 with year
// This is an input time code sub type - used as SubType in bcSetTcInEx().
//***************************************************************************
#define TCODE_IRIG_SUBTYPE_Y    'Y'

//***************************************************************************
// Sub type 'T' is used with IRIG B
//   BT - IRIG B Legacy TrueTime
//***************************************************************************
#define TCODE_IRIG_SUBTYPE_T    'T'

//***************************************************************************
// Output time code sub type - used as SubType in bcSetGenCodeEx().
// See 'bcSetGenCodeEx()' comment.
//***************************************************************************
#define TCODE_IRIG_SUBTYPE_0    '0'
#define TCODE_IRIG_SUBTYPE_1    '1'
#define TCODE_IRIG_SUBTYPE_2    '2'
#define TCODE_IRIG_SUBTYPE_3    '3'
#define TCODE_IRIG_SUBTYPE_4    '4'
#define TCODE_IRIG_SUBTYPE_5    '5'
#define TCODE_IRIG_SUBTYPE_6    '6'
#define TCODE_IRIG_SUBTYPE_7    '7'

//***************************************************************************
// SET_TCODE SELECTS INPUT MODULATION  
//***************************************************************************
#define TCODE_MOD_AM            'M'
#define TCODE_MOD_DC            'D'

//***************************************************************************
// SET_GEN_CODE SELECTS
//***************************************************************************
#define TCODE_GEN_B             'B'
#define TCODE_GEN_I             'I'

//***************************************************************************
// SET_CLK_SRC SELECTS
//***************************************************************************
#define CLK_INT                 'I'
#define CLK_EXT                 'E'

//***************************************************************************
// HEARTBEAT MODE
//***************************************************************************
#define HB_NO_SYNC              0
#define HB_SYNC                 1

//***************************************************************************
// Various Flags
//***************************************************************************
#define GPS_NONE_STATIC         (0)
#define GPS_STATIC              (1)
#define LOCAL_FLAG_DIS          (0)
#define LOCAL_FLAG_ENA          (1)
#define DAY_LIGHT_DIS           (0)
#define DAY_LIGHT_ENA           (1)
#define YEAR_AUTO_DIS           (0)
#define YEAR_AUTO_ENA           (1)

//***************************************************************************
// CONTROL DEFS
//***************************************************************************
#define LOCK_EN                 (1<<0)
#define HB_EN                   (1<<1)
#define EVT_SNS_POS             (0<<2)
#define EVT_SNS_NEG             (1<<2)
#define EVT_EN                  (1<<3)
#define STR_EN                  (1<<4)
#define STR_MOD_MAJ             (0<<5)
#define STR_MOD_MIN             (1<<5)
#define FREQ_10_MHZ             (0)
#define FREQ_5_MHZ              (1<<6)
#define FREQ_1_MHZ              (1<<7)

//***************************************************************************
// ACK REG DEFS
//***************************************************************************
#define ACK_RCV                 (1<<0)
#define ACK_DPA                 (1<<2)
#define ACK_FIFO                (1<<4)
#define ACK_CLR                 (1<<4)
#define ACK_SEND                (1<<7)

//***************************************************************************
// INT MASK/STATUS DEFS
//***************************************************************************
#define INT_EVENT               (1<<0)
#define INT_HBEAT               (1<<1)
#define INT_STROBE              (1<<2)
#define INT_1PPS                (1<<3)
#define INT_DPA                 (1<<4)
#define INT_EVENT2              (1<<5)
#define INT_EVENT3              (1<<6)

//***************************************************************************
// SET_COMMAND SELECTS
//***************************************************************************
#define CMD_WARMSTART           0x01
#define CMD_COLDSTART           0x02
#define CMD_JAM                 0x03
#define CMD_NO_JAM              0x04
#define CMD_SYNC_RTC            0x05

//***************************************************************************
// OTHER DATA
//***************************************************************************
#define REQ_RTC_TIME            0x00
#define REQ_DAC_VALUE           0x01
#define REQ_LEAP_SEC            0x02
#define REQ_PROG_DATA           0x03
#define REQ_MOD_VER             0x04
#define REQ_YEAR                0x05

//***************************************************************************
// Manuf Defines
//***************************************************************************
#define MODEL_ID                0x04
#define CRYSTAL_ID              0x03
#define SET_BC635               0x0635
#define SET_BC637               0x0637
#define STD_CRYSTAL             0x0002
#define MTI_CRYSTAL             0x0014
#define NORMAL_BOOT             0x0000
#define SPECIAL_BOOT            0x0100

//***************************************************************************
// The Revision ID for V2 hardware
//***************************************************************************
#define BC_PCI_V2_REV_ID_START  0x20
#define BC_PCI_V2_REV_ID_END    0x2F

//***************************************************************************
// Choices for bcSetPeriodicDDSSelect()
//***************************************************************************
#define SELECT_PERIODIC_OUT     0x0
#define SELECT_DDS_OUT          0x1

//***************************************************************************
// Choices for bcSetDDSDivider()
//***************************************************************************
#define DDS_DIVIDE_BY_1E0       0x0
#define DDS_DIVIDE_BY_1E1       0x1
#define DDS_DIVIDE_BY_1E2       0x2
#define DDS_DIVIDE_BY_1E3       0x3
#define DDS_DIVIDE_BY_1E4       0x4
#define DDS_DIVIDE_BY_1E5       0x5
#define DDS_DIVIDE_BY_1E6       0x6
#define DDS_DIVIDE_BY_1E7       0x7
#define DDS_DIVIDE_BY_PREG      0xF

//***************************************************************************
// Choices for bcSetDDSDividerSource()
//***************************************************************************
#define DDS_DIVIDER_SRC_DDS     0x0
#define DDS_DIVIDER_SRC_MULT    0x1
#define DDS_DIVIDER_SRC_100MHZ  0x2

//***************************************************************************
// Choices for bcSetDDSSyncMode()
//***************************************************************************
#define DDS_SYNC_MODE_FRAC      0x0
#define DDS_SYNC_MODE_CONT      0x1

//***************************************************************************
// Choices for bcSetDDSMultiplier()
//***************************************************************************
#define DDS_MULTIPLY_BY_1       0x1
#define DDS_MULTIPLY_BY_2       0x2
#define DDS_MULTIPLY_BY_3       0x3
#define DDS_MULTIPLY_BY_4       0x4
#define DDS_MULTIPLY_BY_6       0x6
#define DDS_MULTIPLY_BY_8       0x8
#define DDS_MULTIPLY_BY_10      0xA
#define DDS_MULTIPLY_BY_16      0x10


//***************************************************************************
// API Functions
//***************************************************************************
BC637PCI_API INT    BC637PCI_CONV bcStartPCI (INT);
BC637PCI_API void   BC637PCI_CONV bcStopPCI (void);

BC637PCI_API INT    BC637PCI_CONV bcReadBinTime (ULONG *, ULONG *, UCHAR *);
BC637PCI_API INT    BC637PCI_CONV bcReadDecTime (struct tm *, ULONG *, UCHAR *);
BC637PCI_API INT    BC637PCI_CONV bcSetBinTime (ULONG);
BC637PCI_API INT    BC637PCI_CONV bcSetBCDTime (struct tm);

BC637PCI_API INT    BC637PCI_CONV bcSetYear (INT);
BC637PCI_API INT    BC637PCI_CONV bcReadEventTime (ULONG *, ULONG *);

BC637PCI_API INT    BC637PCI_CONV bcGetReg (UINT, ULONG *);
BC637PCI_API INT    BC637PCI_CONV bcSetReg (UINT, ULONG *);
BC637PCI_API INT    BC637PCI_CONV bcGetDPReg (UINT, UCHAR *);
BC637PCI_API INT    BC637PCI_CONV bcSetDPReg (UINT, UCHAR *);

BC637PCI_API INT    BC637PCI_CONV bcSetMode (UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetTcIn (UCHAR, UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetGenCode (UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetTmFmt (INT);
BC637PCI_API INT    BC637PCI_CONV bcSetClkSrc (UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetLocOff (INT, UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetGenOff (INT, UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetPDelay (LONG);
BC637PCI_API INT    BC637PCI_CONV bcSetUtcCtl (INT);
BC637PCI_API INT    BC637PCI_CONV bcSetLeapEvent (CHAR, ULONG); 
BC637PCI_API INT    BC637PCI_CONV bcSetHbt (CHAR, INT, INT);

BC637PCI_API INT    BC637PCI_CONV bcCommand (INT);
BC637PCI_API INT    BC637PCI_CONV bcAdjustClock (LONG);

BC637PCI_API INT    BC637PCI_CONV bcSetGain (INT);
BC637PCI_API INT    BC637PCI_CONV bcSetDac (INT);
BC637PCI_API INT    BC637PCI_CONV bcSetDis (INT);
BC637PCI_API INT    BC637PCI_CONV bcSetJam (INT);
BC637PCI_API INT    BC637PCI_CONV bcForceJam (void);
BC637PCI_API INT    BC637PCI_CONV bcSyncRtc (void);
BC637PCI_API INT    BC637PCI_CONV bcDisRtcBatt (void);

BC637PCI_API INT    BC637PCI_CONV bcGPSOperMode (UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetLocalFlag (UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetDayLightFlag (UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcYearAutoInc (UCHAR);

BC637PCI_API INT    BC637PCI_CONV bcSetPciCard (UCHAR, ULONG, INT);
BC637PCI_API INT    BC637PCI_CONV bcSpecialBoot (INT);

BC637PCI_API INT    BC637PCI_CONV bcReqTimeData (TimeData *);
BC637PCI_API INT    BC637PCI_CONV bcReqTimeCodeData (TimeCodeData *);
BC637PCI_API INT    BC637PCI_CONV bcReqOscData (OscData *);
BC637PCI_API INT    BC637PCI_CONV bcReqOtherData (OtherData *);
BC637PCI_API INT    BC637PCI_CONV bcReqVerData (VerData *);
BC637PCI_API INT    BC637PCI_CONV bcReqManufData (ManufData *);

// Function to request the card's Revision ID
// This is the 8 bit Revision ID in the PCI configuration space
// For version 1 PCI card, the Revision ID is 0x12
// For version 2 PCI card, the Revision ID is 0x20 - 0x2F
BC637PCI_API INT    BC637PCI_CONV bcReqRevisionID (UCHAR *);

// Function to request the time code data extended with V2 hardware support.
// The V2 hardware supports time code sub type. Calling the original function
// bcReqTimeCodeData (with TimeCodeData *) will not return the sub type info.
BC637PCI_API INT    BC637PCI_CONV bcReqTimeCodeDataEx (TimeCodeDataEx *);

BC637PCI_API INT    BC637PCI_CONV bcGPSReq (GpsPkt *);
BC637PCI_API INT    BC637PCI_CONV bcGPSSnd (GpsPkt *);
BC637PCI_API INT    BC637PCI_CONV bcGPSMan (GpsPkt *, GpsPkt *);

BC637PCI_API INT    BC637PCI_CONV bcReqDPOffs (pOffs *);
BC637PCI_API INT    BC637PCI_CONV bcPCIRdTm (ULONG *, ULONG *);
BC637PCI_API INT    BC637PCI_CONV bcPCIRdCtls (ULONG *, ULONG *, ULONG *, ULONG *);
BC637PCI_API INT    BC637PCI_CONV bcPCIWrCtls (ULONG, ULONG, ULONG, ULONG);
BC637PCI_API INT    BC637PCI_CONV bcReqIrigSymbol(IAFStruct *);
BC637PCI_API INT    BC637PCI_CONV bcRdPciCfgSp (pcicfg *);
BC637PCI_API INT    BC637PCI_CONV bcWrtPciCfgSp (UINT, ULONG);
BC637PCI_API INT    BC637PCI_CONV bcPCICfg (pcidata *);
BC637PCI_API INT    BC637PCI_CONV bcPCICfgOffs (pOffs *);
BC637PCI_API INT    BC637PCI_CONV bcTestPktTime (ULONG *, ULONG *, UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcPCIDPTest (INT, INT *, INT *, INT *);
BC637PCI_API INT    BC637PCI_CONV bcPCIdpW1000 (INT *, INT *);
BC637PCI_API INT    BC637PCI_CONV bcPCITestHarv (INT *, INT *, INT *);
BC637PCI_API INT    BC637PCI_CONV bcPCIdpad (void);
BC637PCI_API INT    BC637PCI_CONV bcPCIdpadc (void);
BC637PCI_API INT    BC637PCI_CONV bcPCIdpw1r2 (INT *, INT *, INT *);
BC637PCI_API INT    BC637PCI_CONV bcPCIdpw1 (INT *, INT *);
BC637PCI_API INT    BC637PCI_CONV bcEmulatorOnOff (INT);
BC637PCI_API INT    BC637PCI_CONV bcDebugOnOff (INT);
BC637PCI_API INT    BC637PCI_CONV bcSetRTC (PCHAR, PCHAR, PCHAR, PCHAR, PCHAR, PCHAR);

BC637PCI_API HANDLE BC637PCI_CONV bcOpen (INT);
BC637PCI_API void   BC637PCI_CONV bcClose (void);
BC637PCI_API INT    BC637PCI_CONV bcMapPCI (void);
BC637PCI_API void   BC637PCI_CONV bcUnMapPCI (void);

// ====================================================================
// DDS functions. These functions are only available for V2 hardware.
// On V1 hardware, it always return FALSE.
// ====================================================================
BC637PCI_API INT    BC637PCI_CONV bcSetPeriodicDDSSelect (UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetPeriodicDDSEnable (BOOL);
BC637PCI_API INT    BC637PCI_CONV bcSetDDSDivider (UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetDDSDividerSource (UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetDDSSyncMode (UCHAR);
BC637PCI_API INT    BC637PCI_CONV bcSetDDSMultiplier (UCHAR);
// dwPeriod is an integer in the range of [0, 0xFFFFFF]
BC637PCI_API INT    BC637PCI_CONV bcSetDDSPeriodValue (DWORD);
BC637PCI_API INT    BC637PCI_CONV bcSetDDSTuningWord (DWORD);

// The bcSetDDSFrequency automatically sets the periodic/DDS output to
// be DDS output and sets the DDS sync mode to be DDS_SYNC_MODE_FRAC.
// If you want to come back to periodic output, please call function
// bcSetPeriodicDDSSelect to set it to periodic output. You can also
// change sync mode with bcSetDDSSyncMode.
BC637PCI_API INT    BC637PCI_CONV bcSetDDSFrequency (double);

// This function is the extended version of the 'bcSetTcIn()'. It is
// equivalent to bcSetTcIn() when the 'TcIn' is 
//   TCODE_IRIG_A, or TCODE_IRIG_B, or TCODE_IEEE, or TCODE_NASA
// and the 'SubType' is TCODE_IRIG_SUBTYPE_NONE.
// For example, 'bcSetTcIn (TCODE_IRIG_B, TCODE_MOD_AM)' is equivalent
// to 'bcSetTcInEx (TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_NONE, TCODE_MOD_AM)'.
//
// However, bcSetTcInEx supports the following new codes.
//
//   TCODE_2137,   TCODE_IRIG_SUBTYPE_NONE  (2137)
//   TCODE_XR3,    TCODE_IRIG_SUBTYPE_NONE  (XR3)
//   TCODE_IRIG_A, TCODE_IRIG_SUBTYPE_Y     (AY - IRIG A with year)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_Y     (BY - IRIG B with year)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_T     (BT - IRIG B Legacy TrueTime)
//   TCODE_IRIG_E, TCODE_IRIG_SUBTYPE_NONE  (E  - IRIG E 1000Hz no year)
//   TCODE_IRIG_E, TCODE_IRIG_SUBTYPE_Y     (EY - IRIG E 1000Hz with year)
//   TCODE_IRIG_e, TCODE_IRIG_SUBTYPE_NONE  (e  - IRIG E 100Hz no year)
//   TCODE_IRIG_e, TCODE_IRIG_SUBTYPE_Y     (eY - IRIG E 100Hz with year)
//   TCODE_IRIG_G, TCODE_IRIG_SUBTYPE_NONE  (G  - IRIG G no year)
//   TCODE_IRIG_G, TCODE_IRIG_SUBTYPE_Y     (GY - IRIG G with year)
//
BC637PCI_API INT    BC637PCI_CONV bcSetTcInEx (UCHAR, UCHAR, UCHAR);

// This function is the extended version of the 'bcSetGenCode()'. It is
// equivalent to bcSetGenCode() when the 'GenTc' is 
//   TCODE_IRIG_B, or TCODE_IEEE
// and the 'SubType' is TCODE_IRIG_SUBTYPE_NONE.
// For example, 'bcSetGenCode (TCODE_IRIG_B)' is equivalent
// to 'bcSetGenCodeEx (TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_NONE)'.
//
// However, bcSetGenCodeEx supports the following new codes.
//
//   TCODE_2137,   TCODE_IRIG_SUBTYPE_NONE  (2137)
//   TCODE_XR3,    TCODE_IRIG_SUBTYPE_NONE  (XR3)
//   TCODE_NASA,   TCODE_IRIG_SUBTYPE_NONE  (NASA)
//   TCODE_IRIG_A, TCODE_IRIG_SUBTYPE_0     (A0 - IRIG A BCD,CF,SBS)
//   TCODE_IRIG_A, TCODE_IRIG_SUBTYPE_1     (A1 - IRIG A BCD,CF)
//   TCODE_IRIG_A, TCODE_IRIG_SUBTYPE_2     (A2 - IRIG A BCD)
//   TCODE_IRIG_A, TCODE_IRIG_SUBTYPE_3     (A3 - IRIG A BCD,SBS)
//   TCODE_IRIG_A, TCODE_IRIG_SUBTYPE_4     (A4 - IRIG A BCD,YEAR,CF,SBS)
//   TCODE_IRIG_A, TCODE_IRIG_SUBTYPE_5     (A5 - IRIG A BCD,YEAR,CF)
//   TCODE_IRIG_A, TCODE_IRIG_SUBTYPE_6     (A6 - IRIG A BCD,YEAR)
//   TCODE_IRIG_A, TCODE_IRIG_SUBTYPE_7     (A7 - IRIG A BCD,YEAR,SBS)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_0     (B0 - IRIG B BCD,CF,SBS)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_1     (B1 - IRIG B BCD,CF)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_2     (B2 - IRIG B BCD)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_3     (B3 - IRIG B BCD,SBS)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_4     (B4 - IRIG B BCD,YEAR,CF,SBS)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_5     (B5 - IRIG B BCD,YEAR,CF)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_6     (B6 - IRIG B BCD,YEAR)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_7     (B7 - IRIG B BCD,YEAR,SBS)
//   TCODE_IRIG_B, TCODE_IRIG_SUBTYPE_T     (BT - IRIG B BCD,CF,SBS - Legacy TrueTime)
//   TCODE_IRIG_E, TCODE_IRIG_SUBTYPE_1     (E1 - IRIG E 1000Hz BCD,CF)
//   TCODE_IRIG_E, TCODE_IRIG_SUBTYPE_2     (E2 - IRIG E 1000Hz BCD)
//   TCODE_IRIG_E, TCODE_IRIG_SUBTYPE_5     (E5 - IRIG E 1000Hz BCD,YEAR,CF)
//   TCODE_IRIG_E, TCODE_IRIG_SUBTYPE_6     (E6 - IRIG E 1000Hz BCD,YEAR)
//   TCODE_IRIG_e, TCODE_IRIG_SUBTYPE_1     (e1 - IRIG E 100Hz BCD,CF)
//   TCODE_IRIG_e, TCODE_IRIG_SUBTYPE_2     (e2 - IRIG E 100Hz BCD)
//   TCODE_IRIG_e, TCODE_IRIG_SUBTYPE_5     (e5 - IRIG E 100Hz BCD,YEAR,CF)
//   TCODE_IRIG_e, TCODE_IRIG_SUBTYPE_6     (e6 - IRIG E 100Hz BCD,YEAR)
//   TCODE_IRIG_G, TCODE_IRIG_SUBTYPE_5     (G5 - IRIG G BCD,YEAR,CF)
//
BC637PCI_API INT    BC637PCI_CONV bcSetGenCodeEx (UCHAR, UCHAR);

// Returns the 100 nano seconds count field
BC637PCI_API INT    BC637PCI_CONV bcReadEventTimeEx (ULONG *maj, ULONG *min, USHORT *nano);

// Read event2 and event3 time
BC637PCI_API INT    BC637PCI_CONV bcReadEvent2TimeEx (ULONG *maj, ULONG *min, USHORT *nano);
BC637PCI_API INT    BC637PCI_CONV bcReadEvent3TimeEx (ULONG *maj, ULONG *min, USHORT *nano);
BC637PCI_API INT    BC637PCI_CONV bcReqOtherDataEx (OtherDataEx *);
BC637PCI_API INT    BC637PCI_CONV bcReqEventsData (EventsData *);
BC637PCI_API INT    BC637PCI_CONV bcSetEventsData (EventsData *);

// Returns the 100 nano seconds count field
BC637PCI_API INT    BC637PCI_CONV bcReadBinTimeEx (ULONG *maj, ULONG *min, USHORT *nano, UCHAR *pstat);
BC637PCI_API INT    BC637PCI_CONV bcReadDecTimeEx (struct tm *ptm, ULONG *min, USHORT *nano, UCHAR *pstat);

// The time is represented by two 32 bit registers of major and minor time.
// Prior to this release (10.0.0), the four time reading functions
//   bcReadBinTime()
//   bcReadDecTime()
//   bcReadBinTimeEx()
//   bcReadDecTimeEx()
// do not use any synchronization primitive to ensure reading the major and
// minor together. Starting from this release, the four functions now use a
// shared critical section to ensure only one thread at a time reading both
// major and minor time. However, there is latency introduced by using the
// critical section. Some applications may want to avoid such latency and
// choose to handle time reading synchronizatin themselves. So the renamed
// functions below, - NoSync version, are the original (no critical section)
// implementations.
BC637PCI_API INT    BC637PCI_CONV bcReadBinTimeNoSync (ULONG *, ULONG *, UCHAR *);
BC637PCI_API INT    BC637PCI_CONV bcReadDecTimeNoSync (struct tm *, ULONG *, UCHAR *);
BC637PCI_API INT    BC637PCI_CONV bcReadBinTimeExNoSync (ULONG *maj, ULONG *min, USHORT *nano, UCHAR *pstat);
BC637PCI_API INT    BC637PCI_CONV bcReadDecTimeExNoSync (struct tm *ptm, ULONG *min, USHORT *nano, UCHAR *pstat);

// Read and write the IO space data
BC637PCI_API INT    BC637PCI_CONV bcReadIOSpace32 (USHORT offset, ULONG *pVal);
BC637PCI_API INT    BC637PCI_CONV bcWriteIOSpace32 (USHORT offset, ULONG val);


//***************************************************************************
// IOCTL Commands for bc635/7PCI
//***************************************************************************
#define PCI_CMD_MODE                    0x10
#define PCI_CMD_TM_FMT                  0x11
#define PCI_CMD_SET_TIME                0x12
#define PCI_CMD_TM_YEAR                 0x13
#define PCI_CMD_YEAR                    0x13
#define PCI_CMD_HBT                     0x14
#define PCI_CMD_TC_RDR_FMT              0x15
#define PCI_CMD_TC_RDR_MOD              0x16
#define PCI_CMD_TB_OFF                  0x17
#define PCI_CMD_TM_UTC_CTL              0x18
#define PCI_CMD_GET_DATA                0x19
#define PCI_CMD_SWRESET                 0x1A
#define PCI_CMD_TC_GEN_CODE             0x1B
#define PCI_CMD_TC_GEN_OFF              0x1C
#define PCI_CMD_TM_LOCAL_OFFSET         0x1D
#define PCI_CMD_LEAP_EVENT              0x1E
#define PCI_CMD_VERSION                 0x1F
#define PCI_CMD_CLK_SRC                 0x20
#define PCI_CMD_CLK_JAM_CTL             0x21
#define PCI_CMD_CLK_JAM_NOW             0x22
#define PCI_CMD_CLK_DIS_CTL             0x23
#define PCI_CMD_CLK_DAC_VAL             0x24
#define PCI_CMD_CLK_DIS_GAIN            0x25
#define PCI_CMD_SYNC_RTC_NOW            0x27
#define PCI_CMD_DIS_RTC_BATT            0x28
#define PCI_CMD_ADJUST_CLK              0x29

#define PCI_CMD_GPS_SND_PKT             0x30
#define PCI_CMD_GPS_GET_PKT             0x31
#define PCI_CMD_GPS_MAN_PKT             0x32
#define PCI_CMD_GPS_UTC_FMT             0x33
#define PCI_CMD_GPS_STATIC              0x34

#define PCI_CMD_LOCAL_FLAG              0x40
#define PCI_CMD_IEEE                    0x41
#define PCI_CMD_YEAR_AUTO_INC           0x42

#define PCI2_CMD_SET_PRD_DDS_SEL        0x43
#define PCI2_CMD_SET_PRD_DDS_ENA        0x44
#define PCI2_CMD_SET_DDS_DIVIDER        0x45
#define PCI2_CMD_SET_DDS_DIV_SRC        0x46
#define PCI2_CMD_SET_DDS_DIV_SYNC       0x47
#define PCI2_CMD_SET_DDS_MULTI          0x48
#define PCI2_CMD_SET_DDS_PERIOD         0x49
#define PCI2_CMD_SET_DDS_TUNEWORD       0x4A

#define PCI_CMD_VERSION_DT              0x4F

#define PCI_CMD_IRIG_SYMBOL             0x50

#define PCI2_CMD_TM_FMT                 0xF0
#define PCI2_CMD_TM_YEAR                0xF1
#define PCI2_CMD_TM_LEAP_YEAR           0xF2
#define PCI2_CMD_TM_UTC_CTL             0xF3
#define PCI2_CMD_TM_LEAP_SEC            0xF4
#define PCI2_CMD_TM_LEAP_EVENT          0xF5
#define PCI2_CMD_TM_LEAP_EVENT_TIME     0xF6

#define PCI2_CMD_CLK_DIS_KVAL           0xE2
#define PCI2_CMD_CLK_JAM_CTL            0xE5
#define PCI2_CMD_CLK_JAM_WIN            0xE6
#define PCI2_CMD_CLK_PHZ_CTL            0xE7
#define PCI2_CMD_CLK_PHZ_LMT            0xE8

#define PCI_CMD_MANUF_BOOT              0xF1
#define PCI_CMD_MANUF_ASSEM             0xF4
#define PCI_CMD_MANUF_FAB               0xF5
#define PCI_CMD_MANUF_MODEL             0xF6
#define PCI_CMD_SPEC_BOOT               0xFB
#define PCI_CMD_MANUF_SERIAL            0xFE

// PCI DP RAM OFFSETS 
#define DPRAM_SIZE              (0x800)
#define DPRAM_OFFSET_INPAC      (DPRAM_SIZE-2)
#define DPRAM_OFFSET_OUTPAC     (DPRAM_SIZE-4)
#define DPRAM_OFFSET_GPSPAC     (DPRAM_SIZE-6)
#define DPRAM_OFFSET_YEAR       (DPRAM_SIZE-8)

// GPS Packets 
#define TIMEOUT                 0xFFFF
#define SOH                     0x01
#define ETB                     0x17
#define DLE                     0x10
#define ETX                     0x03
#define WM_INT_DETECTED         0x7025
#define WM_INT_DYING            0x7026

#ifdef __cplusplus
}
#endif

#endif // __BC637PCI_H__
