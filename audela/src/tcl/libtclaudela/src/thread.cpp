/* thread.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include "tclaudela.h"
#include "audela.h"

#if defined(OS_WIN) 
#include <windows.h>
#include <dos.h>
#include <stdarg.h>    /* pour les vaarg */
#if defined(_MSC_VER)
#include <sys/timeb.h>
#include <time.h>
#endif /* defined(_MSC_VER) */
#define putenv _putenv

/* Definir cette variable pour utiliser TK */
#define USE_TK
#undef USE_AUDELASTD

Tcl_Interp *cmdinterp;
UINT WM_AUDELA = 0;

HANDLE mailslot_main_in    = INVALID_HANDLE_VALUE;
HANDLE mailslot_main_out   = INVALID_HANDLE_VALUE;
HANDLE mailslot_interp_in  = INVALID_HANDLE_VALUE;
HANDLE mailslot_interp_out = INVALID_HANDLE_VALUE;

HANDLE pipe_stdchannel     = INVALID_HANDLE_VALUE;

#define MSG(s)  MessageBox(NULL,s,"Libaudela.dll",MB_OK)
#define MSG2(s) MessageBox(NULL,s,"LIbaudela.dll - thread",MB_OK)

int exit_event_loop;

void eventSetupProc(ClientData clientData,int flags);
void eventCheckProc(ClientData clientData,int flags);
int eventDoCmd(Tcl_Event *evPtr, int flags);


void displayError(char *s)
{
   LPVOID lpMsgBuf;
   FormatMessage( 
      FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
      NULL,
      GetLastError(),
      MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
      (LPTSTR) &lpMsgBuf,
      0,
      NULL
   );
   MessageBox(NULL,(char*)lpMsgBuf,s,MB_OK|MB_ICONINFORMATION);
   LocalFree( lpMsgBuf );
}


/*
 * Declarations pour la redirection des std channels vers un pipe 
 */
#if defined(USE_AUDELASTD)

int	AudelaPipeInput   _ANSI_ARGS_((ClientData instanceData, char *buf, int toRead, int *errorCode));
int	AudelaPipeOutput  _ANSI_ARGS_((ClientData instanceData, char *buf, int toWrite, int *errorCode));
int	AudelaPipeClose   _ANSI_ARGS_((ClientData instanceData, Tcl_Interp *interp));
void	AudelaPipeWatch   _ANSI_ARGS_((ClientData instanceData, int mask));
int	AudelaPipeHandle  _ANSI_ARGS_((ClientData instanceData, int direction, ClientData *handlePtr));

Tcl_ChannelType pipeChannelType = {
    "audelapipe",		   /* Type name. */
    NULL,			      /* Always non-blocking.*/
    AudelaPipeClose,		/* Close proc. */
    AudelaPipeInput,		/* Input proc. */
    AudelaPipeOutput,   /* Output proc. */
    NULL,			      /* Seek proc. */
    NULL,			      /* Set option proc. */
    NULL,			      /* Get option proc. */
    AudelaPipeWatch,    /* Watch for events on console. */
    AudelaPipeHandle    /* Get a handle from the device. */
};

int  AudelaPipeInput _ANSI_ARGS_((ClientData instanceData, char *buf, int toRead, int *errorCode))
{
   return 0;
}

int  AudelaPipeOutput _ANSI_ARGS_((ClientData instanceData, char *buf, int toWrite, int *errorCode))
{
   int written = 0;
   if(pipe_stdchannel!=INVALID_HANDLE_VALUE)
      WriteFile(
         pipe_stdchannel,
         buf,
         toWrite,
         (LPDWORD)&written,
         NULL);
   return written;
}

int  AudelaPipeClose _ANSI_ARGS_((ClientData instanceData, Tcl_Interp *interp))
{
   return 0;
}

void AudelaPipeWatch _ANSI_ARGS_((ClientData instanceData, int mask))
{
}

int  AudelaPipeHandle _ANSI_ARGS_((ClientData instanceData, int direction, ClientData *handlePtr))
{
   return TCL_ERROR;
}
#endif


void vinfo(char *msg, char *fmt, ...)
{
   char s[256];
   va_list va;
   va_start(va,fmt);
   sprintf(s,"%s -> ",msg);
   vsprintf(s+strlen(msg)+4,fmt,va);
   va_end(va);
   LogFile(s);
   return;
}

void close_resources()
{
   DWORD cbwritten;
   CloseHandle(mailslot_interp_in);
   mailslot_interp_in = INVALID_HANDLE_VALUE;
   WriteFile(mailslot_interp_out,"9",2,&cbwritten,(LPOVERLAPPED)NULL);
   CloseHandle(mailslot_interp_out);
   mailslot_interp_out = INVALID_HANDLE_VALUE;
#if defined(USE_AUDELASTD)
   DisconnectNamedPipe(pipe_stdchannel);
   CloseHandle(pipe_stdchannel);
   pipe_stdchannel = INVALID_HANDLE_VALUE;
#endif
}



void eventSetupProc(ClientData clientData,int flags)
{
   return;
}

void eventCheckProc(ClientData clientData,int flags)
{
   Tcl_Event *evPtr;
   DWORD cmessage;

   if(mailslot_interp_in==INVALID_HANDLE_VALUE) {
      return;
   }
   GetMailslotInfo(mailslot_interp_in,(LPDWORD)NULL,NULL,&cmessage,(LPDWORD)NULL); 
   if (cmessage>0) {
      evPtr = (Tcl_Event*)Tcl_Alloc(sizeof(Tcl_Event));
      evPtr->proc = (Tcl_EventProc*)eventDoCmd;
      Tcl_QueueEvent((Tcl_Event*)evPtr,TCL_QUEUE_HEAD);
   }
}

int eventDoCmd(Tcl_Event *evPtr, int flags)
{
	char *s;
	DWORD cbmessage, cmessage, cbread, cbwritten;
	int res;

	if(mailslot_interp_in==INVALID_HANDLE_VALUE) {
		return 1;
	}
	GetMailslotInfo(mailslot_interp_in,(LPDWORD)NULL,&cbmessage,&cmessage,(LPDWORD)NULL); 
   if (cmessage>0) {
		s = (char*)calloc(1,cbmessage+1);
		ReadFile(mailslot_interp_in,s,cbmessage,&cbread,(LPOVERLAPPED)NULL);
		if(strcmp(s,"--------")==0) {
         close_resources();
         Tcl_Exit(0);
      } else {
			res = Tcl_Eval(cmdinterp,s); 
			free(s);
			s = (char*)calloc(1,strlen(Tcl_GetStringResult(cmdinterp))+3);
			sprintf(s,"%d%s",res,Tcl_GetStringResult(cmdinterp));
			WriteFile(mailslot_interp_out,s,strlen(s)+1,&cbwritten,(LPOVERLAPPED)NULL);
		}
		Tcl_Free((char*)evPtr);
		free(s);
	}
	return 1;
}

DWORD WINAPI EventLoopThreadFunc(LPVOID lpParam)
{
   HANDLE hEvent;
   char s[1024];
   size_t i;

   exit_event_loop = 0;

   /* Creation and initialization of the thread's TCL interpreter */
   cmdinterp = Tcl_CreateInterp();

   sprintf(s,"set env(TCL_LIBRARY) \"%s\"",getenv("TCL_LIBRARY"));
   for(i=0;i<strlen(s);i++) if(s[i]=='\\') s[i]='/';
   Tcl_Eval(cmdinterp,s);

   sprintf(s,"set env(TK_LIBRARY) \"%s\"",getenv("TK_LIBRARY"));
   for(i=0;i<strlen(s);i++) if(s[i]=='\\') s[i]='/';
   Tcl_Eval(cmdinterp,s);

   if(Tcl_Init(cmdinterp)!=TCL_OK) {
      sprintf(s,"Can't initialize TCL library :\n%s",Tcl_GetStringResult(cmdinterp));
      MessageBox(NULL,s,"AudeLA",MB_OK);
      return NULL;
   }
   audelaInit(cmdinterp);

   //mailslot_interp_in = CreateMailslot("\\\\.\\mailslot\\audela\\interp",0,MAILSLOT_WAIT_FOREVER,NULL);
   mailslot_interp_in = CreateMailslot("\\\\.\\mailslot\\audela\\interp",0,0,NULL);
   if(mailslot_interp_in==INVALID_HANDLE_VALUE) {
      MessageBox(NULL,"Can't create input mailslot.","AudeLA thread",MB_OK);
      return NULL;
   }

   mailslot_interp_out = CreateFile("\\\\.\\mailslot\\audela\\main",GENERIC_WRITE,FILE_SHARE_READ,(LPSECURITY_ATTRIBUTES)NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,(HANDLE)NULL);
   if(mailslot_interp_out==INVALID_HANDLE_VALUE) {
      MessageBox(NULL,"Can't create output mailslot.","AudeLA thread",MB_OK);
      if(CloseHandle(mailslot_interp_in)==0) {
         displayError("LibAudeLA (EventLoopThreadFunc");
         return NULL;
      }
      return NULL;
	}

	/* Setup of the event source */
	Tcl_CreateEventSource(eventSetupProc,eventCheckProc,NULL);

#if defined(USE_AUDELASTD)
   /* Create the pipeline for stdout/stderr */
   pipe_stdchannel = CreateNamedPipe("\\\\.\\pipe\\audela_stdpipe",PIPE_ACCESS_OUTBOUND,PIPE_TYPE_MESSAGE|PIPE_WAIT,1,1000,1000,10,NULL);

   Tcl_Channel pipeChannel;
   pipeChannel = Tcl_CreateChannel(&pipeChannelType, "audelastd0",(ClientData)NULL, TCL_READABLE);
   if (pipeChannel != NULL) {
      Tcl_SetChannelOption(NULL, pipeChannel, "-translation", "lf");
      Tcl_SetChannelOption(NULL, pipeChannel, "-buffering", "none");
      Tcl_SetStdChannel(pipeChannel, TCL_STDIN);
   }
   pipeChannel = Tcl_CreateChannel(&pipeChannelType, "audelastd1",(ClientData)NULL, TCL_WRITABLE);
   if (pipeChannel != NULL) {
      Tcl_SetChannelOption(NULL, pipeChannel, "-translation", "lf");
      Tcl_SetChannelOption(NULL, pipeChannel, "-buffering", "none");
      Tcl_SetStdChannel(pipeChannel, TCL_STDOUT);
   }
   pipeChannel = Tcl_CreateChannel(&pipeChannelType, "audelastd2",(ClientData)NULL, TCL_WRITABLE);
   if (pipeChannel != NULL) {
      Tcl_SetChannelOption(NULL, pipeChannel, "-translation", "lf");
      Tcl_SetChannelOption(NULL, pipeChannel, "-buffering", "none");
      Tcl_SetStdChannel(pipeChannel, TCL_STDERR);
   }
#endif

   /* EVENT used to signal the end of initialisation of the interp thread */
   hEvent = OpenEvent(EVENT_ALL_ACCESS,0,AUDELA_EVENT_NAME);	
   PulseEvent(hEvent);
   CloseHandle(hEvent);

   /* Thread event loop */
   while(1) {
      Tcl_DoOneEvent(0);
   }

   close_resources();
   Tcl_Exit(0);

   /* Exiting the event loop will make the thread no longer alive ... */
   return 0;
}

HANDLE hThread;

extern "C" void* CALLMETHOD audela_open()
{
   DWORD dwThreadId, dwThrdParam = 1, res;
   HANDLE hMutex;
   HANDLE hEvent;
   char chemin[MAXSTRING+1];
   char env_var[MAXSTRING+1];


   /*
    * An AudeLA specific message is created to excite the
    * event loop thread WindowProc while a command is pending
    * to make it taken into account and processed.
    */
   WM_AUDELA = RegisterWindowMessage(AUDELA_WINMSG_NAME);

   /* Create or open the creation mutex, and wait for it to be available. */
   hMutex = CreateMutex(NULL,0,"audelaMutex");

   WaitForSingleObject(hMutex,INFINITE);

   GetCurrentDirectory(MAXSTRING,chemin);
   if(getenv("TCL_LIBRARY")==NULL) {	
      sprintf(env_var,"TCL_LIBRARY=%s\\..\\lib\\tcl8.0",chemin);
	   putenv(env_var);
   }
   if(getenv("TK_LIBRARY")==NULL) {	
   	sprintf(env_var,"TK_LIBRARY=%s\\..\\lib\\tk8.0",chemin);
	   putenv(env_var);
   }

   hEvent = CreateEvent((LPSECURITY_ATTRIBUTES)NULL,0,0,AUDELA_EVENT_NAME);

   mailslot_main_in = CreateMailslot("\\\\.\\mailslot\\audela\\main",0,60000,(LPSECURITY_ATTRIBUTES)NULL);
   if(mailslot_main_in==INVALID_HANDLE_VALUE) {
      displayError("LibAudeLA (can't create input mailslot)");
      ReleaseMutex(hMutex);
      return NULL;
   }

   hThread = CreateThread((LPSECURITY_ATTRIBUTES)NULL,0,EventLoopThreadFunc,(LPVOID)NULL,0,&dwThreadId);
   if (hThread==INVALID_HANDLE_VALUE) {
      displayError("LibAudeLA (can't create thread)");
      if(CloseHandle(mailslot_main_in)==0)
         displayError("LibAudeLA (can't close input mailslot)");
      ReleaseMutex(hMutex);
      return NULL;
	}

   /* 
    * Wait for event to synchronize to the end of the thread init, and then the
    * creation of the reverse mailslot 
    */
   res=WaitForSingleObject(hEvent,5000);
   if(res==WAIT_FAILED) {
      /* The Wait function has returned because of an error : display it, and
         destroy the created objects */
      displayError("LibAudeLA (wait failed)");
      if(CloseHandle(mailslot_main_in)==0)
         displayError("LibAudeLA (can't close input mailslot)");
      ReleaseMutex(hMutex);
      CloseHandle(hEvent);
      return NULL;
   } else {
      if(res==WAIT_TIMEOUT) {
         displayError("LibAudeLA (timeout occurrence)");
         /* A timeout occurred, delete the ressources and exit */
         if(CloseHandle(mailslot_main_in)==0)
            displayError("LibAudeLA (can't close input mailslot)");
         ReleaseMutex(hMutex);
         CloseHandle(hEvent);
         return NULL;
      }
   }
   CloseHandle(hEvent);


   mailslot_main_out = CreateFile("\\\\.\\mailslot\\audela\\interp",GENERIC_WRITE,FILE_SHARE_READ,(LPSECURITY_ATTRIBUTES)NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,(HANDLE)NULL);
   if(mailslot_main_out==INVALID_HANDLE_VALUE) {
      displayError("LibAudeLA (can't open output mailslot)");
      if(CloseHandle(mailslot_main_in)==0)
         displayError("LibAudeLA (can't close input mailslot)");
      if(TerminateThread(hThread,0)==0)
         displayError("LibAudeLA (can't destroy the thread)");
   	ReleaseMutex(hMutex);
      return NULL;
	}
	ReleaseMutex(hMutex);

	return (void*)1;
 
}

extern "C" int CALLMETHOD audela_close(void *handle)
{
   int res;

   /* Prevents from using a killed interpreter. */
   if(mailslot_main_out==INVALID_HANDLE_VALUE) {
      return TCL_ERROR;
   }
   res = audela_eval(NULL,"--------",NULL);
   
   return res;
}

char result[AUDELA_EXCH_RESBUFSIZE];

extern "C" int CALLMETHOD audela_eval(void *handle, char *s, int *reslen)
{
   int nb, res, msgsizeread;
   HANDLE hMutex;

   /* Prevents from using a killed interpreter. */
   if(mailslot_main_out==INVALID_HANDLE_VALUE) {
      if(reslen) {
         *reslen = strlen(KILLED_THREAD_STR)+1;
      }
      strcpy(result,KILLED_THREAD_STR);
      return TCL_ERROR;
   }

   hMutex = CreateMutex(NULL,0,"audelaMutex");
   WaitForSingleObject(hMutex,INFINITE);
      /* Transfer of informations to the eventloop thread using */
      WriteFile(mailslot_main_out,s,(DWORD)strlen(s) + 1,(LPDWORD)&nb,(LPOVERLAPPED)NULL);
      /* Forces the eventloop thread notifier to poll other events. */
      PostMessage(HWND_BROADCAST,WM_AUDELA,0,0);
      /* Waiting for the eventloop thread answer, and return with its result. */
      ReadFile(mailslot_main_in,result,AUDELA_EXCH_RESBUFSIZE-1,(LPDWORD)&msgsizeread,(LPOVERLAPPED)NULL); 
   ReleaseMutex(hMutex);

   res = result[0]-'0';
   if(reslen) {
      *reslen = msgsizeread-1;
   }

   if(res==9) {
      CloseHandle(mailslot_main_out);
      mailslot_main_out = INVALID_HANDLE_VALUE;
      CloseHandle(mailslot_main_in);
      mailslot_main_in = INVALID_HANDLE_VALUE;
      res = TCL_OK;
   }
   return res;
}

extern "C" int CALLMETHOD audela_getresult(void *handle, int maxchar, char *s)
{
   int imax;
   if(mailslot_main_out==INVALID_HANDLE_VALUE) {
      strncpy(s,KILLED_THREAD_STR,maxchar-1);
      s[maxchar-1] = 0;
      return TCL_ERROR;
   }
   imax = min(maxchar-1,AUDELA_EXCH_RESBUFSIZE-1);
   strncpy(s,result+1,imax);
   s[imax] = 0;
   return TCL_OK;
}

extern "C" int CALLMETHOD audela_putbuf(void *handle, int bufno, int type, int w, int h, void *buffer)
{
   char cmd[256], res[256];
   int i, j, reslen;
   float *ptr;
   unsigned char *ucptr;
   short *sptr;
   unsigned short *usptr;
   long *lptr;
   unsigned long *ulptr;
   float *fptr;
   double *dptr;

   if(mailslot_main_out==INVALID_HANDLE_VALUE) {
	   return TCL_ERROR;
   }

   sprintf(cmd,"lsearch [::buf::list] %d",bufno);
   audela_eval(handle,cmd,&reslen);
   audela_getresult(handle,256,res);
   if(atoi(res)>=0) {
      sprintf(cmd,"::buf::delete %d",bufno);
      audela_eval(handle,cmd,&reslen);
   }
   sprintf(cmd,"::buf::create %d",bufno);
   audela_eval(handle,cmd,&reslen);

   sprintf(cmd,"buf%d format %d %d",bufno,w,h);
   audela_eval(handle,cmd,&reslen);

   sprintf(cmd,"buf%d pointer",bufno);
   audela_eval(handle,cmd,&reslen);
   audela_getresult(handle,256,res);
   ptr = (float*)atoi(res);
   printf("ptr=%p=%d\n",ptr,ptr);

   switch(type) {
      case AUDELA_TYPE_BYTE:
         ucptr = (unsigned char*)buffer;
         for(j=0;j<h;j++) for(i=0;i<w;i++) *ptr++ = *ucptr++;
         sprintf(cmd,"buf%d bitpix byte",bufno);
         audela_eval(handle,cmd,NULL);
         break;
      case AUDELA_TYPE_SHORT:
         sptr = (short*)buffer;
         for(j=0;j<h;j++) for(i=0;i<w;i++) *ptr++ = *sptr++;
         sprintf(cmd,"buf%d bitpix short",bufno);
         audela_eval(handle,cmd,NULL);
         break;
      case AUDELA_TYPE_USHORT:
         usptr = (unsigned short*)buffer;
         for(j=0;j<h;j++) for(i=0;i<w;i++) *ptr++ = *usptr++;
         sprintf(cmd,"buf%d bitpix ushort",bufno);
         audela_eval(handle,cmd,NULL);
         break;
      case AUDELA_TYPE_LONG:
         lptr = (long*)buffer;
         for(j=0;j<h;j++) for(i=0;i<w;i++) *ptr++ = (float)*lptr++;
         sprintf(cmd,"buf%d bitpix long",bufno);
         audela_eval(handle,cmd,NULL);
         break;
      case AUDELA_TYPE_ULONG:
         ulptr = (unsigned long*)buffer;
         for(j=0;j<h;j++) for(i=0;i<w;i++) *ptr++ = (float)*ulptr++;
         sprintf(cmd,"buf%d bitpix ulong",bufno);
         audela_eval(handle,cmd,NULL);
         break;
      case AUDELA_TYPE_FLOAT:
         fptr = (float*)buffer;
         for(j=0;j<h;j++) for(i=0;i<w;i++) *ptr++ = (float)*fptr++;
         sprintf(cmd,"buf%d bitpix float",bufno);
         audela_eval(handle,cmd,NULL);
         break;
      case AUDELA_TYPE_DOUBLE:
         dptr = (double*)buffer;
         for(j=0;j<h;j++) for(i=0;i<w;i++) *ptr++ = (float)*dptr++;
         sprintf(cmd,"buf%d bitpix double",bufno);
         audela_eval(handle,cmd,NULL);
         break;
   }

   return TCL_OK;
}

extern "C" int CALLMETHOD audela_getbuf(void *handle, int bufno, int type, int w, int h, void *buffer)
{
   char cmd[256], res[256];
   int i, j, ww, hh, reslen;
   float *ptr;
   unsigned char *ucptr;
   short *sptr;
   unsigned short *usptr;
   long *lptr;
   unsigned long *ulptr;
   float *fptr;
   double *dptr;

   if(mailslot_main_out==INVALID_HANDLE_VALUE) {
	   return TCL_ERROR;
   }

   sprintf(cmd,"lsearch [::buf::list] %d",bufno);
   audela_eval(handle,cmd,&reslen);
   audela_getresult(handle,256,res);
   if(atoi(res)>=0) {
      sprintf(cmd,"buf%d format",bufno);
      audela_eval(handle,cmd,&reslen);
      audela_getresult(handle,256,res);
      sscanf(res,"%d %d",&ww,&hh);
      printf("w=%d\nh=%d\n",ww,hh);

      sprintf(cmd,"buf%d pointer",bufno);
      audela_eval(handle,cmd,&reslen);
      audela_getresult(handle,256,res);
      ptr = (float*)atoi(res);
      printf("ptr=%p=%d\n",ptr,ptr);

      switch(type) {
         case AUDELA_TYPE_BYTE:
            ucptr = (unsigned char*)buffer;
            for(j=0;j<h;j++) for(i=0;i<w;i++) *ucptr++ = (unsigned char)*ptr++;
            break;
         case AUDELA_TYPE_SHORT:
            sptr = (short*)buffer;
            for(j=0;j<h;j++) for(i=0;i<w;i++) *sptr++ = (short)*ptr++;
            break;
         case AUDELA_TYPE_USHORT:
            usptr = (unsigned short*)buffer;
            for(j=0;j<h;j++) for(i=0;i<w;i++) *usptr++ = (unsigned short)*ptr++;
            break;
         case AUDELA_TYPE_LONG:
            lptr = (long*)buffer;
            for(j=0;j<h;j++) for(i=0;i<w;i++) *lptr++ = (long)*ptr++;
            break;
         case AUDELA_TYPE_ULONG:
            ulptr = (unsigned long*)buffer;
            for(j=0;j<h;j++) for(i=0;i<w;i++) *ulptr++ = (unsigned long)*ptr++;
            break;
         case AUDELA_TYPE_FLOAT:
            fptr = (float*)buffer;
            for(j=0;j<h;j++) for(i=0;i<w;i++) *fptr++ = (float)*ptr++;
            break;
         case AUDELA_TYPE_DOUBLE:
            dptr = (double*)buffer;
            for(j=0;j<h;j++) for(i=0;i<w;i++) *dptr++ = (double)*ptr++;
            break;
      }
   }
   return TCL_OK;
}

#else /* defined(OS_WIN) */

/* To be thought about ... ;() */
extern "C" void* CALLMETHOD audela_open()
{
  return NULL;
}
extern "C" int CALLMETHOD audela_close(void *handle)
{
  return 0;
}
extern "C" int CALLMETHOD audela_eval(void *handle, char *s, int *reslen)
{
  return 0;
}
extern "C" int CALLMETHOD audela_getresult(void *handle, int maxchar, char *s)
{
  return 0;
}
extern "C" int CALLMETHOD audela_putbuf(void *handle, int bufno, int type, int w, int h, void *buffer)
{
  return 0;
}
extern "C" int CALLMETHOD audela_getbuf(void *handle, int bufno, int type, int w, int h, void *buffer)
{
  return 0;
}

#endif /* defined(OS_WIN) */
