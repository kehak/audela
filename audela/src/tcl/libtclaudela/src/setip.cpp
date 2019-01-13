/* setip.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * set AudiNet IP address
 *
 *
 * $Id: setip.cpp,v 1.2 2009-05-01 13:42:18 jacquesmichelet Exp $
 */


#include "sysexp.h"
#include <stdio.h>		// for sscanf


#if defined(OS_WIN)
#include <windows.h>
#include <winsock.h>
#endif

#if defined(OS_LIN) || defined(OS_MACOS)
#include <errno.h>
#include <unistd.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>

#include <arpa/inet.h>

#include <net/if.h>
#include <netinet/in.h>

#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>		/* for socket definitions */
#include <sys/stat.h>
#include <sys/select.h>
// Modif JM
#include <sys/ioctl.h>
// Fin modif JM
#if defined(OS_LIN)
#include <asm/socket.h>		/* DM, added for SO_* options definition !!!! ??? */
#include <asm/ioctls.h>
#endif

#endif

#include "setip.h"
//#include "log.h"

typedef struct {
    unsigned char optype;
    unsigned char hwtype;
    unsigned char hwlen;
    unsigned char hops;
    unsigned long xid;
    unsigned short secs;
    unsigned short unused;
    unsigned long ciaddr;
    unsigned long yiaddr;
    unsigned long siaddr;
    unsigned long giaddr;
    unsigned char chaddr[16];
    unsigned char sname[64];
    unsigned char bootfile[128];
    unsigned char vendor[64];
} BOOTP_PACKET;


#define SOCKADDR struct sockaddr
#define BOOTP_REPLY_PORT 192

// local functions
#if defined(OS_WIN)
int sockbootp_bind();
#endif

#if defined(OS_LIN) || defined(OS_MACOS)
int broadcastBootpReply(int times,
			unsigned long clientIP,
			unsigned char *clientMAC,
			unsigned long clientNM, unsigned long clientGW);
#endif

int sendBootpReply(int times,
		   int Socket,
		   unsigned long serverIP,
		   unsigned long broadcastIP,
		   unsigned long clientIP,
		   unsigned char *clientMAC,
		   unsigned long clientNM, unsigned long clientGW);
int sockbootp_close(int socket);

int sendEthernaude(int times,
		   int Socket,
		   unsigned long serverIP,
		   unsigned long broadcastIP,
		   unsigned long clientIP,
		   unsigned char *clientMAC,
		   unsigned long clientNM, unsigned long clientGW);

/**
 * setip 
 * send a BOOTP REPLY packet with the new IP address
 * params :
 *   szClientIP : client IP address  (required)
 *   szClientMAC : client MAC address (required)
 *   szClientNM  : client Network mask  ( optional, may be NULL)
 *   szClientGW  : client gateway       ( optional, may be NULL)
 * returns 0 if no error occurs
 */
int setip(const char *szClientIP, const char *szClientMAC, const char *szClientNM,
          const char *szClientGW, char *errorMessage)
{
   int result;
   unsigned long clientIP = 0;
   unsigned long clientGW = 0;
   unsigned long clientNM = 0;
   unsigned char clientMAC[6];
#if defined(OS_WIN)
   unsigned long broadcastIP = INADDR_BROADCAST;
   unsigned long serverIP = 0;
   int replySocket;
#endif
   
#if defined(OS_WIN)
  WSADATA wsaData;
  if (WSAStartup(MAKEWORD(1,1),&wsaData) != 0){
	  sprintf(errorMessage,"WSAStartup failed: %d\n",GetLastError());
     //logError(errorMessage);
	  return 1;
  }
#endif

   if (!szClientIP) {
      sprintf(errorMessage, "setip client IP is null");
      //logError(errorMessage);
      return 1;
   } else {
      clientIP = htonl(inet_addr(szClientIP));
      if ((clientIP == (unsigned long) 0) || (clientIP == (unsigned long) -1)) {
         struct hostent *pHostEnt;
         pHostEnt = gethostbyname(szClientIP);
         if (pHostEnt) {
            struct sockaddr_in SockAddr;
            SockAddr.sin_addr =
               *((struct in_addr *) pHostEnt->h_addr_list[0]);
            clientIP = htonl(SockAddr.sin_addr.s_addr);
         }
      }
      if ((clientIP == (unsigned long) 0) || (clientIP == (unsigned long) -1)) {
         sprintf(errorMessage, "setip bad IP address (%s)", szClientIP);
         //logError(errorMessage);
         return 1;
      }
   }
   
   
   if (!szClientMAC) {
      sprintf(errorMessage, "setip client MAC address is null");
      //logError(errorMessage);
      return 1;
   } else {
      char ch;
      int p[6];
      int i, n;
      
      ch = 0;
      n = sscanf(szClientMAC, "%x:%x:%x:%x:%x:%x%c",
         p + 0, p + 1, p + 2, p + 3, p + 4, p + 5, &ch);
      if (n != 6) {
         /* alternate decimal form */
         ch = 0;
         n = sscanf(szClientMAC, "%d.%d.%d.%d.%d.%d%c",
            p + 0, p + 1, p + 2, p + 3, p + 4, p + 5, &ch);
      }
      for (i = 0; i < 6; ++i) {
         if (p[i] > 255)
            n = -1;		/* force error if octet too big */
         if (p[i] < 0)
            n = -1;		/* force error if octet negative */
      }
      if (n != 6 || ch != 0) {
         sprintf(errorMessage, "setip bad MAC address (%s)",
            szClientMAC);
         //logError(errorMessage);
         return 1;
      } else {
         for (i = 0; i < 6; ++i)
            clientMAC[i] = p[i];
      }
   }
   
   
   
   if (szClientGW) {
      clientGW = htonl(inet_addr(szClientGW));
      if ((clientGW == (unsigned long) 0) || (clientGW == (unsigned long) -1)) {
         struct hostent *pHostEnt;
         pHostEnt = gethostbyname(szClientGW);
         if (pHostEnt) {
            struct sockaddr_in SockAddr;
            SockAddr.sin_addr =
               *((struct in_addr *) pHostEnt->h_addr_list[0]);
            clientGW = htonl(SockAddr.sin_addr.s_addr);
         }
      }
      
      if ((clientGW == (unsigned long) 0) || (clientGW == (unsigned long) -1)) {
         sprintf(errorMessage, "setip bad default gateway address (%s)",
            szClientGW);
         //logError(errorMessage);
         return 1;
      }
      
   }
   
   
   if (szClientNM) {
      int i, z = 0;
      
      clientNM = htonl(inet_addr(szClientNM));
      for (i = 0; i < 32; ++i) {
         if ((clientNM & (1 << (31 - i))) != 0) {
            if (z) {
               sprintf(errorMessage, "setip bad netmask (%s)",
                  szClientNM);
               //logError(errorMessage);
               return 1;
            }
            continue;
         } else {
            z = 1;
            continue;
         }
      }
   }
#if defined(OS_WIN)
   if ((replySocket = sockbootp_bind()) != 0) {
      broadcastIP = INADDR_BROADCAST;
      //result = sendBootpReply(3, replySocket, serverIP, broadcastIP, clientIP,
      //   clientMAC, clientNM, clientGW);
      result = sendEthernaude(1, replySocket, serverIP, broadcastIP, clientIP, clientMAC, clientNM, clientGW);
      if (result != 0) {
         sprintf(errorMessage, "sendBootpReply error errno=%d", errno);
         //logError(errorMessage);
      }
      sockbootp_close(replySocket);
   } else {
      sprintf(errorMessage, "sockbootp_bind error errno=%d", errno);
      //logError(errorMessage);
      result = 1;
   }
#else
   result =
      broadcastBootpReply(3, clientIP, clientMAC, clientNM, clientGW);
#endif
   
   return result;
}


/**
 * sendBootpReply
 * envoit un paquet REPLY contenant la nouvelle adresse IP
 * returns 0 if no error occurs
 */

int sendBootpReply(int times,
		   int Socket,
		   unsigned long serverIP,
		   unsigned long broadcastIP,
		   unsigned long clientIP,
		   unsigned char *clientMAC,
		   unsigned long clientNM, unsigned long clientGW)
{
    int i;
    char udpbuf[sizeof(BOOTP_PACKET)];
    int udpbuflen = sizeof(udpbuf);
    BOOTP_PACKET *ppkt = (BOOTP_PACKET *) udpbuf;
    struct sockaddr dst;

    /*
    logInfo("sendBootpReply(%d, %d, "
	    "Server IP=%d.%d.%d.%d, "
	    "Broadcast IP=%d.%d.%d.%d, "
	    "Client IP=%d.%d.%d.%d:%d, "
	    "MAC=%02x:%02x:%02x:%02x:%02x:%02x, "
	    "NM=%d.%d.%d.%d, "
	    "GW=%d.%d.%d.%d)\n",
	    times,
	    (int) Socket,
	    (serverIP >> 24) & 255, (serverIP >> 16) & 255,
	    (serverIP >> 8) & 255, serverIP & 255,
	    (broadcastIP >> 24) & 255, (broadcastIP >> 16) & 255,
	    (broadcastIP >> 8) & 255, broadcastIP & 255,
	    (clientIP >> 24) & 255, (clientIP >> 16) & 255,
	    (clientIP >> 8) & 255, clientIP & 255, BOOTP_REPLY_PORT,
	    clientMAC[0], clientMAC[1], clientMAC[2], clientMAC[3],
	    clientMAC[4], clientMAC[5], (clientNM >> 24) & 255,
	    (clientNM >> 16) & 255, (clientNM >> 8) & 255, clientNM & 255,
	    (clientGW >> 24) & 255, (clientGW >> 16) & 255,
	    (clientGW >> 8) & 255, clientGW & 255);

    ((struct sockaddr_in *) (&dst))->sin_family = AF_INET;
    ((struct sockaddr_in *) (&dst))->sin_addr.s_addr = htonl(broadcastIP);
    ((struct sockaddr_in *) (&dst))->sin_port = htons(BOOTP_REPLY_PORT);
    */
    memset(ppkt, 0, udpbuflen);	/* clear BOOTP packet */

    ppkt->optype = 2;		/* BOOTREPLY */
    ppkt->hwtype = 1;		/* 10mb ethernet */
    ppkt->hwlen = 6;
    ppkt->hops = 0;
    ppkt->xid = 0;		/* transaction ID */
    ppkt->secs = 0;		/* client's secs since boot */
    ppkt->ciaddr = ntohl(0);	/* client IP (from client) */
    ppkt->yiaddr = ntohl(clientIP);	/* client IP (from server) */
    ppkt->siaddr = ntohl(serverIP);	/* server IP (from server) */
    ppkt->giaddr = ntohl(0);	/* gateway IP (optional) */
    ppkt->chaddr[0] = clientMAC[0];	/* client Ethernet address */
    ppkt->chaddr[1] = clientMAC[1];
    ppkt->chaddr[2] = clientMAC[2];
    ppkt->chaddr[3] = clientMAC[3];
    ppkt->chaddr[4] = clientMAC[4];
    ppkt->chaddr[5] = clientMAC[5];
    {
       unsigned long *p = (unsigned long *) (&ppkt->vendor);
       p[0] = ntohl(clientNM);	/* client NM (from client) */
       p[1] = ntohl(clientGW);	/* client GW (from client) */
    }

    for (i = 0; i < times; ++i) {
	   if (sendto(Socket, udpbuf, udpbuflen, 0, &dst,sizeof(struct sockaddr)) != udpbuflen) {
	       //logError("sendBootpReply sendto errno=%d", errno);
	       return (1);		/* error exit */
	   }
    }
    return 0;
}

/**
 * BOOT_ETHERNAUDE
 * envoit un paquet ETHERNAUDE contenant la nouvelle adresse IP
 * returns 0 if no error occurs
 */

typedef struct {
    unsigned char signature[4];
    unsigned long clientIP;
} BOOT_ETHERNAUDE;


int sendEthernaude(int times,
		   int Socket,
		   unsigned long serverIP,
		   unsigned long broadcastIP,
		   unsigned long clientIP,
		   unsigned char *clientMAC,
		   unsigned long clientNM, unsigned long clientGW)
{
    int i;

    char udpbuf[sizeof(BOOT_ETHERNAUDE)];
    int udpbuflen = sizeof(udpbuf);
    BOOT_ETHERNAUDE *ppkt = (BOOT_ETHERNAUDE *) udpbuf;
    struct sockaddr dst;

    ((struct sockaddr_in *) (&dst))->sin_family = AF_INET;
    ((struct sockaddr_in *) (&dst))->sin_addr.s_addr = htonl(broadcastIP);
    ((struct sockaddr_in *) (&dst))->sin_port = htons(BOOTP_REPLY_PORT);

   ppkt->signature[0] = 0xFF;
   ppkt->signature[1] = 0x0F;
   ppkt->signature[2] = 0xF0;
   ppkt->signature[3] = 0x11;
   ppkt->clientIP = htonl(clientIP);

    for (i = 0; i < times; ++i) {
	    if (sendto(Socket, udpbuf, udpbuflen, 0, &dst,sizeof(struct sockaddr)) != udpbuflen) {
	       //logError("sendBootpReply sendto errno=%d", errno);
	       return (1);		/* error exit */
       }
    }
    return 0;
}


#if defined(OS_WIN)
/**
 * sockbootp_bind   for OS_WIN only
 * bind a socket
 * returns replySocket, or 0 if error occurs
 */
int sockbootp_bind()
{
   int replySocket = 0;
   int bBroad = 1;
   struct sockaddr_in SockAddr;
   
   replySocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
   if (replySocket < 0) {
      //logError("sockbootp_bind socket() ");
      return 0;
   }
   
   SockAddr.sin_family = AF_INET;
   SockAddr.sin_addr.s_addr = INADDR_ANY;
   //SockAddr.sin_port = 0;	/* use any old port to reply */
   SockAddr.sin_port = htons(192);	/* use any old port to reply */
   
   if (bind(replySocket, (struct sockaddr *) &SockAddr, sizeof SockAddr)
      != 0) {
      //logError("sockbootp_bind bind errno=%d", errno);
      return 0;
   }
   
   if (setsockopt(replySocket, SOL_SOCKET, SO_BROADCAST,
      (char *) &bBroad, sizeof bBroad) != 0) {
      //logError("sockbootp_bind setsockopt errno=%d", errno);
      return 0;
   }
   
   return replySocket;
}
#endif


#if defined(OS_LIN) || defined(OS_MACOS)
/**
 * broadcastBootpReply   for OS_LIN only
 * bind a socket
 * returns 0 if no error occurs
 */
int broadcastBootpReply(int times,
			unsigned long clientIP,
			unsigned char *clientMAC,
			unsigned long clientNM, unsigned long clientGW)
{
    int s;
    struct sockaddr_in sin;
    struct sockaddr dst;
    int on = 1;
    struct ifconf ifc;
    struct ifreq *ifr;
    char buf[BUFSIZ];
    int n;
    unsigned long serverIP;
    unsigned long broadcastIP;

    // To send a broadcast message, a datagram socket should be created:
    s = socket(AF_INET, SOCK_DGRAM, 0);

    // The socket is marked as allowing broadcasting,
    if (setsockopt(s, SOL_SOCKET, SO_BROADCAST, &on, sizeof(on)) < 0) {
	perror("setsockopt(SO_BROADCAST)");
	return (1);
    }
    // and at least a port number should be bound to the socket:
    sin.sin_family = AF_INET;
    sin.sin_addr.s_addr = htonl(INADDR_ANY);
    sin.sin_port = htons(BOOTP_REPLY_PORT);
    bind(s, (struct sockaddr *) &sin, sizeof(sin));

    // The destination address of the message to be broadcast depends
    // on the network(s) on which the message is to be broadcast. The
    // Internet domain supports a shorthand notation for broadcast
    // on the local network, the address INADDR_BROADCAST (defined
    // in <netinet/in.h>. To determine the list of addresses for
    // all reachable neighbors requires knowledge of the networks to
    // which the host is connected. Since this information should be
    // obtained in a host-independent fashion and may be impossible
    // to derive, 4.4BSD provides a method of retrieving this
    // information from the system data structures. The SIOCGIFCONF
    // ioctl call returns the interface configuration of a host
    // in the form of a single ifconf structure; this structure
    // contains a ``data area'' which is made up of an array of of
    // ifreq structures, one for each network interface to which the
    // host is connected. These structures are defined in <net/if.h>
    // as follows:
    //
    // struct ifconf {
    //      int      ifc_len;                  /* size of associated buffer */
    //      union {
    //           caddr_t      ifcu_buf;
    //           struct ifreq *ifcu_req;
    //      } ifc_ifcu;
    // };
    //
    // #define ifc_buf ifc_ifcu.ifcu_buf       /* buffer address */
    // #define ifc_req ifc_ifcu.ifcu_req       /* array of structures returned */
    //
    // #define IFNAMSIZ 16
    //
    // struct ifreq {
    //      char      ifr_name[IFNAMSIZ];      /* if name, e.g. "en0" */
    //      union {
    //           struct sockaddr ifru_addr;
    //           struct sockaddr ifru_dstaddr;
    //           struct sockaddr ifru_broadaddr;
    //           short           ifru_flags;
    //           caddr_t         ifru_data;
    //      } ifr_ifru;
    // };
    //
    // #define ifr_addr      ifr_ifru.ifru_addr      /* address */
    // #define ifr_dstaddr   ifr_ifru.ifru_dstaddr   /* other end of p-to-p link */
    // #define ifr_broadaddr ifr_ifru.ifru_broadaddr /* broadcast address */
    // #define ifr_flags     ifr_ifru.ifru_flags     /* flags */
    // #define ifr_data      ifr_ifru.ifru_data      /* for use by interface */
    //
    // The actual call which obtains the interface configuration is

    ifc.ifc_len = sizeof(buf);
    ifc.ifc_buf = buf;
    if (ioctl(s, SIOCGIFCONF, (char *) &ifc) < 0) {
	perror("ioctl(SIOCGIFCONF)");
	return (1);
    }
    // After this call buf will contain one ifreq structure for each
    // network to which the host is connected, and ifc.ifc_len will
    // have been modified to reflect the number of bytes used by
    // the ifreq structures.
    //
    // For each structure there exists a set of ``interface
    // flags'' which tell whether the network correspond ing to
    // that interface is up or down, point to point or broadcast,
    // etc. The SIOCGIFFLAGS ioctl retrieves these flags for an
    // interface specified by an ifreq structure as follows:

    ifr = ifc.ifc_req;
    for (n = ifc.ifc_len / sizeof(struct ifreq); --n >= 0; ifr++) {
	/*
	 * We must be careful that we don't use an interface
	 * dev oted to an address family other than those intended;
	 * if we were interested in NS interfaces, the
	 * AF_INET would be AF_NS.
	 */
	if (ifr->ifr_addr.sa_family != AF_INET)
	    continue;
	if (ioctl(s, SIOCGIFFLAGS, (char *) ifr) < 0) {
	    perror("ioctl(SIOCGIFFLAGS)");
	    return (1);
	}
	/*
	 * Skip boring cases.
	 */
	if ((ifr->ifr_flags & IFF_UP) == 0 ||
	    (ifr->ifr_flags & IFF_LOOPBACK)
#ifdef IFF_POINTTOPOINT
	    || (ifr->ifr_flags & IFF_POINTTOPOINT) == 0)
#endif
	    ) {
	    continue;
	    }

	/*
	 * Skip "non-broadcast" entries
	 */
	if ((ifr->ifr_flags & IFF_BROADCAST) == 0)
	    continue;

	/*
	 * save interface's IP address
	 */
	serverIP =
	    htonl(((struct sockaddr_in *) (&ifr->ifr_addr))->sin_addr.
		  s_addr);

	// Once the flags have been obtained, the broadcast address
	// must be obtained. In the case of broadcast networks this is
	// done via the SIOCGIFBRDADDR ioctl, while for point-to-point
	// networks the address of the destination host is obtained
	// with SIOCGIFDSTADDR.

#ifdef IFF_POINTTOPOINT
	if (ifr->ifr_flags & IFF_POINTTOPOINT) {
	    if (ioctl(s, SIOCGIFDSTADDR, (char *) ifr) < 0) {
		perror("ioctl(SIOCGIFDSTADDR)");
		return (1);
	    }
	    bcopy((char *) ifr->ifr_dstaddr, (char *) &dst,
		  sizeof(ifr->ifr_dstaddr));
	} else
#endif
	if (ifr->ifr_flags & IFF_BROADCAST) {
	    if (ioctl(s, SIOCGIFBRDADDR, (char *) ifr) < 0) {
		perror("ioctl(SIOCGIFBRDADDR)");
		return (1);
	    }
	    bcopy((char *) &ifr->ifr_broadaddr, (char *) &dst,
		  sizeof(ifr->ifr_broadaddr));
	}
	// After the appropriate ioctl's have obtained the broadcast or
	// destination address (now in dst), the sendto call may be used:

	broadcastIP =
	    htonl(((struct sockaddr_in *) (&dst))->sin_addr.s_addr);
	sendBootpReply(times, s, serverIP, broadcastIP, clientIP,
		       clientMAC, clientNM, clientGW);

    }

    // In the above loop one sendto occurs for every interface
    // to which the host is connected that supports the notion of
    // broadcast or point-to-point addressing. If a process only
    // wished to send broadcast messages on a given network, code
    // similar to that outlined above would be used, but the loop
    // would need to find the correct destination address.

    // Received broadcast messages contain the senders address
    // and port, as datagram sockets are bound before a message is
    // allowed to go out.
    sockbootp_close(s);
// Modif JM
    return 0;
// Fin modif JM
}

#endif


/**
 * sockbootp_close
 * close a a socket
 * returns 0 if no error occurs
 */
int sockbootp_close(int socket) {
#if defined(OS_WIN)
    return closesocket(socket);
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
    return close(socket);
#endif
}
