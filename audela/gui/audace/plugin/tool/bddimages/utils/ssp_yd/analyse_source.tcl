#--------------------------------------------------
# source audace/plugin/tool/av4l/analyse_source.tcl
#--------------------------------------------------
#
# Fichier        : analyse_source.tcl
# Description    : Utilitaires de communcation avec un flux (video ou lot d'image)
# Auteur         : Frederic Vachier
# Mise à jour $Id: analyse_source.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::analyse_source {


   #
   # ::analyse_source::test
   # 
   #
   proc ::analyse_source::test { listsources } {

      global bddconf
   
      ::console::affiche_resultat "[lindex $listsources 0]  \n"

      set unesource [lindex [lindex $listsources 1] 10]
      ::console::affiche_resultat "$unesource \n"
      set ra  [lindex [lindex [lindex $unesource 0] 1] 0]
      set dec [lindex [lindex [lindex $unesource 0] 1] 1]
      set x [lindex [lindex [lindex $unesource 0] 2] 2]
      set y [lindex [lindex [lindex $unesource 0] 2] 3]
      set fwhm [lindex [lindex [lindex $unesource 0] 2] 24]
      ::console::affiche_resultat "X $x / Y $y / FWHM $fwhm\n"

      set source [list {"SOURCE" {} {} } [list [list [list "SOURCE" [list $ra $dec] {}]]]]
      affich_rond $source "SOURCE" "green" 1

      gren_info "[::confVisu::screen2Canvas  $bddconf(visuno) [list $x $y]]\n"
      gren_info "[::confVisu::canvas2Picture $bddconf(visuno) [list $x $y]]\n"

      affich_un_rond_xy $x $y "green" 5  4

      set results [ ::av4l_photom::photom_methode $x $y $fwhm $bddconf(bufno) ]
      set x2 [lindex $results 0]
      set y2 [lindex $results 1]
      ::console::affiche_resultat "X $x2 / Y $y2 \n"
      affich_un_rond_xy $x2 $y2 "blue" 5  2
      ::console::affiche_resultat "diff X [expr abs($x2-$x)] / Y [expr abs($y2-$y)] \n"

      gren_info "$results\n"
   }

   #
   # ::analyse_source::test
   #
   # photom_methode
   # xsm         ysm        fwhmx    fwhmy    fwhm     fluxintegre errflux  pixmax  intensite sigmafond snint         snpx          delta
   # 1936.447981 844.076965 3.510291 1.861599 2.685945 799.000000  0        1310    246.0     33.616402 23.7681593646 7.31785632502 3.21

   proc ::analyse_source::test2 { listsources radius_threshold } {

      global bddconf

      set cpt 0
      set doute 0

      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]

      set nbs [::manage_source::get_nb_sources_by_cata $listsources "IMG"]
      ::console::affiche_resultat "nb sources to work : $nbs \n"

      lappend fields [list "PHOTOM" {} [list "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff"] ]
      set newsources {}

      foreach s $sources {
         
         foreach cata $s {

            if { [lindex $cata 0]=="IMG" } {

               set ra   [lindex [lindex [lindex $s 0] 1] 0]
               set dec  [lindex [lindex [lindex $s 0] 1] 1]
               set x    [lindex [lindex [lindex $s 0] 2] 2]
               set y    [lindex [lindex [lindex $s 0] 2] 3]
               set fwhm [lindex [lindex [lindex $s 0] 2] 24]
               set results [::av4l_photom::photom_methode $x $y $fwhm $bddconf(bufno) ]
               if {$results == -1} {
                  lappend newsources $s
               } else {
                  incr cpt
                  set xd [expr abs([lindex $results 0]-$x)]
                  set yd [expr abs([lindex $results 1]-$y)]
                  set rdiff [expr sqrt (pow($xd,2) + pow($yd ,2))]
                  if {$rdiff > $radius_threshold } {
                     lappend newsources $s
                     incr doute
                  } else {
                     lappend results $rdiff
                     lappend s [list "PHOTOM" {} $results]
                     lappend newsources $s
                  }

               }

            }

         }
         
      }

      ::console::affiche_resultat "nb doute : $doute \n"
   return [list $fields $newsources]
   }


}
