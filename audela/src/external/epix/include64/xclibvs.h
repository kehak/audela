/*
 *
 *	xclibvs.h	External	13-Feb-2014
 *
 *	Copyright (C)  1999-2014  EPIX, Inc.  All rights reserved.
 *
 *	PIXCI(R) Library: Video State (Format) Definitions
 *
 *	Most end-users will not modify these structures directly,
 *	but either use the default or change and export the
 *	default with SVIP/4MIP/XCIP/XCAP and import the new
 *	structures into the frame grabber library.
 *
 */


#if !defined(__EPIX_XCLIBVS_DEFINED)
#define __EPIX_XCLIBVS_DEFINED
#include "cext_hps.h"     


/*
 * For PIXCI(R) SV2/SV3/SV4/SV5/SV6 frame grabbers.
 * Familiarity with the underlying Bt819/Bt829/Bt848/Bt878/Cx2388x
 * chips is implied.
 */
struct xcsv2format {
    struct  pxddch  ddch;


    uint8   Bt8x9format;    /* video format code			    */
			    /* All:   0 derived from pxvidformat	    */
			    /* Bt819: 1 NTSC, 3 PAL(B,D,G,H,I)		    */
			    /*						    */
			    /* Bt829: 1 NTSC, 3 PAL(B,D,G,H,I)		    */
			    /*	      4 PAL(M), 5 PAL(N), 6 SECAM	    */
			    /* Bt848: 1 NTSC, 2 NTSC Japan,		    */
			    /*	      3 PAL(B,D,G,H,I)			    */
			    /*	      4 PAL(M), 5 PAL(N), 6 SECAM	    */
			    /* Bt878: 1 NTSC, 2 NTSC Japan,		    */
			    /*	      3 PAL(B,D,G,H,I)			    */
			    /*	      4 PAL(M), 5 PAL(N), 6 SECAM	    */
			    /*	      7 PAL(N Combo)			    */
			    /* Cx2388x: 1 NTSC-M, 2 NTSC-J, 3 PAL-BDGHI     */
			    /*		4 PAL-M, 5 PAL-N, 7 PAL-Nc,	    */
			    /*		8 PAL 60, 6 SECAM		    */

    uint8   Bt8x9xtal;	    /* 1: Xtal 1, 2: Xtal 2			    */
    uint8   Bt8x9control;   /* bits 0b11110000 for CONTROL register	    */
			    /* also used for Bt848, Bt878, Cx2388x	    */

    uint8   Bt819oform;     /* bits 0b11100000 for OFORM register	    */
    uint8   Bt819vscale;    /* bits 0b11100000 for VSCALE_HI register	    */
    uint8   Bt819adc;	    /* bits 0b11110110 for ADC register 	    */

    uint8   Bt829oform;     /* bits 0b11100000 for OFORM register	    */
			    /* also used for Bt848, Bt878, Cx2388x	    */
    uint8   Bt829vscale;    /* bits 0b11100000 for VSCALE_HI register	    */
			    /* also used for Bt848, Bt878, Cx2388x	    */
			    /* for Bt878: bits 0x03 refine use of bit 0x80  */
    uint8   Bt829adc;	    /* bits 0b00110110 for ADC register 	    */
    uint8   Bt829vtc;	    /* bits 0b00000011 for VTC register 	    */
			    /* also used for Bt848, Bt878, Cx2388x	    */

    uint8   Bt829scloop;    /* bits 0b01100000 for SCLOOP register	    */
			    /* also used for Bt848, Bt878, Cx2388x	    */
    uint8   Bt848adc;	    /* bits 0b00110111 for ADC register 	    */
			    /* also used for Cx2388x			    */
    uint8   Bt848clrctl;    /* bits 0b01010000 for COLOR CONTROL register   */
			    /* also used for Cx2388x			    */

    uint8   Bt819options;   /* Bit 0: monochrome: underlay color in same    */
			    /* image buffer, reducing image buffer size, but*/
			    /* buffer should not be examined during capture */
			    /* Bt819 and Bt829 only.			    */

    uint32  Bt848faultmask; /* INT_STAT bits that should generate faults    */
    uint32  Bt848haltmask;  /* INT_STAT bits that should terminate video    */
			    /* Some error conditions may always fault/halt  */
			    /* For Bt848, Bt878, Cx2388x		    */

    uint8   rsvd[8];
};
typedef struct xcsv2format  xcsv2format_s;
#define XCMOS_SV2FORMAT     (PXMOS_DDCH+14+2+8)


/*
 * For PIXCI(R) SV7 frame grabbers.
 * Must be identical to xcsv2format, albeit with different m.o.s. names
 * Familiarity with the underlying MAX9526 chip is implied.
 */
struct xcsv7format {
    struct  pxddch  ddch;

    uint8   Max9526format;	/* video format code		*/
				/* t.b.d.			*/
    uint8   Max9526standard;	/* as per Maxim 9526 data sheet */
    uint8   Max9526videoin;	/* as per Maxim 9526 data sheet */
    uint8   Max9526gainctrl;	/* as per Maxim 9526 data sheet */
    uint8   Max9526colorkill;	/* as per Maxim 9526 data sheet */
    uint8   Max9526test;	/* as per Maxim 9526 data sheet */
    uint8   Max9526clock;	/* as per Maxim 9526 data sheet */
    uint8   Max9526pll; 	/* as per Maxim 9526 data sheet */
    uint8   Max9526misc;	/* as per Maxim 9526 data sheet */

    uint8   rsvd1[5];

    uint32  rsvd2[2];

    uint8   rsvd3[8];
};
typedef struct xcsv7format  xcsv7format_s;
#define XCMOS_SV7FORMAT     (PXMOS_DDCH+9+5+2+8)


/*
 * For PIXCI(R) A310 frame grabbers.
 * Familiarity with the underlying Texas Instruments TVP7002 chip is implied.
 */
struct xca310format {
    struct  pxddch  ddch;

    uint32  pllStd;			/* select method of setting PLL */
					/* 0: from pllRate		*/
					/* !0: from pllDiv, pllControl, */
					/*     pllPhase 		*/
					/* 1-38: per predefined formats */
    uint32  pllRate[3]; 		/* line rate, rational, KHz	*/
					/* pixels per line		*/
    uint16  pllDiv;			/* as per TVP7002 data sheet	*/
    uint16  cscCoef[9]; 		/* reserved			*/
    uint16  rsvd0[8];			/* reserved			*/
    uint8   pllControl; 		/* as per TVP7002 data sheet	*/
    uint8   pllPhase;			/* as per TVP7002 data sheet	*/
    uint8   clampStart; 		/* as per TVP7002 data sheet	*/
    uint8   clampWidth; 		/* as per TVP7002 data sheet	*/
    uint8   hsyncOutputWidth;		/* as per TVP7002 data sheet	*/
    uint8   hsyncOutputStart;		/* as per TVP7002 data sheet	*/
    uint8   syncControl1;		/* as per TVP7002 data sheet	*/
    uint8   pllAndClampControl; 	/* as per TVP7002 data sheet	*/
    uint8   fineClampControl;		/* as per TVP7002 data sheet	*/
    uint8   coarseClampControl; 	/* as per TVP7002 data sheet	*/
    uint8   sogThreshold;		/* as per TVP7002 data sheet	*/
    uint8   sogClamp;			/* as per TVP7002 data sheet	*/
    uint8   syncSeparatorThreshold;	/* as per TVP7002 data sheet	*/
    uint8   pllPreCoast;		/* as per TVP7002 data sheet	*/
    uint8   pllPostCoast;		/* as per TVP7002 data sheet	*/
    uint8   outputFormatter;		/* as per TVP7002 data sheet	*/
    uint8   miscControl1;		/* as per TVP7002 data sheet	*/
    uint8   miscControl2;		/* as per TVP7002 data sheet	*/
    uint8   miscControl3;		/* as per TVP7002 data sheet	*/
    uint8   miscControl4;		/* as per TVP7002 data sheet	*/
    uint8   inputMuxSelect1;		/* as per TVP7002 data sheet	*/
    uint8   inputMuxSelect2;		/* as per TVP7002 data sheet	*/
    uint8   alcEnable;			/* as per TVP7002 data sheet	*/
    uint8   alcFilter;			/* as per TVP7002 data sheet	*/
    uint8   alcPlacement;		/* as per TVP7002 data sheet	*/
    uint8   powerControl;		/* as per TVP7002 data sheet	*/
    uint8   adcSetup;			/* as per TVP7002 data sheet	*/
    uint8   rgbCoarseClampControl;	/* as per TVP7002 data sheet	*/
    uint8   sogCoarseClampControl;	/* as per TVP7002 data sheet	*/
    uint8   macStripperWidth;		/* as per TVP7002 data sheet	*/
    uint8   vsyncAlignment;		/* as per TVP7002 data sheet	*/
    uint8   syncBypass; 		/* as per TVP7002 data sheet	*/
    uint8   lineLengthTolerance;	/* as per TVP7002 data sheet	*/
    uint8   videoBandwidthControl;	/* as per TVP7002 data sheet	*/
    uint8   vblkField0LineOffset;	/* as per TVP7002 data sheet	*/
    uint8   vblkField1LineOffset;	/* as per TVP7002 data sheet	*/
    uint8   vblkField0Duration; 	/* as per TVP7002 data sheet	*/
    uint8   vblkField1Duration; 	/* as per TVP7002 data sheet	*/
    uint8   fbitField0StartLineOffset;	/* as per TVP7002 data sheet	*/
    uint8   fbitField1StartLineOffset;	/* as per TVP7002 data sheet	*/
    uint8   rsvd1[16];			/* reserved			*/
};

typedef struct xca310format  xca310format_s;
#define XCMOS_A310FORMAT     (PXMOS_DDCH+4+1+9+8+40+16)


struct xca310mode {
    struct  pxddch  ddch;

					/* order: R, G, B		*/
    sint16  fineOffset[3];		/* as per TVP7002 data sheet	*/
    uint16  gain[3];			/* as per TVP7002 data sheet	*/
    sint16  offset[3];			/* as per TVP7002 data sheet	*/
    uint16  fineGain[3];		/* as per TVP7002 data sheet	*/

    uint16  rsvd[8];
};
typedef struct xca310mode    xca310mode_s;
#define XCMOS_A310MODE	     (PXMOS_DDCH+3+3+3+3+8)

/*
 * For PIXCI(R) SV8 frame grabbers.
 * Familiarity with the underlying Analog Devices ADV7403 chip is implied.
 */
struct xcsv8format {
    struct  pxddch  ddch;

    uint16  CSC[12];		    /* A[1234], B[1234], C[1234]    */
				    /* as per ADV7403 data sheet    */
    uint16  CPClampA;		    /* as per ADV7403 data sheet    */
    uint16  CPClampB;		    /* as per ADV7403 data sheet    */
    uint16  CPClampC;		    /* as per ADV7403 data sheet    */
    uint16  CPHVFStartHS;	    /* as per ADV7403 data sheet    */
    uint16  CPHVFEndHS; 	    /* as per ADV7403 data sheet    */
    uint16  CPTLLCDivRatio;	    /* as per ADV7403 data sheet    */
    uint16  FreeRunLineLength;	    /* as per ADV7403 data sheet    */
    uint16  ADISequenceGroup;	    /* index to set of firmware tweaks */
    uint16  rsvd1[16];
    uint8   InputControl;	    /* as per ADV7403 data sheet    */
    uint8   VideoSelection;	    /* as per ADV7403 data sheet    */
    uint8   OutputControl;	    /* as per ADV7403 data sheet    */
    uint8   ExtendedOutputControl;  /* as per ADV7403 data sheet    */
    uint8   PrimaryMode;	    /* as per ADV7403 data sheet    */
    uint8   VideoStandard;	    /* as per ADV7403 data sheet    */
    uint8   AutoDetectEnable;	    /* as per ADV7403 data sheet    */
    uint8   DefaultValueY;	    /* as per ADV7403 data sheet    */
    uint8   DefaultValueC;	    /* as per ADV7403 data sheet    */
    uint8   PowerManagement;	    /* as per ADV7403 data sheet    */
    uint8   AnalogueClampControl;   /* as per ADV7403 data sheet    */
    uint8   DigitalClamp;	    /* as per ADV7403 data sheet    */
    uint8   ShapingFilterControl;   /* as per ADV7403 data sheet    */
    uint8   ShapingFilterControl2;  /* as per ADV7403 data sheet    */
    uint8   CombFilterControl;	    /* as per ADV7403 data sheet    */
    uint8   PixelDelayControl;	    /* as per ADV7403 data sheet    */
    uint8   MiscGainControl;	    /* as per ADV7403 data sheet    */
    uint8   AGCModeControl;	    /* as per ADV7403 data sheet    */
    uint8   ChromaGainControl1;     /* as per ADV7403 data sheet    */
    uint8   LumaGainControl1;	    /* as per ADV7403 data sheet    */
    uint8   NTSCCombControl;	    /* as per ADV7403 data sheet    */
    uint8   PALCombControl;	    /* as per ADV7403 data sheet    */
    uint8   ADCControl; 	    /* as per ADV7403 data sheet    */
    uint8   TLLCControl;	    /* as per ADV7403 data sheet    */
    uint8   ManualWindow;	    /* as per ADV7403 data sheet    */
    uint8   ResampleControl;	    /* as per ADV7403 data sheet    */
    uint8   CTIDNRControl1;	    /* as per ADV7403 data sheet    */
    uint8   CTIDNRControl2;	    /* as per ADV7403 data sheet    */
    uint8   CTIDNRControl4;	    /* as per ADV7403 data sheet    */
    uint8   LockCount;		    /* as per ADV7403 data sheet    */
    uint8   CSC1;		    /* as per ADV7403 data sheet    */
    uint8   CSC22;		    /* as per ADV7403 data sheet    */
    uint8   CSC23;		    /* as per ADV7403 data sheet    */
    uint8   Configure1; 	    /* as per ADV7403 data sheet    */
    uint8   TTLCPhaseAdjust;	    /* as per ADV7403 data sheet    */
    uint8   CPOutputSelection;	    /* as per ADV7403 data sheet    */
    uint8   CPClamp1;		    /* as per ADV7403 data sheet    */
    uint8   CPAGC1;		    /* as per ADV7403 data sheet    */
    uint8   CPAGC3;		    /* as per ADV7403 data sheet    */
    uint8   CPOffset1;		    /* as per ADV7403 data sheet    */
    uint8   CPAVControl;	    /* as per ADV7403 data sheet    */
    uint8   CPHVFControl1;	    /* as per ADV7403 data sheet    */
    uint8   CPHVFControl4;	    /* as per ADV7403 data sheet    */
    uint8   CPHVFControl5;	    /* as per ADV7403 data sheet    */
    uint8   CPMeasureControl3;	    /* as per ADV7403 data sheet    */
    uint8   CPMeasureControl4;	    /* as per ADV7403 data sheet    */
    uint8   CPDetectionControl1;    /* as per ADV7403 data sheet    */
    uint8   CPMiscControl1;	    /* as per ADV7403 data sheet    */
    uint8   CPTLLCControl1;	    /* as per ADV7403 data sheet    */
    uint8   CPTLLCControl3;	    /* as per ADV7403 data sheet    */
    uint8   CPTLLCControl4;	    /* as per ADV7403 data sheet    */
    uint8   DPPCP64;		    /* as per ADV7403 data sheet    */
    uint8   DPPCP97;		    /* as per ADV7403 data sheet    */
    uint8   DPPCP98;		    /* as per ADV7403 data sheet    */
    uint8   CPDefCol1;		    /* as per ADV7403 data sheet    */
    uint8   CPDefCol2;		    /* as per ADV7403 data sheet    */
    uint8   CPDefCol3;		    /* as per ADV7403 data sheet    */
    uint8   CPDefCol4;		    /* as per ADV7403 data sheet    */
    uint8   ADCSwitch1; 	    /* as per ADV7403 data sheet    */
    uint8   ADCSwitch2; 	    /* as per ADV7403 data sheet    */
    uint8   ClampAveraging;	    /* as per ADV7403 data sheet    */
    uint8   DDRMode;		    /* as per ADV7403 data sheet    */
    uint8   LetterboxControl1;	    /* as per ADV7403 data sheet    */
    uint8   LetterboxControl2;	    /* as per ADV7403 data sheet    */
    uint8   NTSCVBitBegin;	    /* as per ADV7403 data sheet    */
    uint8   NTSCVBitEnd;	    /* as per ADV7403 data sheet    */
    uint8   NTSCFBitToggle;	    /* as per ADV7403 data sheet    */
    uint8   PALVBitBegin;	    /* as per ADV7403 data sheet    */
    uint8   PALVBitEnd; 	    /* as per ADV7403 data sheet    */
    uint8   PALFBitToggle;	    /* as per ADV7403 data sheet    */
    uint8   VBlankControl1;	    /* as per ADV7403 data sheet    */
    uint8   VBlankControl2;	    /* as per ADV7403 data sheet    */
    uint8   FBControl1; 	    /* as per ADV7403 data sheet    */
    uint8   FBControl2; 	    /* as per ADV7403 data sheet    */
    uint8   FBControl3; 	    /* as per ADV7403 data sheet    */
    uint8   FBControl4; 	    /* as per ADV7403 data sheet    */
    uint8   FBControl5; 	    /* as per ADV7403 data sheet    */
    uint8   AFEControl1;	    /* as per ADV7403 data sheet    */
    uint8   IFFilter;		    /* as per ADV7403 data sheet    */
    uint8   VSModeControl;	    /* as per ADV7403 data sheet    */
    uint8   CoringThreshold2;	    /* as per ADV7403 data sheet    */
    uint8   rsvd2[31];
};

typedef struct xcsv8format  xcsv8format_s;
#define XCMOS_SV8FORMAT     (PXMOS_DDCH+12+8+16+81+31)

struct xcsv8mode {
    struct  pxddch  ddch;

			    /* only in SDP mode w AGC manual	*/
    uint16  SDPChromaGain;  /* as per ADV7403 data sheet	*/
    uint16  SDPLumaGain;    /* as per ADV7403 data sheet	*/

			    /* only in CP mode w AGC manual	*/
    uint16  CPGainA;	    /* as per ADV7403 data sheet	*/
    uint16  CPGainB;	    /* as per ADV7403 data sheet	*/
    uint16  CPGainC;	    /* as per ADV7403 data sheet	*/
			    /* only in CP mode w AGC target	*/
    uint16  CPAgcTarget;    /* as per ADV7403 data sheet	*/

			    /* only in CP mode		    */
    uint16  CPOffsetA;	    /* as per ADV7403 data sheet    */
    uint16  CPOffsetB;	    /* as per ADV7403 data sheet    */
    uint16  CPOffsetC;	    /* as per ADV7403 data sheet    */

    uint16  rsvd1[15];


			    /* only in SDP modes		*/
    uint8   SDPLumaAgc;     /* 1: enabled, 2: frozen, 4: manual */
    uint8   SDPChromaAgc;   /* 1: enabled, 2: frozen, 4: manual, 8: use lumagain */
    sint8   SDPContrast;    /* as per ADV7403 data sheet	*/
    sint8   SDPBrightness;  /* as per ADV7403 data sheet	*/
    sint8   SDPHue;	    /* as per ADV7403 data sheet	*/
    uint8   SDOffsetCb;     /* as per ADV7403 data sheet	*/
    uint8   SDOffsetCr;     /* as per ADV7403 data sheet	*/
    uint8   SDSaturationCb; /* as per ADV7403 data sheet	*/
    uint8   SDSaturationCr; /* as per ADV7403 data sheet	*/
    uint8   SDPeakingGain;  /* as per ADV7403 data sheet	*/

			    /* only in CP mode			*/
    uint8   CPGainAgc;	    /* 0x01: enabled, 0x02: frozen, 0x10: enabled w. target, 0x04: manual */
    uint8   CPOffsetMode;   /* 1: auto offset, 4: manual offset */

    sint8   AdcMux[4];	    /* AINx input for each A/D		*/

    uint8   rsvd2[15];
};
typedef struct xcsv8mode    xcsv8mode_s;
#define XCMOS_SV8MODE	    (PXMOS_DDCH+2+4+3+10+13+2+4+15)



/*
 * For PIXCI(R) SV2/SV3/SV4/SV5 frame grabbers.
 * Familiarity with the underlying Bt819/Bt829/Bt848/Bt878 chips is implied.
 */
struct xcsv2mode {
    struct  pxddch  ddch;

    sint8   brightness;     /* add to luma channel, -128-+127, 0 default    */
    sint8   hue;	    /* add to demod subcarrier phase, -128-+127,    */
			    /* in units of .7 degrees, 0 default	    */
    uint16  lumagain;	    /* contrast: multiply w. luma channel, 0-511, 216 default */
    uint16  chromaUgain;    /* multiply w. U component, 0-511, 254 default  */
    uint16  chromaVgain;    /* multiply w. V component, 0-511, 180 default  */
    uint16  rsvd[8];
};
typedef struct xcsv2mode    xcsv2mode_s;
#define XCMOS_SV2MODE	    (PXMOS_DDCH+5+8)


/*
 * For PIXCI(R) A/CL3SD/D/D24/D32/D2X/CL1/CL2/E1/E4/E8/EB1POCL/EB1MINI/EC1/ECB1/ECB134/ECB2/EL1/E1DB
 * /EL1DB/ELS2/E8CAM/E4DB/E8DB/SI/SI1/SI2/SI4/e104x4/EB1mini/E4G2 frame grabbers.
 * Familiarity with the underlying frame grabber documentation is implied.
 */
struct xcdxxformat {
    struct  pxddch  ddch;

    uint16  PRINC;	/* PRINC bits	   (formerly initialargs[0]&0xFFFF)	    */
    uint16  EXSYNC;	/* EXSYNC bits	   (formerly initialargs[1]&0xFFFF)	    */
    uint16  exsync;	/*		   (formerly (initialargs[1]>>16)&0xFFFF    */
    uint16  prin;	/*		   (formerly (initialargs[0]>>16)&0xFFFF    */
    uint16  MWETS;	/* some MWETS bits (formerly initialargs[2])		    */
			/* (2LSBF)						    */
    uint16  LCD;	/* some LCD bits   (formerly initialargs[3])		    */
			/* (VDEND)						    */

    /*
     * Additions for PIXCI(R) A
     */
    uint16  PLLMX;		/* PLLMX bits (formerly initialargs[4]) 	    */
    uint16  clampreference;	/*	      (formerly initialargs[5]&0xFFFF	    */
    uint16  pixelclkreference;	/*	      (formerly (initialargs[5]>>16)&0xFFFF */

    /*
     * Additions for PIXCI(R) CL3SD
     */
    sint32  sdclkfreq[2];	/* SDRAM clock frequency, MHz, rational 	    */
    uint32  SDIET;		/* option bits					    */

    /*
     * Additions for D2X
     */
    uint16  PCWD;	/* some  PCWD bits					    */

    /*
     * Additions for CL2, E1, E4, E8, EB1, EB1POCL, EB1MINI, EC1, ECB1, ECB1-34,
     * ECB2, EL1, E1DB, E4DB, EL1DB, E8DB, E8CAM, e104x4, EB1mini, E4G2
     */
    uint16  CLCCSE;	/* some CLCCSE bits					    */
    uint16  TEST;	/* some VIDEOTEST bits					    */
    uint16  CLCCSEhi;	/* some CLCCSE high bits				    */
    uint16  MSSMUB;	/* some MSSMUB bits					    */

    /*
     * Additions for PIXCI(R) D w. Roper (Kodak) MASD Toucan.
     * Requires familiarity with Toucan documentation.
     * Should be 0 if Toucan not used.
     */
    uint32  ToucanOpt;		/* 00 thru 06: Black Setup		    */
				/* 07 thru 08: Toucan.dll rslt: BlueGain    */
				/* 09 thru 10: sharp gain		    */
				/* 11 thru 11: med edge only		    */
				/* 12 thru 12: detail only		    */
				/* 13 thru 13: clip on 2		    */
				/* 15 thru 15: one to enable loading Toucan */
				/* 16 thru 17: Bayer phase		    */
				/* (formerly initialargs[12])		    */
    uint32  ToucanCoef1;	/* Toucan.dll rslt: CCMRow[0]		    */
    uint32  ToucanCoef2;	/* Toucan.dll rslt: CCMRow[1]		    */
    uint32  ToucanCoef3;	/* Toucan.dll rslt: CCMRow[2]		    */
				/*   Col A: bits  0-9 : SNNN.DDDDDD (2's comp fract) */
				/*   Col B: bits 10-19: SNNN.DDDDDD (2's comp fract) */
				/*   Col C: bits 20-29: SNNN.DDDDDD (2's comp fract) */
				/* (formerly initialargs[13-15])		     */


    /*
     * Info
     */
    uint32  exsyncinfo[4];	/* min value, max value, scaling (rational, microsec)	*/
				/* formerly initialargs[8], [9], [10], [11]		*/
    uint32  prininfo[4];	/* min value, max value, scaling (rational, microsec)	*/

    /*
     * Additions for various custom boards
     */
    uint16  XXX;

    /*
     * Additions for CL2, E1, E4, E8, EB1, EB1POCL, EB1MINI, EC1, ECB1, ECB1-34, ECB2, EL1,
     * E1DB, E4DB, EL1DB, E8DB, e104x4, EB1mini, E4G2
     */
    uint16  CLCCGP;	    /* enable/disable CLCC control: video state vs. g.p.    */


    uint16  MSSMUBhi;	    /* some MSSMUB high bits				    */
    uint16  rsvd2[5];
};
typedef struct xcdxxformat xcdxxformat_s;
#define XCMOS_DXXFORMAT    (PXMOS_DDCH+6+3+8 +4 +2*4 +1+1+6)


union xcanalogformat
{
    struct xcsv2format	sv2format;
    struct xcsv7format	sv7format;
    struct xca310format a310format;
    struct xcsv8format	sv8format;
};
typedef union xcanalogformat xcanaformat_s;

union xcanalogmode
{
    struct xcsv2mode	sv2mode;
    struct xca310mode	a310mode;
    struct xcsv8mode	sv8mode;
};
typedef union xcanalogmode xcanamode_s;






#include "cext_hpe.h"     
#endif				/* !defined(__EPIX_XCLIBVS_DEFINED) */
