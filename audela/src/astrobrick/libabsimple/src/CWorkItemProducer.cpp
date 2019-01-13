// CCalendar.cpp
// sample of internal implementation of class with methods 
// returning basic types (ex:double) 
//

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
#include "CMessageQueue.h"
#include "CThread.h"
#include "CWorkItemProducer.h"

 
class WorkItem
{
private:
   std::string m_message;
   int    m_number;

public:
    WorkItem(const char* message, int number) 
          : m_message(message), m_number(number) {}
    ~WorkItem() {}
 
    const char* getMessage() { return m_message.c_str(); }
    int getNumber() { return m_number; }
};

class ConsumerThread : public CThread
{
    CMessageQueue<WorkItem*>& m_queue;
 
public:
    ConsumerThread(CMessageQueue<WorkItem*>& queue) : m_queue(queue) {
    }
    ConsumerThread & operator=( const ConsumerThread & ) { return *this; }

    void* run() {
       // Remove 1 item at a time and process it. Blocks if no items are 
       // available to process.
       bool a = true;
       for (int i = 0; a == true; i++) {
          printf("thread %lu, loop %d - waiting for item...\n", 
             (long unsigned int)self(), i);
          WorkItem* item = m_queue.remove();
          printf("thread %lu, loop %d - got one item\n", 
             (long unsigned int)self(), i);
          printf("thread %lu, loop %d - item: message - %s, number - %d\n", 
             (long unsigned int)self(), i, item->getMessage(), 
             item->getNumber());
          delete item;
       }
       return NULL;
    }
};



CWorkItemProducer::CWorkItemProducer() {

}

CWorkItemProducer::~CWorkItemProducer() {

}

void CWorkItemProducer::release() {
   delete this;
}


void CWorkItemProducer::run(int iterations)
{
    // Create the queue and consumer (worker) threads
    CMessageQueue<WorkItem*>  queue;
    ConsumerThread* thread1 = new ConsumerThread(queue);
    ConsumerThread* thread2 = new ConsumerThread(queue);
    thread1->start();
    thread2->start();
 
    // Add items to the queue
    WorkItem* item;
    for (int i = 0; i < iterations; i++) {
        item = new WorkItem("abc", 123);
        queue.add(item);
        item = new WorkItem("def", 456);
        queue.add(item);
        item = new WorkItem("ghi", 789);
        queue.add(item);
        //sleep(1);
        sleep(1000);
    }
 
    // Wait for the queue to be empty
    while (queue.size() < 0);
    printf("done\n");
}




