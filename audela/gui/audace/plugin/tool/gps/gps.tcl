#
# Fichier : gps.tcl
# Description : Outil de synchronisation GPS
# Auteur : Jacques MICHELET
# Mise à jour $Id: gps.tcl 12701 2016-01-17 15:00:19Z robertdelmas $
#

namespace eval ::gps {
    variable This
    variable parametres
    variable fenetre

    package provide gps 3.8

    source [file join [file dirname [info script]] gps.cap]

    ##############################################################
    ### AffichageAltitudeGPGGA ###################################
    ##############################################################
    proc AffichageAltitudeGPGGA {ligne} {
        variable position
        variable gps
        variable couleur
        variable fenetre

        # Recuperation des infos dans la ligne
        regexp {([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)} \
        $ligne match type heure lat_brute nord_sud long_brute est_ouest qualite sat hdop altitude unite

        # Recuperation des infos dans la ligne
        if { ([info exists unite]) && ($unite == "M") && ([string is double -strict $altitude]) } {
            set gps(somme_altitude) [expr $gps(somme_altitude) + $altitude]
            incr gps(nombre_altitude)
            set position(altitude) [expr round($gps(somme_altitude) / $gps(nombre_altitude))]
            $fenetre.tableau_bord.trame1.color_invariant_altitude configure -text [format "%d" $position(altitude)] -fg $couleur(donnee,valide)
        } else {
            $fenetre.tableau_bord.trame1.color_invariant_altitude configure -text [format "%d" $position(altitude)] -fg $couleur(donnee,invalide)
        }
    }

    ##############################################################
    ### AffichageAltitudePGRMZ ###################################
    ##############################################################
    proc AffichageAltitudePGRMZ {ligne} {
        variable position
        variable gps
        variable couleur
        variable fenetre

        # Recuperation des infos dans la ligne
        set altitude [string range $ligne 7 end]
        set virgule [string first "," $altitude]
        if {$virgule != 0} {
            set altitude [string range $altitude 0 [expr $virgule - 1]]
            # conversion en metres
            set altitude [expr $altitude/3.2808]
            set gps(somme_altitude) [expr $gps(somme_altitude) + $altitude]
            incr gps(nombre_altitude)
            set position(altitude) [expr round($gps(somme_altitude) / $gps(nombre_altitude))]
            $fenetre.tableau_bord.trame1.color_invariant_altitude configure -text [format "%d" $position(altitude)] -fg $couleur(donnee,valide)
        } else {
            $fenetre.tableau_bord.trame1.color_invariant_altitude configure -text [format "%d" $position(altitude)] -fg $couleur(donnee,invalide)
        }
    }

    ##############################################################
    ### AffichageHeure ###########################################
    ##############################################################
    proc AffichageHeure {ligne temps_pc} {
        variable gps
        variable parametres
        variable couleur
        variable fenetre

        set AAAA_pc [string range $temps_pc 0 3]
        set BB_pc [string range $temps_pc 5 6]
        set JJ_pc [string range $temps_pc 8 9]
        set HH_pc [string range $temps_pc 11 12]
        set MM_pc [string range $temps_pc 14 15]
        set SS_pc [string range $temps_pc 17 18]
        set tt [expr double([clock scan "${AAAA_pc}${BB_pc}${JJ_pc}T${HH_pc}${MM_pc}${SS_pc}"])]
        scan [string range $temps_pc 20 22] "%3d" milli_pc
        set temps_pc [expr $tt + $milli_pc/1000.0]

        # Decodage de la ligne GPS
        regexp {([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)} \
        $ligne match type heure_gps flag lat_brute nord_sud long_brute est_ouest q1 q2 date_gps

        if {([info exists date_gps] > 0) && ([info exists heure_gps] > 0)} {
            set AA_gps [string range $date_gps 4 5]
            set BB_gps [string range $date_gps 2 3]
            set JJ_gps [string range $date_gps 0 1]
            set HH_gps [string range $heure_gps 0 1]
            set MM_gps [string range $heure_gps 2 3]
            set SS_gps [string range $heure_gps 4 5]

            set test 0
            incr test [TestEntier $AA_gps]
            incr test [TestEntier $BB_gps]
            incr test [TestEntier $JJ_gps]
            incr test [TestEntier $HH_gps]
            incr test [TestEntier $MM_gps]
            incr test [TestEntier $SS_gps]
            if {$test == 0} {
                set temps_gps [clock scan "20${AA_gps}${BB_gps}${JJ_gps}T${HH_gps}${MM_gps}${SS_gps}" -base [clock seconds]]

                set delta [expr $temps_gps - $temps_pc]
                set gps(somme_delta) [expr $gps(somme_delta) + $delta]
                incr gps(nombre_delta)
                set moyenne_delta [expr $gps(somme_delta) / $gps(nombre_delta)]
                if {([expr abs($moyenne_delta - $gps(moyenne_precedente))] < [expr $parametres(seuil_ok) / 1000.0]) && ($gps(synchro_position) == 1)} {
                    incr gps(nombre_ok)
                    if {$gps(nombre_ok) >= 10} {set gps(synchro_temps) 1} else {set gps(synchro_temps) 0}
                    if {$gps(nombre_ok) == 10} {bell}
                } else {
                    set gps(nombre_ok) 0
                    set gps(synchro_temps) 0
                }
                set gps(moyenne_precedente) $moyenne_delta

                set gps(correction) [expr ($parametres(decalage) / 1000.0) + $moyenne_delta]

                if {$gps(synchro_temps) == 0} {
                    set aspect $couleur(donnee,invalide)
                } else {
                    set aspect $couleur(donnee,valide)
                }
                $fenetre.tableau_bord.trame1.color_invariant_temps_gps configure -text [format "%s:%s:%s" $HH_gps $MM_gps $SS_gps] -fg $aspect
                $fenetre.tableau_bord.trame1.color_invariant_temps_pc configure -text [format "%s:%s:%s.%s" $HH_pc $MM_pc $SS_pc $milli_pc] -fg $aspect
                $fenetre.tableau_bord.trame1.color_invariant_diff_temps configure -text [format "%9.3f" $delta] -fg $aspect
                $fenetre.tableau_bord.trame1.color_invariant_moyenne configure -text [format "%9.3f" $moyenne_delta] -fg $aspect
                $fenetre.tableau_bord.trame1.color_invariant_etat configure -text [format "%9.3f" [expr $parametres(decalage) / 1000.0]] -fg $aspect
                $fenetre.tableau_bord.trame1.color_invariant_correction configure -text [format "%9.3f" $gps(correction)] -fg $aspect
            }
        }
    }

    ##############################################################
    ### AffichagePosition ########################################
    ##############################################################
    proc AffichagePosition {ligne} {
        variable gps
        variable position
        variable couleur
        variable fenetre

        # Recuperation des infos dans la ligne
        regexp {([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)} $ligne match type heure flag lat_brute nord_sud long_brute est_ouest

        # Verification de la synchro
        if {(![info exists lat_brute]) || (![info exists long_brute]) || (![info exists nord_sud]) || (![info exists est_ouest])} {
            set test 1
        } else {
            set test 0
            incr test [TestFlottant $lat_brute]
            incr test [TestFlottant $long_brute]
            if {[string length $nord_sud] != 1} {incr test}
            if {[string length $est_ouest] != 1} {incr test}
        }

        if {$test != 0} {
            $fenetre.tableau_bord.trame1.color_invariant_latitude configure -text [format "%sd %s' %s\" %s" $position(DD_lat) $position(MM_lat) $position(SS_lat) $position(NS)] -fg $couleur(donnee,invalide)
            $fenetre.tableau_bord.trame1.color_invariant_longitude configure -text [format "%sd %s' %s\" %s" $position(DD_lon) $position(MM_lon) $position(SS_lon) $position(EW)] -fg $couleur(donnee,invalide)
            set gps(synchro_position) 0
        } else {
            scan [string range $lat_brute 0 1] "%2d" position(DD_lat)
            scan [string range $lat_brute 2 3] "%2d" position(MM_lat)
            set position(NS) $nord_sud
            scan [string range $long_brute 0 2] "%3d" position(DD_lon)
            scan [string range $long_brute 3 4] "%2d" position(MM_lon)
            set position(EW) $est_ouest

            # Conversion des secondes (precision du 1/10 de seconde)
            scan [string range $lat_brute 5 end] "%d" ddd
            set l [string length [string range $lat_brute 5 end]]
            set position(SS_lat) [format "%3.1f" [expr $ddd * 60 * 1e-$l]]
            scan [string range $long_brute 6 end] "%d" ddd
            set l [string length [string range $long_brute 6 end]]
            set position(SS_lon) [format "%3.1f" [expr $ddd * 60 * 1e-$l]]

            $fenetre.tableau_bord.trame1.color_invariant_latitude configure -text [format "%sd %s' %s\" %s" $position(DD_lat) $position(MM_lat) $position(SS_lat) $position(NS)] -fg $couleur(donnee,valide)
            $fenetre.tableau_bord.trame1.color_invariant_longitude configure -text [format "%sd %s' %s\" %s" $position(DD_lon) $position(MM_lon) $position(SS_lon) $position(EW)] -fg $couleur(donnee,valide)
            set gps(synchro_position) 1
        }
    }

    ##############################################################
    ### ArretAuto ################################################
    ##############################################################
    proc ArretAuto {} {
        variable This
        variable gps
        variable serie
        global caption

        pack forget $This.fautomatique.fautobis.barret_auto
        pack $This.fautomatique.fautobis.bdemarrage_auto -side top -fill x -padx 3 -pady 3
        update idletasks

        set gps(confirmation_arret) 0
        set gps(demande_arret) 1
        if {$gps(confirmation_arret) != 1} {
            fconfigure $serie -blocking $gps(configuration_serie_blocking)
            fconfigure $serie -mode $gps(configuration_serie_mode)
            fconfigure $serie -buffering $gps(configuration_serie_buffering)
            close $serie
            Message log "%s\n" $caption(gps,fermeture_serie)
            set gps(confirmation_arret) 1
        }

        if {$gps(synchro_temps) == 0} {
            if {$gps(synchro_position) == 0} {
                EtatBouton normal normal disabled disabled disabled normal disabled disabled disabled normal disabled
            } else {
                EtatBouton normal normal disabled disabled normal normal disabled disabled disabled normal disabled
            }
        } else {
            if {$gps(synchro_position) == 0} {
                EtatBouton normal normal disabled normal disabled normal disabled disabled disabled normal disabled
            } else {
                EtatBouton normal normal disabled normal normal normal disabled disabled disabled normal disabled
            }
        }
        Message infos ""
        set gps(etat) repos
        set gps(heure_arret) [clock seconds]
    }

    ##############################################################
    ### ArretGPS #################################################
    ##############################################################
    proc ArretGPS {} {
        variable This
        variable fenetre
        variable gps
        variable serie
        global caption

        pack forget $This.fmanuel.fgps.barret_gps
        pack $This.fmanuel.fgps.blancement_gps -side top -fill x -padx 3 -pady 3
        update idletasks

        set gps(confirmation_arret) 0
        set gps(demande_arret) 1
        if {$gps(confirmation_arret) != 1} {
            fconfigure $serie -blocking $gps(configuration_serie_blocking)
            fconfigure $serie -mode $gps(configuration_serie_mode)
            fconfigure $serie -buffering $gps(configuration_serie_buffering)
            close $serie
            Message consolog "%s\n" $caption(gps,fermeture_serie)
            set gps(confirmation_arret) 1
        }

        if {$gps(synchro_temps) == 0} {
            if {$gps(synchro_position) == 0} {
                EtatBouton normal normal disabled disabled disabled normal disabled disabled disabled normal disabled
            } else {
                EtatBouton normal normal disabled disabled normal normal disabled disabled disabled normal disabled
            }
        } else {
            if {$gps(synchro_position) == 0} {
                EtatBouton normal normal disabled normal disabled normal disabled disabled disabled normal disabled
            } else {
                EtatBouton normal normal disabled normal normal normal disabled disabled disabled normal disabled
            }
        }
        destroy $fenetre.tableau_bord
        Message infos ""
        set gps(etat) repos
        set gps(heure_arret) [clock seconds]
    }

    ##############################################################
    ### ArretHorloge #############################################
    ##############################################################
    proc ArretHorloge {} {
        variable This
        variable horloge
        global caption

        set horloge(confirmation_arret) 0
        set horloge(demande_arret) 1

        pack forget $This.fmanuel.freg.barret_horloge
        pack $This.fmanuel.freg.becoute_horloge -side top -fill x -padx 3 -pady 3
        update idletasks

        bind all <Key-Prior> {}
        bind all <Key-Next> {}

        EtatBouton normal normal disabled disabled disabled normal disabled disabled disabled normal disabled
        vwait ::gps::horloge(confirmation_arret)
        Message infos ""
        Message consolog "%s %d ms\n" $caption(gps,decalage_horloge) $horloge(decalage_total)
        set gps(etat) repos
    }

    ##############################################################
    ### AvanceHorloge ############################################
    ##############################################################
    proc AvanceHorloge {} {
        variable parametres
        variable horloge

        jm_reglageheurepc [expr $parametres(reglage) + $parametres(temps_minimal)]
        incr horloge(decalage_total) $parametres(reglage)
        incr parametres(decalage) $parametres(reglage)
    }

    ##############################################################
    ### BoucleBip ################################################
    ##############################################################
    proc BoucleBip {} {
        variable horloge

        set bip 0
        while {$bip == 0} {
            set temps_pc [jm_heurepc]
            if {[string index $temps_pc 20] == "0"} {
                if {$horloge(demande_arret) != 1} {bell}
                set bip 1
            }
        }
        set heure_pc [string range $temps_pc 11 end]
        Message infos "%s:%s:%s.%s" [string range $heure_pc 0 1] [string range $heure_pc 3 4] [string range $heure_pc 6 7] [string range $heure_pc 9 end]
        if {$horloge(demande_arret) != 1} {
            after 950 ::gps::BoucleBip
        } else {
            set horloge(confirmation_arret) 1
        }
    }

    ##############################################################
    ### Calibration ##############################################
    ##############################################################
    proc Calibration {} {
        global caption

        set temps [time {jm_reglageheurepc 0} 10]
        set micro [string first "micro" $temps]
        set milli [expr [string range $temps 0 [expr $micro - 2]] / 1000]
        if {$milli < 0} {
            return [expr -$milli]
        } else {
            return $milli
        }
    }

    ##############################################################
    ### createPanel ##############################################
    ##############################################################
    proc createPanel {this} {
        global caption conf color
        variable This
        variable parametres
        variable couleur
        variable gps

        if {[catch {load libjm[info sharedlibextension]} chargement_lib]} {
            Message console "%s\n" $chargement_lib
            return 1
        }

        if {[catch {jm_versionlib} version_lib]} {
            Message console "%s\n" $caption(gps,mauvaise_version)
            return 1
        } else {
            if {[expr double([string range $version_lib 0 2])] < 3.0} {
                Message console "%s\n" $caption(gps,mauvaise_version)
                return 1
            }
        }

        set This $this

        set couleur(donnee,invalide) $color(red)
        set couleur(donnee,valide) $color(green)
        set couleur(fond,entree) $color(black)

        CreationPanneauGPS $This

        # Pour le stockage des fichiers d'initialisation et de traces
        set gps_home $::audace(rep_home)
        set gps(fichier_ini) [ file join $gps_home gps.ini ]
        set gps_home_log $::audace(rep_log)
        set gps(fichier_log) [ file join $gps_home_log gps.log ]
    }

    ##############################################################
    ### CreationFenetreGPS #######################################
    ##############################################################
    proc CreationFenetreGPS {} {
        global conf
        global caption
        variable couleur
        variable position
        variable fenetre

        #  Affichage de la fenetre, et des champs de saisie avec les valeurs par   #
        #   defaut.                                                             #
        set tb [toplevel $fenetre.tableau_bord -borderwidth 2 -relief groove]
        wm geometry $tb +150+50
        wm title $tb $caption(gps,titre_fenetre_gps)
        wm transient $tb $fenetre
        wm protocol $tb WM_DELETE_WINDOW ::gps::Suppression

        # Trame des champs heure
        frame $tb.trame1
        frame $tb.trame1.temps

        set valeur_defaut(temps_gps) ""
        set valeur_defaut(temps_pc) ""
        set valeur_defaut(diff_temps) ""
        set valeur_defaut(moyenne) ""
        set valeur_defaut(ecart_type) ""
        set valeur_defaut(etat) ""
        set valeur_defaut(correction) ""
        set valeur_defaut(latitude) [format "%sd %s' %s\" %s" $position(DD_lat) $position(MM_lat) $position(SS_lat) $position(NS)]
        set valeur_defaut(longitude) [format "%sd %s' %s\" %s" $position(DD_lon) $position(MM_lon) $position(SS_lon) $position(EW)]
        set valeur_defaut(altitude) $position(altitude)

        set apparence(temps_gps) w
        set apparence(temps_pc) w
        set apparence(diff_temps) e
        set apparence(moyenne) e
        set apparence(ecart_type) e
        set apparence(etat) e
        set apparence(correction) e
        set apparence(latitude) e
        set apparence(longitude) e
        set apparence(altitude) w

        foreach champ {temps_gps temps_pc diff_temps moyenne etat correction latitude longitude altitude} {
            label $tb.trame1.l$champ \
                -text $caption(gps,$champ)
            label $tb.trame1.color_invariant_$champ \
                -text $valeur_defaut($champ) \
                -bg $couleur(fond,entree) \
                -fg $couleur(donnee,invalide) \
                -relief sunken \
                -anchor $apparence($champ)
            grid $tb.trame1.l$champ $tb.trame1.color_invariant_$champ \
                -sticky news
        }
        ::pack $tb.trame1 \
            -fill x \
            -side left

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $tb
        update idletask
    }

    ##############################################################
    ### CreationPanneauGPS #######################################
    ##############################################################
    proc CreationPanneauGPS {This} {
        global caption
        variable couleur
        variable parametres

        # Partie graphique
        frame $This \
            -borderwidth 2 \
            -relief groove
        #--- Frame du titre
        frame $This.fra1 \
            -borderwidth 2 \
            -relief groove
        # Bouton du titre
        Button $This.fra1.but \
            -borderwidth 2 \
            -text "$caption(gps,help,titre1)\n$caption(gps,titre1)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::gps::getPluginType ] ] \
                [ ::gps::getPluginDirectory ] [ ::gps::getPluginHelp ]"
        ::pack $This.fra1.but \
            -in $This.fra1 \
            -anchor center \
            -expand 1 \
            -fill both \
            -side top
        DynamicHelp::add $This.fra1.but \
            -text $caption(gps,help,titre)
        pack $This.fra1 \
            -side top \
            -fill x

        #Trame d'affichage des parametres
        # Construction de la trame
        set t1 [frame $This.fparametre \
            -borderwidth 1 \
            -relief groove]
        # Definition des menus
        menubutton $t1.mb \
            -text $caption(gps,parametre) \
            -menu $t1.mb.menu \
            -height 1 \
            -relief raised
        ::pack $t1.mb \
            -in $t1 \
            -pady 4
        set m1 [menu $t1.mb.menu \
            -tearoff 0]
        # Menus et sous-menus
        $m1 add separator
        $m1 add cascade \
            -label $caption(gps,port) \
            -menu $m1.sm1
        $m1 add cascade \
            -label $caption(gps,baud) \
            -menu $m1.sm3
        $m1 add cascade \
            -label $caption(gps,intervalle_synchro) \
            -menu $m1.sm2
        $m1 add command \
            -label $caption(gps,divers) \
            -command {::gps::EditionsDiverses}
        set sm1 [menu $m1.sm1 \
            -tearoff 0]
        set sm2 [menu $m1.sm2 \
            -tearoff 0]
        set sm3 [menu $m1.sm3 \
           -tearoff 0]
        # Les sous-menus des ports et des intervalles de synchro sont crees plus tard pour tenir compte des parametres initialises ulterieurement
        # Positionnement de la trame
        pack $t1 \
            -side top \
            -fill x \
            -padx 3 \
            -pady 3

        #Trame Commande Manuel (t2)
        set t2 [frame $This.fmanuel \
            -borderwidth 1 \
            -relief groove]
        label $t2.l \
            -text $caption(gps,manuel)
        ::pack $t2.l \
            -fill x \
            -side top

        #Trame du GPS (t21)
        set t21 [frame $t2.fgps \
            -borderwidth 1 \
            -relief groove]
        label $t21.l \
            -text $caption(gps,titre_gps)
        ::pack $t21.l \
            -fill x \
            -side top
        # Generation des boutons
        set commande(lancement_gps) ::gps::LancementGPS
        set commande(arret_gps) ::gps::ArretGPS
        set commande(synchro_temps) ::gps::SynchroTempsGPS
        set commande(synchro_position) ::gps::SynchroPositionGPS

        foreach champ {synchro_position synchro_temps arret_gps lancement_gps} {
            button $t21.b$champ \
                -text $caption(gps,$champ) \
                -command $commande($champ)
            pack $t21.b$champ \
                -in $t21 \
                -pady 2 \
                -side bottom
        }
        pack $t21 \
            -side top \
            -fill x \
            -padx 3 \
            -pady 3
        pack forget $t21.barret_gps

        # Trame du reglage fin (t22)
        set t22 [frame $t2.freg \
            -borderwidth 1 \
            -relief groove]
        label $t22.l \
            -text $caption(gps,titre_reglage_fin)
        ::pack $t22.l \
            -fill x \
            -side top
        set commande(ecoute_horloge) ::gps::EcouteHorloge
        set commande(arret_horloge) ::gps::ArretHorloge
        set commande(avance) {::gps::AvanceHorloge}
        set commande(retard) {::gps::RetardHorloge }
        foreach champ {retard avance arret_horloge ecoute_horloge} {
            button $t22.b$champ \
                -text $caption(gps,$champ) \
                -command $commande($champ)
            pack $t22.b$champ \
                -in $t22 \
                -pady 2 \
                -side bottom
        }
        pack $t22 \
            -side top \
            -fill x \
            -padx 3 \
            -pady 3
        pack forget $t22.barret_horloge

        pack $t2 \
            -side top \
            -fill x \
            -padx 3 \
            -pady 3

        #Trame Commande Automatique (t3)
        set t3 [frame $This.fautomatique \
            -borderwidth 1 \
            -relief groove]
        label $t3.l \
            -text $caption(gps,automatique)
        ::pack $t3.l \
            -fill x \
            -side top

        set t31 [frame $t3.fautobis \
            -borderwidth 1 \
            -relief groove]
        set commande(demarrage_auto) ::gps::DemarrageAuto
        set commande(arret_auto) ::gps::ArretAuto
        foreach champ {demarrage_auto arret_auto} {
            button $t31.b$champ \
                -text $caption(gps,$champ) \
                -command $commande($champ)
            pack $t31.b$champ \
                -in $t31 \
                -pady 2
        }
        pack $t31 \
            -side top \
            -fill x \
            -padx 3 \
            -pady 3
        pack forget $t31.barret_auto

        pack $t3 \
            -side top \
            -fill x \
            -padx 3 \
            -pady 3

        # Etats d'activation des boutons
        EtatBouton normal normal disabled disabled disabled normal disabled disabled disabled normal disabled

        # Trame des infos (couleurs fixes)
        set t4 [frame $This.finfos \
            -borderwidth 1 \
            -relief groove]
        label $t4.color_invariant \
            -bg $couleur(fond,entree) \
            -fg $couleur(donnee,valide)
        ::pack $t4.color_invariant \
            -fill both \
            -side top
        pack $t4 \
            -side top \
            -fill x \
            -padx 3 \
            -pady 3

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $This
    }

    ##############################################################
    ### ConfigureSerie ###########################################
    ##############################################################
    proc ConfigureSerie {} {
        global caption
        variable parametres
        variable gps

        if {[catch {open $parametres(port_serie) r+} serie]} {
            tk_messageBox \
                -type ok \
                -message $caption(gps,conseil_serie) \
                -title $caption(gps,erreur) \
                -icon error
            return 0
        }

        # Sauvegarde de la configuration du port serie
        if {[catch {fconfigure $serie -blocking} confserie]} {
            tk_messageBox \
                -type ok \
                -message $caption(gps,non_rs232) \
                -title $caption(gps,erreur) \
                -icon error
            return 0
        } else {
            set gps(configuration_serie_blocking) $confserie
        }

        if {[catch {fconfigure $serie -mode} confserie]} {
            tk_messageBox \
                -type ok \
                -message $caption(gps,non_rs232) \
                -title $caption(gps,erreur) \
                -icon error
            return 0
        } else {
            set gps(configuration_serie_mode) $confserie
        }

        if {[catch {fconfigure $serie -buffering} confserie]} {
            tk_messageBox \
                -type ok \
                -message $caption(gps,non_rs232) \
                -title $caption(gps,erreur) \
                -icon error
            return 0
        } else {
            set gps(configuration_serie_buffering) $confserie
        }
        return $serie
    }

    ##############################################################
    ### DemarrageAuto ############################################
    ##############################################################
    proc DemarrageAuto {} {
        global caption
        global gps_reveil_synchro
        variable This
        variable parametres
        variable serie
        variable gps
        variable test

        set serie [ConfigureSerie]
        if {$serie == 0} {return}

        set gps(etat) automatique

        pack forget $This.fautomatique.fautobis.bdemarrage_auto
        pack $This.fautomatique.fautobis.barret_auto -side top -fill x -padx 3 -pady 3
        update idletasks

        EtatBouton disabled disabled disabled disabled disabled disabled disabled disabled disabled disabled normal

        set gps(nombre_delta) 0
        set gps(somme_delta) 0
        set gps(nombre_ok) 0
        set gps(nombre_echec) 0
        set gps(moyenne_precedente) 0
        set gps(somme_altitude) 0.0
        set gps(nombre_altitude) 0
        set gps(synchro_temps) 0
        set gps(synchro_position) 0
        set gps(demande_arret) 0

        set gps(message_GPRMC) "\$GPRMC"
        set gps(message_PGRMZ) "\$PGRMZ"
        set gps(message_GPGGA) "\$GPGGA"

        Message infos $caption(gps,attente_nmea)
        Message log "%s %s\n" $caption(gps,ouverture_serie) $parametres(port_serie)

        # Sauvegarde de la configuration du port serie
        set gps(configuration_serie_blocking) [fconfigure $serie -blocking]
        set gps(configuration_serie_mode) [fconfigure $serie -mode]
        set gps(configuration_serie_buffering) [fconfigure $serie -buffering]

        # Changement de vitesse
        fconfigure $serie -mode "$parametres(baud),n,8,1" -translation auto
        set gps(erreur_lecture) 0
        set gps_reveil_synchro 0
        # Gestion de la liaison serie par filevent
        fileevent $serie readable [list ::gps::TraitementLigneMuet $serie]

        # Debut de la boucle de synchro automatique
        SynchronisationAutomatique
    }

    ##############################################################
    ### EcouteHorloge ############################################
    ##############################################################
    proc EcouteHorloge {} {
        global caption
        variable This
        variable horloge

        # On cherche a savoir si l'utilisateur a les droits suffisants pour modifier l'horloge systeme
        set erreur [catch {set temps [time {jm_reglageheurepc 0} 10] } resultat ]
        if { $erreur } {
            tk_messageBox -title $caption(gps,ecoute_horloge) -type ok -icon error -message $caption(gps,droit_acces)
        } else {
            set gps(etat) horloge

            pack forget $This.fmanuel.freg.becoute_horloge
            pack $This.fmanuel.freg.barret_horloge -side top -fill x -padx 3 -pady 3
            update idletasks
            EtatBouton disabled disabled disabled disabled disabled disabled normal normal normal disabled disabled

            bind all <Key-Prior> {::gps::AvanceHorloge}
            bind all <Key-Next> {::gps::RetardHorloge}

            set horloge(demande_arret) 0
            set horloge(decalage_total) 0
            update idletasks
            # Calibration
            set parametres(temps_minimal) [Calibration]

            BoucleBip
        }
    }

    ##############################################################
    ### EditionsDiverses #########################################
    ##############################################################
    proc EditionsDiverses {} {
        variable parametres
        global caption
        variable fenetre

        set d [toplevel $fenetre.divers -borderwidth 2 -relief groove]
        wm geometry $d +150+50
        wm title $d $caption(gps,titre_parametres)
        wm transient $d $fenetre
        wm protocol $d WM_DELETE_WINDOW ::gps::Suppression

        set t1 [frame $d.trame1]
        foreach champ {decalage seuil_ok reglage} {
            label $t1.l$champ \
                -text $caption(gps,$champ)
            entry $t1.e$champ \
                -textvariable ::gps::parametres($champ) \
                -relief sunken \
                -width 4
            grid $t1.l$champ $t1.e$champ \
                -sticky news
        }

        set t2 [frame $d.trame2 \
            -borderwidth 2 \
            -relief groove]
        button $t2.b1 \
            -text $caption(gps,valider) \
            -command {::gps::ValideSaisie} \
            -height 1
        ::pack $t2.b1 \
            -side top \
            -padx 10 \
            -pady 10

        ::pack $t1 $t2 \
            -fill x

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $d
    }

    ##############################################################
    ### EtatBoutons ##############################################
    ##############################################################
    proc EtatBouton {e0 e1 e2 e3 e4 e5 e6 e7 e8 e9 e10} {
        variable This

        $This.fparametre.mb configure -state $e0
        $This.fmanuel.fgps.blancement_gps configure -state $e1
        $This.fmanuel.fgps.barret_gps configure -state $e2
        $This.fmanuel.fgps.bsynchro_temps configure -state $e3
        $This.fmanuel.fgps.bsynchro_position configure -state $e4
        $This.fmanuel.freg.becoute_horloge configure -state $e5
        $This.fmanuel.freg.barret_horloge configure -state $e6
        $This.fmanuel.freg.bavance configure -state $e7
        $This.fmanuel.freg.bretard configure -state $e8
        $This.fautomatique.fautobis.bdemarrage_auto configure -state $e9
        $This.fautomatique.fautobis.barret_auto configure -state $e10
    }

    ##############################################################
    ### getPluginTitle ###########################################
    ##############################################################
    proc getPluginTitle { } {
        global caption

        return "$caption(gps,titre)"
    }

    ##############################################################
    ### getPluginHelp ############################################
    ##############################################################
    proc getPluginHelp { } {
        return "gps.htm"
    }

    ##############################################################
    ### getPluginType ############################################
    ##############################################################
    proc getPluginType { } {
        return "tool"
    }

    ##############################################################
    ### getPluginDirectory #######################################
    ##############################################################
    proc getPluginDirectory { } {
        return "gps"
    }

    ##############################################################
    ### getPluginOS ##############################################
    ##############################################################
    proc getPluginOS { } {
        return [ list Windows Linux Darwin ]
    }

    ##############################################################
    ### getPluginProperty ########################################
    ##############################################################
    proc getPluginProperty { propertyName } {
        switch $propertyName {
            function     { return "setup" }
            subfunction1 { return "gps" }
            display      { return "panel" }
        }
    }

    ##############################################################
    ### createPluginInstance #####################################
    ##############################################################
    proc createPluginInstance { base { visuNo 1 } } {
        variable fenetre

        set fenetre $base
        createPanel $base.gps
        return $base.gps
    }

    ##############################################################
    ### deletePluginInstance #####################################
    ##############################################################
    proc deletePluginInstance { visuNo } {

    }

    ##############################################################
    ### Initialisation ###########################################
    ##############################################################
    proc Initialisation {This} {
        global conf
        global caption
        variable position
        variable parametres
        variable gps

        if {[info exists gps(etat)]} {
            if {$gps(etat) == "automatique"} {return}
        }

        # Recuperation des informations de position
        set d [string first "d" $conf(posobs,lat)]
        set m [string first "m" $conf(posobs,lat)]
        set s [string first "s" $conf(posobs,lat)]
        if {[expr $d * $m * $s] <= 0} {
            # il manque un champ
            set position(DD_lat) 45
            set position(MM_lat) 0
            set position(SS_lat) 0
        } else {
            set position(DD_lat) [string range $conf(posobs,lat) 0 [expr $d - 1]]
            set position(MM_lat) [string range $conf(posobs,lat) [expr $d + 1] [expr $m - 1]]
            set position(SS_lat) [string range $conf(posobs,lat) [expr $m + 1] [expr $s - 1]]
        }
        set position(NS) $conf(posobs,nordsud)

        set d [string first "d" $conf(posobs,long)]
        set m [string first "m" $conf(posobs,long)]
        set s [string first "s" $conf(posobs,long)]
        if {[expr $d * $m * $s] <= 0} {
            set position(DD_lon) 0
            set position(MM_lon) 0
            set position(SS_lon) 0
        } else {
            set position(DD_lon) [string range $conf(posobs,long) 0 [expr $d - 1]]
            set position(MM_lon) [string range $conf(posobs,long) [expr $d + 1] [expr $m - 1]]
            set position(SS_lon) [string range $conf(posobs,long) [expr $m + 1] [expr $s - 1]]
        }

        set position(EW) $conf(posobs,estouest)
        set position(altitude) $conf(posobs,altitude)

        # Ouverture du fichier de parametres
        if { [ file exists $gps(fichier_ini) ] } {
            source $gps(fichier_ini)
        }
        if {![info exists parametres(os)]}         {set parametres(os)         $::tcl_platform(os)}
        if {![info exists parametres(port_serie)]} {set parametres(port_serie) [lindex [ ::serialport::getPorts ] 0]}
        if {![info exists parametres(baud)]}       {set parametres(baud)       4800}
        # Cas du changement d'OS
        if {$parametres(os) != $::tcl_platform(os)}        {set parametres(port_serie)         [lindex [ ::serialport::getPorts ] 0]}
        if {![info exists parametres(seuil_ok)]}           {set parametres(seuil_ok)           20}
        if {![info exists parametres(decalage)]}           {set parametres(decalage)           0}
        if {![info exists parametres(reglage)]}            {set parametres(reglage)            100}
        if {![info exists parametres(temps_minimal)]}      {set parametres(temps_minimal)      55}
        if {![info exists parametres(mise_heure)]}         {set parametres(mise_heure)         [clock seconds]}
        if {![info exists parametres(choix_synchro)]}      {set parametres(choix_synchro)      [list 60 120 300 600 1800 3600 7200]}
        if {![info exists parametres(intervalle_synchro)]} {set parametres(intervalle_synchro) [lindex $parametres(choix_synchro) 0]}

        # Sous-menu des ports
        foreach port [ ::serialport::getPorts ] {
            $This.fparametre.mb.menu.sm1 add radio -label $port -variable ::gps::parametres(port_serie) -value $port
        }
        # Sous-menu des baud
        foreach baud [ list 4800 9600 ] {
            $This.fparametre.mb.menu.sm3 add radio -label $baud -variable ::gps::parametres(baud) -value $baud
        }
        # Sous-menu des intervalles de synchro
        foreach intervalle $parametres(choix_synchro) {
            $This.fparametre.mb.menu.sm2 add radio -label $intervalle -variable ::gps::parametres(intervalle_synchro) -value $intervalle
        }

        Message consolog "---------- %s %s ----------\n" $caption(gps,bienvenue) [ package version gps ]
        Message consolog "%s\n" $caption(gps,copyright)
        set gps(etat) repos
    }

    ##############################################################
    ### LancementGPS #############################################
    ##############################################################
    proc LancementGPS {} {
        global caption
        variable This
        variable parametres
        variable serie
        variable gps
        variable test

        set serie [ConfigureSerie]
        if {$serie == 0} {return}

        set gps(etat) gps

        pack forget $This.fmanuel.fgps.blancement_gps
        pack $This.fmanuel.fgps.barret_gps -side top -fill x -padx 3 -pady 3
        update idletasks

        EtatBouton disabled disabled normal disabled disabled disabled disabled disabled disabled disabled disabled

        CreationFenetreGPS

        set gps(nombre_delta) 0
        set gps(somme_delta) 0
        set gps(nombre_ok) 0
        set gps(moyenne_precedente) 0
        set gps(somme_altitude) 0.0
        set gps(nombre_altitude) 0
        set gps(synchro_temps) 0
        set gps(synchro_position) 0
        set gps(demande_arret) 0

        set gps(message_GPRMC) "\$GPRMC"
        set gps(message_PGRMZ) "\$PGRMZ"
        set gps(message_GPGGA) "\$GPGGA"

        Message infos $caption(gps,attente_nmea)
        Message consolog "%s %s\n" $caption(gps,ouverture_serie) $parametres(port_serie)

        # Changement de vitesse
        fconfigure $serie -mode "$parametres(baud),n,8,1" -translation auto
        set gps(erreur_lecture) 0

        # Gestion par filevent
        fileevent $serie readable [list ::gps::TraitementLigne $serie]
    }

    ##############################################################
    ### Message ##################################################
    ##############################################################
    proc Message {niveau args} {
        global audace
        variable This
        variable gps

        switch -exact -- $niveau {
            console {
                ::console::disp [eval [concat {format} $args]]
                update idletasks
            }
            test {
                ::console::disp "Test : "
                ::console::disp [eval [concat {format} $args]]
            }
            infos {
                $This.finfos.color_invariant configure -text [eval [concat {format} $args]]
                update idletasks
            }
            consolog {
                ::console::disp [eval [concat {format} $args]]
                if [catch {open $gps(fichier_log) a} fichier] {
                    ::console::disp $fichier
                    ::console::disp "\n"
                } else {
                    puts -nonewline $fichier $audace(tu,format,dmyhmsint)
                    puts -nonewline $fichier "  "
                    puts -nonewline $fichier [eval [concat {format} $args]]
                    close $fichier
                }
                update idletasks
            }
            log {
                if [catch {open $gps(fichier_log) a} fichier] {
                    ::console::disp $fichier
                    ::console::disp "\n"
                } else {
                    puts -nonewline $fichier $audace(tu,format,dmyhmsint)
                    puts -nonewline $fichier "  "
                    puts -nonewline $fichier [eval [concat {format} $args]]
                    close $fichier
                }
                update idletasks
            }
            erreur {
                ::console::affiche_erreur [eval [concat {format} $args]]
                update idletasks
            }
            default {
                ::console::disp "Erreur dans la gestion des messages\n"
            }
        }
    }

    ##############################################################
    ### startTool ################################################
    ##############################################################
    proc startTool { visuNo } {
       variable This

        Initialisation $This
    }

    ##############################################################
    ### RetardHorloge ############################################
    ##############################################################
    proc RetardHorloge {} {
        variable parametres
        variable horloge

        jm_reglageheurepc [expr -$parametres(reglage) + $parametres(temps_minimal)]
        incr horloge(decalage_total) [expr -$parametres(reglage)]
        incr parametres(decalage) [expr -$parametres(reglage)]
    }

    ##############################################################
    ### Suppression ##############################################
    ##############################################################
    proc Suppression {} {
        # Empeche certaines fenetres d'etre effacees
    }

    ##############################################################
    ### SynchronisationAutomatique ###############################
    ##############################################################
    proc SynchronisationAutomatique {} {
        global caption
        global gps_synchro_temps
        global gps_reveil_synchro
        variable gps
        variable parametres

        while {$gps(demande_arret) == 0} {
            Message log "Recherche synchro\n"
            set gps(temps_synchro) 0
            set gps(nombre_ok) 0
            set gps(nombre_delta) 0
            set gps(nombre_echec) 0
            set gps(somme_delta) 0.0
            # Attente de ce que l'ecart t_gps - t_pc se stabilise ou bien
            # que la synchro ne s'est pas faite
            set heure_debut_synchro [clock seconds]
            set gps_synchro_temps 0
            vwait gps_synchro_temps

            if {$gps(synchro_temps) == 1} {
                # La synchro s'est faite

                # Mise a l'heure du PC
                # Le GPS est synchrone du PC, reste a le recaler
                set corr_milli [expr round($gps(correction) * 1000)]
                if {[catch {jm_reglageheurepc $corr_milli} reglage]} {
                    Message erreur "%s\n" $caption(gps,droit_acces)
                } else {
                    set message [concat $caption(gps,m_synchro_temps_1) [format "%9.3f" $gps(correction)] $caption(gps,m_synchro_temps_2)]
                    Message log "%s\n" $message
                    set gps(heure_arret) [clock seconds]

                    # Calcul de la derive
                    set diff_temps [expr $gps(heure_arret) - $parametres(mise_heure)]
                    set derive [expr 3600000.0 * $gps(correction) / $diff_temps]
                    set message [concat $caption(gps,derive) [format "%9.3f" $derive] " ms/h"]
                    Message log "%s\n" $message
                    set parametres(mise_heure) [clock seconds]

                    # Calcul du temps qu'a requis la synchro qui sera deduit du temps
                    #  a attendre pour le reveil
                    set heure_fin_synchro [clock seconds]
                    set temps_requis_synchro [expr $heure_fin_synchro - $heure_debut_synchro]
                    # Attente de la phase de reveil
                    set gps(temps_synchro) [expr $gps(temps_gps) + $parametres(intervalle_synchro) - $temps_requis_synchro]
                }
                set gps_reveil_synchro 0
                vwait gps_reveil_synchro
            } else {
                # La synchro ne s'est pas faite
                Message consolog "%s\n" $caption(gps,pas_synchro)
            }
        }

    }

    ##############################################################
    ### SynchroPositionGPS #######################################
    ##############################################################
    proc SynchroPositionGPS {} {
        variable position
        global conf
        global caption
        global audace

        # Fermeture de la fenetre Position de l'observateur si elle est ouverte
        if { [ winfo exists .audace.confPosObs ] } {
            destroy .audace.confPosObs
        }

        # Mise a jour des champs de configuration de la Position de l'observateur
        set conf(posobs,lat)      $position(DD_lat)
        append conf(posobs,lat)   "d" $position(MM_lat) "m" $position(SS_lat) "s"
        set conf(posobs,nordsud)  $position(NS)
        set conf(posobs,long)     $position(DD_lon)
        append conf(posobs,long)  "d" $position(MM_lon) "m" $position(SS_lon) "s"
        set conf(posobs,estouest) $position(EW)
        set conf(posobs,altitude) $position(altitude)

        # Mise a jour du format GPS
        set SDD_lat $position(DD_lat)
        if {$position(NS) == "S"} {
            set SDD_lat -$SDD_lat
        }
        set conf(posobs,observateur,gps) "GPS [string trimleft [mc_angle2deg [list $position(DD_lon) $position(MM_lon) $position(SS_lon)]] " "] $position(EW) [string trimleft [mc_angle2deg [list $SDD_lat $position(MM_lat) $position(SS_lat)]] " "] $position(altitude)"
        set audace(posobs,observateur,gps) $conf(posobs,observateur,gps)

        Message consolog "%s\n" $caption(gps,m_synchro_position_1)
        set message "\t"
        append message $caption(gps,m_synchro_position_2)
        append message [format " %2dd %2d' %3.1f\" %s" $position(DD_lat) $position(MM_lat) $position(SS_lat) $position(NS)]
        Message consolog "%s\n" $message
        set message "\t"
        append message $caption(gps,m_synchro_position_3)
        append message [format "%3dd %2d' %3.1f\" %s" $position(DD_lon) $position(MM_lon) $position(SS_lon) $position(EW)]
        Message consolog "%s\n" $message
        set message "\t"
        append message $caption(gps,m_synchro_position_4)
        append message [format "%3d m" $position(altitude)]
        Message consolog "%s\n" $message
        bell
    }

    ##############################################################
    ### SynchroTempsGPS ##########################################
    ##############################################################
    proc SynchroTempsGPS {} {
        variable gps
        variable parametres
        variable This
        global caption

        if {$gps(synchro_temps) == 1} {
            set corr_milli [expr round($gps(correction) * 1000)]
            if {[catch {jm_reglageheurepc $corr_milli} reglage]} {
                tk_messageBox -type ok -icon error -message $caption(gps,droit_acces)
            } else {
                set gps(synchro_temps) 0
                $This.fmanuel.fgps.bsynchro_temps configure -state disabled
                set message [concat $caption(gps,m_synchro_temps_1) [format "%9.3f" $gps(correction)] $caption(gps,m_synchro_temps_2)]
                Message consolog "%s\n" $message
                bell

                # Calcul de la derive
                set diff_temps [expr $gps(heure_arret) - $parametres(mise_heure)]
                set derive [expr 3600000.0 * $gps(correction) / $diff_temps]
                set message [concat $caption(gps,derive) [format "%9.3f" $derive] " ms/h"]
                Message consolog "%s\n" $message
                set parametres(mise_heure) [clock seconds]
            }
        }
    }

    ##############################################################
    ### Terminaison ##############################################
    ##############################################################
    proc Terminaison {This} {
        global caption
        variable parametres
        variable gps

        if {$gps(etat) == "automatique"} {return}
        if {$gps(etat) == "gps"} {ArretGPS}
        if {$gps(etat) == "horloge"} {ArretHorloge}

        Message consolog "---------- %s -------------\n\n" $caption(gps,tchao)

        # Sauvegarde des parametres
        if [catch {open $gps(fichier_ini) w} fichier] {
            Message console "%s\n" $fichier
        } else {
            foreach {a b} [array get parametres] {
                puts $fichier "set parametres($a) \"$b\""
            }
            close $fichier
        }

        # Suppression des sous-menus
        $This.fparametre.mb.menu.sm1 delete 0 end
        $This.fparametre.mb.menu.sm2 delete 0 end
        $This.fparametre.mb.menu.sm3 delete 0 end
    }

    ##############################################################
    ### TestEntier ###############################################
    ##############################################################
    proc TestEntier {valeur} {
        set test 0
        if {[string length $valeur] != 0} {
            for {set i 0} {$i < [string length $valeur]} {incr i} {
                set a [string index $valeur $i]
                if {![string match {[0-9]} $a]} {
                    set test 1
                }
            }
        } else {
            set test 1
        }
        return $test
    }

    ##############################################################
    ### TestFlottant #############################################
    ##############################################################
    proc TestFlottant {valeur} {
        # Envisager de le remplacer par [string is double]
        # Retourne 0 si c'est un entier, 1 dans le cas contraire
        set test 0
        if {[string length $valeur] != 0} {
            for {set i 0} {$i < [string length $valeur]} {incr i} {
                set a [string index $valeur $i]
                if {![string match {[0-9.]} $a]} {
                    set test 1
                }
            }
        } else {
            set test 1
        }
        return $test
    }

    ##############################################################
    ### TraitementHeure ##########################################
    ##############################################################
    proc TraitementHeure {ligne temps_pc} {
        global gps_synchro_temps
        global gps_reveil_synchro
        variable gps
        variable parametres

#       Message console "T_PC=%s\n" $temps_pc
        set AAAA_pc [string range $temps_pc 0 3]
        set BB_pc [string range $temps_pc 5 6]
        set JJ_pc [string range $temps_pc 8 9]
        set HH_pc [string range $temps_pc 11 12]
        set MM_pc [string range $temps_pc 14 15]
        set SS_pc [string range $temps_pc 17 18]
        set tt [expr double([clock scan "${AAAA_pc}${BB_pc}${JJ_pc}T${HH_pc}${MM_pc}${SS_pc}"])]
        scan [string range $temps_pc 20 22] "%3d" milli_pc
        set temps_pc [expr $tt + $milli_pc/1000.0]

        # Decodage de la ligne GPS
        regexp {([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)} \
        $ligne match type heure_gps flag lat_brute nord_sud long_brute est_ouest q1 q2 date_gps

        if {([info exists date_gps] > 0) && ([info exists heure_gps] > 0)} {
            set AA_gps [string range $date_gps 4 5]
            set BB_gps [string range $date_gps 2 3]
            set JJ_gps [string range $date_gps 0 1]
            set HH_gps [string range $heure_gps 0 1]
            set MM_gps [string range $heure_gps 2 3]
            set SS_gps [string range $heure_gps 4 5]

            set test 0
            incr test [TestEntier $AA_gps]
            incr test [TestEntier $BB_gps]
            incr test [TestEntier $JJ_gps]
            incr test [TestEntier $HH_gps]
            incr test [TestEntier $MM_gps]
            incr test [TestEntier $SS_gps]
            if {$test == 0} {
                set temps_gps [clock scan "20${AA_gps}${BB_gps}${JJ_gps}T${HH_gps}${MM_gps}${SS_gps}" -base [clock seconds]]

                if {$temps_gps > $gps(temps_synchro)} {
                    set gps_reveil_synchro 1
                }
                set delta [expr $temps_gps - $temps_pc]
                set gps(somme_delta) [expr $gps(somme_delta) + $delta]
                incr gps(nombre_delta)
                set moyenne_delta [expr $gps(somme_delta) / $gps(nombre_delta)]
                if {([expr abs($moyenne_delta - $gps(moyenne_precedente))] < [expr $parametres(seuil_ok) / 1000.0]) && ($gps(synchro_position) == 1)} {
                    incr gps(nombre_ok)
                    if {$gps(nombre_ok) >= 10} {
                        set gps(synchro_temps) 1
                        # Signalisation pour le mode auto
                        set gps_synchro_temps 1
                    } else {
                        set gps(synchro_temps) 0
                    }
                    if {$gps(nombre_ok) == 10} {bell}
                } else {
                    set gps(nombre_ok) 0
                    set gps(synchro_temps) 0
                    incr gps(nombre_echec)
                    if {$gps(nombre_echec) > 50} {
                        # Signalisation pour le mode auto
                        set gps_synchro_temps 1
                    }
                }
                set gps(moyenne_precedente) $moyenne_delta
                set gps(temps_gps) $temps_gps

                set gps(correction) [expr ($parametres(decalage) / 1000.0) + $moyenne_delta]
            }
        } else {
            set gps(synchro_temps) 0
            incr gps(nombre_echec)
            if {$gps(nombre_echec) > 50} {
                # Signalisation pour le mode auto
                set gps_synchro_temps 1
            }
        }
    }

    ##############################################################
    ### TraitementLigne ##########################################
    ##############################################################
    proc TraitementLigne {serie} {
        variable gps
        variable parametres
        variable test

        if {[catch {gets $serie ligne} lecture]} {
            incr gps(erreur_lecture)

            if {$gps(erreur_lecture) > 9} {
                Message console "%s\n" $lecture
                ArretGPS
                return
            }
        } else {
            set gps(erreur_lecture) 0
            if {$lecture > 0} {
                set entete_gps [string range $ligne 0 5]
                if {[string compare $entete_gps $gps(message_GPRMC)] == 0} {
                    set temps_pc [jm_heurepc]
                    AffichageHeure $ligne $temps_pc
                    AffichagePosition $ligne
                }
                if {[string compare $entete_gps $gps(message_PGRMZ)] == 0} {
                    AffichageAltitudePGRMZ $ligne
                }
                if {[string compare $entete_gps $gps(message_GPGGA)] == 0} {
                    AffichageAltitudeGPGGA $ligne
                }
                if {[string index $entete_gps 0] == "\$"} {
                    Message infos $entete_gps
                }
                update idletasks
            }
        }
    }

    ##############################################################
    ### TraitementLigneMuet ######################################
    ##############################################################
    # Utilise en mode automatique                               #
    ##############################################################
    proc TraitementLigneMuet {serie} {
        variable gps
        variable parametres

        if {[catch {gets $serie ligne} lecture]} {
            incr gps(erreur_lecture)

            if {$gps(erreur_lecture) > 9} {
                Message console "%s\n" $lecture
                ArretGPS
                return
            }
        } else {
            set gps(erreur_lecture) 0
            if {$lecture > 0} {
                set entete_gps [string range $ligne 0 5]
                if {[string compare $entete_gps $gps(message_GPRMC)] == 0} {
                    set temps_pc [jm_heurepc]
                    TraitementHeure $ligne $temps_pc
                    TraitementPosition $ligne
                }
                if {[string index $entete_gps 0] == "\$"} {
                    Message infos $entete_gps
                }
                update idletasks
            }
        }
    }

    ##############################################################
    ### TraitementPosition #######################################
    ##############################################################
    proc TraitementPosition {ligne} {
        variable gps
        variable position

        # Recuperation des infos dans la ligne
        regexp {([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)} $ligne match type heure flag lat_brute nord_sud long_brute est_ouest

        # Verification de la synchro
        if {(![info exists lat_brute]) || (![info exists long_brute]) || (![info exists nord_sud]) || (![info exists est_ouest])} {
            set test 1
        } else {
            set test 0
            incr test [TestFlottant $lat_brute]
            incr test [TestFlottant $long_brute]
            if {[string length $nord_sud] != 1} {incr test}
            if {[string length $est_ouest] != 1} {incr test}
        }

        if {$test != 0} {
            set gps(synchro_position) 0
        } else {
            scan [string range $lat_brute 0 1] "%2d" position(DD_lat)
            scan [string range $lat_brute 2 3] "%2d" position(MM_lat)
            set position(NS) $nord_sud
            scan [string range $long_brute 0 2] "%3d" position(DD_lon)
            scan [string range $long_brute 3 4] "%2d" position(MM_lon)
            set position(EW) $est_ouest

            # Conversion des secondes (precision du 1/10 de seconde)
            scan [string range $lat_brute 5 end] "%d" ddd
            set l [string length [string range $lat_brute 5 end]]
            set position(SS_lat) [format "%3.1f" [expr $ddd * 60 * 1e-$l]]
            scan [string range $long_brute 6 end] "%d" ddd
            set l [string length [string range $long_brute 6 end]]
            set position(SS_lon) [format "%3.1f" [expr $ddd * 60 * 1e-$l]]

            set gps(synchro_position) 1
        }
    }

    ##############################################################
    ### stopTool #################################################
    ##############################################################
    proc stopTool { visuNo } {
        variable This

        Terminaison $This
    }

    ##############################################################
    ### ValideSaisie #############################################
    ##############################################################
    proc ValideSaisie {} {
        global caption
        variable parametres
        variable fenetre

        set test 0
        foreach champ {decalage seuil_ok reglage} {
            incr test [string is integer $parametres($champ)]
        }

        if {$test == 3} {
            destroy $fenetre.divers
        } else {
            tk_messageBox -type ok -icon error -title $caption(gps,erreur) -message $caption(gps,type_non_entier)
        }
    }
    # fin du namespace
}

