/***
 * @file : calaphot.h
 * @brief : définition des macros et des objets se rapportant à la photométrie et à la modélisation
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: calaphot.h,v 1.8 2010-06-20 12:18:20 jacquesmichelet Exp $
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

#ifndef __LIBJM_CALAPHOT_H__
#define __LIBJM_CALAPHOT_H__

namespace LibJM {
/* Declaration des structures */
struct data 
{
    int nxy;
    int x1;
    int y1;
    int x2;
    int y2;
    double * pixels;
};

/* --- Macros pour générer des traces --- */
#ifndef __CALAPHOT_STRINGIFY
# define __CALAPHOT_TSTRHELPER(x) #x
# define __CALAPHOT_STRINGIFY(y) __CALAPHOT_TSTRHELPER(y)
#endif /* __CALAPHOT_STRINGIFY  */

#  define photom_log(level,__s) \
    if (level >= Photom::_log_verbosity) { photom_log_on_stream(log_stream,__CALAPHOT_STRINGIFY(level),__s) }

#  define photom_verbose_log(level,__s) \
    if (level >= Photom::_log_verbosity) { photom_verbose_log_on_stream(log_stream,__CALAPHOT_STRINGIFY(level),__s) }

#  if defined(__GNUC__)
#   define photom_log_on_stream(__stream,level,str) \
                 (__stream) << str << "\n"; \
                 (__stream).flush();
#   define photom_verbose_log_on_stream(__stream,level,str) \
                 (__stream) << "[" << level << "] " <<__FILE__ << ":" << __LINE__ << " ("<<__PRETTY_FUNCTION__<<") -" << "- " << str << "\n"; \
                 (__stream).flush();
#   else /* !__GNUC__ */
#   define photom_log_on_stream(__stream,level,str) \
                 (__stream) << str << "\n"; \
                 (__stream).flush();
#   define photom_verbose_log_on_stream(__stream,level,str) \
                 (__stream) << "[" << level << "] " << __FILE__ << ":" << __LINE__ << " -" << str << "\n"; \
                 (__stream).flush();
#  endif /* !__GNUC__*/

# define photom_error(__s)    photom_verbose_log(Photom::Error_Level,__s)
# define photom_warning(__s)  photom_log(Photom::Warning_Level,__s)
# define photom_notice(__s)   photom_log(Photom::Notice_Level,__s)
# define photom_info1(__s)    photom_verbose_log(Photom::Info1_Level,__s)
# define photom_info2(__s)    photom_verbose_log(Photom::Info2_Level,__s)
# define photom_info3(__s)    photom_verbose_log(Photom::Info3_Level,__s)
# define photom_info4(__s)    photom_verbose_log(Photom::Info4_Level,__s)
#undef PHOTOM_DEBUG_VALIDE
#ifdef PHOTOM_DEBUG_VALIDE
# define photom_debug(__s)    photom_verbose_log(Photom::Debug_Level,__s)
# define photom_trace(__s)    photom_verbose_log(Photom::Trace_Level,__s)
#else
# define photom_debug(__s)
# define photom_trace(__s)
#endif

class Photom
{
public :
    class Modele
    {
        public :
        double X0;
        double Y0;
        double Signal;
        double Fond;
        double Sigma_X;
        double Sigma_Y;
        double Ro;
        double Sigma_1;
        double Sigma_2;
        double Alpha;
        double Flux;
        Modele() : X0(0.0), Y0(0.0), Signal(0.0), Fond(0.0), Sigma_X(0.0), Sigma_Y(0.0), Ro(0.0), Sigma_1(0.0),Sigma_2(0.0), Alpha(0.0), Flux(0.0) {};
    };
    class Rectangle 
    {
        public :
        int xmin;
        int xmax;
        int ymin;
        int ymax;
        int nx;
        int ny;
        size_t nxy;
        void Init( const std::vector<int> & );
        int lecture_rectangle( gsl_vector *vect_s );
        Rectangle() : xmin(0), xmax(0), ymin(0), ymax(0), nx(0), ny(0), nxy(0) {};
    };
    class Astre 
    {
        private :
        Rectangle * _rect;
        Modele * _modele;
        Modele * _incertitude;
        public :
        void init_rectangle( const std::vector<int> & zone ) { _rect->Init( zone ); }
        Rectangle * rect() { return _rect; }
        Modele * modele() { return _modele; }
        Modele * incert() { return _incertitude;  }
        Astre() 
        {
            _rect = new Rectangle();
            _modele = new Modele();
            _incertitude = new Modele();
        }
        ~Astre() 
        {
            delete _rect;
            delete _modele;
            delete _incertitude;
        }
    };

    struct point 
    {
        double x;
        double y;
    } point;

    class Limites 
    {
        private :
        TYPE_PIXELS _minimum;
        TYPE_PIXELS _maximum;
        public :
        Limites( TYPE_PIXELS mini, TYPE_PIXELS maxi ) {
            _minimum = mini;
            _maximum = maxi;
        }
        TYPE_PIXELS maximum() { return _maximum; }
        TYPE_PIXELS minimum() { return _minimum; }
        void maximum( TYPE_PIXELS m ) { _maximum = m; }
        void minimum( TYPE_PIXELS m ) { _minimum = m; }
    };

    struct ouverture 
    {
        struct point centre;
        double rayon_1;
        double rayon_2;
        double rayon_3;
        double rapport_yx;
        double facteur_ro;
    };

    struct flux_ouverture 
    {
        double flux_etoile;
        double nb_pixels_etoile;
        double intensite_fond_ciel;
        double nb_pixels_fond_ciel;
        double bruit_fond_ciel;
    };

    enum log_level
    {
        Error_Level = 9,
        Warning_level = 8,
        Notice_Level = 7,
        Info1_Level = 6,
        Info2_Level = 5,
        Info3_Level = 4,
        Info4_Level = 3,
        Debug_Level = 2,
        Trace_Level = 1
    };
    enum mode_lecture_pixel
    {
        NORMAL = 0,
        BILINEAIRE = 1
    };

    static Photom * instance();
    static int CmdFluxEllipse( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdAjustementGaussien( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdNiveauTraces( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdMinMax( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    static int CmdModeLecturePixels( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );

    static int _log_verbosity;
    static std::ofstream log_stream;
    static std::string photom_log_file_name;
    static Limites * minmax;
    static int photom_mode;

    TYPE_PIXELS LecturePixel( double x, double y );

private :
    Photom();
    ~Photom();
    static Photom * _unique_instance;
    IBuffer * _buffer;
    int Gauss( Astre &, gsl_vector *, gsl_vector *, gsl_matrix *, double *me1 );
    int EcriturePixel( double x, double y, TYPE_PIXELS intensite );
    void FluxEllipse( Photom::ouverture * ouv, int c, flux_ouverture *fouv );
    int Incertitude( double flux_etoile, double flux_fond, double nb_pixel, double nb_pixel_fond, double gain, double sigma, double *signal_bruit, double *incertitude, double *bruit_flux );
    int CmdMagnitude( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
    int CmdIncertitude( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );

    int AjustementGaussien( Astre &, std::vector<double>, std::vector<double>, double * );
    int SoustractionGaussienne( Astre & );
    int Magnitude( double, double, double, double * );
    void niveau_traces( int );

    IBuffer * set_buffer (int);

    enum Erreur {
        ERR_FATALE = -100,
        ERR_MODELISATION = -200,
        ERR_DIVERGENCE = -201,
        ERR_AJUSTEMENT = -202
    };
};

}

#endif // __LIBJM_CALAPHOT_H__
