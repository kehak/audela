## @file bdi_gui_verifcata.tcl
#  @brief     M&eacute;thodes d&eacute;&eacute;es &agrave; la verification des catas de bddimages
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_verifcata.tcl]
#  @endcode

# $Id: bdi_gui_verifcata.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace tools_verifcata
# @brief M&eacute;thodes d&eacute;&eacute;es &agrave; la verification des catas de bddimages
# @warning Outil en d&eacute;veloppement
#
namespace eval ::tools_verifcata {

}


#------------------------------------------------------------
## Verification d'une liste de sources
#  @return void
#
proc ::tools_verifcata::verif { send_source_list send_date_list } {

   upvar $send_source_list source_list
   upvar $send_date_list   date_list

   set date_list ""
   set source_list ""

   set ::tools_cata::id_current_image 0
   foreach ::tools_cata::current_image $::tools_cata::img_list {

      incr ::tools_cata::id_current_image
      set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
      set ::tools_cata::current_image_date [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      set ::tools_cata::current_image_name [::bddimages_liste::lget $::tools_cata::current_image "filename"]
      ::bdi_gui_cata::load_cata

      set idd $::tools_cata::id_current_image
      set listsources $::tools_cata::current_listsources
      set ::bdi_gui_cata::cata_list($::tools_cata::id_current_image) $listsources
      
      set staraster 0
      set catadouble 0
      set cataastrom 0
      set cataskybot 0
      set err 0
      set warn 0

      set sources [lindex $listsources 1] 
      set ids 0
      foreach s $sources {

         incr ids
         set star  "n"
         set aster "n"
         set catas ""
         set doubl "n"
         set skybotmes ""

         foreach cata $s {
            set name [lindex $cata 0]

            # Test si plusieurs catas du meme nom pour une meme source
            set p [lsearch $catas $name]
            if {$p != -1} {
               incr err
               incr catadouble
               set doubl "y"
            }

            # identifie la source, stellaire ou systeme solaire
            append catas " $name"
            switch $name {
                "SKYBOT"   { set aster "y" } 
                "GAIA1"    - 
                "TYCHO2"   - 
                "2MASS"    - 
                "PPMX"     - 
                "PPMXL"    - 
                "USNOA2"   - 
                "WFIBC"    -
                "SDSS"     -
                "PANSTARR" -
                "UCAC2"    - 
                "UCAC3"    -
                "UCAC4"    { set star  "y" } 
                default    {}
            }
            
         }
         # Denomination de la source
         set namable [::manage_source::namable $s]
         if {$namable==""} {
            set namesource ""
         } else {
            set namesource [::manage_source::naming $s $namable]
         } 

         # Test si plusieurs catas du meme nom pour une meme source
         if {$doubl == "y"} {
            lappend source_list [list $ids $idd $::tools_cata::current_image_date "DoubleCata" $namesource $catas]
         }

         # Test si la source est a la fois stellaire et systeme solaire
         if {$star == "y" && $aster == "y"} {
            lappend source_list [list $ids $idd $::tools_cata::current_image_date "Star&Aster" $namesource $catas]
            incr staraster
            incr err
         }

         # Test si le flag cataastrom pointe bien sur la bonne source
         set p [lsearch -index 0 $s "ASTROID"]
         if {$p != -1} {
            set othf [lindex [lindex $s $p] 2]
            set ar [::bdi_tools_psf::get_val othf "flagastrom"]
            set ac [::bdi_tools_psf::get_val othf "cataastrom"]
            if {$ar == "S" || $ar == "R"} {
               set p [lsearch -index 0 $s $ac]
               if {$p == -1} {
                  incr err
                  incr cataastrom
                  lappend source_list [list $ids $idd $::tools_cata::current_image_date "CataAstrom" $namesource $catas]
               }
            }
         }

         # Test si la source SKYBOT est selectionnee comme mesure
         set p [lsearch -index 0 $s "SKYBOT"]
         if {$p != -1} {
            set q [lsearch -index 0 $s "ASTROID"]
            if {$q != -1} {
               set othf [lindex [lindex $s $q] 2]
               set ar [::bdi_tools_psf::get_val othf "flagastrom"]
               set ac [::bdi_tools_psf::get_val othf "cataastrom"]
               if {$ar != "S"} {
                  set p [lsearch -index 0 $s $ac]
                  if {$p == -1} {
                     incr warn
                     incr cataskybot
                     lappend source_list [list $ids $idd $::tools_cata::current_image_date "SkybotNOTScience" $namesource $catas]
                  }
               }
            } else {
               # La source SKYBOT n'est pas dans ASTROID !
               incr warn
               incr cataskybot
               lappend source_list [list $ids $idd $::tools_cata::current_image_date "SkybotNOTAstroid" $namesource $catas]
            }
         }

         # Test la distance entre les catalogues d une meme source
         # calcul de la position moyenne
         set xl ""
         set yl ""
         foreach cata $s {
            set name_0 [lindex $cata 0]
            if {$name_0 == "ASTROID"} {
               set othf [lindex $cata 2]
               if {[::bdi_tools_psf::get_val othf "err_psf"] != "-"} {
                  continue
               }
            }
            set ra_0  [lindex $cata {1 0}]
            set dec_0 [lindex $cata {1 1}]
            set xy [::bdi_tools_psf::get_xy s $name_0]
            lappend xl [lindex $xy 0]
            lappend yl [lindex $xy 1]
         }
         set xm [::math::statistics::median $xl]
         set ym [::math::statistics::median $yl]

         foreach cata $s {
            set name_0 [lindex $cata 0]
            if {$name_0 == "ASTROID"} {
               set othf [lindex $cata 2]
               if {[::bdi_tools_psf::get_val othf "err_psf"] != "-"} {
                  continue
               }
            }
            set ra_0  [lindex $cata {1 0}]
            set dec_0 [lindex $cata {1 1}]
            set xy [::bdi_tools_psf::get_xy s $name_0]
            if {[expr abs([lindex $xy 0] - $xm)] > $::tools_verifcata::rdiff} {
               lappend source_list [list $ids $idd $::tools_cata::current_image_date "CataTooFar_X_${name_0}" $namesource $catas]
            } else {
               if {[expr abs([lindex $xy 1] - $ym)] > $::tools_verifcata::rdiff} { 
                  lappend source_list [list $ids $idd $::tools_cata::current_image_date "CataTooFar_Y_${name_0}" $namesource $catas]
               }
            }
            
         }


      }

      if {$err} { lappend date_list [list $ids $idd $idd $staraster $catadouble $cataastrom] }
   }

}



#------------------------------------------------------------
## Verification d'une liste de sources
#  @return void
#
proc ::tools_verifcata::verif_in_get_cata { p_listsources } {

   upvar $p_listsources listsources
       
   set staraster 0
   set catadouble 0
   set cataastrom 0
   set err 0
   set log 0
   
   if {![info exists ::tools_verifcata::rdiff]} {set ::tools_verifcata::rdiff 3}

   set fields  [lindex $listsources 0] 
   set sources [lindex $listsources 1] 

   set ids 0
   set new_sources {}
   
   foreach s $sources {

      incr ids
      set star  "n"
      set aster "n"
      set catas ""
      set doubl "n"
      set new_s0 {}
      set new_s1 {}
      foreach cata $s {
         set name [lindex $cata 0]

         # Test si plusieurs catas du meme nom pour une meme source
         set p [lsearch $catas $name]
         if {$p!=-1} {
            incr err
            incr catadouble
            if {$log==1} {gren_info "($ids) Double Cata\n"}
            lappend new_s1 $cata
            continue
         }
         
         # identifie la source, stellaire ou systeme solaire
         append catas " $name"
         switch $name {
             "SKYBOT"    { set aster "y" } 
             "GAIA1"     - 
             "TYCHO2"    - 
             "2MASS"     - 
             "PPMX"      - 
             "PPMXL"     - 
             "USNOA2"    - 
             "WFIBC"     -
             "SDSS"      -
             "PANSTARRS" -
             "UCAC2"     - 
             "UCAC3"     -
             "UCAC4"     { set star  "y" } 
             default     {}
         }
         
      }

      # Test si la source est a la fois stellaire et systeme solaire
      if {$star == "y" && $aster == "y"} {
         lappend new_s1 $cata
         if {$log==1} {gren_info "($ids) Star&Aster\n"}
         incr err
         continue
      }
      
      # Test la distance entre les catalogues d une meme source
      # calcul de la position mediane
      set xl ""
      set yl ""
      foreach cata $s {
         set name_0 [lindex $cata 0]
         if {$name_0=="ASTROID"} {
            set othf [lindex $cata 2]
            if {[::bdi_tools_psf::get_val othf "err_psf"]!="-"} {
               continue
            }
         }
         set ra_0  [lindex $cata {1 0}]
         set dec_0 [lindex $cata {1 1}]
         set xy [::bdi_tools_psf::get_xy s $name_0]
         lappend xl [lindex $xy 0]
         lappend yl [lindex $xy 1]
      }
      set xm [format "%.0f" [::math::statistics::median $xl] ]
      set ym [format "%.0f" [::math::statistics::median $yl] ]

      foreach cata $s {
         set name_0 [lindex $cata 0]
         if {$name_0=="ASTROID"} {
            set othf [lindex $cata 2]
            if {[::bdi_tools_psf::get_val othf "err_psf"]!="-"} {
               continue
            }
         }
         set ra_0  [lindex $cata {1 0}]
         set dec_0 [lindex $cata {1 1}]
         set xy [::bdi_tools_psf::get_xy s $name_0]
         set x [format "%.0f" [lindex $xy 0]]
         set y [format "%.0f" [lindex $xy 1]]
         if {[expr abs($x - $xm)] > $::tools_verifcata::rdiff} {
            if {$log==1} {gren_info "($ids) CataTooFar_X_${name_0} $xm <==> ($x) $y \n"}
            incr err
         } else {
            if {[expr abs($y - $ym)] > $::tools_verifcata::rdiff} { 
               if {$log==1} {gren_info "($ids) CataTooFar_Y_${name_0} $ym <==> $x ($y)\n"}
               incr err
            } else {
               lappend new_s0 $cata
            }
         }
         
      }

   }

   return -code 0 "Verification sources: nb err / nb sources = $err / $ids"

}
