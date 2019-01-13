//***************************************************************************
//
// bc637pci.h
//
// Version 7.1.0
//
// Header file for bc635/7PCI SDK
//
// Copyright (c) Symmetricom - Formerly Datum 1997 - 2003
//
//
//***************************************************************************

#ifndef __BC637PCI_H__
#define __BC637PCI_H__

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _PCI_LINKAGE_
#define _PCI_LINKAGE_
#endif

//***************************************************************************
// TimeData Data Structure
//***************************************************************************
typedef struct _TimeData {
	INT tmformat;		// Time format (i.e. bin or bcd)
	INT year;			// Current year data
	INT leapyear;		// 1 = true 0 = false
	INT utcctl;			// Enable/Disable UTC info usage
	INT leapsec;		// Current leap second count
	INT leapevt;		// Current leap second event type (1=ins,0=no,-1=del)
	INT leapevttm;		// Scheduled time for leap second event
	SHORT locoff;		// Local time offset
	UCHAR lhlfhr;		// Local time offset half hour flag
	long int pdelay;	// Phase delay
	INT dlight;			// IEEE Daylight Savings Flag 
	INT localt;			// Local Time Flag Enable/Disable
} TimeData;

//***************************************************************************
// TimeCodeData Data Structure
//***************************************************************************
typedef struct _TimeCodeData {
	INT format;			// Time Code Decode Type 
	INT modulation;		// Time Code Decode Modulation
	INT gencode;		// Time Code Generator Type
	SHORT genoffset;	// Time Code Generator Offset
	UCHAR ghfhr;		// Time Code Gen Offset half Hour flag 0/1
} TimeCodeData;

//***************************************************************************
// OscData Data Structure
//***************************************************************************
typedef struct _OscData {
	INT BattStat;		// Real Time Clock Battery status
	INT ClkSrc;			// Selected Clock input
    INT DisCtl;			// Disciplining Enable/Disable
    float DisKval;		// Disciplining Filter Constant
    SHORT DisGain;		// Disciplining Gain
    SHORT DacVal;		// DAC Value
    INT JamCtl;			// Jamsynch Enable/Disable
    INT JamWin;			// Jamsynch Window
    INT PhzCtl;			// Phase Enable/Disable
    INT PhzLmt;			// Phase Shift Limit
	LONG AdjClk;		// Advance/Retard Clock Value
} OscData;

//***************************************************************************
// OtherData Data Structure
//***************************************************************************
typedef struct _OtherData {
	INT mode;			// Selected Reference mode
	INT hbtmode;		// Heartbeat/Periodic mode (0=async,1=sync)
	INT hbtcnt1;		// Heartbeat/Periodic n1
	INT hbtcnt2;		// Heartbeat/Periodic n2
	INT freq;			// Current freq output (1,5,10MHz)
	INT evtctl;			// Enable/Disable events
	INT evtsense;		// Event trigger on edge (0=falling,1=rising)
	INT evtlock;		// Enable/Disable event capture lockout
	INT evtsrc;			// Event trigger source (0=evt,1=hbt)
} OtherData;

//***************************************************************************
// VerData Data Structure
//***************************************************************************
typedef struct _VerData {
	INT majver;			// Major Version Number
	INT minver;			// Minor Version Number
	INT month;			// Month of build
	INT day;			// Day of build
	INT year;			// Year of build
	UCHAR byt1;			// DT Number "D"
	UCHAR byt2;			// DT Number "T"
	UCHAR byt3;			// DT Number "6"
	UCHAR byt4;			// DT Number "0"
	UCHAR byt5;			// DT Number "0"
	UCHAR byt6;			// DT Number "0"
	UCHAR byt7;			// DT Number "A,B,C..."
	UCHAR byt8;			// DT Number "."
	UCHAR byt9;			// DT Number "1,2.."
	UCHAR byt10;		// DT Number "1,2.."
	UCHAR byt11;		// DT Number "1,2.."
} VerData;

//***************************************************************************
// ManufData Data Structure
//***************************************************************************
typedef struct _ManufData
{
    INT		BootCfg;				// Boot Configration
    INT		Assembly;				// Assembly Part Number
	INT		HwFab;					// Hardware Fab Number
	ULONG	Serial;					// Hardware Serial Number
	UCHAR	model1;					// Model 'B'
	UCHAR	model2;					// Model 'C'
	UCHAR	model3;					// Model '6'
	UCHAR	model4;					// Model '3'
	UCHAR	model5;					// Model '5' or '7'
	UCHAR	model6;					// Model 'P'
	UCHAR	model7;					// Model 'C'
	UCHAR	model8;					// Model 'I'
} ManufData;

//***************************************************************************
// GpsPkt Data Structure
//***************************************************************************
typedef struct _GpsPkt {
	UCHAR id;			// GPS Packet ID Byte
	UCHAR len;			// GPS Packet Data Length
	UCHAR *data;		// GPS Packet Data Area Pointer
} GpsPkt;

//***************************************************************************
// pcidata Data Structure
//***************************************************************************
typedef struct _pcidata
{
    USHORT  majorVer;               // driver major version number
    USHORT  minorVer;               // minor version number
    ULONG   busType;                // type of bus, see INTERFACE_TYPE
    ULONG   busNumber;              // number of bus: 0
    ULONG   ioIncrement;            // priority boast
    ULONG   portMin;                // minimum port address
    ULONG   portMax;                // maximum port address
    ULONG   memMin;                 // minimum memory address
    ULONG   memMax;                 // maximum memory address
    ULONG   interruptVector;        // interrupt vector
    ULONG   interruptLevel;         // interrupt level, section 1 data
    ULONG   portMin1;               // minimum port address
    ULONG   portMax1;               // maximum port address
    ULONG   memMin1;                // minimum memory address
    ULONG   memMax1;                // maximum memory address
} pcidata;

//***************************************************************************
// pcicfg Config Structure
//***************************************************************************
typedef struct _pcicfg
{									// PCI Configuration Register
	USHORT  VendorID;				// PCI device vendor ID
    USHORT  DeviceID;				// PCI device device ID
	USHORT	Command;				// PCI Command Register
	USHORT  Status;					// PCI Status Register
	UCHAR   RevID;					// PCI Revision ID
	INT     ClassCode;				// PCI Class Code  
	USHORT  SubVenID;				// PCI Subsytem vendor ID
    USHORT  SubID;					// PCI Subsystem ID
	UCHAR	IntLine;				// PCI Interrupt Line
	UCHAR	IntPin;					// PCI Interrupt Pin
} pcicfg;

//***************************************************************************
// pOffs offset Structure
//***************************************************************************    
typedef struct _pOffs {
	INT pIn;						// DPRAM Input Packet Area
	INT pOut;						// DPRAM Output Packet Area
	INT pGPS;						// DPRAM GPS Output Packet Area
	INT pYear;
} pOffs;

//***************************************************************************
// IAFStruct IAF Data Structure
//*************************************************************************** 
typedef struct _IAFStruct {
		UCHAR	SignByte;
		UCHAR	HoldByte;
		UCHAR	Seconds;
		UCHAR	Minutes;
		UCHAR	Hours;
		INT		Ctrl_LSB;
		INT		Ctrl_MSB;
} IAFStruct;

//***************************************************************************
// Return Codes 
//***************************************************************************
#define RC_OK			(0)
#define RC_ERROR		(-1)

//***************************************************************************
// Register Offsets
//***************************************************************************
#define PCI_OFFSET_CTL			0x10
#define PCI_OFFSET_ACK			0x14
#define PCI_OFFSET_INT_MASK		0x18
#define PCI_OFFSET_INT_STAT		0x1C

//***************************************************************************
// SET_MODE SELECTS
//***************************************************************************
#define MODE_IRIG	0x00
#define MODE_FREE	0x01
#define MODE_1PPS	0x02
#define MODE_RTC	0x03
#define MODE_GPS	0x06

//***************************************************************************
// SET_TCODE SELECTS INPUT FORMAT
//***************************************************************************
#define TCODE_IRIG_A	'A'
#define TCODE_IRIG_B	'B'
#define TCODE_2137		'C'
#define TCODE_NASA36	'N'
#define TCODE_XR3		'X'
#define TCODE_IEEE		'I'

//***************************************************************************
// SET_TCODE SELECTS INPUT MODULATION  
//***************************************************************************
#define TCODE_MOD_AM	'M'
#define TCODE_MOD_DC	'D'

//***************************************************************************
// SET_GEN_CODE SELECTS  
//***************************************************************************
#define TCODE_GEN_B		'B'
#define TCODE_GEN_I		'I'

//***************************************************************************
// SET_CLK_SRC SELECTS  
//***************************************************************************
#define CLK_INT			'I'
#define CLK_EXT			'E'

//***************************************************************************
// HEARTBEAT MODE  
//***************************************************************************
#define HB_NO_SYNC		 0
#define HB_SYNC			 1

//***************************************************************************
// Various Flags 
//***************************************************************************
#define GPS_NONE_STATIC	(0)
#define GPS_STATIC		(1)
#define LOCAL_FLAG_DIS	(0)
#define LOCAL_FLAG_ENA	(1)
#define DAY_LIGHT_DIS	(0)
#define DAY_LIGHT_ENA	(1)
#define YEAR_AUTO_DIS	(0)
#define YEAR_AUTO_ENA	(1)

//***************************************************************************
// CONTROL DEFS  
//***************************************************************************
#define LOCK_EN		(1<<0)
#define HB_EN		(1<<1)
#define EVT_SNS_POS	(0<<2)
#define EVT_SNS_NEG	(1<<2)
#define EVT_EN		(1<<3)
#define STR_EN		(1<<4)
#define STR_MOD_MAJ	(0<<5)
#define STR_MOD_MIN	(1<<5)
#define FREQ_10_MHZ	(0)
#define FREQ_5_MHZ	(1<<6)
#define FREQ_1_MHZ	(1<<7)

//***************************************************************************
// ACK REG DEFS  
//***************************************************************************
#define ACK_RCV		(1<<0)
#define ACK_DPA		(1<<2)
#define ACK_FIFO	(1<<4)
#define ACK_CLR		(1<<4)
#define ACK_SEND	(1<<7)

//***************************************************************************
// INT MASK/STATUS DEFS   
//***************************************************************************
#define INT_EVENT	(1<<0)
#define INT_HBEAT	(1<<1)
#define INT_STROBE	(1<<2)
#define INT_1PPS	(1<<3)
#define INT_DPA		(1<<4)

//***************************************************************************
// SET_COMMAND SELECTS   
//***************************************************************************
#define CMD_WARMSTART	0x01
#define CMD_COLDSTART	0x02
#define CMD_JAM			0x03
#define CMD_NO_JAM		0x04
#define CMD_SYNC_RTC	0x05

//***************************************************************************
// OTHER DATA  
//***************************************************************************
#define REQ_RTC_TIME	0x00
#define REQ_DAC_VALUE	0x01
#define REQ_LEAP_SEC	0x02
#define REQ_PROG_DATA	0x03
#define REQ_MOD_VER		0x04
#define REQ_YEAR		0x05

//***************************************************************************
// Manuf Defines   
//***************************************************************************
#define MODEL_ID		0x04
#define CRYSTAL_ID		0x03
#define SET_BC635		0x0635
#define SET_BC637		0x0637
#define STD_CRYSTAL		0x0002
#define MTI_CRYSTAL		0x0014
#define NORMAL_BOOT		0x0000
#define SPECIAL_BOOT	0x0100

//***************************************************************************
// API Functions 
//***************************************************************************
INT		_PCI_LINKAGE_ bcStartPCI (INT);
void	_PCI_LINKAGE_ bcStopPCI (void);	

INT		_PCI_LINKAGE_ bcReadBinTime (ULONG *, ULONG *, UCHAR *);
INT		_PCI_LINKAGE_ bcReadDecTime (struct tm *, ULONG *, UCHAR *);
INT		_PCI_LINKAGE_ bcSetBinTime (ULONG);
INT		_PCI_LINKAGE_ bcSetBCDTime (struct tm);

INT		_PCI_LINKAGE_ bcSetYear (INT);
INT		_PCI_LINKAGE_ bcReadEventTime (ULONG *, ULONG *);

INT		_PCI_LINKAGE_ bcGetReg (UINT,ULONG *);
INT		_PCI_LINKAGE_ bcSetReg (UINT,ULONG *);
INT		_PCI_LINKAGE_ bcGetDPReg (UINT,UCHAR *);
INT		_PCI_LINKAGE_ bcSetDPReg (UINT,UCHAR *);

void	_PCI_LINKAGE_ bcSetMode (UCHAR);
INT		_PCI_LINKAGE_ bcSetTcIn (UCHAR, UCHAR);
INT		_PCI_LINKAGE_ bcSetGenCode (UCHAR);
INT		_PCI_LINKAGE_ bcSetTmFmt (INT);
INT		_PCI_LINKAGE_ bcSetClkSrc (UCHAR);
INT		_PCI_LINKAGE_ bcSetLocOff (INT, UCHAR);
INT		_PCI_LINKAGE_ bcSetGenOff (INT, UCHAR);
INT		_PCI_LINKAGE_ bcSetPDelay (LONG);
INT		_PCI_LINKAGE_ bcSetUtcCtl (INT);
INT		_PCI_LINKAGE_ bcSetLeapEvent (CHAR, ULONG); 
INT		_PCI_LINKAGE_ bcSetHbt (CHAR,INT,INT);

INT		_PCI_LINKAGE_ bcCommand (INT);
INT		_PCI_LINKAGE_ bcAdjustClock (LONG);

INT		_PCI_LINKAGE_ bcSetGain (INT);
INT		_PCI_LINKAGE_ bcSetDac (INT);
INT		_PCI_LINKAGE_ bcSetDis (INT);
INT		_PCI_LINKAGE_ bcSetJam (INT);
INT		_PCI_LINKAGE_ bcForceJam (void);
INT		_PCI_LINKAGE_ bcSyncRtc (void);
INT		_PCI_LINKAGE_ bcDisRtcBatt (void);

INT		_PCI_LINKAGE_ bcGPSOperMode (UCHAR);
INT		_PCI_LINKAGE_ bcSetLocalFlag (UCHAR);
INT		_PCI_LINKAGE_ bcSetDayLightFlag (UCHAR);
INT		_PCI_LINKAGE_ bcYearAutoInc (UCHAR);

INT		_PCI_LINKAGE_ bcSetPciCard (UCHAR, ULONG, INT);
INT		_PCI_LINKAGE_ bcSpecialBoot (INT);
INT		_PCI_LINKAGE_ bcRequest (UCHAR,PCHAR);

INT		_PCI_LINKAGE_ bcReqTimeData (TimeData *);
INT		_PCI_LINKAGE_ bcReqTimeCodeData (TimeCodeData *);
INT		_PCI_LINKAGE_ bcReqOscData (OscData *);
INT		_PCI_LINKAGE_ bcReqOtherData (OtherData *);
INT		_PCI_LINKAGE_ bcReqVerData (VerData *);
INT		_PCI_LINKAGE_ bcReqManufData (ManufData *);

INT		_PCI_LINKAGE_ bcGPSReq (GpsPkt *);
INT		_PCI_LINKAGE_ bcGPSSnd (GpsPkt *);
INT		_PCI_LINKAGE_ bcGPSMan (GpsPkt *, GpsPkt *);

INT		_PCI_LINKAGE_ bcReqDPOffs (pOffs *);
INT		_PCI_LINKAGE_ bcPCIRdTm (ULONG *, ULONG *);
INT		_PCI_LINKAGE_ bcPCIRdCtls (ULONG *, ULONG *, ULONG *, ULONG *);
INT		_PCI_LINKAGE_ bcPCIWrCtls (ULONG, ULONG, ULONG, ULONG);
INT		_PCI_LINKAGE_ bcReqIrigSymbol(IAFStruct *);
INT		_PCI_LINKAGE_ bcRdPciCfgSp (pcicfg *);
INT		_PCI_LINKAGE_ bcWrtPciCfgSp (UINT, ULONG);
INT		_PCI_LINKAGE_ bcMapPCI (void);
INT		_PCI_LINKAGE_ bcPCICfg (pcidata *);
INT		_PCI_LINKAGE_ bcPCICfgOffs (pOffs *);
INT		_PCI_LINKAGE_ bcTestPktTime (ULONG *,ULONG *,UCHAR);
INT		_PCI_LINKAGE_ bcPCIDPTest (INT,int *,int *,int *);
INT		_PCI_LINKAGE_ bcPCIdpW1000 (int *, int *);
INT		_PCI_LINKAGE_ bcPCITestHarv (int *, int *, int *);
INT		_PCI_LINKAGE_ bcPCIdpad (void);
INT		_PCI_LINKAGE_ bcPCIdpadc (void);
INT		_PCI_LINKAGE_ bcPCIdpw1r2 (int *, int *, int *);
INT		_PCI_LINKAGE_ bcPCIdpw1 (int *, int *);
INT		_PCI_LINKAGE_ bcEmulatorOnOff (INT);
INT		_PCI_LINKAGE_ bcDebugOnOff (INT);
INT		_PCI_LINKAGE_ bcCtlInt (ULONG, HANDLE, INT);
INT		_PCI_LINKAGE_ bcSetRTC (PCHAR,PCHAR,PCHAR,PCHAR,PCHAR,PCHAR);
HANDLE	_PCI_LINKAGE_ bcOpen (INT);
void	_PCI_LINKAGE_ bcClose (void);
void	_PCI_LINKAGE_ bcUnMapPCI (void);
void	_PCI_LINKAGE_ bcKillInts (void);

//***************************************************************************
// IOCTL Commands for bc635/7PCI
//***************************************************************************
#define PCI_CMD_MODE					0x10
#define PCI_CMD_TM_FMT					0x11
#define PCI_CMD_SET_TIME				0x12
#define PCI_CMD_TM_YEAR					0x13
#define PCI_CMD_YEAR					0x13
#define PCI_CMD_HBT						0x14
#define PCI_CMD_TC_RDR_FMT				0x15
#define PCI_CMD_TC_RDR_MOD				0x16
#define PCI_CMD_TB_OFF					0x17
#define PCI_CMD_TM_UTC_CTL				0x18
#define PCI_CMD_GET_DATA				0x19
#define PCI_CMD_SWRESET					0x1A
#define PCI_CMD_TC_GEN_CODE				0x1B
#define PCI_CMD_TC_GEN_OFF				0x1C
#define PCI_CMD_TM_LOCAL_OFFSET			0x1D
#define PCI_CMD_LEAP_EVENT				0x1E
#define PCI_CMD_VERSION					0x1F
#define PCI_CMD_CLK_SRC					0x20
#define PCI_CMD_CLK_JAM_CTL				0x21
#define PCI_CMD_CLK_JAM_NOW				0x22
#define PCI_CMD_CLK_DIS_CTL				0x23
#define PCI_CMD_CLK_DAC_VAL				0x24
#define PCI_CMD_CLK_DIS_GAIN			0x25
#define PCI_CMD_SYNC_RTC_NOW			0x27
#define PCI_CMD_DIS_RTC_BATT			0x28
#define PCI_CMD_ADJUST_CLK				0x29

#define PCI_CMD_GPS_SND_PKT				0x30
#define PCI_CMD_GPS_GET_PKT				0x31
#define PCI_CMD_GPS_MAN_PKT				0x32
#define PCI_CMD_GPS_UTC_FMT				0x33
#define PCI_CMD_GPS_STATIC				0x34

#define PCI_CMD_LOCAL_FLAG				0x40
#define PCI_CMD_IEEE					0x41
#define PCI_CMD_YEAR_AUTO_INC			0x42
#define PCI_CMD_VERSION_DT				0x4F

#define PCI_CMD_IRIG_SYMBOL				0x50

#define PCI2_CMD_TM_FMT					0xF0
#define PCI2_CMD_TM_YEAR				0xF1
#define PCI2_CMD_TM_LEAP_YEAR			0xF2
#define PCI2_CMD_TM_UTC_CTL				0xF3
#define PCI2_CMD_TM_LEAP_SEC			0xF4
#define PCI2_CMD_TM_LEAP_EVENT			0xF5
#define PCI2_CMD_TM_LEAP_EVENT_TIME		0xF6

#define PCI2_CMD_CLK_DIS_KVAL			0xE2
#define PCI2_CMD_CLK_JAM_CTL			0xE5
#define PCI2_CMD_CLK_JAM_WIN			0xE6
#define PCI2_CMD_CLK_PHZ_CTL			0xE7
#define PCI2_CMD_CLK_PHZ_LMT			0xE8

#define PCI_CMD_MANUF_BOOT				0xF1
#define PCI_CMD_MANUF_ASSEM				0xF4
#define PCI_CMD_MANUF_FAB				0xF5
#define PCI_CMD_MANUF_MODEL				0xF6
#define PCI_CMD_SPEC_BOOT				0xFB
#define PCI_CMD_MANUF_SERIAL			0xFE

// PCI DP RAM OFFSETS 
#define DPRAM_SIZE				(0x800)
#define DPRAM_OFFSET_INPAC 		(DPRAM_SIZE-2)
#define DPRAM_OFFSET_OUTPAC		(DPRAM_SIZE-4)
#define DPRAM_OFFSET_GPSPAC		(DPRAM_SIZE-6)
#define DPRAM_OFFSET_YEAR		(DPRAM_SIZE-8)

// GPS Packets 
#define TIMEOUT			0xFFFF
#define SOH				0x01
#define ETB				0x17
#define DLE				0x10
#define ETX				0x03
#define WM_INT_DETECTED	0x7025
#define WM_INT_DYING	0x7026

#ifdef __cplusplus
}
#endif

#endif // __BC637PCI_H__