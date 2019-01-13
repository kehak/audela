/**
 * porttalk_interface.cpp
 *
 *    utilitaire pour autoriser l'acces aux ports paralleles et serie 
 *    sous WINDOWS NT, 2000 , XP 
 *    via le driver PortTalk ( voir http://www.beyondlogic.org)
 *
 * Mise a jour : 25/02/2004
 *
 *    OpenPortTalk()  : ouvre l'acces aux ports pour le process courant.
 *        Si le driver n'est pas installe, copie le fichier ../bin/porttalk.sys dans le repertoire des drivers systeme
 *        et demarre le service PortTalk
 *
 *    ClosePortTalk() : ferme l'acces aux ports pour le process courant
 *
 *    GrantPort() : ouvre l'acces à un port supplémentaire 
 */

#include "sysexp.h"

/* ================================================================ */
/* ===     Pour WINDOWS uniquement                              === */
/* ================================================================ */
#if defined(OS_WIN)
/* ================================================================ */



#include <stdio.h>			   // pour sprintf 
#include <windows.h>
#include <winioctl.h>
#include <porttalk_ioctl.h>
#include "porttalk_interface.h"

HANDLE PortTalk_Handle = NULL;         // Handle for PortTalk Driver */
int    winnt ;                         // is WinNT, Win2000, WinXP  

/** 
 * getFileVersion
 *   gets the file version info structure
 */
int getFileVersion (char *filename, VS_FIXEDFILEINFO *pvsf) {
   DWORD dwHandle;
   char* pver;
   DWORD cchver;
   BOOL bret;
   UINT uLen;
   void *pbuf;
   
      
   cchver = GetFileVersionInfoSize(filename,&dwHandle);
   if (cchver == 0) return GetLastError();
   pver = (char *) calloc(cchver,sizeof(char));
   bret = GetFileVersionInfo(filename,dwHandle,cchver,pver);
   if (!bret) return GetLastError();
   bret = VerQueryValue(pver,"\\",&pbuf,&uLen);
   if (!bret) return GetLastError();
   memcpy(pvsf,pbuf,sizeof(VS_FIXEDFILEINFO));
   free( pver);
   return 0;
}

/** 
 * getFileDate
 *   gets the create time of file
 *   we are interested only in the create time
 *   this is the equiv of "modified time" in the 
 *   Windows Explorer properties dialog
 */
int getFileDate (char *filename, FILETIME *pft) {
   FILETIME ct,lat;
   BOOL bret;

   HANDLE hFile = CreateFile(filename,GENERIC_READ,FILE_SHARE_READ | FILE_SHARE_WRITE,0,OPEN_EXISTING,0,0);
   if (hFile == INVALID_HANDLE_VALUE) return GetLastError();
   bret = GetFileTime(hFile,&ct,&lat,pft);
   if (bret == 0)  return GetLastError();
   return 0;
}

/** 
 * makeVersionString
 *   converts Major and Minor file version into string
 */
void makeVersionString (DWORD dwFileVersionMS, DWORD dwFileVersionLS, char * result)
{
  
  sprintf(result, "%u.%u.%u.%u",
	      HIWORD(dwFileVersionMS),
	      LOWORD(dwFileVersionMS),
	      HIWORD(dwFileVersionLS),
	      LOWORD(dwFileVersionLS));
  return;
}

/** 
 * makeDateString
 *   converts FILETIME struct into string
 */
void makeDateString (FILETIME *ft, char * result) {

   FILETIME lft;
   SYSTEMTIME stCreate;

   FileTimeToLocalFileTime(ft,&lft);
   FileTimeToSystemTime(ft,&stCreate);
    sprintf(result,"%02d/%02d/%d  %02d:%02d:%02d",
      stCreate.wDay, stCreate.wMonth, stCreate.wYear,
      stCreate.wHour, stCreate.wMinute, stCreate.wSecond);
   return;
}


/** 
 * checkFileVersion
 *   check file version of file >= (referenceVersionMS,referenceVersionLS)
 */
unsigned char checkFileVersion( char * fileName, DWORD referenceVersionMS, DWORD referenceVersionLS, char * resultMessage  ) {


   VS_FIXEDFILEINFO fixedFileInfo;
   char sfileVersion[80];
	DWORD res;
   char sreferenceVersion[80];



      // Retreive file version 
      res = getFileVersion(fileName, &fixedFileInfo);
      if( res == -1 ) {
         sprintf(resultMessage,"PortTalk: Error getFileVersion: file=%s error=%ld \n ",fileName, res );
         return -1 ;
      }

      // verify the file version
      if ( fixedFileInfo.dwFileVersionMS >=  referenceVersionMS ) {
         if (fixedFileInfo.dwFileVersionLS >=  referenceVersionLS ) {
            res = 0;
         } else { 
            res = -1;
         }
      } else { 
            res = -1;
      }
      
      if( res == -1) {
         makeVersionString(fixedFileInfo.dwFileVersionMS,fixedFileInfo.dwFileVersionLS ,sfileVersion);
         makeVersionString(referenceVersionMS,referenceVersionLS ,sreferenceVersion);
         sprintf(resultMessage,"PortTalk: bad version of %s ( current version: %s, version required: %s)", fileName, sfileVersion, sreferenceVersion);
         return -1;
      }

   return 0;
}



unsigned char InstallPortTalkDriver(char * inputDirectory, char * resultMessage)
{
    SC_HANDLE  SchSCManager;
    SC_HANDLE  schService;
    DWORD      err;
    CHAR         driverFileName[80];

    /* Get Current Directory. Assumes PortTalk.SYS driver is in this directory.    */
    /* Doesn't detect if file exists, nor if file is on removable media - if this  */
    /* is the case then when windows next boots, the driver will fail to load and  */
    /* a error entry is made in the event viewer to reflect this */

    /* Get System Directory. This should be something like c:\windows\system32 or  */
    /* c:\winnt\system32 with a Maximum Character lenght of 20. As we have a       */
    /* buffer of 80 bytes and a string of 24 bytes to append, we can go for a max  */
    /* of 55 bytes */

    if (!GetSystemDirectory(driverFileName, 55))
        {
         sprintf(resultMessage,"PortTalk: Failed to get System Directory. Is System Directory Path > 55 Characters?");
         return -1;
        }

    /* Append our Driver Name */
    lstrcat(driverFileName,"\\Drivers\\PortTalk.sys");
    sprintf(resultMessage,"PortTalk: Copying driver to %s",driverFileName);

    /* Copy Driver to System32/drivers directory. This fails if the file doesn't exist. */

    char inputFileName [1024];
    strcpy(inputFileName,inputDirectory);
    for(unsigned int c=0;c<strlen(inputFileName); c++){
       if(inputFileName[c]=='/'){
          inputFileName[c]='\\';
       }
    }
    if(inputFileName[strlen(inputFileName)-1]!='\\'){
       strcat(inputFileName,"\\");
    }
    strcat(inputFileName,"PortTalk.sys");
    if (!CopyFile(inputFileName, driverFileName, FALSE))
        {
         sprintf(resultMessage,"PortTalk: Failed to copy driver to %s . Please manually copy driver to your system32/driver directory.",driverFileName);
        }

    /* Open Handle to Service Control Manager */
    SchSCManager = OpenSCManager (NULL,                   /* machine (NULL == local) */
                                  NULL,                   /* database (NULL == default) */
                                  SC_MANAGER_ALL_ACCESS); /* access required */

    /* Create Service/Driver - This adds the appropriate registry keys in */
    /* HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services - It doesn't  */
    /* care if the driver exists, or if the path is correct.              */

    schService = CreateService (SchSCManager,                      /* SCManager database */
                                "PortTalk",                        /* name of service */
                                "PortTalk",                        /* name to display */
                                SERVICE_ALL_ACCESS,                /* desired access */
                                SERVICE_KERNEL_DRIVER,             /* service type */
                                SERVICE_DEMAND_START,              /* start type */
                                SERVICE_ERROR_NORMAL,              /* error control type */
                                "System32\\Drivers\\PortTalk.sys", /* service's binary */
                                NULL,                              /* no load ordering group */
                                NULL,                              /* no tag identifier */
                                NULL,                              /* no dependencies */
                                NULL,                              /* LocalSystem account */
                                NULL                               /* no password */
                                );

    if (schService == NULL) {
         err = GetLastError();
         if (err == ERROR_SERVICE_EXISTS)
               sprintf(resultMessage,"PortTalk: Driver already exists. No action taken.");
         else  
            sprintf(resultMessage,"PortTalk: Unknown error while creating Service.");    
    }
    else 
       sprintf(resultMessage,"PortTalk: Driver successfully installed.");

    /* Close Handle to Service Control Manager */
    CloseServiceHandle (schService);
   return 0;

}


unsigned char StartPortTalkDriver(char * inputDirectory, char * resultMessage )
{
    SC_HANDLE  SchSCManager  = NULL;
    SC_HANDLE  schService = NULL;
    BOOL       ret;
    DWORD      err;
    int        nbTry;

    /* Open Handle to Service Control Manager */
    SchSCManager = OpenSCManager (NULL,                        /* machine (NULL == local) */
                                  NULL,                        /* database (NULL == default) */
                                  SC_MANAGER_ALL_ACCESS);      /* access required */
                         
    if (SchSCManager == NULL)
      if (GetLastError() == ERROR_ACCESS_DENIED) {
         /* We do not have enough rights to open the SCM, therefore we must */
         /* be a poor user with only user rights. */
         sprintf(resultMessage,"PortTalk: You do not have rights to access the Service Control Manager and ");
         strcat(resultMessage,"the PortTalk driver is not installed or started. ");
         strcat(resultMessage,"Please ask your administrator to install the driver on your behalf.");
         return(-1);
      }

      for ( nbTry=0  ; nbTry<5 && (schService == NULL); nbTry++ ) {
         /* Open a Handle to the PortTalk Service Database */
         schService = OpenService(SchSCManager,         /* handle to service control manager database */
                                  "PortTalk",           /* pointer to name of service to start */
                                  SERVICE_ALL_ACCESS);  /* type of access to service */

         if (schService == NULL) {
            err = GetLastError();
            switch (err) {
               case ERROR_ACCESS_DENIED:
                  sprintf(resultMessage,"PortTalk: You do not have rights to the PortTalk service database");
                  return(-1);
                  break;
               case ERROR_INVALID_NAME:
                  sprintf(resultMessage,"PortTalk: The specified service name is invalid.");
                  return(-1);
                  break;
               case ERROR_SERVICE_DOES_NOT_EXIST:
                  InstallPortTalkDriver(inputDirectory, resultMessage);
                  break;
               case ERROR_ALREADY_EXISTS:
                  InstallPortTalkDriver(inputDirectory, resultMessage);
                  break;
               default:
                  sprintf(resultMessage,"PortTalk: OpenService PortTalk error=%ld.",err);
                  return(-1);
     
            }
         }
      } 

    // Start the PortTalk Driver. Errors will occur here if PortTalk.SYS file doesn't exist   
    ret = StartService (schService,    /* service identifier */
                        0,             /* number of arguments */
                        NULL);         /* pointer to arguments */
                    
    if (ret) sprintf(resultMessage,"PortTalk: The PortTalk driver has been successfully started.");
    else {
        err = GetLastError();
        if (err == ERROR_SERVICE_ALREADY_RUNNING)
          sprintf(resultMessage,"PortTalk: The PortTalk driver is already running.");
        else {
          sprintf(resultMessage,"PortTalk: Unknown error while starting PortTalk driver service. ");
          strcat(resultMessage,"Does PortTalk.SYS exist in your \\System32\\Drivers Directory?");
          return(-1);
        }
    }

    /* Close handle to Service Control Manager */
    CloseServiceHandle (schService);

    return(0);
}

/** 
 * GrantPort
 *    ouvre l'access pour un port supplementaire 
 */

unsigned  char GrantPort( char *port, char * inputDirectory, char * resultMessage  )
{
    
   DWORD BytesReturned;        
   unsigned int error;
   int value;
   int offset;

   OSVERSIONINFO OSVersionInfo;
   OSVersionInfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
   GetVersionEx(&OSVersionInfo);

   if( OSVersionInfo.dwPlatformId == VER_PLATFORM_WIN32_NT ) {
      winnt = 1;
   }
   else {
      winnt = 0;
   }


   if( winnt == 1 ) {

      if( PortTalk_Handle == NULL ) {
         error = OpenPortTalk(0, 0, inputDirectory, resultMessage);
         if( error != 0 ) {
            return -1;
         }
      }


         if (port[0] == '0' && port[1] =='x') {
                sscanf(port,"%x", &value);
                offset = value / 8;
                
                error = DeviceIoControl(PortTalk_Handle,
                                        IOCTL_SET_IOPM,
                                        &offset,
                                        3,    
                                        NULL,
                                        0,
                                        &BytesReturned,
                                        NULL);
               if (!error) {
                  sprintf(resultMessage,"Error %d granting access to Address 0x%03X",GetLastError(),value);                
                  return -1;
               } else {
                  sprintf(resultMessage,"Granting access to 0x%03X",value);                
               }
         } else {
            sprintf(resultMessage,"Error granting access to address %s",port);
            return -1;
         }

   }
	return 0;
}


/** 
 * ClosePortTalk
 *    ferme l'acces du process courant aux port 
 */
void ClosePortTalk(void) {
    CloseHandle(PortTalk_Handle);
}


/** 
 * OpenPortTalk
 *   autorise le programme a acceder aux port paralleles ou serie via le driver porttalk.sys
 * params :
 *   argc :  nombre de valeurs dans argv
 *   argv :  tableau des adresses des ports a autoriser (valeur hexadecimale sous forme de chaine de caractere)
 *      exemple 1 : { "0x278", "0x03F8", "0x02F8" } autorise l'acces a l'adresses des ports LPT1, COM1 et COM2
 *      exemple 2 : { "all" } autorise l'acces aux adresses de tous les ports
 *   resultMessage : message de retour (taille minimale = 256 octects)
 *
 * return 0 si OK, -1 si erreur
 */
unsigned  char OpenPortTalk( int argc, char ** argv, char * inputDirectory, char * resultMessage )
{
    
   DWORD pid;
   DWORD BytesReturned;        
   unsigned int error;
   int count;                /* Temp Variable to process Auguments */
   int value;
   int offset;
   char stemp[256];
   char driverFileName[80];

   OSVERSIONINFO OSVersionInfo;
   OSVersionInfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
   GetVersionEx(&OSVersionInfo);

   if( OSVersionInfo.dwPlatformId == VER_PLATFORM_WIN32_NT ) {
      winnt = 1;
   }
   else {
      winnt = 0;
   }

   if( winnt == 1 ) {

      // Open PortTalk Driver. If we cannot open it, try installing and starting it 
      PortTalk_Handle = CreateFile("\\\\.\\PortTalk", 
                                 GENERIC_READ, 
                                 0, 
                                 NULL,
                                 OPEN_EXISTING, 
                                 FILE_ATTRIBUTE_NORMAL, 
                                 NULL);

      if(PortTalk_Handle == INVALID_HANDLE_VALUE) {
            // Start or Install PortTalk Driver 
            error = StartPortTalkDriver(inputDirectory, resultMessage);
            // Then try to open once more, before failing 
            if( error == 0 ) {
               PortTalk_Handle = CreateFile("\\\\.\\PortTalk", 
                                         GENERIC_READ, 
                                         0, 
                                         NULL,
                                         OPEN_EXISTING, 
                                         FILE_ATTRIBUTE_NORMAL, 
                                         NULL);
               
               if(PortTalk_Handle == INVALID_HANDLE_VALUE) {
                  sprintf(resultMessage, "PortTalk: Couldn't access PortTalk Driver, Please ensure driver is loaded.");
                  return -1;
               }
            } else {
               return -1;
            }
      }


      // retreive system directory (ex:  "c:\\winnt\\system32" )
      if (!GetSystemDirectory(driverFileName, 55)) {
         sprintf(resultMessage,"PortTalk: Failed to get System Directory. Is System Directory Path > 55 Characters?");
         return -1;
      }

      // Append our Driver Name 
      lstrcat(driverFileName,"\\Drivers\\PortTalk.sys");
      
      // check file version (current version  >= 5.0.2195.1620 )
      error = checkFileVersion( driverFileName, MAKELONG( 0, 5 ), MAKELONG( 1620, 2195 ), resultMessage);
      if( error != 0 ) {
         return -1;
      }


      error = DeviceIoControl(PortTalk_Handle,
                            IOCTL_IOPM_RESTRICT_ALL_ACCESS,   
                            NULL,
                            0,    
                            NULL,
                            0,
                            &BytesReturned,
                            NULL);
      if (!error) {
         sprintf(resultMessage,"Error occured DeviceIoControl IOCTL_IOPM_RESTRICT_ALL_ACCESS  %d",GetLastError());
         return -1 ;
      }

      strcpy(resultMessage, "Granting exclusive access to  ");
      for (count = 0; count < argc; count++) { 
         // If argument starts with '0x' 
         if (argv[count][0] == '0' && argv[count][1] =='x') {
                sscanf(argv[count],"%x", &value);
                offset = value / 8;
                
                error = DeviceIoControl(PortTalk_Handle,
                                        IOCTL_SET_IOPM,
                                        &offset,
                                        3,    
                                        NULL,
                                        0,
                                        &BytesReturned,
                                        NULL);
               if (!error) {
                  sprintf(resultMessage,"Error %d granting access to Address 0x%03X",GetLastError(),value);                
                  return -1;
               } else {
                  sprintf(stemp, "0x%03X ",value);
                  strcat(resultMessage, stemp);
               }
         } else if ( strcmp( argv[count], "all") == 0) {
            //  if arg is "all" then set Entire IOPM 
            printf("Granting exclusive access to all I/O Ports");
            error = DeviceIoControl(PortTalk_Handle,
                                        IOCTL_IOPM_ALLOW_EXCUSIVE_ACCESS,
                                        NULL,
                                        0,    
                                        NULL,
                                        0,
                                        &BytesReturned,
                                        NULL);

            if (!error) {
               sprintf(resultMessage,"Error %d granting exclusive access to all I/O Ports",GetLastError());
               return -1;
            } else {
               sprintf(resultMessage, "Granting exclusive access to all I/O Ports");
            }

         } else {
            sprintf(resultMessage,"Error Invalid port address %s",argv[count]);
            return -1;
         }
      }


      // allows granted access to the current process
      pid= (DWORD) GetCurrentProcessId();
       
      error = DeviceIoControl(PortTalk_Handle,
                            IOCTL_ENABLE_IOPM_ON_PROCESSID,
                            &pid,
                            4,
                            NULL,
                            0,
                            &BytesReturned,
                            NULL);
      if (!error) {
         sprintf(resultMessage,"Error occured DeviceIoControl IOCTL_ENABLE_IOPM_ON_PROCESSID  %d",GetLastError());
         return -1;
      }

   }
	return 0;
}


/* ================================================================ */
/* ===     Pour WINDOWS uniquement                              === */
/* ================================================================ */
#endif
/* ================================================================ */
