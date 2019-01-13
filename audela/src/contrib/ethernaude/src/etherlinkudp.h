/*

  etherlinkudp.h

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

#ifndef ETHERLINKUDP_H
#define ETHERLINKUDP_H

#include "os.h"
#include "UDPSocketComponent.h"


#ifdef WINDOWS
/* #include	<pthread.h> */
#include	<wtypes.h>
#include	<winbase.h>
#endif

struct TReorderBuffer {		/* struct to bufferize the datas incoming from the socket */
    int FirstPacket;
    int NbPacket;
    int SizePacket;
    int SizeBuffer;
};

int Init_TEtherLinkUDP();

int Close_TEtherLinkUDP();

BOOL Info_Received();

void SendData_TEtherLinkUDP(int NbByteToSend, int port);

void Set_IP(int IP1, int IP2, int IP3, int IP4);

int EthernaudeReset(unsigned char *Buffer);	/*send a reset, need a buffer of 2 bytes */

int Identity(unsigned char *Buffer);	/*ask for identity of CCD, need a buffer of 28 bytes */

int ClearCCD(unsigned char *Buffer, unsigned char number);	/*clear the CCD, 'number' times */

int Exposure(unsigned char *Buffer, int time, int shutter);	/*exposure of time ms */
						    /*shutter=1 -> shutter open */
int StopExposure(unsigned char *Buffer);	/*abort the current exposure */

void Readout(unsigned char *Buffer, unsigned char BinX, unsigned char BinY, int X1, int Y1, int DX, int DY);	/* Readout of CCD */

int ShutterChange(unsigned char *Buffer);	/*inverse the shutter port */

int SetCANSpeed(unsigned char *Buffer, unsigned char speed);	/* set the speed of CAN */

#endif				/* ifndef ETHERLINKUDP_H */
