/*----------------------------------------------*/
/*                 Classe Image                 */
/*              liste des fonctions             */
/*----------------------------------------------*/


// inclusion fichiers d'en-tête locaux

#include "libbm.h"
#include "Vecteur.h"


// Liste des fonctions de la classe Image

class Image {

  private:
    unsigned char adresse_type; // vaut 0 si non affecte
    bool* adresse_bool; // correspond a adresse_type = 1
    char* adresse_char; // correspond a adresse_type = 2
    unsigned char* adresse_unsigned_char; // correspond a adresse_type = 3
    short* adresse_short; // correspond a adresse_type = 4
    unsigned short* adresse_unsigned_short; // correspond a adresse_type = 5
    long* adresse_long; // correspond a adresse_type = 6
    unsigned long* adresse_unsigned_long; // correspond a adresse_type = 7
    float* adresse_float; // correspond a adresse_type = 8
    double* adresse_double; // correspond a adresse_type = 9
    long double* adresse_long_double; // correspond a adresse_type = 10
    // unsigned short tampon_audela; // vaut 0 si non lie a un tampon AudeLA, sinon entier positif non nul.
    unsigned long naxis1;
    unsigned long naxis2;

 public:
    // fonctions de base
    Image(void);
    ~Image(void);
    // unsigned char AttribueTamponAudela(Tcl_Interp *interp, unsigned short numbuf);
    unsigned char AudelaAImage(Tcl_Interp *interp, unsigned short numbuf);
    unsigned char ImageAAudela(Tcl_Interp *interp, unsigned short numbuf);
    unsigned char CreeTamponVierge(unsigned char data_type, unsigned long val_naxis1, unsigned long val_naxis2);
    unsigned char CopieDe(Image* image);
    unsigned char CopieVers(Image* image);
    unsigned long Naxis1() {return naxis1;}
    unsigned long Naxis2() {return naxis2;}
    unsigned char AdresseType() {return adresse_type;}


    // fonctions lecture pixel
    long double Lecture(unsigned long coord1, unsigned long coord2, bool* result);
    bool LectureBool(unsigned long coord1, unsigned long coord2, bool* result);
    char LectureChar(unsigned long coord1, unsigned long coord2, bool* result);
    unsigned char LectureUnsignedChar(unsigned long coord1, unsigned long coord2, bool* result);
    short LectureShort(unsigned long coord1, unsigned long coord2, bool* result);
    unsigned short LectureUnsignedShort(unsigned long coord1, unsigned long coord2, bool* result);
    long LectureLong(unsigned long coord1, unsigned long coord2, bool* result);
    unsigned long LectureUnsignedLong(unsigned long coord1, unsigned long coord2, bool* result);
    float LectureFloat(unsigned long coord1, unsigned long coord2, bool* result);
    double LectureDouble(unsigned long coord1, unsigned long coord2, bool* result);
    long double LectureLongDouble(unsigned long coord1, unsigned long coord2, bool* result);

    // fonctions ecriture pixel
    unsigned char EcritureBool(unsigned long coord1, unsigned long coord2, bool valeur);
    unsigned char EcritureChar(unsigned long coord1, unsigned long coord2, char valeur);
    unsigned char EcritureUnsignedChar(unsigned long coord1, unsigned long coord2, unsigned char valeur);
    unsigned char EcritureShort(unsigned long coord1, unsigned long coord2, short valeur);
    unsigned char EcritureUnsignedShort(unsigned long coord1, unsigned long coord2, unsigned short valeur);
    unsigned char EcritureLong(unsigned long coord1, unsigned long coord2, long valeur);
    unsigned char EcritureUnsignedLong(unsigned long coord1, unsigned long coord2, unsigned long valeur);
    unsigned char EcritureFloat(unsigned long coord1, unsigned long coord2, float valeur);
    unsigned char EcritureDouble(unsigned long coord1, unsigned long coord2, double valeur);
    unsigned char EcritureLongDouble(unsigned long coord1, unsigned long coord2, long double valeur);

    // fonctions de conversion
    unsigned char ConvertitBool();
    unsigned char ConvertitChar();
    unsigned char ConvertitUnsignedChar();
    unsigned char ConvertitShort();
    unsigned char ConvertitUnsignedShort();
    unsigned char ConvertitLong();
    unsigned char ConvertitUnsignedLong();
    unsigned char ConvertitFloat();
    unsigned char ConvertitDouble();
    unsigned char ConvertitLongDouble();

    // fonctions de traitement
    int hard2visu(double seuil_haut, double seuil_bas, Vecteur* fonction_transfert);
    unsigned char Soustrait(Image* image2);
    unsigned char Ajoute(Image* image2);
    unsigned char AjouteFacteur(Image* image2, double facteur);
    unsigned char Abs();
    unsigned char Multiplie(Image* image2);
    unsigned char MultiplieAjoute(Image* image1, Image* image2);
    unsigned char Divise(Image* image2);
    unsigned char Carre();
    unsigned char CarreAjoute(Image* image1);
    unsigned char RacineCarree();
    unsigned char Marche();
    unsigned char Dxx(Image* image1);
    unsigned char Dyy(Image* image1);
    unsigned char Convolue(Image* filtre);
    unsigned char Disque();

    // fonctions maximum
    bool MaxBool(bool* retour);
    char MaxChar(bool* retour);
    unsigned char MaxUnsignedChar(bool* retour);
    short MaxShort(bool* retour);
    unsigned short MaxUnsignedShort(bool* retour);
    long MaxLong(bool* retour);
    unsigned long MaxUnsignedLong(bool* retour);
    float MaxFloat(bool* retour);
    double MaxDouble(bool* retour);
    long double MaxLongDouble(bool* retour);

    // fonctions maximumXY
    unsigned char MaxXYBool(bool* valeur, unsigned long* x_max, unsigned long* y_max);
    unsigned char MaxXYChar(char* valeur, unsigned long* x_max, unsigned long* y_max);
    unsigned char MaxXYUnsignedChar(unsigned char* valeur, unsigned long* x_max, unsigned long* y_max);
    unsigned char MaxXYShort(short* valeur, unsigned long* x_max, unsigned long* y_max);
    unsigned char MaxXYUnsignedShort(unsigned short* valeur, unsigned long* x_max, unsigned long* y_max);
    unsigned char MaxXYLong(long* valeur, unsigned long* x_max, unsigned long* y_max);
    unsigned char MaxXYUnsignedLong(unsigned long* valeur, unsigned long* x_max, unsigned long* y_max);
    unsigned char MaxXYFloat(float* valeur, unsigned long* x_max, unsigned long* y_max);
    unsigned char MaxXYDouble(double* valeur, unsigned long* x_max, unsigned long* y_max);
    unsigned char MaxXYLongDouble(long double* valeur, unsigned long* x_max, unsigned long* y_max);

};
