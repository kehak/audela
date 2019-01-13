/***
 * @file : fourier_services.cpp
 * @brief : Méthodes de l'objet Fourier : gestion des objets
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: fourier_services.cpp,v 1.6 2010-07-22 18:54:35 jacquesmichelet Exp $
 *
 * <pre>
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
 * </pre>
 */
#include <iostream>
#include <fstream>
#include <sysexp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <gsl/gsl_fft_complex.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_fft.h>

#include "libaudela.h"
#include "libtt.h"
//#include "cbuffer.h"
//#include "cpixels.h"
//#include "cpixelsgray.h"
//#include "cfile.h"
#include "libjm.h"
#include "fourier.h"

namespace LibJM {
Fourier * Fourier::_unique_instance = 0;
int Fourier::_log_verbosity = Fourier::Notice_Level;
std::ofstream Fourier::log_stream;
std::string Fourier::fourier_log_file_name("libjm_fourier.log");

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Fourier()
{
    std::string nom_fichier_log;
    if ( LibJM::Generique::repertoire_log.size() > 0 )
    {
        nom_fichier_log = LibJM::Generique::repertoire_log;
#if defined(WIN32)
        nom_fichier_log = nom_fichier_log + "\\";
#else
        nom_fichier_log = nom_fichier_log + "/";
#endif
    }
    nom_fichier_log = nom_fichier_log + fourier_log_file_name;

    log_stream.open( nom_fichier_log.c_str(), std::ios::trunc );
    if( !log_stream )
    {
        std::cerr << "Error opening the log file " << nom_fichier_log << std::endl;
    }
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::~Fourier()
{
    log_stream.close();
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier * Fourier::instance ()
{
    if (_unique_instance == 0)
        _unique_instance = new Fourier();
    return _unique_instance;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::niveau_traces( int niveau )
{
    _log_verbosity = niveau;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Type Fourier::analyse_dft_type( const char * type ) {
    if ( strncmp( type, "REAL" , 4 ) == 0 )
        return Fourier::REAL;
    else if ( strncmp( type, "IMAG", 4 ) == 0 )
        return Fourier::IMAG;
    else if ( strncmp( type, "SPECTRUM", 8 ) == 0 )
        return Fourier::SPECTRUM;
    else if ( strncmp( type, "PHASE", 5 ) == 0 )
        return Fourier::PHASE;
    else return Fourier::NO_TYPE;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Ordre Fourier::analyse_dft_ordre( const char * type ) {
    if ( strncmp( type, "CENTERED", 8 ) == 0 )
        return Fourier::CENTERED;
    else if ( strncmp( type, "REGULAR", 7 ) == 0 )
        return Fourier::REGULAR;
    else return Fourier::NO_ORDER;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
int Fourier::Parametres::compteur = 0;
/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Parametres::Parametres() :
        largeur(0),
        hauteur(0),
        norm(1.0),
        talon(0.0),
        ordre(Fourier::NO_ORDER),
        type(Fourier::NO_TYPE),
        _pixels(0),
        _buffer(0)
{
    _numero = ++compteur;
    fourier_info3( "constructeur de Fourier::Parametre no " << _numero << " _pixels = 0");
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::Parametres::copie( Fourier::Parametres & origine )
{
    _buffer = origine.buffer();
    //if ( _buffer )
    //    _buffer->Reference();
    largeur = origine.largeur;
    hauteur = origine.hauteur;
    norm = origine.norm;
    talon = origine.talon;
    ordre = origine.ordre;
    type = origine.type;
    _pixels =  new TableauPixels( largeur, hauteur );
    memcpy( _pixels->pointeur(), origine.pixels()->pointeur(), origine.pixels()->taille() );
    fourier_info3( "copie de Fourier::Parametre no " << origine._numero << " vers " << _numero );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Parametres::Parametres( int l, int h, Fourier::Ordre o, Fourier::Type t ) :
    largeur(l),
    hauteur(h),
    norm(1.0),
    talon(0.0),
    ordre(o),
    type(t),
    _buffer(0)
{
    _pixels = new TableauPixels( largeur, hauteur );
    _numero = ++compteur;
    fourier_info3( "constructeur de Fourier::Parametre no " << _numero << " _pixels = " << _pixels << " zone = " << _pixels->pointeur() << " taille = " << _pixels->taille() );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::Parametres::init( int l, int h, Fourier::Ordre o, Fourier::Type t )
{
    largeur = l;
    hauteur = h;
    norm = 1.0;
    talon = 0.0;
    ordre = o;
    type = t;
    if ( _pixels )
        delete _pixels ;
    _pixels = new TableauPixels( largeur, hauteur );
    fourier_info3( "init de Fourier::Parametre no " << _numero << " _pixels = " << _pixels << " zone = " << _pixels->pointeur() << " taille = " << _pixels->taille() );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Parametres::~Parametres() {
    fourier_info3( "destructeur de Fourier::Parametre no " << _numero );

    if ( _buffer )
    {
        //_keywords->Unreference();
        if ( _buffer->getReference() == 0 )
        {
            fourier_debug( "Fourier::Parametre no " << _numero << " : destruction de keywords = " << _buffer );
            ILibaudela::deleteBuffer(  _buffer );
            _buffer = 0;
        }
        _buffer->unreference();
    }

    if ( _pixels )
    {
        fourier_debug( "Fourier::Parametre no " << _numero << " : libération de _pixels = " << _pixels << " zone = " << _pixels->pointeur() << " taille = " << _pixels->taille() );
        delete _pixels;
    }
};

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::Parametres::pixels( TableauPixels * tp )
{
    _pixels = tp;
    fourier_info3( "Fourier::Parametre no " << _numero << " : affectation de _pixels = " << _pixels << " zone = " << _pixels->pointeur() << " taille = " << _pixels->taille() );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::Parametres::buffer ( IBuffer * k )
{
    if (_buffer ) {
        fourier_debug( "Fourier::Parametre no " << _numero << " : suppression de la ref sur keywords = " << _buffer << " ref = " << _buffer->GetReference() );
        if ( _buffer->getReference() == 0 )
           ILibaudela::deleteBuffer( _buffer);
        _buffer->unreference();
    }
    _buffer = k;
    if ( _buffer )
        _buffer->reference();
    fourier_info3( "Fourier::Parametre no " << _numero << " : keywords = " << _buffer << " ref = " << _buffer->getReference() );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::TableauPixels::TableauPixels ( unsigned int largeur, unsigned int hauteur )
{
    _taille = largeur * hauteur * sizeof( TYPE_PIXELS );
    _pointeur = (TYPE_PIXELS *) calloc ( largeur * hauteur, sizeof( TYPE_PIXELS ) );
    fourier_debug( "Fourier::TableauPixels allocation de " << _taille << " octets pointés par " << _pointeur );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::TableauPixels::~TableauPixels ( )
{
    if ( _pointeur )
    {
        fourier_debug( "Fourier::TableauPixels libération d'une zone de " << _taille << " octets pointée par " << _pointeur );
        free( _pointeur );
        _pointeur = 0;
        _taille = 0;
    }
    else
    {
        fourier_debug( "Fourier::TableauPixels ANOMALIE taille = " << _taille << " _pointeur = " << _pointeur );
    }
}

}

