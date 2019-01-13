#ifndef _DPAPI_H
#define _DPAPI_H

#ifdef _WIN32
    #include <winsock.h>
    typedef int DPServer; 
    #define ECONNRESET	WSAECONNRESET
#else /* Unix */ 
    typedef int DPServer;
#endif

/*
 * RDO flags
 */

#define DP_REPORT_ERROR		(1<<0)
#define DP_RETURN_VALUE		(1<<1)

/*---------------------- Externally visible API ----------------------*/

char *Dp_RPC			(DPServer server, char *mesgStr, 
				    struct timeval *tv, int *errorPtr);
int Dp_RDOSend			(DPServer server, char *mesgStr,
				    int flags);
char *Dp_RDORead		(DPServer server, int *errorPtr);
int Dp_WaitForServer		(DPServer server, struct timeval *tv);
DPServer Dp_ConnectToServer	(int inetAddr, int port);

#endif
