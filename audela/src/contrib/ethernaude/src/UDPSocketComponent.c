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

#include "UDPSocketComponent.h"

struct TEtherLinkUDP EtherLinkUDP;

unsigned int SocketHandle;  /* As its name tell, it is the handle of the UDP socket open with the EthernAude */

unsigned int
Trame_a_venir, Premiere_Trame, Nombre_Trame, Trame_check, Nb_Last_Packet;
/* Trame_a_venir: index of the first packet of the next command */
/* Premiere_Trame: index of the first packet of an "image" */
/* Nombre_Trame: amount of packet in the "image" */
/* Trame_check: first packet not received */
/* Nb_Last_packet: number of useful pixels in the last packet */

BOOL Overflow, Received, Ack, Exposure_Pending, Exposure_Completed, Readout_in_Progress;
/*
Overflow=true if packet number as to go through 65536
Received=true when all datas have received
Ack=true if command has been well received by EthernAude and an acknowledge send
Exposure_Pending=true during an exposure
Exposure_Completed=true after an exposure and before readout
Readout_in_Progress=true during the reading of CCD
*/

unsigned char Buffer_Ordre[40];

BOOL TrameOK[65536];

PBufferList BufferList;

pthread_t ThreadReceiveSocketEvent; /* thread to manage entering data */
pthread_mutex_t Mutex;

int tache = 1;

BOOL Thread_running;

double GetTimeStamp(void)
{
#if defined(LINUX) && !defined(OS_MAC)
   unsigned long long x;
#if defined(PROCESSOR_INSTRUCTIONS_INTEL)
   __asm__ volatile (".byte 0x0F, 0x31":"=A" (x));
#else
	x=0;
#endif
   return ((double) x / 897000000);
#endif

#ifdef OS_MAC
   return 0.5;
#endif

#ifdef WINDOWS
   return 0.5;
#endif
}


void *ThreadReceiveSocket(void *dummy)
{
   const int BufferSize = 1600;
   int NbPacket;
   unsigned int NbByteReceived[41];
   fd_set ReceiveStatus;
   FD_ZERO(&ReceiveStatus);
   FD_SET(SocketHandle, &ReceiveStatus);
   LOG_DEBUG("%f Création de la tache no %d\n", GetTimeStamp(), tache++);
   Thread_running = true;

   while (Thread_running) {
      int recvResult ;
      NbPacket = 0;
      recvResult = recv(SocketHandle, (BufferList)[NbPacket][0], BufferSize, 0);
      if ( recvResult >= 0 ) {
         NbByteReceived[NbPacket] = recvResult;

         NbPacket++;
         /* printf("NbPacket %d\n",NbPacket); */
         if (NbPacket > 1) {
            LOG_DEBUG("NbPacket>1 %d\n", NbPacket);
         }
         LOG_DEBUG("%f  %d bytes recus\n", GetTimeStamp(), NbByteReceived[NbPacket - 1]);
         receive_data(0, NbPacket, BufferList, NbByteReceived);
      }
      else {
         printf("ThreadReceiveSocket error=%d \n", recvResult);
      }

   }  /* fin du while */
   return 0;

}

int udp_init_connection()
/* Returned value:
>=0: OK SocketHandle
-1   error during the creation of socket
-2   error when trying to change size of buffer of socket
-3   error when trying to get the descriptor of socket
-4   error when trying to change the descriptor of socket
-5   error when opening the socket
-6   error during the creation of thread

  */
{
   int ret, receive_buffer_dim, i;
   struct sockaddr_in socket_address;

#ifdef LINUX
   int fdflags;
#endif

#ifdef WINDOWS
   int BlockingMode;
   WORD wVersionRequested;
   WSADATA wsaData;
#endif

   Received = false;
   Trame_a_venir = 1;
   EtherLinkUDP.ucPacketID = 0;
   receive_buffer_dim = 30 * 1024;
   Exposure_Pending = false;    /* no exposure for the moment!! */
   Exposure_Completed = false;
   Readout_in_Progress = false;
#ifdef WINDOWS
   wVersionRequested = 2 * 256 + 2;

   ret = WSAStartup(wVersionRequested, &wsaData);
   SocketHandle = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
   if (SocketHandle == INVALID_SOCKET) {
      ret = WSAGetLastError();
      return ret;
   }
#endif
#ifdef LINUX
   SocketHandle = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
   if (SocketHandle == -1) {
      ret = errno;
      return ret;
   }
#endif


   ret = setsockopt(SocketHandle, SOL_SOCKET, SO_RCVBUF, (const char *) &receive_buffer_dim, sizeof(receive_buffer_dim));
   if (ret == -1) {
      return -2;
   }
#ifdef LINUX
   ret = fdflags = fcntl(SocketHandle, F_GETFL, 0);
   if (ret == -1) {
      return -3;
   }

   fdflags &= ~O_NONBLOCK;
   ret = fcntl(SocketHandle, F_SETFL, fdflags);
   if (ret == -1) {
      return -4;
   }
#endif              /* LINUX */

#ifdef WINDOWS
   BlockingMode = 1;
   /* ret=ioctlsocket(SocketHandle,FIONBIO,&BlockingMode); */
   if (ret != 0) {
      return -4;
   }
#endif              /* WINDOWS */

   EtherLinkUDP.Port = UDPSERVICE;
   memset(&socket_address, 0, sizeof(socket_address));
   socket_address.sin_family = PF_INET;
   socket_address.sin_port = htons(EtherLinkUDP.Port);
   socket_address.sin_addr.s_addr = INADDR_ANY;

   ret = bind(SocketHandle, (struct sockaddr *) &socket_address, sizeof(struct sockaddr));
   if (ret == -1) {
      if (errno != EADDRINUSE) {
         return -5;
      }
   }

   ret = pthread_create(&ThreadReceiveSocketEvent, NULL, ThreadReceiveSocket, NULL);
   if (ret != 0) {
      return -6;
   }

   for (i = 0; i < 65536; i++)
      TrameOK[i] = false;
   BufferList = (PBufferList) malloc(20 * 1600 * sizeof(unsigned char));

   return SocketHandle;
}

int udp_close_connection()
{
   int ret, T_Sleep;

   struct timespec Time_ns;


#ifdef LINUX
   ret = close(SocketHandle);
#endif
#ifdef WINDOWS
   ret = closesocket(SocketHandle);
#endif
   if (ret != 0) {
      return -2;
   }

   /* ret = pthread_cancel(ThreadReceiveSocketEvent);
   if (ret != 0) {
   return -1;
} */
   Thread_running = false;
   /* we wait 10ms to be sure that thread is finished */
   Time_ns.tv_sec = 0;

   Time_ns.tv_nsec = 10000000;

   T_Sleep = 10;

#ifdef LINUX
   nanosleep(&Time_ns, NULL);
#endif                                /*
   */
#ifdef WINDOWS
   Sleep(T_Sleep);
#endif                                /*
   */

   free(BufferList);

   return 0;
}

int send_base(int fd, int nbytes, const char *addr)
{
   int ret = 0;
   int i, T_Sleep;
   struct timespec Time_ns;

   EtherLinkUDP.Socket_Address.sin_family = AF_INET;
   EtherLinkUDP.Socket_Address.sin_port = htons(EtherLinkUDP.Port);
   LOG_DEBUG("%f envoi de %d bytes\n", GetTimeStamp(), nbytes);
   ret = sendto(fd, Buffer_Ordre, nbytes, 0, (struct sockaddr *) &EtherLinkUDP.Socket_Address, sizeof(EtherLinkUDP.Socket_Address));
   if (Buffer_Ordre[0] == 0) {  /* case of reset need timeout=2s=100*20ms */
      Time_ns.tv_sec = 0;
      Time_ns.tv_nsec = 20000000;
      T_Sleep = 20;
   } else {         /* othercase need timeout=0.1s=100*1ms */

      Time_ns.tv_sec = 0;
      Time_ns.tv_nsec = 1000000;
      T_Sleep = 1;
   }
   for (i = 0; i < 100; i++) {
      if (Ack == true)
         break;
#ifdef LINUX
      nanosleep(&Time_ns, NULL);
#endif
#ifdef WINDOWS
      Sleep(T_Sleep);
#endif
   }                /* end for */
   if (Ack == true)
      return ret;
   else
      return -1;
   return ret;
}

int send_reset(int fd, const char *addr)
{
   int ret = 0;

   Buffer_Ordre[0] = 0;
   Buffer_Ordre[1] = 0;
   Buffer_Ordre[2] = 0;
   Buffer_Ordre[3] = 0;
   ret = send_base(fd, 4, addr);
   Trame_a_venir = 1;
   EtherLinkUDP.ucPacketID = 0;
   return ret;
}

int send_data(int fd, int nbytes, const char *addr, unsigned char *pPacketID)
{
   int i;
   int ret;
   for (i = nbytes; i > 0; i--) {
   Buffer_Ordre[i + 1] = Buffer_Ordre[i - 1];   /* because we use index O and 1 for
   SendPacketID, we shift by two */
   }                /* end for */

   (*pPacketID)++;
   Buffer_Ordre[0] = 1;
   Buffer_Ordre[1] = *pPacketID;
   Ack = false;
   ret = send_base(fd, nbytes + 2, addr);
   return ret;
}

int send_broadcast(int fd, unsigned char *buffer, int nbytes, unsigned short port)
{
   int ret;
   int opt = 1;
   struct sockaddr_in socket_address;

   ret = setsockopt(fd, SOL_SOCKET, SO_BROADCAST, (const char *) &opt, sizeof(opt));
   if (ret == -1) {
      return ret;
   }

   memset(&socket_address, 0, sizeof(socket_address));
   socket_address.sin_family = PF_INET;
   socket_address.sin_port = htons(port);
   socket_address.sin_addr.s_addr = INADDR_BROADCAST;
#ifdef LINUX
   bzero(&(socket_address.sin_zero), 8);
#endif
   ret = sendto(fd, buffer, nbytes, 0, (struct sockaddr *) &socket_address, sizeof(struct sockaddr));
   /* printf("Envoi de: %d octets\n",erreur); */
   return ret;
}

int send_ip_addr(int fd, unsigned short port, unsigned char Ip1, unsigned char Ip2, unsigned char Ip3, unsigned char Ip4)
{
   int ret = 0;
   unsigned char data_buffer[MAXSIZEPACKETSEND];

   data_buffer[0] = 0xFF;
   data_buffer[1] = 0x0F;
   data_buffer[2] = 0xF0;
   data_buffer[3] = 0x11;
   data_buffer[4] = Ip1;
   data_buffer[5] = Ip2;
   data_buffer[6] = Ip3;
   data_buffer[7] = Ip4;

   ret = send_broadcast(fd, data_buffer, 8, port);
   return ret;
}

/* TODO : subst. sprint* with snprint*, add memset() */
int receive_data(const char *addr, int n_packet, PBufferList buffer, const unsigned int *n_byte_recvd_list)
{
    int row, n_handcheck;
    unsigned int Trame_arrivee, K;
    unsigned char *Buffer_start;
    unsigned char *Buffer_end;
    BOOL PacketOK, ReceivedOK;
    char ch = '\0', c1, c2;
    n_handcheck = 0;
    ReceivedOK = false;
    for (row = 0; row <= n_packet - 1; row++) {
        /* printf("row=%d\n",row);
        LOG_DEBUG("Recu %d bytes dans le packet %d\n",n_byte_recvd_list[row],row);
        for (col = 0;  col <= n_byte_recvd_list[row]-1; col++)
        {
            LOG_DEBUG("%x ", (*buffer)[row][col]);
        }
        LOG_DEBUG("\n"); */
        if (n_byte_recvd_list[row] < 4) {
            LOG_WARNING("%s", "Packet trop petit\n");
            // We continue or return now ???
        }
        ch = (*buffer[row])[0];
        /* printf("Ch=%d\n",ch);
        switch (buffer[row][0]) { */
        switch (ch) {
        case 0x01:      /* Handcheck of a command send to EthernAude */
            Ack = true;
            LOG_DEBUG("%f ACK de la commande %d\n", GetTimeStamp(), (*buffer[row])[2]);
            break;

        case 0x02:      /*receive data */
            c1 = (*buffer)[row][1];
            c2 = (*buffer)[row][2];
            Buffer_Ordre[n_handcheck + 2] = (*buffer)[row][1];
            Buffer_Ordre[n_handcheck + 3] = (*buffer)[row][2];
            n_handcheck += 2;
            Trame_arrivee = (*buffer)[row][1] * 256 + (*buffer)[row][2];
/*          LOG_DEBUG ("trame arrivee=%d\n", Trame_arrivee); */
            if (n_byte_recvd_list[row] == 1027) {   /* it's a packet of data of an image */
                PacketOK = false;
                if (Overflow == true) { /* between the first and last packet, we go thrue the boundary of 65536 */
                    if ((Trame_arrivee < Trame_a_venir) || (Trame_arrivee >= Premiere_Trame)) { /* packet number is OK */
                        PacketOK = true;
                    }
                } /* end of if */
                else {
                    if ((Trame_arrivee < Trame_a_venir) && (Trame_arrivee >= Premiere_Trame)) { /* packet number is OK */
                        PacketOK = true;
                    }
                }       /* end of else */
                if ((PacketOK == true) && (TrameOK[Trame_arrivee] == false)) {  /* check if packet is not already arrived */
                    TrameOK[Trame_arrivee] = true;
                    Buffer_end = EtherLinkUDP.BufferUDP + ((Trame_arrivee - Premiere_Trame + 65536) & 0x0FFFF) * 1022;
                    Buffer_start = &(*buffer)[row][5];
                    if (((Trame_arrivee + 1) & 0x0FFFF) == Trame_a_venir) { /* it is the last packet */
                        for (K = 0; K < Nb_Last_Packet; K++) {  /* tranfert of Nb_Last_Packet pixels */
                            *Buffer_end = *Buffer_start;
                            Buffer_start++;
                            Buffer_end++;
                            *Buffer_end = *Buffer_start;
                            Buffer_start++;
                            Buffer_end++;
                        }   /* end of for */
                    } /* end of if */
                    else {
                        for (K = 0; K < 511; K++) { /* transfert of 511 pixels */
                            *Buffer_end = *Buffer_start;
                            Buffer_start++;
                            Buffer_end++;
                            *Buffer_end = *Buffer_start;
                            Buffer_start++;
                            Buffer_end++;
                        }   /* end of for */
                    }       /* end of else */
                    K = Trame_check;
                    while (TrameOK[K & 0x0FFFF] == true) {
                        K++;
                    }       /*end of while */
                    Trame_check = (K & 0x0FFFF);
                    LOG_DEBUG("%f Trame_check=%d\n", GetTimeStamp(), Trame_check);
                    LOG_DEBUG("%f Trame_a_venir=%d\n", GetTimeStamp(), Trame_a_venir);
                    if (Trame_check == Trame_a_venir) {
                        ReceivedOK = true;
                    }
                }
                else {
                    /* n_handcheck-=2; */
                }
            }
            else {      /* it's the end of a command */
                if (Trame_arrivee == Trame_a_venir) {
                    LOG_DEBUG("%f trame <>1027 arrivee=%d\n", GetTimeStamp(), Trame_arrivee);
                    LOG_DEBUG("%f trame <>1027 a venir=%d\n", GetTimeStamp(), Trame_a_venir);
                    Trame_a_venir = (Trame_a_venir + 1) & 0x0FFFF;
                    for (K = 0; K < n_byte_recvd_list[row]; K++) {
                        EtherLinkUDP.BufferUDP[K] = (*buffer)[row][K + 4];
                    }
                    ReceivedOK = true;
                }
                else {
                    LOG_WARNING("trame <>1027 arrivee=%d\n", Trame_arrivee);
                    LOG_WARNING("trame <>1027 a venir=%d\n", Trame_a_venir);
                    LOG_WARNING("%s", "Patatra\n");
                }
            }
            if (n_handcheck > 0) {
                Buffer_Ordre[0] = (char) 2;
                Buffer_Ordre[1] = (char) (n_handcheck / 2);
                send_base(SocketHandle, n_handcheck + 2, addr);
                if (ReceivedOK == true) {
                    Received = true;
                    if (Exposure_Pending == true) {
                        Exposure_Pending = false;
                        Exposure_Completed = true;
                    }
                    if (Readout_in_Progress == true)
                        Readout_in_Progress = false;
                }
            }
            /* end of if */
            break;

        case 0x03:
            LOG_DEBUG("case 3= %d\n", (*buffer[row])[2]);
            EtherLinkUDP.BufferUDP[0] = (*buffer)[row][2];
            EtherLinkUDP.BufferUDP[1] = (*buffer)[row][3];
            Received = true;
            Ack = true;
            break;
        }           /* endswitch */
    }               /* end for (row) */
    return 0;
}               /* end of function */
