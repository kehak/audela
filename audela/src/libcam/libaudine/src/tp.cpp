/* tp.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <klotz@cesr.fr>
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
 * Fichier pour travaux pratiques de masters
 * Universite de Toulouse
 *
 * --- rappel des bits de donnes du port parallele pour Audine
 *     ordre : 87654321
 *     bit 1 : horloge V1
 *     bit 2 : horloge V2
 *     bit 3 : horloge H1
 *     bit 4 : horloge R  (reset)
 *     bit 5 : horloge CL (clamp)
 *     bit 6 : horloge Start Convert (CAN)
 *     bit 7 : horloge Select Byte (CAN)
 *     bit 8 : horloge Select Nibble
 *
 * N.B. Si le bit est à 0 alors la tension est au niveau haut.
 *      Si le bit est à 1 alors la tension est au niveau bas.
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

/* declaration des fonctions locales à ce fichier .c */

static void tp_fast_vidage(struct camprop *cam);
static void tp_zi_zh(struct camprop *cam);
static void tp_read_pel_fast(struct camprop *cam);
static void tp_read_pel_fast2(struct camprop *cam);
static void tp_read_win(struct camprop *cam, unsigned short *buf);
static void tp_fast_line(struct camprop *cam);
static void tp_fast_line2(struct camprop *cam);
static void tp_read_win2(struct camprop *cam,unsigned short *buf);

/* ================================================================== */
/* ================================================================== */
/* === Fonctions appelées par l'interface pour piloter la camera  === */
/* ================================================================== */
/* ================================================================== */

/*
 * cmdAudineAcqNormal()
 *
 * La structure cam est definie dans le fichier libcam.h
 *  au niveau de la definition #define COMMON_CAMSTRUCT
 *
 * Les fonction commençant par libcam sont définies dans
 *  le fichier util.c
 *
 * La fonction atoi transforme le contenu d'une chaine de carateres
 * de type char* en un nombre entier de int.
 *
 * La fonction ceil arrondit à l'entier superieur.
 *
 * La fonction sprintf a le meme effet que fprintf mais elle envoie
 * la chaine de caracteres vers un pointeur char*.
 *
 */
int cmdAudineAcqNormal(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   struct camprop *cam;
   char s[256];
   int i;
   int nb_vidages = 1;
   unsigned short *p;

   cam = (struct camprop *) clientData;

   /* =============================================== */
   /* === Etape de rincage de la matrice CCD      === */
   /* =============================================== */
   /* Bloquage des interruptions */
   if (cam->interrupt == 1) {
      libcam_bloquer();
   }
   /* vidage de la matrice */
   for (i = 0; i < nb_vidages; i++) {
      tp_fast_vidage(cam);
   }
   /* Debloquage des interruptions */
   if (cam->interrupt == 1) {
      libcam_debloquer();
   }
   /* Remise a l'heure de l'horloge du PC */
   update_clock();

   /* =============================================== */
   /* === Integration de l'image (attente)        === */
   /* =============================================== */
   /* Delais du temps de pose (en millisecondes) */
   libcam_sleep((int) (1000 * cam->exptime));

   /* =============================================== */
   /* === Etape de lecture de la matrice CCD      === */
   /* =============================================== */
   /* Bloquage des interruptions */
   if (cam->interrupt == 1) {
      libcam_bloquer();
   }
   /* Parametres de dimensions pour allouer le pointeur image */
   cam->w = cam->nb_photox / cam->binx;
   cam->h = cam->nb_photoy / cam->biny;
   /* Allocation memoire du pointeur image */
   p = (unsigned short *) calloc(cam->w*cam->h, sizeof(unsigned short));
   /* Lecture et numérisation de l'image vers le pointeur p */
   tp_read_win(cam, p);
   /* Debloquage des interruptions */
   if (cam->interrupt == 1) {
      libcam_debloquer();
   }
   /* Remise a l'heure de l'horloge du PC */
   update_clock();

   /* =============================================== */
   /* === Copie des valeurs des pixels a partir   === */
   /* === du pointeur image vers le pointeur Tcl  === */
   /* =============================================== */
	/* Efface le buffer image Tcl */
   sprintf(s, "buf%d clear", cam->bufno);
	if (Tcl_Eval(interp, s) == TCL_ERROR) {
		/* Cree le buffer image Tcl s'il nexiste pas */
		sprintf(s, "buf::create %d", cam->bufno);
		Tcl_Eval(interp, s);
	}
	/* Remplit le buffer image Tcl avec le contenu du pointeur image */
	sprintf(s, "buf%d setpixels CLASS_GRAY %d %d FORMAT_USHORT COMPRESS_NONE %ld",
      cam->bufno, cam->w, cam->h, (long)(void *)p);
   Tcl_Eval(interp, s);
   /* Liberation du pointeur image */
   free(p);

   /* =============================================== */
   /* === Complete le buffer Tcl                  === */
   /* =============================================== */
	/* Mots clés pour l'entete du fichier image */
	sprintf(s, "buf%d setkwd {NAXIS  %d int \"nombre d'axes\" \"\"}", cam->bufno, 2);
	Tcl_Eval(interp, s);
	sprintf(s, "buf%d setkwd {NAXIS1 %d int \"pixels sur X\" \"\"}", cam->bufno, cam->w);
	Tcl_Eval(interp, s);
	sprintf(s, "buf%d setkwd {NAXIS2 %d int \"pixels sur Y\" \"\"}", cam->bufno, cam->h);
	Tcl_Eval(interp, s);

   return TCL_OK;
}

/*
 * cmdCamAcqSpecial()
 *
 * A modifier par les étudiants ...
 * Commencer par copier/coller le contenu de cmdAudineAcqNormal
 * Remplacer l'appel a tp_read_win par tp_read_win2
 * Modifier aussi tp_read_win2 (voir a la fin de ce fichier)
 *
 */
int cmdAudineAcqSpecial(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   return TCL_OK;
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

/*
fast_vidage(struct camprop *cam) --
  Vidage rapide de la matrice. Le decalage des lignes s'effectue
  ici par groupe de 20. C'est le seul parametre a regler ici.
*/
void tp_fast_vidage(struct camprop *cam)
{
   int i, j;
   int imax, jmax, decaligne;

#ifdef __linux__
   /* Demande d'acces aux ports pour linux */
   int port_ok;
   port_ok = iopl(3);
   if (port_ok != 0) {
      fprintf(stderr, "Impossible d'acceder au port parallele.\n");
      exit(1);
   }
#endif

   /* Nombre total de photocellules dans le registre horizontal. */
   imax = cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox;

   /* Nombre total de photocellules dans une colonne de la matrice. */
   jmax = cam->nb_photoy + cam->nb_deadbeginphotoy + cam->nb_deadendphotoy;

   /* Nombre de lignes decalees a chaque boucle sur l'axe vertical. */
   decaligne = 20;

   /* Nombre total de boucles sur l'axe vertical. */
   jmax = (int) ceil (1. * jmax / decaligne) ;

   /* Boucle sur les paquets de lignes. */
   for (j = 0; j < jmax; j++) {
      /* Decalage d'un paquet de 20 lignes. */
      for (i = 0; i < decaligne; i++) {
         tp_zi_zh(cam);
      }
      /* Lecture du registre horizontal sans reset */
      for (i = 0; i < imax; i++) {
         tp_read_pel_fast2(cam);
      }
   }
}

/*
tp_zi_zh(struct camprop *cam) --
  Decalage vertical de toutes les lignes d'un cran vers le bas.
  La premiere ligne du bas est donc transferee dans le registre
  horizontal.
*/
void tp_zi_zh(struct camprop *cam)
{
   unsigned short port = cam->port;
   int i;
   int n_te=1, n_tphiv=4, n_tphihs=1;
   for (i = 0; i < n_te     ; i++) { libcam_out(port, 0xFB); /* 11111011 */ }
   for (i = 0; i < n_tphiv  ; i++) { libcam_out(port, 0xFA); /* 11111010 */ }
   for (i = 0; i < n_tphiv  ; i++) { libcam_out(port, 0xF9); /* 11111001 */ }
   for (i = 0; i < n_tphiv  ; i++) { libcam_out(port, 0xFA); /* 11111010 */ }
   for (i = 0; i < n_tphihs ; i++) { libcam_out(port, 0xFB); /* 11111011 */ }
}

/*
tp_read_pel_fast(struct camprop *cam) --
  Lecture rapide d'un pixel : decalage du registre horizontal
  avec Reset, mais sans lecture du CAN,
*/
void tp_read_pel_fast(struct camprop *cam)
{
   unsigned short port = cam->port;
   int i;
   int n_te2=1, n_tphir=1;
   for (i = 0; i < n_tphir  ; i++) { libcam_out(port, 0xF7); /* 11110111 */ }
   for (i = 0; i < n_te2    ; i++) { libcam_out(port, 0xFF); /* 11111111 */ }
   for (i = 0; i < n_te2    ; i++) { libcam_out(port, 0xFB); /* 11111011 */ }
}

/*
tp_read_pel_fast2(struct camprop *cam) --
  Lecture rapide d'un pixel : decalage du registre horizontal
  sans Reset, mais sans lecture du CAN,
*/
void tp_read_pel_fast2(struct camprop *cam)
{
   unsigned short port = cam->port;
   int i;
   int n_te2=1;
   for (i = 0; i < n_te2    ; i++) { libcam_out(port, 0xFF); /* 11111111 */ }
   for (i = 0; i < n_te2    ; i++) { libcam_out(port, 0xFB); /* 11111011 */ }
}

/*
tp_fast_line_() --
  Lecture rapide du registre horizontal, avec la fonction read_pel_fast.
*/
void tp_fast_line(struct camprop *cam)
{
   int i, imax;
   /* Nombre total de photocellules dans le registre horizontal. */
   imax = cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox;
   for (i = 0; i < imax; i++) {
      tp_read_pel_fast(cam);
   }
}

/*
tp_fast_line2() --
  Lecture rapide du registre horizontal, avec la fonction read_pel_fast2.
*/
void tp_fast_line2(struct camprop *cam)
{
   int i, imax;
   /* Nombre total de photocellules dans le registre horizontal. */
   imax = cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox;
   for (i = 0; i < imax; i++) {
      tp_read_pel_fast2(cam);
   }
}

/*
tp_read_win(struct camprop *cam,short *buf) --
   Lecture normale du CCD, avec un fenetrage possible.
*/
void tp_read_win(struct camprop *cam, unsigned short *buf)
{
   int i, j;
   int k, l;
   int imax, jmax;
   int cx1, cx2, cy1;
   unsigned short int port0, port1;
   unsigned short buffer[2048];
   int x;
   int a1, a2, a3, a4;

	/* adresse du port parallele en sortie */
   port0 = cam->port;
	/* adresse du port parallele en entree */
   port1 = port0 + 1;

   /* dimensions de l'image a digitaliser */
   imax = cam->w;
   jmax = cam->h;
   /* nombre de colonnes de début à ne pas digitaliser */
   cx1 = cam->nb_deadbeginphotox;
   /* nombre de colonnes de fin à ne pas digitaliser */
   cx2 = cam->nb_deadendphotox;
   /* nombre de lignes de début à ne pas digitaliser */
   cy1 = cam->nb_deadbeginphotoy;

   /* On supprime les cy1 premieres lignes */
   for (i = 0; i < cy1; i++) {
      tp_zi_zh(cam);
   }

   /* On nettoie le registre horizontal */
   for (i = 0; i < 4; i++) {
      tp_fast_line(cam);
   }
   /* boucle sur l'horloge verticale (transfert) */
   for (i = 0; i < jmax; i++) {

      /* boucle de binning vertical */
      for (k = 0; k < cam->biny; k++) {
         tp_zi_zh(cam);
      }

      /* On retire les cx1 premiers pixels avec reset */
      for (j = 0; j < cx1; j++) {
         tp_read_pel_fast(cam);
      }

      /* boucle sur l'horloge horizontale (registre de sortie) */
      for (j = 0; j < imax; j++) {
         libcam_out(port0, 247); /* palier de reset 11110111 */

         libcam_out(port0, 255); /* palier de reference 11111111 */
         libcam_out(port0, 255);
         libcam_out(port0, 255);
         libcam_out(port0, 239); /* clamp 11101111 */

         /* boucle de binning horizontal */
         for (l = 0; l < cam->binx; l++) {
            libcam_out(port0, 255);
            libcam_out(port0, 251); /* palier video 11111011 */
         }

         libcam_out(port0, 251); /* palier video 11111011 */
         libcam_out(port0, 251);
         libcam_out(port0, 251);

         /* numerisation et selections des nibbles a lire */
         libcam_out(port0, 219); /* start convert + select 11011011 */
         /* recupere le nibble de poids faible de l'octet de poids faible */
         a1 = libcam_in(port1) & 0x00F0;
         libcam_out(port0, 91); /* select 01011011 */
         /* recupere le nibble de poids fort de l'octet de poids faible */
         a2 = libcam_in(port1) & 0x00F0;
         libcam_out(port0, 155); /* select 10011011 */
         /* recupere le nibble de poids faible de l'octet de poids fort */
         a3 = libcam_in(port1) & 0x00F0;
         libcam_out(port0, 27); /* select 00011011 */
         /* recupere le nibble de poids fort de l'octet de poids fort */
         a4 = libcam_in(port1) & 0x00F0;

         /* On reconstitue la valeur du pixel sur 16 bits. */
         /* Le masque 0x8888 vient du registre de lecture du port parallele */
         /* qui inverse la valeur du bit de poids fort de chaque nibble. */
         x = ((a1 >> 4) + a2 + (a3 << 4) + (a4 << 8)) ^ 0x8888;
         if (x > 32767) {x = 32767;}
         /* Stockage dans un buffer dans la meme page mem */
         buffer[j] = (unsigned short) x;
      }

      /* On retire cx2 pixels à la fin */
      for (j = 0; j < cx2; j++) {
         tp_read_pel_fast(cam);
      }

      /* On transfere le tableau vers la matrice image */
      if (i != 0) {
         buf[(i - 1) * imax] = buffer[0];
      }
      for (j = 1; j < imax; j++) {
         buf[(i + 1) * imax - j] = buffer[j];
      }
   }
}

/*
tp_read_win2(struct camprop *cam,short *buf) --
   Lecture speciale du CCD, a ecrire par les etudiants.
*/
void tp_read_win2(struct camprop *cam, unsigned short *buf)
{
}
