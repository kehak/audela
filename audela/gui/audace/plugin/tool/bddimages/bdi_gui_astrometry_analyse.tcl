## @file bdi_gui_astrometry_analyse.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI de mesure astrom&eacute;trique en mode manuel.
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_astrometry_analyse.tcl]
#  @endcode

# $Id: bdi_gui_astrometry_analyse.tcl 13117 2016-05-21 02:00:00Z jberthier $

proc ::bdi_gui_astrometry::analyse_graph_init { } {

   gren_info "analyse_graph_init\n"

   set li [ ::plotxy::getgcf 1 ]
   if {$li != ""} {
      set p  [lsearch -index 0 $li parent] 
      set parent [lindex [ ::plotxy::getgcf 1 ] [lsearch -index 0 $li parent] 1 ]
      set geom [wm geometry $parent]
      set r [split $geom "+"]
      set size [lindex $r 0]
      set posx [lindex $r 1]
      set posy [lindex $r 2]
      set r [split $size "x"]
      set sizex [lindex $r 0]
      set sizey [lindex $r 1]
      set pos [list $posx $posy $sizex $sizey]
   } else {
      set pos {0 0 600 400}
   }
         
   ::plotxy::clf 1
   ::plotxy::figure 1 
   ::plotxy::hold on 
   ::plotxy::position $pos
   ::plotxy::title "Distance inter-etoiles" 
   ::plotxy::xlabel "X Pixel" 
   ::plotxy::ylabel "Y Pixel" 

}




proc ::bdi_gui_astrometry::analyse_position_pixel { } {

   gren_info "analyse_test\n"
   ::bdi_gui_astrometry::analyse_graph_init

   set id_current_image 0
   set xo ""
   set yo ""
   foreach current_image $::tools_cata::img_list {

      incr id_current_image
      ::manage_source::extract_tabsources_by_idimg $id_current_image tabsources

      foreach {key s} [array get tabsources] {
         set otherfields [lindex $s 2]
         set xsm [lindex $otherfields 0]
         set ysm [lindex $otherfields 1]
         lappend xo $xsm
         lappend yo $ysm
      }

   }
   
   # Trace
   set ho [::plotxy::plot $xo $yo 0]
   plotxy::sethandler $ho [list -color blue -linewidth 0]
   
   
}




proc ::bdi_gui_astrometry::analyse_etoile_getbox { } {

   gren_info "analyse_centrer_etoile_getbox\n"

   if {[::plotxy::figure] == 0 } {
      gren_erreur "Pas de graphe actif\n"
      return
   }

   set err [ catch {set rect [::plotxy::get_selected_region]} msg]
   if {$err} {
      gren_erreur "Veuillez selectionner une zone dans l'image.\n"
      return
   }

   set x1 [lindex $rect 0]
   set x2 [lindex $rect 2]
   set y1 [lindex $rect 1]
   set y2 [lindex $rect 3]

   if {$x1 > $x2} {
      set t $x1
      set x1 $x2
      set x2 $t
   }
   if {$y1 > $y2} {
      set t $y1
      set y1 $y2
      set y2 $t
   }

   gren_info "Zone selectionnee: $x1 < X < $x2 ; $y1 < Y < $y2\n"

   # Recherche de l'etoile
   set refname ""
   array set listref {}

# o = 2207.6722 1090.0450 0.0016 0.0017 9.88 9.80 9.85 41627.5 436.9 434.0 379.9 37.8 0.9 204.0 39 0.29 - psfgaussian2d 10:60 234.14952389 -6.69315333 -0.03892 0.05054 {} {} 14.373187776064775 0.011335922759247552 UCAC4_417-061547 R {} UCAC4 {}

   set id_current_image 0
   foreach current_image $::tools_cata::img_list {
      incr id_current_image
      ::manage_source::extract_tabsources_by_idimg $id_current_image tabsources
      foreach {key s} [array get tabsources] {
#gren_info "s = $s\n"
         set otherfields [lindex $s 2]
         set xsm [lindex $otherfields 0]
         set ysm [lindex $otherfields 1]
         if {$xsm > $x1 && $xsm < $x2 && $ysm > $y1 && $ysm < $y2} {
            lappend refname [lindex $otherfields 27]
#gren_info "o = $otherfields\n"
            lappend listref($refname) [list [lindex $otherfields 0] [lindex $otherfields 1] [lindex $otherfields 2] [lindex $otherfields 3] [lindex $otherfields 19] [lindex $otherfields 20] [lindex $otherfields 21] [lindex $otherfields 22]]
         }
      }
   }
   set zsource [lsort -ascii -unique $refname]
   if {[llength $zsource] > 1} {
      gren_info "Trop de sources selectionnees, veuillez affiner la zone.\n"
      return
   } else {
      gren_info "Source selectionnee: $zsource\n"
      set ::bdi_gui_astrometry::widget(analyse,source,selected,name) $zsource
      gren_erreur "$listref($zsource) \n"

      foreach {k s} [array get listref] {
#            gren_erreur "s= $s\n"
      }
   }


   set sref [lindex $listref($zsource) 0]
   set x_ref [lindex $sref 0]
   set y_ref [lindex $sref 1]
   set ra_ref  [lindex $sref 4]
   set dec_ref [lindex $sref 5]

gren_info "$x_ref $y_ref :: $ra_ref $dec_ref\n"

}


proc ::bdi_gui_astrometry::analyse_position_catalog { } {

}


proc ::bdi_gui_astrometry::analyse_centrer_etoile { } {
   
   gren_info "Centrage sur l etoile : $::bdi_gui_astrometry::widget(analyse,source,selected,name)\n"

   set xo ""
   set yo ""

   set id_current_image 0
   set select_axe_zero  0
   foreach current_image $::tools_cata::img_list {

      incr id_current_image
      set current_listsources $::bdi_gui_cata::cata_list($id_current_image)
      set fields [lindex $current_listsources 0]
      set sources [lindex $current_listsources 1]
      set idref [::manage_source::name2ids $::bdi_gui_astrometry::widget(analyse,source,selected,name) current_listsources]
      if {$idref==-1} {continue}
      #gren_info "idref = $idref\n"

      set s [lindex $current_listsources [list 1 $idref] ]
      set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
      set xsm_ref  [::bdi_tools_psf::get_val othf "xsm"]
      set ysm_ref  [::bdi_tools_psf::get_val othf "ysm"]
      set name     [::bdi_tools_psf::get_val othf "name"]
      set flagastrom [::bdi_tools_psf::get_val othf "flagastrom"]
      if {$flagastrom == ""} {continue}
      
      # premiere image / premiere reference
      if {$select_axe_zero==0} {
          set xsm_ref_zero $xsm_ref
          set ysm_ref_zero $ysm_ref
          gren_info "idref xsm_ref_zero  ysm_ref_zero = ($idref) ($name) $xsm_ref_zero $ysm_ref_zero \n"
          set select_axe_zero 1
          continue
      }

      gren_info "idref xsm  ysm = ($idref) ($name) $xsm_ref $ysm_ref \n"
      set xsm_move [expr $xsm_ref_zero - $xsm_ref]
      set ysm_move [expr $ysm_ref_zero - $ysm_ref]
      gren_info "idref xsm_move  ysm_move = ($idref) ($name) $xsm_move $ysm_move \n"

      set list_id_ref [::tools_cata::get_id_astrometric "R" current_listsources]
      foreach l $list_id_ref {

         set id     [lindex $l 0]
         set idcata [lindex $l 1]
         set name   [lindex $l 4]
         set s [lindex $current_listsources [list 1 $id] ]
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         set xsm  [expr [::bdi_tools_psf::get_val othf "xsm"] + $xsm_move ]
         set ysm  [expr [::bdi_tools_psf::get_val othf "ysm"] + $ysm_move ]
         set name2 [::bdi_tools_psf::get_val othf "name"]
         set flagastrom [::bdi_tools_psf::get_val othf "flagastrom"]
         if {$flagastrom == ""} {continue}
         #gren_info "idf xsm  ysm = ($idref) ($idcata) ($name) ($name2) $xsm $ysm \n"
         lappend xo $xsm
         lappend yo $ysm
         
         continue
      }


      continue
   }
   
   ::bdi_gui_astrometry::analyse_graph_init
   # Trace
   set hmove [::plotxy::plot $xo $yo 0]
   plotxy::sethandler $hmove [list -color green -linewidth 0]

}





proc ::bdi_gui_astrometry::id_ref_to_xy { l p_listsources } {
   upvar $p_listsources listsources
   set id     [lindex $l 0]
   set name   [lindex $l 4]
   set s [lindex $listsources [list 1 $id] ]
   set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
   set flagastrom [::bdi_tools_psf::get_val othf "flagastrom"]
   if {$flagastrom == ""} {return -code 1}
   set xsm  [::bdi_tools_psf::get_val othf "xsm"]
   set ysm  [::bdi_tools_psf::get_val othf "ysm"]
   return [list $name $xsm $ysm]
}


proc ::bdi_gui_astrometry::id_ref_to_radec { l p_listsources } {
   upvar $p_listsources listsources
   set id     [lindex $l 0]
   set name   [lindex $l 4]
   set s [lindex $listsources [list 1 $id] ]
   set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
   set flagastrom [::bdi_tools_psf::get_val othf "flagastrom"]
   if {$flagastrom == ""} {return -code 1}
   set ra    [::bdi_tools_psf::get_val othf "ra"]
   set dec   [::bdi_tools_psf::get_val othf "dec"]
   set fwhmx [::bdi_tools_psf::get_val othf "fwhmx"]
   set fwhmy [::bdi_tools_psf::get_val othf "fwhmy"]
   set mag   [::bdi_tools_psf::get_val othf "mag"]


   return [list $name $ra $dec $fwhmx $fwhmy $mag $id]
}


proc ::bdi_gui_astrometry::analyse_distances_etoile { } {

   global bddconf

   gren_info "Centrage sur l etoile : $::bdi_gui_astrometry::widget(analyse,source,selected,name)\n"
   
   set tt0 [clock clicks -milliseconds]

   # Calcul des distances 
   set id_current_image 0
   foreach current_image $::tools_cata::img_list {

      incr id_current_image
      set current_listsources $::bdi_gui_cata::cata_list($id_current_image)
      set distance($id_current_image) ""
      
      foreach l1 [::tools_cata::get_id_astrometric "R" current_listsources] {
         lassign [::bdi_gui_astrometry::id_ref_to_xy $l1 current_listsources] name1 xsm1 ysm1
         lappend distance($id_current_image) $l1
         set distance($id_current_image,$name1) ""

         foreach l2 [::tools_cata::get_id_astrometric "R" current_listsources] {
            lassign [::bdi_gui_astrometry::id_ref_to_xy $l2 current_listsources] name2 xsm2 ysm2
            lappend distance($id_current_image,$name1) $l2

            set distance($id_current_image,$name1,$name2,x) [expr ($xsm2 - $xsm1)]
            set distance($id_current_image,$name1,$name2,y) [expr ($ysm2 - $ysm1)]

            continue
         }
         continue
      }
      
      # Fin des images
      continue
   }

   set fileres [file join $bddconf(dirtmp) "distances.csv"]
   set chan0 [open $fileres w]
   puts $chan0 "# name, id, ra (deg), dec (deg), fwhm_x (px), fwhm_y (px), mag, jd, dracosdec (arcsec), ddec (arcsec), r (arcsec), Azimut (deg), Hauteur (deg), Angle horaire (deg), Angle parallactique (deg)"

   set home {MPCSTATION $::bdi_tools_astrometry::rapport_uai_code "/usr/local/src/audela/gui/audace/catalogues/obscodes.txt"}

   set xo ""
   set yo ""
   set factor 100.0
   set id_current_image 0

   foreach current_image $::tools_cata::img_list {

      incr id_current_image
      set current_listsources $::bdi_gui_cata::cata_list($id_current_image)
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set dateobsjd [::bddimages_liste::lget $current_image "commundatejj"]

      # Facteur d'echelle en x en arcsec
      if {[::bddimages_liste::lexist $tabkey "CDELT1"] == 0} {
         set cdelt1 1.0
      } else {
         set cdelt1 [expr [lindex [::bddimages_liste::lget $tabkey "CDELT1"] 1 ]*3600.0]
      }
      # Facteur d'echelle en y en arcsec
      if {[::bddimages_liste::lexist $tabkey "CDELT1"] == 0} {
         set cdelt2 1.0
      } else {
         set cdelt2 [expr [lindex [::bddimages_liste::lget $tabkey "CDELT2"] 1 ]*3600.0]
      }

      foreach l1 $distance($id_current_image) {
         lassign [::bdi_gui_astrometry::id_ref_to_radec $l1 current_listsources] name1 ra1 dec1 fwhmx1 fwhmy1 mag1 id1
         set altaz [mc_radec2altaz $ra1 $dec1 $home $dateobsjd]

         foreach l2 $distance($id_current_image,$name1) {
            set name2 [lindex $l2 4]

            if {$id_current_image > 1} {
            
               if {![info exists distance([expr $id_current_image-1],$name1,$name2,x)]} { continue }
               if {![info exists distance([expr $id_current_image-1],$name1,$name2,y)]} { continue }

               set dx [expr ($distance($id_current_image,$name1,$name2,x) - $distance([expr $id_current_image-1],$name1,$name2,x))*$cdelt1*cos($dec1)]
               set dy [expr ($distance($id_current_image,$name1,$name2,y) - $distance([expr $id_current_image-1],$name1,$name2,y))*$cdelt2]

               #lappend xo $dx
               #lappend yo $dy
               lappend xo [expr $ra1  + $factor*$dx/3600.0]
               lappend yo [expr $dec1 + $factor*$dy/3600.0]

               puts $chan0 "$name1, $id1, $ra1, $dec1, $fwhmx1, $fwhmy1, $mag1, $dateobsjd, $dx, $dy, [expr sqrt($dx*$dx+$dy*$dy)], [lindex $altaz 0], [lindex $altaz 1], [lindex $altaz 2], [lindex $altaz 3]"

            }
            continue
         }
         continue
      }
      continue
   }

   close $chan0
   gren_info "Visualisation des resultats: topcat -f csv $fileres\n"

   set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
   gren_info "Fin in $tt_total seconds\n"

   ::bdi_gui_astrometry::analyse_graph_init
   # Trace
   set hmove [::plotxy::plot $xo $yo 0]
   plotxy::sethandler $hmove [list -color green -linewidth 0]

}

