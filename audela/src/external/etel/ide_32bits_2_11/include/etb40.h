/*
 * etb40.h
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
 * This header file contains public declaration for etel-bus library.\n
 * This library contains all drivers to access to the hardware.\n
 * This library is responsible of the communication protocol.\n
 * This library is conformed to POSIX 1003.1c
 * @file etb40.h
 */

#define ETEL_OO_API
#ifndef _ETB40_H
#define _ETB40_H

#ifdef __WIN32__		/* defined by Borland C++ Builder */
	#ifndef WIN32
		#define WIN32
	#endif
#endif

#ifdef __cplusplus
	#ifdef ETEL_OO_API		/* defined by the user when he need the Object Oriented interface */
		#define ETB_OO_API
	#endif
#endif

 /**
 * @defgroup ETBAll ETB All functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup ETBBus ETB Bus access functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup ETBDownloadUpload ETB Download/Upload functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup ETBErrorsAndWarnings ETB Errors and warnings
 */
/*@{*/
/*@}*/

/**
 * @defgroup ETBPort ETB Port access functions
 */
/*@{*/
/*@}*/

/**
 * @defgroup ETBUtils ETB Utility functions
 */
/*@{*/
/*@}*/

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


/**********************************************************************************************************/
/*- LIBRARIES */
/**********************************************************************************************************/

#if defined ETB_OO_API && defined _DSA40_H
	#error dsa40.h must be included AFTER etb40.h
#endif

#ifdef __cplusplus
	extern "C" {
#endif


/*----------------------*/
/* common libraries		*/
#include <time.h>
#include <string.h>
#include <stdarg.h>
#ifdef WIN32
	#ifdef _MSC_VER
		//modif michel 
		//#if _MSC_VER > 1400
		#if _MSC_VER >= 1900
			#include <stdint.h>
		#else
			typedef unsigned int uint32_t;
		#endif
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

#define ETB_ETCOM_DRIVES                 64           /* the maximum number of drives in an new bus type like */
													  /* UltimET, USB for AccurET */
													  /* The records passing on these kinds of bus are ETB_ETCOM */
#define ETB_SERVERS                      4            /* the maximum number of servers in the path */


/*------------------------------------------------------------------------------
 * error codes - c
 *-----------------------------------------------------------------------------*/
#ifndef ETB_OO_API
#define ETB_ERTVREADSYNCRO               -294        /**< RTV read synchronisation error */
#define ETB_EBADDRIVER                   -293        /**< wrong version of the installed device driver */
#define ETB_EBAUDRATE                    -292        /**< matching baudrate not found */
#define ETB_EFPGAFILENOTFOUND            -291        /**< FPGA file is not found in path */
#define ETB_EUNAVAILABLE                 -290        /**< function not available for the driver */
#define ETB_EGPIODEV                     -286        /**< cannot open the gpio device */
#define ETB_EFLASHNOTLOCKED              -285        /**< flash not locked */
#define ETB_EFLASHPROTECTED              -284        /**< flash protected */
#define ETB_EFLASHWRITE                  -283        /**< unable to write flash */
#define ETB_EFLASHREAD                   -282        /**< unable to read flash */
#define ETB_EFLASHINFO                   -281        /**< unable to read flash information */
#define ETB_EFLASHDEV                    -280        /**< unable to open flash device */
#define ETB_EBADOS                       -270        /**< function unavilable on actual OS */
#define ETB_EBOOTPROG                    -263        /**< bad block programming */
#define ETB_EBOOTHEADER                  -262        /**< bad header in boot protocol */
#define ETB_EBOOTENTER                   -261        /**< cannot enter in boot mode */
#define ETB_EBOOTPASSWD                  -260        /**< bad password when enter in boot mode */
#define ETB_EBADHOST                     -253        /**< the specified host address cannot be translated */
#define ETB_ENETWORK                     -252        /**< network problem */
#define ETB_ESOCKRESET                   -251        /**< the socket connection has been broken by peer */
#define ETB_EOPENSOCK                    -250        /**< the specified socket connection cannot be opened */
#define ETB_ECHECKSUM                    -249        /**< checksum error with serial communication */
#define ETB_EOPENCOM                     -240        /**< the specified communication port cannot be opened */
#define ETB_ECRC                         -230        /**< a CRC error has occured */
#define ETB_EBOOTFAILED                  -229        /**< a problem has occured while communicating with the boot */
#define ETB_EBADMODE                     -225        /**< the drive is in a bad mode */
#define ETB_EBADSERVER                   -224        /**< a bad/incompatible server was found */
#define ETB_ESERVER                      -223        /**< the server has incorrect behavior */
#define ETB_EBADSTATE                    -222        /**< this operation is not allowed in this state */
#define ETB_EBUSRESET                    -221        /**< the underlaying etel-bus in performing a reset operation */
#define ETB_EBUSERROR                    -220        /**< the underlaying etel-bus is in error state */
#define ETB_EBADMSG                      -219        /**< a bad message is given */
#define ETB_EBADDRVVER                   -218        /**< a drive with a too old version has been detected */
#define ETB_EBADLIBRARY                  -217        /**< function of external library not found */
#define ETB_ENOLIBRARY                   -216        /**< external library not found */
#define ETB_EBADPARAM                    -215        /**< one of the parameter is not valid */
#define ETB_ENODRIVE                     -214        /**< the specified drive does not respond */
#define ETB_EMASTER                      -213        /**< cannot enter or quit master mode */
#define ETB_EINTERNAL                    -212        /**< some internal error in the etel software */
#define ETB_ESYSTEM                      -211        /**< some system resource return an error */
#define ETB_ETIMEOUT                     -210        /**< a timeout has occured */
#define ETB_ETOOSMALL                    -203        /**< the size of the record table is too small */
#define ETB_EOBSOLETE                    -202        /**< function is obsolete */
#define ETB_ERECTOSMALL                  -201        /**< size of received record too small */
#define ETB_EBADFIRMWARE                 -200        /**< file is not a firmware file */


#endif

/*------------------------------------------------------------------------------
 * timeout special values
 *-----------------------------------------------------------------------------*/
#ifndef INFINITE
	#define INFINITE                         0xFFFFFFFF  /* infinite timeout */
#endif
#ifndef ETB_OO_API
	#define ETB_DEF_TIMEOUT                  (-2L)       /* use the default timeout appropriate for this communication */
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * open/reset/close flags
 *-----------------------------------------------------------------------------*/
#ifndef ETB_OO_API
	#define ETB_FLAG_BOOT_RUN                0x00000001  /* assumes that the drive is in run mode */
	#define ETB_FLAG_BOOT_DIRECT             0x00000002  /* assumes that the drive is in boot mode */
	#define ETB_FLAG_BOOT_BRIDGE             0x00000004  /* assumes that the drive is in boot bridge mode */

	#define ETB_FLAG_RESET_MASTER            0x20000000  /* reset the master (used only with ULTIMET) */
	#define ETB_FLAG_RESET_SLAVES            0x40000000  /* reset all slaves (used only with ACCURET) */

#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * boot modes
 *-----------------------------------------------------------------------------*/
#ifndef ETB_OO_API
	#define ETB_BOOT_MODE_RUN                0           /* drive run mode - normal operation */
	#define ETB_BOOT_MODE_DIRECT             1           /* direct communication to the connected drive boot */
	#define ETB_BOOT_MODE_BRIDGE             2           /* allows access to etel bus slave boot */
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * special axis number
 *-----------------------------------------------------------------------------*/
#ifndef ETB_OO_API
	#define ETB_AXIS_AND                     (-2)        /* and value of the status bits of all drives presents */
	#define ETB_AXIS_OR                      (-1)        /* or value of the status bits of all drives presents */
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * server (record 00h) command numbers
 *-----------------------------------------------------------------------------*/
#ifndef ETB_OO_API
	#define ETB_R_SVR_NUMBER                 0x11        /* get the number of remote servers in the chain */
	#define ETB_R_SVR_INFO_0                 0x12        /* get the product number and soft version of server */
	#define ETB_R_SVR_INFO_1                 0x13        /* get the serial number and boot version */
	#define ETB_R_SVR_INFO_2                 0x14        /* get the name (8 first bytes )*/
	#define ETB_R_SVR_TIMEOUTS_0             0x15        /* get the bus default timeouts of a remote server */
	#define ETB_R_SVR_INFO_3                 0x16        /* get the name (8 last bytes )*/
	#define ETB_R_SVR_STATUS_0               0x21        /* get the bus status of a remote server */
	#define ETB_R_SVR_STATUS_IRQ_0           0x22        /* the bus status interrupt of a remote server */
	#define ETB_R_SVR_KIND	                 0x27        /* the kind of the server */
	#define ETB_R_CHANGE_BOOT_MODE           0x31        /* change the boot mode of the remote drive */
	#define ETB_R_START_DOWNLOAD             0x32        /* start download of the remote drive */
	#define ETB_R_DOWNLOAD_SEGMENT           0x33        /* download a data segment in the remote drive */
	#define ETB_R_START_UPLOAD               0x34        /* start upload of the remote drive */
	#define ETB_R_UPLOAD_SEGMENT             0x35        /* upload a data segment in the remote drive */
	#define ETB_R_OPEN                       0x41        /* open a new connection - first message */
	#define ETB_R_RESET                      0x42        /* reset the current connection to the server */
	#define ETB_R_CLOSE                      0x43        /* close the current connection - last message */
	#define ETB_R_KEEP_ALIVE                 0x44        /* keep connection with the server alive */
	#define ETB_R_START_IRQ                  0x45        /* ask server to start sendnig irqs when required */
	#define ETB_R_PURGE_STOP                 0x46        /* purge queues and stop sending data / interrupts */
	#define ETB_R_ALIVE_RATE                 0x60        /* message to define timeout of connection break */
	#define ETB_R_DOWNLOAD_DATA			     0xF1        /* start download of a set of data */
	#define ETB_R_UPLOAD_DATA			     0xF3        /* start upload of a set of data */
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * magic commands for record 04/12/14
 *-----------------------------------------------------------------------------*/
#ifndef ETB_OO_API
	#define ETB_MAGIC_PRESENT                0x90        /* denotes a drive present request (record 14) */
	#define ETB_MAGIC_STATUS_DRV_0           0x90        /* denotes a drive status request (record 12) */
	#define ETB_MAGIC_STATUS_DRV_IRQ_0       0xA0        /* denotes a drive status interrupt (record 12) */
	#define ETB_MAGIC_INFO_DRV_0             0xB0        /* denotes the first drive information request (record 12) */
	#define ETB_MAGIC_INFO_DRV_1             0xC0        /* denotes the second drive information request (record 12) */
	#define ETB_MAGIC_INFO_DRV_2             0xC1        /* denotes the third drive information request (record 12) */
	#define ETB_MAGIC_INFO_DRV_3             0xC2        /* denotes the fourth drive information request (record 12) */
	#define ETB_MAGIC_INFO_DRV_4             0xC3        /* denotes the fourth drive information request (record 12) */
	#define ETB_MAGIC_INFO_DRV_5             0xC4        /* denotes the fifth drive information request (record 12) */
	#define ETB_MAGIC_INFO_DRV_6             0xC5        /* denotes the sixth drive information request (record 12) */
	#define ETB_MAGIC_INFO_EXT_0             0xD0        /* denotes the first extension card information request (record 12) */
	#define ETB_MAGIC_INFO_EXT_1             0xE0        /* denotes the second extension card information request (record 12) */
	#define ETB_MAGIC_INFO_MASTER_0			 0x10        /* denotes a master specific information request (record 12) */
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * etb special axis number
 *-----------------------------------------------------------------------------*/
#ifndef ETB_OO_API
	#define ETB_ALL_AXIS                     0x40        /* special axis value meaning all axis */
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * etel bus events
 *-----------------------------------------------------------------------------*/
#ifndef ETB_OO_API
	#define ETB_BEV_ERROR_SET                0x00000001  /* the error bit has been set */
	#define ETB_BEV_ERROR_CLR                0x00000002  /* the error bit has been cleared */
	#define ETB_BEV_ERROR                    0x00000003  /* the error bit has changed */
	#define ETB_BEV_WARNING_SET              0x00000004  /* the warning bit has been set */
	#define ETB_BEV_WARNING_CLR              0x00000008  /* the warning bit has been cleared */
	#define ETB_BEV_WARNING                  0x0000000C  /* the warning bit has changed */
	#define ETB_BEV_RESET_SET                0x00000010  /* the driver has entered reset mode */
	#define ETB_BEV_RESET_CLR                0x00000020  /* the driver has exited reset mode */
	#define ETB_BEV_RESET                    0x00000030  /* the reset bit has changed */
	#define ETB_BEV_OPEN_SET                 0x00000040  /* the driver is open */
	#define ETB_BEV_OPEN_CLR                 0x00000080  /* the driver is closed */
	#define ETB_BEV_OPEN                     0x000000C0  /* the open bit has changed */
	#define ETB_BEV_WATCHDOG_SET             0x00000100  /* the watchdog bit has been set */
	#define ETB_BEV_WATCHDOG_CLR             0x00000200  /* the watchdog bit has been cleared */
	#define ETB_BEV_WATCHDOG                 0x00000300  /* the watchdog bit has changed */
	#define ETB_BEV_STATUS                   0x00001000  /* the bus status has changed */
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * etel bus drive events
 *-----------------------------------------------------------------------------*/
#ifndef ETB_OO_API
	#define ETB_DEV_ERROR_SET                0x00000001  /* one of the error bit has been set */
	#define ETB_DEV_ERROR_CLR                0x00000002  /* one of the error bit has been cleared */
	#define ETB_DEV_ERROR                    0x00000003  /* one of the error bit has changed */
	#define ETB_DEV_WARNING_SET              0x00000004  /* one of the warning bit has been set */
	#define ETB_DEV_WARNING_CLR              0x00000008  /* one of the warning bit has been cleared */
	#define ETB_DEV_WARNING                  0x0000000C  /* one of the warning bit has changed */
	#define ETB_DEV_PRESENT_SET              0x00000010  /* a new drive is present */
	#define ETB_DEV_PRESENT_CLR              0x00000020  /* a drive has disappeared */
	#define ETB_DEV_PRESENT                  0x00000030  /* the present bit has changed */
	#define ETB_DEV_STATUS_1                 0x00000100  /* the first status word has changed */
	#define ETB_DEV_STATUS_2                 0x00000200  /* the second status word has changed */
	#define ETB_DEV_STATUS                   0x00000300  /* one of the status word has changed */
	#define ETB_DEV_USER                     0x00001000  /* the user field has changed */
#endif /* ETB_OO_API */

/**********************************************************************************************************/
/*- MACROS */
/**********************************************************************************************************/

/*-------------------------------------------------------------------------------------------------*/
/* Diagnostic call for old type bus (EBL2, DSMAX1, DSMAX2, DSMAX3, DSTEB1, DSTEB3) */
#define ETB_DIAG(err, etb, mask)						{etb_diag(__FILE__, __LINE__, err, etb, mask);}
#define ETB_SDIAG(str, err, etb, mask)					{etb_sdiag(str, __FILE__, __LINE__, err, etb, mask);}
#define ETB_FDIAG(output_file_name, err, etb, mask)		{etb_fdiag(output_file_name, __FILE__, __LINE__, err, etb, mask);}

/*-------------------------------------------------------------------------------------------------*/
/* Diagnostic call for new type bus (UltimET, AccurET)*/
#define ETB_ETCOM_DIAG(err, etb, mask)						{etb_etcom_diag(__FILE__, __LINE__, err, etb, mask);}
#define ETB_ETCOM_SDIAG(str, err, etb, mask)				{etb_etcom_sdiag(str, __FILE__, __LINE__, err, etb, mask);}
#define ETB_ETCOM_FDIAG(output_file_name, err, etb, mask)	{etb_etcom_fdiag(output_file_name, __FILE__, __LINE__, err, etb, mask);}

#define ETB_CONST_REC                        const

/**********************************************************************************************************/
/*- TYPES */
/**********************************************************************************************************/

/*------------------------------------------------------------------------------
 * type modifiers
 *-----------------------------------------------------------------------------*/
/*------------------------------*/
/* WINDOWS type modifiers		*/
#ifdef WIN32
	#define _ETB_EXPORT __cdecl                          /* function exported by static library */
	#define ETB_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* WIN32 */

/*------------------------------*/
/* POSIX type modifiers			*/
#ifdef POSIX
	#define _ETB_EXPORT                           /* function exported by library */
	#define ETB_CALLBACK                          /* client callback function called by library */
#endif /*POSIX*/

/*------------------------------*/
/* VXWORKS type modifiers		*/
#ifdef VXWORKS
	#define _ETB_EXPORT                           /* function exported by library */
	#define ETB_CALLBACK                          /* client callback function called by library */
#endif /*VXWORKS*/

/*------------------------------------------------------------------------------
 * hidden structures for library clients
 *-----------------------------------------------------------------------------*/
#ifndef ETB
	#define ETB void
#endif
#ifndef ETB_PORT
	#define ETB_PORT void
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
 * EtbSW1BitMode type
 *-----------------------------------------------------------------------------*/
/**
 * @struct EtbSW1BitMode
 * Allow access to drive status 1 (M60) with bit members
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbSW1BitMode {
	#ifndef ETB_OO_API
	unsigned power_on:1;				/**< The power is applied to the motor */
	unsigned init_done:1;				/**< The initialisation procedure has been done */
	unsigned homing_done:1;				/**< The homing procedure has been done */
	unsigned present:1;					/**< The drive is present */
	unsigned moving:1;					/**< The motor is moving */
	unsigned in_window:1;				/**< The motor is the target windows */
	unsigned master:1;                  /**< The drive is in master mode */
	unsigned busy:1;                    /**< The drive is busy */
	unsigned exec_seq:1;                /**< A sequence is running */
	unsigned edit_mode:1;               /**< The sequence can be edited */
	unsigned fatal:1;                   /**< Fatal error */
	unsigned trace_busy:1;              /**< The aquisition of the trace is not finished */
	unsigned bridge:1;                  /**< The drive is in bridge mode */
	unsigned homing:1;                  /**< The motor is homing */
	unsigned ebl_to_eb:1;               /**< The EBL is routed transparentrly to EB (download) */
	unsigned spy:1;                     /**< A slave is used as a spy: master of labView channel */
	unsigned warning:8;                 /**< Warning mask */
	unsigned error:8;                   /**< Error mask */
	#else /* ETB_OO_API */
	unsigned powerOn:1;                 /**< The power is applied to the motor */
	unsigned initDone:1;                /**< The initialisation procedure has been done */
	unsigned homingDone:1;              /**< The homing procedure has been done */
	unsigned present:1;                 /**< The drive is present */
	unsigned moving:1;                  /**< The motor is moving */
	unsigned inWindow:1;                /**< The motor is the target windows */
	unsigned master:1;                  /**< The drive is in master mode */
	unsigned busy:1;                    /**< The drive is busy */
	unsigned execSeq:1;                 /**< A sequence is running */
	unsigned editMode:1;                /**< The sequence can be edited */
	unsigned fatal:1;                   /**< Fatal error */
	unsigned traceBusy:1;               /**< The aquisition of the trace is not finished */
	unsigned bridge:1;                  /**< The drive is in bridge mode */
	unsigned homing:1;                  /**< The motor is homing */
	unsigned eblToEb:1;                 /**< The EBL is routed transparentrly to EB (download) */
	unsigned spy:1;                     /**< A slave is used as a spy: master of labView channel */
	unsigned warning:8;                 /**< Warning mask */
	unsigned error:8;                   /**< Error mask */
	#endif /* ETB_OO_API */
} EtbSW1BitMode;
#else /*__BYTE_ORDER == __BIG_ENDIAN*/
typedef struct EtbSW1BitMode {
	#ifndef ETB_OO_API
	unsigned error:8;                   /**< Error mask */
	unsigned warning:8;                 /**< Warning mask */
	unsigned spy:1;                     /**< A slave is used as a spy: master of labView channel */
	unsigned ebl_to_eb:1;               /**< The EBL is routed transparentrly to EB (download) */
	unsigned homing:1;                  /**< The motor is homing */
	unsigned bridge:1;                  /**< The drive is in bridge mode */
	unsigned trace_busy:1;              /**< The aquisition of the trace is not finished */
	unsigned fatal:1;                   /**< Fatal error */
	unsigned edit_mode:1;               /**< The sequence can be edited */
	unsigned exec_seq:1;                /**< A sequence is running */
	unsigned busy:1;                    /**< The drive is busy */
	unsigned master:1;                  /**< The drive is in master mode */
	unsigned in_window:1;               /**< The motor is the target windows */
	unsigned moving:1;                  /**< The motor is moving */
	unsigned present:1;                 /**< The drive is present */
	unsigned homing_done:1;             /**< The homing procedure has been done */
	unsigned init_done:1;               /**< The initialisation procedure has been done */
	unsigned power_on:1;                /**< The power is applied to the motor */
	#else /* ETB_OO_API */
	unsigned error:8;                   /**< Error mask */
	unsigned warning:8;                 /**< Warning mask */
	unsigned spy:1;                     /**< A slave is used as a spy: master of labView channel */
	unsigned eblToEb:1;                 /**< The EBL is routed transparentrly to EB (download) */
	unsigned homing:1;                  /**< The motor is homing */
	unsigned bridge:1;                  /**< The drive is in bridge mode */
	unsigned traceBusy:1;               /**< The aquisition of the trace is not finished */
	unsigned fatal:1;                   /**< Fatal error */
	unsigned editMode:1;                /**< A sequence is running */
	unsigned execSeq:1;                 /**< A sequence is running */
	unsigned busy:1;                    /**< The drive is busy */
	unsigned master:1;                  /**< The drive is in master mode */
	unsigned inWindow:1;                /**< The motor is the target windows */
	unsigned moving:1;                  /**< The motor is moving */
	unsigned present:1;                 /**< The drive is present */
	unsigned homingDone:1;              /**< The homing procedure has been done */
	unsigned initDone:1;                /**< The initialisation procedure has been done */
	unsigned powerOn:1;                 /**< The power is applied to the motor */
	#endif /* ETB_OO_API */
} EtbSW1BitMode;
#endif /*__BYTE_ORDER*/

/*------------------------------------------------------------------------------
 * ETB_SW1 type
 *-----------------------------------------------------------------------------*/
/**
 * @union ETB_SW1
 * Contains status 1 of devices (M60)
 */
typedef union ETB_SW1 {
	dword l;							/**< Status 1 for acces in double word format */
	EtbSW1BitMode s;					/**< Status 1 for access in bit format */
} ETB_SW1;


/*------------------------------------------------------------------------------
 *  EtbSW2BitMode type
 *-----------------------------------------------------------------------------*/
/**
 * @struct EtbSW2BitMode
 * Allow access to drive status 2 (M61) with bit members
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbSW2BitMode {
	#ifndef ETB_OO_API
	unsigned seq_error:1;               /**< Error label has been executed */
	unsigned seq_warning:1;             /**< Warning label has been executed */
	unsigned :6;
	unsigned user:8;                    /**< User status */
	unsigned :12;
	unsigned dll:4;                     /**< Used internally by dlls */
	#else /* ETB_OO_API */
	unsigned seqError:1;                /**< Error label has been executed */
	unsigned seqWarning:1;              /**< Warning label has been executed */
	unsigned :6;
	unsigned user:8;                    /**< User status */
	unsigned :12;
	unsigned dll:4;                     /**< Used internally by dlls */
	#endif /* ETB_OO_API */
} EtbSW2BitMode;

#else /*__BYTE_ORDER == __BIG_ENDIAN*/
typedef struct EtbSW2BitMode {
	#ifndef ETB_OO_API
	unsigned dll:4;                     /**< Used internally by dlls */
	unsigned :12;
	unsigned user:8;                    /**< User status */
	unsigned :6;
	unsigned seq_warning:1;             /**< Warning label has been executed */
	unsigned seq_error:1;               /**< Error label has been executed */
	#else /* ETB_OO_API */
	unsigned dll:4;                     /**< Used internally by dlls */
	unsigned :12;
	unsigned user:8;                    /**< User status */
	unsigned :6;
	unsigned seqWarning:1;              /**< Warning label has been executed */
	unsigned seqError:1;                /**< Error label has been executed */
	#endif /* ETB_OO_API */
} EtbSW2BitMode;
#endif /*__BYTE_ORDER*/

/*------------------------------------------------------------------------------
 *  ETB_SW2 type
 *-----------------------------------------------------------------------------*/
/**
 * @union ETB_SW2
 * Contains status 2 of devices (M61)
 */
typedef union ETB_SW2 {
	dword l;							/**< Status 2 for acces in double word format */
	EtbSW2BitMode s;					/**< Status 2 for access in bit format */
} ETB_SW2;


/*------------------------------------------------------------------------------
 *  ETB_DRV_STATUS type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_DRV_STATUS
 * Etel bus drive status
 */
typedef struct ETB_DRV_STATUS {
    int size;							/**< The size of the structure */
    ETB_SW1 sw1;								/**< Status 1 (M60)*/
    ETB_SW2 sw2;								/**< Status 2 (M61)*/
} ETB_DRV_STATUS;

#define EtbDrvStatus ETB_DRV_STATUS

/*------------------------------------------------------------------------------
 * ETB_ETCOM_PARAM_BIT_MODE type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM_PARAM_BIT_MODE
 * Allow acces to Etel Variable length record parameters with bits members
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct ETB_ETCOM_PARAM_BIT_MODE {
    unsigned idx:16;                        /**< Index in specified address space */
    unsigned sidx:8;                        /**< Sub-index in specified address space */
    unsigned axis:7;                        /**< Axis or bit number */
    unsigned reserved1:1;                   /**< Reserved 1 */
} ETB_ETCOM_PARAM_BIT_MODE;

#else /*__BYTE_ORDER == __BIG_ENDIAN*/
typedef struct ETB_ETCOM_PARAM_BIT_MODE {
    unsigned reserved1:1;                   /**< Reserved 1 */
    unsigned axis:7;                        /**< Axis or bit number */
    unsigned sidx:8;                        /**< Sub-index in specified address space */
    unsigned idx:16;                        /**< Index in specified address space */
} ETB_ETCOM_PARAM_BIT_MODE;
#endif /*__BYTE_ORDER*/

/*------------------------------------------------------------------------------
 * ETB_ETCOM_PARAM_BYTE_MODE type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM_PARAM_BYTE_MODE
 * Allow acces to Etel Variable length record 32 bits parameter with raw members
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct ETB_ETCOM_PARAM_BYTE_MODE {
	byte byte0;						/**< Byte 0 of parameter */
	byte byte1;						/**< Byte 1 of parameter */
	byte byte2;						/**< Byte 2 of parameter */
	byte byte3;						/**< Byte 3 of parameter */
} ETB_ETCOM_PARAM_BYTE_MODE;
#else /*__BYTE_ORDER*/
typedef struct ETB_ETCOM_PARAM_BYTE_MODE {
	byte byte3;						/**< Byte 3 of parameter */
	byte byte2;						/**< Byte 2 of parameter */
	byte byte1;						/**< Byte 1 of parameter */
	byte byte0;						/**< Byte 0 of parameter */
} ETB_ETCOM_PARAM_BYTE_MODE;
#endif


/*------------------------------------------------------------------------------
 * ETB_ETCOM_VALUE type
 *-----------------------------------------------------------------------------*/
/**
 * @union ETB_ETCOM_VALUE
 * Etel variable parameter value
 */
typedef union ETB_ETCOM_VALUE {
	int i32;
	eint64 i64;
	float f32;
	double f64;
	ETB_ETCOM_PARAM_BIT_MODE bits;
	ETB_ETCOM_PARAM_BYTE_MODE bytes;
} ETB_ETCOM_VALUE;
#define EtbEtcomValue ETB_ETCOM_VALUE

/*------------------------------------------------------------------------------
 * ETB_ETCOM_PARAM type
 *-----------------------------------------------------------------------------*/
/**
 * @union ETB_ETCOM_PARAM
 * Etel variable length record parameter
 */
typedef struct ETB_ETCOM_PARAM {
    int typ;								/**< type of parameter (See DMD_TYP...)*/
	ETB_ETCOM_VALUE value;					/**< value of parameter*/
} ETB_ETCOM_PARAM;


/*------------------------------------------------------------------------------
 * ETB_ETCOM_HEADER_BIT_MODE type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM_HEADER_BIT_MODE
 * Allow acces to Etel Variable length record header with bits members
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct ETB_ETCOM_HEADER {
	unsigned nb_param	:8;					/**< number of parameters */
	unsigned gate   	:3;					/**< gate */
	unsigned reserved1	:3;					/**< reserved */
	unsigned err	    :1;					/**< acknowledge of command */
	unsigned ack	    :1;					/**< acknowledge of command */
    unsigned cmd	    :8;					/**< Command number */
	unsigned rec	    :8;					/**< record number */
} ETB_ETCOM_HEADER;
#else /*__BYTE_ORDER == __BIG_ENDIAN*/
typedef struct ETB_ETCOM_HEADER {
	unsigned rec	    :8;					/**< record number */
    unsigned cmd	    :8;					/**< Command number */
	unsigned ack	    :1;					/**< acknowledge of command */
	unsigned err	    :1;					/**< acknowledge of command */
	unsigned reserved1	:3;					/**< reserved */
	unsigned gate   	:3;					/**< gate */
	unsigned nb_param	:8;					/**< number of parameters */
} ETB_ETCOM_HEADER;
#endif /*__BYTE_ORDER*/

/*------------------------------------------------------------------------------
 * ETB_ETCOM type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM
 * Etel variable length record structure with 2 parameters
 */
typedef struct ETB_ETCOM {
	ETB_ETCOM_HEADER header;	    			/**< header */
	ETB_ETCOM_PARAM pars[2];					/**< default 2 parameters*/
} ETB_ETCOM;

#define EtbEtcom ETB_ETCOM

/*------------------------------------------------------------------------------
 * ETB_ETCOM0 type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM0
 * Etel variable length record structure with 0 int32 value-parameter
 */
typedef struct ETB_ETCOM0 {
	ETB_ETCOM_HEADER header;	    			/**< header */
} ETB_ETCOM0;
#define EtbEtcom0 ETB_ETCOM0

/*------------------------------------------------------------------------------
 * ETB_ETCOM1 type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM1
 * Etel variable length record structure with 1 parameter
 */
typedef struct ETB_ETCOM1 {
	ETB_ETCOM_HEADER header;	    			/**< header */
	ETB_ETCOM_PARAM pars[1];					/**< 1 parameter*/
} ETB_ETCOM1;
#define EtbEtcom1 ETB_ETCOM1

/*------------------------------------------------------------------------------
 * ETB_ETCOM2 type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM2
 * Etel variable length record structure with 2 parameters
 */
#define ETB_ETCOM2 ETB_ETCOM
#define EtbEtcom2 ETB_ETCOM2

/*------------------------------------------------------------------------------
 * ETB_ETCOM3 type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM3
 * Etel variable length record structure with 3 parameters
 */
typedef struct ETB_ETCOM3 {
	ETB_ETCOM_HEADER header;	    			/**< header */
	ETB_ETCOM_PARAM pars[3];					/**< 3 parameters*/
} ETB_ETCOM3;
#define EtbEtcom3 ETB_ETCOM3

/*------------------------------------------------------------------------------
 * ETB_ETCOM4 type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM4
 * Etel variable length record structure with 4 parameters
 */
typedef struct ETB_ETCOM4 {
	ETB_ETCOM_HEADER header;	    			/**< header */
	ETB_ETCOM_PARAM pars[4];					/**< 4 parameters*/
} ETB_ETCOM4;
#define EtbEtcom4 ETB_ETCOM4

/*------------------------------------------------------------------------------
 * ETB_ETCOM5 type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM5
 * Etel variable length record structure with 5 parameters
 */
typedef struct ETB_ETCOM5 {
	ETB_ETCOM_HEADER header;	    			/**< header */
	ETB_ETCOM_PARAM pars[5];					/**< 5 parameters*/
} ETB_ETCOM5;
#define EtbEtcom5 ETB_ETCOM5

/*------------------------------------------------------------------------------
 * ETB_ETCOM6 type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_ETCOM6
 * Etel variable length record structure with 6 parameters
 */
typedef struct ETB_ETCOM6 {
	ETB_ETCOM_HEADER header;	    			/**< header */
	ETB_ETCOM_PARAM pars[6];					/**< 6 parameters)*/
} ETB_ETCOM6;
#define EtbEtcom6 ETB_ETCOM6

/*------------------------------------------------------------------------------
 * ETB_ETCOM65 type
 *-----------------------------------------------------------------------------*/
#define ETB_ETCOM_DEF_PARAM 65
/**
 * @struct ETB_ETCOM65 
 * Etel variable length record structure with 65 parameters
 * (used to set all depthes of a registers => max depth 64 + 1 parameter register address)
 */
typedef struct ETB_ETCOM65 {
	ETB_ETCOM_HEADER header;	    			/**< header */
	ETB_ETCOM_PARAM pars[ETB_ETCOM_DEF_PARAM];					/**< 65 value-parameters)*/
} ETB_ETCOM65;
#define EtbEtcom65 ETB_ETCOM65

#define ETB_ETCOMDEF ETB_ETCOM65
#define EtbEtcomDef ETB_ETCOMDEF


/*------------------------------------------------------------------------------
 * ETB_ETCOM203 type
 *-----------------------------------------------------------------------------*/
#define ETB_ETCOM_MAX_PARAM 203
/**
 * @struct ETB_ETCOM203
 * Etel variable length record structure with 203 parameters (Maximum of 32-bits parameters)
 */
typedef struct ETB_ETCOM203 {
	ETB_ETCOM_HEADER header;	    			/**< header */
	ETB_ETCOM_PARAM pars[ETB_ETCOM_MAX_PARAM];					/**< 203 parameters)*/
} ETB_ETCOM203;
#define ETB_ETCOMMAX ETB_ETCOM203
#define EtbEtcom203 ETB_ETCOM203
#define EtbEtcomMax ETB_ETCOMMAX

/*------------------------------------------------------------------------------
 * ETB_ETCOM2E type
 *-----------------------------------------------------------------------------*/
#define ETB_ETCOM_2E_PARAM 253
/**
 * @struct ETB_ETCOM2E
 * Etel record structure with 253 parameters (Maximum of 32-bits parameters) Used for download
 */
typedef struct ETB_ETCOM2E {
	ETB_ETCOM_HEADER header;	    			/**< header */
	ETB_ETCOM_PARAM pars[ETB_ETCOM_2E_PARAM];					/**< 253 parameters)*/
} ETB_ETCOM2E;
#define EtbEtcom2E ETB_ETCOM2E


/*------------------------------------------------------------------------------
 * EtbSWBitMode type
 *-----------------------------------------------------------------------------*/
/**
 * @struct EtbSWBitMode
 * Allows acces to Etel bus status double word in bit mode
 */

#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbSWBitMode {
	#ifndef ETB_OO_API
	unsigned open:1;				/**< The driver is open */
	unsigned reset:1;               /**< The driver currently perforn a reset */
	unsigned b_direct:1;            /**< The drive(s) are in direct boot mode */
	unsigned b_bridge:1;            /**< The drive(s) are in bridge boot mode */
	unsigned warning:1;             /**< There is a communication warning */
	unsigned error:1;               /**< There is a communication error */
	unsigned busy:1;                /**< The drive cannot communicate now */
	unsigned watchdog:1;			/**< There is a watchdog error on communication*/
	unsigned :4;
	unsigned :16;
	unsigned dll:4;                 /**< Reserved for dll use */
	#else /* ETB_OO_API */
	unsigned open:1;                /**< The driver is open */
	unsigned reset:1;               /**< The driver currently perforn a reset */
	unsigned bDirect:1;             /**< The drive(s) are in direct boot mode */
	unsigned bBridge:1;             /**< The drive(s) are in bridge boot mode */
	unsigned warning:1;             /**< There is a communication warning */
	unsigned error:1;               /**< There is a communication error */
	unsigned busy:1;                /**< The drive cannot communicate now */
	unsigned watchdog:1;			/**< There is a watchdog error on communication*/
	unsigned :4;
	unsigned :16;
	unsigned dll:4;                 /**< Reserved for dll use */
	#endif /* ETB_OO_API */
} EtbSWBitMode;
#else /*__BYTE_ORDER == __BIG_ENDIAN*/
typedef struct EtbSWBitMode {
	#ifndef ETB_OO_API
	unsigned dll:4;                 /**< Reserved for dll use */
	unsigned :16;
	unsigned :4;
	unsigned watchdog:1;			/**< There is a watchdog error on communication*/
	unsigned busy:1;                /**< The drive cannot communicate now */
	unsigned error:1;               /**< There is a communication error */
	unsigned warning:1;             /**< There is a communication warning */
	unsigned b_bridge:1;            /**< The drive(s) are in bridge boot mode */
	unsigned b_direct:1;            /**< The drive(s) are in direct boot mode */
	unsigned reset:1;               /**< The driver currently perforn a reset */
	unsigned open:1;				/**< The driver is open */
	#else /* ETB_OO_API */
	unsigned dll:4;                 /**< Reserved for dll use */
	unsigned :16;
	unsigned :4;
	unsigned watchdog:1;			/**< There is a watchdog error on communication*/
	unsigned busy:1;                /**< The drive cannot communicate now */
	unsigned error:1;               /**< There is a communication error */
	unsigned warning:1;             /**< There is a communication warning */
	unsigned bBidge:1;	            /**< The drive(s) are in bridge boot mode */
	unsigned bDrect:1;		        /**< The drive(s) are in direct boot mode */
	unsigned reset:1;               /**< The driver currently perforn a reset */
	unsigned open:1;				/**< The driver is open */
	#endif /* ETB_OO_API */
} EtbSWBitMode;
#endif /*__BYTE_ORDER*/

/*------------------------------------------------------------------------------
 * ETB_SW type
 *-----------------------------------------------------------------------------*/
/**
 * @union ETB_SW
 * Etel bus status double word
 */
typedef union ETB_SW {
	dword l;						/**< Status double word for access in double word */
	EtbSWBitMode s;					/**< Status double word for accexss in bit mode */
} ETB_SW;

#define EtbSW ETB_SW

/*------------------------------------------------------------------------------
 * ETB_BUS_STATUS type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_BUS_STATUS
 * Etel bus status structure
 */
typedef struct ETB_BUS_STATUS {
    int size;                    /**< The size of this structure */
	ETB_SW sw;                      /**< The status */
    int e_code;                     /**< The error code */
} ETB_BUS_STATUS;

#define EtbBusStatus ETB_BUS_STATUS

/*------------------------------------------------------------------------------
 * ETB_DRV_INFO type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_DRV_INFO
 * Etel bus drive information
 */
typedef struct ETB_DRV_INFO {
    int size;                    /**< The size of this structure */
	#ifndef ETB_OO_API
    int product_number;             /**< The drive product number */
    int boot_revision;              /**< The boot revision of drive */
    long serial_number;             /**< The serial number of drive */
    dword soft_version;             /**< The version of drive software */
    dword product_string[8];
    bool true_gantry;				/**< The gantry is a true gantry */
    int hw_version;					/**< The hardware version */
	#else /* ETB_OO_API */
    int productNumber;              /**< The drive product number */
    int bootRevision;               /**< The boot revision of drive */
    long serialNumber;              /**< The serial number of drive */
    dword softVersion;              /**< The version of drive software */
    dword productString[8];
    bool true_gantry;				/**< The gantry is a true gantry */
    int hwVersion;					/**< The hardware version */
	#endif /* ETB_OO_API */
} ETB_DRV_INFO;

#define EtbDrvInfo ETB_DRV_INFO

/*------------------------------------------------------------------------------
 * ETB_MASTER_INFO type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_MASTER_INFO
 * Etel bus master information
 */
typedef struct ETB_MASTER_INFO {
    int size;                    /**< The size of this structure */
	#ifndef ETB_OO_API
	int stream_max_data_size;		/**< The maximal number of long of a record used for stream */
	#else /* ETB_OO_API */
	int streamMaxDataSize;			/**< The maximal number of long of a record used for stream */
	#endif /* ETB_OO_API */
} ETB_MASTER_INFO;

#define EtbMasterInfo ETB_MASTER_INFO

/*------------------------------------------------------------------------------
 * ETB_EXT_INFO type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_EXT_INFO
 * Etel bus extension card information
 */
typedef struct ETB_EXT_INFO {
    int size;                    /**< The size of this structure */
	#ifndef ETB_OO_API
    int product_number;             /**< The extension card product number */
    int boot_revision;              /**< The boot revision of extension card */
    long serial_number;             /**< The serial number of extension card */
    dword soft_version;             /**< The version of extension card software */
	#else /* ETB_OO_API */
    int productNumber;              /**< The extension card product number */
    int bootRevision;               /**< The boot revision of extension card */
    long serialNumber;              /**< The serial number of extension card */
    dword softVersion;              /**< The version of extension card software */
	#endif /* ETB_OO_API */
} ETB_EXT_INFO;

#define EtbExtInfo ETB_EXT_INFO


/*------------------------------------------------------------------------------
 * ETB_SVR_INFO type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_SVR_INFO
 * Etel bus server information
 */
typedef struct ETB_SVR_INFO {
    int size;                    /**< The size of this structure */
	#ifndef ETB_OO_API
    int product_number;             /**< The server product number */
    dword soft_version;             /**< The version of server software */
    int boot_revision;
    long serial_number;
    dword product_string[8];        /**< Product string */
	#else /* ETB_OO_API */
    int productNumber;              /**< The server product number */
    dword softVersion;              /**< The version of server software */
    int bootRevision;
    long serialNumber;
    dword productString[8];        /**< Product string */
	#endif /* ETB_OO_API */
} ETB_SVR_INFO;

#define EtbSvrInfo ETB_SVR_INFO


/*------------------------------------------------------------------------------
 * ETB_TIMEOUTS type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_TIMEOUTS
 * Etel bus preferred timeouts information
 */
typedef struct ETB_TIMEOUTS {
    int size;                    /**< The size of this structure */
    int base;                       /**< The base value of preferred timeouts */
    int fast;                       /**< The factor for preferred fast timeouts */
    int slow;                       /**< The factor for preferred slow timeouts */
} ETB_TIMEOUTS;

#define EtbTimeouts ETB_TIMEOUTS

/*------------------------------------------------------------------------------
 * ETB_RTV_HANDLER type
 *-----------------------------------------------------------------------------*/
/*Type of rtv function called at each interrupt*/
/*For AccurET connected through UltimET only */
typedef void (ETB_CALLBACK *ETB_RTV_HANDLER)(ETB *etb, int nr, void *user);

/*------------------------------------------------------------------------------
 * ETB_FW_INFO type
 *-----------------------------------------------------------------------------*/
/**
 * @struct ETB_FW_INFO
 * Firmware information
 */
typedef struct ETB_FW_INFO {
	char title[64];			/**< The name of the firmware */
	char version[64];		/**< The version of the firmware */
} ETB_FW_INFO;

/*------------------------------------------------------------------------------
 * ETB_ISO_CONVERTER type
 *-----------------------------------------------------------------------------*/
typedef int ETB_CALLBACK ETB_ISO_CONVERTER(ETB *etb, ETB_ETCOM_VALUE *incr, double *iso, int incr_type, int conv, int axis, bool to_iso, void *user);

/**********************************************************************************************************/
/*- VARIABLES */
/**********************************************************************************************************/

#ifndef AXIS_PAR
	extern int etb_axis;
#endif /* AXIS_PAR */

/**********************************************************************************************************/
/*- PROTOTYPES */
/**********************************************************************************************************/
/**
 * @addtogroup ETBAll
 */
/*@{*/

/*------------------------------------------------------------------------------
 * general functions
 *-----------------------------------------------------------------------------*/
dword   _ETB_EXPORT etb_get_version(void);
dword   _ETB_EXPORT etb_get_edi_version(void);
time_t  _ETB_EXPORT etb_get_build_time(void);
long    _ETB_EXPORT etb_get_timer(void);
char_cp _ETB_EXPORT etb_translate_error(int code);

/*------------------------------------------------------------------------------
 * utility functions
 *-----------------------------------------------------------------------------*/
void	_ETB_EXPORT etb_etcom_get_string (char *buffer, int buffer_size, ETB_ETCOM *etcom, int start_par_idx, int end_idx);
int		_ETB_EXPORT etb_fill_etcom(ETB_ETCOM *etcom, int max_param, int rec, int cmd, char *format, ...);
int		_ETB_EXPORT etb_vfill_etcom(ETB_ETCOM *etcom, int max_param, int rec, int cmd, char *format, va_list args);
void	_ETB_EXPORT etb_endian_memcpy(void *dest, void *src, int size);
void	_ETB_EXPORT etb_endian_memcpy64(void *dest, void *src, int size);
void	_ETB_EXPORT etb_endian_memcpy16(void *dest, void *src, int size);
void	_ETB_EXPORT etb_endian_buffer_to_etcom(ETB_ETCOM *etcom, unsigned char *buffer, int buffer_size);
int		_ETB_EXPORT etb_endian_etcom_to_buffer(unsigned char *buffer, int size, ETB_ETCOM *etcom);
void	_ETB_EXPORT etb_etcom_sprintf(char *str, ETB_ETCOM *etcom);
int		_ETB_EXPORT etb_etcom_sizeof(int nb_param);
int		_ETB_EXPORT etb_etcom_record_sizeof(ETB_ETCOM *rec);

/*------------------------------------------------------------------------------
 * connection management functions
 *-----------------------------------------------------------------------------*/
int     _ETB_EXPORT etb_create_bus(ETB **retb);
int     _ETB_EXPORT etb_destroy_bus(ETB **retb);
bool    _ETB_EXPORT etb_is_valid_bus(ETB *etb);
int     _ETB_EXPORT etb_create_port(ETB_PORT **rport, ETB *etb);
int     _ETB_EXPORT etb_destroy_port(ETB_PORT **rport);
int     _ETB_EXPORT etb_create_spy_port(ETB_PORT **rport, ETB *etb);
int     _ETB_EXPORT etb_destroy_spy_port(ETB_PORT **rport);
bool    _ETB_EXPORT etb_is_valid_port(ETB_PORT *port);
int     _ETB_EXPORT etb_open(ETB *etb, const char *driver, dword flags, long baudrate, long timeout);
int     _ETB_EXPORT etb_reset(ETB *etb, dword flags, long baudrate, long timeout, bool deep);
int     _ETB_EXPORT etb_close(ETB *etb, dword flags, long timeout);
int     _ETB_EXPORT etb_is_open(ETB *etb, bool *open);
int     _ETB_EXPORT etb_get_bus(ETB_PORT *port, ETB **etb);
int     _ETB_EXPORT etb_get_driver(ETB *etb, char *buf, size_t max);
int     _ETB_EXPORT etb_get_flags(ETB *etb, dword *flags);
int		_ETB_EXPORT etb_set_rates(ETB *etb, int irq_rate, int status_rate, int mon_rate, int fast_rate, int slow_rate);
int	    _ETB_EXPORT etb_set_prio(ETB *etb, int prio);
int		_ETB_EXPORT etb_irq_watchdog(ETB *etb, int watchdog);
void	_ETB_EXPORT etb_bus_clear_watchdog(ETB *etb);
int		_ETB_EXPORT etb_read_1_slot(ETB *etb, int slot, dword *val);
int		_ETB_EXPORT etb_read_2_slot(ETB *etb, int slot1, int slot2, dword *val1, dword *val2);
int		_ETB_EXPORT etb_write_1_slot(ETB *etb, int slot, dword val);
int		_ETB_EXPORT etb_write_2_slot(ETB *etb, int slot1, int slot2, dword val1, dword val2);
int		_ETB_EXPORT etb_start_rtv_handler(ETB *etb, int nr, int rate, int delay, ETB_RTV_HANDLER handler, void *user);
int		_ETB_EXPORT etb_stop_rtv_handler(ETB *etb, int nr);
int		_ETB_EXPORT etb_etcom_diag(char_cp file_name, int line, int err, ETB *etb, eint64 mask);
int		_ETB_EXPORT etb_etcom_sdiag(char_p str, char_cp file_name, int line, int err, ETB *etb, eint64 mask);
int		_ETB_EXPORT etb_etcom_fdiag(char_cp output_file_name , char_cp file_name, int line, int err, ETB *etb, eint64 mask);

/*------------------------------------------------------------------------------
 * status/info access functions
 *-----------------------------------------------------------------------------*/
int     _ETB_EXPORT etb_get_bus_status(ETB *etb, int server, ETB_BUS_STATUS *stat);
int     _ETB_EXPORT etb_get_bus_timeouts(ETB *etb, ETB_TIMEOUTS *timeouts);
int     _ETB_EXPORT etb_get_svr_number(ETB *etb, int *number);
int     _ETB_EXPORT etb_get_svr_info(ETB *etb, int server, ETB_SVR_INFO *info);
int     _ETB_EXPORT etb_etcom_get_drv_present(ETB *etb, eint64 *present);
int     _ETB_EXPORT etb_etcom_get_drv_status(ETB *etb, int axis, ETB_DRV_STATUS *stat);
int     _ETB_EXPORT etb_etcom_get_drv_info(ETB *etb, int axis, ETB_DRV_INFO *info);
int     _ETB_EXPORT etb_etcom_get_ext_info(ETB *etb, int axis, ETB_EXT_INFO *info);
int     _ETB_EXPORT etb_etcom_get_master_info(ETB *etb, ETB_MASTER_INFO *info);

/*------------------------------------------------------------------------------
 * handlers management functions
 *-----------------------------------------------------------------------------*/
int     _ETB_EXPORT etb_add_bus_handler(ETB *etb, void *key, dword svr_mask, dword ev_mask, void (ETB_CALLBACK *handler)(ETB *, int, dword, void *), void *param);
int     _ETB_EXPORT etb_remove_bus_handler(ETB *etb, void *key);
int     _ETB_EXPORT etb_etcom_add_drv_handler(ETB *etb, void *key, eint64 axis_mask, bool and_mask, bool or_mask, dword ev_mask, void (ETB_CALLBACK *handler)(ETB *, int, dword, void *), void *param);
int     _ETB_EXPORT etb_remove_drv_handler(ETB *etb, void *key);
int     _ETB_EXPORT etb_add_msg_handler(ETB_PORT *port, void *key, void (ETB_CALLBACK *handler)(ETB_PORT *, void *), void *param);
int     _ETB_EXPORT etb_remove_msg_handler(ETB_PORT *port, void *key);

/*------------------------------------------------------------------------------
 * transaction support
 *-----------------------------------------------------------------------------*/
int     _ETB_EXPORT etb_begin_trans(ETB *etb, long timeout);
int     _ETB_EXPORT etb_end_trans(ETB *etb);

/*------------------------------------------------------------------------------
 * message handling functions
 *-----------------------------------------------------------------------------*/
int     _ETB_EXPORT etb_etcom_putm(ETB_PORT *port, const void *key, eint64 mask, ETB_CONST_REC ETB_ETCOM *rec, long timeout);
int     _ETB_EXPORT etb_etcom_putr(ETB_PORT *port, eint64 mask, ETB_CONST_REC ETB_ETCOM *rec, long timeout);
int     _ETB_EXPORT etb_etcom_getm(ETB_PORT *port, const void **key, eint64 *mask, ETB_ETCOM *rec, int max_param, dword *rx_time, long timeout);
int     _ETB_EXPORT etb_etcom_getr(ETB_PORT *port, eint64 *mask, ETB_ETCOM *rec, int max_param, dword *rx_time, long timeout);
/*------------------------------------------------------------------------------
 * boot control functions
 *-----------------------------------------------------------------------------*/
int     _ETB_EXPORT etb_change_boot_mode(ETB *etb, int mode);
int     _ETB_EXPORT etb_etcom_start_download(ETB *etb, eint64 mask, int block);
int     _ETB_EXPORT etb_etcom_start_upload_file(ETB *etb, eint64 mask, char *file_name, int *file_size);
int     _ETB_EXPORT etb_download_segment(ETB *etb, const char *buf, size_t size);
int     _ETB_EXPORT etb_etcom_start_upload(ETB *etb, int axis, int block);
int     _ETB_EXPORT etb_upload_segment(ETB *etb, char *buf, size_t size);
int		_ETB_EXPORT etb_get_block_size(int block, long *size);
bool    _ETB_EXPORT etb_is_block_available(int block, int prod);
bool	_ETB_EXPORT etb_is_block_available_for_version(int block, int prod, int version);
int		_ETB_EXPORT etb_etcom_download_firmware(ETB *etb, eint64 axis_mask, char *firmware, void (ETB_CALLBACK *user_fct)(int, int));
int		_ETB_EXPORT etb_get_firmware_info (char *firmware, ETB_FW_INFO *info);

int		_ETB_EXPORT etb_etn2_reserved_function1(ETB *etb);
int		_ETB_EXPORT etb_etn2_reserved_function2(ETB *etb);

/*@}*/

#ifdef __cplusplus
	} /* extern "C" */
#endif


/**********************************************************************************************************/
/*- C++ WRAPPER CLASSES */
/**********************************************************************************************************/

/*------------------------------------------------------------------------------
 * Etb handlers - c++
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	struct EtbDrvHandler;
	struct EtbEtcomDrvHandler;
	struct EtbBusHandler;
#endif

/*------------------------------------------------------------------------------
 * EtbSvrCommands class
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	/**
	 * @struct EtbSrvCommands
	 * Server (record 00h) command numbers
	 */
	struct EtbSvrCommands {
	public:
		enum { SVR_NUMBER = 0x11 };          /**< Get the number of remote servers in the chain */
		enum { SVR_INFO_0 = 0x12 };          /**< Get the product number and soft version of server */
		enum { SVR_INFO_1 = 0x13 };          /**< Get the serial number and boot version */
		enum { SVR_INFO_2 = 0x14 };          /**< Get the name first 8 bytes*/
		enum { SVR_TIMEOUTS_0 = 0x15 };      /**< Get the bus default timeouts of a remote server */
		enum { SVR_INFO_3 = 0x16 };          /**< Get the name last 8 bytes*/
		enum { SVR_STATUS_0 = 0x21 };        /**< Get the bus status of a remote server */
		enum { SVR_STATUS_IRQ_0 = 0x22 };    /**< The bus status interrupt of a remote server */
		enum { SVR_COUNTERS_0 = 0x25 };      /**< Get the bus counters of a remote server */
		enum { SVR_COUNTERS_IRQ_0 = 0x26 };  /**< The bus counters interrupt of a remote server */
		enum { SVR_KIND = 0x27 };            /**< Get the kind of the server */
		enum { CHANGE_BOOT_MODE = 0x31 };    /**< Change the boot mode of the remote drive */
		enum { START_DOWNLOAD = 0x32 };      /**< Start download of the remote drive */
		enum { DOWNLOAD_SEGMENT = 0x33 };    /**< Download a data segment in the remote drive */
		enum { START_UPLOAD = 0x34 };        /**< Start upload of the remote drive */
		enum { UPLOAD_SEGMENT = 0x35 };      /**< Upload a data segment in the remote drive */
		enum { OPEN = 0x41 };                /**< Open a new connection - first message */
		enum { RESET = 0x42 };               /**< Reset the current connection to the server */
		enum { CLOSE = 0x43 };               /**< Close the current connection - last message */
		enum { KEEP_ALIVE = 0x44 };          /**< Keep connection with the server alive */
		enum { START_IRQ = 0x45 };           /**< Ask server to start sendnig irqs when required */
		enum { PURGE_STOP = 0x46 };          /**< Purge queues and stop sending data / interrupts */
		enum { R_ALIVE_RATE = 0x60 };        /**< message to define timeout of connection break */
		enum { DOWNLOAD_DATA = 0xF1};        /**< start download of a set of data */
		enum { UPLOAD_DATA = 0xF3};	         /**< start upload of a set of data */
	};
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * EtbMagic class
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	/**
	 * @struct EtbMagic
	 * Magic commands for record 04/12/14
	 */
	struct EtbMagic {
	public:
		enum { PRESENT = 0x90 };             /**< Mark a drive present request (record 14) */
		enum { STATUS_DRV_0 = 0x90 };        /**< Mark a drive status request (record 12) */
		enum { STATUS_DRV_IRQ_0 = 0xA0 };    /**< Mark a drive status interrupt (record 12) */
		enum { INFO_DRV_0 = 0xB0 };          /**< Mark the first drive information request (record 12) */
		enum { INFO_DRV_1 = 0xC0 };          /**< Mark the second drive information request (record 12) */
		enum { INFO_DRV_2 = 0xC1 };          /**< Mark the third drive information request (record 12) */
		enum { INFO_DRV_3 = 0xC2 };          /**< Mark the fourth drive information request (record 12) */
		enum { INFO_DRV_4 = 0xC3 };          /**< Mark the fifth drive information request (record 12) */
		enum { INFO_DRV_5 = 0xC4 };          /**< Mark the sixth drive information request (record 12) */
		enum { INFO_DRV_6 = 0xC5 };          /**< Mark the seventh drive information request (record 12) */
		enum { INFO_EXT_0 = 0xD0 };          /**< Mark the first extension card information request (record 12) */
		enum { INFO_EXT_1 = 0xE0 };          /**< Mark the second extension card information request (record 12) */
	};
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * EtbBusEvent class
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	/**
	 * @struct EtbBusEvent
	 * Etel bus handler structure
	 */
	struct EtbBusEvent {
	public:
		enum { ERROR_SET = 0x00000001 };      /**< The error bit has been set */
		enum { ERROR_CLR = 0x00000002 };      /**< The error bit has been cleared */
		enum { ERROR_BIT = 0x00000003 };      /**< The error bit has changed */
		enum { WARNING_SET = 0x00000004 };    /**< The warning bit has been set */
		enum { WARNING_CLR = 0x00000008 };    /**< The warning bit has been cleared */
		enum { WARNING_BIT = 0x0000000C };    /**< The warning bit has changed */
		enum { RESET_SET =  0x00000010 };     /**< The driver has entered reset mode */
		enum { RESET_CLR = 0x00000020 };      /**< The driver has exited reset mode */
		enum { RESET_BIT = 0x00000030 };      /**< The reset bit has changed */
		enum { OPEN_SET = 0x00000040 };       /**< The driver is open */
		enum { OPEN_CLR = 0x00000080 };       /**< The driver is closed */
		enum { OPEN_BIT = 0x000000C0 };       /**< The open bit has changed */
		enum { WATCHDOG_SET =  0x00000100 };  /**< the watchdog bit has been set */
		enum { WATCHDOG_CLR = 0x00000200 };   /**< the watchdog bit has been cleared */
		enum { WATCHDOG_BIT = 0x00000300 };   /**< The watchdog bit has changed */
		enum { STATUS_BIT = 0x00001000 };     /**< The bus status has changed */
	};
#endif

/*------------------------------------------------------------------------------
 * EtbDrvPresent class
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	/**
	 * @struct EtbDrvPresent
	 * Etel bus drive event
	 */
	struct EtbDrvEvent {
	public:
		enum { ERROR_SET = 0x00000001 };      /**< One of the error bit has been set */
		enum { ERROR_CLR = 0x00000002 };      /**< One of the error bit has been cleared */
		enum { ERROR_BIT = 0x00000003 };      /**< One of the error bit has changed */
		enum { WARNING_SET = 0x00000004 };    /**< One of the warning bit has been set */
		enum { WARNING_CLR = 0x00000008 };    /**< One of the warning bit has been cleared */
		enum { WARNING_BIT = 0x0000000C };    /**< One of the warning bit has changed */
		enum { PRESENT_SET = 0x00000010 };    /**< A new drive is present */
		enum { PRESENT_CLR = 0x00000020 };    /**< A drive has disappeared */
		enum { PRESENT_BIT = 0x00000030 };    /**< The present bit has changed */
		enum { STATUS_1 = 0x00000100 };       /**< The first status word has changed */
		enum { STATUS_2 = 0x00000200 };       /**< The second status word has changed */
		enum { STATUS_BIT = 0x00000300 };     /**< One of the status word has changed */
		enum { USER = 0x00001000 };           /**< The user field has changed */
	};
#endif

/*------------------------------------------------------------------------------
 * Etb base class - c++
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	class Etb {
		/*
		 * some public constants
		 */
	public:
		enum { ETCOM_DRIVES = ETB_ETCOM_DRIVES };     /* the maximum number of drives in an new bus type like */
													  /* UltimET, USB for AccurET */
													  /* The records passing on these kinds of bus are ETB_ETCOM */
		enum { SERVERS = ETB_SERVERS };				  /* the maximum number of servers in the path */

		/*
		 * etb special axis number
		 */
	public:
		enum { ALL_AXIS = 0x40 };                        /* special axis value meaning all axis*/

		/*
		 * timeout special values
		 */
	public:
		enum { DEF_TIMEOUT = (-2L) };                    /* use the default timeout appropriate for this communication */

		/*
		 * versions access
		 */
	public:
		static dword getVersion() {
			return etb_get_version();
		}
		static dword getEdiVersion() {
			return etb_get_edi_version();
		}
		static time_t getBuildTime() {
			return etb_get_build_time();
		}
		static long getTimer() {
			return etb_get_timer();
		}
	};
#endif /* ETB_OO_API */


/*------------------------------------------------------------------------------
 * Etb exception - c++
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	class EtbException {
	friend class EtbBus;
	friend class EtbPortBase;
	friend class EtbPort;
	friend class EtbSpyPort;
	friend class EtbTraductor;
		/*
		 * public error codes
		 */
	public:
		    enum {EBADDRIVER = -293 };                      /* wrong version of the installed device driver */
    enum {EBADDRVVER = -218 };                      /* a drive with a too old version has been detected */
    enum {EBADFIRMWARE = -200 };                    /* file is not a firmware file */
    enum {EBADHOST = -253 };                        /* the specified host address cannot be translated */
    enum {EBADLIBRARY = -217 };                     /* function of external library not found */
    enum {EBADMODE = -225 };                        /* the drive is in a bad mode */
    enum {EBADMSG = -219 };                         /* a bad message is given */
    enum {EBADOS = -270 };                          /* function unavilable on actual OS */
    enum {EBADPARAM = -215 };                       /* one of the parameter is not valid */
    enum {EBADSERVER = -224 };                      /* a bad/incompatible server was found */
    enum {EBADSTATE = -222 };                       /* this operation is not allowed in this state */
    enum {EBAUDRATE = -292 };                       /* matching baudrate not found */
    enum {EBOOTENTER = -261 };                      /* cannot enter in boot mode */
    enum {EBOOTFAILED = -229 };                     /* a problem has occured while communicating with the boot */
    enum {EBOOTHEADER = -262 };                     /* bad header in boot protocol */
    enum {EBOOTPASSWD = -260 };                     /* bad password when enter in boot mode */
    enum {EBOOTPROG = -263 };                       /* bad block programming */
    enum {EBUSERROR = -220 };                       /* the underlaying etel-bus is in error state */
    enum {EBUSRESET = -221 };                       /* the underlaying etel-bus in performing a reset operation */
    enum {ECHECKSUM = -249 };                       /* checksum error with serial communication */
    enum {ECRC = -230 };                            /* a CRC error has occured */
    enum {EFLASHDEV = -280 };                       /* unable to open flash device */
    enum {EFLASHINFO = -281 };                      /* unable to read flash information */
    enum {EFLASHNOTLOCKED = -285 };                 /* flash not locked */
    enum {EFLASHPROTECTED = -284 };                 /* flash protected */
    enum {EFLASHREAD = -282 };                      /* unable to read flash */
    enum {EFLASHWRITE = -283 };                     /* unable to write flash */
    enum {EFPGAFILENOTFOUND = -291 };               /* FPGA file is not found in path */
    enum {EGPIODEV = -286 };                        /* cannot open the gpio device */
    enum {EINTERNAL = -212 };                       /* some internal error in the etel software */
    enum {EMASTER = -213 };                         /* cannot enter or quit master mode */
    enum {ENETWORK = -252 };                        /* network problem */
    enum {ENODRIVE = -214 };                        /* the specified drive does not respond */
    enum {ENOLIBRARY = -216 };                      /* external library not found */
    enum {EOBSOLETE = -202 };                       /* function is obsolete */
    enum {EOPENCOM = -240 };                        /* the specified communication port cannot be opened */
    enum {EOPENSOCK = -250 };                       /* the specified socket connection cannot be opened */
    enum {ERECTOSMALL = -201 };                     /* size of received record too small */
    enum {ERTVREADSYNCRO = -294 };                  /* RTV read synchronisation error */
    enum {ESERVER = -223 };                         /* the server has incorrect behavior */
    enum {ESOCKRESET = -251 };                      /* the socket connection has been broken by peer */
    enum {ESYSTEM = -211 };                         /* some system resource return an error */
    enum {ETIMEOUT = -210 };                        /* a timeout has occured */
    enum {ETOOSMALL = -203 };                       /* the size of the record table is too small */
    enum {EUNAVAILABLE = -290 };                    /* function not available for the driver */




		/*
		 * error translation
		 */
	public:
		static const char *translate(int code) {
			return etb_translate_error(code);
		}

		/*
		 * exception code
		 */
	private:
		int code;

		/*
		 * constructor
		 */
	protected:
		EtbException(int e) { code = e; };

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
#endif /* ETB_OO_API */


/*------------------------------------------------------------------------------
 * Bus class - c++
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	#define ERRCHK(a) do { int _err = (a); if (_err) throw EtbException(_err); } while(0)
	class EtbBus {
	friend class EtbPortBase;
	friend class EtbPort;
	friend class EtbSpyPort;
		/*
		 * internal etb pointer
		 */
	protected:
		ETB *etb;

		/*
		 * open/reset/close flags
		 */
	public:
		enum { FLAG_BOOT_RUN =           0x00000001 }; /* assumes that the drive is in run mode */
		enum { FLAG_BOOT_DIRECT =        0x00000002 }; /* assumes that the drive is in boot mode */
		enum { FLAG_BOOT_BRIDGE =        0x00000004 }; /* assumes that the drive is in boot bridge mode */

		enum { FLAG_RESET_MASTER =       0x20000000 }; /* reset the master (used only with DSMAX) */
		enum { FLAG_RESET_SLAVES =       0x40000000 }; /* reset all slaves (used only with DSC) */

		/*
		 * boot modes
		 */
	public:
		enum { BOOT_MODE_RUN = 0 };                      /* drive run mode - normal operation */
		enum { BOOT_MODE_DIRECT = 1 };                   /* direct communication to the connected drive boot */
		enum { BOOT_MODE_BRIDGE = 2 };                   /* allows access to etel bus slave boot */

		/*
		 * special axis number
		 */
	public:
		enum { AXIS_AND = (-2) };                        /* and value of the status bits of all drives presents */
		enum { AXIS_OR = (-1) };                         /* or value of the status bits of all drives presents */

		/*
		 * constructors
		 */
	public:
		EtbBus() {
			etb = NULL;
			etb_create_bus(&etb);
		}
	protected:
		EtbBus(ETB *b) {
			etb = b;
		};
	public:
		bool isValid() {
			return etb_is_valid_bus(etb);
		}

		/*
		 * destructor function
		 */
		void destroy() {
			ERRCHK(etb_destroy_bus(&etb));
		}

		/*
		 * connection management functions
		 */
	public:
		void open(const char *s, dword flags, long baudrate = 0, long timeout = 0) {
			ERRCHK(etb_open(etb, s, flags, baudrate, timeout));
		}
		void reset(dword flags = 0, long baudrate = 0, long timeout = 0, bool deep = false) {
			ERRCHK(etb_reset(etb, flags, baudrate, timeout, deep));
		}
		void close(dword flags = 0, long timeout = 0) {
			ERRCHK(etb_close(etb, flags, timeout));
		}
		bool isOpen() {
			bool open;
			ERRCHK(etb_is_open(etb, &open));
			return open;
		}
		void getDriver(char *buf, size_t max) {
			ERRCHK(etb_get_driver(etb, buf, max));
		}
		dword getFlags() {
			dword flags;
			ERRCHK(etb_get_flags(etb, &flags));
			return flags;
		}
		void etcomDiag(char_cp file_name, int line, int err, eint64 mask) {
			ERRCHK(etb_etcom_diag(file_name, line, err, etb, mask));
		}
		void etcomSdiag(char_p str, char_cp file_name, int line, int err, eint64 mask) {
			ERRCHK(etb_etcom_sdiag(str, file_name, line, err, etb, mask));
		}
		void etcomFdiag(char_cp output_file_name, char_cp file_name, int line, int err, eint64 mask) {
			ERRCHK(etb_etcom_fdiag(output_file_name, file_name, line, err, etb, mask));
		}

		/*
		 * status/info access functions
		 */
	public:
		EtbBusStatus getBusStatus(int server) {
			ETB_BUS_STATUS status;
			memset(&status, 0, sizeof(ETB_BUS_STATUS));
			status.size = sizeof(ETB_BUS_STATUS);
			ERRCHK(etb_get_bus_status(etb, server, &status));
			return status;
		}
		EtbTimeouts getBusTimeouts() {
			ETB_TIMEOUTS timeouts;
			memset(&timeouts, 0, sizeof(ETB_TIMEOUTS));
			timeouts.size = sizeof(ETB_TIMEOUTS);
			ERRCHK(etb_get_bus_timeouts(etb, &timeouts));
			return timeouts;
		}
		int getSvrNumber() {
			int number;
			ERRCHK(etb_get_svr_number(etb, &number));
			return number;
		}
		EtbSvrInfo getSvrInfo(int server) {
			ETB_SVR_INFO info;
			memset(&info, 0, sizeof(ETB_SVR_INFO));
			info.size = sizeof(ETB_SVR_INFO);
			ERRCHK(etb_get_svr_info(etb, server, &info));
			return info;
		}
		eint64 etcomGetDrvPresent() {
			eint64 mask;
			ERRCHK(etb_etcom_get_drv_present(etb, &mask));
			return mask;
		}
		EtbDrvStatus getEtcomDrvStatus(int axis) {
			ETB_DRV_STATUS status;
			memset(&status, 0, sizeof(ETB_DRV_STATUS));
			status.size = sizeof(ETB_DRV_STATUS);
			ERRCHK(etb_etcom_get_drv_status(etb, axis, &status));
			return status;
		}
		EtbDrvInfo getEtcomDrvInfo(int axis) {
			ETB_DRV_INFO info;
			memset(&info, 0, sizeof(ETB_DRV_INFO));
			info.size = sizeof(ETB_DRV_STATUS);
			ERRCHK(etb_etcom_get_drv_info(etb, axis, &info));
			return info;
		}
		EtbMasterInfo getEtcomMasterInfo() {
			ETB_MASTER_INFO info;
			memset(&info, 0, sizeof(ETB_MASTER_INFO));
			info.size = sizeof(ETB_MASTER_INFO);
			ERRCHK(etb_etcom_get_master_info(etb, &info));
			return info;
		}
		EtbExtInfo getEtcomExtInfo(int axis) {
			ETB_EXT_INFO info;
			memset(&info, 0, sizeof(ETB_EXT_INFO));
			info.size = sizeof(ETB_EXT_INFO);
			ERRCHK(etb_etcom_get_ext_info(etb, axis, &info));
			return info;
		}

		/*
		 * handler management functions
		 */
	public:
		void addBusHandler(void *key, dword svr_mask, dword ev_mask, void (ETB_CALLBACK *handler)(EtbBus, int, dword, void *), void *param) {
			ERRCHK(etb_add_bus_handler(etb, key, svr_mask, ev_mask, (void (ETB_CALLBACK *)(ETB *, int, dword, void *))handler, param));
		}
		void removeBusHandler(void *key) {
			ERRCHK(etb_remove_bus_handler(etb, key));
		}
		void etcomAddDrvHandler(void *key, eint64 axis_mask, bool and_mask, bool or_mask, dword ev_mask, void (ETB_CALLBACK *handler)(EtbBus, int, dword, void *), void *param) {
			ERRCHK(etb_etcom_add_drv_handler(etb, key, axis_mask, and_mask, or_mask, ev_mask, (void (ETB_CALLBACK *)(ETB *, int, dword, void *))handler, param));
		}
		void removeDrvHandler(void *key) {
			ERRCHK(etb_remove_drv_handler(etb, key));
		}
		/*
		 * transaction support
		 */
		void beginTrans(long timeout) {
			ERRCHK(etb_begin_trans(etb, timeout));
		}
		void endTrans() {
			ERRCHK(etb_end_trans(etb));
		}

		/*
		 * boot control functions
		 */
	public:
		void changeBootMode(int mode) {
			ERRCHK(etb_change_boot_mode(etb, mode));
		}
		void etcomStartDownload(eint64 mask, int block) {
			ERRCHK(etb_etcom_start_download(etb, mask, block));
		}
		void downloadSegment(const char *buf, size_t size) {
			ERRCHK(etb_download_segment(etb, buf, size));
		}
		void etcomStartUpload(int axis, int block) {
			ERRCHK(etb_etcom_start_upload(etb, axis, block));
		}
		void uploadSegment(char *buf, size_t size) {
			ERRCHK(etb_upload_segment(etb, buf, size));
		}
		long getBlockSize(int block) {
			long size;
			ERRCHK(etb_get_block_size(block, &size));
			return size;
		}
		void setPrio(int prio) {
			ERRCHK(etb_set_prio(etb, prio));
		}
		void setRates(int irq_rate, int status_rate, int mon_rate, int fast_rate, int slow_rate) {
			ERRCHK(etb_set_rates(etb, irq_rate, status_rate, mon_rate, fast_rate, slow_rate));
		}
		void irq_watchdog(int watchdog) {
			ERRCHK(etb_irq_watchdog(etb, watchdog));
		}
		void clearWatchdog() {
			etb_bus_clear_watchdog(etb);
		}
		void etcomDownloadFirmware(eint64 axis_mask, char *firmware, void (ETB_CALLBACK *user_fct)(int, int)) {
			ERRCHK(etb_etcom_download_firmware(etb, axis_mask, firmware, (void (ETB_CALLBACK *)(int, int))user_fct));
		}
		void read1Slot(int slot, dword *value) {
			ERRCHK(etb_read_1_slot(etb, slot, value));
		}
		void read2Slot(int slot1, int slot2, dword *value1, dword *value2) {
			ERRCHK(etb_read_2_slot(etb, slot1, slot2, value1, value2));
		}
		void write1Slot(int slot, dword value) {
			ERRCHK(etb_write_1_slot(etb, slot, value));
		}
		void write2Slot(int slot1, int slot2, dword value1, dword value2) {
			ERRCHK(etb_write_2_slot(etb, slot1, slot2, value1, value2));
		}
		void startRTVHandler(int nr, int rate, int delay, ETB_RTV_HANDLER handler, void *user) {
			ERRCHK(etb_start_rtv_handler(etb, nr, rate, delay, handler, user));
		}
		void stopRTVHandler(int nr) {
			ERRCHK(etb_stop_rtv_handler(etb, nr));
		}
	};
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * Port Base class - c++
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	class EtbPortBase {
		/*
		 * internal etb pointer
		 */
	protected:
		ETB_PORT *port;

	public:
		bool isValid() {
			return etb_is_valid_port(port);
		}
		EtbBus getBus() {
			ETB *etb;
			ERRCHK(etb_get_bus(port, &etb));
			EtbBus bus(etb);
			return bus;
		}

		/*
		 * handler management functions
		 */
	public:
		void addMsgHandler(void *key, void (ETB_CALLBACK *handler)(EtbPort, void *), void *param) {
			ERRCHK(etb_add_msg_handler(port, key, (void (ETB_CALLBACK *)(ETB_PORT *, void *))handler, param));
		}
		void removeMsgHandler(void *key) {
			ERRCHK(etb_remove_msg_handler(port, key));
		}

		/*
		 * message handling functions
		 */
	public:
		EtbEtcomMax etcomGetMsg(eint64 *mask, const void **key = NULL, dword *rx_time = NULL, long timeout = 0) {
			EtbEtcomMax rec;
			ERRCHK(etb_etcom_getm(port, key, mask, (ETB_ETCOM *)&rec, ETB_ETCOM_MAX_PARAM, rx_time, timeout));
			return rec;
		}
		EtbEtcomMax etcomGetRec(eint64 *mask = NULL, dword *rx_time = NULL, long timeout = 0) {
			EtbEtcomMax rec;
			ERRCHK(etb_etcom_getr(port, mask, (ETB_ETCOM *)&rec, sizeof(ETB_ETCOMMAX), rx_time, timeout));
			return rec;
		}
	};
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * Port class - c++
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	class EtbPort : public EtbPortBase {
		/*
		 * constructors
		 */
	public:
		EtbPort(EtbBus etb) {
			port = NULL;
			etb_create_port(&port, etb.etb);
		}
	protected:
		EtbPort(ETB_PORT *p) {
			port = p;
		};

		/*
		 * destructor function
		 */
	public:
		void destroy() {
			ERRCHK(etb_destroy_port(&port));
		}

		/*
		 * message handling functions
		 */
	public:
		void etcomPutMsg(dword mask, const EtbEtcom &rec, const void *key = NULL, long timeout = 0) {
			ERRCHK(etb_etcom_putm(port, key, mask, (const ETB_ETCOM *)&rec, timeout));
		}
		void etcomPutRec(eint64 mask, const EtbEtcom &rec, long timeout = 0) {
			ERRCHK(etb_etcom_putr(port, mask, (const ETB_ETCOM *)&rec, timeout));
		}
	};
#endif /* ETB_OO_API */

/*------------------------------------------------------------------------------
 * Spy Port class - c++
 *-----------------------------------------------------------------------------*/
#ifdef ETB_OO_API
	class EtbSpyPort : public EtbPortBase {
		/*
		 * constructors
		 */
	public:
		EtbSpyPort(EtbBus etb) {
			port = NULL;
			etb_create_spy_port(&port, etb.etb);
		}
	protected:
		EtbSpyPort(ETB_PORT *p) {
			port = p;
		};

		/*
		 * destructor function
		 */
	public:
		void destroy() {
			ERRCHK(etb_destroy_spy_port(&port));
		}
	};
#endif /* ETB_OO_API */

#ifdef ETB_OO_API
typedef void (ETB_CALLBACK *EtbIsoConverter)(EtbBus bus, EtbEtcomValue *incr, double *iso, int incr_type, int conv, int axis, bool to_iso, void *user);
#endif /* ETB_OO_API */

#undef ERRCHK

#endif /* _etb40_H */

