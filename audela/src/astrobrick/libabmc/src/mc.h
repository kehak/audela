/* mc.h
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

#pragma once
#include <stdio.h>

#include <string>
//using namespace ::std;

//#include "abmc.h" // pour les interfaces des structures

#define TCL_OK			0
#define TCL_ERROR		1
#define TCL_RETURN		2

#define TCL_BREAK		3
#define TCL_CONTINUE		4
#define VSOP87
//#if defined LIBRARY_DLL
#define ELP82
//#endif

#define mc_USNO 0
#define mc_USNOCOMP 1
#define mc_LONEOSCOMP 2

#define OTHERPLANET -2
#define ALLPLANETS -1
#define SOLEIL 0
#define MERCURE 1
#define VENUS 2
#define TERRE 3
#define MARS 4
#define JUPITER 5
#define SATURNE 6
#define URANUS 7
#define NEPTUNE 8
#define PLUTON 9
#define LUNE_ELP 10
#define LUNE 11
#define CERES 12
#define VESTA 13
#define PALLAS 14
#define NB_PLANETES 15

#define MASS_SOLEIL 1.9889e30
#define MASS_MERCURE 3.302e23
#define MASS_VENUS 4.8685e24
#define MASS_TERRE 5.9736e24
#define MASS_MARS 6.4185e23
#define MASS_JUPITER 1.8986e27
#define MASS_SATURNE 5.6846e26
#define MASS_URANUS 8.6832e25
#define MASS_NEPTUNE 1.0243e26
#define MASS_PLUTON 1.314e22

#define PI 3.1415926535897
#define PISUR2 PI/2.
#define DR PI/180
#define PBB 2
#define PB 1
#define NO 1
#define YES 0
#define OK 0
#define OKOK 2
#define B1850 2396758.203
#define B1900 2415020.3135
#define B1950 2433282.4235
#define B1975 2442413.478
#define B2000 2451544.533
#define B2025 2460675.588
#define B2050 2469806.643
#define B2100 2488068.753
#define J1900 2415020.0000
#define J1950 2433282.5000
#define J2000 2451545.0000
#define J2050 2469807.5000
#define J2100 2488070.0000
#define K 0.01720209895  /* constante de gravitation de Gauss (rGM) ua1.5/j */
#define KGEOS 2.999288437593486e-005 /* constante de gravitation de Gauss geocentrique (rGM) ua1.5/j */
#define MAGNULL -99
#define UNKNOWN 0
#define COMETE 1
#define ASTEROIDE 2
#define PLANETE 3
#define MAXCHAINE 256
#define UA 1.49597870691e11
#define CLIGHT 2.99792458e8
#define EARTH_SEMI_MAJOR_RADIUS 6378137 /*WGS 84 */
#define EARTH_INVERSE_FLATTENING 298.257223563 /*WGS 84 */

#define TYPE_MPEC1 1
#define TYPE_MPECDOU 2
#define TYPE_MC 3
#define APPEND 1
#define WRITE 2
/*
#define PLOSS -99
#define TLOSS -99
*/

#define RV_KLSR 0
#define RV_DLSR 1
#define RV_GALC 2
#define RV_LOG  3
#define RV_COSM 4

#define NB_OBJECTLOCALRANGES_MAX 20

// seconds
#define TT_MINUS_TAI 32.184

#define MC_NORAD_SGP 0
#define MC_NORAD_SGP4 1
#define MC_NORAD_SDP4 2
#define MC_NORAD_SGP8 3
#define MC_NORAD_SDP8 4

/***************************************************************************/
/***************************************************************************/
/**                DEFINITON DES STRUCTURES DE DONNEES                    **/
/***************************************************************************/
/***************************************************************************/

/***************************************************************************/
/* Structure des variables d'entree de mc                                  */
/***************************************************************************/
struct mcvar {
   char repertoire1[MAXCHAINE]; /* repertoire des bases de donnees (Bowell) */
   char repertoire2[MAXCHAINE]; /* repertoire de travail */
   char repertoire3[MAXCHAINE]; /* repertoire des fichiers temporaires */
   int choix;                   /* numero du menu d'appel */
   int langage;                 /* choix de la langue */
   char erreur[MAXCHAINE];      /* message d'erreur en retour de mc */
   char chaine1[MAXCHAINE];
   char chaine2[MAXCHAINE];
   char chaine3[MAXCHAINE];
   double reel1;
   double reel2;
   double reel3;
   double reel4;
   double reel5;
   double reel6;
   double reel7;
   int entier1;
   int entier2;
   int entier3;
   char date1[MAXCHAINE];
   char date2[MAXCHAINE];
   double jj1;
   double jj2;
};

/***************************************************************************/
/* Structure des observations astrometriques de position                   */
/***************************************************************************/
struct observ {
   char designation[82]; /* designation de l'objet */
   double jjtu;          /* instant TU d'observation en jour julien */
   double jjtd;          /* instant TD d'observation en jour julien */
   double asd;           /* ascension droite en radian */
   double dec;           /* declinaison en radian      */
   double jj_equinoxe;   /* equinoxe des observations  */
   char codmpc[4];       /* COD MPC */
   double longuai;       /* longitude du lieu UAI (>0 vers l'est) */
   double rhocosphip;    /* r*cos(phi') du lieu */
   double rhosinphip;    /* r*sin(phi') du lieu */
   double mag1;          /* magnitude totale    */
   double ecart_asd;     /* ecart o-c en ascension droite en radian */
   double ecart_dec;     /* ecart o-c en declinaison en radian      */
};

/***************************************************************************/
/* Structure des elements d'orbites coniques employee en interne           */
/***************************************************************************/
struct elemorb {
   char designation[80];/* designation de l'objet */
   char id_norad[20];   /* designation satellite norme NORAD */
   char id_cospar[20];   /* designation satellite norme COSPAR */
   double m0;           /* anomalie moyenne a l'instant jj_m0 */
   double jj_m0;        /* instant de l'anomalie moyenne m0   */
   double e;            /* excentricite a l'instant jj_epoque */
   double q;            /* dist. perihelie a l'instant jj_epoque */
   double jj_perihelie; /* instant de passage au perihelie */
   double i;            /* inclinaison a l'instant jj_epoque rapporte a l'equinoxe jj_equinoxe */
   double o;            /* long. noeud ascend. a l'instant jj_epoque rapporte a l'equinoxe jj_equinoxe */
   double w;            /* argu. du perihelie a l'instant jj_epoque rapporte a l'equinoxe jj_equinoxe */
   double jj_equinoxe;  /* instant de l'equinoxe auqeul se rapportent i o w */
   double jj_epoque;    /* instant des elements e q i o w qui definit l'orbite osculatrice */
   int type;            /* type d'astre (0=inconnu 1=comete 2=asteroide 3=planete 4=geocentrique) */
   double h0;           /* magnitude absolue totale pour une comete */
   double n;            /* parametre d'activite pour une comete */
   double h;            /* magnitude absolue totale pour un asteroide */
   double g;            /* coefficient de phase pour un asteroide */
   int nbjours;
   int nbobs;
   double ceu0;
   double ceut;
   double jj_ceu0;
   int code1;
   int code2;
   int code3;
   int code4;
   int code5;
   int code6;
   double residu_rms;   /* residu o-c rms en arcsec*/
	double ndot; /* derivee 1 du mouvement d'un satellite terrestre */
	double ndotdot; /* derivee 2 du mouvement d'un satellite terrestre */
	double bstar;  /* pression de radiation d'un satellite terrestre */
	double nrevperday; /* nb revolution / jour d'un satellite terrestre */
	double tle_epoch; /* epoch as read in TLEs */
} ;

/***************************************************************************/
/* Structure des elements d'orbites en notation P Q W                      */
/***************************************************************************/
struct pqw {
   double px;
   double py;
   double pz;
   double qx;
   double qy;
   double qz;
   double wx;
   double wy;
   double wz;
} ;

/***************************************************************************/
/* Structure de la carte d'identite d'un asteroide pour la base de Bowell  */
/***************************************************************************/
struct asterident {
   int num;
   char name[23];
   double h;
   double g;
   double bv;
   double rayoniras;
   char classe[10];
   int code1;
   int code2;
   int code3;
   int code4;
   int code5;
   int code6;
   int nbjours;
   int nbobs;
   double jj_epoque;
   double m0;
   double jj_m0;
   double jj_equinoxe;
   double w;
   double o;
   double i;
   double e;
   double a;
   double ceu0;
   double ceut;
   double jj_ceu0;
};


/* --- lecture du catalogue USNO ---*/
typedef struct {
   unsigned long ra;
   unsigned long dec;
   unsigned long divers;
} usnotype;

/* --- lecture du catalogue USNO compresse ---*/
typedef struct {
   unsigned long ra;
   unsigned long dec;
   unsigned char magr;
   unsigned char magb;
} usnocomptype;

/* --- Structure pour definir une etoile ---*/
typedef struct {
   double ra;   /* en degres */
   double dec;  /* en degres */
   short magr; /* mag*100 ou *1000 pour Loneos */
   short magb; /* mag*100 ou *1000 pour Loneos*/
   short magv; /* mag*100 ou *1000 pour Loneos*/
   short magi; /* mag*100 ou *1000 pour Loneos*/
   float x;   /* en pixels */
   float y;  /* en pixels */
   char origin; /* 1:TycMicro 2:GscMicro 3:Usno */
} objetype;

/* --- Lecture USNO methode Buil */
typedef struct {
   int flag;
   int indexRA;
   int indexSPD;
   int offset;
   int nbObjects;
} mc_USNO_INDEX;

/* --- informations sur la transformation carte-image --- */
typedef struct {
   int valid;
   /*-----*/
   double foclen; /* focale en m*/
   double px;     /* pixel en m */
   double py;
   double crota2;
   double cd11;
   double cd12;
   double cd21;
   double cd22;
   double crpix1;
   double crpix2;
   double crval1;
   double crval2;
   double cdelta1;
   double cdelta2;
   double dec0;
   double ra0;
   /*-----*/
   int naxis1;
   int naxis2;
   int astromcatalog;
   char path_astromcatalog[255];
   double bordure;
   double magrsup;
   double magrinf;
   double magbsup;
   double magbinf;
   int tycho_only;
} mc_ASTROM;

/* --- HTM pour courbes de lumieres d'asteroides */
/* --- HTM est valable pour une phase donnee */
typedef struct {
   /* --- name of each triangle */
   char index[10];
   /* --- coordinates of each triangle / asteroid frame / center of asteroid */
   double l;
   double b;
   double l1;
   double b1;
   double l2;
   double b2;
   double l3;
   double b3;
   double r1;
   double r2;
   double r3;
   /* --- */
   double xg;
   double yg;
   double zg;
   double volume;
   double density;
   double mass;
   /* --- */
   double tr;
   double albedo;
   double pr;
   double elamb;
   double els;
   double emin;
   double ephong;
   /* --- coordinates of each triangle / heliocentric frame / center of asteroid */
   double x;
   double y;
   double z;
   double x1;
   double y1;
   double z1;
   double x2;
   double y2;
   double z2;
   double x3;
   double y3;
   double z3;
   /* --- coordinates of each triangle / heliocentric frame / center of sun - for projection and shadows ---*/
   double dl;
   double db;
   double dl1;
   double db1;
   double dl2;
   double db2;
   double dl3;
   double db3;
   double rs;
   double rs1;
   double rs2;
   double rs3;
} mc_htm;

typedef struct {
   int naxis1;
   int naxis2;
   double crval1;
   double crval2;
   double cdelt1;
   double cdelt2;
   double crpix1;
   double crpix2;
   double crota2;
   double cd11;
   double cd12;
   double cd21;
   double cd22;
} mc_wcs;

/* --- CDR positions pour courbes de lumieres d'asteroides */
typedef struct {
   /* --- for each phase index */
   double jdtt;
   double phasett;
   double jd;
   double phase;
   double xaster;
   double yaster;
   double zaster;
   double xearth;
   double yearth;
   double zearth;
   double delta;
   double r;
   double angelong;
   double angphase;
   double mag0;
   double mag1;
   double mag2;
   double mag3;
   double mag4;
   double eclipsed;
} mc_cdrpos;

/* --- CDR pour courbes de lumieres d'asteroides */
typedef struct {
   int htmlevel;
   double lon_phase0; /* rad */
   double jd_phase0; /* JD dans le repere de l'asteroide */
   double jd_phase0tt ; /* JD TT dans le repere terrestre */
   double period; /* sideral, day */
   double lonpole; /* rad */
   double latpole; /* rad */
   int frame_coord; /* =0/ecl =1/equ */
   int frame_center; /* =0/sun =1/earth */
   int frame_time; /* =1 UTC, =2 In the asteroid frame time */
   double albedo;
   double h;
   double g;
   double density;
   double a; /* demi grand axe pour les asteroides doubles */
} mc_cdr;

typedef struct {
	double x;
	double y;
	double z;
	double lon;
	double lat;
	double r;
} struct_point ;


/* --- Modele de pointage de telescopes */
typedef struct {
   int kl;
   int kc;
	double coef;
} mc_modpoi_matx;

/* --- Modele de pointage de telescopes */
typedef struct {
   int k;
	char type[10];
	double coef;
} mc_modpoi_vecy;

/* --- Catalogue astrometrique */
typedef struct {
   int id;
	double ra;
	double dec;
	double mag;
	double mura;
	double mudec;
	double plx;
} mc_cata_astrom;

typedef struct {
   double az;
   double elev;
} mc_HORIZON_ALTAZ;

typedef struct {
   double dec;
   double ha_rise;
   double ha_set;
} mc_HORIZON_HADEC;

typedef struct {
	int ha_defined;
	double ha_rise;
	double ha_set;
	int dec_defined;
	double dec_inf;
	double dec_sup;
	int az_defined;
	double az_rise;
	double az_set;
	int elev_defined;
	double elev_inf;
	double elev_sup;
	char filemap[1024];
} mc_HORIZON_LIMITS;

#define OBJECTDESCR_MAXCOM 50
typedef struct {
	int idseq; // index
	// --- constraints
	double const_jd1; // start sequence (julian day)
	double const_jd2; // stop sequence (julian day)
	double const_elev; // minimum elevation to observe (degrees)
	double const_fullmoondist; // minimum separation to the full moon (degrees)
	double const_sundist; // minimum separation to the sun (degrees)
	double const_skylightlevel; // minimum sky brithness (mag/"2)
	int const_startexposures; // =0 best elevation, =1 start exposure as soon as possible, =2 start in the middle of the [start stop] sequence
	int const_startsynchro; // =0 normal, =1 wait a precice pointing
	// --- user
	int user; // index to define the user
	double user_priority; // priority of the sequence
	double user_quota; // quota of the user (0.-1.)
	// ---
	int axe_type; // 0=radec 1=hadec 2=altaz
	int axe_njd; // number of defined positions
	double axe_equinox;
	double axe_epoch;
	double axe_mura;
	double axe_mudec;
	double axe_plx;
	double axe_jd[20]; // julian day of the positions
	double axe_pos1[20]; // positions of the axis 1
	double axe_pos2[20]; // positions of the axis 2
	double axe_slew1; // slew velocity axis 1 (deg/sec)
	double axe_slew2; // slew velocity axis 2 (deg/sec)
	int axe_slew_synchro; // =0 is to axis slew together. =1 is axis slews after the other
	// --- delays
	double delay_slew; // delay to wait the telescope slewing complete (sec)
	double delay_instrum; // delay to wait the instrument setup complete (sec)
	double delay_exposures; // delay to wait the exposures (+readout) complete (sec)
	// ==========================================================
	// ==== private
	// ==========================================================
	double private_elevmaxi;
	double private_jdelevmaxi;
	int status_plani;
	int nb_plani;
	char comments[OBJECTDESCR_MAXCOM];
} mc_OBJECTDESCR;

/* status plani comments */
#define STATUS_PLANI_NOT_PLANIFIED 0
#define STATUS_PLANI_END_OBS_BEFORE_RANGE 1
#define STATUS_PLANI_START_OBS_AFTER_RANGE 2
#define STATUS_PLANI_NEVER_VISIBLE_IN_RANGE 3
#define STATUS_PLANI_OVER_QUOTA 4
#define STATUS_PLANI_PLANIFIED 5
#define STATUS_PLANI_PLANIFIED_OVER 6

typedef struct {
   double elev;
   double az;
   double ha;
   double dec;
   double ra;
   double moon_dist;
   double sun_dist;
   double skylevel; // -50 = masked by horizon limits, else expected skylight in mag/arcsec2 in V band
	int flagobs; // 0=inobservable, 1=observable, 2=passage a la plus haute elevation
} mc_OBJECTLOCAL;

typedef struct {
   double nbrange;
   double jd1[NB_OBJECTLOCALRANGES_MAX];
   double jd2[NB_OBJECTLOCALRANGES_MAX];
   double jdelevmax[NB_OBJECTLOCALRANGES_MAX];
   double elev1[NB_OBJECTLOCALRANGES_MAX];
   double elev2[NB_OBJECTLOCALRANGES_MAX];
   double elevmax[NB_OBJECTLOCALRANGES_MAX];
} mc_OBJECTLOCALRANGES;

typedef struct {
   double jd;
   double sun_elev;
   double sun_az;
   double moon_elev;
   double moon_az;
   double moon_phase;
   double lst;
} mc_SUNMOON;

typedef struct {
   int idseq;
   int order;
   double jd_slew_start_with_slew;
	double jd_slew_start_without_slew;
   double jd_acq_start;
   double jd_acq_end;
   double percent_quota_used;
   double jd_elev_max;
	//double az;
	//double elev;
	double az_acq_start;
	double elev_acq_start;
	double ra_acq_start;
	double ha_acq_start;
	double dec_acq_start;
	double az_acq_end;
	double elev_acq_end;
	double ra_acq_end;
	double ha_acq_end;
	double dec_acq_end;
} mc_PLANI;

typedef struct {
   int iduser; // that of mc_OBJECTDESCR.user
   double percent_quota_authorized;
	// private
   double percent_quota_used;
	double duration_total_used;
	int same_priority;
	double percent_quota_relative_authorized;
} mc_USERS;



/***************************************************************************/
/***************************************************************************/
/**                    DEFINITION DES FONCTIONS                           **/
/***************************************************************************/
/***************************************************************************/

/***************************************************************************/
/* Menus pour un mode d'utilisation texte                                  */
/***************************************************************************/
void mc_main(void);

void mc_menu1(void);
void mc_menu11(void);
void mc_menu12(void);
void mc_menu13(void);
void mc_menu14(void);
void mc_menu15(void);
void mc_menu16(void);
void mc_menu17(void);
void mc_menu18(void);
void mc_menu19(void);
void mc_menu2(void);
void mc_menu21(void);
void mc_menu22(void);
void mc_menu23(void);
void mc_menu24(void);
void mc_menu25(void);
void mc_menu3(void);
void mc_menu31(void);
void mc_menu4(void);
void mc_menu41(void);
void mc_menu42(void);
void mc_menu43(void);
void mc_menu5(void);
void mc_menu51(void);
void mc_menu6(void);
void mc_menu61(void);
void mc_menu62(void);
void mc_menu63(void);
void mc_menu64(void);
void mc_menu7(void);
void mc_menu71(void);
void mc_menu72(void);
void mc_menu8(void);
void mc_menu81(void);

void mc_separligne(char a);
void mc_menu_entete(char *texte);
void mc_inputdate(char *intitule,char *contrainte, char *date);
void mc_inputfile(char *intitule, char *nom_fichier);
void mc_inputnumber(char *intitule,char *contrainte, double *nombre);
void mc_outputfile(char *intitule, char *nom_fichier);

/***************************************************************************/
/* Gestion des choix de calcul de MC                                       */
/***************************************************************************/
void mc_entree(struct mcvar *param);
void mc_paramjj(char *date,char *contrainte, double *jj);

/***************************************************************************/
/* Macro fonctions a appeler de l'exterieur                                */
/***************************************************************************/

void mc_macro11(char *nom_fichier_obs,double delta,char *nom_fichier_ele);
void mc_macro12(char *nom_fichier_obs,double a,char *nom_fichier_ele);
void mc_macro13(char *nom_fichier_obs,char *nom_fichier_ele);
void mc_macro14(char *nom_fichier_obs,double offc, double offl,char *nom_fichier_ele);
void mc_macro15(char *nom_fichier_obs,char *nom_fichier_ele);
void mc_macro16(char *nom_fichier_obs,char *nom_fichier_ele);
void mc_macro17(char *nom_fichier_obs,char *nom_fichier_ele);
void mc_macro18(char *nom_fichier_obs,char *nom_fichier_ele);
void mc_macro19(char *nom_fichier_obs,double e,char *nom_fichier_ele);
void mc_macro21(char *nom_fichier_bow,char *num_objet,char *nom_fichier_ele);
void mc_macro22(char *nom_fichier_ele1,char *nom_fichier_ele2);
void mc_macro23(char *nom_fichier_ele1,char *nom_fichier_ele2);
void mc_macro24(char *nom_fichier_ele1,char *nom_fichier_ele2);
void mc_macro25(char *nom_fichier_ele1,char *nom_fichier_ele2);
void mc_macro31(char *nom_fichier_ele1,double jj,char *nom_fichier_ele2);
void mc_macro41(char *nom_fichier_ele,double jjdeb, double jjfin,double jjpas,char *nom_fichier_out);
void mc_macro42(char *nom_fichier_ele,double jj, double heuretu, double rangetq, double pastq, double equinoxe, char *nom_fichier_out);
void mc_macro43(char *nom_fichier_ele,double jjdeb, double jjfin,double jjpas,char *nom_fichier_out);
void mc_macro51(char *nom_fichier_ele,double jjdeb, double jjfin,double jjpas,char *nom_fichier_out);
void mc_macro61(char *nom_fichier_in,char *nom_fichier_out);
void mc_macro62(char *nom_fichier_in,char *nom_fichier_ele,char *nom_fichier_out);
void mc_macro63(double latitude,double altitude);
void mc_macro64(double rhocosphip,double rhosinphip);
void mc_macro71(char *nom_fichier_bow,double jjdeb, double jjfin);
void mc_macro72(char *nom_fichier_bow,double jjdeb, double jjfin,double magmax,double magmin,double elong,double decmax,double decmin,double incmax,double incmin,int flag1,int flag2,int flag3);
void mc_macro81(char *nom_fichier_bow,double jj, double heuretu,double asd, double dec, double champ,char *nom_fichier_out);

void mc_baryvel(double jj,double longmpc,double rhocosphip,double rhosinphip, double asd0, double dec0, double *x_helio,double *y_helio,double *z_helio, double *vx_helio,double *vy_helio,double *vz_helio, double *v_helio,double *hjd, double *x_bary,double *y_bary,double *z_bary, double *vx_bary,double *vy_bary,double *vz_bary, double *v_bary,double *bjd);
void mc_rvcor(double asd0, double dec0, double equinox, int reference, double *v);
void mc_adastrom(double jj, struct elemorb elem, double equinoxe, double *asd, double *dec, double *delta,double *rr,double *rsol);
void mc_adasaap(double jj,double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, struct elemorb elem, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr);
void mc_xyzasaaphelio(double jj,double jjutc, double equinoxe, int astrometric,double longmpc,double rhocosphip,double rhosinphip, struct elemorb elem, int frame, double *xearth,double *yearth,double *zearth,double *xaster,double *yaster,double *zaster, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr);
void mc_adplaap(double jj,double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, int planete, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun);
void mc_adlunap(int planete, double jj, double jjutc, double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip,double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun);
void mc_adsolap(double jj,double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun);
void mc_adelemap(double jj,double jjutc, double equinoxe, int astrometric, struct elemorb elem, double longmpc,double rhocosphip,double rhosinphip, int planete, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun,double *sunfraction);
void mc_adelemap_sgp(int sgp_method,double jj,double jjutc, double equinoxe, int astrometric, struct elemorb elem, double longmpc,double rhocosphip,double rhosinphip, int planete, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun,double *sunfraction,double *zenith_longmpc,double *zenith_latmpc,double *azimuth, double *elevation, double *parallactic, double *hour_angle,double *zenith_dist);
void mc_adshadow(double jj,double jjutc, double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, double nrevperday, double *asd_center, double *dec_center, double *semi_angle_eq, double *semi_angle_po, double *asd_west, double *dec_west, double *asd_east, double *dec_east, double *asd_north, double *dec_north, double *asd_south, double *dec_south, double *asd_satel_west, double *asd_satel_east, double *dec_satel, double *impact);
void mc_xyzgeoelem(double jj,double jjutc, double equinoxe, int astrometric, struct elemorb elem, double longmpc,double rhocosphip,double rhosinphip, int planete, double *xageo, double *yageo, double *zageo, double *xtgeo, double *ytgeo, double *ztgeo, double *xsgeo, double *ysgeo, double *zsgeo, double *xlgeo, double *ylgeo, double *zlgeo);
void mc_affielem(struct elemorb elem);
void mc_bowell1(char *nom_fichier_in,double jj,double equinoxe,double lim_mag_sup, double lim_mag_inf,double lim_elong,double lim_dec_sup, double lim_dec_inf,double lim_inc_sup, double lim_inc_inf,int flag1,int flag2,int flag3,char *nom_fichier_out);
void mc_bowell3(char *nom_fichier_in,double jj,double asd0, double dec0,double equinoxe,double dist0, char *nom_fichier_out);
void mc_bowell4(char *nom_fichier_in,char *num_aster,double jjdeb,double jjfin, double pasjj, double equinoxe, char *nom_fichier_out,int *concordance);
void mc_changepoque(char *nom_fichier_ele_deb,char *num_aster,double jj, double equinoxe, char *nom_fichier_ele_fin,int *concordance);
void mc_ephem1(char *nom_fichier_ele,double jjdeb,double jjfin, double pasjj, double equinoxe, char *nom_fichier_out,int *concordance);
void mc_lec_mpc_auto(char *nom_fichier_in,struct observ *obs, int *nbobs);
void mc_typedaster(struct asterident aster, char *ligne);
void mc_xvxpla(double jj, int planete, double jj_equinoxe, double *x, double *y,double *z, double *vx, double *vy,double *vz);

void mc_determag(struct elemorb *elem, struct observ *obs, int nbobs);
void mc_bowell22(char *nom_fichier_in,char *num_aster,char *nom_fichier_out,int *concordance);
void mc_ephem1b(char *nom_fichier_ele,double jjdeb,double jjfin, double pasjj, double equinoxe, char *nom_fichier_out,int *concordance);
void mc_ephem2(char *nom_fichier_ele,double jj, double rangetq, double pastq, double equinoxe, char *nom_fichier_out,int *concordance);
void mc_paradist(char *nom_fichier_obs,char *nom_fichier_ele,char *nom_fichier_out);
void mc_paradist_calc(struct observ *obs,int k1, int k2,double *parallaxe,double *corde,double *dist);
void mc_simulc(mc_cdr cdr,double *relief,double *albedo,mc_cdrpos *cdrpos,int n,char *genefilename);
void mc_simulc_sat_stl(mc_cdr cdr,struct_point *point1,struct_point *point2,struct_point *point3,struct_point *point4,int n_in,double albedo,mc_cdrpos *cdrpos,int n,char *genefilename);
void mc_simulcbin(mc_cdr cdr,double *relief1,double *albedo1,double *relief2,double *albedo2,mc_cdrpos *cdrpos,int n,char *genefilename);
char *mc_savefits(float *mat,int naxis1, int naxis2,char *filename,mc_wcs *wcs);

void mc_norad_sgdp48(double jj,int sgp, struct elemorb *elem,double *xgeo,double *ygeo,double *zgeo,double *vxgeo,double *vygeo,double *vzgeo);

/***************************************************************************/
/* Determination des elements d'orbite.                                    */
/***************************************************************************/

void mc_cu2xyzeq(double l,double m,double n,double *a,double *ll, double *mm, double *nn);
void mc_elemplus(struct observ *obs,struct elemorb *elem,int nbobs);
void mc_elemtype(struct elemorb *elem);
void mc_gem3(struct observ *obs,struct elemorb *elem,double jj_equinoxe);
void mc_herget2(struct observ *obs,double *delta,struct elemorb *elem,double jj_equinoxe);
void mc_matcunni(double ll1, double mm1, double nn1, double ll3, double mm3, double nn3, double *a);
void mc_mvc2a(struct observ *obs,double delta,struct elemorb *elem,double jj_equinoxe);
void mc_mvc3a(struct observ *obs,struct elemorb *elem,double jj_equinoxe);
void mc_mvc3b(struct observ *obs,struct elemorb *elem,double jj_equinoxe);
void mc_xyzeq2cu(double ll,double mm,double nn,double *a,double *l, double *m, double *n);
void mc_secratio(double r1, double r2, double kay, double dt, double kgrav, double *y);
double mc_secratiq(double x);

void mc_gem3b(struct observ *obs,double offc, double offl,struct elemorb *elem,double jj_equinoxe);
void mc_mvc2b(struct observ *obs,struct elemorb *elem,double jj_equinoxe);
void mc_mvc2c(struct observ *obs,double aa,struct elemorb *elem,double jj_equinoxe);
void mc_mvc2d(struct observ *obs,double ee,struct elemorb *elem,double jj_equinoxe);

void mc_orbi_auto(char *nom_fichier_obs,char *nom_fichier_ele);
void mc_rms_obs(struct elemorb *elem, struct observ *obs, int nbobs);

/***************************************************************************/
/* Utilitaires de petits calculs astro (magnitudes, elongation ...)        */
/***************************************************************************/
void mc_quicksort_double(double *arr, int low, int high, int *karr);
void mc_elonphaslimb(double asd, double dec, double asds, double decs, double r, double delta, double *elong, double *phase, double *posang_brightlimb);
void mc_elonphas(double r, double rsol, double delta, double *elong, double *phase);
void mc_magaster(double r, double delta, double phase, double h, double g, double *mag);
void mc_magplanet(double r,double delta,int planete,double phase,double l,double b,double *mag,double *diamapp);
void mc_magcomete(double r, double delta, double h0, double n, double *mag);
void mc_sepangle(double a1, double a2, double d1, double d2, double *dist, double *posangle);
void mc_libration(double jj,int planete,double longmpc,double rhocosphip,double rhosinphip,double *lonc, double *latc, double *p,double *lons, double *lats);
void mc_physephem(double jj,int planete,double xg,double yg,double zg,double x,double y,double z,
                  double *diamapp_equ,double *diamapp_pol,
                  double *long1,double *long2,double *long3,double *lati,double *posangle_north,
                  double *posangle_sun,double *long1_sun,double *lati_sun);
int mc_util_cd2cdelt_old(double cd11,double cd12,double cd21,double cd22,double *cdelt1,double *cdelt2,double *crota2);
int mc_htm_testin(double *v0, double *v1, double *v2, double *v);
int mc_radec2htm(double ra,double dec,int niter,char *htm);
int mc_htm2radec(char *htm,double *ra,double *dec,int *niter,double *ra0,double *dec0,double *ra1,double *dec1,double *ra2,double *dec2);

int intersect_triangle(double orig[3], double dir[3],double vert0[3], double vert1[3], double vert2[3], double *t, double *u, double *v);

/***************************************************************************/
/* Transformations du temps (jour julien, temps dynamique ...)             */
/***************************************************************************/
void mc_equinoxe_jd(const char *chaine,double *jj);
void mc_date_jd(int annee, int mois, double jour, double *jj);
void mc_jd_date(double jj, int *annee, int *mois, double *jour);
void mc_jd_equinoxe(double jj, char *chaine);
void mc_jd_equinoxe2(double jj,int year_type,int nb_subdigit, char *chaine);
void mc_tsl(double jj,double longitude,double *tsl);
void mc_td2tu(double jjtd,double *jjtu);
void mc_tu2td(double jjtu,double *jjtd);
void mc_tdminusut(double jj,double *dt);
void mc_jd2dateobs(double jj, char *date);
void mc_dateobs2jd(const char *date, double *jj);

/***************************************************************************/
/* Corrections de precession, nutation, aberration ...                     */
/***************************************************************************/
void mc_parallaxe_stellaire(double jj,double asd1,double dec1,double *asd2,double *dec2,double plx_mas);
void mc_aberration_annuelle(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe);
void mc_aberration_eterms(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe);
void mc_aberration_diurne(double jj,double asd1,double dec1, double longuai, double rhocosphip, double rhosinphip,double *asd2,double *dec2,int signe);
void mc_aberpla(double jj1, double delta, double *jj2);
void mc_latalt2rhophi(double latitude,double altitude,double *rhosinphip,double *rhocosphip);
void mc_nutation(double jj, int precision, double *dpsi, double *deps);
void mc_nutradec(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe);
void mc_obliqmoy(double jj, double *eps);
void mc_paraldxyzeq(double jj, double longuai, double rhocosphip, double rhosinphip, double *dxeq, double *dyeq, double *dzeq);
void mc_precelem(struct elemorb elem1, double jd1, double jd2, struct elemorb *elem2);
void mc_precxyz(double jd1, double x1, double y1, double z1, double jd2, double *x2, double *y2, double *z2);
void mc_precad(double jd1, double asd1, double dec1, double jd2, double *asd2, double *dec2);
void mc_preclb(double jd1, double lon1, double lat1, double jd2, double *lon2, double *lat2);
void mc_rhophi2latalt(double rhosinphip,double rhocosphip,double *latitude,double *altitude);
void mc_refraction(double h,int inout,double temperature,double pressure,double *refraction);
void mc_corearthsatelem(double jj,struct elemorb *elem);
void mc_refraction2(double h,int inout,double tk,double ppa, double lnm, double hump, double latd, double altm, double *refraction);
void mc_refraction_coef_fz(double zdeg,double *fz);
void mc_refraction_coef_gz(double zdeg,double *gz);
void mc_refraction_coef_r0(double zdeg, double *r0);
void mc_refraction_coef_a(double zdeg, double t, double *a);
void mc_refraction_coef_b(double zdeg, double p, double *b);
void mc_refraction_coef_c(double zdeg, double lnm, double *c);
void mc_refraction_coef_d(double zdeg, double f, double *dd);
void mc_refraction_coef_e(double zdeg, double phi, double *e);
void mc_refraction_coef_h(double zdeg, double altm, double *h);
void mc_refraction_coef_fsat(double t, double *fsat);
void mc_refraction_coef_r(double z0, double tk, double ppa, double lnm,double hump,double latd, double altm,double *r);

/***************************************************************************/
/* Utilitaires mathematiques                                               */
/***************************************************************************/
double mc_deg(double valeur);
void mc_deg2d_m_s(double valeur,char *charsigne,int *d,int *m,double *s);
void mc_deg2h_m_s(double valeur,int *h,int *m,double *s);
double mc_dms(double valeur);
double mc_frac(double x);
void mc_fstr(double valeur, int signe, int nbint, int nbfrac,int zeros,char *chaine);
void mc_prodscal(double x1, double y1,double z1, double x2,double y2,double z2, double *p);
void mc_prodvect(double x1, double y1,double z1, double x2,double y2,double z2, double *x3, double *y3, double *z3);
double mc_sgn(double arg);
double mc_sgn2(double arg);
void mc_strupr(char *chainein, char *chaineout);
double mc_acos(double x);
double mc_asin(double x);
double mc_atan2(double y, double x);
double mc_sqrt(double x);

/***************************************************************************/
/* Transformation de systemes de coordonnees                               */
/***************************************************************************/
void mc_anomoy(struct elemorb elem,double jd,double *m);
void mc_anovrair(struct elemorb elempla,double m,double *v,double *r);
void mc_aster2elem(struct asterident aster, struct elemorb *elem);
void mc_copyelem(struct elemorb elem1, struct elemorb *elem2);
void mc_elem2aster(struct elemorb elem,struct asterident *aster);
void mc_elempqec(struct elemorb elem, struct pqw *vect);
void mc_elempqeq(struct pqw vectec, double eps, struct pqw *vecteq);
void mc_he2ge(double xh,double yh,double zh,double xs,double ys,double zs,double *xg,double *yg,double *zg);
void mc_lbr2xyz(double l, double b, double r, double *x, double *y, double *z);
void mc_rv_xyz(struct pqw vectpqw, double r, double v, double *x, double *y, double *z);
void mc_rv_vxyz(struct pqw vectpqw, struct elemorb elem, double r, double v, double *vx, double *vy, double *vz);
void mc_xvx2elem(double x, double y, double z, double vx, double vy, double vz, double jj, double jj_equinoxe, double kgrav, struct elemorb *elem);
void mc_xyz2lbr(double x, double y, double z, double *l, double *b, double *r);
void mc_xyz2add(double xg, double yg, double zg, double *asd, double *dec, double *delta);
void mc_xyzec2eq(double xec, double yec, double zec, double eps, double *xeq, double *yeq, double *zeq);
void mc_xyzeq2ec(double xeq, double yeq, double zeq, double eps, double *xec, double *yec, double *zec);
void mc_ad2hd(double jd, double longuai, double asd, double *ha);
void mc_hd2ad(double jd, double longuai, double ha, double *asd);
void mc_hd2parallactic(double ha, double dec, double latitude, double *parallactic);
void mc_hd2parallactic_altalt(double ha, double dec, double latitude, double *parallactic);
void mc_hd2ah(double ha, double dec, double latitude, double *az, double *h);
void mc_ah2hd(double az, double h, double latitude, double *ha, double *dec);
void mc_hd2rp(double ha, double dec, double latitude, double *az, double *h);
void mc_rp2hd(double az, double h, double latitude, double *ha, double *dec);
void mc_ad2ah(double jd, double longuai, double latitude, double asd, double dec, double *az,double *h);
void mc_radec2galactic(double ra2000, double dec2000, double *lon,double *lat);
void mc_galactic2radec(double lon,double lat, double *ra2000, double *dec2000);
void mc_map_xy2lonlat(double lc, double bc, double p, double f, double xc, double yc, double rc, double ls, double bs, double power,double i,double j,double *lon,double *lat,double *visibility);
void mc_map_lonlat2xy(double lc, double bc, double p, double f, double xc, double yc, double rc, double ls, double bs, double power,double lon,double lat,double *i,double *j,double *visibility);

/***************************************************************************/
/* Utilitaires de gestion de fichiers (base de Bowell, tri ...)            */
/***************************************************************************/
void mc_mpc_dec1(char *ligne, struct asterident *aster);
void mc_bow_dec1(char *ligne, struct asterident *aster);
void mc_bow_dec2(char *num_aster, char *nom_fichier_in,struct elemorb *elem,struct asterident *aster,int *concordance);
void mc_bow_dec3(char *num_aster, char *nom_fichier_in,int *concordance,char *nom_fichier_ele);
void mc_lec_obs_mpc(char *nom_fichier_in, struct observ *obs, int *nbobs);
void mc_lec_station_mpc(char *nom_fichier_station, char *station, double *longmpc, double *rhocosphip, double *rhosinphip);
void mc_readelem(char *nom_fichier_in,struct elemorb *elem);
void mc_select_observ(struct observ *obsin, int nbobsin,char *designation,struct observ *obsout,int *nbobsout);
void mc_select32_observ(struct observ *obsin, int nbobsin,struct observ *obsout,int *nbobsout,int contrainte);
void mc_tle_decnext1(FILE *ftle,struct elemorb *elem,char *name,int *valid);
void mc_tri1(char *nom_in, char *nom_out);
void mc_tri2(char *nom_in, char *nom_out,char *nom_ref);
int mc_util_comptelignes(char *nom,int *nblignes);
void mc_writeelem(struct elemorb *elem,char *nom_fichier_out);

void mc_bowspace(char *nom_fichier_in,char *nom_fichier_out,int *concordance);
void mc_convformat(int flag,char *nom_fichier_ele1,char *nom_fichier_ele2, int *concordance);
void mc_fprfbow1(int flag, double equinoxe,FILE *fichier_out,int *nblighead);
void mc_fprfbow11(char *name,double asd,double dec,double mag,double delta,struct asterident aster,double incert,double dist,double posangle,FILE *fichier_out);
void mc_fprfeph1(int flag, double equinoxe,struct elemorb elem, FILE *fichier_out,int *nblighead);
void mc_fprfeph21(int flag,struct elemorb elem,double jj,double asd,double dec,double mag,double delta,double r,double elong,double dist,double posangle,double incert,FILE *fichier_out);
void mc_fprfeph2(int flag, double equinoxe, double jj, struct elemorb elem, FILE *fichier_out,int *nblighead);
void mc_fprfeph22(int flag,struct elemorb elem,double jj,double asd,double dec,double mag,double delta,double r,double elong,double dist,double posangle,double incert,FILE *fichier_out);
void mc_lec_ele_mpec1(char *nom_fichier_in, struct elemorb *elem,int *concordance,int *ligfin);
void mc_mpec_check(struct elemorb *elem,struct elemorb *elemok,int *check);
void mc_mpec_datesjjjj(char *ligne, char *motcle,char *argument1,char *argument2);
void mc_mpec_datejj(char *ligne, char *motcle,char *argument);
void mc_mpec_argnum(char *ligne, char *motcle,char *argument);
void mc_mpec_argbowell(char *ligne, char *motcle,char *argument);
void mc_mpec_t2amj(char *texte, int *annee, int *mois, double *jour);
void mc_mpec_jjjjdates(double jj1, double jj2, char *texte);
void mc_mpec_mois(int mois,char *texte);
void mc_typedastre(struct elemorb elem,char *astre);
void mc_wri_ele_mpec1(char *nom_fichier_out, struct elemorb elem,int type_fichier);

void mc_lec_mpc_noms(char *nom_fichier_obs,char *nom_fichier_noms);

/***************************************************************************/
/* Calculs d'ephemerides precises des planetes, du Soleil ...              */
/***************************************************************************/
void mc_jd2elem1(double jj, int planete, struct elemorb *elempla);
void mc_jd2lbr1a(double jj, double *l, double *m, double *u);

void mc_jd2lbr1b(double jj, int planete, double *l, double *m, double *u, double *ll, double *bb, double *rr);
void mc_jd2lbr_vsop87_mer(double jj, double *ll, double *bb, double *rr);
void mc_jd2lbr_vsop87_ven(double jj, double *ll, double *bb, double *rr);
void mc_jd2lbr_vsop87_ear(double jj, double *ll, double *bb, double *rr);
void mc_jd2lbr_vsop87_mar(double jj, double *ll, double *bb, double *rr);
void mc_jd2lbr_vsop87_jup(double jj, double *ll, double *bb, double *rr);
void mc_jd2lbr_vsop87_sat(double jj, double *ll, double *bb, double *rr);
void mc_jd2lbr_vsop87_ura(double jj, double *ll, double *bb, double *rr);
void mc_jd2lbr_vsop87_nep(double jj, double *ll, double *bb, double *rr);
void mc_jd2lbr_vsop87_compute(double jj,
   double *l0,double *l1,double *l2,double *l3,double *l4,double *l5, int lmax, int *lalpha,
   double *b0,double *b1,double *b2,double *b3,double *b4,double *b5, int bmax, int *balpha,
   double *r0,double *r1,double *r2,double *r3,double *r4,double *r5, int rmax, int *ralpha,
   double *ll, double *bb, double *rr);

void mc_jd2lbr1c(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0);
void mc_jd2lbr1d(double jj, double *ll0, double *bb0, double *rr0);
void mc_jd2lbr2d(double jj, double *ll0, double *bb0, double *rr0);
void mc_jd2lbr1e(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0);
void mc_jd2lbr1f(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0);
void mc_jd2lbr1g(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0);
void mc_jd2lbr1h(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0);

void mc_elp10(double *elp, double pla_me, double pla_ve, double tt, double pla_ma, double pla_ju, double pla_sa, double pla_ur, double pla_ne, double d, double l, double f);
void mc_elp11(double *elp, double pla_me, double pla_ve, double tt, double pla_ma, double pla_ju, double pla_sa, double pla_ur, double pla_ne, double d, double l, double f);
void mc_elp12(double *elp, double pla_me, double pla_ve, double tt, double pla_ma, double pla_ju, double pla_sa, double pla_ur, double pla_ne, double d, double l, double f);
void mc_elp13(double *elp, double pla_me, double pla_ve, double tt, double pla_ma, double pla_ju, double pla_sa, double pla_ur, double pla_ne, double d, double l, double f);

/***************************************************************************/
/* Utilitaires de gestion de catalogues (Usno, MicroCat, ...)              */
/***************************************************************************/
int mc_ima_series_catchart_2(mc_ASTROM p,int *nbobj, int nbobjmax, objetype *objs,char *outfilename);
void mc_ComputeUsnoIndexs(double ra,double de,int *indexSPD,int *indexRA);
double mc_R2D(double a);
double mc_D2R(double a);
int mc_Big2LittleEndianLong(int l);
double mc_GetUsnoBleueMagnitude(int magL);
double mc_GetUsnoRedMagnitude(int magL);
int mc_util_astrom_radec2xy(mc_ASTROM *p,double ra,double dec, double *x,double *y);
int mc_util_astrom_xy2radec(mc_ASTROM *p, double x,double y,double *ra,double *dec);
int mc_fitspline(int n1,int n2,double *x, double *y, double *dy, double s,int nn, double *xx, double *ff);
int mc_interplin1(int n1,int n2,double *x, double *y, double *dy, double s,int nn, double *xx, double *ff);
int mc_interplin2(int n1,int n2,double *x, double *y, double *dy, double s,int nn, double *xx, double *ff);
char *mc_d2s(double val);
int mc_readhip(char *hip_main_file, char *bits, double *values, int *nstars, mc_cata_astrom *hips);
int mc_meo_ruban(double az, double montee,double descente,double largmontee,double largdescente,double amplitude,double *daz);

/***************************************************************************/
/* Utilitaires de planificateur d'observations                             */
/***************************************************************************/
int mc_sheduler_interpcoords(mc_OBJECTDESCR *objectdescr,double jd,double *pos1,double *pos2);
int mc_sheduler_corccoords(mc_OBJECTDESCR *objectdescr);
int mc_obsconditions1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,mc_HORIZON_ALTAZ *horizon_altaz,mc_HORIZON_HADEC *horizon_hadec,int nobj,mc_OBJECTDESCR *objectdescr,double djd,char *fullfilename);
int mc_scheduler1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,mc_HORIZON_ALTAZ *horizon_altaz,mc_HORIZON_HADEC *horizon_hadec,int nobj,mc_OBJECTDESCR *objectdescr,int output_type, char *output_file, char *log_file);
int mc_nextnight1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,double elev_set,double elev_twilight, double *jdprev, double *jdset,double *jddusk,double *jddawn,double *jdrise,double *jdnext,double *jdriseprev2,double *jdmer2,double *jdset2,double *jddusk2,double *jddawn2,double *jdrisenext2);
int mc_sheduler_coord_app2cat(double jd,double ra,double dec,double equinox,double *racat,double *deccat);

/***************************************************************************/
/* Integration numerique pour le mouvement des n corps.                    */
/***************************************************************************/
void mc_inimasse(double *mass);
void mc_integ1(double jjdeb, double jjfin, double jjpas, struct elemorb elem,double jj_equinoxe, double *x, double *y, double *z, double *vx, double *vy, double *vz);
void mc_rk4(double tdeb, double tfin, double *x, int dimx, char *nom_fichier_out,double *masse,double pas);
void mc_rk45(double tdeb, double tfin, double *x, int dimx, char *nom_fichier_out,double *masse,double tl);
void mc_equa_dif2(double *x,int dimx,double *z,double *masse);

/***************************************************************************/
/* Modele de pointage                                                      */
/***************************************************************************/
double mc_modpoi_addobs_az(double az,double h,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx);
double mc_modpoi_addobs_h(double az,double h,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx);
double mc_modpoi_addobs_ha(double ha,double dec,double latrad,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx);
double mc_modpoi_addobs_dec(double ha,double dec,double latrad,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx);

/***************************************************************************/
/***************************************************************************/
/**               INTITULE ET LOCALISATION DES FONCTIONS                  **/
/***************************************************************************/
/***************************************************************************/

/***************************************************************************/
/* Macro fonctions a appeler de l'exterieur                                */
/***************************************************************************/
/*
MC_MACR2.C
void mc_baryvel(double jj,double longmpc,double rhocosphip,double rhosinphip, double asd0, double dec0, double *x_helio,double *y_helio,double *z_helio, double *vx_helio,double *vy_helio,double *vz_helio, double *v_helio, ,double *hjd, double *x_bary,double *y_bary,double *z_bary, double *vx_bary,double *vy_bary,double *vz_bary, double *v_bary,double *bjd);
   Calcule la vitesse de la Terre
void mc_rvcor(double asd0, double dec0, double equinox, int reference, double *v);
   Calcule la correction de vitesse radiale dans un refentiel donne
void mc_adastrom(double jj, struct elemorb elem, double equinoxe, double *asd, double *dec, double *delta,double *rr,double *rsol);
   Calcul de l'asd, dec et distance a jj donne rapporte a un equinoxe
   pour un astre defini par ses elements d'orbite.
void mc_adasaap(double jj,double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, struct elemorb elem, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr);
   Calcul de l'asd, dec et distance a jj donne rapporte a un equinoxe
   pour un astre defini par ses elements d'orbite.
void mc_xyzasaaphelio(double jj,double jjutc, double equinoxe, int astrometric,double longmpc,double rhocosphip,double rhosinphip, struct elemorb elem, int frame, double *xearth,double *yearth,double *zearth,double *xaster,double *yaster,double *zaster, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr);
   Calcul de coord. cartesiennes heliocentriquesa jj donne rapporte a un equinoxe
   pour un astre defini par ses elements d'orbite.
void mc_adplaap(double jj,double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, int planete, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun)
   Calcul de l'asd, dec et distance apparentes d'une planete a jj donne.
void mc_adlunap(int planete, double jj, double jjutc, double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip,double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun);
   Calcul de l'asd, dec et distance apparentes de la Lune a jj donne.
void mc_adsolap(double jj,double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun)
   Calcul de l'asd, dec et distance apparentes du Soleil a jj donne
void mc_adelemap(double jj,double jjutc, double equinoxe, int astrometric, struct elemorb elem, double longmpc,double rhocosphip,double rhosinphip, int planete, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun,double *sunfraction);
   Calcul de l'asd, dec et distance apparentes d'un astre defini par ses elements d'orbite a jj donne.
void mc_adelemap_sgp(int sgp_method,double jj,double jjutc, double equinoxe, int astrometric, struct elemorb elem, double longmpc,double rhocosphip,double rhosinphip, int planete, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun,double *sunfraction,double *zenith_longmpc,double *zenith_latmpc,double *azimuth, double *elevation, double *parallactic, double *hour_angle);
   Calcul de l'asd, dec et distance apparentes d'un astre defini par ses  elements d'orbite GEOCENTRIQUES uniquement a jj donne.
void mc_adshadow(double jj,double jjutc, double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, double nrevperday, double *asd_center, double *dec_center, double *semi_angle_eq, double *semi_angle_po, double *asd_west, double *dec_west, double *asd_east, double *dec_east, double *asd_north, double *dec_north, double *asd_south, double *dec_south, double *asd_satel_west, double *asd_satel_east, double *dec_satel, double *impact);
   Calcul de l'asd, dec de l'ombre de la Terre
void mc_affielem(struct elemorb elem);
   Affiche les elements d'orbite en clair a l'ecran.
void mc_bowell1(char *nom_fichier_in,double jj,double equinoxe,double lim_mag_sup, double lim_mag_inf,double lim_elong,double lim_dec_sup, double lim_dec_inf,double lim_inc_sup, double lim_inc_inf,int flag1,int flag2,int flag3,char *nom_fichier_out);
   Genere un fichier ASCII d'ephemerides des petites planetes de la base
   de Bowell pour jj donne rapporte a un equinoxe. On donne des criteres
   de selection tels que la limite en elongation, la limite en magnitude...
void mc_bowell3(char *nom_fichier_in,double jj,double asd0, double dec0,double equinoxe,double dist0, char *nom_fichier_out);
   Genere un fichier ASCII d'ephemerides des petites planetes a numero
   provisoire pour jj donne rapporte a un equinoxe. On donne un critere
   de centre du champ asd,dec + un cercle angulaire centre
void mc_bowell4(char *nom_fichier_in,char *num_aster,double jjdeb,double jjfin, double pasjj, double equinoxe, char *nom_fichier_out,int *concordance);
   Changement d'epoque d'elements d'orbite par integration numerique.
void mc_changepoque(char *nom_fichier_ele_deb,char *num_aster,double jjdeb,double jjfin, double pasjj, double equinoxe, char *nom_fichier_ele_fin,int *concordance);
   Changement d'epoque d'elements d'orbite par integration numerique a
   a partir des elements a une autre epoque.
void mc_ephem1(char *nom_fichier_ele,double jjdeb,double jjfin, double pasjj, double equinoxe, char *nom_fichier_out,int *concordance);
   Genere un fichier ASCII d'ephemerides pour un astre defini par ses
   elements d'orbite.
void mc_lec_mpc_auto(char *nom_fichier_in,struct observ *obs, int *nbobs);
   Macro destinee a charger la serie de trois dates d'observations du
   premier objet rencontre dans la base *nom_fichier_in au format MPC.
void mc_typedaster(struct asterident aster, char *ligne);
  Genere un ligne de mots clairs qui designe le type d'asteroide a partir
  des 6 codes de la base de Bowell.
void mc_xvxpla(double jj, int planete, double jj_equinoxe, double *x, double *y,double *z, double *vx, double *vy,double *vz);
   Calcul de pos. et vit. cart. equ. heliocent. d'une planete a jj donne.
MC_MACR3.C
void mc_determag(struct elemorb *elem, struct observ *obs, int nbobs);
   Determination du coef de magnitude absolue pour un asteroide
   La valeur de g=0.15
void mc_bowell22(char *nom_fichier_in,char *num_aster,char *nom_fichier_out,int *concordance);
   Transforme les elements d'orbite initialement au format de la base de
   Bowell en elements d'orbite au format interne
   On rentre, soit le numero (ex : 1 pour Ceres) ou bien le numero
   provisoire toutes lettres collees (ex : 1997DQ).
void mc_ephem1b(char *nom_fichier_ele,double jjdeb,double jjfin, double pasjj, double equinoxe, char *nom_fichier_out,int *concordance);
   Genere un fichier ASCII d'ephemerides pour des astres definis par leurs
   elements d'orbite.
   Entre les dates juliennes jjdeb et jjfin avec un pas de pasjj
   Rapporte a l'equinoxe donne.
void mc_ephem2(char *nom_fichier_ele,double jj, double rangetq, double pastq, double equinoxe, char *nom_fichier_out,int *concordance);
   Genere un fichier ASCII d'ephemerides pour un astre defini par ses
   elements d'orbite.
   pour la date julienne jj.
   on fait varier l'instant de passage au perihelie entre -rangetq et
   +rangetq autour de Tq par pas de pastq.
   Rapporte a l'equinoxe donne.
void mc_paradist(char *nom_fichier_obs,char *nom_fichier_ele,char *nom_fichier_out);
   Calcul de la distance Terre Astre a partir d'observations effectuees
   aux memes moments par deux sites.
void mc_paradist_calc(struct observ *obs,int k1, int k2,double *parallaxe,double *corde,double *dist);
   Calcul de la distance d'un astre a partir de deux observations realisees
   en seux sites differents. Methode de la parallaxe.
void mc_simulc(mc_cdr cdr,double *relief,double *albedo,mc_cdrpos *cdrpos,int n,char *genefilename);
   Simulation de la courbe de lumiere d'un asteroide.
void mc_simulc_sat(mc_cdr cdr,double *relief,double *albedo,mc_cdrpos *cdrpos,int n,char *genefilename);
   Simulation de la courbe de lumiere d'un satellite.
void mc_simulcbin(mc_cdr cdr,double *relief1,double *albedo1,double *relief2,double *albedo2,mc_cdrpos *cdrpos,int n,char *genefilename);
   Simulation de la courbe de lumiere d'un asteroide SSB.
char *mc_savefits(float *mat,int naxis1, int naxis2,char *filename,mc_wcs *wcs);
   Save the *mat as a FITS file
MC_NORA.C
void mc_norad_sgdp48(double jj,int sgp, struct elemorb *elem,double *xgeo,double *ygeo,double *zgeo,double *vxgeo,double *vygeo,double *vzgeo);
   models NORAD SGP, SGP4, SDP4, SGP8, SDP8 for satellites
*/

/***************************************************************************/
/* Determination des elements d'orbite                                     */
/***************************************************************************/
/*
MC_ORBI1.C
void mc_cu2xyzeq(double l,double m,double n,double *a,double *ll, double *mm, double *nn);
   Calcul des coordonnees cart. du repere de Cunningham vers equatorial
void mc_elemplus(struct observ *obs,struct elemorb *elem,int nbobs);
   Ajoute quelques renseignements supplementaires aux elements d'orbites
   en particulier les incertitudes estimees
void mc_elemtype(struct elemorb *elem);
   Complete le type d'astre et les codes Bowell dans la structure elem.
void mc_gem3(struct observ *obs,struct elemorb *elem,double jj_equinoxe);
   Methode GEM 3 obervations.
void mc_herget2(struct observ *obs,double *delta,struct elemorb *elem,double jj_equinoxe);
   Methode d'Herget a 2 observations.
void mc_matcunni(double ll1, double mm1, double nn1, double ll3, double mm3, double nn3, double *a);
   Calcul des elements de la matrice de Cunningham.
void mc_mvc2a(struct observ *obs,double delta,struct elemorb *elem,double jj_equinoxe);
   Methode MVC 2 observations. methode de Vaisala (orbite perihelique).
void mc_mvc3a(struct observ *obs,struct elemorb *elem,double jj_equinoxe);
   Methode MVC 3 observations. methode A de Danby.
void mc_mvc3b(struct observ *obs,struct elemorb *elem,double jj_equinoxe);
   Methode MVC 3 observations. methode B de Danby (Marsden).
void mc_xyzeq2cu(double ll,double mm,double nn,double *a,double *l, double *m, double *n);
   Calcul des coordonnees cartesiennes dans le repere de Cunningham.
void mc_secratio(double r1, double r2, double kay, double dt, double kgrav, double *y);
   Calcul du ratio des aires des secteurs de Gauss.
double mc_secratiq(double x);
   Serie hypergeometrique.
MC_ORBI2.C
void mc_gem3b(struct observ *obs,double offc, double offl,struct elemorb *elem,double jj_equinoxe);
   Methode GEM 3 observations. Contraintes de Marsden (offc,offl)
   offc est le Delta-n de courbue defini par Marsden (en arcsec)
   offl est le Delta-m de sinus de longitude par Marsden (en arcsec)
void mc_mvc2b(struct observ *obs,struct elemorb *elem,double jj_equinoxe);
   Methode MVC 2 observations. Orbite circulaire contrainte.
void mc_mvc2c(struct observ *obs,double aa,struct elemorb *elem,double jj_equinoxe);
   Methode MVC 2 observations. Contrainte sur le demi grand axe.
void mc_mvc2d(struct observ *obs,double ee,struct elemorb *elem,double jj_equinoxe);
   Methode MVC 2 observations. Excentricite contrainte.
MC_ORBI3.C
void mc_orbi_auto(char *nom_fichier_obs,char *nom_fichier_ele);
   Traitement automatique des observations d'un fichier qui contient les
   les observations de plusieurs astres.
   Le fichier de sortie contient les elements d'orbite les uns a la suite
   des autres au format MPEC.
void mc_rms_obs(struct elemorb *elem, struct observ *obs, int nbobs);
   calcule les ecarts o-c entre les asd/dec des observations et ceux prevus
   par les elements d'orbite.
   complete la valeur du residu RMS en arcsec pour l'ensemble des obs
   dans elem.residu_rms.
*/

/***************************************************************************/
/* Utilitaires de petits calculs astro (magnitudes, elongation ...)        */
/***************************************************************************/
/*
MC_UTIL1.C
void mc_quicksort_double(double *arr, int low, int high, int *karr);
   Quick sort.
void mc_elonphaslimb(double asd, double dec, double asds, double decs, double r, double delta, double *elong, double *phase, double *posang_brightlimb);
   Calcul des angles d'elongation de phase et de position du limbe.
void mc_elonphas(double r, double rsol, double delta, double *elong, double *phase);
   Calcul des angles d'elongation et de phase.
void mc_magaster(double r, double delta, double phase, double h, double g, double *mag);
   Calcule la magnitude d'un asteroide a partir de H, G et la phase.
void mc_magplanet(double r,double delta,int planete,double phase,double l,double b,double *mag);
   Calcule la magnitude d'une planete
void mc_magcomete(double r, double delta, double h0, double n, double *mag);
   Calcule la magnitude d'une comete a partir de h0 et n.
void mc_sepangle(double a1, double a2, double d1, double d2, double *dist, double *posangle);
   Calcul de l'angle de separation et de l'angle de position au pole nord
   a partir de deux coordonnees spheriques.
void mc_libration(double jj,int planete,double longmpc,double rhocosphip,double rhosinphip,double *lonc, double *latc, double *p,double *lons, double *lats)
   Calcul de la libration apparentes de la Lune a jj donne.
void mc_physephem(double jj,int planete,double xg,double yg,double zg,double x,double y,double z,
                  double *diamapp_equ,double *diamapp_pol,
                  double *long1,double *long2,double *long3,double *lati,double *posangle_north,
                  double *posangle_sun);
   Cacul des parametres do'bservation physique des planetes
int mc_util_cd2cdelt_old(double cd11,double cd12,double cd21,double cd22,double *cdelt1,double *cdelt2,double *crota2);
   Utilitaire qui tranforme les mots wcs de la matrice cd vers les
   vieux mots cle cdelt1, cdelt2 et crota2.
int mc_htm_testin(double *v0, double *v1, double *v2, double *v)
   Retourne 1 si v est l'interieur du triangle v0,v1,v2.
int mc_radec2htm(double ra,double dec,int niter,char *htm)
   Retourne le code Hierarchical Triangle Mesh.
int mc_htm2radec(char *htm,double *ra,double *dec,int *niter,double *ra0,double *dec0,double *ra1,double *dec1,double *ra2,double *dec2)
   Retourne le ra,dec a paertir du code Hierarchical Triangle Mesh.
*/


/***************************************************************************/
/* Utilitaires de petits calculs astro (magnitudes, elongation ...)        */
/***************************************************************************/
/*
MC_UTIL2.C
int mc_fitspline(int n1,int n2,double *x, double *y, double *dy, double s,int nn, double *xx, double *ff);
   Fit by splines with smooth
int mc_interplin1(int n1,int n2,double *x, double *y, double *dy, double s,int nn, double *xx, double *ff);
   Interpolation lineaire
char *mc_d2s(double val)
   Double to String conversion with many digits
int mc_meo_ruban(double az, double montee,double descente,double largmontee,double largdescente,double amplitude,double *daz);
   Fonction du ruban cordeur de MEO
*/

/***************************************************************************/
/* Transformations du temps (jour julien, temps dynamique ...)             */
/***************************************************************************/
/*
MC_TIME1.C
void mc_equinoxe_jd(char *chaine,double *jj);
   Donne le jour julien correspondant a un code d'equinoxe.
void mc_date_jd(int annee, int mois, double jour, double *jj);
   Calcul du jour julien pour une date gregorienne.
void mc_jd_date(double jj, int *annee, int *mois, double *jour);
   Calcul de la date gregorienne a partir du jour julien.
void mc_jd_equinoxe(double jj, char *chaine);
   Donne le code d'equinoxe correspondant a un jour julien.
void mc_jd_equinoxe2(double jj,int year_type,int nb_subdigit, char *chaine);
   Donne le code d'equinoxe correspondant a un jour julien.
void mc_td2tu(double jjtd,double *jjtu);
   Corrige le jour julien temps dynamique en jour julien TU.
void mc_tsl(double jj,double longitude,double *tsl);
   Calcul du temps sideral local (en radian)
   La longitude est comptee en radian positive vers l'ouest
void mc_tu2td(double jjtu,double *jjtd);
   Corrige le jour julien TU en jour julien temps dynamique.
void mc_tdminusut(double jj,double *dt);
   Retourne la valeur dt=TT-UT partir de jj en TU
void mc_jd2dateobs(double jj, char *date);
   Donne la date Fits (DATE-OBS) correspondant a un jour julien
void mc_dateobs2jd(char *date, double *jj);
   Donne le jour juliene correspondant a la date Fits (DATE-OBS)
*/

/***************************************************************************/
/* Corrections de precession, nutation, aberration ...                     */
/***************************************************************************/
/*
MC_CORC1.C
void mc_parallaxe_stellaire(double jj,double asd1,double dec1,double *asd2,double *dec2,double plx_mas);
   Corrige asd1,dec1 de la parallaxe stellaire et retourne asd2 et dec2
void mc_aberration_annuelle(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe);
   Corrige asd1,dec1 de l'aberration annuelle et retourne asd2 et dec2
void mc_aberration_eterms(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe);
   Corrige asd1,dec1 de l'aberration eterms et retourne asd2 et dec2
void mc_aberration_diurne(double jj,double asd1,double dec1, double longuai, double rhocosphip, double rhosinphip,double *asd2,double *dec2,int signe);
   Corrige asd1,dec1 de l'aberration diurne et retourne asd2 et dec2
void mc_aberpla(double jj1, double delta, double *jj2);
   Corrige le jour julien du temps d'aberration planetaire.
void mc_latalt2rhophi(double latitude,double altitude,double *rhosinphip,double *rhocosphip);
   Retourne les valeurs de rhocosphi' et rhosinphi' (en rayons equatorial
   terrestres) a partir de la latitude et de l'altitude.
void mc_nutation(double jj, int precision, double *dpsi, double *deps);
   Calcul des corrections de longitude et d'obliquite dus a la nutation.
void mc_nutradec(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe);
   Corrige asd1,dec1 de la nutation et retourne asd2 et dec2
void mc_obliqmoy(double jj, double *eps);
   Calcul la valeur de l'obliquite moyenne a l'equinoxe de la date jj.
void mc_paraldxyzeq(double jj, double longuai, double rhocosphip, double rhosinphip, double *dxeq, double *dyeq, double *dzeq);
   Calcul des corrections cartesiennes equatoriales de la parallaxe
void mc_precelem(struct elemorb elem1, double jd1, double jd2, struct elemorb *elem2);
   Calcul de precession sur o,i,w des elements d'orbite.
void mc_precxyz(double jd1, double x1, double y1, double z1, double jd2, double *x2, double *y2, double *z2);
   Calcul de precession sur les coordonnees x,y,z equatoriales.
void mc_precad(double jd1, double asd1, double dec1, double jd2, double *asd2, double *dec2);
   Passage des coordonnees spheri. equatoriales d'un equinoxe a un autre
void mc_preclb(double jd1, double lon1, double lat1, double jd2, double *lon2, double *lat2);
   Passage des coord. sph. ecliptiques d'un equinoxe a un autre
void mc_rhophi2latalt(double rhosinphip,double rhocosphip,double *latitude,double *altitude);
   Retourne les valeurs de la latitude et de l'altitude a partir de
   rhocosphi' et rhosinphi' (en rayons equatorial terrestres)
void mc_refraction(double h,int inout,double temperature,double pressure,double *refraction);
   Retourne la valeur de la refraction.
void mc_corearthsatelem(double jj,struct elemorb *elem);
   Correction de perturbations de la figure de la Terre pour satellites
void mc_cor_sgp4_satelem(double jj,struct elemorb *elem);
   Correction de perturbations modele SGP4 pour satellites
void mc_refraction2(double h,int inout,double tk,double ppa, double lnm, double hump, double latd, double altm, double *refraction);
   Retourne la valeur de la refraction .                                   
void mc_refraction_coef_fz(double zdeg,double *fz);
   Retourne la valeur du coef f(z) de la refraction.                       
void mc_refraction_coef_gz(double zdeg,double *gz);
   Retourne la valeur du coef g(z) de la refraction.                       
void mc_refraction_coef_r0(double zdeg, double *r0);
   Retourne la valeur du coef Ro(z) de la refraction.                      
void mc_refraction_coef_a(double zdeg, double t, double *a);
   Retourne la valeur du coef A(z) de la refraction.                       
void mc_refraction_coef_b(double zdeg, double p, double *b);
   Retourne la valeur du coef B(z) de la refraction.                       
void mc_refraction_coef_c(double zdeg, double lnm, double *c);
   Retourne la valeur du coef C(z) de la refraction.                       
void mc_refraction_coef_d(double zdeg, double f, double *dd);
   Retourne la valeur du coef D(z) de la refraction.                       
void mc_refraction_coef_e(double zdeg, double phi, double *e);
   Retourne la valeur du coef E(z) de la refraction.                       
void mc_refraction_coef_h(double zdeg, double altm, double *h);
   Retourne la valeur du coef H(z) de la refraction.                       
void mc_refraction_coef_fsat(double t, double *fsat);
   Retourne la valeur de la pression de vapeur saturante de l'eau          
void mc_refraction_coef_r(double z0, double tk, double ppa, double lnm,double hump,double latd, double altm,double *r);
   Retourne la valeur du coef R de la refraction (arcmin)                  
*/

/***************************************************************************/
/* Utilitaires mathematiques                                               */
/***************************************************************************/
/*
MC_MATH1.C
double mc_deg(double valeur);
   Calcul la valeur decimale a partir de la valeur d.ms
double mc_deg2d_m_s(double valeur);
   Calcul la valeur d.ms a partir de la valeur decimale.
double mc_deg2h_m_s(double valeur);
   Calcul la valeur h.ms a partir de la valeur decimale.
double mc_dms(double valeur);
   Calcul la valeur d.ms a partir de la valeur decimale.
double mc_frac(double x);
   Calcul de la partie fractionnaire d'un nombre decimal.
void mc_fstr(double valeur, int signe, int nbint, int nbfrac,int zeros,char *chaine);
   Formatage d'une chaine de sortie a partir d'une valeur numerique.
void mc_prodscal(double x1, double y1,double z1, double x2,double y2,double z2, double *p);
   Produit vectoriel de deux vecteurs.
void mc_prodvect(double x1, double y1,double z1, double x2,double y2,double z2, double *x3, double *y3, double *z3);
   Produit vectoriel de deux vecteurs.
double mc_sgn(double arg);
   Renvoi le signe de l'argument.
double mc_sgn2(double arg);
   Renvoi le signe du sinus de l'argument.
void mc_strupr(char *chainein, char *chaineout);
   Fonction de mise en majuscules emulant strupr (pb sous unix)
double mc_acos(double x);
   Fonction arccosinus evitant les problemes de depassement
double mc_asin(double x);
   Fonction arcsinus evitant les problemes de depassement
double mc_atan2(double y, double x);
   Calcul de atan2 sans 'domain error'.
double mc_sqrt(double x);
   Fonction sqrt evitant les problemes de negatif
*/

/***************************************************************************/
/* Transformation de systemes de coordonnees                               */
/***************************************************************************/
/*
MC_CORD1.C
void mc_anomoy(struct elemorb elem,double jd,double *m);
   Calcul de l'anomalie moyenne M a partir des elements d'orbite et
   pour une date donnee jd. Valable pour n'importe quelle orbite conique.
void mc_anovrair(struct elemorb elempla,double m,double *v,double *r);
   Calcul de l'anomalie vraie v et du rayon vecteur r a partir de
   l'anomalie moyenne M et des elements d'orbite. Valable pour n'importe
   quel type d'orbite conique.
void mc_aster2elem(struct asterident aster, struct elemorb *elem);
   Copie les valeurs d'elements d'orbite definis a partir de la structure
   asterident vers les elements d'orbites definis a partir de la structure
   elemorb. (utile pour la base de Bowell).
void mc_copyelem(struct elemorb elem1, struct elemorb *elem2);
   Copie les valeurs d'elements d'orbite vers une autre variable.
void mc_elem2aster(struct elemorb elem,struct asterident *aster);
   Copie les valeurs d'elements d'orbite definis a partir de la structure
   elemorb vers les elements d'orbites definis a partir de la structure
   asterident. (utile pour la base de Bowell).
void mc_elempqec(struct elemorb elem, struct pqw *vect);
   Transforme les elements d'orbites kepleriens o,i,w (spheriques) vers les
   elements d'orbites gaussiens P Q W (cartesiens).
void mc_elempqeq(struct pqw vectec, double eps, struct pqw *vecteq);
   Transforme les elements d'orbite gaussiens P Q W definis dans le
   repere ecliptique vers le repere equatorial.
void mc_he2ge(double xh,double yh,double zh,double xs,double ys,double zs,double *xg,double *yg,double *zg);
   Translation de repere cartesien heliocentrique vers le repere cartesien
   geocentrique.
void mc_lbr2xyz(double l, double b, double r, double *x, double *y, double *z);
   Transformation des coordonnees spheriques vers les coordonnees
   cartesiennes.
void mc_rv_xyz(struct pqw vectpqw, double r, double v, double *x, double *y, double *z);
   Calcul des composantes de la position d'un astre defini par v et r dans
   le repere orbital vers le repere cartesien equatorial ou ecliptique
   (depend du choix de P Q W).
void mc_rv_vxyz(struct pqw vectpqw, struct elemorb elem, double r, double v, double *vx, double *vy, double *vz);
   Calcul des composantes de la vitesse d'un astre defini par v et r dans
   le repere orbital vers le repere cartesien equatorial ou ecliptique
   (depend du choix de P Q W).
void mc_xvx2elem(double x, double y, double z, double vx, double vy, double vz, double jj, double jj_equinoxe, double kgrav, struct elemorb *elem);
   Calcule les elements d'orbite a partir des vecteurs position et vitesse
   dans le repere heliocentrique ecliptique.
void mc_xyz2lbr(double x, double y, double z, double *l, double *b, double *r);
   Transformation des coordonnees cartesiennes vers les coordonnees
   spheriques.
void mc_xyz2add(double xg, double yg, double zg, double *asd, double *dec, double *delta);
   Transformation des coordonnees cartesiennes vers les coordonnees
   spheriques (equatoriales en general). Doublon avec la fonction
   mc_xyz2lbr.
void mc_xyzec2eq(double xec, double yec, double zec, double eps, double *xeq, double *yeq, double *zeq);
   Rotation du repere cartesien ecliptique vers le repere cartesien
   equatorial.
void mc_xyzeq2ec(double xeq, double yeq, double zeq, double eps, double *xec, double *yec, double *zec);
   Rotation du repere cartesien equatorial vers le repere cartesien
   ecliptique.
void mc_ad2hd(double jd, double longuai, double asd, double *ha);
   Transforme l'ascension droite en angle horaire
void mc_hd2ad(double jd, double longuai, double ha, double *asd);
   Transforme l'angle horaire en ascension droite
void mc_hd2parallactic(double ha, double dec, double latitude, double *parallactic);
   Transforme les coord. sph. equatoriales vers angle parallactic
void mc_hd2parallactic_altalt(double ha, double dec, double latitude, double *parallactic);
   Transforme les coord. sph. equatoriales vers angle parallactic altalt
void mc_hd2ah(double ha, double dec, double latitude, double *az, double *h);
   Transforme les coord. sph. equatoriales vers sph. azinuth hauteur
void mc_ah2hd(double az, double h, double latitude, double *ha, double *dec);
   Transforme les coord. sph. azinuth hauteur vers sph. equatoriales
void mc_hd2rp(double ha, double dec, double latitude, double *az, double *h);
   Transforme les coord. sph. equatoriales vers sph. roulis assiette
void mc_rp2hd(double az, double h, double latitude, double *ha, double *dec);
   Transforme les coord. sph. roulis assiette vers sph. equatoriales
void mc_ad2ah(double jd, double longuai, double latitude, double asd, double dec, double *az,double *h);
   Transforme les coord. sph. equatoriales vers sph. azinuth hauteur
void mc_radec2galactic(double ra2000, double dec2000, double *lon,double *lat);
   Transforme les coord. sph. equatoriales J2000.0 vers sph. galactiques
void mc_galactic2radec(double lon,double lat, double *ra2000, double *dec2000);
   Transforme les coord. sph. galactiques vers sph. equatoriales J2000.0
void mc_map_xy2lonlat(double lc, double bc, double p, double f, double xc, double yc, double rc, double ls, double bs, double power,double i,double j,double *lon,double *lat,double *visibility);
   Conversion of a pixel (i,j) towards planetographics coordinates.
void mc_map_lonlat2xy(double lc, double bc, double p, double f, double xc, double yc, double rc, double ls, double bs, double power,double lon,double lat,double *i,double *j,double *visibility);
   Conversion planetographics coordinates towards a pixel (i,j).
*/

/***************************************************************************/
/* Utilitaires de gestion de catalogues (Usno, MicroCat, ...)              */
/***************************************************************************/
/*
MC_CART1.C
int mc_ima_series_catchart_2(mc_ASTROM p,int *nbobj, int nbobjmax, objetype *objs,char *outfilename);
void mc_ComputeUsnoIndexs(double ra,double de,int *indexSPD,int *indexRA);
double mc_R2D(double a);
double mc_D2R(double a);
int mc_Big2LittleEndianLong(int l);
double mc_GetUsnoBleueMagnitude(int magL);
double mc_GetUsnoRedMagnitude(int magL);
int mc_util_astrom_radec2xy(TT_ASTROM *p,double ra,double dec, double *x,double *y);
int mc_util_astrom_xy2radec(mc_ASTROM *p, double x,double y,double *ra,double *dec);

MC_CATA1.C
int mc_readhip(char *hip_main_file, char *bits, double *values, int *nstars, mc_cata_astrom *hips);
*/

/***************************************************************************/
/* Utilitaires de gestion de fichiers (base de Bowell, tri ...)            */
/***************************************************************************/
/*
MC_FILE1.C
void mc_mpc_dec1(char *ligne, struct asterident *aster);
   Decode les arguments d'une ligne extraite du fichier de la base de
   MPC et stocke les parametres dans la structure asterindent.
void mc_bow_dec1(char *ligne, struct asterident *aster);
   Decode les arguments d'une ligne extraite du fichier de la base de
   Bowell et stocke les parametres dans la structure asterindent.
void mc_bow_dec2(char *num_aster, char *nom_fichier_in,struct elemorb *elem,struct asterident *aster,int *concordance);
   Decode le *num_aster d'un asteroide de la base de Bowell
   On rentre, soit le numero (ex : 1 pour Ceres) ou bien le numero
   provisoire toutes lettres collees (ex : 1997DQ).
   Met a jour la structure elem pour l'asteroide trouve.
void mc_bow_dec3(char *num_aster, char *nom_fichier_in,int *concordance,char *nom_fichier_ele);
   Decode le *num_aster d'un asteroide de la base de Bowell
   On rentre, soit le numero (ex : 1 pour Ceres) ou bien le numero
   provisoire toutes lettres collees (ex : 1997DQ).
   Met a jour le fichier elem pour l'asteroide trouve.
void mc_lec_obs_mpc(char *nom_fichier_in, struct observ *obs, int *nbobs);
   Converti les donnees d'observation format MPC vers format interne.
void mc_lec_station_mpc(char *nom_fichier_station, char *station, double *longmpc, double *rhocosphip, double *rhosinphip);
   Fourni les coordonnees MPC s'un site a partir du fichier de station
void mc_readelem(char *nom_fichier_in,struct elemorb *elem);
   Lit les elements d'orbites sur le disque.
void mc_select_observ(struct observ *obsin, int nbobsin,char *designation,struct observ *obsout,int *nbobsout);
   Isole une serie d'observations qui ont la meme designation et trie ces
   observations dans l'ordre chronologique croissant
void mc_select32_observ(struct observ *obsin, int nbobsin,struct observ *obsout,int *nbobsout,int contrainte);
   Isole une serie de deux ou trois observations prealablement triee en
   ordre chronologique par mc_select_observ.
void mc_tle_decnext1(FILE *ftle,struct elemorb *elem,char *name,int *valid);
   Genere un fichier de reference pour effectuer un tri croissant.
void mc_tri1(char *nom_in, char *nom_out);
   Genere un fichier de reference pour effectuer un tri croissant.
   Le fichier in comporte deux colonnes : 1/ un indice incremental entier
   2/ une valeur numerique (decimale) servant de critere de tri.
void mc_tri2(char *nom_in, char *nom_out,char *nom_ref);
   Trie les lignes du fichier in pour generer le fichier out a partir
   de l'ordre des indices lus sequentiellement dans le fichier ref
   (genere par mc_tri1).
int mc_util_comptelignes(char *nom,int *nblignes);
   Compte le nombre de ligne non vides ni blanches d'un fichier.
void mc_writeelem(struct elemorb *elem,char *nom_fichier_out);
   Ecrit les elements d'orbites sur le disque.
MC_FILE2.C
void mc_bowspace(char *nom_fichier_in,char *nom_fichier_out,int *concordance);
   Ecrit un fichier de l base de Bowell en remplacant tous les parametres
   inutiles par des espaces. On peut ainsi compacter ulterieument la base.
void mc_convformat(int flag,char *nom_fichier_ele1,char *nom_fichier_ele2, int *concordance);
   Conversion de format d'elements d'orbite.
void mc_fprfbow1(int flag, double equinoxe, FILE *fichier_out,int *nblighead);
   Entete de sorties d'ephemerides de la base de Bowell
   flag=1 appel par mc_bowell1
   flag=3 appel par mc_bowell3
void mc_fprfbow11(char *name,double asd,double dec,double mag,double delta,strcut asterident aster,double incert,double dist,double posangle,FILE *fichier_out);
   Sorties d'ephemerides d'apres l'entete definie par mc_fprfbow1
   Serie de positions pour d'astres divers pour une date donnee
void mc_fprfeph1(int flag, double equinoxe, struct elemorb elem, FILE *fichier_out,int *nblighead);
   Entete de sorties d'ephemerides a partie des elements orbitaux
   flag=1 appel par mc_ephem1
void mc_fprfeph21(int flag,struct elemorb elem,double jj,double asd,double dec,double mag,double delta,double r,double elong,double dist,double posangle,double incert,FILE *fichier_out);
   Sorties d'ephemerides d'apres l'entete definie par mc_fprfbow2
   Serie de positions a differentes dates pour un astre donne
void mc_fprfeph2(int flag, double equinoxe, double jj, struct elemorb elem, FILE *fichier_out,int *nblighead);
   Entete de sorties d'ephemerides a partir des elements orbitaux
   flag=1 appel par mc_ephem2
void mc_fprfeph22(int flag,struct elemorb elem,double jj,double asd,double dec,double mag,double delta,double r,double elong,double dist,double posangle,double incert,FILE *fichier_out);
   Sorties d'ephemerides d'apres l'entete definie par mc_fprfeph2
   Serie de positions a differentes dates pour un astre donne
void mc_lec_ele_mpec1(char *nom_fichier_in, struct elemorb *elem,int *concordance,int *ligfin);
   Converti les donnees d'element d'orbite format MPEC vers format interne.
void mc_lec_ele_mpec2(char *texte, int *annee, int *mois, double *jour);
   Convertit une date [[a] mmm(.)] jj.jjjj en annee,mois,jour.
void mc_mpec_check(struct elemorb *elem,struct elemorb *elemok,int *check);
   Verifie la coherence des elements d'orbites deja lus et retourne un
   *check=OK pour arreter la lecture des elements dans le fichier.
void mc_mpec_datesjjjj(char *ligne, char *motcle,char *argument1,char *argument2);
   Recherche la chaine "motcle" dans la chaine "ligne" et retourne dans
   "argument1" la premiere date trouvee immediatement apres "motcle" et
   "argument2" la deuxieme date trouvee immediatement apres la premiere.
void mc_mpec_datejj(char *ligne, char *motcle,char *argument);
   Recherche la chaine "motcle" dans la chaine "ligne" et retourne dans
  "argument" la premiere date trouvee immediatement apres "motcle".
void mc_mpec_argnum(char *ligne, char *motcle,char *argument);
   Recherche la chaine "motcle" dans la chaine "ligne" et retourne dans
   "argument" le premier nombre trouve immediatement apres "motcle".
void mc_mpec_argbowell(char *ligne, char *motcle,char *argument);
   Recherche la chaine "motcle" dans la chaine "ligne" et retourne dans
   "argument" les 6 nombres trouve immediatement apres "motcle".
void mc_mpec_t2amj(char *texte, int *annee, int *mois, double *jour);
   Convertit une date d'une variable texte en trois composantes A/M/J
void mc_mpec_jjjjdates(double jj1, double jj2, char *texte);
   Convertit un JJ en une variable texte en trois composantes A/M/J MPEC
void mc_mpec_mois(int mois,char *texte);
   Convertit un mois en une variable texte MPEC
void mc_typedastre(struct elemorb elem,char *astre);
   Retourne la nature d'un astre dans une chaine d'apres la structure elem.
void mc_wri_ele_mpec1(char *nom_fichier_out, struct elemorb elem,int type_fichier);
   Converti les donnees d'element d'orbite format interne vers format MPEC.
MC_FILE3.C
void mc_lec_mpc_noms(char *nom_fichier_obs,char *nom_fichier_noms);
   Retourne un fichier texte contenant les noms et le nombre d'observations
   pour chaque nom.
*/

/***************************************************************************/
/* Calculs d'ephemerides precises des planetes, du Soleil ...              */
/***************************************************************************/
/*
MC_PLNT1.C
void mc_jd2elem1(double jj, int planete, struct elemorb *elempla);
   Calcul des elements d'orbites moyens d'une planete a la date jj
   pour l'equinoxe moyen de la date.
void mc_jd2lbr1a(double jj, double *l, double *m, double *u);
   Calcul des parametres angulaires utiles pour les fonctions
   mc_jd2lbr1*.
MC_PLNT2.C
void mc_jd2lbr1b(double jj, int planete, double *l, double *m, double *u, double *ll, double *bb, double *rr);
   Calcul des longitude (l) latitude (b) et rayon vecteur (r) d'une planete
   en tenant compte des perturbations planetaires importantes pour atteindre
   un precision de +/- environ 4 arcsec sur les angles et +/- 0.0001 ua
   sur le rayon vecteur.
void mc_jd2lbr_vsop87_mer(double jj, double *ll, double *bb, double *rr);
   VSOP87 for mer
void mc_jd2lbr_vsop87_ven(double jj, double *ll, double *bb, double *rr);
   VSOP87 for ven
void mc_jd2lbr_vsop87_ear(double jj, double *ll, double *bb, double *rr);
   VSOP87 for ear
void mc_jd2lbr_vsop87_mar(double jj, double *ll, double *bb, double *rr);
   VSOP87 for mar
void mc_jd2lbr_vsop87_jup(double jj, double *ll, double *bb, double *rr);
   VSOP87 for jup
void mc_jd2lbr_vsop87_sat(double jj, double *ll, double *bb, double *rr);
   VSOP87 for sat
void mc_jd2lbr_vsop87_ura(double jj, double *ll, double *bb, double *rr);
   VSOP87 for ura
void mc_jd2lbr_vsop87_nep(double jj, double *ll, double *bb, double *rr);
   VSOP87 for nep
void mc_jd2lbr_vsop87_compute(double jj,
   double *l0,double *l1,double *l2,double *l3,double *l4,double *l5, int lmax, int *lalpha,
   double *b0,double *b1,double *b2,double *b3,double *b4,double *b5, int bmax, int *balpha,
   double *r0,double *r1,double *r2,double *r3,double *r4,double *r5, int rmax, int *ralpha,
   double *ll, double *bb, double *rr);
   Retourne les valeurs de longitude *ll, latitude *bb, rayon vecteur *rr
   pour l'equinoxe moyen de la date. (longitudes vraies)
   VSOP87
MC_PLNT3.C
void mc_jd2lbr1c(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0);
   Fonction de calcul planetaire appelee en interne par mc_jd2lbr1b.
   JUPITER
void mc_jd2lbr1d(double jj, double *ll0, double *bb0, double *rr0);
   Retourne les valeurs de longitude *ll, latitude *bb, rayon vecteur *rr
   pour l'equinoxe moyen de la date. (longitudes vraies)
   LUNE
void mc_jd2lbr2d(double jj, double *ll0, double *bb0, double *rr0);
   Retourne les valeurs de longitude *ll, latitude *bb, rayon vecteur *rr
   pour l'equinoxe moyen de la date. (longitudes vraies)
   LUNE => Theorie ELP2000 82B
MC_PLNT4.C
void mc_jd2lbr1e(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0);
   Fonction de calcul planetaire appelee en interne par mc_jd2lbr1b.
   SATURNE
void mc_jd2lbr1f(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0);
   Fonction de calcul planetaire appelee en interne par mc_jd2lbr1b.
   URANUS
void mc_jd2lbr1g(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0);
   Fonction de calcul planetaire appelee en interne par mc_jd2lbr1b.
   NEPTUNE
void mc_jd2lbr1h(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0);
   Fonction de calcul planetaire appelee en interne par mc_jd2lbr1b.
   PLUTON
*/

/***************************************************************************/
/* Modele de pointage                                                      */
/***************************************************************************/
/*
double mc_modpoi_addobs_az(double az,double h,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx);
   Fill a line of the matrix of the pointing model
double mc_modpoi_addobs_h(double az,double h,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx);
   Fill a line of the matrix of the pointing model
double mc_modpoi_addobs_ha(double ha,double dec,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx);
   Fill a line of the matrix of the pointing model
double mc_modpoi_addobs_dec(double ha,double dec,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx);
   Fill a line of the matrix of the pointing model
*/
