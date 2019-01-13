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

extern struct camini CAM_INI[];

static void AcqReadTrack(ClientData clientData);

/*
int cmdSbigClose(ClientData clientData, Tcl_Interp * interp, int argc,
		 char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sbig_cam_close(cam);
    Tcl_SetResult(interp, "", TCL_VOLATILE);
    return TCL_OK;
}
*/

int cmdSbigInfotemp(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[])
{
/***********************************************************************/
/* cmdCamActivateRelay : used to activate one or more of the telescope */
/* control outputs or to cancel an activation in progress.             */
/*                                                                     */
/* INPUTS                                                              */
/* none                                                                */
/*                                                                     */
/* OUTPUT                                                              */
/* float : check temperature (deg. Celcius)                            */
/* float : CCD temperature (deg. Celcius)                              */
/* float : ambient temperature (deg. Celcius)                          */
/* int   : regulation, 1=on, 0=off                                     */
/* int   : Peltier power, (0-255=0-100%)                               */
/***********************************************************************/
    /*
       // setpoint = température de consigne
       // ccd = température du ccd
       // ambient = température ambiante
       // reg = régulation ?
       // power = puissance du peltier (0-255=0-100%)
     */
    struct camprop *cam;
    double setpoint, ccd, ambient;
    int reg, power;
    char s[256];
    cam = (struct camprop *) clientData;
    sbig_get_info_temperatures(cam, &setpoint, &ccd, &ambient, &reg,
			       &power);
    sprintf(s, "%f %f %f %d %d", setpoint, ccd, ambient, reg, power);
    Tcl_SetResult(interp, s, TCL_VOLATILE);
    return TCL_OK;
}

int cmdSbigActivateRelay(ClientData clientData, Tcl_Interp * interp,
			 int argc, char *argv[])
/***********************************************************************/
/* cmdCamActivateRelay : used to activate one or more of the telescope */
/* control outputs or to cancel an activation in progress.             */
/*                                                                     */
/* INPUTS                                                              */
/* tXPlus  : x plus activation duration in hundredths of a second.     */
/* tXMinus : x minus activation duration in hundredths of a second.    */
/* tYPlus  : y plus activation duration in hundredths of a second.     */
/* tYMinus : y minus activation duration in hundredths of a second.    */
/*                                                                     */
/* OUTPUT                                                              */
/* int : x plus status, 0=off, 1=active                                */
/* int : x minus status, 0=off, 1=active                               */
/* int : y plus status, 0=off, 1=active                                */
/* int : y minus status, 0=off, 1=active                               */
/***********************************************************************/
{
    char ligne[256];
    int b[4];
    struct camprop *cam;
    int xplus = 0, xmoins = 0, yplus = 0, ymoins = 0;
    int res, k;
    ActivateRelayParams arp;
    QueryCommandStatusParams qcsp;
    QueryCommandStatusResults qcsr;

    if ((argc != 6) && (argc != 2)) {
	sprintf(ligne, "Usage: %s %s tXPlus tXMinus tYPlus tYMinus",
		argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	return TCL_ERROR;
    } else {
	cam = (struct camprop *) clientData;
	if (argc == 6) {
	    xplus = atoi(argv[2]);
	    xmoins = atoi(argv[3]);
	    yplus = atoi(argv[4]);
	    ymoins = atoi(argv[5]);
	    if (xplus < 0) {
		xplus = 0;
	    }
	    if (xmoins < 0) {
		xmoins = 0;
	    }
	    if (yplus < 0) {
		yplus = 0;
	    }
	    if (ymoins < 0) {
		ymoins = 0;
	    }
	    arp.tXPlus = (unsigned short) xplus;
	    arp.tXMinus = (unsigned short) xmoins;
	    arp.tYPlus = (unsigned short) yplus;
	    arp.tYMinus = (unsigned short) ymoins;
	    cam->drv_status = pardrvcommand(CC_ACTIVATE_RELAY, &arp, NULL);
	    if (cam->drv_status != 0) {
		sprintf(ligne, "Error %d. %s", cam->drv_status,
			sbig_get_status(cam->drv_status));
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	    }
	}
	b[0] = 0;
	b[1] = 0;
	b[2] = 0;
	b[3] = 0;
	qcsp.command = (unsigned short) CC_ACTIVATE_RELAY;
	cam->drv_status =
	    pardrvcommand(CC_QUERY_COMMAND_STATUS, &qcsp, &qcsr);
	if (cam->drv_status == 0) {
	    res = (int) qcsr.status;
	    for (k = 0; k < 4; k++) {
		b[k] = (int) (res - 2 * floor((double)(res / 2)));
		res = (int) floor((double)(res / 2));
	    }
	}
	sprintf(ligne, "%d %d %d %d", b[3], b[2], b[1], b[0]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return TCL_OK;
}

int cmdSbigPulseOut(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[])
/***********************************************************************/
/* cmdCamPulseOut : used to position the CFW-6A/CFW-8 of ST7/ST8       */
/* and to position the internal vane/filter wheel of PixCel255/237     */
/*                                                                     */
/* INPUTS                                                              */
/* numberPulses : number of pulses to generate (0-255)                 */
/* pulseWidth : width of pulses (microsec) (>9)                        */
/* pulsePeriod : period of pulses (microsec) (>29+pulseWidth)          */
/*                                                                     */
/* OUTPUT                                                              */
/* int : 0=incative, 1=pulse out in progress                           */
/* int : for PixCel255 or PixCel237, 0=moving, 1-5=position.           */
/***********************************************************************/
{
    char ligne[256];
    int b[4];
    struct camprop *cam;
    int numberpulses = 0, pulsewidth = 9, pulseperiod =
	38, pixcel255237filterstate = 0;
    int res, k;
    PulseOutParams pop;
    QueryCommandStatusParams qcsp;
    QueryCommandStatusResults qcsr;

    if ((argc != 5) && (argc != 2)) {
	sprintf(ligne, "Usage: %s %s numberPulses pulseWidth pulsePeriod",
		argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	return TCL_ERROR;
    } else {
	cam = (struct camprop *) clientData;
	if (argc == 5) {
	    numberpulses = atoi(argv[2]);
	    pulsewidth = atoi(argv[3]);
	    pulseperiod = atoi(argv[4]);
	    if (numberpulses < 0) {
		numberpulses = 0;
	    }
	    if (numberpulses > 255) {
		numberpulses = 255;
	    }
	    if (pulsewidth < 9) {
		pulsewidth = 9;
	    }
	    if (pulseperiod < (29 + pulsewidth)) {
		pulseperiod = 29 + pulsewidth;
	    }
	    pop.numberPulses = (unsigned short) numberpulses;
	    pop.pulseWidth = (unsigned short) pulsewidth;
	    pop.pulsePeriod = (unsigned short) pulseperiod;
	    cam->drv_status = pardrvcommand(CC_PULSE_OUT, &pop, NULL);
	    if (cam->drv_status != 0) {
		sprintf(ligne, "Error %d. %s", cam->drv_status,
			sbig_get_status(cam->drv_status));
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	    }
	}
	b[0] = 0;
	b[1] = 0;
	b[2] = 0;
	b[3] = 0;
	qcsp.command = (unsigned short) CC_PULSE_OUT;
	cam->drv_status =
	    pardrvcommand(CC_QUERY_COMMAND_STATUS, &qcsp, &qcsr);
	if (cam->drv_status == 0) {
	    res = (int) qcsr.status;
	    for (k = 0; k < 4; k++) {
		b[k] = (int) (res - 2 * floor((double)(res / 2)));
		res = (int) floor((double)(res / 2));
	    }
	}
	pixcel255237filterstate = (int) ((2 * (2 * b[3]) + b[2]) + b[1]);
	sprintf(ligne, "%d %d", b[0], pixcel255237filterstate);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return TCL_OK;
}

int cmdSbigAOTipTilt(ClientData clientData, Tcl_Interp * interp, int argc,
		     char *argv[])
/***********************************************************************/
/* cmdCamAOTipTilt : The AO tip tilt is used to position an OA-7       */
/* attached to the telescope port ST7/8/etc.                           */
/*                                                                     */
/* INPUTS                                                              */
/* xDeflection : position in the X axis (0-2048-4095)                  */
/* yDeflection : position in the Y axis (0-2048-4095)                  */
/*                                                                     */
/* OUTPUT                                                              */
/* none                                                                */
/***********************************************************************/
{
    char ligne[256];
    struct camprop *cam;
    int xdeflection = 2048, ydeflection = 2048;
    AOTipTiltParams aottp;

    if ((argc != 4)) {
	sprintf(ligne, "Usage: %s %s xDeflection yDeflection", argv[0],
		argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	return TCL_ERROR;
    } else {
	cam = (struct camprop *) clientData;
	xdeflection = atoi(argv[2]);
	ydeflection = atoi(argv[3]);
	if (xdeflection < 0) {
	    xdeflection = 0;
	}
	if (xdeflection > 4095) {
	    xdeflection = 4095;
	}
	if (ydeflection < 0) {
	    ydeflection = 0;
	}
	if (ydeflection > 4095) {
	    ydeflection = 4095;
	}
	aottp.xDeflection = (unsigned short) xdeflection;
	aottp.yDeflection = (unsigned short) ydeflection;
	cam->drv_status = pardrvcommand(CC_AO_TIP_TILT, &aottp, NULL);
	if (cam->drv_status != 0) {
	    sprintf(ligne, "Error %d. %s", cam->drv_status,
		    sbig_get_status(cam->drv_status));
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    return TCL_ERROR;
	}
	Tcl_SetResult(interp, "", TCL_VOLATILE);
    }
    return TCL_OK;
}


int cmdSbigAODelay(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[])
/***********************************************************************/
/* cmdCamAODelay : used to generate daleys for exposing the tracking   */
/* CCD.                                                                */
/*                                                                     */
/* INPUTS                                                              */
/* delay : desired delay in microseconds (or millisec ?)               */
/*                                                                     */
/* OUTPUT                                                              */
/* none                                                                */
/***********************************************************************/
{
    char ligne[256];
    struct camprop *cam;
    int delay;
    AODelayParams aodp;

    if ((argc != 3)) {
	sprintf(ligne, "Usage: %s %s delay", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	return TCL_ERROR;
    } else {
	cam = (struct camprop *) clientData;
	delay = atoi(argv[2]);
	if (delay < 0) {
	    delay = 0;
	}
	aodp.delay = (unsigned short) delay;
	cam->drv_status = pardrvcommand(CC_AO_DELAY, &aodp, NULL);
	if (cam->drv_status != 0) {
	    sprintf(ligne, "Error %d. %s", cam->drv_status,
		    sbig_get_status(cam->drv_status));
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    return TCL_ERROR;
	}
	Tcl_SetResult(interp, "", TCL_VOLATILE);
    }
    return TCL_OK;
}

/*
 * cmdSbigBufTrack
 * Lecture/ecriture du numero de buffer associe a la camera track.
 */
int cmdSbigBufTrack(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[])
{
    char ligne[256];
    int i_bufno, result = TCL_OK;
    struct camprop *cam;

    if ((argc != 2) && (argc != 3)) {
	sprintf(ligne, "Usage: %s %s ?bufno?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%d", cam->bufnotrack);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	if (Tcl_GetInt(interp, argv[2], &i_bufno) != TCL_OK) {
	    sprintf(ligne,
		    "Usage: %s %s ?bufno?\nbufno : must be an integer > 0",
		    argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else {
	    cam = (struct camprop *) clientData;
	    cam->bufnotrack = i_bufno;
	    sprintf(ligne, "%d", cam->bufnotrack);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	}
    }
    return result;
}

/*
 * AcqReadTrack
 * Commande de lecture du CCD.
 */
void AcqReadTrack(ClientData clientData)
{
    int naxis1, naxis2, bin1, bin2;
    char s[100];
    float *p;		/* cameras de 1 a 16 bits non signes */
    double ra, dec, exptime = 0.;
    float *pp;
    int t, status;
    struct camprop *cam;
    Tcl_Interp *interp;

    cam = (struct camprop *) clientData;
    interp = cam->interp;
    naxis1 = cam->wtrack;
    naxis2 = cam->htrack;
    bin1 = cam->binxtrack;
    bin2 = cam->binytrack;

    p = (float*) calloc(naxis1 * naxis2, sizeof(float));

    libcam_GetCurrentFITSDate(interp, cam->date_endtrack);

    /*cam_stop_exp(cam); */
    sbig_cam_read_ccdtrack(cam, p);

    /*
     * Ce test permet de savoir si le buffer existe
     */
    sprintf(s, "buf%d bitpix", cam->bufnotrack);
    if (Tcl_Eval(interp, s) == TCL_ERROR) {
	/* Creation du buffer */
	/*
	   sprintf(s,"%s%s",CAM_LIBNAME,CAM_LIBVER);
	   MessageBox(NULL,"Creation du buffer",s,MB_OK);
	 */
	sprintf(s, "buf::create %d", cam->bufnotrack);
	Tcl_Eval(interp, s);
    }

    sprintf(s, "buf%d format %d %d", cam->bufnotrack, naxis1, naxis2);
    Tcl_Eval(interp, s);
    sprintf(s, "buf%d pointer", cam->bufnotrack);
    Tcl_Eval(interp, s);

    pp = (float *) atoi(Tcl_GetStringResult(interp));

    t = naxis1 * naxis2;
    while (--t >= 0)
	*(pp + t) = (float) *((unsigned short *) (p + t));

    sprintf(s, "buf%d bitpix ushort", cam->bufnotrack);
    Tcl_Eval(interp, s);

    /* Add FITS keywords */
    sprintf(s, "buf%d setkwd {NAXIS1 %d int \"\" \"\"}", cam->bufnotrack,
	    naxis1);
    Tcl_Eval(interp, s);
    sprintf(s, "buf%d setkwd {NAXIS2 %d int \"\" \"\"}", cam->bufnotrack,
	    naxis2);
    Tcl_Eval(interp, s);
    sprintf(s, "buf%d setkwd {BIN1 %d int \"\" \"\"}", cam->bufnotrack,
	    bin1);
    Tcl_Eval(interp, s);
    sprintf(s, "buf%d setkwd {BIN2 %d int \"\" \"\"}", cam->bufnotrack,
	    bin2);
    Tcl_Eval(interp, s);
    sprintf(s, "buf%d setkwd {DATE-OBS %s string \"\" \"\"}",
	    cam->bufnotrack, cam->date_obstrack);
    Tcl_Eval(interp, s);
    if (cam->timerExpirationTrack != NULL) {
	sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"s\"}",
		cam->bufnotrack, cam->exptimetrack);
    } else {
	sprintf(s, "expr (([mc_date2jd %s]-[mc_date2jd %s])*86400.)",
		cam->date_endtrack, cam->date_obstrack);
	Tcl_Eval(interp, s);
	exptime = atof(Tcl_GetStringResult(interp));
	sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"s\"}",
		cam->bufnotrack, exptime);
    }
    Tcl_Eval(interp, s);

    libcam_get_tel_coord(interp, &ra, &dec, cam, &status);
    if (status == 0) {
	/* Add FITS keywords */
	sprintf(s,
		"buf%d setkwd {RA %f float \"Right ascension telescope encoder\" \"\"}",
		cam->bufno, ra);
	Tcl_Eval(interp, s);
	sprintf(s,
		"buf%d setkwd {DEC %f float \"Declination telescope encoder\" \"\"}",
		cam->bufno, dec);
	Tcl_Eval(interp, s);
    }
    if (cam->timerExpirationTrack != NULL) {
	sprintf(s, "status_track_cam%d", cam->camno);
    }
    Tcl_SetVar(interp, s, "stand", TCL_GLOBAL_ONLY);
    cam->clockbegin = 0;

    if (cam->timerExpirationTrack != NULL) {
	free(cam->timerExpirationTrack);
	cam->timerExpirationTrack = NULL;
    }
    free(p);
}


/*
 * cmdSbigAcqTrack()
 * Commande de demarrage d'une acquisition.
 */
int cmdSbigAcqTrack(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[])
{
    char *ligne;
    int i;
    struct camprop *cam;
    int result = TCL_OK;

    ligne = (char *) calloc(100, sizeof(char));
    if (argc != 2) {
	sprintf(ligne, "Usage: %s %s", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	cam = (struct camprop *) clientData;
	if (cam->timerExpirationTrack == NULL) {
	    /* Pour avertir les gens du status de la camera. */
	    sprintf(ligne, "status__track_cam%d", cam->camno);
	    Tcl_SetVar(interp, ligne, "exp", TCL_GLOBAL_ONLY);

	    i = (int) (1000 * cam->exptimetrack);
	    cam->timerExpirationTrack =
		(struct TimerExpirationStruct *) calloc(1,
							sizeof(struct
							       TimerExpirationStruct));
	    cam->timerExpirationTrack->clientData = clientData;
	    cam->timerExpirationTrack->interp = interp;
	    sbig_cam_start_exptrack(cam, "amplioff");
	    Tcl_Eval(interp, "clock seconds");
	    cam->clockbegin = (unsigned long) atoi(Tcl_GetStringResult(interp));
	    libcam_GetCurrentFITSDate(interp, cam->date_obstrack);
	    /* Creation du timer pour realiser le temps de pose. */
	    cam->timerExpirationTrack->TimerToken =
		Tcl_CreateTimerHandler(i, AcqReadTrack, (ClientData) cam);
	} else {
	    sprintf(ligne, "Camera already in use");
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	}
    }
    return result;
}


/*
 * cmdCamStop()
 * Commande d'arret d'une acquisition.
 */
int cmdSbigStopTrack(ClientData clientData, Tcl_Interp * interp, int argc,
		     char *argv[])
{
    struct camprop *cam;
    int retour = TCL_OK;
    cam = (struct camprop *) clientData;
    if (cam->timerExpirationTrack) {
	if (cam->timerExpirationTrack != NULL) {
            Tcl_DeleteTimerHandler(cam->timerExpirationTrack->TimerToken);
	    free(cam->timerExpirationTrack);
            cam->timerExpirationTrack = NULL;
	}
	sbig_cam_stop_exptrack(cam);
	AcqReadTrack((ClientData) cam);
    } else {
	Tcl_SetResult(interp, "No current exposure", TCL_STATIC);
	retour = TCL_ERROR;
    }
    return retour;
}

int cmdSbigExptimeTrack(ClientData clientData, Tcl_Interp * interp,
			int argc, char *argv[])
{
    int retour = TCL_OK;
    char ligne[256];
    double d_exptime;
    struct camprop *cam;

    if ((argc != 2) && (argc != 3)) {
	sprintf(ligne, "Usage: %s %s ?exptime?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	retour = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%.2f", cam->exptimetrack);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	if (Tcl_GetDouble(interp, argv[2], &d_exptime) != TCL_OK) {
	    sprintf(ligne, "Usage: %s %s ?num?\nnum = must be a float > 0",
		    argv[0], argv[1]);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    retour = TCL_ERROR;
	} else {
	    cam = (struct camprop *) clientData;
	    cam->exptimetrack = (float) d_exptime;
	    sprintf(ligne, "%.2f", cam->exptimetrack);
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	}
    }
    return retour;
}

int cmdSbigWindowTrack(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[])
{
    char ligne[256];
    const char **listArgv;
    int listArgc;
    int i_x1, i_y1, i_x2, i_y2;
    int result = TCL_OK;
    struct camprop *cam;

    if ((argc != 2) && (argc != 3)) {
	sprintf(ligne, "Usage: %s %s ?{x1 y1 x2 y2}?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%d %d %d %d", cam->x1track + 1, cam->y1track + 1,
		cam->x2track + 1, cam->y2track + 1);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	if (Tcl_SplitList(interp, argv[2], &listArgc, &listArgv) != TCL_OK) {
	    sprintf(ligne,
		    "Window struct not valid: must be {x1 y1 x2 y2}");
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else if (listArgc != 4) {
	    sprintf(ligne,
		    "Window struct not valid: must be {x1 y1 x2 y2}");
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else {
	    if (Tcl_GetInt(interp, listArgv[0], &i_x1) != TCL_OK) {
		sprintf(ligne,
			"Usage: %s %s {x1 y1 x2 y2}\nx1 : must be an integer",
			argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else if (Tcl_GetInt(interp, listArgv[1], &i_y1) != TCL_OK) {
		sprintf(ligne,
			"Usage: %s %s {x1 y1 x2 y2}\ny1 : must be an integer",
			argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else if (Tcl_GetInt(interp, listArgv[2], &i_x2) != TCL_OK) {
		sprintf(ligne,
			"Usage: %s %s {x1 y1 x2 y2}\nx2 : must be an integer",
			argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else if (Tcl_GetInt(interp, listArgv[3], &i_y2) != TCL_OK) {
		sprintf(ligne,
			"Usage: %s %s {x1 y1 x2 y2}\ny2 : must be an integer",
			argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else {
		cam = (struct camprop *) clientData;
		cam->x1track = i_x1 - 1;
		cam->y1track = i_y1 - 1;
		cam->x2track = i_x2 - 1;
		cam->y2track = i_y2 - 1;
		sbig_cam_update_windowtrack(cam);
		sprintf(ligne, "%d %d %d %d", cam->x1track + 1,
			cam->y1track + 1, cam->x2track + 1,
			cam->y2track + 1);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    }
	    Tcl_Free((char *) listArgv);
	}
    }
    return result;
}

int cmdSbigBinTrack(ClientData clientData, Tcl_Interp * interp, int argc,
		    char *argv[])
{
    char ligne[256];
    const char **listArgv;
    int listArgc;
    int i_binx, i_biny, result = TCL_OK;
    struct camprop *cam;

    if ((argc != 2) && (argc != 3)) {
	sprintf(ligne, "Usage: %s %s ?{binx biny}?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else if (argc == 2) {
	cam = (struct camprop *) clientData;
	sprintf(ligne, "%d %d", cam->binxtrack, cam->binytrack);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    } else {
	if (Tcl_SplitList(interp, argv[2], &listArgc, &listArgv) != TCL_OK) {
	    sprintf(ligne,
		    "Binning struct not valid: must be {binx biny}");
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else if (listArgc != 2) {
	    sprintf(ligne,
		    "Binning struct not valid: must be {binx biny}");
	    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    result = TCL_ERROR;
	} else {
	    if (Tcl_GetInt(interp, listArgv[0], &i_binx) != TCL_OK) {
		sprintf(ligne,
			"Usage: %s %s {binx biny}\nbinx : must be an integer",
			argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else if (Tcl_GetInt(interp, listArgv[1], &i_biny) != TCL_OK) {
		sprintf(ligne,
			"Usage: %s %s {binx biny}\nbiny : must be an integer",
			argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		result = TCL_ERROR;
	    } else {
		cam = (struct camprop *) clientData;
		CAM_DRV.set_binning(i_binx, i_biny, cam);
		sbig_cam_update_windowtrack(cam);
		sprintf(ligne, "%d %d", cam->binxtrack, cam->binytrack);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	    }
	    Tcl_Free((char *) listArgv);
	}
    }
    return result;
}

int cmdSbigCFW(ClientData clientData, Tcl_Interp * interp,int argc, char *argv[])
/***********************************************************************/
/* cmdSbigCFW : used to set the filter wheel SBIG functions.           */
/***********************************************************************/
{
	char ligne[256],res[2048];
	struct camprop *cam;
	int ret, k, pb ;
	CFWParams params;
	CFWResults results;
	char cfw_model_select[512];
	char cfw_command[512];
	char cfw_position[512];
	char cfw_com_port[512];
	char cfw_getinfo_select[512];
   Tcl_DString dsptr;
	strcpy(cfw_model_select,"0=CFWSEL_UNKNOWN 1=CFWSEL_CFW2 2=CFWSEL_CFW5 3=CFWSEL_CFW8 4=CFWSEL_CFWL 5=CFWSEL_CFW402 6=CFWSEL_AUO 7=CFWSEL_CFW6A 8=CFWSEL_CFW10 9=CFWSEL_CFW10_SERIAL 10=CFWSEL_CFW9 11=CFWSEL_CFWL8 12=CFWSEL_CFWL8G 13=CFWSEL_CFW1603");
	strcpy(cfw_command,"0=CFWC_QUERY 1=CFWC_GOTO 2=CFWC_INIT 3=CFWC_GET_INFO 4=CFWC_OPEN_DEVICE 5=CFWC_CLOSE_DEVICE");
	strcpy(cfw_position,"0=CFWP_UNKNOWN 1=CFWP_1 2=CFWP_2 3=CFWP_3 4=CFWP_4 5=CFWP_5 6=CFWP_6 7=CFWP_7 8=CFWP_8 9=CFWP_9 10=CFWP_10");
	strcpy(cfw_com_port,"0=CFWPORT_COM1=1 1=CFWPORT_COM2 2=CFWPORT_COM3 3=CFWPORT_COM4");
	strcpy(cfw_getinfo_select,"0=CFWG_FIRMWARE_VERSION 1=CFWG_CAL_DATA 2=CFWG_DATA_REGISTERS");
 
	ret=TCL_OK;
	if (argc <= 2) {
		sprintf(ligne, "Usage: %s %s cfwModel cfwCommand ?cwfParam1? ?cwfParam2? ",argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	} else {
	   Tcl_DStringInit(&dsptr);
		cam = (struct camprop *) clientData;
		pb=0;
		// --- Model
		if (argc>=3) {
			k = atoi(argv[2]);
			if ((k < 0)||(k > 12)) {
				pb=1;
				sprintf(res,"cfwModel must be amongst %s. ",cfw_model_select);
	         Tcl_DStringAppend(&dsptr,res,-1);
			} else {
				params.cfwModel=(unsigned short)k;
			}
		}
		// --- Command
		if (argc>=4) {
			k = atoi(argv[3]);
			if ((k >= 0)&&(k <= 5)) {
				params.cfwCommand=(unsigned short)k;
			} else {
				pb=2;
			}
		} else {
			pb=2;
		}
		if (pb==2) {
			sprintf(res,"cfwCommand must be amongst %s. ",cfw_command);
	      Tcl_DStringAppend(&dsptr,res,-1);
		}
		// --- Default other params
		params.cfwParam1=(unsigned long)0;
		params.cfwParam2=(unsigned long)0;
		/*
		params.outLength=(unsigned short)0;
		params.outPtr=(unsigned char*)NULL;
		params.inLength=(unsigned short)0;
		params.inPtr=(unsigned char*)NULL;
		*/
		// --- Command=Goto
		if (params.cfwCommand==(unsigned short)1) {
			if (argc>=5) {
				k = atoi(argv[4]);
				if ((k >= 0)&&(k <= 10)) {
					params.cfwParam1=(unsigned long)k;
				} else {
					pb=3;
				}
			}
			if (pb==3) {
				sprintf(res,"cfwParam1 must be amongst %s. ",cfw_position);
				Tcl_DStringAppend(&dsptr,res,-1);
			}
		}
		// --- Command=Info
		if (params.cfwCommand==(unsigned short)3) {
			if (argc>=5) {
				k = atoi(argv[4]);
				if ((k >= 0)&&(k <= 2)) {
					params.cfwParam1=(unsigned long)k;
				} else {
					pb=4;
				}
			}
			if (pb==4) {
				sprintf(res,"cfwParam1 must be amongst %s. ",cfw_getinfo_select);
				Tcl_DStringAppend(&dsptr,res,-1);
			}
		}
		// --- Command=Open or Close
		if ((params.cfwCommand==(unsigned short)4)||(params.cfwCommand==(unsigned short)5)) {
			if (argc>=5) {
				k = atoi(argv[4]);
				if ((k >= 0)&&(k <= 3)) {
					params.cfwParam1=(unsigned long)k;
				} else {
					pb=4;
				}
			}
			if (pb==4) {
				sprintf(res,"cfwParam1 must be amongst %s. ",cfw_com_port);
				Tcl_DStringAppend(&dsptr,res,-1);
			}
		}
		/*
		pb=0;
		params.cfwModel=(unsigned short)CFWSEL_CFW9;
		params.cfwCommand=(unsigned short)CFWC_GET_INFO;
		params.cfwParam1=(unsigned long)CFWG_FIRMWARE_VERSION;
		*/
		// --- Execute command cam1 cfw 10 2 0
		if (pb==0) {
			cam->drv_status = pardrvcommand(CC_CFW, &params, &results);
			if (cam->drv_status != 0) {
				sprintf(ligne, "Error %d. %s", cam->drv_status,sbig_get_status(cam->drv_status));
				Tcl_SetResult(interp, ligne, TCL_VOLATILE);
				return TCL_ERROR;
			}
			// --- Analysis of the result
			sprintf(res,"{cfwModel %d} ",(int)results.cfwModel);
			Tcl_DStringAppend(&dsptr,res,-1);
			sprintf(res,"{cfwPosition %d} ",(int)results.cfwPosition);
			Tcl_DStringAppend(&dsptr,res,-1);
			sprintf(res,"{cfwStatus %d} ",(int)results.cfwStatus);
			Tcl_DStringAppend(&dsptr,res,-1);
			sprintf(res,"{cfwError %d} ",(int)results.cfwError);
			Tcl_DStringAppend(&dsptr,res,-1);
			sprintf(res,"{cfwResult1 %d} ",(int)results.cfwResult1);
			Tcl_DStringAppend(&dsptr,res,-1);
			sprintf(res,"{cfwResult2 %d} ",(int)results.cfwResult2);
			Tcl_DStringAppend(&dsptr,res,-1);
			Tcl_DStringResult(interp,&dsptr);
		} else {
			ret=TCL_ERROR;
			Tcl_DStringResult(interp,&dsptr);
		}
		Tcl_DStringFree(&dsptr);
	}
	return ret;
}
