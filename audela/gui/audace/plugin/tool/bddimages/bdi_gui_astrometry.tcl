## @file bdi_gui_astrometry.tcl
#  @brief     GUI de mesure astrom&eacute;trique en mode manuel.
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_astrometry.tcl]
#  @endcode

# $Id: bdi_gui_astrometry.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_astrometry
# @brief GUI de mesure astrom&eacute;trique en mode manuel.
# @pre Requiert \c bdi_tools_astrometry .
# @warning Outil en d&eacute;veloppement
# @todo Sauver les infos MPC dans le header de l'image
#
namespace eval ::bdi_gui_astrometry {

   variable factor

   variable rapport_info
   variable rapport_xml
   variable rapport_xml_obj
   variable rapport_txt_obj
   variable rapport_mpc_obj

}


#----------------------------------------------------------------------------
## Initialisation des variables de namespace
#  \details   Si la variable n'existe pas alors on va chercher
#             dans la variable globale \c conf
#  \sa        gui_cata::inittoconf
proc ::bdi_gui_astrometry::inittoconf {  } {

   ::bdi_tools_astrometry::inittoconf

   set ::bdi_gui_astrometry::state_gestion 0
   set ::bdi_gui_astrometry::object_list {}
   set ::bdi_gui_astrometry::factor 1000

}


#----------------------------------------------------------------------------
## Fermeture de la fenetre Astrometrie.
# Les variables utilisees sont affectees a la variable globale
# \c conf
proc ::bdi_gui_astrometry::fermer {  } {

   ::bdi_tools_astrometry::closetoconf
   ::bdi_gui_astrometry::recup_position
   destroy $::bdi_gui_astrometry::fen
   cleanmark

}


#------------------------------------------------------------
## Recuperation de la position d'affichage de la GUI
#  @return void
#
proc ::bdi_gui_astrometry::recup_position { } {

   global conf bddconf

   set bddconf(geometry_astrometry) [wm geometry $::bdi_gui_astrometry::fen]
   set conf(bddimages,geometry_astrometry) $bddconf(geometry_astrometry)

}


#----------------------------------------------------------------------------
## Effacement des sources dans worklist
#  @param p_worklist pointeur sur la worklist
proc ::bdi_gui_astrometry::delete_worklist { p_worklist } {

   upvar $p_worklist worklist

   foreach w $worklist {

      set idimg [lindex $w 0]
      set ids [lindex $w 1]
      set listsources $::bdi_gui_cata::cata_list($idimg)
      set fields [lindex $listsources 0]
      set sources [lindex $listsources 1]
      set s [lindex $sources [expr $ids-1]]

      set x [lsearch -index 0 $s "ASTROID"]
      if {$x >= 0} {
         set astroid [lindex $s $x]
         set othf [lindex $astroid 2]
         ::bdi_tools_psf::set_by_key othf "flagastrom" ""
         ::bdi_tools_psf::set_by_key othf "cataastrom" ""
         set astroid [lreplace $astroid 2 2 $othf]
         set s [lreplace $s $x $x $astroid]
         set sources [lreplace $sources [expr $ids-1] [expr $ids-1] $s]
         set ::bdi_gui_cata::cata_list($idimg) [list $fields $sources]
      }

   }

}


#----------------------------------------------------------------------------
## Fonction qui est appelee lors d'un clic gauche dans la table
# des references (parent / table de gauche)
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::cmdButton1Click_srpt { w args } {

   
   gren_info "Nb selected = [llength [$w curselection]] \n"
   foreach select [$w curselection] {
      set name [lindex [$w get $select] 0]
      #gren_info "srpt name = $name \n"
      set ::bdi_tools_astrometry::srpt_selected $name
      # Construit la table enfant
      $::bdi_gui_astrometry::sret delete 0 end
      foreach date $::bdi_tools_astrometry::listref($name) {
         $::bdi_gui_astrometry::sret insert end [lreplace $::bdi_tools_astrometry::tabval($name,$date) 1 2 $date]
      }

      # Affiche un rond sur la source
      ::bdi_gui_cata::voir_sxpt $::bdi_gui_astrometry::srpt

      set ::bdi_gui_astrometry::srpt_name $name

      break
   }

}


#----------------------------------------------------------------------------
## Fonction qui unset les references de toutes les images
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::unset_srpt { w args } {

   set worklist {}

   foreach select [$w curselection] {
      set name [lindex [$w get $select] 0]
      gren_info "Delete $name \n"
      foreach date $::bdi_tools_astrometry::listref($name) {
         set idsource [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
         lappend worklist [list $::tools_cata::date2id($date) $idsource]
      }
   }
   
   ::bdi_gui_astrometry::delete_worklist worklist
   unset worklist

   ::bdi_gui_astrometry::affich_gestion

}


#----------------------------------------------------------------------------
## Fonction qui unset les references d'une liste de dates
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::unset_sret { w args } {

   set worklist {}

   set name $::bdi_gui_astrometry::srpt_name

   foreach select [$w curselection] {
      set dateiso [lindex [$w get $select] 1]
      set idsource [lindex $::bdi_tools_astrometry::tabval($name,$dateiso) 0]
      lappend worklist [list $::tools_cata::date2id($dateiso) $idsource]
   }
   
   ::bdi_gui_astrometry::delete_worklist worklist
   unset worklist

   ::bdi_gui_astrometry::affich_gestion

   # ReConstruit la table enfant
   $::bdi_gui_astrometry::sret delete 0 end
   foreach date $::bdi_tools_astrometry::listref($name) {
      $::bdi_gui_astrometry::sret insert end [lreplace $::bdi_tools_astrometry::tabval($name,$date) 1 2 $date]
   }

}

#----------------------------------------------------------------------------
## Fonction qui unset les references de toutes les images
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::unset_sat { w args } {

   set worklist {}
   
   foreach select [$w curselection] {
      set ids  [lindex [$w get $select] 0]
      set name [lindex [$w get $select] 1]
      set date [lindex [$w get $select] 2]
      lappend worklist [list $::tools_cata::date2id($date) $ids]
   }
   
   ::bdi_gui_astrometry::delete_worklist worklist
   unset worklist

   ::bdi_gui_astrometry::affich_gestion

}

#----------------------------------------------------------------------------
## Fonction qui est appelee lors d'un clic gauche dans la table
# des sciences (parent / table de gauche)
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::cmdButton1Click_sspt { w args } {

   foreach select [$w curselection] {
      set name [lindex [$w get $select] 0]
      #gren_info "sspt name = $name \n"
      set ::bdi_tools_astrometry::sspt_selected $name

      # Construit la table enfant
      $::bdi_gui_astrometry::sset delete 0 end
      foreach date $::bdi_tools_astrometry::listscience($name) {
         $::bdi_gui_astrometry::sset insert end [lreplace $::bdi_tools_astrometry::tabval($name,$date) 1 2 $date]
      }

      # Affiche un rond sur la source
      ::bdi_gui_cata::voir_sxpt $::bdi_gui_astrometry::sspt

      set ::bdi_gui_astrometry::sspt_name $name
      break
   }

}


#----------------------------------------------------------------------------
## Fonction qui unset les sciences de toutes les images
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::unset_sspt { w args } {

   set worklist {}

   foreach select [$w curselection] {

      set name [lindex [$w get $select] 0]
      gren_info "Delete $name \n"
      foreach date $::bdi_tools_astrometry::listscience($name) {
         set idsource [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
         lappend worklist [list $::tools_cata::date2id($date) $idsource]
      }

   }
   
   ::bdi_gui_astrometry::delete_worklist worklist
   unset worklist

   ::bdi_gui_astrometry::affich_gestion

}


#----------------------------------------------------------------------------
## Fonction qui unset les science d'une liste de dates
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::unset_sset { w args } {

   set worklist {}

   set name $::bdi_gui_astrometry::sspt_name

   foreach select [$w curselection] {
      set dateiso [lindex [$w get $select] 1]
      set idsource [lindex $::bdi_tools_astrometry::tabval($name,$dateiso) 0]
      lappend worklist [list $::tools_cata::date2id($dateiso) $idsource]
   }
   
   ::bdi_gui_astrometry::delete_worklist worklist
   unset worklist

   ::bdi_gui_astrometry::affich_gestion

   # ReConstruit la table enfant
   $::bdi_gui_astrometry::sset delete 0 end
   foreach date $::bdi_tools_astrometry::listscience($name) {
      $::bdi_gui_astrometry::sset insert end [lreplace $::bdi_tools_astrometry::tabval($name,$date) 1 2 $date]
   }

}



#----------------------------------------------------------------------------
## Fonction qui est appelee lors d'un clic gauche dans la table
# des dates et sources (parent / table de gauche)
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::cmdButton1Click_dspt { w args } {

   foreach select [$w curselection] {
      set date [lindex [$w get $select] 0]
      #gren_info "dspt date = $date \n"
      set ::bdi_tools_astrometry::dspt_selected $date
      # Charge l'image correspondante
      ::bdi_gui_cata::voirimg_dspt
      # Construit la table enfant
      $::bdi_gui_astrometry::dset delete 0 end
      foreach name $::bdi_tools_astrometry::listdate($date) {
         $::bdi_gui_astrometry::dset insert end [lreplace $::bdi_tools_astrometry::tabval($name,$date) 1 1 $name]
      }

      break
   }

}


#----------------------------------------------------------------------------
## Fonction qui unset une liste de dates
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::unset_dspt { w args } {

   set worklist {}

   foreach select [$w curselection] {
      set date [lindex [$w get $select] 0]
      gren_info "Delete $date \n"
      foreach name $::bdi_tools_astrometry::listdate($date) {
         set idsource [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
         lappend worklist [list $::tools_cata::date2id($date) $idsource]
      }
   }
   
   ::bdi_gui_astrometry::delete_worklist worklist
   unset worklist

   ::bdi_gui_astrometry::affich_gestion

}


#----------------------------------------------------------------------------
## Fonction qui est appelee lors d'un clic gauche dans la table
# des dates et sources (enfant / table de droite)
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::cmdButton1Click_dset { w args } {

   foreach select [$w curselection] {
      set name [lindex [$w get $select] 1]
      gren_info "dset name = $name \n"

      # Affiche un rond sur la source
      ::bdi_gui_cata::voir_dset $::bdi_gui_astrometry::dset

      break
   }

}


#----------------------------------------------------------------------------
## Fonction qui unset une liste de source dans une image
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::unset_dset { w args } {

   set worklist {}

   set date $::bdi_tools_astrometry::dspt_selected

   foreach select [$w curselection] {
      set name [lindex [$w get $select] 1]
      set idsource [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
      lappend worklist [list $::tools_cata::date2id($date) $idsource]
   }
   
   ::bdi_gui_astrometry::delete_worklist worklist
   unset worklist
   
   ::bdi_gui_astrometry::affich_gestion
   
   # ReConstruit la table enfant
   $::bdi_gui_astrometry::dset delete 0 end
   foreach name $::bdi_tools_astrometry::listdate($date) {
      $::bdi_gui_astrometry::dset insert end [lreplace $::bdi_tools_astrometry::tabval($name,$date) 1 1 $name]
   }

}



#----------------------------------------------------------------------------
## Fonction qui est appelee lors d'un clic gauche dans la table
# des dates et wcs (parent / table de gauche)
#  @param w    selection tklist
#  @param args argument non utilise
proc ::bdi_gui_astrometry::cmdButton1Click_dwpt { w args } {

   global bddconf

   cleanmark

   foreach select [$w curselection] {
      set date [lindex [$w get $select] 0]
      gren_info "Selected date = $date \n"

      # Charge l'image correspondante
      ::bdi_gui_cata::voirimg_dwpt

      # Charge la table
      set id $::bdi_tools_astrometry::date_to_id($date)
      set tabkey [::bddimages_liste::lget [lindex $::tools_cata::img_list [expr $id -1] ] "tabkey"]
      set datei   [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      gren_info "  Id img = $id -> date = $datei \n"

      #::bdi_gui_astrometry::voir_dwet %w

      $::bdi_gui_astrometry::dwet delete 0 end
      foreach val $::tools_cata::new_astrometry($id) {
         # Insere une entree dans la table
         $::bdi_gui_astrometry::dwet insert end $val

         if {[lindex $val 0] == "RA"}     { set RA     [lindex $val 1]}
         if {[lindex $val 0] == "DEC"}    { set DEC    [lindex $val 1]}
         if {[lindex $val 0] == "CRVAL1"} { set CRVAL1 [lindex $val 1]}
         if {[lindex $val 0] == "CRVAL2"} { set CRVAL2 [lindex $val 1]}
         if {[lindex $val 0] == "CDELT1"} { set CDELT1 [lindex $val 1]}
         if {[lindex $val 0] == "CDELT2"} { set CDELT2 [lindex $val 1]}
         if {[lindex $val 0] == "CRPIX1"} { set CRPIX1 [lindex $val 1]}
         if {[lindex $val 0] == "CRPIX2"} { set CRPIX2 [lindex $val 1]}
      }

      # Affiche une marque pour le centre theorique
      gren_info "astrom = $CRVAL1 $CRVAL2 \n"
      set imgxy_t [buf$::bddconf(bufno) radec2xy [list $CRVAL1 $CRVAL2]]
      gren_info "Centre theorique (x,y): $imgxy_t\n"
      affich_un_rond_xy [lindex $imgxy_t 0] [lindex $imgxy_t 1] red 6 2
      # Affiche une marque pour le centre optique
      set imgxy_o [buf$::bddconf(bufno) radec2xy [list $RA $DEC]]
      gren_info "Centre optique (x,y): $imgxy_o\n"
      affich_un_rond_xy [lindex $imgxy_o 0] [lindex $imgxy_o 1] red 4 2

      # Affiche les reperes
      ::bdi_gui_cata::trace_reticule [list $CRPIX1 $CRPIX2] DeepPink 1
      ::bdi_gui_cata::trace_reticule $imgxy_o DodgerBlue 1
      ::bdi_gui_cata::trace_repere_x [list $CDELT1 $CDELT2] 200 $imgxy_o red 2

      break
   }

}


#----------------------------------------------------------------------------


# **************************************
# TODO bdi_gui_astrometry.tcl A GARDER EN COMMENTAIRE POUR L'INSTANT
# **************************************
#proc ::bdi_gui_astrometry::rapport_get_ephem { send_listsources name middate } {
#
#   upvar $send_listsources listsources
#
#   global bddconf audace
#
#   gren_info "rapport_get_ephem $name [ mc_date2iso8601 $middate ]\n"
#
#   set cpts 0
#   set pass "no"
#   foreach s [lindex $listsources 1] {
#      set x  [lsearch -index 0 $s "ASTROID"]
#      if {$x>=0} {
#         set b  [lindex [lindex $s $x] 2]
#         set sourcename [lindex $b 24]
#
#         if {$sourcename == "-"} {
#
#            set namable [::manage_source::namable $s]
#            if {$namable==""} {
#               set sourcename ""
#            } else {
#               set sourcename [::manage_source::naming $s $namable]
#            }
#
#         }
#
#         if {$sourcename == $name} {
#
#            set sp [split $sourcename "_"]
#            set cata [lindex $sp 0]
#            set x [lsearch -index 0 $s $cata]
#            #gren_info "x,cata = $x :: $cata \n"
#            if {$x>=0 && $cata=="SKYBOT"} {
#               set b  [lindex [lindex $s $x] 2]
#               set pass "ok"
#               set type "aster"
#               set num [string trim [lindex $b 0] ]
#               set nom [string trim [lindex $b 1] ]
#               break
#            }
#            if {$x>=0 && $cata=="TYCHO2"} {
#               set b  [lindex [lindex $s $x] 2]
#               set pass "ok"
#               set type "star"
#               set nom [lindex [lindex $s $x] 0]
#               set num "[string trim [lindex $b 1]]_[string trim [lindex $b 2]]_1"
#               break
#            }
#            if {$x>=0 && ( $cata=="UCAC2" || $cata=="UCAC3" )  } {
#               set b  [lindex [lindex $s $x] 1]
#               set pass "ok"
#               set type "star"
#               set ra  [string trim [lindex $b 0] ]
#               set dec [string trim [lindex $b 1] ]
#               return [list $ra $dec "-" "-" "-" "-"]
#            }
#         } else {
#            continue
#         }
#
#      }
#   }
#
#   if {$pass == "no"} {
#      return [list "-" "-" "-" "-" "-" "-"]
#   }
#
#   set ephemcc_nom "-n $num"
#   if {$num == "-"} {
#      set num $nom
#      set ephemcc_nom "-nom \"$nom\""
#   }
#
#   set file [ file join $audace(rep_travail) cmd.ephemcc ]
#   set chan0 [open $file w]
#   puts $chan0 "#!/bin/sh"
#   puts $chan0 "LD_LIBRARY_PATH=/usr/local/lib:$::bdi_tools_astrometry::ifortlib"
#   puts $chan0 "export LD_LIBRARY_PATH"
#
#   switch $type { "star"  { set cmd "/usr/local/bin/ephemcc etoile -a $nom -n $num -j $middate -tp 1 -te 1 -tc 5 -uai $::bdi_tools_astrometry::rapport_uai_code -d 1 -e utc --julien" }
#                  "aster" { set cmd "/usr/local/bin/ephemcc asteroide $ephemcc_nom -j $middate -tp 1 -te 1 -tc 5 -uai $::bdi_tools_astrometry::rapport_uai_code -d 1 -e utc --julien" }
#                  default { set cmd ""}
#                }
#   puts $chan0 $cmd
#   close $chan0
#   set err [catch {exec sh ./cmd.ephemcc} msg]
#
#   set pass "yes"
#
#   if { $err } {
#      ::console::affiche_erreur "WARNING: EPHEMCC $err ($msg)\n"
#      set ra_imcce "-"
#      set dec_imcce "-"
#      set h_imcce "-"
#      set am_imcce "-"
#      set pass "no"
#   } else {
#
#      foreach line [split $msg "\n"] {
#         set line [string trim $line]
#         set c [string index $line 0]
#         if {$c == "#"} {continue}
#         set rd [regexp -inline -all -- {\S+} $line]
#         set tab [split $rd " "]
#         set rah [lindex $tab  2]
#         set ram [lindex $tab  3]
#         set ras [lindex $tab  4]
#         set ded [lindex $tab  5]
#         set dem [lindex $tab  6]
#         set des [lindex $tab  7]
#         set hd  [lindex $tab 17]
#         set hm  [lindex $tab 18]
#         set hs  [lindex $tab 19]
#         set am  [lindex $tab 20]
#         break
#      }
#      #gren_info "EPHEM RA = $rah $ram $ras; DEC = $ded $dem $des\n"
#      set ra_imcce [::bdi_tools::sexa2dec [list $rah $ram $ras] 15.0]
#      set dec_imcce [::bdi_tools::sexa2dec [list $ded $dem $des] 1.0]
#      set h_imcce [::bdi_tools::sexa2dec [list $hd $hm $hs] 1.0]
#      set am_imcce "-"
#      if {$am != "---"} { set am_imcce $am }
#   }
#
#   # Ephem du mpc
#   set ra_mpc  "-"
#   set dec_mpc "-"
#   set go_mpc 1
#   if {$go_mpc && $type == "aster"} {
#      #set middate 2456298.51579861110
#      #set num 20000
#      #set dateiso [ mc_date2iso8601 $middate ]
#      #set position [list GPS 0 E 43 2890]
#      #set ephem [vo_getmpcephem [string map {" " ""} $num] $dateiso $::bdi_tools_astrometry::rapport_uai_code]
#      #gren_info "EPHEM MPC ephem = $ephem\n"
#      #gren_info "CMD = vo_getmpcephem $num $dateiso $position\n"
#      set datejj  [format "%.9f"  $middate ]
#      if {[info exists ::bdi_gui_astrometry::jpl_ephem($datejj)]} {
#         set ra_mpc  [lindex $::bdi_gui_astrometry::jpl_ephem($datejj) 0]
#         set dec_mpc [lindex $::bdi_gui_astrometry::jpl_ephem($datejj) 1]
#      } else {
#         set ra_mpc  "-"
#         set dec_mpc "-"
#      }
#      #gren_info "CMD = vo_getmpcephem $num $dateiso $::bdi_tools_astrometry::rapport_uai_code   ||EPHEM MPC ($num) ; date =  $middate ; ra dec = $ra_mpc  $dec_mpc \n"
#
#   }
#
#   gren_info "EPHEM IMCCE RA = $ra_imcce; DEC = $dec_imcce\n"
#   #gren_info "EPHEM MPC RA = $ra_mpc; DEC = $dec_mpc\n"
#   return [list $ra_imcce $dec_imcce $ra_mpc $dec_mpc $h_imcce $am_imcce]
#
#}
# **************************************




proc ::bdi_gui_astrometry::get_data_report { name date } {

   set imcce [list "-" {"-" "-" "-" "-" "-"}]
   if {$::bdi_tools_astrometry::use_ephem_imcce && [array exists ::bdi_tools_astrometry::ephem_imcce]} {
      foreach key [array names ::bdi_tools_astrometry::ephem_imcce] {
         if {[regexp -all -- $name $key]} {
            set imcce [list "$key" $::bdi_tools_astrometry::ephem_imcce($name,$date)]
         }
      }
   }

   set jpl [list "-" {"-" "-" "-"}]
   if {$::bdi_tools_astrometry::use_ephem_jpl && [array exists ::bdi_tools_astrometry::ephem_jpl]} {
      foreach key [array names ::bdi_tools_astrometry::ephem_jpl] {
         if {[regexp -all -- $name $key]} {
            set jpl [list "$key" $::bdi_tools_astrometry::ephem_jpl($name,$date)]
         }
      }
   }

   return [list [list IMCCE $imcce] [list JPL $jpl]]

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::create_report_mpc {  } {

   # Defini le tableau contenant les rapports txt par objet
   array unset ::bdi_gui_astrometry::rapport_mpc_obj
   array set ::bdi_gui_astrometry::rapport_mpc_obj {}

   # Efface la zone de rapport
   $::bdi_gui_astrometry::rapport_mpc delete 0.0 end

   set pos_last_header_field_num 10

   # Entete
   set entete ""
   append entete "COD $::bdi_tools_astrometry::rapport_uai_code \n"
   append entete "CON $::bdi_tools_astrometry::rapport_rapporteur \n"
   if {[llength $::bdi_tools_astrometry::rapport_adresse]>0} {
      incr pos_last_header_field_num
      append entete "CON $::bdi_tools_astrometry::rapport_adresse \n"
   }
   if {[llength $::bdi_tools_astrometry::rapport_mail] > 0} {
      incr pos_last_header_field_num
      append entete "CON $::bdi_tools_astrometry::rapport_mail \n"
   }
   append entete "OBS $::bdi_tools_astrometry::rapport_observ \n"
   append entete "MEA $::bdi_tools_astrometry::rapport_reduc \n"
   append entete "TEL $::bdi_tools_astrometry::rapport_instru \n"
   append entete "NET $::bdi_tools_astrometry::rapport_cata \n"

   if {$::bdi_tools_astrometry::rapport_cata == "WFIBC"} {
      incr pos_last_header_field_num
      append entete "COM WFIBC : Reference Star Catalog from Assafin et al. 2010, 2012 A&A \n"
   }
   append entete "COM Software Reduction : Audela Bddimages Priam (http://www.audela.org) \n"
   append entete "ACK Batch $::bdi_tools_astrometry::rapport_batch \n"
   append entete "AC2 $::bdi_tools_astrometry::rapport_mail \n"

   $::bdi_gui_astrometry::rapport_mpc insert end $entete

   # Constant parameters
   # - Note 1: alphabetical publishable note or (those sites that use program codes) an alphanumeric
   #           or non-alphanumeric character program code => http://www.minorplanetcenter.net/iau/info/ObsNote.html
   set note1 " "
   # - C = CCD observations (default)
   set note2 "C"

#      $::bdi_gui_astrometry::rapport_mpc insert end "         1         2         3         4         5         6         7         8\n"
#      $::bdi_gui_astrometry::rapport_mpc insert end "12345678901234567890123456789012345678901234567890123456789012345678901234567890\n"

   # Format of MPC line
   set form "%13s%1s%1s%-17s%-12s%-12s         %6s      %3s\n"
   set nb 0
   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name y} $l {

      append ::bdi_gui_astrometry::rapport_mpc_obj($name) $entete

      set cata [::manage_source::name_cata $name]
      if {$cata != "SKYBOT"} {continue}

      set data_obj ""
      set nb_data_obj 0
      foreach date $::bdi_tools_astrometry::listscience($name) {
         # Rend effectif le crop du graphe
         if {[info exists ::bdi_gui_astrometry::graph_results($name,$date,good)]} {
            if {$::bdi_gui_astrometry::graph_results($name,$date,good)==0} {continue}
         }

         set alpha   [lindex $::bdi_tools_astrometry::tabval($name,$date) 6]
         set delta   [lindex $::bdi_tools_astrometry::tabval($name,$date) 7]
         set mag     [lindex $::bdi_tools_astrometry::tabval($name,$date) 8]

         set object  [::bdi_tools_mpc::convert_name $name]
         set datempc [::bdi_tools_mpc::convert_jd $::tools_cata::date2midate($date)]
         set ra_hms  [::bdi_tools_mpc::convert_hms $alpha]
         set dec_dms [::bdi_tools_mpc::convert_dms $delta]
         set magmpc  [::bdi_tools_mpc::convert_mag $mag]
         set obsuai  $::bdi_tools_astrometry::rapport_uai_code
         set txt [format $form $object $note1 $note2 $datempc $ra_hms $dec_dms $magmpc $obsuai]
         append data_obj $txt
         incr nb_data_obj
         incr nb
      }

      append ::bdi_gui_astrometry::rapport_mpc_obj($name) "NUM $nb_data_obj\n"
      append ::bdi_gui_astrometry::rapport_mpc_obj($name) "$data_obj"
      $::bdi_gui_astrometry::rapport_mpc insert end "$data_obj"

   }

   $::bdi_gui_astrometry::rapport_mpc insert $pos_last_header_field_num.0  "NUM $nb\n"
   $::bdi_gui_astrometry::rapport_mpc insert end  "\n\n\n"

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::stdev { tab fmt } {

   if {[llength $tab] > 1} {
      return [format $fmt [::math::statistics::stdev $tab] ]
   } else {
      return ""
   }
}


#----------------------------------------------------------------------------


# Structure de tabval :
#  0  id
#  1  field
#  2  ar
#  3  rho
#  4  res_ra
#  5  res_dec
#  6  ra
#  7  dec
#  8  mag
#  9  err_mag
# 10  err_xsm
# 11  err_ysm
# 12  fwhm_x
# 13  fwhm_y

# Future routine de calcul des resultats qui sera lancee par ephemeride et non plus a la creation du rapport
proc ::bdi_gui_astrometry::tabule { } {


   # Pour chaque objet SCIENCE
   foreach {name y} $l {

      if {[info exists tabcalc]} { unset tabcalc }

      set calc($name,name,short) [lrange [split $name "_"] 2 end]
      set nbobs 0

      foreach dateimg $::bdi_tools_astrometry::listscience($name) {

         # Rend effectif le crop du graphe
         if {[info exists ::bdi_gui_astrometry::graph_results($name,$dateimg,good)]} {
            if {$::bdi_gui_astrometry::graph_results($name,$dateimg,good)==0} {continue}
         }

         incr nbobs
         set idsource [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  0]
         gren_info "otabval($name,$dateimg) = $::bdi_tools_astrometry::tabval($name,$dateimg)\n"

         set rho   [format "%.4f"  [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  3]]
         set res_a [format "%.4f"  [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  4]]
         set res_d [format "%.4f"  [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  5]]
         set alpha [format "%.8f"  [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  6]]
         set delta [format "%+.8f" [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  7]]

         set val [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  8]
         set mag ""
         if {$val != ""} { set mag $val }
         set err_mag [format "%.3f" [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  9]]
         set err_x   [format "%.4f" [lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 10]]
         set err_y   [format "%.4f" [lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 11]]
         set fwhm_x  [format "%.4f" [lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 12]]
         set fwhm_y  [format "%.4f" [lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 13]]

         set ra_hms  [::bdi_tools_astrometry::convert_txt_hms [lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 6]]
         set dec_dms [::bdi_tools_astrometry::convert_txt_dms [lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 7]]
         set fwhm [format "%.4f"  [expr sqrt(pow([lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 12],2)+\
                                             pow([lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 13],2))] ]

         # Recupere les ephemerides de l'objet courant pour la date courante
         set all_ephem [::bdi_gui_astrometry::get_data_report $name $dateimg]

         # Ephemerides de l'IMCCE
         set eph_imcce     [lindex $all_ephem 0]
         #set midatejd      [lindex $eph_imcce {1 1 0}]
         #gren_info "eph_imcce = $eph_imcce\n"
         set ra_imcce_deg  [lindex $eph_imcce {1 1 1}]
         set dec_imcce_deg [lindex $eph_imcce {1 1 2}]
         set h_imcce_deg   [lindex $eph_imcce {1 1 3}]
         set am_imcce_deg  [lindex $eph_imcce {1 1 4}]

         # Ephemerides du JPL
         set eph_jpl       [lindex $all_ephem 1]
         #set midatejd [lindex $eph_jpl {1 1 0}]
         set ra_jpl_deg    [lindex $eph_jpl {1 1 1}]
         set dec_jpl_deg   [lindex $eph_jpl {1 1 2}]

         # Epoque du milieu de pose au format JD
         set midatejd $::tools_cata::date2midate($dateimg)

         # Epoque du milieu de pose au format ISO
         set midateiso "-"
         if {$midatejd != "-"} {
            set midateiso [mc_date2iso8601 $midatejd]
         }

         # OMC IMCCE
         if { $ra_imcce_deg == "" || $ra_imcce_deg == "-" } {
            set ra_imcce_omc "-"
         } else {
            set ra_imcce_omc [format "%+.4f" [expr ($alpha - $ra_imcce_deg) * 3600.0]]
            set ra_imcce [::bdi_tools_astrometry::convert_txt_hms $ra_imcce_deg]
         }
         if { $dec_imcce_deg == "" || $dec_imcce_deg == "-" } {
            set dec_imcce_omc "-"
         } else {
            set dec_imcce_omc [format "%+.4f" [expr ($delta - $dec_imcce_deg) * 3600.0]]
            set dec_imcce [::bdi_tools_astrometry::convert_txt_dms $dec_imcce_deg]
         }

         # OMC JPL
         if {$ra_jpl_deg == "-"} {
            set ra_jpl_omc "-"
         } else {
            set ra_jpl_omc [format "%+.4f" [expr ($alpha - $ra_jpl_deg) * 3600.0]]
            set ra_jpl [::bdi_tools_astrometry::convert_txt_hms $ra_jpl_deg]
         }
         if {$dec_jpl_deg == "-"} {
            set dec_jpl_omc "-"
         } else {
            set dec_jpl_omc [format "%+.4f" [expr ($delta - $dec_jpl_deg) * 3600.0]]
            set dec_jpl [::bdi_tools_astrometry::convert_txt_dms $dec_jpl_deg]
         }

         # CMC IMCCE-JPL
         if {$ra_imcce_deg == "-" || $ra_jpl_deg == "-"} {
            set ra_imccejpl_cmc "-"
         } else {
            set ra_imccejpl_cmc [format "%+.4f" [expr ($ra_imcce_deg - $ra_jpl_deg) * 3600.0]]
         }
         if {$dec_imcce_deg == "-" || $dec_jpl_deg == "-"} {
            set dec_imccejpl_cmc "-"
         } else {
            set dec_imccejpl_cmc [format "%+.4f" [expr ($dec_imcce_deg - $dec_jpl_deg) * 3600.0]]
         }

         # Definition de la structure de donnees pour les calculs de stat
         lappend tabcalc(datejj) $midatejd
         lappend tabcalc(alpha)  $alpha
         lappend tabcalc(delta)  $delta
         lappend tabcalc(res_a)  $res_a
         lappend tabcalc(res_d)  $res_d

         if {$ra_imcce_omc     != "-"} {lappend tabcalc(ra_imcce_omc)     $ra_imcce_omc}
         if {$dec_imcce_omc    != "-"} {lappend tabcalc(dec_imcce_omc)    $dec_imcce_omc}
         if {$ra_jpl_omc       != "-"} {lappend tabcalc(ra_jpl_omc)       $ra_jpl_omc}
         if {$dec_jpl_omc      != "-"} {lappend tabcalc(dec_jpl_omc)      $dec_jpl_omc}
         if {$ra_imccejpl_cmc  != "-"} {lappend tabcalc(ra_imccejpl_cmc)  $ra_imccejpl_cmc}
         if {$dec_imccejpl_cmc != "-"} {lappend tabcalc(dec_imccejpl_cmc) $dec_imccejpl_cmc}

         # Formatage de certaines valeurs
         if {$ra_imcce_deg  != "-"} {set ra_imcce_deg  [format "%.8f" $ra_imcce_deg]}
         if {$dec_imcce_deg != "-"} {set dec_imcce_deg [format "%.8f" $dec_imcce_deg]}
         if {$h_imcce_deg   != "-"} {set h_imcce_deg   [format "%.8f" $h_imcce_deg]}
         if {$am_imcce_deg  != "-"} {set am_imcce_deg  [format "%.8f" $am_imcce_deg]}
         if {$ra_jpl_deg    != "-"} {set ra_jpl_deg    [format "%.8f" $ra_jpl_deg ]}
         if {$dec_jpl_deg   != "-"} {set dec_jpl_deg   [format "%.8f" $dec_jpl_deg]}

         # Ajustement affichage
         set midatejd [string range "${midatejd}000000000000" 0 15]

         # Graphe
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,good)             1
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,idsource)         $idsource
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,datejj)           $midatejd
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra)               $alpha
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec)              $delta
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,res_a)            $res_a
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,res_d)            $res_d
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra_imcce_omc)     $ra_imcce_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec_imcce_omc)    $dec_imcce_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra_jpl_omc)       $ra_jpl_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec_jpl_omc)      $dec_jpl_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra_imccejpl_cmc)  $ra_imccejpl_cmc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec_imccejpl_cmc) $dec_imccejpl_cmc

         set calc($name,$dateimg,good)             1
         set calc($name,$dateimg,idsource)         $idsource
         set calc($name,$dateimg,middatejj)        $midatejd
         set calc($name,$dateimg,ra)               $alpha
         set calc($name,$dateimg,dec)              $delta
         set calc($name,$dateimg,ra_hms)           $ra_hms
         set calc($name,$dateimg,dec_dms)          $dec_dms
         set calc($name,$dateimg,res_a)            $res_a
         set calc($name,$dateimg,res_d)            $res_d
         set calc($name,$dateimg,ra_imcce_omc)     $ra_imcce_omc
         set calc($name,$dateimg,dec_imcce_omc)    $dec_imcce_omc
         set calc($name,$dateimg,ra_jpl_omc)       $ra_jpl_omc
         set calc($name,$dateimg,dec_jpl_omc)      $dec_jpl_omc
         set calc($name,$dateimg,ra_imccejpl_cmc)  $ra_imccejpl_cmc
         set calc($name,$dateimg,dec_imccejpl_cmc) $dec_imccejpl_cmc

         set calc($name,$dateimg,mag)              $mag
         set calc($name,$dateimg,err_mag)          $err_mag
         set calc($name,$dateimg,ra_imcce_deg)     $ra_imcce_deg
         set calc($name,$dateimg,dec_imcce_deg)    $dec_imcce_deg
         set calc($name,$dateimg,ra_jpl_deg)       $ra_jpl_deg
         set calc($name,$dateimg,dec_jpl_deg)      $dec_jpl_deg
         set calc($name,$dateimg,err_x)            $err_x
         set calc($name,$dateimg,err_y)            $err_y
         set calc($name,$dateimg,fwhm_x)           $fwhm_x
         set calc($name,$dateimg,fwhm_y)           $fwhm_y
         set calc($name,$dateimg,h_imcce_deg)      $h_imcce_deg
         set calc($name,$dateimg,am_imcce_deg)     $am_imcce_deg

      }

      set calc($name,mean,res_a)      [format "%.4f" [::math::statistics::mean  $tabcalc(res_a)]]
      set calc($name,mean,res_d)      [format "%.4f" [::math::statistics::mean  $tabcalc(res_d)]]
      set calc($name,mean,middatejj)  [::math::statistics::mean  $tabcalc(datejj)]
      set calc($name,mean,middateiso) [mc_date2iso8601 $calc($name,mean,middatejj)]
      set calc($name,mean,alpha)      [format "%16.12f"  [::math::statistics::mean  $tabcalc(alpha)]]
      set calc($name,mean,delta)      [format "%+15.12f" [::math::statistics::mean  $tabcalc(delta)]]
      set calc($name,mean,alphasexa)  [::bdi_tools_astrometry::convert_txt_hms $calc($name,mean,alpha)]
      set calc($name,mean,deltasexa)  [::bdi_tools_astrometry::convert_txt_dms $calc($name,mean,delta)]
      set calc($name,stdev,res_a)     [::bdi_gui_astrometry::stdev $tabcalc(res_a)  "%.4f"]
      set calc($name,stdev,res_d)     [::bdi_gui_astrometry::stdev $tabcalc(res_d)  "%.4f"]
      set calc($name,stdev,datejj)    [::bdi_gui_astrometry::stdev $tabcalc(datejj) "%.4f"]
      set calc($name,stdev,alpha)     [::bdi_gui_astrometry::stdev $tabcalc(alpha)  "%.4f"]
      set calc($name,stdev,delta)     [::bdi_gui_astrometry::stdev $tabcalc(delta)  "%.4f"]

      set pi [expr 2*asin(1.0)]

      # OMC IMCCE
      if {[info exists tabcalc(ra_imcce_omc)]} {
         set mean [::math::statistics::mean $tabcalc(ra_imcce_omc)]
         set mean [expr $mean * cos($calc($name,delta,mean) * $pi / 180.)]
         set calc($name,ra_imcce_omc,mean)  [format "%.4f" $mean]
         set calc($name,ra_imcce_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(ra_imcce_omc) "%.4f"]
      } else {
         set calc($name,ra_imcce_omc,mean)  "-"
         set calc($name,ra_imcce_omc,stdev) "-"
      }
      if {[info exists tabcalc(dec_imcce_omc)]} {
         set calc($name,dec_imcce_omc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_imcce_omc)]]
         set calc($name,dec_imcce_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(dec_imcce_omc) "%.4f"]
      } else {
         set calc($name,dec_imcce_omc,mean)   "-"
         set calc($name,dec_imcce_omc,stdev)  "-"
      }

      # OMC JPL
      if {[info exists tabcalc(ra_jpl_omc)]} {
         set mean [::math::statistics::mean  $tabcalc(ra_jpl_omc)]
         set mean [expr $mean * cos($calc($name,mean,delta) * $pi / 180.)]
         set calc($name,ra_jpl_omc,mean)  [format "%.4f" $mean]
         set calc($name,ra_jpl_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(ra_jpl_omc) "%.4f"]
      } else {
         set calc($name,ra_jpl_omc,mean)   "-"
         set calc($name,ra_jpl_omc,stdev)  "-"
      }
      if {[info exists tabcalc(dec_jpl_omc)]} {
         set calc($name,dec_jpl_omc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_jpl_omc)]]
         set calc($name,dec_jpl_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(dec_jpl_omc) "%.4f"]
      } else {
         set calc($name,dec_jpl_omc,mean)   "-"
         set calc($name,dec_jpl_omc,stdev)  "-"
      }

      # CMC IMCCE-JPL
      if {[info exists tabcalc(ra_imccejpl_cmc)]} {
         set calc($name,ra_imccejpl_cmc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(ra_imccejpl_cmc)]]
         set calc($name,ra_imccejpl_cmc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(ra_imccejpl_cmc) "%.4f"]
      } else {
         set calc($name,ra_imccejpl_cmc,mean)   "-"
         set calc($name,ra_imccejpl_cmc,stdev)  "-"
      }

      if {[info exists tabcalc(dec_imccejpl_cmc)]} {
         set calc($name,dec_imccejpl_cmc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_imccejpl_cmc)]]
         set calc($name,dec_imccejpl_cmc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(dec_imccejpl_cmc) "%.4f"]
      } else {
         set calc($name,dec_imccejpl_cmc,mean)   "-"
         set calc($name,dec_imccejpl_cmc,stdev)  "-"
      }

      if {$calc($name,res_a,mean)>=0} {set calc($name,res_a,mean) "+$calc($name,mean,res_a)" }
      if {$calc($name,res_d,mean)>=0} {set calc($name,res_d,mean) "+$calc($name,mean,res_d)" }
      if {$calc($name,res_a,stdev)>=0} {set calc($name,res_a,stdev) "+$calc($name,stdev,res_a)" }
      if {$calc($name,res_d,stdev)>=0} {set calc($name,res_d,stdev) "+$calc($name,stdev,res_d)" }

      if {$calc($name,ra_imcce_omc,mean)>=0} {set calc($name,ra_imcce_omc,mean) "+$calc($name,mean,ra_imcce_omc)" }
      if {$calc($name,dec_imcce_omc,mean)>=0} {set calc($name,dec_imcce_omc,mean) "+$calc($name,dec_imcce_omc,mean)" }
      if {$calc($name,ra_imcce_omc,stdev)>=0} {set calc($name,ra_imcce_omc,stdev) "+$calc($name,ra_imcce_omc,stdev)" }
      if {$calc($name,dec_imcce_omc,stdev)>=0} {set calc($name,dec_imcce_omc,stdev) "+$calc($name,dec_imcce_omc,stdev)" }

      if {$calc($name,ra_jpl_omc,mean)>=0} {set calc($name,ra_jpl_omc,mean) "+$calc($name,ra_jpl_omc,mean)" }
      if {$calc($name,dec_jpl_omc,mean)>=0} {set calc($name,dec_jpl_omc,mean) "+$calc($name,dec_jpl_omc,mean)" }
      if {$calc($name,ra_jpl_omc,stdev)>=0} {set calc($name,ra_jpl_omc,stdev) "+$calc($name,ra_jpl_omc,stdev)" }
      if {$calc($name,dec_jpl_omc,stdev)>=0} {set calc($name,dec_jpl_omc,stdev) "+$calc($name,dec_jpl_omc,stdev)" }

      if {$calc($name,ra_imccejpl_cmc,mean)>=0} {set calc($name,ra_imccejpl_cmc,mean) "+$calc($name,ra_imccejpl_cmc,mean)" }
      if {$calc($name,dec_imccejpl_cmc,mean)>=0} {set calc($name,dec_imccejpl_cmc,mean) "+$calc($name,dec_imccejpl_cmc,mean)" }
      if {$calc($name,ra_imccejpl_cmc,stdev)>=0} {set calc($name,ra_imccejpl_cmc,stdev) "+$calc($name,ra_imccejpl_cmc,stdev)" }
      if {$calc($name,dec_imccejpl_cmc,stdev)>=0} {set calc($name,dec_imccejpl_cmc,stdev) "+$calc($name,dec_imccejpl_cmc,stdev)" }

   }

}


#----------------------------------------------------------------------------


# ::bdi_tools_astrometry::tabval($name,$dateiso) = [list [expr $id + 1]  
#                                                        field  
#                                                        $ar  
#                                                        $rho  
#                                                        $res_ra  
#                                                        $res_dec  
#                                                        $ra  
#                                                        $dec 
#                                                        $mag  
#                                                        $err_mag 
#                                                        $err_xsm  
#                                                        $err_ysm  
#                                                        $fwhmx  
#                                                        $fwhmy ]

proc ::bdi_gui_astrometry::compute_final_results { } {

   set l [array get ::bdi_tools_astrometry::listscience]
   
   foreach {name y} $l {

      if {[info exists tabcalc]} { unset tabcalc }
   
      set tab_jd ""
      set tab_mag ""
      set tab_err_mag ""
      set tab_ra ""
      set tab_dec ""
      set tab_res ""

      set ::bdi_tools_astrometry::results_table($name,omc)     0
      set ::bdi_tools_astrometry::results_table($name,omc_std) 0
      set ::bdi_tools_astrometry::results_table($name,omcx)     0
      set ::bdi_tools_astrometry::results_table($name,omcx_std) 0
      set ::bdi_tools_astrometry::results_table($name,omcy)     0
      set ::bdi_tools_astrometry::results_table($name,omcy_std) 0

      set ::bdi_tools_astrometry::res_max_ref_stars  0
      set ::bdi_tools_astrometry::res_min_ref_stars  0
      set ::bdi_tools_astrometry::res_mean_ref_stars 0
      set ::bdi_tools_astrometry::res_std_ref_stars  0

      set nbobs 0
      foreach dateimg $::bdi_tools_astrometry::listscience($name) {

         # Rend effectif le crop du graphe
         if {[info exists ::bdi_gui_astrometry::graph_results($name,$dateimg,good)]} {
            if {$::bdi_gui_astrometry::graph_results($name,$dateimg,good)==0} {continue}
         }

         incr nbobs
         set r $::bdi_tools_astrometry::tabval($name,$dateimg)
         set idsource   [lindex $r  0]
         set rho        [lindex $r  3]
         set res_a      [lindex $r  4]
         set res_d      [lindex $r  5]
         set alpha      [lindex $r  6]
         set delta      [lindex $r  7]
         set mag        [lindex $r  8]
         set err_mag    [lindex $r  9]
         set err_xsm    [lindex $r 10]
         set err_ysm    [lindex $r 11]
         set fwhmx      [lindex $r 12]
         set fwhmy      [lindex $r 13]

         if {$mag == ""} {set mag "-"} else {lappend tab_mag $mag}
         if {$err_mag == ""} {set err_mag "-"} else {lappend tab_err_mag $mag}
         if {$err_xsm == ""} {set err_xsm "-"}
         if {$err_ysm == ""} {set err_ysm "-"}

         lappend tab_ra $alpha
         lappend tab_dec $delta
         set ra_hms  [::bdi_tools_astrometry::convert_txt_hms $alpha]
         set dec_dms [::bdi_tools_astrometry::convert_txt_dms $delta]

         lappend tab_res [expr sqrt((pow($res_a,2)+pow($res_d,2))/2)*1000]

         # Recupere les ephemerides de l'objet courant pour la date courante
         set all_ephem [::bdi_gui_astrometry::get_data_report $name $dateimg]

         # Ephemerides de l'IMCCE
         set eph_imcce     [lindex $all_ephem 0]

         #set midatejd      [lindex $eph_imcce {1 1 0}]
         #gren_info "eph_imcce = $eph_imcce\n"
         set ra_imcce_deg  [lindex $eph_imcce {1 1 1}]
         set dec_imcce_deg [lindex $eph_imcce {1 1 2}]
         set h_imcce_deg   [lindex $eph_imcce {1 1 3}]
         set am_imcce_deg  [lindex $eph_imcce {1 1 4}]

         # Ephemerides du JPL
         set eph_jpl       [lindex $all_ephem 1]
         #set midatejd [lindex $eph_jpl {1 1 0}]
         set ra_jpl_deg    [lindex $eph_jpl {1 1 1}]
         set dec_jpl_deg   [lindex $eph_jpl {1 1 2}]

         # Epoque du milieu de pose au format JD
         set midatejd $::tools_cata::date2midate($dateimg)
         lappend tab_jd $midatejd

         # Epoque du milieu de pose au format ISO
         set midateiso "-"
         if {$midatejd != "-"} {
            set midateiso [mc_date2iso8601 $midatejd]
         }

         # OMC IMCCE
         #gren_info "ra_imcce_deg = $ra_imcce_deg\n"
         if { $ra_imcce_deg == "" || $ra_imcce_deg == "-" } {
            set ra_imcce_omc "-"
         } else {
            #gren_info "ra_imcce_deg = $ra_imcce_deg\n"
            set ra_imcce_omc [format "%+.4f" [expr ($alpha - $ra_imcce_deg) * 3600.0]]
            set ra_imcce [::bdi_tools_astrometry::convert_txt_hms $ra_imcce_deg]
         }
         if { $dec_imcce_deg == "" || $dec_imcce_deg == "-" } {
            set dec_imcce_omc "-"
         } else {
            set dec_imcce_omc [format "%+.4f" [expr ($delta - $dec_imcce_deg) * 3600.0]]
            set dec_imcce [::bdi_tools_astrometry::convert_txt_dms $dec_imcce_deg]
         }

         # OMC JPL
         if {$ra_jpl_deg == "-"} {
            set ra_jpl_omc "-"
         } else {
            set ra_jpl_omc [format "%+.4f" [expr ($alpha - $ra_jpl_deg) * 3600.0]]
            set ra_jpl [::bdi_tools_astrometry::convert_txt_hms $ra_jpl_deg]
         }
         if {$dec_jpl_deg == "-"} {
            set dec_jpl_omc "-"
         } else {
            set dec_jpl_omc [format "%+.4f" [expr ($delta - $dec_jpl_deg) * 3600.0]]
            set dec_jpl [::bdi_tools_astrometry::convert_txt_dms $dec_jpl_deg]
         }

         # CMC IMCCE-JPL
         if {$ra_imcce_deg == "-" || $ra_jpl_deg == "-"} {
            set ra_imccejpl_cmc "-"
         } else {
            set ra_imccejpl_cmc [format "%+.4f" [expr ($ra_imcce_deg - $ra_jpl_deg) * 3600.0]]
         }
         if {$dec_imcce_deg == "-" || $dec_jpl_deg == "-"} {
            set dec_imccejpl_cmc "-"
         } else {
            set dec_imccejpl_cmc   [format "%+.4f" [expr ($dec_imcce_deg - $dec_jpl_deg) * 3600.0]]
         }

         # Definition de la structure de donnees pour les calculs de stat
         lappend tabcalc(datejj) $midatejd
         lappend tabcalc(alpha)  $alpha
         lappend tabcalc(delta)  $delta
         lappend tabcalc(res_a)  $res_a
         lappend tabcalc(res_d)  $res_d
         if {$ra_imcce_omc     != "-"} {lappend tabcalc(ra_imcce_omc)     $ra_imcce_omc}
         if {$dec_imcce_omc    != "-"} {lappend tabcalc(dec_imcce_omc)    $dec_imcce_omc}
         if {$ra_jpl_omc       != "-"} {lappend tabcalc(ra_jpl_omc)       $ra_jpl_omc}
         if {$dec_jpl_omc      != "-"} {lappend tabcalc(dec_jpl_omc)      $dec_jpl_omc}
         if {$ra_imccejpl_cmc  != "-"} {lappend tabcalc(ra_imccejpl_cmc)  $ra_imccejpl_cmc}
         if {$dec_imccejpl_cmc != "-"} {lappend tabcalc(dec_imccejpl_cmc) $dec_imccejpl_cmc}
         
         # Formatage de certaines valeurs
         #gren_info "ra_imcce_deg = $ra_imcce_deg\n"
         if {$ra_imcce_deg  != "-"} {set ra_imcce_deg  [format "%.8f" $ra_imcce_deg]}
         if {$dec_imcce_deg != "-"} {set dec_imcce_deg [format "%.8f" $dec_imcce_deg]}
         if {$h_imcce_deg   != "-"} {set h_imcce_deg   [format "%.8f" $h_imcce_deg]}
         if {$am_imcce_deg  != "-" && $am_imcce_deg != ""} {set am_imcce_deg  [format "%.8f" $am_imcce_deg]}
         if {$ra_jpl_deg    != "-"} {set ra_jpl_deg    [format "%.8f" $ra_jpl_deg ]}
         if {$dec_jpl_deg   != "-"} {set dec_jpl_deg   [format "%.8f" $dec_jpl_deg]}

         # Ajustement affichage
         set midatejd [string range "${midatejd}000000000000" 0 15]

         # Graphe
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,good)             1
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,idsource)         $idsource
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,datejj)           $midatejd
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra)               $alpha
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec)              $delta
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,res_a)            $res_a
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,res_d)            $res_d
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra_imcce_omc)     $ra_imcce_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec_imcce_omc)    $dec_imcce_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra_jpl_omc)       $ra_jpl_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec_jpl_omc)      $dec_jpl_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra_imccejpl_cmc)  $ra_imccejpl_cmc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec_imccejpl_cmc) $dec_imccejpl_cmc

      }

      set calc(res_a,mean)   [format "%.4f" [::math::statistics::mean  $tabcalc(res_a)]]
      set calc(res_d,mean)   [format "%.4f" [::math::statistics::mean  $tabcalc(res_d)]]
      set calc(datejj,mean)  [::math::statistics::mean  $tabcalc(datejj)]
      set calc(alpha,mean)   [::math::statistics::mean  $tabcalc(alpha)]
      set calc(delta,mean)   [::math::statistics::mean  $tabcalc(delta)]

      set calc(res_a,stdev) [::bdi_gui_astrometry::stdev $tabcalc(res_a) "%.4f"]
      set calc(res_d,stdev) [::bdi_gui_astrometry::stdev $tabcalc(res_d) "%.4f"]
      set calc(datejj,stdev) [::bdi_gui_astrometry::stdev $tabcalc(datejj) "%.4f"]
      
      set calc(alpha,stdev) [expr [::bdi_gui_astrometry::stdev $tabcalc(alpha) "%.15f"] * 3600000]
      set calc(delta,stdev) [expr [::bdi_gui_astrometry::stdev $tabcalc(delta) "%.15f"] * 3600000]

      set pi [expr 2*asin(1.0)]

      # OMC IMCCE
      if {[info exists tabcalc(ra_imcce_omc)]} {
         set mean [::math::statistics::mean $tabcalc(ra_imcce_omc)  ]
         set mean [expr $mean * cos($calc(delta,mean) * $pi / 180.)]
         set calc(ra_imcce_omc,mean)  [format "%.4f" $mean]
         set calc(ra_imcce_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(ra_imcce_omc) "%.4f"]
      } else {
         set calc(ra_imcce_omc,mean)  "-"
         set calc(ra_imcce_omc,stdev) "-"
      }
      if {[info exists tabcalc(dec_imcce_omc)]} {
         set calc(dec_imcce_omc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_imcce_omc)]]
         set calc(dec_imcce_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(dec_imcce_omc) "%.4f"]
      } else {
         set calc(dec_imcce_omc,mean)   "-"
         set calc(dec_imcce_omc,stdev)  "-"
      }
      if { $calc(ra_imcce_omc,mean)!="-" && $calc(dec_imcce_omc,mean)!="-"} {
         set ::bdi_tools_astrometry::results_table($name,omc) [format "%d" [expr \
                        round(sqrt((pow($calc(ra_imcce_omc,mean),2)+pow($calc(dec_imcce_omc,mean),2)))*1000)]]
      }
      if { $calc(ra_imcce_omc,stdev)!="-" && $calc(dec_imcce_omc,stdev)!="-"} {
         set ::bdi_tools_astrometry::results_table($name,omc_std) [format "%d" [expr \
                        round(sqrt((pow($calc(ra_imcce_omc,stdev),2)+pow($calc(dec_imcce_omc,stdev),2)))*1000)]]
      }
      if { $calc(ra_imcce_omc,mean)!="-"} {
         set ::bdi_tools_astrometry::results_table($name,omcx) [format "%d" [expr round($calc(ra_imcce_omc,mean)*1000)]]
      }
      if { $calc(ra_imcce_omc,stdev)!="-"} {
         set ::bdi_tools_astrometry::results_table($name,omcx_std) [format "%d" [expr \
                        round($calc(ra_imcce_omc,stdev)*1000)]]
      }
      if { $calc(dec_imcce_omc,mean)!="-"} {
         set ::bdi_tools_astrometry::results_table($name,omcy) [format "%d" [expr round($calc(dec_imcce_omc,mean)*1000)]]
      }
      if { $calc(dec_imcce_omc,stdev)!="-"} {
         set ::bdi_tools_astrometry::results_table($name,omcy_std) [format "%d" [expr \
                        round($calc(dec_imcce_omc,stdev)*1000)]]
      }

      # OMC JPL
      if {[info exists tabcalc(ra_jpl_omc)]} {
         set mean [::math::statistics::mean  $tabcalc(ra_jpl_omc)]
         set mean [expr $mean * cos($calc(delta,mean) * $pi / 180.)]
         set calc(ra_jpl_omc,mean)  [format "%.4f" $mean]
         set calc(ra_jpl_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(ra_jpl_omc) "%.4f"]
      } else {
         set calc(ra_jpl_omc,mean)   "-"
         set calc(ra_jpl_omc,stdev)  "-"
      }
      if {[info exists tabcalc(dec_jpl_omc)]} {
         set calc(dec_jpl_omc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_jpl_omc)]]
         set calc(dec_jpl_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(dec_jpl_omc) "%.4f"]
      } else {
         set calc(dec_jpl_omc,mean)   "-"
         set calc(dec_jpl_omc,stdev)  "-"
      }

      # CMC IMCCE-JPL
      if {[info exists tabcalc(ra_imccejpl_cmc)]} {
         set calc(ra_imccejpl_cmc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(ra_imccejpl_cmc)]]
         set calc(ra_imccejpl_cmc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(ra_imccejpl_cmc) "%.4f"]
      } else {
         set calc(ra_imccejpl_cmc,mean)   "-"
         set calc(ra_imccejpl_cmc,stdev)  "-"
      }

      if {[info exists tabcalc(dec_imccejpl_cmc)]} {
         set calc(dec_imccejpl_cmc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_imccejpl_cmc)]]
         set calc(dec_imccejpl_cmc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(dec_imccejpl_cmc) "%.4f"]
      } else {
         set calc(dec_imccejpl_cmc,mean)   "-"
         set calc(dec_imccejpl_cmc,stdev)  "-"
      }

      if {$calc(res_a,mean)>=0} {set calc(res_a,mean) "+$calc(res_a,mean)" }
      if {$calc(res_d,mean)>=0} {set calc(res_d,mean) "+$calc(res_d,mean)" }
      if {$calc(res_a,stdev)>=0} {set calc(res_a,stdev) "+$calc(res_a,stdev)" }
      if {$calc(res_d,stdev)>=0} {set calc(res_d,stdev) "+$calc(res_d,stdev)" }

      if {$calc(ra_imcce_omc,mean)>=0} {set calc(ra_imcce_omc,mean) "+$calc(ra_imcce_omc,mean)" }
      if {$calc(dec_imcce_omc,mean)>=0} {set calc(dec_imcce_omc,mean) "+$calc(dec_imcce_omc,mean)" }
      if {$calc(ra_imcce_omc,stdev)>=0} {set calc(ra_imcce_omc,stdev) "+$calc(ra_imcce_omc,stdev)" }
      if {$calc(dec_imcce_omc,stdev)>=0} {set calc(dec_imcce_omc,stdev) "+$calc(dec_imcce_omc,stdev)" }

      if {$calc(ra_jpl_omc,mean)>=0} {set calc(ra_jpl_omc,mean) "+$calc(ra_jpl_omc,mean)" }
      if {$calc(dec_jpl_omc,mean)>=0} {set calc(dec_jpl_omc,mean) "+$calc(dec_jpl_omc,mean)" }
      if {$calc(ra_jpl_omc,stdev)>=0} {set calc(ra_jpl_omc,stdev) "+$calc(ra_jpl_omc,stdev)" }
      if {$calc(dec_jpl_omc,stdev)>=0} {set calc(dec_jpl_omc,stdev) "+$calc(dec_jpl_omc,stdev)" }

      if {$calc(ra_imccejpl_cmc,mean)>=0} {set calc(ra_imccejpl_cmc,mean) "+$calc(ra_imccejpl_cmc,mean)" }
      if {$calc(dec_imccejpl_cmc,mean)>=0} {set calc(dec_imccejpl_cmc,mean) "+$calc(dec_imccejpl_cmc,mean)" }
      if {$calc(ra_imccejpl_cmc,stdev)>=0} {set calc(ra_imccejpl_cmc,stdev) "+$calc(ra_imccejpl_cmc,stdev)" }
      if {$calc(dec_imccejpl_cmc,stdev)>=0} {set calc(dec_imccejpl_cmc,stdev) "+$calc(dec_imccejpl_cmc,stdev)" }
      
      set none "1"
      
      set ::bdi_tools_astrometry::results_table($name,nb) $nbobs

      set ::bdi_tools_astrometry::results_table($name,duration) [format "%.1f" [expr ([::math::statistics::max $tab_jd]-[::math::statistics::min $tab_jd])*24.0] ]

      set ::bdi_tools_astrometry::results_table($name,mag)     [format "%.3f" [::math::statistics::mean  $tab_mag] ]
      set ::bdi_tools_astrometry::results_table($name,mag_std) [format "%.3f" [::math::statistics::stdev $tab_mag] ]
      set ::bdi_tools_astrometry::results_table($name,mag_amplitude) [format "%.3f" [expr [::math::statistics::max $tab_mag]-[::math::statistics::min $tab_mag]]]

      set ::bdi_tools_astrometry::results_table($name,ra)      [::bdi_tools_astrometry::convert_txt_hms [::math::statistics::mean  $tab_ra] ]
      set ::bdi_tools_astrometry::results_table($name,ra_std)  [format "%d" [expr round([::math::statistics::stdev $tab_ra] *3600000)]]
      set ::bdi_tools_astrometry::results_table($name,dec)     [::bdi_tools_astrometry::convert_txt_dms [::math::statistics::mean  $tab_dec] ]
      set ::bdi_tools_astrometry::results_table($name,dec_std) [format "%d" [expr round([::math::statistics::stdev $tab_dec] *3600000)]]

      set ::bdi_tools_astrometry::results_table($name,residus)     [format "%d" [expr round([::math::statistics::mean  $tab_res])]]
      set ::bdi_tools_astrometry::results_table($name,residus_std) [format "%d" [expr round([::math::statistics::stdev $tab_res])]]

   # Fin de l'objet courant
   }

   # Calcul de la FWHM basee sur celle obtenue sur les etoiles de reference
   # pour toutes les sources de ref et toutes les images
   set tab_fwhm ""
   set l [array get ::bdi_tools_astrometry::listref]
   set cdelt1 ""
   set cdelt2 ""
   set tab_rho ""
   set cpt 0
   foreach {name y} $l {
      
      incr cpt
      lappend tab_rho [lindex $::bdi_tools_astrometry::tabref($name) 2]
      
      foreach dateimg $::bdi_tools_astrometry::listref($name) {

         set r $::bdi_tools_astrometry::tabval($name,$dateimg)
         set fwhmx    [lindex $r 12]
         set fwhmy    [lindex $r 13]
         
         set id $::bdi_tools_astrometry::date_to_id($dateimg)

         unset cdelt1
         unset cdelt2
         foreach val $::tools_cata::new_astrometry($id) {
            set key [lindex $val 0]
            if {$key == "CDELT1"} {set cdelt1 [lindex $val 1] }
            if {$key == "CDELT2"} {set cdelt2 [lindex $val 1] }
         }
         
         if {[info exists cdelt1]&&[info exists cdelt2]} {
            set fwhmx [expr $fwhmx * $cdelt1 *3600]
            set fwhmy [expr $fwhmy * $cdelt2 *3600]
            lappend tab_fwhm [expr sqrt((pow($fwhmx,2)+pow($fwhmy,2))/2)]
         }
      }
   }
   set ::bdi_tools_astrometry::results_table(fwhm)     [format "%.2f" [::math::statistics::mean $tab_fwhm ] ]
   set ::bdi_tools_astrometry::results_table(fwhm_std) [format "%.2f" [::math::statistics::stdev $tab_fwhm] ]
   
   set ::bdi_tools_astrometry::nb_ref_stars $cpt
   if {[llength $tab_rho]>0} {
      set ::bdi_tools_astrometry::res_max_ref_stars  [format "%.3f" [::math::statistics::max $tab_rho]]
      set ::bdi_tools_astrometry::res_min_ref_stars  [format "%.3f" [::math::statistics::min $tab_rho]]
      set ::bdi_tools_astrometry::res_mean_ref_stars [format "%.3f" [::math::statistics::mean $tab_rho]]
      set ::bdi_tools_astrometry::res_std_ref_stars  [format "%.3f" [::math::statistics::stdev $tab_rho]]
   }
   
   gren_info "FWHM Globale : $::bdi_tools_astrometry::results_table(fwhm) \" STD : $::bdi_tools_astrometry::results_table(fwhm_std) \"\n"
   return
}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::create_entete_txt { obj } {

   set txt ""

   append txt "#$+---------------------------------------------------------------------------\n"
   append txt "# OBJECT             = $obj\n"
   append txt "# Type               = astrom\n"
   append txt "# Batch              = ${::bdi_tools_astrometry::rapport_batch}\n"
   append txt "# First date         = [::bdi_gui_astrometry::get_first_date_by_name $obj]\n"
   append txt "# IAU code           = ${::bdi_tools_astrometry::rapport_uai_code}\n"
   append txt "# Subscriber         = ${::bdi_tools_astrometry::rapport_rapporteur}\n"
   append txt "# Address            = ${::bdi_tools_astrometry::rapport_adresse}\n"
   append txt "# Mail               = ${::bdi_tools_astrometry::rapport_mail}\n"
   append txt "# Software           = Audela Bddimages Priam\n"
   append txt "# Observers          = ${::bdi_tools_astrometry::rapport_observ}\n"
   append txt "# Reduction          = ${::bdi_tools_astrometry::rapport_reduc}\n"
   append txt "# Instrument         = ${::bdi_tools_astrometry::rapport_instru}\n"
   append txt "# Nb of dates        = $::bdi_tools_astrometry::results_table($obj,nb)\n"
   append txt "# Duration (h)       = $::bdi_tools_astrometry::results_table($obj,duration)\n"
   append txt "# Ref. catalogue     = ${::bdi_tools_astrometry::rapport_cata}\n"
   append txt "# Nb Ref. Stars      = ${::bdi_tools_astrometry::nb_ref_stars}\n"
   append txt "# Degre polynom      = ${::bdi_tools_astrometry::polydeg}\n"
   append txt "# Use refraction     = ${::bdi_tools_astrometry::use_refraction}\n"
   append txt "# Use EOP            = ${::bdi_tools_astrometry::use_eop}\n"
   append txt "# Use debias         = ${::bdi_tools_astrometry::use_debias}\n"
   append txt "# Res max Ref Stars  = ${::bdi_tools_astrometry::res_max_ref_stars}\n"
   append txt "# Res min Ref Stars  = ${::bdi_tools_astrometry::res_min_ref_stars}\n"
   append txt "# Res mean Ref Stars = ${::bdi_tools_astrometry::res_mean_ref_stars}\n"
   append txt "# Res std Ref Stars  = ${::bdi_tools_astrometry::res_std_ref_stars}\n"
   append txt "# Magnitude          = $::bdi_tools_astrometry::results_table($obj,mag)\n"
   append txt "# Magnitude STD      = $::bdi_tools_astrometry::results_table($obj,mag_std)\n"
   append txt "# Magnitude Ampl     = $::bdi_tools_astrometry::results_table($obj,mag_amplitude)\n"
   append txt "# FWHM (arcsec)      = $::bdi_tools_astrometry::results_table(fwhm)\n"
   append txt "# FWHM STD (arcsec)  = $::bdi_tools_astrometry::results_table(fwhm_std)\n"
   append txt "# Right Asc. (hms)   = $::bdi_tools_astrometry::results_table($obj,ra)\n"
   append txt "# Declination (dms)  = $::bdi_tools_astrometry::results_table($obj,dec)\n"
   append txt "# RA STD (mas)       = $::bdi_tools_astrometry::results_table($obj,ra_std)\n"
   append txt "# DEC STD (mas)      = $::bdi_tools_astrometry::results_table($obj,dec_std)\n"
   append txt "# Residual (mas)     = $::bdi_tools_astrometry::results_table($obj,residus)\n"
   append txt "# Residual STD (mas) = $::bdi_tools_astrometry::results_table($obj,residus_std)\n"
   append txt "# OmC (mas)          = $::bdi_tools_astrometry::results_table($obj,omc)\n"
   append txt "# OmC STD (mas)      = $::bdi_tools_astrometry::results_table($obj,omc_std)\n"
   append txt "# OmC X (mas)        = $::bdi_tools_astrometry::results_table($obj,omcx)\n"
   append txt "# OmC Y (mas)        = $::bdi_tools_astrometry::results_table($obj,omcy)\n"
   append txt "# OmC X STD (mas)    = $::bdi_tools_astrometry::results_table($obj,omcx_std)\n"
   append txt "# OmC Y STD (mas)    = $::bdi_tools_astrometry::results_table($obj,omcy_std)\n"
   append txt "# Comment            = ${::bdi_gui_astrometry::rapport_comment}\n"
   append txt "#$----------------------------------------------------------------------------\n"
   
   return $txt
}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::create_report_txt {  } {

   # TESTASTROMETRY
   #catch {
   #   unset ::bdi_gui_astrometry::omcvaruna_a
   #   unset ::bdi_gui_astrometry::omcvaruna_d
   #}
   # TESTASTROMETRY

   # Reset du graphe
   #if {[info exists ::bdi_gui_astrometry::graph_results]} {
   #   unset ::bdi_gui_astrometry::graph_results
   #}

   # Defini le tableau contenant les rapports txt par objet
   array unset ::bdi_gui_astrometry::rapport_txt_obj
   array set ::bdi_gui_astrometry::rapport_txt_obj {}
   # Efface la zone de rapport
   $::bdi_gui_astrometry::rapport_txt delete 0.0 end

   # Separateur
   set sep_txt "#[string repeat - 332]\n"

   # Cherche la lgueur max des noms des objets SCIENCE pour le formattage
   set l [array get ::bdi_tools_astrometry::listscience]
   set nummax 0
   foreach {name y} $l {
      set num [string length $name]
      if {$num>$nummax} {set nummax $num}
   }
   # Format des lignes du rapport TXT
   set form "%1s %-${nummax}s  %-23s  %-13s  %-13s  %-6s  %-6s  %-6s  %-6s %-7s %-7s %-7s %-7s  %-16s  %-12s  %-12s  %-12s  %-12s  %-12s  %-12s  %10s %10s %10s %10s %10s %10s\n"

   # Definitions des entetes de la table
   set name          ""
   set date          ""
   set ra_hms        ""
   set dec_dms       ""
   set res_a         ""
   set res_d         ""
   set mag           ""
   set err_mag       ""
   set ra_imcce_omc  "IMCCE"
   set dec_imcce_omc ""
   set ra_mpc_omc    "JPL"
   set dec_mpc_omc   ""
   set datejj        ""
   set alpha         ""
   set delta         ""
   set ra_imcce      "IMCCE"
   set dec_imcce     ""
   set ra_mpc        "JPL"
   set dec_mpc       ""
   set err_x         ""
   set err_y         ""
   set fwhm_x        ""
   set fwhm_y        ""
   set hauteur       ""
   set airmass       ""
   set headtab1 [format $form "#" $name $date $ra_hms $dec_dms $res_a $res_d $mag $err_mag $ra_imcce_omc $dec_imcce_omc $ra_mpc_omc $dec_mpc_omc $datejj $alpha $delta $ra_imcce $dec_imcce $ra_mpc $dec_mpc $err_x $err_y $fwhm_x $fwhm_y $hauteur $airmass]

   set name          "Object"
   set date          "Mid-Date"
   set ra_hms        "Right Asc."
   set dec_dms       "Declination"
   set res_a         "Err RA"
   set res_d         "Err De"
   set mag           "Mag"
   set err_mag       "ErrMag"
   set ra_imcce_omc  "OmC RA"
   set dec_imcce_omc "OmC De"
   set ra_mpc_omc    "OmC RA"
   set dec_mpc_omc   "OmC De"
   set datejj        "Julian Date"
   set alpha         "Right Asc."
   set delta         "Declination"
   set ra_imcce      "Right Asc."
   set dec_imcce     "Declination"
   set ra_mpc        "Right Asc."
   set dec_mpc       "Declination"
   set err_x         "Err x"
   set err_y         "Err y"
   set fwhm_x        "fwhm x"
   set fwhm_y        "fwhm y"
   set hauteur       "Hauteur"
   set airmass       "AirMass"
   set headtab2 [format $form "#" $name $date $ra_hms $dec_dms $res_a $res_d $mag $err_mag $ra_imcce_omc $dec_imcce_omc $ra_mpc_omc $dec_mpc_omc $datejj $alpha $delta $ra_imcce $dec_imcce $ra_mpc $dec_mpc $err_x $err_y $fwhm_x $fwhm_y $hauteur $airmass]

   set name          ""
   set date          "iso"
   set ra_hms        "hms"
   set dec_dms       "dms"
   set rho           "arcsec"
   set res_a         "arcsec"
   set res_d         "arcsec"
   set mag           ""
   set err_mag       ""
   set ra_imcce_omc  "arcsec"
   set dec_imcce_omc "arcsec"
   set ra_mpc_omc    "arcsec"
   set dec_mpc_omc   "arcsec"
   set datejj        ""
   set alpha         "deg"
   set delta         "deg"
   set ra_imcce      "deg"
   set dec_imcce     "deg"
   set ra_mpc        "deg"
   set dec_mpc       "deg"
   set err_x         "px"
   set err_y         "px"
   set fwhm_x        "px"
   set fwhm_y        "px"
   set hauteur       "deg"
   set airmass       ""
   set headtab3 [format $form "#" $name $date $ra_hms $dec_dms $res_a $res_d $mag $err_mag $ra_imcce_omc $dec_imcce_omc $ra_mpc_omc $dec_mpc_omc $datejj $alpha $delta $ra_imcce $dec_imcce $ra_mpc $dec_mpc $err_x $err_y $fwhm_x $fwhm_y $hauteur $airmass]

   set pass 0
   # Pour chaque objet SCIENCE
   foreach {name y} $l {

      if {[info exists tabcalc]} { unset tabcalc }

      append ::bdi_gui_astrometry::rapport_txt_obj($name) [::bdi_gui_astrometry::create_entete_txt $name]
      append ::bdi_gui_astrometry::rapport_txt_obj($name) $headtab1
      append ::bdi_gui_astrometry::rapport_txt_obj($name) $headtab2
      append ::bdi_gui_astrometry::rapport_txt_obj($name) $headtab3
      append ::bdi_gui_astrometry::rapport_txt_obj($name) $sep_txt

      $::bdi_gui_astrometry::rapport_txt insert end $::bdi_gui_astrometry::rapport_txt_obj($name)

      set nbobs 0

      foreach dateimg $::bdi_tools_astrometry::listscience($name) {

         # Rend effectif le crop du graphe
         if {[info exists ::bdi_gui_astrometry::graph_results($name,$dateimg,good)]} {
            if {$::bdi_gui_astrometry::graph_results($name,$dateimg,good)==0} {continue}
         }

         incr nbobs
         set idsource [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  0]

         # Structure de tabval :
         #  0  id
         #  1  field
         #  2  ar
         #  3  rho
         #  4  res_ra
         #  5  res_dec
         #  6  ra
         #  7  dec
         #  8  mag
         #  9  err_mag
         # 10  err_xsm
         # 11  err_ysm
         # 12  fwhm_x
         # 13  fwhm_y

         set rho     [format "%.4f"  [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  3]]
         set res_a   [format "%.4f"  [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  4]]
         set res_d   [format "%.4f"  [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  5]]
         set alpha   [format "%.8f"  [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  6]]
         set delta   [format "%+.8f" [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  7]]
         set val [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  8]
         if {$val==""} {set mag "-"} else {set mag $val}

         set val [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  9]
         if {$val==""} {set err_mag "-"} else {set err_mag $val}

         set val [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  10]
         if {$val==""} {set err_x "-"} else {set err_x $val}

         set val [lindex $::bdi_tools_astrometry::tabval($name,$dateimg)  11]
         if {$val==""} {set err_y "-"} else {set err_y $val}

         set fwhm_x  [format "%.4f" [lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 12]]
         set fwhm_y  [format "%.4f" [lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 13]]
         set ra_hms  [::bdi_tools_astrometry::convert_txt_hms [lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 6]]
         set dec_dms [::bdi_tools_astrometry::convert_txt_dms [lindex $::bdi_tools_astrometry::tabval($name,$dateimg) 7]]

         # Recupere les ephemerides de l'objet courant pour la date courante
         set all_ephem [::bdi_gui_astrometry::get_data_report $name $dateimg]

         # Ephemerides de l'IMCCE
         set eph_imcce     [lindex $all_ephem 0]
         set ra_imcce_deg  [lindex $eph_imcce {1 1 1}]
         set dec_imcce_deg [lindex $eph_imcce {1 1 2}]
         set h_imcce_deg   [lindex $eph_imcce {1 1 3}]
         set am_imcce_deg  [lindex $eph_imcce {1 1 4}]

         # Ephemerides du JPL
         set eph_jpl       [lindex $all_ephem 1]
         #set midatejd [lindex $eph_jpl {1 1 0}]
         set ra_jpl_deg    [lindex $eph_jpl {1 1 1}]
         set dec_jpl_deg   [lindex $eph_jpl {1 1 2}]

         # Epoque du milieu de pose au format JD
         set midatejd $::tools_cata::date2midate($dateimg)

         # Epoque du milieu de pose au format ISO
         set midateiso "-"
         if {$midatejd != "-"} {
            set midateiso [mc_date2iso8601 $midatejd]
         }

         # OMC IMCCE
         #gren_info "ra_imcce_deg = $ra_imcce_deg\n"
         if { $ra_imcce_deg == "" || $ra_imcce_deg == "-" } {
            set ra_imcce_omc "-"
         } else {
            #gren_info "ra_imcce_deg = $ra_imcce_deg\n"
            set ra_imcce_omc [format "%+.4f" [expr ($alpha - $ra_imcce_deg) * 3600.0]]
            set ra_imcce [::bdi_tools_astrometry::convert_txt_hms $ra_imcce_deg]
         }
         if { $dec_imcce_deg == "" || $dec_imcce_deg == "-" } {
            set dec_imcce_omc "-"
         } else {
            set dec_imcce_omc [format "%+.4f" [expr ($delta - $dec_imcce_deg) * 3600.0]]
            set dec_imcce [::bdi_tools_astrometry::convert_txt_dms $dec_imcce_deg]
         }

         # OMC JPL
         if {$ra_jpl_deg == "-"} {
            set ra_jpl_omc "-"
         } else {
            set ra_jpl_omc [format "%+.4f" [expr ($alpha - $ra_jpl_deg) * 3600.0]]
            set ra_jpl [::bdi_tools_astrometry::convert_txt_hms $ra_jpl_deg]
         }
         if {$dec_jpl_deg == "-"} {
            set dec_jpl_omc "-"
         } else {
            set dec_jpl_omc [format "%+.4f" [expr ($delta - $dec_jpl_deg) * 3600.0]]
            set dec_jpl [::bdi_tools_astrometry::convert_txt_dms $dec_jpl_deg]
         }

         # CMC IMCCE-JPL
         if {$ra_imcce_deg == "-" || $ra_jpl_deg == "-"} {
            set ra_imccejpl_cmc "-"
         } else {
            set ra_imccejpl_cmc [format "%+.4f" [expr ($ra_imcce_deg - $ra_jpl_deg) * 3600.0]]
         }
         if {$dec_imcce_deg == "-" || $dec_jpl_deg == "-"} {
            set dec_imccejpl_cmc "-"
         } else {
            set dec_imccejpl_cmc   [format "%+.4f" [expr ($dec_imcce_deg - $dec_jpl_deg) * 3600.0]]
         }

         # Definition de la structure de donnees pour les calculs de stat
         lappend tabcalc(datejj) $midatejd
         lappend tabcalc(alpha)  $alpha
         lappend tabcalc(delta)  $delta
         lappend tabcalc(res_a)  $res_a
         lappend tabcalc(res_d)  $res_d
         if {$ra_imcce_omc     != "-"} {lappend tabcalc(ra_imcce_omc)     $ra_imcce_omc}
         if {$dec_imcce_omc    != "-"} {lappend tabcalc(dec_imcce_omc)    $dec_imcce_omc}
         if {$ra_jpl_omc       != "-"} {lappend tabcalc(ra_jpl_omc)       $ra_jpl_omc}
         if {$dec_jpl_omc      != "-"} {lappend tabcalc(dec_jpl_omc)      $dec_jpl_omc}
         if {$ra_imccejpl_cmc  != "-"} {lappend tabcalc(ra_imccejpl_cmc)  $ra_imccejpl_cmc}
         if {$dec_imccejpl_cmc != "-"} {lappend tabcalc(dec_imccejpl_cmc) $dec_imccejpl_cmc}
         
# TESTASTROMETRY
#            if {$name == "SKYBOT_20000_Varuna"} {
#               
#               set ::bdi_gui_astrometry::omcvaruna_a($dateimg) $ra_imcce_omc
#               set ::bdi_gui_astrometry::omcvaruna_d($dateimg) $dec_imcce_omc
#            }
# TESTASTROMETRY
         
         # Formatage de certaines valeurs
         #gren_info "ra_imcce_deg = $ra_imcce_deg\n"
         if {$ra_imcce_deg  != "-"} {set ra_imcce_deg  [format "%.8f" $ra_imcce_deg]}
         if {$dec_imcce_deg != "-"} {set dec_imcce_deg [format "%.8f" $dec_imcce_deg]}
         if {$h_imcce_deg   != "-"} {set h_imcce_deg   [format "%.8f" $h_imcce_deg]}
         if {$am_imcce_deg  != "-" && $am_imcce_deg != ""} {set am_imcce_deg  [format "%.8f" $am_imcce_deg]}
         if {$ra_jpl_deg    != "-"} {set ra_jpl_deg    [format "%.8f" $ra_jpl_deg ]}
         if {$dec_jpl_deg   != "-"} {set dec_jpl_deg   [format "%.8f" $dec_jpl_deg]}

         # Ajustement affichage
         set midatejd [string range "${midatejd}000000000000" 0 15]

         # Ligne de resultats
         set txt [format $form "" $name $midateiso $ra_hms $dec_dms $res_a $res_d $mag $err_mag $ra_imcce_omc $dec_imcce_omc $ra_jpl_omc $dec_jpl_omc $midatejd $alpha $delta $ra_imcce_deg $dec_imcce_deg $ra_jpl_deg $dec_jpl_deg $err_x $err_y $fwhm_x $fwhm_y $h_imcce_deg $am_imcce_deg]
         append ::bdi_gui_astrometry::rapport_txt_obj($name) $txt
         $::bdi_gui_astrometry::rapport_txt insert end  $txt

         # Graphe
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,good)             1
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,idsource)         $idsource
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,datejj)           $midatejd
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra)               $alpha
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec)              $delta
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,res_a)            $res_a
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,res_d)            $res_d
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra_imcce_omc)     $ra_imcce_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec_imcce_omc)    $dec_imcce_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra_jpl_omc)       $ra_jpl_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec_jpl_omc)      $dec_jpl_omc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,ra_imccejpl_cmc)  $ra_imccejpl_cmc
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,dec_imccejpl_cmc) $dec_imccejpl_cmc

      }

      set calc(res_a,mean)   [format "%.4f" [::math::statistics::mean  $tabcalc(res_a)]]
      set calc(res_d,mean)   [format "%.4f" [::math::statistics::mean  $tabcalc(res_d)]]
      set calc(datejj,mean)  [::math::statistics::mean  $tabcalc(datejj)]
      set calc(alpha,mean)   [::math::statistics::mean  $tabcalc(alpha)]
      set calc(delta,mean)   [::math::statistics::mean  $tabcalc(delta)]

      set calc(res_a,stdev) [::bdi_gui_astrometry::stdev $tabcalc(res_a) "%.4f"]
      set calc(res_d,stdev) [::bdi_gui_astrometry::stdev $tabcalc(res_d) "%.4f"]
      set calc(datejj,stdev) [::bdi_gui_astrometry::stdev $tabcalc(datejj) "%.4f"]
      
      set calc(alpha,stdev) [expr [::bdi_gui_astrometry::stdev $tabcalc(alpha) "%.15f"] * 3600000]
      set calc(delta,stdev) [expr [::bdi_gui_astrometry::stdev $tabcalc(delta) "%.15f"] * 3600000]

      set pi [expr 2*asin(1.0)]

      # OMC IMCCE
      if {[info exists tabcalc(ra_imcce_omc)]} {
         set mean [::math::statistics::mean $tabcalc(ra_imcce_omc)  ]
         set mean [expr $mean * cos($calc(delta,mean) * $pi / 180.)]
         set calc(ra_imcce_omc,mean)  [format "%.4f" $mean]
         set calc(ra_imcce_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(ra_imcce_omc) "%.4f"]
      } else {
         set calc(ra_imcce_omc,mean)  "-"
         set calc(ra_imcce_omc,stdev) "-"
      }
      if {[info exists tabcalc(dec_imcce_omc)]} {
         set calc(dec_imcce_omc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_imcce_omc)]]
         set calc(dec_imcce_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(dec_imcce_omc) "%.4f"]
      } else {
         set calc(dec_imcce_omc,mean)   "-"
         set calc(dec_imcce_omc,stdev)  "-"
      }

      # OMC JPL
      if {[info exists tabcalc(ra_jpl_omc)]} {
         set mean [::math::statistics::mean  $tabcalc(ra_jpl_omc)]
         set mean [expr $mean * cos($calc(delta,mean) * $pi / 180.)]
         set calc(ra_jpl_omc,mean)  [format "%.4f" $mean]
         set calc(ra_jpl_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(ra_jpl_omc) "%.4f"]
      } else {
         set calc(ra_jpl_omc,mean)   "-"
         set calc(ra_jpl_omc,stdev)  "-"
      }
      if {[info exists tabcalc(dec_jpl_omc)]} {
         set calc(dec_jpl_omc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_jpl_omc)]]
         set calc(dec_jpl_omc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(dec_jpl_omc) "%.4f"]
      } else {
         set calc(dec_jpl_omc,mean)   "-"
         set calc(dec_jpl_omc,stdev)  "-"
      }

      # CMC IMCCE-JPL
      if {[info exists tabcalc(ra_imccejpl_cmc)]} {
         set calc(ra_imccejpl_cmc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(ra_imccejpl_cmc)]]
         set calc(ra_imccejpl_cmc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(ra_imccejpl_cmc) "%.4f"]
      } else {
         set calc(ra_imccejpl_cmc,mean)   "-"
         set calc(ra_imccejpl_cmc,stdev)  "-"
      }

      if {[info exists tabcalc(dec_imccejpl_cmc)]} {
         set calc(dec_imccejpl_cmc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_imccejpl_cmc)]]
         set calc(dec_imccejpl_cmc,stdev) [::bdi_gui_astrometry::stdev $tabcalc(dec_imccejpl_cmc) "%.4f"]
      } else {
         set calc(dec_imccejpl_cmc,mean)   "-"
         set calc(dec_imccejpl_cmc,stdev)  "-"
      }


      if {$calc(res_a,mean)>=0} {set calc(res_a,mean) "+$calc(res_a,mean)" }
      if {$calc(res_d,mean)>=0} {set calc(res_d,mean) "+$calc(res_d,mean)" }
      if {$calc(res_a,stdev)>=0} {set calc(res_a,stdev) "+$calc(res_a,stdev)" }
      if {$calc(res_d,stdev)>=0} {set calc(res_d,stdev) "+$calc(res_d,stdev)" }

      if {$calc(ra_imcce_omc,mean)>=0} {set calc(ra_imcce_omc,mean) "+$calc(ra_imcce_omc,mean)" }
      if {$calc(dec_imcce_omc,mean)>=0} {set calc(dec_imcce_omc,mean) "+$calc(dec_imcce_omc,mean)" }
      if {$calc(ra_imcce_omc,stdev)>=0} {set calc(ra_imcce_omc,stdev) "+$calc(ra_imcce_omc,stdev)" }
      if {$calc(dec_imcce_omc,stdev)>=0} {set calc(dec_imcce_omc,stdev) "+$calc(dec_imcce_omc,stdev)" }

      if {$calc(ra_jpl_omc,mean)>=0} {set calc(ra_jpl_omc,mean) "+$calc(ra_jpl_omc,mean)" }
      if {$calc(dec_jpl_omc,mean)>=0} {set calc(dec_jpl_omc,mean) "+$calc(dec_jpl_omc,mean)" }
      if {$calc(ra_jpl_omc,stdev)>=0} {set calc(ra_jpl_omc,stdev) "+$calc(ra_jpl_omc,stdev)" }
      if {$calc(dec_jpl_omc,stdev)>=0} {set calc(dec_jpl_omc,stdev) "+$calc(dec_jpl_omc,stdev)" }

      if {$calc(ra_imccejpl_cmc,mean)>=0} {set calc(ra_imccejpl_cmc,mean) "+$calc(ra_imccejpl_cmc,mean)" }
      if {$calc(dec_imccejpl_cmc,mean)>=0} {set calc(dec_imccejpl_cmc,mean) "+$calc(dec_imccejpl_cmc,mean)" }
      if {$calc(ra_imccejpl_cmc,stdev)>=0} {set calc(ra_imccejpl_cmc,stdev) "+$calc(ra_imccejpl_cmc,stdev)" }
      if {$calc(dec_imccejpl_cmc,stdev)>=0} {set calc(dec_imccejpl_cmc,stdev) "+$calc(dec_imccejpl_cmc,stdev)" }

      set bodyblock ""

      append bodyblock $sep_txt
      
      #append bodyblock "# BODY NAME = [lrange [split $name "_"] 2 end]\n"
      # sinon ne marche pas pour les etoiles
      append bodyblock "# BODY NAME = $name\n"

      append bodyblock "# Number of positions: $nbobs \n"
      append bodyblock "# -\n"
      append bodyblock "# Residus     RA  (arcsec): mean = $calc(res_a,mean) stedv = $calc(res_a,stdev)\n"
      append bodyblock "# Residus     DEC (arcsec): mean = $calc(res_d,mean) stedv = $calc(res_d,stdev)\n"
      append bodyblock "# -\n"
      append bodyblock "# O-C(IMCCE)  RA  (arcsec): mean = $calc(ra_imcce_omc,mean) stedv = $calc(ra_imcce_omc,stdev)\n"
      append bodyblock "# O-C(IMCCE)  DEC (arcsec): mean = $calc(dec_imcce_omc,mean) stedv = $calc(dec_imcce_omc,stdev)\n"
      append bodyblock "# -\n"
      append bodyblock "# O-C(JPL)    RA  (arcsec): mean = $calc(ra_jpl_omc,mean) stedv = $calc(ra_jpl_omc,stdev)\n"
      append bodyblock "# O-C(JPL)    DEC (arcsec): mean = $calc(dec_jpl_omc,mean) stedv = $calc(dec_jpl_omc,stdev)\n"
      append bodyblock "# -\n"
      append bodyblock "# IMCCE-JPL   RA  (arcsec): mean = $calc(ra_imccejpl_cmc,mean) stedv = $calc(ra_imccejpl_cmc,stdev)\n"
      append bodyblock "# IMCCE-JPL   DEC (arcsec): mean = $calc(dec_imccejpl_cmc,mean) stedv = $calc(dec_imccejpl_cmc,stdev)\n"
      append bodyblock "# -\n"
      append bodyblock "# Mean epoch (jd) : $calc(datejj,mean) ( [mc_date2iso8601 $calc(datejj,mean)] )\n"
      append bodyblock "# Mean RA    (deg): [format "%16.12f" $calc(alpha,mean)]   (  [::bdi_tools_astrometry::convert_txt_hms $calc(alpha,mean)] )\n"
      append bodyblock "# Mean DEC   (deg): [format "%+15.12f" $calc(delta,mean)]   ( [::bdi_tools_astrometry::convert_txt_dms $calc(delta,mean)]  )\n"
      append bodyblock "# Stdev RA   (mas): [format "%.1f" $calc(alpha,stdev)] \n"
      append bodyblock "# Stdev DEC  (mas): [format "%.1f" $calc(delta,stdev)] \n"

      # TESTASTROMETRY
      ### XTRA pour travail sur l astrometrie. verification de l occultation de Varuna/UCAC3
      
#         if {$name == "SKYBOT_20000_Varuna"} {
#            incr pass
#            set moa [format "%.1f" [expr $calc(ra_imcce_omc,mean)*1000] ]
#            set mod [format "%.1f" [expr $calc(dec_imcce_omc,mean)*1000] ]
#            set soa [format "%.1f" [expr $calc(ra_imcce_omc,stdev)*1000] ]
#            set sod [format "%.1f" [expr $calc(dec_imcce_omc,stdev)*1000] ]
#         }

#         if {$name == "UCAC3_233-089504"} {

#            incr pass
#            set aref 117.40414125
#            set dref 26.4311219444
#            set offra [format "%.1f" [expr ($calc(alpha,mean)-$aref)*3600000] ]
#            set offde [format "%.1f" [expr ($calc(delta,mean)-$dref)*3600000] ]
##            set soa_star [format "%.1f" $calc(alpha,stdev)]
#            set sod_star [format "%.1f" $calc(delta,stdev)]          
##         }

      append bodyblock $sep_txt

      append ::bdi_gui_astrometry::rapport_txt_obj($name) $bodyblock
      $::bdi_gui_astrometry::rapport_txt insert end $bodyblock

   }

   if {$pass == 2} {
         ::bdi_gui_astrometry::test_astrometry_carteresidu
         #::bdi_gui_astrometry::test_astrometry_dxdy
         
         set diffra [format "%.1f" [expr $offra-$moa] ]
         set diffde [format "%.1f" [expr $offde-$mod] ]
         gren_info "Distance offset ($diffra,$diffde)\n"
         gren_info "Erreur pos star : ($soa_star,$sod_star)\n"
         gren_info "Erreur offset varuna : ($soa,$sod)\n"
         $::bdi_gui_astrometry::rapport_txt insert end  "# Distance Offset RA : $diffra \n"
         $::bdi_gui_astrometry::rapport_txt insert end  "# Distance Offset DEC: $diffde \n"
         $::bdi_gui_astrometry::rapport_txt insert end  "# STAR Offset RA : $offra \n"
         $::bdi_gui_astrometry::rapport_txt insert end  "# STAR Offset DEC: $offde \n"
         $::bdi_gui_astrometry::rapport_txt insert end  "# 0,$calc(datejj,mean),$moa,$mod,$soa,$sod,VARUNA nuit \n"
         $::bdi_gui_astrometry::rapport_txt insert end  "# 1,$calc(datejj,mean),$offra,$offde,[format "%.1f" $calc(alpha,stdev)],[format "%.1f" $calc(delta,stdev)],STAR nuit \n"
   }

   $::bdi_gui_astrometry::rapport_txt insert end "\n"

   return

}


#----------------------------------------------------------------------------

# TESTASTROMETRY
proc ::bdi_gui_astrometry::test_get_radec { name p_listsources } {

   upvar $p_listsources listsources 

   set idref [ ::manage_source::name2ids $name listsources]
   set s [lindex $listsources [list 1 $idref] ]
   foreach cata $s {
      if {[lindex $cata 0] == "WFIBC"} {
         set ra_ref  [format "%.6f" [lindex [lindex $cata 2] 0] ]
         set dec_ref [format "%.6f" [lindex [lindex $cata 2] 1] ]
         return [list $ra_ref $dec_ref]
      }
   }
   return -1
}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::test_astrometry_carteresidu {  } {

   global bddconf
   
   if {1==1} {
   
      set chan0 [open [file join $bddconf(dirtmp) "carte_residus.csv"] w] 
      puts $chan0 "name,date,catalog_ra,catalog_dec,xsm,ysm,priam_res_ra,priam_res_dec"
      close $chan0
      set chan0 [open [file join $bddconf(dirtmp) "carte_varuna.csv"] w] 
      puts $chan0 "name,date,priam_ra,priam_dec,xsm,ysm,priam_res_ra,priam_res_dec,omcra,omcde"
      close $chan0
      set chan0 [open [file join $bddconf(dirtmp) "carte_UCAC3.csv"] w] 
      puts $chan0 "name,date,priam_ra,priam_dec,xsm,ysm,priam_res_ra,priam_res_dec"
      close $chan0

   }

   foreach date [array get ::bdi_tools_astrometry::dxdy_date] {

      set pass 0

      if {$date == "1"} {continue}

      # extraction des info de la bonne image
      set id_img 1
      foreach img $::tools_cata::img_list {
         set tabkey   [::bddimages_liste::lget $img "tabkey"]
         set dateiso [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
         if {[::bdi_tools::is_isodates_equal $dateiso $date]} {
            set pass 1
            break
         }
         incr id_img
      }
      if {$pass == 0} {
         continue
      }

      # extraction de listsource
      set listsources $::bdi_gui_cata::cata_list($id_img)


      # extraction des etoiles
      foreach name [array get ::bdi_tools_astrometry::dxdy_name] {

         if {$name == "1"} {continue}

         if {[info exists ::bdi_tools_astrometry::dxdy($name,$date)]} {
         
            # position de l etoile dans le catalogue

            if {$name == "SKYBOT_20000_Varuna"} {
               set priam_res_ra  [lindex $::bdi_tools_astrometry::dxdy($name,$date) 4]
               set priam_res_dec [lindex $::bdi_tools_astrometry::dxdy($name,$date) 5]
               set priam_ra      [lindex $::bdi_tools_astrometry::dxdy($name,$date) 6]
               set priam_dec     [lindex $::bdi_tools_astrometry::dxdy($name,$date) 7]
               set xsm           [lindex $::bdi_tools_astrometry::dxdy($name,$date) 0]
               set ysm           [lindex $::bdi_tools_astrometry::dxdy($name,$date) 1]
               set omcra         $::bdi_gui_astrometry::omcvaruna_a($date)
               set omcde         $::bdi_gui_astrometry::omcvaruna_d($date)
               
               #gren_info "$name,$date,$priam_ra,$priam_dec,$xsm,$ysm,$priam_res_ra,$priam_res_dec\n"
               gren_info "$name,$date: ($omcra,$omcde)\n"
               
               if { $omcra!="" && $omcde!="" } {
                  set chan0 [open [file join $bddconf(dirtmp) "carte_varuna.csv"] a] 
                  puts $chan0 "$name,$date,$priam_ra,$priam_dec,$xsm,$ysm,$priam_res_ra,$priam_res_dec,$omcra,$omcde"
                  close $chan0
               }
               continue
            }

            set r [::bdi_gui_astrometry::test_get_radec $name listsources]
            if {$r==-1} {
               #gren_erreur "etoile $name : pas de reference WFIBC dans cette image\n"
               continue
            } 

            set catalog_ra    [lindex $r 0]
            set catalog_dec   [lindex $r 1]
            set priam_res_ra  [lindex $::bdi_tools_astrometry::dxdy($name,$date) 4]
            set priam_res_dec [lindex $::bdi_tools_astrometry::dxdy($name,$date) 5]
            set priam_ra      [lindex $::bdi_tools_astrometry::dxdy($name,$date) 6]
            set priam_dec     [lindex $::bdi_tools_astrometry::dxdy($name,$date) 7]
            set xsm           [lindex $::bdi_tools_astrometry::dxdy($name,$date) 0]
            set ysm           [lindex $::bdi_tools_astrometry::dxdy($name,$date) 1]
            if {$priam_res_ra==""||$priam_res_dec==""} {
               gren_erreur "reference $starref $date: pas de residus\n"
               continue
            }

            if {$name == "UCAC3_233-089504"} {
               set chan0 [open [file join $bddconf(dirtmp) "carte_UCAC3.csv"] a] 
               puts $chan0 "$name,$date,$priam_ra,$priam_dec,$xsm,$ysm,$priam_res_ra,$priam_res_dec"
               close $chan0
               continue
            }
            set chan0 [open [file join $bddconf(dirtmp) "carte_residus.csv"] a] 
            puts $chan0 "$name,$date,$catalog_ra,$catalog_dec,$xsm,$ysm,$priam_res_ra,$priam_res_dec"
            close $chan0
            
         }
      }
   }

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::test_astrometry_dxdy {  } {

   global bddconf
   
   set starref "WFIBC_117.418054+26.448215"
   set starref "WFIBC_117.369850+26.394985"
   set starref "WFIBC_117.419562+26.411274"

   set a [array get ::bdi_tools_astrometry::dxdy_name]

   if {1==1} {
      foreach name [array get ::bdi_tools_astrometry::dxdy_name] {
         set chan0 [open [file join $bddconf(dirtmp) "dxdy_$name.dat"] w] 
         puts $chan0 "name,date,dx,dy,ra,dec"
         close $chan0
      }
      set chan0 [open [file join $bddconf(dirtmp) "dxdy_all.dat"] w] 
      puts $chan0 "name,date,dx,dy,ra,dec"
      close $chan0
   }

   foreach date [array get ::bdi_tools_astrometry::dxdy_date] {

      set pass 0

      # extraction des info de la bonne image
      if {$date == "1"} {continue}

      set id_img 1
      foreach img $::tools_cata::img_list {
         set tabkey   [::bddimages_liste::lget $img "tabkey"]
         set dateiso [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
         if {[::bdi_tools::is_isodates_equal $dateiso $date]} {
            set CDELT1 [string trim [lindex [::bddimages_liste::lget $tabkey "CDELT1"] 1] ]
            set CDELT2 [string trim [lindex [::bddimages_liste::lget $tabkey "CDELT2"] 1] ]
            set CDELT1 [expr $CDELT1*3600]
            set CDELT2 [expr $CDELT2*3600]
            #gren_info "date ok : $dateiso $CDELT1 $CDELT2 \n"
            set pass 1
            break
         }
         incr id_img
      }
      if {$pass == 0} {
         #gren_erreur "*** Date $date n a pas d image\n"
         continue
      }
      # extraction de listsource

      set listsources $::bdi_gui_cata::cata_list($id_img)

      # position de l etoile de reference dans le catalogue
      
      set r [::bdi_gui_astrometry::test_get_radec $starref listsources]
      if {$r==-1} {
         #gren_erreur "reference $starref : pas de reference WFIBC dans cette image\n"
         continue
      } else {
         set catalog_ref_ra  [lindex $r 0]
         set catalog_ref_dec [lindex $r 1]
         set priam_res_ra   [lindex $::bdi_tools_astrometry::dxdy($starref,$date) 4]
         set priam_res_dec  [lindex $::bdi_tools_astrometry::dxdy($starref,$date) 5]
         if {$priam_res_ra==""||$priam_res_dec==""} {
            gren_erreur "reference $starref ($date) $id_img: pas de residus\n"
            break
         }
         set priam_ref_ra  [ expr $catalog_ref_ra-$priam_res_ra/3600 ]
         set priam_ref_dec [ expr $catalog_ref_dec-$priam_res_dec/3600 ]
         #gren_info "ra_ref = $ra_ref dec_ref=$dec_ref\n"
      }

      foreach name [array get ::bdi_tools_astrometry::dxdy_name] {

         if {$name == "1"} {continue}
         if {[info exists ::bdi_tools_astrometry::dxdy($starref,$date)]} {

            if {[info exists ::bdi_tools_astrometry::dxdy($name,$date)]} {
            
               # position de l etoile dans le catalogue

               set r [::bdi_gui_astrometry::test_get_radec $name listsources]
               if {$r==-1} {
                  #gren_erreur "etoile $name : pas de reference WFIBC dans cette image\n"
                  continue
               } 

               set catalog_ra    [lindex $r 0]
               set catalog_dec   [lindex $r 1]
               set priam_res_ra  [lindex $::bdi_tools_astrometry::dxdy($name,$date) 4]
               set priam_res_dec [lindex $::bdi_tools_astrometry::dxdy($name,$date) 5]
               if {$priam_res_ra==""||$priam_res_dec==""} {
                  gren_erreur "reference $starref $date: pas de residus\n"
                  continue
               }
               set priam_star_ra  [ expr $catalog_ra  - $priam_res_ra  /3600 ]
               set priam_star_dec [ expr $catalog_dec - $priam_res_dec /3600 ]
               #gren_info "ra = $ra dec_ref=$dec\n"

               set diff_catalog_ra  [expr ($catalog_ra  - $catalog_ref_ra ) * cos($catalog_dec*3.1415926535897931/180)*3600]
               set diff_catalog_dec [expr ($catalog_dec - $catalog_ref_dec) * 3600]

               set diff_priam_ra  [expr ($priam_star_ra  - $priam_ref_ra)  * cos($priam_star_dec*3.1415926535897931/180)*3600]
               set diff_priam_dec [expr ($priam_star_dec - $priam_ref_dec) * 3600]
               #gren_info "diff_ra_catalog = $diff_ra_catalog diff_dec_catalog=$diff_dec_catalog\n"

               
               #set xref [lindex $::bdi_tools_astrometry::dxdy($starref,$date) 0]
               #set yref [lindex $::bdi_tools_astrometry::dxdy($starref,$date) 1]
               #set x    [lindex $::bdi_tools_astrometry::dxdy($name,$date) 0]
               #set y    [lindex $::bdi_tools_astrometry::dxdy($name,$date) 1]
               #set err_x [lindex $::bdi_tools_astrometry::dxdy($name,$date) 2]
               #set err_y [lindex $::bdi_tools_astrometry::dxdy($name,$date) 3]
               
               #set ddx [expr ($x - $xref)*$CDELT1]
               #set ddy [expr ($y - $yref)*$CDELT2]
                         
               #set dx [expr ($x - $xref)*$CDELT1-$diff_ra_catalog ]
               #set dy [expr ($y - $yref)*$CDELT2-$diff_dec_catalog]
               
               # methode 2 : direct avec les ra dec donne par l astrometrie
                         
               set dx [expr $diff_priam_ra  - $diff_catalog_ra ]
               set dy [expr $diff_priam_dec - $diff_catalog_dec]
               
               #gren_info "$name DXDY arcsec  : $dx $dy\n"

               #set dx [format "%.1f" [expr $dx * 1000]]
               #set dy [format "%.1f" [expr $dy * 1000]]
               
               
               #gren_info "$name DXDY mas  : $dx $dy\n"
                
               set chan0 [open [file join $bddconf(dirtmp) "dxdy_$name.dat"] a] 
               puts $chan0 "$name,$date,$dx,$dy,$priam_star_ra,$priam_star_dec"
               close $chan0
                
               set chan0 [open [file join $bddconf(dirtmp) "dxdy_all.dat"] a] 
               puts $chan0 "$name,$date,$dx,$dy,$priam_star_ra,$priam_star_dec"
               close $chan0
               
            }

         }
         
      }
   }

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::create_report_xml { } {

   # clean votable
   set ::bdi_gui_astrometry::rapport_xml ""
   array unset ::bdi_gui_astrometry::rapport_xml_obj
   array set ::bdi_gui_astrometry::rapport_xml_obj {}

   foreach {obj y} [array get ::bdi_tools_astrometry::listscience] {

      # Init VOTable: defini la version et le prefix (mettre "" pour supprimer le prefixe)
      ::votable::init "1.1" ""
      # Ouvre une VOTable
      set votable [::votable::openVOTable]
      # Ajoute l'element INFO pour definir le QUERY_STATUS = "OK" | "ERROR"
      append votable [::votable::addInfoElement "status" "QUERY_STATUS" "OK"] "\n"
      # Ouvre l'element RESOURCE
      append votable [::votable::openResourceElement {} ] "\n"

      # Definition des champs PARAM
      set votParams ""
      set description "Type of data (e.g. astrom|photom)"
      set p [ list "$::votable::Field::ID \"type\"" \
                   "$::votable::Field::NAME \"Type\"" \
                   "$::votable::Field::UCD \" meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"16\"" \
                   "$::votable::Field::WIDTH \"16\"" ]
      lappend p "$::votable::Param::VALUE \"astrom\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set firstdate [::bdi_gui_astrometry::get_first_date_by_name $obj]
      set description "First date of observation of the dataset"
      set p [ list "$::votable::Field::ID \"firstdate\"" \
                   "$::votable::Field::NAME \"FirstDate\"" \
                   "$::votable::Field::UCD \" time.epoch\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"32\"" \
                   "$::votable::Field::WIDTH \"32\"" ]
      lappend p "$::votable::Param::VALUE \"$firstdate\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Observatory IAU code"
      set p [ list "$::votable::Field::ID \"iau_code\"" \
                   "$::votable::Field::NAME \"IAUCode\"" \
                   "$::votable::Field::UCD \" meta.code\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"3\"" \
                   "$::votable::Field::WIDTH \"3\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_astrometry::rapport_uai_code}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Subscriber"
      set p [ list "$::votable::Field::ID \"subscriber\"" \
                   "$::votable::Field::NAME \"Subscriber\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"256\"" \
                   "$::votable::Field::WIDTH \"256\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_astrometry::rapport_rapporteur}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Address"
      set p [ list "$::votable::Field::ID \"address\"" \
                   "$::votable::Field::NAME \"Address\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"256\"" \
                   "$::votable::Field::WIDTH \"256\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_astrometry::rapport_adresse}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Mail"
      set p [ list "$::votable::Field::ID \"mail\"" \
                   "$::votable::Field::NAME \"Mail\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_astrometry::rapport_mail}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Software"
      set p [ list "$::votable::Field::ID \"software\"" \
                   "$::votable::Field::NAME \"Software\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"256\"" \
                   "$::votable::Field::WIDTH \"256\"" ]
      lappend p "$::votable::Param::VALUE \"Audela Bddimages\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Who acquired the data"
      set p [ list "$::votable::Field::ID \"observers\"" \
                   "$::votable::Field::NAME \"Observers\"" \
                   "$::votable::Field::UCD \" obs.observer\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"256\"" \
                   "$::votable::Field::WIDTH \"256\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_astrometry::rapport_observ}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Who reduced the data"
      set p [ list "$::votable::Field::ID \"reduction\"" \
                   "$::votable::Field::NAME \"Reduction\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_astrometry::rapport_reduc}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Instrument used to acquire the data"
      set p [ list "$::votable::Field::ID \"instrument\"" \
                   "$::votable::Field::NAME \"Instrument\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_astrometry::rapport_instru}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Astrometric or Photometric reference catalogue"
      set p [ list "$::votable::Field::ID \"ref_catalogue\"" \
                   "$::votable::Field::NAME \"ReferenceCatalogue\"" \
                   "$::votable::Field::UCD \"meta.id;meta.table\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_astrometry::rapport_cata}\""; # attribut value doit toujours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Batch id"
      set p [ list "$::votable::Field::ID \"batch\"" \
                   "$::votable::Field::NAME \"Batch\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_tools_astrometry::rapport_batch}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Number of dates of observation"
      set p [ list "$::votable::Field::ID \"nb_dates\"" \
                   "$::votable::Field::NAME \"NumberOfDates\"" \
                   "$::votable::Field::UCD \" meta.number\"" \
                   "$::votable::Field::DATATYPE \"int\"" \
                   "$::votable::Field::WIDTH \"6\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,nb)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Total duration of the data"
      set p [ list "$::votable::Field::ID \"duration\"" \
                   "$::votable::Field::NAME \"Duration\"" \
                   "$::votable::Field::UCD \" time.duration\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"s\"" \
                   "$::votable::Field::PRECISION \"4\"" \
                   "$::votable::Field::WIDTH \"10\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,duration)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Number of astrometric or photometric reference stars"
      set p [ list "$::votable::Field::ID \"nb_ref_stars\"" \
                   "$::votable::Field::NAME \"NumberRefStars\"" \
                   "$::votable::Field::UCD \"meta.number\"" \
                   "$::votable::Field::DATATYPE \"int\"" \
                   "$::votable::Field::WIDTH \"6\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_astrometry::nb_ref_stars}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Degree of the polynom used in the astrometric mapping"
      set p [ list "$::votable::Field::ID \"deg_polynom\"" \
                   "$::votable::Field::NAME \"DegreeOfPolynom\"" \
                   "$::votable::Field::UCD \"meta.number\"" \
                   "$::votable::Field::DATATYPE \"int\"" \
                   "$::votable::Field::WIDTH \"6\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_astrometry::polydeg}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Correction of atmospheric refraction applied (1) or not (0)"
      set p [ list "$::votable::Field::ID \"use_refraction\"" \
                   "$::votable::Field::NAME \"UseRefraction\"" \
                   "$::votable::Field::UCD \"meta.number\"" \
                   "$::votable::Field::DATATYPE \"int\"" \
                   "$::votable::Field::WIDTH \"1\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_astrometry::use_refraction}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Correction of EOP applied (1) or not (0)"
      set p [ list "$::votable::Field::ID \"use_eop\"" \
                   "$::votable::Field::NAME \"UseEOP\"" \
                   "$::votable::Field::UCD \"meta.number\"" \
                   "$::votable::Field::DATATYPE \"int\"" \
                   "$::votable::Field::WIDTH \"1\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_astrometry::use_eop}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Correction of debias applied (1) or not (0) (farnocchia et al., ICarus 245, 2015)"
      set p [ list "$::votable::Field::ID \"use_debias\"" \
                   "$::votable::Field::NAME \"UseDebias\"" \
                   "$::votable::Field::UCD \"meta.number\"" \
                   "$::votable::Field::DATATYPE \"int\"" \
                   "$::votable::Field::WIDTH \"1\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_astrometry::use_debias}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Maximum residual of reference stars"
      set p [ list "$::votable::Field::ID \"res_max_ref_stars\"" \
                   "$::votable::Field::NAME \"MaxResidualsRefStars\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.max\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"12\"" \
                   "$::votable::Field::WIDTH \"4\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_astrometry::res_max_ref_stars}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Minimum residual of reference stars"
      set p [ list "$::votable::Field::ID \"res_min_ref_stars\"" \
                   "$::votable::Field::NAME \"MinResidualsRefStars\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.min\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"12\"" \
                   "$::votable::Field::WIDTH \"4\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_astrometry::res_min_ref_stars}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Mean residual of reference stars"
      set p [ list "$::votable::Field::ID \"res_moy_ref_stars\"" \
                   "$::votable::Field::NAME \"MeanResidualsRefStars\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.mean\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"12\"" \
                   "$::votable::Field::WIDTH \"4\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_astrometry::res_mean_ref_stars}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Stdev residual of reference stars"
      set p [ list "$::votable::Field::ID \"res_std_ref_stars\"" \
                   "$::votable::Field::NAME \"StdResidualsRefStars\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.stdev\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"12\"" \
                   "$::votable::Field::WIDTH \"4\"" ]
      lappend p "$::votable::Param::VALUE ${::bdi_tools_astrometry::res_std_ref_stars}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Mean FWHM"
      set p [ list "$::votable::Field::ID \"fwhm_mean\"" \
                   "$::votable::Field::NAME \"FWHM_mean\"" \
                   "$::votable::Field::UCD \"phys.angSize;stat.mean\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"pixel\"" \
                   "$::votable::Field::PRECISION \"7\"" \
                   "$::votable::Field::WIDTH \"4\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table(fwhm)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Stdev FWHM"
      set p [ list "$::votable::Field::ID \"fwhm_std\"" \
                   "$::votable::Field::NAME \"FWHM_std\"" \
                   "$::votable::Field::UCD \"phys.angSize;stat.stdev\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"pixel\"" \
                   "$::votable::Field::PRECISION \"7\"" \
                   "$::votable::Field::WIDTH \"4\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table(fwhm_std)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Mean magnitude"
      set p [ list "$::votable::Field::ID \"mag_mean\"" \
                   "$::votable::Field::NAME \"MeanMagnitude\"" \
                   "$::votable::Field::UCD \"phot.mag;stat.mean\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"8\"" \
                   "$::votable::Field::WIDTH \"4\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,mag)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Stdev magnitude"
      set p [ list "$::votable::Field::ID \"mag_std\"" \
                   "$::votable::Field::NAME \"StdMagnitude\"" \
                   "$::votable::Field::UCD \"phot.mag;stat.stdev\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"8\"" \
                   "$::votable::Field::WIDTH \"4\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,mag_std)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Amplitude of magnitude variations"
      set p [ list "$::votable::Field::ID \"mag_amp\"" \
                   "$::votable::Field::NAME \"AmplitudeOfMagnitude\"" \
                   "$::votable::Field::UCD \"src.var.amplitude\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"8\"" \
                   "$::votable::Field::WIDTH \"4\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,mag_amplitude)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"


      set x [split $::bdi_tools_astrometry::results_table($obj,ra) " "]
      set ra_mean [::bdi_tools::sexa2dec [list [lindex $x 0] [lindex $x 1] [lindex $x 2]] 15.0]
      set description "Mean right ascension"
      set p [ list "$::votable::Field::ID \"ra_mean\"" \
                   "$::votable::Field::NAME \"MeanRA\"" \
                   "$::votable::Field::UCD \"pos.eq.ra;stat.mean\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"deg\"" \
                   "$::votable::Field::PRECISION \"13\"" \
                   "$::votable::Field::WIDTH \"8\"" ]
      lappend p "$::votable::Param::VALUE $ra_mean"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Stdev right ascension"
      set p [ list "$::votable::Field::ID \"ra_std\"" \
                   "$::votable::Field::NAME \"StdRA\"" \
                   "$::votable::Field::UCD \"pos.eq.ra;stat.stdev\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"13\"" \
                   "$::votable::Field::WIDTH \"8\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,ra_std)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set x [split $::bdi_tools_astrometry::results_table($obj,dec) " "]
      set dec_mean [::bdi_tools::sexa2dec [list [lindex $x 0] [lindex $x 1] [lindex $x 2]] 1.0]
      set description "Mean declibation"
      set p [ list "$::votable::Field::ID \"dec_mean\"" \
                   "$::votable::Field::NAME \"MeanDEC\"" \
                   "$::votable::Field::UCD \"pos.eq.dec;stat.mean\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"deg\"" \
                   "$::votable::Field::PRECISION \"13\"" \
                   "$::votable::Field::WIDTH \"8\"" ]
      lappend p "$::votable::Param::VALUE $dec_mean"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Stdev declination"
      set p [ list "$::votable::Field::ID \"dec_std\"" \
                   "$::votable::Field::NAME \"StdDEC\"" \
                   "$::votable::Field::UCD \"pos.eq.dec;stat.stdev\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"13\"" \
                   "$::votable::Field::WIDTH \"8\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,dec_std)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Mean residuals"
      set p [ list "$::votable::Field::ID \"res_mean\"" \
                   "$::votable::Field::NAME \"MeanResiduals\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.mean\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"deg\"" \
                   "$::votable::Field::PRECISION \"13\"" \
                   "$::votable::Field::WIDTH \"8\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,residus)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Stdev residuals"
      set p [ list "$::votable::Field::ID \"res_std\"" \
                   "$::votable::Field::NAME \"StdDEC\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.stdev\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"deg\"" \
                   "$::votable::Field::PRECISION \"13\"" \
                   "$::votable::Field::WIDTH \"8\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,residus_std)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Mean O-C"
      set p [ list "$::votable::Field::ID \"omc_mean\"" \
                   "$::votable::Field::NAME \"MeanOmC\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.mean\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"12\"" \
                   "$::votable::Field::WIDTH \"5\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,omc)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Stdev O-C"
      set p [ list "$::votable::Field::ID \"omc_std\"" \
                   "$::votable::Field::NAME \"StdOmC\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.stdev\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"12\"" \
                   "$::votable::Field::WIDTH \"6\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,omc_std)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Mean O-C along x axis"
      set p [ list "$::votable::Field::ID \"omc_x_mean\"" \
                   "$::votable::Field::NAME \"MeanXOmC\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.mean\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"12\"" \
                   "$::votable::Field::WIDTH \"5\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,omcx)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Stdev O-C along x axis"
      set p [ list "$::votable::Field::ID \"omc_x_std\"" \
                   "$::votable::Field::NAME \"StdXOmC\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.stdev\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"12\"" \
                   "$::votable::Field::WIDTH \"6\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,omcx_std)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Mean O-C along y axis"
      set p [ list "$::votable::Field::ID \"omc_y_mean\"" \
                   "$::votable::Field::NAME \"MeanYOmC\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.mean\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"12\"" \
                   "$::votable::Field::WIDTH \"5\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,omcy)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Stdev O-C along y axis"
      set p [ list "$::votable::Field::ID \"omc_y_std\"" \
                   "$::votable::Field::NAME \"StdYOmC\"" \
                   "$::votable::Field::UCD \"stat.fit.residual;stat.stdev\"" \
                   "$::votable::Field::DATATYPE \"float\"" \
                   "$::votable::Field::UNIT \"arcsec\"" \
                   "$::votable::Field::PRECISION \"12\"" \
                   "$::votable::Field::WIDTH \"6\"" ]
      lappend p "$::votable::Param::VALUE $::bdi_tools_astrometry::results_table($obj,omcy_std)"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Comment"
      set p [ list "$::votable::Field::ID \"comment\"" \
                   "$::votable::Field::NAME \"Comment\"" \
                   "$::votable::Field::UCD \"meta.note\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"512\"" \
                   "$::votable::Field::WIDTH \"512\"" ]
      lappend p "$::votable::Param::VALUE \"${::bdi_gui_astrometry::rapport_comment}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      # Ajoute les params a la votable
      append votable $votParams

      # Definition des champs FIELDS
      set votFields ""
      set description "Object Name"
      set f [ list "$::votable::Field::ID \"object\"" \
                   "$::votable::Field::NAME \"Object\"" \
                   "$::votable::Field::UCD \"meta.id;meta.name\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"24\"" \
                   "$::votable::Field::WIDTH \"24\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "ISO-Date at mid-exposure)"
      set f [ list "$::votable::Field::ID \"isodate\"" \
                   "$::votable::Field::NAME \"ISO-Date\"" \
                   "$::votable::Field::UCD \"time.epoch\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"24\"" \
                   "$::votable::Field::WIDTH \"24\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Julian date at mid-exposure"
      set f [ list "$::votable::Field::ID \"jddate\"" \
                   "$::votable::Field::NAME \"JD-Date\"" \
                   "$::votable::Field::UCD \"time.epoch\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"16\"" \
                   "$::votable::Field::PRECISION \"8\"" \
                   "$::votable::Field::UNIT \"d\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Measured astrometric J2000 right ascension"
      set f [ list "$::votable::Field::ID \"ra\"" \
                   "$::votable::Field::NAME \"RA\"" \
                   "$::votable::Field::UCD \"pos.eq.ra;meta.main\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"6\"" \
                   "$::votable::Field::UNIT \"deg\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Measured astrometric J2000 declination"
      set f [ list "$::votable::Field::ID \"dec\"" \
                   "$::votable::Field::NAME \"DEC\"" \
                   "$::votable::Field::UCD \"pos.eq.dec;meta.main\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"6\"" \
                   "$::votable::Field::UNIT \"deg\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Uncertainty on astrometric J2000 right ascension"
      set f [ list "$::votable::Field::ID \"ra_err\"" \
                   "$::votable::Field::NAME \"RA_err\"" \
                   "$::votable::Field::UCD \"stat.error;pos.eq.ra\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"6\"" \
                   "$::votable::Field::UNIT \"arcsec\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Uncertainty on astrometric J2000 declination"
      set f [ list "$::votable::Field::ID \"dec_err\"" \
                   "$::votable::Field::NAME \"DEC_err\"" \
                   "$::votable::Field::UCD \"stat.error;pos.eq.dec\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"6\"" \
                   "$::votable::Field::UNIT \"arcsec\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Measured magnitude"
      set f [ list "$::votable::Field::ID \"mag\"" \
                   "$::votable::Field::NAME \"Magnitude\"" \
                   "$::votable::Field::UCD \"phot.mag\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"13\"" \
                   "$::votable::Field::PRECISION \"2\"" \
                   "$::votable::Field::UNIT \"mag\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Uncertainty on measured magnitude"
      set f [ list "$::votable::Field::ID \"mag_err\"" \
                   "$::votable::Field::NAME \"Magnitude_err\"" \
                   "$::votable::Field::UCD \"stat.error;phot.mag\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"13\"" \
                   "$::votable::Field::PRECISION \"2\"" \
                   "$::votable::Field::UNIT \"mag\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "O-C of astrometric J2000 right ascension"
      set f [ list "$::votable::Field::ID \"ra_omc\"" \
                   "$::votable::Field::NAME \"RA_omc\"" \
                   "$::votable::Field::UCD \"pos.ang\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"8\"" \
                   "$::votable::Field::PRECISION \"3\"" \
                   "$::votable::Field::UNIT \"arcsec\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "O-C of astrometric J2000 declination"
      set f [ list "$::votable::Field::ID \"dec_omc\"" \
                   "$::votable::Field::NAME \"DEC_omc\"" \
                   "$::votable::Field::UCD \"pos.ang\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"8\"" \
                   "$::votable::Field::PRECISION \"3\"" \
                   "$::votable::Field::UNIT \"arcsec\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Error on x photometric measure"
      set f [ list "$::votable::Field::ID \"err_x\"" \
                   "$::votable::Field::NAME \"Err x\"" \
                   "$::votable::Field::UCD \"stat.error;pos.cartesian.x\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"4\"" \
                   "$::votable::Field::UNIT \"px\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Error on y photometric measure"
      set f [ list "$::votable::Field::ID \"err_y\"" \
                   "$::votable::Field::NAME \"Err y\"" \
                   "$::votable::Field::UCD \"stat.error;pos.cartesian.x\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"4\"" \
                   "$::votable::Field::UNIT \"px\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "FWHM on x"
      set f [ list "$::votable::Field::ID \"fwhm_x\"" \
                   "$::votable::Field::NAME \"fwhm x\"" \
                   "$::votable::Field::UCD \"obs.param;phys.angSize\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"4\"" \
                   "$::votable::Field::UNIT \"px\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "FWHM on y"
      set f [ list "$::votable::Field::ID \"fwhm_y\"" \
                   "$::votable::Field::NAME \"fwhm y\"" \
                   "$::votable::Field::UCD \"obs.param;phys.angSize\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"10\"" \
                   "$::votable::Field::PRECISION \"4\"" \
                   "$::votable::Field::UNIT \"px\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Elevation"
      set f [ list "$::votable::Field::ID \"elevation\"" \
                   "$::votable::Field::NAME \"Elevation\"" \
                   "$::votable::Field::UCD \"pos.ang\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"8\"" \
                   "$::votable::Field::PRECISION \"3\"" \
                   "$::votable::Field::UNIT \"deg\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      set description "Airmass"
      set f [ list "$::votable::Field::ID \"airmass\"" \
                   "$::votable::Field::NAME \"Airmass\"" \
                   "$::votable::Field::UCD \"pos.ang\"" \
                   "$::votable::Field::DATATYPE \"double\"" \
                   "$::votable::Field::WIDTH \"8\"" \
                   "$::votable::Field::PRECISION \"3\"" \
                   "$::votable::Field::UNIT \"-\"" ]
      set field [list $f [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"

      # Construit la table des donnees
      set nrows 0
      set votSources ""
      foreach dateimg $::bdi_tools_astrometry::listscience($obj) {

         # Rend effectif le crop du graphe
         if {[info exists ::bdi_gui_astrometry::graph_results($obj,$dateimg,good)]} {
            if {$::bdi_gui_astrometry::graph_results($obj,$dateimg,good)==0} {continue}
         }

         incr nrows
         append votSources [::votable::openElement $::votable::Element::TR {}]

         # Epoque du milieu de pose au format JD
         set midatejd $::tools_cata::date2midate($dateimg)

         # Epoque du milieu de pose au format ISO
         set midateiso "-"
         if {$midatejd != "-"} { set midateiso [mc_date2iso8601 $midatejd] }

         set res_a   [format "%.4f"  [lindex $::bdi_tools_astrometry::tabval($obj,$dateimg)  4]]
         set res_d   [format "%.4f"  [lindex $::bdi_tools_astrometry::tabval($obj,$dateimg)  5]]
         set alpha   [format "%.8f"  [lindex $::bdi_tools_astrometry::tabval($obj,$dateimg)  6]]
         set delta   [format "%+.8f" [lindex $::bdi_tools_astrometry::tabval($obj,$dateimg)  7]]

         set val [lindex $::bdi_tools_astrometry::tabval($obj,$dateimg)  8]
         if {$val==""} {set mag ""} else {set mag $val}

         set val [lindex $::bdi_tools_astrometry::tabval($obj,$dateimg)  9]
         if {$val==""} {set mag_err ""} else {set mag_err $val}

         set val [lindex $::bdi_tools_astrometry::tabval($obj,$dateimg)  10]
         if {$val==""} {set err_x ""} else {set err_x $val}

         set val [lindex $::bdi_tools_astrometry::tabval($obj,$dateimg)  11]
         if {$val==""} {set err_y ""} else {set err_y $val}

         set fwhm_x  [format "%.4f"  [lindex $::bdi_tools_astrometry::tabval($obj,$dateimg) 12]]
         set fwhm_y  [format "%.4f"  [lindex $::bdi_tools_astrometry::tabval($obj,$dateimg) 13]]

         # Recupere les ephemerides de l'objet courant pour la date courante
         set all_ephem [::bdi_gui_astrometry::get_data_report $obj $dateimg]

         # Ephemerides de l'IMCCE
         set eph_imcce [lindex $all_ephem 0]
         set ra_imcce  [lindex $eph_imcce {1 1 1}]
         set dec_imcce [lindex $eph_imcce {1 1 2}]
         set h_imcce   [lindex $eph_imcce {1 1 3}]
         set am_imcce  [lindex $eph_imcce {1 1 4}]

         # Ephemerides du JPL
         set eph_jpl   [lindex $all_ephem 1]
         set ra_jpl    [lindex $eph_jpl {1 1 1}]
         set dec_jpl   [lindex $eph_jpl {1 1 2}]

         # Calcul des O-C IMCCE
         if {$ra_imcce == "-"} {
            set ra_imcce_omc ""
         } else {
            set ra_imcce_omc [format "%+.4f" [expr ($alpha - $ra_imcce) * 3600.0]]
         }
         if {$dec_imcce == "-"} {
            set dec_imcce_omc ""
         } else {
            set dec_imcce_omc [format "%+.4f" [expr ($delta - $dec_imcce) * 3600.0]]
         }
         # Calcul des O-C JPL
         if {$ra_jpl == "-"} {
            set ra_jpl_omc ""
         } else {
            set ra_jpl_omc [format "%+.4f" [expr ($alpha - $ra_jpl) * 3600.0]]
         }
         if {$dec_jpl == "-"} {
            set dec_jpl_omc ""
         } else {
            set dec_jpl_omc [format "%+.4f" [expr ($delta - $dec_jpl) * 3600.0]]
         }

         # Insertion des data dans la Votable
         append votSources [::votable::addElement $::votable::Element::TD {} $obj]
         append votSources [::votable::addElement $::votable::Element::TD {} $midateiso]
         append votSources [::votable::addElement $::votable::Element::TD {} $midatejd]
         append votSources [::votable::addElement $::votable::Element::TD {} $alpha]
         append votSources [::votable::addElement $::votable::Element::TD {} $delta]
         append votSources [::votable::addElement $::votable::Element::TD {} $res_a]
         append votSources [::votable::addElement $::votable::Element::TD {} $res_d]
         append votSources [::votable::addElement $::votable::Element::TD {} $mag]
         append votSources [::votable::addElement $::votable::Element::TD {} $mag_err]
         append votSources [::votable::addElement $::votable::Element::TD {} $ra_imcce_omc]
         append votSources [::votable::addElement $::votable::Element::TD {} $dec_imcce_omc]
         append votSources [::votable::addElement $::votable::Element::TD {} $err_x]
         append votSources [::votable::addElement $::votable::Element::TD {} $err_y]
         append votSources [::votable::addElement $::votable::Element::TD {} $fwhm_x]
         append votSources [::votable::addElement $::votable::Element::TD {} $fwhm_y]
         append votSources [::votable::addElement $::votable::Element::TD {} $h_imcce]
         append votSources [::votable::addElement $::votable::Element::TD {} $am_imcce]

         append votSources [::votable::closeElement $::votable::Element::TR] "\n"
      }

      # Nom de l'objet science
      set cata [lindex [split $obj "_"] 0]
      switch [string toupper $cata] {
         SKYBOT {
            set sobj [split $obj "_"]
            if {[lindex $sobj 1] == "-"} {
               set zname [lindex $sobj 2]
            } else {
               set zname "[lindex $sobj 1]_[lindex $sobj 2]"
            }
         }
         default {
            set zname $obj
         }
      }

      # Ouvre l'element TABLE
      append votable [::votable::openTableElement [list "$::votable::Table::NAME \"Astrometric results for $zname\"" "$::votable::Table::NROWS $nrows"]] "\n"
      #  Ajoute un element de description de la table
      append votable [::votable::addElement $::votable::Element::DESCRIPTION {} "Astrometric measures of science object $zname obtained by Audela/Bddimages"] "\n"
      #  Ajoute les definitions des colonnes
      append votable $votFields
      #  Ouvre l'element DATA
      append votable [::votable::openElement $::votable::Element::DATA {}] "\n"
      #   Ouvre l'element TABLEDATA
      append votable [::votable::openElement $::votable::Element::TABLEDATA {}] "\n"
      #    Ajoute les sources
      append votable $votSources
      #   Ferme l'element TABLEDATA
      append votable [::votable::closeElement $::votable::Element::TABLEDATA] "\n"
      #  Ferme l'element DATA
      append votable [::votable::closeElement $::votable::Element::DATA] "\n"
      # Ferme l'element TABLE
      append votable [::votable::closeTableElement] "\n"

      # Ferme l'element RESOURCE
      append votable [::votable::closeResourceElement] "\n"
      # Ferme la VOTable
      append votable [::votable::closeVOTable]

      # Sauve la VOTABLE par objet
      set ::bdi_gui_astrometry::rapport_xml_obj($obj) "$votable"

   }

   return

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::save_dateobs { } {

   gren_info "Extraction des dates pour l'objet $::bdi_gui_astrometry::combo_list_object ...\n"

   if {[array exists ::tools_cata::date2midate]} {
      set strdate ""
      foreach {name y} [array get ::bdi_tools_astrometry::listscience] {
         if {$name != $::bdi_gui_astrometry::combo_list_object} {
            continue
         }
         foreach dateimg $::bdi_tools_astrometry::listscience($name) {
            set midepoch $::tools_cata::date2midate($dateimg)
            set strdate "$strdate$datejj\n"
         }
      }
      if {[string length $strdate] > 0} {
         ::bdi_tools::save_as $strdate "DAT"
      } else {
         gren_erreur "  Aucune date a sauver\n"
      }
   } else {
      gren_erreur "  Aucune date chargee: rien a sauver\n"
   }

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::save_posxy { } {

   gren_info "Extraction des dates pour l'objet $::bdi_gui_astrometry::combo_list_object ...\n"
   set strdate ""
   if {[array exists ::tools_cata::date2midate]} {
      foreach {name y} [array get ::bdi_tools_astrometry::listscience] {
         append strdate "#Object = $name\n"
         append strdate "#midepoch         x pixel  y pixel  xerr     yerr   xfwhm  yfwhm\n"
         foreach dateimg $::bdi_tools_astrometry::listscience($name) {

            # Rend effectif le crop du graphe
            if {[info exists ::bdi_gui_astrometry::graph_results($name,$dateimg,good)]} {
               if {$::bdi_gui_astrometry::graph_results($name,$dateimg,good)==0} {continue}
            }

            set midepoch $::tools_cata::date2midate($dateimg)
            set err [ catch { set astroid [::bdi_tools::get_astroid $dateimg $name] } msg ]
            if {$err} {
               gren_erreur "get_astroid = ($err) $msg\n"
               continue
            }
            set x      [format "%.3f" [lindex $astroid 0]]
            set y      [format "%.3f" [lindex $astroid 1]]

         set val [lindex $astroid 2]
         if {$val==""} {set err_x "-"} else {set err_x [format "%.3f" $val]}

         set val [lindex $astroid 3]
         if {$val==""} {set err_y "-"} else {set err_y [format "%.3f" $val]}

            set fwhm_x [format "%.1f" [lindex $astroid 4]]
            set fwhm_y [format "%.1f" [lindex $astroid 5]]

            append strdate [format "%.9f %-8s %-8s %-8s %-8s %-6s %-6s \n" $midepoch $x $y $err_x $err_y $fwhm_x $fwhm_y]
         }
      }
      if {[string length $strdate] > 0} {
         ::bdi_tools::save_as $strdate "DAT"
      } else {
         gren_erreur "  Aucune date a sauver\n"
      }
   } else {
      gren_erreur "  Aucune date chargee: rien a sauver\n"
   }

}


proc ::bdi_gui_astrometry::save_images { } {

   if { $::bdi_tools_astrometry::polydeg != 0 } {
      # la raison vient de Audela qui ne gere pas les entetes autres que le deg 0.
      set msg "Vous devez effectuer une astrometrie de degree 0 "
      append msg "pour pouvoir enregistrer les images.\n\n"
      append msg "Onglets : Astrometry\n\n"
      append msg "Degree of polynom : 0"
      tk_messageBox -message $msg -type ok
      return
   } 

   $::bdi_gui_astrometry::fen.appli.info.fermer configure -state disabled
   $::bdi_gui_astrometry::fen.appli.info.enregistrer configure -state disabled

   set ::bdi_tools_astrometry::savprogress 0
   set ::bdi_tools_astrometry::savannul 0

   set ::bdi_gui_astrometry::fensav .savprogress
   if { [winfo exists $::bdi_gui_astrometry::fensav] } {
      wm withdraw $::bdi_gui_astrometry::fensav
      wm deiconify $::bdi_gui_astrometry::fensav
      focus $::bdi_gui_astrometry::fensav
      return
   }

   toplevel $::bdi_gui_astrometry::fensav -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $::bdi_gui_astrometry::fensav ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::bdi_gui_astrometry::fensav ] "+" ] 2 ]
   wm geometry $::bdi_gui_astrometry::fensav +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $::bdi_gui_astrometry::fensav 1 1
   wm title $::bdi_gui_astrometry::fensav "Enregistrement"
   wm protocol $::bdi_gui_astrometry::fensav WM_DELETE_WINDOW ""

   set frm $::bdi_gui_astrometry::fensav.appli

   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_astrometry::fensav -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

      set data [frame $frm.progress -borderwidth 0 -cursor arrow -relief groove]
      pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          set  pf [ ttk::progressbar $data.p -variable ::bdi_tools_astrometry::savprogress -orient horizontal -length 200 -mode determinate]
          pack $pf -in $data -side top

      set data [frame $frm.boutons -borderwidth 0 -cursor arrow -relief groove]
      pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $data.annul -state active -text "Annuler" -relief "raised" \
             -command "::bdi_gui_astrometry::annul_save_images"
          pack $data.annul -side top -anchor c -padx 0 -padx 10 -pady 5

   ::confColor::applyColor $::bdi_gui_astrometry::fensav

   update
   ::bdi_tools_astrometry::save_images
   destroy $::bdi_gui_astrometry::fensav

   $::bdi_gui_astrometry::fen.appli.info.fermer configure -state normal
   $::bdi_gui_astrometry::fen.appli.info.enregistrer configure -state normal

}




proc ::bdi_gui_astrometry::annul_save_images { } {

   $::bdi_gui_astrometry::fensav.appli.boutons.annul configure -state disabled
   set ::bdi_tools_astrometry::savannul 1

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::psf { t w } {

   set cpt 0
   set date_id ""
   set worklist ""

    gren_info "t=$t\n"
   
   switch $t {

      "srp" {
         if {[llength [$w curselection]]!=1} {
            tk_messageBox -message "Veuillez selectionner une source" -type ok
            return
         }
         set name [lindex [$w get [$w curselection]] 0]
         foreach date $::bdi_tools_astrometry::listref($name) {
            set idsource [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
            lappend date_id [list $idsource $date]
            lappend worklist [list $::tools_cata::date2id($date) $idsource]
            incr cpt
         }
      }

      "sre" {
         set name $::bdi_gui_astrometry::srpt_name
         foreach select [$w curselection] {
            set idsource [lindex [$w get $select] 0]
            set date [lindex [$w get $select] 1]
            lappend date_id [list $idsource $date]
            lappend worklist [list $::tools_cata::date2id($date) $idsource]
            incr cpt
         }
      }

      "ssp" {
         if {[llength [$w curselection]]!=1} {
            tk_messageBox -message "Veuillez selectionner une source" -type ok
            return
         }
         set name [lindex [$w get [$w curselection]] 0]
         foreach date $::bdi_tools_astrometry::listscience($name) {
            set idsource [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
            lappend date_id [list $idsource $date]
            lappend worklist [list $::tools_cata::date2id($date) $idsource]
            incr cpt
         }
      }

      "sse" {
         set name $::bdi_gui_astrometry::sspt_name
         foreach select [$w curselection] {
            set idsource [lindex [$w get $select] 0]
            set date [lindex [$w get $select] 1]
            lappend date_id [list $idsource $date]
            lappend worklist [list $::tools_cata::date2id($date) $idsource]
            incr cpt
         }
      }

      "dsp" {
         if {[llength [$w curselection]]!=1} {
            tk_messageBox -message "Veuillez selectionner une date" -type ok
            return
         }
         set date [lindex [$w get [$w curselection]] 0]
         foreach name $::bdi_tools_astrometry::listdate($date) {
            set idsource [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
            lappend date_id [list $idsource $date]
            lappend worklist [list $::tools_cata::date2id($date) $idsource]
            incr cpt
         }
      }

      "dse" {
         set date $::bdi_tools_astrometry::dspt_selected
         foreach select [$w curselection] {
            set idsource [lindex [$w get $select] 0]
            lappend date_id [list $idsource $date]
            lappend worklist [list $::tools_cata::date2id($date) $idsource]
            incr cpt
         }
      }


      default {
         tk_messageBox -message "::bdi_gui_astrometry::psf: action inconnue" -type ok
         return
      }
   }
   ::bdi_gui_gestion_source::run $worklist
   #::psf_gui::from_astrometry $name $cpt $date_id

}




proc ::bdi_gui_astrometry::graph { xkey ykey } {

   if {[string length $::bdi_gui_astrometry::combo_list_object] < 1} {
      tk_messageBox -message "Veuillez choisir un objet dans la liste" -type ok
      return
   }

   gren_info "Graphe : $xkey VS $ykey\n"

   set x ""
   set z ""
   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name y} $l {
      if {$name !=  $::bdi_gui_astrometry::combo_list_object} {
         continue
      }
      gren_info "Object Selected : $name\n"
      foreach dateimg $::bdi_tools_astrometry::listscience($name) {
         if { $::bdi_gui_astrometry::graph_results($name,$dateimg,good) } {
            if {![info exists ::bdi_gui_astrometry::graph_results($name,$dateimg,$xkey)] || \
                ![info exists ::bdi_gui_astrometry::graph_results($name,$dateimg,$ykey)] } {
                continue
            }
                
            lappend x $::bdi_gui_astrometry::graph_results($name,$dateimg,$xkey)
            lappend z $::bdi_gui_astrometry::graph_results($name,$dateimg,$ykey)
         }
      }
   }

   ::plotxy::clf 1
   ::plotxy::figure 1
   ::plotxy::hold on
   ::plotxy::position {0 0 600 400}
   ::plotxy::title "$::bdi_gui_astrometry::combo_list_object : $xkey VS $ykey"
   ::plotxy::xlabel $xkey
   ::plotxy::ylabel $ykey

   catch { set h [::plotxy::plot $x $z .]
           plotxy::sethandler $h [list -color black -linewidth 0]
         }

}




proc ::bdi_gui_astrometry::graph_crop { } {

   if {[::plotxy::figure] == 0 } {
      gren_erreur "Pas de graphe actif\n"
      return
   }

   set err [ catch {set rect [::plotxy::get_selected_region]} msg]
   if {$err} {
      return
   }
   set x1 [lindex $rect 0]
   set x2 [lindex $rect 2]
   set y1 [lindex $rect 1]
   set y2 [lindex $rect 3]

   if {$x1>$x2} {
      set t $x1
      set x1 $x2
      set x2 $t
   }
   if {$y1>$y2} {
      set t $y1
      set y1 $y2
      set y2 $t
   }

   set xkey [::plotxy::xlabel]
   set ykey [::plotxy::ylabel]

   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name w} $l {
      if {$name !=  $::bdi_gui_astrometry::combo_list_object} {
         continue
      }
      gren_info "Object Selected : $name\n"
      foreach dateimg $::bdi_tools_astrometry::listscience($name) {
         set xx $::bdi_gui_astrometry::graph_results($name,$dateimg,$xkey)
         if { $xx > $x1 && $xx < $x2} {
            set yy $::bdi_gui_astrometry::graph_results($name,$dateimg,$ykey)
            if { $yy > $y1 && $yy < $y2} {
               continue
            }
         }
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,good) 0
      }
   }

   ::bdi_gui_astrometry::graph $xkey $ykey
}




proc ::bdi_gui_astrometry::graph_uncrop { } {

   set xkey [::plotxy::xlabel]
   set ykey [::plotxy::ylabel]

   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name w} $l {
      if {$name !=  $::bdi_gui_astrometry::combo_list_object} {
         continue
      }
      gren_info "Object Selected : $name\n"
      foreach dateimg $::bdi_tools_astrometry::listscience($name) {
         set ::bdi_gui_astrometry::graph_results($name,$dateimg,good) 1
      }
   }

   ::bdi_gui_astrometry::graph $xkey $ykey
}




proc ::bdi_gui_astrometry::graph_voir_source { } {

   if {[::plotxy::figure] == 0 } {
      gren_erreur "Pas de graphe actif\n"
      return
   }

   set err [ catch {set rect [::plotxy::get_selected_region]} msg]
   if {$err} {
      return
   }
   set x1 [lindex $rect 0]
   set x2 [lindex $rect 2]
   set y1 [lindex $rect 1]
   set y2 [lindex $rect 3]

   if {$x1>$x2} {
      set t $x1
      set x1 $x2
      set x2 $t
   }
   if {$y1>$y2} {
      set t $y1
      set y1 $y2
      set y2 $t
   }

   set xkey [::plotxy::xlabel]
   set ykey [::plotxy::ylabel]
   set x ""
   set y ""
   set worklist ""

   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name w} $l {
      if {$name !=  $::bdi_gui_astrometry::combo_list_object} {
         continue
      }
      gren_info "Object Selected : $name\n"
      foreach dateimg $::bdi_tools_astrometry::listscience($name) {
         set xx $::bdi_gui_astrometry::graph_results($name,$dateimg,$xkey)
         if { $xx > $x1 && $xx < $x2} {
            set yy $::bdi_gui_astrometry::graph_results($name,$dateimg,$ykey)
            if { $yy > $y1 && $yy < $y2} {
               lappend x $xx
               lappend y $yy
               set idsource $::bdi_gui_astrometry::graph_results($name,$dateimg,idsource)
               set date $dateimg
               lappend worklist [list $::tools_cata::date2id($dateimg) $idsource]
               continue
            }
         }
      }
   }
   set name $::bdi_gui_astrometry::combo_list_object
   gren_info "Voir la source\n"
   gren_info "Objet = $name\n"

   gren_info "worklist = $worklist\n"

   ::bdi_gui_gestion_source::run $worklist

   return

   if { [llength $x]>1 || [llength $y]>1 } {
      ::console::affiche_erreur "Selectionner 1 seul point\n"
      return
   }

   set name $::bdi_gui_astrometry::combo_list_object
   gren_info "Voir la source\n"
   gren_info "date image = $date\n"
   gren_info "Objet = $name\n"
   #incr idsource -1
   gren_info "Idsource = $idsource\n"

# TODO afficher la psf
   ::psf_gui::from_astrometry $name 1 [list [list $idsource $date]]

}




proc ::bdi_gui_astrometry::set_list2combo { } {

   set nb_obj [llength $::bdi_gui_astrometry::object_list]
   $::bdi_gui_astrometry::fen.appli.onglets.list.ephem.onglets.list.jpl.input.obj.combo configure -height $nb_obj -values $::bdi_gui_astrometry::object_list
   $::bdi_gui_astrometry::fen.appli.onglets.list.graphes.selinobj.obj.combo configure -height $nb_obj -values $::bdi_gui_astrometry::object_list
   $::bdi_gui_astrometry::fen.appli.onglets.list.rapports.onglets.list.misc.select_obj.combo configure -height $nb_obj -values $::bdi_gui_astrometry::object_list

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::affich_catalist {  } {

   set tt0 [clock clicks -milliseconds]
   ::bdi_tools_astrometry::create_vartab
   gren_info "Creation de la structure de variable en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"

   # Charge la liste des objets SCIENCE
   set ::bdi_gui_astrometry::object_list [::bdi_tools_astrometry::get_object_list]
   ::bdi_gui_astrometry::set_list2combo

   set tt0 [clock clicks -milliseconds]
   ::bdi_tools_astrometry::calcul_statistique
   gren_info "Calculs des statistiques en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"

   set tt0 [clock clicks -milliseconds]

   $::bdi_gui_astrometry::srpt delete 0 end
   $::bdi_gui_astrometry::sret delete 0 end
   $::bdi_gui_astrometry::sspt delete 0 end
   $::bdi_gui_astrometry::sset delete 0 end
   $::bdi_gui_astrometry::sat  delete 0 end
   $::bdi_gui_astrometry::dspt delete 0 end
   $::bdi_gui_astrometry::dset delete 0 end
   $::bdi_gui_astrometry::dwpt delete 0 end

   foreach name [array names ::bdi_tools_astrometry::listref] {
      $::bdi_gui_astrometry::srpt insert end $::bdi_tools_astrometry::tabref($name)
   }

   foreach name [array names ::bdi_tools_astrometry::listscience] {
      $::bdi_gui_astrometry::sspt insert end $::bdi_tools_astrometry::tabscience($name)
   }

   foreach date [array names ::bdi_tools_astrometry::listdate] {
      $::bdi_gui_astrometry::dspt insert end $::bdi_tools_astrometry::tabdate($date)
      $::bdi_gui_astrometry::dwpt insert end $::bdi_tools_astrometry::tabdate($date)
   }

   foreach date [array names ::bdi_tools_astrometry::listdate] {
      foreach name [array names ::bdi_tools_astrometry::listscience] {
         if {[info exists ::bdi_tools_astrometry::tabscience($name,$date)]} {
            $::bdi_gui_astrometry::sat insert end $::bdi_tools_astrometry::tabscience($name,$date)
         }
      }
      foreach name [array names ::bdi_tools_astrometry::listref] {
         if {[info exists ::bdi_tools_astrometry::tabref($name,$date)]} {
            $::bdi_gui_astrometry::sat insert end $::bdi_tools_astrometry::tabref($name,$date)
         }
      }
   }

   # Tri les resultats en fonction de la colonne Rho
   catch {
      $::bdi_gui_astrometry::srpt sortbycolumn 2 -decreasing
      $::bdi_gui_astrometry::sspt sortbycolumn 2 -decreasing
      $::bdi_gui_astrometry::sat  sortbycolumn 3  -decreasing
      $::bdi_gui_astrometry::srpt see 0
      $::bdi_gui_astrometry::sspt see 0
      $::bdi_gui_astrometry::sat  see 0
   }
   
   
   gren_info "Affichage des resultats en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"
   gren_info "Nb reference : [$::bdi_gui_astrometry::srpt size]\n"
}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::go_ephem {  } {

   # Verifie la presence d'un code UAI
   if {[string length [string trim $::bdi_tools_astrometry::rapport_uai_code]] == 0} {
      tk_messageBox -message "Veuillez definir le code UAI des observations (onglet Rapports->Entetes->IAU Code)" -type ok
      return
   }

   gren_info "Generation des ephemerides des objets SCIENCE ...\n"

   if {$::bdi_tools_astrometry::use_ephem_imcce} {
      set err [::bdi_tools_astrometry::get_ephem_imcce]
      if {$err != 0} {
         gren_erreur "WARNING: le calcul des ephemerides IMCCE a echoue\n"
      }
   }

   if {$::bdi_tools_astrometry::use_ephem_jpl} {
      set err [::bdi_tools_astrometry::compose_ephem_jpl]
      if {$err != 0} {
         gren_erreur "WARNING: le calcul des ephemerides JPL a echoue\n"
      }
   }

   gren_info "done\n"
}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::go_priam {  } {

   set tt0 [clock clicks -milliseconds]

   ::bdi_tools_astrometry::init_priam
   ::bdi_tools_astrometry::exec_priam
   gren_info "Determination de la solution astrometrique (Priam) en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"

   if {$::bdi_tools_astrometry::use_debias == 1} {
      ::bdi_tools_astrometry::apply_debias
      gren_info "Debiaisage de la solution astrometrique (Debias) en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"
   }

   ::bdi_gui_astrometry::affich_catalist

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::get_first_date {  } {


   set i 0
   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name y} $l {
      set cata [::manage_source::name_cata $name]
      if {$cata != "SKYBOT"} {continue}
      foreach date $::bdi_tools_astrometry::listscience($name) {
         incr i
         set date [string range $date 0 9]
         if {$i==1} { 
            set datemin $date
            continue
         }
         if {[string compare $datemin $date]==1} {
            set datemin $date
         }
      }
   }
   return "DateObs.$datemin"
}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::get_first_date_by_name { myname } {

   set datemin ""
   set i 0
   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name y} $l {
      if {$name != $myname} {continue}
      set cata [::manage_source::name_cata $name]
      foreach date $::bdi_tools_astrometry::listscience($name) {
         incr i
         set date [string range $date 0 9]
         if {$i==1} { 
            set datemin $date
            continue
         }
         if {[string compare $datemin $date]==1} {
            set datemin $date
         }
      }
   }
   return $datemin
}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::cut_object_name { name } {
   # ::bdi_gui_astrometry::cut_object_name SKYBOT_202421_2005_UQ513
   
   set pos [expr [string first _ $name] +1]
   set name [string range $name $pos end]
   set pos [expr [string first _ $name] +1]
   set name [string range $name $pos end]
   return $name
}

#----------------------------------------------------------------------------

proc ::bdi_gui_astrometry::get_objects {  } {

   set names ".Obj"
   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name y} $l {
      set cata [::manage_source::name_cata $name]
      if {$cata != "SKYBOT"} {continue}
         gren_info "name = $name\n"
         append names ".[::bdi_gui_astrometry::cut_object_name $name]"
   }
   return $names
}

#----------------------------------------------------------------------------

proc ::bdi_gui_astrometry::get_objects_complete {  } {

   set names ""
   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name y} $l {
      set cata [::manage_source::name_cata $name]
      if {$cata != "SKYBOT"} {continue}
         gren_info "name = $name\n"
         append names ".[::bdi_gui_astrometry::cut_object_name $name]"
   }
   return $names
}

#----------------------------------------------------------------------------

proc ::bdi_gui_astrometry::list_objects {  } {

   set names ""
   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name y} $l {
      set cata [::manage_source::name_cata $name]
      lappend names $name
   }
   return $names
}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::get_info_list { obj firstdate } {

   array unset ::bdi_gui_astrometry::rapport_info_obj
   array set ::bdi_gui_astrometry::rapport_info_obj {}

   set type              "astrom"
   set batch             ${::bdi_tools_astrometry::rapport_batch}
   set submit_mpc        [expr $::bdi_tools_astrometry::rapport_mpc_submit == 0 ? "no" : "yes"]
   set iau_code          ${::bdi_tools_astrometry::rapport_uai_code}
   set subscriber        ${::bdi_tools_astrometry::rapport_rapporteur}
   set address           ${::bdi_tools_astrometry::rapport_adresse}
   set mail              ${::bdi_tools_astrometry::rapport_mail}
   set software          "Audela Bddimages Priam"
   set observers         ${::bdi_tools_astrometry::rapport_observ}
   set reduction         ${::bdi_tools_astrometry::rapport_reduc}
   set instrument        ${::bdi_tools_astrometry::rapport_instru}
   set nb_dates          $::bdi_tools_astrometry::results_table($obj,nb)
   set duration          $::bdi_tools_astrometry::results_table($obj,duration)
   set ref_catalogue     ${::bdi_tools_astrometry::rapport_cata}
   set nb_ref_stars      ${::bdi_tools_astrometry::nb_ref_stars}
   set deg_polynom       ${::bdi_tools_astrometry::polydeg}
   set use_refraction    ${::bdi_tools_astrometry::use_refraction}
   set use_eop           ${::bdi_tools_astrometry::use_eop}
   set use_debias        ${::bdi_tools_astrometry::use_debias}
   set res_max_refstars  ${::bdi_tools_astrometry::res_max_ref_stars}
   set res_min_refstars  ${::bdi_tools_astrometry::res_min_ref_stars}
   set res_mean_refstars ${::bdi_tools_astrometry::res_mean_ref_stars}
   set res_std_refstars  ${::bdi_tools_astrometry::res_std_ref_stars}
   set fwhm_mean         $::bdi_tools_astrometry::results_table(fwhm)
   set fwhm_std          $::bdi_tools_astrometry::results_table(fwhm_std)
   set mag_mean          $::bdi_tools_astrometry::results_table($obj,mag)
   set mag_std           $::bdi_tools_astrometry::results_table($obj,mag_std)
   set mag_amp           $::bdi_tools_astrometry::results_table($obj,mag_amplitude)
   set ra_mean           $::bdi_tools_astrometry::results_table($obj,ra)
   set ra_std            $::bdi_tools_astrometry::results_table($obj,ra_std)
   set dec_mean          $::bdi_tools_astrometry::results_table($obj,dec)
   set dec_std           $::bdi_tools_astrometry::results_table($obj,dec_std)
   set residus_mean      $::bdi_tools_astrometry::results_table($obj,residus)
   set residus_std       $::bdi_tools_astrometry::results_table($obj,residus_std)
   set omc_mean          $::bdi_tools_astrometry::results_table($obj,omc)
   set omc_std           $::bdi_tools_astrometry::results_table($obj,omc_std)
   set omc_x_mean        $::bdi_tools_astrometry::results_table($obj,omcx)
   set omc_y_mean        $::bdi_tools_astrometry::results_table($obj,omcy)
   set omc_x_std         $::bdi_tools_astrometry::results_table($obj,omcx_std)
   set omc_y_std         $::bdi_tools_astrometry::results_table($obj,omcy_std)
   set comment           ${::bdi_gui_astrometry::rapport_comment}

   return [list obj $obj type $type firstdate $firstdate batch $batch submit_mpc $submit_mpc iau_code $iau_code \
                subscriber $subscriber address $address mail $mail software $software observers $observers reduction $reduction \
                instrument $instrument nb_dates $nb_dates duration $duration ref_catalogue $ref_catalogue nb_ref_stars $nb_ref_stars \
                deg_polynom $deg_polynom use_refraction $use_refraction use_eop $use_eop use_debias $use_debias res_max_ref_stars $res_max_refstars \
                res_min_ref_stars $res_min_refstars res_mean_ref_stars $res_mean_refstars res_std_ref_stars $res_std_refstars \
                fwhm_mean $fwhm_mean fwhm_std $fwhm_std mag_mean $mag_mean mag_std $mag_std mag_amp $mag_amp ra_mean $ra_mean \
                ra_std $ra_std dec_mean $dec_mean dec_std $dec_std residuals_mean $residus_mean residuals_std $residus_std \
                omc_mean $omc_mean omc_std $omc_std omc_x_mean $omc_x_mean omc_y_mean $omc_y_mean omc_x_std $omc_x_std \
                omc_y_std $omc_y_std comment $comment]

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::create_reports {  } {

   # Verifie la presence d'un code UAI
   if {[string length [string trim $::bdi_tools_astrometry::rapport_uai_code]] == 0} {
      tk_messageBox -message "Veuillez definir le code UAI des observations (onglet Rapports->Entetes->IAU Code)" -type ok
      return
   }

   gren_info "Generation des rapports d'observations ...\n"

   # Batch
   set ::bdi_tools_astrometry::rapport_batch [::bdi_tools_reports::get_batch]

   # Liste des catalogue de reference
   set l [array get ::bdi_tools_astrometry::listref]
   set clist ""
   foreach {name y} $l {
      set cata [lindex [split $name "_"] 0]
      set pos [lsearch $clist $cata]
      if {$pos==-1} {
         lappend clist $cata
      }
   }
   set ::bdi_tools_astrometry::rapport_cata ""
   set separ ""
   foreach cata $clist {
      append ::bdi_tools_astrometry::rapport_cata "${separ}${cata}"
      if {$separ == ""} {set separ " "}
   }

   # Generation des rapports
   ::bdi_gui_astrometry::compute_final_results
   
   gren_info " ... rapport MPC\n"
   ::bdi_gui_astrometry::create_report_mpc
   gren_info " ... rapport TXT\n"
   ::bdi_gui_astrometry::create_report_txt
   gren_info " ... rapport XML\n"
   ::bdi_gui_astrometry::create_report_xml
   gren_info "done\n"

}


#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::save_all_reports {  } {

   global bddconf

   gren_info "Sauvegarde de tous les rapports :\n"

   # Definition du batch
   set batch ${::bdi_tools_astrometry::rapport_batch}

   # Pour chaque objet
   foreach obj [::bdi_gui_astrometry::list_objects] {

      gren_info "Object: $obj\n"
      set cata [lindex [split $obj "_"] 0]

      # Creation de la structure de rep.: objet
      set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj]
      createdir_ifnot_exist $dir

      # Creation de la structure de rep.: date
      set date [::bdi_gui_astrometry::get_first_date_by_name $obj]
      set dir [file join $dir $date]
      createdir_ifnot_exist $dir

      # Creation de la structure de rep.: batch
      set dir [file join $dir $batch]
      createdir_ifnot_exist $dir

      # Sauvegarde du commentaire
      set file [file join $dir [::bdi_tools_reports::build_filename $obj $date $batch "info" "txt"]]
      gren_info "  - Rapport INFO : $file\n"
      set info_list [::bdi_gui_astrometry::get_info_list $obj $date]
      ::bdi_tools_reports::list_to_file_info $file info_list

      # Sauvegarde des donnees ASTROM MPC
      if {[string toupper $cata] == "SKYBOT"} {
         set file [file join $dir [::bdi_tools_reports::build_filename $obj $date $batch "astrom" "mpc"]]
         gren_info "  - Rapport MPC : $file\n"
         set chan [open $file w]
         puts $chan "$::bdi_gui_astrometry::rapport_mpc_obj($obj)"
         close $chan
      }

      # Sauvegarde des donnees ASTROM TXT
      set file [file join $dir [::bdi_tools_reports::build_filename $obj $date $batch "astrom" "txt"]]
      gren_info "  - Rapport IMCCE TXT: $file\n"
      set chan [open $file w]
      puts $chan "$::bdi_gui_astrometry::rapport_txt_obj($obj)"
      close $chan

      # Sauvegarde des donnees ASTROM XML
      set file [file join $dir [::bdi_tools_reports::build_filename $obj $date $batch "astrom" "xml"]]
      gren_info "  - Rapport IMCCE XML: $file\n"
      set chan [open $file w]
      puts $chan "$::bdi_gui_astrometry::rapport_xml_obj($obj)"
      close $chan

   }

   return 0
}


#proc ::bdi_gui_astrometry::save_all_reports_old {  } {
#
#
#   gren_info "Sauvegarde de tous les rapports :\n"
#
#   # Recuperation des info pour construction des nom de fichier
#   set part_date    [::bdi_gui_astrometry::get_first_date]
#   set part_objects [::bdi_gui_astrometry::get_objects]
#   if {$::bdi_tools_astrometry::rapport_mpc_submit==0} {
#      set part_submit ".submit.no"
#   } else {
#      set part_submit ".submit.yes"
#   }
#   set part_batch ".Batch.${::bdi_tools_astrometry::rapport_batch}"
#   
#   # Sauveagarde des donnees MPC
#   set file "${part_date}${part_objects}${part_submit}${part_batch}.mpc"
#   set file [file join $::bdi_tools_astrometry::rapport_mpc_dir $file]
#   set chan [open $file w]
#   puts $chan "[$::bdi_gui_astrometry::rapport_mpc get 0.0 end]"
#   close $chan
#   gren_info "Rapport MPC : $file\n"
#   # Sauveagarde des donnees IMCCE
#   set file "${part_date}${part_objects}${part_submit}${part_batch}.txt"
#   set file [file join $::bdi_tools_astrometry::rapport_imc_dir $file]
#   set chan [open $file w]
#   puts $chan "[$::bdi_gui_astrometry::rapport_txt get 0.0 end]"
#   close $chan
#   gren_info "Rapport IMCCE TXT: $file\n"
#   # Sauveagarde des donnees XML
#   set file "${part_date}${part_objects}${part_submit}${part_batch}.xml"
#   set file [file join $::bdi_tools_astrometry::rapport_xml_dir $file]
#   set chan [open $file w]
#   puts $chan "$::bdi_gui_astrometry::rapport_xml"
#   close $chan
#   gren_info "Rapport IMCCE XML: $file\n"
#
#   return 0
#}

#----------------------------------------------------------------------------


proc ::bdi_gui_astrometry::affich_gestion {  } {

   gren_info "\n\n\n-----------\n"
   set tt0 [clock clicks -milliseconds]

   if {$::bdi_gui_astrometry::state_gestion == 0} {
      catch {destroy $::bdi_gui_cata_gestion::fen}
      gren_info "Chargement des fichiers XML\n"
      ::bdi_gui_cata_gestion::go $::tools_cata::img_list
      set ::bdi_gui_astrometry::state_gestion 1
   }

   if {[info exists ::bdi_gui_cata_gestion::state_gestion] && $::bdi_gui_cata_gestion::state_gestion == 1} {
      gren_info "Chargement depuis la fenetre de gestion des sources\n"
      ::bdi_gui_astrometry::affich_catalist
   } else {
      catch {destroy $::bdi_gui_cata_gestion::fen}
      gren_info "Chargement des fichiers XML\n"
      ::bdi_gui_cata_gestion::go $::tools_cata::img_list
   }

   # Focus sur la gui
   focus $::bdi_gui_astrometry::fen

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Chargement complet en $tt sec \n"

   return

}




proc ::bdi_gui_astrometry::charge_element_rapport { } {

   set current_image [lindex $::tools_cata::img_list 0]
   set tabkey [::bddimages_liste::lget $current_image "tabkey"]
   set datei  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]

   set ::bdi_tools_astrometry::rapport_uai_code [string trim [lindex [::bddimages_liste::lget $tabkey "IAU_CODE"] 1] ]
   set ::bdi_tools_astrometry::rapport_observ   [string trim [lindex [::bddimages_liste::lget $tabkey "OBSERVER"] 1] ]

   set ex [::bddimages_liste::lexist $tabkey "INSTRUME"]
   if {$ex != 0} {
      set ::bdi_tools_astrometry::rapport_instru [string trim [lindex [::bddimages_liste::lget $tabkey "INSTRUME"] 1] ]
   }

   # Nombre de positions rapportees
   set cpt 0
   set l [array get ::bdi_tools_astrometry::listscience]
   foreach {name y} $l {
      foreach date $::bdi_tools_astrometry::listscience($name) {
         incr cpt
      }
   }
   set ::bdi_tools_astrometry::rapport_nb $cpt

}




#----------------------------------------------------------------------------
## Chargement de l'astrometrie pour chaque image de la structure img_list
# \note le resultat de cette procedure affecte la variable de 
# namespace \c tools_cata::img_list puis charge toutes l'info 
# concernant l'astrometrie
#----------------------------------------------------------------------------
# set astrom(kwds)     {RA       DEC       CRPIX1      CRPIX2      CRVAL1       CRVAL2       CDELT1      CDELT2      CROTA1    CROTA2      CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN       PIXSIZE1       PIXSIZE2        CATA_PVALUE        EQUINOX       CTYPE1        CTYPE2      LONPOLE                                        CUNIT1                       CUNIT2                       }
# set astrom(units)    {deg      deg       pixel       pixel       deg          deg          deg/pixel   deg/pixel   deg       deg         deg/pixel     deg/pixel     deg/pixel     deg/pixel     m            mum            mum             percent            no            no            no          deg                                            no                           no                           }
# set astrom(types)    {double   double    double      double      double       double       double      double      double    double      double        double        double        double        double       double         double          double             string        string        string      double                                         string                       string                       }
# set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Rotation of coordinate" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included" "Pvalue of astrometric reduction" "System of equatorial coordinates" "Gnomonic projection" "Gnomonic projection" "Long. of the celest.NP in native coor.syst."  "Angles are degrees always"  "Angles are degrees always"  }
#----------------------------------------------------------------------------
proc ::bdi_gui_astrometry::charge_solution_astrometrique {  } {

   gren_info "DATEOBS charge_solution_astrometrique *** \n"

   set id_current_image 0
   ::bdi_tools_astrometry::set_fields_astrom astrom
   set n [llength $astrom(kwds)]
   array unset ::tools_cata::date2midate

   foreach current_image $::tools_cata::img_list {

      incr id_current_image

      set ::tools_cata::new_astrometry($id_current_image) ""

      # Tabkey
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      # Date obs au format ISO
      set dateobs [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      # Exposure
      set exposure [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"] 1] ]

      if {$exposure == -1} {
         gren_erreur "WARNING: Exposure inconnu pour l'image : $date\n"
         set midexpo 0
      } else {
         set midexpo [expr ($exposure/2.0) / 86400.0]
      }
      # Calcul de midate au format JD
      array set ::tools_cata::date2midate [list $dateobs [expr [mc_date2jd $dateobs] + $midexpo]]
      
      gren_info "DATEOBS : $dateobs :: MIDDATE : [mc_date2iso8601 [expr [mc_date2jd $dateobs] + $midexpo]] :: MIDDATE : [expr [mc_date2jd $dateobs] + $midexpo] :: $exposure [expr $midexpo * 86400.0 * 2.0]\n"
      
      for {set k 0 } { $k<$n } {incr k} {
         set kwd [lindex $astrom(kwds) $k]
         foreach key $tabkey {
            if {[string equal -nocase [lindex $key 0] $kwd] } {
               set type [lindex $astrom(types) $k]
               set unit [lindex $astrom(units) $k]
               set comment [lindex $astrom(comments) $k]
               set val [lindex [lindex $key 1] 1]
               lappend ::tools_cata::new_astrometry($id_current_image) [list $kwd $val $type $unit $comment]
            }
         }
      }
   }
}




#----------------------------------------------------------------------------
## Chargement de la liste d'image selectionnee dans l'outil Recherche.
#  \param img_list structure de liste d'images
#  \note le resultat de cette procedure affecte la variable de
# namespace  \c img_list puis charge toutes l'info
# concernant l'astrometrie
#----------------------------------------------------------------------------
proc ::bdi_gui_astrometry::charge_list { img_list } {

  catch {
      if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
      if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
      if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
   }

   set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
   set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
   set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

   ::bdi_gui_astrometry::charge_solution_astrometrique
   ::bdi_gui_astrometry::charge_element_rapport

}


#----------------------------------------------------------------------------

proc ::bdi_gui_astrometry::setup { img_list } {

   global audace
   global conf bddconf


   ::bdi_gui_astrometry::inittoconf
   ::bdi_gui_astrometry::charge_list $img_list
   ::bdi_gui_astrometry::setup_gui
   
   # Au lancement, charge les donnees
   ::bdi_gui_astrometry::affich_gestion

}

proc ::bdi_gui_astrometry::recharge_gui {  } {

   ::bddimages::ressource
   ::console::clear
   ::bdi_gui_astrometry::fermer
   ::bdi_gui_astrometry::setup_gui

}


proc ::bdi_gui_astrometry::toggle_cndobs { } {

   set s [expr {$::bdi_tools_astrometry::cndobs_from_header == 1 ? "disabled" : "normal"}]
   $::bdi_gui_astrometry::parameteo.valo configure -state $s
   $::bdi_gui_astrometry::parameteo.vald configure -state $s
   $::bdi_gui_astrometry::parameteo.valh configure -state $s
   $::bdi_gui_astrometry::parameteo.valb configure -state $s

}


#----------------------------------------------------------------------------
proc ::bdi_gui_astrometry::setup_gui { } {

   global audace
   global conf bddconf


   #--- 
   set wdth 13
   set nb_obj 1

   set loc_sources_par [list 0 "Name"              left  \
                             0 "Nb img"            right \
                             0 "\u03C1"            right \
                             0 "stdev \u03C1"      right \
                             0 "moy res \u03B1"    right \
                             0 "moy res \u03B4"    right \
                             0 "stdev res \u03B1"  right \
                             0 "stdev res \u03B4"  right \
                             0 "moy \u03B1"        right \
                             0 "moy \u03B4"        right \
                             0 "stdev \u03B1"      right \
                             0 "stdev \u03B4"      right \
                             0 "moy Mag"           right \
                             0 "stdev Mag"         right \
                             0 "moy err x"         right \
                             0 "moy err y"         right ]
   set loc_dates_enf   [list 0 "Id"                right \
                             0 "Date-obs"          left  \
                             0 "\u03C1"            right \
                             0 "res \u03B1"        right \
                             0 "res \u03B4"        right \
                             0 "\u03B1"            right \
                             0 "\u03B4"            right \
                             0 "Mag"               right \
                             0 "err_Mag"           right \
                             0 "err x"             right \
                             0 "err y"             right ]
      #   0  ids        : id source
      #   1  name       :
      #   2  date       :
      #   3  rho        : rho =  rayon des residu
      #   4  res_ra     : residu alpha
      #   5  res_dec    : residu delta
      #   6  mag        : magnitude
      #   7  err_xsm    : erreur sur position X pixel
      #   8  err_ysm    : erreur sur position X pixel
      #   9  fwhmx      : fwhm en X
      #   10 fwhmy      : fwhm en Y
   set loc_allsources  [list 0 "Ids"               right \
                             0 "Name"              left  \
                             0 "Date-obs"          left  \
                             0 "\u03C1"            right \
                             0 "res \u03B1"        right \
                             0 "res \u03B4"        right \
                             0 "mag"               right \
                             0 "err xsm"           right \
                             0 "err ysm"           right \
                             0 "fwhmx"             right \
                             0 "fwhmy"             right ]
                             
   set loc_dates_par   [list 0 "Date-obs"          left  \
                             0 "Nb ref"            right \
                             0 "\u03C1"            right \
                             0 "stdev \u03C1"      right \
                             0 "moy res \u03B1"    right \
                             0 "moy res \u03B4"    right \
                             0 "stdev res \u03B1"  right \
                             0 "stdev res \u03B4"  right \
                             0 "moy \u03B1"        right \
                             0 "moy \u03B4"        right \
                             0 "stdev \u03B1"      right \
                             0 "stdev \u03B4"      right \
                             0 "moy Mag"           right \
                             0 "stdev Mag"         right \
                             0 "moy err x"         right \
                             0 "moy err y"         right ]
   set loc_sources_enf [list 0 "Id"                right \
                             0 "Name"              left  \
                             0 "type"              center \
                             0 "\u03C1"            right \
                             0 "res \u03B1"        right \
                             0 "res \u03B4"        right \
                             0 "\u03B1"            right \
                             0 "\u03B4"            right \
                             0 "Mag"               right \
                             0 "err_Mag"           right \
                             0 "err x"             right \
                             0 "err y"             right ]
   set loc_wcs_enf     [list 0 "Cles"              left \
                             0 "Valeur"            center  \
                             0 "type"              center \
                             0 "unite"             center \
                             0 "commentaire"       left ]

   #--- Geometry
   if { ! [ info exists conf(bddimages,geometry_astrometry) ] } { set conf(bddimages,geometry_astrometry) "+165+55" }
   set bddconf(geometry_astrometry) $conf(bddimages,geometry_astrometry)

   set ::bdi_gui_astrometry::fen .astrometry
   if { [winfo exists $::bdi_gui_astrometry::fen] } {
      wm withdraw $::bdi_gui_astrometry::fen
      wm deiconify $::bdi_gui_astrometry::fen
      focus $::bdi_gui_astrometry::fen
      return
   }

   toplevel $::bdi_gui_astrometry::fen -class Toplevel
   wm geometry $::bdi_gui_astrometry::fen $bddconf(geometry_astrometry)
   wm resizable $::bdi_gui_astrometry::fen 1 1
   wm title $::bdi_gui_astrometry::fen "Astrometrie"
   wm protocol $::bdi_gui_astrometry::fen WM_DELETE_WINDOW "::bdi_gui_astrometry::fermer"

   set frm $::bdi_gui_astrometry::fen.appli

   #--- Cree un frame general
   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_astrometry::fen -anchor s -side top -expand yes -fill both  -padx 10 -pady 5

      #--- Cree un frame pour afficher bouton fermeture
      set actions [frame $frm.actions  -borderwidth 0 -cursor arrow -relief groove]
      pack $actions  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           set ::bdi_gui_astrometry::gui_affich_gestion [button $actions.affich_gestion -text "Charge" \
               -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_astrometry::affich_gestion"]
           pack $actions.affich_gestion -side left -anchor e \
              -padx 5 -pady 5 -ipadx 2 -ipady 2 -expand 0

           set ::bdi_gui_astrometry::gui_go_priam [button $actions.go_priam -text "1. Priam" \
              -borderwidth 2 -takefocus 1 -command "::bdi_gui_astrometry::go_priam"]
           pack $actions.go_priam -side left -anchor e \
              -padx 5 -pady 5 -ipadx 2 -ipady 2 -expand 0

           set ::bdi_gui_astrometry::gui_get_ephem [button $actions.get_ephem -text "2. Ephemerides" \
              -borderwidth 2 -takefocus 1 -command "::bdi_gui_astrometry::go_ephem"]
           pack $actions.get_ephem -side left -anchor e \
              -padx 5 -pady 5 -ipadx 2 -ipady 2 -expand 0

           set ::bdi_gui_astrometry::gui_generer_rapport [button $actions.generer_rapport -text "3. Generer Rapport" \
              -borderwidth 2 -takefocus 1 -command "::bdi_gui_astrometry::create_reports"]
           pack $actions.generer_rapport -side left -anchor e \
              -padx 5 -pady 5 -ipadx 2 -ipady 2 -expand 0


      #--- Cree un frame pour afficher les tables et les onglets
      set tables [frame $frm.tables  -borderwidth 0 -cursor arrow -relief groove]
      pack $tables  -in $frm -anchor s -side top -expand 0  -padx 10 -pady 5

      set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
      pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5

         pack [ttk::notebook $onglets.list] -expand yes -fill both

         set sources [frame $onglets.list.sources]
         pack $sources -in $onglets.list -expand yes -fill both
         $onglets.list add $sources -text "Sources"

         set dates [frame $onglets.list.dates]
         pack $dates -in $onglets.list -expand yes -fill both
         $onglets.list add $dates -text "Dates"

         set astrom [frame $onglets.list.astrom]
         pack $astrom -in $onglets.list -expand yes -fill both
         $onglets.list add $astrom -text "Astrometry"

         set ephem [frame $onglets.list.ephem]
         pack $ephem -in $onglets.list -expand yes -fill both
         $onglets.list add $ephem -text "Ephemerides"

         set rapports [frame $onglets.list.rapports]
         pack $rapports -in $onglets.list -expand yes -fill both
         $onglets.list add $rapports -text "Rapports"

         set graphes [frame $onglets.list.graphes]
         pack $graphes -in $onglets.list -expand yes -fill both
         $onglets.list add $graphes -text "Graphes"

         set analyse [frame $onglets.list.analyse]
         pack $analyse -in $onglets.list -expand yes -fill both
         $onglets.list add $analyse -text "Analyse"

         set dev [frame $onglets.list.dev]
         pack $dev -in $onglets.list -expand yes -fill both
         $onglets.list add $dev -text "Dev"

      #--- Onglet SOURCES
      set onglets_sources [frame $sources.onglets -borderwidth 1 -cursor arrow -relief groove]
      pack $onglets_sources -in $sources -side top -expand yes -fill both -padx 10 -pady 5

           pack [ttk::notebook $onglets_sources.list] -expand yes -fill both

           set references [frame $onglets_sources.list.references -borderwidth 1]
           pack $references -in $onglets_sources.list -expand yes -fill both
           $onglets_sources.list add $references -text "References"

           set sciences [frame $onglets_sources.list.sciences -borderwidth 1]
           pack $sciences -in $onglets_sources.list -expand yes -fill both
           $onglets_sources.list add $sciences -text "Sciences"

           set allsources [frame $onglets_sources.list.allsources -borderwidth 1]
           pack $allsources -in $onglets_sources.list -expand yes -fill both
           $onglets_sources.list add $allsources -text "All Sources"

      #--- Onglet DATES
      set onglets_dates [frame $dates.onglets -borderwidth 1 -cursor arrow -relief groove]
      pack $onglets_dates -in $dates -side top -expand yes -fill both -padx 10 -pady 5

           pack [ttk::notebook $onglets_dates.list] -expand yes -fill both

           set sour [frame $onglets_dates.list.sources -borderwidth 1]
           pack $sour -in $onglets_dates.list -expand yes -fill both
           $onglets_dates.list add $sour -text "Sources"

           set wcs [frame $onglets_dates.list.wcs -borderwidth 1]
           pack $wcs -in $onglets_dates.list -expand yes -fill both
           $onglets_dates.list add $wcs -text "WCS"

      #--- Onglet ASTROMETRY
      set onglets_astrom [frame $astrom.onglets -borderwidth 1 -cursor arrow -relief groove]
      pack $onglets_astrom -in $astrom -side top -anchor c -expand yes -fill y -padx 10 -pady 10 -ipadx 20 -ipady 20

       set onglets_astromG [frame $onglets_astrom.g -borderwidth 1 -cursor arrow -relief flat]
       pack $onglets_astromG -in $onglets_astrom -side left -anchor c -expand yes -fill both -padx 10 -pady 10

         set opts $onglets_astromG.opts
         TitleFrame $opts -borderwidth 2 -text "Parametres pour la\nreduction astrometrique" -font $bddconf(font,arial_10_b) -relief ridge -baseline center -ipad 20 -side center
         grid $opts -in $onglets_astromG -sticky nsew -padx 20 -pady 20

            label $opts.labo -text "Axes orientation: "
            entry $opts.valo -relief sunken -textvariable ::bdi_tools_astrometry::orient -width 3
            label $opts.labd -text "Degree of polynom: "
            entry $opts.vald -relief sunken -textvariable ::bdi_tools_astrometry::polydeg -width 3
            label $opts.labrefrac -text "Atmospheric refraction: "
            checkbutton $opts.crefrac -highlightthickness 0 -variable ::bdi_tools_astrometry::use_refraction
            label $opts.labeop -text "EOP correction: "
            checkbutton $opts.ceop -highlightthickness 0 -variable ::bdi_tools_astrometry::use_eop
            label $opts.labdebias -text "Debias correction: "
            checkbutton $opts.cdebias -highlightthickness 0 -variable ::bdi_tools_astrometry::use_debias
            label $opts.labfinal -text "set BDI ASTROMETRY = FINAL "
            checkbutton $opts.cfinal -highlightthickness 0 -variable ::bdi_tools_astrometry::update_bdi_astrom_key

            grid $opts.labo $opts.valo -in [$opts getframe] -sticky nsw -pady 5
            grid configure $opts.labo -sticky nse -padx 5
            grid $opts.labd $opts.vald -in [$opts getframe] -sticky nsw -pady 5
            grid configure $opts.labd -sticky nse -padx 5
            grid $opts.labrefrac $opts.crefrac -in [$opts getframe] -sticky nsw -pady 5
            grid configure $opts.labrefrac -sticky nse -padx 5
            grid $opts.labeop $opts.ceop -in [$opts getframe] -sticky nsw -pady 5
            grid configure $opts.labeop -sticky nse -padx 5
            grid $opts.labdebias $opts.cdebias -in [$opts getframe] -sticky nsw -pady 5
            grid configure $opts.labdebias -sticky nse -padx 5
            grid $opts.labfinal $opts.cfinal -in [$opts getframe] -sticky nsw -pady 5
            grid configure $opts.labfinal -sticky nse -padx 5

       set onglets_astromD [frame $onglets_astrom.d -borderwidth 1 -cursor arrow -relief flat]
       pack $onglets_astromD -in $onglets_astrom -side left -anchor c -expand yes -fill both -padx 10 -pady 10

         set ::bdi_gui_astrometry::parameteo $onglets_astromD.meteo
         TitleFrame $::bdi_gui_astrometry::parameteo -borderwidth 2 -text "Parametres des\nconditions d'observation" -font $bddconf(font,arial_10_b) -relief ridge -baseline center -ipad 20 -side center
         grid $::bdi_gui_astrometry::parameteo -in $onglets_astromD -sticky nsew -padx 20 -pady 20

            label $::bdi_gui_astrometry::parameteo.labauto -text "Utiliser les parametres des images "
            checkbutton $::bdi_gui_astrometry::parameteo.cauto -highlightthickness 0 -variable ::bdi_tools_astrometry::cndobs_from_header -command {::bdi_gui_astrometry::toggle_cndobs}
            label $::bdi_gui_astrometry::parameteo.labo -text "Temperature (deg. C): "
            entry $::bdi_gui_astrometry::parameteo.valo -relief sunken -textvariable ::bdi_tools_astrometry::tempair -width 7
            label $::bdi_gui_astrometry::parameteo.labd -text "Pression (hPa): "
            entry $::bdi_gui_astrometry::parameteo.vald -relief sunken -textvariable ::bdi_tools_astrometry::airpress -width 7
            label $::bdi_gui_astrometry::parameteo.labh -text "Humidite (%): "
            entry $::bdi_gui_astrometry::parameteo.valh -relief sunken -textvariable ::bdi_tools_astrometry::hydro -width 7
            label $::bdi_gui_astrometry::parameteo.labb -text "Longueur d'onde (mum): "
            entry $::bdi_gui_astrometry::parameteo.valb -relief sunken -textvariable ::bdi_tools_astrometry::bandwidth -width 7

            grid $::bdi_gui_astrometry::parameteo.labauto $::bdi_gui_astrometry::parameteo.cauto -in [$::bdi_gui_astrometry::parameteo getframe] -sticky nsw -pady 5
            grid configure $::bdi_gui_astrometry::parameteo.labauto -sticky nse -padx 5
            grid $::bdi_gui_astrometry::parameteo.labo $::bdi_gui_astrometry::parameteo.valo -in [$::bdi_gui_astrometry::parameteo getframe] -sticky nsw -pady 5
            grid configure $::bdi_gui_astrometry::parameteo.labo -sticky nse -padx 5
            grid $::bdi_gui_astrometry::parameteo.labd $::bdi_gui_astrometry::parameteo.vald -in [$::bdi_gui_astrometry::parameteo getframe] -sticky nsw -pady 5
            grid configure $::bdi_gui_astrometry::parameteo.labd -sticky nse -padx 5
            grid $::bdi_gui_astrometry::parameteo.labh $::bdi_gui_astrometry::parameteo.valh -in [$::bdi_gui_astrometry::parameteo getframe] -sticky nsw -pady 5
            grid configure $::bdi_gui_astrometry::parameteo.labh -sticky nse -padx 5
            grid $::bdi_gui_astrometry::parameteo.labb $::bdi_gui_astrometry::parameteo.valb -in [$::bdi_gui_astrometry::parameteo getframe] -sticky nsw -pady 5
            grid configure $::bdi_gui_astrometry::parameteo.labb -sticky nse -padx 5

         ::bdi_gui_astrometry::toggle_cndobs

      #--- Onglet EPHEMERIDES
      set onglets_ephem [frame $ephem.onglets -borderwidth 0 -cursor arrow -relief groove]
      pack $onglets_ephem -in $ephem -side top -expand yes -fill both -padx 10 -pady 5

         pack [ttk::notebook $onglets_ephem.list] -expand yes -fill both

         set imcce [frame $onglets_ephem.list.imcce -borderwidth 1]
         pack $imcce -in $onglets_ephem.list -expand yes -fill both
         $onglets_ephem.list add $imcce -text "IMCCE"

         set jpl [frame $onglets_ephem.list.jpl -borderwidth 1]
         pack $jpl -in $onglets_ephem.list -expand yes -fill both
         $onglets_ephem.list add $jpl -text "JPL"

            #--- EPHEM IMCCE
            set onglets_ephem_imcce [frame $imcce.input -borderwidth 0 -cursor arrow -relief groove]
            pack $onglets_ephem_imcce -in $imcce -side top -expand 0 -fill x -padx 5 -pady 5 -anchor n

               checkbutton $onglets_ephem_imcce.use -highlightthickness 0 -text " Calculer les ephemerides IMCCE" \
                  -font $bddconf(font,arial_10_b) -variable ::bdi_tools_astrometry::use_ephem_imcce
               pack $onglets_ephem_imcce.use -in $onglets_ephem_imcce -side top -padx 5 -pady 2 -anchor w

               set block [frame $onglets_ephem_imcce.prgme -borderwidth 0 -cursor arrow -relief groove]
               pack $block -in $onglets_ephem_imcce -side top -expand 0 -fill x -padx 2 -pady 2
                  label $block.lab -text "Programme ephemcc : " -width 20 -justify left
                  pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                  entry $block.val -relief sunken -textvariable ::bdi_tools_astrometry::imcce_ephemcc
                  pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

               set block [frame $onglets_ephem_imcce.options -borderwidth 0 -cursor arrow -relief groove]
               pack $block -in $onglets_ephem_imcce -side top -expand 0 -fill x -padx 2 -pady 2
                  label $block.lab -text "Options pour ephemcc : " -width 20 -justify left
                  pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                  entry $block.val -relief sunken -textvariable ::bdi_tools_astrometry::ephemcc_options
                  pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

               frame $onglets_ephem_imcce.space -borderwidth 0 -cursor arrow -height 10
               pack $onglets_ephem_imcce.space -in $onglets_ephem_imcce -side top -expand 0 -fill x -padx 2 -pady 2

               set block [frame $onglets_ephem_imcce.ifort -borderwidth 0 -cursor arrow -relief groove]
               pack $block -in $onglets_ephem_imcce -side top -expand 0 -fill x -padx 2 -pady 2
                  label $block.lab -text "Path to ifort : " -width 20 -justify left
                  pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                  entry $block.val -relief sunken -textvariable ::bdi_tools_astrometry::ifortlib
                  pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

               set block [frame $onglets_ephem_imcce.local -borderwidth 0 -cursor arrow -relief groove]
               pack $block -in $onglets_ephem_imcce -side top -expand 0 -fill x -padx 2 -pady 2
                  label $block.lab -text "Library path : " -width 20 -justify left
                  pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                  entry $block.val -relief sunken -textvariable ::bdi_tools_astrometry::locallib
                  pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

            #--- EPHEM JPL
            set onglets_ephem_jpl [frame $jpl.input -borderwidth 0 -cursor arrow -relief groove]
            pack $onglets_ephem_jpl -in $jpl -side top -expand yes -fill both -padx 5 -pady 5 -anchor n

               checkbutton $onglets_ephem_jpl.use -highlightthickness 0 -text " Calculer les ephemerides JPL" \
                   -font $bddconf(font,arial_10_b) -variable ::bdi_tools_astrometry::use_ephem_jpl
               pack $onglets_ephem_jpl.use -in $onglets_ephem_jpl -side top -padx 5 -pady 2 -anchor w

               set block [frame $onglets_ephem_jpl.obj -borderwidth 0 -cursor arrow -relief groove]
               pack $block -in $onglets_ephem_jpl -side top -expand 0 -fill x -padx 2 -pady 2
                  label $block.lab -text "Objet Science : " -width 12
                  pack $block.lab -in $block -side left -padx 5 -pady 2 -fill x
                  ComboBox $block.combo \
                     -width 50 -height $nb_obj \
                     -relief sunken -borderwidth 1 -editable 0 \
                     -textvariable ::bdi_gui_astrometry::combo_list_object \
                     -values $::bdi_gui_astrometry::object_list
                  pack $block.combo -side left -fill x -expand 0

               set block [frame $onglets_ephem_jpl.exped  -borderwidth 0 -cursor arrow -relief groove]
               pack $block -in $onglets_ephem_jpl -side top -expand 0 -fill x -padx 2 -pady 3
                  label $block.lab -text "Destinataire : " -width 12
                  pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                  entry $block.val -relief sunken -textvariable ::bdi_tools_jpl::destinataire
                  pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

               set block [frame $onglets_ephem_jpl.subj  -borderwidth 0 -cursor arrow -relief groove]
               pack $block -in $onglets_ephem_jpl -side top -expand 0 -fill x -padx 2 -pady 3
                     label $block.lab -text "Sujet : " -width 12
                     pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                     entry $block.val -relief sunken -textvariable ::bdi_tools_jpl::sujet
                     pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

               #set ::bdi_gui_astrometry::getjpl_send $onglets_ephem_jpl.sendtext
               #   text $::bdi_gui_astrometry::getjpl_send -height 30  \
               #        -xscrollcommand "$::bdi_gui_astrometry::getjpl_send.xscroll set" \
               #        -yscrollcommand "$::bdi_gui_astrometry::getjpl_send.yscroll set" \
               #        -wrap none
               #   pack $::bdi_gui_astrometry::getjpl_send -expand yes -fill both -padx 5 -pady 5
               #
               #   scrollbar $::bdi_gui_astrometry::getjpl_send.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_astrometry::getjpl_send xview"
               #   pack $::bdi_gui_astrometry::getjpl_send.xscroll -side bottom -fill x
               #
               #   scrollbar $::bdi_gui_astrometry::getjpl_send.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_astrometry::getjpl_send yview"
               #   pack $::bdi_gui_astrometry::getjpl_send.yscroll -side right -fill y

               #set block [frame $onglets_ephem_jpl.butaction -borderwidth 0 -cursor arrow -relief groove]
               #pack $block -in $onglets_ephem_jpl -side top -expand 0 -padx 2 -pady 5
               #      button $block.butread -text "Read" -borderwidth 2 -takefocus 1 -command "" -state disable
               #      pack $block.butread -side right -anchor c -expand 0
               #      button $block.butsend -text "Send" -borderwidth 2 -takefocus 1 -command "" -state disable
               #      pack $block.butsend -side right -anchor c -expand 0
               #      button $block.butcreate -text "Create" -borderwidth 2 -takefocus 1 -command "" -state disable
               #      pack $block.butcreate -side right -anchor c -expand 0

               set block [frame $onglets_ephem_jpl.reponse -borderwidth 1 -cursor arrow -relief groove]
               pack $block -in $onglets_ephem_jpl -side top -expand 1 -fill both -padx 5 -pady 5
                  label $block.lab -text "Copier/coller ci-dessous les ephemerides renvoyees par Horizons@JPL" -font $bddconf(font,arial_10_b)
                  pack $block.lab -side top -anchor c -fill x -padx 3 -pady 3

                  set recv [frame $block.reponse -borderwidth 0 -cursor arrow -relief groove]
                  pack $recv -in $block -side top -expand 1 -fill both -padx 5 -pady 5

                     set ::bdi_gui_astrometry::getjpl_recev $recv.recevtext
                     text $::bdi_gui_astrometry::getjpl_recev -height 30 \
                          -xscrollcommand "$::bdi_gui_astrometry::getjpl_recev.xscroll set" \
                          -yscrollcommand "$::bdi_gui_astrometry::getjpl_recev.yscroll set" \
                          -wrap none
                     pack $::bdi_gui_astrometry::getjpl_recev -side left -expand yes -fill both -padx 3

                     set but [frame $recv.but -borderwidth 0]
                     pack $but -in $recv -side left -expand 0 -fill y
                        button $but.butread -text "Read" -borderwidth 2 -takefocus 1 -command "::bdi_tools_astrometry::read_ephem_jpl"
                        pack $but.butread -side top -anchor n -expand 0 -fill x
                        button $but.butclean -text "Clean" -borderwidth 2 -takefocus 1 -command "$::bdi_gui_astrometry::getjpl_recev delete 0.0 end"
                        pack $but.butclean -side top -anchor n -expand 0 -fill x

                  scrollbar $::bdi_gui_astrometry::getjpl_recev.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_astrometry::getjpl_recev xview"
                  pack $::bdi_gui_astrometry::getjpl_recev.xscroll -side bottom -fill x

                  scrollbar $::bdi_gui_astrometry::getjpl_recev.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_astrometry::getjpl_recev yview"
                  pack $::bdi_gui_astrometry::getjpl_recev.yscroll -side right -fill y

      #--- Onglet RAPPORTS
      set onglets_rapports [frame $rapports.onglets -borderwidth 1 -cursor arrow -relief groove]
      pack $onglets_rapports -in $rapports -side top -expand yes -fill both -padx 10 -pady 5

         pack [ttk::notebook $onglets_rapports.list] -expand yes -fill both

         set entetes [frame $onglets_rapports.list.entetes -borderwidth 1]
         pack $entetes -in $onglets_rapports.list -expand yes -fill both
         $onglets_rapports.list add $entetes -text "Entetes"

         set mpc [frame $onglets_rapports.list.mpc -borderwidth 1]
         pack $mpc -in $onglets_rapports.list -expand yes -fill both
         $onglets_rapports.list add $mpc -text "MPC"

         set txt [frame $onglets_rapports.list.txt -borderwidth 1]
         pack $txt -in $onglets_rapports.list -expand yes -fill both
         $onglets_rapports.list add $txt -text "TXT"

         set misc [frame $onglets_rapports.list.misc -borderwidth 1]
         pack $misc -in $onglets_rapports.list -expand yes -fill both
         $onglets_rapports.list add $misc -text "MISC"

         set save [frame $onglets_rapports.list.save -borderwidth 1]
         pack $save -in $onglets_rapports.list -expand yes -fill both
         $onglets_rapports.list add $save -text "SAVE"

      #--- TABLE Sources - References Parent (par liste de source et moyenne)
      set srp [frame $onglets_sources.list.references.parent -borderwidth 1 -cursor arrow -relief groove -background white]
      pack $srp -in $onglets_sources.list.references -expand yes -fill both -side left

           set ::bdi_gui_astrometry::srpt $srp.table

           tablelist::tablelist $::bdi_gui_astrometry::srpt \
             -columns $loc_sources_par \
             -labelcommand tablelist::sortByColumn \
             -xscrollcommand [ list $srp.hsb set ] \
             -yscrollcommand [ list $srp.vsb set ] \
             -selectmode extended \
             -activestyle none \
             -stripebackground "#e0e8f0" \
             -showseparators 1

           scrollbar $srp.hsb -orient horizontal -command [list $::bdi_gui_astrometry::srpt xview]
           pack $srp.hsb -in $srp -side bottom -fill x
           scrollbar $srp.vsb -orient vertical -command [list $::bdi_gui_astrometry::srpt yview]
           pack $srp.vsb -in $srp -side left -fill y

           menu $srp.popupTbl -title "Actions"

               menu $srp.popupTbl.psf -tearoff 0
               $srp.popupTbl add cascade -label "PSF" -menu $srp.popupTbl.psf

                    $srp.popupTbl.psf add command -label "Manuel" \
                       -command "::bdi_gui_astrometry::psf srp $::bdi_gui_astrometry::srpt"

                    $srp.popupTbl.psf add command -label "Auto" \
                       -command "::bdi_gui_cata_gestion::psf_auto srpt $::bdi_gui_astrometry::srpt"
                       
               $srp.popupTbl add command -label "Voir l'objet dans une image" \
                   -command {::bdi_gui_cata::voirobj_srpt}
               $srp.popupTbl add command -label "Supprimer de toutes les images" \
                   -command {::bdi_gui_astrometry::unset_srpt $::bdi_gui_astrometry::srpt}

           #--- bindings
           bind $::bdi_gui_astrometry::srpt <<ListboxSelect>> [ list ::bdi_gui_astrometry::cmdButton1Click_srpt %W ]
           bind [$::bdi_gui_astrometry::srpt bodypath] <ButtonPress-3> [ list tk_popup $srp.popupTbl %X %Y ]

           pack $::bdi_gui_astrometry::srpt -in $srp -expand yes -fill both

           # tri des colonnes en mode reel pour les colonnes de 1 a 15
           for {set col 1} {$col <=1} {incr col} {
              $::bdi_gui_astrometry::srpt columnconfigure $col -sortmode real
           }
           

      #--- TABLE Sources - References Enfant (par liste de date chaque mesure)
      set sre [frame $onglets_sources.list.references.enfant -borderwidth 0 -cursor arrow -relief groove -background white]
      pack $sre -in $onglets_sources.list.references -expand yes -fill both -side left

           set ::bdi_gui_astrometry::sret $sre.table

           tablelist::tablelist $::bdi_gui_astrometry::sret \
             -columns $loc_dates_enf \
             -labelcommand tablelist::sortByColumn \
             -xscrollcommand [ list $sre.hsb set ] \
             -yscrollcommand [ list $sre.vsb set ] \
             -selectmode extended \
             -activestyle none \
             -stripebackground "#e0e8f0" \
             -showseparators 1

           scrollbar $sre.hsb -orient horizontal -command [list $::bdi_gui_astrometry::sret xview]
           pack $sre.hsb -in $sre -side bottom -fill x
           scrollbar $sre.vsb -orient vertical -command [list $::bdi_gui_astrometry::sret yview]
           pack $sre.vsb -in $sre -side right -fill y

           menu $sre.popupTbl -title "Actions"

               menu $sre.popupTbl.psf -tearoff 0
               $sre.popupTbl add cascade -label "PSF" -menu $sre.popupTbl.psf

                    $sre.popupTbl.psf add command -label "Manuel" \
                       -command "::bdi_gui_astrometry::psf sre $::bdi_gui_astrometry::sret"

                    $sre.popupTbl.psf add command -label "Auto" \
                       -command "::bdi_gui_cata_gestion::psf_auto sret $::bdi_gui_astrometry::sret"
                       
               $sre.popupTbl add command -label "Voir l'objet dans cette image" \
                   -command "::bdi_gui_cata::voirobj_sret"
               $sre.popupTbl add command -label "Supprimer" \
                  -command {::bdi_gui_astrometry::unset_sret $::bdi_gui_astrometry::sret}

           bind [$::bdi_gui_astrometry::sret bodypath] <ButtonPress-3> [ list tk_popup $sre.popupTbl %X %Y ]

           pack $::bdi_gui_astrometry::sret -in $sre -expand yes -fill both

      #--- TABLE Sources - Science Parent (par liste de source et moyenne)
      set ssp [frame $onglets_sources.list.sciences.parent -borderwidth 1 -cursor arrow -relief groove -background white]
      pack $ssp -in $onglets_sources.list.sciences -expand yes -fill both -side left

           set ::bdi_gui_astrometry::sspt $onglets_sources.list.sciences.parent.table

           tablelist::tablelist $::bdi_gui_astrometry::sspt \
             -columns $loc_sources_par \
             -labelcommand tablelist::sortByColumn \
             -xscrollcommand [ list $ssp.hsb set ] \
             -yscrollcommand [ list $ssp.vsb set ] \
             -selectmode extended \
             -activestyle none \
             -stripebackground "#e0e8f0" \
             -showseparators 1
           
           scrollbar $ssp.hsb -orient horizontal -command [list $::bdi_gui_astrometry::sspt xview]
           pack $ssp.hsb -in $ssp -side bottom -fill x
           scrollbar $ssp.vsb -orient vertical -command [list $::bdi_gui_astrometry::sspt yview]
           pack $ssp.vsb -in $ssp -side left -fill y

           menu $ssp.popupTbl -title "Actions"

               menu $ssp.popupTbl.psf -tearoff 0
               $ssp.popupTbl add cascade -label "PSF" -menu $ssp.popupTbl.psf
                    $ssp.popupTbl.psf add command -label "Manuel" \
                       -command "::bdi_gui_astrometry::psf ssp $::bdi_gui_astrometry::sspt"
                    $ssp.popupTbl.psf add command -label "Auto" \
                       -command "::bdi_gui_cata_gestion::psf_auto sspt $::bdi_gui_astrometry::sspt"

               $ssp.popupTbl add command -label "Voir l'objet dans une image" \
                   -command "::bdi_gui_cata::voirobj_sspt"
               $ssp.popupTbl add command -label "Supprimer de toutes les images" \
                   -command {::bdi_gui_astrometry::unset_sspt $::bdi_gui_astrometry::sspt}

           bind $::bdi_gui_astrometry::sspt <<ListboxSelect>> [ list ::bdi_gui_astrometry::cmdButton1Click_sspt %W ]
           bind [$::bdi_gui_astrometry::sspt bodypath] <ButtonPress-3> [ list tk_popup $ssp.popupTbl %X %Y ]

           pack $::bdi_gui_astrometry::sspt -in $ssp -expand yes -fill both

      #--- TABLE Sources - Science Enfant (par liste de date chaque mesure)
      set sse [frame $onglets_sources.list.sciences.enfant -borderwidth 1 -cursor arrow -relief groove -background white]
      pack $sse -in $onglets_sources.list.sciences -expand yes -fill both -side left

           set ::bdi_gui_astrometry::sset $onglets_sources.list.sciences.enfant.table

           tablelist::tablelist $::bdi_gui_astrometry::sset \
             -columns $loc_dates_enf \
             -labelcommand tablelist::sortByColumn \
             -xscrollcommand [ list $sse.hsb set ] \
             -yscrollcommand [ list $sse.vsb set ] \
             -selectmode extended \
             -activestyle none \
             -stripebackground "#e0e8f0" \
             -showseparators 1

           scrollbar $sse.hsb -orient horizontal -command [list $::bdi_gui_astrometry::sset xview]
           pack $sse.hsb -in $sse -side bottom -fill x
           scrollbar $sse.vsb -orient vertical -command [list $::bdi_gui_astrometry::sset yview]
           pack $sse.vsb -in $sse -side right -fill y

           menu $sse.popupTbl -title "Actions"

               menu $sse.popupTbl.psf -tearoff 0
               $sse.popupTbl add cascade -label "PSF" -menu $sse.popupTbl.psf
                    $sse.popupTbl.psf add command -label "Manuel" \
                       -command "::bdi_gui_astrometry::psf sse $::bdi_gui_astrometry::sset"
                    $sse.popupTbl.psf add command -label "Auto" \
                       -command "::bdi_gui_cata_gestion::psf_auto sset $::bdi_gui_astrometry::sset"

               $sse.popupTbl add command -label "Voir l'objet dans cette image" \
                   -command "::bdi_gui_cata::voirobj_sset"
               $sse.popupTbl add command -label "Supprimer" \
                  -command {::bdi_gui_astrometry::unset_sset $::bdi_gui_astrometry::sset}

           bind [$::bdi_gui_astrometry::sset bodypath] <ButtonPress-3> [ list tk_popup $sse.popupTbl %X %Y ]

           pack $::bdi_gui_astrometry::sset -in $sse -expand yes -fill both

      #--- TABLE ALl Sources - Science et reference toutes dates
      set sa [frame $onglets_sources.list.allsources.parent -borderwidth 1 -cursor arrow -relief groove -background white]
      pack $sa -in $onglets_sources.list.allsources -expand yes -fill both -side left

           set ::bdi_gui_astrometry::sat $onglets_sources.list.allsources.parent.table

           tablelist::tablelist $::bdi_gui_astrometry::sat \
             -columns $loc_allsources \
             -labelcommand tablelist::sortByColumn \
             -xscrollcommand [ list $sa.hsb set ] \
             -yscrollcommand [ list $sa.vsb set ] \
             -selectmode extended \
             -activestyle none \
             -stripebackground "#e0e8f0" \
             -showseparators 1
           
           scrollbar $sa.hsb -orient horizontal -command [list $::bdi_gui_astrometry::sat xview]
           pack $sa.hsb -in $sa -side bottom -fill x
           scrollbar $sa.vsb -orient vertical -command [list $::bdi_gui_astrometry::sat yview]
           pack $sa.vsb -in $sa -side left -fill y

           menu $sa.popupTbl -title "Actions"

               menu $sa.popupTbl.psf -tearoff 0
               $sa.popupTbl add cascade -label "PSF" -menu $sa.popupTbl.psf
                    $sa.popupTbl.psf add command -label "Manuel" -state disabled -command "::bdi_gui_astrometry::psf sa $::bdi_gui_astrometry::sat"
                    $sa.popupTbl.psf add command -label "Auto" -state disabled -command "::bdi_gui_cata_gestion::psf_auto sat $::bdi_gui_astrometry::sat"

               $sa.popupTbl add command -label "Voir l'objet dans une image" -state disabled -command "::bdi_gui_cata::voirobj_sat"
               $sa.popupTbl add command -label "Supprimer" -command {::bdi_gui_astrometry::unset_sat $::bdi_gui_astrometry::sat}

           #bind $::bdi_gui_astrometry::sat <<ListboxSelect>> [ list ::bdi_gui_astrometry::cmdButton1Click_sat %W ]
           bind [$::bdi_gui_astrometry::sat bodypath] <ButtonPress-3> [ list tk_popup $sa.popupTbl %X %Y ]
           pack $::bdi_gui_astrometry::sat -in $sa -expand yes -fill both

           #   0  ids        : id source
           #   1  name       :
           #   2  date       :
           #   3  rho        : rho =  rayon des residu
           #   4  res_ra     : residu alpha
           #   5  res_dec    : residu delta
           #   6  mag        : magnitude
           #   7  err_xsm    : erreur sur position X pixel
           #   8  err_ysm    : erreur sur position X pixel
           #   9  fwhmx      : fwhm en X
           #   10 fwhmy      : fwhm en Y
           # tri des colonnes en mode reel pour les colonnes de 1 a 10
           foreach col [list 3 4 5 6 7 8 9 10 ] {
              $::bdi_gui_astrometry::sat columnconfigure $col -sortmode real
           }
           foreach col [list 0 ] {
              $::bdi_gui_astrometry::sat columnconfigure $col -sortmode integer
           }
           foreach col [list 1 2 ] {
              $::bdi_gui_astrometry::sat columnconfigure $col -sortmode ascii
           }

      #--- TABLE Dates - Sources Parent (par liste de dates et moyenne)
      set dsp [frame $onglets_dates.list.sources.parent -borderwidth 1 -cursor arrow -relief groove -background white]
      pack $dsp -in $onglets_dates.list.sources -expand yes -fill both -side left

           set ::bdi_gui_astrometry::dspt $onglets_dates.list.sources.parent.table

           tablelist::tablelist $::bdi_gui_astrometry::dspt \
             -columns $loc_dates_par \
             -labelcommand tablelist::sortByColumn \
             -xscrollcommand [ list $dsp.hsb set ] \
             -yscrollcommand [ list $dsp.vsb set ] \
             -selectmode extended \
             -activestyle none \
             -stripebackground "#e0e8f0" \
             -showseparators 1

           scrollbar $dsp.hsb -orient horizontal -command [list $::bdi_gui_astrometry::dspt xview]
           pack $dsp.hsb -in $dsp -side bottom -fill x
           scrollbar $dsp.vsb -orient vertical -command [list $::bdi_gui_astrometry::dspt yview]
           pack $dsp.vsb -in $dsp -side left -fill y

           menu $dsp.popupTbl -title "Actions"

               menu $dsp.popupTbl.psf -tearoff 0
               $dsp.popupTbl add cascade -label "PSF" -menu $dsp.popupTbl.psf
                    $dsp.popupTbl.psf add command -label "Manuel" \
                       -command "::bdi_gui_astrometry::psf dsp $::bdi_gui_astrometry::dspt"
                    $dsp.popupTbl.psf add command -label "Auto" \
                       -command "::bdi_gui_cata_gestion::psf_auto dspt $::bdi_gui_astrometry::dspt"

               $dsp.popupTbl add command -label "Supprimer" \
                   -command "::bdi_gui_astrometry::unset_dspt $::bdi_gui_astrometry::dspt"

           bind $::bdi_gui_astrometry::dspt <<ListboxSelect>> [ list ::bdi_gui_astrometry::cmdButton1Click_dspt %W ]
           bind [$::bdi_gui_astrometry::dspt bodypath] <ButtonPress-3> [ list tk_popup $dsp.popupTbl %X %Y ]

           pack $::bdi_gui_astrometry::dspt -in $dsp -expand yes -fill both

      #--- TABLE Dates - Sources Enfant (par liste de sources chaque mesure)
      set dse [frame $onglets_dates.list.sources.enfant -borderwidth 0 -cursor arrow -relief groove -background white]
      pack $dse -in $onglets_dates.list.sources -expand yes -fill both -side left

           set ::bdi_gui_astrometry::dset $dse.table

           tablelist::tablelist $::bdi_gui_astrometry::dset \
             -columns $loc_sources_enf \
             -labelcommand tablelist::sortByColumn \
             -xscrollcommand [ list $dse.hsb set ] \
             -yscrollcommand [ list $dse.vsb set ] \
             -selectmode extended \
             -activestyle none \
             -stripebackground "#e0e8f0" \
             -showseparators 1

           scrollbar $dse.hsb -orient horizontal -command [list $::bdi_gui_astrometry::dset xview]
           pack $dse.hsb -in $dse -side bottom -fill x
           scrollbar $dse.vsb -orient vertical -command [list $::bdi_gui_astrometry::dset yview]
           pack $dse.vsb -in $dse -side right -fill y

           menu $dse.popupTbl -title "Actions"

               menu $dse.popupTbl.psf -tearoff 0
               $dse.popupTbl add cascade -label "PSF" -menu $dse.popupTbl.psf
                    $dse.popupTbl.psf add command -label "Manuel" \
                       -command "::bdi_gui_astrometry::psf dse $::bdi_gui_astrometry::dset"
                    $dse.popupTbl.psf add command -label "Auto" \
                       -command "::bdi_gui_cata_gestion::psf_auto dset $::bdi_gui_astrometry::dset"

               $dse.popupTbl add command -label "Supprimer dans cette image" \
                  -command "::bdi_gui_astrometry::unset_dset $::bdi_gui_astrometry::dset" 

           bind $::bdi_gui_astrometry::dset <<ListboxSelect>> [ list ::bdi_gui_astrometry::cmdButton1Click_dset %W ]
           bind [$::bdi_gui_astrometry::dset bodypath] <ButtonPress-3> [ list tk_popup $dse.popupTbl %X %Y ]

           pack $::bdi_gui_astrometry::dset -in $dse -expand yes -fill both

      #--- TABLE Dates - WCS Parent (par liste de dates et moyenne)
      set dwp [frame $onglets_dates.list.wcs.parent -borderwidth 1 -cursor arrow -relief groove -background white]
      pack $dwp -in $onglets_dates.list.wcs -expand yes -fill both -side left

           set ::bdi_gui_astrometry::dwpt $onglets_dates.list.wcs.parent.table

           tablelist::tablelist $::bdi_gui_astrometry::dwpt \
             -columns $loc_dates_par \
             -labelcommand tablelist::sortByColumn \
             -xscrollcommand [ list $dwp.hsb set ] \
             -yscrollcommand [ list $dwp.vsb set ] \
             -selectmode extended \
             -activestyle none \
             -stripebackground "#e0e8f0" \
             -showseparators 1

           scrollbar $dwp.hsb -orient horizontal -command [list $::bdi_gui_astrometry::dwpt xview]
           pack $dwp.hsb -in $dwp -side bottom -fill x
           scrollbar $dwp.vsb -orient vertical -command [list $::bdi_gui_astrometry::dwpt yview]
           pack $dwp.vsb -in $dwp -side left -fill y

           bind $::bdi_gui_astrometry::dwpt <<ListboxSelect>> [ list ::bdi_gui_astrometry::cmdButton1Click_dwpt %W ]

           pack $::bdi_gui_astrometry::dwpt -in $dwp -expand yes -fill both

      #--- TABLE Dates - WCS Enfant (Solution astrometrique)
      set dwe [frame $onglets_dates.list.wcs.enfant -borderwidth 1 -cursor arrow -relief groove -background ivory]
      pack $dwe -in $onglets_dates.list.wcs -expand yes -fill both -side left

         label  $dwe.titre -text "Solution astrometrique" -borderwidth 1
         pack   $dwe.titre -in $dwe -side top -padx 3 -pady 3 -anchor c

           set ::bdi_gui_astrometry::dwet $onglets_dates.list.wcs.enfant.table

           tablelist::tablelist $::bdi_gui_astrometry::dwet \
             -columns $loc_wcs_enf \
             -labelcommand tablelist::sortByColumn \
             -xscrollcommand [ list $dwe.hsb set ] \
             -yscrollcommand [ list $dwe.vsb set ] \
             -selectmode extended \
             -activestyle none \
             -stripebackground "#e0e8f0" \
             -showseparators 1

           scrollbar $dwe.hsb -orient horizontal -command [list $::bdi_gui_astrometry::dwet xview]
           pack $dwe.hsb -in $dwe -side bottom -fill x
           scrollbar $dwe.vsb -orient vertical -command [list $::bdi_gui_astrometry::dwet yview]
           pack $dwe.vsb -in $dwe -side left -fill y

           pack $::bdi_gui_astrometry::dwet -in $dwe -expand yes -fill both


      #--- Onglet RAPPORT - Entetes
      set block [frame $entetes.uai_code  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            label  $block.lab -text "IAU Code : " -borderwidth 1 -width $wdth
            pack   $block.lab -side left -padx 3 -pady 3 -anchor w

            entry  $block.val -relief sunken -width 5 -textvariable ::bdi_tools_astrometry::rapport_uai_code
            pack   $block.val -side left -padx 3 -pady 3 -anchor w

            label  $block.loc -textvariable ::bdi_tools_astrometry::rapport_uai_location -borderwidth 1 -width $wdth
            pack   $block.loc -side left -padx 3 -pady 3 -anchor w

      set block [frame $entetes.rapporteur  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            label  $block.lab -text "Rapporteur : " -borderwidth 1 -width $wdth
            pack   $block.lab -side left -padx 3 -pady 3 -anchor w

            entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_astrometry::rapport_rapporteur
            pack   $block.val -side left -padx 3 -pady 3 -anchor w

      set block [frame $entetes.adresse  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            label  $block.lab -text "Adresse : " -borderwidth 1 -width $wdth
            pack   $block.lab -side left -padx 3 -pady 3 -anchor w

            entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_astrometry::rapport_adresse
            pack   $block.val -side left -padx 3 -pady 3 -anchor w

      set block [frame $entetes.mail  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            label  $block.lab -text "Mail : " -borderwidth 1 -width $wdth
            pack   $block.lab -side left -padx 3 -pady 3 -anchor w

            entry  $block.val -relief sunken -width 80  -textvariable ::bdi_tools_astrometry::rapport_mail
            pack   $block.val -side left -padx 3 -pady 3 -anchor w

      set block [frame $entetes.observ  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            label  $block.lab -text "Observateurs : " -borderwidth 1 -width $wdth
            pack   $block.lab -side left -padx 3 -pady 3 -anchor w

            entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_astrometry::rapport_observ
            pack   $block.val -side left -padx 3 -pady 3 -anchor w

      set block [frame $entetes.reduc  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            label  $block.lab -text "Reduction : " -borderwidth 1 -width $wdth
            pack   $block.lab -side left -padx 3 -pady 3 -anchor w

            entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_astrometry::rapport_reduc
            pack   $block.val -side left -padx 3 -pady 3 -anchor w

      set block [frame $entetes.instru  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            label  $block.lab -text "Instrument : " -borderwidth 1 -width $wdth
            pack   $block.lab -side left -padx 3 -pady 3 -anchor w

            entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_astrometry::rapport_instru
            pack   $block.val -side left -padx 3 -pady 3 -anchor w

      set block [frame $entetes.cata  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            label  $block.lab -text "Catalogue Ref : " -borderwidth 1 -width $wdth
            pack   $block.lab -side left -padx 3 -pady 3 -anchor w

            entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_astrometry::rapport_cata
            pack   $block.val -side left -padx 3 -pady 3 -anchor w

      #--- Onglet RAPPORT - MPC
      #set block [frame $mpc.exped  -borderwidth 0 -cursor arrow -relief groove]
      #pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5
      #      label  $block.lab -text "Destinataire : " -borderwidth 1 -width $wdth
      #      pack   $block.lab -side left -padx 3 -pady 1 -anchor w
      #      entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_astrometry::rapport_desti
      #      pack   $block.val -side left -padx 3 -pady 1 -anchor w

      #set block [frame $mpc.subj  -borderwidth 0 -cursor arrow -relief groove]
      #pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5
      #      label  $block.lab -text "Batch : " -borderwidth 1 -width $wdth
      #      pack   $block.lab -side left -padx 3 -pady 1 -anchor w
      #      entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_astrometry::rapport_batch
      #      pack   $block.val -side left -padx 3 -pady 1 -anchor w

      set ::bdi_gui_astrometry::rapport_mpc $mpc.text
      text $::bdi_gui_astrometry::rapport_mpc -height 30 -width 80 \
           -xscrollcommand "$::bdi_gui_astrometry::rapport_mpc.xscroll set" \
           -yscrollcommand "$::bdi_gui_astrometry::rapport_mpc.yscroll set" \
           -wrap none
      pack $::bdi_gui_astrometry::rapport_mpc -expand yes -fill both -padx 5 -pady 5

      scrollbar $::bdi_gui_astrometry::rapport_mpc.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_astrometry::rapport_mpc xview"
      pack $::bdi_gui_astrometry::rapport_mpc.xscroll -side bottom -fill x

      scrollbar $::bdi_gui_astrometry::rapport_mpc.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_astrometry::rapport_mpc yview"
      pack $::bdi_gui_astrometry::rapport_mpc.yscroll -side right -fill y

      #set block [frame $mpc.save -borderwidth 0 -cursor arrow -relief groove]
      #pack $block -in $mpc -side top -expand 0 -padx 2 -pady 5
      #   button $block.sas -text "Save As" -borderwidth 2 -takefocus 1 \
      #           -command {::bdi_tools::save_as [$::bdi_gui_astrometry::rapport_mpc get 0.0 end] "TXT"}
      #   pack $block.sas -side left -anchor c -expand 0 -fill x -padx 3
      #   button $block.send -text "Send to MPC" -borderwidth 2 -takefocus 1 \
      #           -command "::bdi_tools_astrometry::send_to_mpc"
      #   pack $block.send -side left -anchor c -expand 0 -fill x -padx 3

      #--- Onglet RAPPORT - TXT et XML
      set ::bdi_gui_astrometry::rapport_txt $txt.text
      text $::bdi_gui_astrometry::rapport_txt -height 30 -width 120 \
           -xscrollcommand "$::bdi_gui_astrometry::rapport_txt.xscroll set" \
           -yscrollcommand "$::bdi_gui_astrometry::rapport_txt.yscroll set" \
           -wrap none
      pack $::bdi_gui_astrometry::rapport_txt -expand yes -fill both -padx 5 -pady 5

      scrollbar $::bdi_gui_astrometry::rapport_txt.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_astrometry::rapport_txt xview"
      pack $::bdi_gui_astrometry::rapport_txt.xscroll -side bottom -fill x

      scrollbar $::bdi_gui_astrometry::rapport_txt.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_astrometry::rapport_txt yview"
      pack $::bdi_gui_astrometry::rapport_txt.yscroll -side right -fill y

      #set block [frame $txt.save -borderwidth 0 -cursor arrow -relief groove]
      #pack $block -in $txt -side top -expand 0 -padx 2 -pady 5
      #
      #      button $block.xml -text "Save as XML" -borderwidth 2 -takefocus 1 \
      #              -command {::bdi_tools::save_as $::bdi_gui_astrometry::rapport_xml "XML"}
      #      pack $block.xml -side right -anchor c -expand 0
      #
      #      button $block.txt -text "Save as TXT" -borderwidth 2 -takefocus 1 \
      #              -command {::bdi_tools::save_as [$::bdi_gui_astrometry::rapport_txt get 0.0 end] "TXT"}
      #      pack $block.txt -side right -anchor c -expand 0

      #--- Onglet RAPPORT - MISC
      set object [frame $misc.select_obj -borderwidth 0 -cursor arrow -relief groove]
      pack $object -in $misc -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          label $object.lab -width 10 -text "Objet : "
          pack  $object.lab -in $object -side left -padx 5 -pady 0

          ComboBox $object.combo \
             -width 50 -height $nb_obj \
             -relief sunken -borderwidth 1 -editable 0 \
             -textvariable ::bdi_gui_astrometry::combo_list_object \
             -values $::bdi_gui_astrometry::object_list
          pack $object.combo -anchor center -side left -fill x -expand 0

      set block [frame $misc.save -borderwidth 0 -cursor arrow -relief groove]
      pack $block -in $misc -side top -expand 0 -padx 2 -pady 5

            button $block.date -text "Save observation dates (JD)" -borderwidth 2 -takefocus 1 \
                    -command ::bdi_gui_astrometry::save_dateobs
            pack $block.date -side top -anchor c -expand 0

            button $block.posyx -text "Save pixel positions" -borderwidth 2 -takefocus 1 \
                    -command ::bdi_gui_astrometry::save_posxy
            pack $block.posyx -side top -anchor c -expand 0

      #--- Onglet RAPPORT - SAVE
      set block [frame $save.frm  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $save -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            label  $block.lab -text "Commentaire pour le rapport final : " -borderwidth 1 
            pack   $block.lab -side top -padx 3 -pady 3 -anchor w

            entry  $block.val -relief sunken -width 80 -textvariable ::bdi_gui_astrometry::rapport_comment
            pack   $block.val -side top -padx 3 -pady 3 -anchor w

            #checkbutton $block.mpc -highlightthickness 0 -text " Le rapport MPC a ete soumis" \
            #   -font $bddconf(font,arial_10_b) -variable ::bdi_tools_astrometry::rapport_mpc_submit
            #pack $block.mpc -in $block -side top -padx 5 -pady 2 -anchor w

            button $block.saveall -text "Sauver tous les rapports" -borderwidth 2 -takefocus 1 \
                    -command ::bdi_gui_astrometry::save_all_reports
            pack $block.saveall -side top -anchor c -expand 0

      #--- Onglet GRAPHS
      set onglet_graphes [frame $graphes.selinobj -borderwidth 0 -cursor arrow -relief groove]
      pack $onglet_graphes -in $graphes -anchor s -side top -expand 0  -padx 10 -pady 5

         set selinobject [frame $onglet_graphes.obj -borderwidth 0 -cursor arrow -relief groove]
         pack $selinobject -in $onglet_graphes -anchor s -side top -expand 0  -padx 10 -pady 10

            label $selinobject.lab -width 10 -text "Objet : "
            pack  $selinobject.lab -in $selinobject -side left -padx 5 -pady 0

            ComboBox $selinobject.combo \
                -width 50 -height $nb_obj \
                -relief sunken -borderwidth 1 -editable 0 \
                -textvariable ::bdi_gui_astrometry::combo_list_object \
                -values $::bdi_gui_astrometry::object_list
            pack $selinobject.combo -anchor center -side left -fill x -expand 0

         set selingraph [frame $onglet_graphes.selingraph -borderwidth 1 -cursor arrow -relief groove]
         pack $selingraph -in $onglet_graphes -anchor c -side top -expand 0  -padx 10 -pady 5 -ipady 5

            button $selingraph.c -text "Crop" -borderwidth 2 -takefocus 1 \
                    -command "::bdi_gui_astrometry::graph_crop"
            pack $selingraph.c -side left -anchor c -expand 1 -padx 20 -pady 5

            button $selingraph.u -text "Un-Crop" -borderwidth 2 -takefocus 1 \
                    -command "::bdi_gui_astrometry::graph_uncrop"
            pack $selingraph.u -side left -anchor c -expand 1 -padx 20 -pady 5

            button $selingraph.v -text "Voir Source" -borderwidth 2 -takefocus 1 \
                    -command "::bdi_gui_astrometry::graph_voir_source"
            pack $selingraph.v -side left -anchor c -expand 1 -padx 20 -pady 5

         set frmgraph [frame $onglet_graphes.actions -borderwidth 0 -cursor arrow -relief groove]
         pack $frmgraph -in $onglet_graphes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            set frmgraphx [frame $frmgraph.x -borderwidth 0 -cursor arrow -relief groove]
            pack $frmgraphx -in $frmgraph -anchor s -side left -expand 1 -fill x -padx 10 -pady 5

               label $frmgraphx.lab -text "RA"
               pack  $frmgraphx.lab -in $frmgraphx -side top -padx 5 -pady 5

               button $frmgraphx.datejj_vs_ra -text "Date vs RA" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph datejj ra"
               pack $frmgraphx.datejj_vs_ra -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphx.datejj_vs_res_a -text "Date vs Residus" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph datejj res_a"
               pack $frmgraphx.datejj_vs_res_a -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphx.datejj_vs_ra_omc_imcce -text "Date vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph datejj ra_imcce_omc"
               pack $frmgraphx.datejj_vs_ra_omc_imcce -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphx.res_a_vs_ra_omc -text "Residus vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph res_a ra_imcce_omc"
               pack $frmgraphx.res_a_vs_ra_omc -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphx.datejj_vs_ra_omc_jpl -text "Date vs O-C(JPL)" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph datejj ra_mpc_omc"
               pack $frmgraphx.datejj_vs_ra_omc_jpl -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphx.omc_jpl_vs_omc_imcce -text "O-C(JPL) vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph ra_mpc_omc ra_imcce_omc"
               pack $frmgraphx.omc_jpl_vs_omc_imcce -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphx.datejj_vs_ra_imccejpl_cmc -text "Date vs IMCCE-JPL" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph datejj ra_imccejpl_cmc"
               pack $frmgraphx.datejj_vs_ra_imccejpl_cmc -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

            set frmgraphy [frame $frmgraph.y -borderwidth 0 -cursor arrow -relief groove]
            pack $frmgraphy -in $frmgraph -anchor s -side left -expand 1 -fill x -padx 10 -pady 5

               label $frmgraphy.lab -text "DEC"
               pack  $frmgraphy.lab -in $frmgraphy -side top -padx 5 -pady 5

               button $frmgraphy.datejj_vs_dec -text "Date vs Dec" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph datejj dec"
               pack $frmgraphy.datejj_vs_dec -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphy.datejj_vs_res_d -text "Date vs Residus" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph datejj res_d"
               pack $frmgraphy.datejj_vs_res_d -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphy.datejj_vs_dec_omc_imcce -text "Date vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph datejj dec_imcce_omc"
               pack $frmgraphy.datejj_vs_dec_omc_imcce -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphy.res_d_vs_dec_omc -text "Residus vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph res_d dec_imcce_omc"
               pack $frmgraphy.res_d_vs_dec_omc -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphy.datejj_vs_dec_omc_jpl -text "Date vs O-C(JPL)" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph datejj dec_mpc_omc"
               pack $frmgraphy.datejj_vs_dec_omc_jpl -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphy.omc_jpl_vs_omc_imcce -text "O-C(JPL) vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph dec_mpc_omc dec_imcce_omc"
               pack $frmgraphy.omc_jpl_vs_omc_imcce -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               button $frmgraphy.datejj_vs_dec_imccejpl_cmc -text "Date vs IMCCE-JPL" -borderwidth 2 -takefocus 1 \
                       -command "::bdi_gui_astrometry::graph datejj dec_imccejpl_cmc"
               pack $frmgraphy.datejj_vs_dec_imccejpl_cmc -side top -anchor c -expand 0 -fill x -padx 10 -pady 5


      #--- Onglet Analyse
      set frmnb [frame $analyse.frmnb -borderwidth 0 -cursor arrow -relief groove]
      pack $frmnb -in $analyse -anchor s -side top -expand 0  -padx 10 -pady 5

         TitleFrame $frmnb.gra -borderwidth 2 -text "Analyse des deplacements inter-etoile"
         grid $frmnb.gra -in $frmnb -sticky news

            Button $frmnb.gra.ress -text "Ressource les Scripts"  -command "::bddimages::ressource ; ::console::clear"
            Button $frmnb.gra.cat  -text "Position catalogue"     -width 30 -command "::bdi_gui_astrometry::analyse_position_catalog"
            Button $frmnb.gra.pix  -text "Position Pixel"         -width 30 -command "::bdi_gui_astrometry::analyse_position_pixel"
            Button $frmnb.gra.see  -text "Selection d une etoile" -width 30 -command "::bdi_gui_astrometry::analyse_etoile_getbox"
            entry  $frmnb.gra.sel  -textvariable ::bdi_gui_astrometry::widget(analyse,source,selected,name)  -width 35 -justify center -state disabled
            Button $frmnb.gra.cen  -text "Rotation de champ"       -width 30 -command "::bdi_gui_astrometry::analyse_centrer_etoile"
            Button $frmnb.gra.dis  -text "Distances"               -width 30 -command "::bdi_gui_astrometry::analyse_distances_etoile"

            grid $frmnb.gra.ress -in [$frmnb.gra getframe] -sticky news -columnspan 4
            grid $frmnb.gra.cat  -in [$frmnb.gra getframe] -sticky news -columnspan 4
            grid $frmnb.gra.pix  -in [$frmnb.gra getframe] -sticky news -columnspan 4
            grid $frmnb.gra.see  -in [$frmnb.gra getframe] -sticky news -columnspan 4
            grid $frmnb.gra.sel  -in [$frmnb.gra getframe] -sticky news -columnspan 4
            grid $frmnb.gra.cen  -in [$frmnb.gra getframe] -sticky news -columnspan 4
            grid $frmnb.gra.dis  -in [$frmnb.gra getframe] -sticky news -columnspan 4

         
      #--- Onglet Dev
      set frmnb [frame $dev.frmnb -borderwidth 0 -cursor arrow -relief groove]
      pack $frmnb -in $dev -anchor s -side top -expand 0  -padx 10 -pady 5

         TitleFrame $frmnb.rel -borderwidth 2 -text "Relance tout"
         grid $frmnb.rel -in $frmnb -sticky news

            Button $frmnb.rel.ress -text "Ressource les Scripts" -command "::bddimages::ressource ; ::console::clear"
            Button $frmnb.rel.rech -text "Relance la GUI   "     -command "::bdi_gui_astrometry::recharge_gui" 
            grid $frmnb.rel.ress -in [$frmnb.rel getframe] -sticky news
            grid $frmnb.rel.rech -in [$frmnb.rel getframe] -sticky news


      #--- Cree un frame pour afficher les boutons
      set info [frame $frm.info  -borderwidth 0 -cursor arrow -relief groove]
      pack $info  -in $frm -anchor s -side bottom -expand 0 -fill x -padx 10 -pady 5

           label  $info.labf -text "Fichier resultats : " -borderwidth 1
           pack   $info.labf -in $info -side left -padx 3 -pady 3 -anchor c
           label  $info.lastres -textvariable ::bdi_tools_astrometry::last_results_file -borderwidth 1
           pack   $info.lastres -in $info -side left -padx 3 -pady 3 -anchor c

           set ::bdi_gui_astrometry::gui_fermer [button $info.fermer -text "Fermer" -borderwidth 2 -takefocus 1 -command "::bdi_gui_astrometry::fermer"]
           pack $info.fermer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           button $info.enregistrer -text "Enregistrer" -borderwidth 2 -takefocus 1 -command "::bdi_gui_astrometry::save_images"
           pack $info.enregistrer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_astrometry::fen
   #--- Surcharge la couleur de fond des resultats
   $::bdi_gui_astrometry::srpt configure -background white
   $::bdi_gui_astrometry::sret configure -background white
   $::bdi_gui_astrometry::sspt configure -background white
   $::bdi_gui_astrometry::sset configure -background white
   $::bdi_gui_astrometry::sat  configure -background white
   $::bdi_gui_astrometry::dspt configure -background white
   $::bdi_gui_astrometry::dset configure -background white
   $::bdi_gui_astrometry::dwpt configure -background white
   $::bdi_gui_astrometry::dwet configure -background white
   $::bdi_gui_astrometry::rapport_txt configure -background white
   $::bdi_gui_astrometry::rapport_txt configure -font  $bddconf(font,courier_10)
   $::bdi_gui_astrometry::rapport_mpc configure -background white
   $::bdi_gui_astrometry::rapport_mpc configure -font  $bddconf(font,courier_10)

}


#----------------------------------------------------------------------------
## Visualise dans une fenetre la qualite de l astrometrie 
#  qui vient d etre faite
proc ::bdi_gui_astrometry::view_astrometry_quality {  } {

   global bddconf

   set file [file join $bddconf(dirtmp) "carte_astrometrie.csv"]
   gren_info "Lecture du fichier $file\n"
   if {[file exists $file]==1} {
      set chan [open $file r]
      while {[gets $chan line] >= 0} {
         set a [split $line ","]
      }
      close $chan
   }

   set svg_file [file join $bddconf(dirtmp) "carte_astrometrie.svg"]
   
set htm    "<?xml version='1.0' encoding='utf-8' standalone='no'?>\n"
#append htm "<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>\n"
append htm "<svg width='${width}px' height='${height}px' preserveAspectRatio='xMinYMin meet' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>\n"
append htm "<defs>\n"
append htm "<style type='text/css'>\n"
append htm "<!\[CDATA\[\n"
#--   Tous les textes ont ce style
#append htm "text{fill:yellow;text-anchor:middle;font-size:24px;font-family:Courgette}"
#--   La class css .redcircle a ce style
append htm ".astercircle{fill:none;stroke:#fc9600;stroke-width:2.0}\n"
append htm ".starcircle{fill:none;stroke:blue;stroke-width:2.0}\n"
append htm ".astername{fill:#fc9600;text-anchor:start;font-family:Courgette;font-size:14px;font-weight: bold}\n"
append htm ".starname{fill:cyan;text-anchor:start;font-family:Courgette;font-size:14px;font-weight: bold}\n"
append htm ".date{fill:yellow;text-anchor:middle;font-size:14px;font-family:Courgette}\n"
append htm "\]\]>\n"
append htm "</style>\n"
#--   modele de cercle centre sur le coin gauche en haut ; il n'apparait pas car il n'a pas de css
append htm "<circle id='circle' cx='0' cy='0' r='${radius}px' />\n"
append htm "</defs>\n"

#--   Le facteur d'echelle s'applique a toute l'image
append htm "<g transform='scale($scale)' >\n"

#--   Place le cercle
foreach aster $list_aster {
   set name [lindex $aster 0]
   set mag  [lindex $aster 1]
   #puts "ASTER MAG = $mag"
   set cx   [expr [lindex $aster 2] / $naxis1 * $width]
   set cy   [expr $height - [lindex $aster 3] / $naxis2 * $height]

   if {0==1} {
      gren_info "SVG: LOG -----------------\n"
      gren_info "SVG: naxis1 = $naxis1\n"
      gren_info "SVG: naxis2 = $naxis2\n"
      gren_info "SVG: width  = $width\n"
      gren_info "SVG: height = $height\n"
      gren_info "SVG: $name  xraw = [lindex $aster 2]\n"
      gren_info "SVG: $name  yraw = [lindex $aster 3]\n"
      gren_info "SVG: $name  xtr  = $cx\n"
      gren_info "SVG: $name  ytr  = $cy\n"
      gren_info "SVG: LOG -----------------\n"
   }
   
   set t [split $name "_"]
   if {[llength $t] == 3} { set name [lindex $t 2] }
   if {[llength $t] == 4} { set name "[lindex $t 2]_[lindex $t 3]" }
   if {[llength $t] == 5} { set name "[lindex $t 2]_[lindex $t 3]_[lindex $t 4]" }
   set texte "$name $mag"
   append htm "<use xlink:href='#circle' class='astercircle' transform='translate($cx,$cy)'/>\n"
   append htm "<text class='astername' x='[expr { $cx+13 }]' y='[expr { $cy-11 }]'>$name</text>\n"
   append htm "<text class='astername' x='[expr { $cx+13 }]' y='[expr { $cy+5 }]'>$mag</text>\n"
}
set magmax 0
set magmin 99
set cpt 0
foreach star $list_stars {
   incr cpt
   set mag [lindex $star 1]
   if {$mag>$magmax} { set magmax $mag}
   if {$mag<$magmin} { set magmin $mag}
   
   #puts "STAR MAG = $mag"
   if {$cpt<50} {
      set cx  [expr [lindex $star 2] / $naxis1 * $width]
      set cy  [expr $height - [lindex $star 3] / $naxis2 * $height]
      set texte "$mag"
      append htm "<use xlink:href='#circle' class='starcircle' transform='translate($cx,$cy)'/>\n"
      append htm "<text class='starname' x='[expr { $cx+13 }]' y='[expr { $cy+5 }]'>$texte</text>\n"
   }
}

#--   Place le milieu du texte au milieu de width grace a text-anchor:middle et le bas du texte a 10 px du bas
set startx           0
set starty           [expr $height-20]
set width_rectangle  $width
set height_rectangle 20
set color "black"
append htm "<rect x='$startx' y='$starty' width='$width_rectangle' height='$height_rectangle' style='fill:$color'/>"
append htm "<text class='date' x='[expr { $width/2 }]' y='[expr { $height-5 }]'>$date_info</text>"

#--   Fermeture des balises
append htm "</g>"    ; # balise de scale
append htm "</svg>"

gren_info "Sauvegarde du SVG\n"
set fid [open $svg_file w]
puts $fid $htm
close $fid


}
