/*----------------------------------------------*/
/*                Classe Vecteur                */
/*              liste des fonctions             */
/*----------------------------------------------*/


// inclusion fichiers d'en-tete locaux



// Liste des fonctions de la classe Vecteur

class Vecteur {

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
    unsigned short tampon_audela; // vaut 0 si non lie a un tampon AudeLA, sinon entier positif non nul.
    unsigned long naxis1;

 public:
    // fonctions de base
    Vecteur(void);
    ~Vecteur(void);
    unsigned char CreeVectVierge(unsigned char data_type, unsigned long val_naxis1);
    unsigned char CopieDe(Vecteur vectdyn);
    unsigned char CopieVers(Vecteur vectdyn);
    unsigned long Naxis1() {return naxis1;}
    unsigned char AdresseType() {return adresse_type;}

    // fonctions lecture element
    long double Lecture(unsigned long coord1);
    bool LectureBool(unsigned long coord1);
    char LectureChar(unsigned long coord1);
    unsigned char LectureUnsignedChar(unsigned long coord1);
    short LectureShort(unsigned long coord1);
    unsigned short LectureUnsignedShort(unsigned long coord1);
    long LectureLong(unsigned long coord1);
    unsigned long LectureUnsignedLong(unsigned long coord1);
    float LectureFloat(unsigned long coord1);
    double LectureDouble(unsigned long coord1);
    long double LectureLongDouble(unsigned long coord1);

    // fonctions ecriture pixel
    unsigned char EcritureBool(unsigned long coord1, bool valeur);
    unsigned char EcritureChar(unsigned long coord1, char valeur);
    unsigned char EcritureUnsignedChar(unsigned long coord1, unsigned char valeur);
    unsigned char EcritureShort(unsigned long coord1, short valeur);
    unsigned char EcritureUnsignedShort(unsigned long coord1, unsigned short valeur);
    unsigned char EcritureLong(unsigned long coord1, long valeur);
    unsigned char EcritureUnsignedLong(unsigned long coord1, unsigned long valeur);
    unsigned char EcritureFloat(unsigned long coord1, float valeur);
    unsigned char EcritureDouble(unsigned long coord1, double valeur);
    unsigned char EcritureLongDouble(unsigned long coord1, long double valeur);

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
    unsigned char Soustrait(Vecteur* vect2);
    unsigned char Ajoute(Vecteur* vect2);
    unsigned char AjouteFacteur(Vecteur* vect2, double facteur);
    unsigned char Multiplie(Vecteur* vect2);
    unsigned char MultiplieAjoute(Vecteur* vect1, Vecteur* vect2);
    unsigned char Divise(Vecteur* vect2);
    unsigned char Carre();
    unsigned char CarreAjoute(Vecteur* vect1);
    unsigned char RacineCarree();
    unsigned char Marche();
    unsigned char Dxx(Vecteur* vect1);
    unsigned char Dyy(Vecteur* vect1);
    unsigned char Convolue(Vecteur* filtre);

    // fonctions maximum
    bool MaxBool();
    char MaxChar();
    unsigned char MaxUnsignedChar();
    short MaxShort();
    unsigned short MaxUnsignedShort();
    long MaxLong();
    unsigned long MaxUnsignedLong();
    float MaxFloat();
    double MaxDouble();
    long double MaxLongDouble();

    // fonctions maximumX
    unsigned char MaxXBool(bool* valeur, unsigned long* x_max);
    unsigned char MaxXChar(char* valeur, unsigned long* x_max);
    unsigned char MaxXUnsignedChar(unsigned char* valeur, unsigned long* x_max);
    unsigned char MaxXShort(short* valeur, unsigned long* x_max);
    unsigned char MaxXUnsignedShort(unsigned short* valeur, unsigned long* x_max);
    unsigned char MaxXLong(long* valeur, unsigned long* x_max);
    unsigned char MaxXUnsignedLong(unsigned long* valeur, unsigned long* x_max);
    unsigned char MaxXFloat(float* valeur, unsigned long* x_max);
    unsigned char MaxXDouble(double* valeur, unsigned long* x_max);
    unsigned char MaxXLongDouble(long double* valeur, unsigned long* x_max);

};
