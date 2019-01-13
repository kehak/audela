/* camtcl.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

extern struct camini CAM_INI[];

/* --- Global variable for TDI acquisition mode ---*/
static ScanStruct *TheScanStruct = NULL;

static void ScanCallback(ClientData clientData);
static void ScanTerminateSequence(ClientData clientData, int camno,
				  char *reason);
static void ScanTransfer(ClientData clientData);
static void ScanLibereStructure();

int cmdFingerlakesNbFlushes(ClientData clientData, Tcl_Interp * interp,
			    int argc, char *argv[])
{
    int retour = TCL_OK;
    int i;
    struct camprop *cam;
    char ligne[1024];

    cam = (struct camprop *) clientData;
    if (argc == 2) {
	sprintf(ligne, "%d", cam->nb_flushes);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_OK;
    } else if (argc == 3) {
	i = atoi(argv[2]);
	fingerlakes_nbflushes(cam, i);
	Tcl_ResetResult(interp);
	retour = TCL_OK;
    } else {
	sprintf(ligne, "%s %s [0<=nb<=10]", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
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
 *  cmdFingerlakesScanLoop()
 *
 *  Calcule le nombre de boucles pour attendre une milliseconde en mode cli
 *  C'est une fonction a utiliser avant de faire un scan avec l'option -fast.
 *
 *  buf scanloop
 *
 * -----------------------------------------------------------------------------
 */
int cmdFingerlakesScanLoop(ClientData clientData, Tcl_Interp * interp,
			   int argc, char *argv[])
{
    char ligne[100];
    sprintf(ligne, "%ld", loopsmillisec());
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdFingerlakesScan()
 *
 *  Lance un scan.
 *
 *  buf scan width height bin dt
 *    - width : largeur de l'image
 *    - height : largeur de l'image
 *    - bin : facteur de binning
 *    - dt : intervalle de temps entre chaque lecture de ligne (en ms, float)
 *    - -firstpix index : la fenetre commence au pixel numéro (1 a DimX).
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
int cmdFingerlakesScan(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
    int w;			/* parametre d'appel : largeur */
    int h;			/* parametre d'appel : hauteur */
    int b;			/* parametre d'appel : binning */
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
    char msgtcl[] =
	"Usage: %s %s width height bin dt ?-firstpix index? ?-fast speed? ?-perfo? ?-tmpfile?";
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
		sprintf(ligne2,
			"%s\nwidth : must be an integer between 1 and %d",
			msgtcl, cam->nb_photox);
		sprintf(ligne, ligne2, argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		retour = TCL_ERROR;
	    } else if (Tcl_GetInt(interp, argv[3], &h) != TCL_OK) {
		sprintf(ligne2, "%s\nheight : must be an integer >= 1",
			msgtcl);
		sprintf(ligne, ligne2, argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		retour = TCL_ERROR;
	    } else if (Tcl_GetInt(interp, argv[4], &b) != TCL_OK) {
		sprintf(ligne2, "%s\nbin : must be an integer >= 1",
			msgtcl);
		sprintf(ligne, ligne2, argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		retour = TCL_ERROR;
	    } else if (Tcl_GetDouble(interp, argv[5], &dt) != TCL_OK) {
		sprintf(ligne2,
			"%s\ndt : must be an floating point number >= 0, expressed in milliseconds",
			msgtcl);
		sprintf(ligne, ligne2, argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		retour = TCL_ERROR;
	    } else {
		for (i = 6; i < argc; i++) {
		    if ((strcmp(argv[i], "-offset") == 0)
			|| (strcmp(argv[i], "-firstpix") == 0)) {
			if (Tcl_GetInt(interp, argv[++i], &offset) !=
			    TCL_OK) {
			    sprintf(ligne,
				    "Usage: %s %s width height bin dt ?-firstpix index? ?-blocking? ?-perfo?\nfirstpix index \"%s\" must be an integer",
				    argv[0], argv[1], argv[i]);
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
		    /* Pour avertir les gens du status de la camera. */
		    //sprintf(ligne, "status_cam%d", cam->camno);
		    //Tcl_SetVar(interp, ligne, "exp", TCL_GLOBAL_ONLY);
          setCameraStatus(cam,"exp");
		    idt = (int) dt;
		    TheScanStruct =
			(ScanStruct *) calloc(1, sizeof(ScanStruct));
		    TheScanStruct->clientData = clientData;
		    TheScanStruct->interp = interp;
		    TheScanStruct->dateobs =
			(char *) calloc(32, sizeof(char));
		    TheScanStruct->dateend =
			(char *) calloc(32, sizeof(char));
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
		    if (b < 1) {
			b = 1;
		    }
		    TheScanStruct->bin = b;
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
			TheScanStruct->pix = (unsigned short *)
			    calloc((unsigned int) (w * h / b),
				   sizeof(unsigned short));
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
		    libcam_get_tel_coord(interp, &TheScanStruct->ra,
					 &TheScanStruct->dec, cam,
					 &status);
		    if (status == 1) {
			TheScanStruct->ra = -1.;
		    }
		    /* Nettoyage du ccd */
		    // TODO passer l'obturateur dans un mode ou il sera ouvert en
		    // permanence, y compris pendant la lecture de l'image.
		    CAM_DRV.shutter_on(cam);
		    cam->x1 = offset;
		    cam->y1 = 0;
		    cam->x2 = offset + w;
		    cam->y2 = CAM_INI[cam->index_cam].maxy;
		    CAM_DRV.set_binning(b, b, cam);
		    CAM_DRV.update_window(cam);
		    cam->exptime = 0;
		    CAM_DRV.start_exp(cam, "amplion");
		    Tcl_Eval(interp, "clock seconds");
		    cam->clockbegin = (int) atoi(Tcl_GetStringResult(interp));
		    TheScanStruct->t0 = libcam_getms();
		    /* Declenche le premier evenement */
		    if (blocking == 0) {
			TheScanStruct->TimerToken =
			    Tcl_CreateTimerHandler(idt, ScanCallback,
						   (ClientData) cam);
			libcam_GetCurrentFITSDate(interp,
						  TheScanStruct->dateobs);
			Tcl_ResetResult(interp);
		    } else {
			nb_lignes = TheScanStruct->height;
			libcam_GetCurrentFITSDate(interp,
						  TheScanStruct->dateobs);
			if (cam->authorized == 1) {
			    if (cam->interrupt == 1) {
				libcam_bloquer();
			    }
			    for (i = 0; i < nb_lignes; i++) {
				ScanCallback((ClientData) cam);
				next_occur = (long) TheScanStruct->dt;
				TheScanStruct->last_delta =
				    (int) next_occur;
				TheScanStruct->dts[i] = (int) next_occur;
				for (msloop10 = 0, msloop = 0;
				     msloop <
				     next_occur *
				     TheScanStruct->loopmilli1; msloop++) {
				    msloops[msloop10] =
					(unsigned long) (0);
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
			libcam_GetCurrentFITSDate(interp,
						  TheScanStruct->dateend);
			ScanTerminateSequence(clientData, cam->camno,
					      "Normally terminated.");
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
 * ScanCallback --
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
void ScanCallback(ClientData clientData)
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
	fingerlakes_read_line(cam, TheScanStruct->width,
			      TheScanStruct->offset, TheScanStruct->bin,
			      buf);
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
    w = (TheScanStruct->width / TheScanStruct->bin);
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
	ScanTerminateSequence(clientData, cam->camno,
			      "User aborted exposure.");
    } else if (TheScanStruct->y < TheScanStruct->height) {	/* On continue : */
	n1 = TheScanStruct->t0;
	n2 = (unsigned long) ((TheScanStruct->y + 1) * TheScanStruct->dt);
	n3 = libcam_getms();
	next_occur = (long) (n1 + n2 - n3);
	TheScanStruct->last_delta = (int) next_occur;
	TheScanStruct->dts[TheScanStruct->y - 1] = (int) next_occur;
	if (next_occur <= 0) {	/* ben non : decalage temporel trop grand, on arrete l'image. */
	    libcam_GetCurrentFITSDate(TheScanStruct->interp,
				      TheScanStruct->dateend);
	    ScanTerminateSequence(clientData, cam->camno,
				  "Error : Aborted because CCD line transfers couldn't be re-scheduled (too busy system, or dt too small).");
	} else {		/* OK on continue */
	    TheScanStruct->TimerToken =
		Tcl_CreateTimerHandler((int) next_occur, ScanCallback,
				       (ClientData) cam);
	}
    } else {			/* Image terminee : */
	libcam_GetCurrentFITSDate(TheScanStruct->interp,
				  TheScanStruct->dateend);
	ScanTerminateSequence(clientData, cam->camno,
			      "Normally terminated.");
    }
}

void ScanTerminateSequence(ClientData clientData, int camno, char *reason)
{
   //char s[80];
   FILE *f;
   int i;
   if (TheScanStruct->fileima == 1) {
      fclose(TheScanStruct->fima);
      TheScanStruct->fima = NULL;
   }
   ScanTransfer((struct camprop *)clientData);
   //sprintf(s, "scan_result%d", camno);
   //Tcl_SetVar(TheScanStruct->interp, s, reason, TCL_GLOBAL_ONLY);
   setScanResult((struct camprop *)clientData, reason);
   //sprintf(s, "status_cam%d", camno);
   //Tcl_SetVar(TheScanStruct->interp, s, "stand", TCL_GLOBAL_ONLY);
   setCameraStatus((struct camprop *)clientData,"stand");
   if (TheScanStruct->keep_perfos) {
      f = fopen("scanperf.txt", "wt");
      for (i = 0; i < TheScanStruct->height; i++) {
         fprintf(f, "%d %d\n", i, TheScanStruct->dts[i]);
      }
      fclose(f);
   }
   ScanLibereStructure();
}

/*
 * ScanTransfer --
 *
 * Transfere l'image accumulee dans un buffer accessible depuis les
 * scripts TCL.
 *
 * Effets de bord :
 *   - Buffer realloue et rempli de l'image acquise.
 *
 */
void ScanTransfer(ClientData clientData)
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
    naxis1 = TheScanStruct->width / TheScanStruct->bin;
    naxis2 = TheScanStruct->y;
    bin1 = TheScanStruct->bin;
    bin2 = TheScanStruct->bin;
    dt = TheScanStruct->dt / 1000.;
    exptime = -1;

    /* peu importe le nom de fonction qui suit buf1 */
    sprintf(s, "buf%d bitpix", cam->bufno);
    if (Tcl_Eval(interp, s) == TCL_ERROR) {
	/* Creation du buffer car il n'existe pas */
	sprintf(s, "buf::create %d", cam->bufno);
	Tcl_Eval(interp, s);
    }

    sprintf(s, "buf%d format %d %d", cam->bufno, naxis1, naxis2);
    Tcl_Eval(interp, s);
    sprintf(s, "buf%d pointer", cam->bufno);
    Tcl_Eval(interp, s);
    pp = (float *) atoi(Tcl_GetStringResult(interp));

    strcpy(dateobs_tu, TheScanStruct->dateobs);
    strcpy(dateend_tu, TheScanStruct->dateend);

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

    /* Transfert du fichier ou memoire temporaire dans le buffer image */
    t = naxis1 * naxis2;
    if (TheScanStruct->fileima == 1) {
	TheScanStruct->fima = fopen("#scan.bin", "rb");
	if (TheScanStruct->fima != NULL) {
	    tt = 0;
	    while (tt < t) {
		fread(&tmp, sizeof(unsigned short), 1,
		      TheScanStruct->fima);
		*(pp + tt++) = (float) tmp;
	    }
	    fclose(TheScanStruct->fima);
	    TheScanStruct->fima = NULL;
	}
    } else {
	while (--t >= 0)
	    *(pp + t) = (float) *(TheScanStruct->pix + t);
    }

    sprintf(s, "buf%d bitpix ushort", cam->bufno);
    Tcl_Eval(interp, s);

    sprintf(s, "buf%d setkwd {NAXIS1 %d int \"\" \"\"}", cam->bufno,
	    naxis1);
    Tcl_Eval(interp, s);
    sprintf(s, "buf%d setkwd {NAXIS2 %d int \"\" \"\"}", cam->bufno,
	    naxis2);
    Tcl_Eval(interp, s);
    sprintf(s, "buf%d setkwd {BIN1 %d int \"\" \"\"}", cam->bufno, bin1);
    Tcl_Eval(interp, s);
    sprintf(s, "buf%d setkwd {BIN2 %d int \"\" \"\"}", cam->bufno, bin2);
    Tcl_Eval(interp, s);
    sprintf(s,
	    "buf%d setkwd {DATE-OBS %s string \"Begin of scan exposure.\" \"\"}",
	    cam->bufno, dateobs_tu);
    Tcl_Eval(interp, s);
    sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"\"}", cam->bufno,
	    exptime);
    Tcl_Eval(interp, s);
    sprintf(s,
	    "buf%d setkwd {DATE-END %s string \"End of scan exposure.\" \"\"}",
	    cam->bufno, dateend_tu);
    Tcl_Eval(interp, s);
    sprintf(s,
	    "buf%d setkwd {SP %lu int \"Asked speed parameter for fast\" \"\"}",
	    cam->bufno, TheScanStruct->loopmilli1);
    Tcl_Eval(interp, s);
    sprintf(s,
	    "buf%d setkwd {SPEFF %d int \"Effective speed parameter for fast\" \"\"}",
	    cam->bufno, (int) bloceff);
    Tcl_Eval(interp, s);
    sprintf(s,
	    "buf%d setkwd {DT %f float \"Asked Time Delay Integration\" \"s/line\"}",
	    cam->bufno, dt);
    Tcl_Eval(interp, s);
    sprintf(s,
	    "buf%d setkwd {DTEFF %f float \"Effective Time Delay Integration\" \"s/line\"}",
	    cam->bufno, dteff);
    Tcl_Eval(interp, s);

    libcam_get_tel_coord(interp, &ra, &dec, cam, &status);
    if (status == 0) {
	/* Add FITS keywords */
	sprintf(s,
		"buf%d setkwd {RA %f float \"Right ascension telescope at the end\" \"\"}",
		cam->bufno, ra);
	Tcl_Eval(interp, s);
	sprintf(s,
		"buf%d setkwd {DEC %f float \"Declination telescope at the end\" \"\"}",
		cam->bufno, dec);
	Tcl_Eval(interp, s);
    }
    if (TheScanStruct->ra != -1.) {
	/* Add FITS keywords */
	sprintf(s,
		"buf%d setkwd {RA_BEG %f float \"Right ascension telescope at the begining\" \"\"}",
		cam->bufno, TheScanStruct->ra);
	Tcl_Eval(interp, s);
	sprintf(s,
		"buf%d setkwd {DEC_BEG %f float \"Declination telescope at the begining\" \"\"}",
		cam->bufno, TheScanStruct->dec);
	Tcl_Eval(interp, s);
    }

    //sprintf(s, "status_cam%d", cam->camno);
    //Tcl_SetVar(interp, s, "stand", TCL_GLOBAL_ONLY);
    setCameraStatus(cam,"stand");

}

/*
 * ScanLibereStructure --
 *
 * Libere la structure necessaire au fonctionnement du scan.
 *
 * Effets de bord :
 *   - Structure liberee et remise a NULL.
 *
 */
void ScanLibereStructure()
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
 *  cmdFingerlakesBreakScan --
 *
 *  Commande d'arret d'acquisition de scan.
 *
 *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
 * -----------------------------------------------------------------------------
 */
int cmdFingerlakesBreakScan(ClientData clientData, Tcl_Interp * interp,
			    int argc, char *argv[])
{
    int retour;

    if (TheScanStruct) {
	TheScanStruct->stop = 1;
	retour = TCL_OK;
    } else {
	Tcl_SetResult(interp, "No current exposure", TCL_STATIC);
	retour = TCL_ERROR;
    }

    return retour;
}

int cmdFingerlakesCoolerPower(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    char s[100];
    double power;

    fingerlakes_cooler_power((struct camprop *)clientData, &power);
    sprintf(s,"%lf",power);
    Tcl_SetResult(interp,s,TCL_VOLATILE);
    return TCL_OK;
}

int cmdFingerlakesGetTempPower(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[100];
   double internalTemp;
   double externalTemp;
   double power;
   struct camprop *cam= (struct camprop *)clientData;
   if ( fingerlakes_getTempPower(cam, &internalTemp, &externalTemp, &power) == 0 ) {      
      sprintf(s,"%lf %lf %lf", internalTemp, externalTemp, power);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
   } else {
      Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
      return TCL_ERROR;
   }
}


int cmdFingerlakesFLIDebug(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    int err;

    if (argc == 2 ) {
        if ( flidebuglevel == FLIDEBUG_NONE ) {
            Tcl_SetResult(interp,"none",TCL_STATIC);
            return TCL_OK;
        }
        if ( flidebuglevel == FLIDEBUG_INFO ) {
            Tcl_SetResult(interp,"info",TCL_STATIC);
            return TCL_OK;
        }
        if ( flidebuglevel == FLIDEBUG_WARN ) {
            Tcl_SetResult(interp,"warn",TCL_STATIC);
            return TCL_OK;
        }
        if ( flidebuglevel == FLIDEBUG_FAIL ) {
            Tcl_SetResult(interp,"fail",TCL_STATIC);
            return TCL_OK;
        }
        if ( flidebuglevel == FLIDEBUG_ALL ) {
            Tcl_SetResult(interp,"all",TCL_STATIC);
            return TCL_OK;
        }
    }
    if ( ! strcmp(argv[2], "none" ) ) {
        if ( ( err = FLISetDebugLevel(NULL,FLIDEBUG_NONE) ) ) {
           Tcl_SetResult(interp,"Can't set debug level to none",TCL_STATIC);
           return TCL_ERROR;
        }
        flilogactivated = 0;
    } else if ( ! strcmp(argv[2], "info" ) ) {
        if ( ( err = FLISetDebugLevel(NULL,FLIDEBUG_INFO) ) ) {
           Tcl_SetResult(interp,"Can't set debug level to info",TCL_STATIC);
           return TCL_ERROR;
        }
        flilogactivated = 1;
    } else if ( ! strcmp(argv[2], "warn" ) ) {
        if ( ( err = FLISetDebugLevel(NULL,FLIDEBUG_WARN) ) ) {
           Tcl_SetResult(interp,"Can't set debug level to warn",TCL_STATIC);
           return TCL_ERROR;
        }
        flilogactivated = 1;
    } else if ( ! strcmp(argv[2], "fail" ) ) {
        if ( ( err = FLISetDebugLevel(NULL,FLIDEBUG_FAIL) ) ) {
           Tcl_SetResult(interp,"Can't set debug level to fail",TCL_STATIC);
           return TCL_ERROR;
        }
        flilogactivated = 1;
    } else if ( ! strcmp(argv[2], "all" ) ) {
        if ( ( err = FLISetDebugLevel(NULL,FLIDEBUG_ALL) ) ) {
           Tcl_SetResult(interp,"Can't set debug level to all",TCL_STATIC);
           return TCL_ERROR;
        }
        flilogactivated = 1;
    }
    Tcl_ResetResult(interp);
    return TCL_OK;
}
int cmdFingerlakesFLIModes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int err, i;
   char s[100];
   Tcl_DString dsptr;
   struct camprop *cam;
   
   cam = (struct camprop *) clientData;

   if (argc != 2 ) {
      sprintf(s,"%s %s", argv[0], argv[1]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }

   Tcl_DStringInit(&dsptr);
   i = 0;
   while(1) {
      if ((err = FLIGetCameraModeString(cam->device,i,s,100)))
         break;
      Tcl_DStringAppend(&dsptr,"{",-1);
      Tcl_DStringAppend(&dsptr,s,-1);
      Tcl_DStringAppend(&dsptr,"} ",-1);
      i++;
   }
   Tcl_DStringResult(interp,&dsptr);
   Tcl_DStringFree(&dsptr);
   return TCL_OK;
}

int cmdFingerlakesFLIMode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[100];
   struct camprop *cam;
   flimode_t mode;
   int err;
   
   cam = (struct camprop *) clientData;

   if (argc > 3 ) {
      sprintf(s,"%s %s {mode}", argv[0], argv[1]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
   
   if (argc == 2) {
      // On renvoie le mode
      if ((err = FLIGetCameraMode(cam->device,&mode))) {
         Tcl_SetResult(interp, "cmdFingerlakesFLIMode: could not get mode", TCL_STATIC);
         return TCL_ERROR;
      }
      sprintf(s,"%d", (int)mode);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
   }

   // On change le mode
   if (Tcl_GetInt(interp, argv[2], (int*)&mode) != TCL_OK) {
      Tcl_SetResult(interp, "mode shall be an integer", TCL_STATIC);
      return TCL_ERROR;
   }
   if ((err = FLISetCameraMode(cam->device,mode))) {
      Tcl_SetResult(interp, "cmdFingerlakesFLIMode: could not set mode", TCL_STATIC);
      return TCL_ERROR;
   }
   
   Tcl_ResetResult(interp);
   return TCL_OK;
}



int cmdFingerlakesGetWheelInfo(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   struct filtprop *filt;
   filt = (struct filtprop *) clientData;
   
   if (FLIGetFilterPos(filt->device, &(filt->WhereIAm))) return TCL_ERROR;
   if (FLIGetFilterCount(filt->device, &(filt->filter_number))) return TCL_ERROR;
   return cmdFingerlakesGetFilterDef(clientData, interp, argc, argv);
}

int cmdFingerlakesGetFilterDef(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   struct filtprop *filt;
   filt = (struct filtprop *) clientData;
   int i = 0;
   // short name of filters
   filt->short_name[0]="OFCIUVBRffff";
   // Long name of filters
   int remaining_slots = filt->filter_number;
   for (i=0;i<12; i++) {
	  filt->position[i]=i;
   }
   
   /*   
   file =fopen(filename, "r");
   if (file != NULL) {
	   fgets(buffer, 1000, file);
	   if (strncmp (buffer,"FILTER",6) == 0) {
		   // copy the string into a string for better use
		   my_result = buffer;
		   // get the filter number, at pos6
		   filt->filter_name[i]->position = atoi(my_result[6]);
		   filt->filter_name[i]->short_name = ....
		   i++;
		   if (i > remaining_slots -1) return TCL_ERROR;
	   }
   };*/
   return TCL_OK;
}


int cmdFingerlakesGetWheelPos(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   struct filtprop *filt;
   filt = (struct filtprop *) clientData;
   if (FLIGetFilterPos(filt->device, &(filt->WhereIAm))) return TCL_ERROR;
   return TCL_OK;
}


int cmdFingerlakesMoveWheel(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   struct filtprop *filt;
   filt = (struct filtprop *) clientData;
   filt->WhereIAm++;
   FLISetFilterPos(filt->device, filt->WhereIAm);
   return TCL_OK;
}

int cmdFingerlakesGotoFilter(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   struct filtprop *filt;
   filt = (struct filtprop *) clientData;
   filt->WhereIAm = atoi(argv[2]);
   FLISetFilterPos(filt->device, filt->WhereIAm);
   return TCL_OK;
}

int cmdFingerlakesGotoClosed(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   struct filtprop *filt;
   filt = (struct filtprop *) clientData;
   filt->WhereIAm = 1;
   FLISetFilterPos(filt->device, filt->WhereIAm);
   return TCL_OK;
}

int cmdFingerlakesOpenWheel(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   struct filtprop *filt;
   char **listname;
   filt = (struct filtprop *) clientData;
   if (FLIList(FLIDEVICE_FILTERWHEEL | FLIDOMAIN_USB, &listname)) return TCL_ERROR;
   if (listname[0] == NULL) return TCL_ERROR;
   char *fliname = strdup(listname[0]);
   char *semicolon = strchr(fliname, ';');
   if (semicolon) {
      *semicolon = '\0';
   }
   if (FLIFreeList(listname)) return TCL_ERROR;
   if (FLIOpen(&filt->device, fliname, FLIDEVICE_FILTERWHEEL | FLIDOMAIN_USB)) return TCL_ERROR;
   return TCL_OK;
}

int cmdFingerlakesCloseWheel(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   struct filtprop *filt;
   filt = (struct filtprop *) clientData;
   if (FLIClose(filt->device)) return TCL_ERROR;
//   delete filt->filter_name;
   return TCL_OK;
}


int cmdFingerlakesCloseFilter(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   return cmdFingerlakesCloseWheel(clientData, interp, argc, argv);
}


int cmdFingerlakesScanForWheel(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   struct filtprop *filt;
   char **listname;
   filt = (struct filtprop *) clientData;
   if (FLIList(FLIDEVICE_FILTERWHEEL, &listname)) return TCL_ERROR;
   if (FLIFreeList(listname)) return TCL_ERROR;
   return TCL_OK;
}
			   
int cmdFingerlakesInitFilter(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
   if (cmdFingerlakesOpenWheel(clientData, interp, argc, argv) != TCL_OK) return TCL_ERROR;
   if (cmdFingerlakesGetWheelInfo(clientData, interp, argc, argv) != TCL_OK) return TCL_ERROR;
   if (cmdFingerlakesGotoClosed(clientData, interp, argc, argv) != TCL_OK) return TCL_ERROR;
   return TCL_OK;
}
		   

int cmdFingerlakesFLIIOPort(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[100];
   struct camprop *cam;
   flimode_t mode;
   int err;
	long ioportset=0;
   
   cam = (struct camprop *) clientData;

   if (argc < 3 ) {
      sprintf(s,"%s %s configure|read|write ?state?", argv[0], argv[1]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }

	if (strcmp(argv[2],"configure")==0) {
		if (argc < 4) {
			sprintf(s,"%s %s configure ioportset", argv[0], argv[1]);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		ioportset = atoi(argv[3]);
		if ((err = FLIConfigureIOPort(cam->device,ioportset))) {
         Tcl_SetResult(interp, "FLIConfigureIOPort: could not configure ioportset", TCL_STATIC);
         return TCL_ERROR;
      }
	} else if (strcmp(argv[2],"write")==0) {
		if (argc < 4) {
			sprintf(s,"%s %s write ioportset", argv[0], argv[1]);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		ioportset = atoi(argv[3]);
		if ((err = FLIWriteIOPort(cam->device,ioportset))) {
         Tcl_SetResult(interp, "FLIWriteIOPort: could not configure ioportset", TCL_STATIC);
         return TCL_ERROR;
      }
	} else if (strcmp(argv[2],"read")==0) {
		if ((err = FLIReadIOPort(cam->device,&ioportset))) {
         Tcl_SetResult(interp, "FLIReadIOPort: could not read ioportset", TCL_STATIC);
         return TCL_ERROR;
      }
	} else {
      sprintf(s,"%s %s configure|read|write ?state?", argv[0], argv[1]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
	}
	sprintf(s,"%d",ioportset);
   Tcl_SetResult(interp,s, TCL_STATIC);
   return TCL_OK;
}
