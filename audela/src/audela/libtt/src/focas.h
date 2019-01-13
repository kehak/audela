/* focas.h
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

#define FOCAS_SORT 45
#define FOCAS_NOBJMAX 100 /* limite … 59 … cause du type short !!*/
#define FOCAS_NOBJINI 50
#define FOCAS_EPSIINI 0.002
#define PB 1
#define OK 0
#define FR 1
#define GB 2

#define LG FR

struct focas_tableau_entree {
   double x;
   double y;
   double mag;
   double ad;
   double dec;
   double mag_gsc;
   double qualite;
   int  type;      /* -1 si saturation sinon 1*/
} ;

struct focas_tableau_triang {
   int indice1;
   int indice2;
   int indice3;
   double x;
   double y;
} ;

struct focas_tableau_dist {
   int indice1;
   int indice2;
   double dist2;
} ;

struct focas_tableau_vote {
   int indice1;
   int indice2;
   int poids;
} ;

struct focas_tableau_corresp {
   int indice1;
   double x1;
   double y1;
   double mag1;
   int indice2;
   double x2;
   double y2;
   double mag2;
   double poids;
   double ad;
   double dec;
   double mag_gsc;
   int    type1;
   int    type2;
} ;

int focas_main(char *nom_fichier1,int type_fichier1,
		 char *nom_fichier2,int type_fichier2,
		 int flag_focas,
		 int flag_sature1,
		 int flag_sature2,
		 char *nom_fichier_com,char *nom_fichier_dif,
		 int *nbcom,
		 double *transf_1vers2,double *transf_2vers1,
		 int *nbcom2,
		 double *transf2_1vers2,double *transf2_2vers1,
               double epsilon, double delta, double seuil_poids);
int focas_match(struct focas_tableau_entree *data_tab1,int nb1,struct focas_tableau_entree *data_tab2,int nb2,double epsilon,double seuil_poids,struct focas_tableau_corresp *corresp,int *nbcorresp,
		  int *poids_max,int *indice_cut1,int *indice_cut2);
int focas_register(struct focas_tableau_corresp *corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1);
int focas_register_2nd(struct focas_tableau_corresp *corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1);
int focas_best_corresp(int nb1,struct focas_tableau_entree *data_tab1,int nb2,struct focas_tableau_entree *data_tab2,double seuil_poids,struct focas_tableau_vote *vote,int *nbc,struct focas_tableau_corresp *corresp,
			int *poids_max,int *indice_cut1,int *indice_cut2);
int focas_calcul_triang(int nbb, int *nbbb, struct focas_tableau_dist *dist, struct focas_tableau_triang *triang);
int focas_transmoy(struct focas_tableau_corresp *corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1);
int focas_compte_lignes (char *nom_fichier_in,int *nombre);
int focas_stringcmp(char *chaine1,char *chaine2);
int focas_fileeof(FILE *fichier_in);
int focas_get_tab(char *nom_fichier_in,int type_fichier,int *nombre,struct focas_tableau_entree *data_tab,int flag_sature1);
int focas_calcul_dist(int nb, struct focas_tableau_entree *data_tab, struct focas_tableau_dist *dist);
int focas_match_triang(struct focas_tableau_triang *triang1, int nb111, struct focas_tableau_triang *triang2, int nb222, int nb1, int nb2, struct focas_tableau_vote *vote,double epsilon);
int focas_mat_vdtv(double *a,double *d,double *v,int n);
int focas_mat_givens(double *a,double *d,double *v,int n);
int focas_mat_mult(double *a,double *b,double *c,int n,int m,int p);
int focas_tri_tabx(struct focas_tableau_entree *data_tab,int nbtot);
int focas_tri_taby(struct focas_tableau_entree *data_tab,int nbtot);
int focas_tri_tabm(struct focas_tableau_entree *data_tab,int nbtot);
int focas_liste2(char *nom_fichier_in,int nbtot,FILE *hand_dif,int indice,int nb_coef_a,double *transform,int xmin,int xmax,int ymin,int ymax);
int focas_liste_commune(char *nom_fichier_com,char *nom_fichier_dif,struct focas_tableau_entree *data_tab10,int nb1tot,struct focas_tableau_entree *data_tab20,int nb2tot,double *transf12,double *transf21,int nb_coef_a,int ordre_corresp,double delta,
			    int *total,struct focas_tableau_corresp *corresp,struct focas_tableau_corresp *differe,int flag_corresp);
int focas_tri_corresp(struct focas_tableau_corresp *corresp,int nbtot);
int focas_detec_dist(struct focas_tableau_corresp *data1,int nbdif1,struct focas_tableau_corresp *data2,int nbdif2,struct focas_tableau_dist *dist12,int nbdist12);
int focas_transcom(char *nom_fichier,double *transf21);
int focas_get_tab3(char *nom_fichier_in,int *nblignes,struct focas_tableau_dist *data);
int focas_get_tab2(char *nom_fichier_in,int *nblignes,struct focas_tableau_corresp *data);
int focas_getput_tab(char *nom_fichier_ref,char *nom_fichier_in,char *nom_fichier_out);

/* --- nouveaux fichiers pour ameliorer Focas ---*/
int focas_best_corresp2(int nb1,struct focas_tableau_entree *data_tab1,int nb2,struct focas_tableau_entree *data_tab2,double seuil_poids,struct focas_tableau_vote *vote,int *nbc,struct focas_tableau_corresp *corresp,
		       int *poids_max,int *indice_cut1,int *indice_cut2);

