/*

  UDPSocketComponent.h

  This file is part of the Ethernaude Driver.

  Copyright (C)2000-2005, Michel MEUNIER <michel.meunier10@tiscali.fr>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

        Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

        Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials
        provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

*/

#ifndef UDPSOCKETCOMPONENT_H
#define UDPSOCKETCOMPONENT_H

#include "os.h"

#ifdef WINDOWS
#define EADDRINUSE WSAEADDRINUSE
#include <pthread.h>
#endif

#ifdef LINUX
#include <stdlib.h>     /* use by malloc */
#include <string.h>     /* use by memset and bzero */
#include <errno.h>      /* use by errno */
#include <unistd.h>     /* use by close, fcntl */
#include <fcntl.h>      /* use by fcntl */
#include <pthread.h>        /* use for the thread */
#include <sys/socket.h>     /* use by socket ...etc */
#include <time.h>       /* use by nanosleep */

#endif

#ifdef LINUX
#include <arpa/inet.h>
/*  #include <sys/types.h>  */
#include <netinet/in.h>
#include <netdb.h>
/* #include <sys/ioctl.h> */

#endif
/*
#include "common.h"
#include "error.h" */

#include    <stdio.h>
#ifdef WINDOWS
/* --- debut modif Alain*/
#ifdef FD_SET
#else
#include    <winsock2.h>
#endif
/* --- fin modif Alain*/
#include <pthread.h>
#endif

#ifdef LINUX
#include <pthread.h>
#endif

#define MAXINT               2147483647
#define MAXPACKET                65536

#define UDPSERVICE           192
#define MAXSIZEFRAME_SX52            180
#define true                         1
#define false                        0

#define ARP_IP_UDPHEADERSIZE         42

#define MAXSIZEPACKETSEND            (MAXSIZEFRAME_SX52 - ARP_IP_UDPHEADERSIZE)+1

#define MAXSIZEPACKETSENDUSABLE       (MAXSIZEPACKETSEND-2)

#ifndef OK
#  define    OK  0
#endif

/* les types utilisés: */
typedef unsigned char TBuffer[1600];
typedef TBuffer *PBuffer;
#ifdef LINUX
typedef short BOOL;
#endif

typedef unsigned char TBufferList[20][1600];    /* ne sera jamais initialise avec une telle valeur */
typedef TBufferList *PBufferList;
/* typedef TBufferList *PBufferList; */

/* typedef int TBufferSize[MAXINT/sizeof(int)]; */
/* typedef TBufferSize *PBufferSize; */

struct TEtherLinkUDP {      /* struct to manage an UDP socket */
    int ReceiveBuffer;
    int SocketHandle;
    unsigned short Port;
    char Addrb1;
    char Addrb2;
    char Addrb3;
    char Addrb4;
    struct sockaddr_in Socket_Address;
    unsigned char ucPacketID;
    unsigned char *BufferUDP;
    BOOL bActive;
};

/* BEGIN_C_DECLS */
extern struct TEtherLinkUDP EtherLinkUDP;

extern unsigned int SocketHandle;   /* As its name tell, it is the handle of the UDP socket open with the EthernAude */

extern unsigned int Trame_a_venir, Premiere_Trame, Nombre_Trame, Trame_check, Nb_Last_Packet;
    /* Trame_a_venir: index of the first packet of the next command */
    /* Premiere_Trame: index of the first packet of an "image" */
    /* Nombre_Trame: amount of packet in the "image" */
    /* Trame_check: first packet not received */
    /* Nb_Last_packet: number of useful pixels in the last packet */

extern BOOL Overflow, Received, Ack, Exposure_Pending, Exposure_Completed, Readout_in_Progress; /*
                                                   Overflow=true if packet number as to go through 65536
                                                   Received=true when all datas have received
                                                   Ack=true if command has been well received by EthernAude and an acknowledge send
                                                   Exposure_Pending=true during an exposure
                                                   Exposure_Completed=true after an exposure and before readout
                                                   Readout_in_Progress=true during the reading of CCD

                                                 */

extern unsigned char Buffer_Ordre[40];

extern BOOL TrameOK[65536];

extern PBufferList BufferList;

extern pthread_t ThreadReceiveSocketEvent;  /* thread to manage entering data */
extern pthread_mutex_t Mutex;

double GetTimeStamp(void);

void *ThreadReceiveSocket(void *dummy);

int udp_init_connection();

int udp_close_connection();

int send_base(int fd, int nbytes, const char *addr);

int send_reset(int fd, const char *addr);

int send_data(int fd, int nbytes, const char *addr, unsigned char *pPacketID);

int send_broadcast(int fd, unsigned char *buffer, int nbytes, unsigned short port);

int send_ip_addr(int fd, unsigned short port, unsigned char Ip1, unsigned char Ip2, unsigned char Ip3, unsigned char Ip4);

int receive_data(const char *addr, int n_packet, PBufferList buffer, const unsigned int *n_byte_recvd_list);

#ifndef __TSTR
# define __TSTRHELPER(x) #x
# define __TSTR(y) __TSTRHELPER(y)
#endif /* __TSTR  */

#define LOG_FILE_NAME "ethernaude_driver.txt"

#define ETH_DRIVER_ERROR 5
#define ETH_DRIVER_WARNING 4
#define ETH_DRIVER_NOTICE 3
#define ETH_DRIVER_INFO 2
#define ETH_DRIVER_DEBUG 1

static int ethernaude_driver_verbosity = ETH_DRIVER_WARNING;

#define ETH_DRIVER_LOG_FILE( __level, fmt,... ) do { \
    FILE * f; \
    f = fopen( "ethernaude_driver.log", "at" ); \
    fprintf( f, "%s %s[%s:%d]: " fmt, __level, __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__ ); \
    fclose( f ); \
} while(0)

#define ETH_DRIVER_LOG(__level,...) do { \
    if (__level >= ethernaude_driver_verbosity) { \
        ETH_DRIVER_LOG_FILE(__TSTR(__level),__VA_ARGS__); \
    } \
} while(0)

# define LOG_ERROR(...) ETH_DRIVER_LOG(ETH_DRIVER_ERROR,__VA_ARGS__)
# define LOG_WARNING(...) ETH_DRIVER_LOG(ETH_DRIVER_WARNING,__VA_ARGS__)
# define LOG_NOTICE(...) ETH_DRIVER_LOG(ETH_DRIVER_NOTICE,__VA_ARGS__)
# define LOG_INFO(...) ETH_DRIVER_LOG(ETH_DRIVER_INFO,__VA_ARGS__)
# define LOG_DEBUG(...) ETH_DRIVER_LOG(ETH_DRIVER_DEBUG,__VA_ARGS__)


#endif  /* ifndef UDPSOCKETCOMPONENT_H */
