/*
 * porttalk_interface.h
 *
 * prototypes des fonctions implementees dans porttalk_interface.c
 *
 */


unsigned char OpenPortTalk(int argc, char ** argv, char * inputDirectory, char * resultMessage );
unsigned  char GrantPort( char *port, char * inputDirectory, char * resultMessage  );
void ClosePortTalk( void);
int  GetPortTalkHandle(void);


