/* camtcl.h
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

#ifndef __CAMTCL_H__
#define __CAMTCL_H__

#include <string>
#include <vector>

#define SPECIFIC_CMDLIST \
   {"scan", (Tcl_CmdProc *)cmdFingerlakesScan}, \
   {"breakscan", (Tcl_CmdProc *)cmdFingerlakesBreakScan}, \
   {"scanloop", (Tcl_CmdProc *)cmdFingerlakesScanLoop}, \
   {"nbflushes", (Tcl_CmdProc *)cmdFingerlakesNbFlushes}, \
   {"coolerpower", (Tcl_CmdProc *)cmdFingerlakesCoolerPower}, \
   {"flidebug", (Tcl_CmdProc *)cmdFingerlakesFLIDebug}, \
   {"flimodes", (Tcl_CmdProc*)cmdFingerlakesFLIModes}, \
   {"flimode", (Tcl_CmdProc *)cmdFingerlakesFLIMode}, \
   {"temppower", (Tcl_CmdProc *)cmdFingerlakesGetTempPower}, \
   {"getwheelinfo", (Tcl_CmdProc *)cmdFingerlakesGetWheelInfo}, \
   {"getfilterdef", (Tcl_CmdProc *)cmdFingerlakesGetFilterDef}, \
   {"getwheelpos", (Tcl_CmdProc *)cmdFingerlakesGetWheelPos}, \
   {"movewheel", (Tcl_CmdProc *)cmdFingerlakesMoveWheel}, \
   {"gotoclosed", (Tcl_CmdProc *)cmdFingerlakesGotoClosed}, \
   {"openwheel", (Tcl_CmdProc *)cmdFingerlakesOpenWheel}, \
   {"closewheel", (Tcl_CmdProc *)cmdFingerlakesCloseWheel}, \
   {"scanforwheel", (Tcl_CmdProc *)cmdFingerlakesScanForWheel}, \
   {"initfilter", (Tcl_CmdProc *)cmdFingerlakesInitFilter}, \
   {"gotofilter", (Tcl_CmdProc *)cmdFingerlakesGotoFilter}, \
   {"closefilter", (Tcl_CmdProc *)cmdFingerlakesCloseFilter}, \
   {"fliioport", (Tcl_CmdProc *)cmdFingerlakesFLIIOPort}, 

 /* === Specific commands for that camera === */
int cmdFingerlakesScan(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesBreakScan(ClientData clientData, Tcl_Interp * interp,
			   int argc, char *argv[]);
int cmdFingerlakesScanLoop(ClientData clientData, Tcl_Interp * interp,
			   int argc, char *argv[]);
int cmdFingerlakesNbFlushes(ClientData clientData, Tcl_Interp * interp,
			   int argc, char *argv[]);
int cmdFingerlakesCoolerPower(ClientData clientData, Tcl_Interp * interp,
               int argc, char *argv[]);
int cmdFingerlakesFLIDebug(ClientData clientData, Tcl_Interp * interp,
               int argc, char *argv[]);
int cmdFingerlakesFLIModes(ClientData clientData, Tcl_Interp * interp,
               int argc, char *argv[]);
int cmdFingerlakesFLIMode(ClientData clientData, Tcl_Interp* interp,
               int argc, char *argv[]);
int cmdFingerlakesGetTempPower(ClientData clientData, Tcl_Interp* interp,
               int argc, char *argv[]);
int cmdFingerlakesGetWheelInfo(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesGetFilterDef(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesGetWheelPos(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesMoveWheel(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesGotoFilter(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesGotoClosed(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesOpenWheel(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesCloseWheel(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesScanForWheel(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesInitFilter(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesCloseFilter(ClientData clientData, Tcl_Interp * interp,
		       int argc, char *argv[]);
int cmdFingerlakesFLIIOPort(ClientData clientData, Tcl_Interp *interp, 
				 int argc, char *argv[]);
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
    int bin;			/* binning */
    float dt;			/* intervalle de temps en millisecondes */
    int y;			/* nombre de lignes deja lues */
    unsigned long t0;		/* instant de depart en microsecondes */
    unsigned short *pix;	/* stockage de l'image */
    unsigned short *pix2;	/* pointeur defilant sur le contenu de pix */
    int last_delta;		/* dernier delta temporel */
    int blocking;		/* vaut 1 si le scan est bloquant */
    int keep_perfos;		/* vaut 1 si on conserve les dt du scan dans 1 fichier */
    int fileima;		/* vaut 1 si on écrit les pixels dans un fichier */
    FILE *fima;			/* fichier binaire pour stocker les pixels */
    int *dts;			/* tableau des délais */
    unsigned long loopmilli1;	/* nb de boucles pour faire une milliseconde (~10000) */
    int stop;			/* indicateur d'arret (1=>pose arretee au prochain coup) */
    double ra;			/* RA at the bigining */
    double dec;			/* DEC at the bigining */
} ScanStruct;

#endif
