/***
 * @file : horloge.cpp
 * @brief : interface TCL<->C pour la gestion de l'horloge système
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: horloge.cpp,v 1.4 2010-06-20 12:18:20 jacquesmichelet Exp $
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

#include <sysexp.h>

#if defined(OS_LIN)
#include <sys/time.h>
#include <errno.h>
extern int errno;
#endif

#include <math.h>
#include "libjm.h"
#include "horloge.h"



namespace LibJM {


/* ******************* jd *********************
 * Donne le jour julien correspondant a la date
 * annee : valeur de l'annee correspondante
 * mois  : valeur du mois correspondant
 * jour  : valeur du jour decimal correspondant
 * *jj   : valeur du jour julien converti
 * ********************************************/
int Horloge::jd( int annee,int mois,double jour,double *jj )
{
    double a, m, j, aa, bb;

    a = (double)annee;
    m = (double)mois;
    j = jour;

    if ( m <= 2 )
    {
        a = a - 1;
        m = m + 12;
    }

    aa = floor( a / 100 );
    bb = 2 - aa + floor( aa / 4 );
    *jj = floor( 365.25 * ( a + 4716 ) ) + floor( 30.6001 * ( m + 1 ) ) + j + bb - 1524.5;
    return Generique::OK;
}

int Horloge::jc( int *annee, int *mois, double *jour, double jj )
{
    double jjj, z, f, a, alpha, b, c, d, e;

    jjj = jj + 0.5;
    z = floor( jjj );
    f = jjj - z;

    if ( z < 2299161.0 )
        a = z;
    else
    {
        alpha = floor( ( z - 1867216.25 ) / 36524.25 );
        a = z + 1 + alpha - floor( alpha / 4 );
    }

    b = a + 1524;
    c = floor( ( b - 121.1 ) / 365.25 );
    d = floor( 365.25 * c );
    e = floor( ( b - d ) / 30.6001 );

    *jour = b - d - floor( 30.6001 * e ) + f;
    if ( e < 14 )
        *mois = (int)( e - 1 );
    else
        *mois = (int)( e - 13 );
    if ( *mois > 2 )
        *annee = (int)( c - 4716 );
    else
        *annee = (int)( c - 4715 );

    return Generique::OK;
}


/* ***************** LitHeurePC ****************
 * LitHeurePC
 * Lecture de l'heure d'un PC
 * *********************************************/
int Horloge::LitHeurePC(int *annee, int *mois, int *jour, int *heure, int *minute, int *seconde, int *milli)
{
#if defined(OS_WIN)
    struct _SYSTEMTIME temps_pc;

    GetSystemTime(&temps_pc);
    *annee = temps_pc.wYear;
    *mois = temps_pc.wMonth;
    *jour = temps_pc.wDay;
    *heure = temps_pc.wHour;
    *minute = temps_pc.wMinute;
    *seconde = temps_pc.wSecond;
    *milli = temps_pc.wMilliseconds;
#endif

#if defined(OS_LIN)
    struct timeval temps_pc;
    struct timezone fuseau;
    double jour_decimal, jj, t;

    gettimeofday(&temps_pc, &fuseau);

    /* conversion en jour décimaux et ajout du jj du 01/01/1970 */
    jj = (double)temps_pc.tv_sec / 86400.0 + 2440587.5;

    /* conversion en jour calendaire */
    jc(annee, mois, &jour_decimal, jj);
    *jour = (int)floor(jour_decimal);
    t = 24.0 * (jour_decimal - (double)(*jour));
    *heure = (int)floor(t);
    t = 60.0 * (t - (double)(*heure));
    *minute = (int)floor(t);
    t = 60.0 * (t - (double)(*minute));
    *seconde = (int)floor(t);

    *milli = floor(temps_pc.tv_usec / 1000);
#endif
    return Generique::OK;
}

/* ***************** EcritHeurePC ****************
 * EcritHeurePC
 * Ecriture de l'heure d'un PC
 * ***********************************************/
int Horloge::EcritHeurePC(int annee, int mois, int jour, int heure, int minute, int seconde, int milli)
{
#if defined(OS_WIN)
    struct _SYSTEMTIME temps_pc;

    temps_pc.wYear = annee;
    temps_pc.wMonth = mois;
    temps_pc.wDay = jour;
    temps_pc.wHour = heure;
    temps_pc.wMinute = minute;
    temps_pc.wSecond = seconde;
    temps_pc.wMilliseconds = milli;
    if (!SetSystemTime(&temps_pc))
        return Generique::PB;
#endif
#if defined(OS_LIN)
    struct timeval temps_pc;
    struct timezone fuseau;
    double jour_decimal, jj;

    /* La lecture sert à initialiser le fuseau */
    gettimeofday(&temps_pc, &fuseau);

    /* Conversion en jj et retrait du jj correspondant au 01/01/1970 */
    jour_decimal = (double)(jour + (heure / 24.0) + (minute / 1440.0) + (seconde / 86400.0));
    jd(annee, mois, jour_decimal, &jj);
    jj -=  2440587.5;

    temps_pc.tv_sec = jj * 86400;
    temps_pc.tv_usec = milli;

    if (settimeofday(&temps_pc, &fuseau)) {
      if (errno == EPERM)
        return Generique::PB2;
      if (errno)
        return Generique::PB;
    }
#endif
    return Generique::OK;
}

/* ***************** ReglageHeurePC ****************
 * ReglageHeurePC
 * Reglage de l'heure d'un PC
 * *************************************************/
int Horloge::ReglageHeurePC(long *decalage_reel, long decalage)
{
#if defined(OS_WIN)

    struct _SYSTEMTIME temps_pc;
    double jour_decimal, jj, t;
    double jj1, jj2;
    int annee, mois, jour, heure, minute, seconde, milli;

    GetSystemTime(&temps_pc);
    annee = temps_pc.wYear;
    mois = temps_pc.wMonth;
    jour = temps_pc.wDay;
    heure = temps_pc.wHour;
    minute = temps_pc.wMinute;
    seconde = temps_pc.wSecond;
    milli = temps_pc.wMilliseconds;

    /* Conversion en jour julien */
    jour_decimal = (double)(jour + (heure / 24.0) + (minute / 1440.0) + (seconde / 86400.0) + (milli / 86400000.0));
    jd(annee, mois, jour_decimal, &jj);

    /* Mise en mémoire */
    jj1 = jj;

    /* Ajout de la correction */
    jj += ((double)decalage / 86400000.0);

    /* Conversion en date calendaire */
    jc(&annee, &mois, &jour_decimal, jj);
    jour = (int)floor(jour_decimal);
    t = 24.0 * (jour_decimal - (double)(jour));
    heure = (int)floor(t);
    t = 60.0 * (t - (double)(heure));
    minute = (int)floor(t);
    t = 60.0 * (t - (double)(minute));
    seconde = (int)floor(t);
    t = 1000.0 * (t - (double)(seconde));
    milli = (int)floor(t);

    /* Ecriture de la nouvelle heure */
    temps_pc.wYear = annee;
    temps_pc.wMonth = mois;
    temps_pc.wDay = jour;
    temps_pc.wHour = heure;
    temps_pc.wMinute = minute;
    temps_pc.wSecond = seconde;
    temps_pc.wMilliseconds = milli;
    if (!SetSystemTime(&temps_pc))
        return Generique::PB;

    /* Verification  */
    GetSystemTime(&temps_pc);
    annee = temps_pc.wYear;
    mois = temps_pc.wMonth;
    jour = temps_pc.wDay;
    heure = temps_pc.wHour;
    minute = temps_pc.wMinute;
    seconde = temps_pc.wSecond;
    milli = temps_pc.wMilliseconds;

    /* Conversion en jour julien */
    jour_decimal = (double)(jour + (heure / 24.0) + (minute / 1440.0) + (seconde / 86400.0) + (milli / 86400000.0));
    jd(annee, mois, jour_decimal, &jj2);

    *decalage_reel = (long)(((jj2 - jj1) * 86400000.0));
#endif

#if defined(OS_LIN)
    struct timeval temps_pc;
    struct timezone fuseau;
    double jj, jj1;

    gettimeofday(&temps_pc, &fuseau);

    /* conversion en secondes */
    jj = ((double)temps_pc.tv_sec + (double)temps_pc.tv_usec / 1000000.0);

    /* Mise en mémoire */
    jj1 = jj;

    /* Ajout de la correction (le décalage est en ms)*/
    jj += ((double)decalage / 1000.0);

    temps_pc.tv_sec = (long)floor(jj);
    temps_pc.tv_usec = (long)((jj - floor(jj)) * 1000000.0);

    if (settimeofday(&temps_pc, &fuseau)) {
      if (errno == EPERM)
        return Generique::PB2;
      if (errno)
        return Generique::PB;
    }

    /* Verification  */
    gettimeofday(&temps_pc, &fuseau);

    /* conversion en secondes */
    jj = (double)temps_pc.tv_sec + ((double)temps_pc.tv_usec / 1000000.0);

    *decalage_reel = (long)(((jj - jj1) * 1000.0));
#endif
    return Generique::OK;
}

}

