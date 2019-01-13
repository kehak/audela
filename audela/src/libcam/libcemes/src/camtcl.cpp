/* camtcl.c
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

/*
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

/*
#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif*/

//ACRESCENTAMOS TUDO ISTO ATE ...
/*
BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
			AlimsInit();
			ControleurInit();
			break;
		case DLL_THREAD_ATTACH:
			break;
		case DLL_THREAD_DETACH:
			break;
		case DLL_PROCESS_DETACH:
				AlimsStop();
				ControleurStop();
			break;
    }
    return TRUE;
}
*/
//... ATE AQUI

int cmdPeltierMarche(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	int result=TCL_OK;
	char ligne[256];
	
	if (SetPeltier(true)==1) { //true=1-> peltier on
			sprintf(ligne, "Peltier error");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
	}	
	else {
			sprintf(ligne, "Peltier ON\n");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_OK;
	}
	return result;
}

int cmdPeltierArret(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	int result=TCL_OK;
	char ligne[256];
	
	if (SetPeltier(false)==1) { //false=0-> peltier off
			sprintf(ligne, "Peltier error");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
	}	
	else {
			sprintf(ligne, "Peltier OFF\n");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_OK;
	}
	return result;
}

int cmdCemesGetTemp(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	int result=TCL_OK;
	char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;

	unsigned int n;
	double temperature=0;
	
	if (argc!=3)
	{
		sprintf(ligne, "Usage: %s %s (1)\n\n\t\t(1)->Temperature to read:  \n\t\t\t\t0-Peltier\n\t\t\t\t1-Thermal Exchanger\n\t\t\t\t2-Cold Finger\n", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	}
	else
	{
		n=atoi(argv[2]);
		if ((n<0) || (n>2)) 
		{
			sprintf(ligne, "It can only be chosen 0, 1 or 2");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
		}
		else
		{
			GetTemperature(n, &temperature);
			sprintf(ligne, "Temperature (Celsius): %f\n", temperature);
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_OK;
		}
	}
	return result;
}

int cmdCemesSetTemp(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	int result=TCL_OK;
	char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;

	unsigned int Temp;
	unsigned int consigne=0;
	bool ret = false;

	if (argc!=3)
	{
		sprintf(ligne, "Usage: %s %s (1)\n\n\t\t(1)->Temperature to reach:  \n\t\t\t\t0-> -30\n\t\t\t\t1-> -35\n\t\t\t\t2-> -40\n\t\t\t\t3-> -45\n\t\t\t\t4-> -50\n", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	}
	else
	{
		Temp=atoi(argv[2]);
		if ((Temp<0) || (Temp>4)) 
		{
			sprintf(ligne, "It can only be chosen 0, 1, 2, 3 or 4");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
		}
		else
		{
			if (Temp == 0) consigne = 7900;		//-30°C
			if (Temp == 1) consigne = 10250;	//-35°C
			if (Temp == 2) consigne = 13600;	//-40°C
			if (Temp == 3) consigne = 18500;	//-45°C
			if (Temp == 4) consigne = 25500;	//-50°C

			SetPeltierConsigne(consigne);

			if (Temp == 0) sprintf(ligne, "You've chosen -30\n");
			if (Temp == 1) sprintf(ligne, "You've chosen -35\n");
			if (Temp == 2) sprintf(ligne, "You've chosen -40\n");
			if (Temp == 3) sprintf(ligne, "You've chosen -45\n");
			if (Temp == 4) sprintf(ligne, "You've chosen -50\n");

			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_OK;
		}
	}
	return result;
}


int cmdCemesParam(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	char ligne[256];
	int result=TCL_OK;
    struct camprop *cam;
    cam = (struct camprop *) clientData;

	if (argc!=7)
	{
		sprintf(ligne, "Usage: %s %s (1) (2) (3) (4) (5)\n\n\t\t(1)->HV(1-on/0-off)\n\t\t(2)->vitesse(1,2 ou 3)\n\t\t(3)->taillex(0-2048)\n\t\t(4)->tailley(0-2048)\n\t\t(5)->debug(1-on/0-off)\n", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
		return result;
	}
	else
	{
		if ((atoi(argv[2])!=1) && ((atoi(argv[2])!=0)))
		{
			sprintf(ligne, "HV(1-on/0-off)");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
			return result;
		}

		//HAUTE VITESSE (1-ON/0-OFF)
		if (atoi(argv[2])==1)
		{	
			cam->HV=1;

			//VITESSE (1/2/3)
			if ((atoi(argv[3])!=2) && (atoi(argv[3])!=3))  
			{
				cam->vitesse=1; //vitesse 1
			}
			else{
				cam->vitesse=atoi(argv[3]); //vitesse 2 ou 3
			}
		}
		else
		{
			cam->HV=0;
		}
		
		//TAILLEX (0-2048)
		if ((atoi(argv[4])<0) || (atoi(argv[4])>2048))
		{
			sprintf(ligne, "taillex(0-2048)");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
			return result;
		}
		cam->nb_photox=atoi(argv[4]);

		//TAILLEY (0-2048)
		if ((atoi(argv[5])<0) || (atoi(argv[5])>2048))
		{
			sprintf(ligne, "tailley(0-2048)");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
			return result;
		}
		cam->nb_photoy=atoi(argv[5]);

		//DEBUG (1-ON/0-OFF)
		if ((atoi(argv[6])!=0) && (atoi(argv[6])!=1))
		{
			sprintf(ligne, "debug(1-on/0-off)");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
			return result;
		}
		cam->debug=atoi(argv[6]);
	}
	
	sprintf(ligne, "The following parameters have been selected: \n\n\t\tHV=%d\n\t\tVitesse=%d\n\t\tTaillex=%d\n\t\tTailley=%d\n\t\tDebug=%d\n", cam->HV, cam->vitesse, cam->nb_photox, cam->nb_photoy, cam->debug);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);

	return result;
}

int cmdCemesObtu(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	char ligne[256];
	int result=TCL_OK;
    struct camprop *cam;
    cam = (struct camprop *) clientData;

	if (argc!=7)
	{
		sprintf(ligne, "Usage: %s %s (1) (2) (3) (4) (5)\n\n\t\t(1)->Ampli(0-AUTO/1-MAN)\n\t\t(2)->Obtu(0-AUTO/1-MAN)\n\t\t(3)->Ampli(0-Off, 1-On)\n\t\t(4)->Obtu(0-Off, 1-On)\n\t\t(5)->Obtu Mode(0-Astro, 1-Detector, 2-Imag)\n", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
		return result;
	}
	else
	{
		//AMPLIFICATEUR (0-AUTO/1-MAN)
		if ((atoi(argv[2])!=1) && ((atoi(argv[2])!=0)))
		{
			sprintf(ligne, "Ampli(0-AUTO/1-MAN)");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
			return result;
		}
		
		//OBTURATEUR (0-AUTO/1-MAN)
		if ((atoi(argv[3])!=1) && ((atoi(argv[3])!=0)))
		{
			sprintf(ligne, "Obtu(0-AUTO/1-MAN)");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
			return result;
		}

		//AMPLIFICATEUR (0-OFF/1-ON)
		if ((atoi(argv[4])!=1) && ((atoi(argv[4])!=0)))
		{
			sprintf(ligne, "Ampli(0-Off/1-On)");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
			return result;
		}

		//OBTURATEUR (0-OFF/1-ON)
		if ((atoi(argv[5])!=1) && ((atoi(argv[5])!=0)))
		{
			sprintf(ligne, "Obtu(0-Off/1-On)");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
			return result;
		}
		
		//MODE OBTURATEUR (0-ASTRO/1-DETECTEUR/2-IMAGEUR)
		if ((atoi(argv[6])!=2) && (atoi(argv[6])!=1) && ((atoi(argv[6])!=0)))
		{
			sprintf(ligne, "Obtu Mode(0-Astro, 1-Detector, 2-Imag)");
			Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			result = TCL_ERROR;
			return result;
		}

		//PARAMETRAGE
		cam->ampliautoman=atoi(argv[2]);
		cam->obtuautoman=atoi(argv[3]);
		cam->amplionoff=atoi(argv[4]);
		cam->obtuonoff=atoi(argv[5]);
		cam->obtumode=atoi(argv[6]);

		sprintf(ligne, "The following parameters have been selected: \n\n\t\tAmpli(0-AUTO/1-MAN)=%d\n\t\tObtu(0-AUTO/1-MAN)=%d\n\t\tAmpli(0-Off/1-On)=%d\n\t\tObtu(0-Off/1-On)=%d\n\t\tObtu Mode(0-Astro, 1-Detector, 2-Imag)=%d\n", cam->ampliautoman, cam->obtuautoman, cam->amplionoff, cam->obtuonoff, cam->obtumode);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	}
	return result;
}

int cmdStatique_dinamique(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	int result=TCL_OK;
	char ligne[256];
	
	if (argc!=3)
	{
		sprintf(ligne, "Usage: %s %s 0=static/1=dynamic\n", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
		return result;
	}
	else
	{
		if (atoi(argv[2])==0) 
		{
			//statique
			SetConfCalcul(2);
		}
		else 
		{
			//dinamique
			SetConfCalcul(5);
		}
	}

	return result;
}

int cmdBalance(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	int result=TCL_OK;
	char ligne[256];
	
	if (argc!=3)
	{
		sprintf(ligne, "Usage: %s %s 0=static (non binning)/1=dynamic (non binning)/2=static (binning)/3=dynamic (binning)\n", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
		return result;
	}
	else
	{
		if (atoi(argv[2])==0) 
		{
			//statique
			equilibrer(0);
		}
		if (atoi(argv[2])==1) 
		{
			//dinamique
			equilibrer(1);
		}
		if (atoi(argv[2])==2) 
		{
			//statique avec binning
			equilibrer(2);
		}
		if (atoi(argv[2])==3) 
		{
			//dinamique avec binning
			equilibrer(3);
		}
	}

	return result;
}

int cmdSetwindow(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	int result=TCL_OK;
	/*char ligne[256];
	
	if (argc!=4)
	{
		sprintf(ligne, "Usage: %s %s (1) (2)\n\n\t\t(1)->X size (0-2048)\n\t\t(2)->Y size (0-2048)", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
		return result;
	}
	else
	{
		SetArea((16/cam->binx),(16/cam->biny),10000,10000);
	}
*/
	return result;
}

int cmdRESET(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	int result=TCL_OK;
	char ligne[256];
	int iteration = 0;
	int com=1;
	int	progOK=0;
	
	if (argc!=2)
	{
		sprintf(ligne, "Usage: %s %s", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
		return result;
	}
	else
	{
		ResetADLINK();
		while((com==1)&&(iteration<10)) 	
		{
			com = SetDECALAGE(20, 2000);
			iteration++;
		}
		if(com!=1) 
		{
			progOK = SerialDownload();
			if(progOK == 0) 
			{
				SetDebugLevel(0);
				Initialise(1);
				sprintf(ligne, "Reset successful");
				Tcl_SetResult(interp, ligne, TCL_VOLATILE);
			}
		}
	}
	return result;
}

/*
int cmdBALANCEAUTO(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	int result=TCL_OK;
	char ligne[256];
	struct camprop *cam;
    cam = (struct camprop *) clientData;
	
	char *exemplo;
	*exemplo=1;


	if (argc!=2)
	{
		sprintf(ligne, "Usage: %s %s 0=static/1=dynamic\n", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
		return result;
	}
	else
	{
		SetConfCalcul(2);
		cam_start_exp(cam,exemplo);
		equilibrer(0);
	}

	return result;
}
*/