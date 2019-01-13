## \file gui_astrometry.tcl
#  \brief     Astrometrie en mode manuel. Necessite une GUI
#  \details   This class is used to demonstrate a number of section commands.
#  \author    Frederic Vachier & Jerome Berthier
#  \version   1.0
#  \date      2013
#  \copyright GNU Public License.
#  \par Ressource
#  \code  source [file join $audace(rep_install) gui audace plugin tool bddimages gui_astrometry.tcl]
#  \endcode
#  \todo      modifier le nom du fichier source

# Mise à jour $Id: gui_astrometry.tcl 9228 2013-03-20 16:24:43Z fredvachier $

#============================================================
## Declaration du namespace \c gui_astrometry .
#  \brief     Permet d'effectuer l'astrometrie en mode manuel.
#             Necessite une GUI.
#  \pre       Chargement a partir de l'outil Recherche
#  \bug       Probleme de memoire sur les exec
#  \warning   Pour developpeur seulement
#  \todo      Sauver les infos MPC dans le header de l'image
namespace eval gui_astrometry {

   variable factor

   #----------------------------------------------------------------------------
   ## Initialisation des variables de namespace
   #  \details   Si la variable n'existe pas alors on va chercher
   #             dans la variable globale \c conf
   #  \sa        gui_cata::inittoconf
   proc ::gui_astrometry::inittoconf {  } {

      ::tools_astrometry::inittoconf

      set ::gui_astrometry::state_gestion 0
      set ::gui_astrometry::object_list {}
      set ::gui_astrometry::factor 1000

   }

   #----------------------------------------------------------------------------
   ## Fermeture de la fenetre Astrometrie.
   # Les variables utilisees sont affectees a la variable globale
   # \c conf
   proc ::gui_astrometry::fermer {  } {

      ::tools_astrometry::closetoconf

      destroy $::gui_astrometry::fen
      cleanmark

   }




   #----------------------------------------------------------------------------
   ## Fonction qui est appelee lors d'un clic gauche dans la table
   # des references (parent / table de gauche)
   #  \param w    selection tklist
   #  \param args argument non utilise
   proc ::gui_astrometry::cmdButton1Click_srpt { w args } {

      foreach select [$w curselection] {
         set name [lindex [$w get $select] 0]
         gren_info "srpt name = $name \n"

         # Construit la table enfant
         $::gui_astrometry::sret delete 0 end
         foreach date $::tools_astrometry::listref($name) {
            $::gui_astrometry::sret insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 2 $date]
         }

         # Affiche un rond sur la source
         ::gui_cata::voir_sxpt $::gui_astrometry::srpt

         set ::gui_astrometry::srpt_name $name

         break
      }

   }




   proc ::gui_astrometry::cmdButton1Click_sspt { w args } {

      foreach select [$w curselection] {
         set name [lindex [$w get $select] 0]
         gren_info "sspt name = $name \n"

         # Construit la table enfant
         $::gui_astrometry::sset delete 0 end
         foreach date $::tools_astrometry::listscience($name) {
            $::gui_astrometry::sset insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 2 $date]
         }

         # Affiche un rond sur la source
         ::gui_cata::voir_sxpt $::gui_astrometry::sspt

         set ::gui_astrometry::sspt_name $name
         break
      }

   }




   proc ::gui_astrometry::cmdButton1Click_dspt { w args } {

      foreach select [$w curselection] {
         set date [lindex [$w get $select] 0]
         gren_info "dspt date = $date \n"

         # Construit la table enfant
         $::gui_astrometry::dset delete 0 end
         foreach name $::tools_astrometry::listdate($date) {
            $::gui_astrometry::dset insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 1 $name]
         }

         break
      }

   }




   proc ::gui_astrometry::cmdButton1Click_dset { w args } {

      foreach select [$w curselection] {
         set name [lindex [$w get $select] 1]
         gren_info "dset name = $name \n"

         # Affiche un rond sur la source
         ::gui_cata::voir_dset $::gui_astrometry::dset

         break
      }

   }




   proc ::gui_astrometry::cmdButton1Click_dwpt { w args } {

      foreach select [$w curselection] {
         set date [lindex [$w get $select] 0]

         gren_info "date = $date \n"
         gren_info "Id img = $::tools_astrometry::date_to_id($date) \n"
         set id $::tools_astrometry::date_to_id($date)
         set tabkey [::bddimages_liste::lget [lindex $::tools_cata::img_list [expr $id -1] ] "tabkey"]
         set datei   [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
         gren_info "date = $datei \n"
         #gren_info "tabkey = $::tools_cata::new_astrometry($id) \n"

         ::gui_astrometry::voir_dwet %w

         $::gui_astrometry::dwet delete 0 end
         foreach val $::tools_cata::new_astrometry($id) {
            $::gui_astrometry::dwet insert end $val
         }

         break
      }

   }


   #----------------------------------------------------------------------------


# **************************************
# TODO gui_astrometry.tcl A GARDER EN COMMENTAIRE POUR L'INSTANT
# **************************************
   #proc ::gui_astrometry::rapport_get_ephem { send_listsources name middate } {
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
   #   puts $chan0 "LD_LIBRARY_PATH=/usr/local/lib:$::tools_astrometry::ifortlib"
   #   puts $chan0 "export LD_LIBRARY_PATH"
   #
   #   switch $type { "star"  { set cmd "/usr/local/bin/ephemcc etoile -a $nom -n $num -j $middate -tp 1 -te 1 -tc 5 -uai $::tools_astrometry::rapport_uai_code -d 1 -e utc --julien" }
   #                  "aster" { set cmd "/usr/local/bin/ephemcc asteroide $ephemcc_nom -j $middate -tp 1 -te 1 -tc 5 -uai $::tools_astrometry::rapport_uai_code -d 1 -e utc --julien" }
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
   #      #set ephem [vo_getmpcephem [string map {" " ""} $num] $dateiso $::tools_astrometry::rapport_uai_code]
   #      #gren_info "EPHEM MPC ephem = $ephem\n"
   #      #gren_info "CMD = vo_getmpcephem $num $dateiso $position\n"
   #      set datejj  [format "%.9f"  $middate ]
   #      if {[info exists ::gui_astrometry::jpl_ephem($datejj)]} {
   #         set ra_mpc  [lindex $::gui_astrometry::jpl_ephem($datejj) 0]
   #         set dec_mpc [lindex $::gui_astrometry::jpl_ephem($datejj) 1]
   #      } else {
   #         set ra_mpc  "-"
   #         set dec_mpc "-"
   #      }
   #      #gren_info "CMD = vo_getmpcephem $num $dateiso $::tools_astrometry::rapport_uai_code   ||EPHEM MPC ($num) ; date =  $middate ; ra dec = $ra_mpc  $dec_mpc \n"
   #
   #   }
   #
   #   gren_info "EPHEM IMCCE RA = $ra_imcce; DEC = $dec_imcce\n"
   #   #gren_info "EPHEM MPC RA = $ra_mpc; DEC = $dec_mpc\n"
   #   return [list $ra_imcce $dec_imcce $ra_mpc $dec_mpc $h_imcce $am_imcce]
   #
   #}
# **************************************




   proc ::gui_astrometry::get_data_report { name date } {

      set imcce [list "-" {"-" "-" "-" "-" "-"}]
      if {$::tools_astrometry::use_ephem_imcce && [array exists ::tools_astrometry::ephem_imcce]} {
         foreach key [array names ::tools_astrometry::ephem_imcce] {
            if {[regexp -all -- $name $key]} {
               set imcce [list "$key" $::tools_astrometry::ephem_imcce($name,$date)]
            } else {
            }
         }
      }

      set jpl [list "-" {"-" "-" "-"}]
      if {$::tools_astrometry::use_ephem_jpl && [array exists ::tools_astrometry::ephem_jpl]} {
         foreach key [array names ::tools_astrometry::ephem_jpl] {
            if {[regexp -all -- $name $key]} {
               set jpl [list "$key" $::tools_astrometry::ephem_jpl($name,$date)]
            }
         }
      }

      return [list [list IMCCE $imcce] [list JPL $jpl]]

   }


   #----------------------------------------------------------------------------


   proc ::gui_astrometry::create_report_mpc {  } {

      # Efface la zone de rapport
      $::gui_astrometry::rapport_mpc delete 0.0 end

      # Entete
      $::gui_astrometry::rapport_mpc insert end  "#COD $::tools_astrometry::rapport_uai_code \n"
      $::gui_astrometry::rapport_mpc insert end  "#CON $::tools_astrometry::rapport_rapporteur \n"
      $::gui_astrometry::rapport_mpc insert end  "#CON $::tools_astrometry::rapport_mail \n"
      $::gui_astrometry::rapport_mpc insert end  "#CON Software Reduction : Audela Bddimages Priam \n"
      $::gui_astrometry::rapport_mpc insert end  "#OBS $::tools_astrometry::rapport_observ \n"
      $::gui_astrometry::rapport_mpc insert end  "#MEA $::tools_astrometry::rapport_reduc \n"
      $::gui_astrometry::rapport_mpc insert end  "#TEL $::tools_astrometry::rapport_instru \n"
      $::gui_astrometry::rapport_mpc insert end  "#NET $::tools_astrometry::rapport_cata \n"
      $::gui_astrometry::rapport_mpc insert end  "#ACK Batch $::tools_astrometry::rapport_batch \n"
      $::gui_astrometry::rapport_mpc insert end  "#AC2 $::tools_astrometry::rapport_mail \n"
      #$::gui_astrometry::rapport_mpc insert end  "#NUM $::tools_astrometry::rapport_nb \n"


      # Constant parameters
      # - Note 1: alphabetical publishable note or (those sites that use program codes) an alphanumeric
      #           or non-alphanumeric character program code => http://www.minorplanetcenter.net/iau/info/ObsNote.html
      set note1 " "
      # - C = CCD observations (default)
      set note2 "C"

      # Format of MPC line
      set form "%13s%1s%1s%17s%12s%12s         %6s      %3s\n"
      set nb 0
      set l [array get ::tools_astrometry::listscience]
      foreach {name y} $l {
         set cata [::manage_source::name_cata $name]
         if {$cata != "SKYBOT"} {continue}

         foreach date $::tools_astrometry::listscience($name) {
            set alpha   [lindex $::tools_astrometry::tabval($name,$date) 6]
            set delta   [lindex $::tools_astrometry::tabval($name,$date) 7]
            set mag     [lindex $::tools_astrometry::tabval($name,$date) 8]

            set object  [::tools_astrometry::convert_mpc_name $name]
            set datempc [::tools_astrometry::convert_mpc_date $date]
            set ra_hms  [::tools_astrometry::convert_mpc_hms $alpha]
            set dec_dms [::tools_astrometry::convert_mpc_dms $delta]
            set magmpc  [::tools_astrometry::convert_mpc_mag $mag]
            set obsuai  $::tools_astrometry::rapport_uai_code

            set txt [format $form $object $note1 $note2 $datempc $ra_hms $dec_dms $magmpc $obsuai]
            $::gui_astrometry::rapport_mpc insert end $txt
            incr nb
         }
      }
      $::gui_astrometry::rapport_mpc insert 11.0  "#NUM $nb\n"
      $::gui_astrometry::rapport_mpc insert end  "\n\n\n"

   }




   proc ::gui_astrometry::create_report_txt {  } {

      # Reset du graphe
      if {[info exists ::gui_astrometry::graph_results]} {
         unset ::gui_astrometry::graph_results
      }

      # Efface la zone de rapport
      $::gui_astrometry::rapport_txt delete 0.0 end

      # Separateur
      set sep_txt "#[string repeat - 312]\n"

      # Entete
      $::gui_astrometry::rapport_txt insert end $sep_txt
      $::gui_astrometry::rapport_txt insert end  "# IAU code       : $::tools_astrometry::rapport_uai_code \n"
      $::gui_astrometry::rapport_txt insert end  "# Subscriber     : $::tools_astrometry::rapport_rapporteur \n"
      $::gui_astrometry::rapport_txt insert end  "# Mail           : $::tools_astrometry::rapport_mail \n"
      $::gui_astrometry::rapport_txt insert end  "# Software       : Audela Bddimages Priam \n"
      $::gui_astrometry::rapport_txt insert end  "# Observers      : $::tools_astrometry::rapport_observ \n"
      $::gui_astrometry::rapport_txt insert end  "# Reduction      : $::tools_astrometry::rapport_reduc \n"
      $::gui_astrometry::rapport_txt insert end  "# Instrument     : $::tools_astrometry::rapport_instru \n"
      $::gui_astrometry::rapport_txt insert end  "# Ref. catalogue : $::tools_astrometry::rapport_cata \n"
      $::gui_astrometry::rapport_txt insert end  "# Batch          : $::tools_astrometry::rapport_batch \n"
      $::gui_astrometry::rapport_txt insert end $sep_txt

      # Cherche la lgueur max des noms des objets SCIENCE pour le formattage
      set l [array get ::tools_astrometry::listscience]
      set nummax 0
      foreach {name y} $l {
         set num [string length $name]
         if {$num>$nummax} {set nummax $num}
      }

      # Format des lignes du rapport TXT
      set form "%1s %-${nummax}s  %-23s  %-13s  %-13s  %-6s  %-6s  %-6s  %-6s %-7s %-7s %-7s %-7s  %-16s  %-12s  %-12s  %-12s  %-12s  %-12s  %-12s  %10s %10s %10s %10s %10s %10s \n"

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

      # Pour chaque objet SCIENCE
      foreach {name y} $l {

         if {[info exists tabcalc]} { unset tabcalc }

         $::gui_astrometry::rapport_txt insert end $headtab1
         $::gui_astrometry::rapport_txt insert end $headtab2
         $::gui_astrometry::rapport_txt insert end $headtab3
         $::gui_astrometry::rapport_txt insert end $sep_txt

         set nbobs 0

         foreach dateimg $::tools_astrometry::listscience($name) {

            incr nbobs
            set idsource [lindex $::tools_astrometry::tabval($name,$dateimg)  0]
            set rho     [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  3]]
            set res_a   [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  4]]
            set res_d   [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  5]]
            set alpha   [format "%.8f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  6]]
            set delta   [format "%+.8f" [lindex $::tools_astrometry::tabval($name,$dateimg)  7]]
            set mag     [format "%.3f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  8]]
            set err_mag [format "%.3f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  9]]
            set err_x   [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg) 10]]
            set err_y   [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg) 11]]
            set fwhm_x  [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg) 12]]
            set fwhm_y  [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg) 13]]
            set ra_hms  [::tools_astrometry::convert_txt_hms [lindex $::tools_astrometry::tabval($name,$dateimg) 6]]
            set dec_dms [::tools_astrometry::convert_txt_dms [lindex $::tools_astrometry::tabval($name,$dateimg) 7]]

            # Recupere les ephemerides de l'objet courant pour la date courante
            set all_ephem [::gui_astrometry::get_data_report $name $dateimg]

            # Ephemerides de l'IMCCE
            set eph_imcce     [lindex $all_ephem 0]
            #set midatejd      [lindex $eph_imcce {1 1 0}]
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
            if {$ra_imcce_deg == "-"} {
               set ra_imcce_omc "-"
            } else {
               set ra_imcce_omc [format "%+.4f" [expr ($alpha - $ra_imcce_deg) * 3600.0]]
               set ra_imcce [::tools_astrometry::convert_txt_hms $ra_imcce_deg]
            }
            if {$dec_imcce_deg == "-"} {
               set dec_imcce_omc "-"
            } else {
               set dec_imcce_omc [format "%+.4f" [expr ($delta - $dec_imcce_deg) * 3600.0]]
               set dec_imcce [::tools_astrometry::convert_txt_dms $dec_imcce_deg]
            }

            # OMC JPL
            if {$ra_jpl_deg == "-"} {
               set ra_jpl_omc "-"
            } else {
               set ra_jpl_omc [format "%+.4f" [expr ($alpha - $ra_jpl_deg) * 3600.0]]
               set ra_jpl [::tools_astrometry::convert_txt_hms $ra_jpl_deg]
            }
            if {$dec_jpl_deg == "-"} {
               set dec_jpl_omc "-"
            } else {
               set dec_jpl_omc [format "%+.4f" [expr ($delta - $dec_jpl_deg) * 3600.0]]
               set dec_jpl [::tools_astrometry::convert_txt_dms $dec_jpl_deg]
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
            if {$ra_imcce_deg  != "-"} {set ra_imcce_deg  [format "%.8f" $ra_imcce_deg]}
            if {$dec_imcce_deg != "-"} {set dec_imcce_deg [format "%.8f" $dec_imcce_deg]}
            if {$h_imcce_deg   != "-"} {set h_imcce_deg   [format "%.8f" $h_imcce_deg]}
            if {$am_imcce_deg  != "-"} {set am_imcce_deg  [format "%.8f" $am_imcce_deg]}
            if {$ra_jpl_deg    != "-"} {set ra_jpl_deg    [format "%.8f" $ra_jpl_deg ]}
            if {$dec_jpl_deg   != "-"} {set dec_jpl_deg   [format "%.8f" $dec_jpl_deg]}

            # Ajustement affichage
            set midatejd [string range "${midatejd}000000000000" 0 15]

            # Ligne de resultats
            set txt [format $form "" $name $midateiso $ra_hms $dec_dms $res_a $res_d $mag $err_mag $ra_imcce_omc $dec_imcce_omc $ra_jpl_omc $dec_jpl_omc $midatejd $alpha $delta $ra_imcce_deg $dec_imcce_deg $ra_jpl_deg $dec_jpl_deg $err_x $err_y $fwhm_x $fwhm_y $h_imcce_deg $am_imcce_deg]
            $::gui_astrometry::rapport_txt insert end  $txt

            # Graphe
            set ::gui_astrometry::graph_results($name,$dateimg,good)             1
            set ::gui_astrometry::graph_results($name,$dateimg,idsource)         $idsource
            set ::gui_astrometry::graph_results($name,$dateimg,datejj)           $midatejd
            set ::gui_astrometry::graph_results($name,$dateimg,res_a)            $res_a
            set ::gui_astrometry::graph_results($name,$dateimg,res_d)            $res_d
            set ::gui_astrometry::graph_results($name,$dateimg,ra_imcce_omc)     $ra_imcce_omc
            set ::gui_astrometry::graph_results($name,$dateimg,dec_imcce_omc)    $dec_imcce_omc
            set ::gui_astrometry::graph_results($name,$dateimg,ra_jpl_omc)       $ra_jpl_omc
            set ::gui_astrometry::graph_results($name,$dateimg,dec_jpl_omc)      $dec_jpl_omc
            set ::gui_astrometry::graph_results($name,$dateimg,ra_imccejpl_cmc)  $ra_imccejpl_cmc
            set ::gui_astrometry::graph_results($name,$dateimg,dec_imccejpl_cmc) $dec_imccejpl_cmc

         }

         set calc(res_a,mean)   [format "%.4f" [::math::statistics::mean  $tabcalc(res_a)]]
         set calc(res_a,stdev)  [format "%.4f" [::math::statistics::stdev $tabcalc(res_a)]]
         set calc(res_d,mean)   [format "%.4f" [::math::statistics::mean  $tabcalc(res_d)]]
         set calc(res_d,stdev)  [format "%.4f" [::math::statistics::stdev $tabcalc(res_d)]]

         set calc(datejj,mean)  [::math::statistics::mean  $tabcalc(datejj)]
         set calc(datejj,stdev) [::math::statistics::stdev $tabcalc(datejj)]
         set calc(alpha,mean)   [::math::statistics::mean  $tabcalc(alpha)]
         set calc(alpha,stdev)  [::math::statistics::stdev $tabcalc(alpha)]
         set calc(delta,mean)   [::math::statistics::mean  $tabcalc(delta)]
         set calc(delta,stdev)  [::math::statistics::stdev $tabcalc(delta)]
         set pi [expr 2*asin(1.0)]

         # OMC IMCCE
         if {[info exists tabcalc(ra_imcce_omc)]} {
            set mean [::math::statistics::mean $tabcalc(ra_imcce_omc)  ]
            set mean [expr $mean * cos($calc(delta,mean) * $pi / 180.)]
            set calc(ra_imcce_omc,mean)  [format "%.4f" $mean]
            set calc(ra_imcce_omc,stdev) [format "%.4f" [::math::statistics::stdev $tabcalc(ra_imcce_omc)]]
         } else {
            set calc(ra_imcce_omc,mean)  "-"
            set calc(ra_imcce_omc,stdev) "-"
         }
         if {[info exists tabcalc(dec_imcce_omc)]} {
           set calc(dec_imcce_omc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_imcce_omc)]]
           set calc(dec_imcce_omc,stdev) [format "%.4f" [::math::statistics::stdev $tabcalc(dec_imcce_omc)]]
         } else {
            set calc(dec_imcce_omc,mean)   "-"
            set calc(dec_imcce_omc,stdev)  "-"
         }

         # OMC JPL
         if {[info exists tabcalc(ra_jpl_omc)]} {
            set mean [::math::statistics::mean  $tabcalc(ra_jpl_omc)]
            set mean [expr $mean * cos($calc(delta,mean) * $pi / 180.)]
            set calc(ra_jpl_omc,mean)  [format "%.4f" $mean]
            set calc(ra_jpl_omc,stdev) [format "%.4f" [::math::statistics::stdev $tabcalc(ra_jpl_omc)]]
         } else {
            set calc(ra_jpl_omc,mean)   "-"
            set calc(ra_jpl_omc,stdev)  "-"
         }
         if {[info exists tabcalc(dec_jpl_omc)]} {
           set calc(dec_jpl_omc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_jpl_omc)]]
           set calc(dec_jpl_omc,stdev) [format "%.4f" [::math::statistics::stdev $tabcalc(dec_jpl_omc)]]
         } else {
            set calc(dec_jpl_omc,mean)   "-"
            set calc(dec_jpl_omc,stdev)  "-"
         }

         # CMC IMCCE-JPL
         if {[info exists tabcalc(ra_imccejpl_cmc)]} {
            set calc(ra_imccejpl_cmc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(ra_imccejpl_cmc)]]
            set calc(ra_imccejpl_cmc,stdev) [format "%.4f" [::math::statistics::stdev $tabcalc(ra_imccejpl_cmc)]]
         } else {
            set calc(ra_imccejpl_cmc,mean)   "-"
            set calc(ra_imccejpl_cmc,stdev)  "-"
         }

         if {[info exists tabcalc(dec_imccejpl_cmc)]} {
           set calc(dec_imccejpl_cmc,mean)  [format "%.4f" [::math::statistics::mean  $tabcalc(dec_imccejpl_cmc)]]
           set calc(dec_imccejpl_cmc,stdev) [format "%.4f" [::math::statistics::stdev $tabcalc(dec_imccejpl_cmc)]]
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

         $::gui_astrometry::rapport_txt insert end $sep_txt
         $::gui_astrometry::rapport_txt insert end  "# BODY NAME = [lrange [split $name "_"] 2 end]\n"
         $::gui_astrometry::rapport_txt insert end  "# Number of positions: $nbobs \n"
         $::gui_astrometry::rapport_txt insert end  "# -\n"
         $::gui_astrometry::rapport_txt insert end  "# Residus     RA  (arcsec): mean = $calc(res_a,mean) stedv = $calc(res_a,stdev)\n"
         $::gui_astrometry::rapport_txt insert end  "# Residus     DEC (arcsec): mean = $calc(res_d,mean) stedv = $calc(res_d,stdev)\n"
         $::gui_astrometry::rapport_txt insert end  "# -\n"
         $::gui_astrometry::rapport_txt insert end  "# O-C(IMCCE)  RA  (arcsec): mean = $calc(ra_imcce_omc,mean) stedv = $calc(ra_imcce_omc,stdev)\n"
         $::gui_astrometry::rapport_txt insert end  "# O-C(IMCCE)  DEC (arcsec): mean = $calc(dec_imcce_omc,mean) stedv = $calc(dec_imcce_omc,stdev)\n"
         $::gui_astrometry::rapport_txt insert end  "# -\n"
         $::gui_astrometry::rapport_txt insert end  "# O-C(JPL)    RA  (arcsec): mean = $calc(ra_jpl_omc,mean) stedv = $calc(ra_jpl_omc,stdev)\n"
         $::gui_astrometry::rapport_txt insert end  "# O-C(JPL)    DEC (arcsec): mean = $calc(dec_jpl_omc,mean) stedv = $calc(dec_jpl_omc,stdev)\n"
         $::gui_astrometry::rapport_txt insert end  "# -\n"
         $::gui_astrometry::rapport_txt insert end  "# IMCCE-JPL   RA  (arcsec): mean = $calc(ra_imccejpl_cmc,mean) stedv = $calc(ra_imccejpl_cmc,stdev)\n"
         $::gui_astrometry::rapport_txt insert end  "# IMCCE-JPL   DEC (arcsec): mean = $calc(dec_imccejpl_cmc,mean) stedv = $calc(dec_imccejpl_cmc,stdev)\n"
         $::gui_astrometry::rapport_txt insert end  "# -\n"
         $::gui_astrometry::rapport_txt insert end  "# Mean epoch (jd) : $calc(datejj,mean) ( [mc_date2iso8601 $calc(datejj,mean)] )\n"
         $::gui_astrometry::rapport_txt insert end  "# Mean RA    (deg): [format "%16.12f" $calc(alpha,mean)]   (  [::tools_astrometry::convert_txt_hms $calc(alpha,mean)] )\n"
         $::gui_astrometry::rapport_txt insert end  "# Mean DEC   (deg): [format "%+15.12f" $calc(delta,mean)]   ( [::tools_astrometry::convert_txt_dms $calc(delta,mean)]  )\n"
         $::gui_astrometry::rapport_txt insert end $sep_txt

      }
      $::gui_astrometry::rapport_txt insert end "\n"

      return

   }




   proc ::gui_astrometry::create_report_xml {  } {

      # clean votable
      set ::gui_astrometry::rapport_xml ""

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
      set description "Observatory IAU code"
      set p [ list "$::votable::Field::ID \"iaucode\"" \
                   "$::votable::Field::NAME \"IAUCode\"" \
                   "$::votable::Field::UCD \"\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"3\"" \
                   "$::votable::Field::WIDTH \"3\"" ]
      lappend p "$::votable::Param::VALUE ${::tools_astrometry::rapport_uai_code}"; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Subscriber"
      set p [ list "$::votable::Field::ID \"subscriber\"" \
                   "$::votable::Field::NAME \"Subscriber\"" \
                   "$::votable::Field::UCD \"\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::tools_astrometry::rapport_rapporteur}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Mail"
      set p [ list "$::votable::Field::ID \"mail\"" \
                   "$::votable::Field::NAME \"Mail\"" \
                   "$::votable::Field::UCD \"\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::tools_astrometry::rapport_mail}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Software"
      set p [ list "$::votable::Field::ID \"software\"" \
                   "$::votable::Field::NAME \"Software\"" \
                   "$::votable::Field::UCD \"\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"Audela Bddimages\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Observers"
      set p [ list "$::votable::Field::ID \"observers\"" \
                   "$::votable::Field::NAME \"Observers\"" \
                   "$::votable::Field::UCD \"\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::tools_astrometry::rapport_observ}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Reduction"
      set p [ list "$::votable::Field::ID \"reduction\"" \
                   "$::votable::Field::NAME \"Reduction\"" \
                   "$::votable::Field::UCD \"\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::tools_astrometry::rapport_reduc}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Instrument"
      set p [ list "$::votable::Field::ID \"instrument\"" \
                   "$::votable::Field::NAME \"Instrument\"" \
                   "$::votable::Field::UCD \"\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::tools_astrometry::rapport_instru}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Reference catalogue"
      set p [ list "$::votable::Field::ID \"refcata\"" \
                   "$::votable::Field::NAME \"ReferenceCatalogue\"" \
                   "$::votable::Field::UCD \"\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::tools_astrometry::rapport_cata}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "Batch"
      set p [ list "$::votable::Field::ID \"batch\"" \
                   "$::votable::Field::NAME \"Batch\"" \
                   "$::votable::Field::UCD \"\"" \
                   "$::votable::Field::DATATYPE \"char\"" \
                   "$::votable::Field::ARRAYSIZE \"64\"" \
                   "$::votable::Field::WIDTH \"64\"" ]
      lappend p "$::votable::Param::VALUE \"${::tools_astrometry::rapport_batch}\""; # attribut value doit toijours etre present
      set param [list $p [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"

      set description "NumberOfPositions"
      set p [ list "$::votable::Field::ID \"numberpos\"" \
                   "$::votable::Field::NAME \"NumberOfPositions\"" \
                   "$::votable::Field::UCD \"\"" \
                   "$::votable::Field::DATATYPE \"int\"" \
                   "$::votable::Field::WIDTH \"6\"" ]
      lappend p "$::votable::Param::VALUE ${::tools_astrometry::rapport_nb}"; # attribut value doit toijours etre present
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
      foreach {name y} [array get ::tools_astrometry::listscience] {

         set nrows 0
         set votSources ""
         foreach dateimg $::tools_astrometry::listscience($name) {
            incr nrows
            append votSources [::votable::openElement $::votable::Element::TR {}]

            set res_a   [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  4]]
            set res_d   [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  5]]
            set alpha   [format "%.8f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  6]]
            set delta   [format "%+.8f" [lindex $::tools_astrometry::tabval($name,$dateimg)  7]]
            set mag     [format "%.3f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  8]]
            set mag_err [format "%.3f"  [lindex $::tools_astrometry::tabval($name,$dateimg)  9]]
            set err_x   [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg) 10]]
            set err_y   [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg) 11]]
            set fwhm_x  [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg) 12]]
            set fwhm_y  [format "%.4f"  [lindex $::tools_astrometry::tabval($name,$dateimg) 13]]

            # Recupere les ephemerides de l'objet courant pour la date courante
            set all_ephem [::gui_astrometry::get_data_report $name $dateimg]

            # Ephemerides de l'IMCCE
            set eph_imcce [lindex $all_ephem 0]
            set midatejd  [lindex $eph_imcce {1 1 0}]
            set ra_imcce  [lindex $eph_imcce {1 1 1}]
            set dec_imcce [lindex $eph_imcce {1 1 2}]
            set h_imcce   [lindex $eph_imcce {1 1 3}]
            set am_imcce  [lindex $eph_imcce {1 1 4}]

            # Ephemerides du JPL
            set eph_jpl   [lindex $all_ephem 1]
            set ra_jpl    [lindex $eph_jpl {1 1 1}]
            set dec_jpl   [lindex $eph_jpl {1 1 2}]

            # Epoque d milieu de pose au format ISO
            set midateiso "-"
            if {$midatejd != "-"} {
               set midateiso [mc_date2iso8601 $midatejd]
            }

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
            append votSources [::votable::addElement $::votable::Element::TD {} $name]
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

         set zname [lrange [split $name "_"] 2 end]
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

      }

      # Ferme l'element RESOURCE
      append votable [::votable::closeResourceElement] "\n"
      # Ferme la VOTable
      append votable [::votable::closeVOTable]

      set ::gui_astrometry::rapport_xml "$votable"

      return

   }


   #----------------------------------------------------------------------------


   proc ::gui_astrometry::save_dateobs { } {

      gren_info "Extraction des dates pour l'objet $::gui_astrometry::combo_list_object ...\n"

      if {[array exists ::tools_cata::date2midate]} {
         set strdate ""
         foreach {name y} [array get ::tools_astrometry::listscience] {
            if {$name != $::gui_astrometry::combo_list_object} {
               continue
            }
            foreach dateimg $::tools_astrometry::listscience($name) {
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


   proc ::gui_astrometry::save_posxy { } {

      gren_info "Extraction des dates pour l'objet $::gui_astrometry::combo_list_object ...\n"
      set strdate ""
      if {[array exists ::tools_cata::date2midate]} {
         foreach {name y} [array get ::tools_astrometry::listscience] {
            append strdate "#Object = $name\n"
            append strdate "#midepoch         x pixel  y pixel  xerr     yerr   xfwhm  yfwhm\n"
            foreach dateimg $::tools_astrometry::listscience($name) {
               set midepoch $::tools_cata::date2midate($dateimg)
               set err [ catch { set astroid [::bdi_tools::get_astroid $dateimg $name] } msg ]
               if {$err} {
                  gren_erreur "get_astroid = ($err) $msg\n"
                  continue
               }
               set x      [format "%.3f" [lindex $astroid 0]]
               set y      [format "%.3f" [lindex $astroid 1]]
               set err_x  [format "%.3f" [lindex $astroid 2]]
               set err_y  [format "%.3f" [lindex $astroid 3]]
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


   proc ::gui_astrometry::save_images { } {

      $::gui_astrometry::fen.appli.info.fermer configure -state disabled
      $::gui_astrometry::fen.appli.info.enregistrer configure -state disabled

      set ::tools_astrometry::savprogress 0
      set ::tools_astrometry::savannul 0

      set ::gui_astrometry::fensav .savprogress
      if { [winfo exists $::gui_astrometry::fensav] } {
         wm withdraw $::gui_astrometry::fensav
         wm deiconify $::gui_astrometry::fensav
         focus $::gui_astrometry::fensav
         return
      }

      toplevel $::gui_astrometry::fensav -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_astrometry::fensav ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_astrometry::fensav ] "+" ] 2 ]
      wm geometry $::gui_astrometry::fensav +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_astrometry::fensav 1 1
      wm title $::gui_astrometry::fensav "Enregistrement"
      wm protocol $::gui_astrometry::fensav WM_DELETE_WINDOW ""

      set frm $::gui_astrometry::fensav.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_astrometry::fensav -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         set data  [frame $frm.progress -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set    pf [ ttk::progressbar $data.p -variable ::tools_astrometry::savprogress -orient horizontal -length 200 -mode determinate]
             pack   $pf -in $data -side top

         set data  [frame $frm.boutons -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $data.annul -state active -text "Annuler" -relief "raised" \
                -command "::gui_astrometry::annul_save_images"
             pack   $data.annul -side top -anchor c -padx 0 -padx 10 -pady 5

      update
      ::tools_astrometry::save_images

      destroy $::gui_astrometry::fensav

      $::gui_astrometry::fen.appli.info.fermer configure -state normal
      $::gui_astrometry::fen.appli.info.enregistrer configure -state normal

   }




   proc ::gui_astrometry::annul_save_images { } {

      $::gui_astrometry::fensav.appli.boutons.annul configure -state disabled
      set ::tools_astrometry::savannul 1

   }


   #----------------------------------------------------------------------------


   proc ::gui_astrometry::psf { t w } {

      set cpt 0
      set date_id ""

      switch $t {

         "srp" {
            if {[llength [$w curselection]]!=1} {
               tk_messageBox -message "Veuillez selectionner une source" -type ok
               return
            }
            set name [lindex [$w get [$w curselection]] 0]
            foreach date $::tools_astrometry::listref($name) {
               set idsource [lindex $::tools_astrometry::tabval($name,$date) 0]
               lappend date_id [list $idsource $date]
               incr cpt
            }
         }

         "sre" {
            set name $::gui_astrometry::srpt_name
            foreach select [$w curselection] {
               set idsource [lindex [$w get $select] 0]
               set date [lindex [$w get $select] 1]
               lappend date_id [list $idsource $date]
               incr cpt
            }
         }

         "ssp" {
            if {[llength [$w curselection]]!=1} {
               tk_messageBox -message "Veuillez selectionner une source" -type ok
               return
            }
            set name [lindex [$w get [$w curselection]] 0]
            foreach date $::tools_astrometry::listscience($name) {
               set idsource [lindex $::tools_astrometry::tabval($name,$date) 0]
               lappend date_id [list $idsource $date]
               incr cpt
            }
         }

         "sse" {
            set name $::gui_astrometry::sspt_name
            foreach select [$w curselection] {
               set idsource [lindex [$w get $select] 0]
               set date [lindex [$w get $select] 1]
               lappend date_id [list $idsource $date]
               incr cpt
            }
         }

         default {
            tk_messageBox -message "::gui_astrometry::psf: action inconnue" -type ok
            return
         }
      }

      ::psf_gui::from_astrometry $name $cpt $date_id

   }




   proc ::gui_astrometry::graph { xkey ykey } {

      if {[string length $::gui_astrometry::combo_list_object] < 1} {
         tk_messageBox -message "Veuillez choisir un objet dans la liste" -type ok
         return
      }

      gren_info "Graphe : $xkey VS $ykey\n"

      set x ""
      set z ""
      set l [array get ::tools_astrometry::listscience]
      foreach {name y} $l {
         if {$name !=  $::gui_astrometry::combo_list_object} {
            continue
         }
         gren_info "Object Selected : $name\n"
         foreach dateimg $::tools_astrometry::listscience($name) {
            if { $::gui_astrometry::graph_results($name,$dateimg,good) } {
               lappend x $::gui_astrometry::graph_results($name,$dateimg,$xkey)
               lappend z $::gui_astrometry::graph_results($name,$dateimg,$ykey)
            }
         }
      }

      ::plotxy::clf 1
      ::plotxy::figure 1
      ::plotxy::hold on
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "$::gui_astrometry::combo_list_object : $xkey VS $ykey"
      ::plotxy::xlabel $xkey
      ::plotxy::ylabel $ykey

      set h [::plotxy::plot $x $z .]
      plotxy::sethandler $h [list -color black -linewidth 0]

   }




   proc ::gui_astrometry::graph_crop { } {

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

      set l [array get ::tools_astrometry::listscience]
      foreach {name w} $l {
         if {$name !=  $::gui_astrometry::combo_list_object} {
            continue
         }
         gren_info "Object Selected : $name\n"
         foreach dateimg $::tools_astrometry::listscience($name) {
            set xx $::gui_astrometry::graph_results($name,$dateimg,$xkey)
            if { $xx > $x1 && $xx < $x2} {
               set yy $::gui_astrometry::graph_results($name,$dateimg,$ykey)
               if { $yy > $y1 && $yy < $y2} {
                  continue
               }
            }
            set ::gui_astrometry::graph_results($name,$dateimg,good) 0
         }
      }

      ::gui_astrometry::graph $xkey $ykey
   }




   proc ::gui_astrometry::graph_uncrop { } {

      set xkey [::plotxy::xlabel]
      set ykey [::plotxy::ylabel]

      set l [array get ::tools_astrometry::listscience]
      foreach {name w} $l {
         if {$name !=  $::gui_astrometry::combo_list_object} {
            continue
         }
         gren_info "Object Selected : $name\n"
         foreach dateimg $::tools_astrometry::listscience($name) {
            set ::gui_astrometry::graph_results($name,$dateimg,good) 1
         }
      }

      ::gui_astrometry::graph $xkey $ykey
   }




   proc ::gui_astrometry::graph_voir_source { } {

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
      set l [array get ::tools_astrometry::listscience]
      foreach {name w} $l {
         if {$name !=  $::gui_astrometry::combo_list_object} {
            continue
         }
         gren_info "Object Selected : $name\n"
         foreach dateimg $::tools_astrometry::listscience($name) {
            set xx $::gui_astrometry::graph_results($name,$dateimg,$xkey)
            if { $xx > $x1 && $xx < $x2} {
               set yy $::gui_astrometry::graph_results($name,$dateimg,$ykey)
               if { $yy > $y1 && $yy < $y2} {
                  lappend x $xx
                  lappend y $yy
                  set idsource $::gui_astrometry::graph_results($name,$dateimg,idsource)
                  set date $dateimg

                  continue
               }
            }
         }
      }

      if { [llength $x]>1 || [llength $y]>1 } {
         ::console::affiche_erreur "Selectionner 1 seul point\n"
         return
      }

      set name $::gui_astrometry::combo_list_object
      gren_info "Voir la source\n"
      gren_info "date image = $date\n"
      gren_info "Objet = $name\n"
      #incr idsource -1
      gren_info "Idsource = $idsource\n"

# TODO afficher la psf
      ::psf_gui::from_astrometry $name 1 [list [list $idsource $date]]

   }




   proc ::gui_astrometry::set_list2combo { } {

      set nb_obj [llength $::gui_astrometry::object_list]
      $::gui_astrometry::fen.appli.onglets.list.ephem.onglets.list.jpl.input.obj.combo configure -height $nb_obj -values $::gui_astrometry::object_list
      $::gui_astrometry::fen.appli.onglets.list.graphes.selinobj.obj.combo configure -height $nb_obj -values $::gui_astrometry::object_list
      $::gui_astrometry::fen.appli.onglets.list.rapports.onglets.list.misc.select_obj.combo configure -height $nb_obj -values $::gui_astrometry::object_list

   }


   #----------------------------------------------------------------------------


   proc ::gui_astrometry::affich_catalist {  } {

      set tt0 [clock clicks -milliseconds]
      ::tools_astrometry::create_vartab
      gren_info "Creation de la structure de variable en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"

      # Charge la liste des objets SCIENCE
      set ::gui_astrometry::object_list [::tools_astrometry::get_object_list]
      ::gui_astrometry::set_list2combo

      set tt0 [clock clicks -milliseconds]
      ::tools_astrometry::calcul_statistique
      gren_info "Calculs des statistiques en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"

      set tt0 [clock clicks -milliseconds]

      $::gui_astrometry::srpt delete 0 end
      $::gui_astrometry::sret delete 0 end
      $::gui_astrometry::sspt delete 0 end
      $::gui_astrometry::sset delete 0 end
      $::gui_astrometry::dspt delete 0 end
      $::gui_astrometry::dset delete 0 end
      $::gui_astrometry::dwpt delete 0 end

      foreach name [array names ::tools_astrometry::listref] {
         $::gui_astrometry::srpt insert end $::tools_astrometry::tabref($name)
      }

      foreach name [array names ::tools_astrometry::listscience] {
         $::gui_astrometry::sspt insert end $::tools_astrometry::tabscience($name)
      }

      foreach date [array names ::tools_astrometry::listdate] {
         $::gui_astrometry::dspt insert end $::tools_astrometry::tabdate($date)
         $::gui_astrometry::dwpt insert end $::tools_astrometry::tabdate($date)
      }

      # Tri les resultats en fonction de la colonne Rho
      $::gui_astrometry::srpt sortbycolumn 2 -decreasing
      $::gui_astrometry::sspt sortbycolumn 2 -decreasing

      gren_info "Affichage des resultats en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"

   }


   #----------------------------------------------------------------------------


   proc ::gui_astrometry::create_reports {  } {

      # Verifie la presence d'un code UAI
      if {[string length [string trim $::tools_astrometry::rapport_uai_code]] == 0} {
         tk_messageBox -message "Veuillez definir le code UAI des observations (onglet Rapports->Entetes->IAU Code)" -type ok
         return
      }

      gren_info "Generation des rapports d'observations ...\n"

      # Batch
      set ::tools_astrometry::rapport_batch [clock format [clock scan now] -format "Audela BDI %Y-%m-%dT%H:%M:%S %Z"]

      # Liste des catalogue de reference
      set l [array get ::tools_astrometry::listref]
      set clist ""
      foreach {name y} $l {
         set cata [lindex [split $name "_"] 0]
         set pos [lsearch $clist $cata]
         if {$pos==-1} {
            lappend clist $cata
         }
      }
      set ::tools_astrometry::rapport_cata ""
      set separ ""
      foreach cata $clist {
         append ::tools_astrometry::rapport_cata "${separ}${cata}"
         if {$separ==""} {set separ " "}
      }

      # Generation des rapports
      gren_info " ... rapport MPC\n"
      ::gui_astrometry::create_report_mpc
      gren_info " ... rapport TXT\n"
      ::gui_astrometry::create_report_txt
      gren_info " ... rapport XML\n"
      ::gui_astrometry::create_report_xml
      gren_info "done\n"

   }




   proc ::gui_astrometry::go_ephem {  } {

      # Verifie la presence d'un code UAI
      if {[string length [string trim $::tools_astrometry::rapport_uai_code]] == 0} {
         tk_messageBox -message "Veuillez definir le code UAI des observations (onglet Rapports->Entetes->IAU Code)" -type ok
         return
      }

      gren_info "Generation des ephemerides des objets SCIENCE ...\n"

      if {$::tools_astrometry::use_ephem_imcce} {
         set err [::tools_astrometry::get_ephem_imcce]
         if {$err != 0} {
            gren_erreur "WARNING: le calcul des ephemerides IMCCE a echoue\n"
         }
      }

      if {$::tools_astrometry::use_ephem_jpl} {
         set err [::tools_astrometry::compose_ephem_jpl]
         if {$err != 0} {
            gren_erreur "WARNING: le calcul des ephemerides JPL a echoue\n"
         }
      }

      gren_info "done\n"
   }




   proc ::gui_astrometry::go_priam {  } {

      set tt0 [clock clicks -milliseconds]
      ::tools_astrometry::init_priam
      ::tools_astrometry::exec_priam
      gren_info "Determination de la solution astrometrique (Priam) en [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]] sec.\n"
      ::gui_astrometry::affich_catalist

   }


   #----------------------------------------------------------------------------


   proc ::gui_astrometry::affich_gestion {  } {

      gren_info "\n\n\n-----------\n"
      set tt0 [clock clicks -milliseconds]

      if {$::gui_astrometry::state_gestion == 0} {
         catch {destroy $::cata_gestion_gui::fen}
         gren_info "Chargement des fichiers XML\n"
         ::cata_gestion_gui::go $::tools_cata::img_list
         set ::gui_astrometry::state_gestion 1
      }

      if {[info exists ::cata_gestion_gui::state_gestion] && $::cata_gestion_gui::state_gestion == 1} {
         gren_info "Chargement depuis la fenetre de gestion des sources\n"
         ::gui_astrometry::affich_catalist
      } else {
         catch {destroy $::cata_gestion_gui::fen}
         gren_info "Chargement des fichiers XML\n"
         ::cata_gestion_gui::go $::tools_cata::img_list
      }

      # Focus sur la gui
      focus $::gui_astrometry::fen

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Chargement complet en $tt sec \n"

      return

   }




   proc ::gui_astrometry::charge_element_rapport { } {

      set current_image [lindex $::tools_cata::img_list 0]
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set datei  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]

      set ::tools_astrometry::rapport_uai_code [string trim [lindex [::bddimages_liste::lget $tabkey "IAU_CODE"] 1] ]
      set ::tools_astrometry::rapport_observ   [string trim [lindex [::bddimages_liste::lget $tabkey "OBSERVER"] 1] ]

      set ex [::bddimages_liste::lexist $tabkey "INSTRUME"]
      if {$ex != 0} {
         set ::tools_astrometry::rapport_instru [string trim [lindex [::bddimages_liste::lget $tabkey "INSTRUME"] 1] ]
      }

      # Nombre de positions rapportees
      set cpt 0
      set l [array get ::tools_astrometry::listscience]
      foreach {name y} $l {
         foreach date $::tools_astrometry::listscience($name) {
            incr cpt
         }
      }
      set ::tools_astrometry::rapport_nb $cpt

   }




   #----------------------------------------------------------------------------
   ## Chargement de l'astrometrie pour chaque image de la structure img_list
   # \note le resultat de cette procedure affecte la variable de 
   # namespace \c tools_cata::img_list puis charge toutes l'info 
   # concernant l'astrometrie
   #----------------------------------------------------------------------------
   # set astrom(kwds)     {RA       DEC       CRPIX1      CRPIX2      CRVAL1       CRVAL2       CDELT1      CDELT2      CROTA2      CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN       PIXSIZE1       PIXSIZE2        CATA_PVALUE        EQUINOX       CTYPE1        CTYPE2      LONPOLE                                        CUNIT1                       CUNIT2                       }
   # set astrom(units)    {deg      deg       pixel       pixel       deg          deg          deg/pixel   deg/pixel   deg         deg/pixel     deg/pixel     deg/pixel     deg/pixel     m            mum            mum             percent            no            no            no          deg                                            no                           no                           }
   # set astrom(types)    {double   double    double      double      double       double       double      double      double      double        double        double        double        double       double         double          double             string        string        string      double                                         string                       string                       }
   # set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included" "Pvalue of astrometric reduction" "System of equatorial coordinates" "Gnomonic projection" "Gnomonic projection" "Long. of the celest.NP in native coor.syst."  "Angles are degrees always"  "Angles are degrees always"  }
   #----------------------------------------------------------------------------
   proc ::gui_astrometry::charge_solution_astrometrique {  } {

      set id_current_image 0
      ::tools_astrometry::set_fields_astrom astrom
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
   proc ::gui_astrometry::charge_list { img_list } {

     catch {
         if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
         if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
         if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
      }

      set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

      ::gui_astrometry::charge_solution_astrometrique
      ::gui_astrometry::charge_element_rapport

   }


   #----------------------------------------------------------------------------


   proc ::gui_astrometry::setup { img_list } {

      global audace
      global bddconf

      set nb_obj 1

      ::gui_astrometry::inittoconf
      ::gui_astrometry::charge_list $img_list

      #--- Entetes Rapports
      set wdth 13

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

      set ::gui_astrometry::fen .astrometry
      if { [winfo exists $::gui_astrometry::fen] } {
         wm withdraw $::gui_astrometry::fen
         wm deiconify $::gui_astrometry::fen
         focus $::gui_astrometry::fen
         return
      }
      toplevel $::gui_astrometry::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_astrometry::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_astrometry::fen ] "+" ] 2 ]
      wm geometry $::gui_astrometry::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_astrometry::fen 1 1
      wm title $::gui_astrometry::fen "Astrometrie"
      wm protocol $::gui_astrometry::fen WM_DELETE_WINDOW "destroy $::gui_astrometry::fen"

      set frm $::gui_astrometry::fen.appli

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_astrometry::fen -anchor s -side top -expand yes -fill both  -padx 10 -pady 5

         #--- Cree un frame pour afficher bouton fermeture
         set actions [frame $frm.actions  -borderwidth 0 -cursor arrow -relief groove]
         pack $actions  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              set ::gui_astrometry::gui_affich_gestion [button $actions.affich_gestion -text "Charge" \
                  -borderwidth 2 -takefocus 1 -relief "raised" -command "::gui_astrometry::affich_gestion"]
              pack $actions.affich_gestion -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              set orient [frame $actions.orient -borderwidth 0 -cursor arrow -relief groove]
              pack $orient -in $actions -side left -expand 0 -fill x -padx 10 -pady 5

                   label  $orient.lab -text "Orientation : " -borderwidth 1
                   pack   $orient.lab -side left -padx 3 -pady 3
                   entry  $orient.val -relief sunken -textvariable ::tools_astrometry::orient -width 3
                   pack   $orient.val -side left -padx 3 -pady 3

              set ::gui_astrometry::gui_go_priam [button $actions.go_priam -text "1. Priam" \
                 -borderwidth 2 -takefocus 1 -command "::gui_astrometry::go_priam"]
              pack $actions.go_priam -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              set ::gui_astrometry::gui_get_ephem [button $actions.get_ephem -text "2. Ephemerides" \
                 -borderwidth 2 -takefocus 1 -command "::gui_astrometry::go_ephem"]
              pack $actions.get_ephem -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              set ::gui_astrometry::gui_generer_rapport [button $actions.generer_rapport -text "3. Generer Rapport" \
                 -borderwidth 2 -takefocus 1 -command "::gui_astrometry::create_reports"]
              pack $actions.generer_rapport -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


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

            set ephem [frame $onglets.list.ephem]
            pack $ephem -in $onglets.list -expand yes -fill both
            $onglets.list add $ephem -text "Ephemerides"

            set graphes [frame $onglets.list.graphes]
            pack $graphes -in $onglets.list -expand yes -fill both
            $onglets.list add $graphes -text "Graphes"

            set rapports [frame $onglets.list.rapports]
            pack $rapports -in $onglets.list -expand yes -fill both
            $onglets.list add $rapports -text "Rapports"

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
                      -font $bddconf(font,arial_10_b) -variable ::tools_astrometry::use_ephem_imcce
                  pack $onglets_ephem_imcce.use -in $onglets_ephem_imcce -side top -padx 5 -pady 2 -anchor w

                  set block [frame $onglets_ephem_imcce.prgme -borderwidth 0 -cursor arrow -relief groove]
                  pack $block -in $onglets_ephem_imcce -side top -expand 0 -fill x -padx 2 -pady 2
                     label $block.lab -text "Programme ephemcc : " -width 20 -justify left
                     pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                     entry $block.val -relief sunken -textvariable ::tools_astrometry::imcce_ephemcc
                     pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

                  set block [frame $onglets_ephem_imcce.options -borderwidth 0 -cursor arrow -relief groove]
                  pack $block -in $onglets_ephem_imcce -side top -expand 0 -fill x -padx 2 -pady 2
                     label $block.lab -text "Options pour ephemcc : " -width 20 -justify left
                     pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                     entry $block.val -relief sunken -textvariable ::tools_astrometry::ephemcc_options
                     pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

                  frame $onglets_ephem_imcce.space -borderwidth 0 -cursor arrow -height 10
                  pack $onglets_ephem_imcce.space -in $onglets_ephem_imcce -side top -expand 0 -fill x -padx 2 -pady 2

                  set block [frame $onglets_ephem_imcce.ifort -borderwidth 0 -cursor arrow -relief groove]
                  pack $block -in $onglets_ephem_imcce -side top -expand 0 -fill x -padx 2 -pady 2
                     label $block.lab -text "Path to ifort : " -width 20 -justify left
                     pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                     entry $block.val -relief sunken -textvariable ::tools_astrometry::ifortlib
                     pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

                  set block [frame $onglets_ephem_imcce.local -borderwidth 0 -cursor arrow -relief groove]
                  pack $block -in $onglets_ephem_imcce -side top -expand 0 -fill x -padx 2 -pady 2
                     label $block.lab -text "Library path : " -width 20 -justify left
                     pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                     entry $block.val -relief sunken -textvariable ::tools_astrometry::locallib
                     pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

               #--- EPHEM JPL
               set onglets_ephem_jpl [frame $jpl.input -borderwidth 0 -cursor arrow -relief groove]
               pack $onglets_ephem_jpl -in $jpl -side top -expand yes -fill both -padx 5 -pady 5 -anchor n

                  checkbutton $onglets_ephem_jpl.use -highlightthickness 0 -text " Calculer les ephemerides JPL" \
                      -font $bddconf(font,arial_10_b) -variable ::tools_astrometry::use_ephem_jpl
                  pack $onglets_ephem_jpl.use -in $onglets_ephem_jpl -side top -padx 5 -pady 2 -anchor w

                  set block [frame $onglets_ephem_jpl.obj -borderwidth 0 -cursor arrow -relief groove]
                  pack $block -in $onglets_ephem_jpl -side top -expand 0 -fill x -padx 2 -pady 2
                     label $block.lab -text "Objet Science : " -width 12
                     pack $block.lab -in $block -side left -padx 5 -pady 2 -fill x
                     ComboBox $block.combo \
                        -width 50 -height $nb_obj \
                        -relief sunken -borderwidth 1 -editable 0 \
                        -textvariable ::gui_astrometry::combo_list_object \
                        -values $::gui_astrometry::object_list
                     pack $block.combo -side left -fill x -expand 0

                  set block [frame $onglets_ephem_jpl.exped  -borderwidth 0 -cursor arrow -relief groove]
                  pack $block -in $onglets_ephem_jpl -side top -expand 0 -fill x -padx 2 -pady 3
                     label $block.lab -text "Destinataire : " -width 12
                     pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                     entry $block.val -relief sunken -textvariable ::bdi_jpl::destinataire
                     pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

                  set block [frame $onglets_ephem_jpl.subj  -borderwidth 0 -cursor arrow -relief groove]
                  pack $block -in $onglets_ephem_jpl -side top -expand 0 -fill x -padx 2 -pady 3
                        label $block.lab -text "Sujet : " -width 12
                        pack $block.lab -side left -padx 3 -pady 1 -anchor w -fill x
                        entry $block.val -relief sunken -textvariable ::bdi_jpl::sujet
                        pack $block.val -side left -padx 3 -pady 1 -anchor w -fill x -expand 1

                  #set ::gui_astrometry::getjpl_send $onglets_ephem_jpl.sendtext
                  #   text $::gui_astrometry::getjpl_send -height 30  \
                  #        -xscrollcommand "$::gui_astrometry::getjpl_send.xscroll set" \
                  #        -yscrollcommand "$::gui_astrometry::getjpl_send.yscroll set" \
                  #        -wrap none
                  #   pack $::gui_astrometry::getjpl_send -expand yes -fill both -padx 5 -pady 5
                  #
                  #   scrollbar $::gui_astrometry::getjpl_send.xscroll -orient horizontal -cursor arrow -command "$::gui_astrometry::getjpl_send xview"
                  #   pack $::gui_astrometry::getjpl_send.xscroll -side bottom -fill x
                  #
                  #   scrollbar $::gui_astrometry::getjpl_send.yscroll -orient vertical -cursor arrow -command "$::gui_astrometry::getjpl_send yview"
                  #   pack $::gui_astrometry::getjpl_send.yscroll -side right -fill y

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

                        set ::gui_astrometry::getjpl_recev $recv.recevtext
                        text $::gui_astrometry::getjpl_recev -height 30 \
                             -xscrollcommand "$::gui_astrometry::getjpl_recev.xscroll set" \
                             -yscrollcommand "$::gui_astrometry::getjpl_recev.yscroll set" \
                             -wrap none
                        pack $::gui_astrometry::getjpl_recev -side left -expand yes -fill both -padx 3

                        set but [frame $recv.but -borderwidth 0]
                        pack $but -in $recv -side left -expand 0 -fill y
                           button $but.butread -text "Read" -borderwidth 2 -takefocus 1 -command "::tools_astrometry::read_ephem_jpl"
                           pack $but.butread -side top -anchor n -expand 0 -fill x
                           button $but.butclean -text "Clean" -borderwidth 2 -takefocus 1 -command "$::gui_astrometry::getjpl_recev delete 0.0 end"
                           pack $but.butclean -side top -anchor n -expand 0 -fill x

                     scrollbar $::gui_astrometry::getjpl_recev.xscroll -orient horizontal -cursor arrow -command "$::gui_astrometry::getjpl_recev xview"
                     pack $::gui_astrometry::getjpl_recev.xscroll -side bottom -fill x

                     scrollbar $::gui_astrometry::getjpl_recev.yscroll -orient vertical -cursor arrow -command "$::gui_astrometry::getjpl_recev yview"
                     pack $::gui_astrometry::getjpl_recev.yscroll -side right -fill y

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

         #--- TABLE Sources - References Parent (par liste de source et moyenne)
         set srp [frame $onglets_sources.list.references.parent -borderwidth 1 -cursor arrow -relief groove -background white]
         pack $srp -in $onglets_sources.list.references -expand yes -fill both -side left

              set ::gui_astrometry::srpt $srp.table

              tablelist::tablelist $::gui_astrometry::srpt \
                -columns $loc_sources_par \
                -labelcommand tablelist::sortByColumn \
                -xscrollcommand [ list $srp.hsb set ] \
                -yscrollcommand [ list $srp.vsb set ] \
                -selectmode extended \
                -activestyle none \
                -stripebackground "#e0e8f0" \
                -showseparators 1

              scrollbar $srp.hsb -orient horizontal -command [list $::gui_astrometry::srpt xview]
              pack $srp.hsb -in $srp -side bottom -fill x
              scrollbar $srp.vsb -orient vertical -command [list $::gui_astrometry::srpt yview]
              pack $srp.vsb -in $srp -side left -fill y

              menu $srp.popupTbl -title "Actions"
                  $srp.popupTbl add command -label "Mesurer le photocentre" \
                     -command "::gui_astrometry::psf srp $::gui_astrometry::srpt"
                  $srp.popupTbl add command -label "Voir l'objet dans une image" \
                      -command {::gui_cata::voirobj_srpt}
                  $srp.popupTbl add command -label "Supprimer de toutes les images" \
                      -command {::gui_cata::unset_srpt; ::gui_astrometry::affich_gestion}

              #--- bindings
              bind $::gui_astrometry::srpt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_srpt %W ]
              bind [$::gui_astrometry::srpt bodypath] <ButtonPress-3> [ list tk_popup $srp.popupTbl %X %Y ]

              pack $::gui_astrometry::srpt -in $srp -expand yes -fill both

         #--- TABLE Sources - References Enfant (par liste de date chaque mesure)
         set sre [frame $onglets_sources.list.references.enfant -borderwidth 0 -cursor arrow -relief groove -background white]
         pack $sre -in $onglets_sources.list.references -expand yes -fill both -side left

              set ::gui_astrometry::sret $sre.table

              tablelist::tablelist $::gui_astrometry::sret \
                -columns $loc_dates_enf \
                -labelcommand tablelist::sortByColumn \
                -xscrollcommand [ list $sre.hsb set ] \
                -yscrollcommand [ list $sre.vsb set ] \
                -selectmode extended \
                -activestyle none \
                -stripebackground "#e0e8f0" \
                -showseparators 1

              scrollbar $sre.hsb -orient horizontal -command [list $::gui_astrometry::sret xview]
              pack $sre.hsb -in $sre -side bottom -fill x
              scrollbar $sre.vsb -orient vertical -command [list $::gui_astrometry::sret yview]
              pack $sre.vsb -in $sre -side right -fill y

              menu $sre.popupTbl -title "Actions"
                  $sre.popupTbl add command -label "Mesurer le photocentre" \
                     -command "::gui_astrometry::psf sre $::gui_astrometry::sret"
                  $sre.popupTbl add command -label "Voir l'objet dans cette image" \
                      -command "::gui_cata::voirobj_sret"
                  $sre.popupTbl add command -label "Supprimer de cette image uniquement" \
                     -command {::gui_cata::unset_sret; ::gui_astrometry::affich_gestion}

              bind [$::gui_astrometry::sret bodypath] <ButtonPress-3> [ list tk_popup $sre.popupTbl %X %Y ]

              pack $::gui_astrometry::sret -in $sre -expand yes -fill both

         #--- TABLE Sources - Science Parent (par liste de source et moyenne)
         set ssp [frame $onglets_sources.list.sciences.parent -borderwidth 1 -cursor arrow -relief groove -background white]
         pack $ssp -in $onglets_sources.list.sciences -expand yes -fill both -side left

              set ::gui_astrometry::sspt $onglets_sources.list.sciences.parent.table

              tablelist::tablelist $::gui_astrometry::sspt \
                -columns $loc_sources_par \
                -labelcommand tablelist::sortByColumn \
                -xscrollcommand [ list $ssp.hsb set ] \
                -yscrollcommand [ list $ssp.vsb set ] \
                -selectmode extended \
                -activestyle none \
                -stripebackground "#e0e8f0" \
                -showseparators 1

              scrollbar $ssp.hsb -orient horizontal -command [list $::gui_astrometry::sspt xview]
              pack $ssp.hsb -in $ssp -side bottom -fill x
              scrollbar $ssp.vsb -orient vertical -command [list $::gui_astrometry::sspt yview]
              pack $ssp.vsb -in $ssp -side left -fill y

              menu $ssp.popupTbl -title "Actions"
                  $ssp.popupTbl add command -label "Mesurer le photocentre" \
                     -command "::gui_astrometry::psf ssp $::gui_astrometry::sspt"
                  $ssp.popupTbl add command -label "Voir l'objet dans une image" \
                      -command "::gui_cata::voirobj_sspt"
                  $ssp.popupTbl add command -label "Supprimer de toutes les images" \
                      -command {::gui_cata::unset_sspt; ::gui_astrometry::affich_gestion}

              bind $::gui_astrometry::sspt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_sspt %W ]
              bind [$::gui_astrometry::sspt bodypath] <ButtonPress-3> [ list tk_popup $ssp.popupTbl %X %Y ]

              pack $::gui_astrometry::sspt -in $ssp -expand yes -fill both

         #--- TABLE Sources - Science Enfant (par liste de date chaque mesure)
         set sse [frame $onglets_sources.list.sciences.enfant -borderwidth 1 -cursor arrow -relief groove -background white]
         pack $sse -in $onglets_sources.list.sciences -expand yes -fill both -side left

              set ::gui_astrometry::sset $onglets_sources.list.sciences.enfant.table

              tablelist::tablelist $::gui_astrometry::sset \
                -columns $loc_dates_enf \
                -labelcommand tablelist::sortByColumn \
                -xscrollcommand [ list $sse.hsb set ] \
                -yscrollcommand [ list $sse.vsb set ] \
                -selectmode extended \
                -activestyle none \
                -stripebackground "#e0e8f0" \
                -showseparators 1

              scrollbar $sse.hsb -orient horizontal -command [list $::gui_astrometry::sset xview]
              pack $sse.hsb -in $sse -side bottom -fill x
              scrollbar $sse.vsb -orient vertical -command [list $::gui_astrometry::sset yview]
              pack $sse.vsb -in $sse -side right -fill y

              menu $sse.popupTbl -title "Actions"
                  $sse.popupTbl add command -label "Mesurer le photocentre" \
                     -command "::gui_astrometry::psf sse $::gui_astrometry::sset"
                  $sse.popupTbl add command -label "Voir l'objet dans cette image" \
                      -command "::gui_cata::voirobj_sset"
                  $sse.popupTbl add command -label "Supprimer de cette image uniquement" \
                     -command {::gui_cata::unset_sset; ::gui_astrometry::affich_gestion}

              bind [$::gui_astrometry::sset bodypath] <ButtonPress-3> [ list tk_popup $sse.popupTbl %X %Y ]

              pack $::gui_astrometry::sset -in $sse -expand yes -fill both

         #--- TABLE Dates - Sources Parent (par liste de dates et moyenne)
         set dsp [frame $onglets_dates.list.sources.parent -borderwidth 1 -cursor arrow -relief groove -background white]
         pack $dsp -in $onglets_dates.list.sources -expand yes -fill both -side left

              set ::gui_astrometry::dspt $onglets_dates.list.sources.parent.table

              tablelist::tablelist $::gui_astrometry::dspt \
                -columns $loc_dates_par \
                -labelcommand tablelist::sortByColumn \
                -xscrollcommand [ list $dsp.hsb set ] \
                -yscrollcommand [ list $dsp.vsb set ] \
                -selectmode extended \
                -activestyle none \
                -stripebackground "#e0e8f0" \
                -showseparators 1

              scrollbar $dsp.hsb -orient horizontal -command [list $::gui_astrometry::dspt xview]
              pack $dsp.hsb -in $dsp -side bottom -fill x
              scrollbar $dsp.vsb -orient vertical -command [list $::gui_astrometry::dspt yview]
              pack $dsp.vsb -in $dsp -side left -fill y

              menu $dsp.popupTbl -title "Actions"
                  $dsp.popupTbl add command -label "Voir cette image" -command "::gui_cata::voirimg_dspt"
                  $dsp.popupTbl add command -label "Supprimer cette image" -command "" -state disable

              bind $::gui_astrometry::dspt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_dspt %W ]
              bind [$::gui_astrometry::dspt bodypath] <ButtonPress-3> [ list tk_popup $dsp.popupTbl %X %Y ]

              pack $::gui_astrometry::dspt -in $dsp -expand yes -fill both

         #--- TABLE Dates - Sources Enfant (par liste de sources chaque mesure)
         set dse [frame $onglets_dates.list.sources.enfant -borderwidth 0 -cursor arrow -relief groove -background white]
         pack $dse -in $onglets_dates.list.sources -expand yes -fill both -side left

              set ::gui_astrometry::dset $dse.table

              tablelist::tablelist $::gui_astrometry::dset \
                -columns $loc_sources_enf \
                -labelcommand tablelist::sortByColumn \
                -xscrollcommand [ list $dse.hsb set ] \
                -yscrollcommand [ list $dse.vsb set ] \
                -selectmode extended \
                -activestyle none \
                -stripebackground "#e0e8f0" \
                -showseparators 1

              scrollbar $dse.hsb -orient horizontal -command [list $::gui_astrometry::dset xview]
              pack $dse.hsb -in $dse -side bottom -fill x
              scrollbar $dse.vsb -orient vertical -command [list $::gui_astrometry::dset yview]
              pack $dse.vsb -in $dse -side right -fill y

              menu $dse.popupTbl -title "Actions"

                  $dse.popupTbl add command -label "Supprimer de cette image uniquement" -command "" -state disable

              bind $::gui_astrometry::dset <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_dset %W ]
              bind [$::gui_astrometry::dset bodypath] <ButtonPress-3> [ list tk_popup $dse.popupTbl %X %Y ]

              pack $::gui_astrometry::dset -in $dse -expand yes -fill both

         #--- TABLE Dates - WCS Parent (par liste de dates et moyenne)
         set dwp [frame $onglets_dates.list.wcs.parent -borderwidth 1 -cursor arrow -relief groove -background white]
         pack $dwp -in $onglets_dates.list.wcs -expand yes -fill both -side left

              set ::gui_astrometry::dwpt $onglets_dates.list.wcs.parent.table

              tablelist::tablelist $::gui_astrometry::dwpt \
                -columns $loc_dates_par \
                -labelcommand tablelist::sortByColumn \
                -xscrollcommand [ list $dwp.hsb set ] \
                -yscrollcommand [ list $dwp.vsb set ] \
                -selectmode extended \
                -activestyle none \
                -stripebackground "#e0e8f0" \
                -showseparators 1

              scrollbar $dwp.hsb -orient horizontal -command [list $::gui_astrometry::dwpt xview]
              pack $dwp.hsb -in $dwp -side bottom -fill x
              scrollbar $dwp.vsb -orient vertical -command [list $::gui_astrometry::dwpt yview]
              pack $dwp.vsb -in $dwp -side left -fill y

              bind $::gui_astrometry::dwpt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_dwpt %W ]

              pack $::gui_astrometry::dwpt -in $dwp -expand yes -fill both

         #--- TABLE Dates - WCS Enfant (Solution astrometrique)
         set dwe [frame $onglets_dates.list.wcs.enfant -borderwidth 1 -cursor arrow -relief groove -background ivory]
         pack $dwe -in $onglets_dates.list.wcs -expand yes -fill both -side left

            label  $dwe.titre -text "Solution astrometrique" -borderwidth 1
            pack   $dwe.titre -in $dwe -side top -padx 3 -pady 3 -anchor c

              set ::gui_astrometry::dwet $onglets_dates.list.wcs.enfant.table

              tablelist::tablelist $::gui_astrometry::dwet \
                -columns $loc_wcs_enf \
                -labelcommand tablelist::sortByColumn \
                -xscrollcommand [ list $dwe.hsb set ] \
                -yscrollcommand [ list $dwe.vsb set ] \
                -selectmode extended \
                -activestyle none \
                -stripebackground "#e0e8f0" \
                -showseparators 1

              scrollbar $dwe.hsb -orient horizontal -command [list $::gui_astrometry::dwet xview]
              pack $dwe.hsb -in $dwe -side bottom -fill x
              scrollbar $dwe.vsb -orient vertical -command [list $::gui_astrometry::dwet yview]
              pack $dwe.vsb -in $dwe -side left -fill y

              pack $::gui_astrometry::dwet -in $dwe -expand yes -fill both

         #--- Onglet RAPPORT - Entetes
         set block [frame $entetes.uai_code  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "IAU Code : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 5 -textvariable ::tools_astrometry::rapport_uai_code
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

               label  $block.loc -textvariable ::tools_astrometry::rapport_uai_location -borderwidth 1 -width $wdth
               pack   $block.loc -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.rapporteur  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Rapporteur : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_rapporteur
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.mail  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Mail : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80  -textvariable ::tools_astrometry::rapport_mail
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.observ  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Observateurs : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_observ
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.reduc  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Reduction : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_reduc
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.instru  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Instrument : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_instru
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         set block [frame $entetes.cata  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $entetes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               label  $block.lab -text "Catalogue Ref : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 3 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_cata
               pack   $block.val -side left -padx 3 -pady 3 -anchor w

         #--- Onglet RAPPORT - MPC
         set block [frame $mpc.exped  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5

               label  $block.lab -text "Destinataire : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 1 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_desti
               pack   $block.val -side left -padx 3 -pady 1 -anchor w

         set block [frame $mpc.subj  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5

               label  $block.lab -text "Sujet : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 1 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::tools_astrometry::rapport_batch
               pack   $block.val -side left -padx 3 -pady 1 -anchor w

         set ::gui_astrometry::rapport_mpc $mpc.text
         text $::gui_astrometry::rapport_mpc -height 30 -width 80 \
              -xscrollcommand "$::gui_astrometry::rapport_mpc.xscroll set" \
              -yscrollcommand "$::gui_astrometry::rapport_mpc.yscroll set" \
              -wrap none
         pack $::gui_astrometry::rapport_mpc -expand yes -fill both -padx 5 -pady 5

         scrollbar $::gui_astrometry::rapport_mpc.xscroll -orient horizontal -cursor arrow -command "$::gui_astrometry::rapport_mpc xview"
         pack $::gui_astrometry::rapport_mpc.xscroll -side bottom -fill x

         scrollbar $::gui_astrometry::rapport_mpc.yscroll -orient vertical -cursor arrow -command "$::gui_astrometry::rapport_mpc yview"
         pack $::gui_astrometry::rapport_mpc.yscroll -side right -fill y

         set block [frame $mpc.save -borderwidth 0 -cursor arrow -relief groove]
         pack $block -in $mpc -side top -expand 0 -padx 2 -pady 5
            button $block.sas -text "Save As" -borderwidth 2 -takefocus 1 \
                    -command {::bdi_tools::save_as [$::gui_astrometry::rapport_mpc get 0.0 end] "TXT"}
            pack $block.sas -side left -anchor c -expand 0 -fill x -padx 3
            button $block.send -text "Send to MPC" -borderwidth 2 -takefocus 1 \
                    -command "::tools_astrometry::send_to_mpc"
            pack $block.send -side left -anchor c -expand 0 -fill x -padx 3

         #--- Onglet RAPPORT - TXT et XML
         set ::gui_astrometry::rapport_txt $txt.text
         text $::gui_astrometry::rapport_txt -height 30 -width 120 \
              -xscrollcommand "$::gui_astrometry::rapport_txt.xscroll set" \
              -yscrollcommand "$::gui_astrometry::rapport_txt.yscroll set" \
              -wrap none
         pack $::gui_astrometry::rapport_txt -expand yes -fill both -padx 5 -pady 5

         scrollbar $::gui_astrometry::rapport_txt.xscroll -orient horizontal -cursor arrow -command "$::gui_astrometry::rapport_txt xview"
         pack $::gui_astrometry::rapport_txt.xscroll -side bottom -fill x

         scrollbar $::gui_astrometry::rapport_txt.yscroll -orient vertical -cursor arrow -command "$::gui_astrometry::rapport_txt yview"
         pack $::gui_astrometry::rapport_txt.yscroll -side right -fill y

         set block [frame $txt.save -borderwidth 0 -cursor arrow -relief groove]
         pack $block -in $txt -side top -expand 0 -padx 2 -pady 5

               button $block.xml -text "Save as XML" -borderwidth 2 -takefocus 1 \
                       -command {::bdi_tools::save_as $::gui_astrometry::rapport_xml "XML"}
               pack $block.xml -side right -anchor c -expand 0

               button $block.txt -text "Save as TXT" -borderwidth 2 -takefocus 1 \
                       -command {::bdi_tools::save_as [$::gui_astrometry::rapport_txt get 0.0 end] "TXT"}
               pack $block.txt -side right -anchor c -expand 0

         #--- Onglet RAPPORT - MISC
         set object [frame $misc.select_obj -borderwidth 0 -cursor arrow -relief groove]
         pack $object -in $misc -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $object.lab -width 10 -text "Objet : "
             pack  $object.lab -in $object -side left -padx 5 -pady 0

             ComboBox $object.combo \
                -width 50 -height $nb_obj \
                -relief sunken -borderwidth 1 -editable 0 \
                -textvariable ::gui_astrometry::combo_list_object \
                -values $::gui_astrometry::object_list
             pack $object.combo -anchor center -side left -fill x -expand 0

         set block [frame $misc.save -borderwidth 0 -cursor arrow -relief groove]
         pack $block -in $misc -side top -expand 0 -padx 2 -pady 5

               button $block.date -text "Save observation dates (JD)" -borderwidth 2 -takefocus 1 \
                       -command ::gui_astrometry::save_dateobs
               pack $block.date -side top -anchor c -expand 0

               button $block.posyx -text "Save pixel positions" -borderwidth 2 -takefocus 1 \
                       -command ::gui_astrometry::save_posxy
               pack $block.posyx -side top -anchor c -expand 0

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
                   -textvariable ::gui_astrometry::combo_list_object \
                   -values $::gui_astrometry::object_list
               pack $selinobject.combo -anchor center -side left -fill x -expand 0

            set selingraph [frame $onglet_graphes.selingraph -borderwidth 1 -cursor arrow -relief groove]
            pack $selingraph -in $onglet_graphes -anchor c -side top -expand 0  -padx 10 -pady 5 -ipady 5

               button $selingraph.c -text "Crop" -borderwidth 2 -takefocus 1 \
                       -command "::gui_astrometry::graph_crop"
               pack $selingraph.c -side left -anchor c -expand 1 -padx 20 -pady 5

               button $selingraph.u -text "Un-Crop" -borderwidth 2 -takefocus 1 \
                       -command "::gui_astrometry::graph_uncrop"
               pack $selingraph.u -side left -anchor c -expand 1 -padx 20 -pady 5

               button $selingraph.v -text "Voir Source" -borderwidth 2 -takefocus 1 \
                       -command "::gui_astrometry::graph_voir_source"
               pack $selingraph.v -side left -anchor c -expand 1 -padx 20 -pady 5

            set frmgraph [frame $onglet_graphes.actions -borderwidth 0 -cursor arrow -relief groove]
            pack $frmgraph -in $onglet_graphes -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

               set frmgraphx [frame $frmgraph.x -borderwidth 0 -cursor arrow -relief groove]
               pack $frmgraphx -in $frmgraph -anchor s -side left -expand 1 -fill x -padx 10 -pady 5

                  label $frmgraphx.lab -text "RA"
                  pack  $frmgraphx.lab -in $frmgraphx -side top -padx 5 -pady 5

                  button $frmgraphx.datejj_vs_res_a -text "Date vs Residus" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph datejj res_a"
                  pack $frmgraphx.datejj_vs_res_a -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

                  button $frmgraphx.datejj_vs_ra_omc_imcce -text "Date vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph datejj ra_imcce_omc"
                  pack $frmgraphx.datejj_vs_ra_omc_imcce -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

                  button $frmgraphx.res_a_vs_ra_omc -text "Residus vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph res_a ra_imcce_omc"
                  pack $frmgraphx.res_a_vs_ra_omc -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

                  button $frmgraphx.datejj_vs_ra_omc_jpl -text "Date vs O-C(JPL)" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph datejj ra_mpc_omc"
                  pack $frmgraphx.datejj_vs_ra_omc_jpl -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

                  button $frmgraphx.omc_jpl_vs_omc_imcce -text "O-C(JPL) vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph ra_mpc_omc ra_imcce_omc"
                  pack $frmgraphx.omc_jpl_vs_omc_imcce -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

                  button $frmgraphx.datejj_vs_ra_imccejpl_cmc -text "Date vs IMCCE-JPL" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph datejj ra_imccejpl_cmc"
                  pack $frmgraphx.datejj_vs_ra_imccejpl_cmc -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

               set frmgraphy [frame $frmgraph.y -borderwidth 0 -cursor arrow -relief groove]
               pack $frmgraphy -in $frmgraph -anchor s -side left -expand 1 -fill x -padx 10 -pady 5

                  label $frmgraphy.lab -text "DEC"
                  pack  $frmgraphy.lab -in $frmgraphy -side top -padx 5 -pady 5

                  button $frmgraphy.datejj_vs_res_d -text "Date vs Residus" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph datejj res_d"
                  pack $frmgraphy.datejj_vs_res_d -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

                  button $frmgraphy.datejj_vs_dec_omc_imcce -text "Date vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph datejj dec_imcce_omc"
                  pack $frmgraphy.datejj_vs_dec_omc_imcce -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

                  button $frmgraphy.res_d_vs_dec_omc -text "Residus vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph res_d dec_imcce_omc"
                  pack $frmgraphy.res_d_vs_dec_omc -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

                  button $frmgraphy.datejj_vs_dec_omc_jpl -text "Date vs O-C(JPL)" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph datejj dec_mpc_omc"
                  pack $frmgraphy.datejj_vs_dec_omc_jpl -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

                  button $frmgraphy.omc_jpl_vs_omc_imcce -text "O-C(JPL) vs O-C(IMCCE)" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph dec_mpc_omc dec_imcce_omc"
                  pack $frmgraphy.omc_jpl_vs_omc_imcce -side top -anchor c -expand 0 -fill x -padx 10 -pady 5

                  button $frmgraphy.datejj_vs_dec_imccejpl_cmc -text "Date vs IMCCE-JPL" -borderwidth 2 -takefocus 1 \
                          -command "::gui_astrometry::graph datejj dec_imccejpl_cmc"
                  pack $frmgraphy.datejj_vs_dec_imccejpl_cmc -side top -anchor c -expand 0 -fill x -padx 10 -pady 5


         #--- Cree un frame pour afficher les boutons
         set info [frame $frm.info  -borderwidth 0 -cursor arrow -relief groove]
         pack $info  -in $frm -anchor s -side bottom -expand 0 -fill x -padx 10 -pady 5

              label  $info.labf -text "Fichier resultats : " -borderwidth 1
              pack   $info.labf -in $info -side left -padx 3 -pady 3 -anchor c
              label  $info.lastres -textvariable ::tools_astrometry::last_results_file -borderwidth 1
              pack   $info.lastres -in $info -side left -padx 3 -pady 3 -anchor c

              set ::gui_astrometry::gui_fermer [button $info.fermer -text "Fermer" -borderwidth 2 -takefocus 1 -command "::gui_astrometry::fermer"]
              pack $info.fermer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              button $info.enregistrer -text "Enregistrer" -borderwidth 2 -takefocus 1 -command "::gui_astrometry::save_images"
              pack $info.enregistrer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


      # Au lancement, charge les donnees
      ::gui_astrometry::affich_gestion



   }


proc toto { } {


}

}
