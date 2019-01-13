/*
 * dsa40.h
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
 * This header file contains public declarations for the high level library.\n
 * This library allows access to ETEL hardware like drives, UltimET, etc...\n
 * Once connected, it is possible to get and set registers, executing command
 * and different functions on the hardware itself.\n
 * This library is conformed to POSIX 1003.1c 
 * @file dsa40.h
 */

#ifndef _DSA40_H
#define _DSA40_H


/**********************************************************************************************************/
/*- LIBRARIES */
/**********************************************************************************************************/

/*----------------------*/
/* common libraries		*/
#include <stdio.h>
#include <stddef.h>
#include <stdarg.h>
#include <time.h>
#include <string.h>
#ifdef WIN32
	//modif michel 
	//#if _MSC_VER > 1400
	#if _MSC_VER >= 1900
		#include <stdint.h>
	#else
		typedef unsigned int uint32_t;
	#endif
#endif
#if defined __cplusplus && !defined LINUX
	#include <typeinfo.h>
#endif
#ifdef POSIX
	#include <stdint.h>
#endif

#if defined __cplusplus && defined DSA_OO_API
	#define DMD_OO_API
#endif
#include <dmd40.h>

/**
 * @defgroup DSAAll DSA All functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAAcquisition DSA Acquisition
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSACommunicationAndConfiguration DSA Communication and configuration
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAControllerStatus DSA Controller status
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSADeviceHandling DSA Device handling functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAErrorsAndWarnings DSA Errors and warnings
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAFeedback DSA Feedback
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAGenericFunctions DSA Generic functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAInitialisationAndIndexation DSA Initialisation and indexation
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAInterpolation DSA Interpolation functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAMotorAndCommutation DSA Motor and commutation
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAOptionalBoard DSA Optional board
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSARegulation DSA Regulation
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSASafetyAndProtection DSA Safety and protection
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSASaveAndRestore DSA Save and restore functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSASequenceHandling DSA Sequence handling
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSASetPointGenerator DSA Set point generator
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSATrace DSA Trace
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSATriggerRTIAndIO DSA Trigger, RTI and IO
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAUtils DSA Utility functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAWaitFunctions DSA Wait functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAGate DSA Gate functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSARTV DSA Realtime Value access functions (AccurET family)
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSARTVSLOT DSA RTV slots internal access functions (AccurET family)
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAMap DSA Mapping download and upload functions (AccurET family)
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSAIO DSA IO management functions (UltimET)
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSASystemConfiguration DSA System Configuration management functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup DSADebugSequence DSA Debug Sequences functions
 */
/*@{*/
/*@}*/

/**
 * @example acquisition.c
 */
/**
 * @example compiler.c
 */
 /**
 * @example offline_compiler.c
 */
/**
 * @example sample_1.c
 */
/**
 * @example sample_2.c
 */
/**
 * @example sample_3.c
 */
/**
 * @example sample_4.c
 */
/**
 * @example sample_5.c
 */
/**
 * @example io1.c
 */
/**
 * @example mapping1.c
 */
/**
 * @example scaling1.c
 */
/**
 * @example rtv1.c
 */
/**
 * @example rtv2.c
 */
/**
 * @example rtv3.c
 */
/**
 * @example stream.c
 */
/**
 * @example ultimet_1.c
 */
/**
 * @example ultimet_2.c
 */
/**
 * @example umeg.c
 */



/**********************************************************************************************************/
/*- LITTERALS */
/**********************************************************************************************************/

#ifdef __WIN32__		/* defined by Borland C++ Builder */
	#ifndef WIN32
		#define WIN32
	#endif
#endif

#ifdef __cplusplus
	#ifdef ETEL_OO_API      /* defined by the user when he need the Object Oriented interface */
		#define DSA_OO_API
	#endif
#endif

#ifdef __cplusplus
	extern "C" {
#endif

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

/*------------------------------------------------------------------------------
 * Number of axis
 *-----------------------------------------------------------------------------*/
#ifdef WIN32
	#define DSA_ETCOM_DRIVES 64
#endif
#ifdef POSIX
	#define DSA_ETCOM_DRIVES 64
#endif /* POSIX */
#ifdef VXWORKS
	#define DSA_ETCOM_DRIVES 64
#endif /* VXWORKS */

/*------------------------------------------------------------------------------
 * flags
 *-----------------------------------------------------------------------------*/
#define DSA_FLAG_DISABLE_ISO_CONV   0x00000002  /**< disable all request of drv unit informations */

/*------------------------------------------------------------------------------
 * error codes - c
 *-----------------------------------------------------------------------------*/
#define DSA_EEQUATION                    -340        /**< Equation cannot be resolved */
#define DSA_ECFGCOMPFILE                 -339        /**< File has been compiled for a different axes configuration */
#define DSA_EBADSEQVERSION               -338        /**< the sequence version is not correct */
#define DSA_EACQDEVINUSE                 -337        /**< One of the device is already doing an acquisition */
#define DSA_EACQNOTPOSSIBLE              -336        /**< Drives must be connected with transnet */
#define DSA_EMAPNOTACTIVATED             -335        /**< Mapping cannot be activated by the device */
#define DSA_ESYNTAX                      -334        /**< Mapping file syntax error */
#define DSA_EBADLIBRARY                  -333        /**< function of external library not found */
#define DSA_ENOLIBRARY                   -332        /**< external library not found */
#define DSA_ERTVREADSYNCRO               -331        /**< RTV read synchronisation error */
#define DSA_ENOFREESLOT                  -330        /**< no free slot available */
#define DSA_EOBSOLETE                    -329        /**< function is obsolete */
#define DSA_EBADDRIVER                   -328        /**< wrong version of the installed device driver */
#define DSA_EBADIPOLGRP                  -327        /**< the ipol group is not correctly defined */
#define DSA_ENOTIMPLEMENTED              -326        /**< the specified operation is not implemented */
#define DSA_EBADDRVVER                   -325        /**< a drive with a bad version has been detected */
#define DSA_EBADSTATE                    -324        /**< this operation is not allowed in this state */
#define DSA_EDRVFAILED                   -323        /**< the drive does not operate properly */
#define DSA_EBADPARAM                    -322        /**< one of the parameter is not valid */
#define DSA_EOPENPORT                    -321        /**< the specified port cannot be open */
#define DSA_ENODRIVE                     -320        /**< the specified drive does not respond */
#define DSA_ECANCEL                      -319        /**< the transaction has been canceled */
#define DSA_ETRANS                       -318        /**< a transaction error has occured */
#define DSA_ECONVERT                     -317        /**< a parameter exceeded the permitted range */
#define DSA_EINTERNAL                    -316        /**< some internal error in the etel software */
#define DSA_ESYSTEM                      -315        /**< some system resource return an error */
#define DSA_EBUSRESET                    -314        /**< the underlaying etel-bus in performing a reset operation */
#define DSA_EBUSERROR                    -313        /**< the underlaying etel-bus is not working fine */
#define DSA_ENOACK                       -312        /**< no acknowledge from the drive */
#define DSA_EDRVERROR                    -311        /**< drive in error */
#define DSA_ETIMEOUT                     -310        /**< a timeout has occured */



/*------------------------------------------------------------------------------
 * convert special value / macro
 *-----------------------------------------------------------------------------*/
#ifndef DSA_OO_API
	#define DSA_CONV_AUTO                    (-1)        /**< try to use the conversion appropriate for this operation */
#endif

/*------------------------------------------------------------------------------
 * timeout special values
 *-----------------------------------------------------------------------------*/
#ifndef INFINITE
	#define INFINITE                         0xFFFFFFFF  /**< infinite timeout */
#endif
#ifndef DSA_OO_API
	#define DSA_DEF_TIMEOUT                  (-2L)       /**< use the default timeout appropriate for this communication */
#endif

/*------------------------------------------------------------------------------
 * register kind of access
 *-----------------------------------------------------------------------------*/
#ifndef DSA_OO_API
	#define DSA_GET_CURRENT                  0           /**< get current value, bypass pending commands */
	#define DSA_GET_CONV_FACTOR              10          /**< get the conversion factor */
	#define DSA_GET_MIN_VALUE                11          /**< get the minimum value */
	#define DSA_GET_MAX_VALUE                12          /**< get the maximum value */
	#define DSA_GET_DEF_VALUE                13          /**< get the default value */
#endif /* DSA_OO_API */


/*------------------------------------------------------------------------------
 * STA-STI flags
 *-----------------------------------------------------------------------------*/
#ifndef DSA_OO_API
	#define DSA_STA_POS                           0x01   /**< get the KL210 specified depth as position for the next move*/
	#define DSA_STA_SPD                           0x02   /**< get the KL211 specified depth as speed for the next move*/
	#define DSA_STA_ACC                           0x04   /**< get the KL212 specified depth as acceleration for the next move*/
	#define DSA_STA_JRK                           0x08   /**< get the K213 specified depth as jerk for the next move*/
#endif /* DSA_OO_API */

/*------------------------------------------------------------------------------
 * parameters enumeration values - c
 *-----------------------------------------------------------------------------*/
#ifndef DSA_OO_API
	#define DSA_CTRL_ENABLE_AUTO             170         /**< enable signal perform automatic power on of the drive */
	#define DSA_CTRL_ENABLE_NOT_USED         125         /**< enable signal not used */
	#define DSA_CTRL_ENABLE_USED             0           /**< enable signal is necessary to power on ths drive */
	#define DSA_CTRL_FORCE_REFERENCE         0           /**< driver controlled by a force reference */
	#define DSA_CTRL_HOME_INVERTED           2           /**< home switch is inverted */
	#define DSA_CTRL_HOME_SWITCH			 128         /**< home switch is used */
	#define DSA_CTRL_LIMIT_SWITCH            1           /**< limit switch are used */
	#define DSA_CTRL_POSITION_PROFILE        1           /**< standard position profile mode */
	#define DSA_CTRL_POSITION_REFERENCE      4           /**< driver controlled by a position reference */
	#define DSA_CTRL_PULSE_DIRECTION         5           /**< pulse and direction mode */
	#define DSA_CTRL_PULSE_DIRECTION_TTL     6           /**< pulse and direction mode with TTL encoder */
	#define DSA_CTRL_REGEN_LIMITED           2           /**< regeneration of, max 10s */
	#define DSA_CTRL_REGEN_OFF               0           /**< no regeneration */
	#define DSA_CTRL_REGEN_ON                3           /**< regeneration always on */
	#define DSA_CTRL_SOURCE_MONITORING       3           /**< monitoring of a monitoring register */
	#define DSA_CTRL_SOURCE_PARAMETER        2           /**< monitoring of a parameter */
	#define DSA_CTRL_SOURCE_USER_VARIABLE    1           /**< monitoring of a user variable */
	#define DSA_CTRL_SPEED_REFERENCE         3           /**< driver controlled by a speed reference */
	#define DSA_DRIVE_DISPLAY_ENCODER_SIGNAL 4           /**< display encoder's signals */
	#define DSA_DRIVE_DISPLAY_NORMAL         1           /**< display normal informations */
	#define DSA_DRIVE_DISPLAY_SEQUENCE       8           /**< display sequence line number */
	#define DSA_DRIVE_DISPLAY_TEMPERATURE    2           /**< display drive's temperature */
	#define DSA_HOMING_GATED_INDEX_NEG       17          /*  */
	#define DSA_HOMING_GATED_INDEX_NEG_L     19          /*  */
	#define DSA_HOMING_GATED_INDEX_POS       16          /*  */
	#define DSA_HOMING_GATED_INDEX_POS_L     18          /*  */
	#define DSA_HOMING_HOME_SW_NEG           3           /*  */
	#define DSA_HOMING_HOME_SW_NEG_L         7           /*  */
	#define DSA_HOMING_HOME_SW_POS           2           /*  */
	#define DSA_HOMING_HOME_SW_POS_L         6           /*  */
	#define DSA_HOMING_LIMIT_SW_NEG          5           /*  */
	#define DSA_HOMING_LIMIT_SW_POS          4           /*  */
	#define DSA_HOMING_MECHANICAL_NEG        1           /*  */
	#define DSA_HOMING_MECHANICAL_POS        0           /*  */
	#define DSA_HOMING_MULTI_INDEX_NEG       13          /*  */
	#define DSA_HOMING_MULTI_INDEX_NEG_L     15          /*  */
	#define DSA_HOMING_MULTI_INDEX_POS       12          /*  */
	#define DSA_HOMING_MULTI_INDEX_POS_L     14          /*  */
	#define DSA_HOMING_SINGLE_INDEX_NEG      9           /*  */
	#define DSA_HOMING_SINGLE_INDEX_NEG_L    11          /*  */
	#define DSA_HOMING_SINGLE_INDEX_POS      8           /*  */
	#define DSA_HOMING_SINGLE_INDEX_POS_L    10          /*  */
	#define DSA_INIT_CONTINUOUS_CURRENT      2           /**< initialisation by sending continous to the motor */
	#define DSA_INIT_CURRENT_PULSE           1           /**< initialisation with current pulses */
	#define DSA_INIT_NO_INIT                 0           /**< no initialisation */
	#define DSA_MON_SOURCE_MONITORING        3           /**< monitoring of a monitoring register */
	#define DSA_MON_SOURCE_OFF               0           /**< no real time monitoring */
	#define DSA_MON_SOURCE_PARAMETER         2           /**< monitoring of a parameter */
	#define DSA_MON_SOURCE_USER_VARIABLE     1           /**< monitoring of a user variable */
	#define DSA_MOTOR_INVERT_FORCE           2           /**< invert current force of the motor */
	#define DSA_MOTOR_INVERT_PHASES          1           /**< invert phases 1 and 2 of the motor */
	#define DSA_PARAM_DEFAULT_ALL            0           /**< restore all informations from ROM default */
	#define DSA_PARAM_DEFAULT_SEQ_LKT        1           /**< restore sequence and user lookup-tables from ROM default */
	#define DSA_PARAM_DEFAULT_K_C_PARAMS     2           /**< restore K, and KL, KF, KD, C, CL, CF CD if any, parameters from ROM default */
	#define DSA_PARAM_DEFAULT_K_RESET_E_PARAMS 3         /**< restore K, KL, KF, KD parameters from ROM default, reset EL parameters*/
	#define DSA_PARAM_DEFAULT_C_PARAMS       4           /**< restore C, CL, CF, CD parameters from ROM default */
	#define DSA_PARAM_DEFAULT_X_PARAMS		 5           /**< reset X, XL, XF, XD parameters */
	#define DSA_PARAM_DEFAULT_L_PARAMS		 6           /**< reset LD parameters */
	#define DSA_PARAM_DEFAULT_SEQUENCES		 7           /**< reset sequences */
	#define DSA_PARAM_DEFAULT_E_PARAMS		 8           /**< reset E parameters */
	#define DSA_PARAM_DEFAULT_P_PARAMS		 9           /**< reset P parameters */
	#define DSA_PARAM_LOAD_ALL               0           /**< load all informations from flash memory */
	#define DSA_PARAM_LOAD_SEQ_LKT           1           /**< load sequence and user lookup-tables from flash memory */
	#define DSA_PARAM_LOAD_K_C_E_X_PARAMS    2           /**< load K, KL, KF, KD, C, CL, CF, CD, EL, X, XL, XF, XD parameters from flash memory */
	#define DSA_PARAM_LOAD_K_PARAMS			 3           /**< load K, KL, KF, KD parameters from flash memory */
	#define DSA_PARAM_LOAD_C_PARAMS			 4           /**< load C, CL, CF, CD parameters from flash memory */
	#define DSA_PARAM_LOAD_X_PARAMS			 5           /**< load X, XL, XF, XD parameters from flash memory */
	#define DSA_PARAM_LOAD_L_PARAMS			 6           /**< load LD parameters from flash memory */
	#define DSA_PARAM_LOAD_SEQUENCES		 7           /**< load sequences from flash memory */
	#define DSA_PARAM_LOAD_E_PARAMS			 8           /**< load EL parameters from flash memory */
	#define DSA_PARAM_LOAD_P_PARAMS			 9           /**< load P parameters from flash memory */
	#define DSA_PARAM_SAVE_ALL               0           /**< save all informations in flash memory */
	#define DSA_PARAM_SAVE_SEQ_LKT           1           /**< save sequence and user lookup-tables in flash memory */
	#define DSA_PARAM_SAVE_K_C_E_X_PARAMS    2           /**< save K, KL, KF, KD, C, CL, CF, CD, EL, X, XL, XF, XD parameters in flash memory */
	#define DSA_PARAM_SAVE_K_PARAMS			 3           /**< save K, KL, KF, KD parameters in flash memory */
	#define DSA_PARAM_SAVE_C_PARAMS			 4           /**< save C, CL, CF, CD parameters in flash memory */
	#define DSA_PARAM_SAVE_X_PARAMS			 5           /**< save X, XL, XF, XD parameters in flash memory */
	#define DSA_PARAM_SAVE_L_PARAMS			 6           /**< save LD parameters in flash memory */
	#define DSA_PARAM_SAVE_SEQUENCES		 7           /**< save sequences in flash memory */
	#define DSA_PARAM_SAVE_K_E_PARAMS		 8           /**< save K, KL, KF, KD, EL parameters in flash memory */
	#define DSA_PARAM_SAVE_P_PARAMS			 9           /**< save P parameters in flash memory */
	#define DSA_PARAM_K_PARAMS				 3			 /**< refers to K, KL, KF, KD parameters (AccurET-family: SAV, RES, NEW, STV)*/
	#define DSA_PARAM_C_PARAMS				 4           /**< refers to C, CL, CF, CD parameters (AccurET-family: SAV, RES, NEW, STV)*/
	#define DSA_PARAM_X_PARAMS				 5           /**< refers to X, XL, XF, XD parameters (AccurET-family: SAV, RES, NEW, STV)*/
	#define DSA_PARAM_L_PARAMS				 6           /**< refers to LD parameters (AccurET-family: SAV, RES, NEW, STV)*/
	#define DSA_PARAM_SEQUENCES				 7           /**< refers to sequences (AccurET-family: SAV, RES, NEW, STV)*/
	#define DSA_PARAM_K_E_PARAMS			 8           /**< refers to K, KL, KF, KD, EL parameters (AccurET-family: SAV, RES, NEW, STV)*/
	#define DSA_PARAM_P_PARAMS				 9           /**< refers to P parameters (AccurET-family: SAV, RES, NEW, STV)*/

	#define DSA_PL_INTEGRATOR_IN_POSITION    1           /**< integrator off during motion */
	#define DSA_PL_INTEGRATOR_OFF            2           /**< integrator always off */
	#define DSA_PL_INTEGRATOR_ON             0           /**< integrator always on */
	#define DSA_PROFILE_TRAPEZIODAL_MVT      0           /**< trapezoidal motion (jerk = infinite) (obsolete DSB) */
	#define DSA_PROFILE_S_CURVE_MVT          1           /**< s-curve motion */
	#define DSA_PROFILE_RECTANGULAR_MVT      2           /**< trapezoidal motion (jerk = 0, acc = infinite) (obsolete DSB) */
	#define DSA_PROFILE_PREDEFINED_PROFILE_MVT			3    /**< predefined profile motion (DSC family only) */
	#define DSA_PROFILE_SLOW_LKT_MVT         10          /**< lookup-table motion in profile interrupt (DSC family only)*/
	#define DSA_PROFILE_FAST_LKT_MVT         11          /**< lookup-table motion in controller interrupt (DSC family only)*/
	#define DSA_PROFILE_ROTARY_S_CURVE_MVT   17          /**< rotary s-curve motion */
	#define DSA_PROFILE_ROTARY_PREDEFINED_PROFILE_MVT	19    /**< rotary predefined profile motion (DSC family only) */
	#define DSA_PROFILE_INFINITE_ROTARY_MVT  24          /**< infinite rotary motion */
	#define DSA_PROFILE_ROTARY_LKT_MVT		 26          /**< rotary lookup-table motion (DSC family only)*/
	#define DSA_QS_BYPASS                    2           /**< bypass all pending command */
	#define DSA_QS_INFINITE_DEC              1           /**< stop motor with infinite deceleration (step) */
	#define DSA_QS_POWER_OFF                 0           /**< switch off power bridge */
	#define DSA_QS_PROGRAMMED_DEC            2           /**< stop motor with programmed deceleration */
	#define DSA_QS_STOP_SEQUENCE             1           /**< also stop the sequence */
	#define DSA_ROTATION_PLAN_XT             2           /**< rotation of the XTheta plan */
	#define DSA_ROTATION_PLAN_XY             0           /**< rotation of the XY plan */
	#define DSA_ROTATION_PLAN_XZ             1           /**< rotation of the XZ plan */
	#define DSA_ROTATION_PLAN_YT             4           /**< rotation of the YT plan */
	#define DSA_ROTATION_PLAN_YZ             3           /**< rotation of the YZ plan */
	#define DSA_ROTATION_PLAN_ZT             5           /**< rotation of the ZT plan */
	#define DSA_SYSTEM_ANALOG                0           /**< analog sine/cosine encoder */
	#define DSA_SYSTEM_HALL                  2           /**< HALL effect encoder */
	#define DSA_SYSTEM_TTL                   1           /**< TTL encoder */
#endif /* DSA_OO_API */

/*------------------------------------------------------------------------------
 * acquisition constants - c
 *-----------------------------------------------------------------------------*/
#ifndef DSA_OO_API
	#define DSA_ACQUISITION_TRIG_IMMEDIATE      0           /**< trig immediately */
	#define DSA_ACQUISITION_TRIG_START_MOVE     1           /**< trig on move start */
	#define DSA_ACQUISITION_TRIG_END_MOVE       2           /**< trig on move end */
	#define DSA_ACQUISITION_TRIG_POSITION       3           /**< trig on position level crossed */
	#define DSA_ACQUISITION_TRIG_TRACE          4           /**< trig on trace level crossed */
	#define DSA_ACQUISITION_TRIG_EXTERNAL       5           /**< external trig */
	#define DSA_ACQUISITION_TRIG_REGISTER       6           /**< trig on given value of register */
	#define DSA_ACQUISITION_TRIG_BIT_FIELD_STATE	7       /**< trig on bit field state */
	#define DSA_ACQUISITION_TRIG_BIT_FIELD_EDGE		8       /**< trig on bit field riging or falling edge */

	#define DSA_ACQUISITION_SYNCHRO_MODE_NONE           0   /**< each device will have its own time rate, given time and number of point will be respected */
	#define DSA_ACQUISITION_SYNCHRO_MODE_COMMON_STI     1   /**< a common time rate is choosen for all device, only given number of point will be respected */
	#define DSA_ACQUISITION_SYNCHRO_MODE_MIN_STI        2   /**< the time rate of the fastest device is choosen as reference, only given number of point will be respected */

	#define DSA_ACQUISITION_UPLOAD_MODE_AVOID_FAST      1   /**< no traces will be uploaded as fast */

	#define DSA_ACQUISITION_FALLING_EDGE				-1  /**< trig on falling edge */
	#define DSA_ACQUISITION_BOTH_EDGE					0  /**< trig on falling and rising edge */
	#define DSA_ACQUISITION_RISING_EDGE					1  /**< trig on rising edge */
#endif /* DSA_OO_API */

/*------------------------------------------------------------------------------
 * gate definitions
 *-----------------------------------------------------------------------------*/
#ifndef DSA_OO_API
	#define DSA_GATE_COMET_ID                0           /**< id of ComET Application */
	#define DSA_GATE_USER_ID_1			     1           /**< id of User Application 1 */
	#define DSA_GATE_USER_ID_2			     2           /**< id of User Application 2 */
	#define DSA_GATE_USER_ID_3			     3           /**< id of User Application 3 */
	#define DSA_GATE_USER_MAX			     3           /**< max application */

	#define DSA_GATE_TYPE_NORMAL             0           /**< Normal gate */
	#define DSA_GATE_TYPE_SEQUENTIAL         1           /**< ^Sequential gate */

#endif /* DSA_OO_API */

/*------------------------------------------------------------------------------
 * scaling mode definitions
 *-----------------------------------------------------------------------------*/
#ifndef DSA_OO_API
	#define DSA_SCALE_MAPPING_MODE_ZERO_EDGE	1	     /**< 0 will be add at each ends of the scaling area */
	#define DSA_SCALE_MAPPING_MODE_SPLINE		2	     /**< the points defined in scaling area will be splined */
#endif /* DSA_OO_API */

/*------------------------------------------------------------------------------
 * system configuration backup type definitions
 *-----------------------------------------------------------------------------*/
#ifndef DSA_OO_API
	#define DSA_SYSTEM_CONFIGURATION_BINARY 0				/**< Backup binary blocks */
	#define DSA_SYSTEM_CONFIGURATION_TXT 1					/**< Backup text files (Will be available in the future) */
#endif /* DSA_OO_API */

/*------------------------------------------------------------------------------
 * scaling activation definitions
 *-----------------------------------------------------------------------------*/
#ifndef DSA_OO_API
	#define DSA_SCALE_MAPPING_LINEAR_ACTIVATION	0	     /**< Activation of linear scale-mapping */
	#define DSA_SCALE_MAPPING_CYCLIC_ACTIVATION	1	     /**< Activation of cyclic scale-mapping */
#endif /* DSA_OO_API */

/**********************************************************************************************************/
/*- MACROS */
/**********************************************************************************************************/

#ifdef WIN32
	#define DSA_IMPL_A
	#define DSA_IMPL_S
	#define DSA_IMPL_G
#endif /* WIN32 */

#ifdef POSIX
	#define DSA_IMPL_A
	#define DSA_IMPL_S
	#define DSA_IMPL_G
#endif /* POSIX */

#ifdef VXWORKS
	#define DSA_IMPL_A
	#define DSA_IMPL_S
	#define DSA_IMPL_G
#endif /* VXWORKS */

/*------------------------------------------------------------------------------
 * conversion macros
 *-----------------------------------------------------------------------------*/
#define DSA_REG_CONV(typ, idx, sidx)     (0x10000000 + ((typ)<<20) + ((sidx)<<16) + (idx))
#define DSA_PPK_CONV(idx, sidx)          (0x10200000 + ((sidx)<<16) + (idx))
#define DSA_KL_CONV(idx, sidx)           (0x14200000 + ((sidx)<<16) + (idx))
#define DSA_KF_CONV(idx, sidx)           (0x12200000 + ((sidx)<<16) + (idx))
#define DSA_KD_CONV(idx, sidx)           (0x16200000 + ((sidx)<<16) + (idx))
#define DSA_MON_CONV(idx, sidx)          (0x10300000 + ((sidx)<<16) + (idx))
#define DSA_ML_CONV(idx, sidx)           (0x14300000 + ((sidx)<<16) + (idx))
#define DSA_MF_CONV(idx, sidx)           (0x12300000 + ((sidx)<<16) + (idx))
#define DSA_MD_CONV(idx, sidx)           (0x16300000 + ((sidx)<<16) + (idx))
#define DSA_C_CONV(idx, sidx)            (0x10D00000 + ((sidx)<<16) + (idx))
#define DSA_CL_CONV(idx, sidx)           (0x14D00000 + ((sidx)<<16) + (idx))
#define DSA_CF_CONV(idx, sidx)           (0x12D00000 + ((sidx)<<16) + (idx))
#define DSA_CD_CONV(idx, sidx)           (0x16D00000 + ((sidx)<<16) + (idx))

#define DSA_CMD_CONV(typ, idx, par)      (0x20000000 + ((typ)<<20) + ((par)<<16) + (idx))

#define DSA_GET_CONV_KIND(code)          (((unsigned)(code)) >> 28)
#define DSA_GET_CONV_TYP(code)           (((code) >> 20) & 0xFFU)
#define DSA_GET_CONV_IDX(code)           ((code) & 0xFFFFUL)
#define DSA_GET_CONV_PAR(code)           (((code) >> 16) & 0xFFU)
#define DSA_GET_CONV_SIDX(code)          (((code) >> 16) & 0xFU)

/*------------------------------------------------------------------------------
 * diagnostic macros
 *-----------------------------------------------------------------------------*/
#define DSA_DIAG(err, dev)                      (dsa_diag(__FILE__, __LINE__, err, dev))
#define DSA_SDIAG(str, err, dev)                (dsa_sdiag(str, __FILE__, __LINE__, err, dev))
#define DSA_FDIAG(output_file_name, err, dev)   (dsa_fdiag(output_file_name, __FILE__, __LINE__, err, dev))

#define DSA_EXT_DIAG(err, dev)                      (dsa_ext_diag(__FILE__, __LINE__, err, dev))
#define DSA_EXT_SDIAG(size, str, err, dev)          (dsa_ext_sdiag(size, str, __FILE__, __LINE__, err, dev))
#define DSA_EXT_FDIAG(output_file_name, err, dev)   (dsa_ext_fdiag(output_file_name, __FILE__, __LINE__, err, dev))

/**********************************************************************************************************/
/*- TYPES */
/**********************************************************************************************************/

/*------------------------------------------------------------------------------
 * type modifiers
 *-----------------------------------------------------------------------------*/
/*------------------------------*/
/* WINDOWS type modifiers		*/
#ifdef WIN32
	#define _DSA_EXPORT __cdecl                          /* function exported by static library */
	#define DSA_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* WIN32 */

/*------------------------------*/
/* POSIX type modifiers			*/
#ifdef POSIX
	#define _DSA_EXPORT                           /* function exported by library */
	#define DSA_CALLBACK                          /* client callback function called by library */
#endif /* POSIX */

/*------------------------------*/
/* VXWORKS type modifiers		*/
#ifdef VXWORKS
	#define _DSA_EXPORT                           /* function exported by library */
	#define DSA_CALLBACK                          /* client callback function called by library */
#endif /* VXWORKS */

/*------------------------------------------------------------------------------
 * hidden structures for library clients
 *-----------------------------------------------------------------------------*/
#ifndef ETB
	#define ETB void
	struct EtbBus { ETB *etb; };
#endif
#ifndef DMD
	#define DMD void
	struct DmdData { DMD *dmd; };
#endif
#ifndef DSA_DEVICE_BASE
	#define DSA_DEVICE_BASE void
#endif
#ifndef DSA_DEVICE
	#define DSA_DEVICE void
#endif
#ifndef DSA_DEVICE_GROUP
	#define DSA_DEVICE_GROUP void
#endif
#ifndef DSA_DRIVE_BASE
	#define DSA_DRIVE_BASE void
#endif
#ifndef DSA_DRIVE
	#define DSA_DRIVE void
#endif
#ifndef DSA_DRIVE_GROUP
	#define DSA_DRIVE_GROUP void
#endif
#ifndef DSA_GANTRY
	#define DSA_GANTRY void
#endif
#ifndef DSA_MASTER_BASE
	#define DSA_MASTER_BASE void
#endif
#ifndef DSA_MASTER
	#define DSA_MASTER void
#endif
#ifndef DSA_MASTER_GROUP
	#define DSA_MASTER_GROUP void
#endif
#ifndef DSA_DSMAX_BASE
	#define DSA_DSMAX_BASE void
#endif
#ifndef DSA_DSMAX
	#define DSA_DSMAX void
#endif
#ifndef DSA_DSMAX_GROUP
	#define DSA_DSMAX_GROUP void
#endif
#ifndef DSA_IPOL_GROUP
	#define DSA_IPOL_GROUP void
#endif
#ifndef DSA_ACQUISITION
	#define DSA_ACQUISITION void
#endif
#ifndef DSA_RTV_SLOT
	#define DSA_RTV_SLOT void
#endif
#ifndef DSA_RTV_DATA
	#define DSA_RTV_DATA void
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


/*------------------------------------------------------------------------------
 * DSA_SW1 type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DSA_SW1
 * Etel bus drive status word 1 when acces through M60.\n
 * It can be used when status is accessed using function dsa_get_status_from_drive, 
 * because this function redas M60 and M61 of the drive.\n
 * Otherwise, this structure is obsolete and kept kept to backwards compatibility only (obsolete DSA and DSB)\n
 * EDI internal status update works now with M63. See DsaStatusDriveBitMode structure
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
	typedef struct DSA_SW1 {
		#ifndef DSA_OO_API
			unsigned power_on:1;                         /**< Drive: The power is applied to the motor, Master: not relevant*/
			unsigned init_done:1;                        /**< Drive: The initialisation procedure has been done, Master: not relevant*/
			unsigned homing_done:1;                      /**< Drive: The homing procedure has been done, Master: not relevant*/
			unsigned present:1;                          /**< Drive, Master: The device is present*/
			unsigned moving:1;                           /**< Drive: The motor is moving, Master: One of the ipol group is moving*/
			unsigned in_window:1;                        /**< Drive: The motor is the target windows, Master: not relevant*/
			unsigned :1;
			unsigned :1;
			unsigned exec_seq:1;                         /**< Drive, Master: A sequence is running*/
			unsigned in_speed_window:1;                  /**< Drive: The drive is in speed-window, Master: not relevant*/
			unsigned fatal:1;                            /**< Drive, Master: Fatal error*/
			unsigned trace_busy:1;                       /**< Drive, Master: The aquisition of the trace is not finished*/
			unsigned ipol_grp0:1;                        /**< Master: The ipol gropup 0 is moving*/
			unsigned ipol_grp1:1;                        /**< Master: The ipol gropup 1 is moving*/
			unsigned :1;		                         
			unsigned exec_seq_thread:1;                  /**< Drive, Master: The defined threads are executing */
			unsigned :7;
			unsigned warning:1;                          /**< Drive, Master: Warning mask */
			unsigned :8;
		#else /* DSA_OO_API */
			unsigned powerOn:1;                         /**< Drive: The power is applied to the motor, Master: not relevant*/
			unsigned initDone:1;                        /**< Drive: The initialisation procedure has been done, Master: not relevant*/
			unsigned homingDone:1;                      /**< Drive: The homing procedure has been done, Master: not relevant*/
			unsigned present:1;                         /**< Drive, Master: The device is present*/
			unsigned moving:1;                          /**< Drive: The motor is moving, Master: One of the ipol group is moving*/
			unsigned inWindow:1;                        /**< Drive: The motor is the target windows, Master: not relevant*/
			unsigned :1;
			unsigned :1;
			unsigned execSeq:1;                         /**< Drive, Master: A sequence is running*/
			unsigned inSpeedWindow:1;                   /**< Drive: The drive is in speed-window, Master: not relevant*/
			unsigned fatal:1;                           /**< Drive, Master: Fatal error*/
			unsigned traceBusy:1;                       /**< Drive, Master: The aquisition of the trace is not finished*/
			unsigned ipolGrp0:1;                        /**< Master: The ipol gropup 0 is moving*/
			unsigned ipolGrp1:1;                        /**< Master: The ipol gropup 1 is moving*/
			unsigned :1;		                         
			unsigned execSeqThread:1;                   /**< Drive, Master: The defined threads are executing */
			unsigned :7;
			unsigned warning:1;                         /**< Drive, Master: Warning mask */
			unsigned :8;
		#endif /* DSA_OO_API */
	} DSA_SW1;

#else /*__BYTE_ORDER == __BIG_ENDIAN*/
	typedef struct DSA_SW1 {
		#ifndef DSA_OO_API
			unsigned :8;
			unsigned warning:1;                          /**< Drive, Master: Warning mask */
			unsigned :7;
			unsigned exec_seq_thread:1;                  /**< Drive, Master: The defined threads are executing */
			unsigned :1;		                         
			unsigned ipol_grp1:1;                        /**< Master: The ipol gropup 1 is moving*/
			unsigned ipol_grp0:1;                        /**< Master: The ipol gropup 0 is moving*/
			unsigned trace_busy:1;                       /**< Drive, Master: The aquisition of the trace is not finished*/
			unsigned fatal:1;                            /**< Drive, Master: Fatal error*/
			unsigned in_speed_window:1;                  /**< Drive: The drive is in speed-window, Master: not relevant*/
			unsigned exec_seq:1;                         /**< Drive, Master: A sequence is running*/
			unsigned :1;
			unsigned :1;
			unsigned in_window:1;                        /**< Drive: The motor is the target windows, Master: not relevant*/
			unsigned moving:1;                           /**< Drive: The motor is moving, Master: One of the ipol group is moving*/
			unsigned present:1;                          /**< Drive, Master: The device is present*/
			unsigned homing_done:1;                      /**< Drive: The homing procedure has been done, Master: not relevant*/
			unsigned init_done:1;                        /**< Drive: The initialisation procedure has been done, Master: not relevant*/
			unsigned power_on:1;                         /**< Drive: The power is applied to the motor, Master: not relevant*/
		#else /* DSA_OO_API */
			unsigned :8;
			unsigned warning:1;                          /**< Drive, Master: Warning mask */
			unsigned :7;
			unsigned execSeqThread:1;					 /**< Drive, Master: The defined threads are executing */
			unsigned :1;		                         
			unsigned ipolGrp1:1;                         /**< Master: The ipol gropup 1 is moving*/
			unsigned ipolGrp0:1;                         /**< Master: The ipol gropup 0 is moving*/
			unsigned traceBusy:1;                        /**< Drive, Master: The aquisition of the trace is not finished*/
			unsigned fatal:1;                            /**< Drive, Master: Fatal error*/
			unsigned inSpeedWindow:1;                    /**< Drive: The drive is in speed-window, Master: not relevant*/
			unsigned execSeq:1;                          /**< Drive, Master: A sequence is running*/
			unsigned :1;
			unsigned :1;
			unsigned inWindow:1;                         /**< Drive: The motor is the target windows, Master: not relevant*/
			unsigned moving:1;                           /**< Drive: The motor is moving, Master: One of the ipol group is moving*/
			unsigned present:1;                          /**< Drive, Master: The device is present*/
			unsigned homingDone:1;                       /**< Drive: The homing procedure has been done, Master: not relevant*/
			unsigned initDone:1;                         /**< Drive: The initialisation procedure has been done, Master: not relevant*/
			unsigned powerOn:1;                          /**< Drive: The power is applied to the motor, Master: not relevant*/
		#endif /* DSA_OO_API */
	} DSA_SW1;
#endif /*__BYTE_ORDER*/


/*------------------------------------------------------------------------------
 * DSA_SW2 type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DSA_SW2
 * Etel bus drive status word 2 when acces through M61.\n
 * It can be used when status is accessed using function dsa_get_status_from_drive, 
 * because this function redas M60 and M61 of the drive.\n
 * Otherwise, this structure is obsolete and kept kept to backwards compatibility only (obsolete DSA and DSB)\n
 * EDI internal status update works now with M63. See DsaStatusDriveBitMode structure
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
	typedef struct DSA_SW2 {
		#ifndef DSA_OO_API
			unsigned int_error:1;                       /**< Drive: Error label has been executed, Master: not relevant*/
			unsigned warning:1;                         /**< Drive: not relevant, Master: The warning is present */
			unsigned save_pos:1;                        /**< Drive: Position has been reached, Master: The warning is present */
			unsigned :1;
			unsigned breakpoint:1;                      /**< Drive: not relevant, Master: The breakpoint is reached */
			unsigned :3;
			unsigned user:8;                            /**< Drive: not relevant, Master: User status (UltimET) */
			unsigned :16;
		#else /* DSA_OO_API */
			unsigned intError:1;                       /**< Drive: Error label has been executed, Master: not relevant*/
			unsigned warning:1;                         /**< Drive: not relevant, Master: The warning is present */
			unsigned savePos:1;                        /**< Drive: Position has been reached, Master: The warning is present */
			unsigned :1;
			unsigned breakpoint:1;                      /**< Drive: not relevant, Master: The breakpoint is reached */
			unsigned :3;
			unsigned user:8;                            /**< Drive: not relevant, Master: User status */
			unsigned :16;
	    #endif /* DSA_OO_API */
	} DSA_SW2;
#else /*__BYTE_ORDER == __BIG_ENDIAN*/
	typedef struct DSA_SW2 {
	    #ifndef DSA_OO_API
			unsigned :16;
			unsigned user:8;                            /**< Drive: not relevant, Master: User status */
			unsigned :3;
			unsigned breakpoint:1;                      /**< Drive: not relevant, Master: The breakpoint is reached */
			unsigned :1;
			unsigned save_pos:1;                        /**< Drive: Position has been reached, Master: The warning is present */
			unsigned warning:1;                         /**< Drive: not relevant, Master: The warning is present */
			unsigned int_error:1;                       /**< Drive: Error label has been executed, Master: not relevant*/
	    #else /* DSA_OO_API */
			unsigned :16;
			unsigned user:8;                            /**< Drive: not relevant, Master: User status */
			unsigned :3;
			unsigned breakpoint:1;                      /**< Drive: not relevant, Master: The breakpoint is reached */
			unsigned :1;
			unsigned savePos:1;                        /**< Drive: Position has been reached, Master: The warning is present */
			unsigned warning:1;                         /**< Drive: not relevant, Master: The warning is present */
			unsigned intError:1;                       /**< Drive: Error label has been executed, Master: not relevant*/
	    #endif /* DSA_OO_API */
	} DSA_SW2;
#endif/*__BYTE_ORDER*/

/*------------------------------------------------------------------------------
 * DsaStatusSWMode type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DsaStatusSWMode
 * Allow access to drive status with DSA_SW1(M60) and DSA_SW2(M61) members.\n
 * Obsolete.\n
 * This structure is kept to backwards compatibility only (obsolete DSA and DSB)\n
 * EDI internal status update works now with M63. See DsaStatusDriveBitMode structure
 */
typedef struct DsaStatusSWMode {
    size_t size;                                /**< The size of the structure */
    DSA_SW1 sw1;                                /**< Drive status SW1(M60) */
    DSA_SW2 sw2;                                /**< Drive status SW2(M61) */
} DsaStatusSWMode;

/*------------------------------------------------------------------------------
 * DsaStatusRawMode type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DsaStatusRawMode
 * Allow access to drive status with dword members
 */
typedef struct DsaStatusRawMode {
    size_t size;                                /**< The size of the structure */
    dword sw1;                                  /**< Drive status SW1 in dword type */
    dword sw2;                                  /**< Drive status SW2 in dword type */
} DsaStatusRawMode;

#if __BYTE_ORDER == __LITTLE_ENDIAN
	/*------------------------------------------------------------------------------
	 * DsaStatusDriveBitMode type
	 *-----------------------------------------------------------------------------*/
	/**
	 * @struct DsaStatusDriveBitMode
	 * Allow access to drive status with bit members when acces through M63
	 */
	typedef struct DsaStatusDriveBitMode {
		size_t size;                                /**< The size of the structure */
	    #ifndef DSA_OO_API
			unsigned power_on:1;                        /**< The drive is in power on */
			unsigned :2;
			unsigned present:1;                         /**< The device is present */
			unsigned moving:1;                          /**< The motor is moving */
			unsigned in_window:1;                       /**< The motor's position is in window */
			unsigned :2;
			unsigned sequence:1;                        /**< A sequence is running */
			unsigned in_speed_window:1;								
			unsigned error:1;                           /**< Fatal error */
			unsigned trace:1;                           /**< The aquisition of the trace is not finished */
			unsigned :3;
			unsigned sequence_thread:1;					/**< The specified thread of sequence are executing */
			unsigned :7;
			unsigned warning:1;                         /**< Global warning */
			unsigned :8;
			unsigned :1;								
			unsigned :1;
			unsigned save_pos:1;                        /**< Position has been reached */
			unsigned :1;
			unsigned breakpoint:1;                      /**< Breakpoint is reached */
			unsigned :3;
			unsigned user:16;                           /**< User status */
			unsigned :8;
	    #else /* DSA_OO_API */
			unsigned powerOn:1;                         /* The drive is in power on */
			unsigned :2;                                /* Reserved */
			unsigned present:1;                         /* The drive is present */
			unsigned moving:1;                          /* The motor is moving */
			unsigned inWindow:1;                        /* The motor's position is in window */
			unsigned :2;                                /* Reserved */
			unsigned sequence:1;                        /* A sequence is running */
			unsigned inSpeedWindow:1;                   /* Reserved */
			unsigned error:1;                           /* Fatal error */
			unsigned trace:1;                           /* The aquisition of the trace is not finished */
			unsigned :3;                                /* Reserved */
			unsigned sequenceThread:1;                  /* The specified thread of sequence are executing */
			unsigned :7;                                /* Reserved */
			unsigned warning:1;                         /* Global warning */
			unsigned :8;                                /* Reserved */
			unsigned :1;	
			unsigned :1;
			unsigned savePos:1;                         /* Position has been reached */
			unsigned :1;                                /* Reserved */
			unsigned breakpoint:1;                      /* Breakpoint is reached */
			unsigned :3;                                /* Reserved */
			unsigned user:16;                           /* User status */
			unsigned :8;                                /* Reserved */
	    #endif /* DSA_OO_API */
	} DsaStatusDriveBitMode;

	/*------------------------------------------------------------------------------
	 * DsaStatusDsmaxBitMode type
	 *-----------------------------------------------------------------------------*/
	/**
	 * @struct DsaStatusDsmaxBitMode
	 * Allow access to dsmax status with bit members when acces through M63
	 */
	typedef struct DsaStatusDsmaxBitMode {
	    size_t size;                                /**< The size of the structure */
	    unsigned :3;
		unsigned present:1;                         /**< The Master is present */
		unsigned moving:1;                          /**< One of the interpolation group is moving */
		unsigned :3;
		unsigned sequence:1;                        /**< A sequence is running */
		unsigned :1;
		unsigned error:1;                           /**< Fatal error */
		unsigned trace:1;                           /**< The aquisition of the trace is not finished */
		unsigned ipol0_moving:1;                    /**< Ipol group 0 is moving */
		unsigned ipol1_moving:1;                    /**< Ipol group 1 is moving */
		unsigned :1;
		unsigned :1;
		unsigned :7;
		unsigned warning:1;                         /**< Global warning */
		unsigned :8;
		unsigned :4;
		unsigned :4;
		unsigned user:16;                           /**< User status */
		unsigned :8;
	} DsaStatusDsmaxBitMode;

	/*------------------------------------------------------------------------------
	 * DsaStatusUltimETBitMode type
	 *-----------------------------------------------------------------------------*/
	/**
	 * @struct DsaStatusUltimETBitMode
	 * Allow access to UltimET status with bit members when acces through M63
	 */
	typedef struct DsaStatusUltimETBitMode {
	    size_t size;                                /**< The size of the structure */
	    unsigned :3;
		unsigned present:1;                         /**< The Master is present */
		unsigned moving:1;                          /**< One of the interpolation group is moving */
		unsigned :3;
		unsigned sequence:1;                        /**< A sequence is running */
		unsigned :1;
		unsigned error:1;                           /**< Fatal error */
		unsigned trace:1;                           /**< The aquisition of the trace is not finished */
		unsigned ipol0_moving:1;                    /**< Ipol group 0 is moving */
		unsigned ipol1_moving:1;                    /**< Ipol group 1 is moving */
		unsigned :1;
		unsigned sequence_thread:1;					/**< The specified thread of sequence are executing */
		unsigned :7;
		unsigned warning:1;                         /**< Global warning */
		unsigned :8;
		unsigned :1;
		unsigned :1;
		unsigned transnet_broken:1;                 /**< Transnet is broken */
		unsigned :1;
		unsigned breakpoint:1;                      /**< Breakpoint is reached */
		unsigned :3;
		unsigned user:16;                           /**< User status */
		unsigned :8;
	} DsaStatusUltimETBitMode;
#else /*__BYTE_ORDER == __BIG_ENDIAN*/
	/*------------------------------------------------------------------------------
	 * DsaStatusDriveBitMode type
	 *-----------------------------------------------------------------------------*/
	/**
	 * @struct DsaStatusDriveBitMode
	 * Allow access to drive status with bit members when acces through M63
	 */
	typedef struct DsaStatusDriveBitMode {
		size_t size;                                /**< The size of the structure */
	    #ifndef DSA_OO_API
			unsigned :8;
			unsigned warning:1;                         /**< Global warning */
			unsigned :7;
			unsigned sequence_thread:1;					/**< The specified thread of sequence are executing */
			unsigned :3;
			unsigned trace:1;                           /**< The aquisition of the trace is not finished */
			unsigned error:1;                           /**< Fatal error */
			unsigned in_speed_window:1;								
			unsigned sequence:1;                        /**< A sequence is running */
			unsigned :2;
			unsigned in_window:1;                       /**< The motor's position is in window */
			unsigned moving:1;                          /**< The motor is moving */
			unsigned present:1;                         /**< The drive is present */
			unsigned :2;
			unsigned power_on:1;                        /**< Drive: The drive is in power on */
			unsigned :8;
			unsigned user:16;                           /**< User status */
			unsigned :3;
			unsigned breakpoint:1;                      /**< Breakpoint is reached */
			unsigned :1;
			unsigned save_pos:1;                        /**< Position has been reached */
			unsigned :1;
			unsigned :1;	
	    #else /* DSA_OO_API */
			unsigned :8;
			unsigned warning:1;                         /**< Global warning */
			unsigned :7;
			unsigned sequenceThread:1;					/**< The specified thread of sequence are executing */
			unsigned :3;
			unsigned trace:1;                           /**< The aquisition of the trace is not finished */
			unsigned error:1;                           /**< Fatal error */
			unsigned inSpeedWindow:1;								
			unsigned sequence:1;                        /**< A sequence is running */
			unsigned :2;
			unsigned inWindow:1;                       /**< The motor's position is in window */
			unsigned moving:1;                          /**< The motor is moving */
			unsigned present:1;                         /**< The drive is present */
			unsigned :2;
			unsigned powerOn:1;                        /**< Drive: The drive is in power on */
			unsigned :8;
			unsigned user:16;                           /**< User status */
			unsigned :3;
			unsigned breakpoint:1;                      /**< Breakpoint is reached */
			unsigned :1;
			unsigned savePos:1;                        /**< Position has been reached */
			unsigned :1;
			unsigned :1;
	    #endif /* DSA_OO_API */
	} DsaStatusDriveBitMode;

	/*------------------------------------------------------------------------------
	 * DsaStatusDsmaxBitMode type
	 *-----------------------------------------------------------------------------*/
	/**
	* @struct DsaStatusDsmaxBitMode
	* Allow access to dsmax status with bit members when acces through M60
	*/
	typedef struct DsaStatusDsmaxBitMode {
		size_t size;                                /**< The size of the structure */
		unsigned :8;
		unsigned warning:1;                         /**< Global warning */
		unsigned :7;
		unsigned :2;
		unsigned ipol1_moving:1;                    /**< Ipol group 1 is moving */
		unsigned ipol0_moving:1;                    /**< Ipol group 0 is moving */
		unsigned trace:1;                           /**< The aquisition of the trace is not finished */
		unsigned error:1;                           /**< Fatal error */
		unsigned :1;
		unsigned sequence:1;                        /**< A sequence is running */
		unsigned :3;
		unsigned moving:1;                          /**< An axis (of ipol group 0 or 1) is moving */
		unsigned present:1;                         /**< The dsmax is present */
		unsigned :3;
		unsigned :8;
		unsigned user:16;                           /**< User status */
		unsigned :4;
		unsigned :4;
	} DsaStatusDsmaxBitMode;

	/*------------------------------------------------------------------------------
	 * DsaStatusUltimETBitMode type
	 *-----------------------------------------------------------------------------*/
	/**
	* @struct DsaStatusUltimETBitMode
	* Allow access to UltimET status with bit members when acces through M60
	*/
	typedef struct DsaStatusUltimETBitMode {
		size_t size;                                /**< The size of the structure */
		unsigned :8;
		unsigned warning:1;                         /**< Global warning */
		unsigned :7;
		unsigned sequence_thread;
		unsigned :1;
		unsigned ipol1_moving:1;                    /**< Ipol group 1 is moving */
		unsigned ipol0_moving:1;                    /**< Ipol group 0 is moving */
		unsigned trace:1;                           /**< The aquisition of the trace is not finished */
		unsigned error:1;                           /**< Fatal error */
		unsigned :1;
		unsigned sequence:1;                        /**< A sequence is running */
		unsigned :3;
		unsigned moving:1;                          /**< An axis (of ipol group 0 or 1) is moving */
		unsigned present:1;                         /**< The UltimET is present */
		unsigned :3;
		unsigned :8;
		unsigned user:16;                           /**< User status */
		unsigned :3;
		unsigned breakpoint:1;                      /**< Breakpoint is reached */
		unsigned : 1;
		unsigned transnet_broken:1;                 /**< Transnet connection broken */
		unsigned : 2;
	} DsaStatusUltimETBitMode;

#endif /*__BYTE_ORDER*/

/*------------------------------------------------------------------------------
 * DSA_STATUS type
 *-----------------------------------------------------------------------------*/
/**
 * @union DSA_STATUS
 * Contains status of devices
 */
typedef union DSA_STATUS {
    int size;                                /**< The size of this structure */
    DsaStatusSWMode sw;							/**< Status for SW1/SW2 access. Obsolete */
    DsaStatusRawMode raw;						/**< Status for raw access. Obsolete */
    DsaStatusDriveBitMode drive;				/**< Status for drive bit access */
    DsaStatusDsmaxBitMode dsmax;				/**< Status for dsmax bit access */
    DsaStatusUltimETBitMode ultimet;            /**< Status for UltimET bit access */
    DsaStatusUltimETBitMode master;             /**< Status for UltimET bit access */
} DSA_STATUS;

#define DsaStatus DSA_STATUS


/*------------------------------------------------------------------------------
 * DSA_INFO type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DSA_INFO
 * Device info parameters monitoring structure
 */
typedef struct DSA_INFO {
    int size;                                     /**< Size of this structure */
	#ifndef DSA_OO_API
		int info_product_number;                         /**< Product number */
		int info_boot_revision;                          /**< Boot revision */
		dword info_serial_number;                        /**< Serial number */
		dword info_soft_version;                         /**< Software version */
		dword info_p_soft_build_time;                    /**< Position software build time */
		dword info_c_soft_build_time;                    /**< Current software build time */
		dword info_product_string[8];                    /**< Product string */
	#else /* DSA_OO_API */
		int infoProductNumber;                           /**< Product number */
		int infoBootRevision;                            /**< Boot revision */
		dword infoSerialNumber;                          /**< Serial number */
		dword infoSoftVersion;                           /**< Software version */
		dword infoPSoftBuildTime;                        /**< Position software build time */
		dword infoCSoftBuildTime;                        /**< Current software build time */
		dword infoProductString[8];                      /**< Product string */
	#endif /* DSA_OO_API */
} DSA_INFO;

#define DsaInfo DSA_INFO

/*------------------------------------------------------------------------------
 * DSA_X_INFO type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DSA_X_INFO
 * Extension card info parameters monitoring structure
 */
typedef struct DSA_X_INFO {
    int size;                                     /**< Size of this structure */
	#ifndef DSA_OO_API
		int x_info_product_number;                       /**< Extension card info product number */
		int x_info_boot_revision;                        /**< Extension card info boot revision */
		dword x_info_serial_number;                      /**< Extension card info serial number */
		dword x_info_soft_version;                       /**< Extension card info software version */
		dword x_info_soft_build_time;                    /**< Extension card info software build time */
		dword x_info_product_string[4];                  /**< Extension card info product string */
	#else /* DSA_OO_API */
		int xInfoProductNumber;                          /**< Extension card info product number */
		int xInfoBootRevision;                           /**< Extension card info boot revision */
		dword xInfoSerialNumber;                         /**< Extension card info serial number */
		dword xInfoSoftVersion;                          /**< Extension card info software version */
		dword xInfoSoftBuildTime;                        /**< Extension card info software build time */
		dword xInfoProductString[4];                     /**< Extension card info product string */
	#endif /* DSA_OO_API */
} DSA_X_INFO;

#define DsaXInfo DSA_X_INFO

/*------------------------------------------------------------------------------
 * DSA_RTV_HANDLER type
 *-----------------------------------------------------------------------------*/
/*Type of RTV handler called at each cyclic Master interrupt*/
/*Only on AccurET family connected through Master*/
typedef void (DSA_CALLBACK *DSA_RTV_HANDLER)(DSA_MASTER *master, int nr, int nb_read, DSA_RTV_DATA **read_rtv, int nb_write, DSA_RTV_DATA **write_rtv, void *user);
//#define DsaRTVHandler DSA_RTV_HANDLER

/*------------------------------------------------------------------------------
 * asynchronous handlers
 *-----------------------------------------------------------------------------*/
typedef void (DSA_CALLBACK *DSA_HANDLER)(DSA_DEVICE_BASE *dev, int err, void *param);
typedef void (DSA_CALLBACK *DSA_INT_HANDLER)(DSA_DEVICE *dev, int err, void *param, int val);
typedef void (DSA_CALLBACK *DSA_LONG_HANDLER)(DSA_DEVICE *dev, int err, void *param, long val);
typedef void (DSA_CALLBACK *DSA_INT64_HANDLER)(DSA_DEVICE *dev, int err, void *param, eint64 val);
typedef void (DSA_CALLBACK *DSA_DWORD_HANDLER)(DSA_DEVICE *dev, int err, void *param, dword val);
typedef void (DSA_CALLBACK *DSA_FLOAT_HANDLER)(DSA_DEVICE *dev, int err, void *param, float val);
typedef void (DSA_CALLBACK *DSA_DOUBLE_HANDLER)(DSA_DEVICE *dev, int err, void *param, double val);
typedef void (DSA_CALLBACK *DSA_STATUS_HANDLER)(DSA_DEVICE *dev, int err, void *param, const DSA_STATUS *status);
typedef void (DSA_CALLBACK *DSA_2INT_HANDLER)(DSA_DEVICE *dev, int err, void *param, int val1, int val2);
typedef void (DSA_CALLBACK *DSA_PROGRESS)(const char *text, void *puser);

/*------------------------------------------------------------------------------
 * DsaId type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DsaId
 * generic command parameter
 */
typedef union DsaId {
    int i;
    eint64 i64;
	float f;
    double d;				/**< also used when conv != 0 */
} DsaId;

/*------------------------------------------------------------------------------
 * DSA_COMMAND_PARAM type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DSA_COMMAND_PARAM
 * Generic command parameter
 */
typedef struct DSA_COMMAND_PARAM {
    int typ;                /**< Parameter type */
    int conv;               /**< Coenversion index, zero means no conversion */
    DsaId val;              /**< Value of parameter */
} DSA_COMMAND_PARAM;
#define DsaCommandParam DSA_COMMAND_PARAM

/*------------------------------------------------------------------------------
 * DsaDim type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DsaDim
 * Dimension of interpolation structure
 */
typedef struct DsaDim {
    double x;               /**< X axis*/
    double y;               /**< Y axis */
    double z;               /**< Z axis */
    double theta;           /**< Theta axis */
} DsaDim;

/*------------------------------------------------------------------------------
 * DsaDimArray type
 *-----------------------------------------------------------------------------*/
/**
 * @union DsaDimDArray
 * Allows access to parameter through DsaDim structure or array of double
 */
typedef union DsaDimDArray {
    DsaDim dim;         /**< Access through DsaDim structure */
    double array[4];        /**< Access through array of double */
} DsaDimDArray;

/*------------------------------------------------------------------------------
 * DsaDimIArray type
 *-----------------------------------------------------------------------------*/
/**
 * @union DsaDimIArray
 * Allows access to parameter through DsaDim structure or array of integer
 */
typedef union DsaDimIArray {
    int array[4];           /**< Access through array of int */
} DsaDimIArray;

/*------------------------------------------------------------------------------
 * DSA_VECTOR type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DSA_VECTOR
 * Vector
 */
typedef struct DSA_VECTOR {
    int size;                        /**< Size of this structure */
    int reserved;                       /**< Reserved for compatibility algnment 8 bytes */
    DsaDimDArray val;                   /**< The value of the axis */
} DSA_VECTOR;

#define DsaVector DSA_VECTOR

/*------------------------------------------------------------------------------
 * DSA_VECTOR_TYP type
 *-----------------------------------------------------------------------------*/
/**
 * @struct DSA_VECTOR_TYP
 * Vector Typ
 */
typedef struct DSA_VECTOR_TYP {
    int size;                        /**< Size of this structure */
    int reserved;                       /**< Reserved for compatibility algnment 8 bytes */
    DsaDimIArray val;                   /**< The typ of the values of the axis */
} DSA_VECTOR_TYP;

#define DsaVectorTyp DSA_VECTOR_TYP
#define DSA_INT_VECTOR DSA_VECTOR_TYP
#define DsaIntVector DSA_VECTOR_TYP


/**********************************************************************************************************/
/*- PROTOTYPES */
/**********************************************************************************************************/

/**
 * @addtogroup DSAAll
 * @{
 */

/*------------------------------------------------------------------------------
 * special functions - synchronous
 *-----------------------------------------------------------------------------*/
#ifdef DSA_IMPL_S
	int     _DSA_EXPORT dsa_power_on_s(DSA_DRIVE_BASE *grp, long timeout);
	int     _DSA_EXPORT dsa_power_off_s(DSA_DRIVE_BASE *grp, long timeout);
	int     _DSA_EXPORT dsa_new_setpoint_s(DSA_DRIVE_BASE *grp, int sidx, dword flags, long timeout);
	int     _DSA_EXPORT dsa_change_setpoint_s(DSA_DRIVE_BASE *grp, int sidx, dword flags, long timeout);
	int     _DSA_EXPORT dsa_quick_stop_s(DSA_DRIVE_BASE *grp, int mode, dword flags, long timeout);
	int     _DSA_EXPORT dsa_homing_start_s(DSA_DRIVE_BASE *obj, long timeout);
	int     _DSA_EXPORT dsa_get_warning_code_s(DSA_DEVICE *dev, int *code, int kind, long timeout);
	int     _DSA_EXPORT dsa_execute_command_s(DSA_DEVICE_BASE *grp, int cmd, bool fast, bool ereport, long timeout);
	int     _DSA_EXPORT dsa_execute_command_d_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, bool fast, bool ereport, long timeout);
	int     _DSA_EXPORT dsa_execute_command_i_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout);
	int     _DSA_EXPORT dsa_execute_command_dd_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout);
	int     _DSA_EXPORT dsa_execute_command_id_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout);
	int     _DSA_EXPORT dsa_execute_command_di_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout);
	int     _DSA_EXPORT dsa_execute_command_ii_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout);
	int     _DSA_EXPORT dsa_execute_command_x_s(DSA_DEVICE_BASE *grp, int cmd, DSA_COMMAND_PARAM *params, int count, bool fast, bool ereport, long timeout);
	int		_DSA_EXPORT dsa_start_profiled_movement_s(DSA_DRIVE_BASE *grp, double pos, double speed, double acc, long timeout);
	int		_DSA_EXPORT dsa_start_relative_profiled_movement_s(DSA_DRIVE_BASE *grp, double relative_pos, long timeout);

	int     _DSA_EXPORT dsa_get_register_s(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, long *val, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_register_int32_s(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, long *val, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_register_int64_s(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, eint64 *val, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_register_float32_s(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, float *val, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_register_float64_s(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, double *val, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_array_s(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_array_int32_s(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_array_int64_s(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_array_float32_s(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_array_float64_s(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int kind, long timeout);
	int     _DSA_EXPORT dsa_set_register_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, long val, long timeout);
	int     _DSA_EXPORT dsa_set_register_int32_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, long val, long timeout);
	int     _DSA_EXPORT dsa_set_register_int64_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, eint64 val, long timeout);
	int     _DSA_EXPORT dsa_set_register_float32_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, float val, long timeout);
	int     _DSA_EXPORT dsa_set_register_float64_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, double val, long timeout);

	int     _DSA_EXPORT dsa_set_array_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout);
	int     _DSA_EXPORT dsa_set_array_int32_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout);
	int     _DSA_EXPORT dsa_set_array_int64_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout);
	int     _DSA_EXPORT dsa_set_array_float32_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout);
	int     _DSA_EXPORT dsa_set_array_float64_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout);

	int     _DSA_EXPORT dsa_get_iso_register_s(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, double *val, int conv, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_iso_array_s(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout);
	int     _DSA_EXPORT dsa_set_iso_register_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, double val, int conv, long timeout);
	int     _DSA_EXPORT dsa_set_iso_array_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout);
	int     _DSA_EXPORT dsa_ipol_begin_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_ipol_end_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_ipol_begin_concatenation_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_ipol_end_concatenation_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_ipol_line_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, long timeout);
	int     _DSA_EXPORT dsa_ipol_circle_cw_r2d_s(DSA_IPOL_GROUP *igrp, double x, double y, double r, long timeout);
	int     _DSA_EXPORT dsa_ipol_circle_ccw_r2d_s(DSA_IPOL_GROUP *igrp, double x, double y, double r, long timeout);
	int     _DSA_EXPORT dsa_ipol_tan_velocity_s(DSA_IPOL_GROUP *igrp, double velocity, long timeout);
	int     _DSA_EXPORT dsa_ipol_tan_acceleration_s(DSA_IPOL_GROUP *igrp, double acc, long timeout);
	int     _DSA_EXPORT dsa_ipol_tan_deceleration_s(DSA_IPOL_GROUP *igrp, double dec, long timeout);
	int     _DSA_EXPORT dsa_ipol_tan_jerk_time_s(DSA_IPOL_GROUP *igrp, double jerk_time, long timeout);
	int     _DSA_EXPORT dsa_ipol_quick_stop_s(DSA_IPOL_GROUP *igrp, int mode, dword flags, long timeout);
	int     _DSA_EXPORT dsa_ipol_continue_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_ipol_pvt_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_VECTOR *velocity, double time, long timeout);
	int		_DSA_EXPORT dsa_ipol_pt_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, double time, long timeout);
	int     _DSA_EXPORT dsa_ipol_mark_s(DSA_IPOL_GROUP *igrp, long number, long operation, long op_param, long timeout);
	int		_DSA_EXPORT dsa_ipol_mark_2param_s(DSA_IPOL_GROUP *igrp, long number, long operation, long op_param1, long op_param2, long timeout);
	int     _DSA_EXPORT dsa_ipol_set_velocity_rate_s(DSA_IPOL_GROUP *igrp, double rate, long timeout);
	int     _DSA_EXPORT dsa_ipol_circle_cw_c2d_s(DSA_IPOL_GROUP *igrp, double x, double y, double cx, double cy, long timeout);
	int     _DSA_EXPORT dsa_ipol_circle_ccw_c2d_s(DSA_IPOL_GROUP *igrp, double x, double y, double cx, double cy, long timeout);
	int     _DSA_EXPORT dsa_ipol_line_2d_s(DSA_IPOL_GROUP *igrp, double x, double y, long timeout);
	int     _DSA_EXPORT dsa_ipol_wait_movement_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_ipol_prepare_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_ipol_pvt_update_s(DSA_IPOL_GROUP *igrp, int depth, dword mask, long timeout);
	int     _DSA_EXPORT dsa_ipol_pvt_reg_typ_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_VECTOR_TYP destTyp, DSA_VECTOR *velocity, DSA_VECTOR_TYP velocityTyp, double time, int timeTyp, long timeout);
	int     _DSA_EXPORT dsa_ipol_set_lkt_speed_ratio_s(DSA_IPOL_GROUP *igrp, double value, long timeout);
	int     _DSA_EXPORT dsa_ipol_set_lkt_cyclic_mode_s(DSA_IPOL_GROUP *igrp, bool active, long timeout);
	int     _DSA_EXPORT dsa_ipol_set_lkt_relative_mode_s(DSA_IPOL_GROUP *igrp, bool active, long timeout);
	int     _DSA_EXPORT dsa_ipol_lkt_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_INT_VECTOR *lkt_number, double time, long timeout);
	int     _DSA_EXPORT dsa_ipol_wait_mark_s(DSA_IPOL_GROUP *igrp, int mark, long timeout);
	int     _DSA_EXPORT dsa_ipol_uline_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, long timeout);
	int     _DSA_EXPORT dsa_ipol_uline_2d_s(DSA_IPOL_GROUP *igrp, double x, double y, long timeout);
	int     _DSA_EXPORT dsa_ipol_disable_uconcatenation_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_ipol_set_urelative_mode_s(DSA_IPOL_GROUP *igrp, bool active, long timeout);
	int     _DSA_EXPORT dsa_ipol_uspeed_axis_mask_s(DSA_IPOL_GROUP *igrp, dword mask, long timeout);
	int     _DSA_EXPORT dsa_ipol_uspeed_s(DSA_IPOL_GROUP *igrp, double speed, long timeout);
	int     _DSA_EXPORT dsa_ipol_utime_s(DSA_IPOL_GROUP *igrp, double acc_time, double jerk_time, long timeout);
	int     _DSA_EXPORT dsa_ipol_translate_matrix_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *trans, long timeout);
	int     _DSA_EXPORT dsa_ipol_scale_matrix_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *scale, long timeout);
	int     _DSA_EXPORT dsa_ipol_rotate_matrix_s(DSA_IPOL_GROUP *igrp, int plan, double degree, long timeout);
	int     _DSA_EXPORT dsa_ipol_translate_matrix_2d_s(DSA_IPOL_GROUP *igrp, double x, double y, long timeout);
	int     _DSA_EXPORT dsa_ipol_scale_matrix_2d_s(DSA_IPOL_GROUP *igrp, double x, double y, long timeout);
	int     _DSA_EXPORT dsa_ipol_shear_matrix_s(DSA_IPOL_GROUP *igrp, int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, long timeout);
	int     _DSA_EXPORT dsa_ipol_lock_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_ipol_unlock_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_ipol_clear_buffer_s(DSA_IPOL_GROUP *igrp, long timeout);
	int     _DSA_EXPORT dsa_wait_status_equal_s(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS *ref, DSA_STATUS *status, long timeout);
	int     _DSA_EXPORT dsa_wait_status_not_equal_s(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS *ref, DSA_STATUS *status, long timeout);
	int     _DSA_EXPORT dsa_grp_wait_and_status_equal_s(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
	int     _DSA_EXPORT dsa_grp_wait_and_status_not_equal_s(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
	int     _DSA_EXPORT dsa_gantry_wait_and_status_equal_s(DSA_GANTRY *gantry, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
	int     _DSA_EXPORT dsa_gantry_wait_and_status_not_equal_s(DSA_GANTRY *gantry, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
	int     _DSA_EXPORT dsa_wait_status_change_s(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS *status, long timeout);
	int     _DSA_EXPORT dsa_grp_wait_or_status_equal_s(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
	int     _DSA_EXPORT dsa_grp_wait_or_status_not_equal_s(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
	int     _DSA_EXPORT dsa_sync_trace_enable_s(DSA_DEVICE_BASE *obj, bool enable, long timeout);
	int     _DSA_EXPORT dsa_sync_trace_force_trigger_s(DSA_DEVICE_BASE *obj, long timeout);
	int     _DSA_EXPORT dsa_get_error_code_s(DSA_DEVICE *obj, int *code, int kind, long timeout);
	int     _DSA_EXPORT dsa_acquisition_acquire_s(DSA_ACQUISITION *acq, int timeout);
	int		_DSA_EXPORT dsa_ipol_set_abs_mode_s(DSA_IPOL_GROUP *igrp, bool active, long timeout);
	int		_DSA_EXPORT dsa_ipol_abs_coords_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *pos, long timeout);
	int		_DSA_EXPORT dsa_debug_sequence_enable_breakpoint_at_s(DSA_DEVICE_BASE *obj, int code_offset, bool enable, long timeout);
	int		_DSA_EXPORT dsa_debug_sequence_enable_breakpoint_everywhere_s(DSA_DEVICE_BASE *obj, bool enable, long timeout);
	int		_DSA_EXPORT dsa_debug_sequence_continue_s(DSA_DEVICE_BASE *obj, long timeout);
#endif /* DSA_IMPL_S */


/*------------------------------------------------------------------------------
 * special functions - asynchronous
 *-----------------------------------------------------------------------------*/
#ifdef DSA_IMPL_A
	int     _DSA_EXPORT dsa_power_on_a(DSA_DRIVE_BASE *grp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_power_off_a(DSA_DRIVE_BASE *grp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_new_setpoint_a(DSA_DRIVE_BASE *grp, int sidx, dword flags, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_change_setpoint_a(DSA_DRIVE_BASE *grp, int sidx, dword flags, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_quick_stop_a(DSA_DRIVE_BASE *grp, int mode, dword flags, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_homing_start_a(DSA_DRIVE_BASE *obj, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_warning_code_a(DSA_DEVICE *dev, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_execute_command_a(DSA_DEVICE_BASE *grp, int cmd, bool fast, bool ereport, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_execute_command_d_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, bool fast, bool ereport, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_execute_command_i_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_execute_command_dd_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_execute_command_id_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_execute_command_di_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_execute_command_ii_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_execute_command_x_a(DSA_DEVICE_BASE *grp, int cmd, DSA_COMMAND_PARAM *params, int count, bool fast, bool ereport, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_start_profiled_movement_a(DSA_DRIVE_BASE *grp, double pos, double speed, double acc, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_start_relative_profiled_movement_a(DSA_DRIVE_BASE *grp, double relative_pos, DSA_HANDLER handler, void *param);

	int     _DSA_EXPORT dsa_get_register_a(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, int kind, DSA_LONG_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_register_int32_a(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, int kind, DSA_LONG_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_register_int64_a(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, int kind, DSA_INT64_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_register_float32_a(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, int kind, DSA_FLOAT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_register_float64_a(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);

	int     _DSA_EXPORT dsa_get_array_a(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_array_int32_a(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_array_int64_a(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, int kind, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_array_float32_a(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, int kind, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_array_float64_a(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int kind, DSA_HANDLER handler, void *param);

	int     _DSA_EXPORT dsa_set_register_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, long val, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_register_int32_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, long val, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_register_int64_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, eint64 val, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_register_float32_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, float val, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_register_float64_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, double val, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_array_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_array_int32_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_array_int64_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_array_float32_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_array_float64_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DSA_HANDLER handler, void *param);

	int     _DSA_EXPORT dsa_get_iso_register_a(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, int conv, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_iso_array_a(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_iso_register_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, double val, int conv, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_iso_array_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_begin_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_end_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_begin_concatenation_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_end_concatenation_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_line_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_circle_cw_r2d_a(DSA_IPOL_GROUP *igrp, double x, double y, double r, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_circle_ccw_r2d_a(DSA_IPOL_GROUP *igrp, double x, double y, double r, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_tan_velocity_a(DSA_IPOL_GROUP *igrp, double velocity, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_tan_acceleration_a(DSA_IPOL_GROUP *igrp, double acc, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_tan_deceleration_a(DSA_IPOL_GROUP *igrp, double dec, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_tan_jerk_time_a(DSA_IPOL_GROUP *igrp, double jerk_time, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_quick_stop_a(DSA_IPOL_GROUP *igrp, int mode, dword flags, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_continue_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_pvt_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_VECTOR *velocity, double time, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_ipol_pt_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, double time, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_mark_a(DSA_IPOL_GROUP *igrp, long number, long operation, long op_param, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_ipol_mark_2param_a(DSA_IPOL_GROUP *igrp, long number, long operation, long op_param1, long op_param2, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_set_velocity_rate_a(DSA_IPOL_GROUP *igrp, double rate, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_circle_cw_c2d_a(DSA_IPOL_GROUP *igrp, double x, double y, double cx, double cy, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_circle_ccw_c2d_a(DSA_IPOL_GROUP *igrp, double x, double y, double cx, double cy, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_line_2d_a(DSA_IPOL_GROUP *igrp, double x, double y, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_wait_movement_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_prepare_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_pvt_update_a(DSA_IPOL_GROUP *igrp, int depth, dword mask, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_pvt_reg_typ_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_VECTOR_TYP destTyp, DSA_VECTOR *velocity, DSA_VECTOR_TYP velocityTyp, double time, int timeTyp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_set_lkt_speed_ratio_a(DSA_IPOL_GROUP *igrp, double value, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_set_lkt_cyclic_mode_a(DSA_IPOL_GROUP *igrp, bool active, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_set_lkt_relative_mode_a(DSA_IPOL_GROUP *igrp, bool active, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_lkt_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_INT_VECTOR *lkt_number, double time, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_wait_mark_a(DSA_IPOL_GROUP *igrp, int mark, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_uline_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_uline_2d_a(DSA_IPOL_GROUP *igrp, double x, double y, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_disable_uconcatenation_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_set_urelative_mode_a(DSA_IPOL_GROUP *igrp, bool active, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_uspeed_axis_mask_a(DSA_IPOL_GROUP *igrp, dword mask, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_uspeed_a(DSA_IPOL_GROUP *igrp, double speed, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_utime_a(DSA_IPOL_GROUP *igrp, double acc_time, double jerk_time, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_translate_matrix_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *trans, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_scale_matrix_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *scale, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_rotate_matrix_a(DSA_IPOL_GROUP *igrp, int plan, double degree, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_translate_matrix_2d_a(DSA_IPOL_GROUP *igrp, double x, double y, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_scale_matrix_2d_a(DSA_IPOL_GROUP *igrp, double x, double y, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_shear_matrix_a(DSA_IPOL_GROUP *igrp, int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_lock_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_ipol_unlock_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_ipol_clear_buffer_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_status_equal_a(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS *ref, DSA_STATUS_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_status_not_equal_a(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS *ref, DSA_STATUS_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_grp_wait_and_status_equal_a(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_grp_wait_and_status_not_equal_a(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_gantry_wait_and_status_equal_a(DSA_GANTRY *gantry, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_gantry_wait_and_status_not_equal_a(DSA_GANTRY *gantry, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_status_change_a(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_grp_wait_or_status_equal_a(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_grp_wait_or_status_not_equal_a(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_sync_trace_enable_a(DSA_DEVICE_BASE *obj, bool enable, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_sync_trace_force_trigger_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_error_code_a(DSA_DEVICE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_acquisition_acquire_a(DSA_ACQUISITION *acq, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_ipol_set_abs_mode_a(DSA_IPOL_GROUP *igrp, bool active, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_ipol_abs_coords_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *pos, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_debug_sequence_enable_breakpoint_at_a(DSA_DEVICE_BASE *obj, int code_offset, bool enable, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_debug_sequence_enable_breakpoint_everywhere_a(DSA_DEVICE_BASE *obj, bool enable, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_debug_sequence_continue_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);

#endif /* DSA_IMPL_A */

/*------------------------------------------------------------------------------
 * special functions - others
 *-----------------------------------------------------------------------------*/
int     _DSA_EXPORT dsa_etcom_open_e(DSA_DEVICE *dev, ETB *etb, int axis);
int     _DSA_EXPORT dsa_open_u(DSA_DEVICE *dev, char_cp url);
int     _DSA_EXPORT dsa_etcom_open_ef(DSA_DEVICE *dev, ETB *etb, int axis, dword flags);
int     _DSA_EXPORT dsa_reset(DSA_DEVICE *dev);
int     _DSA_EXPORT dsa_close(DSA_DEVICE *dev);
int     _DSA_EXPORT dsa_get_etb_bus(DSA_DEVICE *dev, ETB **etb);
int     _DSA_EXPORT dsa_get_dmd_data(DSA_DEVICE *dev, DMD **dmd);
int     _DSA_EXPORT dsa_etcom_get_etb_axis(DSA_DEVICE *dev, int *axis);
int     _DSA_EXPORT dsa_create_drive(DSA_DRIVE **rdrv);
int     _DSA_EXPORT dsa_create_master(DSA_MASTER **rmaster);
int     _DSA_EXPORT dsa_create_dsmax(DSA_DSMAX **rmaster);
int     _DSA_EXPORT dsa_destroy(DSA_DEVICE_BASE **rdev);
int     _DSA_EXPORT dsa_is_open(DSA_DEVICE *dev, bool *is_open);
int     _DSA_EXPORT dsa_share(DSA_DEVICE_BASE *dsa);
int     _DSA_EXPORT dsa_etcom_create_auto_e(DSA_DEVICE **rdev, ETB *etb, int axis);
int     _DSA_EXPORT dsa_create_auto_o(DSA_DEVICE **rdev, int prod);
int     _DSA_EXPORT dsa_get_motor_typ(DSA_DEVICE *dev);
int     _DSA_EXPORT dsa_get_family(DSA_DEVICE_BASE *dev, DMD_FAMILY *family);
dword   _DSA_EXPORT dsa_get_version(void);
time_t  _DSA_EXPORT dsa_get_build_time(void);
dword   _DSA_EXPORT dsa_get_timer(void);
char_cp _DSA_EXPORT dsa_translate_error(int code);
int     _DSA_EXPORT dsa_set_prio(int prio);
dword   _DSA_EXPORT dsa_get_edi_version(void);
int		_DSA_EXPORT dsa_get_new_gate (DSA_DEVICE_BASE *dsa, int uid, int gate_type, dword *gate_nr);
int		_DSA_EXPORT dsa_set_gate (DSA_DEVICE_BASE *dsa, dword gate_nr);
int		_DSA_EXPORT dsa_clear_gate (DSA_DEVICE_BASE *dsa, int uid, dword gate_nr);
int     _DSA_EXPORT dsa_get_error_text(DSA_DEVICE *dev, char_p text, int size, int code);
int     _DSA_EXPORT dsa_get_warning_text(DSA_DEVICE *dev, char_p text, int size, int code);
char_cp _DSA_EXPORT dsa_translate_edi_error(int code);
int     _DSA_EXPORT dsa_convert_to_iso(DSA_DEVICE *dev, double *iso, long inc, int conv);
int     _DSA_EXPORT dsa_convert_int32_to_iso(DSA_DEVICE *dev, double *iso, long inc, int conv);
int     _DSA_EXPORT dsa_convert_int64_to_iso(DSA_DEVICE *dev, double *iso, eint64 inc, int conv);
int     _DSA_EXPORT dsa_convert_float32_to_iso(DSA_DEVICE *dev, double *iso, float inc, int conv);
int     _DSA_EXPORT dsa_convert_float64_to_iso(DSA_DEVICE *dev, double *iso, double inc, int conv);
int     _DSA_EXPORT dsa_convert_from_iso(DSA_DEVICE *dev, long *inc, double iso, int conv);
int     _DSA_EXPORT dsa_convert_int32_from_iso(DSA_DEVICE *dev, long *inc, double iso, int conv);
int     _DSA_EXPORT dsa_convert_int64_from_iso(DSA_DEVICE *dev, eint64 *inc, double iso, int conv);
int     _DSA_EXPORT dsa_convert_float32_from_iso(DSA_DEVICE *dev, float *inc, double iso, int conv);
int     _DSA_EXPORT dsa_convert_float64_from_iso(DSA_DEVICE *dev, double *inc, double iso, int conv);
int		_DSA_EXPORT dsa_get_inc_to_iso_factor(DSA_DEVICE *dev, int conv, double *factor);
int     _DSA_EXPORT dsa_diag(char_cp file_name, int line, int err, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_sdiag(char_p str, char_cp file_name, int line, int err, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_fdiag(char_cp output_file_name, char_cp file_name, int line, int err, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_ext_diag(char_cp file_name, int line, int err, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_ext_sdiag(int size, char_p str, char_cp file_name, int line, int err, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_ext_fdiag(char_cp output_file_name, char_cp file_name, int line, int err, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_create_device_group(DSA_DEVICE_GROUP **rgrp, int size);
int     _DSA_EXPORT dsa_create_drive_group(DSA_DRIVE_GROUP **rgrp, int size);
int     _DSA_EXPORT dsa_create_master_group(DSA_MASTER_GROUP **rgrp, int size);
int     _DSA_EXPORT dsa_create_dsmax_group(DSA_DSMAX_GROUP **rgrp, int size);
int     _DSA_EXPORT dsa_create_ipol_group(DSA_IPOL_GROUP **rgrp, int size);
int     _DSA_EXPORT dsa_get_group_size(DSA_DEVICE_GROUP *grp, int *size);
int     _DSA_EXPORT dsa_set_group_item(DSA_DEVICE_GROUP *grp, int pos, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_get_group_item(DSA_DEVICE_GROUP *grp, int pos, DSA_DEVICE_BASE **rdev);
int     _DSA_EXPORT dsa_add_group_item(DSA_DEVICE_GROUP *grp, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_set_master(DSA_IPOL_GROUP *grp, DSA_MASTER *master);
int     _DSA_EXPORT dsa_set_dsmax(DSA_IPOL_GROUP *grp, DSA_MASTER *master);
int     _DSA_EXPORT dsa_get_master(DSA_IPOL_GROUP *grp, DSA_MASTER **master);
int     _DSA_EXPORT dsa_get_dsmax(DSA_IPOL_GROUP *grp, DSA_MASTER **master);
bool    _DSA_EXPORT dsa_is_valid_device(DSA_DEVICE *dev);
bool    _DSA_EXPORT dsa_is_valid_drive(DSA_DRIVE *drv);
bool    _DSA_EXPORT dsa_is_valid_master(DSA_MASTER *master);
bool    _DSA_EXPORT dsa_is_valid_dsmax(DSA_DSMAX *master);
bool    _DSA_EXPORT dsa_is_valid_device_group(DSA_DEVICE_GROUP *grp);
bool    _DSA_EXPORT dsa_is_valid_drive_group(DSA_DRIVE_GROUP *grp);
bool    _DSA_EXPORT dsa_is_valid_master_group(DSA_MASTER_GROUP *grp);
bool    _DSA_EXPORT dsa_is_valid_DSMAX_group(DSA_DSMAX_GROUP *grp);
bool    _DSA_EXPORT dsa_is_valid_ipol_group(DSA_IPOL_GROUP *grp);
bool    _DSA_EXPORT dsa_is_valid_device_base(DSA_DEVICE_BASE *dev);
bool    _DSA_EXPORT dsa_is_valid_drive_base(DSA_DRIVE_BASE *dev);
bool    _DSA_EXPORT dsa_is_valid_master_base(DSA_MASTER_BASE *dev);
bool    _DSA_EXPORT dsa_is_valid_dsmax_base(DSA_DSMAX_BASE *dev);
int     _DSA_EXPORT dsa_create_gantry(DSA_GANTRY **gantry);
bool    _DSA_EXPORT dsa_is_valid_gantry(DSA_GANTRY *gantry);
int     _DSA_EXPORT dsa_gantry_get_error_code(DSA_GANTRY *gantry, int *code, int *axis, int kind);
int     _DSA_EXPORT dsa_get_info(DSA_DEVICE *dev, DSA_INFO *info);
bool    _DSA_EXPORT dsa_is_ipol_in_progress(DSA_IPOL_GROUP *igrp);
int     _DSA_EXPORT dsa_get_status(DSA_DEVICE *dev, DSA_STATUS *status);
int     _DSA_EXPORT dsa_cancel_status_wait(DSA_DEVICE_BASE *grp);
int     _DSA_EXPORT dsa_gantry_cancel_status_wait(DSA_GANTRY *gantry);
int     _DSA_EXPORT dsa_gantry_get_and_status(DSA_GANTRY *gantry, DSA_STATUS *status);
int     _DSA_EXPORT dsa_gantry_get_or_status(DSA_GANTRY *gantry, DSA_STATUS *status);
int     _DSA_EXPORT dsa_get_status_from_drive(DSA_DEVICE *dev, DSA_STATUS *status, long timeout);
int     _DSA_EXPORT dsa_grp_cancel_status_wait(DSA_DEVICE_GROUP *grp);
int     _DSA_EXPORT dsa_query_minimum_sample_time(DSA_DEVICE *obj, double *time);
int     _DSA_EXPORT dsa_query_sample_time(DSA_DEVICE *obj, double time, double *real_time);
int     _DSA_EXPORT dsa_begin_sync_trans(void);
int     _DSA_EXPORT dsa_rollback_sync_trans(void);
int     _DSA_EXPORT dsa_commit_sync_trans(long timeout);
int     _DSA_EXPORT dsa_begin_async_trans(void);
int     _DSA_EXPORT dsa_rollback_async_trans(void);
int     _DSA_EXPORT dsa_commit_async_trans(DSA_DEVICE_BASE *grp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_trans_level(int *level);
int     _DSA_EXPORT dsa_get_x_info(DSA_DEVICE *dev, DSA_X_INFO *x_info);
int     _DSA_EXPORT dsa_create_acquisition(DSA_ACQUISITION **acq, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_destroy_acquisition(DSA_ACQUISITION **acq);
bool    _DSA_EXPORT dsa_is_valid_acquisition(DSA_ACQUISITION *acq);
int     _DSA_EXPORT dsa_acquisition_config_trace(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int trace_idx, int typ, int idx, int sidx);
int     _DSA_EXPORT dsa_acquisition_config_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int trig_mode, int trig_trace_idx, double trig_level, int trig_level_conv);
int		_DSA_EXPORT dsa_acquisition_config_immediate_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev);
int		_DSA_EXPORT dsa_acquisition_config_begin_of_movement_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int ipol_grp, double delay);
int		_DSA_EXPORT dsa_acquisition_config_end_of_movement_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int ipol_grp, double delay);
int		_DSA_EXPORT dsa_acquisition_config_position_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, double position, int conv, double delay);
int		_DSA_EXPORT dsa_acquisition_config_position_int64_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, eint64 inc_position, double delay);
int		_DSA_EXPORT dsa_acquisition_config_trace_idx_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, int trace_idx, double value, int conv, double delay);
int		_DSA_EXPORT dsa_acquisition_config_trace_idx_int32_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, int trace_idx, int value, double delay);
int		_DSA_EXPORT dsa_acquisition_config_trace_idx_int64_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, int trace_idx, eint64 inc_value, double delay);
int		_DSA_EXPORT dsa_acquisition_config_trace_idx_float32_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, int trace_idx, float inc_value, double delay);
int		_DSA_EXPORT dsa_acquisition_config_trace_idx_float64_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, int trace_idx, double inc_value, double delay);
int		_DSA_EXPORT dsa_acquisition_config_register_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, int typ, int idx, int sidx, double value, int conv, double delay);
int		_DSA_EXPORT dsa_acquisition_config_register_int32_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, int typ, int idx, int sidx, int inc_value, double delay);
int		_DSA_EXPORT dsa_acquisition_config_register_int64_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, int typ, int idx, int sidx, eint64 inc_value, double delay);
int		_DSA_EXPORT dsa_acquisition_config_register_float32_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, int typ, int idx, int sidx, float inc_value, double delay);
int		_DSA_EXPORT dsa_acquisition_config_register_float64_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int edge, int typ, int idx, int sidx, double inc_value, double delay);

int		_DSA_EXPORT dsa_acquisition_config_int32_bit_field_state_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int typ, int idx, int sidx, dword low_state_mask, dword high_state_mask, double delay);
int		_DSA_EXPORT dsa_acquisition_config_int64_bit_field_state_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int typ, int idx, int sidx, eint64 low_state_mask, eint64 high_state_mask, double delay);
int		_DSA_EXPORT dsa_acquisition_config_int32_bit_field_change_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int typ, int idx, int sidx, dword rising_edge_mask, dword falling_edge_mask, double delay);
int		_DSA_EXPORT dsa_acquisition_config_int64_bit_field_change_trigger(DSA_ACQUISITION *acq, DSA_DEVICE_BASE *dev, int typ, int idx, int sidx, eint64 rising_edge_mask, eint64 falling_edge_mask, double delay);
int     _DSA_EXPORT dsa_acquisition_config_frequency (DSA_ACQUISITION *acq, int nb_points, double total_time, int synchro_mode, int upload_mode);
int     _DSA_EXPORT dsa_acquisition_get_real_total_time(DSA_ACQUISITION *acq, double *real_total_time);
int     _DSA_EXPORT dsa_acquisition_get_trace_real_nb_points(DSA_ACQUISITION *acq, DSA_DEVICE *dev, int trace_idx, int *real_nb_points);
int     _DSA_EXPORT dsa_acquisition_upload_trace(DSA_ACQUISITION *acq, DSA_DEVICE *dev, int trace_idx, int table_size, double times[], double traces[], int conv);
int		_DSA_EXPORT dsa_acquisition_upload_inctrace(DSA_ACQUISITION *acq, DSA_DEVICE *dev, int trace_idx, int table_size, double times[], int traces[]);
int		_DSA_EXPORT dsa_acquisition_upload_int32_trace(DSA_ACQUISITION *acq, DSA_DEVICE *dev, int trace_idx, int table_size, double times[], int traces[]);
int		_DSA_EXPORT dsa_acquisition_upload_int64_trace(DSA_ACQUISITION *acq, DSA_DEVICE *dev, int trace_idx, int table_size, double times[], eint64 traces[]);
int		_DSA_EXPORT dsa_acquisition_upload_float32_trace(DSA_ACQUISITION *acq, DSA_DEVICE *dev, int trace_idx, int table_size, double times[], float traces[]);
int		_DSA_EXPORT dsa_acquisition_upload_float64_trace(DSA_ACQUISITION *acq, DSA_DEVICE *dev, int trace_idx, int table_size, double times[], double traces[]);
int     _DSA_EXPORT dsa_acquisition_stop_acquire(DSA_ACQUISITION *acq);
int     _DSA_EXPORT dsa_acquisition_reserve(DSA_ACQUISITION *acq);
int     _DSA_EXPORT dsa_acquisition_unreserve(DSA_ACQUISITION *acq);
int     _DSA_EXPORT dsa_acquisition_set_name(DSA_ACQUISITION *acq, char *name);
int     _DSA_EXPORT dsa_acquisition_unreserve_all(char *name);
int     _DSA_EXPORT dsa_acquisition_is_reserved(DSA_ACQUISITION *acq, bool *reserved);
int		_DSA_EXPORT dsa_acquisition_get_time_limits(DSA_ACQUISITION *acq, double *start_time, double *end_time);
int		_DSA_EXPORT dsa_start_upload_trace_s(DSA_DEVICE *dev, int trace_typ, int trace_idx, int start_idx, int end_idx, int step_idx, bool fast, long timeout);
int		_DSA_EXPORT dsa_start_upload_sequence_s(DSA_DEVICE *dev, long timeout);
int		_DSA_EXPORT dsa_start_upload_register_s(DSA_DEVICE *dev, int typ, int start_idx, int end_idx, int sidx, long timeout);
int		_DSA_EXPORT dsa_start_upload_memory_s(DSA_DEVICE *dev, dword offset, dword size, long timeout);
int		_DSA_EXPORT dsa_start_download_sequence_s(DSA_DEVICE_BASE *grp, long timeout);
int		_DSA_EXPORT dsa_start_download_register_s(DSA_DEVICE_BASE *grp, int typ, int start_idx, int end_idx, int sidx, long timeout);
int		_DSA_EXPORT dsa_download_data_s(DSA_DEVICE_BASE *grp, const void *data, size_t size, int timeout);
int		_DSA_EXPORT dsa_upload_data_s(DSA_DEVICE *dev, void *data, size_t size, int timeout);
int		_DSA_EXPORT dsa_download_compiled_sequence_file (DSA_DEVICE_BASE *dwn_grp, char* filename);
int		_DSA_EXPORT dsa_set_sequence_version(DSA_DEVICE_BASE *dwn_grp, char *filename);

int		_DSA_EXPORT dsa_get_nb_available_slots_s(DSA_DEVICE *obj, int *nb_free_slots, int kind, long timeout);
int		_DSA_EXPORT dsa_get_nb_available_slots_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int		_DSA_EXPORT dsa_get_32bit_rtv0_slot(DSA_MASTER *dsm, DSA_RTV_SLOT **slot);
int		_DSA_EXPORT dsa_get_32bit_rtv1_slot(DSA_MASTER *dsm, DSA_RTV_SLOT **slot, int sl);
int		_DSA_EXPORT dsa_free_32bit_rtv_slot(DSA_RTV_SLOT **slot);
int		_DSA_EXPORT dsa_get_64bit_rtv0_slot(DSA_MASTER *dsm, DSA_RTV_SLOT **slot);
int		_DSA_EXPORT dsa_get_64bit_rtv1_slot(DSA_MASTER *dsm, DSA_RTV_SLOT **slot, int lsl, int msl);
int		_DSA_EXPORT dsa_free_64bit_rtv_slot(DSA_RTV_SLOT **slot);
int		_DSA_EXPORT dsa_assign_slot_to_register_s(DSA_DEVICE_BASE *grp, DSA_RTV_SLOT *slot, int typ, int idx, int sidx, int timeout);
int		_DSA_EXPORT dsa_assign_slot_to_register_a(DSA_DEVICE_BASE *grp, DSA_RTV_SLOT *slot, int typ, int idx, int sidx, DSA_HANDLER handler, void *param);
int		_DSA_EXPORT dsa_unassign_slot_to_register_s(DSA_DEVICE_BASE *grp, DSA_RTV_SLOT *slot, int typ, int idx, int sidx, int timeout);
int		_DSA_EXPORT dsa_unassign_slot_to_register_a(DSA_DEVICE_BASE *grp, DSA_RTV_SLOT *slot, int typ, int idx, int sidx, DSA_HANDLER handler, void *param);
int		_DSA_EXPORT dsa_assign_register_to_slot_s(DSA_DEVICE *dev, int typ, int idx, int sidx, DSA_RTV_SLOT *slot, int timeout);
int		_DSA_EXPORT dsa_assign_register_to_slot_a(DSA_DEVICE *dev, int typ, int idx, int sidx, DSA_RTV_SLOT *slot, DSA_HANDLER handler, void *param);
int		_DSA_EXPORT dsa_unassign_register_to_slot_s(DSA_DEVICE *dev, int typ, int idx, int sidx, DSA_RTV_SLOT *slot, int timeout);
int		_DSA_EXPORT dsa_unassign_register_to_slot_a(DSA_DEVICE *dev, int typ, int idx, int sidx, DSA_RTV_SLOT *slot, DSA_HANDLER handler, void *param);
int		_DSA_EXPORT dsa_read_32bit_rtv_slot(DSA_RTV_SLOT *slot, dword *value);
int		_DSA_EXPORT dsa_write_32bit_rtv_slot(DSA_RTV_SLOT *slot, dword value);
int		_DSA_EXPORT dsa_read_64bit_rtv_slot(DSA_RTV_SLOT *slot, dword *lvalue, dword *mvalue);
int		_DSA_EXPORT dsa_write_64bit_rtv_slot(DSA_RTV_SLOT *slot, dword lvalue, dword mvalue);
bool	_DSA_EXPORT dsa_is_valid_rtv_slot(DSA_RTV_SLOT *slot);
bool	_DSA_EXPORT dsa_is_32bit_rtv_slot(DSA_RTV_SLOT *slot);
bool	_DSA_EXPORT dsa_is_64bit_rtv_slot(DSA_RTV_SLOT *slot);
int		_DSA_EXPORT dsa_get_32bit_rtv_slot_nr(DSA_RTV_SLOT *slot, int *lsl);
int		_DSA_EXPORT dsa_get_64bit_rtv_slot_nr(DSA_RTV_SLOT *slot, int *lsl, int *msl);

int		_DSA_EXPORT dsa_create_rtv_read(DSA_DEVICE *dev, int reg_typ, int reg_idx, int reg_sidx, DSA_RTV_DATA **rtv_data);
int		_DSA_EXPORT dsa_create_rtv_write(DSA_DEVICE *dev, int inc_typ, DSA_RTV_DATA **rtv_data);
int		_DSA_EXPORT dsa_destroy_rtv(DSA_RTV_DATA **rtv_data);
int		_DSA_EXPORT dsa_read_rtv_int32(DSA_RTV_DATA *rtv_data, int *value);
int		_DSA_EXPORT dsa_read_rtv_int64(DSA_RTV_DATA *rtv_data, eint64 *value);
int		_DSA_EXPORT dsa_read_rtv_float32(DSA_RTV_DATA *rtv_data, float *value);
int		_DSA_EXPORT dsa_read_rtv_float64(DSA_RTV_DATA *rtv_data, double *value);
int		_DSA_EXPORT dsa_write_rtv_int32(DSA_RTV_DATA *rtv_data, int value);
int		_DSA_EXPORT dsa_write_rtv_int64(DSA_RTV_DATA *rtv_data, eint64 value);
int		_DSA_EXPORT dsa_write_rtv_float32(DSA_RTV_DATA *rtv_data, float value);
int		_DSA_EXPORT dsa_write_rtv_float64(DSA_RTV_DATA *rtv_data, double value);
bool	_DSA_EXPORT dsa_is_valid_rtv(DSA_RTV_DATA *rtv_data);
bool	_DSA_EXPORT dsa_is_read_rtv(DSA_RTV_DATA *rtv_data);
bool	_DSA_EXPORT dsa_is_write_rtv(DSA_RTV_DATA *rtv_data);
bool	_DSA_EXPORT dsa_is_int32_rtv(DSA_RTV_DATA *rtv_data);
bool	_DSA_EXPORT dsa_is_int64_rtv(DSA_RTV_DATA *rtv_data);
bool	_DSA_EXPORT dsa_is_float32_rtv(DSA_RTV_DATA *rtv_data);
bool	_DSA_EXPORT dsa_is_float64_rtv(DSA_RTV_DATA *rtv_data);
int		_DSA_EXPORT dsa_get_register_typ_idx_sidx_rtv(DSA_RTV_DATA *rtv_data, int *reg_typ, int *reg_idx, int *reg_sidx);
int		_DSA_EXPORT dsa_get_rtv_slot_of_rtv(DSA_RTV_DATA *rtv_data, DSA_RTV_SLOT **slot);
int		_DSA_EXPORT dsa_start_rtv_handler(DSA_MASTER *master, int nr, int rate, DSA_RTV_HANDLER handler, int nb_read, DSA_RTV_DATA *read_rtv[], int nb_write, DSA_RTV_DATA *write_rtv[], void *user);
int		_DSA_EXPORT dsa_start_delayed_rtv_handler(DSA_DSMAX *ultimet, int nr, int rate, int delay, DSA_RTV_HANDLER handler, int nb_read, DSA_RTV_DATA *read_rtv[], int nb_write, DSA_RTV_DATA *write_rtv[], void *user);
int		_DSA_EXPORT dsa_stop_rtv_handler(DSA_MASTER *master, int nr);
int		_DSA_EXPORT dsa_get_rtv_handler_activity(DSA_MASTER *master, int nr, bool *active);
int		_DSA_EXPORT dsa_set_watchdog(DSA_MASTER *master, double ms);
int		_DSA_EXPORT dsa_stage_mapping_download(DSA_DRIVE_GROUP *grp, const char *file_name);
int		_DSA_EXPORT dsa_stage_mapping_upload(DSA_DRIVE_GROUP *grp, const char *file_name);
int		_DSA_EXPORT dsa_stage_mapping_activate(DSA_DRIVE_BASE *grp);
int		_DSA_EXPORT dsa_stage_mapping_deactivate(DSA_DRIVE_BASE *grp);
int		_DSA_EXPORT dsa_stage_mapping_get_activation(DSA_DRIVE_BASE *grp, bool *active);
int		_DSA_EXPORT dsa_scale_mapping_download(DSA_DRIVE *drv, const char *file_name, dword pre_processing_mode);
int		_DSA_EXPORT dsa_scale_mapping_activate(DSA_DRIVE *drv, dword mode);
int		_DSA_EXPORT dsa_scale_mapping_deactivate(DSA_DRIVE *drv);
int		_DSA_EXPORT dsa_scale_mapping_get_activation(DSA_DRIVE *drv, bool *active);
int		_DSA_EXPORT dsa_ipol_get_ipol_grp(DSA_IPOL_GROUP *igrp, int *ipol_grp);
int		_DSA_EXPORT dsa_system_configuration_backup (const char *zip_file_name, int nb_url, const char* urls[], dword flag, dword optional_block_type_mask, DSA_PROGRESS progress_fct, void *puser);
int		_DSA_EXPORT dsa_system_configuration_download (const char *zip_file_name, int nb_url, const char* urls[], dword flag, DSA_PROGRESS progress_fct, void *puser);
int		_DSA_EXPORT dsa_system_configuration_check_hardware (const char *zip_file_name, int nb_url, const char* urls[], DSA_PROGRESS progress_fct, void *puser);
int		_DSA_EXPORT dsa_system_configuration_check_software (const char *zip_file_name, int nb_url, const char* urls[], bool *up_to_date, DSA_PROGRESS progress_fct, void *puser);
int		_DSA_EXPORT dsa_device_configuration_backup (const char *zip_file_name, const char* url, eint64 axes_mask, dword flag, dword avoid_block_type_mask, DSA_PROGRESS progress_fct, void *puser);
int		_DSA_EXPORT dsa_device_configuration_download(const char *zip_file_name, const char* url, dword flag, DSA_PROGRESS progress_fct, void *puser);

int		_DSA_EXPORT dsa_system_configuration_backup_fw_pool (const char *fw_pool, const char *zip_file_name, int nb_url, const char* urls[], dword flag, dword optional_block_type_mask, DSA_PROGRESS progress_fct, void *puser);
int		_DSA_EXPORT dsa_system_configuration_download_fw_pool (const char *fw_pool, const char *zip_file_name, int nb_url, const char* urls[], dword flag, DSA_PROGRESS progress_fct, void *puser);
int		_DSA_EXPORT dsa_device_configuration_backup_fw_pool (const char *fw_pool, const char *zip_file_name, const char* url, eint64 axes_mask, dword flag, dword avoid_block_type_mask, DSA_PROGRESS progress_fct, void *puser);
int		_DSA_EXPORT dsa_device_configuration_download_fw_pool(const char *fw_pool, const char *zip_file_name, const char* url, dword flag, DSA_PROGRESS progress_fct, void *puser);

/*------------------------------------------------------------------------------
 * very special functions - do not use for normal applications
 *-----------------------------------------------------------------------------*/
#ifdef DSA_IMPL_S
	int     _DSA_EXPORT dsa_quick_register_request_s(DSA_DEVICE *dev, int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout);
	int     _DSA_EXPORT dsa_quick_register_int32_request_s(DSA_DEVICE *dev, int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout);
	int     _DSA_EXPORT dsa_quick_register_int64_request_s(DSA_DEVICE *dev, int typ1, unsigned idx1, int sidx1, eint64 *val1, int typ2, unsigned idx2, int sidx2, eint64 *val2, dword *rx_time, long timeout);
	int     _DSA_EXPORT dsa_quick_register_float32_request_s(DSA_DEVICE *dev, int typ1, unsigned idx1, int sidx1, float *val1, int typ2, unsigned idx2, int sidx2, float *val2, dword *rx_time, long timeout);
	int     _DSA_EXPORT dsa_quick_register_float64_request_s(DSA_DEVICE *dev, int typ1, unsigned idx1, int sidx1, double *val1, int typ2, unsigned idx2, int sidx2, double *val2, dword *rx_time, long timeout);
	int     _DSA_EXPORT dsa_quick_address_request_s(DSA_DEVICE *dev, dword addr1, long *val1, dword addr2, long *val2, long timeout);
#endif /* DSA_IMPL_S */

#ifdef DSA_IMPL_A
	int     _DSA_EXPORT dsa_quick_register_request_a(DSA_DEVICE *dev, int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, DSA_2INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_quick_register_int32_request_a(DSA_DEVICE *dev, int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, DSA_2INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_quick_address_request_a(DSA_DEVICE *dev, dword addr1, long *val1, dword addr2, long *val2, DSA_2INT_HANDLER handler, void *param);
#endif /* DSA_IMPL_A */

/*------------------------------------------------------------------------------
 * commands - synchronous
 *-----------------------------------------------------------------------------*/
#ifdef DSA_IMPL_S
	int     _DSA_EXPORT dsa_reset_error_s(DSA_DEVICE_BASE *obj, long timeout);
	int     _DSA_EXPORT dsa_step_motion_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_execute_sequence_s(DSA_DEVICE_BASE *obj, int label, long timeout);
	int     _DSA_EXPORT dsa_execute_sequence_in_thread_s(DSA_DEVICE_BASE *obj, int label, int thread_nr, long timeout);
	int     _DSA_EXPORT dsa_stop_sequence_s(DSA_DEVICE_BASE *obj, long timeout);
	int     _DSA_EXPORT dsa_stop_sequence_in_thread_s(DSA_DEVICE_BASE *obj, int thread_nr, long timeout);
	int     _DSA_EXPORT dsa_save_parameters_s(DSA_DEVICE_BASE *obj, int what, long timeout);
	int     _DSA_EXPORT dsa_load_parameters_s(DSA_DEVICE_BASE *obj, int what, long timeout);
	int     _DSA_EXPORT dsa_default_parameters_s(DSA_DEVICE_BASE *obj, int what, long timeout);
	int		_DSA_EXPORT dsa_set_parameters_version_s(DSA_DEVICE_BASE *obj, int what, int version, long timeout);
	int		_DSA_EXPORT dsa_get_parameters_version_s(DSA_DEVICE *obj, int what, int *version, long timeout);
	int     _DSA_EXPORT dsa_wait_movement_s(DSA_DEVICE_BASE *obj, long timeout);
	int     _DSA_EXPORT dsa_wait_position_s(DSA_DEVICE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_wait_time_s(DSA_DEVICE_BASE *obj, double time, long timeout);
	int     _DSA_EXPORT dsa_wait_window_s(DSA_DEVICE_BASE *obj, long timeout);
	int     _DSA_EXPORT dsa_wait_bit_set_s(DSA_DEVICE_BASE *obj, int typ, int idx, int sidx, dword mask, long timeout);
	int     _DSA_EXPORT dsa_wait_bit_clear_s(DSA_DEVICE_BASE *obj, int typ, int idx, int sidx, dword mask, long timeout);
	int     _DSA_EXPORT dsa_wait_sgn_register_greater_s(DSA_DEVICE_BASE *obj, int typ, int idx, int sidx, double value, long timeout);
	int     _DSA_EXPORT dsa_wait_sgn_register_lower_s(DSA_DEVICE_BASE *obj, int typ, int idx, int sidx, double value, long timeout);
	int     _DSA_EXPORT dsa_user_stretch_enable_s(DSA_DRIVE_BASE *obj, double offset, float slope, long timeout);
	int     _DSA_EXPORT dsa_user_stretch_disable_s(DSA_DRIVE_BASE *obj, long timeout);
#endif /* DSA_IMPL_S */

/*------------------------------------------------------------------------------
 * commands - asynchronous
 *-----------------------------------------------------------------------------*/
#ifdef DSA_IMPL_A
	int     _DSA_EXPORT dsa_reset_error_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_step_motion_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_execute_sequence_a(DSA_DEVICE_BASE *obj, int label, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_execute_sequence_in_thread_a(DSA_DEVICE_BASE *obj, int label, int thread_nr, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_stop_sequence_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_stop_sequence_in_thread_a(DSA_DEVICE_BASE *obj, int thread_nr, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_save_parameters_a(DSA_DEVICE_BASE *obj, int what, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_load_parameters_a(DSA_DEVICE_BASE *obj, int what, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_default_parameters_a(DSA_DEVICE_BASE *obj, int what, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_set_parameters_version_a(DSA_DEVICE_BASE *obj, int what, int version, DSA_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_get_parameters_version_a(DSA_DEVICE *obj, int what, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_movement_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_position_a(DSA_DEVICE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_time_a(DSA_DEVICE_BASE *obj, double time, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_window_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_bit_set_a(DSA_DEVICE_BASE *obj, int typ, int idx, int sidx, dword mask, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_bit_clear_a(DSA_DEVICE_BASE *obj, int typ, int idx, int sidx, dword mask, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_sgn_register_greater_a(DSA_DEVICE_BASE *obj, int typ, int idx, int sidx, double value, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_wait_sgn_register_lower_a(DSA_DEVICE_BASE *obj, int typ, int idx, int sidx, double value, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_user_stretch_enable_a(DSA_DRIVE_BASE *obj, double offset, float slope, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_user_stretch_disable_a(DSA_DRIVE_BASE *obj, DSA_HANDLER handler, void *param);
#endif /* DSA_IMPL_A */

/*------------------------------------------------------------------------------
 * register getter - synchronous
 *-----------------------------------------------------------------------------*/
#ifdef DSA_IMPL_S
	int     _DSA_EXPORT dsa_get_pl_proportional_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_pl_speed_feedback_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_pl_integrator_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_pl_anti_windup_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_pl_integrator_limitation_s(DSA_DRIVE *obj, double *limit, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_pl_integrator_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_ttl_speed_filter_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_pl_acc_feedforward_gain_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_max_position_range_limit_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_following_error_window_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_velocity_error_limit_s(DSA_DRIVE *obj, double *vel, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_switch_limit_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_enable_input_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_min_soft_position_limit_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_max_soft_position_limit_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_profile_limit_mode_s(DSA_DRIVE *obj, dword *flags, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_position_window_time_s(DSA_DRIVE *obj, double *tim, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_position_window_s(DSA_DRIVE *obj, double *win, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_homing_method_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_homing_zero_speed_s(DSA_DRIVE *obj, double *vel, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_homing_acceleration_s(DSA_DRIVE *obj, double *acc, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_homing_following_limit_s(DSA_DRIVE *obj, double *win, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_homing_current_limit_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_home_offset_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_homing_fixed_mvt_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_homing_switch_mvt_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_homing_index_mvt_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_homing_fine_tuning_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_homing_fine_tuning_value_s(DSA_DRIVE *obj, double *phase, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_motor_phase_correction_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_software_current_limit_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_drive_control_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_display_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_encoder_inversion_s(DSA_DRIVE *obj, double *invert, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_encoder_phase_1_offset_s(DSA_DRIVE *obj, double *offset, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_encoder_phase_2_offset_s(DSA_DRIVE *obj, double *offset, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_encoder_phase_1_factor_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_encoder_phase_2_factor_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_encoder_index_distance_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_proportional_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_integrator_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_current_limit_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_i2t_current_limit_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_i2t_time_limit_s(DSA_DRIVE *obj, double *tim, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_init_mode_s(DSA_DRIVE *obj, int *typ, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_init_pulse_level_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_init_max_current_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_init_final_phase_s(DSA_DRIVE *obj, double *cal, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_init_time_s(DSA_DRIVE *obj, double *tim, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_init_initial_phase_s(DSA_DRIVE *obj, double *cal, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_mon_source_type_s(DSA_DRIVE *obj, int sidx, int *typ, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_mon_source_index_s(DSA_DRIVE *obj, int sidx, int *index, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_syncro_start_timeout_s(DSA_DRIVE *obj, int *tim, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_digital_output_s(DSA_DRIVE *obj, dword *out, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_x_digital_output_s(DSA_DRIVE *obj, dword *out, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_x_analog_output_1_s(DSA_DRIVE *obj, double *out, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_x_analog_output_2_s(DSA_DRIVE *obj, double *out, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_x_analog_output_3_s(DSA_DRIVE *obj, double *out, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_x_analog_output_4_s(DSA_DRIVE *obj, double *out, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_analog_output_s(DSA_DRIVE *obj, double *out, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_indirect_register_idx_s(DSA_DRIVE *obj, int *idx, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_concatenated_mvt_s(DSA_DRIVE *obj, int *concat, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_profile_type_s(DSA_DRIVE *obj, int sidx, int *typ, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_mvt_lkt_number_s(DSA_DRIVE *obj, int sidx, int *number, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_mvt_lkt_time_s(DSA_DRIVE *obj, int sidx, double *time, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_came_value_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_brake_deceleration_s(DSA_DRIVE *obj, double *dec, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_target_position_s(DSA_DRIVE *obj, int sidx, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_profile_velocity_s(DSA_DRIVE *obj, int sidx, double *vel, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_profile_acceleration_s(DSA_DRIVE *obj, int sidx, double *acc, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_jerk_time_s(DSA_DRIVE *obj, int sidx, double *tim, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_ctrl_source_type_s(DSA_DRIVE *obj, int *typ, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_ctrl_source_index_s(DSA_DRIVE *obj, int *index, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_ctrl_offset_s(DSA_DRIVE *obj, long *offset, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_ctrl_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_motor_kt_factor_s(DSA_DRIVE *obj, double *kt, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_position_ctrl_error_s(DSA_DRIVE *obj, double *err, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_position_max_error_s(DSA_DRIVE *obj, double *err, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_position_demand_value_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_position_actual_value_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_velocity_demand_value_s(DSA_DRIVE *obj, double *vel, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_velocity_actual_value_s(DSA_DRIVE *obj, double *vel, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_acc_demand_value_s(DSA_DRIVE *obj, double *acc, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_current_phase_1_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_current_phase_2_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_current_phase_3_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_lkt_phase_1_s(DSA_DRIVE *obj, double *lkt, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_lkt_phase_2_s(DSA_DRIVE *obj, double *lkt, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_lkt_phase_3_s(DSA_DRIVE *obj, double *lkt, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_demand_value_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_actual_value_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_encoder_sine_signal_s(DSA_DRIVE *obj, double *val, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_encoder_cosine_signal_s(DSA_DRIVE *obj, double *val, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_encoder_hall_dig_signal_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_digital_input_s(DSA_DRIVE *obj, dword *inp, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_analog_input_s(DSA_DRIVE *obj, double *inp, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_x_digital_input_s(DSA_DRIVE *obj, dword *inp, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_x_analog_input_1_s(DSA_DRIVE *obj, double *inp, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_x_analog_input_2_s(DSA_DRIVE *obj, double *inp, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_x_analog_input_3_s(DSA_DRIVE *obj, double *inp, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_x_analog_input_4_s(DSA_DRIVE *obj, double *inp, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_drive_status_1_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_drive_status_2_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_cl_i2t_value_s(DSA_DRIVE *obj, double *val, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_axis_number_s(DSA_DRIVE *obj, int *num, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_drive_temperature_s(DSA_DRIVE *obj, double *temp, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_drive_display_s(DSA_DRIVE *obj, int sidx, dword *str, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_drive_sequence_line_s(DSA_DRIVE *obj, long *line, int kind, long timeout);
	int     _DSA_EXPORT dsa_get_drive_fuse_status_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
	int		_DSA_EXPORT dsa_get_sequence_code_usage_s(DSA_DEVICE *dev, double *usage_percentage, long timeout);
	int		_DSA_EXPORT dsa_get_sequence_source_usage_s(DSA_DEVICE *dev, double *usage_percentage, long timeout);
	int		_DSA_EXPORT dsa_get_sequence_data_usage_s(DSA_DEVICE *dev, double *usage_percentage, long timeout);
	int		_DSA_EXPORT dsa_debug_sequence_get_nb_breakpoints_s(DSA_DEVICE *dev, int *nb_breakpoint, int kind, long timeout);
	int		_DSA_EXPORT dsa_debug_sequence_get_break_thread_nb_s(DSA_DEVICE *dev, int *breakthread, int kind, long timeout);
#endif /* DSA_IMPL_S */

/*------------------------------------------------------------------------------
 * register setter - synchronous
 *-----------------------------------------------------------------------------*/
#ifdef DSA_IMPL_S
	int     _DSA_EXPORT dsa_set_pl_proportional_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
	int     _DSA_EXPORT dsa_set_pl_speed_feedback_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
	int     _DSA_EXPORT dsa_set_pl_integrator_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
	int     _DSA_EXPORT dsa_set_pl_anti_windup_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
	int     _DSA_EXPORT dsa_set_pl_integrator_limitation_s(DSA_DRIVE_BASE *obj, double limit, long timeout);
	int     _DSA_EXPORT dsa_set_pl_integrator_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
	int     _DSA_EXPORT dsa_set_ttl_speed_filter_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
	int     _DSA_EXPORT dsa_set_pl_acc_feedforward_gain_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
	int     _DSA_EXPORT dsa_set_max_position_range_limit_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_start_movement_s(DSA_DRIVE_BASE *grp, double *targets, long timeout);
	int     _DSA_EXPORT dsa_set_following_error_window_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_set_velocity_error_limit_s(DSA_DRIVE_BASE *obj, double vel, long timeout);
	int     _DSA_EXPORT dsa_set_switch_limit_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
	int     _DSA_EXPORT dsa_set_enable_input_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
	int     _DSA_EXPORT dsa_set_min_soft_position_limit_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_set_max_soft_position_limit_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_set_profile_limit_mode_s(DSA_DRIVE_BASE *obj, dword flags, long timeout);
	int     _DSA_EXPORT dsa_set_position_window_time_s(DSA_DRIVE_BASE *obj, double tim, long timeout);
	int     _DSA_EXPORT dsa_set_position_window_s(DSA_DRIVE_BASE *obj, double win, long timeout);
	int     _DSA_EXPORT dsa_set_homing_method_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
	int     _DSA_EXPORT dsa_set_homing_zero_speed_s(DSA_DRIVE_BASE *obj, double vel, long timeout);
	int     _DSA_EXPORT dsa_set_homing_acceleration_s(DSA_DRIVE_BASE *obj, double acc, long timeout);
	int     _DSA_EXPORT dsa_set_homing_following_limit_s(DSA_DRIVE_BASE *obj, double win, long timeout);
	int     _DSA_EXPORT dsa_set_homing_current_limit_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
	int     _DSA_EXPORT dsa_set_home_offset_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_set_homing_fixed_mvt_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_set_homing_switch_mvt_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_set_homing_index_mvt_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_set_homing_fine_tuning_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
	int     _DSA_EXPORT dsa_set_homing_fine_tuning_value_s(DSA_DRIVE_BASE *obj, double phase, long timeout);
	int     _DSA_EXPORT dsa_set_motor_phase_correction_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
	int     _DSA_EXPORT dsa_set_software_current_limit_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
	int     _DSA_EXPORT dsa_set_drive_control_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
	int     _DSA_EXPORT dsa_set_display_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
	int     _DSA_EXPORT dsa_set_encoder_inversion_s(DSA_DRIVE_BASE *obj, double invert, long timeout);
	int     _DSA_EXPORT dsa_set_encoder_phase_1_offset_s(DSA_DRIVE_BASE *obj, double offset, long timeout);
	int     _DSA_EXPORT dsa_set_encoder_phase_2_offset_s(DSA_DRIVE_BASE *obj, double offset, long timeout);
	int     _DSA_EXPORT dsa_set_encoder_phase_1_factor_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
	int     _DSA_EXPORT dsa_set_encoder_phase_2_factor_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
	int     _DSA_EXPORT dsa_set_encoder_index_distance_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
	int     _DSA_EXPORT dsa_set_cl_proportional_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
	int     _DSA_EXPORT dsa_set_cl_integrator_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
	int     _DSA_EXPORT dsa_set_cl_current_limit_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
	int     _DSA_EXPORT dsa_set_cl_i2t_current_limit_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
	int     _DSA_EXPORT dsa_set_cl_i2t_time_limit_s(DSA_DRIVE_BASE *obj, double tim, long timeout);
	int     _DSA_EXPORT dsa_set_init_mode_s(DSA_DRIVE_BASE *obj, int typ, long timeout);
	int     _DSA_EXPORT dsa_set_init_pulse_level_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
	int     _DSA_EXPORT dsa_set_init_max_current_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
	int     _DSA_EXPORT dsa_set_init_final_phase_s(DSA_DRIVE_BASE *obj, double cal, long timeout);
	int     _DSA_EXPORT dsa_set_init_time_s(DSA_DRIVE_BASE *obj, double tim, long timeout);
	int     _DSA_EXPORT dsa_set_init_initial_phase_s(DSA_DRIVE_BASE *obj, double cal, long timeout);
	int     _DSA_EXPORT dsa_set_mon_source_type_s(DSA_DRIVE_BASE *obj, int sidx, int typ, long timeout);
	int     _DSA_EXPORT dsa_set_mon_source_index_s(DSA_DRIVE_BASE *obj, int sidx, int index, long timeout);
	int     _DSA_EXPORT dsa_set_syncro_start_timeout_s(DSA_DRIVE_BASE *obj, int tim, long timeout);
	int     _DSA_EXPORT dsa_set_digital_output_s(DSA_DRIVE_BASE *obj, dword out, long timeout);
	int     _DSA_EXPORT dsa_set_x_digital_output_s(DSA_DRIVE_BASE *obj, dword out, long timeout);
	int     _DSA_EXPORT dsa_set_x_analog_output_1_s(DSA_DRIVE_BASE *obj, double out, long timeout);
	int     _DSA_EXPORT dsa_set_x_analog_output_2_s(DSA_DRIVE_BASE *obj, double out, long timeout);
	int     _DSA_EXPORT dsa_set_x_analog_output_3_s(DSA_DRIVE_BASE *obj, double out, long timeout);
	int     _DSA_EXPORT dsa_set_x_analog_output_4_s(DSA_DRIVE_BASE *obj, double out, long timeout);
	int     _DSA_EXPORT dsa_set_analog_output_s(DSA_DRIVE_BASE *obj, double out, long timeout);
	int     _DSA_EXPORT dsa_set_indirect_register_idx_s(DSA_DRIVE_BASE *obj, int idx, long timeout);
	int     _DSA_EXPORT dsa_set_concatenated_mvt_s(DSA_DRIVE_BASE *obj, int concat, long timeout);
	int     _DSA_EXPORT dsa_set_profile_type_s(DSA_DRIVE_BASE *obj, int sidx, int typ, long timeout);
	int     _DSA_EXPORT dsa_set_mvt_lkt_number_s(DSA_DRIVE_BASE *obj, int sidx, int number, long timeout);
	int     _DSA_EXPORT dsa_set_mvt_lkt_time_s(DSA_DRIVE_BASE *obj, int sidx, double time, long timeout);
	int     _DSA_EXPORT dsa_set_came_value_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
	int     _DSA_EXPORT dsa_set_brake_deceleration_s(DSA_DRIVE_BASE *obj, double dec, long timeout);
	int     _DSA_EXPORT dsa_set_target_position_s(DSA_DRIVE_BASE *obj, int sidx, double pos, long timeout);
	int     _DSA_EXPORT dsa_set_profile_velocity_s(DSA_DRIVE_BASE *obj, int sidx, double vel, long timeout);
	int     _DSA_EXPORT dsa_set_profile_acceleration_s(DSA_DRIVE_BASE *obj, int sidx, double acc, long timeout);
	int     _DSA_EXPORT dsa_set_jerk_time_s(DSA_DRIVE_BASE *obj, int sidx, double tim, long timeout);
	int     _DSA_EXPORT dsa_set_ctrl_source_type_s(DSA_DRIVE_BASE *obj, int typ, long timeout);
	int     _DSA_EXPORT dsa_set_ctrl_source_index_s(DSA_DRIVE_BASE *obj, int index, long timeout);
	int     _DSA_EXPORT dsa_set_ctrl_offset_s(DSA_DRIVE_BASE *obj, long offset, long timeout);
	int     _DSA_EXPORT dsa_set_ctrl_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
	int     _DSA_EXPORT dsa_set_motor_kt_factor_s(DSA_DRIVE_BASE *obj, double kt, long timeout);
#endif /* DSA_IMPL_S */

/*------------------------------------------------------------------------------
 * IO functions - synchronous
 *-----------------------------------------------------------------------------*/
#ifdef DSA_IMPL_S
	//ExternalIO Management functions
	int     _DSA_EXPORT dsa_externalIO_set_enable_cyclic_update_s(DSA_DEVICE_BASE *dev, bool enable, long timeout);
	int     _DSA_EXPORT dsa_externalIO_reset_client_communication_s(DSA_DEVICE_BASE *dev, long timeout);
	int     _DSA_EXPORT dsa_externalIO_reset_io_cycle_count_s(DSA_DEVICE_BASE *dev, long timeout);
	int     _DSA_EXPORT dsa_externalIO_reset_max_update_time_s(DSA_DEVICE_BASE *dev, long timeout);

	//ExternalIO Watchdog functions
	int     _DSA_EXPORT dsa_externalIO_enable_watchdog_s(DSA_DEVICE_BASE *dev, long timeout);
	int     _DSA_EXPORT dsa_externalIO_disable_watchdog_s(DSA_DEVICE_BASE *dev, long timeout);
	int     _DSA_EXPORT dsa_externalIO_stop_watchdog_s(DSA_DEVICE_BASE *dev, long timeout);
	int     _DSA_EXPORT dsa_externalIO_set_watchdog_time_s(DSA_DEVICE_BASE *dev, int value, long timeout);

	//ExternalIO digital output functions
	int     _DSA_EXPORT dsa_externalIO_set_digital_output_s(DSA_DEVICE_BASE *dev, int output_idx, long timeout);
	int     _DSA_EXPORT dsa_externalIO_reset_digital_output_s(DSA_DEVICE_BASE *dev, int output_idx, long timeout);
	int     _DSA_EXPORT dsa_externalIO_apply_mask_digital_output_s(DSA_DEVICE_BASE *dev, int first_output_idx, int number_bits, dword value, long timeout);
	int     _DSA_EXPORT dsa_externalIO_get_digital_output_s(DSA_DEVICE *dev, int output_idx, dword *value, bool fast, long timeout);
	int	    _DSA_EXPORT dsa_externalIO_get_digital_output_state_s(DSA_DEVICE *dev, int output_idx, dword *value, bool fast, long timeout);
	int     _DSA_EXPORT dsa_externalIO_get_masked_digital_output_s(DSA_DEVICE *dev, int first_output_idx, int number_bits, dword *value, bool fast, long timeout);
	int		_DSA_EXPORT dsa_externalIO_get_masked_digital_output_state_s(DSA_DEVICE *dev, int first_output_idx, int number_bits, dword *value, bool fast, long timeout);

	//ExternalIO analog output functions
	int     _DSA_EXPORT dsa_externalIO_set_analog_output_raw_data_s(DSA_DEVICE_BASE *dev, int output_idx, dword value, long timeout);
	int     _DSA_EXPORT dsa_externalIO_set_analog_output_converted_data_s(DSA_DEVICE_BASE *dev, int output_idx, float value, long timeout);
	int     _DSA_EXPORT dsa_externalIO_get_analog_output_raw_data_s(DSA_DEVICE *dev, int output_idx, dword *value, bool fast, long timeout);
	int     _DSA_EXPORT dsa_externalIO_get_analog_output_raw_data_state_s(DSA_DEVICE *dev, int output_idx, dword *value, bool fast, long timeout);
	int     _DSA_EXPORT dsa_externalIO_get_analog_output_converted_data_s(DSA_DEVICE *dev, int output_idx, float *value, bool fast, long timeout);
	int     _DSA_EXPORT dsa_externalIO_get_analog_output_converted_data_state_s(DSA_DEVICE *dev, int output_idx, float *value, bool fast, long timeout);

	//ExternalIO digital input functions
	int     _DSA_EXPORT dsa_externalIO_get_digital_input_state_s(DSA_DEVICE *dev, int input_idx, dword *value, bool fast, long timeout);
	int     _DSA_EXPORT dsa_externalIO_get_masked_digital_input_state_s(DSA_DEVICE *dev, int first_input_idx, int number_bits, dword *value, bool fast, long timeout);

	//ExternalIO analog input functions
	int     _DSA_EXPORT dsa_externalIO_get_analog_input_raw_data_state_s(DSA_DEVICE *dev, int input_idx, dword *value, bool fast, long timeout);
	int     _DSA_EXPORT dsa_externalIO_get_analog_input_converted_data_state_s(DSA_DEVICE *dev, int input_idx, float *value, bool fast, long timeout);

	//ExternalIO direct modbus functions
	int     _DSA_EXPORT dsa_externalIO_set_modbus_register_s(DSA_DEVICE_BASE *dev, int register_address, dword value, long timeout);
	int     _DSA_EXPORT dsa_externalIO_get_modbus_register_s(DSA_DEVICE *dev, int register_address, int word_count, int word_number, dword *value, long timeout);

	//LocalIO digital output functions
	int     _DSA_EXPORT dsa_localIO_set_digital_output_s(DSA_DEVICE_BASE *dev, int output_idx, long timeout);
	int     _DSA_EXPORT dsa_localIO_reset_digital_output_s(DSA_DEVICE_BASE *dev, int output_idx, long timeout);
	int     _DSA_EXPORT dsa_localIO_get_digital_output_s(DSA_DEVICE *dev, int output_idx, dword *value, bool fast, long timeout);
	int     _DSA_EXPORT dsa_localIO_apply_mask_digital_output_s(DSA_DEVICE_BASE *dev, int first_output_idx, int number_bits, dword value, long timeout);
	int     _DSA_EXPORT dsa_localIO_get_masked_digital_output_s(DSA_DEVICE *dev, int first_output_idx, int number_bits, dword *value, bool fast, long timeout);

	//LocalIO digital input functions
	int     _DSA_EXPORT dsa_localIO_get_digital_input_state_s(DSA_DEVICE *dev, int input_idx, dword *value, bool fast, long timeout);
	int     _DSA_EXPORT dsa_localIO_get_masked_digital_input_state_s(DSA_DEVICE *dev, int first_input_idx, int number_bits, dword *value, bool fast, long timeout);

#endif /* DSA_IMPL_S */

/*------------------------------------------------------------------------------
 * register getter - asynchronous
 *-----------------------------------------------------------------------------*/
#ifdef DSA_IMPL_A
	int     _DSA_EXPORT dsa_get_pl_proportional_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_pl_speed_feedback_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_pl_integrator_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_pl_anti_windup_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_pl_integrator_limitation_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_pl_integrator_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_ttl_speed_filter_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_pl_acc_feedforward_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_max_position_range_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_following_error_window_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_velocity_error_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_switch_limit_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_enable_input_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_min_soft_position_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_max_soft_position_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_profile_limit_mode_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_position_window_time_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_position_window_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_homing_method_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_homing_zero_speed_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_homing_acceleration_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_homing_following_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_homing_current_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_home_offset_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_homing_fixed_mvt_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_homing_switch_mvt_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_homing_index_mvt_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_homing_fine_tuning_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_homing_fine_tuning_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_motor_phase_correction_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_software_current_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_drive_control_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_display_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_encoder_inversion_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_encoder_phase_1_offset_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_encoder_phase_2_offset_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_encoder_phase_1_factor_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_encoder_phase_2_factor_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_encoder_index_distance_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_proportional_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_integrator_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_current_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_i2t_current_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_i2t_time_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_init_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_init_pulse_level_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_init_max_current_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_init_final_phase_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_init_time_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_init_initial_phase_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_mon_source_type_a(DSA_DRIVE *obj, int sidx, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_mon_source_index_a(DSA_DRIVE *obj, int sidx, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_syncro_start_timeout_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_digital_output_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_x_digital_output_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_x_analog_output_1_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_x_analog_output_2_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_x_analog_output_3_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_x_analog_output_4_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_analog_output_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_indirect_register_idx_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_concatenated_mvt_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_profile_type_a(DSA_DRIVE *obj, int sidx, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_mvt_lkt_number_a(DSA_DRIVE *obj, int sidx, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_mvt_lkt_time_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_came_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_brake_deceleration_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_target_position_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_profile_velocity_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_profile_acceleration_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_jerk_time_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_ctrl_source_type_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_ctrl_source_index_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_ctrl_offset_a(DSA_DRIVE *obj, int kind, DSA_LONG_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_ctrl_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_motor_kt_factor_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_position_ctrl_error_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_position_max_error_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_position_demand_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_position_actual_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_velocity_demand_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_velocity_actual_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_acc_demand_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_current_phase_1_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_current_phase_2_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_current_phase_3_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_lkt_phase_1_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_lkt_phase_2_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_lkt_phase_3_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_demand_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_actual_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_encoder_sine_signal_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_encoder_cosine_signal_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_encoder_hall_dig_signal_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_digital_input_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_analog_input_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_x_digital_input_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_x_analog_input_1_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_x_analog_input_2_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_x_analog_input_3_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_x_analog_input_4_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_drive_status_1_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_drive_status_2_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_cl_i2t_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_axis_number_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_drive_temperature_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_drive_display_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DWORD_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_drive_sequence_line_a(DSA_DRIVE *obj, int kind, DSA_LONG_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_get_drive_fuse_status_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_debug_sequence_get_nb_breakpoints_a(DSA_DEVICE *dev, int kind, DSA_INT_HANDLER handler, void *param);
	int		_DSA_EXPORT dsa_debug_sequence_get_break_thread_nb_a(DSA_DEVICE *dev, int kind, DSA_INT_HANDLER handler, void *param);
#endif /* DSA_IMPL_A */

/*------------------------------------------------------------------------------
 * register setter - asynchronous
 *-----------------------------------------------------------------------------*/
#ifdef DSA_IMPL_A
	int     _DSA_EXPORT dsa_set_pl_proportional_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_pl_speed_feedback_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_pl_integrator_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_pl_anti_windup_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_pl_integrator_limitation_a(DSA_DRIVE_BASE *obj, double limit, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_pl_integrator_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_ttl_speed_filter_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_pl_acc_feedforward_gain_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_max_position_range_limit_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_start_movement_a(DSA_DRIVE_BASE *grp, double *targets, DSA_HANDLER, void *param);
	int     _DSA_EXPORT dsa_set_following_error_window_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_velocity_error_limit_a(DSA_DRIVE_BASE *obj, double vel, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_switch_limit_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_enable_input_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_min_soft_position_limit_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_max_soft_position_limit_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_profile_limit_mode_a(DSA_DRIVE_BASE *obj, dword flags, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_position_window_time_a(DSA_DRIVE_BASE *obj, double tim, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_position_window_a(DSA_DRIVE_BASE *obj, double win, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_homing_method_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_homing_zero_speed_a(DSA_DRIVE_BASE *obj, double vel, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_homing_acceleration_a(DSA_DRIVE_BASE *obj, double acc, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_homing_following_limit_a(DSA_DRIVE_BASE *obj, double win, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_homing_current_limit_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_home_offset_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_homing_fixed_mvt_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_homing_switch_mvt_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_homing_index_mvt_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_homing_fine_tuning_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_homing_fine_tuning_value_a(DSA_DRIVE_BASE *obj, double phase, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_motor_phase_correction_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_software_current_limit_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_drive_control_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_display_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_encoder_inversion_a(DSA_DRIVE_BASE *obj, double invert, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_encoder_phase_1_offset_a(DSA_DRIVE_BASE *obj, double offset, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_encoder_phase_2_offset_a(DSA_DRIVE_BASE *obj, double offset, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_encoder_phase_1_factor_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_encoder_phase_2_factor_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_encoder_index_distance_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_cl_proportional_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_cl_integrator_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_cl_current_limit_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_cl_i2t_current_limit_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_cl_i2t_time_limit_a(DSA_DRIVE_BASE *obj, double tim, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_init_mode_a(DSA_DRIVE_BASE *obj, int typ, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_init_pulse_level_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_init_max_current_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_init_final_phase_a(DSA_DRIVE_BASE *obj, double cal, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_init_time_a(DSA_DRIVE_BASE *obj, double tim, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_init_initial_phase_a(DSA_DRIVE_BASE *obj, double cal, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_mon_source_type_a(DSA_DRIVE_BASE *obj, int sidx, int typ, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_mon_source_index_a(DSA_DRIVE_BASE *obj, int sidx, int index, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_syncro_start_timeout_a(DSA_DRIVE_BASE *obj, int tim, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_digital_output_a(DSA_DRIVE_BASE *obj, dword out, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_x_digital_output_a(DSA_DRIVE_BASE *obj, dword out, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_x_analog_output_1_a(DSA_DRIVE_BASE *obj, double out, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_x_analog_output_2_a(DSA_DRIVE_BASE *obj, double out, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_x_analog_output_3_a(DSA_DRIVE_BASE *obj, double out, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_x_analog_output_4_a(DSA_DRIVE_BASE *obj, double out, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_analog_output_a(DSA_DRIVE_BASE *obj, double out, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_indirect_register_idx_a(DSA_DRIVE_BASE *obj, int idx, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_concatenated_mvt_a(DSA_DRIVE_BASE *obj, int concat, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_profile_type_a(DSA_DRIVE_BASE *obj, int sidx, int typ, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_mvt_lkt_number_a(DSA_DRIVE_BASE *obj, int sidx, int number, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_mvt_lkt_time_a(DSA_DRIVE_BASE *obj, int sidx, double time, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_came_value_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_brake_deceleration_a(DSA_DRIVE_BASE *obj, double dec, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_target_position_a(DSA_DRIVE_BASE *obj, int sidx, double pos, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_profile_velocity_a(DSA_DRIVE_BASE *obj, int sidx, double vel, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_profile_acceleration_a(DSA_DRIVE_BASE *obj, int sidx, double acc, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_jerk_time_a(DSA_DRIVE_BASE *obj, int sidx, double tim, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_ctrl_source_type_a(DSA_DRIVE_BASE *obj, int typ, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_ctrl_source_index_a(DSA_DRIVE_BASE *obj, int index, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_ctrl_offset_a(DSA_DRIVE_BASE *obj, long offset, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_ctrl_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
	int     _DSA_EXPORT dsa_set_motor_kt_factor_a(DSA_DRIVE_BASE *obj, double kt, DSA_HANDLER handler, void *param);
#endif /* DSA_IMPL_A */

/** @} */

#ifdef __cplusplus
	} /* extern "C" */
#endif

/**********************************************************************************************************/
/*- C++ WRAPPER CLASSES */
/**********************************************************************************************************/

/*------------------------------------------------------------------------------
 * DSA constants - c++
 *-----------------------------------------------------------------------------*/

#ifdef DSA_OO_API

class Dsa;
class DsaException;
class DsaBase;
class DsaDeviceBase;
class DsaHandlerDeviceBase;
class DsaDevice;
class DsaDeviceGroup;
class DsaDriveBase;
class DsaDrive;
class DsaDriveGroup;
class DsaGantry;
class DsaMasterBase;
class DsaMaster;
class DsaMasterGroup;
class DsaDsmax;
class DsaDsmaxGroup;
class DsaIpolGroup;
class DsaAcquisition;
class DsaRTVData;
class DsaRTVSlot;

/*------------------------------------------------------------------------------
 * generate exceptions from error codes
 *-----------------------------------------------------------------------------*/
#define ERRCHK(a) do { int _err = (a); if(_err) throw DsaException(_err); } while(0)
#define ERRTRANS() do { if(getTransLevel() > 0) throw DsaException(DSA_EBADSTATE); } while(0)


/*------------------------------------------------------------------------------
 * asynchronous handler types
 *-----------------------------------------------------------------------------*/
typedef void (DSA_CALLBACK *DsaHandler)(DSA_DEVICE_BASE *dev, int err, void *param);
typedef void (DSA_CALLBACK *DsaIntHandler)(DSA_DEVICE_BASE *dev, int err, void *param, int val);
//typedef void (DSA_CALLBACK *DsaLongHandler)(DSA_DEVICE_BASE *dev, int err, void *param, long val);
typedef void (DSA_CALLBACK *DsaLongHandler)(DsaHandlerDeviceBase dev, int err, void *param, long val);
typedef void (DSA_CALLBACK *DsaInt64Handler)(DSA_DEVICE_BASE *dev, int err, void *param, eint64 val);
typedef void (DSA_CALLBACK *DsaDWordHandler)(DSA_DEVICE_BASE *dev, int err, void *param, dword val);
typedef void (DSA_CALLBACK *DsaFloatHandler)(DSA_DEVICE_BASE *dev, int err, void *param, float val);
typedef void (DSA_CALLBACK *DsaDoubleHandler)(DSA_DEVICE_BASE *dev, int err, void *param, double val);
typedef void (DSA_CALLBACK *DsaStatusHandler)(DSA_DEVICE_BASE *dev, int err, void *param, const DsaStatus *stat);
typedef void (DSA_CALLBACK *Dsa2intHandler)(DSA_DEVICE_BASE *dev, int err, void *param, int val1, int val2);
typedef void (DSA_CALLBACK *DsaRTVHandler)(DSA_DEVICE_BASE *dev, int nr, int nb_read, DSA_RTV_DATA **read_rtv, int nb_write, DSA_RTV_DATA **write_rtv, void *param);
typedef void (DSA_CALLBACK *DsaProgress)(const char *text, void *puser);

/*------------------------------------------------------------------------------
 * DSAException Class - c++
 *-----------------------------------------------------------------------------*/
class DsaException {
    friend class Dsa;
    friend class DsaBase;
    friend class DsaDeviceBase;
    friend class DsaHandlerDeviceBase;
    friend class DsaDevice;
    friend class DsaDeviceGroup;
    friend class DsaDriveBase;
    friend class DsaDrive;
    friend class DsaDriveGroup;
    friend class DsaGantry;
    friend class DsaMasterBase;
    friend class DsaMaster;
    friend class DsaMasterGroup;
    friend class DsaDsmax;
    friend class DsadsmaxGroup;
    friend class DsaIpolGroup;
    friend class DsaAcquisition;
    friend class DsaRTVData;
    friend class DsaRTVSlot;

    /* error codes - c++ */
public:
		    enum {EACQDEVINUSE = -337 };                    /* One of the device is already doing an acquisition */
    enum {EACQNOTPOSSIBLE = -336 };                 /* Drives must be connected with transnet */
    enum {EBADDRIVER = -328 };                      /* wrong version of the installed device driver */
    enum {EBADDRVVER = -325 };                      /* a drive with a bad version has been detected */
    enum {EBADIPOLGRP = -327 };                     /* the ipol group is not correctly defined */
    enum {EBADLIBRARY = -333 };                     /* function of external library not found */
    enum {EBADPARAM = -322 };                       /* one of the parameter is not valid */
    enum {EBADSEQVERSION = -338 };                  /* the sequence version is not correct */
    enum {EBADSTATE = -324 };                       /* this operation is not allowed in this state */
    enum {EBUSERROR = -313 };                       /* the underlaying etel-bus is not working fine */
    enum {EBUSRESET = -314 };                       /* the underlaying etel-bus in performing a reset operation */
    enum {ECANCEL = -319 };                         /* the transaction has been canceled */
    enum {ECFGCOMPFILE = -339 };                    /* File has been compiled for a different axes configuration */
    enum {ECONVERT = -317 };                        /* a parameter exceeded the permitted range */
    enum {EDRVERROR = -311 };                       /* drive in error */
    enum {EDRVFAILED = -323 };                      /* the drive does not operate properly */
    enum {EEQUATION = -340 };                       /* Equation cannot be resolved */
    enum {EINTERNAL = -316 };                       /* some internal error in the etel software */
    enum {EMAPNOTACTIVATED = -335 };                /* Mapping cannot be activated by the device */
    enum {ENOACK = -312 };                          /* no acknowledge from the drive */
    enum {ENODRIVE = -320 };                        /* the specified drive does not respond */
    enum {ENOFREESLOT = -330 };                     /* no free slot available */
    enum {ENOLIBRARY = -332 };                      /* external library not found */
    enum {ENOTIMPLEMENTED = -326 };                 /* the specified operation is not implemented */
    enum {EOBSOLETE = -329 };                       /* function is obsolete */
    enum {EOPENPORT = -321 };                       /* the specified port cannot be open */
    enum {ERTVREADSYNCRO = -331 };                  /* RTV read synchronisation error */
    enum {ESYNTAX = -334 };                         /* Mapping file syntax error */
    enum {ESYSTEM = -315 };                         /* some system resource return an error */
    enum {ETIMEOUT = -310 };                        /* a timeout has occured */
    enum {ETRANS = -318 };                          /* a transaction error has occured */



    /* exception code */
	private:
		int code;

    /* constructor */
	protected:
		DsaException(int e) { code = e; };

    /* translate error code */
	public:
		static char_cp translate(int code) {
			return dsa_translate_error(code);
		}

    /* get error description */
	public:
		int getCode() {
			return code;
		}
		const char *getText() {
			return translate(code);
		}
};

/*------------------------------------------------------------------------------
 * Dsa Class - c++
 *-----------------------------------------------------------------------------*/
class Dsa {
    /*
     * timeout special values
     */
	public:
		enum { DEF_TIMEOUT = (-2L) };                   /* use the default timeout appropriate for this communication */

    /*
     * convert special value
     */
	public:
		enum { CONV_AUTO = -1 };                        /* read current drive value, bypass pending commands */

    /*
     * register kind of access
     */
	public:
		enum { GET_CURRENT = 0 };                       /* read current drive value, bypass pending commands */
		enum { GET_CONV_FACTOR = 10 };                  /* get the conversion factor */
		enum { GET_MIN_VALUE = 11 };                    /* get the minimum value */
		enum { GET_MAX_VALUE = 12 };                    /* get the maximum value */
		enum { GET_DEF_VALUE = 13 };                    /* get the default value */

    /*
     * parameters enumeration values - c++
     */
	public:
		enum { ANALOG = 0 };                             /* analog sine/cosine encoder */
		enum { CONTINUOUS_CURRENT = 2 };                 /* initialisation by sending continous to the motor */
		enum { CURRENT_PULSE = 1 };                      /* initialisation with current pulses */
		enum { DEFAULT_ALL = 0 };			             /* restore all informations from ROM default */
		enum { DEFAULT_SEQ_LKT = 1 };                    /* restore sequence and user lookup-tables from ROM default */
		enum { DEFAULT_K_C_PARAMS = 2 };		         /* restore K, and KL, KF, KD, C, CL, CF CD if any, parameters from ROM default */
		enum { DEFAULT_K_RESET_E_PARAMS = 3 };           /* restore K, KL, KF, KD parameters from ROM default, reset EL parameters*/
		enum { DEFAULT_C_PARAMS = 4 };			         /* restore C, CL, CF, CD parameters from ROM default */
		enum { DEFAULT_X_PARAMS = 5 };			         /* reset X, XL, XF, XD parameters */
		enum { DEFAULT_L_PARAMS	= 6 };			         /* reset LD parameters */
		enum { DEFAULT_SEQUENCES = 7 };			         /* reset sequences */
		enum { DEFAULT_E_PARAMS	= 8 };			         /* reset E parameters */
		enum { DEFAULT_P_PARAMS	= 9 };			         /* reset P parameters */
		enum { LOAD_ALL = 0 };					         /* load all informations from flash memory */
		enum { LOAD_SEQ_LKT = 1 };				         /* load sequence and user lookup-tables from flash memory */
		enum { LOAD_K_C_E_X_PARAMS = 2 };		         /* load K, KL, KF, KD, C, CL, CF, CD, EL, X, XL, XF, XD parameters from flash memory */
		enum { LOAD_K_PARAMS = 3 };				         /* load K, KL, KF, KD parameters from flash memory */
		enum { LOAD_C_PARAMS = 4 };				         /* load C, CL, CF, CD parameters from flash memory */
		enum { LOAD_X_PARAMS = 5 };				         /* load X, XL, XF, XD parameters from flash memory */
		enum { LOAD_L_PARAMS = 6 };				         /* load LD parameters from flash memory */
		enum { LOAD_SEQUENCES = 7 };				     /* load sequences from flash memory */
		enum { LOAD_E_PARAMS = 8 };				         /* load EL parameters from flash memory */
		enum { LOAD_P_PARAMS = 9 };				         /* load P parameters from flash memory */
		enum { SAVE_ALL = 0 };				             /* save all informations in flash memory */
		enum { SAVE_SEQ_LKT = 1 };				         /* save sequence and user lookup-tables in flash memory */
		enum { SAVE_K_C_E_X_PARAMS = 2 };		         /* save K, KL, KF, KD, C, CL, CF, CD, EL, X, XL, XF, XD parameters in flash memory */
		enum { SAVE_K_PARAMS = 3 };				         /* save K, KL, KF, KD parameters in flash memory */
		enum { SAVE_C_PARAMS = 4 };				         /* save C, CL, CF, CD parameters in flash memory */
		enum { SAVE_X_PARAMS = 5 };				         /* save X, XL, XF, XD parameters in flash memory */
		enum { SAVE_L_PARAMS = 6 };				         /* save LD parameters in flash memory */
		enum { SAVE_SEQUENCES = 7 };			         /* save sequences in flash memory */
		enum { SAVE_K_E_PARAMS = 8 };			         /* save K, KL, KF, KD, EL parameters in flash memory */
		enum { SAVE_P_PARAMS = 9 };				         /* save P parameters in flash memory */
		enum { DISPLAY_ENCODER_SIGNALS = 4 };            /* display encoder's signals */
		enum { DISPLAY_NORMAL = 1 };                     /* display normal informations */
		enum { DISPLAY_SEQUENCE = 8 };                   /* display sequence line number */
		enum { DISPLAY_TEMPERATURE = 2 };                /* display drive's temperature */
		enum { ENABLE_AUTO = 170 };                      /* enable signal perform automatic power on of the drive */
		enum { ENABLE_NOT_USED = 125 };                  /* enable signal not used */
		enum { ENABLE_USED = 0 };                        /* enable signal is necessary to power on ths drive */
		enum { FORCE_REFERENCE = 0 };                    /* driver controlled by a force reference */
		enum { GATED_INDEX_NEG = 17 };                   /*  */
		enum { GATED_INDEX_NEG_L = 19 };                 /*  */
		enum { GATED_INDEX_POS = 16 };                   /*  */
		enum { GATED_INDEX_POS_L = 18 };                 /*  */
		enum { HALL = 2 };                               /* HALL effect encoder */
		enum { HOME_INVERTED = 2 };                      /* home switch is inverted */
		enum { HOME_SW_NEG = 3 };                        /*  */
		enum { HOME_SW_NEG_L = 7 };                      /*  */
		enum { HOME_SW_POS = 2 };                        /*  */
		enum { HOME_SW_POS_L = 6 };                      /*  */
		enum { HOME_SWITCH = 128 };                      /* home switch is used */
		enum { TRAPEZIODAL_MVT = 0 };                    /* trapezoidal motion (jerk = infinite) (obsolete DSB) */
		enum { S_CURVE_MVT = 1 };                        /* s-curve motion */
		enum { RECTANGULAR_MVT = 2 };                    /* trapezoidal motion (jerk = 0, acc = infinite) (obsolete DSB) */
		enum { PREDEFINED_PROFILE_MVT = 3 };             /* predefined profile motion (DSC family only) */
		enum { SLOW_LKT_MVT = 10 };                      /* lookup-table motion in profile interrupt (DSC family only)*/
		enum { FAST_LKT_MVT = 11 };                      /* lookup-table motion in controller interrupt (DSC family only) */
		enum { ROTARY_S_CURVE_MVT = 17 };                /* rotary s-curve motion */
		enum { ROTARY_PREDEFINED_PROFILE_MVT = 19 };     /* rotary predefined profile motion (DSC family only) */
		enum { INFINITE_ROTARY_MVT = 24 };               /* infinite rotary motion */
		enum { ROTARY_LKT_MVT = 26 };		             /* rotary lookup-table motion (DSC family only) */
		enum { INTEGRATOR_IN_POSITION = 1 };             /* integrator off during motion */
		enum { INTEGRATOR_OFF = 2 };                     /* integrator always off */
		enum { INTEGRATOR_ON = 0 };                      /* integrator always on */
		enum { INVERT_FORCE = 2 };                       /* invert current force of the motor */
		enum { INVERT_PHASES = 1 };                      /* invert phases 1 and 2 of the motor */
		enum { LIMIT_SW_NEG = 5 };                       /*  */
		enum { LIMIT_SW_POS = 4 };                       /*  */
		enum { LIMIT_SWITCH = 1 };                       /* limit switch are used */
		enum { MECHANICAL_NEG = 1 };                     /*  */
		enum { MECHANICAL_POS = 0 };                     /*  */
		enum { MULTI_INDEX_NEG = 13 };                   /*  */
		enum { MULTI_INDEX_NEG_L = 15 };                 /*  */
		enum { MULTI_INDEX_POS = 12 };                   /*  */
		enum { MULTI_INDEX_POS_L = 14 };                 /*  */
		enum { NO_INIT = 0 };                            /* no initialisation */
		enum { POSITION_PROFILE = 1 };                   /* standard position profile mode */
		enum { POSITION_REFERENCE = 4 };                 /* driver controlled by a position reference */
		enum { PULSE_DIRECTION = 5 };                    /* pulse and direction mode */
		enum { PULSE_DIRECTION_TTL = 6 };                /* pulse and direction mode with TTL encoder */
		enum { QS_BYPASS = 2 };                          /* bypass all pending command */
		enum { QS_INFINITE_DEC = 1 };                    /* stop motor with infinite deceleration (step) */
		enum { QS_POWER_OFF = 0 };                       /* switch off power bridge */
		enum { QS_PROGRAMMED_DEC = 2 };                  /* stop motor with programmed deceleration */
		enum { QS_STOP_SEQUENCE = 1 };                   /* also stop the sequence */
		enum { REGEN_LIMITED = 2 };                      /* regeneration of, max 10s */
		enum { REGEN_OFF = 0 };                          /* no regeneration */
		enum { REGEN_ON = 3 };                           /* regeneration always on */
		enum { ROTATION_PLAN_XT = 2 };                   /* rotation of the XTheta plan */
		enum { ROTATION_PLAN_XY = 0 };                   /* rotation of the XY plan */
		enum { ROTATION_PLAN_XZ = 1 };                   /* rotation of the XZ plan */
		enum { ROTATION_PLAN_YT = 4 };                   /* rotation of the YT plan */
		enum { ROTATION_PLAN_YZ = 3 };                   /* rotation of the YZ plan */
		enum { ROTATION_PLAN_ZT = 5 };                   /* rotation of the ZT plan */
		enum { SINGLE_INDEX_NEG = 9 };                   /*  */
		enum { SINGLE_INDEX_NEG_L = 11 };                /*  */
		enum { SINGLE_INDEX_POS = 8 };                   /*  */
		enum { SINGLE_INDEX_POS_L = 10 };                /*  */
		enum { SOURCE_MONITORING = 3 };                  /* monitoring of a monitoring register */
		enum { SOURCE_OFF = 0 };                         /* no real time monitoring */
		enum { SOURCE_PARAMETER = 2 };                   /* monitoring of a parameter */
		enum { SOURCE_USER_VARIABLE = 1 };               /* monitoring of a user variable */
		enum { SPEED_REFERENCE = 3 };                    /* driver controlled by a speed reference */
		enum { TTL = 1 };                                /* TTL encoder */
		enum { PARAM_K_PARAMS = 3};                      /* refers to K, KL, KF, KD parameters (AccurET-family: SAV, RES, NEW, STV)*/
		enum { PARAM_C_PARAMS = 4};						 /* refers to C, CL, CF, CD parameters (AccurET-family: SAV, RES, NEW, STV)*/
		enum { PARAM_X_PARAMS = 5};						 /* refers to X, XL, XF, XD parameters (AccurET-family: SAV, RES, NEW, STV)*/
		enum { PARAM_L_PARAMS = 6};						 /* refers to LD parameters (AccurET-family: SAV, RES, NEW, STV)*/
		enum { PARAM_SEQUENCES = 7};		             /* refers to sequences (AccurET-family: SAV, RES, NEW, STV)*/
		enum { PARAM_K_E_PARAMS = 8};					 /* refers to K, KL, KF, KD, EL parameters (AccurET-family: SAV, RES, NEW, STV)*/
		enum { PARAM_P_PARAMS = 9};					     /* refers to P parameters (AccurET-family: SAV, RES, NEW, STV)*/

		enum { SCALE_MAPPING_MODE_ZERO_EDGE = 1};        /* 0 will be add at each eand of the scaling area */
		enum { SCALE_MAPPING_MODE_SPLINE = 2};			 /* the points defined in scaling area will be splined */

		enum { SYSTEM_CONFIGURATION_BINARY = 0};		 /* Backup binary blocks */
		enum { SYSTEM_CONFIGURATION_TXT = 1};		     /* Backup text blocks (Will be available in the future) */

		enum { SCALE_MAPPING_LINEAR_ACTIVATION = 0};    /* Activation of linear scale-mapping */
		enum { SCALE_MAPPING_CYCLIC_ACTIVATION = 1};	/* Activation of cyclic scale-mapping */
		
    /*
     * STA-STI flags
     */
	public:
		enum {STA_POS = 0x01 };                  /* get the K210 specified depth as position for the next move*/
		enum {STA_SPD = 0x02 };                  /* get the K211 specified depth as speed for the next move*/
		enum {STA_ACC = 0x04 };                  /* get the K212 specified depth as acceleration for the next move*/
		enum {STA_JRK = 0x08 };                  /* get the K213 specified depth as jerk for the next move*/
    /*
     * special functions - c++
     */
	public:
		static DsaDeviceBase createAuto(int prod);
		static DsaDeviceBase etcomCreateAuto(EtbBus etb, int axis);

		static char_cp translateEdiError(int code) {
			return dsa_translate_edi_error(code);
		}
		static void setPrio(int prio) {
			ERRCHK(dsa_set_prio(prio));
		}
		static dword getVersion() {
			return dsa_get_version();
		}
		static time_t getBuildTime() {
			return dsa_get_build_time();
		}
		static dword getTimer() {
			return dsa_get_timer();
		}
		static dword getEdiVersion() {
			return dsa_get_edi_version();
		}
		static void beginSyncTrans() {
			ERRCHK(dsa_begin_sync_trans());
		}
		static void rollbackSyncTrans() {
			ERRCHK(dsa_rollback_sync_trans());
		}
		static void commitSyncTrans(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_commit_sync_trans(timeout));
		}
		static void beginAsyncTrans() {
			ERRCHK(dsa_begin_async_trans());
		}
		static void rollbackAsyncTrans() {
			ERRCHK(dsa_rollback_async_trans());
		}
		static int  getTransLevel() {
			int  level;
			ERRCHK(dsa_get_trans_level(&level));
			return level;
		}
		static void commitAsyncTrans(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_commit_async_trans(NULL, *(DSA_HANDLER*)&handler, param));
		}
		static void systemConfigurationBackup(const char *zipFileName, int nbUrl, const char *urls[], dword flag, dword optionalBlockTypeMask, DsaProgress progressHandler, void *param = NULL) {
			ERRCHK(dsa_system_configuration_backup (zipFileName, nbUrl, urls, flag, optionalBlockTypeMask, *(DSA_PROGRESS*)&progressHandler, param));
		}
		static void systemConfigurationDownload(const char *zipFileName, int nbUrl, const char *urls[], dword flag, DsaProgress progressHandler, void *param = NULL) {
			ERRCHK(dsa_system_configuration_download (zipFileName, nbUrl, urls, flag, *(DSA_PROGRESS*)&progressHandler, param));
		}
		static void systemConfiguratioCheckHardware(const char *zipFileName, int nbUrl, const char *urls[], DsaProgress progressHandler, void *param = NULL) {
			ERRCHK(dsa_system_configuration_check_hardware (zipFileName, nbUrl, urls, *(DSA_PROGRESS*)&progressHandler, param));
		}
		static bool systemConfiguratioCheckSoftware(const char *zipFileName, int nbUrl, const char *urls[], DsaProgress progressHandler, void *param = NULL) {
			bool upToDate;
			ERRCHK(dsa_system_configuration_check_software (zipFileName, nbUrl, urls, &upToDate, *(DSA_PROGRESS*)&progressHandler, param));
			return upToDate;
		}
		static void deviceConfigurationBackup(const char *zipFileName, const char *url, eint64 axesMask, dword flag, dword optionalBlockTypeMask, DsaProgress progressHandler, void *param = NULL) {
			ERRCHK(dsa_device_configuration_backup (zipFileName, url, axesMask, flag, optionalBlockTypeMask, *(DSA_PROGRESS*)&progressHandler, param));
		}
		static void deviceConfigurationDownload(const char *zipFileName, const char *url, dword flag, DsaProgress progressHandler, void *param = NULL) {
			ERRCHK(dsa_device_configuration_download (zipFileName, url, flag, *(DSA_PROGRESS*)&progressHandler, param));
		}

		static void systemConfigurationBackup(const char *fwPool, const char *zipFileName, int nbUrl, const char *urls[], dword flag, dword optionalBlockTypeMask, DsaProgress progressHandler, void *param = NULL) {
			ERRCHK(dsa_system_configuration_backup_fw_pool (fwPool, zipFileName, nbUrl, urls, flag, optionalBlockTypeMask, *(DSA_PROGRESS*)&progressHandler, param));
		}
		static void systemConfigurationDownload(const char *fwPool, const char *zipFileName, int nbUrl, const char *urls[], dword flag, DsaProgress progressHandler, void *param = NULL) {
			ERRCHK(dsa_system_configuration_download_fw_pool (fwPool, zipFileName, nbUrl, urls, flag, *(DSA_PROGRESS*)&progressHandler, param));
		}
		static void deviceConfigurationBackup(const char *fwPool, const char *zipFileName, const char *url, eint64 axesMask, dword flag, dword optionalBlockTypeMask, DsaProgress progressHandler, void *param = NULL) {
			ERRCHK(dsa_device_configuration_backup_fw_pool (fwPool, zipFileName, url, axesMask, flag, optionalBlockTypeMask, *(DSA_PROGRESS*)&progressHandler, param));
		}
		static void deviceConfigurationDownload(const char *fwPool, const char *zipFileName, const char *url, dword flag, DsaProgress progressHandler, void *param = NULL) {
			ERRCHK(dsa_device_configuration_download_fw_pool (fwPool, zipFileName, url, flag, *(DSA_PROGRESS*)&progressHandler, param));
		}

};


/*------------------------------------------------------------------------------
 * DsaBase Class - c++
 *-----------------------------------------------------------------------------*/
class DsaBase: public Dsa {
    friend class DsaDeviceBase;
    friend class DsaDevice;
    friend class DsaDeviceGroup;
    friend class DsaDriveBase;
    friend class DsaDrive;
    friend class DsaDriveGroup;
    friend class DsaGantry;
    friend class DsaMasterBase;
    friend class DsaMaster;
    friend class DsaMasterGroup;
    friend class DsaDsmax;
    friend class DsaDsmaxGroup;
    friend class DsaIpolGroup;

    /*
     * member variable
     */
	protected:
		DSA_DEVICE_BASE *dsa;

    /*
     * constructors - destructor
     */
	protected:
		DsaBase(void) {
			this->dsa = NULL;
		}
		DsaBase(DsaBase &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
	public:
		//Only destructor of the Dsa devices c++ structure
		~DsaBase(void) {
			if (dsa)
				ERRCHK(dsa_destroy(&dsa));
		}

	public:
		DSA_DEVICE_BASE* getDsaStructure() {
			return(dsa);
		}
	/*
	 * default operators
	 */
	protected:
		DsaBase operator = (DsaBase &obj) {
			return obj;
		}

		/*
		 * hand make functions
		 */
		DsaBase getGroupItem(int pos) {
			DsaBase obj;
			ERRCHK(dsa_get_group_item(dsa, pos, &obj.dsa));
			ERRCHK(dsa_share(obj.dsa));
			return obj;
		}
		DsaMaster getMaster(void);
		void setMaster(DsaMaster master);

	/*
	 * special functions - c++
	 */
	protected:
		void powerOn(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_power_on_s(dsa, timeout));
		}
		void powerOff(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_power_off_s(dsa, timeout));
		}
		void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_new_setpoint_s(dsa, sidx, flags, timeout));
		}
		void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_change_setpoint_s(dsa, sidx, flags, timeout));
		}
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_quick_stop_s(dsa, mode, flags, timeout));
		}
		void homingStart(long timeout = 10000) {
			ERRCHK(dsa_homing_start_s(dsa, timeout));
		}
		int  getWarningCode(int kind, long timeout = DEF_TIMEOUT) {
			int  code;
			ERRCHK(dsa_get_warning_code_s(dsa, &code, kind, timeout));
			return code;
		}
		int  getErrorCode(int kind, long timeout = DEF_TIMEOUT) {
			int  code;
			ERRCHK(dsa_get_error_code_s(dsa, &code, kind, timeout));
			return code;
		}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_execute_command_s(dsa, cmd, fast, ereport, timeout));
		}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_execute_command_d_s(dsa, cmd, typ1, par1, fast, ereport, timeout));
		}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_execute_command_i_s(dsa, cmd, typ1, par1, conv1, fast, ereport, timeout));
		}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_execute_command_dd_s(dsa, cmd, typ1, par1, typ2, par2, fast, ereport, timeout));
		}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_execute_command_id_s(dsa, cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout));
		}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_execute_command_di_s(dsa, cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout));
		}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_execute_command_ii_s(dsa, cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout));
		}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_execute_command_x_s(dsa, cmd, *(DSA_COMMAND_PARAM **)&params, count, fast, ereport, timeout));
		}
		void startProfiledMovement(double pos, double speed, double acc, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_start_profiled_movement_s(dsa, pos, speed, acc, timeout));
		}
		void startRelativeProfiledMovement(double relativePos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_start_relative_profiled_movement_s(dsa, relativePos, timeout));
		}

		long getRegister(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {
			long  val;
			ERRCHK(dsa_get_register_s(dsa, typ, idx, sidx, &val, kind, timeout));
			return val;
		}
		long getRegisterInt32(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {
			long  val;
			ERRCHK(dsa_get_register_int32_s(dsa, typ, idx, sidx, &val, kind, timeout));
			return val;
		}
		eint64 getRegisterInt64(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {
			eint64  val;
			ERRCHK(dsa_get_register_int64_s(dsa, typ, idx, sidx, &val, kind, timeout));
			return val;
		}
		float getRegisterFloat32(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {
			float  val;
			ERRCHK(dsa_get_register_float32_s(dsa, typ, idx, sidx, &val, kind, timeout));
			return val;
		}
		double getRegisterFloat64(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {
			double  val;
			ERRCHK(dsa_get_register_float64_s(dsa, typ, idx, sidx, &val, kind, timeout));
			return val;
		}
		void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_array_s(dsa, typ, idx, nidx, sidx, val, offset, kind, timeout));
		}
		void getArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_array_int32_s(dsa, typ, idx, nidx, sidx, val, offset, kind, timeout));
		}
		void getArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, int kind, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_array_int64_s(dsa, typ, idx, nidx, sidx, val, offset, kind, timeout));
		}
		void getArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, int kind, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_array_float32_s(dsa, typ, idx, nidx, sidx, val, offset, kind, timeout));
		}
		void getArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int kind, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_array_float64_s(dsa, typ, idx, nidx, sidx, val, offset, kind, timeout));
		}
		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_register_s(dsa, typ, idx, sidx, val, timeout));
		}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_register_int32_s(dsa, typ, idx, sidx, val, timeout));
		}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_register_int64_s(dsa, typ, idx, sidx, val, timeout));
		}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_register_float32_s(dsa, typ, idx, sidx, val, timeout));
		}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_register_float64_s(dsa, typ, idx, sidx, val, timeout));
		}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_array_s(dsa, typ, idx, nidx, sidx, val, offset, timeout));
		}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_array_int32_s(dsa, typ, idx, nidx, sidx, val, offset, timeout));
		}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_array_int64_s(dsa, typ, idx, nidx, sidx, val, offset, timeout));
		}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_array_float32_s(dsa, typ, idx, nidx, sidx, val, offset, timeout));
		}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_array_float64_s(dsa, typ, idx, nidx, sidx, val, offset, timeout));
		}
		double  getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, long timeout = DEF_TIMEOUT) {
			double  val;
			ERRCHK(dsa_get_iso_register_s(dsa, typ, idx, sidx, &val, conv, kind, timeout));
			return val;
		}
		void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_iso_array_s(dsa, typ, idx, nidx, sidx, val, offset, conv, kind, timeout));
		}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_iso_register_s(dsa, typ, idx, sidx, val, conv, timeout));
		}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_iso_array_s(dsa, typ, idx, nidx, sidx, val, offset, conv, timeout));
		}
		void ipolBegin(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_begin_s(dsa, timeout));
		}
		void ipolEnd(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_end_s(dsa, timeout));
		}
		void ipolBeginConcatenation(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_begin_concatenation_s(dsa, timeout));
		}
		void ipolEndConcatenation(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_end_concatenation_s(dsa, timeout));
		}
		void ipolLine(DsaVector *dest, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_line_s(dsa, *(DSA_VECTOR **)&dest, timeout));
		}
		void ipolCircleCWR2d(double x, double y, double r, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_circle_cw_r2d_s(dsa, x, y, r, timeout));
		}
		void ipolCircleCcwR2d(double x, double y, double r, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_circle_ccw_r2d_s(dsa, x, y, r, timeout));
		}
		void ipolTanVelocity(double velocity, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_tan_velocity_s(dsa, velocity, timeout));
		}
		void ipolTanAcceleration(double acc, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_tan_acceleration_s(dsa, acc, timeout));
		}
		void ipolTanDeceleration(double dec, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_tan_deceleration_s(dsa, dec, timeout));
		}
		void ipolTanJerkTime(double jerk_time, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_tan_jerk_time_s(dsa, jerk_time, timeout));
		}
		void ipolQuickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_quick_stop_s(dsa, mode, flags, timeout));
		}
		void ipolContinue(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_continue_s(dsa, timeout));
		}
		void ipolPvt(DsaVector *dest, DsaVector *velocity, double time, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_pvt_s(dsa, *(DSA_VECTOR **)&dest, *(DSA_VECTOR **)&velocity, time, timeout));
		}
		void ipolMark(long number, long operation, long op_param, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_mark_s(dsa, number, operation, op_param, timeout));
		}
		void ipolMark2Param(long number, long operation, long op_param1, long op_param2, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_mark_2param_s(dsa, number, operation, op_param1, op_param2, timeout));
		}
		void ipolSetVelocityRate(double rate, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_set_velocity_rate_s(dsa, rate, timeout));
		}
		void ipolCircleCWC2d(double x, double y, double cx, double cy, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_circle_cw_c2d_s(dsa, x, y, cx, cy, timeout));
		}
		void ipolCircleCcwC2d(double x, double y, double cx, double cy, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_circle_ccw_c2d_s(dsa, x, y, cx, cy, timeout));
		}
		void ipolLine(double x, double y, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_line_2d_s(dsa, x, y, timeout));
		}
		void ipolWaitMovement(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_wait_movement_s(dsa, timeout));
		}
		void ipolPrepare(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_prepare_s(dsa, timeout));
		}
		void ipolPvtUpdate(int depth, dword mask, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_pvt_update_s(dsa, depth, mask, timeout));
		}
		void ipolPvtRegTyp(DsaVector *dest, DsaVectorTyp destTyp, DsaVector *velocity, DsaVectorTyp velocityTyp, double time, int timeTyp, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_pvt_reg_typ_s(dsa, *(DSA_VECTOR **)&dest, *(DSA_VECTOR_TYP*)&destTyp, *(DSA_VECTOR **)&velocity, *(DSA_VECTOR_TYP*)&velocityTyp, time, timeTyp, timeout));
		}
		void ipolSetLktSpeedRatio(double value, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_set_lkt_speed_ratio_s(dsa, value, timeout));
		}
		void ipolSetLktCyclicMode(bool active, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_set_lkt_cyclic_mode_s(dsa, active, timeout));
		}
		void ipolSetLktRelativeMode(bool active, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_set_lkt_relative_mode_s(dsa, active, timeout));
		}
		void ipolLkt(DsaVector *dest, DsaIntVector *lkt_number, double time, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_lkt_s(dsa, *(DSA_VECTOR **)&dest, *(DSA_INT_VECTOR **)&lkt_number, time, timeout));
		}
		void ipolWaitMark(int mark, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_wait_mark_s(dsa, mark, timeout));
		}
		void ipolUline(DsaVector *dest, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_uline_s(dsa, *(DSA_VECTOR **)&dest, timeout));
		}
		void ipolUline(double x, double y, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_uline_2d_s(dsa, x, y, timeout));
		}
		void ipolDisableUconcatenation(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_disable_uconcatenation_s(dsa, timeout));
		}
		void ipolSetUrelativeMode(bool active, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_set_urelative_mode_s(dsa, active, timeout));
		}
		void ipolUspeedAxisMask(dword mask, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_uspeed_axis_mask_s(dsa, mask, timeout));
		}
		void ipolUspeed(double speed, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_uspeed_s(dsa, speed, timeout));
		}
		void ipolUtime(double acc_time, double jerk_time, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_utime_s(dsa, acc_time, jerk_time, timeout));
		}
		void ipolTranslateMatrix(DsaVector *trans, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_translate_matrix_s(dsa, *(DSA_VECTOR **)&trans, timeout));
		}
		void ipolScaleMatrix(DsaVector *scale, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_scale_matrix_s(dsa, *(DSA_VECTOR **)&scale, timeout));
		}
		void ipolRotateMatrix(int plan, double degree, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_rotate_matrix_s(dsa, plan, degree, timeout));
		}
		void ipolTranslateMatrix(double x, double y, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_translate_matrix_2d_s(dsa, x, y, timeout));
		}
		void ipolScaleMatrix(double x, double y, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_scale_matrix_2d_s(dsa, x, y, timeout));
		}
		void ipolShearMatrix(int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_shear_matrix_s(dsa, sheared_axis, axis1_shearing, axis2_shearing, axis3_shearing, timeout));
		}
		void ipolLock(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_lock_s(dsa, timeout));
		}
		void ipolUnlock(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_ipol_unlock_s(dsa, timeout));
		}
		int ipolGetIpolGroup() {
			int grp;
			ERRCHK(dsa_ipol_get_ipol_grp(dsa, &grp));
			return grp;
		}

		void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_quick_register_request_s(dsa, typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, timeout));
		}
		void quickAddressRequest(dword addr1, long *val1, dword addr2, long *val2, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_quick_address_request_s(dsa, addr1, val1, addr2, val2, timeout));
		}
		DsaStatus  waitStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
			DsaStatus  status = {sizeof(DSA_STATUS)};
			ERRCHK(dsa_wait_status_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, &*(DSA_STATUS *)&status, timeout));
			return status;
		}
		DsaStatus  waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
			DsaStatus  status = {sizeof(DSA_STATUS)};
			ERRCHK(dsa_wait_status_not_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, &*(DSA_STATUS *)&status, timeout));
			return status;
		}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_grp_wait_and_status_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
		}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_grp_wait_and_status_not_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
		}
		void gantryWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_gantry_wait_and_status_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
		}
		void gantryWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_gantry_wait_and_status_not_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
		}
		DsaStatus  waitStatusChange(DsaStatus *mask, long timeout = DEF_TIMEOUT) {
			DsaStatus  status = {sizeof(DSA_STATUS)};
			ERRCHK(dsa_wait_status_change_s(dsa, *(DSA_STATUS **)&mask, &*(DSA_STATUS *)&status, timeout));
			return status;
		}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_grp_wait_or_status_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
		}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_grp_wait_or_status_not_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
		}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_sync_trace_enable_s(dsa, enable, timeout));
		}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_sync_trace_force_trigger_s(dsa, timeout));
		}

		void powerOn(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_power_on_a(dsa, (DSA_HANDLER)handler, param));
		}
		void powerOff(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_power_off_a(dsa, (DSA_HANDLER)handler, param));
		}
		void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_new_setpoint_a(dsa, sidx, flags, (DSA_HANDLER)handler, param));
		}
		void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_change_setpoint_a(dsa, sidx, flags, (DSA_HANDLER)handler, param));
		}
		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_quick_stop_a(dsa, mode, flags, (DSA_HANDLER)handler, param));
		}
		void homingStart(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_homing_start_a(dsa, (DSA_HANDLER)handler, param));
		}
		void getWarningCode(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_warning_code_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getErrorCode(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_error_code_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_execute_command_a(dsa, cmd, fast, ereport, (DSA_HANDLER)handler, param));
		}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_execute_command_d_a(dsa, cmd, typ1, par1, fast, ereport, (DSA_HANDLER)handler, param));
		}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_execute_command_i_a(dsa, cmd, typ1, par1, conv1, fast, ereport, (DSA_HANDLER)handler, param));
		}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_execute_command_dd_a(dsa, cmd, typ1, par1, typ2, par2, fast, ereport, (DSA_HANDLER)handler, param));
		}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_execute_command_id_a(dsa, cmd, typ1, par1, conv1, typ2, par2, fast, ereport, (DSA_HANDLER)handler, param));
		}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_execute_command_di_a(dsa, cmd, typ1, par1, typ2, par2, conv2, fast, ereport, (DSA_HANDLER)handler, param));
		}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_execute_command_ii_a(dsa, cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, (DSA_HANDLER)handler, param));
		}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_execute_command_x_a(dsa, cmd, *(DSA_COMMAND_PARAM **)&params, count, fast, ereport, (DSA_HANDLER)handler, param));
		}
		void startProfiledMovement(double pos, double speed, double acc, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_start_profiled_movement_a(dsa, pos, speed, acc, (DSA_HANDLER)handler, param));
		}
		void startRelativeProfiledMovement(double relativePos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_start_relative_profiled_movement_a(dsa, relativePos, (DSA_HANDLER)handler, param));
		}

		void getRegister(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_register_a(dsa, typ, idx, sidx, kind, (DSA_LONG_HANDLER)handler, param));
		}
		void getRegisterInt32(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_register_int32_a(dsa, typ, idx, sidx, kind, (DSA_LONG_HANDLER)handler, param));
		}
		void getRegisterInt64(int typ, unsigned idx, int sidx, int kind, DsaInt64Handler handler, void *param = NULL) {
			ERRCHK(dsa_get_register_int64_a(dsa, typ, idx, sidx, kind, (DSA_INT64_HANDLER)handler, param));
		}
		void getRegisterFloat32(int typ, unsigned idx, int sidx, int kind, DsaFloatHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_register_float32_a(dsa, typ, idx, sidx, kind, (DSA_FLOAT_HANDLER)handler, param));
		}
		void getRegisterFloat64(int typ, unsigned idx, int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_register_float64_a(dsa, typ, idx, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_array_a(dsa, typ, idx, nidx, sidx, val, offset, kind, (DSA_HANDLER)handler, param));
		}
		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_register_a(dsa, typ, idx, sidx, val, (DSA_HANDLER)handler, param));
		}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_register_int32_a(dsa, typ, idx, sidx, val, (DSA_HANDLER)handler, param));
		}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_register_int64_a(dsa, typ, idx, sidx, val, (DSA_HANDLER)handler, param));
		}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_register_float32_a(dsa, typ, idx, sidx, val, (DSA_HANDLER)handler, param));
		}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_register_float64_a(dsa, typ, idx, sidx, val, (DSA_HANDLER)handler, param));
		}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_array_a(dsa, typ, idx, nidx, sidx, val, offset, (DSA_HANDLER)handler, param));
		}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_array_int32_a(dsa, typ, idx, nidx, sidx, val, offset, (DSA_HANDLER)handler, param));
		}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_array_int64_a(dsa, typ, idx, nidx, sidx, val, offset, (DSA_HANDLER)handler, param));
		}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_array_float32_a(dsa, typ, idx, nidx, sidx, val, offset, (DSA_HANDLER)handler, param));
		}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_array_float64_a(dsa, typ, idx, nidx, sidx, val, offset, (DSA_HANDLER)handler, param));
		}
		void getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_iso_register_a(dsa, typ, idx, sidx, conv, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_iso_array_a(dsa, typ, idx, nidx, sidx, val, offset, conv, kind, (DSA_HANDLER)handler, param));
		}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_iso_register_a(dsa, typ, idx, sidx, val, conv, (DSA_HANDLER)handler, param));
		}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_iso_array_a(dsa, typ, idx, nidx, sidx, val, offset, conv, (DSA_HANDLER)handler, param));
		}
		void ipolBegin(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_begin_a(dsa, (DSA_HANDLER)handler, param));
		}
		void ipolEnd(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_end_a(dsa, (DSA_HANDLER)handler, param));
		}
		void ipolBeginConcatenation(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_begin_concatenation_a(dsa, (DSA_HANDLER)handler, param));
		}
		void ipolEndConcatenation(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_end_concatenation_a(dsa, (DSA_HANDLER)handler, param));
		}
		void ipolLine(DsaVector *dest, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_line_a(dsa, *(DSA_VECTOR **)&dest, (DSA_HANDLER)handler, param));
		}
		void ipolCircleCWR2d(double x, double y, double r, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_circle_cw_r2d_a(dsa, x, y, r, (DSA_HANDLER)handler, param));
		}
		void ipolCircleCcwR2d(double x, double y, double r, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_circle_ccw_r2d_a(dsa, x, y, r, (DSA_HANDLER)handler, param));
		}
		void ipolTanVelocity(double velocity, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_tan_velocity_a(dsa, velocity, (DSA_HANDLER)handler, param));
		}
		void ipolTanAcceleration(double acc, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_tan_acceleration_a(dsa, acc, (DSA_HANDLER)handler, param));
		}
		void ipolTanDeceleration(double dec, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_tan_deceleration_a(dsa, dec, (DSA_HANDLER)handler, param));
		}
		void ipolTanJerkTime(double jerk_time, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_tan_jerk_time_a(dsa, jerk_time, (DSA_HANDLER)handler, param));
		}
		void ipolQuickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_quick_stop_a(dsa, mode, flags, (DSA_HANDLER)handler, param));
		}
		void ipolContinue(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_continue_a(dsa, (DSA_HANDLER)handler, param));
		}
		void ipolPvt(DsaVector *dest, DsaVector *velocity, double time, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_pvt_a(dsa, *(DSA_VECTOR **)&dest, *(DSA_VECTOR **)&velocity, time, (DSA_HANDLER)handler, param));
		}
		void ipolMark(long number, long operation, long op_param, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_mark_a(dsa, number, operation, op_param, (DSA_HANDLER)handler, param));
		}
		void ipolMark2Param(long number, long operation, long op_param1, long op_param2, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_mark_2param_a(dsa, number, operation, op_param1, op_param2, (DSA_HANDLER)handler, param));
		}
		void ipolSetVelocityRate(double rate, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_set_velocity_rate_a(dsa, rate, (DSA_HANDLER)handler, param));
		}
		void ipolCircleCWC2d(double x, double y, double cx, double cy, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_circle_cw_c2d_a(dsa, x, y, cx, cy, (DSA_HANDLER)handler, param));
		}
		void ipolCircleCcwC2d(double x, double y, double cx, double cy, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_circle_ccw_c2d_a(dsa, x, y, cx, cy, (DSA_HANDLER)handler, param));
		}
		void ipolLine(double x, double y, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_line_2d_a(dsa, x, y, (DSA_HANDLER)handler, param));
		}
		void ipolWaitMovement(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_wait_movement_a(dsa, (DSA_HANDLER)handler, param));
		}
		void ipolPrepare(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_prepare_a(dsa, (DSA_HANDLER)handler, param));
		}
		void ipolPvtUpdate(int depth, dword mask, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_pvt_update_a(dsa, depth, mask, (DSA_HANDLER)handler, param));
		}
		void ipolPvtRegTyp(DsaVector *dest, DsaVectorTyp destTyp, DsaVector *velocity, DsaVectorTyp velocityTyp, double time, int timeTyp, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_pvt_reg_typ_a(dsa, *(DSA_VECTOR **)&dest, *(DSA_VECTOR_TYP*)&destTyp, *(DSA_VECTOR **)&velocity, *(DSA_VECTOR_TYP*)&velocityTyp, time, timeTyp, (DSA_HANDLER)handler, param));
		}
		void ipolSetLktSpeedRatio(double value, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_set_lkt_speed_ratio_a(dsa, value, (DSA_HANDLER)handler, param));
		}
		void ipolSetLktCyclicMode(bool active, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_set_lkt_cyclic_mode_a(dsa, active, (DSA_HANDLER)handler, param));
		}
		void ipolSetLktRelativeMode(bool active, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_set_lkt_relative_mode_a(dsa, active, (DSA_HANDLER)handler, param));
		}
		void ipolLkt(DsaVector *dest, DsaIntVector *lkt_number, double time, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_lkt_a(dsa, *(DSA_VECTOR **)&dest, *(DSA_INT_VECTOR **)&lkt_number, time, (DSA_HANDLER)handler, param));
		}
		void ipolWaitMark(int mark, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_wait_mark_a(dsa, mark, (DSA_HANDLER)handler, param));
		}
		void ipolUline(DsaVector *dest, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_uline_a(dsa, *(DSA_VECTOR **)&dest, (DSA_HANDLER)handler, param));
		}
		void ipolUline(double x, double y, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_uline_2d_a(dsa, x, y, (DSA_HANDLER)handler, param));
		}
		void ipolDisableUconcatenation(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_disable_uconcatenation_a(dsa, (DSA_HANDLER)handler, param));
		}
		void ipolSetUrelativeMode(bool active, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_set_urelative_mode_a(dsa, active, (DSA_HANDLER)handler, param));
		}
		void ipolUspeedAxisMask(dword mask, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_uspeed_axis_mask_a(dsa, mask, (DSA_HANDLER)handler, param));
		}
		void ipolUspeed(double speed, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_uspeed_a(dsa, speed, (DSA_HANDLER)handler, param));
		}
		void ipolUtime(double acc_time, double jerk_time, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_utime_a(dsa, acc_time, jerk_time, (DSA_HANDLER)handler, param));
		}
		void ipolTranslateMatrix(DsaVector *trans, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_translate_matrix_a(dsa, *(DSA_VECTOR **)&trans, (DSA_HANDLER)handler, param));
		}
		void ipolScaleMatrix(DsaVector *scale, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_scale_matrix_a(dsa, *(DSA_VECTOR **)&scale, (DSA_HANDLER)handler, param));
		}
		void ipolRotateMatrix(int plan, double degree, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_rotate_matrix_a(dsa, plan, degree, (DSA_HANDLER)handler, param));
		}
		void ipolTranslateMatrix(double x, double y, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_translate_matrix_2d_a(dsa, x, y, (DSA_HANDLER)handler, param));
		}
		void ipolScaleMatrix(double x, double y, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_scale_matrix_2d_a(dsa, x, y, (DSA_HANDLER)handler, param));
		}
		void ipolShearMatrix(int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_shear_matrix_a(dsa, sheared_axis, axis1_shearing, axis2_shearing, axis3_shearing, (DSA_HANDLER)handler, param));
		}
		void ipolLock(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_lock_a(dsa, (DSA_HANDLER)handler, param));
		}
		void ipolUnlock(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_ipol_unlock_a(dsa, (DSA_HANDLER)handler, param));
		}
		void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, Dsa2intHandler handler, void *param = NULL) {
			ERRCHK(dsa_quick_register_request_a(dsa, typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, (DSA_2INT_HANDLER)handler, param));
		}
		void quickAddressRequest(dword addr1, long *val1, dword addr2, long *val2, Dsa2intHandler handler, void *param = NULL) {
			ERRCHK(dsa_quick_address_request_a(dsa, addr1, val1, addr2, val2, (DSA_2INT_HANDLER)handler, param));
		}
		void waitStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_status_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_STATUS_HANDLER)handler, param));
		}
		void waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_status_not_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_STATUS_HANDLER)handler, param));
		}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_grp_wait_and_status_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
		}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_grp_wait_and_status_not_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
		}
		void gantryWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_gantry_wait_and_status_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
		}
		void gantryWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_gantry_wait_and_status_not_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
		}
		void waitStatusChange(DsaStatus *mask, DsaStatusHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_status_change_a(dsa, *(DSA_STATUS **)&mask, (DSA_STATUS_HANDLER)handler, param));
		}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_grp_wait_or_status_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
		}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_grp_wait_or_status_not_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
		}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_sync_trace_enable_a(dsa, enable, (DSA_HANDLER)handler, param));
		}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_sync_trace_force_trigger_a(dsa, (DSA_HANDLER)handler, param));
		}

		void etcomOpen(EtbBus etb, int axis) {
			ERRCHK(dsa_etcom_open_e(dsa, *(ETB **)&etb, axis));
		}
		void open(char_cp url) {
			ERRCHK(dsa_open_u(dsa, url));
		}
		void etcomOpen(EtbBus etb, int axis, dword flags) {
			ERRCHK(dsa_etcom_open_ef(dsa, *(ETB **)&etb, axis, flags));
		}
		void reset() {
			ERRCHK(dsa_reset(dsa));
		}
		void close() {
			ERRCHK(dsa_close(dsa));
		}
		EtbBus  getEtbBus() {
			EtbBus  etb;
			ERRCHK(dsa_get_etb_bus(dsa, &*(ETB **)&etb));
			return etb;
		}
		int  etcomGetEtbAxis() {
			int  axis;
			ERRCHK(dsa_etcom_get_etb_axis(dsa, &axis));
			return axis;
		}
		bool  isOpen() {
			bool  is_open;
			ERRCHK(dsa_is_open(dsa, &is_open));
			return is_open;
		}
		int getMotorTyp() {
			return dsa_get_motor_typ(dsa);
		}
		int getFamily() {
			DMD_FAMILY family;
			ERRCHK(dsa_get_family(dsa, &family));
			return family;
		}
		void getErrorText(char_p text, int size, int code) {
			ERRCHK(dsa_get_error_text(dsa, text, size, code));
		}
		void getWarningText(char_p text, int size, int code) {
			ERRCHK(dsa_get_warning_text(dsa, text, size, code));
		}
		double convertToIso(long inc, int conv) {
			double  iso;
			ERRCHK(dsa_convert_to_iso(dsa, &iso, inc, conv));
			return iso;
		}
		double convertInt32ToIso(long inc, int conv) {
			double  iso;
			ERRCHK(dsa_convert_int32_to_iso(dsa, &iso, inc, conv));
			return iso;
		}
		double convertInt64ToIso(eint64 inc, int conv) {
			double  iso;
			ERRCHK(dsa_convert_int64_to_iso(dsa, &iso, inc, conv));
			return iso;
		}
		double convertFloat32ToIso(float inc, int conv) {
			double  iso;
			ERRCHK(dsa_convert_float32_to_iso(dsa, &iso, inc, conv));
			return iso;
		}
		double convertFloat64ToIso(double inc, int conv) {
			double  iso;
			ERRCHK(dsa_convert_float64_to_iso(dsa, &iso, inc, conv));
			return iso;
		}
		long convertFromIso(double iso, int conv) {
			long  inc;
			ERRCHK(dsa_convert_from_iso(dsa, &inc, iso, conv));
			return inc;
		}
		long convertInt32FromIso(double iso, int conv) {
			long  inc;
			ERRCHK(dsa_convert_int32_from_iso(dsa, &inc, iso, conv));
			return inc;
		}
		eint64 convertInt64FromIso(double iso, int conv) {
			eint64  inc;
			ERRCHK(dsa_convert_int64_from_iso(dsa, &inc, iso, conv));
			return inc;
		}
		float convertFloat32FromIso(double iso, int conv) {
			float  inc;
			ERRCHK(dsa_convert_float32_from_iso(dsa, &inc, iso, conv));
			return inc;
		}
		double convertFloat64FromIso(double iso, int conv) {
			double  inc;
			ERRCHK(dsa_convert_float64_from_iso(dsa, &inc, iso, conv));
			return inc;
		}
		double getIncToIsoFactor(int conv) {
			double factor;
			ERRCHK(dsa_get_inc_to_iso_factor(dsa, conv, &factor));
			return factor;
		}
		void diag(char_cp file_name, int line, int err) {
			ERRCHK(dsa_diag(file_name, line, err, dsa));
		}
		void sdiag(char_p str, char_cp file_name, int line, int err) {
			ERRCHK(dsa_sdiag(str, file_name, line, err, dsa));
		}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {
			ERRCHK(dsa_fdiag(output_file_name, file_name, line, err, dsa));
		}
		void extDiag(char_cp file_name, int line, int err) {
			ERRCHK(dsa_ext_diag(file_name, line, err, dsa));
		}
		void extSdiag(int size, char_p str, char_cp file_name, int line, int err) {
			ERRCHK(dsa_ext_sdiag(size, str, file_name, line, err, dsa));
		}
		void extFdiag(char_cp output_file_name, char_cp file_name, int line, int err) {
			ERRCHK(dsa_ext_fdiag(output_file_name, file_name, line, err, dsa));
		}
		int  getGroupSize() {
			int  size;
			ERRCHK(dsa_get_group_size(dsa, &size));
			return size;
		}
		int  gantryGetErrorCode(int *axis, int kind) {
			int  code;
			ERRCHK(dsa_gantry_get_error_code(dsa, &code, axis, kind));
			return code;
		}
		DsaInfo  getInfo() {
			DsaInfo  info = {sizeof(DSA_INFO)};
			ERRCHK(dsa_get_info(dsa, &*(DSA_INFO *)&info));
			return info;
		}
		bool isIpolINProgress() {
			return dsa_is_ipol_in_progress(dsa);
		}
		DsaStatus  getStatus() {
			DsaStatus  status = {sizeof(DSA_STATUS)};
			ERRCHK(dsa_get_status(dsa, &*(DSA_STATUS *)&status));
			return status;
		}
		void cancelStatusWait() {
			ERRCHK(dsa_cancel_status_wait(dsa));
		}
		void gantryCancelStatusWait() {
			ERRCHK(dsa_gantry_cancel_status_wait(dsa));
		}
		DsaStatus  gantryGetAndStatus() {
			DsaStatus  status = {sizeof(DSA_STATUS)};
			ERRCHK(dsa_gantry_get_and_status(dsa, &*(DSA_STATUS *)&status));
			return status;
		}
		DsaStatus  gantryGetORStatus() {
			DsaStatus  status = {sizeof(DSA_STATUS)};
			ERRCHK(dsa_gantry_get_or_status(dsa, &*(DSA_STATUS *)&status));
			return status;
		}
		DsaStatus  getStatusFromDrive(long timeout = DEF_TIMEOUT) {
			DsaStatus  status = {sizeof(DSA_STATUS)};
			ERRCHK(dsa_get_status_from_drive(dsa, &*(DSA_STATUS *)&status, timeout));
			return status;
		}
		void grpCancelStatusWait() {
			ERRCHK(dsa_grp_cancel_status_wait(dsa));
		}
		double  queryMinimumSampleTime() {
			double  time;
			ERRCHK(dsa_query_minimum_sample_time(dsa, &time));
			return time;
		}
		double  querySampleTime(double time) {
			double  real_time;
			ERRCHK(dsa_query_sample_time(dsa, time, &real_time));
			return real_time;
		}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_commit_async_trans(dsa, *(DSA_HANDLER*)&handler, param));
		}
		DsaXInfo  getXInfo() {
			DsaXInfo  x_info = {sizeof(DSA_X_INFO)};
			ERRCHK(dsa_get_x_info(dsa, &*(DSA_X_INFO *)&x_info));
			return x_info;
		}
		void stageMappingDownload(const char *fileName) {
			ERRCHK(dsa_stage_mapping_download(dsa, fileName));
		}
		void stageMappingUpload(const char *fileName) {
			ERRCHK(dsa_stage_mapping_upload(dsa, fileName));
		}
		void stageMappingActivate() {
			ERRCHK(dsa_stage_mapping_activate(dsa));
		}
		void stageMappingDeactivate() {
			ERRCHK(dsa_stage_mapping_deactivate(dsa));
		}
		bool stageMappingIsActivated() {
			bool active;
			ERRCHK(dsa_stage_mapping_get_activation(dsa, &active));
			return active;
		}
		void scaleMappingDownload(const char *fileName, dword preProcessingMode) {
			ERRCHK(dsa_scale_mapping_download(dsa, fileName, preProcessingMode));
		}
		void scaleMappingActivate(dword mode) {
			ERRCHK(dsa_scale_mapping_activate(dsa, mode));
		}
		void scaleMappingDeactivate() {
			ERRCHK(dsa_scale_mapping_deactivate(dsa));
		}
		bool scaleMappingIsActivated() {
			bool active;
			ERRCHK(dsa_scale_mapping_get_activation(dsa, &active));
			return active;
		}
		void startUploadTrace(int traceTyp, int traceIdx, int startIdx, int endIdx, int stepIdx, bool fast, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_start_upload_trace_s(dsa, traceTyp, traceIdx, startIdx, endIdx, stepIdx, fast, timeout));
		}
		void startUploadSequence(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_start_upload_sequence_s(dsa, timeout));
		}
		void startUploadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_start_upload_register_s(dsa, typ, startIdx, endIdx, sidx, timeout));
		}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_start_download_sequence_s(dsa, timeout));
		}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_start_download_register_s(dsa, typ, startIdx, endIdx, sidx, timeout));
		}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_download_data_s(dsa, data, size, timeout));
		}
		void uploadData(void *data, int size, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_upload_data_s(dsa, data, size, timeout));
		}
		void downloadCompiledSequenceFile(char *fileName) {
			ERRCHK(dsa_download_compiled_sequence_file(dsa, fileName));
		}
		void setSequenceVersion(char *fileName) {
			ERRCHK(dsa_set_sequence_version(dsa, fileName));
		}

	/*
	 * commands - synchronous
	 */
	protected:
		void resetError(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_reset_error_s(dsa, timeout));
		}
		void stepMotion(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_step_motion_s(dsa, pos, timeout));
		}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_execute_sequence_s(dsa, label, timeout));
		}
		void executeSequenceInThread(int label, int thread_nr, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_execute_sequence_in_thread_s(dsa, label, thread_nr, timeout));
		}
		void stopSequenceInThread(int thread_nr, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_stop_sequence_in_thread_s(dsa, thread_nr, timeout));
		}
		void stopSequence(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_stop_sequence_s(dsa, timeout));
		}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_save_parameters_s(dsa, what, timeout));
		}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_load_parameters_s(dsa, what, timeout));
		}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_default_parameters_s(dsa, what, timeout));
		}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_parameters_version_s(dsa, what, version, timeout));
		}
		int getParametersVersion(int what, long timeout = DEF_TIMEOUT) {
			int version;
			ERRCHK(dsa_get_parameters_version_s(dsa, what, &version, timeout));
			return version;
		}
		void waitMovement(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_wait_movement_s(dsa, timeout));
		}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_wait_position_s(dsa, pos, timeout));
		}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_wait_time_s(dsa, time, timeout));
		}
		void waitWindow(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_wait_window_s(dsa, timeout));
		}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_wait_bit_set_s(dsa, typ, idx, sidx, mask, timeout));
		}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_wait_bit_clear_s(dsa, typ, idx, sidx, mask, timeout));
		}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_wait_sgn_register_greater_s(dsa, typ, idx, sidx, value, timeout));
		}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_wait_sgn_register_lower_s(dsa, typ, idx, sidx, value, timeout));
		}
		void userStretchEnable(double offset, float slope, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_user_stretch_enable_s(dsa, offset, slope, timeout));
		}
		void userStretchDisable(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_user_stretch_disable_s(dsa, timeout));
		}

	/*
	 * commands - asynchronous
	 */
	protected:
		void resetError(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_reset_error_a(dsa, (DSA_HANDLER)handler, param));
		}
		void stepMotion(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_step_motion_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_execute_sequence_a(dsa, label, (DSA_HANDLER)handler, param));
		}
		void executeSequenceInThread(int label, int thread_nr, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_execute_sequence_in_thread_a(dsa, label, thread_nr, (DSA_HANDLER)handler, param));
		}
		void stopSequenceInThread(int thread_nr, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_stop_sequence_in_thread_a(dsa, thread_nr, (DSA_HANDLER)handler, param));
		}
		void stopSequence(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_stop_sequence_a(dsa, (DSA_HANDLER)handler, param));
		}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_save_parameters_a(dsa, what, (DSA_HANDLER)handler, param));
		}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_load_parameters_a(dsa, what, (DSA_HANDLER)handler, param));
		}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_default_parameters_a(dsa, what, (DSA_HANDLER)handler, param));
		}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_parameters_version_a(dsa, what, version, (DSA_HANDLER)handler, param));
		}
		void getParametersVersion(int what, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_parameters_version_a(dsa, what, (DSA_INT_HANDLER)handler, param));
		}
		void waitMovement(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_movement_a(dsa, (DSA_HANDLER)handler, param));
		}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_position_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_time_a(dsa, time, (DSA_HANDLER)handler, param));
		}
		void waitWindow(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_window_a(dsa, (DSA_HANDLER)handler, param));
		}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_bit_set_a(dsa, typ, idx, sidx, mask, (DSA_HANDLER)handler, param));
		}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_bit_clear_a(dsa, typ, idx, sidx, mask, (DSA_HANDLER)handler, param));
		}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_sgn_register_greater_a(dsa, typ, idx, sidx, value, (DSA_HANDLER)handler, param));
		}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_wait_sgn_register_lower_a(dsa, typ, idx, sidx, value, (DSA_HANDLER)handler, param));
		}
		void userStretchEnable(double offset, float slope, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_user_stretch_enable_a(dsa, offset, slope, (DSA_HANDLER)handler, param));
		}
		void userStretchDisable(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_user_stretch_disable_a(dsa, (DSA_HANDLER)handler, param));
		}

	/*
	 * register setter - synchronous
	 */
	protected:
		void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_pl_proportional_gain_s(dsa, gain, timeout));
		}
		void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_pl_speed_feedback_gain_s(dsa, gain, timeout));
		}
		void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_pl_integrator_gain_s(dsa, gain, timeout));
		}
		void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_pl_anti_windup_gain_s(dsa, gain, timeout));
		}
		void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_pl_integrator_limitation_s(dsa, limit, timeout));
		}
		void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_pl_integrator_mode_s(dsa, mode, timeout));
		}
		void setTtlSpeedlFilter(double factor, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_ttl_speed_filter_s(dsa, factor, timeout));
		}
		void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_pl_acc_feedforward_gain_s(dsa, factor, timeout));
		}
		void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_max_position_range_limit_s(dsa, pos, timeout));
		}
		void startMovement(double *targets, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_start_movement_s(dsa, targets, timeout));
		}

		void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_following_error_window_s(dsa, pos, timeout));
		}
		void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_velocity_error_limit_s(dsa, vel, timeout));
		}
		void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_switch_limit_mode_s(dsa, mode, timeout));
		}
		void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_enable_input_mode_s(dsa, mode, timeout));
		}
		void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_min_soft_position_limit_s(dsa, pos, timeout));
		}
		void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_max_soft_position_limit_s(dsa, pos, timeout));
		}
		void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_profile_limit_mode_s(dsa, flags, timeout));
		}
		void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_position_window_time_s(dsa, tim, timeout));
		}
		void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_position_window_s(dsa, win, timeout));
		}
		void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_homing_method_s(dsa, mode, timeout));
		}
		void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_homing_zero_speed_s(dsa, vel, timeout));
		}
		void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_homing_acceleration_s(dsa, acc, timeout));
		}
		void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_homing_following_limit_s(dsa, win, timeout));
		}
		void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_homing_current_limit_s(dsa, cur, timeout));
		}
		void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_home_offset_s(dsa, pos, timeout));
		}
		void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_homing_fixed_mvt_s(dsa, pos, timeout));
		}
		void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_homing_switch_mvt_s(dsa, pos, timeout));
		}
		void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_homing_index_mvt_s(dsa, pos, timeout));
		}
		void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_homing_fine_tuning_mode_s(dsa, mode, timeout));
		}
		void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_homing_fine_tuning_value_s(dsa, phase, timeout));
		}
		void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_motor_phase_correction_s(dsa, mode, timeout));
		}
		void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_software_current_limit_s(dsa, cur, timeout));
		}
		void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_drive_control_mode_s(dsa, mode, timeout));
		}
		void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_display_mode_s(dsa, mode, timeout));
		}
		void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_encoder_inversion_s(dsa, invert, timeout));
		}
		void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_encoder_phase_1_offset_s(dsa, offset, timeout));
		}
		void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_encoder_phase_2_offset_s(dsa, offset, timeout));
		}
		void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_encoder_phase_1_factor_s(dsa, factor, timeout));
		}
		void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_encoder_phase_2_factor_s(dsa, factor, timeout));
		}
		void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_encoder_index_distance_s(dsa, pos, timeout));
		}
		void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_cl_proportional_gain_s(dsa, gain, timeout));
		}
		void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_cl_integrator_gain_s(dsa, gain, timeout));
		}
		void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_cl_current_limit_s(dsa, cur, timeout));
		}
		void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_cl_i2t_current_limit_s(dsa, cur, timeout));
		}
		void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_cl_i2t_time_limit_s(dsa, tim, timeout));
		}
		void setInitMode(int typ, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_init_mode_s(dsa, typ, timeout));
		}
		void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_init_pulse_level_s(dsa, cur, timeout));
		}
		void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_init_max_current_s(dsa, cur, timeout));
		}
		void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_init_final_phase_s(dsa, cal, timeout));
		}
		void setInitTime(double tim, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_init_time_s(dsa, tim, timeout));
		}
		void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_init_initial_phase_s(dsa, cal, timeout));
		}
		void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_mon_source_type_s(dsa, sidx, typ, timeout));
		}
		void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_mon_source_index_s(dsa, sidx, index, timeout));
		}
		void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_syncro_start_timeout_s(dsa, tim, timeout));
		}
		void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_digital_output_s(dsa, out, timeout));
		}
		void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_x_digital_output_s(dsa, out, timeout));
		}
		void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_x_analog_output_1_s(dsa, out, timeout));
		}
		void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_x_analog_output_2_s(dsa, out, timeout));
		}
		void setXAnalogOutput3(double out, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_x_analog_output_3_s(dsa, out, timeout));
		}
		void setXAnalogOutput4(double out, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_x_analog_output_4_s(dsa, out, timeout));
		}
		void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_analog_output_s(dsa, out, timeout));
		}
		void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_indirect_register_idx_s(dsa, idx, timeout));
		}
		void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_concatenated_mvt_s(dsa, concat, timeout));
		}
		void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_profile_type_s(dsa, sidx, typ, timeout));
		}
		void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_mvt_lkt_number_s(dsa, sidx, number, timeout));
		}
		void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_mvt_lkt_time_s(dsa, sidx, time, timeout));
		}
		void setCameValue(double factor, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_came_value_s(dsa, factor, timeout));
		}
		void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_brake_deceleration_s(dsa, dec, timeout));
		}
		void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_target_position_s(dsa, sidx, pos, timeout));
		}
		void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_profile_velocity_s(dsa, sidx, vel, timeout));
		}
		void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_profile_acceleration_s(dsa, sidx, acc, timeout));
		}
		void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_jerk_time_s(dsa, sidx, tim, timeout));
		}
		void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_ctrl_source_type_s(dsa, typ, timeout));
		}
		void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_ctrl_source_index_s(dsa, index, timeout));
		}
		void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_ctrl_offset_s(dsa, offset, timeout));
		}
		void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_ctrl_gain_s(dsa, gain, timeout));
		}
		void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_set_motor_kt_factor_s(dsa, kt, timeout));
		}


	/*
	 * register setter - asynchronous
	 */
	protected:
		void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_pl_proportional_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
		}
		void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_pl_speed_feedback_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
		}
		void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_pl_integrator_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
		}
		void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_pl_anti_windup_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
		}
		void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_pl_integrator_limitation_a(dsa, limit, (DSA_HANDLER)handler, param));
		}
		void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_pl_integrator_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
		}
		void setTtlSpeedlFilter(double factor, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_ttl_speed_filter_a(dsa, factor, (DSA_HANDLER)handler, param));
		}
		void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_pl_acc_feedforward_gain_a(dsa, factor, (DSA_HANDLER)handler, param));
		}
		void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_max_position_range_limit_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void startMovement(double *targets, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_start_movement_a(dsa, targets, (DSA_HANDLER)handler, param));
		}

		void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_following_error_window_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_velocity_error_limit_a(dsa, vel, (DSA_HANDLER)handler, param));
		}
		void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_switch_limit_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
		}
		void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_enable_input_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
		}
		void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_min_soft_position_limit_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_max_soft_position_limit_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_profile_limit_mode_a(dsa, flags, (DSA_HANDLER)handler, param));
		}
		void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_position_window_time_a(dsa, tim, (DSA_HANDLER)handler, param));
		}
		void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_position_window_a(dsa, win, (DSA_HANDLER)handler, param));
		}
		void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_homing_method_a(dsa, mode, (DSA_HANDLER)handler, param));
		}
		void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_homing_zero_speed_a(dsa, vel, (DSA_HANDLER)handler, param));
		}
		void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_homing_acceleration_a(dsa, acc, (DSA_HANDLER)handler, param));
		}
		void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_homing_following_limit_a(dsa, win, (DSA_HANDLER)handler, param));
		}
		void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_homing_current_limit_a(dsa, cur, (DSA_HANDLER)handler, param));
		}
		void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_home_offset_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_homing_fixed_mvt_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_homing_switch_mvt_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_homing_index_mvt_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_homing_fine_tuning_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
		}
		void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_homing_fine_tuning_value_a(dsa, phase, (DSA_HANDLER)handler, param));
		}
		void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_motor_phase_correction_a(dsa, mode, (DSA_HANDLER)handler, param));
		}
		void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_software_current_limit_a(dsa, cur, (DSA_HANDLER)handler, param));
		}
		void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_drive_control_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
		}
		void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_display_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
		}
		void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_encoder_inversion_a(dsa, invert, (DSA_HANDLER)handler, param));
		}
		void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_encoder_phase_1_offset_a(dsa, offset, (DSA_HANDLER)handler, param));
		}
		void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_encoder_phase_2_offset_a(dsa, offset, (DSA_HANDLER)handler, param));
		}
		void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_encoder_phase_1_factor_a(dsa, factor, (DSA_HANDLER)handler, param));
		}
		void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_encoder_phase_2_factor_a(dsa, factor, (DSA_HANDLER)handler, param));
		}
		void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_encoder_index_distance_a(dsa, pos, (DSA_HANDLER)handler, param));
		}
		void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_cl_proportional_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
		}
		void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_cl_integrator_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
		}
		void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_cl_current_limit_a(dsa, cur, (DSA_HANDLER)handler, param));
		}
		void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_cl_i2t_current_limit_a(dsa, cur, (DSA_HANDLER)handler, param));
		}
		void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_cl_i2t_time_limit_a(dsa, tim, (DSA_HANDLER)handler, param));
		}
		void setInitMode(int typ, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_init_mode_a(dsa, typ, (DSA_HANDLER)handler, param));
		}
		void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_init_pulse_level_a(dsa, cur, (DSA_HANDLER)handler, param));
		}
		void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_init_max_current_a(dsa, cur, (DSA_HANDLER)handler, param));
		}
		void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_init_final_phase_a(dsa, cal, (DSA_HANDLER)handler, param));
		}
		void setInitTime(double tim, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_init_time_a(dsa, tim, (DSA_HANDLER)handler, param));
		}
		void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_init_initial_phase_a(dsa, cal, (DSA_HANDLER)handler, param));
		}
		void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_mon_source_type_a(dsa, sidx, typ, (DSA_HANDLER)handler, param));
		}
		void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_mon_source_index_a(dsa, sidx, index, (DSA_HANDLER)handler, param));
		}
		void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_syncro_start_timeout_a(dsa, tim, (DSA_HANDLER)handler, param));
		}
		void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_digital_output_a(dsa, out, (DSA_HANDLER)handler, param));
		}
		void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_x_digital_output_a(dsa, out, (DSA_HANDLER)handler, param));
		}
		void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_x_analog_output_1_a(dsa, out, (DSA_HANDLER)handler, param));
		}
		void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_x_analog_output_2_a(dsa, out, (DSA_HANDLER)handler, param));
		}
		void setXAnalogOutput3(double out, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_x_analog_output_3_a(dsa, out, (DSA_HANDLER)handler, param));
		}
		void setXAnalogOutput4(double out, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_x_analog_output_4_a(dsa, out, (DSA_HANDLER)handler, param));
		}
		void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_analog_output_a(dsa, out, (DSA_HANDLER)handler, param));
		}
		void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_indirect_register_idx_a(dsa, idx, (DSA_HANDLER)handler, param));
		}
		void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_concatenated_mvt_a(dsa, concat, (DSA_HANDLER)handler, param));
		}
		void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_profile_type_a(dsa, sidx, typ, (DSA_HANDLER)handler, param));
		}
		void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_mvt_lkt_number_a(dsa, sidx, number, (DSA_HANDLER)handler, param));
		}
		void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_mvt_lkt_time_a(dsa, sidx, time, (DSA_HANDLER)handler, param));
		}
		void setCameValue(double factor, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_came_value_a(dsa, factor, (DSA_HANDLER)handler, param));
		}
		void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_brake_deceleration_a(dsa, dec, (DSA_HANDLER)handler, param));
		}
		void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_target_position_a(dsa, sidx, pos, (DSA_HANDLER)handler, param));
		}
		void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_profile_velocity_a(dsa, sidx, vel, (DSA_HANDLER)handler, param));
		}
		void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_profile_acceleration_a(dsa, sidx, acc, (DSA_HANDLER)handler, param));
		}
		void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_jerk_time_a(dsa, sidx, tim, (DSA_HANDLER)handler, param));
		}
		void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_ctrl_source_type_a(dsa, typ, (DSA_HANDLER)handler, param));
		}
		void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_ctrl_source_index_a(dsa, index, (DSA_HANDLER)handler, param));
		}
		void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_ctrl_offset_a(dsa, offset, (DSA_HANDLER)handler, param));
		}
		void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_ctrl_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
		}
		void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_set_motor_kt_factor_a(dsa, kt, (DSA_HANDLER)handler, param));
		}


	/*
	 * register getter - synchronous
	 */
	protected:
		double getPLProportionalGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double gain;
			ERRTRANS();
			ERRCHK(dsa_get_pl_proportional_gain_s(dsa, &gain, kind, timeout));
			return gain;
		}
		void getPLProportionalGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_pl_proportional_gain_s(dsa, gain, kind, timeout));
		}
		double getPLSpeedFeedbackGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double gain;
			ERRTRANS();
			ERRCHK(dsa_get_pl_speed_feedback_gain_s(dsa, &gain, kind, timeout));
			return gain;
		}
		void getPLSpeedFeedbackGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_pl_speed_feedback_gain_s(dsa, gain, kind, timeout));
		}
		double getPLIntegratorGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double gain;
			ERRTRANS();
			ERRCHK(dsa_get_pl_integrator_gain_s(dsa, &gain, kind, timeout));
			return gain;
		}
		void getPLIntegratorGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_pl_integrator_gain_s(dsa, gain, kind, timeout));
		}
		double getPLAntiWindupGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double gain;
			ERRTRANS();
			ERRCHK(dsa_get_pl_anti_windup_gain_s(dsa, &gain, kind, timeout));
			return gain;
		}
		void getPLAntiWindupGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_pl_anti_windup_gain_s(dsa, gain, kind, timeout));
		}
		double getPLIntegratorLimitation(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double limit;
			ERRTRANS();
			ERRCHK(dsa_get_pl_integrator_limitation_s(dsa, &limit, kind, timeout));
			return limit;
		}
		void getPLIntegratorLimitation(double *limit, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_pl_integrator_limitation_s(dsa, limit, kind, timeout));
		}
		int getPLIntegratorMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int mode;
			ERRTRANS();
			ERRCHK(dsa_get_pl_integrator_mode_s(dsa, &mode, kind, timeout));
			return mode;
		}
		void getPLIntegratorMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_pl_integrator_mode_s(dsa, mode, kind, timeout));
		}
		double getTtlSpeedlFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double factor;
			ERRTRANS();
			ERRCHK(dsa_get_ttl_speed_filter_s(dsa, &factor, kind, timeout));
			return factor;
		}
		void getTtlSpeedlFilter(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_ttl_speed_filter_s(dsa, factor, kind, timeout));
		}
		double getPLAccFeedforwardGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double factor;
			ERRTRANS();
			ERRCHK(dsa_get_pl_acc_feedforward_gain_s(dsa, &factor, kind, timeout));
			return factor;
		}
		void getPLAccFeedforwardGain(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_pl_acc_feedforward_gain_s(dsa, factor, kind, timeout));
		}
		double getMaxPositionRangeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_max_position_range_limit_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getMaxPositionRangeLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_max_position_range_limit_s(dsa, pos, kind, timeout));
		}
		double getFollowingErrorWindow(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_following_error_window_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getFollowingErrorWindow(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_following_error_window_s(dsa, pos, kind, timeout));
		}
		double getVelocityErrorLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double vel;
			ERRTRANS();
			ERRCHK(dsa_get_velocity_error_limit_s(dsa, &vel, kind, timeout));
			return vel;
		}
		void getVelocityErrorLimit(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_velocity_error_limit_s(dsa, vel, kind, timeout));
		}
		int getSwitchLimitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int mode;
			ERRTRANS();
			ERRCHK(dsa_get_switch_limit_mode_s(dsa, &mode, kind, timeout));
			return mode;
		}
		void getSwitchLimitMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_switch_limit_mode_s(dsa, mode, kind, timeout));
		}
		int getEnableInputMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int mode;
			ERRTRANS();
			ERRCHK(dsa_get_enable_input_mode_s(dsa, &mode, kind, timeout));
			return mode;
		}
		void getEnableInputMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_enable_input_mode_s(dsa, mode, kind, timeout));
		}
		double getMinSoftPositionLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_min_soft_position_limit_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getMinSoftPositionLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_min_soft_position_limit_s(dsa, pos, kind, timeout));
		}
		double getMaxSoftPositionLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_max_soft_position_limit_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getMaxSoftPositionLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_max_soft_position_limit_s(dsa, pos, kind, timeout));
		}
		dword getProfileLimitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			dword flags;
			ERRTRANS();
			ERRCHK(dsa_get_profile_limit_mode_s(dsa, &flags, kind, timeout));
			return flags;
		}
		void getProfileLimitMode(dword *flags, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_profile_limit_mode_s(dsa, flags, kind, timeout));
		}
		double getPositionWindowTime(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double tim;
			ERRTRANS();
			ERRCHK(dsa_get_position_window_time_s(dsa, &tim, kind, timeout));
			return tim;
		}
		void getPositionWindowTime(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_position_window_time_s(dsa, tim, kind, timeout));
		}
		double getPositionWindow(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double win;
			ERRTRANS();
			ERRCHK(dsa_get_position_window_s(dsa, &win, kind, timeout));
			return win;
		}
		void getPositionWindow(double *win, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_position_window_s(dsa, win, kind, timeout));
		}
		int getHomingMethod(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int mode;
			ERRTRANS();
			ERRCHK(dsa_get_homing_method_s(dsa, &mode, kind, timeout));
			return mode;
		}
		void getHomingMethod(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_homing_method_s(dsa, mode, kind, timeout));
		}
		double getHomingZeroSpeed(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double vel;
			ERRTRANS();
			ERRCHK(dsa_get_homing_zero_speed_s(dsa, &vel, kind, timeout));
			return vel;
		}
		void getHomingZeroSpeed(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_homing_zero_speed_s(dsa, vel, kind, timeout));
		}
		double getHomingAcceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double acc;
			ERRTRANS();
			ERRCHK(dsa_get_homing_acceleration_s(dsa, &acc, kind, timeout));
			return acc;
		}
		void getHomingAcceleration(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_homing_acceleration_s(dsa, acc, kind, timeout));
		}
		double getHomingFollowingLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double win;
			ERRTRANS();
			ERRCHK(dsa_get_homing_following_limit_s(dsa, &win, kind, timeout));
			return win;
		}
		void getHomingFollowingLimit(double *win, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_homing_following_limit_s(dsa, win, kind, timeout));
		}
		double getHomingCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_homing_current_limit_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getHomingCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_homing_current_limit_s(dsa, cur, kind, timeout));
		}
		double getHomeOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_home_offset_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getHomeOffset(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_home_offset_s(dsa, pos, kind, timeout));
		}
		double getHomingFixedMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_homing_fixed_mvt_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getHomingFixedMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_homing_fixed_mvt_s(dsa, pos, kind, timeout));
		}
		double getHomingSwitchMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_homing_switch_mvt_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getHomingSwitchMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_homing_switch_mvt_s(dsa, pos, kind, timeout));
		}
		double getHomingIndexMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_homing_index_mvt_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getHomingIndexMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_homing_index_mvt_s(dsa, pos, kind, timeout));
		}
		int getHomingFineTuningMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int mode;
			ERRTRANS();
			ERRCHK(dsa_get_homing_fine_tuning_mode_s(dsa, &mode, kind, timeout));
			return mode;
		}
		void getHomingFineTuningMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_homing_fine_tuning_mode_s(dsa, mode, kind, timeout));
		}
		double getHomingFineTuningValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double phase;
			ERRTRANS();
			ERRCHK(dsa_get_homing_fine_tuning_value_s(dsa, &phase, kind, timeout));
			return phase;
		}
		void getHomingFineTuningValue(double *phase, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_homing_fine_tuning_value_s(dsa, phase, kind, timeout));
		}
		int getMotorPhaseCorrection(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int mode;
			ERRTRANS();
			ERRCHK(dsa_get_motor_phase_correction_s(dsa, &mode, kind, timeout));
			return mode;
		}
		void getMotorPhaseCorrection(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_motor_phase_correction_s(dsa, mode, kind, timeout));
		}
		double getSoftwareCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_software_current_limit_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getSoftwareCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_software_current_limit_s(dsa, cur, kind, timeout));
		}
		int getDriveControlMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int mode;
			ERRTRANS();
			ERRCHK(dsa_get_drive_control_mode_s(dsa, &mode, kind, timeout));
			return mode;
		}
		void getDriveControlMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_drive_control_mode_s(dsa, mode, kind, timeout));
		}
		int getDisplayMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int mode;
			ERRTRANS();
			ERRCHK(dsa_get_display_mode_s(dsa, &mode, kind, timeout));
			return mode;
		}
		void getDisplayMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_display_mode_s(dsa, mode, kind, timeout));
		}
		double getEncoderInversion(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double invert;
			ERRTRANS();
			ERRCHK(dsa_get_encoder_inversion_s(dsa, &invert, kind, timeout));
			return invert;
		}
		void getEncoderInversion(double *invert, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_encoder_inversion_s(dsa, invert, kind, timeout));
		}
		double getEncoderPhase1Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double offset;
			ERRTRANS();
			ERRCHK(dsa_get_encoder_phase_1_offset_s(dsa, &offset, kind, timeout));
			return offset;
		}
		void getEncoderPhase1Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_encoder_phase_1_offset_s(dsa, offset, kind, timeout));
		}
		double getEncoderPhase2Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double offset;
			ERRTRANS();
			ERRCHK(dsa_get_encoder_phase_2_offset_s(dsa, &offset, kind, timeout));
			return offset;
		}
		void getEncoderPhase2Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_encoder_phase_2_offset_s(dsa, offset, kind, timeout));
		}
		double getEncoderPhase1Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double factor;
			ERRTRANS();
			ERRCHK(dsa_get_encoder_phase_1_factor_s(dsa, &factor, kind, timeout));
			return factor;
		}
		void getEncoderPhase1Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_encoder_phase_1_factor_s(dsa, factor, kind, timeout));
		}
		double getEncoderPhase2Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double factor;
			ERRTRANS();
			ERRCHK(dsa_get_encoder_phase_2_factor_s(dsa, &factor, kind, timeout));
			return factor;
		}
		void getEncoderPhase2Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_encoder_phase_2_factor_s(dsa, factor, kind, timeout));
		}
		double getEncoderIndexDistance(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_encoder_index_distance_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getEncoderIndexDistance(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_encoder_index_distance_s(dsa, pos, kind, timeout));
		}
		double getCLProportionalGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double gain;
			ERRTRANS();
			ERRCHK(dsa_get_cl_proportional_gain_s(dsa, &gain, kind, timeout));
			return gain;
		}
		void getCLProportionalGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_proportional_gain_s(dsa, gain, kind, timeout));
		}
		double getCLIntegratorGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double gain;
			ERRTRANS();
			ERRCHK(dsa_get_cl_integrator_gain_s(dsa, &gain, kind, timeout));
			return gain;
		}
		void getCLIntegratorGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_integrator_gain_s(dsa, gain, kind, timeout));
		}
		double getCLCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_cl_current_limit_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getCLCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_current_limit_s(dsa, cur, kind, timeout));
		}
		double getCLI2tCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_cl_i2t_current_limit_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getCLI2tCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_i2t_current_limit_s(dsa, cur, kind, timeout));
		}
		double getCLI2tTimeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double tim;
			ERRTRANS();
			ERRCHK(dsa_get_cl_i2t_time_limit_s(dsa, &tim, kind, timeout));
			return tim;
		}
		void getCLI2tTimeLimit(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_i2t_time_limit_s(dsa, tim, kind, timeout));
		}
		int getInitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int typ;
			ERRTRANS();
			ERRCHK(dsa_get_init_mode_s(dsa, &typ, kind, timeout));
			return typ;
		}
		void getInitMode(int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_init_mode_s(dsa, typ, kind, timeout));
		}
		double getInitPulseLevel(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_init_pulse_level_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getInitPulseLevel(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_init_pulse_level_s(dsa, cur, kind, timeout));
		}
		double getInitMaxCurrent(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_init_max_current_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getInitMaxCurrent(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_init_max_current_s(dsa, cur, kind, timeout));
		}
		double getInitFinalPhase(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cal;
			ERRTRANS();
			ERRCHK(dsa_get_init_final_phase_s(dsa, &cal, kind, timeout));
			return cal;
		}
		void getInitFinalPhase(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_init_final_phase_s(dsa, cal, kind, timeout));
		}
		double getInitTime(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double tim;
			ERRTRANS();
			ERRCHK(dsa_get_init_time_s(dsa, &tim, kind, timeout));
			return tim;
		}
		void getInitTime(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_init_time_s(dsa, tim, kind, timeout));
		}
		double getInitInitialPhase(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cal;
			ERRTRANS();
			ERRCHK(dsa_get_init_initial_phase_s(dsa, &cal, kind, timeout));
			return cal;
		}
		void getInitInitialPhase(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_init_initial_phase_s(dsa, cal, kind, timeout));
		}
		int getMonSourceType(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int typ;
			ERRTRANS();
			ERRCHK(dsa_get_mon_source_type_s(dsa, sidx, &typ, kind, timeout));
			return typ;
		}
		void getMonSourceType(int sidx, int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_mon_source_type_s(dsa, sidx, typ, kind, timeout));
		}
		int getMonSourceIndex(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int index;
			ERRTRANS();
			ERRCHK(dsa_get_mon_source_index_s(dsa, sidx, &index, kind, timeout));
			return index;
		}
		void getMonSourceIndex(int sidx, int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_mon_source_index_s(dsa, sidx, index, kind, timeout));
		}
		int getSyncroStartTimeout(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int tim;
			ERRTRANS();
			ERRCHK(dsa_get_syncro_start_timeout_s(dsa, &tim, kind, timeout));
			return tim;
		}
		void getSyncroStartTimeout(int *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_syncro_start_timeout_s(dsa, tim, kind, timeout));
		}
		dword getDigitalOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			dword out;
			ERRTRANS();
			ERRCHK(dsa_get_digital_output_s(dsa, &out, kind, timeout));
			return out;
		}
		void getDigitalOutput(dword *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_digital_output_s(dsa, out, kind, timeout));
		}
		dword getXDigitalOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			dword out;
			ERRTRANS();
			ERRCHK(dsa_get_x_digital_output_s(dsa, &out, kind, timeout));
			return out;
		}
		void getXDigitalOutput(dword *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_x_digital_output_s(dsa, out, kind, timeout));
		}
		double getXAnalogOutput1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double out;
			ERRTRANS();
			ERRCHK(dsa_get_x_analog_output_1_s(dsa, &out, kind, timeout));
			return out;
		}
		void getXAnalogOutput1(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_x_analog_output_1_s(dsa, out, kind, timeout));
		}
		double getXAnalogOutput2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double out;
			ERRTRANS();
			ERRCHK(dsa_get_x_analog_output_2_s(dsa, &out, kind, timeout));
			return out;
		}
		void getXAnalogOutput2(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_x_analog_output_2_s(dsa, out, kind, timeout));
		}
		double getXAnalogOutput3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double out;
			ERRTRANS();
			ERRCHK(dsa_get_x_analog_output_3_s(dsa, &out, kind, timeout));
			return out;
		}
		void getXAnalogOutput3(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_x_analog_output_3_s(dsa, out, kind, timeout));
		}
		double getXAnalogOutput4(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double out;
			ERRTRANS();
			ERRCHK(dsa_get_x_analog_output_4_s(dsa, &out, kind, timeout));
			return out;
		}
		void getXAnalogOutput4(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_x_analog_output_4_s(dsa, out, kind, timeout));
		}
		double getAnalogOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double out;
			ERRTRANS();
			ERRCHK(dsa_get_analog_output_s(dsa, &out, kind, timeout));
			return out;
		}
		void getAnalogOutput(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_analog_output_s(dsa, out, kind, timeout));
		}
		int getIndirectRegisterIdx(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int idx;
			ERRTRANS();
			ERRCHK(dsa_get_indirect_register_idx_s(dsa, &idx, kind, timeout));
			return idx;
		}
		void getIndirectRegisterIdx(int *idx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_indirect_register_idx_s(dsa, idx, kind, timeout));
		}
		int getConcatenatedMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int concat;
			ERRTRANS();
			ERRCHK(dsa_get_concatenated_mvt_s(dsa, &concat, kind, timeout));
			return concat;
		}
		void getConcatenatedMvt(int *concat, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_concatenated_mvt_s(dsa, concat, kind, timeout));
		}
		int getProfileType(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int typ;
			ERRTRANS();
			ERRCHK(dsa_get_profile_type_s(dsa, sidx, &typ, kind, timeout));
			return typ;
		}
		void getProfileType(int sidx, int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_profile_type_s(dsa, sidx, typ, kind, timeout));
		}
		int getMvtLktNumber(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int number;
			ERRTRANS();
			ERRCHK(dsa_get_mvt_lkt_number_s(dsa, sidx, &number, kind, timeout));
			return number;
		}
		void getMvtLktNumber(int sidx, int *number, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_mvt_lkt_number_s(dsa, sidx, number, kind, timeout));
		}
		double getMvtLktTime(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double time;
			ERRTRANS();
			ERRCHK(dsa_get_mvt_lkt_time_s(dsa, sidx, &time, kind, timeout));
			return time;
		}
		void getMvtLktTime(int sidx, double *time, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_mvt_lkt_time_s(dsa, sidx, time, kind, timeout));
		}
		double getCameValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double factor;
			ERRTRANS();
			ERRCHK(dsa_get_came_value_s(dsa, &factor, kind, timeout));
			return factor;
		}
		void getCameValue(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_came_value_s(dsa, factor, kind, timeout));
		}
		double getBrakeDeceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double dec;
			ERRTRANS();
			ERRCHK(dsa_get_brake_deceleration_s(dsa, &dec, kind, timeout));
			return dec;
		}
		void getBrakeDeceleration(double *dec, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_brake_deceleration_s(dsa, dec, kind, timeout));
		}
		double getTargetPosition(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_target_position_s(dsa, sidx, &pos, kind, timeout));
			return pos;
		}
		void getTargetPosition(int sidx, double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_target_position_s(dsa, sidx, pos, kind, timeout));
		}
		double getProfileVelocity(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double vel;
			ERRTRANS();
			ERRCHK(dsa_get_profile_velocity_s(dsa, sidx, &vel, kind, timeout));
			return vel;
		}
		void getProfileVelocity(int sidx, double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_profile_velocity_s(dsa, sidx, vel, kind, timeout));
		}
		double getProfileAcceleration(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double acc;
			ERRTRANS();
			ERRCHK(dsa_get_profile_acceleration_s(dsa, sidx, &acc, kind, timeout));
			return acc;
		}
		void getProfileAcceleration(int sidx, double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_profile_acceleration_s(dsa, sidx, acc, kind, timeout));
		}
		double getJerkTime(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double tim;
			ERRTRANS();
			ERRCHK(dsa_get_jerk_time_s(dsa, sidx, &tim, kind, timeout));
			return tim;
		}
		void getJerkTime(int sidx, double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_jerk_time_s(dsa, sidx, tim, kind, timeout));
		}
		int getCtrlSourceType(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int typ;
			ERRTRANS();
			ERRCHK(dsa_get_ctrl_source_type_s(dsa, &typ, kind, timeout));
			return typ;
		}
		void getCtrlSourceType(int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_ctrl_source_type_s(dsa, typ, kind, timeout));
		}
		int getCtrlSourceIndex(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int index;
			ERRTRANS();
			ERRCHK(dsa_get_ctrl_source_index_s(dsa, &index, kind, timeout));
			return index;
		}
		void getCtrlSourceIndex(int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_ctrl_source_index_s(dsa, index, kind, timeout));
		}
		long getCtrlOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			long offset;
			ERRTRANS();
			ERRCHK(dsa_get_ctrl_offset_s(dsa, &offset, kind, timeout));
			return offset;
		}
		void getCtrlOffset(long *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_ctrl_offset_s(dsa, offset, kind, timeout));
		}
		double getCtrlGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double gain;
			ERRTRANS();
			ERRCHK(dsa_get_ctrl_gain_s(dsa, &gain, kind, timeout));
			return gain;
		}
		void getCtrlGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_ctrl_gain_s(dsa, gain, kind, timeout));
		}
		double getMotorKTFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double kt;
			ERRTRANS();
			ERRCHK(dsa_get_motor_kt_factor_s(dsa, &kt, kind, timeout));
			return kt;
		}
		void getMotorKTFactor(double *kt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_motor_kt_factor_s(dsa, kt, kind, timeout));
		}
		double getPositionCtrlError(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double err;
			ERRTRANS();
			ERRCHK(dsa_get_position_ctrl_error_s(dsa, &err, kind, timeout));
			return err;
		}
		void getPositionCtrlError(double *err, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_position_ctrl_error_s(dsa, err, kind, timeout));
		}
		double getPositionMaxError(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double err;
			ERRTRANS();
			ERRCHK(dsa_get_position_max_error_s(dsa, &err, kind, timeout));
			return err;
		}
		void getPositionMaxError(double *err, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_position_max_error_s(dsa, err, kind, timeout));
		}
		double getPositionDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_position_demand_value_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getPositionDemandValue(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_position_demand_value_s(dsa, pos, kind, timeout));
		}
		double getPositionActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double pos;
			ERRTRANS();
			ERRCHK(dsa_get_position_actual_value_s(dsa, &pos, kind, timeout));
			return pos;
		}
		void getPositionActualValue(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_position_actual_value_s(dsa, pos, kind, timeout));
		}
		double getVelocityDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double vel;
			ERRTRANS();
			ERRCHK(dsa_get_velocity_demand_value_s(dsa, &vel, kind, timeout));
			return vel;
		}
		void getVelocityDemandValue(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_velocity_demand_value_s(dsa, vel, kind, timeout));
		}
		double getVelocityActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double vel;
			ERRTRANS();
			ERRCHK(dsa_get_velocity_actual_value_s(dsa, &vel, kind, timeout));
			return vel;
		}
		void getVelocityActualValue(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_velocity_actual_value_s(dsa, vel, kind, timeout));
		}
		double getAccDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double acc;
			ERRTRANS();
			ERRCHK(dsa_get_acc_demand_value_s(dsa, &acc, kind, timeout));
			return acc;
		}
		void getAccDemandValue(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_acc_demand_value_s(dsa, acc, kind, timeout));
		}
		double getCLCurrentPhase1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_cl_current_phase_1_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getCLCurrentPhase1(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_current_phase_1_s(dsa, cur, kind, timeout));
		}
		double getCLCurrentPhase2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_cl_current_phase_2_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getCLCurrentPhase2(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_current_phase_2_s(dsa, cur, kind, timeout));
		}
		double getCLCurrentPhase3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_cl_current_phase_3_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getCLCurrentPhase3(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_current_phase_3_s(dsa, cur, kind, timeout));
		}
		double getCLLktPhase1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double lkt;
			ERRTRANS();
			ERRCHK(dsa_get_cl_lkt_phase_1_s(dsa, &lkt, kind, timeout));
			return lkt;
		}
		void getCLLktPhase1(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_lkt_phase_1_s(dsa, lkt, kind, timeout));
		}
		double getCLLktPhase2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double lkt;
			ERRTRANS();
			ERRCHK(dsa_get_cl_lkt_phase_2_s(dsa, &lkt, kind, timeout));
			return lkt;
		}
		void getCLLktPhase2(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_lkt_phase_2_s(dsa, lkt, kind, timeout));
		}
		double getCLLktPhase3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double lkt;
			ERRTRANS();
			ERRCHK(dsa_get_cl_lkt_phase_3_s(dsa, &lkt, kind, timeout));
			return lkt;
		}
		void getCLLktPhase3(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_lkt_phase_3_s(dsa, lkt, kind, timeout));
		}
		double getCLDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_cl_demand_value_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getCLDemandValue(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_demand_value_s(dsa, cur, kind, timeout));
		}
		double getCLActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double cur;
			ERRTRANS();
			ERRCHK(dsa_get_cl_actual_value_s(dsa, &cur, kind, timeout));
			return cur;
		}
		void getCLActualValue(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_actual_value_s(dsa, cur, kind, timeout));
		}
		double getEncoderSineSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double val;
			ERRTRANS();
			ERRCHK(dsa_get_encoder_sine_signal_s(dsa, &val, kind, timeout));
			return val;
		}
		void getEncoderSineSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_encoder_sine_signal_s(dsa, val, kind, timeout));
		}
		double getEncoderCosineSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double val;
			ERRTRANS();
			ERRCHK(dsa_get_encoder_cosine_signal_s(dsa, &val, kind, timeout));
			return val;
		}
		void getEncoderCosineSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_encoder_cosine_signal_s(dsa, val, kind, timeout));
		}
		dword getEncoderHallDigSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			dword mask;
			ERRTRANS();
			ERRCHK(dsa_get_encoder_hall_dig_signal_s(dsa, &mask, kind, timeout));
			return mask;
		}
		void getEncoderHallDigSignal(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_encoder_hall_dig_signal_s(dsa, mask, kind, timeout));
		}
		dword getDigitalInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			dword inp;
			ERRTRANS();
			ERRCHK(dsa_get_digital_input_s(dsa, &inp, kind, timeout));
			return inp;
		}
		void getDigitalInput(dword *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_digital_input_s(dsa, inp, kind, timeout));
		}
		double getAnalogInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double inp;
			ERRTRANS();
			ERRCHK(dsa_get_analog_input_s(dsa, &inp, kind, timeout));
			return inp;
		}
		void getAnalogInput(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_analog_input_s(dsa, inp, kind, timeout));
		}
		dword getXDigitalInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			dword inp;
			ERRTRANS();
			ERRCHK(dsa_get_x_digital_input_s(dsa, &inp, kind, timeout));
			return inp;
		}
		void getXDigitalInput(dword *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_x_digital_input_s(dsa, inp, kind, timeout));
		}
		double getXAnalogInput1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double inp;
			ERRTRANS();
			ERRCHK(dsa_get_x_analog_input_1_s(dsa, &inp, kind, timeout));
			return inp;
		}
		void getXAnalogInput1(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_x_analog_input_1_s(dsa, inp, kind, timeout));
		}
		double getXAnalogInput2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double inp;
			ERRTRANS();
			ERRCHK(dsa_get_x_analog_input_2_s(dsa, &inp, kind, timeout));
			return inp;
		}
		void getXAnalogInput2(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_x_analog_input_2_s(dsa, inp, kind, timeout));
		}
		double getXAnalogInput3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double inp;
			ERRTRANS();
			ERRCHK(dsa_get_x_analog_input_3_s(dsa, &inp, kind, timeout));
			return inp;
		}
		void getXAnalogInput3(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_x_analog_input_3_s(dsa, inp, kind, timeout));
		}
		double getXAnalogInput4(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double inp;
			ERRTRANS();
			ERRCHK(dsa_get_x_analog_input_4_s(dsa, &inp, kind, timeout));
			return inp;
		}
		void getXAnalogInput4(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_x_analog_input_4_s(dsa, inp, kind, timeout));
		}
		dword getDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			dword mask;
			ERRTRANS();
			ERRCHK(dsa_get_drive_status_1_s(dsa, &mask, kind, timeout));
			return mask;
		}
		void getDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_drive_status_1_s(dsa, mask, kind, timeout));
		}
		dword getDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			dword mask;
			ERRTRANS();
			ERRCHK(dsa_get_drive_status_2_s(dsa, &mask, kind, timeout));
			return mask;
		}
		void getDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_drive_status_2_s(dsa, mask, kind, timeout));
		}
		double getCLI2tValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double val;
			ERRTRANS();
			ERRCHK(dsa_get_cl_i2t_value_s(dsa, &val, kind, timeout));
			return val;
		}
		void getCLI2tValue(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_cl_i2t_value_s(dsa, val, kind, timeout));
		}
		int getAxisNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int num;
			ERRTRANS();
			ERRCHK(dsa_get_axis_number_s(dsa, &num, kind, timeout));
			return num;
		}
		void getAxisNumber(int *num, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_axis_number_s(dsa, num, kind, timeout));
		}
		double getDriveTemperature(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			double temp;
			ERRTRANS();
			ERRCHK(dsa_get_drive_temperature_s(dsa, &temp, kind, timeout));
			return temp;
		}
		void getDriveTemperature(double *temp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_drive_temperature_s(dsa, temp, kind, timeout));
		}
		dword getDriveDisplay(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			dword str;
			ERRTRANS();
			ERRCHK(dsa_get_drive_display_s(dsa, sidx, &str, kind, timeout));
			return str;
		}
		void getDriveDisplay(int sidx, dword *str, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_drive_display_s(dsa, sidx, str, kind, timeout));
		}
		long getDriveSequenceLine(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			long line;
			ERRTRANS();
			ERRCHK(dsa_get_drive_sequence_line_s(dsa, &line, kind, timeout));
			return line;
		}
		void getDriveSequenceLine(long *line, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_drive_sequence_line_s(dsa, line, kind, timeout));
		}
		dword getDriveFuseStatus(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			dword mask;
			ERRTRANS();
			ERRCHK(dsa_get_drive_fuse_status_s(dsa, &mask, kind, timeout));
			return mask;
		}
		void getDriveFuseStatus(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_drive_fuse_status_s(dsa, mask, kind, timeout));
		}
		double getSequenceCodeUsage(long timeout = DEF_TIMEOUT) {
			double percentage;
			ERRCHK(dsa_get_sequence_code_usage_s(dsa, &percentage, timeout));
			return percentage;
		}
		double getSequenceSourceUsage(long timeout = DEF_TIMEOUT) {
			double percentage;
			ERRCHK(dsa_get_sequence_source_usage_s(dsa, &percentage, timeout));
			return percentage;
		}
		double getSequenceDataUsage(long timeout = DEF_TIMEOUT) {
			double percentage;
			ERRCHK(dsa_get_sequence_data_usage_s(dsa, &percentage, timeout));
			return percentage;
		}
		int getNbAvailableSlot(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int nb_free;
			ERRTRANS();
			ERRCHK(dsa_get_nb_available_slots_s(dsa, &nb_free, kind, timeout));
			return nb_free;
		}
		void getNbAvailableSlot(int *nb_free, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_get_nb_available_slots_s(dsa, nb_free, kind, timeout));
		}
		int getDebugSequenceNbBreakpoints(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int nb_breakpoints;
			ERRCHK(dsa_debug_sequence_get_nb_breakpoints_s(dsa, &nb_breakpoints, kind, timeout));
			return nb_breakpoints;
		}
		int getDebugSequenceBreakThreadNb(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
			int break_thread_nb;
			ERRCHK(dsa_debug_sequence_get_break_thread_nb_s(dsa, &break_thread_nb, kind, timeout));
			return break_thread_nb;
		}


	/*
	 * register getter - asynchronous
	 */
	protected:
		void getPLProportionalGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_proportional_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLProportionalGain(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_proportional_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLSpeedFeedbackGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_speed_feedback_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLSpeedFeedbackGain(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_speed_feedback_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLIntegratorGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_integrator_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLIntegratorGain(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_integrator_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLAntiWindupGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_anti_windup_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLAntiWindupGain(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_anti_windup_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLIntegratorLimitation(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_integrator_limitation_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLIntegratorLimitation(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_integrator_limitation_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLIntegratorMode(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_integrator_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getPLIntegratorMode(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_integrator_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getTtlSpeedlFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_ttl_speed_filter_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getTtlSpeedlFilter(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_ttl_speed_filter_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLAccFeedforwardGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_acc_feedforward_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPLAccFeedforwardGain(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_pl_acc_feedforward_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getMaxPositionRangeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_max_position_range_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getMaxPositionRangeLimit(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_max_position_range_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getFollowingErrorWindow(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_following_error_window_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getFollowingErrorWindow(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_following_error_window_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getVelocityErrorLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_velocity_error_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getVelocityErrorLimit(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_velocity_error_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getSwitchLimitMode(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_switch_limit_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getSwitchLimitMode(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_switch_limit_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getEnableInputMode(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_enable_input_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getEnableInputMode(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_enable_input_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getMinSoftPositionLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_min_soft_position_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getMinSoftPositionLimit(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_min_soft_position_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getMaxSoftPositionLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_max_soft_position_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getMaxSoftPositionLimit(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_max_soft_position_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getProfileLimitMode(int kind, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_profile_limit_mode_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
		}
		void getProfileLimitMode(DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_profile_limit_mode_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
		}
		void getPositionWindowTime(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_window_time_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionWindowTime(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_window_time_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionWindow(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_window_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionWindow(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_window_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingMethod(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_method_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getHomingMethod(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_method_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getHomingZeroSpeed(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_zero_speed_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingZeroSpeed(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_zero_speed_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingAcceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_acceleration_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingAcceleration(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_acceleration_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingFollowingLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_following_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingFollowingLimit(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_following_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_current_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_current_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomeOffset(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_home_offset_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomeOffset(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_home_offset_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingFixedMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_fixed_mvt_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingFixedMvt(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_fixed_mvt_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingSwitchMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_switch_mvt_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingSwitchMvt(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_switch_mvt_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingIndexMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_index_mvt_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingIndexMvt(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_index_mvt_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingFineTuningMode(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_fine_tuning_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getHomingFineTuningMode(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_fine_tuning_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getHomingFineTuningValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_fine_tuning_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getHomingFineTuningValue(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_homing_fine_tuning_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getMotorPhaseCorrection(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_motor_phase_correction_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getMotorPhaseCorrection(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_motor_phase_correction_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getSoftwareCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_software_current_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getSoftwareCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_software_current_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getDriveControlMode(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_control_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getDriveControlMode(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_control_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getDisplayMode(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_display_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getDisplayMode(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_display_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getEncoderInversion(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_inversion_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderInversion(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_inversion_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderPhase1Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_phase_1_offset_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderPhase1Offset(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_phase_1_offset_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderPhase2Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_phase_2_offset_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderPhase2Offset(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_phase_2_offset_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderPhase1Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_phase_1_factor_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderPhase1Factor(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_phase_1_factor_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderPhase2Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_phase_2_factor_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderPhase2Factor(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_phase_2_factor_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderIndexDistance(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_index_distance_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderIndexDistance(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_index_distance_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLProportionalGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_proportional_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLProportionalGain(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_proportional_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLIntegratorGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_integrator_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLIntegratorGain(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_integrator_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_current_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_current_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLI2tCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_i2t_current_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLI2tCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_i2t_current_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLI2tTimeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_i2t_time_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLI2tTimeLimit(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_i2t_time_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getInitMode(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getInitMode(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getInitPulseLevel(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_pulse_level_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getInitPulseLevel(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_pulse_level_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getInitMaxCurrent(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_max_current_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getInitMaxCurrent(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_max_current_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getInitFinalPhase(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_final_phase_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getInitFinalPhase(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_final_phase_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getInitTime(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_time_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getInitTime(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_time_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getInitInitialPhase(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_initial_phase_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getInitInitialPhase(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_init_initial_phase_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getMonSourceType(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_mon_source_type_a(dsa, sidx, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getMonSourceType(int sidx, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_mon_source_type_a(dsa, sidx, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getMonSourceIndex(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_mon_source_index_a(dsa, sidx, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getMonSourceIndex(int sidx, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_mon_source_index_a(dsa, sidx, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getSyncroStartTimeout(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_syncro_start_timeout_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getSyncroStartTimeout(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_syncro_start_timeout_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getDigitalOutput(int kind, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_digital_output_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
		}
		void getDigitalOutput(DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_digital_output_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
		}
		void getXDigitalOutput(int kind, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_digital_output_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
		}
		void getXDigitalOutput(DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_digital_output_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
		}
		void getXAnalogOutput1(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_output_1_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogOutput1(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_output_1_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogOutput2(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_output_2_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogOutput2(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_output_2_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogOutput3(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_output_3_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogOutput3(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_output_3_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogOutput4(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_output_4_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogOutput4(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_output_4_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getAnalogOutput(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_analog_output_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getAnalogOutput(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_analog_output_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getIndirectRegisterIdx(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_indirect_register_idx_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getIndirectRegisterIdx(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_indirect_register_idx_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getConcatenatedMvt(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_concatenated_mvt_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getConcatenatedMvt(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_concatenated_mvt_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getProfileType(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_profile_type_a(dsa, sidx, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getProfileType(int sidx, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_profile_type_a(dsa, sidx, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getMvtLktNumber(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_mvt_lkt_number_a(dsa, sidx, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getMvtLktNumber(int sidx, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_mvt_lkt_number_a(dsa, sidx, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getMvtLktTime(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_mvt_lkt_time_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getMvtLktTime(int sidx, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_mvt_lkt_time_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCameValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_came_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCameValue(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_came_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getBrakeDeceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_brake_deceleration_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getBrakeDeceleration(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_brake_deceleration_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getTargetPosition(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_target_position_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getTargetPosition(int sidx, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_target_position_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getProfileVelocity(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_profile_velocity_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getProfileVelocity(int sidx, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_profile_velocity_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getProfileAcceleration(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_profile_acceleration_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getProfileAcceleration(int sidx, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_profile_acceleration_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getJerkTime(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_jerk_time_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getJerkTime(int sidx, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_jerk_time_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCtrlSourceType(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_ctrl_source_type_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getCtrlSourceType(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_ctrl_source_type_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getCtrlSourceIndex(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_ctrl_source_index_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getCtrlSourceIndex(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_ctrl_source_index_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getCtrlOffset(int kind, DsaLongHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_ctrl_offset_a(dsa, kind, (DSA_LONG_HANDLER)handler, param));
		}
		void getCtrlOffset(DsaLongHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_ctrl_offset_a(dsa, GET_CURRENT, (DSA_LONG_HANDLER)handler, param));
		}
		void getCtrlGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_ctrl_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCtrlGain(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_ctrl_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getMotorKTFactor(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_motor_kt_factor_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getMotorKTFactor(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_motor_kt_factor_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionCtrlError(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_ctrl_error_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionCtrlError(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_ctrl_error_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionMaxError(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_max_error_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionMaxError(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_max_error_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_demand_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionDemandValue(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_demand_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_actual_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getPositionActualValue(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_position_actual_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getVelocityDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_velocity_demand_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getVelocityDemandValue(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_velocity_demand_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getVelocityActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_velocity_actual_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getVelocityActualValue(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_velocity_actual_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getAccDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_acc_demand_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getAccDemandValue(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_acc_demand_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLCurrentPhase1(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_current_phase_1_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLCurrentPhase1(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_current_phase_1_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLCurrentPhase2(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_current_phase_2_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLCurrentPhase2(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_current_phase_2_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLCurrentPhase3(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_current_phase_3_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLCurrentPhase3(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_current_phase_3_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLLktPhase1(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_lkt_phase_1_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLLktPhase1(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_lkt_phase_1_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLLktPhase2(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_lkt_phase_2_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLLktPhase2(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_lkt_phase_2_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLLktPhase3(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_lkt_phase_3_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLLktPhase3(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_lkt_phase_3_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_demand_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLDemandValue(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_demand_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_actual_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLActualValue(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_actual_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderSineSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_sine_signal_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderSineSignal(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_sine_signal_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderCosineSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_cosine_signal_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderCosineSignal(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_cosine_signal_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getEncoderHallDigSignal(int kind, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_hall_dig_signal_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
		}
		void getEncoderHallDigSignal(DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_encoder_hall_dig_signal_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
		}
		void getDigitalInput(int kind, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_digital_input_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
		}
		void getDigitalInput(DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_digital_input_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
		}
		void getAnalogInput(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_analog_input_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getAnalogInput(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_analog_input_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXDigitalInput(int kind, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_digital_input_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
		}
		void getXDigitalInput(DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_digital_input_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
		}
		void getXAnalogInput1(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_input_1_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogInput1(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_input_1_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogInput2(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_input_2_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogInput2(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_input_2_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogInput3(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_input_3_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogInput3(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_input_3_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogInput4(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_input_4_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getXAnalogInput4(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_x_analog_input_4_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_status_1_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
		}
		void getDriveStatus1(DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_status_1_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
		}
		void getDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_status_2_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
		}
		void getDriveStatus2(DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_status_2_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
		}
		void getCLI2tValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_i2t_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getCLI2tValue(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_cl_i2t_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getAxisNumber(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_axis_number_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getAxisNumber(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_axis_number_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getDriveTemperature(int kind, DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_temperature_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getDriveTemperature(DsaDoubleHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_temperature_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
		}
		void getDriveDisplay(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_display_a(dsa, sidx, kind, (DSA_DWORD_HANDLER)handler, param));
		}
		void getDriveDisplay(int sidx, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_display_a(dsa, sidx, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
		}
		void getDriveSequenceLine(int kind, DsaLongHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_sequence_line_a(dsa, kind, (DSA_LONG_HANDLER)handler, param));
		}
		void getDriveSequenceLine(DsaLongHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_sequence_line_a(dsa, GET_CURRENT, (DSA_LONG_HANDLER)handler, param));
		}
		void getDriveFuseStatus(int kind, DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_fuse_status_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
		}
		void getDriveFuseStatus(DsaDWordHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_drive_fuse_status_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
		}
		void getNbAvailableSlot(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_nb_available_slots_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getNbAvailableSlot(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_get_nb_available_slots_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getDebugSequenceNbBreakpoints(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_debug_sequence_get_nb_breakpoints_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getDebugSequenceNbBreakpoints(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_debug_sequence_get_nb_breakpoints_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}
		void getDebugSequenceBreakThreadNb(int kind, DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_debug_sequence_get_break_thread_nb_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
		}
		void getDebugSequenceBreakThreadNb(DsaIntHandler handler, void *param = NULL) {
			ERRCHK(dsa_debug_sequence_get_break_thread_nb_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
		}

	/*
	 * IO management - synchronous
	 */

		//ExternalIO Management functions
		void externalIOSetEnableCyclicUpdate(bool enable, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_set_enable_cyclic_update_s(dsa, enable, timeout));
		}
		void externalIOResetClientCommunication(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_reset_client_communication_s(dsa, timeout));
		}
		void externalIOResetIOCycleCount(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_reset_io_cycle_count_s(dsa, timeout));
		}
		void externalIOResetMaxUpdateTime(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_reset_max_update_time_s(dsa, timeout));
		}

		//ExternalIO Watchdog functions
		void externalIOEnableWatchdog(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_enable_watchdog_s(dsa, timeout));
		}
		void externalIODisableWatchdog(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_disable_watchdog_s(dsa, timeout));
		}
		void externalIOStopWatchdog(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_stop_watchdog_s(dsa, timeout));
		}
		void externalIOSetWatchdogTime(int value, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_set_watchdog_time_s(dsa, value, timeout));
		}

		//ExternalIO digital output functions
		void externalIOSetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_set_digital_output_s(dsa, outputIdx, timeout));
		}
		void externalIOResetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_reset_digital_output_s(dsa, outputIdx, timeout));
		}
		void externalIOApplyMaskDigitalOutput(int firstOutputIdx, int numberBits, dword value, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_apply_mask_digital_output_s(dsa, firstOutputIdx, numberBits, value, timeout));
		}
		dword externalIOGetDigitalOutput(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_externalIO_get_digital_output_s(dsa, outputIdx, &value, fast, timeout));
			return value;
		}
		dword externalIOGetDigitalOutputState(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_externalIO_get_digital_output_state_s(dsa, outputIdx, &value, fast, timeout));
			return value;
		}

		dword externalIOGetMaskedDigitalOutput(int firstOutputIdx, int numberBits, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_externalIO_get_masked_digital_output_s(dsa, firstOutputIdx, numberBits, &value, fast, timeout));
			return value;
		}
		dword externalIOGetMaskedDigitalOutputState(int firstOutputIdx, int numberBits, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_externalIO_get_masked_digital_output_state_s(dsa, firstOutputIdx, numberBits, &value, fast, timeout));
			return value;
		}

		//ExternalIO analog output functions
		void externalIOSetAnalogOutputRawData(int outputIdx, dword value, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_set_analog_output_raw_data_s(dsa, outputIdx, value, timeout));
		}
		void externalIOSetAnalogOutputConvertedData(int outputIdx, float value, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_set_analog_output_converted_data_s(dsa, outputIdx, value, timeout));
		}
		dword externalIOGetAnalogOutputRawData(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_externalIO_get_analog_output_raw_data_s(dsa, outputIdx, &value, fast, timeout));
			return value;
		}
		dword externalIOGetAnalogOutputRawDataState(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_externalIO_get_analog_output_raw_data_state_s(dsa, outputIdx, &value, fast, timeout));
			return value;
		}
		float externalIOGetAnalogOutputConvertedData(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			float value;
			ERRCHK(dsa_externalIO_get_analog_output_converted_data_s(dsa, outputIdx, &value, fast, timeout));
			return value;
		}
		float externalIOGetAnalogOutputConvertedDataState(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			float value;
			ERRCHK(dsa_externalIO_get_analog_output_converted_data_state_s(dsa, outputIdx, &value, fast, timeout));
			return value;
		}

		//ExternalIO digital input functions
		dword externalIOGetDigitalInputState(int inputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_externalIO_get_digital_input_state_s(dsa, inputIdx, &value, fast, timeout));
			return value;
		}
		dword externalIOGetMaskedDigitalInputState(int firstinputIdx, int numberBits, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_externalIO_get_masked_digital_input_state_s(dsa, firstinputIdx, numberBits, &value, fast, timeout));
			return value;
		}

		//ExternalIO analog input functions
		dword externalIOGetAnalogInputRawDataState(int inputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_externalIO_get_analog_input_raw_data_state_s(dsa, inputIdx, &value, fast, timeout));
			return value;
		}
		float externalIOGetAnalogInputConvertedDataState(int inputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			float value;
			ERRCHK(dsa_externalIO_get_analog_input_converted_data_state_s(dsa, inputIdx, &value, fast, timeout));
			return value;
		}

		//ExternalIO direct modbus functions
		void externalIOSetModbusRegister(int registerAddress, dword value, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_externalIO_set_modbus_register_s(dsa, registerAddress, value, timeout));
		}
		dword externalIOGetModbusRegister(int registerAddress, int wordCount, int wordNumber, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_externalIO_get_modbus_register_s(dsa, registerAddress, wordCount, wordNumber, &value, timeout));
			return value;
		}

		//LocalIO digital output functions
		void localIOSetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_localIO_set_digital_output_s(dsa, outputIdx, timeout));
		}
		void localIOResetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_localIO_reset_digital_output_s(dsa, outputIdx, timeout));
		}
		dword localIOGetDigitalOutput(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_localIO_get_digital_output_s(dsa, outputIdx, &value, fast, timeout));
			return value;
		}
		void localIOApplyMaskDigitalOutput(int firstOutputIdx, int numberBits, dword value, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_localIO_apply_mask_digital_output_s(dsa, firstOutputIdx, numberBits, value, timeout));
		}
		dword localIOGetMaskedDigitalOutput(int firstOutputIdx, int numberBits, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_localIO_get_masked_digital_output_s(dsa, firstOutputIdx, numberBits, &value, fast, timeout));
			return value;
		}

		//LocalIO digital input functions
		dword localIOGetDigitalInputState(int inputIdx, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_localIO_get_digital_input_state_s(dsa, inputIdx, &value, fast, timeout));
			return value;
		}
		dword localIOGetMaskedDigitalInputState(int firstinputIdx, int numberBits, bool fast, long timeout = DEF_TIMEOUT) {
			dword value;
			ERRCHK(dsa_localIO_get_masked_digital_input_state_s(dsa, firstinputIdx, numberBits, &value, fast, timeout));
			return value;
		}

		//Debug Sequence functions
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_debug_sequence_enable_breakpoint_at_s(dsa, codeOffset, enable, timeout));
		}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_debug_sequence_enable_breakpoint_at_a(dsa, codeOffset, enable, (DSA_HANDLER)handler, param));
		}

		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_debug_sequence_enable_breakpoint_everywhere_s(dsa, enable, timeout));
		}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_debug_sequence_enable_breakpoint_everywhere_a(dsa, enable, (DSA_HANDLER)handler, param));
		}

		void debugSequenceContinue(long timeout = DEF_TIMEOUT) {
			ERRCHK(dsa_debug_sequence_continue_s(dsa, timeout));
		}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_debug_sequence_continue_a(dsa, (DSA_HANDLER)handler, param));
		}
};


/*------------------------------------------------------------------------------
 * DsaDeviceBase Class - C++
 *-----------------------------------------------------------------------------*/
class DsaDeviceBase: public DsaBase {
    friend class Dsa;

	/* constructors */
	protected:
		DsaDeviceBase(void) {}
	public:
		DsaDeviceBase(DSA_DEVICE_BASE *dev) {
			if (!dsa_is_valid_device_base(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaDeviceBase(DsaDeviceBase &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaDeviceBase(DsaBase &obj) {
			if (!dsa_is_valid_device_base(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}

	/* operators */
	public:
		DsaDeviceBase operator = (DsaDeviceBase &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaDeviceBase operator = (DsaBase &obj) {
			if (!dsa_is_valid_device_base(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		/* functions */
		#ifdef DSA_IMPL_S
			void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
			void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
			void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
			void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
			void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
			void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
			void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
			void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
			void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}

			void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
			void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
			void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
			void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
			void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
			void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
			void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
			void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
			void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
			void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}

			void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
			void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
			void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
			void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
			void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
			void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
			void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
			void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}
		#endif /* DSA_IMPL_S */
		#ifdef DSA_IMPL_A
			void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
			void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
			void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
			void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
			void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
			void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
			void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
			void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
			void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}

			void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
			void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
			void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
			void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
			void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
			void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
			void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
			void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
			void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
			void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
			void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
			void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
			void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
			void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
			void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
			void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
			void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
			void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}
		#endif /* DSA_IMPL_A */

		void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
		void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
		void cancelStatusWait() {DsaBase::cancelStatusWait();}
		void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}

		/* commands */
		void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
		void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
		void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
		void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
		void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
		void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
		void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

		void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
		void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
		void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
		void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
		void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
		void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
	    int getFamily() {return DsaBase::getFamily();}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
		void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
		void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}
};


/*------------------------------------------------------------------------------
 * DsaHandlerDeviceBase class - C++
 *-----------------------------------------------------------------------------*/
class DsaHandlerDeviceBase: public DsaDeviceBase {
    /* constructors - destructors */
	protected:
		DsaHandlerDeviceBase(void) { }
		DsaHandlerDeviceBase(DsaHandlerDeviceBase &obj) {}
	public:
		//This destructor has to call dsa_share, because this object is the device object of a asynchronous
		//handler, and thus is not constructed => not shared => not destructable by dsabase destructor
		//which will be called
		//By sharing this object at destruction, we allow the call of the DsaBase destructor
		~DsaHandlerDeviceBase(void) {
			if (dsa)
				ERRCHK(dsa_share(dsa));
		}
		/* operators */
	protected:
		DsaHandlerDeviceBase operator = (DsaHandlerDeviceBase &obj) {
			return obj;
		}
};


/*------------------------------------------------------------------------------
 * DsaDevice class - C++
 *-----------------------------------------------------------------------------*/
class DsaDevice: public DsaBase {
    /* constructors */
	protected:
		DsaDevice(void) {
		}
	public:
		DsaDevice(DSA_DEVICE *dev) {
			if (!dsa_is_valid_device(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaDevice(DsaDevice &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaDevice(DsaBase &obj) {
			if (!dsa_is_valid_device(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
    /* operators */
	public:
		DsaDevice operator = (DsaDevice &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaDevice operator = (DsaBase &obj) {
			if (!dsa_is_valid_device(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
    /* functions */
    #ifdef DSA_IMPL_S
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
		int  getWarningCode(int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getWarningCode(kind, timeout);}
		int  getErrorCode(int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getErrorCode(kind, timeout);}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}

		long getRegister(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegister(typ, idx, sidx, kind, timeout);}
		long getRegisterInt32(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterInt32(typ, idx, sidx, kind, timeout);}
		eint64 getRegisterInt64(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterInt64(typ, idx, sidx, kind, timeout);}
		float getRegisterFloat32(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterFloat32(typ, idx, sidx, kind, timeout);}
		double getRegisterFloat64(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterFloat64(typ, idx, sidx, kind, timeout);}
		void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayInt32(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayInt64(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayFloat32(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayFloat64(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		int  getParametersVersion(int what, long timeout = DEF_TIMEOUT) {return DsaBase::getParametersVersion(what, timeout);}
		double getSequenceCodeUsage(long timeout = DEF_TIMEOUT) {DsaBase::getSequenceCodeUsage(timeout);}
		double getSequenceSourceUsage(long timeout = DEF_TIMEOUT) {DsaBase::getSequenceSourceUsage(timeout);}
		double getSequenceDataUsage(long timeout = DEF_TIMEOUT) {DsaBase::getSequenceDataUsage(timeout);}
		int getDebugSequenceNbBreakpoints(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDebugSequenceNbBreakpoints(kind, timeout);}
		int getDebugSequenceBreakThreadNb(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDebugSequenceBreakThreadNb(kind, timeout);}

		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}
		double  getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, timeout);}
		void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, timeout);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
		void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout = DEF_TIMEOUT) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, timeout);}
		DsaStatus  waitStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusEqual(mask, ref, timeout);}
		DsaStatus  waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusNotEqual(mask, ref, timeout);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
		DsaStatus  waitStatusChange(DsaStatus *mask, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusChange(mask, timeout);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}
    #endif /* DSA_IMPL_S */
    #ifdef DSA_IMPL_A
		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
		void getWarningCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getWarningCode(kind, handler, param);}
		void getErrorCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getErrorCode(kind, handler, param);}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
		void getRegister(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getRegister(typ, idx, sidx, kind, handler, param);}
		void getRegisterInt32(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getRegisterInt32(typ, idx, sidx, kind, handler, param);}
		void getRegisterInt64(int typ, unsigned idx, int sidx, int kind, DsaInt64Handler handler, void *param = NULL) {DsaBase::getRegisterInt64(typ, idx, sidx, kind, handler, param);}
		void getRegisterFloat32(int typ, unsigned idx, int sidx, int kind, DsaFloatHandler handler, void *param = NULL) {DsaBase::getRegisterFloat32(typ, idx, sidx, kind, handler, param);}
		void getRegisterFloat64(int typ, unsigned idx, int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getRegisterFloat64(typ, idx, sidx, kind, handler, param);}
		void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, handler, param);}
		void getParametersVersion(int what, DsaIntHandler handler, void *param = NULL) {DsaBase::getParametersVersion(what, handler, param);}
		void getDebugSequenceNbBreakpoints(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceNbBreakpoints(kind, handler, param);}
		void getDebugSequenceNbBreakpoints(DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceNbBreakpoints(handler, param);}
		void getDebugSequenceBreakThreadNb(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceBreakThreadNb(kind, handler, param);}
		void getDebugSequenceBreakThreadNb(DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceBreakThreadNb(handler, param);}

		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, handler, param);}
		void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, handler, param);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
		void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, Dsa2intHandler handler, void *param = NULL) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, handler, param);}
		void waitStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusEqual(mask, ref, handler, param);}
		void waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusNotEqual(mask, ref, handler, param);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
		void waitStatusChange(DsaStatus *mask, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusChange(mask, handler, param);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}
    #endif /* DSA_IMPL_A */
    void etcomOpen(EtbBus etb, int axis) {DsaBase::etcomOpen(etb, axis);}
    void open(char_cp url) {DsaBase::open(url);}
    void etcomOpen(EtbBus etb, int axis, dword flags) {DsaBase::etcomOpen(etb, axis, flags);}
    void reset() {DsaBase::reset();}
    void close() {DsaBase::close();}
    EtbBus  getEtbBus() {return DsaBase::getEtbBus();}
    int  etcomGetEtbAxis() {return DsaBase::etcomGetEtbAxis();}
    bool  isOpen() {return DsaBase::isOpen();}
    int getMotorTyp() {return DsaBase::getMotorTyp();}
    void getErrorText(char_p text, int size, int code) {DsaBase::getErrorText(text, size, code);}
    void getWarningText(char_p text, int size, int code) {DsaBase::getWarningText(text, size, code);}
    double  convertToIso(long inc, int conv) {return DsaBase::convertToIso(inc, conv);}
    double  convertInt32ToIso(long inc, int conv) {return DsaBase::convertInt32ToIso(inc, conv);}
    double  convertInt64ToIso(eint64 inc, int conv) {return DsaBase::convertInt64ToIso(inc, conv);}
    double  convertFloat32ToIso(float inc, int conv) {return DsaBase::convertFloat32ToIso(inc, conv);}
    double  convertFloat64ToIso(double inc, int conv) {return DsaBase::convertFloat64ToIso(inc, conv);}
    long  convertFromIso(double iso, int conv) {return DsaBase::convertFromIso(iso, conv);}
    long  convertInt32FromIso(double iso, int conv) {return DsaBase::convertInt32FromIso(iso, conv);}
    eint64  convertInt64FromIso(double iso, int conv) {return DsaBase::convertInt64FromIso(iso, conv);}
    float  convertFloat32FromIso(double iso, int conv) {return DsaBase::convertFloat32FromIso(iso, conv);}
    double  convertFloat64FromIso(double iso, int conv) {return DsaBase::convertFloat64FromIso(iso, conv);}
	double getIncToIsoFactor(int conv) {return DsaBase::getIncToIsoFactor(conv);}

    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    DsaInfo  getInfo() {return DsaBase::getInfo();}
    DsaStatus  getStatus() {return DsaBase::getStatus();}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    DsaStatus  getStatusFromDrive(long timeout = DEF_TIMEOUT) {return DsaBase::getStatusFromDrive(timeout);}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}
    void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}
    DsaXInfo  getXInfo() {return DsaBase::getXInfo();}

    /* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
	void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
	void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
	void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
	void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
    void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
    void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
    void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
    void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
	void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
	void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
	void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
	void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
	void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
	void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
	void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
    void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
    void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
    void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
    void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
    int getFamily() {return DsaBase::getFamily();}
	void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
	void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
	void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
	void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
	void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
	void startUploadTrace(int traceTyp, int traceIdx, int startIdx, int endIdx, int stepIdx, bool fast, long timeout = DEF_TIMEOUT) {DsaBase::startUploadTrace(traceTyp, traceIdx, startIdx, endIdx, stepIdx, fast, timeout);}
	void startUploadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startUploadSequence(timeout);}
	void startUploadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startUploadRegister(typ, startIdx, endIdx, sidx, timeout);}
	void uploadData(void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::uploadData(data, size, timeout);}
	void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
	void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
	void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}
};


/*------------------------------------------------------------------------------
 * DsaDeviceGroup class - C++
 *-----------------------------------------------------------------------------*/
class DsaDeviceGroup: public DsaBase {
    /* constructors */
	private:
		void _Group(int max, ...) {
			va_list arg;
			va_start(arg, max);
			ERRCHK(dsa_create_device_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
			va_end(arg);
		}
	protected:
		DsaDeviceGroup(void) {
		}
	public:
		DsaDeviceGroup(DSA_DEVICE_GROUP *dev) {
			if (!dsa_is_valid_device_group(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaDeviceGroup(DsaDeviceGroup &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaDeviceGroup(DsaBase &obj) {
			if (!dsa_is_valid_device_group(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaDeviceGroup(int max, ...) {
			va_list arg;
			va_start(arg, max);
			ERRCHK(dsa_create_device_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
			va_end(arg);
		}
		DsaDeviceGroup(int max, DsaDeviceBase *list[]) {
			ERRCHK(dsa_create_device_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, list[i]->dsa));
		}
		DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2) {
			_Group(2, &d1, &d2);
		}
		DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3) {
			_Group(3, &d1, &d2, &d3);
		}
		DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3, DsaDeviceBase d4) {
			_Group(4, &d1, &d2, &d3, &d4);
		}
		DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3, DsaDeviceBase d4, DsaDeviceBase d5) {
			_Group(5, &d1, &d2, &d3, &d4, &d5);
		}
		DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3, DsaDeviceBase d4, DsaDeviceBase d5, DsaDeviceBase d6) {
			_Group(6, &d1, &d2, &d3, &d4, &d5, &d6);
		}
		DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3, DsaDeviceBase d4, DsaDeviceBase d5, DsaDeviceBase d6, DsaDeviceBase d7) {
			_Group(7, &d1, &d2, &d3, &d4, &d5, &d6, &d7);
		}
		DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3, DsaDeviceBase d4, DsaDeviceBase d5, DsaDeviceBase d6, DsaDeviceBase d7, DsaDeviceBase d8) {
			_Group(8, &d1, &d2, &d3, &d4, &d5, &d6, &d7, &d8);
		}
    /* operators */
	public:
		DsaDeviceGroup operator = (DsaDeviceGroup &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaDeviceGroup operator = (DsaBase &obj) {
			if (!dsa_is_valid_device_group(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
    /* special functions */
	public:
		DsaDeviceBase getGroupItem(int pos) {return DsaBase::getGroupItem(pos);}
		/* functions */
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

		void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
		void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
		int  getGroupSize() {return DsaBase::getGroupSize();}
		void cancelStatusWait() {DsaBase::cancelStatusWait();}
		void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}

		/* commands */
		void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
		void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
		void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
		void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
		void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
		void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
		void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

		void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
		void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
		void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
		void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
		void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
		void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
	    int getFamily() {return DsaBase::getFamily();}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
		void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
		void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}
};


/*------------------------------------------------------------------------------
 * DsaDriveBase class - C++
 *-----------------------------------------------------------------------------*/
class DsaDriveBase: public DsaBase {
    /* constructors */
	protected:
		DsaDriveBase(void) {
		}
	public:
		DsaDriveBase(DSA_DRIVE_BASE *dev) {
			if (!dsa_is_valid_drive_base(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaDriveBase(DsaDriveBase &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaDriveBase(DsaBase &obj) {
			if (!dsa_is_valid_drive_base(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
	public:
	    /* operators */
		DsaDriveBase operator = (DsaDriveBase &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaDriveBase operator = (DsaBase &obj) {
			if (!dsa_is_valid_drive_base(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		/* functions */
		void powerOn(long timeout = DEF_TIMEOUT) {DsaBase::powerOn(timeout);}
		void powerOff(long timeout = DEF_TIMEOUT) {DsaBase::powerOff(timeout);}
		void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::newSetpoint(sidx, flags, timeout);}
		void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::changeSetpoint(sidx, flags, timeout);}
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
		void homingStart(long timeout = DEF_TIMEOUT) {DsaBase::homingStart(timeout);}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
		void startProfiledMovement(double pos, double speed, double acc, long timeout = DEF_TIMEOUT) {DsaBase::startProfiledMovement(pos, speed, acc, timeout);}
		void startRelativeProfiledMovement(double relativePos, long timeout = DEF_TIMEOUT) {DsaBase::startRelativeProfiledMovement(relativePos, timeout);}
		void stageMappingDownload(const char *fileName) {DsaBase::stageMappingDownload(fileName);}
		void stageMappingUpload(const char *fileName) {DsaBase::stageMappingUpload(fileName);}
		void stageMappingActivate() {DsaBase::stageMappingActivate();}
		void stageMappingDeactivate() {DsaBase::stageMappingDeactivate();}
		bool stageMappingIsActivated() {return DsaBase::stageMappingIsActivated();}

		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

		void powerOn(DsaHandler handler, void *param = NULL) {DsaBase::powerOn(handler, param);}
		void powerOff(DsaHandler handler, void *param = NULL) {DsaBase::powerOff(handler, param);}
		void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::newSetpoint(sidx, flags, handler, param);}
		void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::changeSetpoint(sidx, flags, handler, param);}
		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
		void homingStart(DsaHandler handler, void *param = NULL) {DsaBase::homingStart(handler, param);}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
		void startProfiledMovement(double pos, double speed, double acc, DsaHandler handler, void *param = NULL) {DsaBase::startProfiledMovement(pos, speed, acc, handler, param);}
		void startRelativeProfiledMovement(double relativePos, DsaHandler handler, void *param = NULL) {DsaBase::startRelativeProfiledMovement(relativePos, handler, param);}
		void userStretchEnable(double offset, float slope, long timeout = DEF_TIMEOUT) {DsaBase::userStretchEnable(offset, slope, timeout);}
		void userStretchDisable(long timeout = DEF_TIMEOUT) {DsaBase::userStretchDisable(timeout);}
		void userStretchEnable(double offset, float slope, DsaHandler handler, void *param = NULL) {DsaBase::userStretchEnable(offset, slope, handler, param);}
		void userStretchDisable(DsaHandler handler, void *param = NULL) {DsaBase::userStretchDisable(handler, param);}

		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

		void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
		void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
		void cancelStatusWait() {DsaBase::cancelStatusWait();}
		void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}

		/* commands */
		void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
		void stepMotion(double pos, long timeout = DEF_TIMEOUT) {DsaBase::stepMotion(pos, timeout);}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
		void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
		void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
		void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
		void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
		void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
		void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

		void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
		void stepMotion(double pos, DsaHandler handler, void *param = NULL) {DsaBase::stepMotion(pos, handler, param);}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
		void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
		void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
		void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
		void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
		void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
	    int getFamily() {return DsaBase::getFamily();}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
		void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
		void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}

		/* register setters */
		void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLProportionalGain(gain, timeout);}
		void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedbackGain(gain, timeout);}
		void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorGain(gain, timeout);}
		void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLAntiWindupGain(gain, timeout);}
		void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorLimitation(limit, timeout);}
		void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorMode(mode, timeout);}
		void setTtlSpeedlFilter(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setTtlSpeedlFilter(factor, timeout);}
		void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLAccFeedforwardGain(factor, timeout);}
		void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxPositionRangeLimit(pos, timeout);}
		void startMovement(double *targets, long timeout = DEF_TIMEOUT) {DsaBase::startMovement(targets, timeout);}

		void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setFollowingErrorWindow(pos, timeout);}
		void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setVelocityErrorLimit(vel, timeout);}
		void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setSwitchLimitMode(mode, timeout);}
		void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setEnableInputMode(mode, timeout);}
		void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinSoftPositionLimit(pos, timeout);}
		void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxSoftPositionLimit(pos, timeout);}
		void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {DsaBase::setProfileLimitMode(flags, timeout);}
		void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindowTime(tim, timeout);}
		void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindow(win, timeout);}
		void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingMethod(mode, timeout);}
		void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setHomingZeroSpeed(vel, timeout);}
		void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setHomingAcceleration(acc, timeout);}
		void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFollowingLimit(win, timeout);}
		void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setHomingCurrentLimit(cur, timeout);}
		void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomeOffset(pos, timeout);}
		void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFixedMvt(pos, timeout);}
		void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingSwitchMvt(pos, timeout);}
		void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingIndexMvt(pos, timeout);}
		void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningMode(mode, timeout);}
		void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningValue(phase, timeout);}
		void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setMotorPhaseCorrection(mode, timeout);}
		void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setSoftwareCurrentLimit(cur, timeout);}
		void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDriveControlMode(mode, timeout);}
		void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDisplayMode(mode, timeout);}
		void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderInversion(invert, timeout);}
		void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Offset(offset, timeout);}
		void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Offset(offset, timeout);}
		void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Factor(factor, timeout);}
		void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Factor(factor, timeout);}
		void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderIndexDistance(pos, timeout);}
		void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLProportionalGain(gain, timeout);}
		void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLIntegratorGain(gain, timeout);}
		void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLCurrentLimit(cur, timeout);}
		void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tCurrentLimit(cur, timeout);}
		void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tTimeLimit(tim, timeout);}
		void setInitMode(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setInitMode(typ, timeout);}
		void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitPulseLevel(cur, timeout);}
		void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitMaxCurrent(cur, timeout);}
		void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitFinalPhase(cal, timeout);}
		void setInitTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setInitTime(tim, timeout);}
		void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitInitialPhase(cal, timeout);}
		void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceType(sidx, typ, timeout);}
		void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceIndex(sidx, index, timeout);}
		void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroStartTimeout(tim, timeout);}
		void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setDigitalOutput(out, timeout);}
		void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setXDigitalOutput(out, timeout);}
		void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput1(out, timeout);}
		void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput2(out, timeout);}
		void setXAnalogOutput3(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput3(out, timeout);}
		void setXAnalogOutput4(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput4(out, timeout);}
		void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {DsaBase::setAnalogOutput(out, timeout);}
		void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterIdx(idx, timeout);}
		void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {DsaBase::setConcatenatedMvt(concat, timeout);}
		void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setProfileType(sidx, typ, timeout);}
		void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktNumber(sidx, number, timeout);}
		void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktTime(sidx, time, timeout);}
		void setCameValue(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCameValue(factor, timeout);}
		void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::setBrakeDeceleration(dec, timeout);}
		void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTargetPosition(sidx, pos, timeout);}
		void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setProfileVelocity(sidx, vel, timeout);}
		void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {DsaBase::setProfileAcceleration(sidx, acc, timeout);}
		void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {DsaBase::setJerkTime(sidx, tim, timeout);}
		void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceType(typ, timeout);}
		void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceIndex(index, timeout);}
		void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlOffset(offset, timeout);}
		void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlGain(gain, timeout);}
		void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {DsaBase::setMotorKTFactor(kt, timeout);}

		void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLProportionalGain(gain, handler, param);}
		void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedbackGain(gain, handler, param);}
		void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorGain(gain, handler, param);}
		void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLAntiWindupGain(gain, handler, param);}
		void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorLimitation(limit, handler, param);}
		void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorMode(mode, handler, param);}
		void setTtlSpeedlFilter(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setTtlSpeedlFilter(factor, handler, param);}
		void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLAccFeedforwardGain(factor, handler, param);}
		void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxPositionRangeLimit(pos, handler, param);}
		void startMovement(double *targets, DsaHandler handler, void *param = NULL) {DsaBase::startMovement(targets, handler, param);}

		void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setFollowingErrorWindow(pos, handler, param);}
		void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setVelocityErrorLimit(vel, handler, param);}
		void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setSwitchLimitMode(mode, handler, param);}
		void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setEnableInputMode(mode, handler, param);}
		void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinSoftPositionLimit(pos, handler, param);}
		void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxSoftPositionLimit(pos, handler, param);}
		void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {DsaBase::setProfileLimitMode(flags, handler, param);}
		void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindowTime(tim, handler, param);}
		void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindow(win, handler, param);}
		void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingMethod(mode, handler, param);}
		void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setHomingZeroSpeed(vel, handler, param);}
		void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setHomingAcceleration(acc, handler, param);}
		void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFollowingLimit(win, handler, param);}
		void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setHomingCurrentLimit(cur, handler, param);}
		void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomeOffset(pos, handler, param);}
		void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFixedMvt(pos, handler, param);}
		void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingSwitchMvt(pos, handler, param);}
		void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingIndexMvt(pos, handler, param);}
		void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningMode(mode, handler, param);}
		void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningValue(phase, handler, param);}
		void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setMotorPhaseCorrection(mode, handler, param);}
		void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setSoftwareCurrentLimit(cur, handler, param);}
		void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDriveControlMode(mode, handler, param);}
		void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDisplayMode(mode, handler, param);}
		void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderInversion(invert, handler, param);}
		void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Offset(offset, handler, param);}
		void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Offset(offset, handler, param);}
		void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Factor(factor, handler, param);}
		void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Factor(factor, handler, param);}
		void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderIndexDistance(pos, handler, param);}
		void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLProportionalGain(gain, handler, param);}
		void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLIntegratorGain(gain, handler, param);}
		void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLCurrentLimit(cur, handler, param);}
		void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tCurrentLimit(cur, handler, param);}
		void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tTimeLimit(tim, handler, param);}
		void setInitMode(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setInitMode(typ, handler, param);}
		void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitPulseLevel(cur, handler, param);}
		void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitMaxCurrent(cur, handler, param);}
		void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitFinalPhase(cal, handler, param);}
		void setInitTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setInitTime(tim, handler, param);}
		void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitInitialPhase(cal, handler, param);}
		void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceType(sidx, typ, handler, param);}
		void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceIndex(sidx, index, handler, param);}
		void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroStartTimeout(tim, handler, param);}
		void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setDigitalOutput(out, handler, param);}
		void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setXDigitalOutput(out, handler, param);}
		void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput1(out, handler, param);}
		void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput2(out, handler, param);}
		void setXAnalogOutput3(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput3(out, handler, param);}
		void setXAnalogOutput4(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput4(out, handler, param);}
		void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {DsaBase::setAnalogOutput(out, handler, param);}
		void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterIdx(idx, handler, param);}
		void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {DsaBase::setConcatenatedMvt(concat, handler, param);}
		void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setProfileType(sidx, typ, handler, param);}
		void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktNumber(sidx, number, handler, param);}
		void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktTime(sidx, time, handler, param);}
		void setCameValue(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCameValue(factor, handler, param);}
		void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::setBrakeDeceleration(dec, handler, param);}
		void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTargetPosition(sidx, pos, handler, param);}
		void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setProfileVelocity(sidx, vel, handler, param);}
		void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {DsaBase::setProfileAcceleration(sidx, acc, handler, param);}
		void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {DsaBase::setJerkTime(sidx, tim, handler, param);}
		void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceType(typ, handler, param);}
		void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceIndex(index, handler, param);}
		void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlOffset(offset, handler, param);}
		void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlGain(gain, handler, param);}
		void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {DsaBase::setMotorKTFactor(kt, handler, param);}
};


/*------------------------------------------------------------------------------
 * DsaDrive class - C++
 *-----------------------------------------------------------------------------*/
class DsaDrive: public DsaBase {
    /* constructors */
	public:
		DsaDrive(DSA_DRIVE *dev) {
			if (!dsa_is_valid_drive(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaDrive(void) {
			dsa = NULL;
			ERRCHK(dsa_create_drive(&dsa));
		}
		DsaDrive(DsaDrive &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaDrive(DsaBase &obj) {
			if (!dsa_is_valid_drive(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
	public:
    /* operators */
		DsaDrive operator = (DsaDrive &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaDrive operator = (DsaBase &obj) {
			if (!dsa_is_valid_drive(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		/* functions */
		void powerOn(long timeout = DEF_TIMEOUT) {DsaBase::powerOn(timeout);}
		void powerOff(long timeout = DEF_TIMEOUT) {DsaBase::powerOff(timeout);}
		void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::newSetpoint(sidx, flags, timeout);}
		void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::changeSetpoint(sidx, flags, timeout);}
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
		void homingStart(long timeout = DEF_TIMEOUT) {DsaBase::homingStart(timeout);}
		int  getWarningCode(int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getWarningCode(kind, timeout);}
		int  getErrorCode(int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getErrorCode(kind, timeout);}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
		void startProfiledMovement(double pos, double speed, double acc, long timeout = DEF_TIMEOUT) {DsaBase::startProfiledMovement(pos, speed, acc, timeout);}
		void startRelativeProfiledMovement(double relativePos, long timeout = DEF_TIMEOUT) {DsaBase::startRelativeProfiledMovement(relativePos, timeout);}
		void stageMappingDownload(const char *fileName) {DsaBase::stageMappingDownload(fileName);}
		void stageMappingUpload(const char *fileName) {DsaBase::stageMappingUpload(fileName);}
		void stageMappingActivate() {DsaBase::stageMappingActivate();}
		void stageMappingDeactivate() {DsaBase::stageMappingDeactivate();}
		bool stageMappingIsActivated() {return DsaBase::stageMappingIsActivated();}
		void scaleMappingDownload(const char *fileName, dword preProcessingMode) {return DsaBase::scaleMappingDownload(fileName, preProcessingMode);}
		void scaleMappingActivate(dword mode) {return DsaBase::scaleMappingActivate(mode);}
		void scaleMappingDeactivate() {return DsaBase::scaleMappingDeactivate();}
		bool scaleMappingIsActivated() {return DsaBase::scaleMappingIsActivated();}

		long  getRegister(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegister(typ, idx, sidx, kind, timeout);}
		long getRegisterInt32(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterInt32(typ, idx, sidx, kind, timeout);}
		eint64 getRegisterInt64(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterInt64(typ, idx, sidx, kind, timeout);}
		float getRegisterFloat32(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterFloat32(typ, idx, sidx, kind, timeout);}
		double getRegisterFloat64(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterFloat64(typ, idx, sidx, kind, timeout);}
		void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayInt32(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayInt64(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayFloat32(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayFloat64(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		int  getParametersVersion(int what, long timeout = DEF_TIMEOUT) {return DsaBase::getParametersVersion(what, timeout);}
		double getSequenceCodeUsage(long timeout = DEF_TIMEOUT) {DsaBase::getSequenceCodeUsage(timeout);}
		double getSequenceSourceUsage(long timeout = DEF_TIMEOUT) {DsaBase::getSequenceSourceUsage(timeout);}
		double getSequenceDataUsage(long timeout = DEF_TIMEOUT) {DsaBase::getSequenceDataUsage(timeout);}
		int getDebugSequenceNbBreakpoints(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDebugSequenceNbBreakpoints(kind, timeout);}
		int getDebugSequenceBreakThreadNb(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDebugSequenceBreakThreadNb(kind, timeout);}

		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}
		double  getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, timeout);}
		void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, timeout);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
		void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout = DEF_TIMEOUT) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, timeout);}
		DsaStatus  waitStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusEqual(mask, ref, timeout);}
		DsaStatus  waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusNotEqual(mask, ref, timeout);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
		DsaStatus  waitStatusChange(DsaStatus *mask, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusChange(mask, timeout);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}
		void userStretchEnable(double offset, float slope, long timeout = DEF_TIMEOUT) {DsaBase::userStretchEnable(offset, slope, timeout);}
		void userStretchDisable(long timeout = DEF_TIMEOUT) {DsaBase::userStretchDisable(timeout);}
		void userStretchEnable(double offset, float slope, DsaHandler handler, void *param = NULL) {DsaBase::userStretchEnable(offset, slope, handler, param);}
		void userStretchDisable(DsaHandler handler, void *param = NULL) {DsaBase::userStretchDisable(handler, param);}

		void powerOn(DsaHandler handler, void *param = NULL) {DsaBase::powerOn(handler, param);}
		void powerOff(DsaHandler handler, void *param = NULL) {DsaBase::powerOff(handler, param);}
		void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::newSetpoint(sidx, flags, handler, param);}
		void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::changeSetpoint(sidx, flags, handler, param);}
		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
		void homingStart(DsaHandler handler, void *param = NULL) {DsaBase::homingStart(handler, param);}
		void getWarningCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getWarningCode(kind, handler, param);}
		void getErrorCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getErrorCode(kind, handler, param);}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
		void startProfiledMovement(double pos, double speed, double acc, DsaHandler handler, void *param = NULL) {DsaBase::startProfiledMovement(pos, speed, acc, handler, param);}
		void startRelativeProfiledMovement(double relativePos, DsaHandler handler, void *param = NULL) {DsaBase::startRelativeProfiledMovement(relativePos, handler, param);}

		void getRegister(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getRegister(typ, idx, sidx, kind, handler, param);}
		void getRegisterInt32(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getRegisterInt32(typ, idx, sidx, kind, handler, param);}
		void getRegisterInt64(int typ, unsigned idx, int sidx, int kind, DsaInt64Handler handler, void *param = NULL) {DsaBase::getRegisterInt64(typ, idx, sidx, kind, handler, param);}
		void getRegisterFloat32(int typ, unsigned idx, int sidx, int kind, DsaFloatHandler handler, void *param = NULL) {DsaBase::getRegisterFloat32(typ, idx, sidx, kind, handler, param);}
		void getRegisterFloat64(int typ, unsigned idx, int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getRegisterFloat64(typ, idx, sidx, kind, handler, param);}
		void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, handler, param);}
		void getParametersVersion(int what, DsaIntHandler handler, void *param = NULL) {DsaBase::getParametersVersion(what, handler, param);}
		void getDebugSequenceNbBreakpoints(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceNbBreakpoints(kind, handler, param);}
		void getDebugSequenceNbBreakpoints(DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceNbBreakpoints(handler, param);}
		void getDebugSequenceBreakThreadNb(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceBreakThreadNb(kind, handler, param);}
		void getDebugSequenceBreakThreadNb(DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceBreakThreadNb(handler, param);}

		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, handler, param);}
		void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, handler, param);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
		void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, Dsa2intHandler handler, void *param = NULL) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, handler, param);}
		void waitStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusEqual(mask, ref, handler, param);}
		void waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusNotEqual(mask, ref, handler, param);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
		void waitStatusChange(DsaStatus *mask, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusChange(mask, handler, param);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

		void etcomOpen(EtbBus etb, int axis) {DsaBase::etcomOpen(etb, axis);}
		void open(char_cp url) {DsaBase::open(url);}
		void etcomOpen(EtbBus etb, int axis, dword flags) {DsaBase::etcomOpen(etb, axis, flags);}
		void reset() {DsaBase::reset();}
		void close() {DsaBase::close();}
		EtbBus  getEtbBus() {return DsaBase::getEtbBus();}
		int  etcomGetEtbAxis() {return DsaBase::etcomGetEtbAxis();}
		bool  isOpen() {return DsaBase::isOpen();}
		int getMotorTyp() {return DsaBase::getMotorTyp();}
		void getErrorText(char_p text, int size, int code) {DsaBase::getErrorText(text, size, code);}
		void getWarningText(char_p text, int size, int code) {DsaBase::getWarningText(text, size, code);}
		double  convertToIso(long inc, int conv) {return DsaBase::convertToIso(inc, conv);}
		double  convertInt32ToIso(long inc, int conv) {return DsaBase::convertInt32ToIso(inc, conv);}
		double  convertInt64ToIso(eint64 inc, int conv) {return DsaBase::convertInt64ToIso(inc, conv);}
		double  convertFloat32ToIso(float inc, int conv) {return DsaBase::convertFloat32ToIso(inc, conv);}
		double  convertFloat64ToIso(double inc, int conv) {return DsaBase::convertFloat64ToIso(inc, conv);}
		long  convertFromIso(double iso, int conv) {return DsaBase::convertFromIso(iso, conv);}
		long  convertInt32FromIso(double iso, int conv) {return DsaBase::convertInt32FromIso(iso, conv);}
		eint64  convertInt64FromIso(double iso, int conv) {return DsaBase::convertInt64FromIso(iso, conv);}
		float  convertFloat32FromIso(double iso, int conv) {return DsaBase::convertFloat32FromIso(iso, conv);}
		double  convertFloat64FromIso(double iso, int conv) {return DsaBase::convertFloat64FromIso(iso, conv);}
		double getIncToIsoFactor(int conv) {return DsaBase::getIncToIsoFactor(conv);}

		void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
		void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
		DsaInfo  getInfo() {return DsaBase::getInfo();}
		DsaStatus  getStatus() {return DsaBase::getStatus();}
		void cancelStatusWait() {DsaBase::cancelStatusWait();}
		DsaStatus  getStatusFromDrive(long timeout = DEF_TIMEOUT) {return DsaBase::getStatusFromDrive(timeout);}
		void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
		double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
		double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}
		DsaXInfo  getXInfo() {return DsaBase::getXInfo();}

		/* commands */
		void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
		void stepMotion(double pos, long timeout = DEF_TIMEOUT) {DsaBase::stepMotion(pos, timeout);}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
		void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
		void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
		void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
		void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
		void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
		void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

		void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
		void stepMotion(double pos, DsaHandler handler, void *param = NULL) {DsaBase::stepMotion(pos, handler, param);}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
		void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
		void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
		void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
		void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
		void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
	    int getFamily() {return DsaBase::getFamily();}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
		void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
		void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
		void startUploadTrace(int traceTyp, int traceIdx, int startIdx, int endIdx, int stepIdx, bool fast, long timeout = DEF_TIMEOUT) {DsaBase::startUploadTrace(traceTyp, traceIdx, startIdx, endIdx, stepIdx, fast, timeout);}
		void startUploadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startUploadSequence(timeout);}
		void startUploadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startUploadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void uploadData(void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::uploadData(data, size, timeout);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}

		/* register setters */
		void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLProportionalGain(gain, timeout);}
		void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedbackGain(gain, timeout);}
		void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorGain(gain, timeout);}
		void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLAntiWindupGain(gain, timeout);}
		void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorLimitation(limit, timeout);}
		void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorMode(mode, timeout);}
		void setTtlSpeedlFilter(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setTtlSpeedlFilter(factor, timeout);}
		void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLAccFeedforwardGain(factor, timeout);}
		void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxPositionRangeLimit(pos, timeout);}
		void startMovement(double *targets, long timeout = DEF_TIMEOUT) {DsaBase::startMovement(targets, timeout);}

		void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setFollowingErrorWindow(pos, timeout);}
		void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setVelocityErrorLimit(vel, timeout);}
		void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setSwitchLimitMode(mode, timeout);}
		void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setEnableInputMode(mode, timeout);}
		void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinSoftPositionLimit(pos, timeout);}
		void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxSoftPositionLimit(pos, timeout);}
		void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {DsaBase::setProfileLimitMode(flags, timeout);}
		void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindowTime(tim, timeout);}
		void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindow(win, timeout);}
		void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingMethod(mode, timeout);}
		void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setHomingZeroSpeed(vel, timeout);}
		void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setHomingAcceleration(acc, timeout);}
		void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFollowingLimit(win, timeout);}
		void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setHomingCurrentLimit(cur, timeout);}
		void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomeOffset(pos, timeout);}
		void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFixedMvt(pos, timeout);}
		void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingSwitchMvt(pos, timeout);}
		void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingIndexMvt(pos, timeout);}
		void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningMode(mode, timeout);}
		void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningValue(phase, timeout);}
		void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setMotorPhaseCorrection(mode, timeout);}
		void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setSoftwareCurrentLimit(cur, timeout);}
		void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDriveControlMode(mode, timeout);}
		void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDisplayMode(mode, timeout);}
		void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderInversion(invert, timeout);}
		void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Offset(offset, timeout);}
		void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Offset(offset, timeout);}
		void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Factor(factor, timeout);}
		void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Factor(factor, timeout);}
		void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderIndexDistance(pos, timeout);}
		void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLProportionalGain(gain, timeout);}
		void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLIntegratorGain(gain, timeout);}
		void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLCurrentLimit(cur, timeout);}
		void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tCurrentLimit(cur, timeout);}
		void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tTimeLimit(tim, timeout);}
		void setInitMode(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setInitMode(typ, timeout);}
		void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitPulseLevel(cur, timeout);}
		void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitMaxCurrent(cur, timeout);}
		void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitFinalPhase(cal, timeout);}
		void setInitTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setInitTime(tim, timeout);}
		void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitInitialPhase(cal, timeout);}
		void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceType(sidx, typ, timeout);}
		void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceIndex(sidx, index, timeout);}
		void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroStartTimeout(tim, timeout);}
		void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setDigitalOutput(out, timeout);}
		void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setXDigitalOutput(out, timeout);}
		void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput1(out, timeout);}
		void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput2(out, timeout);}
		void setXAnalogOutput3(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput3(out, timeout);}
		void setXAnalogOutput4(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput4(out, timeout);}
		void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {DsaBase::setAnalogOutput(out, timeout);}
		void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterIdx(idx, timeout);}
		void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {DsaBase::setConcatenatedMvt(concat, timeout);}
		void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setProfileType(sidx, typ, timeout);}
		void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktNumber(sidx, number, timeout);}
		void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktTime(sidx, time, timeout);}
		void setCameValue(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCameValue(factor, timeout);}
		void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::setBrakeDeceleration(dec, timeout);}
		void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTargetPosition(sidx, pos, timeout);}
		void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setProfileVelocity(sidx, vel, timeout);}
		void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {DsaBase::setProfileAcceleration(sidx, acc, timeout);}
		void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {DsaBase::setJerkTime(sidx, tim, timeout);}
		void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceType(typ, timeout);}
		void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceIndex(index, timeout);}
		void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlOffset(offset, timeout);}
		void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlGain(gain, timeout);}
		void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {DsaBase::setMotorKTFactor(kt, timeout);}

		void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLProportionalGain(gain, handler, param);}
		void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedbackGain(gain, handler, param);}
		void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorGain(gain, handler, param);}
		void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLAntiWindupGain(gain, handler, param);}
		void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorLimitation(limit, handler, param);}
		void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorMode(mode, handler, param);}
		void setTtlSpeedlFilter(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setTtlSpeedlFilter(factor, handler, param);}
		void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLAccFeedforwardGain(factor, handler, param);}
		void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxPositionRangeLimit(pos, handler, param);}
		void startMovement(double *targets, DsaHandler handler, void *param = NULL) {DsaBase::startMovement(targets, handler, param);}

		void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setFollowingErrorWindow(pos, handler, param);}
		void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setVelocityErrorLimit(vel, handler, param);}
		void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setSwitchLimitMode(mode, handler, param);}
		void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setEnableInputMode(mode, handler, param);}
		void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinSoftPositionLimit(pos, handler, param);}
		void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxSoftPositionLimit(pos, handler, param);}
		void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {DsaBase::setProfileLimitMode(flags, handler, param);}
		void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindowTime(tim, handler, param);}
		void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindow(win, handler, param);}
		void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingMethod(mode, handler, param);}
		void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setHomingZeroSpeed(vel, handler, param);}
		void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setHomingAcceleration(acc, handler, param);}
		void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFollowingLimit(win, handler, param);}
		void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setHomingCurrentLimit(cur, handler, param);}
		void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomeOffset(pos, handler, param);}
		void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFixedMvt(pos, handler, param);}
		void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingSwitchMvt(pos, handler, param);}
		void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingIndexMvt(pos, handler, param);}
		void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningMode(mode, handler, param);}
		void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningValue(phase, handler, param);}
		void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setMotorPhaseCorrection(mode, handler, param);}
		void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setSoftwareCurrentLimit(cur, handler, param);}
		void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDriveControlMode(mode, handler, param);}
		void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDisplayMode(mode, handler, param);}
		void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderInversion(invert, handler, param);}
		void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Offset(offset, handler, param);}
		void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Offset(offset, handler, param);}
		void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Factor(factor, handler, param);}
		void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Factor(factor, handler, param);}
		void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderIndexDistance(pos, handler, param);}
		void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLProportionalGain(gain, handler, param);}
		void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLIntegratorGain(gain, handler, param);}
		void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLCurrentLimit(cur, handler, param);}
		void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tCurrentLimit(cur, handler, param);}
		void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tTimeLimit(tim, handler, param);}
		void setInitMode(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setInitMode(typ, handler, param);}
		void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitPulseLevel(cur, handler, param);}
		void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitMaxCurrent(cur, handler, param);}
		void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitFinalPhase(cal, handler, param);}
		void setInitTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setInitTime(tim, handler, param);}
		void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitInitialPhase(cal, handler, param);}
		void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceType(sidx, typ, handler, param);}
		void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceIndex(sidx, index, handler, param);}
		void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroStartTimeout(tim, handler, param);}
		void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setDigitalOutput(out, handler, param);}
		void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setXDigitalOutput(out, handler, param);}
		void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput1(out, handler, param);}
		void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput2(out, handler, param);}
		void setXAnalogOutput3(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput3(out, handler, param);}
		void setXAnalogOutput4(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput4(out, handler, param);}
		void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {DsaBase::setAnalogOutput(out, handler, param);}
		void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterIdx(idx, handler, param);}
		void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {DsaBase::setConcatenatedMvt(concat, handler, param);}
		void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setProfileType(sidx, typ, handler, param);}
		void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktNumber(sidx, number, handler, param);}
		void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktTime(sidx, time, handler, param);}
		void setCameValue(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCameValue(factor, handler, param);}
		void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::setBrakeDeceleration(dec, handler, param);}
		void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTargetPosition(sidx, pos, handler, param);}
		void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setProfileVelocity(sidx, vel, handler, param);}
		void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {DsaBase::setProfileAcceleration(sidx, acc, handler, param);}
		void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {DsaBase::setJerkTime(sidx, tim, handler, param);}
		void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceType(typ, handler, param);}
		void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceIndex(index, handler, param);}
		void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlOffset(offset, handler, param);}
		void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlGain(gain, handler, param);}
		void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {DsaBase::setMotorKTFactor(kt, handler, param);}

		/* register getters */
		double getPLProportionalGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLProportionalGain(kind, timeout);}
		void getPLProportionalGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLProportionalGain(gain, kind, timeout);}
		double getPLSpeedFeedbackGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLSpeedFeedbackGain(kind, timeout);}
		void getPLSpeedFeedbackGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLSpeedFeedbackGain(gain, kind, timeout);}
		double getPLIntegratorGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLIntegratorGain(kind, timeout);}
		void getPLIntegratorGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLIntegratorGain(gain, kind, timeout);}
		double getPLAntiWindupGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLAntiWindupGain(kind, timeout);}
		void getPLAntiWindupGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLAntiWindupGain(gain, kind, timeout);}
		double getPLIntegratorLimitation(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLIntegratorLimitation(kind, timeout);}
		void getPLIntegratorLimitation(double *limit, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLIntegratorLimitation(limit, kind, timeout);}
		int getPLIntegratorMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLIntegratorMode(kind, timeout);}
		void getPLIntegratorMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLIntegratorMode(mode, kind, timeout);}
		double getTtlSpeedlFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTtlSpeedlFilter(kind, timeout);}
		void getTtlSpeedlFilter(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTtlSpeedlFilter(factor, kind, timeout);}
		double getPLAccFeedforwardGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLAccFeedforwardGain(kind, timeout);}
		void getPLAccFeedforwardGain(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLAccFeedforwardGain(factor, kind, timeout);}
		double getMaxPositionRangeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMaxPositionRangeLimit(kind, timeout);}
		void getMaxPositionRangeLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMaxPositionRangeLimit(pos, kind, timeout);}
		double getFollowingErrorWindow(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getFollowingErrorWindow(kind, timeout);}
		void getFollowingErrorWindow(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getFollowingErrorWindow(pos, kind, timeout);}
		double getVelocityErrorLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getVelocityErrorLimit(kind, timeout);}
		void getVelocityErrorLimit(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getVelocityErrorLimit(vel, kind, timeout);}
		int getSwitchLimitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSwitchLimitMode(kind, timeout);}
		void getSwitchLimitMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSwitchLimitMode(mode, kind, timeout);}
		int getEnableInputMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEnableInputMode(kind, timeout);}
		void getEnableInputMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEnableInputMode(mode, kind, timeout);}
		double getMinSoftPositionLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMinSoftPositionLimit(kind, timeout);}
		void getMinSoftPositionLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMinSoftPositionLimit(pos, kind, timeout);}
		double getMaxSoftPositionLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMaxSoftPositionLimit(kind, timeout);}
		void getMaxSoftPositionLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMaxSoftPositionLimit(pos, kind, timeout);}
		dword getProfileLimitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileLimitMode(kind, timeout);}
		void getProfileLimitMode(dword *flags, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileLimitMode(flags, kind, timeout);}
		double getPositionWindowTime(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionWindowTime(kind, timeout);}
		void getPositionWindowTime(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionWindowTime(tim, kind, timeout);}
		double getPositionWindow(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionWindow(kind, timeout);}
		void getPositionWindow(double *win, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionWindow(win, kind, timeout);}
		int getHomingMethod(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingMethod(kind, timeout);}
		void getHomingMethod(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingMethod(mode, kind, timeout);}
		double getHomingZeroSpeed(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingZeroSpeed(kind, timeout);}
		void getHomingZeroSpeed(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingZeroSpeed(vel, kind, timeout);}
		double getHomingAcceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingAcceleration(kind, timeout);}
		void getHomingAcceleration(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingAcceleration(acc, kind, timeout);}
		double getHomingFollowingLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFollowingLimit(kind, timeout);}
		void getHomingFollowingLimit(double *win, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFollowingLimit(win, kind, timeout);}
		double getHomingCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingCurrentLimit(kind, timeout);}
		void getHomingCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingCurrentLimit(cur, kind, timeout);}
		double getHomeOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomeOffset(kind, timeout);}
		void getHomeOffset(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomeOffset(pos, kind, timeout);}
		double getHomingFixedMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFixedMvt(kind, timeout);}
		void getHomingFixedMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFixedMvt(pos, kind, timeout);}
		double getHomingSwitchMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingSwitchMvt(kind, timeout);}
		void getHomingSwitchMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingSwitchMvt(pos, kind, timeout);}
		double getHomingIndexMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingIndexMvt(kind, timeout);}
		void getHomingIndexMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingIndexMvt(pos, kind, timeout);}
		int getHomingFineTuningMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFineTuningMode(kind, timeout);}
		void getHomingFineTuningMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFineTuningMode(mode, kind, timeout);}
		double getHomingFineTuningValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFineTuningValue(kind, timeout);}
		void getHomingFineTuningValue(double *phase, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFineTuningValue(phase, kind, timeout);}
		int getMotorPhaseCorrection(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMotorPhaseCorrection(kind, timeout);}
		void getMotorPhaseCorrection(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMotorPhaseCorrection(mode, kind, timeout);}
		double getSoftwareCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSoftwareCurrentLimit(kind, timeout);}
		void getSoftwareCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSoftwareCurrentLimit(cur, kind, timeout);}
		int getDriveControlMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveControlMode(kind, timeout);}
		void getDriveControlMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveControlMode(mode, kind, timeout);}
		int getDisplayMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDisplayMode(kind, timeout);}
		void getDisplayMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDisplayMode(mode, kind, timeout);}
		double getEncoderInversion(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderInversion(kind, timeout);}
		void getEncoderInversion(double *invert, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderInversion(invert, kind, timeout);}
		double getEncoderPhase1Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase1Offset(kind, timeout);}
		void getEncoderPhase1Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase1Offset(offset, kind, timeout);}
		double getEncoderPhase2Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase2Offset(kind, timeout);}
		void getEncoderPhase2Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase2Offset(offset, kind, timeout);}
		double getEncoderPhase1Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase1Factor(kind, timeout);}
		void getEncoderPhase1Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase1Factor(factor, kind, timeout);}
		double getEncoderPhase2Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase2Factor(kind, timeout);}
		void getEncoderPhase2Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase2Factor(factor, kind, timeout);}
		double getEncoderIndexDistance(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderIndexDistance(kind, timeout);}
		void getEncoderIndexDistance(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderIndexDistance(pos, kind, timeout);}
		double getCLProportionalGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLProportionalGain(kind, timeout);}
		void getCLProportionalGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLProportionalGain(gain, kind, timeout);}
		double getCLIntegratorGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLIntegratorGain(kind, timeout);}
		void getCLIntegratorGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLIntegratorGain(gain, kind, timeout);}
		double getCLCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentLimit(kind, timeout);}
		void getCLCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentLimit(cur, kind, timeout);}
		double getCLI2tCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLI2tCurrentLimit(kind, timeout);}
		void getCLI2tCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLI2tCurrentLimit(cur, kind, timeout);}
		double getCLI2tTimeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLI2tTimeLimit(kind, timeout);}
		void getCLI2tTimeLimit(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLI2tTimeLimit(tim, kind, timeout);}
		int getInitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitMode(kind, timeout);}
		void getInitMode(int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitMode(typ, kind, timeout);}
		double getInitPulseLevel(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitPulseLevel(kind, timeout);}
		void getInitPulseLevel(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitPulseLevel(cur, kind, timeout);}
		double getInitMaxCurrent(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitMaxCurrent(kind, timeout);}
		void getInitMaxCurrent(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitMaxCurrent(cur, kind, timeout);}
		double getInitFinalPhase(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitFinalPhase(kind, timeout);}
		void getInitFinalPhase(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitFinalPhase(cal, kind, timeout);}
		double getInitTime(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitTime(kind, timeout);}
		void getInitTime(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitTime(tim, kind, timeout);}
		double getInitInitialPhase(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitInitialPhase(kind, timeout);}
		void getInitInitialPhase(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitInitialPhase(cal, kind, timeout);}
		int getMonSourceType(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonSourceType(sidx, kind, timeout);}
		void getMonSourceType(int sidx, int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonSourceType(sidx, typ, kind, timeout);}
		int getMonSourceIndex(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonSourceIndex(sidx, kind, timeout);}
		void getMonSourceIndex(int sidx, int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonSourceIndex(sidx, index, kind, timeout);}
		int getSyncroStartTimeout(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroStartTimeout(kind, timeout);}
		void getSyncroStartTimeout(int *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroStartTimeout(tim, kind, timeout);}
		dword getDigitalOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDigitalOutput(kind, timeout);}
		void getDigitalOutput(dword *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDigitalOutput(out, kind, timeout);}
		dword getXDigitalOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXDigitalOutput(kind, timeout);}
		void getXDigitalOutput(dword *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXDigitalOutput(out, kind, timeout);}
		double getXAnalogOutput1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogOutput1(kind, timeout);}
		void getXAnalogOutput1(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogOutput1(out, kind, timeout);}
		double getXAnalogOutput2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogOutput2(kind, timeout);}
		void getXAnalogOutput2(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogOutput2(out, kind, timeout);}
		double getXAnalogOutput3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogOutput3(kind, timeout);}
		void getXAnalogOutput3(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogOutput3(out, kind, timeout);}
		double getXAnalogOutput4(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogOutput4(kind, timeout);}
		void getXAnalogOutput4(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogOutput4(out, kind, timeout);}
		double getAnalogOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAnalogOutput(kind, timeout);}
		void getAnalogOutput(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAnalogOutput(out, kind, timeout);}
		int getIndirectRegisterIdx(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIndirectRegisterIdx(kind, timeout);}
		void getIndirectRegisterIdx(int *idx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIndirectRegisterIdx(idx, kind, timeout);}
		int getConcatenatedMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getConcatenatedMvt(kind, timeout);}
		void getConcatenatedMvt(int *concat, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getConcatenatedMvt(concat, kind, timeout);}
		int getProfileType(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileType(sidx, kind, timeout);}
		void getProfileType(int sidx, int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileType(sidx, typ, kind, timeout);}
		int getMvtLktNumber(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMvtLktNumber(sidx, kind, timeout);}
		void getMvtLktNumber(int sidx, int *number, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMvtLktNumber(sidx, number, kind, timeout);}
		double getMvtLktTime(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMvtLktTime(sidx, kind, timeout);}
		void getMvtLktTime(int sidx, double *time, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMvtLktTime(sidx, time, kind, timeout);}
		double getCameValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCameValue(kind, timeout);}
		void getCameValue(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCameValue(factor, kind, timeout);}
		double getBrakeDeceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getBrakeDeceleration(kind, timeout);}
		void getBrakeDeceleration(double *dec, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getBrakeDeceleration(dec, kind, timeout);}
		double getTargetPosition(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTargetPosition(sidx, kind, timeout);}
		void getTargetPosition(int sidx, double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTargetPosition(sidx, pos, kind, timeout);}
		double getProfileVelocity(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileVelocity(sidx, kind, timeout);}
		void getProfileVelocity(int sidx, double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileVelocity(sidx, vel, kind, timeout);}
		double getProfileAcceleration(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileAcceleration(sidx, kind, timeout);}
		void getProfileAcceleration(int sidx, double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileAcceleration(sidx, acc, kind, timeout);}
		double getJerkTime(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getJerkTime(sidx, kind, timeout);}
		void getJerkTime(int sidx, double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getJerkTime(sidx, tim, kind, timeout);}
		int getCtrlSourceType(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlSourceType(kind, timeout);}
		void getCtrlSourceType(int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlSourceType(typ, kind, timeout);}
		int getCtrlSourceIndex(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlSourceIndex(kind, timeout);}
		void getCtrlSourceIndex(int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlSourceIndex(index, kind, timeout);}
		long getCtrlOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlOffset(kind, timeout);}
		void getCtrlOffset(long *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlOffset(offset, kind, timeout);}
		double getCtrlGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlGain(kind, timeout);}
		void getCtrlGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlGain(gain, kind, timeout);}
		double getMotorKTFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMotorKTFactor(kind, timeout);}
		void getMotorKTFactor(double *kt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMotorKTFactor(kt, kind, timeout);}
		double getPositionCtrlError(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionCtrlError(kind, timeout);}
		void getPositionCtrlError(double *err, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionCtrlError(err, kind, timeout);}
		double getPositionMaxError(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionMaxError(kind, timeout);}
		void getPositionMaxError(double *err, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionMaxError(err, kind, timeout);}
		double getPositionDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionDemandValue(kind, timeout);}
		void getPositionDemandValue(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionDemandValue(pos, kind, timeout);}
		double getPositionActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionActualValue(kind, timeout);}
		void getPositionActualValue(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionActualValue(pos, kind, timeout);}
		double getVelocityDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getVelocityDemandValue(kind, timeout);}
		void getVelocityDemandValue(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getVelocityDemandValue(vel, kind, timeout);}
		double getVelocityActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getVelocityActualValue(kind, timeout);}
		void getVelocityActualValue(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getVelocityActualValue(vel, kind, timeout);}
		double getAccDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAccDemandValue(kind, timeout);}
		void getAccDemandValue(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAccDemandValue(acc, kind, timeout);}
		double getCLCurrentPhase1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentPhase1(kind, timeout);}
		void getCLCurrentPhase1(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentPhase1(cur, kind, timeout);}
		double getCLCurrentPhase2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentPhase2(kind, timeout);}
		void getCLCurrentPhase2(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentPhase2(cur, kind, timeout);}
		double getCLCurrentPhase3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentPhase3(kind, timeout);}
		void getCLCurrentPhase3(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentPhase3(cur, kind, timeout);}
		double getCLLktPhase1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLLktPhase1(kind, timeout);}
		void getCLLktPhase1(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLLktPhase1(lkt, kind, timeout);}
		double getCLLktPhase2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLLktPhase2(kind, timeout);}
		void getCLLktPhase2(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLLktPhase2(lkt, kind, timeout);}
		double getCLLktPhase3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLLktPhase3(kind, timeout);}
		void getCLLktPhase3(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLLktPhase3(lkt, kind, timeout);}
		double getCLDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLDemandValue(kind, timeout);}
		void getCLDemandValue(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLDemandValue(cur, kind, timeout);}
		double getCLActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLActualValue(kind, timeout);}
		void getCLActualValue(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLActualValue(cur, kind, timeout);}
		double getEncoderSineSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderSineSignal(kind, timeout);}
		void getEncoderSineSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderSineSignal(val, kind, timeout);}
		double getEncoderCosineSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderCosineSignal(kind, timeout);}
		void getEncoderCosineSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderCosineSignal(val, kind, timeout);}
		dword getEncoderHallDigSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderHallDigSignal(kind, timeout);}
		void getEncoderHallDigSignal(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderHallDigSignal(mask, kind, timeout);}
		dword getDigitalInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDigitalInput(kind, timeout);}
		void getDigitalInput(dword *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDigitalInput(inp, kind, timeout);}
		double getAnalogInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAnalogInput(kind, timeout);}
		void getAnalogInput(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAnalogInput(inp, kind, timeout);}
		dword getXDigitalInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXDigitalInput(kind, timeout);}
		void getXDigitalInput(dword *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXDigitalInput(inp, kind, timeout);}
		double getXAnalogInput1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogInput1(kind, timeout);}
		void getXAnalogInput1(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogInput1(inp, kind, timeout);}
		double getXAnalogInput2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogInput2(kind, timeout);}
		void getXAnalogInput2(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogInput2(inp, kind, timeout);}
		double getXAnalogInput3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogInput3(kind, timeout);}
		void getXAnalogInput3(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogInput3(inp, kind, timeout);}
		double getXAnalogInput4(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogInput4(kind, timeout);}
		void getXAnalogInput4(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogInput4(inp, kind, timeout);}
		dword getDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveStatus1(kind, timeout);}
		void getDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveStatus1(mask, kind, timeout);}
		dword getDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveStatus2(kind, timeout);}
		void getDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveStatus2(mask, kind, timeout);}
		double getCLI2tValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLI2tValue(kind, timeout);}
		void getCLI2tValue(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLI2tValue(val, kind, timeout);}
		int getAxisNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAxisNumber(kind, timeout);}
		void getAxisNumber(int *num, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAxisNumber(num, kind, timeout);}
		double getDriveTemperature(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveTemperature(kind, timeout);}
		void getDriveTemperature(double *temp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveTemperature(temp, kind, timeout);}
		dword getDriveDisplay(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveDisplay(sidx, kind, timeout);}
		void getDriveDisplay(int sidx, dword *str, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveDisplay(sidx, str, kind, timeout);}
		long getDriveSequenceLine(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveSequenceLine(kind, timeout);}
		void getDriveSequenceLine(long *line, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveSequenceLine(line, kind, timeout);}
		dword getDriveFuseStatus(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveFuseStatus(kind, timeout);}
		void getDriveFuseStatus(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveFuseStatus(mask, kind, timeout);}
		int getNbAvailableSlot(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getNbAvailableSlot(kind, timeout);}
		void getNbAvailableSlot(int *val1, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getNbAvailableSlot(val1, kind, timeout);}

		void getPLProportionalGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLProportionalGain(kind, handler, param);}
		void getPLProportionalGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLProportionalGain(handler, param);}
		void getPLSpeedFeedbackGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFeedbackGain(kind, handler, param);}
		void getPLSpeedFeedbackGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFeedbackGain(handler, param);}
		void getPLIntegratorGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorGain(kind, handler, param);}
		void getPLIntegratorGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorGain(handler, param);}
		void getPLAntiWindupGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAntiWindupGain(kind, handler, param);}
		void getPLAntiWindupGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAntiWindupGain(handler, param);}
		void getPLIntegratorLimitation(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorLimitation(kind, handler, param);}
		void getPLIntegratorLimitation(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorLimitation(handler, param);}
		void getPLIntegratorMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getPLIntegratorMode(kind, handler, param);}
		void getPLIntegratorMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getPLIntegratorMode(handler, param);}
		void getTtlSpeedlFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTtlSpeedlFilter(kind, handler, param);}
		void getTtlSpeedlFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTtlSpeedlFilter(handler, param);}
		void getPLAccFeedforwardGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAccFeedforwardGain(kind, handler, param);}
		void getPLAccFeedforwardGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAccFeedforwardGain(handler, param);}
		void getMaxPositionRangeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxPositionRangeLimit(kind, handler, param);}
		void getMaxPositionRangeLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxPositionRangeLimit(handler, param);}
		void getFollowingErrorWindow(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getFollowingErrorWindow(kind, handler, param);}
		void getFollowingErrorWindow(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getFollowingErrorWindow(handler, param);}
		void getVelocityErrorLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityErrorLimit(kind, handler, param);}
		void getVelocityErrorLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityErrorLimit(handler, param);}
		void getSwitchLimitMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getSwitchLimitMode(kind, handler, param);}
		void getSwitchLimitMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getSwitchLimitMode(handler, param);}
		void getEnableInputMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getEnableInputMode(kind, handler, param);}
		void getEnableInputMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getEnableInputMode(handler, param);}
		void getMinSoftPositionLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMinSoftPositionLimit(kind, handler, param);}
		void getMinSoftPositionLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMinSoftPositionLimit(handler, param);}
		void getMaxSoftPositionLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxSoftPositionLimit(kind, handler, param);}
		void getMaxSoftPositionLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxSoftPositionLimit(handler, param);}
		void getProfileLimitMode(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getProfileLimitMode(kind, handler, param);}
		void getProfileLimitMode(DsaDWordHandler handler, void *param = NULL) {DsaBase::getProfileLimitMode(handler, param);}
		void getPositionWindowTime(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindowTime(kind, handler, param);}
		void getPositionWindowTime(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindowTime(handler, param);}
		void getPositionWindow(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindow(kind, handler, param);}
		void getPositionWindow(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindow(handler, param);}
		void getHomingMethod(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingMethod(kind, handler, param);}
		void getHomingMethod(DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingMethod(handler, param);}
		void getHomingZeroSpeed(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingZeroSpeed(kind, handler, param);}
		void getHomingZeroSpeed(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingZeroSpeed(handler, param);}
		void getHomingAcceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingAcceleration(kind, handler, param);}
		void getHomingAcceleration(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingAcceleration(handler, param);}
		void getHomingFollowingLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFollowingLimit(kind, handler, param);}
		void getHomingFollowingLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFollowingLimit(handler, param);}
		void getHomingCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingCurrentLimit(kind, handler, param);}
		void getHomingCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingCurrentLimit(handler, param);}
		void getHomeOffset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomeOffset(kind, handler, param);}
		void getHomeOffset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomeOffset(handler, param);}
		void getHomingFixedMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFixedMvt(kind, handler, param);}
		void getHomingFixedMvt(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFixedMvt(handler, param);}
		void getHomingSwitchMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingSwitchMvt(kind, handler, param);}
		void getHomingSwitchMvt(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingSwitchMvt(handler, param);}
		void getHomingIndexMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingIndexMvt(kind, handler, param);}
		void getHomingIndexMvt(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingIndexMvt(handler, param);}
		void getHomingFineTuningMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningMode(kind, handler, param);}
		void getHomingFineTuningMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningMode(handler, param);}
		void getHomingFineTuningValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningValue(kind, handler, param);}
		void getHomingFineTuningValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningValue(handler, param);}
		void getMotorPhaseCorrection(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMotorPhaseCorrection(kind, handler, param);}
		void getMotorPhaseCorrection(DsaIntHandler handler, void *param = NULL) {DsaBase::getMotorPhaseCorrection(handler, param);}
		void getSoftwareCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSoftwareCurrentLimit(kind, handler, param);}
		void getSoftwareCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSoftwareCurrentLimit(handler, param);}
		void getDriveControlMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDriveControlMode(kind, handler, param);}
		void getDriveControlMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getDriveControlMode(handler, param);}
		void getDisplayMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDisplayMode(kind, handler, param);}
		void getDisplayMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getDisplayMode(handler, param);}
		void getEncoderInversion(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderInversion(kind, handler, param);}
		void getEncoderInversion(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderInversion(handler, param);}
		void getEncoderPhase1Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Offset(kind, handler, param);}
		void getEncoderPhase1Offset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Offset(handler, param);}
		void getEncoderPhase2Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Offset(kind, handler, param);}
		void getEncoderPhase2Offset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Offset(handler, param);}
		void getEncoderPhase1Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Factor(kind, handler, param);}
		void getEncoderPhase1Factor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Factor(handler, param);}
		void getEncoderPhase2Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Factor(kind, handler, param);}
		void getEncoderPhase2Factor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Factor(handler, param);}
		void getEncoderIndexDistance(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderIndexDistance(kind, handler, param);}
		void getEncoderIndexDistance(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderIndexDistance(handler, param);}
		void getCLProportionalGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLProportionalGain(kind, handler, param);}
		void getCLProportionalGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLProportionalGain(handler, param);}
		void getCLIntegratorGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLIntegratorGain(kind, handler, param);}
		void getCLIntegratorGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLIntegratorGain(handler, param);}
		void getCLCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentLimit(kind, handler, param);}
		void getCLCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentLimit(handler, param);}
		void getCLI2tCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tCurrentLimit(kind, handler, param);}
		void getCLI2tCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tCurrentLimit(handler, param);}
		void getCLI2tTimeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tTimeLimit(kind, handler, param);}
		void getCLI2tTimeLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tTimeLimit(handler, param);}
		void getInitMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getInitMode(kind, handler, param);}
		void getInitMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getInitMode(handler, param);}
		void getInitPulseLevel(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitPulseLevel(kind, handler, param);}
		void getInitPulseLevel(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitPulseLevel(handler, param);}
		void getInitMaxCurrent(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitMaxCurrent(kind, handler, param);}
		void getInitMaxCurrent(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitMaxCurrent(handler, param);}
		void getInitFinalPhase(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitFinalPhase(kind, handler, param);}
		void getInitFinalPhase(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitFinalPhase(handler, param);}
		void getInitTime(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitTime(kind, handler, param);}
		void getInitTime(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitTime(handler, param);}
		void getInitInitialPhase(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitInitialPhase(kind, handler, param);}
		void getInitInitialPhase(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitInitialPhase(handler, param);}
		void getMonSourceType(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceType(sidx, kind, handler, param);}
		void getMonSourceType(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceType(sidx, handler, param);}
		void getMonSourceIndex(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceIndex(sidx, kind, handler, param);}
		void getMonSourceIndex(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceIndex(sidx, handler, param);}
		void getSyncroStartTimeout(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getSyncroStartTimeout(kind, handler, param);}
		void getSyncroStartTimeout(DsaIntHandler handler, void *param = NULL) {DsaBase::getSyncroStartTimeout(handler, param);}
		void getDigitalOutput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalOutput(kind, handler, param);}
		void getDigitalOutput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalOutput(handler, param);}
		void getXDigitalOutput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalOutput(kind, handler, param);}
		void getXDigitalOutput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalOutput(handler, param);}
		void getXAnalogOutput1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput1(kind, handler, param);}
		void getXAnalogOutput1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput1(handler, param);}
		void getXAnalogOutput2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput2(kind, handler, param);}
		void getXAnalogOutput2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput2(handler, param);}
		void getXAnalogOutput3(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput3(kind, handler, param);}
		void getXAnalogOutput3(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput3(handler, param);}
		void getXAnalogOutput4(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput4(kind, handler, param);}
		void getXAnalogOutput4(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput4(handler, param);}
		void getAnalogOutput(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogOutput(kind, handler, param);}
		void getAnalogOutput(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogOutput(handler, param);}
		void getIndirectRegisterIdx(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectRegisterIdx(kind, handler, param);}
		void getIndirectRegisterIdx(DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectRegisterIdx(handler, param);}
		void getConcatenatedMvt(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getConcatenatedMvt(kind, handler, param);}
		void getConcatenatedMvt(DsaIntHandler handler, void *param = NULL) {DsaBase::getConcatenatedMvt(handler, param);}
		void getProfileType(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getProfileType(sidx, kind, handler, param);}
		void getProfileType(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getProfileType(sidx, handler, param);}
		void getMvtLktNumber(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMvtLktNumber(sidx, kind, handler, param);}
		void getMvtLktNumber(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMvtLktNumber(sidx, handler, param);}
		void getMvtLktTime(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMvtLktTime(sidx, kind, handler, param);}
		void getMvtLktTime(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMvtLktTime(sidx, handler, param);}
		void getCameValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCameValue(kind, handler, param);}
		void getCameValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCameValue(handler, param);}
		void getBrakeDeceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getBrakeDeceleration(kind, handler, param);}
		void getBrakeDeceleration(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getBrakeDeceleration(handler, param);}
		void getTargetPosition(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTargetPosition(sidx, kind, handler, param);}
		void getTargetPosition(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTargetPosition(sidx, handler, param);}
		void getProfileVelocity(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileVelocity(sidx, kind, handler, param);}
		void getProfileVelocity(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileVelocity(sidx, handler, param);}
		void getProfileAcceleration(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileAcceleration(sidx, kind, handler, param);}
		void getProfileAcceleration(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileAcceleration(sidx, handler, param);}
		void getJerkTime(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getJerkTime(sidx, kind, handler, param);}
		void getJerkTime(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getJerkTime(sidx, handler, param);}
		void getCtrlSourceType(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceType(kind, handler, param);}
		void getCtrlSourceType(DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceType(handler, param);}
		void getCtrlSourceIndex(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceIndex(kind, handler, param);}
		void getCtrlSourceIndex(DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceIndex(handler, param);}
		void getCtrlOffset(int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getCtrlOffset(kind, handler, param);}
		void getCtrlOffset(DsaLongHandler handler, void *param = NULL) {DsaBase::getCtrlOffset(handler, param);}
		void getCtrlGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCtrlGain(kind, handler, param);}
		void getCtrlGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCtrlGain(handler, param);}
		void getMotorKTFactor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMotorKTFactor(kind, handler, param);}
		void getMotorKTFactor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMotorKTFactor(handler, param);}
		void getPositionCtrlError(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionCtrlError(kind, handler, param);}
		void getPositionCtrlError(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionCtrlError(handler, param);}
		void getPositionMaxError(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionMaxError(kind, handler, param);}
		void getPositionMaxError(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionMaxError(handler, param);}
		void getPositionDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionDemandValue(kind, handler, param);}
		void getPositionDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionDemandValue(handler, param);}
		void getPositionActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionActualValue(kind, handler, param);}
		void getPositionActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionActualValue(handler, param);}
		void getVelocityDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityDemandValue(kind, handler, param);}
		void getVelocityDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityDemandValue(handler, param);}
		void getVelocityActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityActualValue(kind, handler, param);}
		void getVelocityActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityActualValue(handler, param);}
		void getAccDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAccDemandValue(kind, handler, param);}
		void getAccDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAccDemandValue(handler, param);}
		void getCLCurrentPhase1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase1(kind, handler, param);}
		void getCLCurrentPhase1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase1(handler, param);}
		void getCLCurrentPhase2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase2(kind, handler, param);}
		void getCLCurrentPhase2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase2(handler, param);}
		void getCLCurrentPhase3(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase3(kind, handler, param);}
		void getCLCurrentPhase3(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase3(handler, param);}
		void getCLLktPhase1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase1(kind, handler, param);}
		void getCLLktPhase1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase1(handler, param);}
		void getCLLktPhase2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase2(kind, handler, param);}
		void getCLLktPhase2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase2(handler, param);}
		void getCLLktPhase3(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase3(kind, handler, param);}
		void getCLLktPhase3(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase3(handler, param);}
		void getCLDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLDemandValue(kind, handler, param);}
		void getCLDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLDemandValue(handler, param);}
		void getCLActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLActualValue(kind, handler, param);}
		void getCLActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLActualValue(handler, param);}
		void getEncoderSineSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderSineSignal(kind, handler, param);}
		void getEncoderSineSignal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderSineSignal(handler, param);}
		void getEncoderCosineSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderCosineSignal(kind, handler, param);}
		void getEncoderCosineSignal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderCosineSignal(handler, param);}
		void getEncoderHallDigSignal(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getEncoderHallDigSignal(kind, handler, param);}
		void getEncoderHallDigSignal(DsaDWordHandler handler, void *param = NULL) {DsaBase::getEncoderHallDigSignal(handler, param);}
		void getDigitalInput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalInput(kind, handler, param);}
		void getDigitalInput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalInput(handler, param);}
		void getAnalogInput(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogInput(kind, handler, param);}
		void getAnalogInput(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogInput(handler, param);}
		void getXDigitalInput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalInput(kind, handler, param);}
		void getXDigitalInput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalInput(handler, param);}
		void getXAnalogInput1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput1(kind, handler, param);}
		void getXAnalogInput1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput1(handler, param);}
		void getXAnalogInput2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput2(kind, handler, param);}
		void getXAnalogInput2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput2(handler, param);}
		void getXAnalogInput3(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput3(kind, handler, param);}
		void getXAnalogInput3(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput3(handler, param);}
		void getXAnalogInput4(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput4(kind, handler, param);}
		void getXAnalogInput4(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput4(handler, param);}
		void getDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus1(kind, handler, param);}
		void getDriveStatus1(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus1(handler, param);}
		void getDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus2(kind, handler, param);}
		void getDriveStatus2(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus2(handler, param);}
		void getCLI2tValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tValue(kind, handler, param);}
		void getCLI2tValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tValue(handler, param);}
		void getAxisNumber(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getAxisNumber(kind, handler, param);}
		void getAxisNumber(DsaIntHandler handler, void *param = NULL) {DsaBase::getAxisNumber(handler, param);}
		void getDriveTemperature(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getDriveTemperature(kind, handler, param);}
		void getDriveTemperature(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getDriveTemperature(handler, param);}
		void getDriveDisplay(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveDisplay(sidx, kind, handler, param);}
		void getDriveDisplay(int sidx, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveDisplay(sidx, handler, param);}
		void getDriveSequenceLine(int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getDriveSequenceLine(kind, handler, param);}
		void getDriveSequenceLine(DsaLongHandler handler, void *param = NULL) {DsaBase::getDriveSequenceLine(handler, param);}
		void getDriveFuseStatus(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveFuseStatus(kind, handler, param);}
		void getDriveFuseStatus(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveFuseStatus(handler, param);}
		void getNbAvailableSlot(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getNbAvailableSlot(kind, handler, param);}
		void getNbAvailableSlot(DsaIntHandler handler, void *param = NULL) {DsaBase::getNbAvailableSlot(handler, param);}
};


/*------------------------------------------------------------------------------
 * DsaDriveGroup class - C++
 *-----------------------------------------------------------------------------*/
class DsaDriveGroup: public DsaBase {
    /* constructors */
	private:
		void _Group(int max, ...) {
			va_list arg;
			va_start(arg, max);
			ERRCHK(dsa_create_drive_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
			va_end(arg);
		}
	protected:
		DsaDriveGroup(void) {
		}
	public:
		DsaDriveGroup(DSA_DRIVE_GROUP *dev) {
			if (!dsa_is_valid_drive_group(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaDriveGroup(DsaDriveGroup &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaDriveGroup(DsaBase &obj) {
			if (!dsa_is_valid_drive_group(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaDriveGroup(int max, ...) {
			va_list arg;
			va_start(arg, max);
			ERRCHK(dsa_create_drive_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
			va_end(arg);
		}
		DsaDriveGroup(int max, DsaDriveBase *list[]) {
			ERRCHK(dsa_create_drive_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, list[i]->dsa));
		}
		DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2) {
			_Group(2, &d1, &d2);
		}
		DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3) {
			_Group(3, &d1, &d2, &d3);
		}
		DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4) {
			_Group(4, &d1, &d2, &d3, &d4);
		}
		DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5) {
			_Group(5, &d1, &d2, &d3, &d4, &d5);
		}
		DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6) {
			_Group(6, &d1, &d2, &d3, &d4, &d5, &d6);
		}
		DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7) {
			_Group(7, &d1, &d2, &d3, &d4, &d5, &d6, &d7);
		}
		DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7, DsaDriveBase d8) {
			_Group(8, &d1, &d2, &d3, &d4, &d5, &d6, &d7, &d8);
		}
    /* operators */
	public:
		DsaDriveGroup operator = (DsaDriveGroup &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaDriveGroup operator = (DsaBase &obj) {
			if (!dsa_is_valid_drive_group(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
	public:
		DsaDriveBase getGroupItem(int pos) {return DsaBase::getGroupItem(pos);}
		/* functions */
		void powerOn(long timeout = DEF_TIMEOUT) {DsaBase::powerOn(timeout);}
		void powerOff(long timeout = DEF_TIMEOUT) {DsaBase::powerOff(timeout);}
		void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::newSetpoint(sidx, flags, timeout);}
		void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::changeSetpoint(sidx, flags, timeout);}
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
		void homingStart(long timeout = DEF_TIMEOUT) {DsaBase::homingStart(timeout);}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
		void startProfiledMovement(double pos, double speed, double acc, long timeout = DEF_TIMEOUT) {DsaBase::startProfiledMovement(pos, speed, acc, timeout);}
		void startRelativeProfiledMovement(double relativePos, long timeout = DEF_TIMEOUT) {DsaBase::startRelativeProfiledMovement(relativePos, timeout);}
		void stageMappingDownload(const char *fileName) {DsaBase::stageMappingDownload(fileName);}
		void stageMappingUpload(const char *fileName) {DsaBase::stageMappingUpload(fileName);}
		void stageMappingActivate() {DsaBase::stageMappingActivate();}
		void stageMappingDeactivate() {DsaBase::stageMappingDeactivate();}
		bool stageMappingIsActivated() {return DsaBase::stageMappingIsActivated();}

		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

		void powerOn(DsaHandler handler, void *param = NULL) {DsaBase::powerOn(handler, param);}
		void powerOff(DsaHandler handler, void *param = NULL) {DsaBase::powerOff(handler, param);}
		void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::newSetpoint(sidx, flags, handler, param);}
		void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::changeSetpoint(sidx, flags, handler, param);}
		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
		void homingStart(DsaHandler handler, void *param = NULL) {DsaBase::homingStart(handler, param);}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
		void startProfiledMovement(double pos, double speed, double acc, DsaHandler handler, void *param = NULL) {DsaBase::startProfiledMovement(pos, speed, acc, handler, param);}
		void startRelativeProfiledMovement(double relativePos, DsaHandler handler, void *param = NULL) {DsaBase::startRelativeProfiledMovement(relativePos, handler, param);}

		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

		void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
		void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
		int  getGroupSize() {return DsaBase::getGroupSize();}
		void cancelStatusWait() {DsaBase::cancelStatusWait();}
		void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}

		/* commands */
		void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
		void stepMotion(double pos, long timeout = DEF_TIMEOUT) {DsaBase::stepMotion(pos, timeout);}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
		void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
		void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
		void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
		void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
		void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
		void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

		void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
		void stepMotion(double pos, DsaHandler handler, void *param = NULL) {DsaBase::stepMotion(pos, handler, param);}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
		void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
		void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
		void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
		void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
		void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
	    int getFamily() {return DsaBase::getFamily();}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
		void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
		void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}

		/* register setters */
		void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLProportionalGain(gain, timeout);}
		void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedbackGain(gain, timeout);}
		void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorGain(gain, timeout);}
		void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLAntiWindupGain(gain, timeout);}
		void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorLimitation(limit, timeout);}
		void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorMode(mode, timeout);}
		void setTtlSpeedlFilter(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setTtlSpeedlFilter(factor, timeout);}
		void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLAccFeedforwardGain(factor, timeout);}
		void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxPositionRangeLimit(pos, timeout);}
		void startMovement(double *targets, long timeout = DEF_TIMEOUT) {DsaBase::startMovement(targets, timeout);}

		void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setFollowingErrorWindow(pos, timeout);}
		void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setVelocityErrorLimit(vel, timeout);}
		void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setSwitchLimitMode(mode, timeout);}
		void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setEnableInputMode(mode, timeout);}
		void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinSoftPositionLimit(pos, timeout);}
		void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxSoftPositionLimit(pos, timeout);}
		void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {DsaBase::setProfileLimitMode(flags, timeout);}
		void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindowTime(tim, timeout);}
		void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindow(win, timeout);}
		void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingMethod(mode, timeout);}
		void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setHomingZeroSpeed(vel, timeout);}
		void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setHomingAcceleration(acc, timeout);}
		void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFollowingLimit(win, timeout);}
		void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setHomingCurrentLimit(cur, timeout);}
		void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomeOffset(pos, timeout);}
		void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFixedMvt(pos, timeout);}
		void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingSwitchMvt(pos, timeout);}
		void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingIndexMvt(pos, timeout);}
		void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningMode(mode, timeout);}
		void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningValue(phase, timeout);}
		void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setMotorPhaseCorrection(mode, timeout);}
		void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setSoftwareCurrentLimit(cur, timeout);}
		void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDriveControlMode(mode, timeout);}
		void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDisplayMode(mode, timeout);}
		void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderInversion(invert, timeout);}
		void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Offset(offset, timeout);}
		void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Offset(offset, timeout);}
		void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Factor(factor, timeout);}
		void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Factor(factor, timeout);}
		void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderIndexDistance(pos, timeout);}
		void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLProportionalGain(gain, timeout);}
		void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLIntegratorGain(gain, timeout);}
		void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLCurrentLimit(cur, timeout);}
		void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tCurrentLimit(cur, timeout);}
		void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tTimeLimit(tim, timeout);}
		void setInitMode(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setInitMode(typ, timeout);}
		void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitPulseLevel(cur, timeout);}
		void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitMaxCurrent(cur, timeout);}
		void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitFinalPhase(cal, timeout);}
		void setInitTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setInitTime(tim, timeout);}
		void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitInitialPhase(cal, timeout);}
		void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceType(sidx, typ, timeout);}
		void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceIndex(sidx, index, timeout);}
		void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroStartTimeout(tim, timeout);}
		void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setDigitalOutput(out, timeout);}
		void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setXDigitalOutput(out, timeout);}
		void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput1(out, timeout);}
		void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput2(out, timeout);}
		void setXAnalogOutput3(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput3(out, timeout);}
		void setXAnalogOutput4(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput4(out, timeout);}
		void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {DsaBase::setAnalogOutput(out, timeout);}
		void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterIdx(idx, timeout);}
		void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {DsaBase::setConcatenatedMvt(concat, timeout);}
		void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setProfileType(sidx, typ, timeout);}
		void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktNumber(sidx, number, timeout);}
		void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktTime(sidx, time, timeout);}
		void setCameValue(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCameValue(factor, timeout);}
		void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::setBrakeDeceleration(dec, timeout);}
		void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTargetPosition(sidx, pos, timeout);}
		void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setProfileVelocity(sidx, vel, timeout);}
		void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {DsaBase::setProfileAcceleration(sidx, acc, timeout);}
		void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {DsaBase::setJerkTime(sidx, tim, timeout);}
		void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceType(typ, timeout);}
		void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceIndex(index, timeout);}
		void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlOffset(offset, timeout);}
		void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlGain(gain, timeout);}
		void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {DsaBase::setMotorKTFactor(kt, timeout);}

		void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLProportionalGain(gain, handler, param);}
		void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedbackGain(gain, handler, param);}
		void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorGain(gain, handler, param);}
		void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLAntiWindupGain(gain, handler, param);}
		void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorLimitation(limit, handler, param);}
		void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorMode(mode, handler, param);}
		void setTtlSpeedlFilter(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setTtlSpeedlFilter(factor, handler, param);}
		void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLAccFeedforwardGain(factor, handler, param);}
		void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxPositionRangeLimit(pos, handler, param);}
		void startMovement(double *targets, DsaHandler handler, void *param = NULL) {DsaBase::startMovement(targets, handler, param);}

		void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setFollowingErrorWindow(pos, handler, param);}
		void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setVelocityErrorLimit(vel, handler, param);}
		void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setSwitchLimitMode(mode, handler, param);}
		void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setEnableInputMode(mode, handler, param);}
		void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinSoftPositionLimit(pos, handler, param);}
		void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxSoftPositionLimit(pos, handler, param);}
		void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {DsaBase::setProfileLimitMode(flags, handler, param);}
		void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindowTime(tim, handler, param);}
		void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindow(win, handler, param);}
		void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingMethod(mode, handler, param);}
		void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setHomingZeroSpeed(vel, handler, param);}
		void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setHomingAcceleration(acc, handler, param);}
		void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFollowingLimit(win, handler, param);}
		void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setHomingCurrentLimit(cur, handler, param);}
		void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomeOffset(pos, handler, param);}
		void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFixedMvt(pos, handler, param);}
		void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingSwitchMvt(pos, handler, param);}
		void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingIndexMvt(pos, handler, param);}
		void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningMode(mode, handler, param);}
		void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningValue(phase, handler, param);}
		void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setMotorPhaseCorrection(mode, handler, param);}
		void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setSoftwareCurrentLimit(cur, handler, param);}
		void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDriveControlMode(mode, handler, param);}
		void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDisplayMode(mode, handler, param);}
		void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderInversion(invert, handler, param);}
		void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Offset(offset, handler, param);}
		void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Offset(offset, handler, param);}
		void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Factor(factor, handler, param);}
		void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Factor(factor, handler, param);}
		void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderIndexDistance(pos, handler, param);}
		void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLProportionalGain(gain, handler, param);}
		void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLIntegratorGain(gain, handler, param);}
		void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLCurrentLimit(cur, handler, param);}
		void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tCurrentLimit(cur, handler, param);}
		void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tTimeLimit(tim, handler, param);}
		void setInitMode(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setInitMode(typ, handler, param);}
		void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitPulseLevel(cur, handler, param);}
		void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitMaxCurrent(cur, handler, param);}
		void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitFinalPhase(cal, handler, param);}
		void setInitTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setInitTime(tim, handler, param);}
		void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitInitialPhase(cal, handler, param);}
		void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceType(sidx, typ, handler, param);}
		void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceIndex(sidx, index, handler, param);}
		void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroStartTimeout(tim, handler, param);}
		void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setDigitalOutput(out, handler, param);}
		void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setXDigitalOutput(out, handler, param);}
		void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput1(out, handler, param);}
		void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput2(out, handler, param);}
		void setXAnalogOutput3(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput3(out, handler, param);}
		void setXAnalogOutput4(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput4(out, handler, param);}
		void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {DsaBase::setAnalogOutput(out, handler, param);}
		void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterIdx(idx, handler, param);}
		void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {DsaBase::setConcatenatedMvt(concat, handler, param);}
		void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setProfileType(sidx, typ, handler, param);}
		void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktNumber(sidx, number, handler, param);}
		void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktTime(sidx, time, handler, param);}
		void setCameValue(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCameValue(factor, handler, param);}
		void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::setBrakeDeceleration(dec, handler, param);}
		void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTargetPosition(sidx, pos, handler, param);}
		void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setProfileVelocity(sidx, vel, handler, param);}
		void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {DsaBase::setProfileAcceleration(sidx, acc, handler, param);}
		void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {DsaBase::setJerkTime(sidx, tim, handler, param);}
		void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceType(typ, handler, param);}
		void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceIndex(index, handler, param);}
		void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlOffset(offset, handler, param);}
		void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlGain(gain, handler, param);}
		void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {DsaBase::setMotorKTFactor(kt, handler, param);}
};

/*------------------------------------------------------------------------------
 * DsaGantry class - C++
 *-----------------------------------------------------------------------------*/
class DsaGantry: public DsaBase {
    /* constructors */
	protected:
		DsaGantry(void) {
		}
	public:
		DsaGantry(DSA_GANTRY *dev) {
			if (!dsa_is_valid_gantry(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaGantry(DsaGantry &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaGantry(DsaBase &obj) {
			if (!dsa_is_valid_drive_group(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaGantry(DsaDriveBase d1, DsaDriveBase d2) {
			ERRCHK(dsa_create_gantry(&dsa));
			ERRCHK(dsa_set_group_item(dsa, 0, d1.dsa));
			ERRCHK(dsa_set_group_item(dsa, 1, d2.dsa));
		}
    /* operators */
	public:
		DsaGantry operator = (DsaGantry &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaGantry operator = (DsaBase &obj) {
			if (!dsa_is_valid_drive_group(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
    /* functions */
	public:
		DsaGantry getGroupItem(int pos) {return DsaBase::getGroupItem(pos);}
		void powerOn(long timeout = DEF_TIMEOUT) {DsaBase::powerOn(timeout);}
		void powerOff(long timeout = DEF_TIMEOUT) {DsaBase::powerOff(timeout);}
		void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::newSetpoint(sidx, flags, timeout);}
		void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::changeSetpoint(sidx, flags, timeout);}
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
		void homingStart(long timeout = DEF_TIMEOUT) {DsaBase::homingStart(timeout);}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
		void startProfiledMovement(double pos, double speed, double acc, long timeout = DEF_TIMEOUT) {DsaBase::startProfiledMovement(pos, speed, acc, timeout);}
		void startRelativeProfiledMovement(double relativePos, long timeout = DEF_TIMEOUT) {DsaBase::startRelativeProfiledMovement(relativePos, timeout);}
		void stageMappingDownload(const char *fileName) {DsaBase::stageMappingDownload(fileName);}
		void stageMappingUpload(const char *fileName) {DsaBase::stageMappingUpload(fileName);}
		void stageMappingActivate() {DsaBase::stageMappingActivate();}
		void stageMappingDeactivate() {DsaBase::stageMappingDeactivate();}
		bool stageMappingIsActivated() {return DsaBase::stageMappingIsActivated();}

		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
		void gantryWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::gantryWaitAndStatusEqual(mask, ref, timeout);}
		void gantryWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::gantryWaitAndStatusNotEqual(mask, ref, timeout);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

		void powerOn(DsaHandler handler, void *param = NULL) {DsaBase::powerOn(handler, param);}
		void powerOff(DsaHandler handler, void *param = NULL) {DsaBase::powerOff(handler, param);}
		void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::newSetpoint(sidx, flags, handler, param);}
		void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::changeSetpoint(sidx, flags, handler, param);}
		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
		void homingStart(DsaHandler handler, void *param = NULL) {DsaBase::homingStart(handler, param);}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
		void startProfiledMovement(double pos, double speed, double acc, DsaHandler handler, void *param = NULL) {DsaBase::startProfiledMovement(pos, speed, acc, handler, param);}
		void startRelativeProfiledMovement(double relativePos, DsaHandler handler, void *param = NULL) {DsaBase::startRelativeProfiledMovement(relativePos, handler, param);}

		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
		void gantryWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::gantryWaitAndStatusEqual(mask, ref, handler, param);}
		void gantryWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::gantryWaitAndStatusNotEqual(mask, ref, handler, param);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

		void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
		void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
		int  getGroupSize() {return DsaBase::getGroupSize();}
		int  gantryGetErrorCode(int *axis, int kind) {return DsaBase::gantryGetErrorCode(axis, kind);}
		void cancelStatusWait() {DsaBase::cancelStatusWait();}
		void gantryCancelStatusWait() {DsaBase::gantryCancelStatusWait();}
		DsaStatus  gantryGetAndStatus() {return DsaBase::gantryGetAndStatus();}
		DsaStatus  gantryGetORStatus() {return DsaBase::gantryGetORStatus();}
		void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}

		/* commands */
		void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
		void stepMotion(double pos, long timeout = DEF_TIMEOUT) {DsaBase::stepMotion(pos, timeout);}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
		void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
		void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
		void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
		void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
		void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
		void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

		void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
		void stepMotion(double pos, DsaHandler handler, void *param = NULL) {DsaBase::stepMotion(pos, handler, param);}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
		void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
		void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
		void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
		void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
		void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
	    int getFamily() {return DsaBase::getFamily();}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
		void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
		void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}

		/* register setters */
		void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLProportionalGain(gain, timeout);}
		void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedbackGain(gain, timeout);}
		void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorGain(gain, timeout);}
		void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLAntiWindupGain(gain, timeout);}
		void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorLimitation(limit, timeout);}
		void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorMode(mode, timeout);}
		void setTtlSpeedlFilter(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setTtlSpeedlFilter(factor, timeout);}
		void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLAccFeedforwardGain(factor, timeout);}
		void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxPositionRangeLimit(pos, timeout);}
		void startMovement(double *targets, long timeout = DEF_TIMEOUT) {DsaBase::startMovement(targets, timeout);}

		void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setFollowingErrorWindow(pos, timeout);}
		void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setVelocityErrorLimit(vel, timeout);}
		void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setSwitchLimitMode(mode, timeout);}
		void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setEnableInputMode(mode, timeout);}
		void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinSoftPositionLimit(pos, timeout);}
		void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxSoftPositionLimit(pos, timeout);}
		void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {DsaBase::setProfileLimitMode(flags, timeout);}
		void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindowTime(tim, timeout);}
		void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindow(win, timeout);}
		void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingMethod(mode, timeout);}
		void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setHomingZeroSpeed(vel, timeout);}
		void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setHomingAcceleration(acc, timeout);}
		void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFollowingLimit(win, timeout);}
		void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setHomingCurrentLimit(cur, timeout);}
		void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomeOffset(pos, timeout);}
		void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFixedMvt(pos, timeout);}
		void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingSwitchMvt(pos, timeout);}
		void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingIndexMvt(pos, timeout);}
		void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningMode(mode, timeout);}
		void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningValue(phase, timeout);}
		void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setMotorPhaseCorrection(mode, timeout);}
		void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setSoftwareCurrentLimit(cur, timeout);}
		void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDriveControlMode(mode, timeout);}
		void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDisplayMode(mode, timeout);}
		void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderInversion(invert, timeout);}
		void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Offset(offset, timeout);}
		void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Offset(offset, timeout);}
		void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Factor(factor, timeout);}
		void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Factor(factor, timeout);}
		void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderIndexDistance(pos, timeout);}
		void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLProportionalGain(gain, timeout);}
		void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLIntegratorGain(gain, timeout);}
		void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLCurrentLimit(cur, timeout);}
		void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tCurrentLimit(cur, timeout);}
		void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tTimeLimit(tim, timeout);}
		void setInitMode(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setInitMode(typ, timeout);}
		void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitPulseLevel(cur, timeout);}
		void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitMaxCurrent(cur, timeout);}
		void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitFinalPhase(cal, timeout);}
		void setInitTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setInitTime(tim, timeout);}
		void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitInitialPhase(cal, timeout);}
		void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceType(sidx, typ, timeout);}
		void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceIndex(sidx, index, timeout);}
		void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroStartTimeout(tim, timeout);}
		void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setDigitalOutput(out, timeout);}
		void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setXDigitalOutput(out, timeout);}
		void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput1(out, timeout);}
		void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput2(out, timeout);}
		void setXAnalogOutput3(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput3(out, timeout);}
		void setXAnalogOutput4(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput4(out, timeout);}
		void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {DsaBase::setAnalogOutput(out, timeout);}
		void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterIdx(idx, timeout);}
		void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {DsaBase::setConcatenatedMvt(concat, timeout);}
		void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setProfileType(sidx, typ, timeout);}
		void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktNumber(sidx, number, timeout);}
		void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktTime(sidx, time, timeout);}
		void setCameValue(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCameValue(factor, timeout);}
		void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::setBrakeDeceleration(dec, timeout);}
		void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTargetPosition(sidx, pos, timeout);}
		void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setProfileVelocity(sidx, vel, timeout);}
		void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {DsaBase::setProfileAcceleration(sidx, acc, timeout);}
		void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {DsaBase::setJerkTime(sidx, tim, timeout);}
		void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceType(typ, timeout);}
		void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceIndex(index, timeout);}
		void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlOffset(offset, timeout);}
		void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlGain(gain, timeout);}
		void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {DsaBase::setMotorKTFactor(kt, timeout);}

		void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLProportionalGain(gain, handler, param);}
		void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedbackGain(gain, handler, param);}
		void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorGain(gain, handler, param);}
		void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLAntiWindupGain(gain, handler, param);}
		void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorLimitation(limit, handler, param);}
		void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorMode(mode, handler, param);}
		void setTtlSpeedlFilter(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setTtlSpeedlFilter(factor, handler, param);}
		void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLAccFeedforwardGain(factor, handler, param);}
		void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxPositionRangeLimit(pos, handler, param);}
		void startMovement(double *targets, DsaHandler handler, void *param = NULL) {DsaBase::startMovement(targets, handler, param);}

		void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setFollowingErrorWindow(pos, handler, param);}
		void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setVelocityErrorLimit(vel, handler, param);}
		void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setSwitchLimitMode(mode, handler, param);}
		void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setEnableInputMode(mode, handler, param);}
		void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinSoftPositionLimit(pos, handler, param);}
		void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxSoftPositionLimit(pos, handler, param);}
		void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {DsaBase::setProfileLimitMode(flags, handler, param);}
		void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindowTime(tim, handler, param);}
		void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindow(win, handler, param);}
		void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingMethod(mode, handler, param);}
		void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setHomingZeroSpeed(vel, handler, param);}
		void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setHomingAcceleration(acc, handler, param);}
		void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFollowingLimit(win, handler, param);}
		void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setHomingCurrentLimit(cur, handler, param);}
		void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomeOffset(pos, handler, param);}
		void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFixedMvt(pos, handler, param);}
		void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingSwitchMvt(pos, handler, param);}
		void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingIndexMvt(pos, handler, param);}
		void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningMode(mode, handler, param);}
		void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningValue(phase, handler, param);}
		void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setMotorPhaseCorrection(mode, handler, param);}
		void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setSoftwareCurrentLimit(cur, handler, param);}
		void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDriveControlMode(mode, handler, param);}
		void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDisplayMode(mode, handler, param);}
		void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderInversion(invert, handler, param);}
		void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Offset(offset, handler, param);}
		void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Offset(offset, handler, param);}
		void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Factor(factor, handler, param);}
		void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Factor(factor, handler, param);}
		void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderIndexDistance(pos, handler, param);}
		void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLProportionalGain(gain, handler, param);}
		void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLIntegratorGain(gain, handler, param);}
		void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLCurrentLimit(cur, handler, param);}
		void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tCurrentLimit(cur, handler, param);}
		void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tTimeLimit(tim, handler, param);}
		void setInitMode(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setInitMode(typ, handler, param);}
		void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitPulseLevel(cur, handler, param);}
		void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitMaxCurrent(cur, handler, param);}
		void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitFinalPhase(cal, handler, param);}
		void setInitTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setInitTime(tim, handler, param);}
		void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitInitialPhase(cal, handler, param);}
		void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceType(sidx, typ, handler, param);}
		void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceIndex(sidx, index, handler, param);}
		void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroStartTimeout(tim, handler, param);}
		void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setDigitalOutput(out, handler, param);}
		void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setXDigitalOutput(out, handler, param);}
		void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput1(out, handler, param);}
		void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput2(out, handler, param);}
		void setXAnalogOutput3(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput3(out, handler, param);}
		void setXAnalogOutput4(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput4(out, handler, param);}
		void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {DsaBase::setAnalogOutput(out, handler, param);}
		void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterIdx(idx, handler, param);}
		void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {DsaBase::setConcatenatedMvt(concat, handler, param);}
		void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setProfileType(sidx, typ, handler, param);}
		void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktNumber(sidx, number, handler, param);}
		void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktTime(sidx, time, handler, param);}
		void setCameValue(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCameValue(factor, handler, param);}
		void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::setBrakeDeceleration(dec, handler, param);}
		void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTargetPosition(sidx, pos, handler, param);}
		void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setProfileVelocity(sidx, vel, handler, param);}
		void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {DsaBase::setProfileAcceleration(sidx, acc, handler, param);}
		void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {DsaBase::setJerkTime(sidx, tim, handler, param);}
		void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceType(typ, handler, param);}
		void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceIndex(index, handler, param);}
		void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlOffset(offset, handler, param);}
		void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlGain(gain, handler, param);}
		void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {DsaBase::setMotorKTFactor(kt, handler, param);}
};


/*------------------------------------------------------------------------------
 * DsaRTVData class - C++
 *-----------------------------------------------------------------------------*/
class DsaRTVData {
	protected:
		DSA_RTV_DATA *rtvData;
		int typ;
		bool destroy;
    /* constructors */
	public: 
		DsaRTVData(DsaDevice dev, int regTyp, int regIdx, int regSidx) {
			rtvData = NULL;
			typ = READ_RTV_DATA;			
			destroy = TRUE;
			ERRCHK(dsa_create_rtv_read(dev.getDsaStructure(), regTyp, regIdx, regSidx, &rtvData));
		}
		DsaRTVData(DsaDevice dev, int incrementTyp) {
			rtvData = NULL;
			typ = WRITE_RTV_DATA;			
			destroy = TRUE;
			ERRCHK(dsa_create_rtv_write(dev.getDsaStructure(), incrementTyp, &rtvData));
		}
		DsaRTVData(DSA_RTV_DATA *rtvData) {
			this->rtvData = rtvData;
			destroy = FALSE;
			if (dsa_is_read_rtv(rtvData))
				typ = READ_RTV_DATA;			
			else
				typ = WRITE_RTV_DATA;			
		}
	public:
		~DsaRTVData(void) {
			if (destroy && rtvData)
				ERRCHK(dsa_destroy_rtv(&rtvData));
		}

	public:
		/*
		 * RTV_DATA typ
		 */
		enum {READ_RTV_DATA = 0};				/*Read RTV data */
		enum {WRITE_RTV_DATA = 1};				/*Write RTV data */


	public:
		DSA_RTV_DATA* getRTVDataStructure() {
			return rtvData;
		}
		int readInt32() {
			int value;
			ERRCHK(dsa_read_rtv_int32(rtvData, &value));
			return value;
		}
		eint64 readInt64() {
			eint64 value;
			ERRCHK(dsa_read_rtv_int64(rtvData, &value));
			return value;
		}
		float readFloat32() {
			float value;
			ERRCHK(dsa_read_rtv_float32(rtvData, &value));
			return value;
		}
		double readFloat64() {
			double value;
			ERRCHK(dsa_read_rtv_float64(rtvData, &value));
			return value;
		}
		void writeInt32(int value) {
			ERRCHK(dsa_write_rtv_int32(rtvData, value));
		}
		void writeInt64(eint64 value) {
			ERRCHK(dsa_write_rtv_int64(rtvData, value));
		}
		void writeFloat32(float value) {
			ERRCHK(dsa_write_rtv_float32(rtvData, value));
		}
		void writeFloat64(double value) {
			ERRCHK(dsa_write_rtv_float64(rtvData, value));
		}
		bool isRead() {
			return dsa_is_read_rtv(rtvData);
		}
		bool isWrite() {
			return dsa_is_write_rtv(rtvData);
		}
		bool isInt32() {
			return dsa_is_int32_rtv(rtvData);
		}
		bool isInt64() {
			return dsa_is_int64_rtv(rtvData);
		}
		bool isFloat32() {
			return dsa_is_float32_rtv(rtvData);
		}
		bool isFloat64() {
			return dsa_is_float64_rtv(rtvData);
		}
		int getRegisterTyp() {
			int value;
			ERRCHK(dsa_get_register_typ_idx_sidx_rtv(rtvData, &value, NULL, NULL));
			return value;
		}
		int getRegisterIdx() {
			int value;
			ERRCHK(dsa_get_register_typ_idx_sidx_rtv(rtvData, NULL, &value, NULL));
			return value;
		}
		int getRegisterSidx() {
			int value;
			ERRCHK(dsa_get_register_typ_idx_sidx_rtv(rtvData, NULL, NULL, &value));
			return value;
		}
};

/*------------------------------------------------------------------------------
 * DsaMasterBase class - C++
 *-----------------------------------------------------------------------------*/
class DsaMasterBase: public DsaBase {
    /* constructors */
	protected:
		DsaMasterBase(void) {
		}
	public:
		DsaMasterBase(DSA_MASTER_BASE *dev) {
			if (!dsa_is_valid_master_base(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaMasterBase(DsaMasterBase &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaMasterBase(DsaBase &obj) {
			if (!dsa_is_valid_master_base(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
	public:
	    /* operators */
		DsaMasterBase operator = (DsaMasterBase &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaMasterBase operator = (DsaBase &obj) {
			if (!dsa_is_valid_master_base(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		/* functions */
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

		void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
		void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
		void cancelStatusWait() {DsaBase::cancelStatusWait();}
		void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}

		/* commands */
		void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
		void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
		void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
		void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
		void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
		void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
		void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

		void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
		void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
		void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
		void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
		void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
		void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
	    int getFamily() {return DsaBase::getFamily();}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
		void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
		void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}

		/*
		 * IO management - synchronous
		 */
		//ExternalIO Management functions
		void externalIOSetEnableCyclicUpdate(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetEnableCyclicUpdate(enable, timeout);}
		void externalIOResetClientCommunication(long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetClientCommunication(timeout);}
		void externalIOResetIOCycleCount(long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetIOCycleCount(timeout);}
		void externalIOResetMaxUpdateTime(long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetMaxUpdateTime(timeout);}

		//ExternalIO Watchdog functions
		void externalIOEnableWatchdog(long timeout = DEF_TIMEOUT) {DsaBase::externalIOEnableWatchdog(timeout);}
		void externalIODisableWatchdog(long timeout = DEF_TIMEOUT) {DsaBase::externalIODisableWatchdog(timeout);}
		void externalIOStopWatchdog(long timeout = DEF_TIMEOUT) {DsaBase::externalIOStopWatchdog(timeout);}
		void externalIOSetWatchdogTime(int value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetWatchdogTime(timeout);}

		//ExternalIO digital output functions
		void externalIOSetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetDigitalOutput(outputIdx, timeout);}
		void externalIOResetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetDigitalOutput(outputIdx, timeout);}
		void externalIOApplyMaskDigitalOutput(int firstOutputIdx, int numberBits, dword value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOApplyMaskDigitalOutput(firstOutputIdx, numberBits, value, timeout);}

		//ExternalIO analog output functions
		void externalIOSetAnalogOutputRawData(int outputIdx, dword value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetAnalogOutputRawData(outputIdx, value, timeout);}
		void externalIOSetAnalogOutputConvertedData(int outputIdx, float value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetAnalogOutputConvertedData(outputIdx, value, timeout);};

		//ExternalIO digital input functions
		//ExternalIO analog input functions
		//ExternalIO direct modbus functions
		void externalIOSetModbusRegister(int registerAddress, dword value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetModbusRegister(registerAddress, value, timeout);}

		//LocalIO digital output functions
		void localIOSetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::localIOSetDigitalOutput(outputIdx, timeout);}
		void localIOResetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::localIOResetDigitalOutput(outputIdx, timeout);}

		//LocalIO digital input functions
};


/*------------------------------------------------------------------------------
 * DsaMaster class - C++
 *-----------------------------------------------------------------------------*/
class DsaMaster: public DsaBase {
	private:
		DSA_RTV_DATA *readTable[64];
		DSA_RTV_DATA *writeTable[64];
    /* constructors */
	public:
		DsaMaster(DSA_MASTER *dev) {
			if (!dsa_is_valid_master(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaMaster(void) {
			dsa = NULL;
			ERRCHK(dsa_create_master(&dsa));
		}
		DsaMaster(DsaMaster &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaMaster(DsaBase &obj) {
			if (!dsa_is_valid_master(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
	public:
	    /* operators */
		DsaMaster operator = (DsaMaster &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaMaster operator = (DsaBase &obj) {
			if (!dsa_is_valid_master(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		/* functions */
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
		int  getWarningCode(int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getWarningCode(kind, timeout);}
		int  getErrorCode(int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getErrorCode(kind, timeout);}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
		long getRegister(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegister(typ, idx, sidx, kind, timeout);}
		long getRegisterInt32(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterInt32(typ, idx, sidx, kind, timeout);}
		eint64 getRegisterInt64(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterInt64(typ, idx, sidx, kind, timeout);}
		float getRegisterFloat32(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterFloat32(typ, idx, sidx, kind, timeout);}
		double getRegisterFloat64(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegisterFloat64(typ, idx, sidx, kind, timeout);}
		void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayInt32(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayInt64(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayFloat32(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		void getArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArrayFloat64(typ, idx, nidx, sidx, val, offset, kind, timeout);}
		int  getParametersVersion(int what, long timeout = DEF_TIMEOUT) {return DsaBase::getParametersVersion(what, timeout);}
		double getSequenceCodeUsage(long timeout = DEF_TIMEOUT) {DsaBase::getSequenceCodeUsage(timeout);}
		double getSequenceSourceUsage(long timeout = DEF_TIMEOUT) {DsaBase::getSequenceSourceUsage(timeout);}
		double getSequenceDataUsage(long timeout = DEF_TIMEOUT) {DsaBase::getSequenceDataUsage(timeout);}
		int getDebugSequenceNbBreakpoints(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDebugSequenceNbBreakpoints(kind, timeout);}
		int getDebugSequenceBreakThreadNb(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDebugSequenceBreakThreadNb(kind, timeout);}

		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}
		double  getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, timeout);}
		void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, timeout);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
		void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout = DEF_TIMEOUT) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, timeout);}
		DsaStatus  waitStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusEqual(mask, ref, timeout);}
		DsaStatus  waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusNotEqual(mask, ref, timeout);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
		DsaStatus  waitStatusChange(DsaStatus *mask, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusChange(mask, timeout);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
		void getWarningCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getWarningCode(kind, handler, param);}
		void getErrorCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getErrorCode(kind, handler, param);}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
		void getRegister(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getRegister(typ, idx, sidx, kind, handler, param);}
		void getRegisterInt32(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getRegisterInt32(typ, idx, sidx, kind, handler, param);}
		void getRegisterInt64(int typ, unsigned idx, int sidx, int kind, DsaInt64Handler handler, void *param = NULL) {DsaBase::getRegisterInt64(typ, idx, sidx, kind, handler, param);}
		void getRegisterFloat32(int typ, unsigned idx, int sidx, int kind, DsaFloatHandler handler, void *param = NULL) {DsaBase::getRegisterFloat32(typ, idx, sidx, kind, handler, param);}
		void getRegisterFloat64(int typ, unsigned idx, int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getRegisterFloat64(typ, idx, sidx, kind, handler, param);}
		void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, handler, param);}
		void getParametersVersion(int what, DsaIntHandler handler, void *param = NULL) {DsaBase::getParametersVersion(what, handler, param);}
		void getDebugSequenceNbBreakpoints(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceNbBreakpoints(kind, handler, param);}
		void getDebugSequenceNbBreakpoints(DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceNbBreakpoints(handler, param);}
		void getDebugSequenceBreakThreadNb(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceBreakThreadNb(kind, handler, param);}
		void getDebugSequenceBreakThreadNb(DsaIntHandler handler, void *param = NULL) {DsaBase::getDebugSequenceBreakThreadNb(handler, param);}

		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, handler, param);}
		void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, handler, param);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
		void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, Dsa2intHandler handler, void *param = NULL) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, handler, param);}
		void waitStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusEqual(mask, ref, handler, param);}
		void waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusNotEqual(mask, ref, handler, param);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
		void waitStatusChange(DsaStatus *mask, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusChange(mask, handler, param);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

		void etcomOpen(EtbBus etb, int axis) {DsaBase::etcomOpen(etb, axis);}
		void open(char_cp url) {DsaBase::open(url);}
		void etcomOpen(EtbBus etb, int axis, dword flags) {DsaBase::etcomOpen(etb, axis, flags);}
		void reset() {DsaBase::reset();}
		void close() {DsaBase::close();}
		EtbBus  getEtbBus() {return DsaBase::getEtbBus();}
		int  etcomGetEtbAxis() {return DsaBase::etcomGetEtbAxis();}
		bool  isOpen() {return DsaBase::isOpen();}
		int getMotorTyp() {return DsaBase::getMotorTyp();}
		void getErrorText(char_p text, int size, int code) {DsaBase::getErrorText(text, size, code);}
		void getWarningText(char_p text, int size, int code) {DsaBase::getWarningText(text, size, code);}
		double  convertToIso(long inc, int conv) {return DsaBase::convertToIso(inc, conv);}
		double  convertInt32ToIso(long inc, int conv) {return DsaBase::convertInt32ToIso(inc, conv);}
		double  convertInt64ToIso(eint64 inc, int conv) {return DsaBase::convertInt64ToIso(inc, conv);}
		double  convertFloat32ToIso(float inc, int conv) {return DsaBase::convertFloat32ToIso(inc, conv);}
		double  convertFloat64ToIso(double inc, int conv) {return DsaBase::convertFloat64ToIso(inc, conv);}
		long  convertFromIso(double iso, int conv) {return DsaBase::convertFromIso(iso, conv);}
		long  convertInt32FromIso(double iso, int conv) {return DsaBase::convertInt32FromIso(iso, conv);}
		eint64  convertInt64FromIso(double iso, int conv) {return DsaBase::convertInt64FromIso(iso, conv);}
		float  convertFloat32FromIso(double iso, int conv) {return DsaBase::convertFloat32FromIso(iso, conv);}
		double  convertFloat64FromIso(double iso, int conv) {return DsaBase::convertFloat64FromIso(iso, conv);}
		double getIncToIsoFactor(int conv) {return DsaBase::getIncToIsoFactor(conv);}

		void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
		void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
		DsaInfo  getInfo() {return DsaBase::getInfo();}
		DsaStatus  getStatus() {return DsaBase::getStatus();}
		void cancelStatusWait() {DsaBase::cancelStatusWait();}
		DsaStatus  getStatusFromDrive(long timeout = DEF_TIMEOUT) {return DsaBase::getStatusFromDrive(timeout);}
		void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
		double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
		double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}
		DsaXInfo  getXInfo() {return DsaBase::getXInfo();}

		/* commands */
		void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
		void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
		void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
		void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
		void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
		void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
	    int getFamily() {return DsaBase::getFamily();}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
		void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
		void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
		void startUploadTrace(int traceTyp, int traceIdx, int startIdx, int endIdx, int stepIdx, bool fast, long timeout = DEF_TIMEOUT) {DsaBase::startUploadTrace(traceTyp, traceIdx, startIdx, endIdx, stepIdx, fast, timeout);}
		void startUploadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startUploadSequence(timeout);}
		void startUploadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startUploadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void uploadData(void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::uploadData(data, size, timeout);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
		void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

		void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
		void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
		void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
		void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
		void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
		void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}

		void startRTVHandler(int nr, int rate, DsaRTVHandler handler, int nbRead, DsaRTVData *readRTV[], int nbWrite, DsaRTVData *writeRTV[], void *param = NULL) {
			int i;
			if ((nbRead < 0) || (nbRead > 64) || (nbWrite < 0) || (nbWrite > 64))
				ERRCHK(DSA_EBADPARAM);
			for (i = 0; i < nbRead; i++)
				readTable[i] = readRTV[i]->getRTVDataStructure();
			for (i = 0; i < nbWrite; i++)
				writeTable[i] = writeRTV[i]->getRTVDataStructure();
			ERRCHK(dsa_start_rtv_handler(DsaBase::dsa, nr, rate, *(DSA_RTV_HANDLER*)&handler, nbRead, readTable, nbWrite, writeTable, param));
		}
		void startDelayedRTVHandler(int nr, int rate, int delay, DsaRTVHandler handler, int nbRead, DsaRTVData *readRTV[], int nbWrite, DsaRTVData *writeRTV[], void *param = NULL) {
			int i;
			if ((nbRead < 0) || (nbRead > 64) || (nbWrite < 0) || (nbWrite > 64))
				ERRCHK(DSA_EBADPARAM);
			for (i = 0; i < nbRead; i++)
				readTable[i] = readRTV[i]->getRTVDataStructure();
			for (i = 0; i < nbWrite; i++)
				writeTable[i] = writeRTV[i]->getRTVDataStructure();
			ERRCHK(dsa_start_delayed_rtv_handler(DsaBase::dsa, nr, rate, delay, *(DSA_RTV_HANDLER*)&handler, nbRead, readTable, nbWrite, writeTable, param));
		}
		void stopRTVHandler(int nr) {
			ERRCHK(dsa_stop_rtv_handler(DsaBase::dsa, nr));
		}
		bool isRTVHandlerActive(int nr) {
			bool active;
			ERRCHK(dsa_get_rtv_handler_activity(DsaBase::dsa, nr, &active));
			return active;
		}
		void setWatchdog(double ms) {
			ERRCHK(dsa_set_watchdog(DsaBase::dsa, ms));
		}		
		/*
		 * IO management - synchronous 
		 */
		//ExternalIO Management functions
		void externalIOSetEnableCyclicUpdate(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetEnableCyclicUpdate(enable, timeout);}
		void externalIOResetClientCommunication(long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetClientCommunication(timeout);}
		void externalIOResetIOCycleCount(long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetIOCycleCount(timeout);}
		void externalIOResetMaxUpdateTime(long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetMaxUpdateTime(timeout);}

		//ExternalIO Watchdog functions
		void externalIOEnableWatchdog(long timeout = DEF_TIMEOUT) {DsaBase::externalIOEnableWatchdog(timeout);}
		void externalIODisableWatchdog(long timeout = DEF_TIMEOUT) {DsaBase::externalIODisableWatchdog(timeout);}
		void externalIOStopWatchdog(long timeout = DEF_TIMEOUT) {DsaBase::externalIOStopWatchdog(timeout);}
		void externalIOSetWatchdogTime(int value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetWatchdogTime(timeout);}

		//ExternalIO digital output functions
		void externalIOSetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetDigitalOutput(outputIdx, timeout);}
		void externalIOResetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetDigitalOutput(outputIdx, timeout);}
		void externalIOApplyMaskDigitalOutput(int firstOutputIdx, int numberBits, dword value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOApplyMaskDigitalOutput(firstOutputIdx, numberBits, value, timeout);}
		dword externalIOGetDigitalOutput(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetDigitalOutput(outputIdx, fast, timeout);}
		dword externalIOGetDigitalOutputState(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetDigitalOutputState(outputIdx, fast, timeout);}
		dword externalIOGetMaskedDigitalOutput(int firstOutputIdx, int numberBits, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetMaskedDigitalOutput(firstOutputIdx, numberBits, fast, timeout);}
		dword externalIOGetMaskedDigitalOutputState(int firstOutputIdx, int numberBits, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetMaskedDigitalOutputState(firstOutputIdx, numberBits, fast, timeout);}

		//ExternalIO analog output functions
		void externalIOSetAnalogOutputRawData(int outputIdx, dword value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetAnalogOutputRawData(outputIdx, value, timeout);}
		void externalIOSetAnalogOutputConvertedData(int outputIdx, float value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetAnalogOutputConvertedData(outputIdx, value, timeout);};
		dword externalIOGetAnalogOutputRawData(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetAnalogOutputRawData(outputIdx, fast, timeout);}
		dword externalIOGetAnalogOutputRawDataState(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetAnalogOutputRawDataState(outputIdx, fast, timeout);}
		float externalIOGetAnalogOutputConvertedData(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetAnalogOutputConvertedData(outputIdx, fast, timeout);}
		float externalIOGetAnalogOutputConvertedDataState(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetAnalogOutputConvertedDataState(outputIdx, fast, timeout);}

		//ExternalIO digital input functions
		dword externalIOGetDigitalInputState(int inputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetDigitalInputState(inputIdx, fast, timeout);}
		dword externalIOGetMaskedDigitalInputState(int firstinputIdx, int numberBits, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetMaskedDigitalInputState(firstinputIdx, numberBits, fast, timeout);}

		//ExternalIO analog input functions
		dword externalIOGetAnalogInputRawDataState(int inputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetAnalogInputRawDataState(inputIdx, fast, timeout);}
		float externalIOGetAnalogInputConvertedDataState(int inputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetAnalogInputConvertedDataState(inputIdx, fast, timeout);}

		//ExternalIO direct modbus functions
		void externalIOSetModbusRegister(int registerAddress, dword value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetModbusRegister(registerAddress, value, timeout);}
		dword externalIOGetModbusRegister(int registerAddress, int wordCount, int wordNumber, long timeout = DEF_TIMEOUT) {return DsaBase::externalIOGetModbusRegister(registerAddress, wordCount, wordNumber, timeout);}

		//LocalIO digital output functions
		void localIOSetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::localIOSetDigitalOutput(outputIdx, timeout);}
		void localIOResetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::localIOResetDigitalOutput(outputIdx, timeout);}
		void localIOApplyMaskDigitalOutput(int firstOutputIdx, int numberBits, dword value, long timeout = DEF_TIMEOUT) {DsaBase::localIOApplyMaskDigitalOutput(firstOutputIdx, numberBits, value, timeout);}
		dword localIOGetDigitalOutput(int outputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::localIOGetDigitalOutput(outputIdx, fast, timeout);}
		dword localIOGetMaskedDigitalOutput(int firstOutputIdx, int numberBits, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::localIOGetMaskedDigitalOutput(firstOutputIdx, numberBits, fast, timeout);}

		//LocalIO digital input functions
		dword localIOGetDigitalInputState(int inputIdx, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::localIOGetDigitalInputState(inputIdx, fast, timeout);}
		dword localIOGetMaskedDigitalInputState(int firstinputIdx, int numberBits, bool fast, long timeout = DEF_TIMEOUT) {return DsaBase::localIOGetMaskedDigitalInputState(firstinputIdx, numberBits, fast, timeout);}
};


/*------------------------------------------------------------------------------
 * DsaMasterGroup class - C++
 *-----------------------------------------------------------------------------*/
class DsaMasterGroup: public DsaBase {
    /* constructors */
	private:
		void _Group(int max, ...) {
			va_list arg;
			va_start(arg, max);
			ERRCHK(dsa_create_master_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
			va_end(arg);
		}
	protected:
		DsaMasterGroup(void) {
		}
	public:
		DsaMasterGroup(DSA_MASTER_GROUP *dev) {
			if (!dsa_is_valid_master_group(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaMasterGroup(DsaMasterGroup &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaMasterGroup(DsaBase &obj) {
			if (!dsa_is_valid_master_group(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaMasterGroup(int max, ...) {
			va_list arg;
			va_start(arg, max);
			ERRCHK(dsa_create_master_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
			va_end(arg);
		}
		DsaMasterGroup(int max, DsaDriveBase *list[]) {
			ERRCHK(dsa_create_master_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, list[i]->dsa));
		}
		DsaMasterGroup(DsaDriveBase d1, DsaDriveBase d2) {
			_Group(2, &d1, &d2);
		}
		DsaMasterGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3) {
			_Group(3, &d1, &d2, &d3);
		}
		DsaMasterGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4) {
			_Group(4, &d1, &d2, &d3, &d4);
		}
		DsaMasterGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5) {
			_Group(5, &d1, &d2, &d3, &d4, &d5);
		}
		DsaMasterGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6) {
			_Group(6, &d1, &d2, &d3, &d4, &d5, &d6);
		}
		DsaMasterGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7) {
			_Group(7, &d1, &d2, &d3, &d4, &d5, &d6, &d7);
		}
		DsaMasterGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7, DsaDriveBase d8) {
			_Group(8, &d1, &d2, &d3, &d4, &d5, &d6, &d7, &d8);
		}
	public:
	    /* operators */
		DsaMasterGroup operator = (DsaMasterGroup &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaMasterGroup operator = (DsaBase &obj) {
			if (!dsa_is_valid_master_group(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		/* functions */
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

		void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
		void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
		int  getGroupSize() {return DsaBase::getGroupSize();}
		void cancelStatusWait() {DsaBase::cancelStatusWait();}
		void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}

		/* commands */
		void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
		void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
		void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
		void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
		void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
		void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
	    int getFamily() {return DsaBase::getFamily();}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
		void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
		void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
		void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

		void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
		void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
		void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
		void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
		void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
		void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}
		/*
		 * IO management - synchronous
		 */
		//ExternalIO Management functions
		void externalIOSetEnableCyclicUpdate(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetEnableCyclicUpdate(enable, timeout);}
		void externalIOResetClientCommunication(long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetClientCommunication(timeout);}
		void externalIOResetIOCycleCount(long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetIOCycleCount(timeout);}
		void externalIOResetMaxUpdateTime(long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetMaxUpdateTime(timeout);}

		//ExternalIO Watchdog functions
		void externalIOEnableWatchdog(long timeout = DEF_TIMEOUT) {DsaBase::externalIOEnableWatchdog(timeout);}
		void externalIODisableWatchdog(long timeout = DEF_TIMEOUT) {DsaBase::externalIODisableWatchdog(timeout);}
		void externalIOStopWatchdog(long timeout = DEF_TIMEOUT) {DsaBase::externalIOStopWatchdog(timeout);}
		void externalIOSetWatchdogTime(int value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetWatchdogTime(timeout);}

		//ExternalIO digital output functions
		void externalIOSetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetDigitalOutput(outputIdx, timeout);}
		void externalIOResetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::externalIOResetDigitalOutput(outputIdx, timeout);}
		void externalIOApplyMaskDigitalOutput(int firstOutputIdx, int numberBits, dword value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOApplyMaskDigitalOutput(firstOutputIdx, numberBits, value, timeout);}

		//ExternalIO analog output functions
		void externalIOSetAnalogOutputRawData(int outputIdx, dword value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetAnalogOutputRawData(outputIdx, value, timeout);}
		void externalIOSetAnalogOutputConvertedData(int outputIdx, float value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetAnalogOutputConvertedData(outputIdx, value, timeout);};

		//ExternalIO digital input functions
		//ExternalIO analog input functions
		//ExternalIO direct modbus functions
		void externalIOSetModbusRegister(int registerAddress, dword value, long timeout = DEF_TIMEOUT) {DsaBase::externalIOSetModbusRegister(registerAddress, value, timeout);}

		//LocalIO digital output functions
		void localIOSetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::localIOSetDigitalOutput(outputIdx, timeout);}
		void localIOResetDigitalOutput(int outputIdx, long timeout = DEF_TIMEOUT) {DsaBase::localIOResetDigitalOutput(outputIdx, timeout);}

		//LocalIO digital input functions
};


/*------------------------------------------------------------------------------
 * DsaIpolGroup class - C++
 *-----------------------------------------------------------------------------*/
class DsaIpolGroup: public DsaBase {
    /* constructors */
	private:
		void _Group(int max, ...) {
			va_list arg;
			va_start(arg, max);
			ERRCHK(dsa_create_ipol_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
			va_end(arg);
		}
	protected:
		DsaIpolGroup(void) {
		}
	public:
		DsaIpolGroup(DSA_IPOL_GROUP *dev) {
			if (!dsa_is_valid_ipol_group(dev))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(dev));
			dsa = dev;
		}
		DsaIpolGroup(DsaIpolGroup &obj) {
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaIpolGroup(DsaBase &obj) {
			if (!dsa_is_valid_ipol_group(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			dsa = obj.dsa;
		}
		DsaIpolGroup(int max, ...) {
			va_list arg;
			va_start(arg, max);
			ERRCHK(dsa_create_ipol_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
			va_end(arg);
		}
		DsaIpolGroup(int max, DsaDriveBase *list[]) {
			ERRCHK(dsa_create_ipol_group(&dsa, max));
			for(int i = 0; i < max; i++)
				ERRCHK(dsa_set_group_item(dsa, i, list[i]->dsa));
		}
		DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2) {
			_Group(2, &d1, &d2);
		}
		DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3) {
			_Group(3, &d1, &d2, &d3);
		}
		DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4) {
			_Group(4, &d1, &d2, &d3, &d4);
		}
		DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5) {
			_Group(5, &d1, &d2, &d3, &d4, &d5);
		}
		DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6) {
			_Group(6, &d1, &d2, &d3, &d4, &d5, &d6);
		}
		DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7) {
			_Group(7, &d1, &d2, &d3, &d4, &d5, &d6, &d7);
		}
		DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7, DsaDriveBase d8) {
			_Group(8, &d1, &d2, &d3, &d4, &d5, &d6, &d7, &d8);
		}
	public:
		/* operators */
		DsaIpolGroup operator = (DsaIpolGroup &obj) {
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
		DsaIpolGroup operator = (DsaBase &obj) {
			if (!dsa_is_valid_ipol_group(obj.dsa))
				throw DsaException(DSA_EBADPARAM);
			ERRCHK(dsa_share(obj.dsa));
			ERRCHK(dsa_destroy(&dsa));
			dsa = obj.dsa;
			return *this;
		}
    /* functions */
	public:
		DsaDriveBase getGroupItem(int pos) {return DsaBase::getGroupItem(pos);}
		DsaMaster getMaster(void) {return DsaBase::getMaster();}
		void setMaster(DsaMaster master) {DsaBase::setMaster(master);}
		void powerOn(long timeout = DEF_TIMEOUT) {DsaBase::powerOn(timeout);}
		void powerOff(long timeout = DEF_TIMEOUT) {DsaBase::powerOff(timeout);}
		void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::newSetpoint(sidx, flags, timeout);}
		void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::changeSetpoint(sidx, flags, timeout);}
		void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
		void homingStart(long timeout = DEF_TIMEOUT) {DsaBase::homingStart(timeout);}
		void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
		void startProfiledMovement(double pos, double speed, double acc, long timeout = DEF_TIMEOUT) {DsaBase::startProfiledMovement(pos, speed, acc, timeout);}
		void startRelativeProfiledMovement(double relativePos, long timeout = DEF_TIMEOUT) {DsaBase::startRelativeProfiledMovement(relativePos, timeout);}
		void stageMappingDownload(const char *fileName) {DsaBase::stageMappingDownload(fileName);}
		void stageMappingUpload(const char *fileName) {DsaBase::stageMappingUpload(fileName);}
		void stageMappingActivate() {DsaBase::stageMappingActivate();}
		void stageMappingDeactivate() {DsaBase::stageMappingDeactivate();}
		bool stageMappingIsActivated() {return DsaBase::stageMappingIsActivated();}

		void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt32(typ, idx, sidx, val, timeout);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterInt64(typ, idx, sidx, val, timeout);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, timeout);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, long timeout = DEF_TIMEOUT) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, timeout);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, timeout);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, timeout);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
		void ipolBegin(long timeout = DEF_TIMEOUT) {DsaBase::ipolBegin(timeout);}
		void ipolEnd(long timeout = DEF_TIMEOUT) {DsaBase::ipolEnd(timeout);}
		void ipolBeginConcatenation(long timeout = DEF_TIMEOUT) {DsaBase::ipolBeginConcatenation(timeout);}
		void ipolEndConcatenation(long timeout = DEF_TIMEOUT) {DsaBase::ipolEndConcatenation(timeout);}
		void ipolLine(DsaVector *dest, long timeout = DEF_TIMEOUT) {DsaBase::ipolLine(dest, timeout);}
		void ipolCircleCWR2d(double x, double y, double r, long timeout = DEF_TIMEOUT) {DsaBase::ipolCircleCWR2d(x, y, r, timeout);}
		void ipolCircleCcwR2d(double x, double y, double r, long timeout = DEF_TIMEOUT) {DsaBase::ipolCircleCcwR2d(x, y, r, timeout);}
		void ipolTanVelocity(double velocity, long timeout = DEF_TIMEOUT) {DsaBase::ipolTanVelocity(velocity, timeout);}
		void ipolTanAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::ipolTanAcceleration(acc, timeout);}
		void ipolTanDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::ipolTanDeceleration(dec, timeout);}
		void ipolTanJerkTime(double jerk_time, long timeout = DEF_TIMEOUT) {DsaBase::ipolTanJerkTime(jerk_time, timeout);}
		void ipolQuickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::ipolQuickStop(mode, flags, timeout);}
		void ipolContinue(long timeout = DEF_TIMEOUT) {DsaBase::ipolContinue(timeout);}
		void ipolPvt(DsaVector *dest, DsaVector *velocity, double time, long timeout = DEF_TIMEOUT) {DsaBase::ipolPvt(dest, velocity, time, timeout);}
		void ipolMark(long number, long operation, long op_param, long timeout = DEF_TIMEOUT) {DsaBase::ipolMark(number, operation, op_param, timeout);}
		void ipolMark2Param(long number, long operation, long op_param1, long op_param2, long timeout = DEF_TIMEOUT) {DsaBase::ipolMark2Param(number, operation, op_param1, op_param2, timeout);}
		void ipolSetVelocityRate(double rate, long timeout = DEF_TIMEOUT) {DsaBase::ipolSetVelocityRate(rate, timeout);}
		void ipolCircleCWC2d(double x, double y, double cx, double cy, long timeout = DEF_TIMEOUT) {DsaBase::ipolCircleCWC2d(x, y, cx, cy, timeout);}
		void ipolCircleCcwC2d(double x, double y, double cx, double cy, long timeout = DEF_TIMEOUT) {DsaBase::ipolCircleCcwC2d(x, y, cx, cy, timeout);}
		void ipolLine(double x, double y, long timeout = DEF_TIMEOUT) {DsaBase::ipolLine(x, y, timeout);}
		void ipolWaitMovement(long timeout = DEF_TIMEOUT) {DsaBase::ipolWaitMovement(timeout);}
		void ipolPrepare(long timeout = DEF_TIMEOUT) {DsaBase::ipolPrepare(timeout);}
		void ipolPvtUpdate(int depth, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::ipolPvtUpdate(depth, mask, timeout);}
		void ipolPvtRegTyp(DsaVector *dest, DsaVectorTyp destTyp, DsaVector *velocity, DsaVectorTyp velocityTyp, double time, int timeTyp, long timeout = DEF_TIMEOUT) {DsaBase::ipolPvtRegTyp(dest, destTyp, velocity, velocityTyp, time, timeTyp, timeout);}
		void ipolSetLktSpeedRatio(double value, long timeout = DEF_TIMEOUT) {DsaBase::ipolSetLktSpeedRatio(value, timeout);}
		void ipolSetLktCyclicMode(bool active, long timeout = DEF_TIMEOUT) {DsaBase::ipolSetLktCyclicMode(active, timeout);}
		void ipolSetLktRelativeMode(bool active, long timeout = DEF_TIMEOUT) {DsaBase::ipolSetLktRelativeMode(active, timeout);}
		void ipolLkt(DsaVector *dest, DsaIntVector *lkt_number, double time, long timeout = DEF_TIMEOUT) {DsaBase::ipolLkt(dest, lkt_number, time, timeout);}
		void ipolWaitMark(int mark, long timeout = DEF_TIMEOUT) {DsaBase::ipolWaitMark(mark, timeout);}
		void ipolUline(DsaVector *dest, long timeout = DEF_TIMEOUT) {DsaBase::ipolUline(dest, timeout);}
		void ipolUline(double x, double y, long timeout = DEF_TIMEOUT) {DsaBase::ipolUline(x, y, timeout);}
		void ipolDisableUconcatenation(long timeout = DEF_TIMEOUT) {DsaBase::ipolDisableUconcatenation(timeout);}
		void ipolSetUrelativeMode(bool active, long timeout = DEF_TIMEOUT) {DsaBase::ipolSetUrelativeMode(active, timeout);}
		void ipolUspeedAxisMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::ipolUspeedAxisMask(mask, timeout);}
		void ipolUspeed(double speed, long timeout = DEF_TIMEOUT) {DsaBase::ipolUspeed(speed, timeout);}
		void ipolUtime(double acc_time, double jerk_time, long timeout = DEF_TIMEOUT) {DsaBase::ipolUtime(acc_time, jerk_time, timeout);}
		void ipolTranslateMatrix(DsaVector *trans, long timeout = DEF_TIMEOUT) {DsaBase::ipolTranslateMatrix(trans, timeout);}
		void ipolScaleMatrix(DsaVector *scale, long timeout = DEF_TIMEOUT) {DsaBase::ipolScaleMatrix(scale, timeout);}
		void ipolRotateMatrix(int plan, double degree, long timeout = DEF_TIMEOUT) {DsaBase::ipolRotateMatrix(plan, degree, timeout);}
		void ipolTranslateMatrix(double x, double y, long timeout = DEF_TIMEOUT) {DsaBase::ipolTranslateMatrix(x, y, timeout);}
		void ipolScaleMatrix(double x, double y, long timeout = DEF_TIMEOUT) {DsaBase::ipolScaleMatrix(x, y, timeout);}
		void ipolShearMatrix(int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, long timeout = DEF_TIMEOUT) {DsaBase::ipolShearMatrix(sheared_axis, axis1_shearing, axis2_shearing, axis3_shearing, timeout);}
		void ipolLock(long timeout = DEF_TIMEOUT) {DsaBase::ipolLock(timeout);}
		void ipolUnlock(long timeout = DEF_TIMEOUT) {DsaBase::ipolUnlock(timeout);}
		int ipolGetIpolGroup() {return DsaBase::ipolGetIpolGroup();}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
		void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
		void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

		void powerOn(DsaHandler handler, void *param = NULL) {DsaBase::powerOn(handler, param);}
		void powerOff(DsaHandler handler, void *param = NULL) {DsaBase::powerOff(handler, param);}
		void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::newSetpoint(sidx, flags, handler, param);}
		void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::changeSetpoint(sidx, flags, handler, param);}
		void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
		void homingStart(DsaHandler handler, void *param = NULL) {DsaBase::homingStart(handler, param);}
		void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
		void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
		void startProfiledMovement(double pos, double speed, double acc, DsaHandler handler, void *param = NULL) {DsaBase::startProfiledMovement(pos, speed, acc, handler, param);}
		void startRelativeProfiledMovement(double relativePos, DsaHandler handler, void *param = NULL) {DsaBase::startRelativeProfiledMovement(relativePos, handler, param);}

		void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
		void setRegisterInt32(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt32(typ, idx, sidx, val, handler, param);}
		void setRegisterInt64(int typ, unsigned idx, int sidx, eint64 val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterInt64(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat32(int typ, unsigned idx, int sidx, float val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat32(typ, idx, sidx, val, handler, param);}
		void setRegisterFloat64(int typ, unsigned idx, int sidx, double val, DsaHandler handler, void *param = NULL) {DsaBase::setRegisterFloat64(typ, idx, sidx, val, handler, param);}
		void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt32(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayInt64(int typ, unsigned idx, unsigned nidx, int sidx, eint64 *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayInt64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat32(int typ, unsigned idx, unsigned nidx, int sidx, float *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat32(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setArrayFloat64(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArrayFloat64(typ, idx, nidx, sidx, val, offset, handler, param);}
		void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
		void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
		void ipolBegin(DsaHandler handler, void *param = NULL) {DsaBase::ipolBegin(handler, param);}
		void ipolEnd(DsaHandler handler, void *param = NULL) {DsaBase::ipolEnd(handler, param);}
		void ipolBeginConcatenation(DsaHandler handler, void *param = NULL) {DsaBase::ipolBeginConcatenation(handler, param);}
		void ipolEndConcatenation(DsaHandler handler, void *param = NULL) {DsaBase::ipolEndConcatenation(handler, param);}
		void ipolLine(DsaVector *dest, DsaHandler handler, void *param = NULL) {DsaBase::ipolLine(dest, handler, param);}
		void ipolCircleCWR2d(double x, double y, double r, DsaHandler handler, void *param = NULL) {DsaBase::ipolCircleCWR2d(x, y, r, handler, param);}
		void ipolCircleCcwR2d(double x, double y, double r, DsaHandler handler, void *param = NULL) {DsaBase::ipolCircleCcwR2d(x, y, r, handler, param);}
		void ipolTanVelocity(double velocity, DsaHandler handler, void *param = NULL) {DsaBase::ipolTanVelocity(velocity, handler, param);}
		void ipolTanAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::ipolTanAcceleration(acc, handler, param);}
		void ipolTanDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::ipolTanDeceleration(dec, handler, param);}
		void ipolTanJerkTime(double jerk_time, DsaHandler handler, void *param = NULL) {DsaBase::ipolTanJerkTime(jerk_time, handler, param);}
		void ipolQuickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::ipolQuickStop(mode, flags, handler, param);}
		void ipolContinue(DsaHandler handler, void *param = NULL) {DsaBase::ipolContinue(handler, param);}
		void ipolPvt(DsaVector *dest, DsaVector *velocity, double time, DsaHandler handler, void *param = NULL) {DsaBase::ipolPvt(dest, velocity, time, handler, param);}
		void ipolMark(long number, long operation, long op_param, DsaHandler handler, void *param = NULL) {DsaBase::ipolMark(number, operation, op_param, handler, param);}
		void ipolMark2Param(long number, long operation, long op_param1, long op_param2, DsaHandler handler, void *param = NULL) {DsaBase::ipolMark2Param(number, operation, op_param1, op_param2, handler, param);}
		void ipolSetVelocityRate(double rate, DsaHandler handler, void *param = NULL) {DsaBase::ipolSetVelocityRate(rate, handler, param);}
		void ipolCircleCWC2d(double x, double y, double cx, double cy, DsaHandler handler, void *param = NULL) {DsaBase::ipolCircleCWC2d(x, y, cx, cy, handler, param);}
		void ipolCircleCcwC2d(double x, double y, double cx, double cy, DsaHandler handler, void *param = NULL) {DsaBase::ipolCircleCcwC2d(x, y, cx, cy, handler, param);}
		void ipolLine(double x, double y, DsaHandler handler, void *param = NULL) {DsaBase::ipolLine(x, y, handler, param);}
		void ipolWaitMovement(DsaHandler handler, void *param = NULL) {DsaBase::ipolWaitMovement(handler, param);}
		void ipolPrepare(DsaHandler handler, void *param = NULL) {DsaBase::ipolPrepare(handler, param);}
		void ipolPvtUpdate(int depth, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::ipolPvtUpdate(depth, mask, handler, param);}
		void ipolPvtRegTyp(DsaVector *dest, DsaVectorTyp destTyp, DsaVector *velocity, DsaVectorTyp velocityTyp, double time, int timeTyp, DsaHandler handler, void *param = NULL) {DsaBase::ipolPvtRegTyp(dest, destTyp, velocity, velocityTyp, time, timeTyp, handler, param);}
		void ipolSetLktSpeedRatio(double value, DsaHandler handler, void *param = NULL) {DsaBase::ipolSetLktSpeedRatio(value, handler, param);}
		void ipolSetLktCyclicMode(bool active, DsaHandler handler, void *param = NULL) {DsaBase::ipolSetLktCyclicMode(active, handler, param);}
		void ipolSetLktRelativeMode(bool active, DsaHandler handler, void *param = NULL) {DsaBase::ipolSetLktRelativeMode(active, handler, param);}
		void ipolLkt(DsaVector *dest, DsaIntVector *lkt_number, double time, DsaHandler handler, void *param = NULL) {DsaBase::ipolLkt(dest, lkt_number, time, handler, param);}
		void ipolWaitMark(int mark, DsaHandler handler, void *param = NULL) {DsaBase::ipolWaitMark(mark, handler, param);}
		void ipolUline(DsaVector *dest, DsaHandler handler, void *param = NULL) {DsaBase::ipolUline(dest, handler, param);}
		void ipolUline(double x, double y, DsaHandler handler, void *param = NULL) {DsaBase::ipolUline(x, y, handler, param);}
		void ipolDisableUconcatenation(DsaHandler handler, void *param = NULL) {DsaBase::ipolDisableUconcatenation(handler, param);}
		void ipolSetUrelativeMode(bool active, DsaHandler handler, void *param = NULL) {DsaBase::ipolSetUrelativeMode(active, handler, param);}
		void ipolUspeedAxisMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::ipolUspeedAxisMask(mask, handler, param);}
		void ipolUspeed(double speed, DsaHandler handler, void *param = NULL) {DsaBase::ipolUspeed(speed, handler, param);}
		void ipolUtime(double acc_time, double jerk_time, DsaHandler handler, void *param = NULL) {DsaBase::ipolUtime(acc_time, jerk_time, handler, param);}
		void ipolTranslateMatrix(DsaVector *trans, DsaHandler handler, void *param = NULL) {DsaBase::ipolTranslateMatrix(trans, handler, param);}
		void ipolScaleMatrix(DsaVector *scale, DsaHandler handler, void *param = NULL) {DsaBase::ipolScaleMatrix(scale, handler, param);}
		void ipolRotateMatrix(int plan, double degree, DsaHandler handler, void *param = NULL) {DsaBase::ipolRotateMatrix(plan, degree, handler, param);}
		void ipolTranslateMatrix(double x, double y, DsaHandler handler, void *param = NULL) {DsaBase::ipolTranslateMatrix(x, y, handler, param);}
		void ipolScaleMatrix(double x, double y, DsaHandler handler, void *param = NULL) {DsaBase::ipolScaleMatrix(x, y, handler, param);}
		void ipolShearMatrix(int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, DsaHandler handler, void *param = NULL) {DsaBase::ipolShearMatrix(sheared_axis, axis1_shearing, axis2_shearing, axis3_shearing, handler, param);}
		void ipolLock(DsaHandler handler, void *param = NULL) {DsaBase::ipolLock(handler, param);}
		void ipolUnlock(DsaHandler handler, void *param = NULL) {DsaBase::ipolUnlock(handler, param);}
		void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
		void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
		void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
		void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
		void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
		void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

		void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
		void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
		void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
		int  getGroupSize() {return DsaBase::getGroupSize();}
		bool isIpolINProgress() {return DsaBase::isIpolINProgress();}
		void cancelStatusWait() {DsaBase::cancelStatusWait();}
		void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
		void commitAsyncTrans(DsaHandler handler, void *param = NULL) {DsaBase::commitAsyncTrans(handler, param);}

		/* commands */
		void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
		void stepMotion(double pos, long timeout = DEF_TIMEOUT) {DsaBase::stepMotion(pos, timeout);}
		void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
		void executeSequenceInThread(int label, int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::executeSequenceInThread(label, threadNr, timeout);}
		void stopSequenceInThread(int threadNr, long timeout = DEF_TIMEOUT) {DsaBase::stopSequenceInThread(threadNr, timeout);}
		void stopSequence(long timeout = DEF_TIMEOUT) {DsaBase::stopSequence(timeout);}
		void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
		void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
		void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
		void setParametersVersion(int what, int version, long timeout = DEF_TIMEOUT) {DsaBase::setParametersVersion(what, version, timeout);}
		void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
		void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
		void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
		void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitSet(typ, idx, sidx, mask, timeout);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::waitBitClear(typ, idx, sidx, mask, timeout);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, timeout);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, long timeout = DEF_TIMEOUT) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, timeout);}
	    int getFamily() {return DsaBase::getFamily();}
		void startDownloadSequence(long timeout = DEF_TIMEOUT) {DsaBase::startDownloadSequence(timeout);}
		void startDownloadRegister(int typ, int startIdx, int endIdx, int sidx, long timeout = DEF_TIMEOUT) {DsaBase::startDownloadRegister(typ, startIdx, endIdx, sidx, timeout);}
		void downloadData(const void *data, int size, long timeout = DEF_TIMEOUT) {DsaBase::downloadData(data, size, timeout);}
		void downloadCompiledSequenceFile(char *fileName) {DsaBase::downloadCompiledSequenceFile(fileName);}
		void setSequenceVersion(char *fileName) {DsaBase::setSequenceVersion(fileName);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, timeout);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, timeout);}
		void debugSequenceContinue(long timeout = DEF_TIMEOUT)  {DsaBase::debugSequenceContinue(timeout);}

		void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
		void stepMotion(double pos, DsaHandler handler, void *param = NULL) {DsaBase::stepMotion(pos, handler, param);}
		void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
		void executeSequenceInThread(int label, int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::executeSequenceInThread(label, threadNr, handler, param);}
		void stopSequenceInThread(int threadNr, DsaHandler handler, void *param = NULL) {DsaBase::stopSequenceInThread(threadNr, handler, param);}
		void stopSequence(DsaHandler handler, void *param = NULL) {DsaBase::stopSequence(handler, param);}
		void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
		void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
		void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
		void setParametersVersion(int what, int version, DsaHandler handler, void *param = NULL) {DsaBase::setParametersVersion(what, version, handler, param);}
		void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
		void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
		void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
		void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}
		void waitBitSet(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitSet(typ, idx, sidx, mask, handler, param);}
		void waitBitClear(int typ, int idx, int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::waitBitClear(typ, idx, sidx, mask, handler, param);}
		void waitSgnRegisterGreater(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterGreater(typ, idx, sidx, value, handler, param);}
		void waitSgnRegisterLower(int typ, int idx, int sidx, double value, DsaHandler handler, void *param = NULL) {DsaBase::waitSgnRegisterLower(typ, idx, sidx, value, handler, param);}
		void debugSequenceEnableBreakpointAt(int codeOffset, bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointAt(codeOffset, enable, handler, param);}
		void debugSequenceEnableBreakpointEverywhere(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceEnableBreakpointEverywhere(enable, handler, param);}
		void debugSequenceContinue(DsaHandler handler, void *param = NULL) {DsaBase::debugSequenceContinue(handler, param);}

		/* register setters */
		void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLProportionalGain(gain, timeout);}
		void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedbackGain(gain, timeout);}
		void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorGain(gain, timeout);}
		void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLAntiWindupGain(gain, timeout);}
		void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorLimitation(limit, timeout);}
		void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorMode(mode, timeout);}
		void setTtlSpeedlFilter(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setTtlSpeedlFilter(factor, timeout);}
		void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLAccFeedforwardGain(factor, timeout);}
		void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxPositionRangeLimit(pos, timeout);}
		void startMovement(double *targets, long timeout = DEF_TIMEOUT) {DsaBase::startMovement(targets, timeout);}

		void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setFollowingErrorWindow(pos, timeout);}
		void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setVelocityErrorLimit(vel, timeout);}
		void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setSwitchLimitMode(mode, timeout);}
		void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setEnableInputMode(mode, timeout);}
		void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinSoftPositionLimit(pos, timeout);}
		void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxSoftPositionLimit(pos, timeout);}
		void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {DsaBase::setProfileLimitMode(flags, timeout);}
		void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindowTime(tim, timeout);}
		void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindow(win, timeout);}
		void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingMethod(mode, timeout);}
		void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setHomingZeroSpeed(vel, timeout);}
		void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setHomingAcceleration(acc, timeout);}
		void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFollowingLimit(win, timeout);}
		void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setHomingCurrentLimit(cur, timeout);}
		void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomeOffset(pos, timeout);}
		void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFixedMvt(pos, timeout);}
		void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingSwitchMvt(pos, timeout);}
		void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingIndexMvt(pos, timeout);}
		void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningMode(mode, timeout);}
		void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningValue(phase, timeout);}
		void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setMotorPhaseCorrection(mode, timeout);}
		void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setSoftwareCurrentLimit(cur, timeout);}
		void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDriveControlMode(mode, timeout);}
		void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDisplayMode(mode, timeout);}
		void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderInversion(invert, timeout);}
		void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Offset(offset, timeout);}
		void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Offset(offset, timeout);}
		void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Factor(factor, timeout);}
		void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Factor(factor, timeout);}
		void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderIndexDistance(pos, timeout);}
		void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLProportionalGain(gain, timeout);}
		void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLIntegratorGain(gain, timeout);}
		void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLCurrentLimit(cur, timeout);}
		void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tCurrentLimit(cur, timeout);}
		void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tTimeLimit(tim, timeout);}
		void setInitMode(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setInitMode(typ, timeout);}
		void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitPulseLevel(cur, timeout);}
		void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitMaxCurrent(cur, timeout);}
		void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitFinalPhase(cal, timeout);}
		void setInitTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setInitTime(tim, timeout);}
		void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitInitialPhase(cal, timeout);}
		void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceType(sidx, typ, timeout);}
		void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceIndex(sidx, index, timeout);}
		void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroStartTimeout(tim, timeout);}
		void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setDigitalOutput(out, timeout);}
		void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setXDigitalOutput(out, timeout);}
		void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput1(out, timeout);}
		void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput2(out, timeout);}
		void setXAnalogOutput3(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput3(out, timeout);}
		void setXAnalogOutput4(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput4(out, timeout);}
		void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {DsaBase::setAnalogOutput(out, timeout);}
		void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterIdx(idx, timeout);}
		void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {DsaBase::setConcatenatedMvt(concat, timeout);}
		void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setProfileType(sidx, typ, timeout);}
		void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktNumber(sidx, number, timeout);}
		void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktTime(sidx, time, timeout);}
		void setCameValue(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCameValue(factor, timeout);}
		void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::setBrakeDeceleration(dec, timeout);}
		void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTargetPosition(sidx, pos, timeout);}
		void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setProfileVelocity(sidx, vel, timeout);}
		void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {DsaBase::setProfileAcceleration(sidx, acc, timeout);}
		void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {DsaBase::setJerkTime(sidx, tim, timeout);}
		void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceType(typ, timeout);}
		void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceIndex(index, timeout);}
		void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlOffset(offset, timeout);}
		void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlGain(gain, timeout);}
		void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {DsaBase::setMotorKTFactor(kt, timeout);}

		void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLProportionalGain(gain, handler, param);}
		void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedbackGain(gain, handler, param);}
		void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLAntiWindupGain(gain, handler, param);}
		void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorLimitation(limit, handler, param);}
		void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorMode(mode, handler, param);}
		void setTtlSpeedlFilter(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setTtlSpeedlFilter(factor, handler, param);}
		void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLAccFeedforwardGain(factor, handler, param);}
		void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxPositionRangeLimit(pos, handler, param);}
		void startMovement(double *targets, DsaHandler handler, void *param = NULL) {DsaBase::startMovement(targets, handler, param);}

		void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setFollowingErrorWindow(pos, handler, param);}
		void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setVelocityErrorLimit(vel, handler, param);}
		void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setSwitchLimitMode(mode, handler, param);}
		void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setEnableInputMode(mode, handler, param);}
		void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinSoftPositionLimit(pos, handler, param);}
		void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxSoftPositionLimit(pos, handler, param);}
		void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {DsaBase::setProfileLimitMode(flags, handler, param);}
		void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindowTime(tim, handler, param);}
		void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindow(win, handler, param);}
		void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingMethod(mode, handler, param);}
		void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setHomingZeroSpeed(vel, handler, param);}
		void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setHomingAcceleration(acc, handler, param);}
		void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFollowingLimit(win, handler, param);}
		void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setHomingCurrentLimit(cur, handler, param);}
		void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomeOffset(pos, handler, param);}
		void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFixedMvt(pos, handler, param);}
		void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingSwitchMvt(pos, handler, param);}
		void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingIndexMvt(pos, handler, param);}
		void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningMode(mode, handler, param);}
		void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningValue(phase, handler, param);}
		void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setMotorPhaseCorrection(mode, handler, param);}
		void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setSoftwareCurrentLimit(cur, handler, param);}
		void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDriveControlMode(mode, handler, param);}
		void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDisplayMode(mode, handler, param);}
		void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderInversion(invert, handler, param);}
		void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Offset(offset, handler, param);}
		void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Offset(offset, handler, param);}
		void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Factor(factor, handler, param);}
		void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Factor(factor, handler, param);}
		void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderIndexDistance(pos, handler, param);}
		void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLProportionalGain(gain, handler, param);}
		void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLIntegratorGain(gain, handler, param);}
		void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLCurrentLimit(cur, handler, param);}
		void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tCurrentLimit(cur, handler, param);}
		void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tTimeLimit(tim, handler, param);}
		void setInitMode(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setInitMode(typ, handler, param);}
		void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitPulseLevel(cur, handler, param);}
		void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitMaxCurrent(cur, handler, param);}
		void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitFinalPhase(cal, handler, param);}
		void setInitTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setInitTime(tim, handler, param);}
		void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitInitialPhase(cal, handler, param);}
		void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceType(sidx, typ, handler, param);}
		void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceIndex(sidx, index, handler, param);}
		void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroStartTimeout(tim, handler, param);}
		void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setDigitalOutput(out, handler, param);}
		void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setXDigitalOutput(out, handler, param);}
		void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput1(out, handler, param);}
		void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput2(out, handler, param);}
		void setXAnalogOutput3(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput3(out, handler, param);}
		void setXAnalogOutput4(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput4(out, handler, param);}
		void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {DsaBase::setAnalogOutput(out, handler, param);}
		void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterIdx(idx, handler, param);}
		void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {DsaBase::setConcatenatedMvt(concat, handler, param);}
		void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setProfileType(sidx, typ, handler, param);}
		void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktNumber(sidx, number, handler, param);}
		void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktTime(sidx, time, handler, param);}
		void setCameValue(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCameValue(factor, handler, param);}
		void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::setBrakeDeceleration(dec, handler, param);}
		void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTargetPosition(sidx, pos, handler, param);}
		void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setProfileVelocity(sidx, vel, handler, param);}
		void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {DsaBase::setProfileAcceleration(sidx, acc, handler, param);}
		void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {DsaBase::setJerkTime(sidx, tim, handler, param);}
		void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceType(typ, handler, param);}
		void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceIndex(index, handler, param);}
		void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlOffset(offset, handler, param);}
		void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlGain(gain, handler, param);}
		void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {DsaBase::setMotorKTFactor(kt, handler, param);}
};


class DsaDsmax: public DsaMaster {
};

class DsaDsmaxGroup: public DsaMasterGroup {
};

/*------------------------------------------------------------------------------
 * DsaAcquisition class - C++
 *-----------------------------------------------------------------------------*/
class DsaAcquisition {
	protected:
		DSA_ACQUISITION *acq;
    /* constructors */
	public:
		DsaAcquisition(DsaDeviceBase dev) {
			acq = NULL;
			ERRCHK(dsa_create_acquisition(&acq, dev.getDsaStructure()));
		}
	public:
		~DsaAcquisition(void) {
			if (acq)
				ERRCHK(dsa_destroy_acquisition(&acq));
		}

	public:
		/*
		 * ACQUISITION TRIGGER mode
		 */
		enum {TRIG_IMMEDIATE = 0};          /* trig immediately */
		enum {TRIG_START_MOVE = 1};         /* trig on move start */
		enum {TRIG_END_MOVE = 2};           /* trig on move end */
		enum {TRIG_POSITION = 3};           /* trig on position level crossed */
		enum {TRIG_TRACE = 4};              /* trig on trace level crossed */
		enum {TRIG_EXTERNAL = 5};           /* external trig */
		enum {TRIG_REGISTER = 6};           /* trig on given value of register */
		enum {TRIG_BIT_FIELD_STATE = 7};    /* trig on bit field state */
		enum {TRIG_BIT_FIELD_EDGE = 8};     /* trig on bit field riging or falling edge */

		/*
		 * ACQUISITION SYNCHRO mode
		 */
		enum {SYNCRO_MODE_NONE = 0};        /* each device will have its own time rate, given time and number of point will be respected */
		enum {SYNCRO_MODE_COMMON_STI = 1};  /* a common time rate is choosen for all device, only given number of point will be respected */
		enum {SYNCRO_MODE_MIN_STI = 2};     /* the time rate of the fastest device is choosen as reference,  only given number of point will be respected */

		/*
		 * ACQUISITION UPLOAD mode
		 */
		enum {UPLOAD_MODE_AVOID_FAST = 1};   /* no traces will be uploaded as fast */

	public:
		void configTrace(DsaDeviceBase dev, int traceIdx, int typ, int idx, int sidx) {
			ERRCHK(dsa_acquisition_config_trace(acq, dev.getDsaStructure(), traceIdx, typ, idx, sidx));
		}

		void configTrigger(DsaDeviceBase dev, int trigMode, int trigTraceIdx, double trigLevel, int trigLevelConv) {
			ERRCHK(dsa_acquisition_config_trigger(acq, dev.getDsaStructure(), trigMode, trigTraceIdx, trigLevel, trigLevelConv));
		}

		void configFrequency(int nbPoints, double totalTime, int synchroMode, int uploadMode) {
			ERRCHK(dsa_acquisition_config_frequency(acq, nbPoints, totalTime, synchroMode, uploadMode));
		}

		void configImmediateTrigger(DsaDeviceBase dev) {
			ERRCHK(dsa_acquisition_config_immediate_trigger(acq, dev.getDsaStructure()));
		}

		void configBeginOfMovementTrigger(DsaDeviceBase dev, int ipolGrp, double delay) {
			ERRCHK(dsa_acquisition_config_begin_of_movement_trigger(acq, dev.getDsaStructure(), ipolGrp, delay));
		}

		void configEndOfMovementTrigger(DsaDeviceBase dev, int ipolGrp, double delay) {
			ERRCHK(dsa_acquisition_config_end_of_movement_trigger(acq, dev.getDsaStructure(), ipolGrp, delay));
		}

		void configPositionTrigger(DsaDeviceBase dev, int edge, double position, int conv, double delay) {
			ERRCHK(dsa_acquisition_config_position_trigger(acq, dev.getDsaStructure(), edge, position, conv, delay));
		}

		void configPositionInt64Trigger(DsaDeviceBase dev, int edge, eint64 inc_position, double delay) {
			ERRCHK(dsa_acquisition_config_position_int64_trigger(acq, dev.getDsaStructure(), edge, inc_position, delay));
		}

		void configTraceIdxTrigger(DsaDeviceBase dev, int edge, int trace_idx, double value, int conv, double delay) {
			ERRCHK(dsa_acquisition_config_trace_idx_trigger(acq, dev.getDsaStructure(), edge, trace_idx, value, conv, delay));
		}

		void configTraceIdxInt32Trigger(DsaDeviceBase dev, int edge, int trace_idx, int value, double delay) {
			ERRCHK(dsa_acquisition_config_trace_idx_int32_trigger(acq, dev.getDsaStructure(), edge, trace_idx, value, delay));
		}

		void configTraceIdxInt64Trigger(DsaDeviceBase dev, int edge, int trace_idx, eint64 value, double delay) {
			ERRCHK(dsa_acquisition_config_trace_idx_int64_trigger(acq, dev.getDsaStructure(), edge, trace_idx, value, delay));
		}

		void configTraceIdxFloat32Trigger(DsaDeviceBase dev, int edge, int trace_idx, float value, double delay) {
			ERRCHK(dsa_acquisition_config_trace_idx_float32_trigger(acq, dev.getDsaStructure(), edge, trace_idx, value, delay));
		}

		void configTraceIdxFloat64Trigger(DsaDeviceBase dev, int edge, int trace_idx, double value, double delay) {
			ERRCHK(dsa_acquisition_config_trace_idx_float64_trigger(acq, dev.getDsaStructure(), edge, trace_idx, value, delay));
		}

		void configRegisterTrigger(DsaDeviceBase dev, int edge, int typ, int idx, int sidx, double value, int conv, double delay) {
			ERRCHK(dsa_acquisition_config_register_trigger(acq, dev.getDsaStructure(), edge, typ, idx, sidx, value, conv, delay));
		}

		void configRegisterInt32Trigger(DsaDeviceBase dev, int edge, int typ, int idx, int sidx, int value, double delay) {
			ERRCHK(dsa_acquisition_config_register_int32_trigger(acq, dev.getDsaStructure(), edge, typ, idx, sidx, value, delay));
		}

		void configRegisterInt64Trigger(DsaDeviceBase dev, int edge, int typ, int idx, int sidx, eint64 value, double delay) {
			ERRCHK(dsa_acquisition_config_register_int64_trigger(acq, dev.getDsaStructure(), edge, typ, idx, sidx, value, delay));
		}

		void configRegisterFloat32Trigger(DsaDeviceBase dev, int edge, int typ, int idx, int sidx, float value, double delay) {
			ERRCHK(dsa_acquisition_config_register_float32_trigger(acq, dev.getDsaStructure(), edge, typ, idx, sidx, value, delay));
		}

		void configRegisterFloat64Trigger(DsaDeviceBase dev, int edge, int typ, int idx, int sidx, int value, double delay) {
			ERRCHK(dsa_acquisition_config_register_float64_trigger(acq, dev.getDsaStructure(), edge, typ, idx, sidx, value, delay));
		}

		void configInt32BitFieldStateTrigger(DsaDeviceBase dev, int typ, int idx, int sidx, dword low_state_mask, dword high_state_mask, double delay) {
			ERRCHK(dsa_acquisition_config_int32_bit_field_state_trigger(acq, dev.getDsaStructure(), typ, idx, sidx, low_state_mask, high_state_mask, delay));
		}

		void configInt64BitFieldStateTrigger(DsaDeviceBase dev, int typ, int idx, int sidx, eint64 low_state_mask, eint64 high_state_mask, double delay) {
			ERRCHK(dsa_acquisition_config_int64_bit_field_state_trigger(acq, dev.getDsaStructure(), typ, idx, sidx, low_state_mask, high_state_mask, delay));
		}

		void configInt32BitFieldChangeTrigger(DsaDeviceBase dev, int typ, int idx, int sidx, dword rising_edge_mask, dword falling_edge_mask, double delay) {
			ERRCHK(dsa_acquisition_config_int32_bit_field_change_trigger(acq, dev.getDsaStructure(), typ, idx, sidx, rising_edge_mask, falling_edge_mask, delay));
		}

		void configInt64BitFieldChangeTrigger(DsaDeviceBase dev, int typ, int idx, int sidx, eint64 rising_edge_mask, eint64 falling_edge_mask, double delay) {
			ERRCHK(dsa_acquisition_config_int64_bit_field_change_trigger(acq, dev.getDsaStructure(), typ, idx, sidx, rising_edge_mask, falling_edge_mask, delay));
		}

		double getRealTotalTime() {
			double totalTime;

			ERRCHK(dsa_acquisition_get_real_total_time(acq, &totalTime));
			return totalTime;
		}

		int getTraceRealNbPoints(DsaDevice dev, int traceIdx) {
			int nbPoints;

			ERRCHK(dsa_acquisition_get_trace_real_nb_points(acq, (DSA_DEVICE*)(dev.getDsaStructure()), traceIdx, &nbPoints));
			return nbPoints;
		}

    #ifdef DSA_IMPL_S
		void acquire(int timeout) {
			ERRCHK(dsa_acquisition_acquire_s(acq, timeout));
		}
    #endif /* DSA_IMPL_S */

    #ifdef DSA_IMPL_A
		void acquire(DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_acquisition_acquire_a(acq, (DSA_HANDLER)handler, param));
		}
    #endif /* DSA_IMPL_A */


    void stopAcquire() {
        ERRCHK(dsa_acquisition_stop_acquire(acq));
    }

    void uploadTrace(DsaDevice dev, int traceIdx, int tableSize, double times[], double traces[], int traceConv) {
        ERRCHK(dsa_acquisition_upload_trace(acq, (DSA_DEVICE*)(dev.getDsaStructure()), traceIdx, tableSize, times, traces, traceConv));
    }
    void uploadTrace(DsaDevice dev, int traceIdx, int tableSize, double times[], int traces[]) {
        ERRCHK(dsa_acquisition_upload_inctrace(acq, (DSA_DEVICE*)(dev.getDsaStructure()), traceIdx, tableSize, times, traces));
    }

    void uploadInt32Trace(DsaDevice dev, int traceIdx, int tableSize, double times[], int traces[]) {
        ERRCHK(dsa_acquisition_upload_int32_trace(acq, (DSA_DEVICE*)(dev.getDsaStructure()), traceIdx, tableSize, times, traces));
    }

    void uploadInt64Trace(DsaDevice dev, int traceIdx, int tableSize, double times[], eint64 traces[]) {
        ERRCHK(dsa_acquisition_upload_int64_trace(acq, (DSA_DEVICE*)(dev.getDsaStructure()), traceIdx, tableSize, times, traces));
    }

    void uploadFloat32Trace(DsaDevice dev, int traceIdx, int tableSize, double times[], float traces[]) {
        ERRCHK(dsa_acquisition_upload_float32_trace(acq, (DSA_DEVICE*)(dev.getDsaStructure()), traceIdx, tableSize, times, traces));
    }

    void uploadFloat64Trace(DsaDevice dev, int traceIdx, int tableSize, double times[], double traces[]) {
        ERRCHK(dsa_acquisition_upload_float64_trace(acq, (DSA_DEVICE*)(dev.getDsaStructure()), traceIdx, tableSize, times, traces));
    }

    void getTimeLimits(double *startTime, double *endTime) {
        ERRCHK(dsa_acquisition_get_time_limits(acq, startTime, endTime));
    }

	void reserve() {
        ERRCHK(dsa_acquisition_reserve(acq));
    }

    void unreserve() {
        ERRCHK(dsa_acquisition_unreserve(acq));
    }

    void setName(char *name) {
        ERRCHK(dsa_acquisition_set_name(acq, name));
    }

    void unreserveAll(char *name) {
        ERRCHK(dsa_acquisition_unreserve_all(name));
    }

    bool isReserved() {
        bool reserved;
        ERRCHK(dsa_acquisition_is_reserved(acq, &reserved));
        return reserved;
    }
};

/*------------------------------------------------------------------------------
 * DsaRTVSlot class - C++
 *-----------------------------------------------------------------------------*/
class DsaRTVSlot {
	protected:
		DSA_RTV_SLOT *slot;
		int typ;
    /* constructors */
	public:
		DsaRTVSlot(DsaMaster master, int slotTyp) {
			slot = NULL;
			typ = slotTyp;			
			if (typ == SLOT_32BIT) 
				ERRCHK(dsa_get_32bit_rtv0_slot((DSA_MASTER*)(master.getDsaStructure()), &slot));
			else if (typ == SLOT_64BIT)
				ERRCHK(dsa_get_64bit_rtv0_slot((DSA_MASTER*)(master.getDsaStructure()), &slot));
			else
				ERRCHK(DSA_EBADPARAM);	
		}
		DsaRTVSlot(DsaMaster master, int slotTyp, int lsl) {
			slot = NULL;
			typ = slotTyp;			
			if (typ == SLOT_32BIT) 
				ERRCHK(dsa_get_32bit_rtv1_slot((DSA_MASTER*)(master.getDsaStructure()), &slot, lsl));
			else
				ERRCHK(DSA_EBADPARAM);	
		}
		DsaRTVSlot(DsaMaster master, int slotTyp, int lsl, int msl) {
			slot = NULL;
			typ = slotTyp;			
			if (typ == SLOT_64BIT) 
				ERRCHK(dsa_get_64bit_rtv1_slot((DSA_MASTER*)(master.getDsaStructure()), &slot, lsl, msl));
			else
				ERRCHK(DSA_EBADPARAM);	
		}

	public:
		~DsaRTVSlot(void) {
			if (slot)
				if (typ == SLOT_32BIT)
					ERRCHK(dsa_free_32bit_rtv_slot(&slot));
				else if (typ == SLOT_64BIT)
					ERRCHK(dsa_free_64bit_rtv_slot(&slot));
				else
					ERRCHK(DSA_EBADPARAM);	
		}

	public:
		/*
		 * RTV_SLOT typ
		 */
		enum {SLOT_32BIT = 0};				/*32 bits slot */
		enum {SLOT_64BIT = 1};				/*64 bits slot */

	public:
		void assignSlotToRegister(DsaDeviceBase grp, int typ, int idx, int sidx, int timeout) {
			ERRCHK(dsa_assign_slot_to_register_s(grp.getDsaStructure(), slot, typ, idx, sidx, timeout));
		}
		void assignSlotToRegister(DsaDeviceBase grp, int typ, int idx, int sidx, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_assign_slot_to_register_a(grp.getDsaStructure(), slot, typ, idx, sidx, (DSA_HANDLER)handler, param));
		}
		void unassignSlotToRegister(DsaDeviceBase grp, int typ, int idx, int sidx, int timeout) {
			ERRCHK(dsa_unassign_slot_to_register_s(grp.getDsaStructure(), slot, typ, idx, sidx, timeout));
		}
		void unassignSlotToRegister(DsaDeviceBase grp, int typ, int idx, int sidx, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_unassign_slot_to_register_a(grp.getDsaStructure(), slot, typ, idx, sidx, (DSA_HANDLER)handler, param));
		}
		void assignRegisterToSlot(DsaDevice dev, int typ, int idx, int sidx, int timeout) {
			ERRCHK(dsa_assign_register_to_slot_s(dev.getDsaStructure(), typ, idx, sidx, slot, timeout));
		}
		void assignRegisterToSlot(DsaDevice dev, int typ, int idx, int sidx, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_assign_register_to_slot_a(dev.getDsaStructure(), typ, idx, sidx, slot, (DSA_HANDLER)handler, param));
		}
		void unassignRegisterToSlot(DsaDevice dev, int typ, int idx, int sidx, int timeout) {
			ERRCHK(dsa_unassign_register_to_slot_s(dev.getDsaStructure(), typ, idx, sidx, slot, timeout));
		}
		void unassignRegisterToSlot(DsaDevice dev, int typ, int idx, int sidx, DsaHandler handler, void *param = NULL) {
			ERRCHK(dsa_unassign_register_to_slot_a(dev.getDsaStructure(), typ, idx, sidx, slot, (DSA_HANDLER)handler, param));
		}
		bool is32bit() {
			return dsa_is_32bit_rtv_slot(slot);
		}
		bool is64bit() {
			return dsa_is_64bit_rtv_slot(slot);
		}
		void read32bit(dword *value) {
			ERRCHK(dsa_read_32bit_rtv_slot(slot, value));
		}
		void read64bit(dword *lvalue, dword *mvalue) {
			ERRCHK(dsa_read_64bit_rtv_slot(slot, lvalue, mvalue));
		}
		void write32bit(dword value) {
			ERRCHK(dsa_write_32bit_rtv_slot(slot, value));
		}
		void write64bit(dword lvalue, dword mvalue) {
			ERRCHK(dsa_write_64bit_rtv_slot(slot, lvalue, mvalue));
		}
		void getSlotNr32bit(int *lsl) {
			ERRCHK(dsa_get_32bit_rtv_slot_nr(slot, lsl));
		}
		void getSlotNr64bit(int *lsl, int *msl) {
			ERRCHK(dsa_get_64bit_rtv_slot_nr(slot, lsl, msl));
		}
};

/*
 * this function should be defined once all classes are well known
 */
inline DsaDeviceBase Dsa::etcomCreateAuto(EtbBus etb, int axis) {
    DsaDeviceBase obj;
    ERRCHK(dsa_etcom_create_auto_e(&obj.dsa, *(ETB **)&etb, axis));
    return obj;
}
inline DsaDeviceBase Dsa::createAuto(int prod) {
    DsaDeviceBase obj;
    ERRCHK(dsa_create_auto_o(&obj.dsa, prod));
    return obj;
}
inline DsaMaster DsaBase::getMaster(void) {
    DsaMaster obj;
    ERRCHK(dsa_get_master(dsa, &obj.dsa));
    ERRCHK(dsa_share(obj.dsa));
    return obj;
}
inline void DsaBase::setMaster(DsaMaster master) {
    ERRCHK(dsa_set_master(dsa, master.dsa));
}

#undef ERRCHK
#endif /* DSA_OO_API */


#endif /* _DSA40_H */
