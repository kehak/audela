#pragma once

#include <time.h>

#ifdef WIN32
#include <Winsock.h>
void  gettimeofday ( struct timeval * start, void * foo);
#else
#include <sys/time.h>
#endif

void getutc_ymdhhmmss(int *y,int *m,int *d,int *hh,int *mm,double *sec);
