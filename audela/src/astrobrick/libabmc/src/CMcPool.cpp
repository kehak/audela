// CMcPool.cpp
// sample of internal implementation of class with methods 
// returning basic types (ex:double) 
//


#include <abcommon.h>
using namespace abcommon;
#include "CMc.h"


// Pool  
CPool  messageProducerPool;

// factory & pool management
abmc::IMc*  abmc::IMcPool::createInstance() {
   CMc* producer = new CMc();
   messageProducerPool.add(producer);
   return producer;
}

void abmc::IMcPool::deleteInstance(abmc::IMc* producer) {
   messageProducerPool.remove(producer);
   delete producer;
}

abmc::IMc* abmc::IMcPool::getInstance(int producerNo) {
   return (abmc::IMc*) messageProducerPool.getInstance(producerNo);
}

int abmc::IMcPool::getInstanceNo(abmc::IMc* producer) {
   return messageProducerPool.getInstanceNo(producer);
}

IIntArray* abmc::IMcPool::getIntanceNoList() {
   return messageProducerPool.getIntanceNoList();
}

