#ifndef __LIBJM_ERREUR_H__
#define __LIBJM_ERREUR_H__

namespace LibJM {

class Erreur : public IError
{
public:
    Erreur( const char * message );
    ~Erreur() throw();
    const char * message() const throw();
    const char * gets(void) const throw();
private:
    std::string msg;
    char* writable;
};

} // Namespace LibJM

#endif // __LIBJM_ERREUR_H__
