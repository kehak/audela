#include <iostream>
#include <fstream>
#include <windows.h>
#include <windowsx.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include "ctype.h"
#include "assert.h"

#define DEBUG 0
#define mysleep( seconds ) Sleep( (int)(seconds * CLOCKS_PER_SEC ));

using namespace std;

#define PM_KEY_UPPER_I 49

HWND hwndNotepad,hwndEdit,hwndDialog;

char BELL=(char)7;
int num_param;
char** _param;
bool _bip=1;
char command[255];
char previous_command[255];

int wait_file(char * name)
{
	HANDLE hnd;
	LPWIN32_FIND_DATA lpfindata = new WIN32_FIND_DATA;

	cout << "Waiting file " << name << " " << flush;

	do
	{
	 hnd=FindFirstFile(name,lpfindata);
	 mysleep(1);
	 cout << "." << flush;
	}
	while ((int)hnd<0);		// Verifier le retour de FindFirst !!!

	cout << "found!" << flush << endl;

	return 1;

}

int avi_convert(char * name)
{
	//on envoi a iris de quoi convertir le fichier name..
   return 0;
}

int delete_file(char * name)
{
	HANDLE hnd;
	LPWIN32_FIND_DATA lpfindata = new WIN32_FIND_DATA;

	cout << "Deleting " ;
	if (hnd=FindFirstFile(name,lpfindata))
 	{
		do
		{
			char * fname = lpfindata->cFileName;
			if (DeleteFile(fname)) cout << "." << flush;
		}
		while (FindNextFile (hnd,lpfindata));
		cout << endl;
	}

   return 0;

}


bool wait_for_enter()
{
	cout << endl << "Intervenez sur Iris puis tapez sur la touche <ENTER>" << endl;
	cout << "Attention a ne pas fermer la fenetre commande";
	if (_bip) cout << BELL << BELL << BELL << BELL << BELL << BELL << endl;

	int res = getchar();
	return true;

}

void send_to_iris(char * cmd)
{
 int i=0;
 while (cmd[i])
 {
 	PostMessage (hwndEdit, WM_CHAR, toascii(cmd[i]),0);
	i++;
 }
}

void wait_for_iris()
{
   
   //char buff[100];
   int i=0;
   /*
   do
   {
      GetWindowText(hwndNotepad,buff,100);
      if ((i%5)==0&&i) cout << "." << flush;
      //else cout << "#" << flush;
      i++;
      mysleep(1);
      
   }
   while (strcmp(buff,previous_command)==0);
   */
   mysleep(0.5);

   cout << endl;
   cout << "sending: " << command << " ";
   
   
   GetWindowText(hwndNotepad,previous_command,100);
}

bool internalCommand(char * buf)
{
	char *c;

	if (c=strstr(buf,"delete"))
	{
		cout << "found delete" << endl;
		c=strchr(buf,'<');
		if (c)
		{
			char * fname=strtok(c,"<>");
			assert(fname);
			delete_file(fname);
		}
		else return false;
		return true;
	}

	if (c=strstr(buf,"aviconvert"))
	{
		cout << "found aviconvert" << endl;
		c=strchr(buf,'<');
		if (c)
		{
			char * fname=strtok(c,"<>");
			assert(fname);
			avi_convert(fname);
		}
		else return false;
		return true;
	}

	if (c=strstr(buf,"wait"))
	{
		cout << "found wait" << endl;
		c=strchr(buf,'<');
		if (c)
		{
			char * fname=strtok(c,"<>");
			assert(fname);
			wait_file(fname);
		}
		else return false;
		return true;
	}
	if (c=strstr(buf,"pause"))
	{
		return wait_for_enter();
	}

	if (c=strstr(buf,"silent"))
	{
		_bip=0;
		return true;
	}

	if (c=strstr(buf,"//"))
	{
		return true;
	}

	return false;
}

void send_file()
{
   //ifstream fichier("script.scr", ios::in);
   ifstream fichier(_param[1], ios::in);
   if (!fichier)
   {
      cerr << "erreur ouverture fichier" << endl;
      exit(1);
   }
   
   char buffer[1024];
   
   while (!fichier.eof())
   {
      fichier.getline(buffer,1024);
      if (strlen(buffer)==0)
      {
         //on attend la fin de la derniere commande et exit
         //strcpy(command,"bg");
         //send_to_iris("bg\n");
         //wait_for_iris();
         exit(0);
      }
      
      char buf[1024]="";
      char bufres[1024]="";
      
      strncpy (buf,buffer,strlen(buffer));
      strcat (buf," ");
      char* c;
      //Any param ?
      
      while (c=strchr(buf,'#'))
      {
         int pos=c-buf;
         int parnum=atoi(&c[1]);
         if (parnum>num_param-2)
         {
            cout << "Parametre N°" << parnum << " non défini !" <<endl;
            exit(1);
         }
         //cout << "buf=" << buf << endl;
         //cout << "found param num" << parnum << "@pos=" << pos << endl;
         bufres[pos]=0;
         strncpy (bufres,buf,pos);
         //cout << "bufres=" << bufres << endl;
         strcat(bufres,_param[parnum+1]);
         strcat(bufres,c+2);
         strncpy (buf,bufres,strlen(bufres));
         //cout << "cmd =" << buf << endl << endl;
      }
      
      if (!internalCommand(buf))
      {
         // on envoi la commande par avance à Iris
         // l'affichage "sending command" se fait lorsqu'on detecte le
         // fin de la commande precedente dans la fenetre d'iris
         strcpy(command,buf);
         send_to_iris(buf);
         send_to_iris("\n");
         wait_for_iris();
      }
   }
}

void main (int argc, char* argv[])
{
 cout << "Scriptis v0.2 - 2001 Xavier Rey-Robert - www.astrosurf.com/xrr" << endl;
 num_param=argc;
 _param=argv;
 if (argc<2)
 {
	cout << "usage: scriptis <fichier.scr> param1 param2 .. param9" << endl;
	exit(1);
 }

 if (strstr(argv[1],"-help"))
 {
	cout << endl << "Commandes internes scriptis:" << endl;
	cout << "pause           - Pause,bip et attente d'une entrée clavier." << endl;
	cout << "wait <fichier> - Attends jusqu'à ce que <fichier> existe." << endl;
	cout << "delete <fichier*> - Supprime <fichier> *? acceptés." << endl;
	cout << "silent - La commande Pause devient silencieuse." << endl;
	cout << endl;
 }

 hwndNotepad=FindWindow(NULL,"Commande - ");
 if (!hwndNotepad) hwndNotepad=FindWindow(NULL,"Commande");

	char * buff = new char(100);

	if (hwndNotepad)
		{
		hwndEdit = FindWindowEx(hwndNotepad,NULL,"Edit",NULL);
		if (hwndEdit)
		{
			int L = Edit_GetLineCount(hwndEdit);
			GetWindowText(hwndNotepad,previous_command,100);
			send_to_iris("\n");
			send_file();

		}
	}
	else cout << "Fenetre Commande d'Iris non trouvee" << endl;
}
