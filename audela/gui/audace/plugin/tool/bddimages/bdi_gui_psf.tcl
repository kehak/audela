## @file bdi_gui_psf.tcl
#  @brief     GUI de traitement des PSF des sources dans les images
#  @author    Frederic Vachier
#  @date      2016
#  @copyright GNU Public License.
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_psf.tcl]
#  @endcode
#  @version   2.0

# $Id: bdi_gui_psf.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_psf
# @brief GUI de traitement des PSF des sources dans les images
# @pre Requiert \c bdi_tools_psf .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_psf {

}


#------------------------------------------------------------
## Initialisation des parametres de PSF au niveau GUI
# Cette initialisation est a effectuer avant l'appel
# a une fonction de mesure de photocentre
# @return void
#
proc ::bdi_gui_psf::inittoconf { } {

   ::bdi_tools_psf::inittoconf

}



#------------------------------------------------------------
## Sauvegarde dans la conf des parametres lies a la PSF
# Cette initialisation est a effectuer avant l'appel
# a une fonction de mesure de photocentre
# @return void
#
proc ::bdi_gui_psf::closetoconf { } {

   ::bdi_tools_psf::closetoconf

}



#------------------------------------------------------------
## Fonction qui initialise la variable current_psf
# et formate le resultat
# @param othf otherfield ASTROID
# @return void
#
proc ::bdi_gui_psf::init_current_psf { othf } {

   set l [::bdi_tools_psf::get_fields_current_psf]

   foreach key $l {

      set value [::bdi_tools_psf::get_val othf $key]

      if {[string is ascii $value]} {set fmt "%s"}
      if {[string is double $value]} {set fmt "%.4f"}
      if {$value==""} {
         set ::bdi_gui_cata::current_psf($key) ""
         continue
      }
      if { ! [info exists fmt] } {gren_erreur "$value n a pas de format\n"}
      set ::bdi_gui_cata::current_psf($key) [format $fmt $value ]
   }

}




proc ::bdi_gui_psf::get_list_col { } {
   return [list xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec ]
}




proc ::bdi_gui_psf::get_pos_col { key } {

   set list_of_columns [::psf_gui::get_list_col]

   set cpt 0
   foreach c $list_of_columns {
      if {$c==$key} {
         return $cpt
      }
      incr cpt
   }
   return -1
}




proc ::bdi_gui_psf::graph_with_error { key err_key } {

      set delta $::bdi_gui_cata::current_psf($err_key)
      set y0    $::bdi_gui_cata::current_psf($key)
      #gren_info "$key = $y0 ; delta = $delta\n"
      set ymin [list [expr $y0 - $delta] [expr $y0 - $delta] ]
      set ymax [list [expr $y0 + $delta] [expr $y0 + $delta] ]
      set x0   [list 0 $::bdi_tools_psf::psf_limitradius_max]
      set h [::plotxy::plot $x0 $ymin .]
      plotxy::sethandler $h [list -color "#808080" -linewidth 2]
      set h [::plotxy::plot $x0 $ymax .]
      plotxy::sethandler $h [list -color "#808080" -linewidth 2]

}




proc ::bdi_gui_psf::graph { key } {

   # graph de log
   if {1 == 1} {
      for {set radius $::bdi_tools_psf::psf_limitradius_min} {$radius < $::bdi_tools_psf::psf_limitradius_max} {incr radius} {
         if {[info exists ::bdi_tools_psf::graph_results($radius,$key)]} {
            if {$::bdi_tools_psf::graph_results($radius,err)==10} {
               gren_erreur "$radius $::bdi_tools_psf::graph_results($radius,err)\n"
            }
            if {$::bdi_tools_psf::graph_results($radius,err)==0} {
               gren_info "$radius $::bdi_tools_psf::graph_results($radius,err)\n"
            }
         }
      }
   }

   set ::bdi_gui_psf::graph_current_key $key

   set x ""
   set y ""

   for {set radius $::bdi_tools_psf::psf_limitradius_min} {$radius < $::bdi_tools_psf::psf_limitradius_max} {incr radius} {

      #catch { gren_erreur "$radius $::bdi_tools_psf::graph_results($radius,err)\n" }

      if {[info exists ::bdi_tools_psf::graph_results($radius,$key)]} {
         if {$::bdi_tools_psf::graph_results($radius,err)==0} {
            lappend x $radius
            lappend y $::bdi_tools_psf::graph_results($radius,$key)
         }
      }
   }

   ::plotxy::clf 1
   ::plotxy::figure 1
   ::plotxy::hold on
   ::plotxy::position {0 0 600 400}


   # Affichage de la valeur obtenue sous forme d'une ligne horizontale
   set x0 [list 0 $::bdi_tools_psf::psf_limitradius_max]
   set y0 [list $::bdi_gui_cata::current_psf($key) $::bdi_gui_cata::current_psf($key)]
   set h [::plotxy::plot $x0 $y0 .]
   plotxy::sethandler $h [list -color black -linewidth 2]

   # Affichage des erreurs pour XSM
   if {$key == "xsm" } {
      ::bdi_gui_psf::graph_with_error "xsm" "err_xsm"
      set y0 $::bdi_gui_cata::current_psf($key)
      set h 0.1
      set axis [::plotxy::axis]
      set axis [lreplace $axis 2 3 [expr $y0 - $h/2.] [expr $y0 + $h/2.] ]
      ::plotxy::axis $axis
   }
   # Affichage des erreurs pour YSM
   if {$key == "ysm" } {
      ::bdi_gui_psf::graph_with_error "ysm" "err_ysm"
      set y0 $::bdi_gui_cata::current_psf($key)
      set h 0.1
      set axis [::plotxy::axis]
      set axis [lreplace $axis 2 3 [expr $y0 - $h/2.] [expr $y0 + $h/2.] ]
      ::plotxy::axis $axis
   }
   # Affichage des erreurs pour FLUX
   if {$key == "flux" } {
      ::bdi_gui_psf::graph_with_error "flux" "err_flux"
   }
   # Affichage des erreurs pour SKY
   if {$key == "sky" } {
      ::bdi_gui_psf::graph_with_error "sky" "err_sky"
   }




   array set point [list 0 . 1 o 2 + 3 . 4 + 5 o ]
   array set color [list 0 "#18ad86" 1 yellow 2 green 3 blue 4 red 5 black ]
   array set line  [list 0 1 1 0 2 0 3 0 4 0 5 0 ]

   set h [::plotxy::plot $x $y .]
   plotxy::sethandler $h [list -color "#18ad86" -linewidth 1]


}

