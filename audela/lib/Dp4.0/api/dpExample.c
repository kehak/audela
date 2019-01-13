/*
 * api/dpExample.c
 *
 * This file provides an example of how to use the DP C API
 * to perform RPCs and RDOs with a Tcl-DP server.
 */

#include <stdio.h>
#include "dpApi.h"

void main(int argc, char **argv)
{
    char *rdoStr = "set s 5";
    char *rpcStr = "set s";
    int host = 0x7F000001;	/* "127.0.0.1" == localhost */
    int port = 7878;
    DPServer server;
    int rc, error;
    char *rcStr;
    struct timeval tv;

#ifdef _WIN32
    /*
     * Win32 requires an application to initialize
     * the sockets library before using it. I suppose
     * this has to do with multithreading...
     */
    WORD ver = 0x0101;
    WSADATA garbage;

    if (WSAStartup(ver, &garbage)) {
	return;
    }
#endif

    /*
     * Set our RPC timeout to 5 seconds.
     */

    tv.tv_sec = 5;
    tv.tv_usec = 0;

    /*
     * Simple RDO - no options
     */

    server = Dp_ConnectToServer(host, port);
    if (server == -1) {
    	printf("Sockets suck.\n");
    	return;
    }

    rc = Dp_RDOSend(server, rdoStr, 0);
    if (rc != (int)strlen(rdoStr)) {
    	printf("RDOs suck.\n");
	closesocket(server);
    	return;
    }

    /*
     * Simple RPC --
     *
     * Error must always be initialized to zero
     * so that we can tell if there was an error
     * on this call.
     */

    error = 0;
    rcStr = Dp_RPC(server, rpcStr, NULL, &error);
    if (error != 0) {
    	printf("Error - Dp_RPC returned: %s\n", rcStr); 
	closesocket(server);
    	return;
    }
    printf("%s\n", rcStr);

    /*
     * Callback RDO
     */

    rc = Dp_RDOSend(server, rdoStr, DP_RETURN_VALUE);
    if (rc != (int)strlen(rdoStr)) {
    	printf("Sending RDOs sucks.\n");
	closesocket(server);
    	return;
    }

    rc = Dp_WaitForServer(server, &tv);
    if (rc <= 0) {
    	printf("Error waiting for reply\n");
	closesocket(server);
    	return;
    }

    rcStr = Dp_RDORead(server, &error);
    if (rcStr == NULL) {
    	printf("Problem with recv\n");
	closesocket(server);
    	return;
    }
    puts(rcStr);

    closesocket(server);
}
