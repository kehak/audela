/*

  etherlinkudp.c

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
#include "etherlinkudp.h"

#ifdef LINUX
#include	<time.h>
#endif

#ifdef WINDOWS
#include	<wtypes.h>
#include	<winbase.h>
#endif

int NbParams;

int Init_TEtherLinkUDP(char *ip)
{
    LOG_NOTICE( "%s\n", __FUNCTION__ );
    EtherLinkUDP.ucPacketID = 0;
    SocketHandle = udp_init_connection();
    pthread_mutex_init(&Mutex, NULL);
    /* debut modif Alain */
    /*EtherLinkUDP.Socket_Address.sin_addr.s_addr = inet_addr ("195.83.102.123"); */
    /*can be change with Set_IP */
    EtherLinkUDP.Socket_Address.sin_addr.s_addr = inet_addr(ip);
    /* fin modif Alain */
    return 0;
}

int Close_TEtherLinkUDP()
{
    LOG_NOTICE( "%s\n", __FUNCTION__ );
    SocketHandle = udp_close_connection();
    pthread_mutex_destroy(&Mutex);
    return 0;
}

BOOL Info_Received()
{
    struct timespec Time_ns;
//    LOG_DEBUG("tps=%f InfoReceived=%d\n", GetTimeStamp(), Received);
    if (Received == true) {
/*      Received = false;   */
        LOG_DEBUG("tps=%f InfoReceived=%d\n", GetTimeStamp(), Received);
        return true;
    }
    else {
        Time_ns.tv_sec = 0;
        Time_ns.tv_nsec = 1000000;
#ifdef LINUX
        nanosleep(&Time_ns, NULL);
#endif
#ifdef WINDOWS
        Sleep(1);
#endif
        return false;
    }
}

void SendData_TEtherLinkUDP(int NbByteToSend, int port)
{
    LOG_NOTICE( "%s\n", __FUNCTION__ );
    int ret;
    ret = send_data(SocketHandle, NbByteToSend, NULL, &EtherLinkUDP.ucPacketID);
    if (ret == -1) {
//        LOG_DEBUG("Error in sendData\n");
    }
}

void Set_IP(int IP1, int IP2, int IP3, int IP4)
{
    LOG_NOTICE( "%s\n", __FUNCTION__ );
    char IP[20];
    sprintf(IP, "%d.%d.%d.%d", IP1, IP2, IP3, IP4);
    EtherLinkUDP.Socket_Address.sin_addr.s_addr = inet_addr(IP);
}

int EthernaudeReset(unsigned char *Buffer)
{
    /*send a reset, need a buffer of 2 bytes */
    LOG_NOTICE( "%s Buffer=%p\n", __FUNCTION__, Buffer );

    int ret;
    Received = false;
    EtherLinkUDP.BufferUDP = Buffer;
    ret = send_reset(SocketHandle, NULL);
    if (ret == 4)
        return true;
    else
        return false;
}

int Identity(unsigned char *Buffer)
{
    LOG_NOTICE( "%s Buffer=%p\n", __FUNCTION__, Buffer );
    int ret;
    EtherLinkUDP.BufferUDP = Buffer;
    Buffer_Ordre[0] = 3;
    NbParams = 1;
    Received = false;
    ret = send_data(SocketHandle, NbParams, NULL, &EtherLinkUDP.ucPacketID);
    if (ret == NbParams + 2)
        return true;
    else
        return false;
}

int ClearCCD(unsigned char *Buffer, unsigned char number)
{
    LOG_NOTICE( "%s Buffer=%p number=%d\n", __FUNCTION__, Buffer, number );

    /*clear the CCD, 'number' times */
    int ret;
    EtherLinkUDP.BufferUDP = Buffer;
    Buffer_Ordre[0] = 1;
    Buffer_Ordre[1] = number;
    NbParams = 2;
    Received = false;
    ret = send_data(SocketHandle, NbParams, NULL, &EtherLinkUDP.ucPacketID);
    if (ret == NbParams + 2)
        return true;
    else
        return false;
}

int Exposure(unsigned char *Buffer, int time, int shutter)
{
    LOG_NOTICE( "%s Buffer=%p time=%d shutter=%d\n", __FUNCTION__, Buffer, time, shutter );
    /*exposure of time ms */
    int ret;
    EtherLinkUDP.BufferUDP = Buffer;
    Buffer_Ordre[0] = 2;
    Buffer_Ordre[1] = time & 0x0FF;
    Buffer_Ordre[2] = (time & 0X0FF00) >> 8;
    Buffer_Ordre[3] = (time & 0x0FF0000) >> 16;
    Buffer_Ordre[4] = shutter & 0x0FF;
    NbParams = 5;
    Received = false;
    Exposure_Pending = true;
    ret = send_data(SocketHandle, NbParams, NULL, &EtherLinkUDP.ucPacketID);

    if (ret == NbParams + 2)
        return true;
    else
        return false;
}


int StopExposure(unsigned char *Buffer)
{
    LOG_NOTICE( "%s Buffer=%p\n", __FUNCTION__, Buffer );
    /*abort the current exposure */
    int ret;
    if (Exposure_Pending == true) {
        EtherLinkUDP.BufferUDP = Buffer;
        Buffer_Ordre[0] = 0xFA;
        NbParams = 1;

/*      Received = false;   */
        ret = send_data(SocketHandle, NbParams, NULL, &EtherLinkUDP.ucPacketID);
        if (ret == NbParams + 2)
            return true;
        else
            return false;
    }
    else
        return false;
}



void Readout(unsigned char *Buffer, unsigned char BinX, unsigned char BinY, int X1, int Y1, int DX, int DY)
{
    LOG_NOTICE( "%s Buffer=%p BinX=%u BinY=%u X1=%d Y1=%d DX=%d DY=%d\n", __FUNCTION__, Buffer, BinX, BinY, X1, Y1, DX, DY );
    /* Readout of CCD */
    int ret;
    unsigned int i, j;
    int T_Sleep;
    struct timespec Time_ns;

    if (Received == false)
        LOG_WARNING("%f ATTENTION Received= false\n", GetTimeStamp());
    Time_ns.tv_sec = 0;
    Time_ns.tv_nsec = 1000000;
    T_Sleep = 1;
/*  while (Received==false)
    #ifdef LINUX
    nanosleep(&Time_ns,NULL);
    #endif
    #ifdef WINDOWS
    Sleep(T_Sleep);
    #endif
 */
    while (Received == false) {
#ifdef LINUX
    nanosleep(&Time_ns, NULL);
#endif
#ifdef WINDOWS
    Sleep(T_Sleep);
#endif
    }

    EtherLinkUDP.BufferUDP = Buffer;
    Buffer_Ordre[0] = 4;
    Buffer_Ordre[1] = BinX;
    Buffer_Ordre[2] = BinY;
    Buffer_Ordre[3] = (unsigned char) (X1 & 0x000FF);
    Buffer_Ordre[4] = (unsigned char) ((X1 & 0x0FF00) >> 8);
    Buffer_Ordre[5] = (unsigned char) (Y1 & 0x000FF);
    Buffer_Ordre[6] = (unsigned char) ((Y1 & 0x0FF00) >> 8);
    Buffer_Ordre[7] = (unsigned char) (DX & 0x000FF);
    Buffer_Ordre[8] = (unsigned char) ((DX & 0x0FF00) >> 8);
    Buffer_Ordre[9] = (unsigned char) (DY & 0x000FF);
    Buffer_Ordre[10] = (unsigned char) ((DY & 0x0FF00) >> 8);
    NbParams = 11;
    Overflow = false;
    Exposure_Completed = false;
    Readout_in_Progress = true;

    LOG_DEBUG ("%f Received= %d\n",GetTimeStamp(), Received);

    Premiere_Trame = Trame_a_venir;
    Trame_check = Premiere_Trame;
    Nombre_Trame = (DX * DY) / 511;
    Nb_Last_Packet = (DX * DY) % 511;
    if (Nb_Last_Packet != 0) {
        Nombre_Trame++;
    }
    Trame_a_venir += Nombre_Trame;
    if (Trame_a_venir > 65535) {
        Trame_a_venir -= 65536;
        Overflow = true;
    }
    j = Premiere_Trame;
    for (i = 0; i < Nombre_Trame + 5; i++) {
        TrameOK[j] = false;
        j++;
        if (j == 65536)
            j = 0;
    }

    LOG_DEBUG("NETTOIE de %d a %d\n",Premiere_Trame,j);
    Received = false;
    ret = send_data(SocketHandle, NbParams, NULL, &EtherLinkUDP.ucPacketID);
    if (ret == -1) {
        printf("Error in sendData\n");
    }
}

int ShutterChange(unsigned char *Buffer)
{
    LOG_NOTICE( "%s Buffer=%p\n", __FUNCTION__, Buffer );

    /*inverse the shutter port */
    int ret;
    EtherLinkUDP.BufferUDP = Buffer;
    Buffer_Ordre[0] = 5;
    NbParams = 1;
    Received = false;
    ret = send_data(SocketHandle, NbParams, NULL, &EtherLinkUDP.ucPacketID);
    if (ret == NbParams + 2)
        return true;
    else
        return false;
}

int SetCANSpeed(unsigned char *Buffer, unsigned char speed)
{
    LOG_NOTICE( "%s Buffer=%p speed=%u\n", __FUNCTION__, Buffer, speed );
    /* set the speed of CAN */
    int ret;
    EtherLinkUDP.BufferUDP = Buffer;
    Buffer_Ordre[0] = 0x0C;
    Buffer_Ordre[1] = speed;
    NbParams = 2;
    Received = false;
    ret = send_data(SocketHandle, NbParams, NULL, &EtherLinkUDP.ucPacketID);
    if (ret == NbParams + 2) {
        return true;
    } else
        return false;
}
