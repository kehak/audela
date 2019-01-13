/*
 * dmd40.h
 *
 * Copyright (c) 1997-2012 ETEL SA. All Rights Reserved.
 *
 * This software is the confidential and proprietary informatione of ETEL SA 
 * ("Confidential Information"). You shall not disclose such Confidential 
 * Information and shall use it only in accordance with the terms of the 
 * license agreement you entered into with ETEL.
 *
 * This software is provided "AS IS," without a warranty of any kind. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY
 * IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR
 * NON-INFRINGEMENT, ARE HEREBY EXCLUDED. ETEL AND ITS LICENSORS SHALL NOT BE
 * LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING
 * OR DISTRIBUTING THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL ETEL OR ITS
 * LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT,
 * INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER
 * CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF
 * OR INABILITY TO USE SOFTWARE, EVEN IF ETEL HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGES.
 *
 * This software is not designed or intended for use in on-line control of
 * aircraft, air traffic, aircraft navigation or aircraft communications; or in
 * the design, construction, operation or maintenance of any nuclear
 * facility. Licensee represents and warrants that it will not use or
 * redistribute the Software for such purposes.
 *
 */

/**
 * This header file contains public declaration for drive meta-data library.\n
 * This library allows access to the definitions of all ETEL drives'versions.\n
 * This library is only a pool of datas.\n
 * No access is made to the drive itself.\n 
 * The available datas are, for example, the list of all versions of a product,
 * the number of registers of a product, the minimum and maximum values of a
 * register, etc.\n
 * This library is conformed to POSIX 1003.1c, and has been ported on the following OS:
 * @li @c WIN32
 * @li @c WIN32 RTX
 * @li @c QNX6
 * @li @c LINUX 2.6
 * @li @c VXWORKS
 * @file dmd40.h
 */


#ifndef _DMD40_H
#define _DMD40_H

#ifdef __WIN32__			/* defined by Borland C++ Builder */
	#ifndef WIN32
		#define WIN32
	#endif
#endif

#ifdef __cplusplus
	#ifdef ETEL_OO_API		/* defined by the user when he need the Object Oriented interface */
		#define DMD_OO_API
	#endif
#endif 

/**
 * @defgroup DMDAll DMD All functions
 */
/*@{*/
/*@}*/

 /**
 * @defgroup DMDCommands DMD Command data access functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DMDConvert DMD Conversion functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DMDEnums DMD Enumeration data access functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DMDErrorsAndWarnings DMD Errors and warnings
 */
/*@{*/
/*@}*/

/**
 * @defgroup DMDObjectHandlingFunctions DMD Object handling functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DMDProduct DMD Product data access functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DMDRegister DMD Register data access functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DMDUtils DMD Utilities functions
 */
/*@{*/
/*@}*/

#ifdef __cplusplus
	extern "C" {
#endif

/**********************************************************************************************************/
/*- LIBRARIES */
/**********************************************************************************************************/

/*----------------------------------------------------------------------------------*/
/* BYTE ORDER */
/*----------------------------------------------------------------------------------*/

#ifndef __BYTE_ORDER

	/*------------------------------*/
	/* Windows Byte order			*/
	#if defined WIN32
		#define __LITTLE_ENDIAN 1234
		#define __BIG_ENDIAN 4321
		#define __BYTE_ORDER __LITTLE_ENDIAN			/* define byte order for INTEL processor */
	#endif /*WIN32*/

	/*------------------------------*/
	/* POSIX LINUX Byte order		*/
	#if defined POSIX && defined LINUX
		#include <endian.h>
	#endif /*LINUX*/

	/*------------------------------*/
	/* POSIX QNX6 Byte order		*/
	#if defined POSIX && defined QNX6
		#define __LITTLE_ENDIAN 1234
		#define __BIG_ENDIAN 4321
		#ifdef __BIGENDIAN__
			#define __BYTE_ORDER __BIG_ENDIAN			/* define byte order for SPARC processor */
		#else
			#define __BYTE_ORDER __LITTLE_ENDIAN        /* define byte order for SPARC processor */
		#endif
	#endif /*QNX6*/

	/*------------------------------*/
	/* VXWORKS Byte order			*/
	#ifdef VXWORKS
		#define __LITTLE_ENDIAN _LITTLE_ENDIAN
		#define __BIG_ENDIAN _BIG_ENDIAN
		#define __BYTE_ORDER _BYTE_ORDER
	#endif /*VXWORKS*/

#endif /*BYTE_ORDER*/

/*----------------------*/
/* common libraries		*/
#include <time.h>
#include <limits.h>
#ifdef WIN32
	//modif michel 
	//#if _MSC_VER > 1400
	#if _MSC_VER >= 1900
		#include <stdint.h>
	#else
		typedef unsigned int uint32_t;
	#endif
#endif
#ifdef POSIX
	#include <stdint.h>
#endif

/**********************************************************************************************************/
/*- LITTERALS */
/**********************************************************************************************************/

/*------------------------------------------------------------------------------
 * true/false boolean values
 *-----------------------------------------------------------------------------*/
#ifndef FALSE
	#define FALSE                            (unsigned char)0
#endif
#ifndef TRUE
	#define TRUE                             (unsigned char)1
#endif

/*------------------------------------------------------------------------------
 * error codes - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_EBADEXTVER                   -419        /**< an extention card with an incompatible version has been specified */
#define DMD_EBADDRVVER                   -418        /**< a drive with an incompatible version has been specified */
#define DMD_EBADEXTPROD                  -417        /**< an unknown extention card  product has been specified */
#define DMD_EBADDRVPROD                  -416        /**< an unknown drive product has been specified */
#define DMD_EBADPARAM                    -415        /**< one of the parameter is not valid */
#define DMD_ESYSTEM                      -414        /**< some system resource return an error */
#define DMD_EOBSOLETE                    -402        /**< function is obsolete */

#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * text query constants
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_TEXT_MNEMONIC                1           /* mnemonic */
	#define DMD_TEXT_SHORT                   2           /* short text description */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * drive special user variables
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_USR_ACC                      0xFFFF      /* special user data - accumulator */
	#define DMD_VAR_INDIRECT		         0xFFFE      /* indirect register access */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * special product number
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_PRODUCT_ANY_ACCURET          (-2)        /* special product number - any Simulate a AccurET*/
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * release status
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_MICRO_ALPHA                  0x00        /* base number for alpha releases */
	#define DMD_MICRO_BETA                   0x40        /* base number for beta releases */
	#define DMD_MICRO_FINAL                  0x80        /* base number for final releases */
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * some maximum values
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_TYPES                        128          /* no more than 128 types now */
	/* If you change this value, change WHERE clause in dmdCode, tableAllEnumGroups AND
	   dmdlocal.t _dmd_enum_grps[][];*/
	#define DMD_ENUMS                        256         /* no more than 256 enums now */
	#define DMD_COMMANDS                     1280        /* no more than 1280 commands now */
	#define DMD_CONVS                        256         /* no more than 256 conversions now */
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * display modes - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_DISPLAY_NORMAL               1           /* normal informations */
	#define DMD_DISPLAY_TEMPERATURE          2           /* drive temperature */
	#define DMD_DISPLAY_ENCODER              4           /* analog encoder signals */
	#define DMD_DISPLAY_SEQUENCE             8           /* sequence line number */
	#define DMD_DISPLAY_DC_VOLTAGE          32          /* DC voltage */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * drive error codes - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_EDRV_FPGA_OSCILLATOR              103        
#define DMD_EDRV_GANTRY_HOME_OFFSET_DIFF      124        
#define DMD_EDRV_GANTRY_ERROR                 118        
#define DMD_EDRV_GANTRY_DIFF_PARAMETER        122        
#define DMD_EDRV_GANTRY_BAD_CMD               121        
#define DMD_EDRV_FUNCTION_NOT_IMPLEMENTED     44         
#define DMD_EDRV_ENDAT_TIMEOUT                27         
#define DMD_EDRV_FPGA_OVER_VOLTAGES           102        
#define DMD_EDRV_GANTRY_TRACKING_ERROR        119        
#define DMD_EDRV_FPGA_INIT                    105        
#define DMD_EDRV_FPGA_CLK                     104        
#define DMD_EDRV_FDOUT_CFG_ERROR              42         
#define DMD_EDRV_F2F_ERRORS                   100        
#define DMD_EDRV_ETHERNET_LOST                49         
#define DMD_EDRV_KEEP_ALIVE_TIMEOUT           55         
#define DMD_EDRV_FPGA_WATCHDOG                101        
#define DMD_EDRV_I2T_OVER_CURRENT             4          
#define DMD_EDRV_ADVANCED_FILTER_BAD_SETTING  32         
#define DMD_EDRV_K79_BAD_VALUE                40         
#define DMD_EDRV_INIT_MOTOR_DISABLED          152        
#define DMD_EDRV_INIT_MOTOR_2                 151        
#define DMD_EDRV_INIT_MOTOR_1                 150        
#define DMD_EDRV_INIT_LOW_TIME                155        
#define DMD_EDRV_GANTRY_NO_SLAVE_SEQUENCE     123        
#define DMD_EDRV_INIT_HIGH_CUR                154        
#define DMD_EDRV_GANTRY_POWERON_ERROR         120        
#define DMD_EDRV_I2T                         11         
#define DMD_EDRV_HOMING_SWITCH_PRESENT        60         
#define DMD_EDRV_HOMING_NOT_POSSIBLE          69         
#define DMD_EDRV_HOMING_NOT_DONE              71         
#define DMD_EDRV_HOMING_MECH_STOP             64         
#define DMD_EDRV_ENDAT_POS_LOST               17         
#define DMD_EDRV_INIT_LOW_CUR                 153        
#define DMD_EDRV_BAD_TEMPERATURE_SENSOR       13         
#define DMD_EDRV_CHUNK_ERROR                  207        
#define DMD_EDRV_CFG_EXT3_ERROR               213        
#define DMD_EDRV_CFG_EXT2_ERROR               212        
#define DMD_EDRV_CFG_EXT1_ERROR               211        
#define DMD_EDRV_BRIDGE_OVERCUR2              136        
#define DMD_EDRV_ERR_COMMAND_ERROR            116        
#define DMD_EDRV_BRIDGE_ERROR                 131        
#define DMD_EDRV_CYCLIC_DATA_ERROR            202        
#define DMD_EDRV_BAD_SEQ_THREAD               402        
#define DMD_EDRV_BAD_SEQ_REG_IDX              401        
#define DMD_EDRV_BAD_SEQ_LABEL                36         
#define DMD_EDRV_BAD_REG_IDX                  38         
#define DMD_EDRV_BAD_FW_VERSION               43         
#define DMD_EDRV_AUT_TIMEOUT                  156        
#define DMD_EDRV_BRIDGE_OVERCUR1              135        
#define DMD_EDRV_DWN_UPL_ERROR                206        
#define DMD_EDRV_ENDAT_OVERFLOW               16         
#define DMD_EDRV_ENDAT_ENCODER_ERROR          31         
#define DMD_EDRV_ENDAT_BAD_READ               19         
#define DMD_EDRV_ENDAT_BAD_CRC                18         
#define DMD_EDRV_ENCODER2_AMPLITUDE           22         
#define DMD_EDRV_ENCODER_POSITION_LOST        21         
#define DMD_EDRV_CHUNK_OVERRUN                201        
#define DMD_EDRV_ENCODER_AMPLITUDE            20         
#define DMD_EDRV_CMD_BAD_PARAM                70         
#define DMD_EDRV_DOUT_FUSE_BROKEN             14         
#define DMD_EDRV_DOUT_CFG_ERROR               45         
#define DMD_EDRV_DIPSWITCH_CFG_ERROR          57         
#define DMD_EDRV_DIGITAL_HALL_WRONG_VALUE     191        
#define DMD_EDRV_DFC_CFG_ERROR                47         
#define DMD_EDRV_LEAK_OVERCURRENT             130        
#define DMD_EDRV_ENCODER_FUSE_KO              35         
#define DMD_EDRV_SLOT_CFG_ERROR               58         
#define DMD_EDRV_STREAM_BUFFER                204        
#define DMD_EDRV_STAGE_PROT_SETTING           215        
#define DMD_EDRV_STAGE_PROT_OTHER_AXIS        214        
#define DMD_EDRV_STAGE_PROT_INIT_ERROR        210        
#define DMD_EDRV_STAGE_MAPPING_STEP_CFG_ERROR 77         
#define DMD_EDRV_SEQ_BAD_CMD_PARAM            405        
#define DMD_EDRV_STAGE_MAPPING_BAD_PARAM      76         
#define DMD_EDRV_STRETCH_CFG_ERROR            73         
#define DMD_EDRV_SINGLE_INDEX                 62         
#define DMD_EDRV_SEQUENCE_ERROR_0408          408        
#define DMD_EDRV_SEQ_ZERO_DIVISION            404        
#define DMD_EDRV_SEQ_THREAD_RUNNING           403        
#define DMD_EDRV_SEQ_BAD_REGISTER             406        
#define DMD_EDRV_K89_BAD_VALUE                41         
#define DMD_EDRV_STAGE_MAPPING_ERROR          75         
#define DMD_EDRV_TRANSNET_ETCOM_BUFFER_OVERFL 84         
#define DMD_EDRV_WD_POSITION_FPGA             141        
#define DMD_EDRV_USB_INPUT_BUFFER_FULL        87         
#define DMD_EDRV_USB_CHECKSUM_ERROR           86         
#define DMD_EDRV_UNDER_VOLTAGE                9          
#define DMD_EDRV_UNDEFINED_SEQ_LABEL          400        
#define DMD_EDRV_TRIGGER_CFG_ERROR            46         
#define DMD_EDRV_STREAM_OVERRUN               200        
#define DMD_EDRV_TRANSNET_REF_MODE_CFG_ERROR  59         
#define DMD_EDRV_STREAM_WRITE                 203        
#define DMD_EDRV_TRANSNET_ETCOM_BAD_SIZE      85         
#define DMD_EDRV_TRACKING_ERROR               23         
#define DMD_EDRV_TCP_OUTPUT_BUFFER_FULL       50         
#define DMD_EDRV_TCP_INPUT_BUFFER_FULL        51         
#define DMD_EDRV_SYNCHRO_START                63         
#define DMD_EDRV_SCALE_MAPPING_CFG_ERROR      74         
#define DMD_EDRV_TRANSNET_TIMEOUT             56         
#define DMD_EDRV_LOAD_OVERCUR2                134        
#define DMD_EDRV_OVER_CURRENT_3               3          
#define DMD_EDRV_OVER_CURRENT_1               2          
#define DMD_EDRV_OUT_OF_STROKE                65         
#define DMD_EDRV_OPTIONAL_BOARD_FLASH_CORRUPT 99         
#define DMD_EDRV_MULTIPLE_INDEX               61         
#define DMD_EDRV_SEQ_BAD_NODE                 407        
#define DMD_EDRV_MASTER_POWER_OFF             67         
#define DMD_EDRV_OVER_TEMPERATURE             5          
#define DMD_EDRV_LOAD_OVERCUR1                133        
#define DMD_EDRV_LINEAR_OVERCUR3              140        
#define DMD_EDRV_LINEAR_OVERCUR2              139        
#define DMD_EDRV_LINEAR_OVERCUR1              138        
#define DMD_EDRV_LINEAR_AMPLI_ERROR           137        
#define DMD_EDRV_LIMIT_SWITCH                 30         
#define DMD_EDRV_MON_VOLTAGE                  15         
#define DMD_EDRV_POWER_MULTI_OTHER_AXIS_POWER 127        
#define DMD_EDRV_SAV_COMMAND                  190        
#define DMD_EDRV_SAG_POWER                    25         
#define DMD_EDRV_SAFETY_RELAY_POWER_ON        132        
#define DMD_EDRV_REF_OUT_OF_STROKE            66         
#define DMD_EDRV_PWR_ON_IN_ITP_MODE           68         
#define DMD_EDRV_PWR_ON_DRV_CFG_ERROR         72         
#define DMD_EDRV_OVER_OFFSET                  10         
#define DMD_EDRV_POWER_ON                     26         
#define DMD_EDRV_OVER_SPEED                   24         
#define DMD_EDRV_POWER_MULTI_OTHER_AXIS_ERROR 126        
#define DMD_EDRV_POWER_MULTI_AXIS_CONFIG      125        
#define DMD_EDRV_PHASING_BAD_INIT             157        
#define DMD_EDRV_OVERTEMP_ERROR               29         
#define DMD_EDRV_OVER_VOLTAGE                 6          
#define DMD_EDRV_WD_QUARTZ                    144        
#define DMD_EDRV_POWER_SUPPLY_INRUSH          7          


#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * kind of encoder - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_ENCODER_ANALOG               0           /* analog encoder */
	#define DMD_ENCODER_TTL                  1           /* TTL encoder */
	#define DMD_ENCODER_TTL_HF               2           /* TTL High frequency encoder */
	#define DMD_ENCODER_ENDAT_22             3           /* ENDAT 2.2 encoder */
	#define DMD_ENCODER_ENDAT_21             4           /* ENDAT 2.1 encoder */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * homing modes - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_HOMING_MECHANICAL            0           /* mechanical end stop */
	#define DMD_HOMING_NEGATIVE_MVT          1           /* negative movement */
	#define DMD_HOMING_HOME_SW               2           /* home switch */
	#define DMD_HOMING_LIMIT_SW              4           /* limit switch */
	#define DMD_HOMING_HOME_SW_L             6           /* home switch w/limit */
	#define DMD_HOMING_SINGLE_INDEX          8           /* single index */
	#define DMD_HOMING_SINGLE_INDEX_L        10          /* single index w/limit */
	#define DMD_HOMING_MULTI_INDEX           12          /* multi-index */
	#define DMD_HOMING_MULTI_INDEX_L         14          /* multi-index w/limit */
	#define DMD_HOMING_GATED_INDEX           16          /* single index and DIN2 */
	#define DMD_HOMING_GATED_INDEX_L         18          /* single index and DIN2 w/limit */
	#define DMD_HOMING_MULTI_INDEX_DS        20          /* multi-index w/defined stroke */
	#define DMD_HOMING_IMMEDIATE             22          /* immediate */
	#define DMD_HOMING_SINGLE_INDEX_DS       24          /* single index w/defined stroke */
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * init modes - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_INIT_NONE                    0           /* none */
	#define DMD_INIT_PULSE                   1           /* current pulses */
	#define DMD_INIT_CONTINOUS               2           /* continous current */
	#define DMD_INIT_HALL_UNTIL_INDEX        3           /* digital hall sensor until index */
	#define DMD_INIT_HALL_UNTIL_EDGE         4           /* digital hall sensor until edge */
	#define DMD_INIT_HALL                    5           /* digital hall sensor */
	#define DMD_INIT_SMALL_MVT               6           /* Small movements phasing */
	#define DMD_INIT_SMALL_MVT_REPEAT        7           /* Small movements phasing repeat 3 times*/
	
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * drive mode - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_MODE_FORCE_REFERENCE         0           /* force reference */
	#define DMD_MODE_POSITION_PROFILE        1           /* position profile */
	#define DMD_MODE_SPEED_REFERENCE         3           /* speed reference */
	#define DMD_MODE_POSITION_REFERENCE      4           /* position reference */
	#define DMD_MODE_POSITION_REFERENCE_2    36          /* position reference */
	#define DMD_MODE_PULSE_DIRECTION_TTL_2   38          /* pulse direction TTL */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * motor phases - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_PWM_MODE_PHASES_1             10          /* 1 phase motor */
	#define DMD_PWM_MODE_PHASE_1_LOW_SWITCHI  11          /* 1 phase motor with low switching freq */
	#define DMD_PWM_MODE_PHASES_2             20          /* 2 phase motor */
	#define DMD_PWM_MODE_PHASE_2_LOW_SWITCHI  21          /* 2 phase motor with low switching freq. */
	#define DMD_PWM_MODE_PHASES_3             30          /* 3 phase motor */
	#define DMD_PWM_MODE_PHASE_3_LOW_SWITCHI  31          /* 3 phase motor with low switching freq. */
	#define DMD_PWM_MODE_PHASE_3_VLOW_SWITCHI 34          /* 3 phase motor with very low switching freq. */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * types of movement - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_MVT_TRAPEZIODAL              0           /* trapezoidal movement */
	#define DMD_MVT_S_CURVE                  1           /* S-curve movement */
	#define DMD_MVT_STEP 	                 5           /* Step movement */
	#define DMD_MVT_LKT_LINEAR               10          /* LKT linear movement */
	#define DMD_MVT_SCURVE_ROTARY            17          /* S-curve rotary movement */
	#define DMD_MVT_INFINITE_ROTARY          24          /* infinite rotary movement */
	#define DMD_MVT_LKT_ROTARY               26          /* LKT rotary movement */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * drive products - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_PRODUCT_ACCURET              32          /* AccurET drive */
	#define DMD_PRODUCT_ACCURET_48V          33          /* AccurET 48V drive */
	#define DMD_PRODUCT_ACCURET_300V         34          /* AccurET 300V drive */
	#define DMD_PRODUCT_ACCURET_DFC          35          /* AccurET DFC drive */
	#define DMD_PRODUCT_ACCURET_VHP          36          /* AccurET VHP drive */
	#define DMD_PRODUCT_ACCURET_MAGLEV       37          /* AccurET MAGLEV */
	#define DMD_PRODUCT_ULTIMET              48          /* UltimET multi-axis controller */
	#define DMD_PRODUCT_ULTIMET_TCPIP        49          /* UltimET TCPIP multi-axis controller */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * extension card products - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_X_PRODUCT_ACCURET_OPTIONAL_IO_BOARD 64	 /* AccurET Optional IO board*/
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * source type - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_TYP_BASIS_MASK				0x1F		/**< mask applied on a byte representing a type to obtain the type basis */
	#define DMD_TYP_FLOAT_BIT_MASK			0x20		/**< mask applied on a byte representing a type to obtain the float bit */
	#define DMD_TYP_64_BIT_MASK				0x40		/**< mask applied on a byte representing a type to obtain the 64 bit */

	#define DMD_TYP_NONE                     0           /**< no type */
	#define DMD_TYP_IMMEDIATE                0           /**< disabled or immediate value */
	#define DMD_TYP_USER                     1           /**< user registers */
	#define DMD_TYP_PPK                      2           /**< drive parameters */
	#define DMD_TYP_MONITOR                  3           /**< monitoring registers */
	#define DMD_TYP_IMMEDIATE_HDWORD		 4           /**< immediate 64 bits value HIGH double-word*/
	#define DMD_TYP_TRACE                    6           /**< trace buffer */
	#define DMD_TYP_ADDRESS                  7           /**< address value */
	#define DMD_TYP_LKT                      8           /**< movement lookup tables */
	#define DMD_TYP_TRIGGER                  9           /**< triggers buffer */
	#define DMD_TYP_Y		                 11          /**< Y type variables */
	#define DMD_TYP_COMMON                   13          /**< common register */
	#define DMD_TYP_MAPPING                  14          /**< P mapping registers */

	#define DMD_TYP_IMMEDIATE_INT32				(DMD_TYP_IMMEDIATE)													/**< immediate integer 32 bits */
	#define DMD_TYP_IMMEDIATE_INT64				(DMD_TYP_IMMEDIATE | DMD_TYP_64_BIT_MASK)							/**< immediate integer 64 bits */
	#define DMD_TYP_IMMEDIATE_FLOAT32			(DMD_TYP_IMMEDIATE | DMD_TYP_FLOAT_BIT_MASK)						/**< immediate float 32 bits */
	#define DMD_TYP_IMMEDIATE_FLOAT64			(DMD_TYP_IMMEDIATE | DMD_TYP_FLOAT_BIT_MASK | DMD_TYP_64_BIT_MASK)	/**< immediate float 64 bits */
	#define DMD_TYP_IMMEDIATE_INT64_LDWORD		(DMD_TYP_IMMEDIATE_INT64)											/**< immediate integer 64 bits low double word*/
	#define DMD_TYP_IMMEDIATE_INT64_HDWORD		(DMD_TYP_IMMEDIATE_INT64 | DMD_TYP_IMMEDIATE_HDWORD)				/**< immediate integer 64 bits high double word*/
	#define DMD_TYP_IMMEDIATE_FLOAT64_LDWORD	(DMD_TYP_IMMEDIATE_FLOAT64)											/**< immediate integer 64 bits low double word*/
	#define DMD_TYP_IMMEDIATE_FLOAT64_HDWORD	(DMD_TYP_IMMEDIATE_FLOAT64 | DMD_TYP_IMMEDIATE_HDWORD)				/**< immediate integer 64 bits high double word*/

	#define DMD_TYP_USER_INT32					(DMD_TYP_USER)														/**< user register integer 32 bits */
	#define DMD_TYP_USER_INT64					(DMD_TYP_USER | DMD_TYP_64_BIT_MASK)								/**< user register integer 64 bits */
	#define DMD_TYP_USER_FLOAT32				(DMD_TYP_USER | DMD_TYP_FLOAT_BIT_MASK)								/**< user register float 32 bits */
	#define DMD_TYP_USER_FLOAT64				(DMD_TYP_USER | DMD_TYP_FLOAT_BIT_MASK | DMD_TYP_64_BIT_MASK)		/**< user register float 64 bits */

	#define DMD_TYP_PPK_INT32					(DMD_TYP_PPK)														/**< drive parameters integer 32 bits */
	#define DMD_TYP_PPK_INT64					(DMD_TYP_PPK | DMD_TYP_64_BIT_MASK)									/**< drive parameters integer 64 bits */
	#define DMD_TYP_PPK_FLOAT32					(DMD_TYP_PPK | DMD_TYP_FLOAT_BIT_MASK)								/**< drive parameters float 32 bits */
	#define DMD_TYP_PPK_FLOAT64					(DMD_TYP_PPK | DMD_TYP_FLOAT_BIT_MASK | DMD_TYP_64_BIT_MASK)		/**< drive parameters float 64 bits */

	#define DMD_TYP_MONITOR_INT32				(DMD_TYP_MONITOR)													/**< monitoring registers integer 32 bits */
	#define DMD_TYP_MONITOR_INT64				(DMD_TYP_MONITOR | DMD_TYP_64_BIT_MASK)								/**< monitoring registers integer 64 bits */
	#define DMD_TYP_MONITOR_FLOAT32				(DMD_TYP_MONITOR | DMD_TYP_FLOAT_BIT_MASK)							/**< monitoring registers float 32 bits */
	#define DMD_TYP_MONITOR_FLOAT64				(DMD_TYP_MONITOR | DMD_TYP_FLOAT_BIT_MASK | DMD_TYP_64_BIT_MASK)	/**< monitoring registers float 64 bits */

	#define DMD_TYP_TRACE_INT32					(DMD_TYP_TRACE)														/**< trace buffer integer 32 bits */
	#define DMD_TYP_TRACE_INT64					(DMD_TYP_TRACE | DMD_TYP_64_BIT_MASK)								/**< trace buffer integer 64 bits */
	#define DMD_TYP_TRACE_FLOAT32				(DMD_TYP_TRACE | DMD_TYP_FLOAT_BIT_MASK)							/**< trace buffer float 32 bits */
	#define DMD_TYP_TRACE_FLOAT64				(DMD_TYP_TRACE | DMD_TYP_FLOAT_BIT_MASK | DMD_TYP_64_BIT_MASK)		/**< trace buffer float 64 bits */

	#define DMD_TYP_LKT_FLOAT64                 (DMD_TYP_LKT | DMD_TYP_FLOAT_BIT_MASK | DMD_TYP_64_BIT_MASK)		/**< lookup table float 64 bits */

	#define DMD_TYP_TRIGGER_INT64				(DMD_TYP_TRIGGER | DMD_TYP_64_BIT_MASK)								/**< trigger buffer integer 64 bits */

	#define DMD_TYP_Y_INT32						(DMD_TYP_Y)															/**< Y type variables integer 32 bits */
	#define DMD_TYP_Y_INT64						(DMD_TYP_Y | DMD_TYP_64_BIT_MASK)									/**< Y type variables integer 64 bits */
	#define DMD_TYP_Y_FLOAT32					(DMD_TYP_Y | DMD_TYP_FLOAT_BIT_MASK)								/**< Y type variables float 32 bits */
	#define DMD_TYP_Y_FLOAT64					(DMD_TYP_Y | DMD_TYP_FLOAT_BIT_MASK | DMD_TYP_64_BIT_MASK)			/**< Y type variables float 64 bits */

	#define DMD_TYP_COMMON_INT32				(DMD_TYP_COMMON)													/**< common register integer 32 bits */
	#define DMD_TYP_COMMON_INT64				(DMD_TYP_COMMON | DMD_TYP_64_BIT_MASK)								/**< common register integer 64 bits */
	#define DMD_TYP_COMMON_FLOAT32				(DMD_TYP_COMMON | DMD_TYP_FLOAT_BIT_MASK)							/**< common register float 32 bits */
	#define DMD_TYP_COMMON_FLOAT64				(DMD_TYP_COMMON | DMD_TYP_FLOAT_BIT_MASK | DMD_TYP_64_BIT_MASK)		/**< user register float 64 bits */

	#define DMD_TYP_MAPPING_INT32				(DMD_TYP_MAPPING)													/**< P mapping integer 32 bits*/

	#define DMD_INCREMENT_INT32					0												/**< increment typ integer 32 bits */
	#define DMD_INCREMENT_INT64					(DMD_TYP_64_BIT_MASK)							/**< increment typ integer 64 bits */
	#define DMD_INCREMENT_FLOAT32				(DMD_TYP_FLOAT_BIT_MASK)							/**< increment typ float 32 bits */
	#define DMD_INCREMENT_FLOAT64				(DMD_TYP_64_BIT_MASK | DMD_TYP_FLOAT_BIT_MASK)		/**< increment typ float 64 bits bits */

#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * status drive 1 - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_SW1_POWER_ON                 0x00000001           /* power on */
	#define DMD_SW1_PRESENT                  0x00000008           /* present */
	#define DMD_SW1_MOVING                   0x00000010          	/* moving */
	#define DMD_SW1_IN_WINDOW                0x00000020          	/* in window */
	#define DMD_SW1_WAITING                  0x00000080         	/* driver is waiting */
	#define DMD_SW1_EXEC_SEQ                 0x00000100         	/* sequence execution */
	#define DMD_SW1_ERROR_ANY                0x00000400       	/* global error */
	#define DMD_SW1_TRACE_BUSY               0x00000800       	/* trace busy */
	#define DMD_SW1_WARNING_I2T              0x00800000     		/* warning */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * status drive 2 - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_SW2_BP_WAITING               0x00000010          	/* break point waiting */
	#define DMD_SW2_USER_0                   0x00000100         	/* user bit 0 */
	#define DMD_SW2_USER_1                   0x00000200         	/* user bit 1 */
	#define DMD_SW2_USER_2                   0x00000400        		/* user bit 2 */
	#define DMD_SW2_USER_3                   0x00000800        		/* user bit 3 */
	#define DMD_SW2_USER_4                   0x00001000        		/* user bit 4 */
	#define DMD_SW2_USER_5                   0x00002000        		/* user bit 5 */
	#define DMD_SW2_USER_6                   0x00004000       		/* user bit 6 */
	#define DMD_SW2_USER_7                   0x00008000       		/* user bit 7 */
	#define DMD_SW2_USER_BYTE                0x0000FF00       		/* user mask */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * reboot option - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_SHUTDOWN_MAGIC               255         /* magic number */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * setpoint buffer mask - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_SETPOINT_TARGET_POSITION     1           /* target position */
	#define DMD_SETPOINT_PROFILE_VELOCITY    2           /* profile velocity */
	#define DMD_SETPOINT_PROFILE_ACCELERATIO 4           /* profile acceleration */
	#define DMD_SETPOINT_JERK_FILTER_TIME    8           /* jerk filter time */
	#define DMD_SETPOINT_PROFILE_DECELERATIO 16          /* profile deceleration */
	#define DMD_SETPOINT_END_VELOCITY        32          /* end velocity */
	#define DMD_SETPOINT_PROFILE_TYPE        64          /* profile type */
	#define DMD_SETPOINT_MVT_LKT_NUMBER      128         /* lookup table number */
	#define DMD_SETPOINT_MVT_LKT_TIME        256         /* lookup table time */
	#define DMD_SETPOINT_MVT_LKT_AMPLITUDE   512         /* movement lookup table amplitude */
	#define DMD_SETPOINT_MVT_DIRECTION       1024        /* movement direction */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * rotary movement direction - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_MVT_DIR_POSITIVE             0           /* positive movement */
	#define DMD_MVT_DIR_NEGATIVE             1           /* negative movement */
	#define DMD_MVT_DIR_SHORTEST             2           /* shortest movement */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * concatenated mode - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_CONCAT_MODE_DISABLED         0           /* concatened movement disabled */
	#define DMD_CONCAT_MODE_ENABLED          1           /* concatened movement enabled */
	#define DMD_CONCAT_MODE_LKT_ONLY         2           /* concatened movement enabled for LKT */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * SLS selection mode - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_SLS_MODE_NEGATIVE_MVT        1           /* begin by negative movement */
	#define DMD_SLS_MODE_MECHANICAL          0           /* mechanical end stop */
	#define DMD_SLS_MODE_LIMIT_SW            2           /* limit switch */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * trace buffer - c
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_TRACE_BUFFER_0               0           /* buffer 0 */
	#define DMD_TRACE_BUFFER_1               1           /* buffer 1 */
	#define DMD_TRACE_BUFFER_2               2           /* buffer 2 */
	#define DMD_TRACE_BUFFER_3               3           /* buffer 3 */
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * special download/upload stream command
 *-----------------------------------------------------------------------------*/
//To upload a piece of memory: available on MAGLEV only
#define DMD_CMD_START_UPLOAD_MEMORY			        0xEF
#define DMD_CMD_START_DOWNLOAD_STREAM_FIRMWARE      0xF0
//#define 0xF1 is reserved for ETB_R_DOWNLOAD_DATA
#define DMD_CMD_START_UPLOAD_STREAM_FIRMWARE        0xF2
//#define 0xF3 is reserved for ETB_R_UPLOAD_DATA
#define DMD_CMD_START_FIRMWARE                      0xF4
#define DMD_CMD_START_DOWNLOAD_SEQUENCE             0xF5
#define DMD_CMD_START_UPLOAD_SEQUENCE				0xF6
#define DMD_CMD_START_UPLOAD_TRACE					0xF7
#define DMD_CMD_START_DOWNLOAD_PARAMETER            0xF8
#define DMD_CMD_START_UPLOAD_PARAMETER				0xF9
#define DMD_CMD_DOWNLOAD_DATA                       0xFA
#define DMD_CMD_UPLOAD_DATA                         0xFB


/*------------------------------------------------------------------------------
 * drive (record 20h) command numbers
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_CMD_ADD_REGISTER                     91          /* Adds register */
#define DMD_CMD_AND_NOT_REGISTER                 97          /* AND NOT register */
#define DMD_CMD_AND_REGISTER                     95          /* AND register */
#define DMD_CMD_AUTO_CONFIG_CL                   150         /* Auto config current loop */
#define DMD_CMD_CALL_SUBROUTINE                  68          /* Calls subroutine */
#define DMD_CMD_CHANGE_AXIS                      109         /* Changes axis */
#define DMD_CMD_CHANGE_POWER                     124         /* Changes power */
#define DMD_CMD_CLEAR_CALL_STACK                 34          /* Clears call stack */
#define DMD_CMD_CLEAR_USER_VAR                   17          /* Clears all user registers */
#define DMD_CMD_CONV_REGISTER                    122         /* Converts between int and float */
#define DMD_CMD_DBG_SEQ_EXIT_DEBUG               143         /* Sequence Debugger: Set breakpoint sensitive thread */
#define DMD_CMD_DBG_SEQ_BRKP_AT                  141         /* Sequence Debugger: Set breakpoint enabled */
#define DMD_CMD_DBG_SEQ_BRKP_EVERYWHERE          142         /* Sequence Debugger: Exit sequence debug. */
#define DMD_CMD_DBG_SEQ_CONTINUE                 140         /* Sequence Debugger: Continue sequence execution after break point. */
#define DMD_CMD_DIVIDE_REGISTER                  94          /* Divides register */
#define DMD_CMD_DRIVE_NEW                        78          /* Controller new */
#define DMD_CMD_DRIVE_RESTORE                    49          /* Controller restore */
#define DMD_CMD_DRIVE_SAVE                       48          /* Controller save */
#define DMD_CMD_EIOMAXURST                       755         /* Reset observed max. time between IO updates */
#define DMD_CMD_EIOSTA                           750         /* Start external IO read/write cycle */
#define DMD_CMD_EIOWDEN                          720         /* Enable/disable external IO watchdog */
#define DMD_CMD_EIOWDSTP                         721         /* Stop the external IO watchdog */
#define DMD_CMD_EIOWDTIME                        722         /* Set the external IO watchdog timeout */
#define DMD_CMD_ENABLE_DISABLE_M_TRIGGER         103         /* Command enable trigger function when axis is moving. <P1> Table start line (E registres). <P2> Table number of line (E registers). */
#define DMD_CMD_ENABLE_DISABLE_TRIGGER           104         /* Command enable trigger function when axis isn't moving. <P1> Table start line (E registres). <P2> Table number of line (E registers). */
#define DMD_CMD_ENTER_DOWNLOAD                   42          /* Enter download mode */
#define DMD_CMD_GETDINS                          738         /* Get actual value of a specified digital local input */
#define DMD_CMD_GETDOUT                          735         /* Get the value of a specified digital local output */
#define DMD_CMD_GETEAINCS                        746         /* Ext. IO: get actual conv. value of a specified AIN */
#define DMD_CMD_GETEAINRS                        745         /* Ext. IO: get actual raw value of a specified AIN */
#define DMD_CMD_GETEAOUTC                        741         /* Ext. IO: get set conv. value of a specified AOUT */
#define DMD_CMD_GETEAOUTCS                       743         /* Ext. IO: get actual conv. val. of a specified AOUT */
#define DMD_CMD_GETEAOUTR                        740         /* Ext. IO: get set raw value of a specified AOUT */
#define DMD_CMD_GETEAOUTRS                       742         /* Ext. IO: get actual raw value of a specified AOUT */
#define DMD_CMD_GETEDINS                         765         /* Ext. IO: get the actual value of a specified DIN */
#define DMD_CMD_GETEDOUT                         760         /* Ext. IO: get set value of a specified DOUT */
#define DMD_CMD_GETEDOUTS                        764         /* Ext. IO: get the actual value of a specified DOUT */
#define DMD_CMD_GETEREG                          726         /* Get a register from the ext. IO system */
#define DMD_CMD_GETMDINS                         734         /* Get masked local inputs */
#define DMD_CMD_GETMDOUT                         732         /* Get masked local outputs */
#define DMD_CMD_GETMEDINS                        758         /* Ext. IO: get masked actual external inputs */
#define DMD_CMD_GETMEDOUT                        757         /* Ext. IO: get masked set external outputs */
#define DMD_CMD_GETMEDOUTS                       766         /* Ext. IO: get masked actual external outputs */
#define DMD_CMD_HARDWARE_RESET                   600         /* Hardware reset */
#define DMD_CMD_HOMING_START                     45          /* Homing start */
#define DMD_CMD_HOMING_SYNCHRONISED              41          /* Synchronized homing */
#define DMD_CMD_IF_EQUAL                         151         /* Jumps if par1 equal XAC */
#define DMD_CMD_IF_GREATER                       154         /* Jumps if par1 greater XAC */
#define DMD_CMD_IF_GREATER_OR_EQUAL              156         /* Jumps if par1 greater or equal XAC */
#define DMD_CMD_IF_LOWER                         153         /* Jumps if par1 lower XAC */
#define DMD_CMD_IF_LOWER_OR_EQUAL                155         /* Jumps if par1 less or equal XAC */
#define DMD_CMD_IF_NOT_EQUAL                     152         /* Jumps if par1 different XAC */
#define DMD_CMD_INI_START                        44          /* Phasing start */
#define DMD_CMD_INIT_TRIGGER_OUTPUT              106         /* Command to initialize the DOUT/FDOUT used by the trigger. <P1> is the state for the DOUT and <P2> is the state for FDOUT */
#define DMD_CMD_INPUT_START_MVT                  33          /* Starts mvt on input */
#define DMD_CMD_INVERT_REGISTER                  174         /* Inverts register */
#define DMD_CMD_IPOL_ABS_COORDS                  556         /* Assigns the coordinates of the current position of the axes */
#define DMD_CMD_IPOL_ABS_MODE                    555         /* Sets (1) or clears (0) the abs ref coordinates mode */
#define DMD_CMD_IPOL_BEGIN                       553         /* Enter to interpolated mode */
#define DMD_CMD_IPOL_BEGIN_CONCATENATION         1030        /* Starts the concatenation */
#define DMD_CMD_IPOL_CIRCLE_CCW_C2D              1041        /* Adds circular segment to trajectory */
#define DMD_CMD_IPOL_CIRCLE_CCW_R2D              1027        /* Adds circular segment to trajectory */
#define DMD_CMD_IPOL_CIRCLE_CW_C2D               1040        /* Adds circular segment to trajectory */
#define DMD_CMD_IPOL_CIRCLE_CW_R2D               1026        /* Adds circular segment to trajectory */
#define DMD_CMD_IPOL_CLEAR_BUFFER                657         /* Clears the ipol command buffer */
#define DMD_CMD_IPOL_CONTINUE                    654         /* Restarts interpolation after a quick stop */
#define DMD_CMD_IPOL_DISABLE_UCONCATENATION      1052        /* Forces to stop before the next universal line */
#define DMD_CMD_IPOL_END                         554         /* Leave the interpolated mode */
#define DMD_CMD_IPOL_END_CONCATENATION           1031        /* Stops the concatenation */
#define DMD_CMD_IPOL_LINE                        1025        /* Adds linear segment to trajectory */
#define DMD_CMD_IPOL_LKT                         1032        /* Adds lkt segment to trajectory */
#define DMD_CMD_IPOL_LOCK                        1044        /* Locks the trajectory execution */
#define DMD_CMD_IPOL_MARK                        1039        /* Puts a mark in the trajectory */
#define DMD_CMD_IPOL_MATRIX_ROTATE               1056        /* Rotates the selected axis plane */
#define DMD_CMD_IPOL_MATRIX_SCALE                1055        /* Scales the selected axes */
#define DMD_CMD_IPOL_MATRIX_SHEAR                1057        /* Shears selected axes */
#define DMD_CMD_IPOL_MATRIX_TRANSLATE            1054        /* Translates the reference frame */
#define DMD_CMD_IPOL_PT                          1045        /* Adds pt segment to trajectory */
#define DMD_CMD_IPOL_PVT                         1028        /* Adds pvt segment to trajectory */
#define DMD_CMD_IPOL_PVT_UPDATE                  662         /* Updates registers for PVT trajectory */
#define DMD_CMD_IPOL_SET                         552         /* Sets the interpolation axis */
#define DMD_CMD_IPOL_STOP_EMCY                   656         /* Stops interpolation emergency */
#define DMD_CMD_IPOL_STOP_SMOOTH                 653         /* Stops interpolation smooth */
#define DMD_CMD_IPOL_TAN_ACCELERATION            1036        /* Adds acceleration modification to trajectory */
#define DMD_CMD_IPOL_TAN_DECELERATION            1037        /* Adds deceleration modification to trajectory */
#define DMD_CMD_IPOL_TAN_JERK_TIME               1038        /* Adds jerk time modification to trajectory */
#define DMD_CMD_IPOL_TAN_VELOCITY                1035        /* Adds speed modification to trajectory */
#define DMD_CMD_IPOL_ULINE                       1033        /* Adds universal linear segment to trajectory */
#define DMD_CMD_IPOL_UNLOCK                      655         /* Unlock the ipol buffer */
#define DMD_CMD_IPOL_URELATIVE                   1051        /* Enables or disables relative mode */
#define DMD_CMD_IPOL_USPEED                      1049        /* Changes speed for universal linear moves */
#define DMD_CMD_IPOL_USPEED_AXISMASK             1053        /* Changes the axis mask for tangential speed */
#define DMD_CMD_IPOL_UTIME                       1050        /* Changes acceleration and jerk time for universal linear moves */
#define DMD_CMD_IPOL_WAIT_TIME                   1029        /* Waits before continue the trajectory */
#define DMD_CMD_JUMP_BIT_CLEAR                   37          /* Jump bit clear */
#define DMD_CMD_JUMP_BIT_SET                     36          /* Jump bit set */
#define DMD_CMD_JUMP_LABEL                       26          /* Jumps to label */
#define DMD_CMD_MAPPING_ASP                      234         /* SET slot address for stage error mapping mode */
#define DMD_CMD_MAPPING_MAM                      199         /* Set all involved axes mask and corrected axes mask */
#define DMD_CMD_MAPPING_MCS                      200         /* Stage error mapping command, set the cyclic stroke of source axes */
#define DMD_CMD_MAPPING_MCT                      193         /* Set config. and table nbr info for stage error mapping */
#define DMD_CMD_MAPPING_MDA                      195         /* Set dimension and axes for stage error mapping */
#define DMD_CMD_MAPPING_MDT                      192         /* Set date and time info for stage error mapping */
#define DMD_CMD_MAPPING_MMO                      194         /* Set correction mode for stage error mapping */
#define DMD_CMD_MAPPING_MSI                      190         /* Set string info for stage error mapping */
#define DMD_CMD_MAPPING_MSR                      196         /* Set mapping source registers for stage error mapping */
#define DMD_CMD_MAPPING_MSV                      191         /* Set version info for stage error mapping */
#define DMD_CMD_MAPPING_MTP                      197         /* Set mapping origin for stage error mapping */
#define DMD_CMD_MAPPING_MTU                      198         /* Set mapping unit factor for stage error mapping */
#define DMD_CMD_MODULO_REGISTER                  101         /* Modulo register */
#define DMD_CMD_MULTIPLY_REGISTER                93          /* Multiplies register */
#define DMD_CMD_OR_NOT_REGISTER                  98          /* OR NOT register */
#define DMD_CMD_OR_REGISTER                      96          /* OR register */
#define DMD_CMD_PROFILED_MOVE                    60          /* Start movement */
#define DMD_CMD_RCT                              754         /* Resets the client TCP/IP communication */
#define DMD_CMD_RELATIVE_PROFILED_MOVE           62          /* Start relative movement */
#define DMD_CMD_RESET_DRIVE                      88          /* Resets controller */
#define DMD_CMD_RESET_ERROR                      79          /* Resets error */
#define DMD_CMD_RIC                              753         /* Reset IO update cycle count */
#define DMD_CMD_RSTDOUT                          737         /* Reset digital local output */
#define DMD_CMD_RSTEDOUT                         762         /* Reset digital output */
#define DMD_CMD_SEARCH_LIMIT_STROKE              46          /* Searches limit stroke */
#define DMD_CMD_SET_REGISTER                     123         /* Sets register */
#define DMD_CMD_SET_REGISTER_DEPTH               125         /* Set max all depth par1 with value par2 to parx */
#define DMD_CMD_SET_USER_POSITION                22          /* Sets user position */
#define DMD_CMD_SET_VERSION                      20          /* Set version parameters */
#define DMD_CMD_SETDOUT                          736         /* Set digital local output */
#define DMD_CMD_SETEAOUTC                        731         /* Set analog output in converted format */
#define DMD_CMD_SETEAOUTR                        730         /* Set analog output in raw format */
#define DMD_CMD_SETEDOUT                         761         /* Set digital output */
#define DMD_CMD_SETEREG                          725         /* Set a register of the ext. IO system */
#define DMD_CMD_SETMDOUT                         733         /* Apply a mask on local digital outputs */
#define DMD_CMD_SETMEDOUT                        763         /* Apply a mask on external digital outputs */
#define DMD_CMD_SHIFT_LEFT_REGISTER              173         /* Shift left register */
#define DMD_CMD_SHIFT_RIGHT_REGISTER             172         /* Shift right register */
#define DMD_CMD_START_MVT                        25          /* Starts movement */
#define DMD_CMD_START_STOP_PULSE_GENERATOR       105         /* Start or Stop pulse generator. <P1> pulse generator  (1 or 2). <P2> Start or Stop ( 1 or 0) */
#define DMD_CMD_STEP_ABSOLUTE                    129         /* Absolute step */
#define DMD_CMD_STEP_NEGATIVE                    115         /* Negative step */
#define DMD_CMD_STEP_POSITIVE                    114         /* Positive step */
#define DMD_CMD_STOP_MOTOR_EMCY                  18          /* Emergency stop */
#define DMD_CMD_STOP_MOTOR_SMOOTH                70          /* Stops motor smoothly */
#define DMD_CMD_STOP_SEQ_MOTOR_EMCY              120         /* Stops seq ipol emergency */
#define DMD_CMD_STOP_SEQ_MOTOR_SMOOTH            121         /* Stops seq stop ipol smooth */
#define DMD_CMD_STOP_SEQ_POWER_OFF               119         /* Stops seq, ipol emergency and disables ipol */
#define DMD_CMD_STOP_SEQUENCE                    0           /* Stops sequence thread */
#define DMD_CMD_SUBROUTINE_RETURN                69          /* Subroutine return */
#define DMD_CMD_SUBSTRACT_REGISTER               92          /* Substracts register */
#define DMD_CMD_USER_STRETCH                     30          /* User stretch command */
#define DMD_CMD_WAIT_AXIS_BUSY                   13          /* wait end of axis busy */
#define DMD_CMD_WAIT_BIT_CLEAR                   54          /* Wait bit clear */
#define DMD_CMD_WAIT_BIT_SET                     55          /* Wait bit set */
#define DMD_CMD_WAIT_GREATER                     53          /* Wait greater */
#define DMD_CMD_WAIT_IN_WINDOW                   11          /* Waits in window */
#define DMD_CMD_WAIT_LOWER                       52          /* Wait lower */
#define DMD_CMD_WAIT_MARK                        513         /* wait until the movement reach a mark */
#define DMD_CMD_WAIT_MOVEMENT                    8           /* Waits for end of move of specified ipol group */
#define DMD_CMD_WAIT_POSITION                    9           /* Waits for position */
#define DMD_CMD_WAIT_SGN_GREATER                 57          /* Waits for greater signed */
#define DMD_CMD_WAIT_SGN_LOWER                   56          /* Waits for lower signed */
#define DMD_CMD_WAIT_TIME                        10          /* Waits for time */
#define DMD_CMD_XOR_NOT_REGISTER                 100         /* XOR NOT register */
#define DMD_CMD_XOR_REGISTER                     99          /* XOR register */

#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * drive parameters numbers
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_C_ANALOG_OUTPUT            107         /* AOUT analog outputs */
#define DMD_CF_ANALOG_OUTPUT            107         /* AOUT analog outputs */
#define DMD_KL_BRAKE_DECELERATION       206         /* Brake deceleration */
#define DMD_KF_CAME_VALUE               205         /* Came value */
#define DMD_KF_CL_CURRENT_LIMIT         83          /* Current loop overcurrent limit */
#define DMD_KF_CL_I2T_CURRENT_LIMIT     84          /* I2 motor rms current limit */
#define DMD_KF_CL_I2T_TIME_LIMIT        85          /* I2t motor integration limit */
#define DMD_KF_CL_INTEGRATOR_GAIN       81          /* Current loop integrator gain */
#define DMD_KF_CL_PROPORTIONAL_GAIN     80          /* Current loop proportional gain */
#define DMD_PPK_CONCATENATED_MVT         201         /* Concatenated movement */
#define DMD_KF_CTRL_GAIN                224         /* External reference gain */
#define DMD_PPK_CTRL_OFFSET              223         /* External reference offset */
#define DMD_PPK_CTRL_SOURCE_DEPTH        222         /* External reference depth */
#define DMD_PPK_CTRL_SOURCE_INDEX        221         /* External reference index */
#define DMD_PPK_CTRL_SOURCE_TYPE         220         /* External reference type */
#define DMD_PPK_DIGITAL_OUTPUT           171         /* Digital outputs */
#define DMD_PPK_DISPLAY_MODE             66          /* Display mode */
#define DMD_PPK_DRIVE_CONTROL_MODE       61          /* Position reference mode */
#define DMD_C_DRIVE_NAME               3           /* Controller name */
#define DMD_PPK_DRIVE_SLS_MODE           145         /* Searches limit stroke (SLS) mode */
#define DMD_PPK_ENABLE_INPUT_MODE        33          /* Enables input mode */
#define DMD_PPK_ENCODER_HALL_PHASE_ADJ   86          /* Digital Hall sensor phase adjustment */
#define DMD_PPK_ENCODER_INDEX_DISTANCE   75          /* Distance between two indexes */
#define DMD_PPK_ENCODER_INVERSION        68          /* Encoder reading way inversion */
#define DMD_PPK_ENCODER_IPOL_SHIFT       77          /* Encoder interpolation shift value */
#define DMD_PPK_ENCODER_PERIOD           241         /* Encoder period */
#define DMD_KF_ENCODER_PHASE_1_FACTOR   72          /* Analog encoder sine factor */
#define DMD_PPK_ENCODER_PHASE_1_OFFSET   70          /* Analog encoder sine offset */
#define DMD_KF_ENCODER_PHASE_2_FACTOR   73          /* Analog encoder cosine factor */
#define DMD_PPK_ENCODER_PHASE_2_OFFSET   71          /* Analog encoder cosine offset */
#define DMD_PPK_ENCODER_TURN_FACTOR      55          /* Encoder position increment factor */
#define DMD_PPK_ENCODER_TYPE             79          /* Encoder type */
#define DMD_C_FAST_OUTPUT              5           /* Fast outputs */
#define DMD_PPK_FOLLOWING_ERROR_WINDOW   30          /* Tracking error limit */
#define DMD_C_GANTRY_TYPE              245         /* Gantry  level */
#define DMD_KL_HOME_OFFSET              45          /* Offset on absolute position */
#define DMD_KL_HOMING_ACCELERATION      42          /* Homing acceleration */
#define DMD_KF_HOMING_CURRENT_LIMIT     44          /* Homing force limit for mech end stop detection */
#define DMD_PPK_HOMING_FINE_TUNING_MODE  52          /* Homing fine tuning mode */
#define DMD_PPK_HOMING_FINE_TUNING_VALUE 53          /* Homing fine tuning value */
#define DMD_KL_HOMING_FIXED_MVT         46          /* Homing movement stroke */
#define DMD_KL_HOMING_FOLLOWING_LIMIT   43          /* Homing track limit for mech end stop detection */
#define DMD_KL_HOMING_INDEX_MVT         48          /* Mvt to go out of idx/home switch */
#define DMD_PPK_HOMING_METHOD            40          /* Homing mode */
#define DMD_KL_HOMING_SWITCH_MVT        47          /* Mvt to go out of limit switch or mech end stop */
#define DMD_KL_HOMING_ZERO_SPEED        41          /* Homing speed */
#define DMD_PPK_INDIRECT_REGISTER_IDX    198         /* Indirect register index */
#define DMD_PPK_INIT_FINAL_PHASE         93          /* Phasing final phase */
#define DMD_PPK_INIT_INITIAL_PHASE       97          /* Phasing initial phase */
#define DMD_KF_INIT_MAX_CURRENT         92          /* Phasing constant current level */
#define DMD_PPK_INIT_MODE                90          /* Phasing mode */
#define DMD_KF_INIT_PULSE_LEVEL         91          /* Phasing pulse level */
#define DMD_PPK_INIT_TIME                94          /* Phasing time (K90 = 2) */
#define DMD_PPK_INIT_VOLTAGE_RATE        98          /* Phasing voltage rate */
#define DMD_PPK_IPOL_CAME_VALUE          717         /* Interpolation, came value */
#define DMD_PPK_IPOL_LKT_CYCLIC_MODE     710         /* Interpolation, LKT, cyclic mode */
#define DMD_PPK_IPOL_LKT_RELATIVE_MODE   711         /* Interpolation, LKT, relative mode */
#define DMD_PPK_IPOL_LKT_SPEED_RATIO     700         /* Interpolation, LKT, speed ratio of the pointer */
#define DMD_PPK_IPOL_VELOCITY_RATE       530         /* Interpolation, speed rate */
#define DMD_PPK_JERK_FILTER_TIME         213         /* Jerk time */
#define DMD_KL_MAX_POSITION_RANGE_LIMIT 27          /* Max position range limit */
#define DMD_KL_MAX_SOFT_POSITION_LIMIT  35          /* Max software position limit */
#define DMD_KL_MIN_SOFT_POSITION_LIMIT  34          /* Min software position limit */
#define DMD_C_MON_SOURCE_INDEX         31          /* XAOUT source register index */
#define DMD_C_MON_SOURCE_TYPE          30          /* XAOUT source register type */
#define DMD_PPK_MOTION_AND_CONSIGNE      78          /* Regulator type */
#define DMD_PPK_MOTOR_DIV_FACTOR         243         /* Position division factor */
#define DMD_PPK_MOTOR_KT_FACTOR          239         /* Motor Kt factor */
#define DMD_PPK_MOTOR_MUL_FACTOR         242         /* Position multiplication factor */
#define DMD_PPK_MOTOR_PHASE_CORRECTION   56          /* Motor phase correction */
#define DMD_PPK_MOTOR_PHASE_NB           89          /* Motor phase number */
#define DMD_PPK_MOTOR_POLE_NB            54          /* Motor pair pole number */
#define DMD_PPK_MOTOR_TYPE               240         /* Movement type conversion */
#define DMD_PPK_MVT_DIRECTION            209         /* Rotary movement type */
#define DMD_KL_MVT_LKT_AMPLITUDE        208         /* Max stroke for LKT */
#define DMD_PPK_MVT_LKT_NUMBER           203         /* LKT number movement */
#define DMD_PPK_MVT_LKT_TIME             204         /* Movement LKT time */
#define DMD_PPK_MVT_LKT_TYPE             207         /* LKT mode selection */
#define DMD_KF_PL_ACC_FEEDFORWARD_GAIN  21          /* Position loop acceleration ffwd gain */
#define DMD_KF_PL_ANTI_WINDUP_GAIN      5           /* Position loop anti-windup gain */
#define DMD_KF_PL_INTEGRATOR_GAIN       4           /* Position loop integrator gain */
#define DMD_KF_PL_INTEGRATOR_LIMITATION 6           /* Position loop integrator limitation */
#define DMD_PPK_PL_INTEGRATOR_MODE       7           /* Position loop integrator mode */
#define DMD_KF_PL_PROPORTIONAL_GAIN     1           /* Position loop proportional gain */
#define DMD_KF_PL_SPEED_FEEDBACK_GAIN   2           /* Position loop speed feedback gain */
#define DMD_PPK_POSITION_WINDOW          39          /* In-window position */
#define DMD_PPK_POSITION_WINDOW_TIME     38          /* In-window time */
#define DMD_KL_PROFILE_ACCELERATION     212         /* Absolute max acc/deceleration */
#define DMD_PPK_PROFILE_LIMIT_MODE       36          /* Enables position limit (KL34, KL35) */
#define DMD_PPK_PROFILE_TYPE             202         /* Movement type */
#define DMD_KL_PROFILE_VELOCITY         211         /* Absolute max speed */
#define DMD_KF_SOFTWARE_CURRENT_LIMIT   60          /* Software force limit */
#define DMD_PPK_SWITCH_LIMIT_MODE        32          /* Limit switch and home switch inversion */
#define DMD_PPK_SYNCRO_START_TIMEOUT     164         /* Synchro timeout */
#define DMD_KL_TARGET_POSITION          210         /* Target position */
#define DMD_PPK_TARGET_POSITION          210         /* Target position */
#define DMD_PPK_TTL_SPEED_FILTER         11          /* TTL speed smooth filter */
#define DMD_PPK_UFAI_TEN_POWER           525         /* Ufai ten power */
#define DMD_PPK_UFPI_MUL_FACTOR          522         /* Ufpi multiplication factor */
#define DMD_PPK_UFPI_TEN_POWER           523         /* Ufpi ten power */
#define DMD_PPK_UFSI_TEN_POWER           524         /* Ufsi ten power */
#define DMD_PPK_UFTI_TEN_POWER           526         /* Ufti ten power */
#define DMD_PPK_USER_STATUS              177         /* User status */
#define DMD_PPK_VELOCITY_ERROR_LIMIT     31          /* Speed error limit */
#define DMD_C_X_ANALOG_OUTPUT_1        7           /* Optional board analog outputs */
#define DMD_C_X_DIGITAL_OUTPUT         6           /* Optional board digital outputs */

#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * drive monitoring variables numbers
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_MON_ACC_DEMAND_VALUE         14          /* Theoretical acceleration (dai) */
#define DMD_MF_ANALOG_INPUT             51          /* Analog input after gain and offset compensation */
#define DMD_MON_ANALOG_INPUT             51          /* Analog input after gain and offset compensation */
#define DMD_MON_AXIS_NUMBER              87          /* UltimET axis number */
#define DMD_MF_CL_ACTUAL_VALUE          31          /* Real force Iq measured */
#define DMD_MF_CL_CURRENT_PHASE_1       20          /* Real current in phase 1 */
#define DMD_MF_CL_CURRENT_PHASE_2       21          /* Real current in phase 2 */
#define DMD_MF_CL_CURRENT_PHASE_3       22          /* Real current in phase 3 */
#define DMD_MF_CL_DEMAND_VALUE          30          /* Theoretical force Iq for current loop */
#define DMD_MF_CL_I2T_VALUE             67          /* I2t motor current value */
#define DMD_MON_CL_LKT_PHASES            25          /* Phase angle */
#define DMD_MON_COMMON_FAST_INPUTS       52          /* Common fast inputs */
#define DMD_MON_DBG_SEQ_NB_BRKP          67          /* Sequence debugger: Number of breakpoints set */
#define DMD_MON_DIGITAL_INPUT            50          /* Digital inputs */
#define DMD_MON_DIGITAL_OUTPUT_ACTUAL    171         /* Digital outputs */
#define DMD_MON_DRIVE_CL_INT_ACTUAL_TIME 190         /* Actual time of process on current loop */
#define DMD_MON_DRIVE_CL_INT_MAX_TIME    192         /* Min time of process on current loop */
#define DMD_MON_DRIVE_CL_INT_MIN_TIME    191         /* Max time of process on current loop */
#define DMD_MON_DRIVE_CL_TIME_FACTOR     243         /* Controller current loop time factor */
#define DMD_MON_DRIVE_DISPLAY            95          /* Display's string */
#define DMD_MON_DRIVE_FUSE_STATUS        140         /* Fuse status */
#define DMD_MF_DRIVE_MAX_CURRENT        82          /* Controller max current */
#define DMD_MON_DRIVE_MAX_CURRENT        82          /* Controller max current */
#define DMD_MON_DRIVE_PL_INT_ACTUAL_TIME 193         /* Actual time of process on position loop */
#define DMD_MON_DRIVE_PL_INT_MAX_TIME    195         /* Min time of process on position loop */
#define DMD_MON_DRIVE_PL_INT_MIN_TIME    194         /* Max time of process on position loop */
#define DMD_MON_DRIVE_PL_TIME_FACTOR     244         /* Controller position loop time factor */
#define DMD_MON_DRIVE_QUARTZ_FREQUENCY   242         /* Controller quartz frequency [Hz] */
#define DMD_MON_DRIVE_SEQUENCE_LINE      96          /* Current instruction address */
#define DMD_MON_DRIVE_SP_INT_ACTUAL_TIME 196         /* Actual time of process on manager loop */
#define DMD_MON_DRIVE_SP_INT_MAX_TIME    198         /* Min time of process on manager loop */
#define DMD_MON_DRIVE_SP_INT_MIN_TIME    197         /* Max time of process on manager loop */
#define DMD_MON_DRIVE_SP_TIME_FACTOR     245         /* Controller manager loop time factor */
#define DMD_MON_DRIVE_STATUS_1           60          /* Controller status 1 */
#define DMD_MON_DRIVE_STATUS_2           61          /* Controller status 2 */
#define DMD_MON_DRIVE_TEMPERATURE        90          /* Controller temperature */
#define DMD_MON_ENCODER_1VPTP_VALUE      43          /* Analog encoder sine^2 + cosine^2 */
#define DMD_MON_ENCODER_COSINE_SIGNAL    41          /* Analog encoder cosine signal after correction */
#define DMD_MON_ENCODER_HALL_DIG_SIGNAL  48          /* Digital Hall effect sensor */
#define DMD_MON_ENCODER_IPOL_FACTOR      241         /* Encoder interpolation factor */
#define DMD_MON_ENCODER_LIMIT_SWITCH     44          /* Encoder limit switch */
#define DMD_MON_ENCODER_SINE_SIGNAL      40          /* Analog encoder sine signal after correction */
#define DMD_MON_ERROR_CODE               64          /* Error code */
#define DMD_MON_FDOUT_ACTUAL             172         /* Fast digital outputs */
#define DMD_MON_INFO_BOOT_REVISION       71          /* Boot version */
#define DMD_MON_INFO_C_SOFT_BUILD_TIME   74          /* Firmware build time */
#define DMD_MON_INFO_P_SOFT_BUILD_TIME   75          /* FPGA built time */
#define DMD_MON_INFO_PRODUCT_NUMBER      70          /* Product type */
#define DMD_MON_INFO_PRODUCT_STRING      85          /* Article number */
#define DMD_MON_INFO_SERIAL_NUMBER       73          /* Serial number */
#define DMD_MON_INFO_SOFT_VERSION        72          /* Firmware version */
#define DMD_ML_MAX_SLS_POSITION_LIMIT   37          /* Superior position after SLS cmd */
#define DMD_MON_MAX_SLS_POSITION_LIMIT   37          /* Superior position after SLS cmd */
#define DMD_ML_MIN_SLS_POSITION_LIMIT   36          /* Inferior position after SLS cmd */
#define DMD_MON_MIN_SLS_POSITION_LIMIT   36          /* Inferior position after SLS cmd */
#define DMD_ML_POSITION_ACTUAL_VALUE_DS 1           /* Real position with mapping (dpi) */
#define DMD_MON_POSITION_ACTUAL_VALUE_DS 1           /* Real position with mapping (dpi) */
#define DMD_ML_POSITION_ACTUAL_VALUE_US 7           /* Real position */
#define DMD_MON_POSITION_ACTUAL_VALUE_US 7           /* Real position */
#define DMD_MON_POSITION_CTRL_ERROR      2           /* Tracking error */
#define DMD_ML_POSITION_DEMAND_VALUE_DS 0           /* Theoretical position (dpi) */
#define DMD_MON_POSITION_DEMAND_VALUE_DS 0           /* Theoretical position (dpi) */
#define DMD_ML_POSITION_DEMAND_VALUE_US 6           /* Theoretical position */
#define DMD_MON_POSITION_DEMAND_VALUE_US 6           /* Theoretical position */
#define DMD_MON_POSITION_MAX_ERROR       3           /* Max tracking error */
#define DMD_ML_TEB_NODE_MASK            512         /* Present nodes on TransnET */
#define DMD_MON_VELOCITY_ACTUAL_VALUE    11          /* Real speed after adv filter (dsi) */
#define DMD_MON_VELOCITY_BEFORE_K8       111         /* Real speed before adv filter depth 0 (dsi) */
#define DMD_MON_VELOCITY_DEMAND_VALUE    10          /* Theoretical speed after adv filter (dsi) */
#define DMD_MON_X_ANALOG_INPUT_1         56          /* Optional board analog inputs */
#define DMD_MON_X_DIGITAL_INPUT          55          /* Optional board digital inputs */
#define DMD_MON_X_INFO_PRODUCT_NUMBER    76          /* Optional board product number */

#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * convertion constants
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
	#define DMD_CONV_DWORD                   0           /* double word value without conversion */
#define DMD_CONV_BOOL                    1           /* boolean value */
#define DMD_CONV_INT                     2           /* integer value without conversion */
#define DMD_CONV_K14                     3           /*  */
#define DMD_CONV_K8                      3           /*  */
#define DMD_CONV_LONG                    3           /* long integer value without conversion */
#define DMD_CONV_STRING                  4           /* packed string value */
#define DMD_CONV_FLOAT                   5           /* float value */
#define DMD_CONV_KFLOAT                  6           /* float value for K parameters */
#define DMD_CONV_M29                     7           /* per cent unit, 100% correspond to value of M229 */
#define DMD_CONV_CTRL_CUR2               8           /* Controller i<SUP>2</SUP>t, dissipation value */
#define DMD_CONV_UPI2                    9           /* user position increment dual encodeur mode */
#define DMD_CONV_UPI                     10          /* user position increment */
#define DMD_CONV_USI                     11          /* user speed increment */
#define DMD_CONV_UAI                     12          /* acceleration, user acceleration increment */
#define DMD_CONV_IP_ADDRESS              13          /* ip address type */
#define DMD_CONV_CTRL_CUR2T              14          /* Controller i<SUP>2</SUP>t, integration value */
#define DMD_CONV_DPI                     15          /* drive position increment */
#define DMD_CONV_DSI                     16          /* drive speed increment */
#define DMD_CONV_DAI                     17          /* drive acceleration increment */
#define DMD_CONV_DPI2                    18          /* drive position increment for secondary encoder */
#define DMD_CONV_CUR2T_V2                19          /* i<SUP>2</SUP>t, integration value */
#define DMD_CONV_C13                     20          /* current 13bit range */
#define DMD_CONV_C14                     21          /* current 14bit range */
#define DMD_CONV_C29                     22          /* current 29bit range */
#define DMD_CONV_CUR                     24          /* current */
#define DMD_CONV_CUR2                    25          /* i<SUP>2</SUP>, dissipation value */
#define DMD_CONV_CUR2T                   26          /* i<SUP>2</SUP>t, integration value */
#define DMD_CONV_POLE_FREQ               27          /* filter pole frequency in Herz */
#define DMD_CONV_M82                     28          /* current limit in 10 mA unit, 100 correspond to 1.0A */
#define DMD_CONV_MLTI                    30          /* manager loop time increment (sti) */
#define DMD_CONV_STI                     30          /* slow time increment (500us-2ms) */
#define DMD_CONV_FTI                     31          /* fast time increment (125us-166us) */
#define DMD_CONV_PLTI                    31          /* position loop time increment (fti) */
#define DMD_CONV_CLTI                    32          /* current loop time increment (cti) */
#define DMD_CONV_CTI                     32          /* current loop time increment (41us) */
#define DMD_CONV_EXP10                   33          /* ten power factor */
#define DMD_CONV_HSTI                    34          /* half slow time increment */
#define DMD_CONV_M242                    35          /* quartz frequency in Hz */
#define DMD_CONV_QZTIME                  36          /* interrupt time in sec = inc / m242 */
#define DMD_CONV_SPEC2F                  37          /* filter time, T = [fti] * (2<SUP>n</SUP>-1) */
#define DMD_CONV_TEMP                    38          /* 2<SUP>0</SUP> = 1 correspond to 1.0 */
#define DMD_CONV_UFTI                    39          /* user friendly time increment */
#define DMD_CONV_AVI                     40          /* analog voltage increment 8192 correspond to -10V  -8192 correspond to +10V */
#define DMD_CONV_VOLT                    41          /* 2<SUP>0</SUP> = 1 correspond to 1.0 */
#define DMD_CONV_ENCOFF                  42          /* 11bit with 2048 offset */
#define DMD_CONV_VOLT100                 43          /* (2<SUP>0</SUP>)/100 = 1 correspond to 1.0 */
#define DMD_CONV_PH11                    44          /* 2<SUP>11</SUP> = 2048 correspond to 360° */
#define DMD_CONV_PH12                    45          /* 2<SUP>12</SUP> = 4096 correspond to 360° */
#define DMD_CONV_PH28                    46          /* 2<SUP>28</SUP> = 65536*4096 correspond to 360° */
#define DMD_CONV_AVI12BIT                47          /* analog voltage increment 2048 correspond to -10V  -2048 correspond to +10V */
#define DMD_CONV_AVI16BIT                48          /* analog voltage increment 32767 correspond to -10V   -32768 correspond to +10V */
#define DMD_CONV_AVI16BITINV             49          /* analog voltage increment 32767 correspond to 10V   -32768 correspond to -10V */
#define DMD_CONV_BIT0                    50          /* 2<SUP>0</SUP> = 1 correspond to 1.0 */
#define DMD_CONV_BIT5                    55          /* 2<SUP>5</SUP> = 32 correspond to 1.0 */
#define DMD_CONV_BIT8                    58          /* 2<SUP>8</SUP> = 256 correspond to 1.0 */
#define DMD_CONV_BIT9                    59          /* 2<SUP>9</SUP> = 512 correspond to 1.0 */
#define DMD_CONV_BIT10                   60          /* 2<SUP>10</SUP> = 1024 correspond to 1.0 */
#define DMD_CONV_BIT11                   61          /* 2<SUP>11</SUP> = 2048 correspond to 1.0 */
#define DMD_CONV_BIT11_ENCODER           62          /* Analgog encoder signal amplitude in volt (11 bit) */
#define DMD_CONV_BIT15_ENCODER           63          /* Analgog encoder signal amplitude in volt (15 bit) */
#define DMD_CONV_BIT15                   65          /* 2<SUP>15</SUP> = 32768 correspond to 1.0 */
#define DMD_CONV_BIT24                   74          /* 2<SUP>24</SUP> = 256*65536 correspond to 1.0 */
#define DMD_CONV_BIT31                   81          /* 2<SUP>31</SUP> = 32768*65536 correspond to 1.0 */
#define DMD_CONV_BIT11P2                 82          /*  */
#define DMD_CONV_BIT15P2                 83          /*  */
#define DMD_CONV_UFPI                    85          /* user friendly position increment */
#define DMD_CONV_UFSI                    86          /* user friendly speed increment */
#define DMD_CONV_UFAI                    87          /* user friendly acceleration increment */
#define DMD_CONV_MSEC                    88          /* milliseconds */
#define DMD_CONV_K1                      90          /* pl prop gain, k(A/m) = k1 * Iref * dpi_factor / 2<SUP>29</SUP> */
#define DMD_CONV_K2                      92          /* pl speed feedback gain, k(A/(m/s)) = k2 * Iref * dsi_factor / 2<SUP>29</SUP> */
#define DMD_CONV_K4                      94          /* pl integrator gain, k(A/(m*s)) = k1 * Iref * dpi_factor / 2<SUP>29</SUP> / pl_time */
#define DMD_CONV_K5                      96          /* anti-windup K[m/A]=K5*4096/(dpi_factor * Iref) */
#define DMD_CONV_K9                      98          /* 1st order filter in pl */
#define DMD_CONV_MF89                    99          /* Magnetic period for Init small movement 2 */
#define DMD_CONV_K10                     100         /* 1st order filter in s. */
#define DMD_CONV_M16                     101         /* jerk value */
#define DMD_CONV_K20_DSB                 102         /* speed feedback, sec unit (m/(m/s)), F = k20 / 2<SUP>16-k50</SUP> * dsi_factor / dpi_factor */
#define DMD_CONV_K20                     103         /* speed feedback, sec unit (m/(m/s)), F = k20 / 2<SUP>16-k50</SUP> * dsi_factor / dpi_factor */
#define DMD_CONV_K21_DSB                 104         /* speed feedback, sec unit (m/(m/s<SUP>2</SUP>)), F = k20 / 2<SUP>24-k50</SUP> * dai_factor / dpi_factor */
#define DMD_CONV_K21                     105         /* speed feedback, sec unit (m/(m/s<SUP>2</SUP>)), F = k20 / 2<SUP>24-k50</SUP> * dai_factor / dpi_factor */
#define DMD_CONV_K23                     106         /* commutation phase advance period/(period*second/m) */
#define DMD_CONV_K23_ACCURET             107         /* commutation phase advance period/(Volt*second/m) */
#define DMD_CONV_K75                     108         /* encoder multiple index distance, 1/1024 * encoder perion unit */
#define DMD_CONV_K80_VHP                 109         /* cl prop gain delta[V/A] */
#define DMD_CONV_K80                     110         /* cl prop gain delta[1/A] */
#define DMD_CONV_K81_VHP                 111         /* cl prop gain delta[V/(A*s)] */
#define DMD_CONV_K81                     112         /* cl prop integrator delta[1/(A*s)] */
#define DMD_CONV_KF22                    113         /* jerk feedforward */
#define DMD_CONV_K82                     114         /* filter time, T = [cti] * (2<SUP>n</SUP>-1) */
#define DMD_CONV_KIF_FCTRL               115         /* Integrator gain for the force loop */
#define DMD_CONV_K94                     116         /* time in 2x current loop increment */
#define DMD_CONV_KPF_FCTRL               117         /* Proportional gain for the force loop */
#define DMD_CONV_K95                     118         /* current rate for k95 */
#define DMD_CONV_KT_MOTOR                119         /* KT motor */
#define DMD_CONV_K96                     120         /* phase rate for k96 */
#define DMD_CONV_FREF_FCTRL              121         /* Force ref of force control (conv 1:1) */
#define DMD_CONV_PER_100                 122         /* per cent unit, 100 correspond to 1.0 */
#define DMD_CONV_PER_1000                123         /* per thousand unit */
#define DMD_CONV_K239                    124         /* motor Kt factor in mN(m)/A, 1000 correspond to 1.0mN(m)/A */
#define DMD_CONV_K1031                   125         /* per cent unit, 3133 correspond to 1.0 or 100% */
#define DMD_CONV_TTI                     126         /* Minimum time base TransnET (25us) */
#define DMD_CONV_KF256                   127         /* Kt/M for Init small movement 2 */

#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * firmware block types
 *-----------------------------------------------------------------------------*/
#ifndef DMD_OO_API
#define DMD_FW_BLOCK_UNUSED				0			
#define DMD_FW_BLOCK_BOOT				1
#define DMD_FW_BLOCK_FIRMWARE			2
#define DMD_FW_BLOCK_C_PARAMETER		4
#define DMD_FW_BLOCK_X_PARAMETER		5
#define DMD_FW_BLOCK_L_PARAMETER		6
#define DMD_FW_BLOCK_SEQUENCE			7
#define DMD_FW_BLOCK_KE_PARAMETER		8
#define DMD_FW_BLOCK_MAPPING			9
#define DMD_FW_BLOCK_EXTENSION_1		10
#define DMD_FW_BLOCK_EXTENSION_2		11
#define DMD_FW_BLOCK_RESERVED			12
#define DMD_FW_BLOCK_EXTENSION_RESERVED 13
#endif /* DMD_OO_API */

/**********************************************************************************************************/
/*- MACROS */
/**********************************************************************************************************/

#define DMD_MAJOR(v)  (((v)>>24) & 0xFF)             /* major version information */
#define DMD_MINOR(v)  (((v)>>16) & 0xFF)             /* minor version information */
#define DMD_MICRO(v)  (((v)>>8) & 0xFF)              /* micro version information */

#ifndef ETEL_NO_P_MACROS
	#define _DMD_P1(p)                       p
	#define DMD_P1(p)                        p
	#define _DMD_P2(p)                       p,
	#define DMD_P2(p)                        p,
#endif

/**********************************************************************************************************/
/*- TYPES */
/**********************************************************************************************************/

/*------------------------------------------------------------------------------
 * type modifiers
 *-----------------------------------------------------------------------------*/
/*------------------------------*/
/* WINDOWS type modifiers		*/
#ifdef WIN32
	#define _DMD_EXPORT __cdecl                          /* function exported by static library */
	#define DMD_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* WIN32 */

/*------------------------------*/
/* POSIX type modifiers			*/
#ifdef POSIX
	#define _DMD_EXPORT				                     /* function exported by library */
	#define DMD_CALLBACK					             /* client callback function called by library */
#endif /* POSIX */

/*------------------------------*/
/* VXWORKS type modifiers		*/
#ifdef VXWORKS
	#define _DMD_EXPORT									/* function exported by library */
	#define DMD_CALLBACK								/* client callback function called by library */
#endif /* VXWORKS */

/*------------------------------------------------------------------------------
 * hidden structures for library clients
 *-----------------------------------------------------------------------------*/
#ifndef DMD
	#define DMD void
#endif

/*------------------------------------------------------------------------------
 * extended types
 *-----------------------------------------------------------------------------*/
/*--------------------------*/
/* byte type				*/
#ifndef __BYTE
	#define __BYTE
	typedef unsigned char byte;
#endif

/*--------------------------*/
/* word type				*/
#ifndef __WORD
	#define __WORD
	typedef unsigned short word;
#endif

/*--------------------------*/
/* dword type				*/
#ifndef __DWORD
	#define __DWORD
	typedef uint32_t dword;
#endif

/*--------------------------*/
/* char_p type				*/
#ifndef __CHAR_P
	#define __CHAR_P
	typedef char *char_p;
#endif

/*--------------------------*/
/* char_cp type				*/
#ifndef __CHAR_CP
	#define __CHAR_CP
	typedef const char *char_cp;
	#ifndef __cplusplus
		#ifndef __BOOL
			#define __BOOL
			typedef byte bool;
		#endif /*BOOL */
	#endif /*__cplusplus */
#endif /*CHAR_CP */

/*--------------------------*/
/* 64 bits integer			*/
#ifndef __INT64
	#define __INT64
	#if __BYTE_ORDER == __LITTLE_ENDIAN
		typedef struct INT64_DWORD_MODE {
			dword low_dword;
			dword high_dword;
		} INT64_DWORD_MODE;
	#else /*__BYTE_ORDER*/
		typedef struct INT64_DWORD_MODE {
			dword high_dword;
			dword low_dword;
		} INT64_DWORD_MODE;
	#endif /*__BYTE_ORDER*/

	#if __BYTE_ORDER == __LITTLE_ENDIAN
		typedef struct INT64_BYTE_MODE {
			byte byte0;
			byte byte1;
			byte byte2;
			byte byte3;
			byte byte4;
			byte byte5;
			byte byte6;
			byte byte7;
		} INT64_BYTE_MODE;
	#else /*__BYTE_ORDER*/
		typedef struct INT64_BYTE_MODE {
			byte byte7;
			byte byte6;
			byte byte5;
			byte byte4;
			byte byte3;
			byte byte2;
			byte byte1;
			byte byte0;
		} INT64_BYTE_MODE;
	#endif /*__BYTE_ORDER*/

	/*------------------------------*/
	/* WINDOWS 64 bits integer		*/
	#if defined WIN32
		#define eint64 long long
	/*------------------------------*/
	/* POSIX 64 bits integer		*/
	#elif defined POSIX || defined VXWORKS
		#define eint64 long long
	#endif
#endif

/**
 * @enum DMD_FAMILY
 * Device family enum
 */
typedef enum {
    DMD_FAMILY_UNDEFINED = 0,
	DMD_FAMILY_ACCURET = 3
} DMD_FAMILY;

/**
 * @struct DMD_UNITS 
 * unit structure
 */
typedef struct DMD_UNITS {
    int size;                                     /**< the size of this structure */
	#ifdef DMD_OO_API
	int secondExp;                                   /**< exposent of 's' unit */
	int positionExp;                                 /**< exposent of 'm' or 't'(turn) unit */
	int voltExp;                                     /**< exposent of 'V' unit */
	int ampereExp;                                   /**< exposent of 'A' unit */
	int periodExp;                                   /**< exposent of period (360 deg) unit */
	int forceExp;                                    /**< exposent of 'N' or 'Nm' unit */
	int tempExp;                                     /**< exposent of '0C' unit */
	#else /* DMD_OO_API */
	int second_exp;                                  /**< exposent of 's' unit */
	int position_exp;                                /**< exposent of 'm' or 't'(turn) unit */
	int volt_exp;                                    /**< exposent of 'V' unit */
	int ampere_exp;                                  /**< exposent of 'A' unit */
	int period_exp;                                  /**< exposent of period (360 deg) unit */
	int force_exp;                                   /**< exposent of 'N' or 'Nm' unit */
	int temp_exp;                                    /**< exposent of '0C' unit */
	#endif /* DMD_OO_API */
} DMD_UNITS;
#define DmdUnits DMD_UNITS
typedef const DMD_UNITS *DMD_UNITS_CP;               /**< pointer to units information */

/**
 * @struct DMD_FW_BLOCK 
 * Firmware block structure
 */
typedef struct DMD_FW_BLOCK {
	int nb;					/**< The block number*/
	int type;				/**< The type of the block: DMD_FW_BLOCK_BOOT, DMD_FW_BLOCK_FIRMWARE, ... */
	int size;				/**< The size of the block in byte*/
	int product;			/**< The product to which the block correspond DMD_DRV_PRODUCTS_...*/
	int version;			/**< The version of the product 1 or 2*/
} DMD_FW_BLOCK;

/**********************************************************************************************************/
/*- PROTOTYPES */
/**********************************************************************************************************/
/**
 * @addtogroup DMDAll
 * @{
 */

/*------------------------------------------------------------------------------
 * general functions
 *-----------------------------------------------------------------------------*/
dword   _DMD_EXPORT dmd_get_version(void);
dword   _DMD_EXPORT dmd_get_edi_version(void);
time_t  _DMD_EXPORT dmd_get_build_time(void);
char_cp _DMD_EXPORT dmd_translate_error(int code);
char_cp _DMD_EXPORT dmd_translate_drv_product(int d_prod);
char_cp _DMD_EXPORT dmd_translate_ext_product(int x_prod);
bool	_DMD_EXPORT dmd_is_double_conv(int conv);
int		_DMD_EXPORT dmd_get_conv_idx(char_cp alias);
DMD_UNITS_CP _DMD_EXPORT dmd_get_conv_units(int conv);
char_cp _DMD_EXPORT dmd_get_default_type_text(int typ);

/*------------------------------------------------------------------------------
 * supported drive version
 *-----------------------------------------------------------------------------*/
dword   _DMD_EXPORT dmd_get_first_defined_drv_version(int prod);
dword   _DMD_EXPORT dmd_get_last_defined_drv_version(int prod);
dword   _DMD_EXPORT dmd_get_next_defined_drv_version(int prod, dword ver);
bool    _DMD_EXPORT dmd_is_drv_version_supported(int prod, dword ver);
bool    _DMD_EXPORT dmd_is_drv_version_compatible(int prod, dword ref, dword ver);
void	_DMD_EXPORT dmd_version_to_string(char *buffer, int max, dword version);
int		_DMD_EXPORT dmd_string_to_version(char *buffer, dword *version);
DMD_FAMILY _DMD_EXPORT dmd_get_prod_family(int prod);
bool    _DMD_EXPORT dmd_is_master(int prod);

/*------------------------------------------------------------------------------
 * supported extension card version
 *-----------------------------------------------------------------------------*/
dword   _DMD_EXPORT dmd_get_first_defined_ext_version(int prod);
dword   _DMD_EXPORT dmd_get_last_defined_ext_version(int prod);
dword   _DMD_EXPORT dmd_get_next_defined_ext_version(int prod, dword ver);
bool    _DMD_EXPORT dmd_is_ext_version_supported(int prod, dword ver);
bool    _DMD_EXPORT dmd_is_ext_version_compatible(int prod, dword ref, dword ver);
DMD_FAMILY _DMD_EXPORT dmd_get_prod_family(int prod);

/*------------------------------------------------------------------------------
 * object creation functions
 *-----------------------------------------------------------------------------*/
int     _DMD_EXPORT dmd_create(DMD **dmd, int d_prod, dword d_ver, int x_prod, dword x_ver);
int     _DMD_EXPORT dmd_destroy(DMD **dmd);
bool    _DMD_EXPORT dmd_is_valid(DMD *dmd);

/*------------------------------------------------------------------------------
 * general information retrieving
 *-----------------------------------------------------------------------------*/
int     _DMD_EXPORT dmd_get_drv_product(DMD *dmd);
int     _DMD_EXPORT dmd_get_ext_product(DMD *dmd);
dword   _DMD_EXPORT dmd_get_drv_version(DMD *dmd);
dword   _DMD_EXPORT dmd_get_ext_version(DMD *dmd);
DMD_FAMILY _DMD_EXPORT dmd_get_family(DMD *dmd);

/*------------------------------------------------------------------------------
 * register meta-data access
 *-----------------------------------------------------------------------------*/
char_cp _DMD_EXPORT dmd_get_type_text(DMD *dmd, int text, int typ);
int		_DMD_EXPORT dmd_get_register_type_idx(DMD *dmd, char_cp alias, int *typ, int *idx);
char_cp _DMD_EXPORT dmd_get_register_text(DMD *dmd, int text, int typ, unsigned idx, int sidx);
char_cp _DMD_EXPORT dmd_get_register_group(DMD *dmd, int text, int typ, unsigned idx);
long    _DMD_EXPORT dmd_get_register_min_value(DMD *dmd, int typ, unsigned idx, int sidx);
long    _DMD_EXPORT dmd_get_register_max_value(DMD *dmd, int typ, unsigned idx, int sidx);
long    _DMD_EXPORT dmd_get_register_default_value(DMD *dmd, int typ, unsigned idx, int sidx);
long    _DMD_EXPORT dmd_get_register_min_value_int32(DMD *dmd, int typ, unsigned idx, int sidx);
long    _DMD_EXPORT dmd_get_register_max_value_int32(DMD *dmd, int typ, unsigned idx, int sidx);
long    _DMD_EXPORT dmd_get_register_default_value_int32(DMD *dmd, int typ, unsigned idx, int sidx);
eint64   _DMD_EXPORT dmd_get_register_min_value_int64(DMD *dmd, int typ, unsigned idx, int sidx);
eint64   _DMD_EXPORT dmd_get_register_max_value_int64(DMD *dmd, int typ, unsigned idx, int sidx);
eint64   _DMD_EXPORT dmd_get_register_default_value_int64(DMD *dmd, int typ, unsigned idx, int sidx);
float   _DMD_EXPORT dmd_get_register_min_value_float32(DMD *dmd, int typ, unsigned idx, int sidx);
float   _DMD_EXPORT dmd_get_register_max_value_float32(DMD *dmd, int typ, unsigned idx, int sidx);
float   _DMD_EXPORT dmd_get_register_default_value_float32(DMD *dmd, int typ, unsigned idx, int sidx);
double  _DMD_EXPORT dmd_get_register_min_value_float64(DMD *dmd, int typ, unsigned idx, int sidx);
double  _DMD_EXPORT dmd_get_register_max_value_float64(DMD *dmd, int typ, unsigned idx, int sidx);
double  _DMD_EXPORT dmd_get_register_default_value_float64(DMD *dmd, int typ, unsigned idx, int sidx);
eint64   _DMD_EXPORT dmd_get_register_min_value_rawbits(DMD *dmd, int typ, unsigned idx, int sidx);
eint64   _DMD_EXPORT dmd_get_register_max_value_rawbits(DMD *dmd, int typ, unsigned idx, int sidx);
eint64   _DMD_EXPORT dmd_get_register_default_value_rawbits(DMD *dmd, int typ, unsigned idx, int sidx);

bool    _DMD_EXPORT dmd_is_double_register(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_system_register(DMD *dmd, int typ, unsigned idx, int sidx);
int     _DMD_EXPORT dmd_get_register_convert(DMD *dmd, int typ, unsigned idx, int sidx);
DMD_UNITS_CP 
        _DMD_EXPORT dmd_get_register_units(DMD *dmd, int typ, unsigned idx, int sidx);
int     _DMD_EXPORT dmd_get_register_enum_group(DMD *dmd, int typ, unsigned idx, int sidx);
int     _DMD_EXPORT dmd_get_subindex_enum_group(DMD *dmd, int typ, unsigned idx);
bool    _DMD_EXPORT dmd_is_type_available(DMD *dmd, int typ);
bool    _DMD_EXPORT dmd_is_type_uniform(DMD *dmd, int typ);
bool    _DMD_EXPORT dmd_is_type_writable(DMD *dmd, int typ);
bool    _DMD_EXPORT dmd_is_type_restored(DMD *dmd, int typ);
bool	_DMD_EXPORT dmd_is_type_int32(DMD *dmd, int typ);
bool	_DMD_EXPORT dmd_is_type_int64(DMD *dmd, int typ);
bool	_DMD_EXPORT dmd_is_type_float32(DMD *dmd, int typ);
bool	_DMD_EXPORT dmd_is_type_float64(DMD *dmd, int typ);
bool    _DMD_EXPORT dmd_is_index_available(DMD *dmd, int typ, unsigned idx);
bool    _DMD_EXPORT dmd_is_register_available(DMD *dmd, int typ, unsigned idx, int sidx);
long    _DMD_EXPORT dmd_get_number_of_indexes(DMD *dmd, int typ);
int     _DMD_EXPORT dmd_get_number_of_subindexes(DMD *dmd, int typ, int index);
int     _DMD_EXPORT dmd_get_max_number_of_subindexes(DMD *dmd, int typ);
bool    _DMD_EXPORT dmd_is_register_writable(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_register_restored(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_register_deprecated(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_register_hidden(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_register_int32(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_register_int64(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_register_float32(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_register_float64(DMD *dmd, int typ, unsigned idx, int sidx);
int     _DMD_EXPORT dmd_get_register_increment_type(DMD *dmd, int typ, unsigned idx, int sidx);

/*------------------------------------------------------------------------------
 * command meta-data access
 *-----------------------------------------------------------------------------*/
int		_DMD_EXPORT dmd_get_command_idx(DMD *dmd, char_cp alias);
char_cp _DMD_EXPORT dmd_get_command_text(DMD *dmd, int text, int idx);
char_cp _DMD_EXPORT dmd_get_command_group(DMD *dmd, int text, int idx);
char_cp _DMD_EXPORT dmd_get_parameter_text(DMD *dmd, int text, int idx, int par);
long    _DMD_EXPORT dmd_get_parameter_min_value(DMD *dmd, int idx, int par);
long    _DMD_EXPORT dmd_get_parameter_max_value(DMD *dmd, int idx, int par);
long    _DMD_EXPORT dmd_get_parameter_default_value(DMD *dmd, int idx, int par);
long    _DMD_EXPORT dmd_get_parameter_min_value_int32(DMD *dmd, int idx, int par);
long    _DMD_EXPORT dmd_get_parameter_max_value_int32(DMD *dmd, int idx, int par);
long    _DMD_EXPORT dmd_get_parameter_default_value_int32(DMD *dmd, int idx, int par);
eint64   _DMD_EXPORT dmd_get_parameter_min_value_int64(DMD *dmd, int idx, int par);
eint64   _DMD_EXPORT dmd_get_parameter_max_value_int64(DMD *dmd, int idx, int par);
eint64   _DMD_EXPORT dmd_get_parameter_default_value_int64(DMD *dmd, int idx, int par);
float   _DMD_EXPORT dmd_get_parameter_min_value_float32(DMD *dmd, int idx, int par);
float   _DMD_EXPORT dmd_get_parameter_max_value_float32(DMD *dmd, int idx, int par);
float   _DMD_EXPORT dmd_get_parameter_default_value_float32(DMD *dmd, int idx, int par);
double  _DMD_EXPORT dmd_get_parameter_min_value_float64(DMD *dmd, int idx, int par);
double  _DMD_EXPORT dmd_get_parameter_max_value_float64(DMD *dmd, int idx, int par);
double  _DMD_EXPORT dmd_get_parameter_default_value_float64(DMD *dmd, int idx, int par);
eint64   _DMD_EXPORT dmd_get_parameter_min_value_rawbits(DMD *dmd, int idx, int par);
eint64   _DMD_EXPORT dmd_get_parameter_max_value_rawbits(DMD *dmd, int idx, int par);
eint64   _DMD_EXPORT dmd_get_parameter_default_value_rawbits(DMD *dmd, int idx, int par);
bool    _DMD_EXPORT dmd_is_double_parameter(DMD *dmd, int idx, int par);
bool    _DMD_EXPORT dmd_is_parameter_returned_value(DMD *dmd, int idx, int par);
int     _DMD_EXPORT dmd_get_first_returned_value_parameter_index(DMD *dmd, int idx);
int     _DMD_EXPORT dmd_get_parameter_convert(DMD *dmd, int idx, int par);
DMD_UNITS_CP 
        _DMD_EXPORT dmd_get_parameter_units(DMD *dmd, int idx, int par);
int     _DMD_EXPORT dmd_get_parameter_enum_group(DMD *dmd, int idx, int par);
int     _DMD_EXPORT dmd_get_number_of_parameters(DMD *dmd, int idx);
bool    _DMD_EXPORT dmd_is_command_available(DMD *dmd, int idx);
bool    _DMD_EXPORT dmd_is_command_rec_available(DMD *dmd, int idx, int rec, int dst_typ);
bool    _DMD_EXPORT dmd_is_command_deprecated(DMD *dmd, int idx);
bool    _DMD_EXPORT dmd_is_command_hidden(DMD *dmd, int idx);
bool    _DMD_EXPORT dmd_is_command_waiting(DMD *dmd, int idx);
bool    _DMD_EXPORT dmd_is_parameter_jump_target(DMD *dmd, int idx, int par);
bool    _DMD_EXPORT dmd_is_parameter_l_value(DMD *dmd, int idx, int par);
bool    _DMD_EXPORT dmd_is_parameter_int32(DMD *dmd, int idx, int par);
bool    _DMD_EXPORT dmd_is_parameter_int64(DMD *dmd, int idx, int par);
bool    _DMD_EXPORT dmd_is_parameter_float32(DMD *dmd, int idx, int par);
bool    _DMD_EXPORT dmd_is_parameter_float64(DMD *dmd, int idx, int par);
int     _DMD_EXPORT dmd_get_parameter_increment_type(DMD *dmd, int idx, int par);

/*------------------------------------------------------------------------------
 * enum_g values access
 *-----------------------------------------------------------------------------*/
bool    _DMD_EXPORT dmd_is_enum_group_available(DMD *dmd, int enum_g);
char_cp _DMD_EXPORT dmd_get_enum_group_text(DMD *dmd, int text, int enum_g);
int     _DMD_EXPORT dmd_get_enum_group_size(DMD *dmd, int enum_g);
char_cp _DMD_EXPORT dmd_get_enum_text(DMD *dmd, int text, int enum_g, int id);
long    _DMD_EXPORT dmd_get_enum_value(DMD *dmd, int enum_g, int id);
long    _DMD_EXPORT dmd_get_enum_value_int32(DMD *dmd, int enum_g, int id);
eint64   _DMD_EXPORT dmd_get_enum_value_int64(DMD *dmd, int enum_g, int id);
float   _DMD_EXPORT dmd_get_enum_value_float32(DMD *dmd, int enum_g, int id);
double  _DMD_EXPORT dmd_get_enum_value_float64(DMD *dmd, int enum_g, int id);
int     _DMD_EXPORT dmd_get_enum_range(DMD *dmd, int enum_g, int id);
bool    _DMD_EXPORT dmd_is_enum_mask(DMD *dmd, int enum_g, int id);
bool    _DMD_EXPORT dmd_is_enum_hidden(DMD *dmd, int enum_g, int id);
bool    _DMD_EXPORT dmd_is_enum_deprecated(DMD *dmd, int enum_g, int id);
bool    _DMD_EXPORT dmd_is_register_enum_available(DMD *dmd, int enum_id, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_subindex_enum_available(DMD *dmd, int enum_id, int typ, unsigned idx);
bool    _DMD_EXPORT dmd_is_parameter_enum_available(DMD *dmd, int enum_id, int idx, int par);

/*------------------------------------------------------------------------------
 * firmware blocks access
 *-----------------------------------------------------------------------------*/
int		_DMD_EXPORT dmd_get_fw_block_list(int product, int hw_version, dword fw_version, int max_block, DMD_FW_BLOCK blocks[], int *nb_blocks);
char_cp	_DMD_EXPORT dmd_get_fw_block_name(int block_type);
int		_DMD_EXPORT dmd_get_fw_first_map_block(int product, int hw_version, dword fw_version, int motor, DMD_FW_BLOCK *block);
int		_DMD_EXPORT dmd_get_fw_first_block(int product, int hw_version, dword fw_version, DMD_FW_BLOCK *block);
/** @}*/

#ifdef __cplusplus
	} /* extern "C" */
#endif


/**********************************************************************************************************/
/*- C++ WRAPPER CLASSES */
/**********************************************************************************************************/
/*------------------------------------------------------------------------------
 * Dmd base class - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class Dmd {
		/*
		 * some public constants
		 */
		/*
		 * release status
		 */ 
	public:
		enum { MICRO_ALPHA =  0x00 };                    /* base number for alpha releases */
		enum { MICRO_BETA = 0x40 };                      /* base number for beta releases */
		enum { MICRO_FINAL = 0x80 };                     /* base number for final releases */

		/*
		 * special user register
		 */ 
	public:
		enum { USR_ACC = 0xFFFF } ;                      /* special user data - accumulator */
		enum { VAR_INDIRECT = 0xFFFE } ;                 /* indirect register access */

		/*
		 * special product number
		 */ 
	public:
		enum { PRODUCT_ANY_ACCURET = -2 } ;              /* special product number - any ACCURET*/

		/*
		 * some maximum values
		 */
		enum { TYPES = 128 };                             /* no more than 128 types now */
		enum { ENUMS = 256 };                             /* no more than 256 enums now */
		enum { COMMANDS = 1280 };                         /* no more than 1280 commands now */
		enum { CONVS = 256 };                            /* no more than 256 conversions now */
    
		/*
		 * versions access
		 */
	public:
		static dword getVersion() { 
			return dmd_get_version(); 
		}
		static dword getEdiVersion() { 
			return dmd_get_edi_version(); 
		}
		static time_t getBuildTime() { 
			return dmd_get_build_time(); 
		}

		static bool isDoubleConv(int conv) {
			return dmd_is_double_conv(conv);
		}
		static int getConvIdx(char_cp alias) {
			return dmd_get_conv_idx(alias);
		}
		static const DmdUnits &getConvUnits(int conv) {
			return *dmd_get_conv_units(conv);
		}
		static char_cp getDefaultTypeText(int typ) {
			return dmd_get_default_type_text(typ);
		}

		/*
		 * supported drive version
		 */
		static dword getFirstDefinedDrvVersion(int prod) {
			return dmd_get_first_defined_drv_version(prod);
		}
		static dword getLastDefinedDrvVersion(int prod) {
			return dmd_get_last_defined_drv_version(prod);
		}
		static dword getNextDefinedDrvVersion(int prod, dword ver) {
			return dmd_get_next_defined_drv_version(prod, ver);
		}
		static bool isDrvVersionSupported(int prod, dword ver) {
			return dmd_is_drv_version_supported(prod, ver);
		}
		static bool isDrvVersionCompatible(int prod, dword ref, dword ver) {
			return dmd_is_drv_version_compatible(prod, ref, ver);
		}

		/*
		 * supported extension card version
		 */
		static dword getFirstDefinedExtVersion(int prod) {
			return dmd_get_first_defined_ext_version(prod);
		}
		static dword getLastDefinedExtVersion(int prod) {
			return dmd_get_last_defined_ext_version(prod);
		}
		static dword getNextDefinedExtVersion(int prod, dword ver) {
			return dmd_get_next_defined_ext_version(prod, ver);
		}
		static bool isExtVersionSupported(int prod, dword ver) {
			return dmd_is_ext_version_supported(prod, ver);
		}
		static bool isExtVersionCompatible(int prod, dword ref, dword ver) {
			return dmd_is_ext_version_compatible(prod, ref, ver);
		}
	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * Dmd exception - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdException {
	friend class DmdData;
	friend class DmdTraductor;
		/*
		 * public error codes
		 */
	    enum { EBADDRVPROD = -416 };                     /* an unknown drive product has been specified */
    enum { EBADDRVVER = -418 };                      /* a drive with an incompatible version has been specified */
    enum { EBADEXTPROD = -417 };                     /* an unknown extention card  product has been specified */
    enum { EBADEXTVER = -419 };                      /* an extention card with an incompatible version has been specified */
    enum { EBADPARAM = -415 };                       /* one of the parameter is not valid */
    enum { EOBSOLETE = -402 };                       /* function is obsolete */
    enum { ESYSTEM = -414 };                         /* some system resource return an error */


		/*
		 * exception code
		 */
	private:
		int code;

		/*
		 * constructor
		 */
	protected:
		DmdException(int e) { code = e; };

		/*
		 * translate a drive product code to the text description
		 */
	public:
		static const char *translate(int d_prod) { 
			return dmd_translate_error(d_prod);
		}

		/*
		 * get error description
		 */
	public:
		int getCode() { 
			return code; 
		}
		const char *getText() { 
			return translate(code); 
		}
	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * Data class - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	#define ERRCHK(a) do { int _err = (a); if (_err) throw DmdException(_err); } while(0)
	class DmdData {
		/*
		 * internal dmd pointer
		 */
	protected:
		DMD *dmd;

		/*
		 * text query constants
		 */ 
	public:
		enum { TEXT_MNEMONIC = 1 };                      /* mnemonic */
		enum { TEXT_SHORT = 2 };                         /* short text description */

		/*
		 * constructors / destructor
		 */
	public:
		DmdData(int d_prod, dword d_ver, int x_prod, dword x_ver) { 
			dmd = NULL; 
			ERRCHK(dmd_create(&dmd, d_prod, d_ver, x_prod, x_ver));
		}
		DmdData(DmdData &data) { 
			dmd = data.dmd; 
		}
		DmdData() { 
			dmd = NULL; 
		}
		bool isValid() {
			return dmd_is_valid(dmd);
		}

		/*
		 * destructor function
		 */
		void destroy() {
			ERRCHK(dmd_destroy(&dmd));
		}
		
		/*
		 * general information retrieving
		 */
		int getDrvProduct() {
			return dmd_get_drv_product(dmd);
		}
		int getExtProduct() {
			return dmd_get_ext_product(dmd);
		}
		int getDrvVersion() {
			return dmd_get_drv_version(dmd);
		}
		int getExtVersion() {
			return dmd_get_ext_version(dmd);
		}

		/*
		 * register meta-data access
		 */
		char_cp getTypeText(int text, int typ) {
			return dmd_get_type_text(dmd, text, typ);
		}
		int getRegisterTypeIdx(char_cp alias, int *typ, int *idx) {
			return dmd_get_register_type_idx(dmd, alias, typ, idx);
		}
		char_cp getRegisterText(int text, int typ, unsigned idx, int sidx) {
			return dmd_get_register_text(dmd, text, typ, idx, sidx);
		}
		char_cp getRegisterGroup(int text, int typ, unsigned idx) {
			return dmd_get_register_group(dmd, text, typ, idx);
		}
		long getRegisterMinValue(int typ, unsigned idx, int sidx) {
			return dmd_get_register_min_value(dmd, typ, idx, sidx);
		}
		long getRegisterMaxValue(int typ, unsigned idx, int sidx) {
			return dmd_get_register_max_value(dmd, typ, idx, sidx);
		}
		long getRegisterDefaultValue(int typ, unsigned idx, int sidx) {
			return dmd_get_register_default_value(dmd, typ, idx, sidx);
		}
		long getRegisterMinValueInt32(int typ, unsigned idx, int sidx) {
			return dmd_get_register_min_value_int32(dmd, typ, idx, sidx);
		}
		long getRegisterMaxValueInt32(int typ, unsigned idx, int sidx) {
			return dmd_get_register_max_value_int32(dmd, typ, idx, sidx);
		}
		long getRegisterDefaultValueInt32(int typ, unsigned idx, int sidx) {
			return dmd_get_register_default_value_int32(dmd, typ, idx, sidx);
		}
		eint64 getRegisterMinValueInt64(int typ, unsigned idx, int sidx) {
			return dmd_get_register_min_value_int64(dmd, typ, idx, sidx);
		}
		eint64 getRegisterMaxValueInt64(int typ, unsigned idx, int sidx) {
			return dmd_get_register_max_value_int64(dmd, typ, idx, sidx);
		}
		eint64 getRegisterDefaultValueInt64(int typ, unsigned idx, int sidx) {
			return dmd_get_register_default_value_int64(dmd, typ, idx, sidx);
		}
		float getRegisterMinValueFloat32(int typ, unsigned idx, int sidx) {
			return dmd_get_register_min_value_float32(dmd, typ, idx, sidx);
		}
		float getRegisterMaxValueFloat32(int typ, unsigned idx, int sidx) {
			return dmd_get_register_max_value_float32(dmd, typ, idx, sidx);
		}
		float getRegisterDefaultValueFloat32(int typ, unsigned idx, int sidx) {
			return dmd_get_register_default_value_float32(dmd, typ, idx, sidx);
		}
		double getRegisterMinValueFloat64(int typ, unsigned idx, int sidx) {
			return dmd_get_register_min_value_float64(dmd, typ, idx, sidx);
		}
		double getRegisterMaxValueFloat64(int typ, unsigned idx, int sidx) {
			return dmd_get_register_max_value_float64(dmd, typ, idx, sidx);
		}
		double getRegisterDefaultValueFloat64(int typ, unsigned idx, int sidx) {
			return dmd_get_register_default_value_float64(dmd, typ, idx, sidx);
		}
		eint64 getRegisterMinValueRawBits(int typ, unsigned idx, int sidx) {
			return dmd_get_register_min_value_rawbits(dmd, typ, idx, sidx);
		}
		eint64 getRegisterMaxValueRawBits(int typ, unsigned idx, int sidx) {
			return dmd_get_register_max_value_rawbits(dmd, typ, idx, sidx);
		}
		eint64 getRegisterDefaultValueRawBits(int typ, unsigned idx, int sidx) {
			return dmd_get_register_default_value_rawbits(dmd, typ, idx, sidx);
		}
		int getRegisterConvert(int typ, unsigned idx, int sidx) {
			return dmd_get_register_convert(dmd, typ, idx, sidx);
		}
		int getRegisterEnumGroup(int typ, unsigned idx, int sidx) {
			return dmd_get_register_enum_group(dmd, typ, idx, sidx);
		}
		int getSubindexEnumGroup(int typ, unsigned idx) {
			return dmd_get_subindex_enum_group(dmd, typ, idx);
		}
		bool isDoubleRegister(int typ, unsigned idx, int sidx) {
			return dmd_is_double_register(dmd, typ, idx, sidx);
		}
		bool isSystemRegister(int typ, unsigned idx, int sidx) {
			return dmd_is_system_register(dmd, typ, idx, sidx);
		}
		const DMD_UNITS &getRegisterUnits(int typ, unsigned idx, int sidx) {
			return *dmd_get_register_units(dmd, typ, idx, sidx);
		}
		bool isTypeAvailable(int typ) {
			return dmd_is_type_available(dmd, typ);
		}
		bool isTypeUniform(int typ) {
			return dmd_is_type_uniform(dmd, typ);
		}
		bool isTypeWritable(int typ) {
			return dmd_is_type_writable(dmd, typ);
		}
		bool isTypeRestored(int typ) {
			return dmd_is_type_restored(dmd, typ);
		}
		bool isTypeInt32(int typ) {
			return dmd_is_type_int32(dmd, typ);
		}
		bool isTypeInt64(int typ) {
			return dmd_is_type_int64(dmd, typ);
		}
		bool isTypeFloat32(int typ) {
			return dmd_is_type_float32(dmd, typ);
		}
		bool isTypeFloat64(int typ) {
			return dmd_is_type_float64(dmd, typ);
		}
		bool isIndexAvailable(int typ, unsigned idx) {
			return dmd_is_index_available(dmd, typ, idx);
		}
		bool isRegisterAvailable(int typ, unsigned idx, int sidx) {
			return dmd_is_register_available(dmd, typ, idx, sidx);
		}
		bool isRegisterWritable(int typ, unsigned idx, int sidx) {
			return dmd_is_register_writable(dmd, typ, idx, sidx);
		}
		bool isRegisterRestored(int typ, unsigned idx, int sidx) {
			return dmd_is_register_restored(dmd, typ, idx, sidx);
		}
		bool isRegisterHidden(int typ, unsigned idx, int sidx) {
			return dmd_is_register_hidden(dmd, typ, idx, sidx);
		}
		bool isRegisterInt32(int typ, unsigned idx, int sidx) {
			return dmd_is_register_int32(dmd, typ, idx, sidx);
		}
		bool isRegisterInt64(int typ, unsigned idx, int sidx) {
			return dmd_is_register_int64(dmd, typ, idx, sidx);
		}
		bool isRegisterFloat32(int typ, unsigned idx, int sidx) {
			return dmd_is_register_float32(dmd, typ, idx, sidx);
		}
		bool isRegisterFloat64(int typ, unsigned idx, int sidx) {
			return dmd_is_register_float64(dmd, typ, idx, sidx);
		}
		int getRegisterIncrementType(int typ, unsigned idx, int sidx) {
			return dmd_get_register_increment_type(dmd, typ, idx, sidx);
		}
		bool isRegisterDeprecated(int typ, unsigned idx, int sidx) {
			return dmd_is_register_deprecated(dmd, typ, idx, sidx);
		}
		long getNumberOfIndexes(int typ) {
			return dmd_get_number_of_indexes(dmd, typ);
		}
		int getNumberOfSubindexes(int typ, int index) {
			return dmd_get_number_of_subindexes(dmd, typ, index);
		}
		int getMaxNumberOfSubindexes(int typ) {
			return dmd_get_max_number_of_subindexes(dmd, typ);
		}

		/*
		 * command meta-data access
		 */
		int getCommandIdx(int text, char_cp alias) {
			return dmd_get_command_idx(dmd, alias);
		}
		char_cp getCommandText(int text, int idx) {
			return dmd_get_command_text(dmd, text, idx);
		}
		char_cp getCommandGroup(int text, int idx) {
			return dmd_get_command_group(dmd, text, idx);
		}
		char_cp getParameterText(int text, int idx, int par) {
			return dmd_get_parameter_text(dmd, text, idx, par);
		}
		long getParameterMinValue(int idx, int par) {
			return dmd_get_parameter_min_value(dmd, idx, par);
		}
		long getParameterMaxValue(int idx, int par) {
			return dmd_get_parameter_max_value(dmd, idx, par);
		}
		long getParameterDefaultValue(int idx, int par) {
			return dmd_get_parameter_default_value(dmd, idx, par);
		}
		long getParameterMinValueInt32(int idx, int par) {
			return dmd_get_parameter_min_value_int32(dmd, idx, par);
		}
		long getParameterMaxValueInt32(int idx, int par) {
			return dmd_get_parameter_max_value_int32(dmd, idx, par);
		}
		long getParameterDefaultValueInt32(int idx, int par) {
			return dmd_get_parameter_default_value_int32(dmd, idx, par);
		}
		eint64 getParameterMinValueInt64(int idx, int par) {
			return dmd_get_parameter_min_value_int64(dmd, idx, par);
		}
		eint64 getParameterMaxValueInt64(int idx, int par) {
			return dmd_get_parameter_max_value_int64(dmd, idx, par);
		}
		eint64 getParameterDefaultValueInt64(int idx, int par) {
			return dmd_get_parameter_default_value_int64(dmd, idx, par);
		}
		float getParameterMinValueFloat32(int idx, int par) {
			return dmd_get_parameter_min_value_float32(dmd, idx, par);
		}
		float getParameterMaxValueFloat32(int idx, int par) {
			return dmd_get_parameter_max_value_float32(dmd, idx, par);
		}
		float getParameterDefaultValueFloat32(int idx, int par) {
			return dmd_get_parameter_default_value_float32(dmd, idx, par);
		}
		double getParameterMinValueFloat64(int idx, int par) {
			return dmd_get_parameter_min_value_float64(dmd, idx, par);
		}
		double getParameterMaxValueFloat64(int idx, int par) {
			return dmd_get_parameter_max_value_float64(dmd, idx, par);
		}
		double getParameterDefaultValueFloat64(int idx, int par) {
			return dmd_get_parameter_default_value_float64(dmd, idx, par);
		}
		eint64 getParameterMinValueRawBits(int idx, int par) {
			return dmd_get_parameter_min_value_rawbits(dmd, idx, par);
		}
		eint64 getParameterMaxValueRawBits(int idx, int par) {
			return dmd_get_parameter_max_value_rawbits(dmd, idx, par);
		}
		eint64 getParameterDefaultValueRawBits(int idx, int par) {
			return dmd_get_parameter_default_value_rawbits(dmd, idx, par);
		}
		int getParameterConvert(int idx, int par) {
			return dmd_get_parameter_convert(dmd, idx, par);
		}
		bool isDoubleParameter(int idx, int par) {
			return dmd_is_double_parameter(dmd, idx, par);
		}
		const DMD_UNITS &getParameterUnits(int idx, int par) {
			return *dmd_get_parameter_units(dmd, idx, par);
		}
		int getParameterEnumGroup(int idx, int par) {
			return dmd_get_parameter_enum_group(dmd, idx, par);
		}
		int getNumberOfParameters(int idx) {
			return dmd_get_number_of_parameters(dmd, idx);
		}
		bool isCommandAvailable(int idx) {
			return dmd_is_command_available(dmd, idx);
		}
		bool isCommandRecAvailable(int idx, int rec, int dst_typ) {
			return dmd_is_command_rec_available(dmd, idx, rec, dst_typ);
		}
		bool isCommandDeprecated(int idx) {
			return dmd_is_command_deprecated(dmd, idx);
		}
		bool isCommandHidden(int idx) {
			return dmd_is_command_hidden(dmd, idx);
		}
		bool isParameterJumpTarget(int idx, int par) {
			return dmd_is_parameter_jump_target(dmd, idx, par);
		}
		bool isParameterLValue(int idx, int par) {
			return dmd_is_parameter_l_value(dmd, idx, par);
		}
		bool isParameterInt64(int idx, int par) {
			return dmd_is_parameter_int64(dmd, idx, par);
		}
		bool isParameterFloat32(int idx, int par) {
			return dmd_is_parameter_float32(dmd, idx, par);
		}
		bool isParameterInt32(int idx, int par) {
			return dmd_is_parameter_int32(dmd, idx, par);
		}
		bool isParameterFloat64(int idx, int par) {
			return dmd_is_parameter_float64(dmd, idx, par);
		}
		int getParameterIncrementType(int idx, int par) {
			return dmd_get_parameter_increment_type(dmd, idx, par);
		}


		/*
		 * enum_g values access
		 */
		bool isEnumGroupAvailable(int enum_g) {
			return dmd_is_enum_group_available(dmd, enum_g);
		}
		char_cp getEnumGroupText(int text, int enum_g) {
			return dmd_get_enum_group_text(dmd, text, enum_g);
		}
		int getEnumGroupSize(int enum_g) {
			return dmd_get_enum_group_size(dmd, enum_g);
		}
		char_cp getEnumText(int text, int enum_g, int id) {
			return dmd_get_enum_text(dmd, text, enum_g, id);
		}
		long getEnumValue(int enum_g, int id) {
			return dmd_get_enum_value(dmd, enum_g, id);
		}
		long getEnumValueInt32(int enum_g, int id) {
			return dmd_get_enum_value_int32(dmd, enum_g, id);
		}
		eint64 getEnumValueInt64(int enum_g, int id) {
			return dmd_get_enum_value_int64(dmd, enum_g, id);
		}
		float getEnumValueFloat32(int enum_g, int id) {
			return dmd_get_enum_value_float32(dmd, enum_g, id);
		}
		double getEnumValueFloat64(int enum_g, int id) {
			return dmd_get_enum_value_float64(dmd, enum_g, id);
		}
		int getEnumRange(int enum_g, int id) {
			return dmd_get_enum_range(dmd, enum_g, id);
		}
		bool isEnumMask(int enum_g, int id) {
			return dmd_is_enum_mask(dmd, enum_g, id);
		}
		bool isEnumHidden(int enum_g, int id) {
			return dmd_is_enum_hidden(dmd, enum_g, id);
		}
		bool isEnumDeprecated(int enum_g, int id) {
			return dmd_is_enum_deprecated(dmd, enum_g, id);
		}
		bool isRegisterEnumAvailable(int enum_id, int typ, int idx, int sidx) {
			return dmd_is_register_enum_available(dmd, enum_id, typ, idx, sidx);
		}
		bool isSubindexEnumAvailable(int enum_id, int typ, int idx) {
			return dmd_is_subindex_enum_available(dmd, enum_id, typ, idx);
		}
		bool isParameterEnumAvailable(int enum_id, int idx, int par) {
			return dmd_is_parameter_enum_available(dmd, enum_id, idx, par);
		}
	};
	#undef ERRCHK
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * display modes - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdDisplay {
	public:
		enum { NORMAL = 1 };                             /* normal informations */
		enum { TEMPERATURE = 2 };                        /* drive temperature */
		enum { ENCODER = 4 };                            /* analog encoder signals */
		enum { SEQUENCE = 8 };                           /* sequence line number */
		enum { DC_VOLTAGE = 32 };                        /* DC voltage */
	};
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * drive error codes - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdDrvError {
	public:
	    enum {ADVANCED_FILTER_BAD_SETTING = 32 };      
    enum {AUT_TIMEOUT = 156 };                     
    enum {BAD_FW_VERSION = 43 };                   
    enum {BAD_REG_IDX = 38 };                      
    enum {BAD_SEQ_LABEL = 36 };                    
    enum {BAD_SEQ_REG_IDX = 401 };                 
    enum {BAD_SEQ_THREAD = 402 };                  
    enum {BAD_TEMPERATURE_SENSOR = 13 };           
    enum {BRIDGE_ERROR = 131 };                    
    enum {BRIDGE_OVERCUR1 = 135 };                 
    enum {BRIDGE_OVERCUR2 = 136 };                 
    enum {CFG_EXT1_ERROR = 211 };                  
    enum {CFG_EXT2_ERROR = 212 };                  
    enum {CFG_EXT3_ERROR = 213 };                  
    enum {CHUNK_ERROR = 207 };                     
    enum {CHUNK_OVERRUN = 201 };                   
    enum {CMD_BAD_PARAM = 70 };                    
    enum {CYCLIC_DATA_ERROR = 202 };               
    enum {DFC_CFG_ERROR = 47 };                    
    enum {DIGITAL_HALL_WRONG_VALUE = 191 };        
    enum {DIPSWITCH_CFG_ERROR = 57 };              
    enum {DOUT_CFG_ERROR = 45 };                   
    enum {DOUT_FUSE_BROKEN = 14 };                 
    enum {DWN_UPL_ERROR = 206 };                   
    enum {ENCODER_AMPLITUDE = 20 };                
    enum {ENCODER_FUSE_KO = 35 };                  
    enum {ENCODER_POSITION_LOST = 21 };            
    enum {ENCODER2_AMPLITUDE = 22 };               
    enum {ENDAT_BAD_CRC = 18 };                    
    enum {ENDAT_BAD_READ = 19 };                   
    enum {ENDAT_ENCODER_ERROR = 31 };              
    enum {ENDAT_OVERFLOW = 16 };                   
    enum {ENDAT_POS_LOST = 17 };                   
    enum {ENDAT_TIMEOUT = 27 };                    
    enum {ERR_COMMAND_ERROR = 116 };               
    enum {ETHERNET_LOST = 49 };                    
    enum {F2F_ERRORS = 100 };                      
    enum {FDOUT_CFG_ERROR = 42 };                  
    enum {FPGA_CLK = 104 };                        
    enum {FPGA_INIT = 105 };                       
    enum {FPGA_OSCILLATOR = 103 };                 
    enum {FPGA_OVER_VOLTAGES = 102 };              
    enum {FPGA_WATCHDOG = 101 };                   
    enum {FUNCTION_NOT_IMPLEMENTED = 44 };         
    enum {GANTRY_BAD_CMD = 121 };                  
    enum {GANTRY_DIFF_PARAMETER = 122 };           
    enum {GANTRY_ERROR = 118 };                    
    enum {GANTRY_HOME_OFFSET_DIFF = 124 };         
    enum {GANTRY_NO_SLAVE_SEQUENCE = 123 };        
    enum {GANTRY_POWERON_ERROR = 120 };            
    enum {GANTRY_TRACKING_ERROR = 119 };           
    enum {HOMING_MECH_STOP = 64 };                 
    enum {HOMING_NOT_DONE = 71 };                  
    enum {HOMING_NOT_POSSIBLE = 69 };              
    enum {HOMING_SWITCH_PRESENT = 60 };            
    enum {I2T = 11 };                              
    enum {I2T_OVER_CURRENT = 4 };                  
    enum {INIT_HIGH_CUR = 154 };                   
    enum {INIT_LOW_CUR = 153 };                    
    enum {INIT_LOW_TIME = 155 };                   
    enum {INIT_MOTOR_1 = 150 };                    
    enum {INIT_MOTOR_2 = 151 };                    
    enum {INIT_MOTOR_DISABLED = 152 };             
    enum {K79_BAD_VALUE = 40 };                    
    enum {K89_BAD_VALUE = 41 };                    
    enum {KEEP_ALIVE_TIMEOUT = 55 };               
    enum {LEAK_OVERCURRENT = 130 };                
    enum {LIMIT_SWITCH = 30 };                     
    enum {LINEAR_AMPLI_ERROR = 137 };              
    enum {LINEAR_OVERCUR1 = 138 };                 
    enum {LINEAR_OVERCUR2 = 139 };                 
    enum {LINEAR_OVERCUR3 = 140 };                 
    enum {LOAD_OVERCUR1 = 133 };                   
    enum {LOAD_OVERCUR2 = 134 };                   
    enum {MASTER_POWER_OFF = 67 };                 
    enum {MON_VOLTAGE = 15 };                      
    enum {MULTIPLE_INDEX = 61 };                   
    enum {OPTIONAL_BOARD_FLASH_CORRUPTED = 99 };   
    enum {OUT_OF_STROKE = 65 };                    
    enum {OVER_CURRENT_1 = 2 };                    
    enum {OVER_CURRENT_3 = 3 };                    
    enum {OVER_OFFSET = 10 };                      
    enum {OVER_SPEED = 24 };                       
    enum {OVER_TEMPERATURE = 5 };                  
    enum {OVER_VOLTAGE = 6 };                      
    enum {OVERTEMP_ERROR = 29 };                   
    enum {PHASING_BAD_INIT = 157 };                
    enum {POWER_MULTI_AXIS_CONFIG = 125 };         
    enum {POWER_MULTI_OTHER_AXIS_ERROR = 126 };    
    enum {POWER_MULTI_OTHER_AXIS_POWER_OFF = 127 };
    enum {POWER_ON = 26 };                         
    enum {POWER_SUPPLY_INRUSH = 7 };               
    enum {PWR_ON_DRV_CFG_ERROR = 72 };             
    enum {PWR_ON_IN_ITP_MODE = 68 };               
    enum {REF_OUT_OF_STROKE = 66 };                
    enum {SAFETY_RELAY_POWER_ON = 132 };           
    enum {SAG_POWER = 25 };                        
    enum {SAV_COMMAND = 190 };                     
    enum {SCALE_MAPPING_CFG_ERROR = 74 };          
    enum {SEQ_BAD_CMD_PARAM = 405 };               
    enum {SEQ_BAD_NODE = 407 };                    
    enum {SEQ_BAD_REGISTER = 406 };                
    enum {SEQ_THREAD_RUNNING = 403 };              
    enum {SEQ_ZERO_DIVISION = 404 };               
    enum {SEQUENCE_ERROR_0408 = 408 };             
    enum {SINGLE_INDEX = 62 };                     
    enum {SLOT_CFG_ERROR = 58 };                   
    enum {STAGE_MAPPING_BAD_PARAM = 76 };          
    enum {STAGE_MAPPING_ERROR = 75 };              
    enum {STAGE_MAPPING_STEP_CFG_ERROR = 77 };     
    enum {STAGE_PROT_INIT_ERROR = 210 };           
    enum {STAGE_PROT_OTHER_AXIS = 214 };           
    enum {STAGE_PROT_SETTING = 215 };              
    enum {STREAM_BUFFER = 204 };                   
    enum {STREAM_OVERRUN = 200 };                  
    enum {STREAM_WRITE = 203 };                    
    enum {STRETCH_CFG_ERROR = 73 };                
    enum {SYNCHRO_START = 63 };                    
    enum {TCP_INPUT_BUFFER_FULL = 51 };            
    enum {TCP_OUTPUT_BUFFER_FULL = 50 };           
    enum {TRACKING_ERROR = 23 };                   
    enum {TRANSNET_ETCOM_BAD_SIZE = 85 };          
    enum {TRANSNET_ETCOM_BUFFER_OVERFLOW = 84 };   
    enum {TRANSNET_REF_MODE_CFG_ERROR = 59 };      
    enum {TRANSNET_TIMEOUT = 56 };                 
    enum {TRIGGER_CFG_ERROR = 46 };                
    enum {UNDEFINED_SEQ_LABEL = 400 };             
    enum {UNDER_VOLTAGE = 9 };                     
    enum {USB_CHECKSUM_ERROR = 86 };               
    enum {USB_INPUT_BUFFER_FULL = 87 };            
    enum {WD_POSITION_FPGA = 141 };                
    enum {WD_QUARTZ = 144 };                       


	};
#endif /* DMD_OO_API */



/*------------------------------------------------------------------------------
 * kind of encoder - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdEncoder {
	public:
		enum { ANALOG = 0};								/* analog encoder */
		enum { TTL = 1};					           	/* TTL encoder */
		enum { TTL_HF = 2};								/* TTL High frequency encoder */
		enum { ENDAT_22 = 3};							/* ENDAT 2.2 encoder */
		enum { ENDAT_21 = 4};							/* ENDAT 2.1 encoder */
	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * homing modes - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdHoming {
	public:
		enum { MECHANICAL = 0 };                         /* mechanical end stop */
		enum { NEGATIVE_MVT = 1 };                       /* negative movement */
		enum { HOME_SW = 2 };                            /* home switch */
		enum { LIMIT_SW = 4 };                           /* limit switch */
		enum { HOME_SW_L = 6 };                          /* home switch w/limit */
		enum { SINGLE_INDEX = 8 };                       /* single index */
		enum { SINGLE_INDEX_L = 10 };                    /* single index w/limit */
		enum { MULTI_INDEX = 12 };                       /* multi-index */
		enum { MULTI_INDEX_L = 14 };                     /* multi-index w/limit */
		enum { GATED_INDEX = 16 };                       /* single index and DIN2 */
		enum { GATED_INDEX_L = 18 };                     /* single index and DIN2 w/limit */
		enum { MULTI_INDEX_DS = 20 };                    /* multi-index w/defined stroke */
		enum { IMMEDIATE = 22 };                         /* immediate */
		enum { SINGLE_INDEX_DS = 24 };                   /* single index w/defined stroke */
	};
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * init modes - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdInitMode {
	public:
		enum { NONE = 0 };                               /* none */
		enum { PULSE = 1 };                              /* current pulses */
		enum { CONTINOUS = 2 };                          /* continous current */
		enum { HALL_UNTIL_INDEX = 3 };                   /* digital hall sensor until index */
		enum { HALL_UNTIL_EDGE = 4 };                    /* digital hall sensor until edge */
		enum { HALL = 5 };                               /* digital hall sensor */
		enum { SMALL_MVT = 6 };                          /* Small movements phasing */
		enum { SMALL_MVT_REPEAT = 7 };                   /* Small movements phasing repeat 3 times */
	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * drive mode - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdDrvMode {
	public:
		enum { FORCE_REFERENCE = 0 };                    /* force reference */
		enum { POSITION_PROFILE = 1 };                   /* position profile */
		enum { SPEED_REFERENCE = 3 };                    /* speed reference */
		enum { POSITION_REFERENCE = 4 };                 /* position reference */
		enum { POSITION_REFERENCE_2 = 36 };              /* position reference */
		enum { DMD_MODE_PULSE_DIRECTION_TTL_2 = 38 };    /* pulse direction TTL*/
		};
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * motor phases - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdPwmMode {
	public:
		enum { PHASES_1 = 10 };                          /* 1 phase motor */
		enum { PHASE_1_LOW_SWITCHING = 11 };             /* 1 phase motor with low switching freq */
		enum { PHASES_2 = 20 };                          /* 2 phase motor */
		enum { PHASE_2_LOW_SWITCHING = 21 };             /* 2 phase motor with low switching freq. */
		enum { PHASES_3 = 30 };                          /* 3 phase motor */
		enum { PHASE_3_LOW_SWITCHING = 31 };             /* 3 phase motor with low switching freq. */
		enum { PHASE_3_VLOW_SWITCHING = 34 };            /* 3 phase motor with very low switching freq. */
	};
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * types of movement - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdMovement {
	public:
		enum { TRAPEZIODAL = 0 };                        /* trapezoidal movement */
		enum { S_CURVE = 1 };                            /* S-curve movement */
		enum { STEP = 5 };                            	 /* Step movement */
		enum { LKT_LINEAR = 10 };                        /* LKT movement linear */
		enum { SCURVE_ROTARY = 17 };                     /* S-curve rotary movement */
		enum { INFINITE_ROTARY = 24 };                   /* infinite rotary movement */
		enum { LKT_ROTARY = 26 };                        /* LKT rotary movement */
	};
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * drive products - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdDrvProduct {
	public:
		enum { ACCURET = 32 };                           /* AccurET drive */
		enum { ACCURET_48V = 33 };                       /* AccurET 48V drive */
		enum { ACCURET_300V = 34 };                      /* AccurET 300V drive */
		enum { ACCURET_DFC = 35 };                       /* AccurET DFC drive */
		enum { ACCURET_VHP = 36 };                       /* AccurET VHP drive */
		enum { ACCURET_MAGLEV = 37 };                    /* AccurET MAGLEV drive */
		enum { ULTIMET = 48 };                           /* UltimET multi-axis controller */
		enum { ULTIMET_TCPIP = 49 };                     /* UltimET multi-axis controller */
	};
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * extension card products - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdExtProduct {
	public:
		enum { ACCURET_OPTIONAL_IO_BOARD = 64 };	     /* AccurET Optional IO board*/
	};
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * source type - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdTyp {
	public:
		enum { BASIS_MASK		= 0x1F};			 /* mask applied on a byte representing a type to obtain the type basis */
		enum { FLOAT_BIT_MASK	= 0x20};			 /* mask applied on a byte representing a type to obtain the float bit */
		enum { L64_BIT_MASK		= 0x40};			 /* mask applied on a byte representing a type to obtain the 64 bit */
		enum { NONE				= 0 };		         /* no type */
		enum { IMMEDIATE		= 0 };		         /* disabled or immediate value */
		enum { USER             = 1 };				 /* user registers */
		enum { PPK              = 2 };		         /* drive parameters */
		enum { MONITOR          = 3 };	             /* monitoring registers */
		enum { IMMEDIATE_HDWORD	= 4 };		         /* immediate 64 bits value HIGH double-word*/
#ifndef TRACE
		enum { TRACE            = 6 };		         /* trace buffer */
#endif
		enum { ETRACE            = 6 };		         /* trace buffer */
		enum { ADDRESS          = 7 };		         /* address value */
		enum { LKT              = 8 };	             /* movement lookup tables */
		enum { TRIGGER          = 9 };               /* triggers buffer */
		enum { Y		        = 11};		         /* Y type variables */
		enum { COMMON           = 13};               /* common register */
		enum { MAPPING          = 14};               /* P mapping register */

		enum { IMMEDIATE_INT32			= IMMEDIATE	};												/* immediate integer 32 bits */
		enum { IMMEDIATE_INT64			= IMMEDIATE | L64_BIT_MASK };							/* immediate integer 64 bits */
		enum { IMMEDIATE_FLOAT32		= IMMEDIATE | FLOAT_BIT_MASK };							/* immediate float 32 bits */
		enum { IMMEDIATE_FLOAT64		= IMMEDIATE | FLOAT_BIT_MASK | L64_BIT_MASK };		/* immediate float 64 bits */
		enum { IMMEDIATE_INT64_LDWORD	= IMMEDIATE_INT64 };										/* immediate integer 64 bits low double word*/
		enum { IMMEDIATE_INT64_HDWORD	= IMMEDIATE_INT64 | IMMEDIATE_HDWORD };				/* immediate integer 64 bits high double word*/
		enum { IMMEDIATE_FLOAT64_LDWORD	= IMMEDIATE_FLOAT64 };										/* immediate integer 64 bits low double word*/
		enum { IMMEDIATE_FLOAT64_HDWORD	= IMMEDIATE_FLOAT64 | IMMEDIATE_HDWORD };			/* immediate integer 64 bits high double word*/

		enum { USER_INT32				= USER };													/* user register integer 32 bits */
		enum { USER_INT64				= USER | L64_BIT_MASK };									/* user register integer 64 bits */
		enum { USER_FLOAT32				= USER | FLOAT_BIT_MASK };								/* user register float 32 bits */
		enum { USER_FLOAT64				= USER | FLOAT_BIT_MASK | L64_BIT_MASK };			/* user register float 64 bits */

		enum { PPK_INT32				= PPK };													/* drive parameters integer 32 bits */
		enum { PPK_INT64				= PPK | L64_BIT_MASK };									/* drive parameters integer 64 bits */
		enum { PPK_FLOAT32				= PPK | FLOAT_BIT_MASK };								/* drive parameters float 32 bits */
		enum { PPK_FLOAT64				= PPK | FLOAT_BIT_MASK | L64_BIT_MASK };				/* drive parameters float 64 bits */

		enum { MONITOR_INT32			= MONITOR };												/* monitoring registers integer 32 bits */
		enum { MONITOR_INT64			= MONITOR | L64_BIT_MASK };								/* monitoring registers integer 64 bits */
		enum { MONITOR_FLOAT32			= MONITOR | FLOAT_BIT_MASK };							/* monitoring registers float 32 bits */
		enum { MONITOR_FLOAT64			= MONITOR | FLOAT_BIT_MASK | L64_BIT_MASK };			/* monitoring registers float 64 bits */

		enum { TRACE_INT32				= ETRACE };													/* trace buffer integer 32 bits */
		enum { TRACE_INT64				= ETRACE | L64_BIT_MASK };								/* trace buffer integer 64 bits */
		enum { TRACE_FLOAT32			= ETRACE | FLOAT_BIT_MASK };								/* trace buffer float 32 bits */
		enum { TRACE_FLOAT64			= ETRACE | FLOAT_BIT_MASK | L64_BIT_MASK };			/* trace buffer float 64 bits */

		enum { LKT_FLOAT64              = LKT | FLOAT_BIT_MASK | L64_BIT_MASK};		/* lookup table float 64 bits */

		enum { TRIGGER_INT64            = TRIGGER | L64_BIT_MASK};				    /* trigger buffer integer 64 bits */

		enum { Y_INT32					= Y };														/* Y type variables integer 32 bits */
		enum { Y_INT64					= Y | L64_BIT_MASK };									/* Y type variables integer 64 bits */
		enum { Y_FLOAT32				= Y | FLOAT_BIT_MASK };									/* Y type variables float 32 bits */
		enum { Y_FLOAT64				= Y | FLOAT_BIT_MASK | L64_BIT_MASK };				/* Y type variables float 64 bits */

		enum { COMMON_INT32				= COMMON };														/* Common type variables integer 32 bits */
		enum { COMMON_INT64				= COMMON | L64_BIT_MASK };									/* Common type variables integer 64 bits */
		enum { COMMON_FLOAT32			= COMMON | FLOAT_BIT_MASK };									/* Common type variables float 32 bits */
		enum { COMMON_FLOAT64			= COMMON | FLOAT_BIT_MASK | L64_BIT_MASK };				/* Common type variables float 64 bits */

		enum { MAPPING_INT32			= MAPPING };														/* P Mapping integer 32 bits */

		enum { INCREMENT_INT32			= 0 };								/* increment typ integer 32 bits */
		enum { INCREMENT_INT64			= L64_BIT_MASK };					/* increment typ integer 64 bits */
		enum { INCREMENT_FLOAT32		= FLOAT_BIT_MASK };						/* increment typ float 32 bits */
		enum { INCREMENT_FLOAT64		= L64_BIT_MASK | FLOAT_BIT_MASK };		/* increment typ float 64 bits bits */
	};
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * status drive 1 - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdStatus1 {
	public:
		enum { POWER_ON 	= 0x000001 };						/* power on */
		enum { PRESENT 		= 0x000008 };                       /* present */
		enum { MOVING 		= 0x000010 };                       /* moving */
		enum { IN_WINDOW 	= 0x000020 };                       /* in window */
		enum { WAITING 		= 0x000080 };                       /* driver is waiting */
		enum { EXEC_SEQ 	= 0x000100 };                       /* sequence execution */
		enum { ERROR_ANY 	= 0x000400 };                       /* global error */
		enum { TRACE_BUSY 	= 0x000800 };                      	/* trace busy */
		enum { WARNING 		= 0x800000 };                      	/* warning */
	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * status drive 2 - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdStatus2 {
	public:
		enum { BP_WAITING 	= 0x00000010 };                     /* break point waiting */
		enum { USER_0 		= 0x00000100 };                     /* user bit 0 */
		enum { USER_1 		= 0x00000200 };                     /* user bit 1 */
		enum { USER_2 		= 0x00000400 };                     /* user bit 2 */
		enum { USER_3 		= 0x00000800 };                     /* user bit 3 */
		enum { USER_4 		= 0x00001000 };                     /* user bit 4 */
		enum { USER_5 		= 0x00002000 };                     /* user bit 5 */
		enum { USER_6 		= 0x00004000 };                     /* user bit 6 */
		enum { USER_7 		= 0x00008000 };                     /* user bit 7 */
		enum { USER_BYTE 	= 0x0000FF00 };                 	/* user mask */
	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * reboot option - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdShutdown {
	public:
		enum { MAGIC = 255 };                            /* magic number */

	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * setpoint buffer mask - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdSetpoint {
	public:
		enum { TARGET_POSITION = 1 };                    /* target position */
		enum { PROFILE_VELOCITY = 2 };                   /* profile velocity */
		enum { PROFILE_ACCELERATION = 4 };               /* profile acceleration */
		enum { JERK_FILTER_TIME = 8 };                   /* jerk filter time */
		enum { PROFILE_DECELERATION = 16 };              /* profile deceleration */
		enum { END_VELOCITY = 32 };                      /* end velocity */
		enum { PROFILE_TYPE = 64 };                      /* profile type */
		enum { MVT_LKT_NUMBER = 128 };                   /* lookup table number */
		enum { MVT_LKT_TIME = 256 };                     /* lookup table time */
		enum { MVT_LKT_AMPLITUDE = 512 };                /* movement lookup table amplitude */
		enum { MVT_DIRECTION = 1024 };                   /* movement direction */
	};
#endif /* DMD_OO_API */


/*------------------------------------------------------------------------------
 * rotary movement direction - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdMovementDir {
	public:
		enum { POSITIVE = 0 };                           /* positive movement */
		enum { NEGATIVE = 1 };                           /* negative movement */
		enum { SHORTEST = 2 };                           /* shortest movement */

	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * concatenated mode - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdConcatMode {
	public:
		enum { DISABLED = 0 };                           /* concatened movement disabled */
		enum { ENABLED = 1 };                            /* concatened movement enabled */
		enum { LKT_ONLY = 2 };                           /* concatened movement enabled for LKT */

	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * SLS selection mode - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdSlsMode {
	public:
		enum { NEGATIVE_MVT = 1 };                       /* begin by negative movement */
		enum { MECHANICAL = 0 };                         /* mechanical end stop */
		enum { LIMIT_SW = 2 };                           /* limit switch */

	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * trace buffer - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdTrace {
	public:
		enum { BUFFER_0 = 0 };                           /* buffer 0 */
		enum { BUFFER_1 = 1 };                           /* buffer 1 */
		enum { BUFFER_2 = 2 };                           /* buffer 2 */
		enum { BUFFER_3 = 3 };                           /* buffer 3 */

	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * Dmd Commands Numbers - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdCommands {
		/*
		 * public constants
		 */
	public:
	    enum { ADD_REGISTER = 91 };                      /* Adds register */
    enum { AND_NOT_REGISTER = 97 };                  /* AND NOT register */
    enum { AND_REGISTER = 95 };                      /* AND register */
    enum { AUTO_CONFIG_CL = 150 };                   /* Auto config current loop */
    enum { CALL_SUBROUTINE = 68 };                   /* Calls subroutine */
    enum { CHANGE_AXIS = 109 };                      /* Changes axis */
    enum { CHANGE_POWER = 124 };                     /* Changes power */
    enum { CLEAR_CALL_STACK = 34 };                  /* Clears call stack */
    enum { CLEAR_USER_VAR = 17 };                    /* Clears all user registers */
    enum { CONV_REGISTER = 122 };                    /* Converts between int and float */
    enum { DBG_SEQ_EXIT_DEBUG = 143 };               /* Sequence Debugger: Set breakpoint sensitive thread */
    enum { DBG_SEQ_BRKP_AT = 141 };                  /* Sequence Debugger: Set breakpoint enabled */
    enum { DBG_SEQ_BRKP_EVERYWHERE = 142 };          /* Sequence Debugger: Exit sequence debug. */
    enum { DBG_SEQ_CONTINUE = 140 };                 /* Sequence Debugger: Continue sequence execution after break point. */
    enum { DIVIDE_REGISTER = 94 };                   /* Divides register */
    enum { DRIVE_NEW = 78 };                         /* Controller new */
    enum { DRIVE_RESTORE = 49 };                     /* Controller restore */
    enum { DRIVE_SAVE = 48 };                        /* Controller save */
    enum { EIOMAXURST = 755 };                       /* Reset observed max. time between IO updates */
    enum { EIOSTA = 750 };                           /* Start external IO read/write cycle */
    enum { EIOWDEN = 720 };                          /* Enable/disable external IO watchdog */
    enum { EIOWDSTP = 721 };                         /* Stop the external IO watchdog */
    enum { EIOWDTIME = 722 };                        /* Set the external IO watchdog timeout */
    enum { ENABLE_DISABLE_M_TRIGGER = 103 };         /* Command enable trigger function when axis is moving. <P1> Table start line (E registres). <P2> Table number of line (E registers). */
    enum { ENABLE_DISABLE_TRIGGER = 104 };           /* Command enable trigger function when axis isn't moving. <P1> Table start line (E registres). <P2> Table number of line (E registers). */
    enum { ENTER_DOWNLOAD = 42 };                    /* Enter download mode */
    enum { GETDINS = 738 };                          /* Get actual value of a specified digital local input */
    enum { GETDOUT = 735 };                          /* Get the value of a specified digital local output */
    enum { GETEAINCS = 746 };                        /* Ext. IO: get actual conv. value of a specified AIN */
    enum { GETEAINRS = 745 };                        /* Ext. IO: get actual raw value of a specified AIN */
    enum { GETEAOUTC = 741 };                        /* Ext. IO: get set conv. value of a specified AOUT */
    enum { GETEAOUTCS = 743 };                       /* Ext. IO: get actual conv. val. of a specified AOUT */
    enum { GETEAOUTR = 740 };                        /* Ext. IO: get set raw value of a specified AOUT */
    enum { GETEAOUTRS = 742 };                       /* Ext. IO: get actual raw value of a specified AOUT */
    enum { GETEDINS = 765 };                         /* Ext. IO: get the actual value of a specified DIN */
    enum { GETEDOUT = 760 };                         /* Ext. IO: get set value of a specified DOUT */
    enum { GETEDOUTS = 764 };                        /* Ext. IO: get the actual value of a specified DOUT */
    enum { GETEREG = 726 };                          /* Get a register from the ext. IO system */
    enum { GETMDINS = 734 };                         /* Get masked local inputs */
    enum { GETMDOUT = 732 };                         /* Get masked local outputs */
    enum { GETMEDINS = 758 };                        /* Ext. IO: get masked actual external inputs */
    enum { GETMEDOUT = 757 };                        /* Ext. IO: get masked set external outputs */
    enum { GETMEDOUTS = 766 };                       /* Ext. IO: get masked actual external outputs */
    enum { HARDWARE_RESET = 600 };                   /* Hardware reset */
    enum { HOMING_START = 45 };                      /* Homing start */
    enum { HOMING_SYNCHRONISED = 41 };               /* Synchronized homing */
    enum { IF_EQUAL = 151 };                         /* Jumps if par1 equal XAC */
    enum { IF_GREATER = 154 };                       /* Jumps if par1 greater XAC */
    enum { IF_GREATER_OR_EQUAL = 156 };              /* Jumps if par1 greater or equal XAC */
    enum { IF_LOWER = 153 };                         /* Jumps if par1 lower XAC */
    enum { IF_LOWER_OR_EQUAL = 155 };                /* Jumps if par1 less or equal XAC */
    enum { IF_NOT_EQUAL = 152 };                     /* Jumps if par1 different XAC */
    enum { INI_START = 44 };                         /* Phasing start */
    enum { INIT_TRIGGER_OUTPUT = 106 };              /* Command to initialize the DOUT/FDOUT used by the trigger. <P1> is the state for the DOUT and <P2> is the state for FDOUT */
    enum { INPUT_START_MVT = 33 };                   /* Starts mvt on input */
    enum { INVERT_REGISTER = 174 };                  /* Inverts register */
    enum { IPOL_ABS_COORDS = 556 };                  /* Assigns the coordinates of the current position of the axes */
    enum { IPOL_ABS_MODE = 555 };                    /* Sets (1) or clears (0) the abs ref coordinates mode */
    enum { IPOL_BEGIN = 553 };                       /* Enter to interpolated mode */
    enum { IPOL_BEGIN_CONCATENATION = 1030 };        /* Starts the concatenation */
    enum { IPOL_CIRCLE_CCW_C2D = 1041 };             /* Adds circular segment to trajectory */
    enum { IPOL_CIRCLE_CCW_R2D = 1027 };             /* Adds circular segment to trajectory */
    enum { IPOL_CIRCLE_CW_C2D = 1040 };              /* Adds circular segment to trajectory */
    enum { IPOL_CIRCLE_CW_R2D = 1026 };              /* Adds circular segment to trajectory */
    enum { IPOL_CLEAR_BUFFER = 657 };                /* Clears the ipol command buffer */
    enum { IPOL_CONTINUE = 654 };                    /* Restarts interpolation after a quick stop */
    enum { IPOL_DISABLE_UCONCATENATION = 1052 };     /* Forces to stop before the next universal line */
    enum { IPOL_END = 554 };                         /* Leave the interpolated mode */
    enum { IPOL_END_CONCATENATION = 1031 };          /* Stops the concatenation */
    enum { IPOL_LINE = 1025 };                       /* Adds linear segment to trajectory */
    enum { IPOL_LKT = 1032 };                        /* Adds lkt segment to trajectory */
    enum { IPOL_LOCK = 1044 };                       /* Locks the trajectory execution */
    enum { IPOL_MARK = 1039 };                       /* Puts a mark in the trajectory */
    enum { IPOL_MATRIX_ROTATE = 1056 };              /* Rotates the selected axis plane */
    enum { IPOL_MATRIX_SCALE = 1055 };               /* Scales the selected axes */
    enum { IPOL_MATRIX_SHEAR = 1057 };               /* Shears selected axes */
    enum { IPOL_MATRIX_TRANSLATE = 1054 };           /* Translates the reference frame */
    enum { IPOL_PT = 1045 };                         /* Adds pt segment to trajectory */
    enum { IPOL_PVT = 1028 };                        /* Adds pvt segment to trajectory */
    enum { IPOL_PVT_UPDATE = 662 };                  /* Updates registers for PVT trajectory */
    enum { IPOL_SET = 552 };                         /* Sets the interpolation axis */
    enum { IPOL_STOP_EMCY = 656 };                   /* Stops interpolation emergency */
    enum { IPOL_STOP_SMOOTH = 653 };                 /* Stops interpolation smooth */
    enum { IPOL_TAN_ACCELERATION = 1036 };           /* Adds acceleration modification to trajectory */
    enum { IPOL_TAN_DECELERATION = 1037 };           /* Adds deceleration modification to trajectory */
    enum { IPOL_TAN_JERK_TIME = 1038 };              /* Adds jerk time modification to trajectory */
    enum { IPOL_TAN_VELOCITY = 1035 };               /* Adds speed modification to trajectory */
    enum { IPOL_ULINE = 1033 };                      /* Adds universal linear segment to trajectory */
    enum { IPOL_UNLOCK = 655 };                      /* Unlock the ipol buffer */
    enum { IPOL_URELATIVE = 1051 };                  /* Enables or disables relative mode */
    enum { IPOL_USPEED = 1049 };                     /* Changes speed for universal linear moves */
    enum { IPOL_USPEED_AXISMASK = 1053 };            /* Changes the axis mask for tangential speed */
    enum { IPOL_UTIME = 1050 };                      /* Changes acceleration and jerk time for universal linear moves */
    enum { IPOL_WAIT_TIME = 1029 };                  /* Waits before continue the trajectory */
    enum { JUMP_BIT_CLEAR = 37 };                    /* Jump bit clear */
    enum { JUMP_BIT_SET = 36 };                      /* Jump bit set */
    enum { JUMP_LABEL = 26 };                        /* Jumps to label */
    enum { MAPPING_ASP = 234 };                      /* SET slot address for stage error mapping mode */
    enum { MAPPING_MAM = 199 };                      /* Set all involved axes mask and corrected axes mask */
    enum { MAPPING_MCS = 200 };                      /* Stage error mapping command, set the cyclic stroke of source axes */
    enum { MAPPING_MCT = 193 };                      /* Set config. and table nbr info for stage error mapping */
    enum { MAPPING_MDA = 195 };                      /* Set dimension and axes for stage error mapping */
    enum { MAPPING_MDT = 192 };                      /* Set date and time info for stage error mapping */
    enum { MAPPING_MMO = 194 };                      /* Set correction mode for stage error mapping */
    enum { MAPPING_MSI = 190 };                      /* Set string info for stage error mapping */
    enum { MAPPING_MSR = 196 };                      /* Set mapping source registers for stage error mapping */
    enum { MAPPING_MSV = 191 };                      /* Set version info for stage error mapping */
    enum { MAPPING_MTP = 197 };                      /* Set mapping origin for stage error mapping */
    enum { MAPPING_MTU = 198 };                      /* Set mapping unit factor for stage error mapping */
    enum { MODULO_REGISTER = 101 };                  /* Modulo register */
    enum { MULTIPLY_REGISTER = 93 };                 /* Multiplies register */
    enum { OR_NOT_REGISTER = 98 };                   /* OR NOT register */
    enum { OR_REGISTER = 96 };                       /* OR register */
    enum { PROFILED_MOVE = 60 };                     /* Start movement */
    enum { RCT = 754 };                              /* Resets the client TCP/IP communication */
    enum { RELATIVE_PROFILED_MOVE = 62 };            /* Start relative movement */
    enum { RESET_DRIVE = 88 };                       /* Resets controller */
    enum { RESET_ERROR = 79 };                       /* Resets error */
    enum { RIC = 753 };                              /* Reset IO update cycle count */
    enum { RSTDOUT = 737 };                          /* Reset digital local output */
    enum { RSTEDOUT = 762 };                         /* Reset digital output */
    enum { SEARCH_LIMIT_STROKE = 46 };               /* Searches limit stroke */
    enum { SET_REGISTER = 123 };                     /* Sets register */
    enum { SET_REGISTER_DEPTH = 125 };               /* Set max all depth par1 with value par2 to parx */
    enum { SET_USER_POSITION = 22 };                 /* Sets user position */
    enum { SET_VERSION = 20 };                       /* Set version parameters */
    enum { SETDOUT = 736 };                          /* Set digital local output */
    enum { SETEAOUTC = 731 };                        /* Set analog output in converted format */
    enum { SETEAOUTR = 730 };                        /* Set analog output in raw format */
    enum { SETEDOUT = 761 };                         /* Set digital output */
    enum { SETEREG = 725 };                          /* Set a register of the ext. IO system */
    enum { SETMDOUT = 733 };                         /* Apply a mask on local digital outputs */
    enum { SETMEDOUT = 763 };                        /* Apply a mask on external digital outputs */
    enum { SHIFT_LEFT_REGISTER = 173 };              /* Shift left register */
    enum { SHIFT_RIGHT_REGISTER = 172 };             /* Shift right register */
    enum { START_MVT = 25 };                         /* Starts movement */
    enum { START_STOP_PULSE_GENERATOR = 105 };       /* Start or Stop pulse generator. <P1> pulse generator  (1 or 2). <P2> Start or Stop ( 1 or 0) */
    enum { STEP_ABSOLUTE = 129 };                    /* Absolute step */
    enum { STEP_NEGATIVE = 115 };                    /* Negative step */
    enum { STEP_POSITIVE = 114 };                    /* Positive step */
    enum { STOP_MOTOR_EMCY = 18 };                   /* Emergency stop */
    enum { STOP_MOTOR_SMOOTH = 70 };                 /* Stops motor smoothly */
    enum { STOP_SEQ_MOTOR_EMCY = 120 };              /* Stops seq ipol emergency */
    enum { STOP_SEQ_MOTOR_SMOOTH = 121 };            /* Stops seq stop ipol smooth */
    enum { STOP_SEQ_POWER_OFF = 119 };               /* Stops seq, ipol emergency and disables ipol */
    enum { STOP_SEQUENCE = 0 };                      /* Stops sequence thread */
    enum { SUBROUTINE_RETURN = 69 };                 /* Subroutine return */
    enum { SUBSTRACT_REGISTER = 92 };                /* Substracts register */
    enum { USER_STRETCH = 30 };                      /* User stretch command */
    enum { WAIT_AXIS_BUSY = 13 };                    /* wait end of axis busy */
    enum { WAIT_BIT_CLEAR = 54 };                    /* Wait bit clear */
    enum { WAIT_BIT_SET = 55 };                      /* Wait bit set */
    enum { WAIT_GREATER = 53 };                      /* Wait greater */
    enum { WAIT_IN_WINDOW = 11 };                    /* Waits in window */
    enum { WAIT_LOWER = 52 };                        /* Wait lower */
    enum { WAIT_MARK = 513 };                        /* wait until the movement reach a mark */
    enum { WAIT_MOVEMENT = 8 };                      /* Waits for end of move of specified ipol group */
    enum { WAIT_POSITION = 9 };                      /* Waits for position */
    enum { WAIT_SGN_GREATER = 57 };                  /* Waits for greater signed */
    enum { WAIT_SGN_LOWER = 56 };                    /* Waits for lower signed */
    enum { WAIT_TIME = 10 };                         /* Waits for time */
    enum { XOR_NOT_REGISTER = 100 };                 /* XOR NOT register */
    enum { XOR_REGISTER = 99 };                      /* XOR register */

	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * Dmd Parameters Numbers - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdParameters {
		/*
		 * public constants
		 */
	public:
	    enum { ANALOG_OUTPUT = 107 };                    /* AOUT analog outputs */
    enum { BRAKE_DECELERATION = 206 };               /* Brake deceleration */
    enum { CAME_VALUE = 205 };                       /* Came value */
    enum { CL_CURRENT_LIMIT = 83 };                  /* Current loop overcurrent limit */
    enum { CL_I2T_CURRENT_LIMIT = 84 };              /* I2 motor rms current limit */
    enum { CL_I2T_TIME_LIMIT = 85 };                 /* I2t motor integration limit */
    enum { CL_INTEGRATOR_GAIN = 81 };                /* Current loop integrator gain */
    enum { CL_PROPORTIONAL_GAIN = 80 };              /* Current loop proportional gain */
    enum { CONCATENATED_MVT = 201 };                 /* Concatenated movement */
    enum { CTRL_GAIN = 224 };                        /* External reference gain */
    enum { CTRL_OFFSET = 223 };                      /* External reference offset */
    enum { CTRL_SOURCE_DEPTH = 222 };                /* External reference depth */
    enum { CTRL_SOURCE_INDEX = 221 };                /* External reference index */
    enum { CTRL_SOURCE_TYPE = 220 };                 /* External reference type */
    enum { DIGITAL_OUTPUT = 171 };                   /* Digital outputs */
    enum { DISPLAY_MODE = 66 };                      /* Display mode */
    enum { DRIVE_CONTROL_MODE = 61 };                /* Position reference mode */
    enum { DRIVE_NAME = 3 };                         /* Controller name */
    enum { DRIVE_SLS_MODE = 145 };                   /* Searches limit stroke (SLS) mode */
    enum { ENABLE_INPUT_MODE = 33 };                 /* Enables input mode */
    enum { ENCODER_HALL_PHASE_ADJ = 86 };            /* Digital Hall sensor phase adjustment */
    enum { ENCODER_INDEX_DISTANCE = 75 };            /* Distance between two indexes */
    enum { ENCODER_INVERSION = 68 };                 /* Encoder reading way inversion */
    enum { ENCODER_IPOL_SHIFT = 77 };                /* Encoder interpolation shift value */
    enum { ENCODER_PERIOD = 241 };                   /* Encoder period */
    enum { ENCODER_PHASE_1_FACTOR = 72 };            /* Analog encoder sine factor */
    enum { ENCODER_PHASE_1_OFFSET = 70 };            /* Analog encoder sine offset */
    enum { ENCODER_PHASE_2_FACTOR = 73 };            /* Analog encoder cosine factor */
    enum { ENCODER_PHASE_2_OFFSET = 71 };            /* Analog encoder cosine offset */
    enum { ENCODER_TURN_FACTOR = 55 };               /* Encoder position increment factor */
    enum { ENCODER_TYPE = 79 };                      /* Encoder type */
    enum { FAST_OUTPUT = 5 };                        /* Fast outputs */
    enum { FOLLOWING_ERROR_WINDOW = 30 };            /* Tracking error limit */
    enum { GANTRY_TYPE = 245 };                      /* Gantry  level */
    enum { HOME_OFFSET = 45 };                       /* Offset on absolute position */
    enum { HOMING_ACCELERATION = 42 };               /* Homing acceleration */
    enum { HOMING_CURRENT_LIMIT = 44 };              /* Homing force limit for mech end stop detection */
    enum { HOMING_FINE_TUNING_MODE = 52 };           /* Homing fine tuning mode */
    enum { HOMING_FINE_TUNING_VALUE = 53 };          /* Homing fine tuning value */
    enum { HOMING_FIXED_MVT = 46 };                  /* Homing movement stroke */
    enum { HOMING_FOLLOWING_LIMIT = 43 };            /* Homing track limit for mech end stop detection */
    enum { HOMING_INDEX_MVT = 48 };                  /* Mvt to go out of idx/home switch */
    enum { HOMING_METHOD = 40 };                     /* Homing mode */
    enum { HOMING_SWITCH_MVT = 47 };                 /* Mvt to go out of limit switch or mech end stop */
    enum { HOMING_ZERO_SPEED = 41 };                 /* Homing speed */
    enum { INDIRECT_REGISTER_IDX = 198 };            /* Indirect register index */
    enum { INIT_FINAL_PHASE = 93 };                  /* Phasing final phase */
    enum { INIT_INITIAL_PHASE = 97 };                /* Phasing initial phase */
    enum { INIT_MAX_CURRENT = 92 };                  /* Phasing constant current level */
    enum { INIT_MODE = 90 };                         /* Phasing mode */
    enum { INIT_PULSE_LEVEL = 91 };                  /* Phasing pulse level */
    enum { INIT_TIME = 94 };                         /* Phasing time (K90 = 2) */
    enum { INIT_VOLTAGE_RATE = 98 };                 /* Phasing voltage rate */
    enum { IPOL_CAME_VALUE = 717 };                  /* Interpolation, came value */
    enum { IPOL_LKT_CYCLIC_MODE = 710 };             /* Interpolation, LKT, cyclic mode */
    enum { IPOL_LKT_RELATIVE_MODE = 711 };           /* Interpolation, LKT, relative mode */
    enum { IPOL_LKT_SPEED_RATIO = 700 };             /* Interpolation, LKT, speed ratio of the pointer */
    enum { IPOL_VELOCITY_RATE = 530 };               /* Interpolation, speed rate */
    enum { JERK_FILTER_TIME = 213 };                 /* Jerk time */
    enum { MAX_POSITION_RANGE_LIMIT = 27 };          /* Max position range limit */
    enum { MAX_SOFT_POSITION_LIMIT = 35 };           /* Max software position limit */
    enum { MIN_SOFT_POSITION_LIMIT = 34 };           /* Min software position limit */
    enum { MON_SOURCE_INDEX = 31 };                  /* XAOUT source register index */
    enum { MON_SOURCE_TYPE = 30 };                   /* XAOUT source register type */
    enum { MOTION_AND_CONSIGNE = 78 };               /* Regulator type */
    enum { MOTOR_DIV_FACTOR = 243 };                 /* Position division factor */
    enum { MOTOR_KT_FACTOR = 239 };                  /* Motor Kt factor */
    enum { MOTOR_MUL_FACTOR = 242 };                 /* Position multiplication factor */
    enum { MOTOR_PHASE_CORRECTION = 56 };            /* Motor phase correction */
    enum { MOTOR_PHASE_NB = 89 };                    /* Motor phase number */
    enum { MOTOR_POLE_NB = 54 };                     /* Motor pair pole number */
    enum { MOTOR_TYPE = 240 };                       /* Movement type conversion */
    enum { MVT_DIRECTION = 209 };                    /* Rotary movement type */
    enum { MVT_LKT_AMPLITUDE = 208 };                /* Max stroke for LKT */
    enum { MVT_LKT_NUMBER = 203 };                   /* LKT number movement */
    enum { MVT_LKT_TIME = 204 };                     /* Movement LKT time */
    enum { MVT_LKT_TYPE = 207 };                     /* LKT mode selection */
    enum { PL_ACC_FEEDFORWARD_GAIN = 21 };           /* Position loop acceleration ffwd gain */
    enum { PL_ANTI_WINDUP_GAIN = 5 };                /* Position loop anti-windup gain */
    enum { PL_INTEGRATOR_GAIN = 4 };                 /* Position loop integrator gain */
    enum { PL_INTEGRATOR_LIMITATION = 6 };           /* Position loop integrator limitation */
    enum { PL_INTEGRATOR_MODE = 7 };                 /* Position loop integrator mode */
    enum { PL_PROPORTIONAL_GAIN = 1 };               /* Position loop proportional gain */
    enum { PL_SPEED_FEEDBACK_GAIN = 2 };             /* Position loop speed feedback gain */
    enum { POSITION_WINDOW = 39 };                   /* In-window position */
    enum { POSITION_WINDOW_TIME = 38 };              /* In-window time */
    enum { PROFILE_ACCELERATION = 212 };             /* Absolute max acc/deceleration */
    enum { PROFILE_LIMIT_MODE = 36 };                /* Enables position limit (KL34, KL35) */
    enum { PROFILE_TYPE = 202 };                     /* Movement type */
    enum { PROFILE_VELOCITY = 211 };                 /* Absolute max speed */
    enum { SOFTWARE_CURRENT_LIMIT = 60 };            /* Software force limit */
    enum { SWITCH_LIMIT_MODE = 32 };                 /* Limit switch and home switch inversion */
    enum { SYNCRO_START_TIMEOUT = 164 };             /* Synchro timeout */
    enum { TARGET_POSITION = 210 };                  /* Target position */
    enum { TTL_SPEED_FILTER = 11 };                  /* TTL speed smooth filter */
    enum { UFAI_TEN_POWER = 525 };                   /* Ufai ten power */
    enum { UFPI_MUL_FACTOR = 522 };                  /* Ufpi multiplication factor */
    enum { UFPI_TEN_POWER = 523 };                   /* Ufpi ten power */
    enum { UFSI_TEN_POWER = 524 };                   /* Ufsi ten power */
    enum { UFTI_TEN_POWER = 526 };                   /* Ufti ten power */
    enum { USER_STATUS = 177 };                      /* User status */
    enum { VELOCITY_ERROR_LIMIT = 31 };              /* Speed error limit */
    enum { X_ANALOG_OUTPUT_1 = 7 };                  /* Optional board analog outputs */
    enum { X_DIGITAL_OUTPUT = 6 };                   /* Optional board digital outputs */

	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * Dmd Monitoring Numbers - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdMonitoring {
		/*
		 * public constants
		 */
	public:
	    enum { ACC_DEMAND_VALUE = 14 };                  /* Theoretical acceleration (dai) */
    enum { ANALOG_INPUT = 51 };                      /* Analog input after gain and offset compensation */
    enum { AXIS_NUMBER = 87 };                       /* UltimET axis number */
    enum { CL_ACTUAL_VALUE = 31 };                   /* Real force Iq measured */
    enum { CL_CURRENT_PHASE_1 = 20 };                /* Real current in phase 1 */
    enum { CL_CURRENT_PHASE_2 = 21 };                /* Real current in phase 2 */
    enum { CL_CURRENT_PHASE_3 = 22 };                /* Real current in phase 3 */
    enum { CL_DEMAND_VALUE = 30 };                   /* Theoretical force Iq for current loop */
    enum { CL_I2T_VALUE = 67 };                      /* I2t motor current value */
    enum { CL_LKT_PHASES = 25 };                     /* Phase angle */
    enum { COMMON_FAST_INPUTS = 52 };                /* Common fast inputs */
    enum { DBG_SEQ_NB_BRKP = 67 };                   /* Sequence debugger: Number of breakpoints set */
    enum { DIGITAL_INPUT = 50 };                     /* Digital inputs */
    enum { DIGITAL_OUTPUT_ACTUAL = 171 };            /* Digital outputs */
    enum { DRIVE_CL_INT_ACTUAL_TIME = 190 };         /* Actual time of process on current loop */
    enum { DRIVE_CL_INT_MAX_TIME = 192 };            /* Min time of process on current loop */
    enum { DRIVE_CL_INT_MIN_TIME = 191 };            /* Max time of process on current loop */
    enum { DRIVE_CL_TIME_FACTOR = 243 };             /* Controller current loop time factor */
    enum { DRIVE_DISPLAY = 95 };                     /* Display's string */
    enum { DRIVE_FUSE_STATUS = 140 };                /* Fuse status */
    enum { DRIVE_MAX_CURRENT = 82 };                 /* Controller max current */
    enum { DRIVE_PL_INT_ACTUAL_TIME = 193 };         /* Actual time of process on position loop */
    enum { DRIVE_PL_INT_MAX_TIME = 195 };            /* Min time of process on position loop */
    enum { DRIVE_PL_INT_MIN_TIME = 194 };            /* Max time of process on position loop */
    enum { DRIVE_PL_TIME_FACTOR = 244 };             /* Controller position loop time factor */
    enum { DRIVE_QUARTZ_FREQUENCY = 242 };           /* Controller quartz frequency [Hz] */
    enum { DRIVE_SEQUENCE_LINE = 96 };               /* Current instruction address */
    enum { DRIVE_SP_INT_ACTUAL_TIME = 196 };         /* Actual time of process on manager loop */
    enum { DRIVE_SP_INT_MAX_TIME = 198 };            /* Min time of process on manager loop */
    enum { DRIVE_SP_INT_MIN_TIME = 197 };            /* Max time of process on manager loop */
    enum { DRIVE_SP_TIME_FACTOR = 245 };             /* Controller manager loop time factor */
    enum { DRIVE_STATUS_1 = 60 };                    /* Controller status 1 */
    enum { DRIVE_STATUS_2 = 61 };                    /* Controller status 2 */
    enum { DRIVE_TEMPERATURE = 90 };                 /* Controller temperature */
    enum { ENCODER_1VPTP_VALUE = 43 };               /* Analog encoder sine^2 + cosine^2 */
    enum { ENCODER_COSINE_SIGNAL = 41 };             /* Analog encoder cosine signal after correction */
    enum { ENCODER_HALL_DIG_SIGNAL = 48 };           /* Digital Hall effect sensor */
    enum { ENCODER_IPOL_FACTOR = 241 };              /* Encoder interpolation factor */
    enum { ENCODER_LIMIT_SWITCH = 44 };              /* Encoder limit switch */
    enum { ENCODER_SINE_SIGNAL = 40 };               /* Analog encoder sine signal after correction */
    enum { ERROR_CODE = 64 };                        /* Error code */
    enum { FDOUT_ACTUAL = 172 };                     /* Fast digital outputs */
    enum { INFO_BOOT_REVISION = 71 };                /* Boot version */
    enum { INFO_C_SOFT_BUILD_TIME = 74 };            /* Firmware build time */
    enum { INFO_P_SOFT_BUILD_TIME = 75 };            /* FPGA built time */
    enum { INFO_PRODUCT_NUMBER = 70 };               /* Product type */
    enum { INFO_PRODUCT_STRING = 85 };               /* Article number */
    enum { INFO_SERIAL_NUMBER = 73 };                /* Serial number */
    enum { INFO_SOFT_VERSION = 72 };                 /* Firmware version */
    enum { MAX_SLS_POSITION_LIMIT = 37 };            /* Superior position after SLS cmd */
    enum { MIN_SLS_POSITION_LIMIT = 36 };            /* Inferior position after SLS cmd */
    enum { POSITION_ACTUAL_VALUE_DS = 1 };           /* Real position with mapping (dpi) */
    enum { POSITION_ACTUAL_VALUE_US = 7 };           /* Real position */
    enum { POSITION_CTRL_ERROR = 2 };                /* Tracking error */
    enum { POSITION_DEMAND_VALUE_DS = 0 };           /* Theoretical position (dpi) */
    enum { POSITION_DEMAND_VALUE_US = 6 };           /* Theoretical position */
    enum { POSITION_MAX_ERROR = 3 };                 /* Max tracking error */
    enum { TEB_NODE_MASK = 512 };                    /* Present nodes on TransnET */
    enum { VELOCITY_ACTUAL_VALUE = 11 };             /* Real speed after adv filter (dsi) */
    enum { VELOCITY_BEFORE_K8 = 111 };               /* Real speed before adv filter depth 0 (dsi) */
    enum { VELOCITY_DEMAND_VALUE = 10 };             /* Theoretical speed after adv filter (dsi) */
    enum { X_ANALOG_INPUT_1 = 56 };                  /* Optional board analog inputs */
    enum { X_DIGITAL_INPUT = 55 };                   /* Optional board digital inputs */
    enum { X_INFO_PRODUCT_NUMBER = 76 };             /* Optional board product number */

	};
#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * Dmd Convert Numbers - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdConvert {
		/*
		 * public constants
		 */
	public:
	    enum { AVI = 40 };                            /* analog voltage increment 8192 correspond to -10V  -8192 correspond to +10V */
    enum { AVI12BIT = 47 };                       /* analog voltage increment 2048 correspond to -10V  -2048 correspond to +10V */
    enum { AVI16BIT = 48 };                       /* analog voltage increment 32767 correspond to -10V   -32768 correspond to +10V */
    enum { AVI16BITINV = 49 };                    /* analog voltage increment 32767 correspond to 10V   -32768 correspond to -10V */
    enum { BIT0 = 50 };                           /* 2<SUP>0</SUP> = 1 correspond to 1.0 */
    enum { BIT10 = 60 };                          /* 2<SUP>10</SUP> = 1024 correspond to 1.0 */
    enum { BIT11 = 61 };                          /* 2<SUP>11</SUP> = 2048 correspond to 1.0 */
    enum { BIT11_ENCODER = 62 };                  /* Analgog encoder signal amplitude in volt (11 bit) */
    enum { BIT11P2 = 82 };                        /*  */
    enum { BIT15 = 65 };                          /* 2<SUP>15</SUP> = 32768 correspond to 1.0 */
    enum { BIT15_ENCODER = 63 };                  /* Analgog encoder signal amplitude in volt (15 bit) */
    enum { BIT15P2 = 83 };                        /*  */
    enum { BIT24 = 74 };                          /* 2<SUP>24</SUP> = 256*65536 correspond to 1.0 */
    enum { BIT31 = 81 };                          /* 2<SUP>31</SUP> = 32768*65536 correspond to 1.0 */
    enum { BIT5 = 55 };                           /* 2<SUP>5</SUP> = 32 correspond to 1.0 */
    enum { BIT8 = 58 };                           /* 2<SUP>8</SUP> = 256 correspond to 1.0 */
    enum { BIT9 = 59 };                           /* 2<SUP>9</SUP> = 512 correspond to 1.0 */
    enum { BOOL = 1 };                            /* boolean value */
    enum { C13 = 20 };                            /* current 13bit range */
    enum { C14 = 21 };                            /* current 14bit range */
    enum { C29 = 22 };                            /* current 29bit range */
    enum { CLTI = 32 };                           /* current loop time increment (cti) */
    enum { CTI = 32 };                            /* current loop time increment (41us) */
    enum { CTRL_CUR2 = 8 };                       /* Controller i<SUP>2</SUP>t, dissipation value */
    enum { CTRL_CUR2T = 14 };                     /* Controller i<SUP>2</SUP>t, integration value */
    enum { CUR = 24 };                            /* current */
    enum { CUR2 = 25 };                           /* i<SUP>2</SUP>, dissipation value */
    enum { CUR2T = 26 };                          /* i<SUP>2</SUP>t, integration value */
    enum { CUR2T_V2 = 19 };                       /* i<SUP>2</SUP>t, integration value */
    enum { DAI = 17 };                            /* drive acceleration increment */
    enum { DPI = 15 };                            /* drive position increment */
    enum { DPI2 = 18 };                           /* drive position increment for secondary encoder */
    enum { DSI = 16 };                            /* drive speed increment */
    enum { DWORD = 0 };                           /* double word value without conversion */
    enum { ENCOFF = 42 };                         /* 11bit with 2048 offset */
    enum { EXP10 = 33 };                          /* ten power factor */
    enum { FLOAT = 5 };                           /* float value */
    enum { FREF_FCTRL = 121 };                    /* Force ref of force control (conv 1:1) */
    enum { FTI = 31 };                            /* fast time increment (125us-166us) */
    enum { HSTI = 34 };                           /* half slow time increment */
    enum { INT = 2 };                             /* integer value without conversion */
    enum { IP_ADDRESS = 13 };                     /* ip address type */
    enum { K1 = 90 };                             /* pl prop gain, k(A/m) = k1 * Iref * dpi_factor / 2<SUP>29</SUP> */
    enum { K10 = 100 };                           /* 1st order filter in s. */
    enum { K1031 = 125 };                         /* per cent unit, 3133 correspond to 1.0 or 100% */
    enum { K14 = 3 };                             /*  */
    enum { K2 = 92 };                             /* pl speed feedback gain, k(A/(m/s)) = k2 * Iref * dsi_factor / 2<SUP>29</SUP> */
    enum { K20 = 103 };                           /* speed feedback, sec unit (m/(m/s)), F = k20 / 2<SUP>16-k50</SUP> * dsi_factor / dpi_factor */
    enum { K20_DSB = 102 };                       /* speed feedback, sec unit (m/(m/s)), F = k20 / 2<SUP>16-k50</SUP> * dsi_factor / dpi_factor */
    enum { K21 = 105 };                           /* speed feedback, sec unit (m/(m/s<SUP>2</SUP>)), F = k20 / 2<SUP>24-k50</SUP> * dai_factor / dpi_factor */
    enum { K21_DSB = 104 };                       /* speed feedback, sec unit (m/(m/s<SUP>2</SUP>)), F = k20 / 2<SUP>24-k50</SUP> * dai_factor / dpi_factor */
    enum { K23 = 106 };                           /* commutation phase advance period/(period*second/m) */
    enum { K23_ACCURET = 107 };                   /* commutation phase advance period/(Volt*second/m) */
    enum { K239 = 124 };                          /* motor Kt factor in mN(m)/A, 1000 correspond to 1.0mN(m)/A */
    enum { K4 = 94 };                             /* pl integrator gain, k(A/(m*s)) = k1 * Iref * dpi_factor / 2<SUP>29</SUP> / pl_time */
    enum { K5 = 96 };                             /* anti-windup K[m/A]=K5*4096/(dpi_factor * Iref) */
    enum { K75 = 108 };                           /* encoder multiple index distance, 1/1024 * encoder perion unit */
    enum { K8 = 3 };                              /*  */
    enum { K80 = 110 };                           /* cl prop gain delta[1/A] */
    enum { K80_VHP = 109 };                       /* cl prop gain delta[V/A] */
    enum { K81 = 112 };                           /* cl prop integrator delta[1/(A*s)] */
    enum { K81_VHP = 111 };                       /* cl prop gain delta[V/(A*s)] */
    enum { K82 = 114 };                           /* filter time, T = [cti] * (2<SUP>n</SUP>-1) */
    enum { K9 = 98 };                             /* 1st order filter in pl */
    enum { K94 = 116 };                           /* time in 2x current loop increment */
    enum { K95 = 118 };                           /* current rate for k95 */
    enum { K96 = 120 };                           /* phase rate for k96 */
    enum { KF22 = 113 };                          /* jerk feedforward */
    enum { KF256 = 127 };                         /* Kt/M for Init small movement 2 */
    enum { KFLOAT = 6 };                          /* float value for K parameters */
    enum { KIF_FCTRL = 115 };                     /* Integrator gain for the force loop */
    enum { KPF_FCTRL = 117 };                     /* Proportional gain for the force loop */
    enum { KT_MOTOR = 119 };                      /* KT motor */
    enum { LONG = 3 };                            /* long integer value without conversion */
    enum { M16 = 101 };                           /* jerk value */
    enum { M242 = 35 };                           /* quartz frequency in Hz */
    enum { M29 = 7 };                             /* per cent unit, 100% correspond to value of M229 */
    enum { M82 = 28 };                            /* current limit in 10 mA unit, 100 correspond to 1.0A */
    enum { MF89 = 99 };                           /* Magnetic period for Init small movement 2 */
    enum { MLTI = 30 };                           /* manager loop time increment (sti) */
    enum { MSEC = 88 };                           /* milliseconds */
    enum { PER_100 = 122 };                       /* per cent unit, 100 correspond to 1.0 */
    enum { PER_1000 = 123 };                      /* per thousand unit */
    enum { PH11 = 44 };                           /* 2<SUP>11</SUP> = 2048 correspond to 360° */
    enum { PH12 = 45 };                           /* 2<SUP>12</SUP> = 4096 correspond to 360° */
    enum { PH28 = 46 };                           /* 2<SUP>28</SUP> = 65536*4096 correspond to 360° */
    enum { PLTI = 31 };                           /* position loop time increment (fti) */
    enum { POLE_FREQ = 27 };                      /* filter pole frequency in Herz */
    enum { QZTIME = 36 };                         /* interrupt time in sec = inc / m242 */
    enum { SPEC2F = 37 };                         /* filter time, T = [fti] * (2<SUP>n</SUP>-1) */
    enum { STI = 30 };                            /* slow time increment (500us-2ms) */
    enum { STRING = 4 };                          /* packed string value */
    enum { TEMP = 38 };                           /* 2<SUP>0</SUP> = 1 correspond to 1.0 */
    enum { TTI = 126 };                           /* Minimum time base TransnET (25us) */
    enum { UAI = 12 };                            /* acceleration, user acceleration increment */
    enum { UFAI = 87 };                           /* user friendly acceleration increment */
    enum { UFPI = 85 };                           /* user friendly position increment */
    enum { UFSI = 86 };                           /* user friendly speed increment */
    enum { UFTI = 39 };                           /* user friendly time increment */
    enum { UPI = 10 };                            /* user position increment */
    enum { UPI2 = 9 };                            /* user position increment dual encodeur mode */
    enum { USI = 11 };                            /* user speed increment */
    enum { VOLT = 41 };                           /* 2<SUP>0</SUP> = 1 correspond to 1.0 */
    enum { VOLT100 = 43 };                        /* (2<SUP>0</SUP>)/100 = 1 correspond to 1.0 */

	};
	#endif /* DMD_OO_API */

/*------------------------------------------------------------------------------
 * Dmd Family Numbers - c++
 *-----------------------------------------------------------------------------*/
#ifdef DMD_OO_API
	class DmdFamily {
		/*
		 * public constants
		 */
	public:
    enum { UNDEFINED = 0 };                  /* UNDEFINED family */
    enum { ACCURET = 3 };                    /* ACCURET family */

	};
	#endif /* DMD_OO_API */

#endif /* _DMD40_H */
