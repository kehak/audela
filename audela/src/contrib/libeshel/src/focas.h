

#ifndef _INC_LIBESHEL_FOCAS
#define _INC_LIBESHEL_FOCAS

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
               double epsilon, double delta, double seuil_poids);

#endif