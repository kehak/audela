///@file CProducer.h
// This file is part of the AudeLA project : <http://software.audela.free.fr>
// Copyright (C) 1998-2004 The AudeLA Core Team
//
// @author Michel Pujol
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or (at
// your option) any later version.
// 
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// $Id: $

#include <fstream>   // pour ofstream
#include <iomanip>   // pour setw
#include <stdexcept>
#include <cstdlib>   // pour atoi



#ifdef  _WIN32
#define sleep(ms) Sleep(ms)
#else
#include <unistd.h>  // pour usleep
#define sleep(ms) usleep(ms*1000)
#endif


#include <abcommon.h>
using namespace abcommon;
#include "CThread.h"
#include "CProducer.h"

CProducer::CProducer() {

}

CProducer::~CProducer() {

}

class ProducerThread : public CThread
{
    CMessageQueue<MessageItem*>& m_queue;
    int exptime;
 
  public:
    ProducerThread(CMessageQueue<MessageItem*>& queue, int exptime) : m_queue(queue) {
      this->exptime = exptime;
    }
    ProducerThread & operator=( const ProducerThread & ) { return *this; }
 
    void* run() {
       MessageItem* item = new MessageItem("exp", 1);
       m_queue.add(item);
       sleep(exptime);
       item = new MessageItem("read", 2);
       m_queue.add(item);
       sleep(2000);
       item = new MessageItem("stand", 3);
       m_queue.add(item);

       return NULL;
    }
};



void CProducer::acq(int exptime)
{
   ProducerThread* thread1 = new ProducerThread(m_queue, exptime);
   thread1->start();
   printf("CProducer::acq\n");
}


int CProducer::waitMessage()
{
   printf("CProducer::waitMessage begin\n"); 
   MessageItem* item =m_queue.remove();
   printf("CProducer::waitMessage end\n"); 
   //delete item;

   return item->getNumber();
}



