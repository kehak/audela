#include <string.h>
#include <sstream>
#include "libaudela.h"  // class Ierror
#include "erreur.h"

namespace LibJM {
    Erreur::Erreur( const char * message )
    {
        std::ostringstream oss;
        oss << "Erreur " << message;
        this->msg = oss.str();
        this->writable = new char[1024];
    }

    Erreur::~Erreur() throw()
    {
        delete[] writable;
    }

    const char * Erreur::message() const throw()
    {
        return this->msg.c_str();
    }

    const char * Erreur::gets() const throw()
    {
        std::copy(this->msg.begin(), this->msg.end(), writable);
        writable[this->msg.size()] = '\0';
        return writable;
    }
} // Namespace LibJM
