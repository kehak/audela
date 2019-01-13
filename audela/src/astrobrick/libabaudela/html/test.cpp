#include <windows.h>
#include <stdio.h>

#define OS_WIN

#include "audela.h"


HANDLE audela_dll;
const int MAXLEN=255;
char *cmdline;
char t[MAXLEN+1];

void execute(void *session, char *s)
{ 
   int ok, len;
   ok = audela_eval(session,s,&len);
   if(len>0) {
      audela_getresult(session,MAXLEN,t);
      printf("%s -> %s\n",ok==0?"OK":"ERR",t);
   } else {
      printf("OK\n");
   }
}

int main(int argc, char *argv[])
{
   void *session;

   putenv("TCL_LIBRARY=c:\\lib\\tcl8.0");
   putenv("TK_LIBRARY=c:\\lib\\tk8.0");

   cmdline = (char*)calloc(MAXLEN+1,1);
   audela_dll = LoadLibrary("libaudela.dll");
   if(audela_dll==NULL) {
      printf("Unable to open libaudela.dll\n");
	  free(cmdline);
      return 1;
   }

   audela_open      = (AUDELA_OPEN)GetProcAddress(audela_dll,"audela_open");
   audela_close     = (AUDELA_CLOSE)GetProcAddress(audela_dll,"audela_close");
   audela_eval      = (AUDELA_EVAL)GetProcAddress(audela_dll,"audela_eval");
   audela_getbuf    = (AUDELA_GETBUF)GetProcAddress(audela_dll,"audela_getbuf");
   audela_getresult = (AUDELA_GETRESULT)GetProcAddress(audela_dll,"audela_getresult");
   audela_putbuf    = (AUDELA_PUTBUF)GetProcAddress(audela_dll,"audela_putbuf");


   session = audela_open();

   printf("TCL_LIBRARY=%s\n",getenv("TCL_LIBRARY"));
   printf("TK_LIBRARY=%s\n",getenv("TK_LIBRARY"));

   if(session>0) {

      /*
       * Print the current working directory, and do some
       * mathematics.
       */
      execute(session,"cd ..");
      execute(session,"pwd");
      execute(session,"set a 5");
      execute(session,"expr {5*3+27}");
      execute(session,"expr $a+50");

      /*
       * Create a text file containing the famous "Hello AudeLA !".
       */
      execute(session,"set f [open toto.txt w]");
      execute(session,"puts $f \"Hello AudeLA !\n\"");
      execute(session,"close $f");

      /*
       * Create a 160*25 pixels image, with a star at its center,
       * then saves it as a FITS file.
       */
      execute(session,"set buffer buf[buf::create]");
      execute(session,"set fwhmx 2.7");
      execute(session,"set fwhmy 3.1");
      execute(session,"$buffer format 160 25");
      execute(session,"$buffer offset 16384");
      execute(session,"$buffer synthegauss [list 80 12 10000 $fwhmx $fwhmy]");
      execute(session,"$buffer synthegauss [list 82.3 11.1 8700 $fwhmx $fwhmy]");
      execute(session,"$buffer save toto.fit");

      /*
       * The control is let to the user, it's a TCL command line, with
       * all TCL and AudeLA commands. Two commands are added to show an
       * example of data exchange between the User's application and
       * AudeLA.
       */
      printf("Enter \"bye\" to leave the test program.\n"); 
      while(1) {
         printf("AudeLA> ");
         gets(cmdline);
         if (strcmp(cmdline,"putbuf")==0) {
            typedef double TYPE;
            const int w = 10, h = 10;
            TYPE buf[h][w]; int n=0;
            for(int j=0;j<h;j++) for(int i=0;i<w;i++) buf[j][i] = (TYPE)(n++)/1.5;
            audela_putbuf(session,1,AUDELA_TYPE_DOUBLE,w,h,buf);
         } else if (strcmp(cmdline,"getbuf")==0) {
            typedef double TYPE;
            const int w = 10, h = 10;
            TYPE buf[h][w];
            audela_getbuf(session,1,AUDELA_TYPE_DOUBLE,w,h,buf);
            FILE *f;
            f=fopen("image.raw","wt");
            for(int j=0;j<h;j++) {
               for(int i=0;i<w;i++) {
                  fprintf(f,"%lf\t",buf[j][i]);
               }
               fprintf(f,"\n");
            }
            fclose(f);
         } else if (strcmp(cmdline,"bye")==0) {
			audela_close(NULL);
			printf("*** bye bye ***\n");
			getchar();
			exit(0);
         } else {
            execute(session,cmdline);
         }
      }
   } else {
      printf("Impossible de creer une session AudeLA.\nAppuyez sur une touche...");
      getchar();
   }

   FreeLibrary(audela_dll);

   return 0;
}
