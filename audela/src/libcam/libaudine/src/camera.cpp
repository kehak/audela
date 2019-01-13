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

#include "camera.h"
#include <libcam/util.h>


/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"Audine",			/* camera name */
     "audine",        /* camera product */
     "kaf401",			/* ccd name */
     768, 512,			/* maxx maxy */
     14, 14,			/* overscans x */
     4, 4,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Audine",		/* camera name */
     "audine",    /* camera product */
     "kaf1602",   /* ccd name */
     1536, 1024,	/* maxx maxy */
     14, 14,		/* overscans x */
     4, 4,			/* overscans y */
     9e-6, 9e-6,	/* photosite dim (m) */
     32767.,		/* observed saturation */
     1.,			   /* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			   /* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Audine",			/* camera name */
     "audine",       /* camera product */
     "kaf3200",			/* ccd name */
     2184, 1472,		/* maxx maxy */
     46, 37,			/* overscans x */
     34, 4,			/* overscans y */
     6.8e-6, 6.8e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
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
    int i;
    
#ifdef OS_LIN
    if ( ! libcam_can_access_parport() ) {
	sprintf(cam->msg,"You don't have sufficient privileges to access parallel port. Camera cannot be created.");
	return 1;
    }
#endif

    // Creation du tableau des octets a envoyer a la camera
    cam->bytes = (unsigned char*)malloc(256);
    if (cam->index_cam == 2) {
        for (i=0;i<256;i++) {
            unsigned char v = (unsigned char)i, v1, v2;
            // 87654321
	    // 3 est invers�
	    v = v ^ 0x04;
	    // 1 et 2 sont swapes
	    v1 = v & 0x01;		// 0000 0001
	    v2 = v & 0x02;		// 0000 0010
	    cam->bytes[i] = (v & 0xFC) + (v1 << 1) + (v2 >> 1);
	}
    } else {
        for (i=0;i<256;i++)
            cam->bytes[i] = (unsigned char)i;
    }

    cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */

    /* --- pour l'amplificateur des Kaf-401 (synchro by default) --- */
    cam->ampliindex = 0;
    cam->nbampliclean = 60;
    /* --- pour les obturateurs montes en sens inverse --- */
    cam->shutteraudinereverse = 0;
    /* --- pour le type de CAN --- */
    cam->cantypeindex = 0;
    /* --- pour les parametres de l'obturateur de Pierre Thierry --- */
    cam->shuttertypeindex = 0;	/* obturateur Audine par defaut */
    cam->InfoPierre_a = 960;
    cam->InfoPierre_b = 1080;
    cam->InfoPierre_c = 1200;
    cam->InfoPierre_d = 900;
    cam->InfoPierre_e = 1800;
    cam->InfoPierre_t = 8;
    cam->InfoPierre_flag = 1;
    cam->InfoPierre_v = cam->InfoPierre_a;
    /* --- fichier update.log --- */
    cam->updatelogindex = 0;
    strcpy(cam->date_obs, "2000-01-01T12:00:00");
    strcpy(cam->date_end, cam->date_obs);
    return 0;
}

int cam_close(struct camprop * cam)
{
    free(cam->bytes);
    return 0;
}


void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
    short i;
    short nb_vidages = 4;

    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	audine_updatelog(cam, "", "start_exp debut");
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* case : shutter always off (Darks) */
	if (cam->shutterindex == 0) {
	    audine_shutter_off(cam);
	}
	/* vidage de la matrice */
	for (i = 0; i < nb_vidages; i++) {
	    audine_fast_vidage_inv(cam);
	}
	/* case : shutter on */
	if ((cam->shutterindex == 1) || (cam->shutterindex == 2)) {
	    audine_shutter_on(cam);
	}
	/* ampli */
	if (strcmp(amplionoff, "amplion") == 0) {
	    /* case : TDI mode */
	    if (cam->ampliindex != 2) {
		audine_ampli_on(cam);
	    }
	} else {
	    /* case : normal imagery mode */
	    if (cam->ampliindex == 0) {
		audine_ampli_off(cam);
	    }
	}
	/* Debloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_debloquer();
	}
	/* Remise a l'heure de l'horloge de Windows */
	audine_updatelog(cam, "", "start_exp avant");
	if (cam->interrupt == 1) {
	    update_clock();
	}
	audine_updatelog(cam, "", "start_exp apres");
    }
}

void cam_stop_exp(struct camprop *cam)
{
	printf("\n\n\n$$$$$$$ cam_stop_exp\n\n\n");
}

void cam_read_ccd(struct camprop *cam, float *p)
{
    if (p == NULL)
	return;
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	audine_updatelog(cam, "", "read_ccd debut");
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* shutter always off for synchro mode */
	if (cam->shutterindex == 1) {
	    audine_shutter_off(cam);
	}
	/* ampli */
	if (cam->ampliindex == 0) {
	    audine_ampli_on(cam);
	}
	/* Lecture de l'image */
	audine_read_win_inv(cam, p);
	/* Debloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_debloquer();
	}
	/* Remise a l'heure de l'horloge de Windows */
	audine_updatelog(cam, "", "read_ccd avant");
	if (cam->interrupt == 1) {
	    update_clock();
	}
	audine_updatelog(cam, "", "read_ccd apres");
    }
}

void cam_shutter_on(struct camprop *cam)
{
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* shutter off */
	audine_shutter_on(cam);
	/* Debloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_debloquer();
	}
	/* Remise a l'heure de l'horloge de Windows */
	if (cam->interrupt == 1) {
	    update_clock();
	}
    }
}

void cam_shutter_off(struct camprop *cam)
{
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* shutter off */
	audine_shutter_off(cam);
	/* Debloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_debloquer();
	}
	/* Remise a l'heure de l'horloge de Windows */
	if (cam->interrupt == 1) {
	    update_clock();
	}
    }
}

void cam_ampli_on(struct camprop *cam)
{
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* ampli off */
	audine_ampli_on(cam);
	/* Debloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_debloquer();
	}
	/* Remise a l'heure de l'horloge de Windows */
	if (cam->interrupt == 1) {
	    update_clock();
	}
    }
}

void cam_ampli_off(struct camprop *cam)
{
    if (cam->authorized == 1) {
	/* Bloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_bloquer();
	}
	/* shutter off */
	audine_ampli_off(cam);
	/* Debloquage des interruptions */
	if (cam->interrupt == 1) {
	    libcam_debloquer();
	}
	/* Remise a l'heure de l'horloge de Windows */
	if (cam->interrupt == 1) {
	    update_clock();
	}
    }
}

void cam_measure_temperature(struct camprop *cam)
{
    cam->temperature = 0.;
}

void cam_cooler_on(struct camprop *cam)
{
}

void cam_cooler_off(struct camprop *cam)
{
}

void cam_cooler_check(struct camprop *cam)
{
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
    cam->binx = binx;
    cam->biny = biny;
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

    if (cam->x2 > maxx - 1) {
        cam->w = cam->w - 1;
        cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    }

    if (cam->y2 > maxy - 1) {
        cam->h = cam->h - 1;
        cam->y2 = cam->y1 + cam->h * cam->biny - 1;
    }

}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

/*
  audine_fast_vidage_inv(struct camprop *cam) --
  Vidage rapide de la matrice. Le decalage des lignes s'effectue
  ici par groupe de 4, mais est le seul parametre a regler ici.
*/
void audine_fast_vidage_inv(struct camprop *cam)
{
    int i, j;
    int imax, jmax, decaligne;

    /* Nombre de lignes decalees a chaque iteration. */
#if defined(READSLOW)
    decaligne = 4;
#else
    decaligne = 20;
    if (cam->index_cam == 2) {
	decaligne = 128;
    }
#endif

    /* Calcul des constantes de vidage de la matrice. */
    imax = cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox;
    jmax = (cam->nb_photoy + cam->nb_deadbeginphotoy + cam->nb_deadendphotoy) / decaligne + 1;

    for (j = 0; j < jmax; j++) {
	/* Decalage des lignes. */
	for (i = 0; i < decaligne; i++)
	    audine_zi_zh_inv(cam);
	/* Lecture du registre horizontal. */
	/* sans reset */
#if defined(READSLOW)
	for (i = 0; i < imax; i++)
	    audine_read_pel_fast_inv(cam);
#else
	for (i = 0; i < imax; i++)
	    audine_read_pel_fast2_inv(cam);
#endif
    }
}

/*
* On entre l'octet pour Kak04xx/Kaf16xx et ca le convertit
* eventuellement pour le Kaf32xx (index_cam==2)
*/
#if 0
unsigned char audine_kafinv(struct camprop *cam, unsigned char value)
{
    unsigned char v = value, v1, v2;
    if (cam->index_cam == 2) {
	/* 87654321 */
	/* 3 est invers� */
	v = value ^ 0x04;
	/* 1 et 2 sont swapes */
	v1 = v & 0x01;		/* 0000 0001 */
	v2 = v & 0x02;		/* 0000 0010 */
	v = v & 0xFC;		/* 1111 1100 */
	v = v + (v1 << 1) + (v2 >> 1);
    }
    return v;
}
#endif

/*
  audine_zi_zh_inv(struct camprop *cam) --
  Decalage horizontal d'une ligne (dans le registre horizontal).
*/
void audine_zi_zh_inv(struct camprop *cam)
{
    unsigned short port = cam->port;
    int i, n_iter;
#if defined(READSLOW)
    n_iter = 8;
#else
    if (cam->index_cam == 1) {
	/* cas d'un Kaf-1600 */
	/* Becky-Mark Weinberg <becmar1@mediaone.net> */
	n_iter = 8;
    } else {
	n_iter = 4;
    }
#endif

    for (i = 0; i < n_iter/4; i++)
	libcam_out(port, cam->bytes[0xFB]);	/* 11111011 */
    for (i = 0; i < n_iter; i++)
	libcam_out(port, cam->bytes[0xFA]);	/* 11111010 */
    for (i = 0; i < n_iter; i++)
	libcam_out(port, cam->bytes[0xF9]);	/* 11111001 */
    for (i = 0; i < n_iter; i++)
	libcam_out(port, cam->bytes[0xFA]);	/* 11111010 */
    for (i = 0; i < n_iter/4; i++)
	libcam_out(port, cam->bytes[0xFB]);	/* 11111011 */
}

/*
  audine_read_pel_fast_inv(struct camprop *cam) --
  Lecture rapide d'un pixel : decalage du registre horizontal
  avec Reset, mais sans lecture du CAN,
*/
void audine_read_pel_fast_inv(struct camprop *cam)
{
    unsigned short port = cam->port;
    libcam_out(port, cam->bytes[0xF7]);	/* 11110111 */
    libcam_out(port, cam->bytes[0xFF]);	/* 11111111 */
    libcam_out(port, cam->bytes[0xFB]);	/* 11111011 */
}

/*
  audine_read_pel_fast2_inv(struct camprop *cam) --
  Lecture rapide d'un pixel : decalage du registre horizontal
  sans Reset, mais sans lecture du CAN,
*/
void audine_read_pel_fast2_inv(struct camprop *cam)
{
    unsigned short port = cam->port;
    libcam_out(port, cam->bytes[0xFF]);	/* 11111111 */
    libcam_out(port, cam->bytes[0xFB]);	/* 11111011 */
}

/*
   audine_read_win_inv(struct camprop *cam,short *buf) --
   Lecture normale du CCD, avec un fenetrage possible.
*/
void audine_read_win_inv(struct camprop *cam, float *buf)
{
    int i, j;
    int k, l;
    int imax, jmax;
    int cx1, cx2, cy1;
    unsigned short int port0, port1;
    unsigned short buffer[10000];
    float *p0;
    unsigned char mybyte;
    int x;
    int a1, a2, a3, a4;
#ifndef READOPTIC
    int ibeg;
#endif

    p0 = buf;
    port0 = cam->port;
    port1 = port0 + 1;

    /* Calcul des coordonnees de la    */
    /* fenetre, et du nombre de pixels */
    imax = (cam->x2 - cam->x1 + 1) / cam->binx;
    jmax = (cam->y2 - cam->y1 + 1) / cam->biny;
#if defined(READOPTIC)
    cx1 = cam->nb_deadbeginphotox + cam->nb_photox - 1 - cam->x2;
    cx2 = cam->x1 + cam->nb_deadendphotox;
#else
    cx1 = cam->nb_deadbeginphotox + (cam->x1);
    cx2 = cam->nb_photox - 1 - cam->x2 + cam->nb_deadendphotox;
#endif
    cy1 = cam->nb_deadbeginphotoy + (cam->y1);

    /* On supprime les cy1 premieres lignes */
    for (i = 0; i < cy1; i++) {
	audine_zi_zh_inv(cam);
    }
    if (cy1 < 10) {
	j = 4;
    } else {
	j = 10;
    }
    for (i = 0; i < j; i++) {
	audine_fast_line_inv(cam);
    }

    /* boucle sur l'horloge verticale (transfert) */
    for (i = 0; i < jmax; i++) {

	/* Rincage du registre horizontal avec Reset */
#if defined(OS_LIN)
	audine_fast_line_inv(cam);
#endif

#if defined(OS_WIN)
	if (cam->index_cam != 0) {
	    audine_fast_line_inv(cam);
	}
#endif


	/* Cumul des lignes (binning y) */
	for (k = 0; k < cam->biny; k++)
	    audine_zi_zh_inv(cam);

	/* On retire les cx1 premiers pixels avec reset */
	for (j = 0; j < cx1; j++)
	    audine_read_pel_fast_inv(cam);

	/* boucle sur l'horloge horizontale (registre de sortie) */
	for (j = 0; j < imax; j++) {
	    libcam_out(port0, cam->bytes[247]);	/* reset 11110111 */

	    libcam_out(port0, cam->bytes[255]);	/* d�lai critique 11111111 */
	    libcam_out(port0, cam->bytes[255]);
	    libcam_out(port0, cam->bytes[255]);
#if defined(READSLOW)
	    libcam_out(port0, cam->bytes[255]);
	    libcam_out(port0, cam->bytes[255]);
#endif
	    libcam_out(port0, cam->bytes[239]);	/* clamp 11101111 */

	    for (l = 0; l < cam->binx; l++) {
		libcam_out(port0, cam->bytes[255]);
		libcam_out(port0, cam->bytes[251]);	/* palier vid�o 11111011 */
	    }

	    libcam_out(port0, cam->bytes[251]);
	    libcam_out(port0, cam->bytes[251]);
	    libcam_out(port0, cam->bytes[251]);
	    libcam_out(port0, cam->bytes[219]);	/* start convert 11011011 */
	    /* --- */
#if defined(READSLOW)
	    if (cam->cantypeindex == 0) {
		mybyte = (unsigned char) 219;
	    } else {
		mybyte = (unsigned char) 251;
	    }
	    libcam_out(port0, cam->bytes[mybyte]);
	    libcam_out(port0, cam->bytes[mybyte]);
	    libcam_out(port0, cam->bytes[mybyte]);
	    libcam_out(port0, cam->bytes[mybyte]);
#endif
	    /* lecture de la numerisation du start convert precedant */
	    a1 = libcam_in(port1) & 0x00F0;
	    if (cam->cantypeindex == 0) {
		mybyte = (unsigned char) 91;
	    } else {
		mybyte = (unsigned char) 123;
	    }
	    libcam_out(port0, cam->bytes[mybyte]);	/* 01111011 */
	    a2 = libcam_in(port1) & 0x00F0;
	    if (cam->cantypeindex == 0) {
		mybyte = (unsigned char) 155;
	    } else {
		mybyte = (unsigned char) 187;
	    }
	    libcam_out(port0, cam->bytes[mybyte]);	/* 10111011 */
	    a3 = libcam_in(port1) & 0x00F0;
	    if (cam->cantypeindex == 0) {
		mybyte = (unsigned char) 27;
	    } else {
		mybyte = (unsigned char) 59;
	    }
	    libcam_out(port0, cam->bytes[mybyte]);	/* 00111011 */
	    a4 = libcam_in(port1) & 0x00F0;

	    x = ((a1 >> 4) + a2 + (a3 << 4) + (a4 << 8)) ^ 0x8888;
	    if (x > 32767)
		x = 32767;

	    /* Stockage dans un buffer dans la meme page mem */
	    buffer[j] = (unsigned short) x;
	}

	/* On retire cx2 pixels � la fin */

	for (j = 0; j < cx2; j++)
	    audine_read_pel_fast_inv(cam);

	/*
	   Ca c'est pour stocker les pixels dans la memoire
	   centrale. Notons que ca pose PB car il peut y avoir
	   un swap memoire et ca fait sauter le cli. On ne fait
	   le transfert qu'une fois par ligne, pour eviter les
	   cochonneries.
	 */
#if defined(READOPTIC)
	if (i != 0) {
	    p0[(i - 1) * imax] = buffer[0];
	}
	for (j = 1; j < imax; j++) {
	    p0[(i + 1) * imax - j] = buffer[j];
	}
#else
	if (i == 0) {
	    ibeg = 1;
	} else {
	    ibeg = 0;
	}
	for (j = ibeg; j < imax; j++) {
	    *(p0++) = buffer[j];
	}
#endif
    }

    /* lecture de la numerisation du dernier pixel */
    a1 = libcam_in(port1) & 0x00F0;
    if (cam->cantypeindex == 0) {
	mybyte = (unsigned char) 91;
    } else {
	mybyte = (unsigned char) 123;
    }
    libcam_out(port0, cam->bytes[mybyte]);	/* 01111011 */
    a2 = libcam_in(port1) & 0x00F0;
    if (cam->cantypeindex == 0) {
	mybyte = (unsigned char) 155;
    } else {
	mybyte = (unsigned char) 187;
    }
    libcam_out(port0, cam->bytes[mybyte]);	/* 10111011 */
    a3 = libcam_in(port1) & 0x00F0;
    if (cam->cantypeindex == 0) {
	mybyte = (unsigned char) 27;
    } else {
	mybyte = (unsigned char) 59;
    }
    libcam_out(port0, cam->bytes[mybyte]);	/* 00111011 */
    a4 = libcam_in(port1) & 0x00F0;

    x = ((a1 >> 4) + a2 + (a3 << 4) + (a4 << 8)) ^ 0x8888;
    if (x > 32767)
	x = 32767;
#if defined(READOPTIC)
    p0[(jmax - 1) * imax] = (unsigned short) x;
#else
    *(p0++) = (unsigned short) x;
#endif

}


/*
  audine_fast_line_inv() --
  Lecture rapide du registre horizontal, avec la fonction read_pel_fast_inv.
*/
void audine_fast_line_inv(struct camprop *cam)
{
    int i, imax;
    imax = cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox;
    for (i = 0; i < imax; i++) {
	audine_read_pel_fast_inv(cam);
    }
}

/*
  audine_fast_line2_inv() --
  Lecture rapide du registre horizontal, avec la fonction read_pel_fast2_inv.
*/
void audine_fast_line2_inv(struct camprop *cam)
{
    int i, imax;
    imax = cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox;
    for (i = 0; i < imax; i++) {
	audine_read_pel_fast2_inv(cam);
    }
}

void audine_ampli_off(struct camprop *cam)
{
    unsigned short int port2;
    unsigned char ampli;
    port2 = cam->port + 2;
    /* On coupe l'amplificateur de sortie */
    ampli = libcam_in(port2);
    ampli |= 1;
    libcam_out(port2, ampli);
}

void audine_ampli_on(struct camprop *cam)
{
    unsigned short int port2;
    unsigned char ampli;
    /*unsigned char ampli0; */
    int k;
    port2 = cam->port + 2;
    /* On met l'amplificateur sur on */
    ampli = libcam_in(port2);
    ampli &= ~1;
    libcam_out(port2, ampli);
    /* Nettoyage du registre horizontal */
    /* nbampliclean fois avec reset pour supprimer l'effet d'allumage de l'ampli */
    for (k = 0; k < cam->nbampliclean; k++) {
	audine_fast_line_inv(cam);
    }
}

void audine_shutter_on(struct camprop *cam)
{
    unsigned short int port2;
    unsigned char obtu;
    if (cam->shuttertypeindex == 0) {
	if (cam->shutteraudinereverse == 0) {
	    /* --- shutter type : audine direct --- */
	    port2 = cam->port + 2;
	    obtu = libcam_in(port2);
	    obtu |= 2;
	    libcam_out(port2, obtu);
	} else {
	    /* --- shutter type : audine reverse --- */
	    port2 = cam->port + 2;
	    obtu = libcam_in(port2);
	    obtu &= ~2;
	    libcam_out(port2, obtu);
	}
    } else if (cam->shuttertypeindex == 1) {
	/* --- shutter type : thierry --- */
	audine_g_obtu_on(cam);
    }

}


void audine_shutter_off(struct camprop *cam)
{
    unsigned short int port2;
    unsigned char obtu;
    if (cam->shuttertypeindex == 0) {
	if (cam->shutteraudinereverse == 0) {
	    /* --- shutter type : audine direct --- */
	    port2 = cam->port + 2;
	    obtu = libcam_in(port2);
	    obtu &= ~2;
	    libcam_out(port2, obtu);
	} else {
	    /* --- shutter type : audine reverse --- */
	    port2 = cam->port + 2;
	    obtu = libcam_in(port2);
	    obtu |= 2;
	    libcam_out(port2, obtu);
	}
    } else if (cam->shuttertypeindex == 1) {
	/* --- shutter type : thierry --- */
	audine_g_obtu_off(cam);
    }

}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage de la camera     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

/*
 CAudine::set0() --
   Met tous les bits du port parallele a 0.
*/
void audine_set0(struct camprop *cam)
{
    unsigned short port0;
    port0 = cam->port;
    libcam_out(port0, 0);
}


/*
 CAudine::set255() --
   Met tous les bits du port parallele a 0.
*/
void audine_set255(struct camprop *cam)
{
    unsigned short port0;
    port0 = cam->port;
    libcam_out(port0, 255);
}


/*
 CAudine::test() --
   Effectue la fonction TEST de la doc de la camera.
*/
void audine_test(struct camprop *cam, int number)
{
    int i;
    unsigned short port0;
    int n;
    const int n_iter = 8;
    port0 = cam->port;
    for (i = 0; i < number; i++) {
	for (n = 0; n < n_iter; n++)
	    libcam_out(port0, 0xFB);
	for (n = 0; n < n_iter; n++)
	    libcam_out(port0, 0xFA);
	for (n = 0; n < n_iter; n++)
	    libcam_out(port0, 0xF9);
	for (n = 0; n < n_iter; n++)
	    libcam_out(port0, 0xFA);
	for (n = 0; n < n_iter; n++)
	    libcam_out(port0, 0xFB);
    }
}


/*
 CAudine::test2() --
   Effectue la fonction TEST2 de la doc de la camera.
*/
void audine_test2(struct camprop *cam, int number)
{
    int i, j, k;
    unsigned short port0;
    port0 = cam->port;
    for (k = 0; k < number; k++)
	for (i = 0; i < 521; i++) {
	    audine_zi_zh_inv(cam);
	    for (j = 0; j < 790; j++) {
		/* Je sais pas ce que ca fait */
		libcam_out(port0, 0xF7);
		/* Je sais pas ce que ca fait */
		libcam_out(port0, 0xFF);
		libcam_out(port0, 0xFF);
		libcam_out(port0, 0xFF);
		/* Je sais pas ce que ca fait */
		libcam_out(port0, 0xFB);
		libcam_out(port0, 0xFB);
		libcam_out(port0, 0xFB);
	    }
	}
}


/*
  CAudine::read_line(int width, int offset, int bin, short *buf) --
   Lecture d'une ligne du CCD en mode drift scan avec un positionnement
   possible en abscisse.
   - width : largeur de la bande
   - offset : position du premier pixel en x (commence a 1)
   - bin : facteur de binning (identique en x et y)
   - buf : buffer de stockage de la ligne
*/
int audine_read_line(struct camprop *cam, int width, int offset, int binx, int biny, unsigned short *buf)
{
    int i, j, l;
    int imax;
    int cx1, cx2;
    unsigned short int port0, port1;
    unsigned short buffer[10000];
    unsigned short *p0;
    unsigned char mybyte;
    int x;
    int a1, a2, a3, a4;

    if (buf == NULL)
	return 0;

    p0 = buf;
    port0 = cam->port;
    port1 = port0 + 1;

    /* Calcul des coordonnees de la     */
    /* fenetre, et du nombre de pixels  */
    imax = width / binx;

#if defined(READOPTIC)
    cx1 = cam->nb_deadbeginphotox + cam->nb_photox - width - (offset - 1);
    cx2 = (offset - 1) + cam->nb_deadendphotox;
#else
    cx1 = cam->nb_deadbeginphotox + (offset - 1);
    cx2 = cam->nb_photox - width - (offset - 1) + cam->nb_deadendphotox;
#endif

    /* Nettoyage du registre horizontal */
    audine_fast_line_inv(cam);

    /* Cumul vertical */
    for (i = 0; i < biny; i++) {
	audine_zi_zh_inv(cam);
    }

    /* On retire les cx1 premiers pixels */
    for (j = 0; j < cx1; j++) {
	audine_read_pel_fast_inv(cam);
    }

    for (j = 0; j <= imax; j++) {
	libcam_out(port0, cam->bytes[247]);	/* reset 11110111 */

	libcam_out(port0, cam->bytes[255]);	/* d�lai critique 11111111 */
	libcam_out(port0, cam->bytes[255]);
	libcam_out(port0, cam->bytes[255]);
#if defined(READSLOW)
	libcam_out(port0, cam->bytes[255]);
	libcam_out(port0, cam->bytes[255]);
#endif

	libcam_out(port0, cam->bytes[239]);	/* clamp 11101111 */

	for (l = 0; l < binx; l++) {
	    libcam_out(port0, cam->bytes[255]);
	    libcam_out(port0, cam->bytes[251]);	/* palier vid�o 11111011 */
	}
	libcam_out(port0, cam->bytes[251]);
	libcam_out(port0, cam->bytes[251]);
	libcam_out(port0, cam->bytes[251]);
	libcam_out(port0, cam->bytes[219]);	/* start convert 11011011 */
#if defined(READSLOW)
	if (cam->cantypeindex == 0) {
	    mybyte = (unsigned char) 219;
	} else {
	    mybyte = (unsigned char) 251;
	}
	libcam_out(port0, cam->bytes[mybyte]);
	libcam_out(port0, cam->bytes[mybyte]);
	libcam_out(port0, cam->bytes[mybyte]);
	libcam_out(port0, cam->bytes[mybyte]);
#endif
	/* lecture de la numerisation du start convert precedant */
	a1 = libcam_in(port1) & 0x00F0;
	if (cam->cantypeindex == 0) {
	    mybyte = (unsigned char) 91;
	} else {
	    mybyte = (unsigned char) 123;
	}
	libcam_out(port0, cam->bytes[mybyte]);	/* 01111011 */
	a2 = libcam_in(port1) & 0x00F0;
	if (cam->cantypeindex == 0) {
	    mybyte = (unsigned char) 155;
	} else {
	    mybyte = (unsigned char) 187;
	}
	libcam_out(port0, cam->bytes[mybyte]);	/* 10111011 */
	a3 = libcam_in(port1) & 0x00F0;
	if (cam->cantypeindex == 0) {
	    mybyte = (unsigned char) 27;
	} else {
	    mybyte = (unsigned char) 59;
	}
	libcam_out(port0, cam->bytes[mybyte]);	/* 00111011 */
	a4 = libcam_in(port1) & 0x00F0;

	x = ((a1 >> 4) + a2 + (a3 << 4) + (a4 << 8)) ^ 0x8888;

	if (x > 32767)
	    x = 32767;
	/* Stockage dans un buffer dans la meme page mem */
	buffer[j] = (unsigned short) x;
    }
    /* lecture de la numerisation du dernier pixel de la ligne */
    a1 = libcam_in(port1) & 0x00F0;
    if (cam->cantypeindex == 0) {
	mybyte = (unsigned char) 91;
    } else {
	mybyte = (unsigned char) 123;
    }
    libcam_out(port0, cam->bytes[mybyte]);	/* 01111011 */
    a2 = libcam_in(port1) & 0x00F0;
    if (cam->cantypeindex == 0) {
	mybyte = (unsigned char) 155;
    } else {
	mybyte = (unsigned char) 187;
    }
    libcam_out(port0, cam->bytes[mybyte]);	/* 10111011 */
    a3 = libcam_in(port1) & 0x00F0;
    if (cam->cantypeindex == 0) {
	mybyte = (unsigned char) 27;
    } else {
	mybyte = (unsigned char) 59;
    }
    libcam_out(port0, cam->bytes[mybyte]);	/* 00111011 */
    a4 = libcam_in(port1) & 0x00F0;

    x = ((a1 >> 4) + a2 + (a3 << 4) + (a4 << 8)) ^ 0x8888;
    if (x > 32767)
	x = 32767;
    buffer[j] = (unsigned short) x;

    /* On retire cx2 pixels � la fin */
    for (j = 0; j < cx2; j++)
	audine_read_pel_fast_inv(cam);

    /* Ca c'est pour stocker les pixels dans la memoire      */
    /* centrale. Notons que ca pose PB car il peut y avoir   */
    /* un swap memoire et ca fait sauter le cli. On ne fait  */
    /* le transfert qu'une fois par ligne, pour eviter les   */
    /* cochonneries (utile pour linux, inutile pour windows). */
#if defined(READOPTIC)
    for (j = 1; j <= imax; j++) {
	*(p0++) = buffer[imax + 1 - j];
    }
#else
    for (j = 1; j <= imax; j++) {
	*(p0++) = buffer[j];
    }
#endif
    return 0;
}

void audine_cam_test_out(struct camprop *cam, unsigned long nb_out)
{
    unsigned short port;
    port = cam->port;
    /* Bloquage des interruptions */
    if (cam->interrupt == 1) {
	libcam_bloquer();
    }
    /* Mesure du temps de out */
    test_out_time(port, nb_out, (unsigned long) 0);
    /* Debloquage des interruptions */
    if (cam->interrupt == 1) {
	libcam_debloquer();
    }
    /* Remise a l'heure de l'horloge de Windows */
    if (cam->interrupt == 1) {
	update_clock();
    }
}

/* --- obturateur de Pierre Thierry ---*/
/*
' *************************
' Obturateur Pierre Thierry
' OUVERTURE
' *************************
Function g_obtu_on(port As Integer) As Integer
Dim r As Integer
If InfoPierre.flag = 1 Then
   If InfoPierre.v = InfoPierre.a Then
      InfoPierre.v1 = InfoPierre.c
      r = obtu_pierre(port, InfoPierre.t, InfoPierre.b)
   Else
      InfoPierre.v1 = InfoPierre.a
      r = obtu_pierre(port, InfoPierre.t, InfoPierre.b)
   End If
ElseIf InfoPierre.flag = 2 Then
   If InfoPierre.v = InfoPierre.a Then
      InfoPierre.v1 = InfoPierre.c
   Else
      InfoPierre.v1 = InfoPierre.a
   End If
   InfoPierre.v = InfoPierre.v1
   r = obtu_pierre(port, InfoPierre.t, InfoPierre.v)
Else
   obtu_on (port)
End If
g_obtu_on = 0
End Function
*/
void audine_g_obtu_on(struct camprop *cam)
{
    int r;
    if (cam->InfoPierre_flag == 1) {
	if (cam->InfoPierre_v == cam->InfoPierre_a) {
	    cam->InfoPierre_v1 = cam->InfoPierre_c;
	    r = audine_obtu_pierre(cam->port, cam->InfoPierre_t, cam->InfoPierre_b);
	} else {
	    cam->InfoPierre_v1 = cam->InfoPierre_a;
	    r = audine_obtu_pierre(cam->port, cam->InfoPierre_t, cam->InfoPierre_b);
	}
    } else if (cam->InfoPierre_flag == 2) {
	if (cam->InfoPierre_v == cam->InfoPierre_a) {
	    cam->InfoPierre_v1 = cam->InfoPierre_c;
	} else {
	    cam->InfoPierre_v1 = cam->InfoPierre_a;
	}
	cam->InfoPierre_v = cam->InfoPierre_v1;
	r = audine_obtu_pierre(cam->port, cam->InfoPierre_t, cam->InfoPierre_v);
    } else {
	audine_obtu_on(cam->port);
    }
    return;
}

/*
' *************************
' Obturateur Pierre Thierry
' FERMETURE
' *************************
Function g_obtu_off(port As Integer) As Integer
Dim r As Integer
If InfoPierre.flag = 1 Then
   InfoPierre.v = InfoPierre.v1
   r = obtu_pierre(port, InfoPierre.t, InfoPierre.v)
Else
   obtu_off (port)
End If
g_obtu_off = 0
End Function
*/
void audine_g_obtu_off(struct camprop *cam)
{
    int r;
    if (cam->InfoPierre_flag == 1) {
	cam->InfoPierre_v = cam->InfoPierre_v1;
	r = audine_obtu_pierre(cam->port, cam->InfoPierre_t, cam->InfoPierre_v);
    } else {
	audine_obtu_off(cam->port);
    }
    return;
}


/************* OBTU_PIERRE ****************/
/* Obturateur Pierre Thierry              */
/******************************************/
short audine_obtu_pierre(short base, short t1, short v)
{
    short ctr, x, i, w, k;
    ctr = base + 2;
    for (i = 0; i < t1; i++) {
	for (k = 0; k < v; k++) {
	    x = libcam_in(ctr) & 4;
	    if (x == 4) {
		libcam_out((unsigned short) ctr, (unsigned char) (libcam_in(ctr) ^ 4));
	    }
	}
	w = 16000;
	for (k = 0; k < w; k++) {
	    x = libcam_in(ctr) & 4;
	    if (x == 0) {
		libcam_out((unsigned short) ctr, (unsigned char) (libcam_in(ctr) ^ 4));
	    }
	}
    }
    return (t1);
}

/***************** OBTU_OFF *****************/
/* Met � z�ro du bit 1 du port de controle  */
/********************************************/
short audine_obtu_off(short base)
{
    short ctr, x;
    ctr = base + 2;
    x = libcam_in(ctr) & 2;
    if (x == 2)
	libcam_out((unsigned short) ctr, (unsigned char) (libcam_in(ctr) ^ 2));
    return 0;
}

/*************** OBTU_ON ******************/
/* Met � un du bit 1 du port de controle  */
/******************************************/
short audine_obtu_on(short base)
{
    short ctr, x;
    ctr = base + 2;
    x = libcam_in(ctr) & 2;
    if (x == 0)
	libcam_out((unsigned short) ctr, (unsigned char) (libcam_in(ctr) ^ 2));
    return 0;
}

void audine_updatelog(struct camprop *cam, const char *filename, const char *comment)
{
    char s[100];
    char fname[256];
    FILE *fil;
    if (cam->updatelogindex == 1) {
	Tcl_Eval(cam->interp, "clock format [clock seconds] -format \"%Y-%m-%dT%H:%M:%S.00\"");
	strcpy(s, Tcl_GetStringResult(cam->interp));
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
}
