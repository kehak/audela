/*
 * private.h
 *
 * 32-bit Motion Control Device Driver
 * User-mode support library - private definitions
 *
 * Rick Schneeman, NIST, January 1995
 *
 * See readme.txt file for acknowledgements and support.
 *
 * Copyleft (c) US Dept. of Commerce, NIST, 1995.
 */
#ifndef _PRIVATE_H
  #define _PRIVATE_H

/*
 * function codes that the calling thread can ask the worker thread to
 * perform
 */

typedef enum _MCFUNC { //  arg                 result
                       //  ---     ------
    InterruptTerm,     //  <null>    <null>
    InvalidFunction
} MCFUNC, *PMCFUNC;

/* we send this many interrupt request to the kernel at once to queue */

  #define ALL_INTERRUPTS    8   // total available ints on pmac/starter set
  #define INTERRUPT_THRESHOLD 3 // queue not less than these many ints


/*
 * the worker thread starts execution at this function
 */
DWORD MC_ThreadInit(DWORD);

/*
 * process a user request that needs to be handled on the
 * worker thread
 *
 * It returns the result of the operation in pResult, and returns
 * TRUE if the worker thread loop should terminate.
 *
 * This function will normally be called from the main
 * worker-thread event processing loop. However, it must be
 * called directly by the entrypoint functions if they
 * discover they are running on the worker thread (eg from a callback).
 * If this doesn't happen, we will enter deadlock with the worker thread
 * waiting for itself to signal an event.
 */
//BOOL MC_ProcessFunction(PUSER_HANDLE vh, MCFUNC Function, DWORD Param, LPDWORD pResult);

#endif
