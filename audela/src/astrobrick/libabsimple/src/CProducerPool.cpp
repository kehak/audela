///@file CProducerPool.h
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
#include "CProducer.h"


// Pool  
CPool  messageProducerPool;

// factory & pool management
absimple::IProducer*  absimple::IProducerPool::createInstance() {
   CProducer* producer = new CProducer();
   messageProducerPool.add(producer);
   return producer;
}

void absimple::IProducerPool::deleteInstance(absimple::IProducer* producer) {
   messageProducerPool.remove(producer);
   delete producer;
}

absimple::IProducer* absimple::IProducerPool::getInstance(int producerNo) {
   return (absimple::IProducer*) messageProducerPool.getInstance(producerNo);
}

int absimple::IProducerPool::getInstanceNo(absimple::IProducer* producer) {
   return messageProducerPool.getInstanceNo(producer);
}

IIntArray* absimple::IProducerPool::getIntanceNoList() {
   return messageProducerPool.getIntanceNoList();
}

