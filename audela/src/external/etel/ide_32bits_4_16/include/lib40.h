/*
 *
 * Copyright (c) 1997-2015 ETEL SA. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of ETEL SA 
 * ("Confidential Information"). You shall not disclose such Confidential 
 * Information and shall use it only in accordance with the terms of the 
 * license agreement you entered into with ETEL.
 *
 * This software is provided "AS IS" without a warranty or representations of any kind. 
 * ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED WARRANTY 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT ARE HEREBY EXCLUDED. ETEL AND ITS 
 * LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING 
 * THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL ETEL OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR 
 * DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS 
 * OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE SOFTWARE, EVEN IF ETEL HAS BEEN ADVISED OF 
 * THE POSSIBILITY OF SUCH DAMAGES. THE ENTIRE RISK ARISING OUT OF USE, PERFORMANCE OR NON-PERFORMANCE OF THE SOFTWARE 
 * REMAINS WITH THE LICENSEE. IF ETEL SHOULD NEVERTHELESS BE FOUND LIABLE, WHETER DIRECTLY OR INDRECTLY, FOR ANY LOSS, 
 * DAMAGE OR INJURY ARISING UNDER THIS AGREEMENT OR OTHERWISE, REGARDLESS OF CAUSE OR ORIGIN, ON ANY BASIS WHATSOEVER, 
 * ITS TOTAL MAXIMUM LIABILITY IS LIMITED TO CHF 100.000 WHICH WILL BE THE COMPLETE AND EXCLUSIVE REMEDY AGAINST ETEL.

 * This software is in particular not designed or intended .for use in on-line control of aircraft, air traffic, aircraft 
 * navigation or aircraft communications; or in the design, construction, Operation or maintenance of any nuclear facility. 
 * Licensee represents and warrants that it will not use or redistribute the Software for such purposes.
 */

/**********************************************************************************************
									THIRD-PARTY LICENSE

EDI Windows version uses 7ZIP functionality, especially for System Configuration Management.
7z.exe and 7z.dll are piece of binary code, provided with EDI package.
The source code can be found here: http://www.7-zip.org
These piece of program are subject to following licensing:
---------------------------------------------------------------------------
  7-Zip
  ------
  License for use and distribution
  --------------------------------

  7-Zip Copyright (C) 1999-2011 Igor Pavlov.

  Licenses for files are:

    1) 7z.dll: GNU LGPL + unRAR restriction
    2) All other files:  GNU LGPL

  The GNU LGPL + unRAR restriction means that you must follow both 
  GNU LGPL rules and unRAR restriction rules.


  Note: 
    You can use 7-Zip on any computer, including a computer in a commercial 
    organization. You don't need to register or pay for 7-Zip.


  GNU LGPL information
  --------------------

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You can receive a copy of the GNU Lesser General Public License from 
    http://www.gnu.org/


  unRAR restriction
  -----------------

    The decompression engine for RAR archives was developed using source 
    code of unRAR program.
    All copyrights to original unRAR code are owned by Alexander Roshal.

    The license for original unRAR code has the following restriction:

      The unRAR sources cannot be used to re-create the RAR compression algorithm, 
      which is proprietary. Distribution of modified unRAR sources in separate form 
      or as a part of other software is permitted, provided that it is clearly
      stated in the documentation and source comments that the code may
      not be used to develop a RAR (WinRAR) compatible archiver.


  --
  Igor Pavlov
---------------------------------------------------------------------------

**********************************************************************************************************/

/**
 * this header file contains public declaration for low-level library. it also
 * contains macro-definition for real-time objects/operations used to achieve
 * multi-platform source code.
 * @library lib40
 */

#ifndef _LIB40_H
#define _LIB40_H

#ifdef __cplusplus
	extern "C" {
#endif /* __cplusplus */

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
		#endif /*__BIGENDIAN__*/
	#endif /*QNX6*/

	/*------------------------------*/
	/* VXWORKS Byte order			*/
	#if defined VXWORKS_6_9
		#include <vxWorks.h>							//to define the endianness, needed to define the architecture
		#define __LITTLE_ENDIAN 1234
		#define __BIG_ENDIAN 4321
		#ifdef _BYTE_ORDER
			#if (_BYTE_ORDER == _BIG_ENDIAN)			//VxWorks 6.9 defines _BIG_ENDIAN or _LITTLE_ENDIAN
				#define __BYTE_ORDER __BIG_ENDIAN
			#else
				#define __BYTE_ORDER __LITTLE_ENDIAN
			#endif
		#else
			ERROR _BYTE_ORDER NOT DEFINED
		#endif
	#endif /*VXWORKS_6_9*/

	/*------------------------------*/
	/* F_ITRON Byte order			*/
	#if defined F_ITRON
		#define __LITTLE_ENDIAN 1234
		#define __BIG_ENDIAN 4321
		#define __BYTE_ORDER __LITTLE_ENDIAN			
	#endif /*F_ITRON*/

#endif /*BYTE_ORDER*/


/**********************************************************************************************************/
/*- LIBRARIES */
/**********************************************************************************************************/

/*-----------------------*/
/* Windows RTX libraries */
#ifdef WIN32
	#ifdef UNDER_RTSS
		#include <windows.h>
		#include <RtApi.h>

	/*-----------------------*/
	/* Windows W32 libraries */
	#else
		#include <windows.h>
		#include "jni.h"
	#endif /*UNDER_RTSS */
#endif /* WIN32 */

/*-----------------------*/
/* Common libraries*/
#include <stddef.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#ifdef WIN32
	#include <time.h>
	#ifdef _MSC_VER
		#if _MSC_VER >= 1600
			#include <stdint.h>
		#else
			typedef unsigned int uint32_t;
		#endif /* _MSC_VER >= 1600*/
	#else
		typedef unsigned int uint32_t;
	#endif /*_MSC_VER*/
#endif /*WIN32*/

/*----------------------*/
/* POSIX LINUX libraries*/
#if defined POSIX && defined LINUX
	#include <time.h>
	#include <stdint.h>
	#include <pthread.h>
	#include <sys/select.h>
	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <netdb.h>
	#include <arpa/inet.h>
	#include <sys/resource.h>
	#include <semaphore.h>
	#include <unistd.h>
	#include <time.h>
	#include <errno.h>
	#include <math.h>
#endif /*LINUX*/

/*----------------------*/
/* POSIX-QNX6 libraries*/
#if defined POSIX && defined QNX6
	#include <time.h>
	#include <stdint.h>
	#include <pthread.h>
	#include <sys/select.h>
	#include <sys/socket.h>
	#include <sys/types.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include <semaphore.h>
	#include <netdb.h>
	#include <unistd.h>
#endif /* QNX6 */

/*----------------------*/
/* VXWORKS libraries*/
#ifdef VXWORKS_6_9
	#include <sys/select.h>
	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <netdb.h>
	#include <arpa/inet.h>
	#include <sys/resource.h>
	#include <semaphore.h>
	#include <unistd.h>
	#include <time.h>
	#include <stdint.h>
	#include <errno.h>
	#include <math.h>
    #ifdef POSIX 		
    	#include <pthread.h>
    #endif /*VX_WORKS_6_9 && POSIX*/
    #ifdef NATIVE 		
	    #include <taskLib.h>
		#include <semLib.h>
    #endif /*VX_WORKS_6_9 && NATIVE*/
#endif /*VXWORKS_6_9 */

/*----------------------*/
/* F_ITRON libraries*/
#ifdef F_ITRON
	#include <ctype.h>
	#include <OS_IF/os_api.h>
	#include <File_api.h>
	#include <FjComm.h>
	#include <time.h>
#endif /*F_ITRON */

/**********************************************************************************************************/
/*- LITERALS */
/**********************************************************************************************************/

#define PRO_PAR                          1           /* pro parameter used with this platform */

/*------------------------------------------------------------------------------
 * infinite (no) timeout special value
 *-----------------------------------------------------------------------------*/
#ifndef INFINITE
	#define INFINITE                        (-1)
#endif

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
 * return value of wait functions
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* POSIX return value of wait functions		*/
#if defined POSIX || defined VXWORKS_6_9 
	#define WAIT_OBJECT_0   0
	#define WAIT_TIMEOUT    -1
	#define WAIT_FAILED     -2
#endif /*POSIX || defined VXWORKS_6_9 */

/*------------------------------------------*/
/* F_ITRON return value of wait functions	*/
#ifdef F_ITRON
	#define WAIT_OBJECT_0   0
	#define WAIT_TIMEOUT    -1
	#define WAIT_FAILED     -2
#endif /*F_ITRON*/

/*------------------------------------------*/
/* F_ITRON synchronization objectes			*/
#ifdef F_ITRON
	#define SYNC_OBJ_TLS 100
#endif /*F_ITRON*/
/*------------------------------------------------------------------------------
 * thread priority levels
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* POSIX-LINUX thread priority levels		*/
#if defined POSIX && defined LINUX
	#define THREAD_PRIORITY_IDLE                20
	#define THREAD_PRIORITY_LOWEST              10
	#define THREAD_PRIORITY_BELOW_NORMAL        5
	#define THREAD_PRIORITY_NORMAL              0
	#define THREAD_PRIORITY_ABOVE_NORMAL        -5
	#define THREAD_PRIORITY_HIGHEST             -10
	#define THREAD_PRIORITY_TIME_CRITICAL       -20
#endif /* POSIX &&LINUX */

/*------------------------------------------*/
/* POSIX-QNX6 thread priority levels		*/
#if defined POSIX && defined QNX6
	#define THREAD_PRIORITY_IDLE                1
	#define THREAD_PRIORITY_LOWEST              10
	#define THREAD_PRIORITY_BELOW_NORMAL        12
	#define THREAD_PRIORITY_NORMAL              15
	#define THREAD_PRIORITY_ABOVE_NORMAL        18
	#define THREAD_PRIORITY_HIGHEST             20
	#define THREAD_PRIORITY_TIME_CRITICAL       30
#endif /* POSIX &&QNX6 */

/*------------------------------------------*/
/* VXWORKS thread priority levels			*/
/* Highest priority is 0 */
/* Should not be higher than 50 (priority < 50), because tNetTask runs at priority 50 */
#ifdef VXWORKS_6_9
	#ifdef NATIVE
		#define THREAD_PRIORITY_IDLE                170
		#define THREAD_PRIORITY_LOWEST              160
		#define THREAD_PRIORITY_BELOW_NORMAL        155
		#define THREAD_PRIORITY_NORMAL              150
		#define THREAD_PRIORITY_ABOVE_NORMAL        145
		#define THREAD_PRIORITY_HIGHEST             140
		#define THREAD_PRIORITY_TIME_CRITICAL       130
    #endif /*VXWORKS_6_9 && NATIVE */ 
	#ifdef POSIX
		#define THREAD_PRIORITY_IDLE                85			//VxWorks 255-085 = 170
		#define THREAD_PRIORITY_LOWEST              95			//VxWorks 255-095 = 160
		#define THREAD_PRIORITY_BELOW_NORMAL        100			//VxWorks 255-100 = 155
		#define THREAD_PRIORITY_NORMAL              105			//VxWorks 255-105 = 150
		#define THREAD_PRIORITY_ABOVE_NORMAL        110			//VxWorks 255-110 = 145
		#define THREAD_PRIORITY_HIGHEST             115			//VxWorks 255-115 = 140
		#define THREAD_PRIORITY_TIME_CRITICAL       125			//VxWorks 255-125 = 130
    #endif /*VXWORKS_6_9 && POSIX */ 
#endif /* VXWORKS_6_9 */

/*------------------------------------------*/
/* F_ITRON thread priority levels			*/
#ifdef F_ITRON
	#define THREAD_PRIORITY_IDLE                OS_PRI_IDLE			//0x7F
	#define THREAD_PRIORITY_LOWEST              OS_PRI_APL_BTM		//0x60
	#define THREAD_PRIORITY_BELOW_NORMAL        OS_PRI_APL_TOP+7	//0x58	
	#define THREAD_PRIORITY_NORMAL              OS_PRI_APL_TOP+5	//0x56
	#define THREAD_PRIORITY_ABOVE_NORMAL        OS_PRI_APL_TOP+4	//0x55
	#define THREAD_PRIORITY_HIGHEST             OS_PRI_APL_TOP+2	//0x53
	#define THREAD_PRIORITY_TIME_CRITICAL       OS_PRI_APL_TOP 		//0x51
#endif /* F_ITRON */

/*------------------------------------------------------------------------------
 * EDI thread priority levels remapping
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* RTX priority levels		*/
#if defined UNDER_RTSS
	#define EDI_THREAD_PRIORITY_IDLE            0
	#define EDI_THREAD_PRIORITY_LOWEST          20
	#define EDI_THREAD_PRIORITY_BELOW_NORMAL    40
	#define EDI_THREAD_PRIORITY_NORMAL          64
	#define EDI_THREAD_PRIORITY_ABOVE_NORMAL    88
	#define EDI_THREAD_PRIORITY_HIGHEST         108
	#define EDI_THREAD_PRIORITY_TIME_CRITICAL   127
#else
	#define EDI_THREAD_PRIORITY_IDLE            THREAD_PRIORITY_IDLE
	#define EDI_THREAD_PRIORITY_LOWEST          THREAD_PRIORITY_LOWEST
	#define EDI_THREAD_PRIORITY_BELOW_NORMAL    THREAD_PRIORITY_BELOW_NORMAL
	#define EDI_THREAD_PRIORITY_NORMAL          THREAD_PRIORITY_NORMAL
	#define EDI_THREAD_PRIORITY_ABOVE_NORMAL    THREAD_PRIORITY_ABOVE_NORMAL
	#define EDI_THREAD_PRIORITY_HIGHEST         THREAD_PRIORITY_HIGHEST
	#define EDI_THREAD_PRIORITY_TIME_CRITICAL   THREAD_PRIORITY_TIME_CRITICAL
#endif // UNDER_RTSS

/*------------------------------------------------------------------------------
 * debug constants - kind of event
 *-----------------------------------------------------------------------------*/
#define DBG_KIND_INFORMATION                0x01
#define DBG_KIND_WARNING                    0x02
#define DBG_KIND_ERROR                      0x03
#define DBG_KIND_FATAL_ERROR                0x04
#define DBG_KIND_STREAM_IN                  0x05
#define DBG_KIND_STREAM_OUT                 0x06
#define DBG_KIND_FCT_BEGIN                  0x07
#define DBG_KIND_FCT_END                    0x08
#define DBG_KIND_MEM_ALLOC                  0x09


/*------------------------------------------------------------------------------
 * debug constants - source of event
 *-----------------------------------------------------------------------------*/
#define DBG_SOURCE_LIB                      0x01
#define DBG_SOURCE_DMD                      0x02
#define DBG_SOURCE_ETB                      0x04
#define DBG_SOURCE_TRA                      0x05
#define DBG_SOURCE_DSA                      0x06
#define DBG_SOURCE_ETN                      0x10


/*------------------------------------------------------------------------------
 * debug constants - kind of stream
 *-----------------------------------------------------------------------------*/
#define DBG_STREAM_SHM                      0x01
#define DBG_STREAM_TCP                      0x03
#define DBG_STREAM_PCI                      0x04
#define DBG_STREAM_USB                      0x07

/*------------------------------------------------------------------------------
 * debug constants - protocol
 *-----------------------------------------------------------------------------*/
#define DBG_PROTOCOL_EBL2                   0x01
#define DBG_PROTOCOL_ETCOM                  0x02

/*------------------------------------------------------------------------------
 * debug constants - display mode
 *-----------------------------------------------------------------------------*/
#define DBG_DISPLAY_ON                      0x00
#define DBG_DISPLAY_OFF 	                0x01

/*------------------------------------------------------------------------------
 * socket constants
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* socket constants for POSIX				*/
#if defined POSIX || defined VXWORKS_6_9
	#define INVALID_SOCKET                      -1
#endif /*POSIX || VXWORKS_6_9*/

/*------------------------------------------*/
/* socket constants for F_ITRON				*/
#ifdef F_ITRON
	#define INVALID_SOCKET                      -1
#endif /*F_ITRON*/

/*------------------------------------------------------------------------------
 * FileName maximal size
 *-----------------------------------------------------------------------------*/
#if defined POSIX || defined VXWORKS_6_9
	#define _MAX_PATH 260
#endif /*POSIX || VXWORKS_6_9*/

#if defined F_ITRON
	#define _MAX_PATH 512
#endif /*F_ITRON*/

/**********************************************************************************************************/
/*- TYPES */
/**********************************************************************************************************/

/*------------------------------------------------------------------------------
 * common types used in all libraries
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
		static eint64 ZERO64 = 0;
		#define INIT64(i)							do { \
														(i) = 0; \
													} while (0)
		#define SET64FROM64(dest,src)				do { \
														(dest) = (src); \
													} while (0)
		#define SET64FROM32(dest,low)				do { \
														(dest) = (low); \
													} while (0)
		#define SET64FROMLOWHIGH(dest, low, high)	do { \
														(dest) = (((eint64)(high)) << 32) | (low); \
													} while (0)
		#define CREATEANDSET64FROM32(low)			(low)
		#define CREATEANDSET64FROMLOWHIGH(low,high) ((((eint64)(high)) << 32) | (low))
		#define SETBIT64(i,bit)						 do { \
														(i) |= (eint64)1 << (bit); \
													} while (0)
		#define SETBITS64(i,mask)					do { \
														(i) |= (mask); \
													} while (0)
		#define CREATEANDSETBIT64(bit)				((eint64)1 << (bit))
		#define RESETBIT64(i,bit)					do { \
														(i) &= ~((eint64)1 << (bit)); \
													} while (0)
		#define RESETBITS64(i,mask)					do { \
														(i) &= ~(mask); \
													} while (0)
		#define ISBITSET64(i,bit)					(((i) & ((eint64)1 << (bit))) != 0)
		#define ISANYBITSET64(i1,i2)				(((i1) & (i2)) != 0)
		#define ISZERO64(i)							((i) == 0)
		#define INVERT64(i)							do { \
														(i) = ~(i); \
													} while (0)
		#define ANDBITS64(i,j)						do { \
														(i) &= (j); \
													} while (0)
		#define LOWDWORD64(i)						(((INT64_DWORD_MODE*)&(i))->low_dword)
		#define HIGHDWORD64(i)						(((INT64_DWORD_MODE*)&(i))->high_dword)
		#define EQUAL64(i1, i2)							((i1) == (i2))
		#define STRTOI64(s,e,b)						( \
														_strtoi64(s,e,b) \
													)
		#define STRTOUI64(s,e,b)					( \
														_strtoui64(s,e,b) \
													)
		#define I32_TO_I64(i32, i64)				do { \
														(i64) = (eint64)(i32); \
													} while (0)
		#define F32_TO_I64(f32, i64)				do { \
														(i64) = (eint64)(f32); \
													} while (0)
		#define F64_TO_I64(f64, i64)				do { \
														(i64) = (eint64)(f64); \
													} while (0)
		#define I64_TO_I32(i64, i32)				do { \
														(i32) = (int)(i64); \
													} while (0)
		#define I64_TO_F32(i64, f32)				do { \
														(f32) = (float)(i64); \
													} while (0)
		#define I64_TO_F64(i64, f64)				do { \
														(f64) = (float)(i64); \
													} while (0)
														
	/*-----------------------------------------------*/
	/* POSIX, F_ITRON, VXWORKS_6_9 64 bits integer	 */
	#elif defined POSIX || defined F_ITRON || defined VXWORKS_6_9
		#define eint64 long long
		#define ZERO64 0LL
		#define INIT64(i)							do { \
														(i) = 0; \
													} while (0)
		#define SET64FROM64(dest,src)				do { \
														(dest) = (src); \
													} while (0)
		#define SET64FROM32(dest,low)				do { \
														(dest) = (low); \
													} while (0)
		#define SET64FROMLOWHIGH(dest, low, high)	do { \
														(dest) = (eint64)(((eint64)(high) << 32) | (low)); \
													} while (0)
		#define CREATEANDSET64FROM32(low)			(low)
		#define CREATEANDSET64FROMLOWHIGH(low,high) ((((eint64)(high)) << 32) | (low))
		#define SETBIT64(i,bit)						 do { \
														(i) |= (eint64)1 << (bit); \
													} while (0)
		#define SETBITS64(i,mask)					do { \
														(i) |= (mask); \
													} while (0)
		#define CREATEANDSETBIT64(bit)				((eint64)1 << (bit))
		#define RESETBIT64(i,bit)					do { \
														(i) &= ~((eint64)1 << (bit)); \
													} while (0)
		#define RESETBITS64(i,mask)					do { \
														(i) &= ~(mask); \
													} while (0)
		#define ISBITSET64(i,bit)					(((i) & ((eint64)1 << (bit))) != 0)
		#define ISANYBITSET64(i1,i2)				(((i1) & (i2)) != 0)
		#define ISZERO64(i)							((i) == 0)
		#define INVERT64(i)							do { \
														(i) = ~(i); \
													} while (0)
		#define ANDBITS64(i,j)						do { \
														(i) &= (j); \
													} while (0)
		#define LOWDWORD64(i)						(((INT64_DWORD_MODE*)&(i))->low_dword)
		#define HIGHDWORD64(i)						(((INT64_DWORD_MODE*)&(i))->high_dword)
		#define EQUAL64(i1, i2)							((i1) == (i2))
		#define STRTOI64(s,e,b)						( \
														strtoll(s,e,b) \
													)
		#define STRTOUI64(s,e,b)					( \
														strtoull(s,e,b) \
													)
		#define I32_TO_I64(i32, i64)				do { \
														(i64) = (eint64)(i32); \
													} while (0)
		#define F32_TO_I64(f32, i64)				do { \
														(i64) = (eint64)(f32); \
													} while (0)
		#define F64_TO_I64(f64, i64)				do { \
														(i64) = (eint64)(f64); \
													} while (0)
		#define I64_TO_I32(i64, i32)				do { \
														(i32) = (int)(i64); \
													} while (0)
		#define I64_TO_F32(i64, f32)				do { \
														(f32) = (float)(i64); \
													} while (0)
		#define I64_TO_F64(i64, f64)				do { \
														(f64) = (float)(i64); \
													} while (0)
	#endif /*POSIX || F_ITRON || VXWORKS_6_9 */
#endif

/*------------------------------------------------------------------------------
 * WINDOWS types used in JNI code
 *-----------------------------------------------------------------------------*/
#ifdef WIN32
	#ifndef UNDER_RTSS
		#ifndef __JNIVM_P
			#define __JNIVM_P
			typedef JavaVM *jnivm_p;
		#endif /*__JNIVM_P */
		#ifndef __JNIENV_P
			#define __JNIENV_P
			typedef JNIEnv *jnienv_p;
		#endif /*__JNIENV_P*/
	#endif /* UNDER_RTSS */
#endif /* WIN32 */


/*------------------------------------------------------------------------------
 * debug buffer entry
 *-----------------------------------------------------------------------------*/
typedef struct _dbg_entry {
    char process_name[32];
    long event_id;
    int process_id;
    int process_priority;
    int thread_id;
    int thread_priority;
    double timestamp;
    int event_kind;
    int event_source;
    int event_stream;
    int event_ecode;
	int event_protocol;
	int event_port;
    size_t stream_size;
    byte stream_data[128];
    size_t snd_size;
    byte snd_data[128];
    char fct_name[32];
    char event_msg[64];
} DBG_ENTRY;


/*------------------------------------------------------------------------------
 * firmware manifest definition structure
 *-----------------------------------------------------------------------------*/
typedef struct _fw_manifest {
    char name[64];
    char version[64];
    char reg_blocks[64];
    char seq_blocks[64];
    char title[64];
} FW_MANIFEST;


/*------------------------------------------------------------------------------
 * directory entry definition structure
 *-----------------------------------------------------------------------------*/
typedef struct _directory_entry {
    char name[_MAX_PATH];
    bool directory;
} DIRECTORY_ENTRY;


/*------------------------------------------------------------------------------
 * types for net module
 *-----------------------------------------------------------------------------*/

/*--------------------------------------------*/
/* POSIX || VXWORKS_6_9 types for net module  */
#if defined POSIX || defined VXWORKS_6_9
	typedef int SOCKET;
	typedef struct hostent HOSTENT;
	typedef struct sockaddr_in SOCKADDR_IN;
    #ifndef VXWORKS_6_9
	    typedef struct sockaddr SOCKADDR; 
    #endif
#endif /* POSIX || VXWORKS_6_9*/
	
/*------------------------------*/
/* F_ITRON types for net module */
#ifdef F_ITRON
	typedef int SOCKET;
	typedef struct sockaddr_in SOCKADDR_IN;
	typedef struct sockaddr SOCKADDR;
#endif /*F_ITRON*/

/*------------------------------------------------------------------------------
 * type modifiers
 *-----------------------------------------------------------------------------*/
/*------------------------------*/
/* WINDOWS type modifiers		*/
#ifdef WIN32
	#ifndef _LIB_EXPORT
		#ifndef  LIB_STATIC
			#define _LIB_EXPORT __cdecl                     /* function exported by DLL library */
		#else
			#define _LIB_EXPORT __cdecl                     /* function exported by static library */
		#endif
	#endif /* _LIB_EXPORT */
	#define LIB_CALLBACK __cdecl                            /* client callback function called by library */
#endif /* WIN32 */

/*---------------------------------------*/
/* POSIX || VXWORKS_6_9 type modifiers	 */
#if defined POSIX || defined VXWORKS_6_9
	#define _LIB_EXPORT
	#define LIB_EXPORT
#endif /*POSIX || VXWORKS_6_9*/

/*------------------------------*/
/* F_ITRON type modifiers		*/
#ifdef F_ITRON
	#define _LIB_EXPORT __cdecl
	#define LIB_EXPORT __cdecl
#endif /*F_ITRON*/

/*------------------------------------------------------------------------------
 * hidden structures for library clients
 *-----------------------------------------------------------------------------*/
#ifndef PRO
	#define PRO void
#endif
#ifndef SHM
	#define SHM void
#endif

/**********************************************************************************************************/
/*- MACROS */
/**********************************************************************************************************/
/*------------------------------------------------------------------------------
 * Define verify macro - like assert but continue
 * to evaluate and check the argument with the release build
 *-----------------------------------------------------------------------------*/
#if !defined NDEBUG && !defined _NDEBUG
	#define verify(v) assert(v)
#else
	#define verify(v) do { if(!(v)) abort(); } while(0)
#endif

/*------------------------------------------------------------------------------
 * special macro to specify register static or global variables
 * this macro expand to nothing in standard platform
 *-----------------------------------------------------------------------------*/
#define REGISTER

/*------------------------------------------------------------------------------
 * clear the specified structure - utility function
 *-----------------------------------------------------------------------------*/
#define CLEAR(s) (memset(&(s), '\0', sizeof(s)))

/*------------------------------------------------------------------------------
 * waiting macro - wait the specified
 * number of milliseconds
 *-----------------------------------------------------------------------------*/
/*----------------------------------*/
/* WINDOWS-RTX waiting macro		*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#define SLEEP(time)                     (Sleep(time))
		#define USLEEP(time)                    (uSleep(time))
	/*----------------------------------*/
	/* WINDOWS-W32 waiting macro		*/
	#else
		#define SLEEP(time)                     (Sleep(time))
	#endif /* UNDER_RTSS */
#endif /* WIN32 */

/*----------------------------------------------*/
/* POSIX, F_ITRON, VXWORKS_6_9 waiting macro	*/
#if defined POSIX || defined F_ITRON || defined VXWORKS_6_9
	#define SLEEP(time)                     special_sleep(time)
#endif /*POSIX || F_ITRON || VXWORKS_6_9*/

/*------------------------------------------------------------------------------
 * thread macros - use thread in a multi-platform way
 *-----------------------------------------------------------------------------*/
/*--------------------------------------*/
/* WINDOWS-RTX thread macros			*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#define THREAD HANDLE
		#define THREAD_INVALID                              ((HANDLE)(-1))
		#define THREAD_INIT_PRIO(thr, fct, arg,prio)        do { \
																int tid; \
																(thr) = CreateThread(NULL, 20480, (LPTHREAD_START_ROUTINE)(fct), (arg), 0, &tid); \
																RtSetThreadPriority((thr), (prio)); \
															} while(0)
		#define THREAD_INIT_AND_NAME_PRIO(thr,name,fct,arg,prio) do { \
																		int tid; \
																		(thr) = CreateThread(NULL, 20480, (LPTHREAD_START_ROUTINE)(fct), (arg), 0, &tid); \
																		RtSetThreadPriority((thr), (prio)); \
																	} while(0)
		#define THREAD_WAIT(thr, timeout)                   (lib_wait_for_thread(thr, timeout))
		#define THREAD_GET_CURRENT()                        (GetCurrentThread())
		#define THREAD_GET_CURRENT_ID()                     (GetCurrentThreadId())
		#define THREAD_GET_NAME(thr)                        (NULL)
		#define PROCESS_GET_CURRENT()                       (NULL)
		#define PROCESS_GET_CURRENT_ID()                    (GetCurrentProcessId())
		#define THREAD_END()								(NULL)

		/******************************** */
		/* Obsolete: Use THREAD_INIT_PRIO */
		#define THREAD_INIT(thr, fct, arg)                  do { \
																int tid; \
																(thr) = CreateThread(NULL, 20480, (LPTHREAD_START_ROUTINE)(fct), (arg), 0, &tid); \
															} while(0)
		#define THREAD_INIT_AND_NAME(thr, name, fct, arg)   do { \
																int tid; \
																(thr) = CreateThread(NULL, 20480, (LPTHREAD_START_ROUTINE)(fct), (arg), 0, &tid); \
															} while(0)
		#define THREAD_SET_PRIORITY(thr, pri)               do { \
																RtSetThreadPriority((thr), (pri)); \
															} while(0)
		#define THREAD_GET_PRIORITY(thr)                    (RtGetThreadPriority((thr)))
		#define THREAD_SET_CURRENT_PRIORITY(pri)            do { \
																RtSetThreadPriority(GetCurrentThread(), (pri)); \
															} while(0)
		#define THREAD_GET_CURRENT_PRIORITY()               (RtGetThreadPriority(GetCurrentThread()))
		
		/******************************** */

	/*--------------------------------------*/
	/* WINDOWS-W32 thread macros			*/
	#else
		#define THREAD HANDLE
		#define THREAD_INVALID                              ((HANDLE)(-1))
		#define THREAD_INIT_PRIO(thr, fct, arg, prio)       do { \
																(thr) = rtx_beginthread((fct), (arg)); \
																SetThreadPriority((thr), (prio)); \
															} while(0)
		#define THREAD_INIT_AND_NAME_PRIO(thr,name,fct,arg,prio)   do { \
																	(thr) = rtx_begin_named_thread((name), (fct), (arg)); \
																	SetThreadPriority((thr), (prio)); \
																} while(0)
		#define THREAD_WAIT(thr, timeout)                   (WaitForSingleObject((thr), (timeout)))
		#define THREAD_GET_CURRENT()                        (GetCurrentThread())
		#define THREAD_GET_CURRENT_ID()                     (GetCurrentThreadId())
		#define THREAD_GET_NAME(thr)                        (rtx_get_thread_name(thr))
		#define PROCESS_GET_CURRENT()                       (GetCurrentProcess())
		#define PROCESS_GET_CURRENT_ID()                    (GetCurrentProcessId())
		#define THREAD_END()								(NULL)

		/******************************** */
		/* Obsolete: Use THREAD_INIT_PRIO */
		#define THREAD_INIT(thr, fct, arg)                  do { \
																(thr) = rtx_beginthread((fct), (arg)); \
															} while(0)
		#define THREAD_INIT_AND_NAME(thr, name, fct, arg)   do { \
																(thr) = rtx_begin_named_thread((name), (fct), (arg)); \
															} while(0)
		#define THREAD_SET_PRIORITY(thr, pri)               do { \
																SetThreadPriority((thr), (pri)); \
															} while(0)
		#define THREAD_GET_PRIORITY(thr)                    (GetThreadPriority((thr)))
		#define THREAD_SET_CURRENT_PRIORITY(pri)            do { \
																SetThreadPriority(GetCurrentThread(), (pri)); \
															} while(0)
		#define THREAD_GET_CURRENT_PRIORITY()               (GetThreadPriority(GetCurrentThread()))
		/******************************** */

	#endif /* UNDER_RTSS */
#endif /* WIN32 */

/*------------------------------*/
/* POSIX thread macros			*/
#if defined POSIX
	#define THREAD                                      pthread_t
	#define THREAD_INVALID                              ((pthread_t)(-1))
	#ifdef VXWORKS_6_9	
		#define THREAD_INIT_PRIO(thr,fct,arg,prio)          do {\
																	pthread_attr_t attr;\
																	pthread_attr_init(&attr);\
																	pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);\
																	pthread_attr_setschedpolicy(&attr, SCHED_FIFO);\
																	pthread_create (&thr, &attr, (void*)&fct, arg); \
																	thread_set_prio(thr, prio); \
															}while (0)
		#define THREAD_INIT_AND_NAME_PRIO(thr,name,fct,arg,prio) do {\
																pthread_attr_t attr;\
																pthread_attr_init(&attr);\
																pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);\
																pthread_attr_setschedpolicy(&attr, SCHED_FIFO);\
																pthread_attr_setname(&attr, name);\
																pthread_create (&thr, &attr, (void*)&fct, arg); \
																thread_set_prio(thr, prio); \
															}while (0)
	#else															
		#define THREAD_INIT_PRIO(thr,fct,arg,prio)          do {\
																pthread_create (&thr, NULL, (void*)&fct, arg); \
																thread_set_prio(thr, prio); \
															}while (0)
		#define THREAD_INIT_AND_NAME_PRIO(thr,name,fct,arg,prio) do {\
																pthread_create (&thr, NULL, (void*)&fct, arg); \
																thread_set_prio(thr, prio); \
															}while (0)
	#endif /*VXWORKS_6_9	*/															
	#define THREAD_INIT_DETACH(thr,fct,arg)             do { \
															pthread_attr_t attr; \
															pthread_attr_init(&attr); \
															pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED); \
															pthread_create (&thr, &attr, (void*)&fct, arg); \
															pthread_attr_destroy(&attr); \
														}while (0)
	//pas de timeout
	#define THREAD_SET_POLICY(thr,policy,pri)           (thread_set_policy(thr, policy, pri))
	#define THREAD_WAIT(thr,timeout)                    (pthread_join (thr, NULL))
	#define THREAD_GET_CURRENT()                        (pthread_self())
	#define THREAD_GET_CURRENT_ID()                     (pthread_self())
	#define THREAD_GET_NAME(thr)                        NULL
	#define PROCESS_GET_CURRENT()                       (getpid())
	#define PROCESS_GET_CURRENT_ID()                    (getpid())
	#define THREAD_END()								(NULL)
	
	/******************************** */
	/* Obsolete: Use THREAD_INIT_PRIO */
	#define THREAD_INIT(thr,fct,arg)                    do { \
															pthread_create (&thr, NULL, (void*)&fct, arg); \
														}while (0)
	#define THREAD_INIT_AND_NAME(thr,name,fct,arg)      do {\
															pthread_create (&thr, NULL, (void*)&fct, arg); \
														}while (0)
	#define THREAD_SET_CURRENT_PRIORITY(pri)            (thread_set_prio(pthread_self(), pri))
	#define THREAD_GET_CURRENT_PRIORITY()               (thread_get_prio(pthread_self()))
	#define THREAD_SET_PRIORITY(thr,pri)                (thread_set_prio(thr, pri))
	#define THREAD_GET_PRIORITY(thr)                    (thread_get_prio(thr))
	/******************************** */
#endif /*POSIX*/

/*--------------------------------------*/
/* VXWORKS_6_9 NATIVE thread macros	    */
#if defined VXWORKS_6_9 && defined NATIVE
	#define THREAD                                      TASK_ID
	#define THREAD_INVALID                              (TASK_ID_NULL)
	#define THREAD_INIT_PRIO(thr, fct, arg, prio)        do {\
															thr = taskSpawn(NULL, prio, VX_FP_TASK, 128000, (FUNCPTR)fct, (int)arg, 0, 0, 0, 0, 0, 0, 0, 0, 0);\
														} while(0)
	#define THREAD_INIT_AND_NAME_PRIO(thr,name,fct,arg,prio) do {\
																	thr = taskSpawn(name, prio, VX_FP_TASK, 128000, (FUNCPTR)fct, (int)arg, 0, 0, 0, 0, 0, 0, 0, 0, 0);\
																} while(0)
	#define THREAD_INIT_DETACH(thr,fct,arg)             do { \
															THREAD_INIT_AND_NAME_PRIO(thr, NULL, fct, arg, EDI_THREAD_PRIORITY_NORMAL);\
														}while (0)
	#define THREAD_WAIT(thr,timeout)                    do {\
															task_wait(thr, timeout);\
														} while (0);
	#define THREAD_GET_CURRENT()                        (taskIdSelf())
	#define THREAD_GET_CURRENT_ID()                     (taskIdSelf())
	#define THREAD_GET_NAME(thr)                        (taskName(thr))
	#define PROCESS_GET_CURRENT()                       (taskIdSelf())
	#define PROCESS_GET_CURRENT_ID()                    (taskIdSelf())
	#define THREAD_END()								(NULL)
	#define THREAD_SET_POLICY(thr,policy,pri)           (NULL)	//Not possible to set policy with native VxWorks scheduler
		
		
	/******************************** */
	/* Obsolete: Use THREAD_INIT_PRIO */
		
	#define THREAD_INIT(thr,fct,arg)                    do { \
															thr = taskSpawn(NULL, EDI_THREAD_PRIORITY_NORMAL, VX_FP_TASK, 128000, (FUNCPTR)fct, (int)arg, 0, 0, 0, 0, 0, 0, 0, 0, 0); \
														}while (0)
	#define THREAD_INIT_AND_NAME(thr,name,fct,arg)      do {\
															thr = taskSpawn(name, EDI_THREAD_PRIORITY_NORMAL, VX_FP_TASK, 128000, (FUNCPTR)fct, (int)arg, 0, 0, 0, 0, 0, 0, 0, 0, 0); \
														}while (0)
		
	#define THREAD_SET_PRIORITY(thr,pri)                (task_set_prio(thr, pri))
	#define THREAD_GET_PRIORITY(thr)                    (task_get_prio(thr))
	#define THREAD_SET_CURRENT_PRIORITY(pri)            (task_set_prio(taskIdSelf(), pri))
	#define THREAD_GET_CURRENT_PRIORITY()               (task_get_prio(taskIdSelf()))
	/******************************** */
#endif /*VXWORKS_6_9 && NATIVE*/


/*--------------------------------------*/
/* F_ITRON thread macros				*/
#ifdef F_ITRON
	#define THREAD                                      FJ_ID
	#define THREAD_INVALID                              ((FJ_ID)-1)
	#define THREAD_INIT_PRIO(thr,fct,arg,prio)          do { \
															thr = lib_fitron_task_create(fct, arg, prio, NULL); \
														}while (0)
	#define THREAD_INIT_AND_NAME_PRIO(thr,name,fct,arg,prio) do {\
															thr = lib_fitron_task_create(fct, arg, prio, name); \
														}while (0)
	#define THREAD_WAIT(thr,timeout)					(lib_fitron_task_wait(thr, timeout))
	#define THREAD_END()								do {\
															lib_fitron_task_destroy(); \
														}while (0)
	#define THREAD_GET_CURRENT()                        (lib_fitron_get_task_id())
	#define THREAD_GET_CURRENT_ID()                     (lib_fitron_get_task_id())
	#define THREAD_GET_NAME(thr)                        NULL
	#define PROCESS_GET_CURRENT()                       (lib_fitron_get_task_id())
	#define PROCESS_GET_CURRENT_ID()                    (lib_fitron_get_task_id())

	/******************************** */
	/* Obsolete: Use THREAD_INIT_PRIO */
/*
	#define THREAD_INIT(thr,fct,arg)
	#define THREAD_INIT_AND_NAME(thr,name,fct,arg)      
	#define THREAD_SET_PRIORITY(thr,pri)				do {\
															(lib_fitron_task_set_prio(thr, pri));\
														}while (0)
														
	#define THREAD_GET_PRIORITY(thr)					(lib_fitron_task_get_prio(thr))
	#define THREAD_SET_CURRENT_PRIORITY(pri) 
	#define THREAD_GET_CURRENT_PRIORITY() 
*/	
	/******************************** */
#endif /*F_ITRON*/

/*------------------------------------------------------------------------------
 * Synchronization lock object reservation
 * Must be called before first EDI function call of each F_ITRON process
 *-----------------------------------------------------------------------------*/
#ifdef F_ITRON
	#define EDI_INIT(firstLockIndex,nbLock,firstEventIndex,nbEvent,firstSemaIndex,nbSema) \
			(lib_fitron_edi_init(firstLockIndex,nbLock,firstEventIndex,nbEvent,firstSemaIndex,nbSema))
	#define EDI_EXIT() \
			(lib_fitron_edi_exit())
#endif /*F_ITRON*/	
/*------------------------------------------------------------------------------
 * critical sections - used to protect task against others or DPC
 * when shared variables are used betweed tasks.
 *-----------------------------------------------------------------------------*/
/*--------------------------------------*/
/* WINDOWS-RTX critical section			*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#define DEFINE_CRITICAL         CRITICAL_SECTION monitor;
		#define CRITICAL                struct {DEFINE_CRITICAL}
		#define CRITICAL_INIT(ob)       do { \
											InitializeCriticalSection(&(ob).monitor); \
										} while(0)
		#define CRITICAL_DESTROY(ob)    do { \
											DeleteCriticalSection(&(ob).monitor); \
										} while(0)
		#define CRITICAL_ENTER(ob)      do { \
											EnterCriticalSection(&(ob).monitor); \
										} while(0)
		#define CRITICAL_LEAVE(ob)      do { \
											LeaveCriticalSection(&(ob).monitor); \
										} while(0)


	/*--------------------------------------*/
	/* WINDOWS-W32 critical section			*/
	#else
		#define DEFINE_CRITICAL         CRITICAL_SECTION monitor;
		#define CRITICAL                struct {DEFINE_CRITICAL}
		#define CRITICAL_INIT(ob)       do { \
											InitializeCriticalSection(&(ob).monitor); \
										} while(0)
		#define CRITICAL_DESTROY(ob)    do { \
											DeleteCriticalSection(&(ob).monitor); \
										} while(0)
		#define CRITICAL_ENTER(ob)      do { \
											EnterCriticalSection(&(ob).monitor); \
										} while(0)
		#define CRITICAL_LEAVE(ob)      do { \
											LeaveCriticalSection(&(ob).monitor); \
										} while(0)
	#endif /* UNDER_RTSS */
#endif /* WIN32 critical section*/

/*--------------------------------------*/
/* POSIX Critical section				*/
#if defined POSIX
	/*--------------------------------------*/
	/* POSIX-STANDARD MUTEX Critical section : Followed by context switch*/
	#if defined MUTEX_STD
		#define DEFINE_CRITICAL         pthread_mutex_t mutex; int m_counter; THREAD m_pid;
		#define CRITICAL                struct {DEFINE_CRITICAL}
		#define CRITICAL_INIT(ob)       do { \
											pthread_mutex_init(&((ob).mutex), NULL); \
											(ob).m_counter=0;\
											(ob).m_pid=-1;\
										} while(0)
		#define CRITICAL_DESTROY(ob)    do { \
											pthread_mutex_destroy(&(ob).mutex); \
										} while(0)
		#define CRITICAL_ENTER(ob)      do { \
											if ((ob).m_pid==pthread_self()) { \
												(ob).m_counter++; \
											} \
											else { \
												pthread_mutex_lock(&(ob).mutex); \
												(ob).m_pid=pthread_self(); \
												(ob).m_counter++; \
											} \
										} while(0)
		#define CRITICAL_LEAVE(ob)      do { \
											if ((ob).m_pid==pthread_self()) { \
												if (--((ob).m_counter)==0) { \
													(ob).m_pid=-1; \
													pthread_mutex_unlock(&(ob).mutex); \
												} \
											} \
										} while(0)

	/*--------------------------------------*/
	/* POSIX-FAST MUTEX Critical section : Not followed by context switch */
	#elif defined MUTEX_FAST
		#define DEFINE_CRITICAL         pthread_mutex_t mutex; pthread_mutexattr_t attr;
		#define CRITICAL                struct {DEFINE_CRITICAL}
		#if defined QNX6 || defined VXWORKS_6_9 || defined LINUX
		/* Only available for QNX6 and VxWorks 6.9 */
			#define CRITICAL_INIT(ob)       do { \
												pthread_mutexattr_init(&((ob).attr)); \
												pthread_mutexattr_settype(&((ob).attr), PTHREAD_MUTEX_RECURSIVE); \
												pthread_mutex_init(&((ob).mutex), &((ob).attr)); \
											} while(0)
		#else
			#define CRITICAL_INIT(ob)       do { \
												(ob).attr.__mutexkind = PTHREAD_MUTEX_RECURSIVE_NP; \
												pthread_mutex_init(&((ob).mutex), &((ob).attr)); \
											} while(0)
		#endif /*QNX6*/
		#define CRITICAL_DESTROY(ob)    do { \
											pthread_mutex_destroy(&(ob).mutex); \
										} while(0)
		#define CRITICAL_ENTER(ob)      do { \
											pthread_mutex_lock(&((ob).mutex)); \
										} while(0)
		#define CRITICAL_LEAVE(ob)      do { \
											pthread_mutex_unlock(&((ob).mutex)); \
										} while(0)
	/*--------------------------------------*/
	/* POSIX-DEFAULT MUTEX Critical section : Semaphore */
	#else
		#define DEFINE_CRITICAL         sem_t m_sem; int m_counter; THREAD m_pid;
		#define CRITICAL                struct {DEFINE_CRITICAL}
		#define CRITICAL_INIT(ob)       do { \
											sem_init (&(ob).m_sem, FALSE, 1); \
											(ob).m_counter=0; \
											(ob).m_pid=-1; \
										} while(0)
		#define CRITICAL_DESTROY(ob)    do { \
											sem_destroy(&(ob).m_sem); \
										} while(0)
		#define CRITICAL_ENTER(ob)      do { \
											if ((ob).m_pid==pthread_self()) { \
												(ob).m_counter++; \
											} \
											else { \
												sem_wait(&(ob).m_sem); \
												(ob).m_pid=pthread_self(); \
												(ob).m_counter++; \
											} \
										} while(0)
		#define CRITICAL_LEAVE(ob)      do { \
											if ((ob).m_pid==pthread_self()) { \
												if (--((ob).m_counter)==0) { \
													(ob).m_pid=-1; \
													sem_post(&(ob).m_sem); \
												} \
											} \
										} while(0)
	#endif /* MUTEX_STD */
#endif /*POSIX critical section */

/*--------------------------------------*/
/* VXWORKS NATIVE Critical section  	*/
#if defined VXWORKS_6_9 && defined NATIVE
	#define DEFINE_CRITICAL         SEM_ID sem;
	#define CRITICAL                struct {DEFINE_CRITICAL}
	#define CRITICAL_INIT(ob)       do { \
										(ob).sem = semMCreate(SEM_Q_PRIORITY | SEM_INVERSION_SAFE ); \
									} while(0)
	#define CRITICAL_DESTROY(ob)    do { \
										semDelete((ob).sem); \
									} while(0)
	#define CRITICAL_ENTER(ob)      do { \
										critical_enter((ob).sem); \
									} while(0)
	#define CRITICAL_LEAVE(ob)      do { \
										semGive((ob).sem); \
									} while(0)
#endif /*VXWORKS_6_9 && NATIVE*/

/*--------------------------------------*/
/* F_ITRON Critical section  	        */
#ifdef F_ITRON
	#define DEFINE_CRITICAL 		FJ_ID cs; int m_counter; FJ_ID m_pid; 
	#define CRITICAL 				struct {DEFINE_CRITICAL}
	#define CRITICAL_INIT(ob)		do { \
										lib_fitron_critical_create(0, &(ob).cs, &(ob).m_counter, &(ob).m_pid); \
									} while(0)
	#define CRITICAL_DESTROY(ob) 	do { \
										lib_fitron_critical_destroy(&(ob).cs); \
									} while(0)
	#define CRITICAL_ENTER(ob)		do { \
										lib_fitron_critical_enter(&(ob).cs, &(ob).m_counter, &(ob).m_pid); \
									} while(0)
	#define CRITICAL_LEAVE(ob) 		do { \
										lib_fitron_critical_leave(&(ob).cs, &(ob).m_counter, &(ob).m_pid); \
									} while(0)
#endif /*F_ITRON */


/*------------------------------------------------------------------------------
 * events macros - create manual event with specified initial state
 *-----------------------------------------------------------------------------*/
/*--------------------------------------*/
/* WINDOWS - RTX events macros			*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#define EVENT                   HANDLE
		#define EVENT_INVALID           NULL
		#define EVENT_INIT(ev, init)    do { \
											(ev) = RtCreateEvent(NULL, TRUE, (init), NULL); \
										} while(0)
		#define EVENT_DESTROY(ev)       do { \
											RtCloseHandle(ev); \
										} while(0)
		#define EVENT_SET(ev)           do { \
											RtSetEvent((ev)); \
										} while(0)
		#define EVENT_RESET(ev)         do { \
											RtResetEvent((ev)); \
										} while(0)
		#define EVENT_WAIT(ev, timeout) (RtWaitForSingleObject((ev), (timeout)))
		#define IS_VALID_EVENT(ev)      (ev != EVENT_INVALID)

	/*--------------------------------------*/
	/* WINDOWS - W32 events macros			*/
	#else
		#define EVENT                   HANDLE
		#define EVENT_INVALID           NULL
		#define EVENT_INIT(ev, init)    do { \
											(ev) = CreateEvent(NULL, TRUE, (init), NULL); \
										} while(0)
		#define EVENT_DESTROY(ev)       do { \
											CloseHandle(ev); \
										} while(0)
		#define EVENT_SET(ev)           do { \
											SetEvent((ev)); \
										} while(0)
		#define EVENT_RESET(ev)         do { \
											ResetEvent((ev)); \
										} while(0)
		#define EVENT_WAIT(ev, timeout) (WaitForSingleObject((ev), (timeout)))
		#define IS_VALID_EVENT(ev)      (ev != EVENT_INVALID)
	#endif /* UNDER_RTSS */
#endif /* WIN32 */

/*--------------------------------------*/
/* POSIX events macros					*/
#ifdef POSIX
	#define DEFINE_EVENT            pthread_mutex_t mutex; pthread_cond_t cond; int state; int error; int valid;
	#define EVENT_INVALID           NULL
	#define EVENT                   struct {DEFINE_EVENT}
	#define EVENT_INIT(ev,init)     do { \
										pthread_cond_init(&(ev).cond, NULL); \
										pthread_mutex_init(&(ev).mutex, NULL); \
										ev.state = init; \
										ev.error = 0; \
										ev.valid = 1; \
									} while(0)
	#define EVENT_DESTROY(ev)       do { \
										pthread_mutex_lock(&(ev).mutex); \
										ev.error = WAIT_FAILED; \
										pthread_mutex_unlock(&(ev).mutex); \
										pthread_cond_broadcast(&(ev).cond); \
										pthread_cond_destroy(&(ev).cond); \
										pthread_mutex_destroy(&(ev).mutex); \
										ev.valid = 0; \
									} while (0)
	#define EVENT_SET(ev)           do { \
										pthread_mutex_lock(&(ev).mutex); \
										ev.state = TRUE; \
										pthread_mutex_unlock(&(ev).mutex); \
										pthread_cond_broadcast(&(ev).cond); \
									} while (0)
	#define EVENT_RESET(ev)         do { \
										pthread_mutex_lock(&(ev).mutex); \
										ev.state = FALSE; \
										pthread_mutex_unlock(&(ev).mutex); \
									} while (0)
	#define EVENT_WAIT(ev,timeout)  (event_wait(&(ev.mutex), &(ev.cond), &(ev.state), &(ev.error), timeout))
	#define IS_VALID_EVENT(ev)      (ev.valid == 1)
#endif /*POSIX*/

/*--------------------------------------*/
/* VXWORKS NATIVE events macros			*/
#if defined VXWORKS_6_9 && defined NATIVE
	#define EVENT_INVALID           NULL
	#define EVENT                   SEM_ID
	#define EVENT_INIT(ev,init)     do { \
										if (init) { \
											ev = semBCreate(SEM_Q_PRIORITY, SEM_FULL); \
										} \
										else { \
											ev = semBCreate(SEM_Q_PRIORITY, SEM_EMPTY); \
										} \
									} while(0)
	#define EVENT_DESTROY(ev)       do{ \
										semDelete(ev); \
									} while (0)
	#define EVENT_SET(ev)           do { \
										semGive(ev); \
									} while (0)
	#define EVENT_RESET(ev)         do { \
										semGive(ev); \
										semTake(ev, WAIT_FOREVER); \
									} while (0)
	#define EVENT_WAIT(ev,timeout)  (event_wait(ev, timeout))
	#define IS_VALID_EVENT(ev)      (ev != EVENT_INVALID)
#endif /*VXWORKS_6_9 && NATIVE*/

/*--------------------------------------*/
/* F_ITRON events macros				*/
#ifdef F_ITRON
	#define EVENT_INVALID           ((FJ_ID)-1)
	#define EVENT           	    FJ_ID
	#define EVENT_INIT(ev,init)     do { \
										ev = lib_fitron_event_create(0, init); \
									} while(0)
	#define EVENT_DESTROY(ev)       do{ \
										lib_fitron_event_destroy(ev); \
									} while (0)
	#define EVENT_SET(ev)           do { \
										lib_fitron_event_set(ev); \
									} while (0)
	#define EVENT_RESET(ev)         do { \
										lib_fitron_event_reset(ev); \
									} while (0)
	#define EVENT_WAIT(ev,timeout)  (lib_fitron_event_wait(ev, timeout))
	#define IS_VALID_EVENT(ev)      (ev != EVENT_INVALID)
#endif /* F_ITRON */

/*------------------------------------------------------------------------------
 * auto events macros - create automatic event with
 * specified initial state
 *-----------------------------------------------------------------------------*/
/*--------------------------------------*/
/* WINDOWS-RTX auto events macros		*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#define AUTOEVENT HANDLE
		#define AUTOEVENT_INVALID NULL
		#define AUTOEVENT_INIT(ev, init)    do { \
												(ev) = RtCreateEvent(NULL, FALSE, (init), NULL); \
											} while(0)
		#define AUTOEVENT_DESTROY(ev)       do { \
												RtCloseHandle(ev); \
											} while(0)
		#define AUTOEVENT_SET(ev)           do { \
												RtSetEvent((ev)); \
											} while(0)
		#define AUTOEVENT_RESET(ev)         do { \
												RtResetEvent((ev)); \
											} while(0)
		#define AUTOEVENT_WAIT(ev, timeout) (RtWaitForSingleObject((ev), (timeout)))
		#define IS_VALID_AUTOEVENT(ev)      (ev != AUTOEVENT_INVALID)

	/*--------------------------------------*/
	/* WINDOWS-W32 auto events macros		*/
	#else
		#define AUTOEVENT HANDLE
		#define AUTOEVENT_INVALID NULL
		#define AUTOEVENT_INIT(ev, init)    do { \
												(ev) = CreateEvent(NULL, FALSE, (init), NULL); \
											} while(0)
		#define AUTOEVENT_DESTROY(ev)       do { \
												CloseHandle(ev); \
											} while(0)
		#define AUTOEVENT_SET(ev)           do { \
												SetEvent((ev)); \
											} while(0)
		#define AUTOEVENT_RESET(ev)         do { \
												ResetEvent((ev)); \
											} while(0)
		#define AUTOEVENT_WAIT(ev, timeout) (WaitForSingleObject((ev), (timeout)))
		#define IS_VALID_AUTOEVENT(ev)      (ev != AUTOEVENT_INVALID)
	#endif /* UNDER_RTSS */
#endif /* WIN32 */

/*--------------------------------------*/
/* POSIX auto events macros				*/
#ifdef POSIX
    #define DEFINE_AUTOEVENT            pthread_mutex_t mutex; pthread_cond_t cond; int state; int error; int valid;
	#define AUTOEVENT_INVALID           NULL
	#define AUTOEVENT                   struct {DEFINE_AUTOEVENT}
	#define AUTOEVENT_INIT(ev,init)     do { \
											pthread_cond_init(&(ev).cond, NULL); \
											pthread_mutex_init(&(ev).mutex, NULL); \
											ev.state = init; \
											ev.error = 0;\
											ev.valid = 1;\
										} while(0)
	#define AUTOEVENT_DESTROY(ev)       do{ \
											pthread_mutex_lock(&(ev).mutex); \
											ev.error = WAIT_FAILED; \
											pthread_mutex_unlock(&(ev).mutex); \
											pthread_cond_broadcast(&(ev).cond); \
											pthread_cond_destroy(&(ev).cond); \
											pthread_mutex_destroy(&(ev).mutex);\
											ev.valid = 0; \
										} while (0)
	#define AUTOEVENT_SET(ev)           do { \
											pthread_mutex_lock(&(ev).mutex);\
											ev.state = TRUE;\
											pthread_mutex_unlock(&(ev).mutex); \
											pthread_cond_broadcast(&(ev).cond); \
										}while (0)
	#define AUTOEVENT_RESET(ev)         do { \
											pthread_mutex_lock(&(ev).mutex); \
											ev.state = FALSE; \
											pthread_mutex_unlock(&(ev).mutex); \
										} while (0)
	#define AUTOEVENT_WAIT(ev,timeout)  (autoevent_wait(&(ev.mutex), &(ev.cond), &(ev.state), &(ev.error), timeout))
	#define IS_VALID_AUTOEVENT(ev)      (ev.valid == 1)
#endif /* POSIX */

/*--------------------------------------*/
/* VXWORKS NATIVE auto events macros	*/
#if defined VXWORKS_6_9 && defined NATIVE
	#define AUTOEVENT_INVALID           NULL
	#define AUTOEVENT                   SEM_ID
	#define AUTOEVENT_INIT(ev,init)     do { \
											if (init) { \
												ev = semBCreate(SEM_Q_PRIORITY, SEM_FULL); \
											} \
											else { \
												ev = semBCreate(SEM_Q_PRIORITY, SEM_EMPTY); \
											} \
										} while(0)
	#define AUTOEVENT_DESTROY(ev)       do{ \
											semDelete(ev); \
										} while (0)
	#define AUTOEVENT_SET(ev)           do { \
											semGive(ev); \
										} while (0)
	#define AUTOEVENT_RESET(ev)         do { \
											semGive(ev); \
											semTake(ev, WAIT_FOREVER); \
										} while (0)
	#define AUTOEVENT_WAIT(ev,timeout)  (autoevent_wait(ev, timeout))
	#define IS_VALID_AUTOEVENT(ev)      (ev != AUTOEVENT_INVALID)
#endif /*VXWORKS_6_9 && NATIVE*/

/*--------------------------------------*/
/* F_ITRON autoevent macros				*/
#ifdef F_ITRON
	#define AUTOEVENT_INVALID      	    	((FJ_ID)-1)
	#define AUTOEVENT           	        FJ_ID
	#define AUTOEVENT_INIT(ev,init)     	do { \
												ev = lib_fitron_autoevent_create(0, init); \
											} while(0)
	#define AUTOEVENT_DESTROY(ev)       	do{ \
												lib_fitron_autoevent_destroy(ev); \
											} while (0)
	#define AUTOEVENT_SET(ev)           	do { \
												lib_fitron_autoevent_set(ev); \
											} while (0)
	#define AUTOEVENT_RESET(ev)         	do { \
												lib_fitron_autoevent_reset(ev); \
											} while (0)
	#define AUTOEVENT_WAIT(ev,timeout)  	(lib_fitron_autoevent_wait(ev, timeout))
	#define IS_VALID_AUTOEVENT(ev)      	(ev != AUTOEVENT_INVALID)
#endif /* F_ITRON */


/*------------------------------------------------------------------------------
 * mutexes macros - create manual event with
 * specified initial state
 *-----------------------------------------------------------------------------*/

/*--------------------------------------*/
/* WINDOWS-RTX mutexes macros			*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#define MUTEX                   HANDLE
		#define MUTEX_INVALID           NULL
		#define MUTEX_INIT(ev, init)    do { \
											(ev) = RtCreateMutex(NULL, (init), NULL); \
										} while(0)
		#define MUTEX_DESTROY(ev)       do { \
											RtCloseHandle((ev)); \
										} while(0)
		#define MUTEX_RELEASE(ev)       do { \
											RtReleaseMutex((ev)); \
										} while(0)
		#define MUTEX_WAIT(ev, timeout) (RtWaitForSingleObject((ev), (timeout)))
		#define IS_VALID_MUTEX(ev)      (ev != MUTEX_INVALID)

	/*--------------------------------------*/
	/* WINDOWS-W32 mutexes macros			*/
	#else
		#define MUTEX                   HANDLE
		#define MUTEX_INVALID           NULL
		#define MUTEX_INIT(ev, init)    do { \
											(ev) = CreateMutex(NULL, (init), NULL); \
										} while(0)
		#define MUTEX_DESTROY(ev)       do { \
											CloseHandle((ev)); \
										} while(0)
		#define MUTEX_RELEASE(ev)       do { \
											ReleaseMutex((ev)); \
										} while(0)
		#define MUTEX_WAIT(ev, timeout) (WaitForSingleObject((ev), (timeout)))
		#define IS_VALID_MUTEX(ev)      (ev != MUTEX_INVALID)
	#endif /* UNDER_RTSS */
#endif /* WIN32 */

/*--------------------------------------*/
/* POSIX mutexes macros					*/
#ifdef POSIX
	#define DEFINE_MUTEX            pthread_mutex_t mutex; pthread_cond_t cond;  THREAD tid; int counter; int error; int valid;
	#define MUTEX_INVALID           NULL
	#define MUTEX                   struct {DEFINE_MUTEX}
	#define MUTEX_INIT(mut,init)    do { \
										pthread_cond_init(&(mut).cond, NULL); \
										pthread_mutex_init(&(mut).mutex, NULL); \
										mut.error = 0; \
										if (init) { \
											mut.tid = pthread_self(); \
											mut.counter = 0; \
										} \
										else { \
											mut.tid = -1; \
											mut.counter = 1; \
										} \
										mut.valid = 1; \
									} while(0)
	#define MUTEX_DESTROY(mut)      do { \
										pthread_mutex_lock(&(mut).mutex); \
										mut.error = WAIT_FAILED; \
										pthread_mutex_unlock(&(mut).mutex); \
										pthread_cond_broadcast(&(mut).cond); \
										pthread_cond_destroy(&(mut).cond); \
										pthread_mutex_destroy(&(mut).mutex); \
										mut.valid = 0; \
									} while (0)
	#define MUTEX_RELEASE(mut)      do { \
										if ((mut).tid==pthread_self()) { \
											pthread_mutex_lock(&(mut).mutex); \
											if (++((mut).counter)==1) { \
												(mut).tid=-1; \
												pthread_mutex_unlock(&(mut).mutex); \
												pthread_cond_signal(&(mut).cond); \
											} \
											else \
												pthread_mutex_unlock(&(mut).mutex); \
										} \
									} while(0)
	#define MUTEX_WAIT(mut,timeout) mutex_wait(&(mut.mutex), &(mut.cond), &(mut.tid), &(mut.counter), &(mut.error), timeout)
	#define IS_VALID_MUTEX(mut)     (mut.valid == 1)
#endif /*POSIX*/

/*--------------------------------------*/
/* VXWORKS NATIVE mutexes macros		*/
#if defined VXWORKS_6_9 && defined NATIVE
	#define MUTEX                   SEM_ID
	#define MUTEX_INVALID           NULL
	#define MUTEX_INIT(mut,init)    do { \
										mut = semMCreate(SEM_Q_PRIORITY | SEM_INVERSION_SAFE ); \
										if (init) \
											semTake(mut, WAIT_FOREVER); \
									} while(0)
	#define MUTEX_DESTROY(mut)      do { \
										semDelete(mut); \
									} while(0)
	#define MUTEX_RELEASE(mut)      do { \
										semGive(mut); \
									} while(0)
	#define MUTEX_WAIT(mut,timeout) (mutex_wait(mut, timeout))
	#define IS_VALID_MUTEX(mut)     (mut != MUTEX_INVALID)
#endif /*VXWORKS_6_9 && NATIVE*/

/*----------------------------------*/
/* F_ITRON mutex macros				*/
#ifdef F_ITRON
	#define DEFINE_MUTEX 			FJ_ID mut;int counter; FJ_ID pid; 
	#define MUTEX_INVALID       	NULL
	#define MUTEX 					struct {DEFINE_MUTEX}
	#define MUTEX_INIT(ob, init)	do { \
										lib_fitron_mutex_create(0, &(ob).mut, &(ob).counter, &(ob).pid, init); \
									} while(0)
	#define MUTEX_DESTROY(ob) 		do { \
										lib_fitron_mutex_destroy(&(ob).mut); \
									} while(0)
	#define MUTEX_RELEASE(ob)		do { \
										lib_fitron_mutex_release(&(ob).mut, &(ob).counter, &(ob).pid); \
									} while(0)
	#define MUTEX_WAIT(ob, timeout)	(lib_fitron_mutex_wait(&(ob).mut, &(ob).counter, &(ob).pid, timeout))
#endif /*F_ITRON */

/*------------------------------------------------------------------------------
 * counting semaphore macros - create semaphore
 * with specified initial and maximum value
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* WINDOWS-RTX counting semaphore macros	*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#define SEMACOUNT                       HANDLE
		#define SEMACOUNT_INVALID               NULL
		#define SEMACOUNT_INIT(sem, init, max)  do { \
													(sem) = RtCreateSemaphore(NULL, (init), (max), NULL); \
												} while(0)
		#define SEMACOUNT_DESTROY(sem)          do { \
													RtCloseHandle(sem); \
												} while(0)
		#define SEMACOUNT_RELEASE(sem)          do { \
													RtReleaseSemaphore((sem), 1, NULL); \
												} while(0)
		#define SEMACOUNT_WAIT(sem, timeout)    (RtWaitForSingleObject((sem), (timeout)))
		#define IS_VALID_SEMACOUNT(ev)          (ev != SEMACOUNT_INVALID)
		#define SET_SEMACOUNT(target, source)   do { \
													memcpy(&target, &source, sizeof(target));\
												} while (0)
	/*------------------------------------------*/
	/* WINDOWS-W32 counting semaphore macros	*/
	#else
		#define SEMACOUNT                       HANDLE
		#define SEMACOUNT_INVALID               NULL
		#define SEMACOUNT_INIT(sem, init, max)  do { \
													(sem) = CreateSemaphore(NULL, (init), (max), NULL); \
												} while(0)
		#define SEMACOUNT_DESTROY(sem)          do { \
													CloseHandle(sem); \
												} while(0)
		#define SEMACOUNT_RELEASE(sem)          do { \
													ReleaseSemaphore((sem), 1, NULL); \
												} while(0)
		#define SEMACOUNT_WAIT(sem, timeout)    (WaitForSingleObject((sem), (timeout)))
		#define IS_VALID_SEMACOUNT(ev)          (ev != SEMACOUNT_INVALID)
		#define SET_SEMACOUNT(target, source)   do { \
													memcpy(&target, &source, sizeof(target));\
												} while (0)
	#endif /*UNDER_RTSS*/
#endif /* WIN32 */


/*------------------------------------------*/
/* POSIX counting semaphore macros			*/
#ifdef POSIX
    #define DEFINE_SEMACOUNT                        pthread_mutex_t mutex; pthread_cond_t cond; int counter; \
													int error; int max_count; int valid;
	#define SEMACOUNT_INVALID                       NULL
	#define SEMACOUNT                               struct {DEFINE_SEMACOUNT}
	#define SEMACOUNT_INIT(sema,init,max_count_val) do { \
														pthread_cond_init(&(sema).cond, NULL); \
														pthread_mutex_init(&(sema).mutex, NULL); \
														sema.counter = init; \
														sema.max_count = max_count_val; \
														sema.error = 0;\
														sema.valid = 1;\
													} while(0)
	#define SEMACOUNT_DESTROY(sema)                 do { \
														pthread_mutex_lock(&(sema).mutex); \
														sema.error = WAIT_FAILED; \
														pthread_mutex_unlock(&(sema).mutex); \
														pthread_cond_broadcast(&(sema).cond); \
														pthread_cond_destroy(&(sema).cond); \
														pthread_mutex_destroy(&(sema).mutex); \
														sema.valid = 0; \
													} while (0)
	#define SEMACOUNT_RELEASE(sema)                 do { \
														pthread_mutex_lock(&(sema).mutex); \
														if (++((sema).counter) > sema.max_count) \
															sema.counter = sema.max_count; \
														pthread_mutex_unlock(&(sema).mutex); \
														pthread_cond_signal(&(sema).cond); \
													} while(0)
	#define SEMACOUNT_WAIT(sema,timeout)            local_sema_wait(&(sema.mutex), &(sema.cond), &(sema.counter), &(sema.error), timeout)
	#define IS_VALID_SEMACOUNT(sema)                (sema.valid == 1)
	#define SET_SEMACOUNT(target, source)           (memcpy(&target, &source, sizeof(target)))
#endif /*POSIX*/

/*-----------------------------------------------*/
/* VXWORKS_6_9 NATIVE counting semaphore macros  */
#if defined VXWORKS_6_9 && defined NATIVE
	#define DEFINE_SEMACOUNT                        SEM_ID sema; int valid; int i;
	#define SEMACOUNT                               struct {DEFINE_SEMACOUNT}
	#define SEMACOUNT_INVALID                       NULL
	#define SEMACOUNT_INIT(sem,init,max_count_val)  do { \
														sem.sema = semCCreate(SEM_Q_PRIORITY, init); \
														sem.valid = 1; \
													} while(0)
	#define SEMACOUNT_DESTROY(sem)                  do { \
														semDelete(sem.sema); \
													} while (0)
	#define SEMACOUNT_RELEASE(sem)                  do { \
														semGive(sem.sema); \
													} while(0)
	#define SEMACOUNT_WAIT(sem,timeout)             (local_sema_wait(sem.sema, timeout))
	#define IS_VALID_SEMACOUNT(sem)                 (sem.valid == 1)
	#define SET_SEMACOUNT(target, source)           (memcpy(&target, &source, sizeof(target)))
#endif /*VXWORKS_6_9 && NATIVE*/

/*--------------------------------------*/
/* F_ITRON semacount macros				*/
#ifdef F_ITRON
	#define SEMACOUNT_INVALID       		((FJ_ID)-1)
	#define SEMACOUNT           	    	FJ_ID
	#define SEMACOUNT_INIT(sema,init,max)  	do { \
												sema = lib_fitron_semaphore_create(0, init, max); \
											} while(0)
	#define SEMACOUNT_DESTROY(sema)			do{ \
												lib_fitron_semaphore_destroy(sema); \
											} while (0)
	#define SEMACOUNT_RELEASE(sema)		   	do { \
												lib_fitron_semaphore_release(sema); \
											} while (0)
	#define SEMACOUNT_WAIT(sema,timeout)  	(lib_fitron_semaphore_wait(sema, timeout))
	#define IS_VALID_SEMACOUNT(sema) 	   	(sema != SEMACOUNT_INVALID)
	#define SET_SEMACOUNT(target, source)	do { \
												lib_fitron_semaphore_set(&target, &source); \
											} while (0)
#endif /* F_ITRON */

/*------------------------------------------------------------------------------
 * thread local storage macros
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* WINDOWS-RTX thread local storage macros	*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#define TLS_ALLOC(idx) ((idx = TlsAlloc()) == 0xFFFFFFFF)
		#define TLS_FREE(idx) (!TlsFree(idx))
		#define TLS_SET_VALUE(idx, val) (!TlsSetValue(idx, val))
		#define TLS_GET_VALUE(idx) (TlsGetValue(idx))

	/*------------------------------------------*/
	/* WINDOWS-W32 thread local storage macros	*/
	#else
		#define TLS_ALLOC(idx) ((idx = TlsAlloc()) == 0xFFFFFFFF)
		#define TLS_FREE(idx) (!TlsFree(idx))
		#define TLS_SET_VALUE(idx, val) (!TlsSetValue(idx, val))
		#define TLS_GET_VALUE(idx) (TlsGetValue(idx))
	#endif /* UNDER_RTSS */
#endif /* WIN32 */

/*------------------------------------------*/
/* POSIX thread local storage macros		*/
#ifdef POSIX
	#define TLS_ALLOC(idx)          (pthread_key_create((pthread_key_t*)&idx, NULL))
	#define TLS_FREE(idx)           (pthread_key_delete((pthread_key_t)idx))
	#define TLS_SET_VALUE(idx, val) (pthread_setspecific((pthread_key_t)idx, (void*)val))
	#define TLS_GET_VALUE(idx)      (pthread_getspecific((pthread_key_t)idx))
#endif /*POSIX*/

/*--------------------------------------------------*/
/* VXWORKS_6_9 NATIVE thread local storage macros	*/
#if defined VXWORKS_6_9 && defined NATIVE
	#define TLS_ALLOC(idx) 			(lib_tls_alloc(&idx))
	#define TLS_FREE(idx) 			(lib_tls_free(idx))
	#define TLS_SET_VALUE(idx, val) (lib_tls_set_value(idx,val))
	#define TLS_GET_VALUE(idx) 		(lib_tls_get_value(idx))
#endif /*VXWORKS_6_9 && NATIVE*/

/*------------------------------------------*/
/* F_ITRON thread local storage macros		*/
#if defined F_ITRON
	#define TLS_ALLOC(idx) 			(lib_tls_alloc(&idx))
	#define TLS_FREE(idx) 			(lib_tls_free(idx))
	#define TLS_SET_VALUE(idx, val) (lib_tls_set_value(idx,val))
	#define TLS_GET_VALUE(idx) 		(lib_tls_get_value(idx))
#endif /*F_ITRON*/

/*------------------------------------------------------------------------------
 * Yield function implementation
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* WINDOWS-RTX Yield function				*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#define YIELD() do {uSleep(1);} while(0)

	/*------------------------------------------*/
	/* WINDOWS-W32 Yield function				*/
	#else
		#define YIELD() do {Sleep(1);} while(0)
	#endif /* UNDER_RTSS */
#endif /* WIN32 */

/*------------------------------------------*/
/* POSIX-LINUX Yield function				*/
#if defined POSIX && defined LINUX
	#define YIELD()     (usleep(1))
#endif /*LINUX*/

/*------------------------------------------*/
/* POSIX-QNX6 Yield function */
#if defined POSIX && defined QNX6
	#define YIELD()     (sched_yield())
#endif  /*POSIX-QNX6*/

/*------------------------------------------*/
/* VXWORKS Yield function */
#ifdef VXWORKS_6_9
	#define YIELD()     lib_vxworks_6_9_yield()
#endif /* VXWORKS */

/*------------------------------------------*/
/* F_ITRON Yield function */
#ifdef F_ITRON
	#define YIELD() lib_fitron_yield()
#endif /* F_ITRON */

/*------------------------------------------------------------------------------
 * file access functions
 *-----------------------------------------------------------------------------*/
#ifndef F_ITRON
	#define EFILE								FILE
	#define EFOPEN(name, access)                (fopen(name, access))
	#define EFCLOSE(pfile) 		                (fclose(pfile))
	#define EFPRINTF(pfile,fmt,...)             (fprintf(pfile,fmt, ## __VA_ARGS__))
	#define EVFPRINTF(pfile,fmt,args)           (vfprintf(pfile,fmt, args))
	#define EFSCANF(pfile,fmt,...)              (fscanf(pfile,fmt, ## __VA_ARGS__))
	#define EFWRITE(buf,size,count,pfile)       (fwrite(buf,size,count,pfile))
	#define EFREAD(buf,size,count,pfile)        (fread(buf,size,count,pfile))
	#define EFSEEK(pfile,offset,origin)  	    (fseek(pfile,offset,origin))
	#define EFTELL(pfile) 				 	    (ftell(pfile))
	#define EFGETS(buf,nb,pfile)		  	    (fgets(buf,nb,pfile))
	#define EFEOF(pfile)				  	    (feof(pfile))
	#define EFERROR(pfile)				  	    (ferror(pfile))
#else	
	#define EFILE								FJ_FILE
	#define EFOPEN(name, access)                (lib_fitron_file_open(name, access))
	#define EFCLOSE(pfile) 		                (lib_fitron_file_close(pfile))
	#define EFPRINTF(pfile,fmt,...)             (lib_fitron_file_printf(pfile,fmt, ## __VA_ARGS__))
	#define EVFPRINTF(pfile,fmt,args)           (lib_fitron_file_vprintf(pfile,fmt, args))
//	#define EFSCANF(pfile,fmt,...)              (lib_fitron_file_scanf(pfile,fmt, ## __VA_ARGS__))
	#define EFWRITE(buf,size,count,pfile)       (lib_fitron_file_write(buf,size,count,pfile))
	#define EFREAD(buf,size,count,pfile)        (lib_fitron_file_read(buf,size,count,pfile))
	#define EFSEEK(pfile,offset,origin)  	    (lib_fitron_file_seek(pfile,offset,origin))
	#define EFTELL(pfile) 				 	    (lib_fitron_file_tell(pfile))
	#define EFGETS(buf,nb,pfile)		  	    (lib_fitron_fgets(buf,nb,pfile))
	#define EFEOF(pfile)				  	    (lib_fitron_feof(pfile))
	#define EFERROR(pfile)				  	    (lib_fitron_ferror(pfile))
#endif

/*------------------------------------------------------------------------------
 * fifo macro - put/get/extract a message in/form a first in first out queue.
 * a valid fifo queue is a structure who defines 'first'
 * and 'last' pointer to a message.
 * a valid message is a structure which define a 'next' pointer
 *-----------------------------------------------------------------------------*/
#define FIFO_EXTRACT(queue, msg, lmsg)                                      \
    do {                                                                    \
        if(lmsg) {                                                          \
            if(((msg) = (lmsg)->next))                                      \
                if(!((lmsg)->next = (msg)->next)) (queue).last = lmsg;      \
        } else {                                                            \
            if(((msg) = (queue).first))                                     \
                if(!((queue).first = (msg)->next))(queue).last = NULL;      \
        }                                             \
    } while(0)
#define FIFO_GET(queue, msg)                    \
    do {                                        \
        if(((msg) = (queue).first)) {             \
            if(!((queue).first = (msg)->next))  \
                (queue).last = NULL;            \
            (msg)->next = NULL;                 \
        }                                       \
    } while(0)
#define FIFO_PUT(queue, msg)                          \
    do {                                              \
        (msg)->next = NULL;                           \
        if(!(queue).first) {                          \
            (queue).first = (msg);                    \
            (queue).last = (msg);                     \
        } else {                                      \
            (queue).last->next = (msg);               \
            queue.last = (msg);                       \
        }                                             \
    } while(0)
#define FIFO_INS(queue, msg)                          \
    do {                                              \
        if(!(queue).first) {                          \
            (msg)->next = NULL;                       \
            (queue).first = (msg);                    \
            (queue).last = (msg);                     \
        } else {                                      \
            (msg)->next = (queue).first;              \
            (queue).first = (msg);                    \
        }                                             \
    } while(0)


/*------------------------------------------------------------------------------
 * lifo macro - put/get/extract a message in/form a last in first out queue.
 * a valid lifo queue is a structure who defines 'first' pointer to a message.
 * a valid message is a structure which define a 'next' pointer
 *-----------------------------------------------------------------------------*/
#define LIFO_GET(queue, msg)                          \
    do {                                              \
        if(((msg) = (queue).first)) {                   \
            (queue).first = (msg)->next;              \
            (msg)->next = NULL;                       \
        }                                             \
    } while(0)
#define LIFO_PUT(queue, msg)                          \
    do {                                              \
        (msg)->next = (queue).first;                  \
        (queue).first = (msg);                        \
    } while(0)


/*------------------------------------------------------------------------------
 * diverses MACROS
 *-----------------------------------------------------------------------------*/
#ifndef MIN
	#define MIN(A, B)   ((A) < (B) ? (A) : (B))
	#define MAX(A, B)   ((A) > (B) ? (A) : (B))
#endif	
#define ONEBIT(A)   ((A) && !((A) & ((A)-1)))


/**********************************************************************************************************/
/* functions */
/**********************************************************************************************************/

/*------------------------------------------------------------------------------
 * Math functions
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* POSIX except VXWORKS_6_9 Math functions	*/
#if defined POSIX && !defined VXWORKS_6_9
	#define _isnan(d)   (isnan(d))
	#define _finite(d)  (finite(d))
#endif /*POSIX*/
	
/*------------------------------------------*/
/* VXWORKS_6_9 Math functions				*/
#ifdef VXWORKS_6_9
	#define _isnan(d)   (isnan(d))
	#define _finite(d)  (isfinite(d))
#endif /*VXWORKS_6_9*/

/*------------------------------------------*/
/* F_ITRON Math functions					*/
#ifdef F_ITRON
	#define _isnan(d)   (isnan(d))
	#define _finite(d)  (finite(d))
#endif /*F_ITRON*/

/*------------------------------------------------------------------------------
 * libver.c
 *-----------------------------------------------------------------------------*/
time_t	_LIB_EXPORT lib_get_build_time(void);
dword   _LIB_EXPORT lib_get_version(void);
dword   _LIB_EXPORT lib_get_edi_version(void);

/*------------------------------------------------------------------------------
 * libtim.c
 * Function for time access 
 *-----------------------------------------------------------------------------*/
eint64	_LIB_EXPORT tim_counter(void);
double	_LIB_EXPORT tim_dbl_counter(void);

/*------------------------------------------------------------------------------
 * libdbg.c
 * Function for dbgview 
 * DBGVIEW Not implemented on F_ITRON because shared memory not available 
 *-----------------------------------------------------------------------------*/
#if !defined UNDER_RTSS && !defined F_ITRON
    void    _LIB_EXPORT dbg_init(void);
    void    _LIB_EXPORT dbg_reset(void);
    void    _LIB_EXPORT dbg_set_kind_mask(dword mask);
    dword   _LIB_EXPORT dbg_get_kind_mask(void);
    void    _LIB_EXPORT dbg_set_source_mask(dword mask);
    dword   _LIB_EXPORT dbg_get_source_mask(void);
    void    _LIB_EXPORT dbg_set_stream_mask(dword mask);
    dword   _LIB_EXPORT dbg_get_stream_mask(void);
    int     _LIB_EXPORT dbg_get_entry_size(void);
    int     _LIB_EXPORT dbg_get_entry_number(void);
    int     _LIB_EXPORT dbg_get_entry_count(void);
    void    _LIB_EXPORT dbg_fetch_data(DBG_ENTRY *buffer);
    int     _LIB_EXPORT dbg_fetch_last_data(DBG_ENTRY *buffer, int *entry_count);
    void    _LIB_EXPORT dbg_put_im(int source, const char *fct, const char *msg, ...);
    void    _LIB_EXPORT dbg_put_wm(int source, const char *fct, const char *msg, ...);
    void    _LIB_EXPORT dbg_put_em(int source, const char *fct, const char *msg, int ecode, ...);
    void    _LIB_EXPORT dbg_put_fm(int source, const char *fct, const char *msg, int ecode, ...);
    void    _LIB_EXPORT dbg_put_is(int source, const char *fct, const char *msg, int stream, int protocol, int port, const char *rbuffer, size_t rsize, const char *sbuffer, size_t ssize, ...);
    void    _LIB_EXPORT dbg_put_os(int source, const char *fct, const char *msg, int stream, int protocol, int port, const char *buffer, size_t size, ...);
    void    _LIB_EXPORT dbg_put_bf(int source, const char *fct, const char *msg, ...);
    void    _LIB_EXPORT dbg_put_ef(int source, const char *fct, const char *msg, int ecode, ...);
    void    _LIB_EXPORT dbg_put_mm(const char *fct, const char *msg, ...);
    void	_LIB_EXPORT dbg_set_display_mode(int mode);
    int		_LIB_EXPORT dbg_get_display_mode();
#endif /*!defined UNDER_RTSS */

#ifdef UNDER_RTSS
    void    _LIB_EXPORT dbg_put_im(int source, const char *fct, const char *msg, ...);
    void    _LIB_EXPORT dbg_put_wm(int source, const char *fct, const char *msg, ...);
    void    _LIB_EXPORT dbg_put_em(int source, const char *fct, const char *msg, int ecode, ...);
    void    _LIB_EXPORT dbg_put_fm(int source, const char *fct, const char *msg, int ecode, ...);
    void    _LIB_EXPORT dbg_put_is(int source, const char *fct, const char *msg, int stream, int protocol, int port, const char *rbuffer, size_t rsize, const char *sbuffer, size_t ssize, ...);
    void    _LIB_EXPORT dbg_put_os(int source, const char *fct, const char *msg, int stream, int protocol, int port, const char *buffer, size_t size, ...);
    void    _LIB_EXPORT dbg_put_bf(int source, const char *fct, const char *msg, ...);
    void    _LIB_EXPORT dbg_put_ef(int source, const char *fct, const char *msg, int ecode, ...);
    void    _LIB_EXPORT dbg_put_mm(const char *fct, const char *msg, ...);
#endif /* UNDER_RTSS */

#if defined WIN32 || defined POSIX || defined VXWORKS_6_9
	#if !defined NDEBUG && !defined _NDEBUG
		#define DBG_PUT_IM(source, fct, msg, ...) dbg_put_im(source, fct,msg, ## __VA_ARGS__)
		#define DBG_PUT_WM(source, fct, msg, ...) dbg_put_wm(source, fct,msg, ## __VA_ARGS__)
		#define DBG_PUT_EM(source, fct, msg, ecode, ...) dbg_put_em(source, fct, msg, ecode, ## __VA_ARGS__)
		#define DBG_PUT_FM(source, fct, msg, ecode, ...) dbg_put_fm(source, fct, msg, ecode, ## __VA_ARGS__)
		#define DBG_PUT_IS(source, fct, msg, stream, protocol, port, rbuffer, rsize, sbuffer, ssize, ...) dbg_put_is(source, fct, msg, stream, protocol, port, rbuffer, rsize, sbuffer, ssize, ## __VA_ARGS__)
		#define DBG_PUT_OS(source, fct, msg, stream, protocol, port, buffer, size, ...) dbg_put_os(source, fct, msg, stream, protocol, port, buffer, size, ## __VA_ARGS__)		
		#define DBG_PUT_BF(source, fct, msg, ...) dbg_put_bf(source,fct,msg, ## __VA_ARGS__)
		#define DBG_PUT_EF(source, fct, msg, ecode, ...) dbg_put_ef(source, fct, msg, ecode, ## __VA_ARGS__)
	#else /* DEBUG */
        #ifdef VXWORKS_6_9
		    #define DBG_PUT_IM nothing
		    #define DBG_PUT_WM nothing
		    #define DBG_PUT_EM nothing
		    #define DBG_PUT_FM nothing
		    #define DBG_PUT_IS nothing
		    #define DBG_PUT_OS nothing
		    #define DBG_PUT_BF nothing
		    #define DBG_PUT_EF nothing
        #else
		    #define DBG_PUT_IM
		    #define DBG_PUT_WM
		    #define DBG_PUT_EM
		    #define DBG_PUT_FM
		    #define DBG_PUT_IS
		    #define DBG_PUT_OS
		    #define DBG_PUT_BF
		    #define DBG_PUT_EF
    	#endif /* VXWORKS_6_9*/
	#endif /* DEBUG */
	void _LIB_EXPORT nothing(int source, ...);
#endif /* WIN32 || POSIX || defined VXWORKS_6_9*/

#if defined F_ITRON
	/* DBGVIEW Not implemented on F_ITRON because shared memory not available */
	void _LIB_EXPORT nothing(int source, ...);
	#define DBG_PUT_IM nothing
	#define DBG_PUT_WM nothing
	#define DBG_PUT_EM nothing
	#define DBG_PUT_FM nothing
	#define DBG_PUT_IS nothing
	#define DBG_PUT_OS nothing
	#define DBG_PUT_BF nothing
	#define DBG_PUT_EF nothing
#endif /* F_ITRON */


/*------------------------------------------------------------------------------
 * libmem.c
 * Base functions to handle memory allocation.
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* WINDOWS-RTX memory allocation functions	*/
#if defined WIN32
	size_t _LIB_EXPORT                  lib_get_mem_usage();
	#define MALLOC(size)                malloc(size)
	#define CALLOC(num, size)           calloc(num, size)
	#define REALLOC(memblock, size)     realloc(memblock, size)
	#define FREE(membloc)               free(membloc)
#endif /* WIN32 */


/*---------------------------------------------------*/
/* POSIX || VXWORKS_6_9 memory allocation functions	 */
#if defined POSIX || defined VXWORKS_6_9
	#define MALLOC(size)                malloc(size)
	#define CALLOC(num, size)           calloc(num, size)
	#define REALLOC(memblock, size)     realloc(memblock, size)
	#define FREE(membloc)               free(membloc)
#endif /* POSIX || VXWORKS_6_9*/

/*------------------------------------------*/
/* F_ITRON memory allocation functions		*/
#ifdef F_ITRON
    int     _LIB_EXPORT lib_mem_get_edi_heap_info(FJ_ID *head_ID, void** heap_addr, int *heap_size);
//	DBGVIEW not implemented in ITRON because shared memory not available	
//  int     _LIB_EXPORT lib_mem_get_dbgview_shm_info(void** shm_addr, int *shm_size);
    int     _LIB_EXPORT lib_mem_get_etnd_shm_info(void** shm_addr, int *shm_size);
	void* 	_LIB_EXPORT lib_mem_malloc(size_t size);
	void* 	_LIB_EXPORT lib_mem_calloc(size_t num, size_t size);
	void* 	_LIB_EXPORT lib_mem_realloc(void *memblock, size_t size);
	void   	_LIB_EXPORT lib_mem_free(void *memblock);
	#define MALLOC(size)                lib_mem_malloc(size)
	#define CALLOC(num, size)           lib_mem_calloc(num, size)
	#define REALLOC(memblock, size)     lib_mem_realloc(memblock, size)
	#define FREE(membloc)               lib_mem_free(membloc)
#endif /* F_ITRON */

/*------------------------------------------------------------------------------
 * libpro.c
 * All system properties access function
 *-----------------------------------------------------------------------------*/
#if defined WIN32 || defined POSIX || defined VXWORKS_6_9
    int		_LIB_EXPORT pro_create(PRO **rpro);
    int     _LIB_EXPORT pro_destroy(PRO **rpro);
    int     _LIB_EXPORT pro_open_f(PRO *pro, char_cp fn);
    int     _LIB_EXPORT pro_open_s(PRO *pro, char_cp host, short port);
    int     _LIB_EXPORT pro_send_sh(PRO *pro, SOCKET sock);
    char_cp _LIB_EXPORT pro_get_next(PRO *pro, char_cp name);
    char_cp _LIB_EXPORT pro_get_string(PRO *pro, char_cp name, char_cp def);
    int     _LIB_EXPORT pro_get_int(PRO *pro, char_cp name, int def);
    long    _LIB_EXPORT pro_get_long(PRO *pro, char_cp name, long def);
    double  _LIB_EXPORT pro_get_double(PRO *pro, char_cp name, double def);
    int     _LIB_EXPORT pro_add_property(PRO *pro, char_cp name);
    int     _LIB_EXPORT pro_add_string(PRO *pro, char_cp name, char_cp str);
    int     _LIB_EXPORT pro_add_int(PRO *pro, char_cp name, int val);
    int     _LIB_EXPORT pro_add_long(PRO *pro, char_cp name, long val);
    int     _LIB_EXPORT pro_add_double(PRO *pro, char_cp name, double val);
    int     _LIB_EXPORT pro_erase(PRO *pro);
    int     _LIB_EXPORT pro_commit(PRO *pro);
#endif /* defined WIN32 || defined POSIX || defined VXWORKS_6_9*/


/*------------------------------------------------------------------------------
 * libtls.c
 *-----------------------------------------------------------------------------*/
/*------------------------------*/
/* F_ITRON tls functions		*/
#if defined F_ITRON
	int 	_LIB_EXPORT lib_tls_alloc();
	int 	_LIB_EXPORT lib_tls_free(dword idx);
	int 	_LIB_EXPORT lib_tls_set_value(dword idx, void* val);
	void* 	_LIB_EXPORT lib_tls_get_value(dword idx);
#endif /* F_ITRON */

/*--------------------------------------*/
/* VXWORKS_6_9 NATIVE tls functions		*/
#if defined VXWORKS_6_9 && defined NATIVE
	int 	_LIB_EXPORT lib_tls_alloc();
	int 	_LIB_EXPORT lib_tls_free(dword idx);
	int 	_LIB_EXPORT lib_tls_set_value(dword idx, void* val);
	void* 	_LIB_EXPORT lib_tls_get_value(dword idx);
#endif /*VXWORKS_6_9 && NATIVE*/

/*------------------------------------------------------------------------------
 * librtx.c
 * Thread and task function
 *-----------------------------------------------------------------------------*/
#if defined WIN32 && !defined UNDER_RTSS
	THREAD	_LIB_EXPORT rtx_beginthread(int (*fct)(void *param), void *param);
	THREAD  _LIB_EXPORT rtx_begin_named_thread(const char *name, int (*fct)(void *param), void *param);
	char_cp _LIB_EXPORT rtx_get_thread_name(THREAD thread);
#endif /* defined WIN32 && !defined UNDER_RTSS */
#ifdef F_ITRON
	THREAD 	_LIB_EXPORT lib_fitron_task_create(void *fct, void *arg, int prio, char *name);
	void 	_LIB_EXPORT lib_fitron_task_destroy();
	THREAD 	_LIB_EXPORT lib_fitron_get_task_id();
	int		_LIB_EXPORT lib_fitron_task_wait(THREAD thr, int timeout);
#endif /* F_ITRON */

/*------------------------------------------------------------------------------
 * libnet.c
 * TCP/IP access functions
 *-----------------------------------------------------------------------------*/
/*------------------------------------------------------------------*/
/* WINDOWS, POSIX, VXWORKS_6_9 functions		*/
#if defined WIN32 || defined POSIX || defined VXWORKS_6_9
	int 		_LIB_EXPORT net_init(void);
	int 		_LIB_EXPORT net_recv(SOCKET s, char *buf, int len, int flags);
	int 		_LIB_EXPORT net_recvfrom(SOCKET s, char *buf, int len, int flags, struct sockaddr *from, int *fromlen);
	int 		_LIB_EXPORT net_send(SOCKET s, char *buf, int len, int flags);
	int 		_LIB_EXPORT net_sendto(SOCKET s, char *buf, int len, int flags, const struct sockaddr *to, int tolen);
	int 		_LIB_EXPORT net_socket(int af, int type, int protocol);
	int 		_LIB_EXPORT net_connect(SOCKET s, const struct sockaddr *name, int namelen);
	int 		_LIB_EXPORT net_close(SOCKET s);
	int 		_LIB_EXPORT net_listen(SOCKET s, int backlog);
	int 		_LIB_EXPORT net_accept(SOCKET s, struct sockaddr *addr, int *addrlen);
	int 		_LIB_EXPORT net_bind(SOCKET s, const struct sockaddr *name, int namelen);
	int 		_LIB_EXPORT net_setsockopt(SOCKET s, int level, int optname, const char *optval, int optlen);
	int 		_LIB_EXPORT net_getsockopt(SOCKET s, int level, int optname, char *optval, int *optlen);
	int 		_LIB_EXPORT net_select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, const struct timeval *timeout);
	HOSTENT* 	_LIB_EXPORT net_gethostbyname(const char* name);
	int 		_LIB_EXPORT net_gethostname(char* name, int size);
	u_long		_LIB_EXPORT net_inet_addr(const char* cp);
	u_short 	_LIB_EXPORT net_ntohs(u_short netshort);
	u_long  	_LIB_EXPORT net_ntohl(u_long netlong);
	u_short 	_LIB_EXPORT net_htons(u_short hostshort);
	u_long  	_LIB_EXPORT net_htonl(u_long hostlong);

	#if defined WIN32
		int _LIB_EXPORT net_wsa_fd_is_set(SOCKET s, fd_set FAR *fd);
		int _LIB_EXPORT net_get_last_error();
		#ifndef UNDER_RTSS
			#define __WSAFDIsSet net_wsa_fd_is_set
		#endif /* UNDER_RTSS */
	#else
		int _LIB_EXPORT net_wsa_fd_is_set(SOCKET s, fd_set *fd);
	#endif /* WIN32*/
#endif /* WIN32 || POSIX || VXWORKS_6_9*/

#if defined F_ITRON
	int 		_LIB_EXPORT net_init(void);
	int 		_LIB_EXPORT net_recv(SOCKET s, char *buf, int len, int flags);
	int 		_LIB_EXPORT net_send(SOCKET s, char *buf, int len, int flags);
	int 		_LIB_EXPORT net_socket(int af, int type, int protocol);
	int 		_LIB_EXPORT net_connect(SOCKET s, const struct sockaddr *name, int namelen);
	int 		_LIB_EXPORT net_close(SOCKET s);
	int 		_LIB_EXPORT net_listen(SOCKET s, int backlog);
	int 		_LIB_EXPORT net_accept(SOCKET s, struct sockaddr *addr, int *addrlen);
	int 		_LIB_EXPORT net_bind(SOCKET s, const struct sockaddr *name, int namelen);
	int 		_LIB_EXPORT net_setsockopt(SOCKET s, int level, int optname, const char *optval, int optlen);
	int 		_LIB_EXPORT net_getsockopt(SOCKET s, int level, int optname, char *optval, int *optlen);
	int 		_LIB_EXPORT net_select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, const struct timeval *timeout);
	u_short 	_LIB_EXPORT net_ntohs(u_short netshort);
	u_long  	_LIB_EXPORT net_ntohl(u_long netlong);
	u_short 	_LIB_EXPORT net_htons(u_short hostshort);
	u_long  	_LIB_EXPORT net_htonl(u_long hostlong);
//  NOT IMPLEMENTED ON f_itron	
//	u_long		_LIB_EXPORT net_inet_addr(const char* cp);
//	HOSTENT* 	_LIB_EXPORT net_gethostbyname(const char* name);
//	int 		_LIB_EXPORT net_gethostname(char* name, int size);
#endif /* defined F_ITRON */


/*------------------------------------------------------------------------------
 * libjni.c
 * Windows-W32 java JNI access function
 *-----------------------------------------------------------------------------*/
#if defined WIN32 && !defined UNDER_RTSS
	void    	_LIB_EXPORT jni_set_vm(jnivm_p);
	jnivm_p 	_LIB_EXPORT jni_get_vm(void);
	jnienv_p	_LIB_EXPORT jni_get_env(void);
	void    	_LIB_EXPORT jni_detach(void);
	jobject 	_LIB_EXPORT jni_create_object(jnienv_p env, const char *name, const char *sig, ...);
	void    	_LIB_EXPORT jni_out_of_memory_error(jnienv_p env, const char *s);
	void    	_LIB_EXPORT jni_illegal_argument_exception(jnienv_p env, const char *s);
	void    	_LIB_EXPORT jni_illegal_state_exception(jnienv_p env, const char *s);
#endif /* defined WIN32 && !defined UNDER_RTSS */

/*------------------------------------------------------------------------------
 * libshm.c
 *------------------------------------------------------------------------------*/
int _LIB_EXPORT shm_exist(char *name, void *addr, int size);
int _LIB_EXPORT shm_create(SHM **shm_obj, char *name, void *addr, dword size);
int _LIB_EXPORT shm_destroy(SHM *shm_obj);
int _LIB_EXPORT shm_map(SHM *shm_obj, void **addr);
int _LIB_EXPORT shm_unmap(SHM *shm_obj, void *addr);


/*------------------------------------------------------------------------------
 * libprio.c
 * Priority setting functions
 *------------------------------------------------------------------------------*/
/*------------------------------------------*/
/* POSIX priority setting functions			*/
#if defined POSIX
	int _LIB_EXPORT thread_get_prio(pthread_t thr);
	void _LIB_EXPORT thread_set_prio(pthread_t thr, int prio);
	void _LIB_EXPORT thread_set_policy(pthread_t thr, int policy, int prio);
#endif /* POSIX */

/*------------------------------------------------------------------------------
 * libwait.c
 * Waiting synchronisation object functions
 *------------------------------------------------------------------------------*/
 /*------------------------------------------*/
/* POSIX synchronisation object functions	*/
#if defined POSIX
	int 	_LIB_EXPORT event_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *state, int *error, int timeout);
	int 	_LIB_EXPORT autoevent_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *state, int *error, int timeout);
	int 	_LIB_EXPORT mutex_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, THREAD *tid, int *counter, int *error, int timeout);
	int 	_LIB_EXPORT local_sema_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *counter, int *error, int timeout);
	void	_LIB_EXPORT special_sleep(long time);
	void 	_LIB_EXPORT lib_vxworks_6_9_yield();
#endif /* POSIX */

#ifdef UNDER_RTSS
	int		_LIB_EXPORT lib_wait_for_thread (THREAD thr, int timeout);
	void 	_LIB_EXPORT uSleep(long us);
#endif /*UNDER_RTSS*/

/*------------------------------------------*/
/* F_ITRON synchronisation object functions	*/
#ifdef F_ITRON
	int _LIB_EXPORT lib_fitron_edi_init(FJ_ID firstLockIndex,  dword nbLock,
										FJ_ID firstEventIndex, dword nbEvent,
										FJ_ID firstSemaIndex,  dword nbSema);
	int _LIB_EXPORT lib_fitron_edi_exit();
	/* CRITICAL SECTION function */
	void 	_LIB_EXPORT lib_fitron_critical_create(FJ_ID csID, FJ_ID *cs, int *counter, FJ_ID *pid);
	void 	_LIB_EXPORT lib_fitron_critical_destroy(FJ_ID *cs);
	void 	_LIB_EXPORT lib_fitron_critical_enter(FJ_ID *cs, int *counter, FJ_ID *pid);
	void 	_LIB_EXPORT lib_fitron_critical_leave(FJ_ID *cs, int *counter, FJ_ID *pid);

	/* EVENT functions */
	FJ_ID	_LIB_EXPORT lib_fitron_event_create(FJ_ID ev_id, bool init);
	void 	_LIB_EXPORT lib_fitron_event_destroy(FJ_ID ev_id);
	void 	_LIB_EXPORT lib_fitron_event_set(FJ_ID ev_id);
	void 	_LIB_EXPORT lib_fitron_event_reset(FJ_ID ev_id);
	int 	_LIB_EXPORT lib_fitron_event_wait(FJ_ID ev_id, int timeout);

	/* AUTOEVENT functions */
	FJ_ID 	_LIB_EXPORT lib_fitron_autoevent_create(FJ_ID ev_id, bool init);
	void 	_LIB_EXPORT lib_fitron_autoevent_destroy(FJ_ID ev_id);
	void 	_LIB_EXPORT lib_fitron_autoevent_set(FJ_ID ev_id);
	void 	_LIB_EXPORT lib_fitron_autoevent_reset(FJ_ID ev_id);
	int 	_LIB_EXPORT lib_fitron_autoevent_wait(FJ_ID ev_id, int timeout);
	
	/* MUTEX functions */
	void 	_LIB_EXPORT lib_fitron_mutex_create(FJ_ID csID, FJ_ID *cs, int *counter, FJ_ID *pid, int init);
	void 	_LIB_EXPORT lib_fitron_mutex_destroy(FJ_ID *cs);
	void 	_LIB_EXPORT lib_fitron_mutex_release(FJ_ID *cs, int *counter, FJ_ID *pid);
	int 	_LIB_EXPORT lib_fitron_mutex_wait(FJ_ID *cs, int *counter, FJ_ID *pid, int timeout);

	/* SEMACOUNT functions */
	FJ_ID 	_LIB_EXPORT lib_fitron_semaphore_create(FJ_ID semaID, dword init, dword max);
	void 	_LIB_EXPORT lib_fitron_semaphore_destroy(FJ_ID semaID);
	void 	_LIB_EXPORT lib_fitron_semaphore_release(FJ_ID semaID);
	int 	_LIB_EXPORT lib_fitron_semaphore_wait(FJ_ID semaID, int timeout);
	void 	_LIB_EXPORT lib_fitron_semaphore_set(FJ_ID *target, FJ_ID *source);

	/* DELAY functions */
	void 	_LIB_EXPORT special_sleep(long time);
	void 	_LIB_EXPORT lib_fitron_yield();
#endif /*F_ITRON*/

/*-----------------------------------------------------*/
/* VXWORKS_6_9 NATIVE synchronisation object functions	*/
#if defined VXWORKS_6_9 && defined NATIVE
	void _LIB_EXPORT task_wait(int thr, int timeout);
	int _LIB_EXPORT task_get_prio(int task);
	void _LIB_EXPORT task_set_prio(int task, int prio);

	int _LIB_EXPORT event_wait(SEM_ID event, int timeout);
	int _LIB_EXPORT autoevent_wait(SEM_ID event, int timeout);
	int _LIB_EXPORT mutex_wait(SEM_ID event, int timeout);
	int _LIB_EXPORT local_sema_wait_old(SEM_ID mutex, SEM_ID ev, int *counter, int timeout);
	int _LIB_EXPORT local_sema_wait(SEM_ID SEM, int timeout);
	int _LIB_EXPORT critical_enter(SEM_ID event);
	void	_LIB_EXPORT special_sleep(long time);
	void 	_LIB_EXPORT lib_vxworks_6_9_yield();
#endif /*VXWORKS_6_9 && NATIVE */


/*------------------------------------------------------------------------------
 * libzip.c
 * zip/unzip file function (Windows, Posix)
 * unzip from memory to memory (All OS)
 *------------------------------------------------------------------------------*/
#if defined WIN32 || defined POSIX || defined F_ITRON || defined VXWORKS_6_9
	#if !defined UNDER_RTSS
		int _LIB_EXPORT zip_fw_unzip(char *zipFile, char *extractDir);
		int _LIB_EXPORT zip_fw_get_manifest (char *extractDir, FW_MANIFEST *fw_manifest);
		int _LIB_EXPORT zip_unzip(char *zipFile, char *extractDir, char *flags);
		int _LIB_EXPORT zip_zip(char *zipFile, char *dir, char *flags);
	#endif //!defined UNDER_RTSS
	int _LIB_EXPORT zip_unzip_buffer(size_t src_size, char *src_buf, size_t dest_size, byte *dest_buf, size_t *unzipped_size);
    int _LIB_EXPORT zip_unzip_multiple_file_buffer(size_t src_size, char *src_buf, char *sub_file_name, size_t dest_size, byte *dest_buf, size_t *unzipped_size);
#endif //defined WIN32 || defined POSIX


/*------------------------------------------------------------------------------
 * libdir.c (directory search)
 * All OS except RTX
 *------------------------------------------------------------------------------*/
#if (defined WIN32 && !defined UNDER_RTSS) || defined POSIX || defined F_ITRON || defined VXWORKS_6_9
	int _LIB_EXPORT dir_find_first_file (char *dirName, DIRECTORY_ENTRY *entry);
	int _LIB_EXPORT dir_find_next_file (DIRECTORY_ENTRY *entry);
	int _LIB_EXPORT dir_find_abort();
	int _LIB_EXPORT dir_remove(char *dirName);
	int _LIB_EXPORT dir_mkdir (char *dir_name);
	int _LIB_EXPORT dir_chdir (char *dir_name);
	int _LIB_EXPORT dir_getdir (char *dir_name, int size);
	int _LIB_EXPORT dir_file_copy (char *srcFileName, char *destFileName);
	int _LIB_EXPORT dir_dir_copy (char *srcDirName, char *destDirName);
#endif
/*------------------------------------------------------------------------------
 * libdir.c (file access search)
 * All OS
 *------------------------------------------------------------------------------*/
#if defined WIN32 || defined POSIX || F_ITRON || defined VXWORKS_6_9 
	char* _LIB_EXPORT dir_tmpname();
	int _LIB_EXPORT dir_file_remove(char *fileName);
	int _LIB_EXPORT dir_access(char *dirName, int mode);
	int _LIB_EXPORT dir_file_copy(char *srcFileName, char *destFileName);
#endif

#if (defined WIN32 && !defined UNDER_RTSS)
	int _LIB_EXPORT dir_get_dll_path(char *dll_name, int size, char *dll_path);
	bool _LIB_EXPORT lib_is_64bits();
#endif

/*------------------------------------------------------------------------------
 * liberr.c
 * Error generation and display functions
 *------------------------------------------------------------------------------*/
#define CREATE_EDI_ERROR(fctName,errorNr,errorText,comment,axisMask,recNr,cmd,timeout) \
    do {\
        lib_create_error(__FILE__, __LINE__, fctName,errorNr,errorText,comment,axisMask,recNr,cmd,timeout); \
    } while(0)
#define SET_EDI_ERROR_PARAM(axisMask,recNr,cmd,timeout) \
    do {\
        lib_set_error_param(axisMask,recNr,cmd,timeout); \
    } while(0)
#define ADD_EDI_TRACE(fctName,comment) \
    do {\
        lib_add_error_trace(__FILE__, __LINE__, fctName,comment); \
    } while(0)
#define TRACE_OFF() \
    do {\
        lib_trace_off(); \
    } while(0)
#define TRACE_ON() \
    do {\
        lib_trace_on(); \
    } while(0)

int 	_LIB_EXPORT lib_create_error(	char *file,
										int line,
										const char *fctName,
										int errorNr,
										const char *errorText,
										char *comment,
										eint64 axisMask,
										int recNr,
										int cmd,
										int timeout);
int 	_LIB_EXPORT lib_set_error_param(eint64 axisMask,
										int recNr,
										int cmd,
										int timeout);
int 	_LIB_EXPORT lib_add_error_trace(char *file,
										int line,
										const char *fctName,
										char *comment);
int 	_LIB_EXPORT lib_trace_off();
int 	_LIB_EXPORT lib_trace_on();
int 	_LIB_EXPORT lib_get_edi_error_command();
eint64 	_LIB_EXPORT lib_get_edi_error_axismask();
int 	_LIB_EXPORT lib_get_edi_error_record();
int 	_LIB_EXPORT lib_get_edi_error_timeout();
char* 	_LIB_EXPORT lib_get_edi_error_text(int size, char *str);
char *	_LIB_EXPORT lib_get_edi_small_error_text(int size, char *str);
char_cp _LIB_EXPORT lib_translate_edi_error(int code);


/*------------------------------------------------------------------------------
 * liblog.c
 * Logging function (replace printf,sprintf, etc which are not advised on some OS)
 *------------------------------------------------------------------------------*/
int _LIB_EXPORT vsedilog(char *string, const char *format, va_list vargs);
int _LIB_EXPORT sedilog(char *string, const char *format, ...);
int _LIB_EXPORT edilog(const char *format, ...);
int _LIB_EXPORT vedilog(const char *format, va_list vargs);

/*------------------------------------------------------------------------------
 * libstr.c
 * String uppercase function which are not standard
 *------------------------------------------------------------------------------*/
char* _LIB_EXPORT strToUpper(char *src);
char* _LIB_EXPORT strToLower(char *src);
int   _LIB_EXPORT lib_string_to_version(char *buffer, dword *version);
void  _LIB_EXPORT lib_version_to_string(char *buffer, int max, dword version);

/*------------------------------------------------------------------------------
 * libfile.c
 * File access functions
 *------------------------------------------------------------------------------*/
#ifdef F_ITRON
	EFILE* 	_LIB_EXPORT lib_fitron_file_open(char *name, char *access);
	int     _LIB_EXPORT lib_fitron_file_close(EFILE *pfile);
	int     _LIB_EXPORT lib_fitron_file_printf(EFILE *pfile, char *fmt, ...);
	int 	_LIB_EXPORT lib_fitron_file_vprintf(EFILE *pfile, const char *fmt, va_list args);
//	int      lib_fitron_file_scanf(EFILE *pfile, char *fmt, ...);
	size_t  _LIB_EXPORT lib_fitron_file_write(const void *buf, size_t size, size_t count, EFILE *pfile);
	size_t  _LIB_EXPORT lib_fitron_file_read(const void *buf, size_t size, size_t count, EFILE *pfile);
	int		_LIB_EXPORT lib_fitron_file_seek(EFILE *pfile, long offset, int origin);
	long	_LIB_EXPORT lib_fitron_file_tell(EFILE *pfile);
	char* 	_LIB_EXPORT lib_fitron_fgets(char *s, int n, EFILE *pfile);
	int 	_LIB_EXPORT lib_fitron_feof(EFILE *pfile);
	int 	_LIB_EXPORT lib_fitron_ferror(EFILE *pfile);
#endif

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* _LIB40_H */
