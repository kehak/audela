#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_analysis_tools.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_analysis_tools.tcl
# Description    : Outils sans GUI pour l'analyse de la courbe de lumiere
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: atos_analysis_tools.tcl 14093 2016-10-20 22:02:37Z fredvachier $
#

namespace eval ::atos_analysis_tools {

   package require math::statistics
   package require math::special
   package require math::linearalgebra

   variable cols
   variable cdl
   variable nb
   variable diravi
   variable dirwork
   variable filecsv



   proc ::atos_analysis_tools::charge_csv { file } {


      if  {![file exists $file]} {return}

      set cpt 0

      set chan [open $file r]

      while {[gets $chan line] >= 0} {

         set line [string trim $line]
         set c [string index $line 0]
         if {$c=="#"} {continue}

         # description des colonnes
         if {$cpt==0} {
            set cols [split $line ","]
            set ::atos_analysis_tools::cols ""
            foreach col $cols {
               lappend ::atos_analysis_tools::cols [string trim $col]
            }
            incr cpt
            continue
         }

         set a [split $line ","]
         set idcol 0
         catch {unset csvraw}
         foreach col $::atos_analysis_tools::cols {
            set ::atos_analysis_tools::csv($cpt,$col) [string trim [lindex $a $idcol]]
            incr idcol
         }

         incr cpt
         #if {$cpt > 5} {break}
      }
      close $chan

      return -code 0 [expr $cpt - 1]
   }






   proc ::atos_analysis_tools::filtre_raw_data { nb } {


      if {[info exists ::atos_analysis_tools::cols]} {unset ::atos_analysis_tools::cols}
      if {[info exists ::atos_analysis_tools::cdl]} {unset ::atos_analysis_tools::cdl}
      if {[info exists ::atos_analysis_tools::raw_nbframe]} {unset ::atos_analysis_tools::raw_nbframe}


      set ::atos_analysis_tools::nb_pt_ref 0
      set cpt 1
      set cptref 0

      ::console::affiche_resultat "nb=$nb\n"

      for {set i 1} {$i<=$nb} {incr i} {

         if { $::atos_analysis_tools::csv($i,idframe) == ""}  {continue}
         if { $::atos_analysis_tools::csv($i,jd) == ""}       {continue}
         if { $::atos_analysis_tools::csv($i,dateiso) == ""}  {continue}
         if { $::atos_analysis_tools::csv($i,obj_fint) == ""} {continue}

         set ::atos_analysis_tools::cdl($cpt,idframe)  $::atos_analysis_tools::csv($i,idframe)
         set ::atos_analysis_tools::cdl($cpt,jd)       $::atos_analysis_tools::csv($i,jd)
         set ::atos_analysis_tools::cdl($cpt,dateiso)  $::atos_analysis_tools::csv($i,dateiso)
         set ::atos_analysis_tools::cdl($cpt,obj_fint) $::atos_analysis_tools::csv($i,obj_fint)

         if { $::atos_analysis_tools::csv($i,ref_fint) != ""} {
            set ::atos_analysis_tools::cdl($cpt,ref_fint) $::atos_analysis_tools::csv($i,ref_fint)
            incr ::atos_analysis_tools::nb_pt_ref
         }

         incr cpt
      }
      if {$cpt==1} {
         return -code 1 "Aucune donnée"
      }

      set ::atos_analysis_tools::raw_nbframe [expr $cpt - 1]
      set ::atos_analysis_tools::raw_status_file "Chargé"
      set ::atos_analysis_tools::raw_date_begin  $::atos_analysis_tools::cdl(1,dateiso)
      set ::atos_analysis_tools::raw_date_end  $::atos_analysis_tools::cdl($::atos_analysis_tools::raw_nbframe,dateiso)
      set ::atos_analysis_tools::raw_duree  [format "%.3f" [expr ($::atos_analysis_tools::cdl($::atos_analysis_tools::raw_nbframe,jd) \
                                                                 - $::atos_analysis_tools::cdl(1,jd) ) * 86400.0 ]]
      set ::atos_analysis_tools::raw_fps  [format "%.3f" [expr ($::atos_analysis_tools::raw_nbframe /$::atos_analysis_tools::raw_duree )]]
      set ::atos_analysis_tools::orig $::atos_analysis_tools::cdl(1,jd)

      return -code 0
   }








   proc ::atos_analysis_tools::correction_refetoile { } {
      
      set medobj ""
      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::atos_analysis_tools::finalcdl($i,ref_fint)]} {continue}
         lappend medobj $::atos_analysis_tools::finalcdl($i,obj_fint)
      }
      set nb [llength $medobj]
      set medobj [::math::statistics::median $medobj]
      gren_info "Valeur du flux median de l objet : $medobj (nb val = $nb) \n"

      gren_info "Normalisation de la courbe par une etoile de reference\n"
      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::atos_analysis_tools::finalcdl($i,ref_fint)]} {continue}
         set ::atos_analysis_tools::finalcdl($i,obj_fint) [expr $::atos_analysis_tools::finalcdl($i,obj_fint) / $::atos_analysis_tools::finalcdl($i,ref_fint) * $medobj]
      }

   }



   proc ::atos_analysis_tools::correction_temporelle { } {

      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::atos_analysis_tools::finalcdl($i,jd)]} {continue}
         set ::atos_analysis_tools::finalcdl($i,jd) [expr $::atos_analysis_tools::finalcdl($i,jd) - ($::atos_analysis_gui::time_correction/86400.0)]
      }

   }

   proc ::atos_analysis_tools::correction_integration { offset bloc } {

      if {[info exists ::atos_analysis_tools::medianecdl]} {unset ::atos_analysis_tools::medianecdl}
      if {[info exists ::atos_analysis_tools::finalcdl]} {unset ::atos_analysis_tools::finalcdl}

      set i 0
      set fin "no"
      while {$fin=="no"} {

         # on evite un nb d image de debut = offset
         if {$i < $offset} {
            incr i
            continue
         }

         # on calcule la mediane
         set medobj ""
         set medref ""
         set k $i
         for {set j 1} {$j<=$bloc} {incr j} {
            incr k
            if {[string is double $::atos_analysis_tools::cdl($k,obj_fint)]} {
               lappend medobj $::atos_analysis_tools::cdl($k,obj_fint)
            } else {
               tk_messageBox -message "Valeur de flux OBJ invalide : ligne $k" -type ok
               return
            }
            if {[string is double $::atos_analysis_tools::cdl($k,ref_fint)]} {
               lappend medref $::atos_analysis_tools::cdl($k,ref_fint)
            } else {
               tk_messageBox -message "Valeur de flux REF invalide : ligne $k" -type ok
               return
            }
            
         }
         set medobj [::math::statistics::median $medobj]

         if {$::atos_analysis_gui::ref_corr} {
            set medref [::math::statistics::median $medref]
         }
         
         # on cree 2 nouvelles courbes
         for {set j 1} {$j<=$bloc} {incr j} {
            incr i
            if {$j==1} {
               set ::atos_analysis_tools::finalcdl($i,idframe)  $::atos_analysis_tools::cdl($i,idframe)
               set ::atos_analysis_tools::finalcdl($i,jd)       $::atos_analysis_tools::cdl($i,jd)
               set ::atos_analysis_tools::finalcdl($i,obj_fint) $medobj
               if {$::atos_analysis_gui::ref_corr} {
                  set ::atos_analysis_tools::finalcdl($i,ref_fint) $medref
               }
            }
            set ::atos_analysis_tools::medianecdl($i,jd) $::atos_analysis_tools::cdl($i,jd)
            set ::atos_analysis_tools::medianecdl($i,obj_fint) $medobj
            if {$::atos_analysis_gui::ref_corr} {
               set ::atos_analysis_tools::medianecdl($i,ref_fint) $medref
            }
         }
         set reste [expr $::atos_analysis_tools::raw_nbframe - $i]
         if {$reste<$bloc} {break}

      }


   }





   proc ::atos_analysis_tools::save_corrected_curve { file } {

      set chan [open $file w]
      puts $chan "idframe,jd,flux"

      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::atos_analysis_tools::finalcdl($i,jd)]} {continue}
            puts $chan "$::atos_analysis_tools::finalcdl($i,idframe),$::atos_analysis_tools::finalcdl($i,jd),$::atos_analysis_tools::finalcdl($i,obj_fint)"
      }

      close $chan

   }





   proc ::atos_analysis_tools::filtre_corr_data { nb } {

      if {[info exists ::atos_analysis_tools::cols]} {unset ::atos_analysis_tools::cols}
      if {[info exists ::atos_analysis_tools::cdl]} {unset ::atos_analysis_tools::cdl}
      if {[info exists ::atos_analysis_tools::corr_nbframe]} {unset ::atos_analysis_tools::corr_nbframe}

      set cpt 1
      for {set i 1} {$i<=$nb} {incr i} {
         if { $::atos_analysis_tools::csv($i,idframe)==""}  {continue}
         if { $::atos_analysis_tools::csv($i,jd)==""}       {continue}
         if { $::atos_analysis_tools::csv($i,flux)==""}     {continue}
         set ::atos_analysis_tools::cdl($cpt,idframe)  $::atos_analysis_tools::csv($i,idframe)
         set ::atos_analysis_tools::cdl($cpt,jd)       $::atos_analysis_tools::csv($i,jd)
         set ::atos_analysis_tools::cdl($cpt,flux)  $::atos_analysis_tools::csv($i,flux)
         incr cpt
      }
      if {$cpt==1} {
         return -code 1 "Aucune donnée"
      }

      set ::atos_analysis_tools::corr_nbframe [expr $cpt - 1]
      set ::atos_analysis_tools::corr_status_file "Chargé"
      set ::atos_analysis_tools::corr_date_begin  [ mc_date2iso8601 $::atos_analysis_tools::cdl(1,jd) ]

      set ::atos_analysis_tools::corr_date_end  [ mc_date2iso8601 $::atos_analysis_tools::cdl($::atos_analysis_tools::corr_nbframe,jd) ]
      set ::atos_analysis_tools::corr_duree  [format "%.3f" [expr ($::atos_analysis_tools::cdl($::atos_analysis_tools::corr_nbframe,jd) \
            - $::atos_analysis_tools::cdl(1,jd) ) * 86400.0 ]]
      set ::atos_analysis_tools::corr_fps  [format "%.3f" [expr ($::atos_analysis_tools::corr_nbframe / $::atos_analysis_tools::corr_duree )]]
      set ::atos_analysis_tools::corr_exposure [format "%.3f" [expr 1.0 / $::atos_analysis_tools::corr_fps ] ]

      set ::atos_analysis_tools::orig  $::atos_analysis_tools::cdl(1,jd)

      return -code 0
   }














# Obsolete a venir

   proc ::atos_analysis_tools::init {  } {

      set ::atos_analysis_tools::diravi "/data/Occultations/20100605_80SAPPHO"
      set ::atos_analysis_tools::dirwork "/data/Occultations/20100605_80SAPPHO/work"
      set ::atos_analysis_tools::filecsv "sapphoseg.00.avi.00001.csv"

      if {[info exists ::atos_analysis_tools::cols]} {unset ::atos_analysis_tools::cols}
      if {[info exists ::atos_analysis_tools::cdl]} {unset ::atos_analysis_tools::cdl}
      if {[info exists ::atos_analysis_tools::nb]} {unset ::atos_analysis_tools::nb}

      set file [file join $::atos_analysis_tools::dirwork "ombre_geometrique.csv"]
      set changeo [open $file w]
      puts $changeo "# OMBRE GEOMETRIQUE"
      close $changeo

   }









   proc ::atos_analysis_tools::affiche_cdl {  } {

      ::console::affiche_resultat "Afichage de la courbe\n"

      for {set i 1} {$i<=$::atos_analysis_tools::nbframe} {incr i} {
         foreach col $::atos_analysis_tools::cols {
            ::console::affiche_resultat  "$::atos_analysis_tools::cdl($i,$col) "
         }
            ::console::affiche_resultat  "\n"
      }

   }



   proc ::atos_analysis_tools::sauve_brut {  } {

      set file [file join $::atos_analysis_tools::dirwork "brut.csv"]
      set chan [open $file w]
      puts $chan "idframe,jd,obj_fint"
      for {set i 1} {$i<=$::atos_analysis_tools::nbframe} {incr i} {
         #if {$::atos_analysis_tools::cdl($i,jd)==""} {continue}
         #if {$::atos_analysis_tools::cdl($i,obj_fint)==""} {continue}
         puts $chan "$::atos_analysis_tools::cdl($i,idframe),$::atos_analysis_tools::cdl($i,jd),$::atos_analysis_tools::cdl($i,obj_fint)"
      }
      close $chan

   }



   proc ::atos_analysis_tools::sauve_bmediane {  } {

      set file [file join $::atos_analysis_tools::dirwork "bmediane.csv"]
      set chan [open $file w]
      puts $chan "idframe,jd,obj_fint,mediane"
      for {set i 1} {$i<=$::atos_analysis_tools::nbframe} {incr i} {
         #if {$::atos_analysis_tools::cdl($i,jd)==""} {continue}
         #if {$::atos_analysis_tools::cdl($i,obj_fint)==""} {continue}
         if {![info exists ::atos_analysis_tools::cdl($i,mediane)]} {
            set ::atos_analysis_tools::cdl($i,mediane) ""
         }
         puts $chan "$::atos_analysis_tools::cdl($i,idframe),$::atos_analysis_tools::cdl($i,jd),$::atos_analysis_tools::cdl($i,obj_fint),$::atos_analysis_tools::cdl($i,mediane)"
      }
      close $chan

   }




   proc ::atos_analysis_tools::sauve_mediane {  } {

      set file [file join $::atos_analysis_tools::dirwork "mediane.csv"]
      set chan [open $file w]
      puts $chan "idframe,jd,flux"
      foreach v $::atos_analysis_tools::newcdl {
         #puts $chan [format "%5s, %.3f, %.2f" [lindex $v 0] [lindex $v 1] [lindex $v 2]]
         puts $chan [format "%.3f  %.2f" [lindex $v 1] [lindex $v 2]]
      }
      close $chan

   }




   proc ::atos_analysis_tools::genere_mediane {  } {

      ::atos_analysis_tools::init
      ::atos_analysis_tools::charge_cdl [file join $::atos_analysis_tools::diravi $::atos_analysis_tools::filecsv]
      #::atos_analysis_tools::affiche_cdl
      ::atos_analysis_tools::sauve_brut
      ::atos_analysis_tools::compacte
      ::atos_analysis_tools::sauve_bmediane
      ::atos_analysis_tools::sauve_mediane

   }



   proc ::atos_analysis_tools::partie1 {  } {

      # Mode:
      # -1= t0 centre sur l''immersion
      # +1= t0 centre sur l''emersion
      # 0 = t0 centre sur le millieu de la bande

      # FORMULAIRE
      set ::atos_analysis_tools::mode -1

      # idon :
      # Faut-il comparer a des donnees
      # 1 oui
      # 0 non

      # Longueur d''onde (mum : micron)
      # FORMULAIRE
      set ::atos_analysis_tools::wvlngth 0.75
      set ::atos_analysis_tools::wvlngth [expr $::atos_analysis_tools::wvlngth * 1.e-09]

      # Bande passante (mum : micron)
      # FORMULAIRE
      set ::atos_analysis_tools::dlambda 0.4
      set ::atos_analysis_tools::dlambda [expr $::atos_analysis_tools::dlambda * 1.e-09]

      #  Distance a l'anneau (km): distance geocentrique de l objet occulteur
      # FORMULAIRE
      set ::atos_analysis_tools::dist  234000000.0

      #  Rayon de l'etoile (km)
      # FORMULAIRE
      set ::atos_analysis_tools::re 2.04

      # Vitesse normale de l'etoile (dans plan du ciel, km/s) ???
      # Vitesse relative de l'objet par rapport a la terre (km/s)
      # FORMULAIRE
      set ::atos_analysis_tools::vn 27.8

      # Largeur de la bande (km)
      # Taille estimée de l'objet (km)
      # si occultation rasante c est la taille de la corde (km)
      # FORMULAIRE
      set ::atos_analysis_tools::width 150.0

      # transmission
      # opaque = 0, sinon demander bruno
      # FORMULAIRE
      set ::atos_analysis_tools::trans 0.0

      #
      # on a 5 secondes dans lesquelles on va mesurer l instant
      # on a37 points de 0.3 sec d ecart
      #
      #
      # Duree generee (points)
      # duree synthetique choisie autour de l'evenement.
      # ex: 30 sec alrs que l evenement est au milieu.
      # attention de ne pas choisir trop large pour englober
      # l'autre evenement.
      # FORMULAIRE
      set ::atos_analysis_tools::duree 37

      # pas en temps (sec)
      # FORMULAIRE
      set ::atos_analysis_tools::pas 0.3

      # Flux hors occultation (normalisé)
      # FORMULAIRE
      set ::atos_analysis_tools::phi1 1

      # flux stellaire zero (normalisé)
      # FORMULAIRE
      set ::atos_analysis_tools::phi0 0.29

      # Heure de reference (sec TU)
      # FORMULAIRE
      set ::atos_analysis_tools::t0_ref 42082.185
      set ::atos_analysis_tools::t_milieu [expr $::atos_analysis_tools::t0_ref  + $::atos_analysis_tools::width/(2.0*$::atos_analysis_tools::vn)]

      # on essai 100 points autour du T0
      # en considerant un ecart entre les points de 0.02 sec
      # on peut dire qu on choisi pas = tmps d expo / 10
      # le pas est une estimation de la precision
      # nheure = 100 *0.02=> duree de 2 sec pour explorer l espace de
      # recherche autour de l evenement
      #
      # Nombre d'instant a explorer autour de la reference (points)
      # FORMULAIRE
      set ::atos_analysis_tools::nheure 200

      # pas (sec)
      # FORMULAIRE
      set ::atos_analysis_tools::pas_heure 0.02

      set ::atos_analysis_tools::t0_min [expr $::atos_analysis_tools::t0_ref - $::atos_analysis_tools::pas_heure * $::atos_analysis_tools::nheure / 2.0]
      set ::atos_analysis_tools::t0_max [expr $::atos_analysis_tools::t0_ref + $::atos_analysis_tools::pas_heure * $::atos_analysis_tools::nheure / 2.0]
      set ::atos_analysis_tools::t0     $::atos_analysis_tools::t0_min

   }






   proc ::atos_analysis_tools::partie2 { passe } {

      set ::atos_analysis_tools::but_calcul "Calcul"

      #-----------------------------------------------------------------------------
      if {$passe == 1} {
         set ::atos_analysis_tools::24_chi2_x ""
         set ::atos_analysis_tools::24_chi2_y ""
      }
      if {$passe == 2} {
      }

      #-----------------------------------------------------------------------------
      # Fichiers de sortie
      # sorties:
      # fort.20: ombre geometrique
      # fort.21: ombre avec diffraction (convolee par la bande passante et
      #          par le diametre stellaire)
      # fort.22: ombre lissee par la reponse instrumentale
      # fort.23: ombre (fort.22) interpolee sur les points d'observation
      # fort.24: t0, chi2, nombre de points ajustes
      # fort.25: rayon de l'etoile, chi2_min, npt fittes (NB. "append")
      # fort.26: dans le cas ou la bande a une largeur finie (ex. duree finie de l'occn)
      #          chi2 - nfit (NB. "append"), voir par ex. donnees Hakos/Varuna 19 fev 2010
      set file21 [file join $::atos_analysis_tools::dirwork "21_${passe}_modele_flux_avant_convolution.csv"]
      set file22 [file join $::atos_analysis_tools::dirwork "22_${passe}_modele_flux_apres_convolution.csv"]
      set file23 [file join $::atos_analysis_tools::dirwork "23_${passe}_.csv"]
      set file24 [file join $::atos_analysis_tools::dirwork "24_${passe}_.csv"]
      set chan24 [open $file24 w]
      set file25 [file join $::atos_analysis_tools::dirwork "25_${passe}_.csv"]
      set chan25 [open $file25 w]
      set file26 [file join $::atos_analysis_tools::dirwork "26_${passe}_.csv"]
      set chan26 [open $file26 w]
      set file27 [file join $::atos_analysis_tools::dirwork "obs.dat"]
      set chan27 [open $file27 w]
      #-----------------------------------------------------------------------------

      # controle des observations
      for {set i 1} {$i<=$::atos_analysis_tools::duree} {incr i} {
         puts $chan27 [format "%5.5f %5.5f" $::atos_analysis_tools::tobs($i) $::atos_analysis_tools::fobs($i)]
      }
      close $chan27

      # bar.ini
      set file28 [file join $::atos_analysis_tools::dirwork "bar$passe.ini"]
      set chan28 [open $file28 w]
      puts $chan28 "$::atos_analysis_tools::mode"
      puts $chan28 "0"
      puts $chan28 "1"
      puts $chan28 "obs.dat"
      puts $chan28 "$::atos_analysis_tools::sigma"
      puts $chan28 "$::atos_analysis_gui::wvlngth $::atos_analysis_gui::dlambda"
      puts $chan28 "$::atos_analysis_tools::dist $::atos_analysis_tools::re"
      puts $chan28 "$::atos_analysis_tools::vn"
      puts $chan28 "$::atos_analysis_tools::width $::atos_analysis_tools::trans"
      puts $chan28 "$::atos_analysis_tools::duree $::atos_analysis_tools::pas"
      puts $chan28 "$::atos_analysis_tools::phi1 $::atos_analysis_tools::phi0"
      puts $chan28 "$::atos_analysis_tools::t0_ref"
      puts $chan28 "$::atos_analysis_tools::nheure $::atos_analysis_tools::pas_heure"
      close $chan28

      #-----------------------------------------------------------------------------
      
      set tt0 [clock clicks -milliseconds]

      while { $::atos_analysis_tools::t0<=$::atos_analysis_tools::t0_max} {

         set npt [expr int ($::atos_analysis_tools::duree/(2.0 * $::atos_analysis_tools::pas) )]
         if {$::atos_analysis_tools::mode==-1} {
            # bord gauche de l'ombre cale
            # sur l'origine (ie t0 en temps)
            set x1 0.0
            set x2 $::atos_analysis_tools::width
         }
         if {$::atos_analysis_tools::mode==0} {
            # ombre centree sur le milieu
            # de la bande
            set x1 [expr -$::atos_analysis_tools::width / 2.0 ]
            set x2 [expr  $::atos_analysis_tools::width / 2.0 ]
         }
         if {$::atos_analysis_tools::mode==1} {
            # bord droit de l'ombre cale
            # sur l'origine (ie t0 en temps)
            set x1 [expr -$::atos_analysis_tools::width ]
            set x2 0.0
         }

         set opa_ampli [expr  1.0 - sqrt($::atos_analysis_tools::trans)]

         #-----------------------------------------------------------------------------
         #
         # Trace de l'ombre geometrique
         #
         ::atos_analysis_tools::ombre_geometrique  $::atos_analysis_tools::mode $::atos_analysis_tools::t0 $::atos_analysis_tools::duree $::atos_analysis_tools::width $::atos_analysis_tools::vn $::atos_analysis_tools::phi1 $::atos_analysis_tools::phi0

         #-----------------------------------------------------------------------------
         #      etoile: sous-programme de convolution par le diametre
         #         stellaire.
         #
         #      NB.:    on appelle deux fois etoile pour convoluer par la
         #         bande passante.
         #
         set som 0.0
         set chan21 [open $file21 w]
         set ::atos_analysis_tools::21_ombre_avec_diffraction_x ""
         set ::atos_analysis_tools::21_ombre_avec_diffraction_y ""

         for {set i [expr -$npt]} {$i<=$npt} {incr i} {
            set x [expr $::atos_analysis_tools::vn * $::atos_analysis_tools::pas * $i]
            set wvlngth1 [expr $::atos_analysis_tools::wvlngth - $::atos_analysis_tools::dlambda / 2.0]
            set wvlngth2 [expr $::atos_analysis_tools::wvlngth + $::atos_analysis_tools::dlambda / 2.0]
            set flux1 [::atos_analysis_tools::etoile $::atos_analysis_tools::re $x1 $x2 $opa_ampli $wvlngth1 $::atos_analysis_tools::dist $x]
            set flux2 [::atos_analysis_tools::etoile $::atos_analysis_tools::re $x1 $x2 $opa_ampli $wvlngth2 $::atos_analysis_tools::dist $x]
            set flu [expr  ( $flux1 + $flux2 )/2.0]
            set flux($i) [expr $flu*($::atos_analysis_tools::phi1-$::atos_analysis_tools::phi0) + $::atos_analysis_tools::phi0]
            set t($i) [expr $::atos_analysis_tools::t0 + $i * $::atos_analysis_tools::pas]
            puts $chan21 "$t($i) , $flux($i)"

            if {$passe == 2} {
               lappend ::atos_analysis_tools::21_ombre_avec_diffraction_x $t($i)
               lappend ::atos_analysis_tools::21_ombre_avec_diffraction_y [normal2flux $flux($i)]
            }

            set som [expr $som + $::atos_analysis_tools::pas * $::atos_analysis_tools::vn * (1.0-$flux($i))]
         }

         close $chan21

         ::console::affiche_resultat "Integrale du flux avant convolution(km): $som\n"
         #-----------------------------------------------------------------------------


         #-----------------------------------------------------------------------------
         #
         # Convolution par la reponse instrumentale
         # Considerer ici comme lineaire
         #

         if {$::atos_analysis_tools::irep == 1 } {

            # si reponse instrumentale
            set serial_t    [array get t]
            set serial_flux [array get flux]
            set nptl        [::atos_analysis_tools::instrument $serial_t $serial_flux $npt]

         } else {

            # si pas de reponse instrumentale
            set nptl 0
            for {set i [expr -$npt]} {$i<=$npt} {incr i} {
               incr nptl
               set ::atos_analysis_tools::tl($nptl)    $t($i)
               set ::atos_analysis_tools::fluxl($nptl) $flux($i)
            }

         }

         #-----------------------------------------------------------------------------


         #-----------------------------------------------------------------------------
         #
         # Ecriture du modele final (apres convolution par etoile et instrument)
         #
         set chan22 [open $file22 w]
         set ::atos_analysis_tools::22_ombre_instru_x ""
         set ::atos_analysis_tools::22_ombre_instru_y ""
         set som 0.0
         set tl_min  1.e50
         set tl_max  -1.d50
         for {set i 1} {$i<=$nptl} {incr i} {
            puts $chan22 "$::atos_analysis_tools::tl($i),$::atos_analysis_tools::fluxl($i)"
            if {$passe == 2} {
               lappend ::atos_analysis_tools::22_ombre_instru_x $::atos_analysis_tools::tl($i)
               lappend ::atos_analysis_tools::22_ombre_instru_y [normal2flux $::atos_analysis_tools::fluxl($i)]
            }
            if {$::atos_analysis_tools::tl($i)>=$tl_max} {set tl_max $::atos_analysis_tools::tl($i)}
            if {$::atos_analysis_tools::tl($i)<=$tl_min} {set tl_min $::atos_analysis_tools::tl($i)}
            set som [expr $som + $::atos_analysis_tools::pas * $::atos_analysis_tools::vn * (1.0 - $::atos_analysis_tools::fluxl($i))]
         }
         close $chan22
         ::console::affiche_resultat "Integrale du flux apres convolution (km): $som\n"
         #-----------------------------------------------------------------------------



         #-----------------------------------------------------------------------------
         #
         # Calcul du chi2 avec les donnees
         #
         set nfit 0
         set chi2 0.0
         set tobs_min 1.e50
         set tobs_max -1.e50

         set chan23 [open $file23 w]
         set ::atos_analysis_tools::23_ombre_interpol_x  ""
         set ::atos_analysis_tools::23_ombre_interpol_y  ""

         for {set i 1} {$i<=$::atos_analysis_tools::duree} {incr i} {

            set fac [expr ($::atos_analysis_tools::tobs($i)-$tl_min)*($::atos_analysis_tools::tobs($i)-$tl_max)]
            if {$fac<=0.0} {
               set fmod_inter [::atos_analysis_tools::interpol $nptl $::atos_analysis_tools::tobs($i)]
               puts $chan23 "$::atos_analysis_tools::tobs($i),$fmod_inter"
               if {$passe == 2} {
                   lappend  ::atos_analysis_tools::23_ombre_interpol_x $::atos_analysis_tools::tobs($i)
                   lappend  ::atos_analysis_tools::23_ombre_interpol_y [normal2flux $fmod_inter]
               }
               # fmod_inter ! attention !
               set sigma_local $::atos_analysis_tools::sigma
               set chi2 [expr $chi2 + pow(($fmod_inter - $::atos_analysis_tools::fobs($i))/$sigma_local,2)]
               incr nfit
               if {$::atos_analysis_tools::tobs($i)<$tobs_min} {set tobs_min $::atos_analysis_tools::tobs($i)}
               if {$::atos_analysis_tools::tobs($i)>$tobs_max} {set tobs_max $::atos_analysis_tools::tobs($i)}
            }
         }
         close $chan23

         ::console::affiche_resultat "t0: $::atos_analysis_tools::t0\n"
         ::console::affiche_resultat "chi2: $chi2\n"
         ::console::affiche_resultat "nfit: $nfit\n"
         ::console::affiche_resultat "temps milieu de la bande: $::atos_analysis_tools::t_milieu\n"
         ::console::affiche_resultat "duree de la bande: [expr $::atos_analysis_tools::width/$::atos_analysis_tools::vn]\n"
         ::console::affiche_resultat "$nfit points fittes entre: $tobs_min et $tobs_max  \n"
         if {$::atos_analysis_tools::irep == 1 } {
            ::console::affiche_resultat "Reponse instrumentale utilisee. expo : $::atos_analysis_tools::corr_exposure\n"
         } else {
            ::console::affiche_resultat "Reponse instrumentale uniforme \n"
         }


         puts $chan24 "$::atos_analysis_tools::t0,$chi2,$nfit"
         puts $chan26 "[expr $chi2 - $nfit*1.0]"

         if {$passe == 1} {
            lappend ::atos_analysis_tools::24_chi2_x $::atos_analysis_tools::t0
            lappend ::atos_analysis_tools::24_chi2_y $chi2
         }

         lappend ::atos_analysis_tools::chi2_search [list $::atos_analysis_tools::t0 $chi2 $nfit]

         #-----------------------------------------------------------------------------

         #  on incremente t0
         set ::atos_analysis_tools::t0 [expr $::atos_analysis_tools::t0 + $::atos_analysis_tools::pas_heure]

         set ::atos_analysis_tools::percent [format "%.2f" [expr ($::atos_analysis_tools::t0-$::atos_analysis_tools::t0_min)/($::atos_analysis_tools::t0_max-$::atos_analysis_tools::t0_min)*100.0]]
         set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
         set reste [expr $tt / $::atos_analysis_tools::percent * ( 100.0 - $::atos_analysis_tools::percent) / 60.0 ]
         set reste [format "%.1f" $reste ]
         ::console::affiche_resultat "$::atos_analysis_tools::percent % fini dans $reste min---------------------------------------------------\n"

         if {$::atos_analysis_tools::but_calcul=="Stop"} {return}


      # Fin While
      }
      set ::atos_analysis_tools::percent 100.0
      close $chan24
      close $chan26







      #-----------------------------------------------------------------------------
      #
      # on cherche le temps correspondant au minimum de chi2:
      #

      set chi2_min 1.e50
      foreach cols $::atos_analysis_tools::chi2_search {
         set t0   [lindex $cols 0]
         set chi2 [lindex $cols 1]
         set nfit [lindex $cols 2]
         if {$chi2 <= $chi2_min} {
            set chi2_min      $chi2
            set t0_chi2_min   $t0
            set nfit_chi2_min $nfit
         }
      }

      set dchi2  1.0
      set t_inf  1.e50
      set t_sup -1.e50
      foreach cols $::atos_analysis_tools::chi2_search {
         set t0   [lindex $cols 0]
         set chi2 [lindex $cols 1]
         set nfit [lindex $cols 2]
         if {$chi2 <= [expr $chi2_min+$dchi2]} {
            if {$t0 <= $t_inf} { set t_inf $t0}
            if {$t0 >= $t_sup} { set t_sup $t0}
         }
      }
      set ::atos_analysis_tools::t_inf         [format "%.4f" $t_inf]
      set ::atos_analysis_tools::t_sup         [format "%.4f" $t_sup]
      set ::atos_analysis_tools::t_diff        [format "%.3f" [expr $t_sup-$t_inf] ]

      set dchi2  2.0
      set t_inf  1.e50
      set t_sup -1.e50
      foreach cols $::atos_analysis_tools::chi2_search {
         set t0   [lindex $cols 0]
         set chi2 [lindex $cols 1]
         set nfit [lindex $cols 2]
         if {$chi2 <= [expr $chi2_min+$dchi2]} {
            if {$t0 <= $t_inf} { set t_inf $t0}
            if {$t0 >= $t_sup} { set t_sup $t0}
         }
      }
      set ::atos_analysis_tools::t_inf_2s      [format "%.4f" $t_inf]
      set ::atos_analysis_tools::t_sup_2s      [format "%.4f" $t_sup]
      set ::atos_analysis_tools::t_diff_2s     [format "%.3f" [expr $t_sup-$t_inf] ]

      set dchi2  9.0
      set t_inf  1.e50
      set t_sup -1.e50
      foreach cols $::atos_analysis_tools::chi2_search {
         set t0   [lindex $cols 0]
         set chi2 [lindex $cols 1]
         set nfit [lindex $cols 2]
         if {$chi2 <= [expr $chi2_min+$dchi2]} {
            if {$t0 <= $t_inf} { set t_inf $t0}
            if {$t0 >= $t_sup} { set t_sup $t0}
         }
      }
      set ::atos_analysis_tools::t_inf_3s      [format "%.4f" $t_inf]
      set ::atos_analysis_tools::t_sup_3s      [format "%.4f" $t_sup]
      set ::atos_analysis_tools::t_diff_3s     [format "%.3f" [expr $t_sup-$t_inf] ]

#      set chan24 [open $file24 r]
#      set chi2_min 1.e50
#      while {[gets $chan24 line] >= 0} {
#         set line [string trim $line]
#         set cols [split $line ","]
#         set t0   [lindex $cols 0]
#         set chi2 [lindex $cols 1]
#         set nfit [lindex $cols 2]
#         if {$chi2 <= $chi2_min} {
#            set chi2_min      $chi2
#            set t0_chi2_min   $t0
#            set nfit_chi2_min $nfit
#         }
#      }
#      close $chan24

#      set chan24 [open $file24 r]
#      set dchi2  1.0
#      set t_inf  1.e50
#      set t_sup -1.e50
#      while {[gets $chan24 line] >= 0} {
#         set line [string trim $line]
#         set cols [split $line ","]
#         set t0   [lindex $cols 0]
#         set chi2 [lindex $cols 1]
#         set nfit [lindex $cols 2]
#         if {$chi2 <= [expr $chi2_min+$dchi2]} {
#            if {$t0 <= $t_inf} { set t_inf $t0}
#            if {$t0 >= $t_sup} { set t_sup $t0}
#         }
#
#      }
#      close $chan24
#      ::console::affiche_resultat  "t0 = $t0\n"
#      ::console::affiche_resultat  "t0_chi2_min = $t0_chi2_min\n"
#      ::console::affiche_resultat  "chi2_min = $chi2_min\n"
#      ::console::affiche_resultat  "nfit_chi2_min = $nfit_chi2_min\n"
#      ::console::affiche_resultat  "Dchi2 = $dchi2\n"
#      ::console::affiche_resultat  "intervalle ou chi2 < chi2_min + dchi2 = $t_inf $t_sup\n"

     ::console::affiche_resultat  "----------------------------------------\n"
     ::console::affiche_resultat  "nheure = $::atos_analysis_tools::nheure\n"
     ::console::affiche_resultat  "t0 = $t0\n"
     ::console::affiche_resultat  "t0_chi2_min = $t0_chi2_min\n"
     ::console::affiche_resultat  "chi2_min = $chi2_min\n"
     ::console::affiche_resultat  "nfit_chi2_min = $nfit_chi2_min\n"
     ::console::affiche_resultat  "Dchi2 = $dchi2\n"
     ::console::affiche_resultat  "intervalle ou chi2 < chi2_min + dchi2 = $t_inf $t_sup\n"
     ::console::affiche_resultat  "-$passe-----------------------------\n"
     ::console::affiche_resultat  "----------------------------------------\n"

      set ::atos_analysis_tools::t0_chi2_min   [format "%.4f" $t0_chi2_min]
      set ::atos_analysis_tools::chi2_min      [format "%.4f" $chi2_min]
      set ::atos_analysis_tools::nfit_chi2_min $nfit_chi2_min
      set ::atos_analysis_tools::dchi2         [format "%.4f" $dchi2]

      puts $chan25 "$::atos_analysis_tools::width,$chi2_min,$nfit_chi2_min"
      puts $chan25 "[expr $::atos_analysis_tools::width/$::atos_analysis_tools::vn],$chi2_min,$nfit_chi2_min"
      close $chan25
   }





   #-----------------------------------------------------------------------------
   # This subroutine gives the complex amplitude resulting from diffraction of a
   # coherent planar wave, on a homogeneous semi-transparent stripe. The stripe is
   # assumed to be infinite in the 0y direction, it begins at x= "x1" and ends
   # at x= "x2" (x1 < x2). It removes a fraction "opa_ampli" (opacity in amplitude)
   # of the amplitude of the incident wave. So, opa_ampli= 0 corresponds to a
   # transparent stripe, while opa_ampli= 1 corresponds to an opaque stripe. This
   # opacity is related to the fractional transmission in intensity, F, by:
   #
   #            opa_ampli= 1 - sqrt(F)
   #
   # The subroutine call the FRESNEL subroutine, which uses dimensionless
   # quantities normalized to the Fresnel scale fr= sqrt( (wvlngth*dist)/2 ),
   # where "wvlngth" is the wavelength of the observation, and "dist" is the
   # distance of the observer to the diffracting object (here the stripe).
   #
   # The wave is assumed to have an amplitude equal to unity at the stripe,
   # and the subroutine gives the complex amplitude recorded by the observer,
   # whose abscissa along the 0x axis is "x". The real part of the amplitude
   # is Re= 1+r_ampli, and the imaginary part is Im= i_ampli (i_ampli to be
   # declared REAL*8 !). Caution: the resulting intensity is flux= Re**2 + Im**2,
   # NO sqrt !
   #
   # The formula which is used is:
   #
   # amplitude(x)= opa_ampli*( (i-1)/2 )*{ C(x-x1) - C(x-x2) +
   #                i*[ S(x-x1) - S(x-x2) ] },
   #
   # where x,x1,x2 have been normalized to the Fresnel scale, i*i= -1, and
   # C and S are given by the subroutine FRESNEL.
   #
   #
   # NB. x1,x2,wvlngth,dist and x must be expressed in the same unity when entered
   # in the subroutine !
   #
   #-----------------------------------------------------------------------------
   proc ::atos_analysis_tools::bar { x1 x2 opa_ampli wvlngth dist x } {

      # Required accuracy on the amplitude:
      set eps 1.0e-16

      # Normalization to the Fresnel scale
      set fr   [expr sqrt( ($wvlngth*$dist)/2.0 ) ]
      set x1fr [expr $x1 / $fr ]
      set x2fr [expr $x2 / $fr ]
      set xfr  [expr $x  / $fr ]


      # Calculation of the amplitude
      set xmx1 [expr  $xfr-$x1fr ]
      set xmx2 [expr  $xfr-$x2fr ]

      # FRESNEL

      if {$xmx1<0.0} {
         set sxmx1 -1.0
         set xmx1 [expr -1.0 * $xmx1]
      } else {
         set sxmx1 1.0
      }
      if {$xmx2<0.0} {
         set sxmx2 -1.0
         set xmx2 [expr -1.0 * $xmx2]
      } else {
         set sxmx2 1.0
      }

      set c1 [::math::special::fresnel_C $xmx1]
      set s1 [::math::special::fresnel_S $xmx1]
      set c2 [::math::special::fresnel_C $xmx2]
      set s2 [::math::special::fresnel_S $xmx2]

      if {$sxmx1<0.0} {
         set c1 [expr -1.0 * $c1]
         set s1 [expr -1.0 * $s1]
      }
      if {$sxmx2<0.0} {
         set c2 [expr -1.0 * $c2]
         set s2 [expr -1.0 * $s2]
      }


      set cc [expr $c1-$c2 ]
      set ss [expr $s1-$s2 ]
      set r_ampli [expr  - ($cc+$ss)*($opa_ampli/2.0) ]
      set i_ampli [expr    ($cc-$ss)*($opa_ampli/2.0) ]
      set amplir  [expr  1.0 + $r_ampli  ]
      set amplii  [expr  $i_ampli ]
      set flux    [expr  $amplir*$amplir + $amplii*$amplii ]

      return $flux
   }









   proc ::atos_analysis_tools::etoile { re x1 x2 opa_ampli wvlngth dist x } {

      # etoile ponctuelle
      set zero 0.0

      # npt: echantillonnage sur le rayon stellaire pour le lissage
      # doit etre pair pour "sommation" ! NB npt sert a la fois pour explorer
      # horizontalement et verticalement le disque stellaire
      set npt 12

      set tranche [expr $re/($npt*1.0)]
      set flux 0.0
      set som  0.0


      # etoile ponctuelle
      if {$re==$zero} {
         set flux [::atos_analysis_tools::bar $x1 $x2 $opa_ampli $wvlngth $dist $x]
      }

      for {set i [expr -$npt]} {$i<=$npt} {incr i} {
         set p [expr ($i * 1.0)*$tranche]

         #---------------------------------------------------------------------------
         # etoile uniforme
         set coeff [expr sqrt( abs ( pow($re,2) - pow($p,2) ) ) ]
         #---------------------------------------------------------------------------

         #---------------------------------------------------------------------------
         #  etoile assombrie centre-bord:
         #  pour chaque valeur de p on integre ("sommation") l'intensite lumineuse
         #  de 0 a dsqrt(re**2 - p**2) --->
         #  prend ~ 4 fois plus de temps que le disque uniforme.
         #  On peut aller plus vite en calculant une fois pour toutes
         #  "coeff" pour differente valeur de p.
         #
         #   p_norm= p/re                                ! cause de l'appel de "sommation" ---> a ne considerer que
         #   fac= 1.d0 - p_norm**2                       ! dans un 2eme temps
         #   ymax  = dsqrt( dabs(1.d0 - p_norm**2) )     ! dabs: si argument tres legerement negatif
         #   coeff = sommation(0.d0,ymax,p_norm,npt)     ! integre l'intensite verticalement a p_norm=cste
         #---------------------------------------------------------------------------

         set xx    [expr $x + $p]
         set fluxi [::atos_analysis_tools::bar $x1 $x2 $opa_ampli $wvlngth $dist $xx]
         set flux  [expr $flux + $coeff*$fluxi]
         set som   [expr $som + $coeff]
      }

      return [expr $flux / $som ]
   }

















   proc ::atos_analysis_tools::instrument { serial_t serial_flux npt } {

   # subroutine instrument (nmax, t, flux, npt, trep, rep ,nrep, tl, fluxl, nptl)

      # som= somme pour construire le flux lisse
      # aire= integrale de la fonction instrumentale
      # dtmax= longueur en temps de la fonction instrumentale.

      array set t    $serial_t
      array set flux $serial_flux

      set trep(1) [expr -$::atos_analysis_tools::corr_exposure / 2. ]
      set trep(2) [expr +$::atos_analysis_tools::corr_exposure / 2. ]
      set rep(1)  1
      set rep(2)  1
      set nrep 2

      set nptl 0
      set dtmax   [expr $trep($nrep) - $trep(1)]

      # On boucle d'abord sur le fux original
      for {set i [expr - $npt]} {$i <= $npt} {incr i} {

         set tmin [expr $t($i) - $dtmax]
         if { $tmin < $t([expr -$npt]) } {continue}
         set som 0
         set aire 0

         # On boucle ensuite sur la reponse instrumentale

         for {set j [expr $i+1-$npt]} {$j<=[expr $i+1+$npt]} {incr j} {

            set dt [expr $t($i) - $t([expr $i-$j+1])]
            set discri [expr ($dt - $trep(1))*($dt - $trep($nrep))]
            if {$discri <= 0.0 } {

               set coeff 0.0

               for {set k 1} {$k<=[expr $nrep-1]} {incr k} {

                  set discri [expr ($dt - $trep($k))*($dt - $trep([expr $k+1]))]
                  if {$discri <= 0.0 } {
                     set coeff [expr $rep([expr $k+1]) - $rep($k)]
                     set coeff [expr ($dt-$trep($k))/($trep([expr $k+1])-$trep($k))*$coeff]
                     set coeff [expr $coeff + $rep($k)]
                     break
                  }

               }

               set som [expr $som + $coeff * $flux([expr $i - $j +1])]
               set aire [expr $aire + $coeff]

            }

         }
         incr nptl
         set ::atos_analysis_tools::tl($nptl) $t($i)
         set ::atos_analysis_tools::fluxl($nptl) [expr $som/$aire]
      }
      return $nptl
   }
















   # Trace de l'ombre geometrique
   proc ::atos_analysis_tools::ombre_geometrique { imod t0 duree width vn phi1 phi0 } {

      set file [file join $::atos_analysis_tools::dirwork "20_2_ombre_geometrique.csv"]
      set changeo [open $file w]
      set ::atos_analysis_tools::20_ombre_geometrique_x ""
      set ::atos_analysis_tools::20_ombre_geometrique_y ""

      if {$imod==0} {
         # milieu de la bande centre sur t0
         set t1 [expr $t0 - $duree / 2.0 ]
         set t2 [expr $t0 - $width / ( 2.0 * $vn ) ]
         set t3 [expr $t0 + $width / ( 2.0 * $vn ) ]
         set t4 [expr $t0 + $duree / 2.0 ]
      }

      if {$imod==-1} {
         # bord droit de la bande centre sur t0
         set t1 [expr $t0 - $duree / 2.0 ]
         set t2 $t0
         set t3 [expr $t0 + $width / $vn ]
         set t4 [expr $t0 + $duree / 2.0 ]
      }


      if {$imod==1} {
         # bord gauche de la bande centre sur t0
         set t1 [expr $t0 - $duree / 2.0 ]
         set t2 [expr $t0 - $width / $vn ]
         set t3 $t0
         set t4 [expr $t0 + $duree / 2.0 ]
      }

      if {$t1<$t2} {
         puts $changeo "$t1,$phi1"
         puts $changeo "$t2,$phi1"
         puts $changeo "$t2,$phi0"
         lappend ::atos_analysis_tools::20_ombre_geometrique_x $t1
         lappend ::atos_analysis_tools::20_ombre_geometrique_y [normal2flux $phi1]
         lappend ::atos_analysis_tools::20_ombre_geometrique_x $t2
         lappend ::atos_analysis_tools::20_ombre_geometrique_y [normal2flux $phi1]
         lappend ::atos_analysis_tools::20_ombre_geometrique_x $t2
         lappend ::atos_analysis_tools::20_ombre_geometrique_y [normal2flux $phi0]
      } else {
         puts $changeo "$t1,$phi0"
         lappend ::atos_analysis_tools::20_ombre_geometrique_x $t1
         lappend ::atos_analysis_tools::20_ombre_geometrique_y [normal2flux $phi0]
      }
      if {$t3<$t4} {
         puts $changeo "$t3,$phi0"
         puts $changeo "$t3,$phi1"
         puts $changeo "$t4,$phi1"
         lappend ::atos_analysis_tools::20_ombre_geometrique_x $t3
         lappend ::atos_analysis_tools::20_ombre_geometrique_y [normal2flux $phi0]
         lappend ::atos_analysis_tools::20_ombre_geometrique_x $t3
         lappend ::atos_analysis_tools::20_ombre_geometrique_y [normal2flux $phi1]
         lappend ::atos_analysis_tools::20_ombre_geometrique_x $t4
         lappend ::atos_analysis_tools::20_ombre_geometrique_y [normal2flux $phi1]
      } else {
         puts $changeo "$t4,$phi0"
         lappend ::atos_analysis_tools::20_ombre_geometrique_x $t4
         lappend ::atos_analysis_tools::20_ombre_geometrique_y [normal2flux $phi0]
      }

      close $changeo

   }













   #-----------------------------------------------------------------

   proc ::atos_analysis_tools::interpol { nmod t } {

      set zero 0.0
      for {set i 1} {$i<$nmod} {incr i} {
         set fac [expr ( $t - $::atos_analysis_tools::tl($i) ) * ($t - $::atos_analysis_tools::tl([expr $i + 1]) ) ]
         if {$fac<=$zero} {
            set fmod_inter [expr ($::atos_analysis_tools::fluxl([expr $i + 1])- $::atos_analysis_tools::fluxl($i)) / ($::atos_analysis_tools::tl([expr $i + 1])- $::atos_analysis_tools::tl($i)) ]
            #::console::affiche_resultat "tmod : $::atos_analysis_tools::tl($i) $::atos_analysis_tools::tl([expr $i + 1])\n"
            #::console::affiche_resultat "fmod : $::atos_analysis_tools::fluxl($i) $::atos_analysis_tools::fluxl([expr $i + 1])\n"
            #::console::affiche_resultat "fmod_inter : $i $fmod_inter\n"
            set fmod_inter [expr $fmod_inter*( $t - $::atos_analysis_tools::tl($i) ) + $::atos_analysis_tools::fluxl($i)]
            #::console::affiche_resultat "fmod_inter : $i $fmod_inter\n"
            return $fmod_inter
         }
      }
      return -code 1 "Pas d''interpolation possible!!!\n"
   }















   #-----------------------------------------------------------------
   #
   # Integrale d'une fonction par la methode de Simpson
   # Integre la fonction f(x,y) sur y entre a et b, avec npt intervalles
   # Attention, npt doit etre pair !
   #
   #    integrale(a,b)= (h/3)*[ f(x,a0) + 4f(x,a1) + 2f(x,a2) + 4f(x,a3) + ...
   #                      ... + 2f(x,an-2) + 4f(x,an-1) + f(x,an) ]
   #
   #    ou h= (b-a)/npt, a0= a et an= b
   #
   #
   #
   proc ::atos_analysis_tools::sommation { a b x npt } {

      set h [expr ($b-$a)/($npt*1.0)]

      # somme des termes impairs
      set somi 0.0
      for {set i 1} {$i<$npt} {incr i 2} {
         set y [expr $a + $i * $h]
         set somi  [expr $somi + ::atos_analysis_tools::func($x,$y)]
      }
      set somi [expr 4.0 * $somi]

      # somme des termes pairs
      set somi 0.0
      for {set i 2} {$i<=[expr $npt - 2]} {incr i 2} {
         set y [expr $a + $i * $h]
         set somp  [expr $somp + ::atos_analysis_tools::func($x,$y)]
      }
      set somp [expr 4.0 * $somp]

      # addition des bornes
      set somme [expr ::atos_analysis_tools::func($x,$a) + $somi + $somp + ::atos_analysis_tools::func($x,$b)]
      set somme [expr ( $h * $somme ) / 3.0]
      return $somme
   }


   #-----------------------------------------------------------------
   # Calcul de l'intensite lumineuse a (x,y) du centre
   # de l'etoile (assombrissement centre-bord)
   #
   # l'intensite lumineuse I emise par un element de surface
   # de l'etoile dont la normale fait un angle theta avec
   # la ligne de visee, avec mu=cos(theta), est de la form:
   #
   # I(mu)= 1 - sum_1^4 a_k*[1-mu^(k/2)]
   #
   # NB. l'intensite vaut un au milieu du disque stellaire (ou mu=1)
   #
   # Sources: Claret Astron. Astrophys. 363, 1081Ð1190 (2000) et
   #-----------------------------------------------------------------
   proc ::atos_analysis_tools::func { x y } {

      set tol  -1.e-15

      set a(1)  0.6699
      set a(2) -0.7671
      set a(3)  1.6405
      set a(4) -0.6607

      set fac [expr 1.0 - (pow(x,2) + pow(y,2))]
      if { $fac < 0.0  } {
         if {$fac < $tol } {
            ::console::affiche_erreur  "Erreur dans le calcul de l'intensite lumineuse : 1-x^2-y^2=$fac\n"
         }
         set fac 0.0
      }

      set mu [expr sqrt($fac)]

      set f 1.0
      for {set k 1} {$k<=4} {incr k} {
         set f [expr $f - $a($k)*( 1.0-pow($mu,$k)/2.0 )]
      }


   }






   # Procedure d'ajustement d'un polynome sur le signal
   # afin d'endeterminer la dispersion.
   # -> estimation du sigma

   proc ::atos_analysis_tools::calcul_sigma {  } {


      return 0.7

   }


   proc ::atos_analysis_tools::normal2flux { fn } {
      return [expr  $::atos_analysis_tools::med1 * $fn]
   }







   #
   proc ::atos_analysis_tools::run {  } {


      ::atos_analysis_tools::init
      ::atos_analysis_tools::charge_cdl [file join $::atos_analysis_tools::dirwork "immersion.dat"]
      #::atos_analysis_tools::affiche_cdl
      ::atos_analysis_tools::partie1
      ::atos_analysis_tools::partie2

   }



   proc ::atos_analysis_tools::build.matrix {xvec degree} {
       set sums [llength $xvec]
       for {set i 1} {$i <= 2*$degree} {incr i} {
           set sum 0
           foreach x $xvec {
               set sum [expr {$sum + pow($x,$i)}]
           }
           lappend sums $sum
       }

       set order [expr {$degree + 1}]
       set A [math::linearalgebra::mkMatrix $order $order 0]
       for {set i 0} {$i <= $degree} {incr i} {
           set A [math::linearalgebra::setrow A $i [lrange $sums $i $i+$degree]]
       }
       return $A
   }

   proc ::atos_analysis_tools::build.vector {xvec yvec degree} {
       set sums [list]
       for {set i 0} {$i <= $degree} {incr i} {
           set sum 0
           foreach x $xvec y $yvec {
               set sum [expr {$sum + $y * pow($x,$i)}]
           }
           lappend sums $sum
       }

       set x [math::linearalgebra::mkVector [expr {$degree + 1}] 0]
       for {set i 0} {$i <= $degree} {incr i} {
           set x [math::linearalgebra::setelem x $i [lindex $sums $i]]
       }
       return $x
   }



   proc ::atos_analysis_tools::testpoly {} {

      # Now, to solve the example from the top of this page
      set x {0   1   2   3   4   5   6   7   8   9  10}
      set y {1   6  17  34  57  86 121 162 209 262 321}

      # build the system A.x=b
      set degree 2
      set A [build.matrix $x $degree]
      set b [build.vector $x $y $degree]
      # solve it
      set coeffs [math::linearalgebra::solveGauss $A $b]
      # show results
      ::console::affiche_resultat "coeffs=$coeffs\n"

      #3 x2 + 2 x + 1
      #1.0000000000000207 1.9999999999999958 3.0

   }



   proc ::atos_analysis_tools::pi {} {return 3.1415926535897931}
   proc ::atos_analysis_tools::ua {} {return 149597870.0}



# Estime le diametre angulaire (mas) d'une etoile geante ou supergeante
# a partir de ses magnitudes V (ou B) et K. Precision typique de 10 a 20 %

   proc ::atos_analysis_tools::diametre_stellaire { B V K D {class 0} } {

# Source: G.R. van Belle (1999), Predicting stellar angular size,
# Publi. Astron. Soc. Pacific 111, 1515-1523.

      if {$B == "" || $V == "" || $K == "" || $D == ""} { return 0 }

      set D [expr $D * [ua] ]
      set mas2rad [expr [pi]/(180.0*3600.0*1000.0)]

      ::console::affiche_resultat  "V-K = [format "%.3f" [expr $V-$K]]\n"
      ::console::affiche_resultat  "B-K = [format "%.3f" [expr $B-$K]]\n"

      # Etoile de classe inconnue, on cherche a determiner la classe a partir des couleurs V-K et B-K
      if {$class == 0} {
         set VmK [expr $V-$K]
         set BmK [expr $B-$K]
         if {$VmK >= -0.4 && $VmK <=  1.5 && $BmK >= -0.6 && $BmK <=  2.0} { set class 1 }
         if {$VmK >=  2.0 && $VmK <=  8.0 && $BmK >=  3.0 && $BmK <=  7.5} { set class 2 }
         if {$VmK >=  5.5 && $VmK <= 13.0 && $BmK >=  9.0 && $BmK <= 16.0} { set class 3 }
      }

      switch $class {
         2 {
            # Coefficients pour les etoiles geantes et super-geantes (rms error V=12%, B=11%)
            set A_V 0.669
            set B_V 0.223
            set A_B 0.648
            set B_B 0.220
         }
         3 {
            # Coefficients pour les etoiles variables (rms error V=26%, B=20%)
            set A_V 0.789
            set B_V 0.218
            set A_B 0.840
            set B_B 0.211
         }
         default {
            # Coefficients pour les etoiles de la sequence principale (rms error V=2%, B=2%)
            set A_V 0.500
            set B_V 0.264
            set A_B 0.500
            set B_B 0.290
         }
      }

      # Calcul de la taille angulaire a partir de la taille angulaire a magnitude zero
      set angsize_V [expr 10**($A_V + $B_V*($V-$K) -0.2*$V)]
      set angsize_B [expr 10**($A_B + $B_B*($B-$K) -0.2*$B)]

      # Calcul du diametre equivalent en km
      set diam_V [expr tan($angsize_V*$mas2rad) * $D]
      set diam_B [expr tan($angsize_B*$mas2rad) * $D]

      ::console::affiche_resultat  "Diametre angulaire  deduit de B = $angsize_B (mas) \n"
      ::console::affiche_resultat  "Diametre angulaire  deduit de V = $angsize_V (mas) \n"
      ::console::affiche_resultat  "Diametre equivalent deduit de B = $diam_B (km) \n"
      ::console::affiche_resultat  "Diametre equivalent deduit de V = $diam_V (km) \n"

      return [list $angsize_V $diam_V $class]
   }




   proc ::atos_analysis_tools::test_diametre_stellaire {  } {

      set B 11.120
      set V 10.687
      set K 9.478
      set D 1.564791718
      ::atos_analysis_tools::diametre_stellaire $B $V $K $D
   }


}

# 2010-06-05T23:41:22.205
#http://vo.imcce.fr/webservices/miriade/ephemcc_query.php?-name=a:sappho&-type=&-ep=2455928.4870625581&-nbd=5&-step=1d&-tscale=UTC&-observer=@007&-theory=INPOP&-teph=1&-tcoor=1&-mime=text&-output=--jd,--rv&-extrap=0&-from=MiriadeDoc
#O+ | F. Vachier et al     | 23:25:00 | 23:55:00 | M300  | VID | FR | E  02 05 02   | N 48 29 43   |  100 | W  | 6.21 | 23:41:22.02 | 0.08 | 23:41:28.23 | 0.08 | GPS++ |      |      |   |Observation with S. Vaillant/J. Berthier.|;
#O+ | Jean Lecacheux       | 23:33:31 | 23:49:00 | M212  | VID | FR | E  01 29 34.1 | N 48 19 03.5 |  148 | WS | 1.24 | 23:41:27.54 | 0.08 | 23:41:28.78 | 0.04 | GPS++ |      |      |   |;

# arcsec/h
# set dradec -24.7807
# set ddec 14.06
# set dr [expr sqrt($dradec*$dradec+$ddec*$ddec)]
# set arcsec [expr [pi]/(3600.0*180.0)]
# set D [expr 1.564791718 * [ua] ]
# set drkm [expr ($dr*$arcsec*$D)/3600.]
#

