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


//void AcqRead(ClientData clientData);
extern struct camini CAM_INI[];


/*
 *  Definition a structure specific for this driver
 */

/*
char *cam_shuttertypes[] = {
   "audine",
   "thierry",
   NULL
};
*/

/*
char *cam_updatelog[] = {
   "off",
   "on",
   NULL
};
*/

/* AD976A : default audine CAN */
/* LTC1605 : some spanish audine CAN, one pulse only */

static char *cam_can[] = {
    "AD976A",
    "LTC1605",
    NULL
};


/*
 * -----------------------------------------------------------------------------
 *  TTTTT DDDD   III
 *    T   D   D   I
 *    T   D   D   I
 *    T   D   D   I
 *    T   D   D   I
 *    T   D   D   I
 *    T   DDDD   III
 * -----------------------------------------------------------------------------
 */
typedef struct {
    char *dateobs;		/* Date du debut de l'observation (format FITS) */
    char *dateend;		/* Date de fin de l'observation (format FITS) */
    ClientData clientData;	/* Camera (CCamera*) */
    Tcl_Interp *interp;		/* Interpreteur */
    Tcl_TimerToken TimerToken;	/* Handler sur le timer */
    int width;			/* Largeur de l'image */
    int offset;			/* Offset en x (a partir de 1) */
    int height;			/* Hauteur totale de l'image */
    int binx;			/* binning en X */
    int biny;			/* binning en Y */
    float dt;			/* intervalle de temps en millisecondes */
    int y;			/* nombre de lignes deja lues */
    unsigned long t0;		/* instant de depart en microsecondes */
    unsigned short *pix;	/* stockage de l'image */
    unsigned short *pix2;	/* pointeur defilant sur le contenu de pix */
    int last_delta;		/* dernier delta temporel */
    int blocking;		/* vaut 1 si le scan est bloquant */
    int keep_perfos;		/* vaut 1 si on conserve les dt du scan dans 1 fichier */
    int fileima;		/* vaut 1 si on �crit les pixels dans un fichier */
    FILE *fima;			/* fichier binaire pour stocker les pixels */
    int *dts;			/* tableau des d�lais */
    unsigned long loopmilli1;	/* nb de boucles pour faire une milliseconde (~10000) */
    int stop;			/* indicateur d'arret (1=>pose arretee au prochain coup) */
    double ra;			/* RA at the bigining */
    double dec;			/* DEC at the bigining */
} ScanStruct;

/* --- Global variable for TDI acquisition mode ---*/
static ScanStruct *TheScanStruct = NULL;

static void AudineScanCallback(ClientData clientData);
static void AudineScanLibereStructure();
static void AudineScanTerminateSequence(ClientData clientData, int camno, const char *reason);
static void AudineScanTransfer(ClientData clientData);


/*
 * -----------------------------------------------------------------------------
 *  cmdCamUpdateLog()
 *
 * Add a line in the file update.log after each update clock
 *
 * -----------------------------------------------------------------------------
 */
int cmdAudineUpdateLog(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (strcmp(argv[2], "off") == 0) {
	    cam->updatelogindex = 0;
	    pb = 0;
	} else if (strcmp(argv[2], "on") == 0) {
	    cam->updatelogindex = 1;
	    pb = 0;
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s off|on", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, "");
	if (cam->updatelogindex == 0) {
	    sprintf(ligne, "off");
	} else if (cam->updatelogindex == 1) {
	    sprintf(ligne, "on");
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdPortAdress()
 *
 * Change or returns the decimal port adress
 *
 * -----------------------------------------------------------------------------
 */
int cmdAudinePortAdress(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	cam->port = (unsigned short) atoi(argv[2]);
	pb = 0;
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s ?decimal_adress?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, "");
	sprintf(ligne, "%d", cam->port);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdAudineCamOutTime()
 *
 * Compute the delay for an 'out' instruction for parallel port
 *
 * -----------------------------------------------------------------------------
 */
int cmdAudineOutTime(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[100];
    int retour = TCL_OK;
    struct camprop *cam;
    unsigned long billion;
    int date1, date2;
    double tout;
    unsigned long nb_out;

    if (argc <= 2) {
	sprintf(ligne, "Usage %s %s billion_out", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else {
	billion = 1000000;
	/*
	   if (strcmp(argv[2],"?")==0) {
	   nb_out=10*billion;
	   } else {
	 */
	nb_out = (unsigned long) (atof(argv[2]) * billion);
	if (nb_out <= (unsigned long) 0) {
	    nb_out = (unsigned long) 1;
	}
	/*} */
	cam = (struct camprop *) clientData;
	Tcl_Eval(interp, "clock seconds");
	date1 = atoi(Tcl_GetStringResult(interp));
	if (cam->authorized == 1) {
	    audine_cam_test_out(cam, nb_out);
	}
	Tcl_Eval(interp, "clock seconds");
	date2 = atoi(Tcl_GetStringResult(interp));
	tout = (double) (date2 - date1) / (double) nb_out *1.e6;
	sprintf(ligne, "%f", tout);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_OK;
    }
    return retour;
}

int cmdAudineWipe(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
/*
 * -----------------------------------------------------------------------------
 *  cmdAudineCamWipe()
 *
 * Wipe the CCD matrix
 *
 * -----------------------------------------------------------------------------
 */
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;

    CAM_DRV.start_exp(cam, "amplioff");
    libcam_GetCurrentFITSDate(interp, cam->date_obs);

    return TCL_OK;
}

int cmdAudineRead(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
/*
 * -----------------------------------------------------------------------------
 *  cmdAudineCamRead()
 *
 * Read the CCD matrix
 *
 * -----------------------------------------------------------------------------
 */
{
   int naxis1, naxis2, bin1, bin2;
   char s[100];
   float *p;		/* cameras de 1 a 16 bits non signes */
   double ra, dec, exptime = 0.;
   int status;
   struct camprop *cam;

   cam = (struct camprop *) clientData;
   interp = cam->interp;
   naxis1 = cam->w;
   naxis2 = cam->h;
   bin1 = cam->binx;
   bin2 = cam->biny;

   p = (float*)malloc(naxis1*naxis2 * sizeof(float));

   libcam_GetCurrentFITSDate(interp, cam->date_end);

   /*cam_stop_exp(cam); */
   CAM_DRV.read_ccd(cam,p);

   /*
   * Ce test permet de savoir si le buffer existe
   */
   sprintf(s, "buf%d bitpix", cam->bufno);
   if (Tcl_Eval(interp, s) == TCL_ERROR) {
      // Creation du buffer
      sprintf(s, "buf::create %d", cam->bufno);
      Tcl_Eval(interp, s);
   }

   sprintf(s, "buf%d setpixels CLASS_GRAY %d %d FORMAT_SHORT COMPRESS_NONE %zu", cam->bufno, naxis1, naxis2, (size_t) p);
   Tcl_Eval(interp, s);
   /* Add FITS keywords */
   sprintf(s, "buf%d setkwd {NAXIS 2 int \"\" \"\"}", cam->bufno);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {NAXIS1 %d int \"\" \"\"}", cam->bufno, naxis1);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {NAXIS2 %d int \"\" \"\"}", cam->bufno, naxis2);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {BIN1 %d int \"\" \"\"}", cam->bufno, bin1);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {BIN2 %d int \"\" \"\"}", cam->bufno, bin2);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {CAMERA \"%s %s %s\" string \"\" \"\"}", cam->bufno, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd [list GPS-DATE 0 int {1 if datation is derived from GPS, else 0} {}]", cam->bufno);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {DATE-OBS %s string \"\" \"\"}", cam->bufno, cam->date_obs);
   Tcl_Eval(interp, s);
   if (cam->timerExpiration != NULL) {
      sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"s\"}", cam->bufno, cam->exptime);
   } else {
      sprintf(s, "expr (([mc_date2jd %s]-[mc_date2jd %s])*86400.)", cam->date_end, cam->date_obs);
      Tcl_Eval(interp, s);
      exptime = atof(Tcl_GetStringResult(interp));
      sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"s\"}", cam->bufno, exptime);
   }
   Tcl_Eval(interp, s);

   libcam_get_tel_coord(interp, &ra, &dec, cam, &status);
   if (status == 0) {
      /* Add FITS keywords */
      sprintf(s, "buf%d setkwd {RA %f float \"Right ascension telescope encoder\" \"\"}", cam->bufno, ra);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {DEC %f float \"Declination telescope encoder\" \"\"}", cam->bufno, dec);
      Tcl_Eval(interp, s);
   }
   //if (cam->timerExpiration != NULL) {
   //   sprintf(s, "status_cam%d", cam->camno);
   //}
   //Tcl_SetVar(interp, s, "stand", TCL_GLOBAL_ONLY);
   setCameraStatus(cam,"stand");
   cam->clockbegin = 0;

   if (cam->timerExpiration != NULL) {
//      free(cam->timerExpiration->dateobs);
      free(cam->timerExpiration);
      cam->timerExpiration = NULL;
   }
   free(p);

   /*
   struct camprop *cam;
   cam = (struct camprop*)clientData;
   AcqRead((ClientData)cam);
   */
   return TCL_OK;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamAmpli()
 *
 * Setect the synchronisation of the CCD amplifier
 *
 * -----------------------------------------------------------------------------
 */
int cmdAudineAmpli(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3) && (argc != 4)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (argc == 4) {
	    cam->nbampliclean = (int) fabs((double)atoi(argv[3]));
	}
	if (strcmp(argv[2], "synchro") == 0) {
	    cam->ampliindex = 0;
	    pb = 0;
	} else if (strcmp(argv[2], "on") == 0) {
	    cam->ampliindex = 1;
	    CAM_DRV.ampli_on(cam);
	    pb = 0;
	} else if (strcmp(argv[2], "off") == 0) {
	    cam->ampliindex = 2;
	    CAM_DRV.ampli_off(cam);
	    pb = 0;
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s synchro|on|off ?nbcleanings?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, "");
	if (cam->ampliindex == 0) {
	    sprintf(ligne, "synchro %d", cam->nbampliclean);
	} else if (cam->ampliindex == 1) {
	    sprintf(ligne, "on %d", cam->nbampliclean);
	} else if (cam->ampliindex == 2) {
	    sprintf(ligne, "off %d", cam->nbampliclean);
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamCantype()
 *
 * Setect the CAN manufacturer
 *
 * -----------------------------------------------------------------------------
 */
int cmdAudineCantype(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    int result = TCL_OK, pb = 0, i;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {

	pb = 1;
	for (i = 0; cam_can[i] != NULL; i++) {
	    if (strcmp(argv[2], cam_can[i]) == 0) {
		cam->cantypeindex = i;
		pb = 0;
		break;
	    }
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s AD976A|LTC1605", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, "");
	sprintf(ligne, "%s", cam_can[cam->cantypeindex]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdCamShutterType()
 *
 * Setect the type of shutter. 2 shutter types are supported :
 *  audine : build by Raymond David (Essentiel Electronic)
 *  thierry : build by Pierre Thierry.
 *
 * -----------------------------------------------------------------------------
 */
int cmdAudineShutterType(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc > 4)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (strcmp(argv[2], "audine") == 0) {
	    cam->shuttertypeindex = 0;
	    cam->shutteraudinereverse = 0;
	    if (argc >= 4) {
		if (strcmp(argv[3], "reverse") == 0) {
		    cam->shutteraudinereverse = 1;
		}
	    }
	    pb = 0;
	} else if (strcmp(argv[2], "thierry") == 0) {
	    cam->shuttertypeindex = 1;
	    pb = 0;
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s audine|thierry ?options?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, "");
	if (cam->shuttertypeindex == 0) {
	    if (cam->shutteraudinereverse == 0) {
		sprintf(ligne, "audine");
	    } else {
		sprintf(ligne, "audine reverse");
	    }
	} else if (cam->shuttertypeindex == 1) {
	    sprintf(ligne, "thierry");
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamObtupierre()
 *
 *  Driver for the Pierre Thierry personnal shutter.
 *
 * -----------------------------------------------------------------------------
 */
int cmdAudineObtupierre(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    int retour = TCL_OK;
    char ligne[256];
    char lignetot[1024];
    int valint;
    struct camprop *cam;

    if ((argc != 2) && (argc != 9)) {
	sprintf(ligne, "Usage: %s %s ?a b c d e t flag? ", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(lignetot, "%d", cam->InfoPierre_a);
	sprintf(ligne, " %d", cam->InfoPierre_b);
	strcat(lignetot, ligne);
	sprintf(ligne, " %d", cam->InfoPierre_c);
	strcat(lignetot, ligne);
	sprintf(ligne, " %d", cam->InfoPierre_d);
	strcat(lignetot, ligne);
	sprintf(ligne, " %d", cam->InfoPierre_e);
	strcat(lignetot, ligne);
	sprintf(ligne, " %d", cam->InfoPierre_t);
	strcat(lignetot, ligne);
	sprintf(ligne, " %d", cam->InfoPierre_flag);
	strcat(lignetot, ligne);
	Tcl_SetResult(interp, lignetot, TCL_VOLATILE);
    } else {
	if (Tcl_GetInt(interp, argv[2], &valint) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?a b c d e t flag?\na = must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    return TCL_ERROR;
	} else {
	    cam = (struct camprop *) clientData;
	    cam->InfoPierre_a = (short) valint;
	}
	if (Tcl_GetInt(interp, argv[3], &valint) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?a b c d e t flag?\nb = must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    return TCL_ERROR;
	} else {
	    cam->InfoPierre_b = (short) valint;
	}
	if (Tcl_GetInt(interp, argv[4], &valint) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?a b c d e t flag?\nc = must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    return TCL_ERROR;
	} else {
	    cam->InfoPierre_c = (short) valint;
	}
	if (Tcl_GetInt(interp, argv[5], &valint) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?a b c d e t flag?\nd = must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    return TCL_ERROR;
	} else {
	    cam->InfoPierre_d = (short) valint;
	}
	if (Tcl_GetInt(interp, argv[6], &valint) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?a b c d e t flag?\ne = must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    return TCL_ERROR;
	} else {
	    cam->InfoPierre_e = (short) valint;
	}
	if (Tcl_GetInt(interp, argv[7], &valint) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?a b c d e t flag?\nt = must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    return TCL_ERROR;
	} else {
	    cam->InfoPierre_t = (short) valint;
	}
	if (Tcl_GetInt(interp, argv[8], &valint) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?a b c d e t flag?\nflag = must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    return TCL_ERROR;
	} else {
	    cam->InfoPierre_flag = (short) valint;
	}
    }
    return retour;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdCamObtupierreTest()
 *
 *  Driver for the Pierre Thierry personnal shutter.
 *
 * -----------------------------------------------------------------------------
 */
int cmdAudineObtupierreTest(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    int retour = TCL_OK;
    char ligne[256];
    char lignetot[1024];
    int a, b, c, delay = 0, valint;
    struct camprop *cam;

    if ((argc != 2) && (argc != 4)) {
	sprintf(ligne, "Usage: %s %s a delay", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(lignetot, "cam%d obtupierre", cam->camno);
	Tcl_Eval(interp, lignetot);
    } else {
	cam = (struct camprop *) clientData;
	if (Tcl_GetInt(interp, argv[2], &valint) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s a delay?\na = must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    return TCL_ERROR;
	} else {
	    a = valint;
	}
	if (Tcl_GetInt(interp, argv[3], &valint) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s a delay?\ndelay = must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    retour = TCL_ERROR;
	} else {
	    delay = valint;
	}
	b = a + delay;
	c = b + delay;
	sprintf(lignetot, "cam%d obtupierre %d %d %d %d %d %d %d", cam->camno, a, b, c, cam->InfoPierre_d, cam->InfoPierre_e, cam->InfoPierre_t, cam->InfoPierre_flag);
	Tcl_Eval(interp, lignetot);
	sprintf(lignetot, "cam%d shutter closed", cam->camno);
	Tcl_Eval(interp, lignetot);
	strcpy(lignetot, "after 600");
	Tcl_Eval(interp, lignetot);
	sprintf(lignetot, "cam%d shutter opened", cam->camno);
	Tcl_Eval(interp, lignetot);
	strcpy(lignetot, "after 600");
	Tcl_Eval(interp, lignetot);
	sprintf(lignetot, "cam%d shutter closed", cam->camno);
	Tcl_Eval(interp, lignetot);
	sprintf(lignetot, "cam%d obtupierre", cam->camno);
	Tcl_Eval(interp, lignetot);
    }
    return retour;
}


/*
 * -----------------------------------------------------------------------------
 *  DDDD   EEEEE  BBBB   U   U   GGG
 *  D   D  E      B   B  U   U  G   G
 *  D   D  E      B   B  U   U  G
 *  D   D  EEEE   BBBB   U   U  G  GG  your electronic kit
 *  D   D  E      B   B  U   U  G   G
 *  D   D  E      B   B  U   U  G   G
 *  DDDD   EEEEE  BBBB    UUU    GGG
 * -----------------------------------------------------------------------------
 */

/*
 * -----------------------------------------------------------------------------
 *  cmdCamSet0()
 *
 *  Commande de developpement de Audine : SET0 de PISCO.
 *
 *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
 * -----------------------------------------------------------------------------
 */
int cmdAudineSet0(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[100];
    int retour = TCL_OK;
    struct camprop *cam;

    if (argc != 2) {
	sprintf(ligne, "Usage %s %s", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else {
	cam = (struct camprop *) clientData;
	if (cam->authorized == 1) {
	    audine_set0(cam);
	}
	retour = TCL_OK;
    }

    return retour;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdCamSet255()
 *
 *  Commande de developpement de Audine : SET255 de PISCO.
 *
 *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
 * -----------------------------------------------------------------------------
 */
int cmdAudineSet255(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[100];
    int retour = TCL_OK;
    struct camprop *cam;

    if (argc != 2) {
	sprintf(ligne, "Usage %s %s", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else {
	cam = (struct camprop *) clientData;
	if (cam->authorized == 1) {
	    audine_set255(cam);
	}
	retour = TCL_OK;
    }

    return retour;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdCamTest()
 *
 *  Commande de developpement de Audine : TEST de PISCO.
 *
 *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
 * -----------------------------------------------------------------------------
 */
int cmdAudineTest(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[100];
    int retour = TCL_OK;
    int num;
    struct camprop *cam;

    if (argc != 3) {
	sprintf(ligne, "Usage %s %s number", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else {
	if (Tcl_GetInt(interp, argv[2], &num) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s number\nnumber must be an integer >0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    retour = TCL_ERROR;
	} else {
	    cam = (struct camprop *) clientData;
	    if (cam->authorized == 1) {
		audine_test(cam, num);
	    }
	    retour = TCL_OK;
	}
    }

    return retour;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdCamTest2()
 *
 *  Commande de developpement de Audine : TEST2 de PISCO.
 *
 *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
 * -----------------------------------------------------------------------------
 */
int cmdAudineTest2(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[100];
    int retour = TCL_OK;
    int num;
    struct camprop *cam;

    if (argc != 3) {
	sprintf(ligne, "Usage %s %s number", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else {
	if (Tcl_GetInt(interp, argv[2], &num) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s number\nnumber must be an integer > 0", argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    retour = TCL_ERROR;
	} else {
	    cam = (struct camprop *) clientData;
	    if (cam->authorized == 1) {
		audine_test2(cam, num);
	    }
	    retour = TCL_OK;
	}
    }

    return retour;
}

/*
 * -----------------------------------------------------------------------------
 *  TTTTT DDDD   III
 *    T   D   D   I
 *    T   D   D   I
 *    T   D   D   I    acquisition mode
 *    T   D   D   I
 *    T   D   D   I
 *    T   DDDD   III
 * -----------------------------------------------------------------------------
 */

/*
 * -----------------------------------------------------------------------------
 *  cmdAudineScanLoop()
 *
 *  Calcule le nombre de boucles pour attendre une milliseconde en mode cli
 *  C'est une fonction a utiliser avant de faire un scan avec l'option -fast.
 *
 *  buf scanloop
 *
 * -----------------------------------------------------------------------------
 */
int cmdAudineScanLoop(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[100];
    sprintf(ligne, "%ld", loopsmillisec());
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdAudineScan()
 *
 *  Lance un scan.
 *
 *  buf scan width height bin dt
 *    - width : largeur de l'image
 *    - height : largeur de l'image
 *    - bin : facteur de binning
 *    - dt : intervalle de temps entre chaque lecture de ligne (en ms, float)
 *    - -firstpix index : la fenetre commence au pixel numero (1 a DimX).
 *    - -fast speed : bloque les interruptions en permanence pour assurer
 *      des vitesses rapides (<500 ms). La valeur de speed provient du
 *      resultat de la fonction scanloop.
 *    - -tmpfile : l'image est stockee sur un fichier binaire avant d'etre
 *      recuperee en memoire a la fin du scan. Utile pour les grandes images.
 *      Le fichier temporaire s'appelle #scan.bin.
 *    - -perfo : cree un fichier de performances. Inutile pour -fast.
 *
 *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
 * -----------------------------------------------------------------------------
 */
int cmdAudineScan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    int w;			/* parametre d'appel : largeur */
    int h;			/* parametre d'appel : hauteur */
    int binx;			/* parametre d'appel : binning en x */
    int biny;			/* parametre d'appel : binning en y */
    double dt;			/* parametre d'appel : intervalle de temps */
    int retour = TCL_OK;
    struct camprop *cam;
    char *ligne;		/* Texte pour le retour */
    char *ligne2;		/* Texte pour le retour */
    int idt;			/* Intervalle de temps en ms vers le 1er evenement */
    int i;
    int offset = 1;
    int blocking = 0;
    int keep_perfos = 0;
    int fileima = 0;
    int ok = 1;
    long next_occur;
    int nb_lignes, status;
    double loopmilli1 = 0;
    unsigned long msloop, msloop10, msloops[10];
    char msgtcl[] = "Usage: %s %s width height bin dt ?-firstpix index? ?-fast speed? ?-perfo? ?-tmpfile?";


    ligne = (char *) calloc(200, sizeof(char));
    ligne2 = (char *) calloc(200, sizeof(char));
    if (argc < 6) {
       sprintf(ligne, msgtcl, argv[0], argv[1]);
       Tcl_SetResult(interp, ligne, TCL_VOLATILE);
       retour = TCL_ERROR;
    } else {
       cam = (struct camprop *) clientData;
       if (TheScanStruct == NULL) {
          if (Tcl_GetInt(interp, argv[2], &w) != TCL_OK) {
             sprintf(ligne2, "%s\nwidth : must be an integer between 1 and %d", msgtcl, cam->nb_photox);
             sprintf(ligne, ligne2, argv[0], argv[1]);
             Tcl_SetResult(interp, ligne, TCL_VOLATILE);
             retour = TCL_ERROR;
          } else if (Tcl_GetInt(interp, argv[3], &h) != TCL_OK) {
             sprintf(ligne2, "%s\nheight : must be an integer >= 1", msgtcl);
             sprintf(ligne, ligne2, argv[0], argv[1]);
             Tcl_SetResult(interp, ligne, TCL_VOLATILE);
             retour = TCL_ERROR;
          } else if (Tcl_GetInt(interp, argv[4], &binx) != TCL_OK) {
             sprintf(ligne2, "%s\nbin : must be an integer >= 1", msgtcl);
             sprintf(ligne, ligne2, argv[0], argv[1]);
             Tcl_SetResult(interp, ligne, TCL_VOLATILE);
             retour = TCL_ERROR;
          } else if (Tcl_GetDouble(interp, argv[5], &dt) != TCL_OK) {
             sprintf(ligne2, "%s\ndt : must be an floating point number >= 0, expressed in milliseconds", msgtcl);
             sprintf(ligne, ligne2, argv[0], argv[1]);
             Tcl_SetResult(interp, ligne, TCL_VOLATILE);
             retour = TCL_ERROR;
          } else {
             for (i = 6; i < argc; i++) {
                if ((strcmp(argv[i], "-offset") == 0) || (strcmp(argv[i], "-firstpix") == 0)) {
                   if (Tcl_GetInt(interp, argv[++i], &offset) != TCL_OK) {
                      sprintf(ligne, "Usage: %s %s width height bin dt ?-biny biny? ?-firstpix index? ?-blocking? ?-perfo?\nfirstpix index \"%s\" must be an integer", argv[0], argv[1], argv[i]);
                      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                      ok = 0;
                   }
                } else if (strcmp(argv[i], "-biny") == 0) {
                   if (Tcl_GetInt(interp, argv[++i], &biny) != TCL_OK) {
                      sprintf(ligne, "Usage: %s %s width height bin dt ?-biny biny? ?-firstpix index? ?-blocking? ?-perfo?\nfirstpix index \"%s\" must be an integer", argv[0], argv[1], argv[i]);
                      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                      ok = 0;
                   }
                } else if (strcmp(argv[i], "-fast") == 0) {
                   loopmilli1 = 0.;
                   if (i < argc - 1) {
                      loopmilli1 = atof(argv[i + 1]);
                   }
                   blocking = 1;
                } else if (strcmp(argv[i], "-perfo") == 0) {
                   keep_perfos = 1;
                } else if (strcmp(argv[i], "-tmpfile") == 0) {
                   fileima = 1;
                }
             }
             if (ok) {
                // Pour avertir les gens du status de la camera.
                //sprintf(ligne, "status_cam%d", cam->camno);
                //Tcl_SetVar(interp, ligne, "exp", TCL_GLOBAL_ONLY);
                setCameraStatus(cam,"exp");
                idt = (int) dt;
                TheScanStruct = (ScanStruct *) calloc(1, sizeof(ScanStruct));
                TheScanStruct->clientData = clientData;
                TheScanStruct->interp = interp;
                TheScanStruct->dateobs = (char *) calloc(32, sizeof(char));
                TheScanStruct->dateend = (char *) calloc(32, sizeof(char));
                if (offset > cam->nb_photox) {
                   offset = cam->nb_photox;
                }
                if (offset < 1) {
                   offset = 1;
                }
                if (w < 1) {
                   w = 1;
                }
                if (offset + w > cam->nb_photox) {
                   w = cam->nb_photox - (offset - 1);
                }
                TheScanStruct->width = w;
                TheScanStruct->offset = offset;
                TheScanStruct->height = h;
                if (binx < 1) {
                   binx = 1;
                }
                if (biny < 1) {
                   biny = 1;
                }
                TheScanStruct->binx = binx;
                TheScanStruct->biny = biny;
                if (dt < 0) {
                   dt = -dt;
                }
                TheScanStruct->dt = (float) dt;
                TheScanStruct->y = 0;
                TheScanStruct->blocking = blocking;
                TheScanStruct->keep_perfos = keep_perfos;
                TheScanStruct->fileima = fileima;
                TheScanStruct->fima = NULL;
                TheScanStruct->dts = (int *) calloc(h, sizeof(int));
                TheScanStruct->stop = 0;
                TheScanStruct->pix = NULL;
                TheScanStruct->pix2 = NULL;
                TheScanStruct->loopmilli1 = (unsigned long) loopmilli1;
                /* --- reserve de memoire ou fichier pour les datas intermediaires */
                if (TheScanStruct->fileima == 1) {
                   TheScanStruct->fima = fopen("#scan.bin", "wb");
                   if (TheScanStruct->fima == NULL) {
                      TheScanStruct->fileima = 0;
                   }
                }
                if (TheScanStruct->fileima == 0) {
                   TheScanStruct->pix = (unsigned short *) calloc((unsigned int) (w * h / binx), sizeof(unsigned short));
                   TheScanStruct->pix2 = TheScanStruct->pix;
                   if (TheScanStruct->pix == NULL) {
                      TheScanStruct->fileima = 1;
                   }
                   if (TheScanStruct->fileima == 1) {
                      TheScanStruct->fima = fopen("#scan.bin", "wb");
                      if (TheScanStruct->fima == NULL) {
                         /* traiter ce cas ou l'on ne peut pas enregistrer l'image */
                         /* ni ds la memoire, ni ds le disque */
                      }
                   }
                }
                /* coordonnes du telescope au debut de l'acquisition */
                libcam_get_tel_coord(interp, &TheScanStruct->ra, &TheScanStruct->dec, cam, &status);
                if (status == 1) {
                   TheScanStruct->ra = -1.;
                }
                /* Nettoyage du ccd */
                CAM_DRV.start_exp(cam, "amplion");
                Tcl_Eval(interp, "clock seconds");
                cam->clockbegin = (int) atoi(Tcl_GetStringResult(interp));
                TheScanStruct->t0 = libcam_getms();
                /* Declenche le premier evenement */
                if (blocking == 0) {
                   TheScanStruct->TimerToken = Tcl_CreateTimerHandler(idt, AudineScanCallback, (ClientData) cam);
                   libcam_GetCurrentFITSDate(interp, TheScanStruct->dateobs);
                   Tcl_ResetResult(interp);
                } else {
                   nb_lignes = TheScanStruct->height;
                   libcam_GetCurrentFITSDate(interp, TheScanStruct->dateobs);
                   if (cam->authorized == 1) {
                      if (cam->interrupt == 1) {
                         libcam_bloquer();
                      }
                      for (i = 0; i < nb_lignes; i++) {
                         AudineScanCallback((ClientData) cam);
                         next_occur = (long) TheScanStruct->dt;
                         TheScanStruct->last_delta = (int) next_occur;
                         TheScanStruct->dts[i] = (int) next_occur;
                         for (msloop10 = 0, msloop = 0; msloop < next_occur * TheScanStruct->loopmilli1; msloop++) {
                            msloops[msloop10] = (unsigned long) (0);
                            if (++msloop10 > 9) {
                               msloop10 = 0;
                            }
                         }
                      }
                      if (cam->interrupt == 1) {
                         libcam_debloquer();
                      }
                      if (cam->interrupt == 1) {
                         update_clock();
                      }
                   }
                   libcam_GetCurrentFITSDate(interp, TheScanStruct->dateend);
                   AudineScanTerminateSequence(clientData, cam->camno, "Normally terminated.");
                }
             } else {
                retour = TCL_ERROR;
             }
         }
      } else {
         sprintf(ligne, "Camera already in use");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         retour = TCL_ERROR;
      }
   }
   free(ligne);
   free(ligne2);
   return retour;
}

/*
 * AudineScanCallback --
 *
 * Fonction de lecture du CCD et de constitution de l'image, appellee regulierement
 * au cours de l'acquisition.
 *
 * Effets de bord :
 *   - relance eventuellement un nouveau timer avec ScanCallback en callback
 *   - En cas d'arret (volontaire ou non), met a jour les variables
 *     status_cam%d et scan_result%d (%d : numero de la camera).
 *
 */
void AudineScanCallback(ClientData clientData)
{
    long next_occur;		/* Prochain intervalle de temps a attendre.   */
    unsigned long n1, n2, n3;
    unsigned short buf[10000], w;
    struct camprop *cam;

    cam = (struct camprop *) clientData;
    if (cam->authorized == 1) {
	/* Bloquage eventuel des interruptions */
	if (TheScanStruct->blocking == 0) {
	    if (cam->interrupt == 1) {
		libcam_bloquer();
	    }
	}
	/* Lecture de la ligne */
	audine_read_line(cam, TheScanStruct->width, TheScanStruct->offset, TheScanStruct->binx, TheScanStruct->biny, buf);
	/* Debloquage eventuel des interruptions */
	if (TheScanStruct->blocking == 0) {
	    if (cam->interrupt == 1) {
		libcam_debloquer();
	    }
	    if (cam->interrupt == 1) {
		update_clock();
	    }
	}
    }
    /* Stocke la ligne dans le fichier temporaire ou dans la memoire temporaire */
    w = (TheScanStruct->width / TheScanStruct->binx);
    if (TheScanStruct->fileima == 1) {
	/*fwrite(buf,sizeof(unsigned short)*TheScanStruct->width,1,TheScanStruct->fima); */
	fwrite(buf, sizeof(unsigned short) * w, 1, TheScanStruct->fima);
    } else {
	/*memcpy(TheScanStruct->pix2,buf,sizeof(unsigned short)*TheScanStruct->width); */
	memcpy(TheScanStruct->pix2, buf, sizeof(unsigned short) * w);
	/*TheScanStruct->pix2 += TheScanStruct->width; */
	TheScanStruct->pix2 += w;
    }
    TheScanStruct->y = TheScanStruct->y + 1;

    if (TheScanStruct->blocking == 1) {
	return;
    }

    if (TheScanStruct->stop == 1) {	/* Arret a la demande de l'utilisateur */
	libcam_GetCurrentFITSDate(TheScanStruct->interp, TheScanStruct->dateend);
	AudineScanTerminateSequence(clientData, cam->camno, "User aborted exposure.");
    } else if (TheScanStruct->y < TheScanStruct->height) {	/* On continue : */
	n1 = TheScanStruct->t0;
	n2 = (unsigned long) ((TheScanStruct->y + 1) * TheScanStruct->dt);
	n3 = libcam_getms();
	next_occur = (long) (n1 + n2 - n3);
	TheScanStruct->last_delta = (int) next_occur;
	TheScanStruct->dts[TheScanStruct->y - 1] = (int) next_occur;
	if (next_occur <= 0) {	/* ben non : decalage temporel trop grand, on arrete l'image. */
	    libcam_GetCurrentFITSDate(TheScanStruct->interp, TheScanStruct->dateend);
	    AudineScanTerminateSequence(clientData, cam->camno, "Error : Aborted because CCD line transfers couldn't be re-scheduled (too busy system, or dt too small).");
	} else {		/* OK on continue */
	    TheScanStruct->TimerToken = Tcl_CreateTimerHandler((int) next_occur, AudineScanCallback, (ClientData) cam);
	}
    } else {			/* Image terminee : */
	libcam_GetCurrentFITSDate(TheScanStruct->interp, TheScanStruct->dateend);
	AudineScanTerminateSequence(clientData, cam->camno, "Normally terminated.");
    }
}

void AudineScanTerminateSequence(ClientData clientData, int camno, const char *reason)
{
    //char s[80];
    FILE *f;
    int i;
    struct camprop *cam;

    cam = (struct camprop *) clientData;

    if ((cam->shutterindex == 1) || (cam->shutterindex == 0)) {
        audine_shutter_off(cam);
    }

    if (TheScanStruct->fileima == 1) {
	fclose(TheScanStruct->fima);
	TheScanStruct->fima = NULL;
    }
    AudineScanTransfer(clientData);
    //sprintf(s, "scan_result%d", camno);
    //Tcl_SetVar(TheScanStruct->interp, s, reason, TCL_GLOBAL_ONLY);
    setScanResult(cam, reason);
    //sprintf(s, "status_cam%d", camno);
    //Tcl_SetVar(TheScanStruct->interp, s, "stand", TCL_GLOBAL_ONLY);
    setCameraStatus(cam,"stand");
    if (TheScanStruct->keep_perfos) {
	f = fopen("scanperf.txt", "wt");
	for (i = 0; i < TheScanStruct->height; i++) {
	    fprintf(f, "%d %d\n", i, TheScanStruct->dts[i]);
	}
	fclose(f);
    }
    AudineScanLibereStructure();
}

/*
 * AudineScanTransfer --
 *
 * Transfere l'image accumulee dans un buffer accessible depuis les
 * scripts TCL.
 *
 * Effets de bord :
 *   - Buffer realloue et rempli de l'image acquise.
 *
 */
void AudineScanTransfer(ClientData clientData)
{
   int naxis1, naxis2, bin1, bin2;
   char s[200];
   double ra, dec;
   float *pp;			/* fpix */
   int t, tt;
   struct camprop *cam;
   Tcl_Interp *interp;
   double exptime;
   double dt;
   double dteff, jdend, jdobs, bloceff;
   int status;
   unsigned short tmp;
   char dateobs_tu[50], dateend_tu[50];

   interp = TheScanStruct->interp;

   cam = (struct camprop *) clientData;
   cam->clockbegin = 0;
   naxis1 = TheScanStruct->width / TheScanStruct->binx;
   naxis2 = TheScanStruct->y;
   bin1 = TheScanStruct->binx;
   bin2 = TheScanStruct->biny;
   dt = TheScanStruct->dt / 1000.;
   exptime = -1;

   /* peu importe le nom de fonction qui suit buf1 */
   sprintf(s, "buf%d bitpix", cam->bufno);
   if (Tcl_Eval(interp, s) == TCL_ERROR) {
      /* Creation du buffer car il n'existe pas */
      sprintf(s, "buf::create %d", cam->bufno);
      Tcl_Eval(interp, s);
   }

   strcpy(dateobs_tu, TheScanStruct->dateobs);
   strcpy(dateend_tu,  TheScanStruct->dateend);

   sprintf(s, "mc_date2jd %s", TheScanStruct->dateobs);
   Tcl_Eval(interp, s);
   jdobs = atof(Tcl_GetStringResult(interp));
   sprintf(s, "mc_date2jd %s", TheScanStruct->dateend);
   Tcl_Eval(interp, s);
   jdend = atof(Tcl_GetStringResult(interp));
   if (jdend <= jdobs) {
      dteff = dt;
   } else {
      dteff = (jdend - jdobs) * 86400. / (naxis2);
   }
   bloceff = TheScanStruct->loopmilli1;
   if (dteff != 0.) {
      bloceff = dt / dteff * TheScanStruct->loopmilli1;
   }

   pp = (float *) malloc(naxis1 * naxis2 * sizeof(float));
   /* Transfert du fichier ou memoire temporaire dans le buffer image */
   t = naxis1 * naxis2;
   if (TheScanStruct->fileima == 1) {
      TheScanStruct->fima = fopen("#scan.bin", "rb");
      if (TheScanStruct->fima != NULL) {
         tt = 0;
         while (tt < t) {
            fread(&tmp, sizeof(unsigned short), 1, TheScanStruct->fima);
            *(pp + tt++) = (float) tmp;
         }
         fclose(TheScanStruct->fima);
         TheScanStruct->fima = NULL;
      }
   } else {
      while (--t >= 0)
         *(pp + t) = (float) *(TheScanStruct->pix + t);
   }


   // si cam->mirrorv vaut 0 , j'enregistre l'image tel quelle
   // si cam->mirrorv vaut 1 , je redresse l'image  en inversant l'axe X
   sprintf(s, "buf%d setpixels CLASS_GRAY %d %d FORMAT_FLOAT COMPRESS_NONE %zu -reverse_x %d",
      cam->bufno, naxis1, naxis2, (size_t)pp, cam->mirrorv );
   Tcl_Eval(interp, s);

   free(pp);

   sprintf(s, "buf%d setkwd {NAXIS 2 int \"\" \"\"}", cam->bufno);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {NAXIS1 %d int \"\" \"\"}", cam->bufno, naxis1);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {NAXIS2 %d int \"\" \"\"}", cam->bufno, naxis2);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {BIN1 %d int \"\" \"\"}", cam->bufno, bin1);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {BIN2 %d int \"\" \"\"}", cam->bufno, bin2);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {DATE-OBS %s string \"Begin of scan exposure.\" \"\"}", cam->bufno, dateobs_tu);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"\"}", cam->bufno, exptime);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {DATE-END %s string \"End of scan exposure.\" \"\"}", cam->bufno, dateend_tu);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {SP %lu int \"Asked speed parameter for fast\" \"\"}", cam->bufno, TheScanStruct->loopmilli1);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {SPEFF %d int \"Effective speed parameter for fast\" \"\"}", cam->bufno, (int) bloceff);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {DT %f float \"Asked Time Delay Integration\" \"s/line\"}", cam->bufno, dt);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {DTEFF %f float \"Effective Time Delay Integration\" \"s/line\"}", cam->bufno, dteff);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {CAMERA \"%s %s %s\" string \"\" \"\"}", cam->bufno, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd [list GPS-DATE 0 int {1 if datation is derived from GPS, else 0} {}]", cam->bufno);
   Tcl_Eval(interp, s);

   libcam_get_tel_coord(interp, &ra, &dec, cam, &status);
   if (status == 0) {
      /* Add FITS keywords */
      sprintf(s, "buf%d setkwd {RA %f float \"Right ascension telescope at the end\" \"\"}", cam->bufno, ra);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {DEC %f float \"Declination telescope at the end\" \"\"}", cam->bufno, dec);
      Tcl_Eval(interp, s);
   }
   if (TheScanStruct->ra != -1.) {
      /* Add FITS keywords */
      sprintf(s, "buf%d setkwd {RA_BEG %f float \"Right ascension telescope at the begining\" \"\"}", cam->bufno, TheScanStruct->ra);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {DEC_BEG %f float \"Declination telescope at the begining\" \"\"}", cam->bufno, TheScanStruct->dec);
      Tcl_Eval(interp, s);
   }

   //sprintf(s, "status_cam%d", cam->camno);
   //Tcl_SetVar(interp, s, "stand", TCL_GLOBAL_ONLY);
   setCameraStatus(cam,"stand");

}

/*
 * AudineScanLibereStructure --
 *
 * Libere la structure necessaire au fonctionnement du scan.
 *
 * Effets de bord :
 *   - Structure liberee et remise a NULL.
 *
 */
void AudineScanLibereStructure()
{
    if (TheScanStruct->fileima == 1) {
	if (TheScanStruct->fima != NULL) {
	    fclose(TheScanStruct->fima);
	    TheScanStruct->fima = NULL;
	}
    }
    if (TheScanStruct->fileima == 0) {
	free(TheScanStruct->pix);
    }
    free(TheScanStruct->dateobs);
    free(TheScanStruct->dateend);
    free(TheScanStruct->dts);
    free(TheScanStruct);
    TheScanStruct = NULL;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdAudineBreakScan --
 *
 *  Commande d'arret d'acquisition de scan.
 *
 *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
 * -----------------------------------------------------------------------------
 */
int cmdAudineBreakScan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    int retour;

    if (TheScanStruct) {
	TheScanStruct->stop = 1;
	retour = TCL_OK;
    } else {
	Tcl_SetResult(interp, (char*) "No current exposure", TCL_STATIC);
	retour = TCL_ERROR;
    }

    return retour;
}
