/***
 * @file : fourier_calculs.cpp
 * @brief : Méthodes de l'objet Fourier : calculs mathématiques
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: fourier_calculs.cpp,v 1.4 2010-07-22 18:54:35 jacquesmichelet Exp $
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

#include <libaudela.h>
#include "libjm.h"
#include "fourier.h"

namespace LibJM {

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
double * Fourier::tfd_2d( double * data , int largeur, int hauteur, gsl_fft_direction direction ) 
{

    gsl_fft_complex_wavetable *wavetable;
    gsl_fft_complex_workspace *workspace;

    /* DFT sur chaque ligne */

    wavetable = gsl_fft_complex_wavetable_alloc( largeur );
    workspace = gsl_fft_complex_workspace_alloc( largeur );

    for (int ligne = 0; ligne < hauteur ; ligne++) 
    {
        gsl_fft_complex_transform( &data[2 * ligne * largeur], 1, largeur, wavetable, workspace, direction );
    }

    gsl_fft_complex_wavetable_free( wavetable );
    gsl_fft_complex_workspace_free ( workspace );

    /* DFT sur chaque colonne */

    wavetable = gsl_fft_complex_wavetable_alloc( hauteur );
    workspace = gsl_fft_complex_workspace_alloc( hauteur );

    for (int colonne = 0; colonne < largeur; colonne++ ) 
    {
        gsl_fft_complex_transform( &data[2 * colonne], largeur, hauteur, wavetable, workspace, direction );
    }

    gsl_fft_complex_wavetable_free( wavetable );
    gsl_fft_complex_workspace_free ( workspace );

    return data;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
int Fourier::tfd_2d_directe_simple( Fourier::Parametres * param_src, Fourier::Parametres * param_1, Fourier::Parametres * param_2 ) 
{

    fourier_info2( "param_src=" << param_src << " param_1=" << param_1 << " param_2=" << param_2 );
    int largeur = param_1->largeur;
    int hauteur = param_1->hauteur;
    int surface = largeur * hauteur;
    int ligne;

    double * data = (double *) malloc( 2 * surface * sizeof(double) );

    TYPE_PIXELS * tab_src = param_src->pixels()->pointeur();

    /* Lecture et rangement des valeurs */
    fourier_debug( "image d'entree" );
    for ( ligne = 0; ligne < hauteur ; ligne++ ) 
    {
        fourier_debug2( "l=" << ligne );
        for ( int colonne = 0; colonne < largeur; colonne++ ) 
        {
            int i = ligne * largeur + colonne;
            REAL( data, i ) = tab_src[ i ];
            IMAG( data, i ) = 0.0;
            fourier_debug2( " c=" << colonne << " " << REAL( data, i ) << " " << IMAG( data, i) << "/" );
        }
        fourier_debug2( "\n" );
    }

    data = tfd_2d( data, largeur, hauteur, gsl_fft_forward );

    TYPE_PIXELS * ptr1 = param_1->pixels()->pointeur();
    TYPE_PIXELS * ptr2 = param_2->pixels()->pointeur();

    fourier_debug( "image de sortie" );
    for ( ligne = 0; ligne < hauteur; ligne++ ) 
    {
        fourier_debug2( "l=" << ligne );
        for ( int colonne = 0; colonne < largeur; colonne++ ) 
        {
            ptr1[ ligne * largeur + colonne ] = (TYPE_PIXELS)REAL( data, ( ligne * largeur + colonne ) );
            ptr2[ ligne * largeur + colonne ] = (TYPE_PIXELS)IMAG( data, ( ligne * largeur + colonne ) );
            fourier_debug2( " c=" << colonne << " " << ptr1[ ligne * largeur + colonne ] << " " << ptr2[ ligne * largeur + colonne ] << "/" );
        }
        fourier_debug2( "\n" );
    }

    free( data );
    return 0;
}


/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
int Fourier::tfd_2d_directe_complete( Fourier::Parametres * param_src, Fourier::Parametres * param_1, Fourier::Parametres * param_2, int val_max ) 
{
    fourier_info2( "param_src=" << param_src << " param_1=" << param_1 << " param_2=" << param_2 );

    int largeur = param_1->largeur;
    int hauteur = param_1->hauteur;
    int surface = largeur * hauteur;
    float ponderation = sqrt( (float)surface );

    Fourier::format format = NO_FORMAT;
    if ( ( param_1->type == Fourier::REAL ) && ( param_2->type == Fourier::IMAG ) )
        format = Fourier::CARTESIAN;
    if ( ( param_2->type == Fourier::REAL ) && ( param_1->type == Fourier::IMAG ) )
        format = Fourier::CARTESIAN;
    if ( ( param_1->type == Fourier::SPECTRUM ) && ( param_2->type == Fourier::PHASE ) )
        format = Fourier::POLAR;
    if ( ( param_2->type == Fourier::SPECTRUM ) && ( param_1->type == Fourier::PHASE ) )
        format = Fourier::POLAR;
    if ( format == NO_FORMAT )
        return -1;

    double * data = (double *) malloc( 2 * surface * sizeof(double) );

    fourier_info2( "entree dft directe" );

    TYPE_PIXELS * tab_src = param_src->pixels()->pointeur();

    /* Lecture et rangement des valeurs */
    for ( int ligne = 0; ligne < hauteur ; ligne++ ) 
    {
        for ( int colonne = 0; colonne < largeur; colonne++ ) 
        {
            int i = ligne * largeur + colonne;
            REAL( data, i ) = tab_src[ i ];
            IMAG( data, i ) = 0.0;
        }
    }

    data = tfd_2d( data, largeur, hauteur, gsl_fft_forward );

    float dest_max = 0.0;
    float dest_min = (float)surface * (float)val_max;

    TYPE_PIXELS * ptr1 = param_1->pixels()->pointeur();
    TYPE_PIXELS * ptr2 = param_2->pixels()->pointeur();

    if ( format == Fourier::POLAR ) 
    {
        for ( int pixel = 0; pixel < surface; pixel++ ) 
        {
            if ( ( module( data, pixel ) / ponderation ) > dest_max )
                dest_max = (float)module( data, pixel ) / ponderation;
        }
        param_1->norm = (float)val_max / dest_max;
        param_1->talon = 0.0;
        param_2->norm = (float)( val_max / 2.0 / M_PI );
        param_2->talon = (float)M_PI;

        if ( param_1->ordre == Fourier::CENTERED ) 
        {
            fourier_info2( "POLAR CENTERED norm_1=" << param_1->norm << " norm_2=" << param_2->norm );
            for ( int ls = 0; ls < hauteur; ls++ ) 
            {
                fourier_debug( "l=" << ls );
                int ld = ( ls + hauteur / 2 ) % hauteur;
                for ( int cs = 0; cs < largeur; cs++ ) 
                {
                    int cd = ( cs + largeur / 2 ) % largeur;
                    ptr1[ ld * largeur + cd ] = (TYPE_PIXELS)module( data, (ls * largeur + cs) ) * param_1->norm  / ponderation;
                    ptr2[ ld * largeur + cd ] = (TYPE_PIXELS)( argument( data, (ls * largeur + cs) ) + param_2->talon ) * param_2->norm ;
                    fourier_debug( ptr1[ ld * largeur + cd ] << " " <<  ptr2[ ld * largeur + cd ] << "/");
                }
                fourier_debug("\n");
            }
        }
        else 
        { // ordre == REGULAR
            fourier_info2( "POLAR REGULAR norm_1=" << param_1->norm << " norm_2=" << param_2->norm );
            for ( int l = 0; l < hauteur; l++ ) 
            {
                for ( int c = 0; c < largeur; c++ ) 
                {
                    ptr1[ l * largeur + c ] = (TYPE_PIXELS)module( data, (l * largeur + c) ) * param_1->norm / ponderation;
                    ptr2[ l * largeur + c ] = (TYPE_PIXELS)( argument( data, (l * largeur + c) ) + param_2->talon ) * param_2->norm ;
                }
            }
        }
        fourier_info2( "sortie dft directe (spectre+phase)" );
    }
    else 
    { // format == CARTESIAN
        for ( int pixel = 0; pixel < surface; pixel++ ) 
        {
            if ( REAL( data, pixel ) / ponderation > dest_max )
                dest_max = (float)REAL( data, pixel ) / ponderation;
            if ( IMAG( data, pixel ) / ponderation > dest_max )
                dest_max = (float)IMAG( data, pixel ) / ponderation;
            if ( REAL( data, pixel ) / ponderation < dest_min )
                dest_min = (float)REAL( data, pixel ) / ponderation;
            if ( IMAG( data, pixel ) / ponderation < dest_min )
                dest_min = (float)IMAG( data, pixel ) / ponderation;
        }
        param_1->norm = (float)val_max / ( dest_max - dest_min );
        param_1->talon = - dest_min;
        param_2->norm = (float)val_max / ( dest_max - dest_min );
        param_2->talon = - dest_min;
        fourier_info2( "CARTESIAN val_max=" << val_max << " max=" << dest_max << " min=" << dest_min );
        fourier_info2( "CARTESIAN norm_1=" << param_1->norm << " norm_2=" << param_2->norm );
        fourier_info2( "CARTESIAN talon_1=" << param_1->talon << " talon_2=" << param_2->talon );

        if ( param_1->ordre == Fourier::CENTERED ) 
        {
            for ( int ls = 0; ls < hauteur; ls++ ) 
            {
                int ld = ( ls + hauteur / 2 ) % hauteur;
                for ( int cs = 0; cs < largeur; cs++ ) 
                {
                    int cd = ( cs + largeur / 2 ) % largeur;
                    ptr1[ ld * largeur + cd ] = (TYPE_PIXELS)( ( REAL( data, (ls * largeur + cs) )  / ponderation + param_1->talon ) * param_1->norm + 0.5 );
                    ptr2[ ld * largeur + cd ] = (TYPE_PIXELS)( ( IMAG( data, (ls * largeur + cs) )  / ponderation + param_2->talon ) * param_2->norm + 0.5 );
                }
            }
        }
        else 
        { // ordre == REGULAR
            for ( int l = 0; l < hauteur; l++ ) 
            {
                for ( int c = 0; c < largeur; c++ ) 
                {
                    ptr1[ l * largeur + c ] = (TYPE_PIXELS)( ( REAL( data, (l * largeur + c) ) / ponderation + param_1->talon ) * param_1->norm + 0.5 );
                    ptr2[ l * largeur + c ] = (TYPE_PIXELS)( ( IMAG( data, (l * largeur + c) ) / ponderation + param_2->talon ) * param_2->norm + 0.5 );
                }
            }
        }
        fourier_info2( "sortie dft directe(reel+imag)" );
    }
    free( data );
    return 0;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
int Fourier::tfd_2d_inverse_simple( Fourier::Parametres * s1, Fourier::Parametres *s2, Fourier::Parametres * d )
{
    fourier_info2( "s1=" << s1->numero() << " (" << s1 << ") s2=" << s2->numero() << " (" << s2 << ") d=" << d->numero() << " (" << d << ")" );

    /* Contrairement à la TFD directe, il y a une pondération dans ce sens */

    /* A ce niveau, les largeur, hauteur, ordre et type sont supposés cohérents */
    int largeur = s1->largeur;
    int hauteur = s1->hauteur;
    int surface = largeur * hauteur;
    double ponderation = (double)surface;
    int ligne;

    double * data = (double *) malloc( 2 * surface * sizeof(double) );

    TYPE_PIXELS * s1_ptr = s1->pixels()->pointeur();
    TYPE_PIXELS * s2_ptr = s2->pixels()->pointeur();

    fourier_debug( "image d'entrée" );
    for (  ligne = 0; ligne < hauteur ; ligne++ )
    {
        fourier_debug2( "l=" << ligne );
        for ( int colonne = 0; colonne < largeur; colonne++ )
        {
            int i = ligne * largeur + colonne;
            REAL( data, i ) = s1_ptr[ i ];
            IMAG( data, i ) = s2_ptr[ i ];
            fourier_debug2( " c=" << colonne << " " << REAL( data, i ) << " " << IMAG( data, i) << "/" );
        }
        fourier_debug2( "\n" );
    }

    data = tfd_2d( data, largeur, hauteur, gsl_fft_backward );

    TYPE_PIXELS * d_ptr = d->pixels()->pointeur();
    fourier_debug( "image de sortie" );
    for ( ligne = 0; ligne < hauteur ; ligne++ )
    {
        fourier_debug2( "l=" << ligne );
        for ( int colonne = 0; colonne < largeur; colonne++ )
        {
            int i = ligne * largeur + colonne;
            d_ptr[i] = (TYPE_PIXELS)( REAL( data, i ) / ponderation );
            fourier_debug2( " c=" << colonne << " " << d_ptr[i] << " " << IMAG( data, i ) / ponderation << " / " );
        }
        fourier_debug2( "\n" );
    }

    free( data );

    return 0;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
int Fourier::tfd_2d_inverse_complete( Fourier::Parametres * param_1, Fourier::Parametres * param_2, TYPE_PIXELS * tab_dst, int val_max )
{
    fourier_info2( "norm_1=" << param_1->norm << " norm_2=" << param_2->norm );
    fourier_info2( "talon_1=" << param_1->talon << " talon_2=" << param_2->talon );
    fourier_info2( "val_max=" << val_max );

    /* A ce niveau, les largeur, hauteur, ordre et type sont supposés cohérents */
    int largeur = param_1->largeur;
    int hauteur = param_1->hauteur;
    int surface = largeur * hauteur;
    double ponderation = sqrt( (double)surface );

    /* Identification real-imag ou spectre-phase */
    TYPE_PIXELS * tab_src_1 = 0;
    TYPE_PIXELS * tab_src_2 = 0;
    float norm_1 = 1.0;
    float talon_1 = 1.0;
    float norm_2 = 0.0;
    float talon_2 = 0.0;

    if ( ( param_1->type == Fourier::REAL )
            || ( param_1->type == Fourier::SPECTRUM )
            || ( param_1->type == Fourier::NO_TYPE ) )
    {
        tab_src_1 = param_1->pixels()->pointeur();
        tab_src_2 = param_2->pixels()->pointeur();
        norm_1 = param_1->norm;
        norm_2 = param_2->norm;
        talon_1 = param_1->talon;
        talon_2 = param_2->talon;
    }
    else
    {
        tab_src_1 = param_2->pixels()->pointeur();
        tab_src_2 = param_1->pixels()->pointeur();
        norm_1 = param_2->norm;
        norm_2 = param_1->norm;
        talon_1 = param_2->talon;
        talon_2 = param_1->talon;
    }

    fourier_info2( "norm_1=" << norm_1 << " norm_2=" << norm_2 );
    fourier_info2( "talon_1=" << talon_1 << " talon_2=" << talon_2 );

    double * data = (double *) malloc( 2 * surface * sizeof(double) );

    Fourier::format format = Fourier::POLAR;
    if ( ( param_1->type == Fourier::REAL )
         || ( param_1->type == Fourier::IMAG ) )
        format = Fourier::CARTESIAN;

    if ( format == POLAR )
    {
        if ( param_1->ordre == Fourier::REGULAR )
        {
            fourier_info2( "POLAR REGULAR");
            for ( int ligne = 0; ligne < hauteur ; ligne++ )
            {
                for ( int colonne = 0; colonne < largeur; colonne++ )
                {
                    int i = ligne * largeur + colonne;
                    double longueur = ( tab_src_1[ i ] / norm_1 ) - talon_1;
                    double angle = ( tab_src_2[ i ] / norm_2 ) - talon_2;
                    REAL( data, i ) = longueur * cos( angle );
                    IMAG( data, i ) = longueur * sin( angle );
                }
            }
        }
        else
        { // ordre == CENTERED
            fourier_info2( "POLAR CENTERED");
            for ( int ls = 0; ls < hauteur; ls++ )
            {
                int ld = ( ls + hauteur / 2 ) % hauteur;
                for ( int cs = 0; cs < largeur; cs++ )
                {
                    int cd = ( cs + largeur / 2 ) % largeur;
                    double longueur = tab_src_1[ ld * largeur + cd ] / norm_1 - talon_1;
                    double angle = (tab_src_2[ ld * largeur + cd ] / norm_2) - talon_2;
                    REAL( data, ls * largeur + cs ) = longueur * cos( angle );
                    IMAG( data, ls * largeur + cs ) = longueur * sin( angle );
                }
            }
        }
    }
    else
    {
        if ( param_1->ordre == Fourier::REGULAR )
        {
            fourier_info2( "CARTESIAN REGULAR");
            for ( int ligne = 0; ligne < hauteur ; ligne++ )
            {
                for ( int colonne = 0; colonne < largeur; colonne++ )
                {
                    int i = ligne * largeur + colonne;
                    REAL( data, i ) = ( tab_src_1[ i ] / norm_1 ) - talon_1;
                    IMAG( data, i ) = ( tab_src_2[ i ] / norm_2 ) - talon_2;
                }
            }
        }
        else
        { // ordre == CENTERED
            fourier_info2( "CARTESIAN CENTERED");
            for ( int ls = 0; ls < hauteur; ls++ )
            {
                int ld = ( ls + hauteur / 2 ) % hauteur;
                for ( int cs = 0; cs < largeur; cs++ )
                {
                    int cd = ( cs + largeur / 2 ) % largeur;
                    REAL( data, ls * largeur + cs ) = ( tab_src_1[ ld * largeur + cd ] / norm_1 - talon_1 );
                    IMAG( data, ls * largeur + cs ) = ( tab_src_2[ ld * largeur + cd ] / norm_2 - talon_2 );
                }
            }
        }
    }

    data = tfd_2d( data, largeur, hauteur, gsl_fft_backward );


    for ( int ligne = 0; ligne < hauteur ; ligne++ )
    {
        for ( int colonne = 0; colonne < largeur; colonne++ )
        {
            int i = ligne * largeur + colonne;
            tab_dst[ i ] = (TYPE_PIXELS)( REAL( data, i ) / ponderation );
        }
    }

    free( data );

    return 0;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
Fourier::Parametres * Fourier::inclusion( Fourier::Parametres * p1, Fourier::Parametres * p2 )
{
    TYPE_PIXELS * s;
    Fourier::Parametres * p;
    unsigned int l1, l2, c1, c2;
    IBuffer *buffer;

    if ( ( p1->largeur == p2->largeur ) && ( p1->hauteur == p2->hauteur ) )
    { // Rien à faire, youpi !
        return p1;
    }
    else if ( ( p1->largeur > p2->largeur ) && ( p1->hauteur > p2->hauteur ) )
    {
        s = p2->pixels()->pointeur();
        l1 = p1->hauteur;
        c1 = p1->largeur;
        l2 = p2->hauteur;
        c2 = p2->largeur;
        buffer = p1->buffer();
        p = p2;
    }
    else if ( ( p1->largeur < p2->largeur ) && ( p1->hauteur < p2->hauteur ) )
    {
        s = p1->pixels()->pointeur();
        l1 = p2->hauteur;
        c1 = p2->largeur;
        l2 = p1->hauteur;
        c2 = p1->largeur;
        buffer = p2->buffer();
        p = p1;
    }
    else
    { // Cas où aucune image n'est vraiment pas incluse dans l'autre. Non traité à ce jour.
        return 0;
    }

    fourier_info3( "l1=" << l1 << " c1=" << c1 );
    /* Place vide pour l'image agrandie , et nettoyage */
    TableauPixels * tp = new TableauPixels( c1, l1 );
    TYPE_PIXELS * d = tp->pointeur();

    /* Recopie des pixels de tel façon que le pixel central se retrouve en (0,0) */
    /* Cela permet que l'image corrélée ou convoluée ne se décale pas */
    for ( unsigned int ls = 0; ls < l2; ls++ )
    {
        int ld = ( ls - ( l2 / 2) + l1 ) % l1;
        for ( unsigned int cs = 0; cs < c2; cs++ )
        {
            int cd = ( cs - ( c2 / 2 ) + c1 ) % c1;
            d[ ld * c1 + cd ] = s[ ls * c2 + cs ];
            fourier_debug2( "d[" << cd << "," << ld << "]=s[" << cs << "," << ls << "]=" <<  s[ ls * c2 + cs ] << " / " );
        }
        fourier_debug2("\n");
    }

    /* transfert du pointeur mémoire */
    delete p->pixels();
    p->pixels( tp );
    p->largeur = c1;
    p->hauteur = l1;

    /* transfert du pointeur de keywords */
    p->buffer( buffer );

    return p;
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::produit_complexe( Fourier::Parametres *r1, Fourier::Parametres *i1, Fourier::Parametres *r2, Fourier::Parametres *i2, Fourier::Parametres *r0, Fourier::Parametres *i0, Fourier::multiply m )
{
    fourier_info2( "r1=" << r1->numero() << " (" << r1 << ") i1=" << i1->numero() << " (" << i1 << ")"
        << "r2=" << r2->numero() << " (" << r2 << ") i2=" << i2->numero() << " (" << i2 << ")"
        << "r0=" << r0->numero() << " (" << r0 << ") i0=" << i0->numero() << " (" << i0 << ")" );
    TYPE_PIXELS * tr1 = r1->pixels()->pointeur();
    TYPE_PIXELS * ti1 = i1->pixels()->pointeur();
    TYPE_PIXELS * tr2 = r2->pixels()->pointeur();
    TYPE_PIXELS * ti2 = i2->pixels()->pointeur();
    TYPE_PIXELS * tr0 = r0->pixels()->pointeur();
    TYPE_PIXELS * ti0 = i0->pixels()->pointeur();

    if ( m == Fourier::CONJUGATE )
    {
        for ( unsigned int i = 0; i < ( r1-> largeur * r1->hauteur ); i++ )
        {
            tr0[i] = tr1[i] * tr2[i] + ti1[i] * ti2[i];
            ti0[i] = ti1[i] * tr2[i] - tr1[i] * ti2[i];
        }
    }
    else // m == Fourier::STANDARD
    {
        for ( unsigned int i = 0; i < ( r1-> largeur * r1->hauteur ); i++ )
        {
            tr0[i] = tr1[i] * tr2[i] - ti1[i] * ti2[i];
            ti0[i] = ti1[i] * tr2[i] + tr1[i] * ti2[i];
        }
    }
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::normalisation( Fourier::Parametres * p, TYPE_PIXELS norm_basse, TYPE_PIXELS norm_haute, Fourier::Ordre ordre )
{
    fourier_info2( "parametres=" << p->numero() << " (" << p << ") norm basse=" << norm_basse << " norm_haute=" << norm_haute << " ordre=" << ordre );

    TYPE_PIXELS * s = p->pixels()->pointeur();
    TableauPixels * tp = new TableauPixels( p->largeur, p->hauteur);
    TYPE_PIXELS * d = tp->pointeur();

    float pente = 0.0;
    float x0 = 0.0;
    float y0 = 0.0;

    if ( ( norm_basse != 0 ) || ( norm_haute != 0 ) )
    {
        /* Recherche des valeurs extrêmes */
        float minimum = FLT_MAX;
        float maximum = - FLT_MAX;

        for ( unsigned int i = 0; i < ( p-> largeur * p->hauteur ); i++ )
        {
            if ( s[i] > maximum )
                maximum = s[i];
            if ( s[i] < minimum )
                minimum = s[i];
        }

        if ( maximum > minimum )
            pente = ( norm_haute - norm_basse ) / ( maximum - minimum );
        else
            pente = 1.0;

        y0 = norm_basse;
        x0 = minimum;
    }
    else // norm_basse = norm_haute = 0
    { // Pas de normalisation à proprement parler
        pente = 1.0;
        y0 = 0;
        x0 = 0;
    }

    fourier_info2( "pente=" << pente << " x0=" << x0 << " y0=" << y0 );

    if ( ordre == Fourier::REGULAR )
    {
        /* Normalisation simple */
        for ( unsigned int i = 0; i < ( p-> largeur * p->hauteur ); i++ )
        {
            d[i] = ( ( s[i] - x0 ) * pente ) + y0 ;
        }
    }
    else // ordre == Fourier::CENTERED
    {
        for ( unsigned int ls = 0; ls < p->hauteur; ls++ )
        {
            int ld = ( ls + p->hauteur / 2 ) % p->hauteur;
            for ( unsigned int cs = 0; cs < p->largeur; cs++ )
            {
                int cd = ( cs + p->largeur / 2 ) % p->largeur;
                d[ld * p->largeur + cd] = ( ( s[ls * p->largeur + cs] - x0 ) * pente ) + y0 ;
            }
        }
    }
    /* Changement de pointeurs */
    delete p->pixels();
    p->pixels( tp );
}

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
void Fourier::extrema( Fourier::Parametres * p, TYPE_PIXELS * minimum, TYPE_PIXELS * maximum )
{
    * minimum = FLT_MAX;
    * maximum = -FLT_MAX;
    TYPE_PIXELS *s = ( p->pixels() )->pointeur();

    for ( unsigned int i = 0; i < ( p->largeur * p->hauteur ); i++ )
    {
        if ( s[i] > * maximum )
            * maximum = s[i];
        if ( s[i] < * minimum )
            * minimum = s[i];
    }
}

}

