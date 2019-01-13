
#include <exception>
#include <vector>
#include <valarray>
#include <math.h>
#include <string.h> //memset
#include "focas.h"


#define PB 1
#define OK 0
#define OK_DLL 0
#define PB_DLL -1
#define TT_NO 1
#define TT_YES 0

#define FOCAS_SORT 45
#define FOCAS_NOBJMAX 100 /* limite … 59 … cause du type short !!*/
#define FOCAS_NOBJINI 50
#define FOCAS_EPSIINI 0.002

#define TT_QSORT 10000

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

int focas_match(struct focas_tableau_entree *data_tab1,int nb1,
   struct focas_tableau_entree *data_tab2,int nb2,
   double epsilon,double seuil_poids,
   ::std::valarray<focas_tableau_corresp> &corresp, int *nbcorresp,
   int *poids_max,int *indice_cut1,int *indice_cut2);

int focas_register(::std::valarray<focas_tableau_corresp> &corresp,
                   int nbcorresp,
                   double *transf_1vers2,double *transf_2vers1);

int focas_mat_givens(double *a,double *d,double *v,int n);
int focas_mat_mult(double *a,double *b,double *c,int n,int m,int p);
int focas_mat_vdtv(double *a,double *d,double *v,int n);

int focas_calcul_dist(int nb, struct focas_tableau_entree *data_tab, struct focas_tableau_dist *dist);
int focas_calcul_triang(int nbb, int *nbbb, struct focas_tableau_dist *dist, struct focas_tableau_triang *triang);
int focas_match_triang(struct focas_tableau_triang *triang1, int nb111, struct focas_tableau_triang *triang2, int nb222, int nb1, int nb2, struct focas_tableau_vote *vote,double epsilon);
int focas_best_corresp2(int nb1,struct focas_tableau_entree *data_tab1,
                        int nb2,struct focas_tableau_entree *data_tab2,
                        double seuil_poids,struct focas_tableau_vote *vote,
                        int *nbc, ::std::valarray<focas_tableau_corresp> &corresp,
                        int *poids_max,int *indice_cut1,int *indice_cut2);

int focas_liste_commune(
   ::std::vector<focas_tableau_entree> &data_tab10,int nb1tot,
   ::std::vector<focas_tableau_entree> &data_tab20,int nb2tot,
   double *transf12,double *transf21,int nb_coef_a,
   int ordre_corresp,
   double delta,
   int *total,
   ::std::valarray<focas_tableau_corresp> &corresp,
   ::std::valarray<focas_tableau_corresp> &differe,
   int flag_corresp);
int focas_tri_tabx(struct focas_tableau_entree *data_tab,int nbtot);
int focas_tri_corresp(::std::valarray<focas_tableau_corresp> &corresp,int nbtot);

int tt_util_qsort_double(double *x,int kdeb,int n,int *index);
int tt_util_qsort_verif(int index);

double * allocDouble(int size);


int focas_main(::std::vector<focas_tableau_entree> &data_tab10,
               ::std::vector<focas_tableau_entree> &data_tab20,
               int flag_focas,
               int flag_sature1,
               int flag_sature2,
               ::std::valarray<focas_tableau_corresp> &corresp, 
               ::std::valarray<focas_tableau_corresp> &differe,
               int *nbcom,
               double *transf_1vers2,double *transf_2vers1,
               int *nbcom2,
               double *transf2_1vers2,double *transf2_2vers1,
               double epsilon, double delta, double seuil_poids)
   /*************************************************************************/
   /* FOCAS_MAIN                                                            */
   /* But : appariement de deux listes d'etoiles sorties de KAOPHOT         */
   /* D'apres : Faint-Object Classification and Analysis System             */
   /*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
   /*                                                                       */
   /* 1) Charge les deux listes en memoire. La liste cible est NOM_FICHIER1 */
   /*    et la liste de reference est NOM_FICHIER2.                         */
   /* 2) Trie chaque liste selon les magnitudes croissantes.                */
   /* 3) Extrait un lot des NOBJ premieres etoiles de chaque liste.         */
   /* 4) Appel a FOCAS_MATCH. Cree une liste de correspondances.            */
   /* 5) Si le nombre de meilleures correspondances est superieur ou        */
   /*    egal a 4 alors on a trouve le bon l'appariement. Sinon, on         */
   /*    revient au point 3) en prenant les NOBJ etoiles suivantes.         */
   /* 6) On calcule la matrice de transformation des coordonnees des        */
   /*    etoiles de la liste 1 dans le repere des coordonnees de la liste   */
   /*    2. (appel a FOCAS_REGISTER).                                       */
   /* 7) On effectue l'appariement des deux listes completes d'etoiles.     */
   /*    L'appariement est bon lorsque la distance entre les deux etoiles   */
   /*    est inferieure a "delta" pixel.                                    */
   /* 8) On sauvegarde la liste commune des etoiles appariees dans le       */
   /*    fichier NOM_FICHIER0.                                              */
   /*                                                                       */
   /* Parametres d'entree :                                                 */
   /*   NOM_FICHIER1  : fichier d'etoiles (champ de reference).             */
   /*   TYPE_FICHIER1 : flag indiquant le type de NOM_FICHIER1              */
   /*                   =0 pour un ordre des colonnes type KAOPHOT 1        */
   /*                      indice X Y fwhmx fwhmy I mag fond qualite        */
   /*                   =1 pour un ordre des colonnes type NOM_FICHIER_COM: */
   /*                      X1 Y1 mag1 X2 Y2 mag2 mag1-2 qualite1 qualite2   */
   /*                      (lit l'indice 1)                                 */
   /*                   =2 pour un ordre des colonnes type NOM_FICHIER_COM: */
   /*                      X1 Y1 mag1 X2 Y2 mag2 mag1-2 qualite1 qualite2   */
   /*                      (lit l'indice 2)                                 */
   /*                   =3 pour un ordre des colonnes type KAOPHOT 2        */
   /*                      indice X Y mag_relative AD DEC mag qualite fwhm  */
   /*                      sharp                                            */
   /*   NOM_FICHIER2  : fichier d'etoiles (champ a apparier).               */
   /*   TYPE_FICHIER2 : flag indiquant le type de NOM_FICHIER2              */
   /*   FLAG_FOCAS    : flag interne permettant de choisir des options :    */
   /*    =0 : pour effectuer un appariement simple (FOCAS)                  */
   /*    =1 : pour contraindre des translations (AUTOTRANS)                 */
   /*    =2 : effectue l'appariement avec les coefs de *transf_1vers2 et    */
   /*         *transf_2vers1 sans passer par FOCAS.                         */
   /*   FLAG_SATURE1  : flag interne permettant de choisir des options :    */
   /*    =0 : pour exclure les etoiles qui saturent dans le matching        */
   /*    =1 : pour inclure les etoiles qui saturent dans le matching        */
   /*   FLAG_SATURE2  : flag interne permettant de choisir des options :    */
   /*    =0 : pour inclure les etoiles qui saturent dans les fichiers       */
   /*         de sortie.                                                    */
   /*    =1 : pour exclure les etoiles qui saturent dans les fichiers       */
   /*         de sortie.                                                    */
   /*                                                                       */
   /* Parametres de sortie :                                                */
   /* *NOM_FICHIER_COM : nom de fichier qui contiendra la liste des etoiles */
   /*                    communes aux deux tableaux d'entree.               */
   /*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
   /*                    L'odre des colonnes est :                          */
   /*                     x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2                 */
   /*                     mag1-2 qualite1 qualite2                          */
   /*                     (qualite=-1 si sature sinon =1)                   */
   /* *NOM_FICHIER_DIF : nom de fichier qui contiendra la liste des etoiles */
   /*                    differentes aux deux tableaux d'entree.            */
   /*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
   /*                    L'odre des colonnes est :                          */
   /*                     x2/1 y2/1 mag2/2 x2/2 y2/2 mag2/2                 */
   /*                     mag1-2 qualite1 qualite2                          */
   /*                     (qualite=-1 si sature sinon =1)                   */
   /*                     (x1,y1) coordonnees (x2,y2) dans le repere 1      */
   /*   *NBCOM         : nombre d'etoiles communes aux deux fichiers        */
   /*   *TRANSF_1VERS2 : coefficients de transfert liste 1 vers la liste 2  */
   /*     ce tableau comporte 12 elements dont 6 sont references ainsi :    */
   /*     x1/2 = [1*3+1] * x1/1 + [1*3+2] * y1/1 + [1*3+3]                  */
   /*     y1/2 = [2*3+1] * x1/1 + [2*3+2] * y1/1 + [2*3+3]                  */
   /*   *TRANSF_2VERS1 : coefficients de transfert liste 2 vers la liste 1  */
   /*     ce tableau comporte 12 elements dont 6 sont references ainsi :    */
   /*     x2/1 = [1*3+1] * x2/2 + [1*3+2] * y2/2 + [1*3+3]                  */
   /*     y2/1 = [2*3+1] * x2/2 + [2*3+2] * y2/2 + [2*3+3]                  */
   /*   *NBCOM2        : nombre d'etoiles communes aux deux fichiers (2nd ordre ) */
   /*   =NULL si l'on ne veut pas calculer les coefs du 2nd ordre.          */
   /*   !=2 en entree si l'on veut calculer les coefs du 2nd ordre et que   */
   /*     les correspondances soient calculees avec l'ordre 1.              */
   /*   2 en entree si l'on veut calculer les coefs du 2nd ordre et que les */
   /*     correspondances soient calculees avec l'ordre 2.                  */
   /*   *TRANSF2_1VERS2 : coefficients de transfert liste 1 vers la liste 2 */
   /*     ce tableau comporte 33 elements dont 20 sont references ainsi :   */
   /*     x1/2 = [1*3+1] * x1/1 + [1*3+2] * y1/1 + [1*3+3] + [1*3+4] * x1/1 * y1/1 + [1*3+5] * x1/1 * x1/1 + [1*3+6] * y1/1 * y1/1  */
   /*     y1/2 = [2*3+1] * x1/1 + [2*3+2] * y1/1 + [2*3+3] + [2*3+4] * x1/1 * y1/1 + [2*3+5] * x1/1 * x1/1 + [2*3+6] * y1/1 * y1/1  */
   /*   =NULL si l'on ne veut pas calculer les coefs du 2nd ordre.          */
   /*   *TRANSF2_2VERS1 : coefficients de transfert liste 2 vers la liste 1  */
   /*     ce tableau comporte 33 elements dont 20 sont references ainsi :    */
   /*     x2/1 = [1*3+1] * x2/2 + [1*3+2] * y2/2 + [1*3+3] + [1*3+4] * x2/2 * y2/2 + [1*3+5] * x2/2 * x2/2 + [1*3+6] * y2/2 * y2/2  */
   /*     y2/1 = [2*3+1] * x2/2 + [2*3+2] * y2/2 + [2*3+3] + [2*3+4] * x2/2 * y2/2 + [2*3+5] * x2/2 * x2/2 + [2*3+6] * y2/2 * y2/2  */
   /*   =NULL si l'on ne veut pas calculer les coefs du 2nd ordre.          */
   /*                                                                       */
   /*************************************************************************/
{
   int n1,nb1deb,nb1fin,n2,nb2deb,nb2fin,sortie0=0;
   int nb1,nb1tot;
   struct focas_tableau_entree *data_tab1=NULL;
   int nb2,nb2tot;
   struct focas_tableau_entree *data_tab2=NULL;
   //struct focas_tableau_entree *data_tab10=NULL;
   //struct focas_tableau_entree *data_tab20=NULL;
   //struct focas_tableau_corresp *corresp=NULL;
   //struct focas_tableau_corresp *differe=NULL;
   int nb,nbc=0,indice_cut1=0,indice_cut2=0,nobj;
   /*
   double epsilon,delta=1.0;
   */
   int poids_max;
   int nb_coef_a=3,total=0,nbcmax,flag_corresp,flag_tri,nbmax;
   int ordre_corresp=1/*,nbc2=0*/;

   
   *nbcom=0;

   /*============================================================*/
   /*= lit les donnees completes des deux tables ASCII           */
   /*============================================================*/
   nb1tot = data_tab10.size();
   data_tab10.insert(data_tab10.begin() ,data_tab10[0]);
   nb2tot = data_tab20.size();
   data_tab20.insert(data_tab20.begin() ,data_tab20[0]);
   
   /* ============================================== */
   /* === effectue l'appariement des deux listes === */
   /* ============================================== */
   if (nbcom2!=NULL) { 
      if (*nbcom2==2) { 
         ordre_corresp=2;
      } 
   }
   nbmax=(nb2tot>nb1tot)?nb2tot:nb1tot;
   if ((flag_focas==0)||(flag_focas==1)) {
      if ((nb1tot==0)||(nb2tot==0)) {
         /* - cas : il n'y a pas d'etoiles dans les listes -*/
         nbc=0;
         sortie0=1;
         nb1=nb2=1;
         /* - allocation de corresp -*/
         //corresp = new focas_tableau_corresp[(nb1+1)*nb2+1]; 
         corresp.resize((nb1+1)*nb2+1);
      } else {
         sortie0=0;
      }
      /*============================================================*/
      /*= identifie l'accord entre des parties des deux listes      */
      /*============================================================*/
      nobj=FOCAS_NOBJINI;
      if (epsilon==0.) {
         epsilon=FOCAS_EPSIINI;
      }
      if (seuil_poids==0.) {
         seuil_poids=1./3.;
      }
      if (delta==0.) {
         delta=1.0;
      }
      /*nb_essais=1; ?*/
      while (sortie0==0) {
         nb1deb=1;
         nb2deb=1;
         nb1=nb1fin= (nb1tot>nobj) ? nobj : nb1tot ;
         nb2=nb2fin= (nb2tot>nobj) ? nobj : nb2tot ;

         /*--- dimensionne les tableaux de pointeurs ---*/
         data_tab1 = new focas_tableau_entree[nb1fin+2];
         memset(data_tab1, 0, (nb1fin+2)*sizeof(focas_tableau_entree));
         
         data_tab2 = new focas_tableau_entree[nb2fin+2];
         memset(data_tab2, 0, (nb2fin+2)*sizeof(focas_tableau_entree));


         //corresp = new focas_tableau_corresp[nbmax+1];
         //memset(corresp, nbmax+1, sizeof(focas_tableau_corresp));
         corresp.resize(nbmax+1);
         n1=nb1deb;

         /* --- extrait le lot LISTE 1 d'etoiles de #1.lst ---*/
         do {
            data_tab1[n1-nb1deb+1].x      =data_tab10[n1].x;
            data_tab1[n1-nb1deb+1].y      =data_tab10[n1].y;
            data_tab1[n1-nb1deb+1].mag    =data_tab10[n1].mag;
            data_tab1[n1-nb1deb+1].qualite=data_tab10[n1].qualite;
            data_tab1[n1-nb1deb+1].ad     =data_tab10[n1].ad;
            data_tab1[n1-nb1deb+1].dec    =data_tab10[n1].dec;
            data_tab1[n1-nb1deb+1].mag_gsc=data_tab10[n1].mag_gsc;
            data_tab1[n1-nb1deb+1].type   =data_tab10[n1].type;
            /*
            // Ecrire une procedure qui recherche XXmin1,xxmax1,yymin1,yymax1
            // en scannant *data_tab10
            // if ((data_tab10[n1].x>=xxmin1)&&(data_tab10[n1].x<=xxmax1)&&
            //     (data_tab10[n1].y>=yymin1)&&(data_tab10[n1].y<=yymax1) ) {
            */
            n1++;
            /*// }*/
         } while (n1<=nb1fin) ; /* revoir cette condition de sortie ##*/
         n2=nb2deb;

         /* --- extrait le lot LISTE 2 d'etoiles de #2.lst ---*/
         do {
            data_tab2[n2-nb2deb+1].x      =data_tab20[n2].x;
            data_tab2[n2-nb2deb+1].y      =data_tab20[n2].y;
            data_tab2[n2-nb2deb+1].mag    =data_tab20[n2].mag;
            data_tab2[n2-nb2deb+1].qualite=data_tab20[n2].qualite;
            data_tab2[n2-nb2deb+1].ad     =data_tab20[n2].ad;
            data_tab2[n2-nb2deb+1].dec    =data_tab20[n2].dec;
            data_tab2[n2-nb2deb+1].mag_gsc=data_tab20[n2].mag_gsc;
            data_tab2[n2-nb2deb+1].type   =data_tab20[n2].type;
            /*
            // if ((data_tab20[n2].x>=xxmin2)&&(data_tab20[n2].x<=xxmax2)&&
            //     (data_tab20[n2].y>=yymin2)&&(data_tab20[n2].y<=yymax2) ) {
            */
            n2++;
            /*// }*/
         } while (n2<=nb2fin) ;

         /* --- On rentre ici dans le coeur de l'algo Focas ! ---*/
         if (focas_match(data_tab1,nb1,data_tab2,nb2,epsilon,seuil_poids,corresp,&nbc,&poids_max,&indice_cut1,&indice_cut2)!=OK) {
            throw ::std::exception("Pb focas_match in focas_main");
         }
         delete [] data_tab1;
         delete [] data_tab2;
         
         /*--- conditions de sortie ---*/
         nb=(nb1<nb2) ? nb1 : nb2;
         /*pmax=(nb*nb-3*nb+2)/2;*/
         nb=(nb <4  ) ? nb  : 4  ;
         if (nbc>=nb) {
            /* - calcule les matrices de transformation -*/
            if (focas_register(corresp,nbc,transf_1vers2,transf_2vers1)!=OK) {
               throw ::std::exception("Pb focas_register in focas_main");
            }
            /* - calcul le nombre total d'appariements -*/
            if (focas_liste_commune(data_tab10,nb1tot,data_tab20,nb2tot,transf_1vers2,transf_2vers1,nb_coef_a,1,delta,&total,corresp,corresp,0)!=OK) {
               throw ::std::exception("Pb focas_liste_commune in focas_main");
            }
         }
         /*if ((nbc>=nb)&&(total>=nbc)) { sortie0=1; }*/
         if (nbc>=nb) { sortie0=1; }
         else {sortie0=1; nbc=0;}
         if (flag_focas==1) {
            /* - cas : contraintes en translations -*/
            if ((fabs(transf_2vers1[1*nb_coef_a+1]-1.0)>2e-2)||
               (fabs(transf_2vers1[1*nb_coef_a+2]    )>2e-2)||
               (fabs(transf_2vers1[2*nb_coef_a+1]    )>2e-2)||
               (fabs(transf_2vers1[2*nb_coef_a+2]-1.0)>2e-2)  ) {
                  sortie0=0;
            }
         }
      }
      /* - Cas de non correspondance. On apparie alors les deux -*/
      /* - etoiles les plus brillantes. -*/
      if (nbc==0) {
         if (nb1tot==0) {
            data_tab10[0].x=0.;
            data_tab10[0].y=0.;
         }
         if (nb2tot==0) {
            data_tab20[0].x=0.;
            data_tab20[0].y=0.;
         }
         corresp[1].indice1=0;
         corresp[1].x1     =data_tab10[0].x;
         corresp[1].y1     =data_tab10[0].y;
         corresp[1].indice2=0;
         corresp[1].x2     =data_tab20[0].x;
         corresp[1].y2     =data_tab20[0].y;
         if ((nb1tot==0)||(nb2tot==0)) {
            transf_2vers1[1*nb_coef_a+1]=1.0;
            transf_2vers1[1*nb_coef_a+2]=0.0;
            transf_2vers1[2*nb_coef_a+1]=0.0;
            transf_2vers1[2*nb_coef_a+2]=1.0;
            transf_1vers2[1*nb_coef_a+1]=1.0;
            transf_1vers2[1*nb_coef_a+2]=0.0;
            transf_1vers2[2*nb_coef_a+1]=0.0;
            transf_1vers2[2*nb_coef_a+2]=1.0;
         } else {
            if (focas_register(corresp,1,transf_1vers2,transf_2vers1)!=OK) {
               throw ::std::exception("Pb focas_register nbc== 0 in focas_main");
            }
         }
      }
   }

   /* =============================================================== */
   /* = Les matrices de tranformation sont deja calculees et on va  = */
   /* = maintenant etablir les tableaux de correspondance entre les = */
   /* = deux listes.                                                = */
   /* =============================================================== */
   nbcmax=(nb1tot>nb2tot)?nb1tot:nb2tot;

   /* --- on dimensionne les listes de correspondance et de differences ---*/
   //corresp = new focas_tableau_corresp[nbcmax+1];
   //memset(corresp, nbcmax+1, sizeof(focas_tableau_corresp));
   corresp.resize(0);
   corresp.resize(nbcmax+1);
   
   //differe = new focas_tableau_corresp[nbcmax+1];
   //memset(differe, nbcmax+1, sizeof(focas_tableau_corresp));
   differe.resize(0);
   differe.resize(nbcmax+1);

   /* --- On remplit les tableaux de correspondance et de difference   ---*/
   /* --- et l'on calcule une matrice de passage entre les deux listes ---*/
   flag_corresp=(flag_sature2==0)?1:2;
   if ((nbc!=0)&&((flag_focas==0)||(flag_focas==1))) {
      if (focas_liste_commune(data_tab10,nb1tot,data_tab20,nb2tot,transf_1vers2,transf_2vers1,nb_coef_a,1,delta,&nbc,corresp,differe,1)!=OK) {
         throw ::std::exception("Pb focas_liste_commune in focas_main");
      }
      /* - on calcule la matrice de passage d'ordre 1 d'une liste a l'autre  -*/
      if (focas_register(corresp,nbc,transf_1vers2,transf_2vers1)!=OK) {
         throw ::std::exception("Pb focas_register in focas_main");
      }
      if ((transf2_1vers2!=NULL)&&(transf2_2vers1!=NULL)) {
         /* - on calcule la matrice de passage d'ordre 2 d'une liste a l'autre  -*/
         ////////////focas_register_2nd(corresp,nbc,transf2_1vers2,transf2_2vers1);
/// a faire
      }
   }

   flag_tri=1; /* a faire rentrer comme parametre de focas main...*/
   
   /* --- On remplit les tableaux de correspondance et de difference   ---*/
   if (focas_liste_commune(data_tab10,nb1tot,data_tab20,nb2tot,transf_1vers2,transf_2vers1,nb_coef_a,ordre_corresp,delta,&nbc,corresp,differe,flag_corresp)!=OK) {
      throw ::std::exception("Pb focas_liste_commune correspondance et de difference in focas_main");
   }

   /* --- Cas de translations contraintes ---*/
   //if ((nbc!=0)&&(flag_focas==1)&&((flag_focas==0)||(flag_focas==1))) {
   //   focas_transmoy(corresp,nbc,transf_1vers2,transf_2vers1);
   //}

   *nbcom=nbc;

   return(OK);
}

int focas_match(struct focas_tableau_entree *data_tab1,int nb1,
                struct focas_tableau_entree *data_tab2,int nb2,
                double epsilon,double seuil_poids,
                ::std::valarray<focas_tableau_corresp> &corresp,int *nbcorresp,
                int *poids_max,int *indice_cut1,int *indice_cut2)
                /*************************************************************************/
                /* FOCAS_MATCH                                                           */
                /* But : cree une liste de correspondance entre 2 listes *data_tab       */
                /* D'apres : Faint-Object Classification and Analysis System             */
                /*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
                /*                                                                       */
                /* 1) Calcule toutes les distances entre les etoiles de chaque liste.    */
                /* 2) Calcule tous les triangles (a,b,c) avec a>b>c dans chaque liste.   */
                /*    Ne garde que les triangles qui verifient (b/a)<0.9.                */
                /* 3) Trie les deux listes de triangles selon les ((b/a) croissants.     */
                /* 4) Apparie les triangles en comparant les x=(b/a) et y=(c/a) entre    */
                /*    les deux listes. L'appariement est bon lorsque la distance entre   */
                /*    le point (xi1,yi1) est a une distance inferieure a EPSILON du      */
                /*    point (xj2,yj2).                                                   */
                /* 5) Pour chaque appariement, on ajoute 1 a une matrice de 'vote'       */
                /*    donnant la correspondance entre les etoiles des deux listes.       */
                /* 6) On trie la matrice de vote selon les valeurs croissantes de vote.  */
                /* 7) On ne garde que les meilleures correspondances definies par :      */
                /*     Attention, nouvelle methode en cours.                             */
                /*     - un nombre de vote superieur a la moitie de la valeur du         */
                /*       nombre de vote maximum.                                         */
                /*     - l'etoile d'une correspondance ne doit pas deja apparaitre       */
                /*       dans une correspandace qui a un nombre de votes plus eleve.     */
                /*                                                                       */
                /* ENTREES :                                                             */
                /* *data_tab1 : tableau des entrees 1                                    */
                /* nb1        : nombre d'entrees dans le tableau 1                       */
                /* *data_tab2 : tableau des entrees 2                                    */
                /* nb2        : nombre d'entrees dans le tableau 2                       */
                /* epsilon    : cote du carre d'incertitude dans l'espace des triangles  */
                /* seuil_poids: fraction du poids maximum autorise (entre 0 et 1) pour   */
                /*              une correspondance acceptable (0.3 habituellement)       */
                /*                                                                       */
                /* SORTIES :                                                             */
                /* *corresp   : tableau des correspondances                              */
                /* *nbcorresp : nombre de correspondances                                */
                /* *poids_max : poids de la valeur maximale de la matrice de vote        */
                /* *indice_cut1 indice de la premiere correspondance aberrante           */
                /* *indice_cut2 indice de coupure du critere seuil_poids                 */
                /*************************************************************************/
{
   int nb11,nb111;
   struct focas_tableau_dist *dist1;
   struct focas_tableau_triang *triang1;
   int nb22,nb222;
   struct focas_tableau_dist *dist2;
   struct focas_tableau_triang *triang2;
   struct focas_tableau_vote *vote;
   int nbc=0;

   /*--- dimensionne les tableaux de pointeurs ---*/
   dist1=NULL;
   dist2=NULL;
   triang1=NULL;
   triang2=NULL;
   vote=NULL;
   nb11 =(nb1*(nb1-1))/2;
   nb111=(nb1*(2+nb1*(nb1-3)))/6;
   nb22 =(nb2*(nb2-1))/2;
   nb222=(nb2*(2+nb2*(nb2-3)))/6;

   dist1 = new focas_tableau_dist[nb11+2];
   memset(dist1,0,sizeof(focas_tableau_dist));

   triang1 = new focas_tableau_triang[nb111+2];
   memset(triang1,0,(nb111+2)*sizeof(focas_tableau_triang));

   dist2 = new focas_tableau_dist[nb22+2];
   memset(dist2,0,(nb22+2)*sizeof(focas_tableau_dist));

   triang2 = new focas_tableau_triang[nb222+2];
   memset(triang2,0,(nb222+2)*sizeof(focas_tableau_triang));

   vote = new focas_tableau_vote[nb1*nb2+2];
   memset(vote,0,(nb1*nb2+2)*sizeof(focas_tableau_vote));

   /* --- calcul de la distance mutuelle entre deux etoiles LISTE 1---*/
   if (focas_calcul_dist(nb1,data_tab1,dist1)!=OK) {
      throw ::std::exception("Pb calloc in focas_match when compute focas_calcul_dist for liste 1"); 
   }

   /* --- calcul des triangles LISTE 1 ---*/
   if (focas_calcul_triang(nb11,&nb111,dist1,triang1)!=OK) {
      throw ::std::exception("Pb in focas_match when compute focas_calcul_triang for liste 1");
   }
   /* --- calcul de la distance mutuelle entre deux etoiles LISTE 2---*/
   if (focas_calcul_dist(nb2,data_tab2,dist2)!=OK) {
      throw ::std::exception("Pb in focas_match when compute focas_calcul_dist for liste 2");
   }
   /* --- calcul des triangles LISTE 2---*/
   if (focas_calcul_triang(nb22,&nb222,dist2,triang2)!=OK) {
      throw ::std::exception("Pb in focas_match when compute focas_calcul_triang for liste 2");
   }
   /* --- matching entre les deux listes ---*/
   if (focas_match_triang(triang1,nb111,triang2,nb222,nb1,nb2,vote,epsilon)!=OK) {
      throw ::std::exception("Pb in focas_match when compute focas_match_triang");
   }
   /* --- selectionne les meilleures correspondances ---*/
   if (focas_best_corresp2(nb1,data_tab1,nb2,data_tab2,seuil_poids,vote,&nbc,corresp,poids_max,indice_cut1,indice_cut2)!=OK) {
      throw ::std::exception("Pb in focas_match when compute focas_best_corresp2");
   }

   *nbcorresp=nbc;
   delete [] dist1;
   delete [] triang1;
   delete [] dist2;
   delete [] triang2;
   delete [] vote;
   return(OK);
}


int focas_register(::std::valarray<focas_tableau_corresp> &corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1)
/*************************************************************************/
/* FOCAS_REGISTER                                                        */
/* But : calcule les coefficients de transformation de listes d'etoiles  */
/* D'apres : Faint-Object Classification and Analysis System             */
/*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
/*                                                                       */
/* .)  A employer apres FOCAS_MATCH.                                     */
/* 1)  On calcule la matrice de transformation des coordonnees des       */
/*     etoiles de la liste 1 dans le repere des coordonnees de la liste  */
/*     2 et vice versa.                                                  */
/*                                                                       */
/* ENTREES :                                                             */
/* *corresp   : tableau des correspondances                              */
/* nbcorresp  : nombre de correspondances                                */
/*                                                                       */
/* SORTIES :                                                             */
/* *transf_1vers2 : tableau des six coefs de transformation pour une     */
/*                  etoile de la liste 1 dans le repere de la liste 2.   */
/* *transf_2vers1 : tableau des six coefs de transformation pour une     */
/*                  etoile de la liste 2 dans le repere de la liste 1.   */
/*                                                                       */
/*************************************************************************/
{
   int nbc;
   int nb_coef_a,lig,col,j;
   double *xx,*xy,*a,*vec_p,*val_p;
   int *valid,kv;
   double *valeur;
   double x1,y1,x2,y2,dx,dy;
   double i=0.,mu_i=0.,mu_ii=0.,sx_i,sx_ii=0.,delta,mean,sigma;

   FILE *f;   
   nbc=nbcorresp;
   nb_coef_a=3;
   
   f=fopen("matrix.txt","wt");
   fclose(f);
  
   nbc=nbcorresp;
   nb_coef_a=3;

   if (nbc>=3) {
      xx = allocDouble((nb_coef_a+1)*(nb_coef_a+1));
      xy = allocDouble(3*(nb_coef_a+1));
      a = allocDouble(3*(nb_coef_a+1));
      vec_p = allocDouble((nb_coef_a+1)*(nb_coef_a+1));
      val_p = allocDouble(nb_coef_a+1);
      valid = new int[nbc+1];
      memset(valid, 0, (nbc+1)*sizeof(int));
      valeur = allocDouble(nbc+1);

      for (j=0;j<=nbc;j++) {
         valid[j]=TT_YES;
      }
      for (kv=0;kv<=1;kv++) {

         /***************************************************/
         /* ====== x1 = A*x2 + B*y2 + C (idem pur y1) ======*/
         /* --- a1 = A  et  x1j = x2                    --- */
         /* --- a2 = B  et  x2j = y2                    --- */
         /* --- a3 = C  et  x3j = 1                     --- */
         /***************************************************/
         /* === calcule les elements de matrice XX ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
            for (col=1;col<=nb_coef_a;col++) {
               xx[lig+nb_coef_a*col]=0;
               if ((lig==1)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2);} } }
               if ((lig==1)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2);} } }
               if ((lig==1)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x2              );} } }
               if ((lig==2)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].x2);} } }
               if ((lig==2)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2);} } }
               if ((lig==2)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y2              );} } }
               if ((lig==3)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(              corresp[j].x2);} } }
               if ((lig==3)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(              corresp[j].y2);} } }
               if ((lig==3)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(            1.000          );} } }
            }
         }
         focas_mat_givens(xx,val_p,vec_p,nb_coef_a);
         /* === inverse les valeurs propres de la matrice XX ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
            if (*(val_p+lig)!=0) { 
               *(val_p+lig)=1/ *(val_p+lig); 
            } else {
               throw ::std::exception("irregular first transformation in focas_register");              
            }
         }
         /* === calcul de la matrice XX-1 ===*/
         focas_mat_vdtv(xx,val_p,vec_p,nb_coef_a);
         /* === calcule les elements de matrice XY pour x1 ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
            xy[lig+1]=0;
            if (lig==1) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x1*corresp[j].x2);} } }
            if (lig==2) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x1*corresp[j].y2);} } }
            if (lig==3) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x1              );} } }
         }
         /* === calcule les coefficients de transformation pour x1 ===*/
         focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
         for (col=1;col<=nb_coef_a;col++) {
            transf_2vers1[1*nb_coef_a+col]=a[1*1+col];
         }
         /* === calcule les elements de matrice XY pour y1 ===*/
         for (lig=1;lig<=nb_coef_a;lig++) {
            xy[lig+1]=0;
            if (lig==1) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y1*corresp[j].x2);} } }
            if (lig==2) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y1*corresp[j].y2);} } }
            if (lig==3) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y1              );} } }
         }
         /* === calcule les coefficients de transformation pour y1 ===*/
         focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
         for (col=1;col<=nb_coef_a;col++) {
            transf_2vers1[2*nb_coef_a+col]=a[1*1+col];
         }

         /* === verif des validites ===*/
         /* on elimine les distances > a 2 sigma */
         i=0.;mu_i=0.;mu_ii=0.;sx_ii=0.;
         sx_i=0;
         for (j=1;j<=nbc;j++) {
            x2=corresp[j].x2;
            y2=corresp[j].y2;
            x1=transf_2vers1[1*nb_coef_a+1]*x2+transf_2vers1[1*nb_coef_a+2]*y2+transf_2vers1[1*nb_coef_a+3];
            y1=transf_2vers1[2*nb_coef_a+1]*x2+transf_2vers1[2*nb_coef_a+2]*y2+transf_2vers1[2*nb_coef_a+3];
            dx=corresp[j].x1-x1;
            dy=corresp[j].y1-y1;
            valeur[j]=sqrt(dx*dx+dy*dy);
            /* --- algo de la valeur moy et ecart type de Miller ---*/
            if (j==1) {mu_i=valeur[j];}
            i=(double) (j+1);
            delta=valeur[j]-mu_i;
            mu_ii=mu_i+delta/(i);
            sx_ii=sx_i+delta*(valeur[j]-mu_ii);
            mu_i=mu_ii;
            sx_i=sx_ii;
         }
         mean=mu_ii;
         sigma=0.;
         if (i!=0.) {
            sigma=sqrt(sx_ii/i);
         }
         for (j=1;j<=nbc;j++) {
            if (fabs(valeur[j]-mean)>2.*sigma) {
               valid[j]=TT_NO;
            }
         }

         f=fopen("matrix.txt","at");
         fprintf(f,"%f %f %f\n",transf_2vers1[1*nb_coef_a+1],transf_2vers1[1*nb_coef_a+2],transf_2vers1[1*nb_coef_a+3]);
         fprintf(f,"%f %f %f\n",transf_2vers1[2*nb_coef_a+1],transf_2vers1[2*nb_coef_a+2],transf_2vers1[2*nb_coef_a+3]);
         fprintf(f,"\n");
         fclose(f);

      }

     
      /***************************************************/
      /* ====== x2 = A*x1 + B*y1 + C (idem pur y2) ======*/
      /* --- a1 = A  et  x1j = x1                    --- */
      /* --- a2 = B  et  x2j = y1                    --- */
      /* --- a3 = C  et  x3j = 1                     --- */
      /***************************************************/
      /* === calcule les elements de matrice XX ===*/
      
      for (lig=1;lig<=nb_coef_a;lig++) {
         for (col=1;col<=nb_coef_a;col++) {
            xx[lig+nb_coef_a*col]=0;
            if ((lig==1)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1);} } }
            if ((lig==1)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1);} } }
            if ((lig==1)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].x1              );} } }
            if ((lig==2)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].x1);} } }
            if ((lig==2)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1);} } }
            if ((lig==2)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(corresp[j].y1              );} } }
            if ((lig==3)&&(col==1)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(              corresp[j].x1);} } }
            if ((lig==3)&&(col==2)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(              corresp[j].y1);} } }
            if ((lig==3)&&(col==3)) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xx[lig+nb_coef_a*col]+=(            1.000          );} } }
         }
      }
      focas_mat_givens(xx,val_p,vec_p,nb_coef_a);
      // === inverse les valeurs propres de la matrice XX ===
      for (lig=1;lig<=nb_coef_a;lig++) {
         if (*(val_p+lig)!=0) { *(val_p+lig)=1/ *(val_p+lig); } else {
            throw ::std::exception("irregular second transformation in focas_register ");  
         }
      }
      // === calcul de la matrice XX-1 ===
      focas_mat_vdtv(xx,val_p,vec_p,nb_coef_a);
      // === calcule les elements de matrice XY pour x2 ===
      for (lig=1;lig<=nb_coef_a;lig++) {
         xy[lig+1]=0;
         if (lig==1) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x2*corresp[j].x1);} } }
         if (lig==2) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x2*corresp[j].y1);} } }
         if (lig==3) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].x2              );} } }
      }
      // === calcule les coefficients de transformation pour x2 ===
      focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
      for (col=1;col<=nb_coef_a;col++) {
         transf_1vers2[1*nb_coef_a+col]=a[1*1+col];
      }
      // === calcule les elements de matrice XY pour y2 ===
      for (lig=1;lig<=nb_coef_a;lig++) {
         xy[lig+1]=0;
         if (lig==1) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y2*corresp[j].x1);} } }
         if (lig==2) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y2*corresp[j].y1);} } }
         if (lig==3) { for (j=1;j<=nbc;j++) { if (valid[j]==TT_YES) {xy[lig+1]+=(corresp[j].y2              );} } }
      }
      // === calcule les coefficients de transformation pour y2 ===
      focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
      for (col=1;col<=nb_coef_a;col++) {
         transf_1vers2[2*nb_coef_a+col]=a[1*1+col];
      }
      

      delete [] xx;
      delete [] xy;
      delete [] a;
      delete [] vec_p;
      delete [] val_p;
      delete [] valid;
      delete [] valeur;

   } else if ((nbc<=2)&&(nbc>=1)) {
      transf_1vers2[1*nb_coef_a+1]=1.0;
      transf_1vers2[1*nb_coef_a+2]=0.0;
      transf_1vers2[1*nb_coef_a+3]=corresp[1].x2-corresp[1].x1;
      transf_1vers2[2*nb_coef_a+1]=0.0;
      transf_1vers2[2*nb_coef_a+2]=1.0;
      transf_1vers2[2*nb_coef_a+3]=corresp[1].y2-corresp[1].y1;
      transf_2vers1[1*nb_coef_a+1]=1.0;
      transf_2vers1[1*nb_coef_a+2]=0.0;
      transf_2vers1[1*nb_coef_a+3]=corresp[1].x1-corresp[1].x2;
      transf_2vers1[2*nb_coef_a+1]=0.0;
      transf_2vers1[2*nb_coef_a+2]=1.0;
      transf_2vers1[2*nb_coef_a+3]=corresp[1].y1-corresp[1].y2;
   }
   return(OK);
}

int focas_mat_givens(double *a,double *d,double *v,int n)
/***************************************************************************/
/*                                                                         */
/*  BUT ET ALGORITHME : A.Klotz 31/3/94                                    */
/*   calcul des valeurs propres et les vecteurs propres d'une matrice par  */
/*   l'algo de Givens                                                      */
/*   Dans un premier temps on transforme la matrice de depart en une       */
/*   matrice trigonale                                                     */
/*   Dans un deuxieme temps on reduit cette matrice trigonale              */
/*   source : Numerical Recipes (ISBN 0 521 30811 9) Cambridge Press 1986  */
/*            W.H.Press, B.P.Flannery, S.A.Teukolsky, W.T.Vetterling       */
/*                                                                         */
/*  ENTREES                                                                */
/*   La matrice A a pour dimension n*n                                     */
/*   La matrice A est definie par le pointeur *matrice definit par :       */
/*    a=(double *)tt_calloc((n+1)*(n+1),sizeof(double));                        */
/*   La dimension n de la matrice a diagonaliser                           */
/*                                                                         */
/*  SORTIES                                                                */
/*   Le vecteur contenant les valeurs propres non triees defini par :      */
/*    d = (double *) tt_calloc((n+1),sizeof(double));                           */
/*   La matrice V a pour dimension n*n et contient les vecteurs propres    */
/*    dans ses colonnes                                                    */
/*   La matrice V est definie par le pointeur *matrice definit par :       */
/*    v = (double *)tt_calloc((n+1)*(n+1),sizeof(double));                      */
/*   La matrice d'entree *a n'est pas changee                              */
/*                                                                         */
/***************************************************************************/
{
   double *e,*aa;
   int i,j,k,l,iter,m;
   double h,scale,f,g,hh,dd,r,s,c,b,p;

   e = allocDouble(n+1);
   aa = allocDouble((n+1)*(n+1));

   /*--- initialise la matrice aa ---*/
   for (i=1;i<=n;i++) {
      for (j=1;j<=n;j++) {
         *(aa+n*i+j)=*(a+n*i+j);
      }
   }
   if (n>1) {
      for (i=n;i>=2;i--) {
         l=i-1;
         h=0;
         scale=0;
         if (l>1) {
            for (k=1;k<=l;k++) { scale+=fabs(*(aa+n*i+k)); }
            if (scale==0) { *(e+i)=*(aa+n*i+l); }
            else {
               for (k=1;k<=l;k++) {
                  *(aa+n*i+k)/=scale;
                  h+=*(aa+n*i+k)*(*(aa+n*i+k));
               }
               f=*(aa+n*i+l);
               g=((f>=0) ? -fabs(sqrt(h)) : fabs(sqrt(h))) ;
               *(e+i)=scale*g;
               h-=f*g;
               *(aa+n*i+l)=f-g;
               f=0;
               for (j=1;j<=l;j++) {
                  *(aa+n*j+i)=*(aa+n*i+j)/h;
                  g=0.;
                  for (k=1;k<=j;k++) {
                     g+=*(aa+n*j+k)*(*(aa+n*i+k));
                  }
                  if (l>j) {
                     for (k=j+1;k<=l;k++) {
                        g+=*(aa+n*k+j)*(*(aa+n*i+k));
                     }
                  }
                  *(e+j)=g/h;
                  f+=*(e+j)*(*(aa+n*i+j));
               }
               hh=f/(h+h);
               for (j=1;j<=l;j++) {
                  f=*(aa+n*i+j);
                  g=*(e+j)-hh*f;
                  *(e+j)=g;
                  for (k=1;k<=j;k++) {
                     *(aa+n*j+k)-=f*(*(e+k))+g*(*(aa+n*i+k));
                  }
               }
            } /* endif */
         }
         else {
            *(e+i)=*(aa+n*i+l);
         }
         *(d+i)=h;
      } /* i */
   }
   *(d+1)=0.;
   *(e+1)=0.;
   for (i=1;i<=n;i++) {
      l=i-1;
      if (*(d+i)!=0) {
         for (j=1;j<=l;j++) {
            g=0;
            for (k=1;k<=l;k++) {
               g+=*(aa+n*i+k)*(*(aa+n*k+j));
            }
            for (k=1;k<=l;k++) {
               *(aa+n*k+j)-=*(aa+n*k+i)*g;
            }
         }
      }
      *(d+i)=*(aa+n*i+i);
      *(aa+n*i+i)=1.;
      if (l>=1) {
         for (j=1;j<=l;j++) {
            *(aa+n*i+j)=0.;
            *(aa+n*j+i)=0.;
         }
      }
   }
   if (n>1) {
      for (i=2;i<=n;i++) {
         *(e+i-1)=*(e+i);
      }
      *(e+n)=0;
      for (l=1;l<=n;l++) {
         iter=0;
n1 : for (i=0,m=l;m<=n-1;m++) {
         dd=fabs(*(d+m))+fabs(*(d+m+1));
         if ((fabs(*(e+m))+dd)==dd) { i=1; break; }
     }
     if (i==0) { m=n; }
     if (m!=l) {
        if (iter==30) { 
           //printf("trop d'iteration dans focas_mat_givens\n");
           //throw ::std::exception("trop d'iteration dans focas_mat_givens");
        }
        iter++;
        g=(*(d+l+1)-*(d+l))/(2.*(*(e+l)));
        r=sqrt(g*g+1.);
        g=*(d+m)-*(d+l)+*(e+l)/(g+ ((g>=0) ? fabs(r) : -fabs(r)) );
        s=1.;
        c=1.;
        p=0.;
        for (i=m-1;i>=l;i--) {
           f=*(e+i)*s;
           b=*(e+i)*c;
           if (fabs(f)>=fabs(g)) {
              c=g/f;
              r=sqrt(c*c+1.);
              *(e+i+1)=f*r;
              s=1./r;
              c*=s;
           }
           else {
              s=f/g;
              r=sqrt(s*s+1.);
              *(e+i+1)=g*r;
              c=1./r;
              s*=c;
           }
           g=*(d+i+1)-p;
           r=(*(d+i)-g)*s+2.*c*b;
           p=s*r;
           *(d+i+1)=g+p;
           g=c*r-b;
           for (k=1;k<=n;k++) {
              f=*(aa+n*k+i+1);
              *(aa+n*k+i+1)=*(aa+n*k+i)*s+c*f;
              *(aa+n*k+i)=*(aa+n*k+i)*c-s*f;
           }
        }
        *(d+l)-=p;
        *(e+l)=g;
        *(e+m)=0.;
        goto n1;
     }
      }
   }
   for (i=1;i<=n;i++) {
      for (j=1;j<=n;j++) {
         *(v+n*i+j)=*(aa+n*i+j);
      }
   }
   delete [] e;
   delete [] aa;
   return(OK);
}

int focas_mat_mult(double *a,double *b,double *c,int n,int m,int p)
/***************************************************************************/
/*                                                                         */
/*  BUT ET ALGORITHME : A.Klotz 3/4/94                                     */
/*   calcul la matrice C= A * B a partir des matrices A(m,n) et B(n,p)     */
/*   la matrice C a pour dimension C(lignes=m,colonnes=p)                  */
/*                                                                         */
/*  ENTREES                                                                */
/*   Les dimensions n,m,p des matrices A(m,n) B(n,p) et C(m,p)             */
/*   La matrice A est definie par le pointeur *a definit par :             */
/*    a = (double *)tt_calloc((m+1)*(n+1),sizeof(double));                      */
/*   La matrice B est definie par le pointeur *b definit par :             */
/*    b = (double *)tt_calloc((n+1)*(p+1),sizeof(double));                      */
/*                                                                         */
/*  SORTIES                                                                */
/*   La matrice C est definie par le pointeur *c definit par :             */
/*    c = (double *)tt_calloc((m+1)*(p+1),sizeof(double));                      */
/*    il est possible d'avoir le nom de C comme celui de A ou B            */
/*                                                                         */
/***************************************************************************/
{
   int ligne,colonne,k;
   double *cc;

   cc = allocDouble((m+1)*(p+1));
   for (ligne=1;ligne<=m;ligne++) {
      for (colonne=1;colonne<=p;colonne++) {
         *(cc+p*ligne+colonne)=0;
         for (k=1;k<=n;k++) {
            *(cc+p*ligne+colonne)+=*(a+n*ligne+k)*(*(b+p*k+colonne));
         }
      }
   }
   for (ligne=1;ligne<=m;ligne++) {
      for (colonne=1;colonne<=p;colonne++) {
         *(c+p*ligne+colonne)=*(cc+p*ligne+colonne);
      }
   }
   delete [] cc;
   return(OK);
}

int focas_mat_vdtv(double *a,double *d,double *v,int n)
/***************************************************************************/
/*                                                                         */
/*  BUT ET ALGORITHME : A.Klotz 11/4/94                                    */
/*   calcul la matrice A = V * D * tV a partir des vecteurs propres V et   */
/*   des valeurs prores D                                                  */
/*                                                                         */
/*  ENTREES                                                                */
/*   La dimension n de la matrice                                          */
/*   Le vecteur contenant les valeurs propres non triees defini par :      */
/*    d = (double *) tt_calloc((n+1),sizeof(double));                           */
/*   La matrice V a pour dimension n*n et contient les vecteurs propres    */
/*    dans ses colonnes                                                    */
/*   La matrice V est definie par le pointeur *matrice definit par :       */
/*    v = (double *)tt_calloc((n+1)*(n+1),sizeof(double));                      */
/*                                                                         */
/*  SORTIES                                                                */
/*   La matrice A a pour dimension n*n                                     */
/*   La matrice A est definie par le pointeur *matrice definit par :       */
/*    a=(double *)tt_calloc((n+1)*(n+1),sizeof(double));                        */
/*                                                                         */
/***************************************************************************/
{
   double *aa;
   int ligne,colonne,k;

   aa = allocDouble( (n+1)*(n+1));
   for (ligne=1;ligne<=n;ligne++) {
      for (colonne=1;colonne<=n;colonne++) {
         *(aa+n*ligne+colonne)=*(v+n*ligne+colonne)*(*(d+colonne)) ;
      }
   }
   for (ligne=1;ligne<=n;ligne++) {
      for (colonne=1;colonne<=n;colonne++) {
         *(a+n*ligne+colonne)=0;
         for (k=1;k<=n;k++) {
            *(a+n*ligne+colonne)+=*(aa+n*ligne+k)*(*(v+n*colonne+k));
         }
      }
   }
   delete [] aa;
   return(OK);
}

int focas_calcul_dist(int nb, struct focas_tableau_entree *data_tab, struct focas_tableau_dist *dist)
/**************************************************************************/
/* Calcule la distance au carre entre deux etoiles :                      */
/* Effectue le calcul pour tous les couples d'etoiles.                    */
/* Place le resultat dans le tableau *dist                                */
/**************************************************************************/
{
   int i,j,k;
   double x0,y0,x,y;
   int n=nb*(nb-1)/2,s,l,r;
   double v,w;
   double *qsort_r,*qsort_l;

   qsort_r = NULL; 
   qsort_l = NULL; 
   qsort_r = allocDouble(FOCAS_SORT);
   qsort_l = allocDouble(FOCAS_SORT);

   for (k=1,i=1;i<=nb-1;i++) {
      x0=(data_tab+i)->x;
      y0=(data_tab+i)->y;
      for (j=i+1;j<=nb;j++,k++) {
         x=x0-(data_tab+j)->x;
         y=y0-(data_tab+j)->y;
         if ((x==0.)&&(y==0.)) {
            throw ::std::exception("Pb of null distance in focas_calcul_dist (check files .lst)");
         }
         (dist+k)->indice1=i;
         (dist+k)->indice2=j;
         (dist+k)->dist2=(x*x+y*y);
      }
   }
   /*--- trie le tableau dans l'ordre croissant des distances ---*/
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
         i=l; j=r;
         v=dist[(int) (floor((((double)l+r)/2)))].dist2;
         do {
            while (dist[i].dist2<v) {i++;}
            while (v<dist[j].dist2) {j--;}
            if (i<=j) {
               w=dist[i].dist2;   dist[i].dist2=dist[j].dist2;     dist[j].dist2=w;
               k=dist[i].indice1; dist[i].indice1=dist[j].indice1; dist[j].indice1=k;
               k=dist[i].indice2; dist[i].indice2=dist[j].indice2; dist[j].indice2=k;
               i++; j--;
            }
         } while (i<=j);
         if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;

   delete [] qsort_r;
   delete [] qsort_l;

   return(OK);
}

int focas_calcul_triang(int nbb, int *nbbb, struct focas_tableau_dist *dist, struct focas_tableau_triang *triang)
/**************************************************************************/
/* Calcule les parametres xt et yt pour chaque triangle a<b<c             */
/* nbb : nb de distances entre etoiles                                    */
/* nbbb: nb de triangles tels que a<b<c.                                  */
/**************************************************************************/
/*                          pp1                                           */
/*                         /   \                                          */
/*                    a  /       \  c                                     */
/*                     /     b     \                                      */
/*                   pp2 ---------- pp3                                   */
/**************************************************************************/
{
   int i,j,k,p1,p2,p11,p22,pp1=0,pp2=0,pp3,ii,jj,ppp1,ppp3;
   double a,b,c;
   int kk=0,nb;
   int n,s,l,r;
   double v,w;
   double *qsort_r=NULL,*qsort_l=NULL;

   qsort_r = NULL; 
   qsort_l = NULL; 
   qsort_r = allocDouble(FOCAS_SORT);
   qsort_l = allocDouble(FOCAS_SORT);


   nb=(int)((1+sqrt((double)(1+8*nbb)))/2);
   for (i=nbb;i>=3;i--) {
      a=dist[i].dist2;
      p1=dist[i].indice1;
      p2=dist[i].indice2;
      for (j=i-1;j>=2;j--) {
         b=dist[j].dist2;
         p11=dist[j].indice1;
         p22=dist[j].indice2;
         pp3=0;
         if (p11==p1) {pp1=p2; pp2=p1; pp3=p22;}
         else if (p11==p2) {pp1=p1; pp2=p2; pp3=p22;}
         else if (p22==p1) {pp1=p2; pp2=p1; pp3=p11;}
         else if (p22==p2) {pp1=p1; pp2=p2; pp3=p11;}
         if (pp3>0) {
            if (pp1<pp3) {ppp1=pp1; ppp3=pp3;} else {ppp1=pp3; ppp3=pp1;}
            k=j-1;
            do {
               ii=dist[k].indice1;
               jj=dist[k].indice2;
               if ((ii==ppp1)&&(jj==ppp3)) {
                  c=dist[k].dist2;
                  b=sqrt(b/a);
                  if ((b<0.9)||(nb==3)) {
                     kk++;
                     triang[kk].x=b;
                     triang[kk].y=sqrt(c/a);
                     triang[kk].indice1=pp1;
                     triang[kk].indice2=pp2;
                     triang[kk].indice3=pp3;
                  }
                  k=0;
               } else {
                  k--;
               }
            } while (k!=0) ;
         }
      }
   }
   *nbbb=kk;
   /*--- trie le tableau dans l'ordre croissant des x ---*/
   n=kk;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
         int index;
         i=l; j=r;
         index = (int) (floor(((double)l+r)/2));
         v=triang[index].x;
         do {
            while (triang[i].x<v) {i++;}
            while (v<triang[j].x) {j--;}
            if (i<=j) {
               w=triang[i].x;       triang[i].x=triang[j].x;             triang[j].x=w;
               w=triang[i].y;       triang[i].y=triang[j].y;             triang[j].y=w;
               k=triang[i].indice1; triang[i].indice1=triang[j].indice1; triang[j].indice1=k;
               k=triang[i].indice2; triang[i].indice2=triang[j].indice2; triang[j].indice2=k;
               k=triang[i].indice3; triang[i].indice3=triang[j].indice3; triang[j].indice3=k;
               i++; j--;
            }
         } while (i<=j);
         if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;

   delete [] qsort_r;
   delete [] qsort_l;


   return(OK);
}

int focas_match_triang(struct focas_tableau_triang *triang1, int nb111, struct focas_tableau_triang *triang2, int nb222, int nb1, int nb2, struct focas_tableau_vote *vote,double epsilon)
/**************************************************************************/
/* Calcule les poids de probabilite d'associer deux etoiles des deux      */
/* listes.                                                                */
/* le poids se trouve dans le tableau de 'vote'                           */
/**************************************************************************/
{
   int i1,i2,i2deb;
   double x1,x2,y1,y2,x1mini,x1maxi,y1mini,y1maxi;
   int indice11,indice21,indice31,indice12,indice22,indice32;
   int i,j,k;
   int n,s,l=0,r=0;
   int v,w;
   double *qsort_r,*qsort_l;

   qsort_r = NULL; 
   qsort_l = NULL; 
   qsort_r = allocDouble(FOCAS_SORT);
   qsort_l = allocDouble(FOCAS_SORT);

   i2deb=1;
   for (i1=1;i1<=nb111;i1++) {
      x1=triang1[i1].x;
      y1=triang1[i1].y;
      x1mini=x1-epsilon;
      x1maxi=x1+epsilon;
      y1mini=y1-epsilon;
      y1maxi=y1+epsilon;
      i2=i2deb;
      do {
         x2=triang2[i2].x;
         if (x2<x1mini) { i2deb=i2; }
         else if (x2>x1maxi) { i2=nb222+1; }
         else {
            y2=triang2[i2].y;
            if ((y2>y1mini)&&(y2<y1maxi)) {
               indice11=triang1[i1].indice1; indice12=triang2[i2].indice1;
               vote[(indice11-1)*nb2+indice12].poids++;
               indice21=triang1[i1].indice2; indice22=triang2[i2].indice2;
               vote[(indice21-1)*nb2+indice22].poids++;
               indice31=triang1[i1].indice3; indice32=triang2[i2].indice3;
               vote[(indice31-1)*nb2+indice32].poids++;
            }
         }
         i2++;
      } while (i2<=nb222) ;
   }
   for (i1=1;i1<=nb1;i1++) {
      for (i2=1;i2<=nb2;i2++) {
         vote[(i1-1)*nb2+i2].indice1=i1;
         vote[(i1-1)*nb2+i2].indice2=i2;
      }
   }
   /*--- trie le tableau de vote dans l'ordre croissant des poids ---*/
   n=nb1*nb2;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
         int index;
         i=l; j=r;
         index = (int) (floor((((double)l+r)/2)));
         v=vote[index].poids;
         do {
            while (vote[i].poids<v) {i++;}
            while (v<vote[j].poids) {j--;}
            if (i<=j) {
               w=vote[i].poids;   vote[i].poids  =vote[j].poids;   vote[j].poids=w;
               k=vote[i].indice1; vote[i].indice1=vote[j].indice1; vote[j].indice1=k;
               k=vote[i].indice2; vote[i].indice2=vote[j].indice2; vote[j].indice2=k;
               i++; j--;
            }
         } while (i<=j);
         if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
   delete [] qsort_r;
   delete [] qsort_l;
   return(OK);
}

int focas_best_corresp2(int nb1,struct focas_tableau_entree *data_tab1,int nb2,
   struct focas_tableau_entree *data_tab2,
   double seuil_poids,struct focas_tableau_vote *vote,int *nbc,
   ::std::valarray<focas_tableau_corresp> &corresp,
   int *poids_max,int *indice_cut1,int *indice_cut2)
   /**************************************************************************/
   /* NOUVELLE METHODE                                                       */
   /* Le tableau *corresp etablit la correspondance entre les donnees des    */
   /* deux listes (x1,y1) et (x2,y2) pour les correspondances les plus       */
   /* probables (poids du vote).                                             */
   /* *nbc est modifie pour ne contenir que des 'vraies' correpondances.     */
   /**************************************************************************/
{
   int i,j,k,knext=0;
   int indice1,indice2,nbc6=0;
   int *best6;
   int *ibest6;
   int nb_coef_a=3,compteur;
   double transf12[20],transf21[20];
   double dist1[37],dist2[37],disterr[37],disterr0[37];
   double xi,xj,yi,yj,dx,dy,x,y,x1,y1,x2,y2;
   double err,errtot,errsigma,seuil,d2;
   int ntot,sortie,maxi,imaxi;

   *nbc=0;
   /* --- initialise le tableau de selection des 6 etoiles qui vont */
   /* --- permettre le calcul des coef de transformation */
   best6 = NULL; 
   best6 = new int[nb1*nb2+1];
   memset(best6,0,(nb1*nb2+1)*sizeof(int));

   for (i=0,k=nb1*nb2;k>=1;k--) {
      if ((nb1*nb2-k)<6) {
         i++;
         best6[k]=1;
         knext=k-1;
      } else {
         best6[k]=0;
      }
   }

   ibest6 = NULL; 
   ibest6 = new int[i+1];
   memset(ibest6,0,(i+1)*sizeof(int));

   sortie=TT_NO;
   compteur=0;
   while (sortie==TT_NO) {
      /*--- copie 'vote' dans le tableau 'corresp' pour les 6 etoiles ---*/
      for (i=0,k=nb1*nb2;k>=1;k--) {
         if (best6[k]==1) {
            i++;
            ibest6[i]=k;
            indice1=vote[k].indice1;
            corresp[i].indice1=indice1;
            corresp[i].x1     =data_tab1[indice1].x;
            corresp[i].y1     =data_tab1[indice1].y;
            indice2=vote[k].indice2;
            corresp[i].indice2=indice2;
            corresp[i].x2     =data_tab2[indice2].x;
            corresp[i].y2     =data_tab2[indice2].y;
            corresp[i].poids=vote[k].poids;
            corresp[i].ad     =data_tab2[indice2].ad;        /* GSC = liste 2 */
            corresp[i].dec    =data_tab2[indice2].dec;
            corresp[i].mag_gsc=data_tab2[indice2].mag_gsc;
            /* --- ici on detourne le sens des .type pour les utiliser */
            /* --- au calcul des erreurs d'appariement ---*/
            corresp[i].type1  =0;
            corresp[i].type2  =0;
         }
         nbc6=i;
      }
      if (nbc6>=3) {
         if (focas_register(corresp,nbc6,transf12,transf21)!=OK) {
            throw ::std::exception("Pb in focas_best_corresp2 when compute focas_register");
         }
      } else {
         /* sortie avec trop peu d'etoile a faire ...*/
         throw ::std::exception("sortie avec trop peu d'etoile a faire ...");
      }
      /* --- calcul des distances entre etoiles de la liste 1 ---*/
      for (i=0;i<37;i++) { dist1[i]=0.; dist2[i]=0.; disterr[i]=0.; }
      for (i=1;i<=nbc6-1;i++) {
         xi=corresp[i].x1;
         yi=corresp[i].y1;
         for (j=i+1;j<=nbc6;j++) {
            xj=corresp[j].x1;
            yj=corresp[j].y1;
            dx=(xi-xj);
            dy=(yi-yj);
            dist1[(i-1)*nbc6+j-1]=dx*dx+dy*dy;
         }
      }

      /* --- calcul des distances entre etoiles de la liste 2 ---*/
      /* --- corrigee de la transformation ---*/
      for (i=1;i<=nbc6-1;i++) {
         x=corresp[i].x2;
         y=corresp[i].y2;
         xi=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3];
         yi=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3];
         for (j=i+1;j<=nbc6;j++) {
            x=corresp[j].x2;
            y=corresp[j].y2;
            xj=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3];
            yj=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3];
            dx=(xi-xj);
            dy=(yi-yj);
            dist2[(i-1)*nbc6+j-1]=dx*dx+dy*dy;
         }
      }
      /* --- calcul de l'erreur de distance entre les deux listes ---*/
      errtot=0;
      ntot=0;
      for (i=0;i<37;i++) {
         err=sqrt(dist2[i])-sqrt(dist1[i]);
         disterr[i]=fabs(err);
         disterr0[i]=fabs(err);
         errtot+=(err*err);
         if ((dist2[i]!=0.)||(dist1[i]!=0.)) {
            ntot++;
         }
      }
      errsigma=(ntot==0)?0.:sqrt(errtot/ntot);

      /* --- condition de sortie ---*/
      if (errsigma<2.) {
         sortie=TT_YES;
         break;
      }
      if (++compteur>5) {
         sortie=TT_YES;
         break;
      }
      /* --- recherche la valeur seuil a 60 pourcent ---*/
      tt_util_qsort_double(disterr,0,37,NULL);
      for (i=0;i<37;i++) {
         if (disterr[i]!=0) { break; }
      }
      j=37-i; /* j valeurs non nulles */
      i=i+(int)(0.6*j);
      if (i>36) {i=36;}
      seuil=disterr[i];
      /* --- recherche les mauvais appariements ---*/
      /* --- a partir des erreurs sur les distances ---*/
      for (i=1;i<=nbc6-1;i++) {
         for (j=i+1;j<=nbc6;j++) {
            if (disterr0[(i-1)*nbc6+j-1]>=seuil) {
               corresp[i].type1  +=1;
               corresp[j].type1  +=1;
               corresp[i].type2  +=1;
               corresp[j].type2  +=1;
            }
         }
      }
      /* --- on elimine le couple qui a le plus d'erreurs ---*/
      /* --- il suffit de le faire sur la liste 1 seulement ---*/
      maxi=0;
      imaxi=0;
      for (i=1;i<=nbc6;i++) {
         if (corresp[i].type1>maxi) {
            maxi=corresp[i].type1;
            imaxi=ibest6[i];
         }
      }
      /* --- on remplace le couple a eliminer par le suivant en ---*/
      /* --- ordre de vote decroissant ---*/
      best6[imaxi]=0;
      if (knext>=1) {
         best6[knext]=1;
      } else {
         sortie=TT_YES;
      }
      knext--;

   } /* --- fin de la grande boucle while ---*/

   /* --- dresse la liste des correspondances totales ---*/
   for (i=0,k=nb1*nb2;k>=1;k--) {
      indice1=vote[k].indice1;
      indice2=vote[k].indice2;
      x1     =data_tab1[indice1].x;
      y1     =data_tab1[indice1].y;
      x      =data_tab2[indice2].x;
      y      =data_tab2[indice2].y;
      x2=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3];
      y2=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3];
      dx=(x1-x2);
      dy=(y1-y2);
      d2=dx*dx+dy*dy;
      if (d2<4) {
         i++;
         if ((i>nb1)||(i>nb2)) {
            i--;
            break;
         }
         corresp[i].indice1=indice1;
         corresp[i].x1     =data_tab1[indice1].x;
         corresp[i].y1     =data_tab1[indice1].y;
         corresp[i].indice2=indice2;
         corresp[i].x2     =data_tab2[indice2].x;
         corresp[i].y2     =data_tab2[indice2].y;
         corresp[i].poids=vote[k].poids;
         corresp[i].ad     =data_tab2[indice2].ad;        /* GSC = liste 2 */
         corresp[i].dec    =data_tab2[indice2].dec;
         corresp[i].mag_gsc=data_tab2[indice2].mag_gsc;
         corresp[i].type1  =data_tab1[indice1].type;
         corresp[i].type2  =data_tab2[indice2].type;
      }
   }
   if (i==0) {
      k=nb1*nb2;
      i=1;
      indice1=vote[k].indice1;
      indice2=vote[k].indice2;
      corresp[i].indice1=indice1;
      corresp[i].x1     =data_tab1[indice1].x;
      corresp[i].y1     =data_tab1[indice1].y;
      corresp[i].indice2=indice2;
      corresp[i].x2     =data_tab2[indice2].x;
      corresp[i].y2     =data_tab2[indice2].y;
      corresp[i].poids=vote[k].poids;
      corresp[i].ad     =data_tab2[indice2].ad;        /* GSC = liste 2 */
      corresp[i].dec    =data_tab2[indice2].dec;
      corresp[i].mag_gsc=data_tab2[indice2].mag_gsc;
      corresp[i].type1  =data_tab1[indice1].type;
      corresp[i].type2  =data_tab2[indice2].type;
   }
   delete [] best6;
   delete [] ibest6;
   *nbc=i;
   return(OK);
}

int focas_liste_commune(
   ::std::vector<focas_tableau_entree> &data_tab10,int nb1tot,
   ::std::vector<focas_tableau_entree> &data_tab20,int nb2tot,
   double *transf12,double *transf21,int nb_coef_a,
   int ordre_corresp,
   double delta,
   int *total,
   ::std::valarray<focas_tableau_corresp> &corresp,
   ::std::valarray<focas_tableau_corresp> &differe,
   int flag_corresp)
   /*************************************************************************/
   /* FOCAS_LISTE_COMMUNE                                                   */
   /* But : cree une liste de correspondance entre 2 listes *data_tab       */
   /* D'apres : Faint-Object Classification and Analysis System             */
   /*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
   /*                                                                       */
   /* 1) Compte (et eventuellement assigne dans le tableau *corresp si      */
   /*    flag_corresp==1) les correspondances entre les deux tableaux       */
   /*    d'entrees en connaissant les coefficients de transformation.       */
   /* Si flag_corresp==1 alors on peut avoir 2 :                            */
   /* 2) Compte et Assigne la liste des etoiles qui different dans la zone  */
   /*    commune aux deux images (tableau *differe).                        */
   /* Si flag_corresp==1 et *nom_fichier_com!="" alors on peut avoir 3 :    */
   /* 3) Trie le tableau *corresp dans l'ordre des plus grands vers les     */
   /*    plus petits ecarts par rapport a la moyenne des ecarts en          */
   /*    magnitude. Puis, ecrit la liste dans le fichier *nom_fichier_com.  */
   /* Si flag_corresp==1 et *nom_fichier_dif!="" alors on peut avoir 4 :    */
   /* 4) Trie le tableau *differe dans l'ordre des plus grandes vers les    */
   /*    plus petites brillances d'etoiles.                                 */
   /*    Puis, ecrit la liste dans le fichier *nom_fichier_dif.             */
   /*                                                                       */
   /* ENTREES :                                                             */
   /* *NOM_FICHIER_COM : nom de fichier qui contiendra la liste des etoiles */
   /*                    communes aux deux tableaux d'entree.               */
   /*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
   /*                    L'odre des colonnes est :                          */
   /*                     x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2                 */
   /*                     mag1-2 qualite1 qualite2                          */
   /*                     (qualite=-1 si sature sinon =1)                   */
   /* *NOM_FICHIER_DIF : nom de fichier qui contiendra la liste des etoiles */
   /*                    differentes aux deux tableaux d'entree.            */
   /*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
   /*                    L'odre des colonnes est :                          */
   /*                     x2/1 y2/1 mag2/2 x2/2 y2/2 mag2/2                 */
   /*                     mag1-2 qualite1 qualite2                          */
   /*                     (qualite=-1 si sature sinon =1)                   */
   /*                     (x1,y1) coordonnees (x2,y2) dans le repere 1      */
   /* *data_tab10 : tableau des entrees 1.                                  */
   /* nb1tot      : nombre d'entrees dans le tableau 1.                     */
   /* *data_tab20 : tableau des entrees 2.                                  */
   /* nb2tot      : nombre d'entrees dans le tableau 2.                     */
   /* *transf12   : coefficients de transformation 1 vers 2.                */
   /* *transf21   : coefficients de transformation 2 vers 1.                */
   /* nb_coef_a   : dimension des tableaux des coefficients de              */
   /*               transformation (=3 pour ordre 1 =6 pour ordre deux).    */
   /* ordre_corresp : =1 pour faire les correspondances avec l'ordre 1      */
   /*                 =2 pour faire les correspondances avec l'ordre 1      */
   /* delta       : dimension, en pixels, du cote du carre d'incertitude    */
   /*               pour l'appariement de deux etoiles (=1.0).              */
   /* flag_corresp: =0 compte uniquement le nombre d'etoiles en commun.     */
   /*                  Ne modifie pas les tableaux *corresp et *differe.    */
   /*                  A employer ave les noms de fichiers = "".            */
   /*               =1 modifie les tableaux *corresp et *differe et inclut  */
   /*                  les etoiles qui saturent dans les fichiers de sortie */
   /*                  et trie les listes en magnitudes.                    */
   /*               =2 modifie les tableaux *corresp et *differe et exclut  */
   /*                  les etoiles qui saturent dans les fichiers de sortie */
   /*                  et trie les listes en magnitudes.                    */
   /*              =11 modifie les tableaux *corresp et *differe et inclut  */
   /*                  les etoiles qui saturent dans les fichiers de sortie */
   /*                  et ne trie pas les listes en magnitudes.             */
   /*              =12 modifie les tableaux *corresp et *differe et exclut  */
   /*                  les etoiles qui saturent dans les fichiers de sortie */
   /*                  et ne trie pas les listes en magnitudes.             */
   /*                                                                       */
   /* SORTIES :                                                             */
   /* *total   : nombre total d'etoiles en correspondance.                  */
   /* *corresp : tableau des correspondances entre les deux listes.         */
   /*            non affecte si flag_corresp==0.                            */
   /* *differe : tableau des differences entre les deux listes.             */
   /*            non affecte si flag_corresp==0.                            */
   /*************************************************************************/
{
   int fichier_com;
   int fichier_dif;
   int i,totall_cor=0,totall_dif=0,accord;
   int i1,i2,nbdmin,flag_tri;
   double x1,x2,y1,y2;
   double x=0.,y=0.,poids,delta2,dist2,*dmin;
   double xmin,xmax,ymin,ymax,bordure;
   struct focas_tableau_entree *data_tab100;
   struct focas_tableau_entree *data_tab200;
   int *deja_pris,*dminindex;
   double val0,val;
   int ibeg,iend,imed;
   int sortie;
   int nombre;

   flag_tri=1;
   if (flag_corresp==11) {flag_corresp=1; flag_tri=0;}
   if (flag_corresp==12) {flag_corresp=2; flag_tri=0;}

   /* --- initialisation des listes d'etoiles et des tableaux ---*/
   data_tab100=NULL;
   data_tab200=NULL;
   deja_pris=NULL;
   dmin=NULL;
   dminindex=NULL;
   nombre=nb1tot+1;
   data_tab100 = new focas_tableau_entree[nombre];
   memset(data_tab100, 0, nombre*sizeof(focas_tableau_entree));

   nombre=nb2tot+1;
   data_tab200 = new focas_tableau_entree[nombre];
   memset(data_tab200, 0, nombre*sizeof(focas_tableau_entree));

   nombre=nb1tot+1;
   deja_pris = new int[nombre];
   memset(deja_pris, 0, nombre*sizeof(int));
  
   nbdmin=(nb1tot>nb2tot)?nb1tot:nb2tot;
   nombre=nbdmin+1;
   dmin = allocDouble(nombre);
   memset(dmin, 0, nombre*sizeof(double));
   dminindex = new int[nombre];
   memset(dminindex, 0, nombre*sizeof(int));
   
   fichier_com=1;
   fichier_dif=1;

   /* --- On remplit les listes d'etoiles ---*/
   for (i=1;i<=nb1tot;i++) {
      data_tab100[i].x=data_tab10[i].x;
      data_tab100[i].y=data_tab10[i].y;
      data_tab100[i].mag=data_tab10[i].mag;
      data_tab100[i].ad=data_tab10[i].ad;
      data_tab100[i].dec=data_tab10[i].dec;
      data_tab100[i].mag_gsc=data_tab10[i].mag_gsc;
      data_tab100[i].type=data_tab10[i].type;
   }
   if (focas_tri_tabx(data_tab100,nb1tot)!=OK) {
      throw ::std::exception("Pb focas_tri_tabx in focas_liste_commune");
   }
   for (i=1;i<=nb2tot;i++) {
      x=data_tab20[i].x;
      y=data_tab20[i].y;
      if (ordre_corresp==1) {
         data_tab200[i].x=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3];
         data_tab200[i].y=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3];
      } else {
         data_tab200[i].x=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3]+transf21[1*nb_coef_a+4]*x*y+transf21[1*nb_coef_a+5]*x*x+transf21[1*nb_coef_a+6]*y*y;
         data_tab200[i].y=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3]+transf21[2*nb_coef_a+4]*x*y+transf21[2*nb_coef_a+5]*x*x+transf21[2*nb_coef_a+6]*y*y;
      }
      data_tab200[i].mag=data_tab20[i].mag;
      data_tab200[i].ad=data_tab20[i].ad;
      data_tab200[i].dec=data_tab20[i].dec;
      data_tab200[i].mag_gsc=data_tab20[i].mag_gsc;
      data_tab200[i].type=data_tab20[i].type;
   }

   if (delta<=0) {delta=1;}
   delta2=delta*delta;
   bordure=3; /* pixels*/
   if (nb1tot==0) {
      ymax=1e9;
      ymin=0;
      xmax=1e9;
      xmin=0;
   } else {
      ymin=1e9;
      ymax=0;
      xmin=1e9;
      xmax=0;
   }
   /* boucle de recherche des bornes de l'image commune */
   for (i1=1;i1<=nb1tot;i1++) {
      x1=data_tab100[i1].x;
      y1=data_tab100[i1].y;
      dmin[i1]=1e9;
      if (x1<xmin) {xmin=x1;}
      if (x1>xmax) {xmax=x1;}
      if (y1<ymin) {ymin=y1;}
      if (y1>ymax) {ymax=y1;}
   }
   xmin+=bordure;
   ymin+=bordure;
   xmax-=bordure;
   ymax-=bordure;
   
   /* nouvel algo rapide */
   for (i2=1;i2<=nb2tot;i2++) {
      x2=data_tab200[i2].x;
      y2=data_tab200[i2].y;
      /* recherche l'indice i1 pour que data_tab200[i2].x */
      /* soit le plus proche de data_tab100[i1].x-delta */
      /* On procede par dichotomie car data_tab100 est trie en x */
      val0=x2-delta;
      ibeg=1;
      iend=nb1tot;
      sortie=0;
      while (sortie==0) {
         imed=(int)floor((iend+ibeg)/2.);
         val=data_tab100[imed].x;
         if (val0>val) {
            ibeg=imed;
         } else {
            iend=imed;
         }
         if ((iend-ibeg)<20) {
            sortie=1;
            break;
         }
      }
      ibeg-=20;
      if (ibeg<1) {ibeg=1;}
      if (ibeg>=nb1tot) {ibeg=nb1tot;}
      dmin[i2]=1e9;
      dminindex[i2]=-1;
      for (i1=ibeg;i1<=nb1tot;i1++) {
         x1=data_tab100[i1].x;
         if (x1>(x2+delta)) {
            break;
         }
         y1=data_tab100[i1].y;
         dist2=(x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
         if ((dist2<dmin[i2])&&(dist2<=delta2)) {
            dmin[i2]=dist2;
            dminindex[i2]=i1;
         }
      }
   }

   /* grande boucle des assignations pbtt */
   totall_cor=0;
   totall_dif=0;
   for (i2=1;i2<=nb2tot;i2++) {
      x2=data_tab200[i2].x;
      y2=data_tab200[i2].y;
      accord=0;
      if (dminindex[i2]>=0) {
         /*for (i1=1;i1<=nb1tot;i1++) {*/
         i1=dminindex[i2];
         x1=data_tab100[i1].x;
         y1=data_tab100[i1].y;
         /*
         dist2=(x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
         if ((dist2==dmin[i2])&&(deja_pris[i1]==(int)(0))&&(dist2<=delta2)) {
         */
         if (deja_pris[i1]==(int)(0)) {
            totall_cor++;accord=1;
            deja_pris[i1]=(int)(1);
            if ((data_tab100[i1].type==-1)&&(flag_corresp==2)) {
               totall_cor--;
            } else {
               /*
               if (totall_cor>nbdmin) {
               totall_cor=nbdmin;
               }
               */
               corresp[totall_cor].indice1=i1;
               corresp[totall_cor].x1=x1;
               corresp[totall_cor].y1=y1;
               corresp[totall_cor].mag1=data_tab100[i1].mag;
               x=data_tab200[i2].x;
               y=data_tab200[i2].y;
               corresp[totall_cor].indice2=i2;
               if (ordre_corresp==1) {
                  corresp[totall_cor].x2=transf12[1*nb_coef_a+1]*x+transf12[1*nb_coef_a+2]*y+transf12[1*nb_coef_a+3];
                  corresp[totall_cor].y2=transf12[2*nb_coef_a+1]*x+transf12[2*nb_coef_a+2]*y+transf12[2*nb_coef_a+3];
               } else {
                  corresp[totall_cor].x2=transf12[1*nb_coef_a+1]*x+transf12[1*nb_coef_a+2]*y+transf12[1*nb_coef_a+3]+transf12[1*nb_coef_a+4]*x*y+transf12[1*nb_coef_a+5]*x*x+transf12[1*nb_coef_a+6]*y*y;
                  corresp[totall_cor].y2=transf12[2*nb_coef_a+1]*x+transf12[2*nb_coef_a+2]*y+transf12[2*nb_coef_a+3]+transf12[2*nb_coef_a+4]*x*y+transf12[2*nb_coef_a+5]*x*x+transf12[2*nb_coef_a+6]*y*y;
               }
               corresp[totall_cor].mag2=data_tab200[i2].mag;
               x-=x1;
               y-=y1;
               poids=1-(x*x+y*y)/(2*delta2);
               corresp[totall_cor].poids=poids;
               corresp[totall_cor].ad=data_tab200[i2].ad;
               corresp[totall_cor].dec=data_tab200[i2].dec;
               corresp[totall_cor].mag_gsc=data_tab200[i2].mag_gsc;
               corresp[totall_cor].type1=data_tab100[i1].type;
               corresp[totall_cor].type2=data_tab200[i2].type;
            }
         }
      }
      if (accord==0) {
         if (flag_corresp>=1) {
            if ((x2>xmin)&&(x2<xmax)&&(y2>ymin)&&(y2<ymax)) {
               totall_dif++;
               /*
               if (totall_dif>nbdmin) {
               totall_dif=nbdmin;
               }
               */
               differe[totall_dif].indice2=i2;
               differe[totall_dif].x1=x2;
               differe[totall_dif].y1=y2;
               differe[totall_dif].mag1=data_tab200[i2].mag;
               if (ordre_corresp==1) {
                  differe[totall_dif].x2=transf12[1*nb_coef_a+1]*x2+transf12[1*nb_coef_a+2]*y2+transf12[1*nb_coef_a+3];
                  differe[totall_dif].y2=transf12[2*nb_coef_a+1]*x2+transf12[2*nb_coef_a+2]*y2+transf12[2*nb_coef_a+3];
               } else {
                  differe[totall_dif].x2=transf12[1*nb_coef_a+1]*x2+transf12[1*nb_coef_a+2]*y2+transf12[1*nb_coef_a+3]+transf12[1*nb_coef_a+4]*x*y+transf12[1*nb_coef_a+5]*x*x+transf12[1*nb_coef_a+6]*y*y;
                  differe[totall_dif].y2=transf12[2*nb_coef_a+1]*x2+transf12[2*nb_coef_a+2]*y2+transf12[2*nb_coef_a+3]+transf12[2*nb_coef_a+4]*x*y+transf12[2*nb_coef_a+5]*x*x+transf12[2*nb_coef_a+6]*y*y;
               }
               differe[totall_dif].mag2=data_tab200[i2].mag;
               differe[totall_dif].ad=data_tab200[i2].ad;
               differe[totall_dif].dec=data_tab200[i2].dec;
               differe[totall_dif].mag_gsc=data_tab200[i2].mag_gsc;
               differe[totall_dif].type1=data_tab200[i2].type;
               differe[totall_dif].type2=data_tab200[i2].type;
            }
         }
      }
   }

   /* --- ecrit les fichiers de correspondance ---*/
   if ((fichier_com==1)&&(flag_corresp>=1)) {
      if (flag_tri==1) {
         /* trie dans l'ordre des x decroissant*/
         for (i=1;i<=totall_cor;i++) {
            poids=corresp[i].x1;
            corresp[i].poids=poids;
         }
         if (focas_tri_corresp(corresp,totall_cor)!=OK) {
            throw ::std::exception("Error focas_tri_corresp 1 in focas_liste_commune");
         }
         /* retrie dans l'ordre des brillances decroissantes (mag croissantes)*/
         for (i=1;i<=totall_cor;i++) {
            poids=corresp[i].mag1;
            corresp[i].poids=poids;
         }
         if (focas_tri_corresp(corresp,totall_cor)!=OK) {
            throw ::std::exception("Error focas_tri_corresp 2 in focas_liste_commune");
         }
      }
   }

   
   *total=totall_cor;
   delete [] data_tab100;
   delete [] data_tab200;
   delete [] deja_pris;
   delete [] dmin;
   delete [] dminindex;

   return(OK);
}

int focas_tri_tabx(struct focas_tableau_entree *data_tab,int nbtot)
/**************************************************************************/
/**************************************************************************/
{
   int n,s,l,r,i,j;
   int k;
   double v,w;
   double *qsort_r=NULL,*qsort_l=NULL;

   qsort_r = NULL; 
   qsort_l = NULL; 
   qsort_r = allocDouble(FOCAS_SORT);
   qsort_l = allocDouble(FOCAS_SORT);

   /*--- trie les valeurs dans l'ordre croissant des x ---*/
   n=nbtot;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
	 i=l; j=r;
	 v=data_tab[(int) (floor((double)((l+r)/2)))].x;
	 do {
	    while (data_tab[i].x<v) {i++;}
	    while (v<data_tab[j].x) {j--;}
	    if (i<=j) {
	       w=data_tab[i].x;       data_tab[i].x=data_tab[j].x;             data_tab[j].x=w;
	       w=data_tab[i].y;       data_tab[i].y=data_tab[j].y;             data_tab[j].y=w;
	       w=data_tab[i].mag;     data_tab[i].mag=data_tab[j].mag;         data_tab[j].mag=w;
	       w=data_tab[i].qualite; data_tab[i].qualite=data_tab[j].qualite; data_tab[j].qualite=w;
	       w=data_tab[i].ad;      data_tab[i].ad=data_tab[j].ad;           data_tab[j].ad=w;
	       w=data_tab[i].dec;     data_tab[i].dec=data_tab[j].dec;         data_tab[j].dec=w;
	       w=data_tab[i].mag_gsc; data_tab[i].mag_gsc=data_tab[j].mag_gsc; data_tab[j].mag_gsc=w;
	       k=data_tab[i].type;    data_tab[i].type=data_tab[j].type;       data_tab[j].type=k;
	       i++; j--;
	    }
	 } while (i<=j);
	 if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
   delete [] qsort_r;
   delete [] qsort_l;

   return(OK);
}

int focas_tri_corresp(::std::valarray<focas_tableau_corresp> &corresp,int nbtot)
/**************************************************************************/
/* trie *corresp dans l'ordre croissant de poids                          */
/**************************************************************************/
{
   int n,s,l,r,i,j;
   int k;
   double v,w;
   double *qsort_r=NULL,*qsort_l=NULL;

   qsort_r = NULL; 
   qsort_l = NULL; 
   qsort_r = allocDouble(FOCAS_SORT);
   qsort_l = allocDouble(FOCAS_SORT);

   /*--- trie les valeurs dans l'ordre croissant des poids ---*/
   n=nbtot;
   s=1; qsort_l[1]=1; qsort_r[1]=n;
   do {
      l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
      s=s-1;
      do {
	 i=l; j=r;
	 v=corresp[(int) (floor((double)((l+r)/2)))].poids;
	 do {
	    while (corresp[i].poids<v) {i++;}
	    while (v<corresp[j].poids) {j--;}
	    if (i<=j) {
	       w=corresp[i].x1;      corresp[i].x1=corresp[j].x1;           corresp[j].x1=w;
	       w=corresp[i].y1;      corresp[i].y1=corresp[j].y1;           corresp[j].y1=w;
	       w=corresp[i].mag1;    corresp[i].mag1=corresp[j].mag1;       corresp[j].mag1=w;
	       w=corresp[i].x2;      corresp[i].x2=corresp[j].x2;           corresp[j].x2=w;
	       w=corresp[i].y2;      corresp[i].y2=corresp[j].y2;           corresp[j].y2=w;
	       w=corresp[i].mag2;    corresp[i].mag2=corresp[j].mag2;       corresp[j].mag2=w;
	       w=corresp[i].poids;   corresp[i].poids=corresp[j].poids;     corresp[j].poids=w;
	       w=corresp[i].ad;      corresp[i].ad=corresp[j].ad;           corresp[j].ad=w;
	       w=corresp[i].dec;     corresp[i].dec=corresp[j].dec;         corresp[j].dec=w;
	       w=corresp[i].mag_gsc; corresp[i].mag_gsc=corresp[j].mag_gsc; corresp[j].mag_gsc=w;
	       k=corresp[i].type1;   corresp[i].type1=corresp[j].type1;     corresp[j].type1=k;
	       k=corresp[i].type2;   corresp[i].type2=corresp[j].type2;     corresp[j].type2=k;
	       i++; j--;
	    }
	 } while (i<=j);
	 if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
      } while (l<r);
   } while (s!=0) ;
   delete [] qsort_r;
   delete [] qsort_l;
   return(OK);
}


int tt_util_qsort_double(double *x,int kdeb,int n,int *index)
/***************************************************************************/
/* Quick sort pour un tableau de double                                    */
/***************************************************************************/
/* x est le tableau qui commence a l'indice 1                              */
/* kdeb la valeur de l'indice a partir duquel il faut trier                */
/* n est le nombre d'elements                                              */
/* index est le tableau des indices une fois le tri effectue (=NULL si on  */
/*  ne veut pas l'utiliser).                                               */
/***************************************************************************/
{
   double qsort_r[TT_QSORT],qsort_l[TT_QSORT];
   int s,l,r,i,j,kfin;
   double v,w;
   int wi;
   int kt1,kt2,kp;
   double m,a;
   int mi,ai;
   kfin=n+kdeb-1;
   /* --- retour immediat si n==1 ---*/
   if (n==1) { return(OK_DLL); }
   if (index!=NULL) {
      /*--- effectue un tri simple si n<=15 ---*/
      if (n<=15) {
         for (kt1=kdeb;kt1<kfin;kt1++) {
            m=x[kt1];
            mi=index[kt1];
            kp=kt1;
            for (kt2=kt1+1;kt2<=kfin;kt2++) {
               if (x[kt2]<m) {
                  m=x[kt2];
                  mi=index[kt2];
                  kp=kt2;
               }
            }
            a=x[kt1];x[kt1]=m;x[kp]=a;
            ai=index[kt1];index[kt1]=mi;index[kp]=ai;
         }
         return(OK_DLL);
      }
      /*--- trie le tableau dans l'ordre croissant avec quick sort ---*/
      s=kdeb; qsort_l[tt_util_qsort_verif(kdeb)]=kdeb; qsort_r[tt_util_qsort_verif(kdeb)]=kfin;
      do {
         l=(int)(qsort_l[tt_util_qsort_verif(s)]); r=(int)(qsort_r[tt_util_qsort_verif(s)]);
         s=s-1;
         do {
            i=l; j=r;
            v=x[(int) (floor(((double)l+r)/(double)2))];
            do {
               while (x[i]<v) {i++;}
               while (v<x[j]) {j--;}
               if (i<=j) {
                  w=x[i];x[i]=x[j];x[j]=w;
                  wi=index[i];index[i]=index[j];index[j]=wi;
                  i++; j--;
               }
            } while (i<=j);
            if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[tt_util_qsort_verif(s)]=i ; qsort_r[tt_util_qsort_verif(s)]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[tt_util_qsort_verif(s)]=l ; qsort_r[tt_util_qsort_verif(s)]=j;} l=i; }
         } while (l<r);
      } while (s!=(kdeb-1)) ;
      return(OK_DLL);
   } else {
      /*--- effectue un tri simple si n<=15 ---*/
      if (n<=15) {
         for (kt1=kdeb;kt1<kfin;kt1++) {
            m=x[kt1];
            kp=kt1;
            for (kt2=kt1+1;kt2<=kfin;kt2++) {
               if (x[kt2]<m) {
                  m=x[kt2];
                  kp=kt2;
               }
            }
            a=x[kt1];x[kt1]=m;x[kp]=a;
         }
         return(OK_DLL);
      }
      /*--- trie le tableau dans l'ordre croissant avec quick sort ---*/
      s=kdeb; qsort_l[tt_util_qsort_verif(kdeb)]=kdeb; qsort_r[tt_util_qsort_verif(kdeb)]=kfin;
      do {
         l=(int)(qsort_l[tt_util_qsort_verif(s)]); r=(int)(qsort_r[tt_util_qsort_verif(s)]);
         s=s-1;
         do {
            i=l; j=r;
            v=x[(int) (floor(((double)l+r)/(double)2))];
            do {
               while (x[i]<v  && i < n) {i++;}
               while (v<x[j]  && j >= 0) {j--;}
               if (i<=j) {
                  w=x[i];x[i]=x[j];x[j]=w;
                  i++; j--;
               }
            } while (i<=j);
            if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[tt_util_qsort_verif(s)]=i ; qsort_r[tt_util_qsort_verif(s)]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[tt_util_qsort_verif(s)]=l ; qsort_r[tt_util_qsort_verif(s)]=j;} l=i; }
         } while (l<r);
      } while (s!=(kdeb-1)) ;
      return(OK_DLL);
   }
}

int tt_util_qsort_verif(int index)
/***************************************************************************/
/* Verifie que l'indice ne depasse pas le seuil maximal pour qsort_*       */
/***************************************************************************/
{
   static int indexout;
   if (index>=(int)(TT_QSORT)) {
      //tt_errlog(TT_WAR_INDEX_OUTMAX,"index out of high limit in tt_util_qsort_verif");
      index=(int)(TT_QSORT-1);
   }
   if (index<0) {
      //tt_errlog(TT_WAR_INDEX_OUTMIN,"index out of low limit in tt_util_qsort_verif");
      index=0;
   }
   indexout=index;
   return indexout;
}



double * allocDouble(int size) {
   double * pointeur = new double[size]; 
   if (pointeur == NULL ) {
      ::std::exception("error alloc double ");
   }
   memset(pointeur,0,size*sizeof(double));
   return pointeur;
}   

