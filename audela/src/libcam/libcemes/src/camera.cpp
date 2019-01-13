/* camera.c
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

/*#define READSLOW*/
#define READOPTIC

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#if defined(OS_LIN)
#include <unistd.h>    
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>    
#include <stdio.h>
#include <math.h>



#include <libcam/util.h>
#include "camera.h"
unsigned int mean1, mean2, mean3, mean4, mean5, mean6, mean7, mean8;


/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"Cemes",			/* camera name */
     "cemes",        /* camera product */
     "THX7899M",			/* ccd name */
     2048, 2048,			/* maxx maxy */
     0, 0,			/* overscans x??? */
     0, 0,			/* overscans y??? */
     14e-6, 14e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation??? */
     1.,			/* filling factor */
     2.,			/* gain (e/adu)??? */
     11.,			/* readnoise (e)??? */
     2, 2,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    CAM_INI_NULL
};

static int cam_init(struct camprop *cam, int argc, const char **argv);
static int cam_close(struct camprop * cam);
static void cam_start_exp(struct camprop *cam, const char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, float *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
static void cam_ampli_on(struct camprop *cam);
static void cam_ampli_off(struct camprop *cam);
static void cam_measure_temperature(struct camprop *cam);
static void cam_cooler_on(struct camprop *cam);
static void cam_cooler_off(struct camprop *cam);
static void cam_cooler_check(struct camprop *cam);
static void cam_set_binning(int binx, int biny, struct camprop *cam);
static void cam_update_window(struct camprop *cam);

struct cam_drv_t CAM_DRV = {
    cam_init,
	cam_close,
    cam_set_binning,
    cam_update_window,
    cam_start_exp,
    cam_stop_exp,
    cam_read_ccd,
    cam_shutter_on,
    cam_shutter_off,
    cam_ampli_on,
    cam_ampli_off,
    cam_measure_temperature,
    cam_cooler_on,
    cam_cooler_off,
    cam_cooler_check
};

CAlims *calim;
Ccontroleur *control;

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int cam_init(struct camprop *cam, int argc, const char **argv)
/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
{
	unsigned int error;

	mean1=0;
	mean2=0;
	mean3=0;
	mean4=0;
	mean5=0;
	mean6=0;
	mean7=0;
	mean8=0;

	cam->status=0; 

	//CamInit();
 	ControleurInit();	
	AlimsInit();	

	//Mise en marche
	error=SetBasseTension(1);	
	if (error==1) {
	    sprintf(cam->msg,"SetBasseTension returns %d",error);
  	    cam->status=1;
    	return 1;
	}
	Sleep(1000);
	error=SerialDownload();	
	if (error==1) {
	    sprintf(cam->msg,"SerialDownload returns %d",error);
  	    cam->status=2;
    	return 2;
	}

	control->Initialise(1);
	
	return 0;
}

int cam_close(struct camprop * cam)
{
	unsigned int error;

	error=Stop(0);   
	if (error==1) {
	    sprintf(cam->msg,"Stop returns %d",error);
  	    cam->status=4;
    	return 3;
	}

	AlimsStop();		
	ControleurStop();

    return 0;
}

void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
	
	//BINNING (pour HR mode)
	//0: binning=1x1
	//1: binning=2x2
	//2: binning=4x4
	//3: binning=8x8

	//VITESSE:
	//1: HV3 -> binning=2x2
	//2: HV2 -> binning=4x4
	//3: HV1 -> binning=8x8
	//Default-> binning=2x2

	double expos;		//temps de pose
	unsigned int error,erreur,binning;
	unsigned int obtu=0;
	unsigned int automan=0;
	//unsigned int numerodeimagens; ////////////////////////////////////////////
	//numerodeimagens=cam->nb_images; //////////////////////////////////////


	SetDebugLevel(0);

	cam->status=0;
	
	if (cam->binx==1)		
		binning=0;			
	if (cam->binx==2)		
		binning=1;			
	if (cam->binx==4)		
		binning=2;			
	if (cam->binx==8)		
		binning=3;			

	//set binning mode
	error=SetModeBinning(cam->HV, binning, cam->vitesse, cam->debug); 
	if (error==1) {
	    sprintf(cam->msg,"SetModeBinning returns %d",error);
  	    cam->status=5;
    	return ;
	}
	
	cam_update_window(cam);
	
	error=SetModeTension(cam->HV, binning);
	if (error==1) {
		sprintf(cam->msg,"SetModeTension returns %d",error);
  		cam->status=6;
    	return ;
	}

	//set exposure time
	erreur=SetTempsExposition(cam->exptime, &error);
	if (error==1 || erreur==1) {
	    sprintf(cam->msg,"SetTempsExposition returns %d",error);
  	    cam->status=7;
    	return ;
	}

	erreur=GetTempsExposition(&expos, &error);		//Pour verifier le SetTempsExposition
	if (error==1 || erreur==1) {
	    sprintf(cam->msg,"GetTempsExposition returns %d",error);
  	    cam->status=8;
    	return ;
	}

	error=SetArea((16/cam->binx),(16/cam->binx),10000,10000);	 //Regler la taille de l'image
	if (error==1) {
	    sprintf(cam->msg,"SetArea returns %d",error);
  	    cam->status=9;
    	return ;
	}	
	
	if (cam->shutterindex==0) {
		automan=1;		//obturateur manuel 
		obtu=0;			//obturateur ferme
	}
	if (cam->shutterindex==1) {
		automan=0;		//obturateur auto 	
	}
	if (cam->shutterindex==2) {
		automan=1;		//obturateur manuel 
		obtu=1;			//obturateur ouvert
	}

	//Regler les parameters d'amplificateur et d'obturateur

	error=SetAmplisObtu(cam->ampliautoman,automan,cam->amplionoff,obtu,cam->obtumode);
	if (error==1) {
	    sprintf(cam->msg,"SetAmplisObtu returns %d",error);
  	    cam->status=10;
    	return ;
	}			
	
	error=Stop(1);
	if (error==1) {
	    sprintf(cam->msg,"Stop returns %d",error);
  	    cam->status=11;
    	return ;
	}

	error=Start();
	if (error==1) {
	    sprintf(cam->msg,"Start returns %d",error);
  	    cam->status=12;
    	return ;
	}
}

void cam_stop_exp(struct camprop *cam)
{
	unsigned int error;
	
	error=Abort(0);
	if (error!=0) {
	    sprintf(cam->msg,"Abort returns %d",error);
  	    cam->status=13;
	}
}


void cam_read_ccd(struct camprop *cam, float *p)
{
	bool full = false;
	unsigned short *sdata=NULL;
	unsigned short *sdata1=NULL;
	unsigned int k, tailletotal;		//tailletotal c'est le numero de pixels de l'image	
	unsigned int slice=0;
	bool fin_image=0;			
	int nb_image;				
	int nbimages=0;
	unsigned long size = 0;
	unsigned int taille=((cam->nb_photox)/(cam->binx))*((cam->nb_photoy)/(cam->biny))*sizeof(unsigned short);	//cam->nb_photox=2048
	sdata=(unsigned short *)malloc(taille);
	sdata1=(unsigned short *)malloc(taille);
	unsigned short val;
	//unsigned int somamedia,moyennetotal,moyenne1voie,ecarttype;
	unsigned int i,j,error;
	unsigned int somadesvio=0;
	unsigned long sum=0;
	unsigned int equilibrer=1;
	unsigned int counter_ms;  ///////

	if (cam->status!=0) {
		return;
	}

	counter_ms=0;
	//Dans ce boucle on attend la fin de la lecture de l'image
	while((size == 0) && (counter_ms!=(1200+1000*cam->exptime))){ 
		size = control->GetNextImage(sdata,0,&fin_image, &nb_image);  //((unsigned char *)sdata,0,&fin_image, &nb_image);	
		Sleep(1);
		counter_ms++;
	}
	size=0;
	
	counter_ms=0;
	//Dans ce boucle on attend la fin de la lecture d'une image de 2048x2048
	if (cam->binx==1)
	{
		while(((size == 0) && (!fin_image)) && (counter_ms!=(1000))){			
			size = control->GetNextImage(sdata1,0,&fin_image, &nb_image);	//((unsigned char *)sdata1,0,&fin_image, &nb_image);
			Sleep(1);
			counter_ms++;
		}
	}
	
	error=Stop(1);
	if (error==1) {
	    sprintf(cam->msg,"Stop returns %d",error);
  	    cam->status=14;
    	return ;
	}
	
	size=0;

	tailletotal=(cam->nb_photox/cam->binx)*(cam->nb_photoy/cam->biny);

	//Dans ce boucle on rempli le pointeur *p avec l'image capturée

	for (k=0;k<tailletotal;k++)	
	{
		val=sdata[k];  //na primeira volta sdata nao tem nada
		p[k] = val;	
	}

	if (cam->binx==1)
	{	
		//Dans ce boucle on rempli le pointeur *p avec l'image 2048x2048 capturée	
		for (k=tailletotal/4;k<(tailletotal*0.75);k++)
		{
			val=sdata1[k];
			p[k] = val;	
		}

		//REGLAGE DES 4 VOIES NON BINNING
		//FIRST SQUARE
		for (i=256;i<768;i++)
		{
			for (j=256;j<768;j++)	
			{
				sum=(unsigned long)p[2048*i+j]+sum;
			}
		}
		mean1=sum/(tailletotal/16);

		//SECOND SQUARE
		sum = 0;
		for (i=256;i<768;i++)
		{
			for (j=256;j<768;j++)	
			{
				sum=(unsigned long)p[2048*i+1024+j]+sum;
			}
		}
		mean2=sum/(tailletotal/16);

		//THIRD SQUARE
		sum = 0;
		for (i=256;i<768;i++)
		{
			for (j=256;j<768;j++)	
			{
				sum=(unsigned long)p[2048*i+(tailletotal/2)+j]+sum;
			}
		}
		mean3=sum/(tailletotal/16);

		//FOURTH SQUARE
		sum = 0;
		for (i=256;i<768;i++)
		{
			for (j=256;j<768;j++)	
			{
				sum=(unsigned long)p[2048*i+(tailletotal/2)+1024+j]+sum;
			}
		}
		mean4=sum/(tailletotal/16);		//NOW WE'VE GOT THE MEANS IN NON BINNING MODE!

/*
		//Calculer la moyenne des 4 voies 
		somamedia=0;
		for (i=0;i<tailletotal;i++)
		{
			somamedia=somamedia+p[i];
		}

		moyennetotal=somamedia/tailletotal;

		//Calculer la moyenne de la premiere voie
		somamedia=0;
		for (i=0;i<1024;i++)
		{
			for (j=0;j<1024;j++)
			{
				somamedia=somamedia+p[i*2048+j];
			}
		}

		moyenne1voie=somamedia/(tailletotal/4);

		//Calculer l'ecart type
		for (i=0;i<tailletotal;i++)
		{
			somadesvio=somadesvio+((p[i]-moyennetotal)*(p[i]-moyennetotal));
		}
		ecarttype=somadesvio/tailletotal;
		//ecarttype=sqrt(ecarttype);
*/
	}
	else
	{		
		//REGLAGE DES 4 VOIES BINNING
		//FIRST SQUARE
		for (i=(unsigned int)(256/cam->binx);i<(unsigned int)(768/cam->binx);i++)
		{
			for (j=(unsigned int)(256/cam->binx);j<(unsigned int)(768/cam->binx);j++)	
			{
				sum=(unsigned long)p[2048/(cam->binx)*i+j]+sum;
			}
		}
		mean5=sum/(tailletotal/(16/cam->binx));

		//SECOND SQUARE
		sum = 0;
		for (i=(unsigned int)(256/cam->binx);i<(unsigned int)(768/cam->binx);i++)
		{
			for (j=(unsigned int)(256/cam->binx);j<(unsigned int)(768/cam->binx);j++)	
			{
				sum=(unsigned long)p[2048/(cam->binx)*i+(1024/(cam->binx))+j]+sum;
			}
		}
		mean6=sum/(tailletotal/(16/cam->binx));

		//THIRD SQUARE
		sum = 0;
		for (i=(unsigned int)(256/cam->binx);i<(unsigned int)(768/cam->binx);i++)
		{
			for (j=(unsigned int)(256/cam->binx);j<(unsigned int)(768/cam->binx);j++)
			{
				sum=(unsigned long)p[2048/(cam->binx)*i+((tailletotal/2)/cam->binx)+j]+sum;
			}
		}
		mean7=sum/(tailletotal/(16/cam->binx));

		//FOURTH SQUARE
		sum = 0;
		for (i=(unsigned int)(256/cam->binx);i<(unsigned int)(768/cam->binx);i++)
		{
			for (j=(unsigned int)(256/cam->binx);j<(unsigned int)(768/cam->binx);j++)
			{
				sum=(unsigned long)p[(2048/cam->binx)*i+((tailletotal/2)/cam->binx)+(1024/cam->binx)+j]+sum;
			}
		}
		mean8=sum/(tailletotal/(16/cam->binx));		//NOW WE'VE GOT THE MEANS IN BINNING MODE!
	}
}

void cam_shutter_on(struct camprop *cam)
{
	SetAmplisObtu(1,1,1,1,0);
}

void cam_shutter_off(struct camprop *cam)
{
	SetAmplisObtu(1,1,1,0,0);
}

void cam_ampli_on(struct camprop *cam)
{
	SetAmplisObtu(1,1,1,1,0);
}

void cam_ampli_off(struct camprop *cam)
{
	SetAmplisObtu(1,1,0,1,0);
}

void cam_measure_temperature(struct camprop *cam)
{
	GetTemperature(2,&(cam->temperature));
}

void cam_cooler_on(struct camprop *cam)
{
	SetPeltier(1);
	cam->coolerindex=1;
}

void cam_cooler_off(struct camprop *cam)
{
	SetPeltier(0);
	cam->coolerindex=0;
}

void cam_cooler_check(struct camprop *cam)
{
	double temp;
	unsigned int consigne;
	temp=cam->check_temperature;
	if (temp>=-30.) { consigne = 7900; cam->check_temperature=-30.; }
	else if (temp<=-50.) { consigne = 25500; cam->check_temperature=-50.; }
	else {
		consigne=(unsigned int)pow(10.,2.6551e-6*temp*temp*temp+4.9964e-4*temp*temp+1.516e-3*temp+3.565199); //conversion temp->consigne
	}
    SetPeltierConsigne(consigne);
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
	//bin doit etre 1, 2, 4 ou 8
	if ((binx!=1) && (binx!=2) && (binx!=4) && (binx!=8) && (binx!=1) && (binx!=2) && (biny!=4) && (biny!=8))
	{
		sprintf(cam->msg,"The binning must be 1, 2, 4 or 8");
    	return ;
	}	
	else
	{
		cam->binx = binx;
		cam->biny = biny;
	}
}

void cam_update_window(struct camprop *cam)
{
    int maxx, maxy;
    maxx = cam->nb_photox;
    maxy = cam->nb_photoy;
    if (cam->x1 > cam->x2)
	libcam_swap(&(cam->x1), &(cam->x2));
    if (cam->x1 < 0)
	cam->x1 = 0;
    if (cam->x2 > maxx - 1)
	cam->x2 = maxx - 1;

    if (cam->y1 > cam->y2)
	libcam_swap(&(cam->y1), &(cam->y2));
    if (cam->y1 < 0)
	cam->y1 = 0;
    if (cam->y2 > maxy - 1)
	cam->y2 = maxy - 1;

    cam->w = (cam->x2 - cam->x1) / cam->binx + 1;
    cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    cam->h = (cam->y2 - cam->y1) / cam->biny + 1;
    cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}


// ================================================================
// ================================================================ 
// ===     Fonctions de base pour le pilotage de la camera      === 
// ================================================================ 
// ================================================================ 
// Ces fonctions sont tres specifiques a chaque camera.             


/*
void CamInit()
{
	CAM = new cam();
}
*/

void ControleurInit()
{
	control = new Ccontroleur();
}

void ControleurStop()
{
	if (control != NULL) {
		delete control;
		control = NULL;
	}
}

void AlimsInit()
{
	calim = new CAlims();
}

void AlimsStop()
{
	if (calim != NULL) {
		delete calim;
		calim = NULL;
	}
}

void equilibrer(unsigned int stat_dina)
{
	//EQUILIBRER EN CAS DE BINNING = 1
	double dif1,dif2,dif3,dif4,dif5,dif6,dif7,dif8;

	//MAINTENANT IL FAUT EQUILIBRER L'IMAGE FINALE
	
	//equilibrage statique 
	if (stat_dina==0)
	{
		dif1=(mean1-50)*6 + (control->ReadMyDoubleKey2("DEC1", (2000)));
		dif2=(mean2-50)*6 + (control->ReadMyDoubleKey2("DEC2", (2000)));
		dif3=(mean3-50)*6 + (control->ReadMyDoubleKey2("DEC3", (2000)));
		dif4=(mean4-50)*6 + (control->ReadMyDoubleKey2("DEC4", (2000)));

		SetDECALAGE(13,(unsigned int)dif1);
		SetDECALAGE(14,(unsigned int)dif2);
		SetDECALAGE(15,(unsigned int)dif3);
		SetDECALAGE(16,(unsigned int)dif4);

		control->SaveRegistry();
	}

	//equilibrage dinamique  (funciona mas demorou bastante a convergir para 150)
	if (stat_dina==1)
	{
		dif1=(mean1-150)/16*6 + (control->ReadMyDoubleKey2("DECD1", (2000)));
		dif2=(mean2-150)/16*6 + (control->ReadMyDoubleKey2("DECD2", (2000)));
		dif3=(mean3-150)/16*6 + (control->ReadMyDoubleKey2("DECD3", (2000)));
		dif4=(mean4-150)/16*6 + (control->ReadMyDoubleKey2("DECD4", (2000)));

		SetDECALAGE(17,(unsigned int)dif1);
		SetDECALAGE(18,(unsigned int)dif2);
		SetDECALAGE(19,(unsigned int)dif3);
		SetDECALAGE(20,(unsigned int)dif4);

		control->SaveRegistry();
	}

	//equilibrage statique avec binning
	if (stat_dina==2)
	{
		dif5=(mean5-50)*6 + (control->ReadMyDoubleKey2("DECB1", (2000)));
		dif6=(mean6-50)*6 + (control->ReadMyDoubleKey2("DECB2", (2000)));
		dif7=(mean7-50)*6 + (control->ReadMyDoubleKey2("DECB3", (2000)));
		dif8=(mean8-50)*6 + (control->ReadMyDoubleKey2("DECB4", (2000)));

		SetDECALAGE(13,(unsigned int)dif5);
		SetDECALAGE(14,(unsigned int)dif6);
		SetDECALAGE(15,(unsigned int)dif7);
		SetDECALAGE(16,(unsigned int)dif8);

		control->SaveRegistry();
	}

	//equilibrage dinamique avec binning 
	if (stat_dina==3)
	{
		dif5=(mean5-150)/16*6 + (control->ReadMyDoubleKey2("DECDB1", (2000)));
		dif6=(mean6-150)/16*6 + (control->ReadMyDoubleKey2("DECDB2", (2000)));
		dif7=(mean7-150)/16*6 + (control->ReadMyDoubleKey2("DECDB3", (2000)));
		dif8=(mean8-150)/16*6 + (control->ReadMyDoubleKey2("DECDB4", (2000)));

		SetDECALAGE(17,(unsigned int)dif5);
		SetDECALAGE(18,(unsigned int)dif6);
		SetDECALAGE(19,(unsigned int)dif7);
		SetDECALAGE(20,(unsigned int)dif8);

		control->SaveRegistry();
	}
}



////////////////
void SetDebugLevel(int level)
{
	bool onBOOL;
	if (level==1) { onBOOL=true; }
	else { onBOOL=false; }
	control->SetDebugLevel(onBOOL);
}
//////////////////////
unsigned int ResetADLINK()
{
	bool ret=control->ResetADLINK();

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int SetConfCalcul(short ConfCalcul)
{
	bool ret=control->SetConfCalcul(ConfCalcul);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int SetDECALAGE(unsigned int n, unsigned int val)
{
	bool ret=control->SetDECALAGE(n, val);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int SetBasseTension(int onoff)
{
	bool btruefalse;
	if (onoff==1) { btruefalse=true; }
	else { btruefalse=false; }

	bool ret=calim->SetBasseTension(btruefalse);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int SetModeTension(int HR, unsigned int binning)
{
	bool truefalse;
	if (HR==1) { truefalse=true; }
	else { truefalse=false; }
	
	bool ret=calim->SetModeTension(truefalse, binning);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int GetTemperature(int n, double *temp)
{
	bool ret=calim->GetTemperature(n, temp);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int SetPeltier(int on)
{
	bool truefalse;
	if (on==1) { truefalse=true; }
	else { truefalse=false; }

	bool ret=calim->SetPeltier(truefalse);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int SetPeltierConsigne(int temp)
{
	bool ret=calim->SetPeltierConsigne(temp);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int SetSupply(int on)
{
	bool truefalse;
	if (on==1) { truefalse=true; }
	else { truefalse=false; }
	bool ret=calim->SetSupply(truefalse);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int SetModeBinning(int HV, unsigned int binning, unsigned int vitesse,int debug)
{
	bool HVbool;
	if (HV==1) { HVbool=true; }
	else { HVbool=false; }

	bool debugbool;
	if (debug==1) { debugbool=true; }
	else { debugbool=false; }

	bool ret=control->SetModeBinning(HVbool, binning, vitesse, debugbool);
	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int SetTempsExposition(double pose, unsigned int *erreur)
{
	bool erreurbool=0;
	bool ret=control->SetTempsExposition(pose, &erreurbool);
	if (erreurbool==false) { *erreur=0; }
	else { *erreur=1; }

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}


unsigned int SetArea(unsigned short x0, unsigned short y0, unsigned short xb, unsigned short yb)
{
	xb=10000;
	yb=10000;
	bool ret=control->SetArea(x0, y0, xb, yb);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int Start(void)
{
	bool erreurbool=0;
	int erreur=0;
	erreurbool=control->Start();
	
	if (erreurbool==true) { erreur=0; }
	else { erreur=1; }
	return erreur;
}

unsigned int Stop(int stp)
{
	bool onBOOL;
	int erreur=0;
	if (stp==1) { onBOOL=true; }
	else { onBOOL=false; }
	bool erreurbool=control->Stop(onBOOL);

	if (erreurbool==true) { erreur=0; }
	else { erreur=1; }
	return erreur;
}

unsigned int SerialDownload(void)
{
	unsigned int com=0, iteration=0;
	bool com2=0;
	while((com==0)&&(iteration<10)) 	
	{
		com = control->SetDECALAGE(20, 2000);
		iteration++;
	}
	
	if (com!=0)
	{
		com2 = control->SerialDownload();
	}

	unsigned int error;
	if (com2==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

void Initialise(int initls)
{
	bool onBOOL;
	if (initls==1) { onBOOL=true; }
	else { onBOOL=false; }
	control->Initialise(onBOOL);
}

unsigned int GetTempsExposition(double *pose, unsigned int *erreur)
{
		bool erreurbool=0;
		bool ret=control->GetTempsExposition(pose, &erreurbool);
		if (erreurbool==true) { *erreur=0; }
		else { *erreur=1; }

		unsigned int error;
		if (ret==true) { error = 0 ; }
		else { error = 1; }
		return error;
}

unsigned int SetImageSize(unsigned long sx, unsigned long sy)
{
		bool ret=control->SetImageSize(sx,sy);

		unsigned int error;
		if (ret==true) { error = 0 ; }
		else { error = 1; }
		return error;
}
  
unsigned int GetImageSize(unsigned long *sx, unsigned long *sy)
{
	bool ret=control->GetImageSize(sx,sy);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int Abort(int abrt)
{
	bool onBOOL;
	if (abrt==1) { onBOOL=true; }
	else { onBOOL=false; }
	bool ret=control->Abort(onBOOL);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int GetStatusCamera(int est0, int est1)
{
	bool *estBOOL0=0;
	if (est0==1) { *estBOOL0=true; }
	else { *estBOOL0=false; }
	
	bool *estBOOL1=0;
	if (est1==1) { *estBOOL1=true; }
	else { *estBOOL1=false; }
	
	bool ret=control->GetStatusCamera(estBOOL0, estBOOL1);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int GetStatusAmplis(int comG, int comBP, int comL, int ampliam, int ampliof)
{
	bool *b0=0;
	if (comG==1) { *b0=true; }
	else { *b0=false; }
	
	bool *b1=0;
	if (comBP==1) { *b1=true; }
	else { *b1=false; }
	
	bool *b2=0;
	if (comL==1) { *b2=true; }
	else { *b0=false; }
	
	bool *b3=0;
	if (ampliam==1) { *b3=true; }
	else { *b3=false; }
	
	bool *b4=0;
	if (ampliof==1) { *b4=true; }
	else { *b4=false; }

	bool ret=control->GetStatusAmplis(b0, b1, b2, b3, b4);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int GetStatusObtu(int onoff, int am, int ouvfer)
{
	bool *ON=0;
	if (onoff==1) { *ON=true; }
	else { *ON=false; }
	
	bool *AM=0;
	if (am==1) { *AM=true; }
	else { *AM=false; }
	
	bool *OUV=0;
	if (ouvfer==1) { *OUV=true; }
	else { *OUV=false; }
	
	bool ret=control->GetStatusObtu(ON, AM, OUV);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}

unsigned int SetAmplisObtu(int onoff, int onoff2, int onoff3, int onoff4, int onoff5)
{
	int on5int;

	bool onBOOL;
	if (onoff==1) { onBOOL=true; }
	else { onBOOL=false; }

	bool on2BOOL;
	if (onoff2==1) { on2BOOL=true; }
	else { on2BOOL=false; }

	bool on3BOOL;
	if (onoff3==1) { on3BOOL=true; }
	else { on3BOOL=false; }
	
	bool on4BOOL;
	if (onoff4==1) { on4BOOL=true; }
	else { on4BOOL=false; }

	on5int=onoff5;

	bool ret=control->SetAmplisObtu(onBOOL, on2BOOL, on3BOOL, on4BOOL, on5int);

	unsigned int error;
	if (ret==true) { error = 0 ; }
	else { error = 1; }
	return error;
}


// ================================================================ 
// ================================================================ 
// ===     Fonctions etendues pour le pilotage de la camera     === 
// ================================================================ 
// ================================================================ 
// Ces fonctions sont tres specifiques a chaque camera.             
// ================================================================ 


void cemes_updatelog(struct camprop *cam, char *filename, char *comment)
{
	/*
    char s[100];
    char fname[256];
    FILE *fil;
    if (cam->updatelogindex == 1) {
	Tcl_Eval(cam->interp, "clock format [clock seconds] -format \"%Y-%m-%dT%H:%M:%S.00\"");
	strcpy(s, cam->Tcl_GetStringResult(interp));
	if (strcmp(filename, "") == 0) {
	    strcpy(fname, "updateclock.log");
	} else {
	    strcpy(fname, filename);
	}
	fil = fopen(fname, "at");
	if (fil == NULL)
	    return;
	fprintf(fil, "%s : %s\n", s, comment);
	fclose(fil);
    }
    return;
	*/
}


