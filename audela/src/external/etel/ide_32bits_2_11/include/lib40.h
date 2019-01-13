/*
 * lib40.h
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
 * this header file contains public declaration for low-level library. it also
 * contains macro-definition for real-time objects/operations used to achieve
 * multi-platform source code.
 * @library lib40
 */

#ifndef _LIB40_H
#define _LIB40_H

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
		#include <jni.h>
	#endif /*UNDER_RTSS */
#endif /* WIN32 */

/*-----------------------*/
/* Common libraries*/
#include <stddef.h>
#include <string.h>
#include <assert.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#ifdef WIN32
	#ifdef _MSC_VER
		#if _MSC_VER > 1400
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



/*----------------------*/
/* POSIX LINUX libraries*/
#if defined POSIX && defined LINUX
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
#ifdef VXWORKS
	#include <taskLib.h>
	#include <sockLib.h>
	#include <dirent.h>
	#include <taskVarLib.h>
	#include <ioLib.h>
	#include <selectLib.h>
	#include <hostLib.h>
	#include <inetLib.h>
	#include <resolvLib.h>
	#include <logLib.h>
#endif /*VXWORKS */


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
#ifdef POSIX
	#define WAIT_OBJECT_0   0
	#define WAIT_TIMEOUT    -1
	#define WAIT_FAILED     -2
#endif /*POSIX*/

/*------------------------------------------*/
/* VXWORKS return value of wait functions	*/
#ifdef VXWORKS
	#define WAIT_OBJECT_0   0
	#define WAIT_TIMEOUT    -1
	#define WAIT_FAILED     -2
#endif /*VXWORKS*/


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
#endif /* LINUX */

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
#endif /* QNX6 */

/*------------------------------------------*/
/* VXWORKS thread priority levels			*/
/* High priority is 0 */
/* Should not be higher than 50 (priority < 50), because tNetTask runs at priority 50 */
#ifdef VXWORKS
	#define THREAD_PRIORITY_IDLE                255
	#define THREAD_PRIORITY_LOWEST              200
	#define THREAD_PRIORITY_BELOW_NORMAL        150
	#define THREAD_PRIORITY_NORMAL              100
	#define THREAD_PRIORITY_ABOVE_NORMAL        90
	#define THREAD_PRIORITY_HIGHEST             80
	#define THREAD_PRIORITY_TIME_CRITICAL       75
#endif /* VXWORKS */


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
#define DBG_STREAM_TCP                      0x03
#define DBG_STREAM_PCI                      0x04
#define DBG_STREAM_USB                      0x07

/*------------------------------------------------------------------------------
 * debug constants - protocol
 *-----------------------------------------------------------------------------*/
#define DBG_PROTOCOL_EBL2                   0x01
#define DBG_PROTOCOL_ETCOM                  0x02

/*------------------------------------------------------------------------------
 * socket constants
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* socket constants for POSIX				*/
#ifdef POSIX
	#define INVALID_SOCKET                      -1
#endif /*POSIX*/

/*------------------------------------------*/
/* socket constants for VXWORKS				*/
#ifdef VXWORKS
	#define INVALID_SOCKET                      -1
#endif /*VXWORKS*/



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
														
	/*------------------------------*/
	/* POSIX 64 bits integer		*/
	#elif defined POSIX || defined VXWORKS
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
	#endif
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
    char name[256];
    bool directory;
} DIRECTORY_ENTRY;


/*------------------------------------------------------------------------------
 * types for net module
 *-----------------------------------------------------------------------------*/
/*------------------------------*/
/* POSIX types for net module	*/
#ifdef POSIX
	typedef int SOCKET;
	typedef struct hostent HOSTENT;
	typedef struct sockaddr_in SOCKADDR_IN;
	typedef struct sockaddr SOCKADDR;
#endif /* POSIX */

/*------------------------------*/
/* VXWORKS types for net module */
#ifdef VXWORKS
	typedef int SOCKET;
	typedef struct hostent HOSTENT;
	typedef struct sockaddr_in SOCKADDR_IN;
#endif /*VXWORKS*/


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

/*------------------------------*/
/* POSIX type modifiers			*/
#ifdef POSIX
	#define _LIB_EXPORT
	#define LIB_EXPORT
#endif /*POSIX*/

/*------------------------------*/
/* VXWORKS type modifiers		*/
#ifdef VXWORKS
	#define _LIB_EXPORT
	#define LIB_EXPORT
#endif /*VXWORKS*/


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
#ifndef NDEBUG
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

/*----------------------------------*/
/* POSIX and VXWORKS waiting macro	*/
#if defined POSIX || defined VXWORKS
	#define SLEEP(time)                     do { \
												special_sleep(time); \
											} while(0)
#endif /*POSIX || VXWORKS*/



/*------------------------------------------------------------------------------
 * thread macros - use thread in a multi-platform way
 *-----------------------------------------------------------------------------*/
/*--------------------------------------*/
/* WINDOWS-RTX thread macros			*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#define THREAD HANDLE
		#define THREAD_INVALID                              ((HANDLE)(-1))
		#define THREAD_INIT(thr, fct, arg)                  do { \
																int tid; \
																(thr) = CreateThread(NULL, 20480, (LPTHREAD_START_ROUTINE)(fct), (arg), 0, &tid); \
															} while(0)
		#define THREAD_INIT_AND_NAME(thr, name, fct, arg)   do { \
																int tid; \
																(thr) = CreateThread(NULL, 20480, (LPTHREAD_START_ROUTINE)(fct), (arg), 0, &tid); \
															} while(0)
		#define THREAD_SET_PRIORITY(thr, pri)               do { \
																SetThreadPriority((thr), (pri)); \
															} while(0)
		#define THREAD_GET_PRIORITY(thr)                    (GetThreadPriority((thr)))
		#define THREAD_SET_CURRENT_PRIORITY(pri)            do { \
																SetThreadPriority(GetCurrentThread(), (pri)); \
															} while(0)
		#define THREAD_GET_CURRENT_PRIORITY()               (GetThreadPriority(GetCurrentThread()))
		#define THREAD_WAIT(thr, timeout)                   (lib_wait_for_thread(thr, timeout))
		#define THREAD_GET_CURRENT()                        (GetCurrentThread())
		#define THREAD_GET_CURRENT_ID()                     (GetCurrentThreadId())
		#define THREAD_GET_NAME(thr)                        (NULL)
		#define PROCESS_GET_CURRENT()                       (NULL)
		#define PROCESS_GET_CURRENT_ID()                    (GetCurrentProcessId())

	/*--------------------------------------*/
	/* WINDOWS-W32 thread macros			*/
	#else
		#define THREAD HANDLE
		#define THREAD_INVALID                              ((HANDLE)(-1))
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
		#define THREAD_WAIT(thr, timeout)                   (WaitForSingleObject((thr), (timeout)))
		#define THREAD_GET_CURRENT()                        (GetCurrentThread())
		#define THREAD_GET_CURRENT_ID()                     (GetCurrentThreadId())
		#define THREAD_GET_NAME(thr)                        (rtx_get_thread_name(thr))
		#define PROCESS_GET_CURRENT()                       (GetCurrentProcess())
		#define PROCESS_GET_CURRENT_ID()                    (GetCurrentProcessId())
	#endif
#endif /* WIN32 */

/*--------------------------------------*/
/* other POSIX							*/
#if defined POSIX
	#define THREAD                                      pthread_t
	#define THREAD_INVALID                              ((pthread_t)(-1))
	#define THREAD_INIT(thr,fct,arg)                    do { \
															pthread_create (&thr, NULL, (void*)&fct, arg); \
														}while (0)
	#define THREAD_INIT_AND_NAME(thr,name,fct,arg)      do {\
															pthread_create (&thr, NULL, (void*)&fct, arg); \
														}while (0)
	#define THREAD_INIT_DETACH(thr,fct,arg)             do { \
															pthread_attr_t attr; \
															pthread_attr_init(&attr); \
															pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED); \
															pthread_create (&thr, &attr, (void*)&fct, arg); \
															pthread_attr_destroy(&attr); \
														}while (0)
	#define THREAD_WAIT(thr,timeout)                    (pthread_join (thr, NULL))
	//pas de timeout
	#define THREAD_GET_CURRENT()                        (pthread_self())
	#define THREAD_GET_CURRENT_ID()                     (pthread_self())
	#define THREAD_GET_NAME(thr)                        NULL
	#define THREAD_SET_POLICY(thr,policy,pri)           (thread_set_policy(thr, policy, pri))
	#define THREAD_SET_PRIORITY(thr,pri)                (thread_set_prio(thr, pri))
	#define THREAD_GET_PRIORITY(thr)                    (thread_get_prio(thr))
	#define THREAD_SET_CURRENT_PRIORITY(pri)            (thread_set_prio(pthread_self(), pri))
	#define THREAD_GET_CURRENT_PRIORITY()               (thread_get_prio(pthread_self()))
	#define PROCESS_GET_CURRENT()                       (getpid())
	#define PROCESS_GET_CURRENT_ID()                    (getpid())
#endif /*POSIX*/

/*--------------------------------------*/
/* VXWORKS thread macros				*/
#ifdef VXWORKS
	#define THREAD                                      int
	#define THREAD_INVALID                              (ERROR)
	#define THREAD_INIT(thr,fct,arg)                    do { \
															thr = taskSpawn(NULL, THREAD_PRIORITY_NORMAL, VX_FP_TASK, 128000, (FUNCPTR)fct, (int)arg, 0, 0, 0, 0, 0, 0, 0, 0, 0); \
														}while (0)
	#define THREAD_INIT_AND_NAME(thr,name,fct,arg)      do {\
															thr = taskSpawn(name, THREAD_PRIORITY_NORMAL, VX_FP_TASK, 128000, (FUNCPTR)fct, (int)arg, 0, 0, 0, 0, 0, 0, 0, 0, 0); \
														}while (0)
	#define THREAD_WAIT(thr,timeout)                    do { \
															SLEEP(1000); \
														} while (taskIdVerify(thr) == OK)
	#define THREAD_GET_CURRENT()                        (taskIdSelf())
	#define THREAD_GET_CURRENT_ID()                     (taskIdSelf())
	#define THREAD_GET_NAME(thr)                        NULL
	#define THREAD_SET_PRIORITY(thr,pri)                (task_set_prio(thr, pri))
	#define THREAD_GET_PRIORITY(thr)                    (task_get_prio(thr))
	#define THREAD_SET_CURRENT_PRIORITY(pri)            (task_set_prio(taskIdSelf(), pri))
	#define THREAD_GET_CURRENT_PRIORITY()               (task_get_prio(taskIdSeld()))
	#define PROCESS_GET_CURRENT()                       (taskIdSelf())
	#define PROCESS_GET_CURRENT_ID()                    (taskidSelf())
#endif /*VXWORKS*/


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
		#define DEFINE_CRITICAL         pthread_mutex_t mutex; int m_counter; pid_t m_pid;
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
		/* Only available for QNX6 */
		#if defined QNX6
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
		#define DEFINE_CRITICAL         sem_t m_sem; int m_counter; pid_t m_pid;
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
	#endif
#endif /*POSIX critical section */

/*--------------------------------------*/
/* VXWORKS Critical section */
#ifdef VXWORKS
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
#endif /*VXWORKS*/


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
/* VXWORKS events macros				*/
#ifdef VXWORKS
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
										taskLock(); \
										semGive(ev); \
										semTake(ev, WAIT_FOREVER); \
										taskUnlock(); \
									} while (0)
	#define EVENT_WAIT(ev,timeout)  (event_wait(ev, timeout))
	#define IS_VALID_EVENT(ev)      (ev != EVENT_INVALID)
#endif /*VXWORKS*/


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
		#define AUTOEVENT_WAIT(ev, timeout) (WaitForSingleObject((ev), (timeout)))
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
/* VXWORKS auto events macros			*/
#ifdef VXWORKS
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
											taskLock(); \
											semGive(ev); \
											semTake(ev, WAIT_FOREVER); \
											taskUnlock(); \
										} while (0)
	#define AUTOEVENT_WAIT(ev,timeout)  (autoevent_wait(ev, timeout))
	#define IS_VALID_AUTOEVENT(ev)      (ev != AUTOEVENT_INVALID)
#endif /*VXWORKS */


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
		#define MUTEX_WAIT(ev, timeout) (WaitForSingleObject((ev), (timeout)))
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
	#define DEFINE_MUTEX            pthread_mutex_t mutex; pthread_cond_t cond;  int tid; int counter; int error; int valid;
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
/* VXWORKS mutexes macros				*/
#ifdef VXWORKS
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
#endif /*VXWORKS*/


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
		#define SEMACOUNT_WAIT(sem, timeout)    (WaitForSingleObject((sem), (timeout)))
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

/*------------------------------------------*/
/* VXWORKS counting semaphore macros		*/
#ifdef VXWORKS
	#define DEFINE_SEMACOUNT                        SEM_ID sema; int valid; int i;
	#define SEMACOUNT                               struct {DEFINE_SEMACOUNT}
	#define SEMACOUNT_INVALID                       NULL
	#define SEMACOUNT_INIT(sem,init,max_count_val)  do { \
														sem.sema = semCCreate(SEM_Q_PRIORITY, max_count_val); \
														for (sem.i = max_count_val; sem.i > init; sem.i--) \
															semTake(sem.sema, WAIT_FOREVER); \
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
#endif /*VXWORKS*/


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

/*------------------------------------------*/
/* VXWORKS thread local storage macros		*/
#ifdef VXWORKS
	#define TLS_ALLOC(idx) (tls_alloc(&idx))
	#define TLS_FREE(idx) (tls_free(idx))
	#define TLS_SET_VALUE(idx, val) (tls_set_value(idx, val))
	#define TLS_GET_VALUE(idx) (tls_get_value(idx))
#endif /* VXWORKS */


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
#endif  /*QNX6*/

/*------------------------------------------*/
/* VXWORKS Yield function */
#ifdef VXWORKS
	#define YIELD() sched_yield()
#endif /* VXWORKS */


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
#define MAX(A, B)   ((A) > (B) ? (A) : (B))
#define MIN(A, B)   ((A) < (B) ? (A) : (B))
#define ONEBIT(A)   ((A) && !((A) & ((A)-1)))


/**********************************************************************************************************/
/* functions */
/**********************************************************************************************************/

/*------------------------------------------------------------------------------
 * Math functions
 *-----------------------------------------------------------------------------*/
/*------------------------------------------*/
/* POSIX Math functions						*/
#ifdef POSIX
	#define _isnan(d)   (isnan(d))
	#define _finite(d)  (finite(d))
#endif /*POSIX*/

/*------------------------------------------*/
/* VXWORKS Math functions					*/
#ifdef VXWORKS
	#define _isnan(d) ((((dword*)&d)[1] & 0x7FF00000) == 0x7FF00000 && (((dword*)&d)[0] != 0 || (((dword*)&d)[1] & 0x000FFFFF) != 0))
	#define _finite(d) (!(((dword*)&d)[0] == 0 && (((dword*)&d)[1] & 0x7FFFFFFF) == 0x7FF00000) && !_isnan(d))
#endif /*VXWORKS*/

/*------------------------------------------------------------------------------
 * libver.c
 *-----------------------------------------------------------------------------*/
time_t  _LIB_EXPORT lib_get_build_time(void);
dword   _LIB_EXPORT lib_get_version(void);
dword   _LIB_EXPORT lib_get_edi_version(void);
void    _LIB_EXPORT lib_get_library_path(char *buf, int size);
void    _LIB_EXPORT lib_get_library_dir(char *buf, int size);
bool	_LIB_EXPORT lib_is_64bits();

/*------------------------------------------------------------------------------
 * libtim.c
 *-----------------------------------------------------------------------------*/
long    _LIB_EXPORT tim_counter(void);
double  _LIB_EXPORT tim_dbl_counter(void);

/*------------------------------------------------------------------------------
 * libdbg - functions currently defined as macros
 *-----------------------------------------------------------------------------*/
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

#if (defined WIN32 && !defined UNDER_RTSS) || defined  POSIX
	void    _LIB_EXPORT putlog(const char *format, ...);
#endif

#ifdef VXWORKS
	void    _LIB_EXPORT nothing(int source, ...);
#endif /* VXWORKS */

#ifdef WIN32
	#ifndef NDEBUG
		#define DBG_PUT_IM dbg_put_im
		#define DBG_PUT_WM dbg_put_wm
		#define DBG_PUT_EM dbg_put_em
		#define DBG_PUT_FM dbg_put_fm
		#define DBG_PUT_IS dbg_put_is
		#define DBG_PUT_OS dbg_put_os
		#define DBG_PUT_BF dbg_put_bf
		#define DBG_PUT_EF dbg_put_ef
	#else /* DEBUG */
		#define DBG_PUT_IM
		#define DBG_PUT_WM
		#define DBG_PUT_EM
		#define DBG_PUT_FM
		#define DBG_PUT_IS
		#define DBG_PUT_OS
		#define DBG_PUT_BF
		#define DBG_PUT_EF
	#endif /* DEBUG */
#endif /* WIN32 */

#ifdef POSIX
	#ifndef NDEBUG
		#define DBG_PUT_IM dbg_put_im
		#define DBG_PUT_WM dbg_put_wm
		#define DBG_PUT_EM dbg_put_em
		#define DBG_PUT_FM dbg_put_fm
		#define DBG_PUT_IS dbg_put_is
		#define DBG_PUT_OS dbg_put_os
		#define DBG_PUT_BF dbg_put_bf
		#define DBG_PUT_EF dbg_put_ef
	#else /* DEBUG */
		#define DBG_PUT_IM
		#define DBG_PUT_WM
		#define DBG_PUT_EM
		#define DBG_PUT_FM
		#define DBG_PUT_IS
		#define DBG_PUT_OS
		#define DBG_PUT_BF
		#define DBG_PUT_EF
	#endif /* DEBUG */
#endif /* POSIX */

#ifdef VXWORKS
	#ifndef NDEBUG
		#define DBG_PUT_IM dbg_put_im
		#define DBG_PUT_WM dbg_put_wm
		#define DBG_PUT_EM dbg_put_em
		#define DBG_PUT_FM dbg_put_fm
		#define DBG_PUT_IS dbg_put_is
		#define DBG_PUT_OS dbg_put_os
		#define DBG_PUT_BF dbg_put_bf
		#define DBG_PUT_EF dbg_put_ef
	#else /* DEBUG */
		#define DBG_PUT_IM nothing
		#define DBG_PUT_WM nothing
		#define DBG_PUT_EM nothing
		#define DBG_PUT_FM nothing
		#define DBG_PUT_IS nothing
		#define DBG_PUT_OS nothing
		#define DBG_PUT_BF nothing
		#define DBG_PUT_EF nothing
	#endif /* DEBUG */
#endif /* VXWORKS */


/*------------------------------------------------------------------------------
 * Base functions to handle memory allocation.
 *-----------------------------------------------------------------------------*/
void * _LIB_EXPORT mem_malloc(size_t size);
void * _LIB_EXPORT mem_calloc(size_t num, size_t size);
void * _LIB_EXPORT mem_realloc(void *memblock, size_t size);
void   _LIB_EXPORT mem_free(void *memblock);

/*------------------------------------------*/
/* WINDOWS-RTX memory allocation functions	*/
#ifdef WIN32
	#ifdef UNDER_RTSS
		#ifdef NDEBUG
			#define MALLOC(size)            malloc(size)
			#define CALLOC(num, size)       calloc(num, size)
			#define REALLOC(memblock, size) realloc(memblock, size)
			#define FREE(membloc)           free(membloc)
		#else /* NDEBUG */
			#define MALLOC(size)            mem_malloc(size)
			#define CALLOC(num, size)       mem_calloc(num, size)
			#define REALLOC(memblock, size) mem_realloc(memblock, size)
			#define FREE(membloc)           mem_free(membloc)
		#endif /* NDEBUG */

	/*------------------------------------------*/
	/* WINDOWS-W32 memory allocation functions	*/
	#else
		#ifdef NDEBUG
			#define MALLOC(size)            malloc(size)
			#define CALLOC(num, size)       calloc(num, size)
			#define REALLOC(memblock, size) realloc(memblock, size)
			#define FREE(membloc)           free(membloc)
		#else /* NDEBUG */
			#define MALLOC(size)            mem_malloc(size)
			#define CALLOC(num, size)       mem_calloc(num, size)
			#define REALLOC(memblock, size) mem_realloc(memblock, size)
			#define FREE(membloc)           mem_free(membloc)
		#endif /* NDEBUG */
	#endif /* UNDER_RTSS */
#endif /* WIN32 */


/*------------------------------------------*/
/* POSIX memory allocation functions		*/
#ifdef POSIX
	#ifdef NDEBUG
		#define MALLOC(size)                malloc(size)
		#define CALLOC(num, size)           calloc(num, size)
		#define REALLOC(memblock, size)     realloc(memblock, size)
		#define FREE(membloc)               free(membloc)
	#else /* NDEBUG */
		#define MALLOC(size)                malloc(size)
		#define CALLOC(num, size)           calloc(num, size)
		#define REALLOC(memblock, size)     realloc(memblock, size)
		#define FREE(membloc)               free(membloc)
	#endif /* NDEBUG */
#endif /* POSIX */

/*------------------------------------------*/
/* VXWORKS memory allocation functions		*/
#ifdef VXWORKS
	#undef MALLOC
	#define MALLOC(size)                malloc(size)
	#define CALLOC(num, size)           calloc(num, size)
	#define REALLOC(memblock, size)     realloc(memblock, size)
	#undef FREE
	#define FREE(membloc)               free(membloc)
#endif /* VXWORKS */

/*------------------------------------------------------------------------------
 * libtim.c
 * POSIX and VXWORKS Special time functions
 *-----------------------------------------------------------------------------*/
#if defined POSIX || defined VXWORKS
	void _LIB_EXPORT special_sleep(long time);
#endif
#ifdef UNDER_RTSS
	int _LIB_EXPORT lib_wait_for_thread (THREAD thr, int timeout);
	void _LIB_EXPORT uSleep(long us);
#endif

/*------------------------------------------------------------------------------
 * libpro.c
 * All system properties access function
 *-----------------------------------------------------------------------------*/
int     _LIB_EXPORT pro_create(PRO **rpro);
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


/*------------------------------------------------------------------------------
 * libtls.c
 *-----------------------------------------------------------------------------*/
/*------------------------------*/
/* VXWORKS tls functions		*/
#ifdef VXWORKS
	int     _LIB_EXPORT tls_alloc(dword *tls_index);
	int     _LIB_EXPORT tls_free(dword tls_index);
	int     _LIB_EXPORT tls_set_value(dword tls_index, void *value);
	void *  _LIB_EXPORT tls_get_value(dword tls_index);
#endif /* VXWORKS */

/*------------------------------------------------------------------------------
 * librtx.c
 * Windows-W32 rtx function
 *-----------------------------------------------------------------------------*/
#ifdef WIN32
	#ifdef UNDER_RTSS
	#else /* Not UNDER_RTSS */
		THREAD  _LIB_EXPORT rtx_beginthread(int (*fct)(void *param), void *param);
		THREAD  _LIB_EXPORT rtx_begin_named_thread(const char *name, int (*fct)(void *param), void *param);
		char_cp _LIB_EXPORT rtx_get_thread_name(THREAD thread);
	#endif
#endif /* WIN32 */

/*------------------------------------------------------------------------------
 * libnet.c
 * TCP/IP access functions
 *-----------------------------------------------------------------------------*/
/*------------------------------------------------------------------*/
/* WINDOWS, POSIX and VXWORKS functions		*/
#if defined WIN32 || defined POSIX || defined VXWORKS
	int _LIB_EXPORT     net_init(void);
	int _LIB_EXPORT     net_recv(SOCKET s, char *buf, int len, int flags);
	int _LIB_EXPORT     net_recvfrom(SOCKET s, char *buf, int len, int flags, struct sockaddr *from, int *fromlen);
	int _LIB_EXPORT     net_send(SOCKET s, char *buf, int len, int flags);
	int _LIB_EXPORT     net_sendto(SOCKET s, char *buf, int len, int flags, const struct sockaddr *to, int tolen);
	int _LIB_EXPORT     net_socket(int af, int type, int protocol);
	int _LIB_EXPORT     net_connect(SOCKET s, const struct sockaddr *name, int namelen);
	int _LIB_EXPORT     net_close(SOCKET s);
	int _LIB_EXPORT     net_listen(SOCKET s, int backlog);
	int _LIB_EXPORT     net_accept(SOCKET s, struct sockaddr *addr, int *addrlen);
	int _LIB_EXPORT     net_bind(SOCKET s, const struct sockaddr *name, int namelen);
	int _LIB_EXPORT     net_setsockopt(SOCKET s, int level, int optname, const char *optval, int optlen);
	int _LIB_EXPORT     net_getsockopt(SOCKET s, int level, int optname, char *optval, int *optlen);
	int _LIB_EXPORT     net_select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, const struct timeval *timeout);
	HOSTENT * _LIB_EXPORT net_gethostbyname(const char* name);
	int _LIB_EXPORT net_gethostname(char* name, int size);
	unsigned long _LIB_EXPORT net_inet_addr(const char* cp);
	u_short _LIB_EXPORT net_ntohs(u_short netshort);
	u_long  _LIB_EXPORT net_ntohl(u_long netlong);
	u_short _LIB_EXPORT net_htons(u_short hostshort);
	u_long  _LIB_EXPORT net_htonl(u_long hostlong);

	#if defined WIN32
		int _LIB_EXPORT net_wsa_fd_is_set(SOCKET s, fd_set FAR *fd);
		int _LIB_EXPORT net_get_last_error();
		#ifndef UNDER_RTSS
			#define __WSAFDIsSet net_wsa_fd_is_set
		#endif /* UNDER_RTSS */
	#else
		int _LIB_EXPORT net_wsa_fd_is_set(SOCKET s, fd_set *fd);
	#endif
#endif


/*------------------------------------------------------------------------------
 * libjni.c
 * Windows-W32 java JNI access function
 *-----------------------------------------------------------------------------*/
#if defined WIN32 && !defined UNDER_RTSS
	void    _LIB_EXPORT jni_set_vm(jnivm_p);
	jnivm_p _LIB_EXPORT jni_get_vm(void);
	jnienv_p _LIB_EXPORT jni_get_env(void);
	void    _LIB_EXPORT jni_detach(void);
	jobject _LIB_EXPORT jni_create_object(jnienv_p env, const char *name, const char *sig, ...);
	void    _LIB_EXPORT jni_out_of_memory_error(jnienv_p env, const char *s);
	void    _LIB_EXPORT jni_illegal_argument_exception(jnienv_p env, const char *s);
	void    _LIB_EXPORT jni_illegal_state_exception(jnienv_p env, const char *s);
#endif /* WIN32 */

/*------------------------------------------------------------------------------
 * libshm.c
 * All system except VXWORKS shared memory functions
 *------------------------------------------------------------------------------*/
#ifndef VXWORKS
	int _LIB_EXPORT shm_create(SHM **shm_obj, char *name, dword size);
	int _LIB_EXPORT shm_destroy(SHM *shm_obj);
	int _LIB_EXPORT shm_map(SHM *shm_obj, void **addr);
	int _LIB_EXPORT shm_unmap(SHM *shm_obj, void *addr);
	int _LIB_EXPORT shm_exist(char *name, int size);
#endif


/*------------------------------------------------------------------------------
 * libprio.c
 * Priority setting functions
 *------------------------------------------------------------------------------*/
/*------------------------------------------*/
/* POSIX priority setting functions			*/
#ifdef POSIX
	int _LIB_EXPORT thread_get_prio(pthread_t thr);
	void _LIB_EXPORT thread_set_prio(pthread_t thr, int prio);
	void _LIB_EXPORT thread_set_policy(pthread_t thr, int policy, int prio);
#endif /* POSIX */

/*------------------------------------------*/
/* VXWORKS priority setting functions			*/
#ifdef VXWORKS
	int _LIB_EXPORT task_get_prio(int task);
	void _LIB_EXPORT task_set_prio(int task, int prio);
#endif /*VXWORKS*/

/*------------------------------------------------------------------------------
 * libwait.c
 * Waiting synchronisation object functions
 *------------------------------------------------------------------------------*/
/*--------------------------------------------------*/
/* POSIX Waiting synchronisation object functions	*/
#ifdef POSIX
	int _LIB_EXPORT event_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *state, int *error, int timeout);
	int _LIB_EXPORT autoevent_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *state, int *error, int timeout);
	int _LIB_EXPORT mutex_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *tid, int *counter, int *error, int timeout);
	int _LIB_EXPORT local_sema_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *counter, int *error, int timeout);
#endif /* POSIX */

/*--------------------------------------------------*/
/* VXWORKS Waiting synchronisation object functions	*/
#ifdef VXWORKS
	int _LIB_EXPORT event_wait(SEM_ID event, int timeout);
	int _LIB_EXPORT autoevent_wait(SEM_ID event, int timeout);
	int _LIB_EXPORT mutex_wait(SEM_ID event, int timeout);
	int _LIB_EXPORT local_sema_wait_old(SEM_ID mutex, SEM_ID ev, int *counter, int timeout);
	int _LIB_EXPORT local_sema_wait(SEM_ID SEM, int timeout);
	int _LIB_EXPORT critical_enter(SEM_ID event);
#endif /*VXWORKS */


/*------------------------------------------------------------------------------
 * libzip.c
 * WINDOWS-W32, POSIX unzip file function
 *------------------------------------------------------------------------------*/
#if (defined WIN32 && !defined UNDER_RTSS) || defined POSIX
	int _LIB_EXPORT zip_fw_unzip(char *zipFile, char *extractDir);
	int _LIB_EXPORT zip_fw_get_manifest (char *extractDir, FW_MANIFEST *fw_manifest);
#endif

/*------------------------------------------------------------------------------
 * libzip.c
 * WINDOWS-W32 zip/unzip function
 *------------------------------------------------------------------------------*/
#if (defined WIN32 && !defined UNDER_RTSS) || defined POSIX
	int _LIB_EXPORT zip_unzip(char *zipFile, char *extractDir, char *flags);
	int _LIB_EXPORT zip_zip(char *zipFile, char *dir, char *flags);
#endif

/*------------------------------------------------------------------------------
 * libdir.c (directory search)
 * WINDOWS-W32, POSIX directory browse function
 *------------------------------------------------------------------------------*/
#if (defined WIN32 && !defined UNDER_RTSS) || defined POSIX
	#ifdef POSIX
		#define _MAX_PATH 260
	#endif
	int _LIB_EXPORT dir_find_first_file (char *dirName, DIRECTORY_ENTRY *entry);
	int _LIB_EXPORT dir_find_next_file (DIRECTORY_ENTRY *entry);
	int _LIB_EXPORT dir_find_abort();
	int _LIB_EXPORT dir_remove(char *dirName);
	int _LIB_EXPORT dir_mkdir (char *dir_name);
	int _LIB_EXPORT dir_chdir (char *dir_name);
	int _LIB_EXPORT dir_getdir (char *dir_name, int size);
#endif
/*------------------------------------------------------------------------------
 * libdir.c (file access search)
 * WINDOWS-W32, RTX, POSIX directory browse function
 *------------------------------------------------------------------------------*/
#if defined WIN32 || defined POSIX
	char* _LIB_EXPORT dir_tmpname();
	int _LIB_EXPORT dir_file_remove(char *fileName);
	int _LIB_EXPORT dir_access(char *dirName, int mode);
#endif

#if (defined WIN32 && !defined UNDER_RTSS)
	int _LIB_EXPORT dir_get_dll_path(char *dll_name, int size, char *dll_path);
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

int _LIB_EXPORT lib_create_error(char *file,
                                 int line,
                                 char *fctName,
                                 int errorNr,
                                 const char *errorText,
                                 char *comment,
                                 eint64 axisMask,
                                 int recNr,
                                 int cmd,
                                 int timeout);
int _LIB_EXPORT lib_set_error_param(eint64 axisMask,
									int recNr,
									int cmd,
									int timeout);
int _LIB_EXPORT lib_add_error_trace(char *file,
                                    int line,
                                    char *fctName,
                                    char *comment);
int _LIB_EXPORT lib_trace_off();
int _LIB_EXPORT lib_trace_on();
int _LIB_EXPORT lib_get_edi_error_command();
eint64 _LIB_EXPORT lib_get_edi_error_axismask();
int _LIB_EXPORT lib_get_edi_error_record();
int _LIB_EXPORT lib_get_edi_error_timeout();
char* _LIB_EXPORT lib_get_edi_error_text(int size, char *str);
char *_LIB_EXPORT lib_get_edi_small_error_text(int size, char *str);
char_cp _LIB_EXPORT lib_translate_edi_error(int code);


/*------------------------------------------------------------------------------
 * liblog.c
 * Logging function (replace printf,sprintf, etc which are not advised on some OS)
 *------------------------------------------------------------------------------*/
int vsedilog(char *string, const char *format, va_list vargs);
int sedilog(char *string, const char *format, ...);
int edilog(const char *format, ...);
int vedilog(const char *format, va_list vargs);

/*------------------------------------------------------------------------------
 * libstr.c
 * String uppercase function which are not standard
 *------------------------------------------------------------------------------*/
char *strToUpper(char *src);
char *strToLower(char *src);

/*------------------------------------------------------------------------------
 * libint64.c
 * integer 64 bits manipulation functions for system without 64 bits integer
 *------------------------------------------------------------------------------*/

#if defined WIN32
void lib_setbit64(eint64 *i64, int bit); 
bool lib_isbitset64(eint64 i64, int bit);
void lib_createandsetbit64(eint64 *i64, int bit);
#endif

#ifdef __cplusplus
	} /* extern "C" */
#endif

#endif /* _LIB40_H */
