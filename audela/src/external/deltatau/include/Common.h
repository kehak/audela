/*
 * common.h
 *
 * 32-bit Motion Control Device Driver
 * Hardware-specific data structures for the Pmac.
 *
 *
 * This header describes the structures that are shared between
 * the hardware-specific user-mode code and the hardware-specific
 * kernel mode code.
 *
 */


#ifndef _COMMON_H_
  #define _COMMON_H_

/*
 * default settings for port, interrupt and dpram
 */

  #define DEF_PCBUSTYPE          0 // ISA, VME etc.
  #define DEF_TYPE               1 // PMAC 1
  #define DEF_PORT             528 // 0x210
  #define DEF_INTERRUPT          0 // No interrupt, make them select!
  #define DEF_FIFO             0x0
  #define DEF_LOCATION           0 // Computer BUS
  #define DEF_TIMEOUT          200
  #define DEF_FLUSHTIMEOUT      20
  #define DEF_DPRROT1ADR     0x400
  #define DEF_DPRROT2ADR     0x400
  #define DEF_DPRROT3ADR       0x0
  #define DEF_DPRROT4ADR       0x0
  #define DEF_DPRROT5ADR       0x0
  #define DEF_DPRROT6ADR       0x0
  #define DEF_DPRROT7ADR       0x0
  #define DEF_DPRROT8ADR       0x0
  #define DEF_DPRVARADR      0xD60
  #define DEF_DPRUSERBUF     0x580
  #define DEF_FBSTART       0x9f00
  #define DEF_FBTIMER       0x9f80
  #define DEF_BAUDRATE        9600
  #define DEF_COMPORT            2 // COM2
  #define DEF_PARITY             0 // Odd
  #define DEF_VMEBASE     0x7FA000 // PMAC's Default VME base address
  #define DEF_VMEDPRBASE  0x700000 // PMAC's Default VME DPR Base Address
  #define DEF_VMEINTERRUPT       7 // PMAC's Default VME Interrupt Level
  #define DEF_VMEHOSTID          0 // VMIC 7686
  #define DEF_VMEAM           0x39 // Address Modifier
  #define DEF_VMEAMDC         0x04 // Address Modifier Dont care
  #define DEF_VMEIRQVECT      0xA1 // VME IRQ Vector
  #define DEF_BUSCHARTIMEOUT    1000
  #define DEF_BUSFLUSHTIMEOUT   10
  #define DEF_VMECHARTIMEOUT    30
  #define DEF_VMEFLUSHTIMEOUT    3
  #define DEF_DPBKTIMEOUT       10
  #define DEF_DPRTTIMEOUT        2
  #define DEF_DPCHARTIMEOUT   1000
  #define DEF_DPFLUSHTIMEOUT    20
  #define DEF_SERCHARTIMEOUT  1000
  #define DEF_SERFLUSHTIMEOUT   15

/*
* Common defines
*
*/

  #define MAXMOTORS           8
  #define MAXMOTORSTURBO      32
  #define MAXLINKS            68               // max number of PLCC links
  #define MINLINKS            41
  #define MAXLDS              27               // max number of PLCC LADDER DIAG links
  #define MINLDS              27               // MIN number of PLCC LADDER DIAG links
  #define MAXSTRLINK          ((8*MAXLINKS)+1) // max string length of links
  #define VERSION_BUFFER_SIZE 10
  #define DATE_BUFFER_SIZE    20
  #define ISR_IPOS            1                /*         IR0 for in position          */
  #define ISR_BREQ            2                /*         IR1 for buffer request       */
  #define ISR_FERROR          4                /*         IR2 for general error        */
  #define ISR_ERROR           8                /*         IR3 for following error      */
  #define ISR_HREQ            16               /*         IR4 for communication        */
  #define ISR_IR5             32               /*         IR5                          */
  #define ISR_IR6             64               /*         IR6                          */
  #define ISR_IR7             128              /*         IR7                          */

/*
 * Parameter Names:
 *
 * These are the names of Values in the Parameters key (or driver section
 * of the profile) used for communicating configuration information and errors
 * between the kernel and user-mode drivers.
 */

  #define PARAM_TYPE        TEXT("PmacType")     // model of PMAC
  #define PARAM_PCBUSTYPE   TEXT("PCBusType")    // bus type isa, pci
  #define PARAM_PORT        TEXT("Port")         // port i/o address
  #define PARAM_INTERRUPT   TEXT("Interrupt")    // interrupt number
  #define PARAM_BUSCHARTIMEOUT  TEXT("BUSCharTimeout")
  #define PARAM_BUSFLUSHTIMEOUT TEXT("BUSFlushTimeout")
  #define PARAM_FIFO        TEXT("DualPortRam")  // DP Ram physical addr
  #define PARAM_ERROR       TEXT("InstallError") // config error/success code (below)
  #define PARAM_DPRROT1     TEXT("DualPortRamRot1")
  #define PARAM_DPRROT2     TEXT("DualPortRamRot2")
  #define PARAM_DPRROT3     TEXT("DualPortRamRot3")
  #define PARAM_DPRROT4     TEXT("DualPortRamRot4")
  #define PARAM_DPRROT5     TEXT("DualPortRamRot5")
  #define PARAM_DPRROT6     TEXT("DualPortRamRot6")
  #define PARAM_DPRROT7     TEXT("DualPortRamRot7")
  #define PARAM_DPRROT8     TEXT("DualPortRamRot8")
  #define PARAM_DPRVARADR   TEXT("DualPortRamVar")
  #define PARAM_DPRUSERSIZE TEXT("DualPortRamUserSize")
  #define PARAM_FBSTART     TEXT("FunctionBlockStart")
  #define PARAM_FBTIMER     TEXT("FunctionBlockTimer")
  #define PARAM_PORTNUMBER  TEXT("SerialPortNumber")
  #define PARAM_BAUDRATE    TEXT("SerialBaudrate")
  #define PARAM_PARITY      TEXT("SerialOddParity")
  #define PARAM_LOCATION    TEXT("Location")

  #define PARAM_DPBKTIMEOUT    TEXT("DPRBackTimeout")
  #define PARAM_DPRTTIMEOUT    TEXT("DPRRTTimeout")
  #define PARAM_DPCHARTIMEOUT  TEXT("DPRCharTimeout")
  #define PARAM_DPFLUSHTIMEOUT TEXT("DPRFlushTimeout")

  #define PARAM_VMEBASE         TEXT("VMEBase")
  #define PARAM_VMEDPRBASE      TEXT("VMEDPRBase")
  #define PARAM_VMEINTERRUPT    TEXT("VMEInterrupt")
  #define PARAM_VMEHOSTID       TEXT("VMEHostID")
  #define PARAM_VMEAM           TEXT("VMEAM")
  #define PARAM_VMEAMDC         TEXT("VMEAMDontCare")
  #define PARAM_VMEIRQVECT      TEXT("VMEIRQVector")
  #define PARAM_VMECHARTIMEOUT  TEXT("VMECharTimeout")
  #define PARAM_VMEFLUSHTIMEOUT TEXT("VMEFlushTimeout")
  #define PARAM_SERCHARTIMEOUT  TEXT("SerCharTimeout")
  #define PARAM_SERFLUSHTIMEOUT TEXT("SerFlushTimeout")

  #ifdef _NC
    #define PARAM_NCTITLE         TEXT("Title")
    #define PARAM_SOURCEPROFILE   TEXT("SourceProfile")
    #define PARAM_TOOLPROFILE     TEXT("ToolProfile")
    #define PARAM_COORDPROFILE    TEXT("CoordProfile")
    #define PARAM_MACHINETYPE     TEXT("MachineType")
    #define PARAM_NOOFTOOLS       TEXT("NoOfTools")
    #define PARAM_NOOFBLOCKS      TEXT("NoOfBlocks")
    #define PARAM_NOOFCOORDSYS    TEXT("NoOfCoordSys")
    #define PARAM_METRICDISPLAY   TEXT("MetricDisplay")
    #define PARAM_LEASTHANDLEINC  TEXT("LeastHandleInc")
    #define PARAM_MAXHANDLEINC    TEXT("MaxHandleInc")
    #define PARAM_LEASTJOGINC     TEXT("LeastJogInc")
    #define PARAM_AXISMOTORMAP    TEXT("AxisMotorMap")
    #define PARAM_AXISMOTORSEL    TEXT("AxisMotorSel")
    #define PARAM_AXISDISPMAP     TEXT("AxisDispMap")
    #define PARAM_MAXRAPIDOVRD    TEXT("MaxRapidOvrd")
    #define PARAM_MAXFEEDOVRD     TEXT("MaxFeedOvrd")
// Axis stuff
    #define PARAM_ISSPINDLE       TEXT("IsSpindle")
    #define PARAM_HASSLAVE        TEXT("HasSlave")
    #define PARAM_ISPHANTOM       TEXT("IsPhantom")
    #define PARAM_DISPLAY         TEXT("Display")
    #define PARAM_DISPLAYSLAVE    TEXT("DisplaySlave")
    #define PARAM_HOMEMODE        TEXT("HomeMode")
    #define PARAM_HOMEPRGNUMBER   TEXT("HomePrgNumber")
    #define PARAM_PRECISION       TEXT("Precision")
    #define PARAM_METRICDISPLAY   TEXT("MetricDisplay")
    #define PARAM_METRICUNITS     TEXT("MetricUnits")
    #define PARAM_PROBEPRGNUMBER  TEXT("ProbePrgNumber")
    #define PARAM_PULSEPERUNIT    TEXT("PulsePerInit")
    #define PARAM_INPOSITIONBAND  TEXT("InpositionBand")
    #define PARAM_MAXRAPID        TEXT("MaxRapid")
    #define PARAM_MAXFEED         TEXT("MaxFeed")
    #define PARAM_FATALFERROR     TEXT("FatalFError")
    #define PARAM_WARNFERROR      TEXT("WarnFError")
    #define PARAM_JOGSPEEDLOW     TEXT("JogSpeedLow")
    #define PARAM_JOGSPEEDMedLow  TEXT("JogSpeedMedLow")
    #define PARAM_JOGSPEEDMed     TEXT("JogSpeedMed")
    #define PARAM_JOGSPEEDMedHigh TEXT("JogSpeedMedHigh")
    #define PARAM_JOGSPEEDHigh    TEXT("JogSpeedHigh")
    #define PARAM_FORMATINCH      TEXT("FormatInch")
    #define PARAM_FORMATMM        TEXT("FormatMM")
  #endif

/*
 * Error handling
 *
 * during startup of the kernel-driver, the PARAM_ERROR value is written with
 * one of the values below. These are the IDs of strings in
 * pmac\dll\pmac.rc that are produced in a dialog box by the user-mode
 * driver during configuration if not MC_ERR_OK
 */

  #define ERR_OK           0    // no configuration error
  #define ERR_CREATEDEVICE 1001 // failed to create device object
  #define ERR_CONFLICT     1002 // resource conflict
  #define ERR_DETECTFAILED 1003 // could not find hardware
  #define ERR_INTERRUPT    1004 // interrupt did not install
  #define ERR_INTRDETECT   1005 // interrupt did not occur
  #define ERR_BUSTIMEOUT   1006 // timeout during bus read
  #define ERR_DPRTIMEOUT   1007 // timeout during dpram ascii read
  #define ERR_SERTIMEOUT   1008 // timeout during serial ascii rea
  #define ERR_INBOOTSTRAP  1009 // PMAC in bootstrap mode can't load
  #define ERR_CONFIGDRIVER 1010 // Unable to configure driver (in registry perhaps)
  #define ERR_EMPTYBUS     1011 // Continuous characters from bus, No Card!!
  #define ERR_EMPTYDPRAM   1012 // Continuous characters from bus, No Card!!


#endif //_COMMON_H_

