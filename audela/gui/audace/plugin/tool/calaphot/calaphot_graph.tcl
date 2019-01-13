##
# @file calaphot_graph.tcl
#
# @author Olivier Thizy (thizy@free.fr) & Jacques Michelet (jacques.michelet@laposte.net)
#
# @brief Routines de gestion des affichages de Calaphot
#
# $Id: calaphot_graph.tcl 12789 2016-01-21 19:26:01Z rzachantke $

namespace eval ::CalaPhot {

    ##
    # @brief Affichage séquentiel des menus de sélection des astres
    # @details si tracage active, init des valeurs de sortie directement @n
    #         sinon, passage par les écrans de saisie (conditionné par
    #         par une eventuelle demande d'arret)
    # @param[in] nom_image : nom générique des images
    # @retval data_script(nombre_reference) : nombre d'étoile de référence
    # @retval data_script(nombre_variable) : nombre d'asteroide
    # @retval data_script(nombre_indes) : nombre d'étoile a supprimer
    proc AffichageMenus { nom_image } {
        variable demande_arret
        variable data_script
        variable pos_theo
        variable coord_aster
        variable parametres
        variable calaphot

        Message debug "%s\n" [ info level [ info level ] ]
        Message debug "nbre ref=%d / nbre var=%d / reprise=%s\n" $data_script(nombre_reference) $data_script(nombre_variable) $parametres(reprise_astres)

        set retour 0
        if { ( $data_script(nombre_reference) == 0 ) \
            || ( $data_script(nombre_variable) == 0 ) \
            || ( $parametres(reprise_astres) == "non" ) } {

            # On nettoie
            for { set i 0 } { $i < $data_script(nombre_reference) } { incr i } {
                set pos_theo(ref,$i) [ list ]
            }
            set data_script(nombre_reference) 0
            for { set i 0 } { $i < $data_script(nombre_variable) } { incr i } {
                set coord_aster($i,1) [ list ]
                set coord_aster($i,2) [ list ]
            }
            set data_script(nombre_variable) 0
            set data_script(nombre_indes) 0

            # La fonctionnalité du catalogue automatique n'est plus incluse dans cette version de Calaphot
            # Le fichier calaphot_catalogues.tcl est enlevé du code.
            # ChoixManuelAutomatique
            set data_script(choix_mode_reference) "manuel"
            switch -exact -- $data_script(choix_mode_reference) {
                arret {
                    set demande_arret 1
                }
                auto_internet {
                    if { [ ModeAutoInternet $nom_image ] != 0 } {
                        set demande_arret 1
                    }
                }
                manuel {
                    AffichageMenuEtoile $nom_image
                }
            }

            if { ( $demande_arret == 0 ) } {
                AffichageMenuAsteroide 1 $nom_image
                if { $demande_arret == 0 } {
                    AffichageMenuIndesirable $nom_image
                } else {
                    set retour 1
                }
            } else {
                set retour 1
            }
        } else {
            set data_script(choix_mode_reference) manuel
            set retour 0
        }

        Message notice "%s : %d\n" $calaphot(texte,nombre_variables) $data_script(nombre_variable)
        TraceFichier "%s : %d\n" $calaphot(texte,nombre_variables) $data_script(nombre_variable)
        for { set i 0 } { $i < $data_script(nombre_variable) } { incr i } {
            Message notice "\t%s %i x=%.2f y=%.2f\n" $calaphot(texte,variable) $i [lindex $coord_aster($i,1) 0 ] [ lindex $coord_aster($i,1) 1 ]
            TraceFichier "\t%s %i x=%.2f y=%.2f\n" $calaphot(texte,variable) $i [lindex $coord_aster($i,1) 0 ] [ lindex $coord_aster($i,1) 1 ]
            Message notice "\t%s %i x=%.2f y=%.2f\n" $calaphot(texte,variable) $i [lindex $coord_aster($i,2) 0 ] [ lindex $coord_aster($i,2) 1 ]
            TraceFichier "\t%s %i x=%.2f y=%.2f\n" $calaphot(texte,variable) $i [lindex $coord_aster($i,2) 0 ] [ lindex $coord_aster($i,2) 1 ]
        }

        Message notice "%s : %d\n" $calaphot(texte,nombre_references) $data_script(nombre_reference)
        TraceFichier "%s : %d\n" $calaphot(texte,nombre_references) $data_script(nombre_reference)
        for { set i 0 } { $i < $data_script(nombre_reference) } { incr i } {
            # Il se peut que l'utilisateur ait arrêté avant de positionner les astéroides
            if [ info exist pos_theo(ref,$i) ] {
                Message notice "\t%s %i x=%.2f y=%.2f m=%.2f\n" $calaphot(texte,reference) $i [lindex $pos_theo(ref,$i) 0 ] [ lindex $pos_theo(ref,$i) 1 ] [ lindex $pos_theo(ref,$i) 2 ]
                TraceFichier "\t%s %i x=%.2f y=%.2f m=%.2f\n" $calaphot(texte,reference) $i [lindex $pos_theo(ref,$i) 0 ] [ lindex $pos_theo(ref,$i) 1 ] [ lindex $pos_theo(ref,$i) 2 ]
            }
        }

        return $retour
    }

    ##
    # @brief Trampoline pour valider la bonne saisie des coordonnées de l'astéroide
    #
    proc ValidationPositionAsteroide { nom indice } {
        Message debug "%s\n" [ info level [ info level ] ]

        set r [ ::CalaPhot::PositionAsteroide $nom $indice ]
        if { $r == 0 } {
            $::audace(base).selection_aster.bcontinuation configure -state normal
        }
    }

    ##
    # @brief Affichage de la boite de sélection d'un astéroide
    # @param indice : sélecteur
    # - 0 : permet de passer à un astéroide suivant (quand on supportera les astéroides multiples)
    # - 1 : sélection dans la 1ère image de la séquence
    # - 2 : sélection dans la dernière image de la séquence
    # .
    # @param nom_image nom générique de l'image sur laquelle va se faire la sélection
    # @return
    proc AffichageMenuAsteroide { indice nom_image } {
        variable calaphot
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        catch { destroy $::audace(base).selection_aster }

        toplevel $::audace(base).selection_aster -class Toplevel -borderwidth 2 -relief groove
        wm resizable $::audace(base).selection_aster 0 0
        wm title $::audace(base).selection_aster $calaphot(texte,asteroide)
        wm transient $::audace(base).selection_aster .audace
        wm protocol $::audace(base).selection_aster WM_DELETE_WINDOW ::CalaPhot::Suppression

        set texte_bouton(pos_aster_1) $calaphot(texte,pos_aster_1)
        set texte_bouton(pos_aster_2) $calaphot(texte,pos_aster_2)
        set texte_bouton(continuation) $calaphot(texte,continuation)
        set texte_bouton(retour) $calaphot(texte,retour)
        set texte_bouton(suivant) $calaphot(texte,suivant)
        set texte_bouton(annulation) $calaphot(texte,annulation)

        if { $indice == 0 } {
            if { $data_script(nombre_variable) == 0 } {
                set liste_champ { suivant annulation }
            } else {
                set liste_champ { suivant continuation annulation }
                set commande_bouton(continuation) "::CalaPhot::ContinuationAsteroide"
            }
        }
        if { $indice == 1 } {
            # Affichage de la première ou de la dernière image de la série
            ChargementImageParNom ${nom_image}1 visu $data_script(premier_liste)
            set liste_champ { pos_aster_1 continuation annulation }
            set commande_bouton(continuation) "::CalaPhot::AffichageMenuAsteroide 2 $nom_image"
        }
        if { $indice == 2 } {
            # Affichage de la première ou de la dernière image de la série
            ChargementImageParNom ${nom_image}2 visu $data_script(dernier_liste)
            set liste_champ { pos_aster_2 continuation retour annulation }
        # MultAster : remettre
            #set commande_bouton(continuation) "::CalaPhot::AffichageMenuAsteroide 0 $nom_image"
        # /MultAster
            set commande_bouton(continuation) "::CalaPhot::ContinuationAsteroide"
        }

        # indice <- (indice + 1) mod 3
        if { $indice == 2 } { set indice 1 } else { incr indice }

        set commande_bouton(pos_aster_1) "::CalaPhot::ValidationPositionAsteroide $nom_image 1"
        set commande_bouton(pos_aster_2) "::CalaPhot::ValidationPositionAsteroide $nom_image 2"
        set commande_bouton(retour) "::CalaPhot::Retour $nom_image"
        set commande_bouton(suivant) "::CalaPhot::AffichageMenuAsteroide $indice $nom_image"
        set commande_bouton(annulation) ::CalaPhot::ArretScript

        #----- Création du contenu de la fenêtre
        foreach champ $liste_champ {
            button $::audace(base).selection_aster.b$champ \
                -text $texte_bouton($champ) \
                -command $commande_bouton($champ) \
                -bg $::audace(color,backColor2)
            pack $::audace(base).selection_aster.b$champ \
                -anchor center \
                -side top \
                -fill x \
                -padx 4 \
                -pady 4 \
                -in $::audace(base).selection_aster \
                -anchor center \
                -expand 1 \
                -fill both \
                -side top
        }
        $::audace(base).selection_aster.bcontinuation configure -state disabled
        ::confColor::applyColor $::audace(base).selection_aster

        tkwait window $::audace(base).selection_aster
    }

    ##
    # @brief Affichage de la boite de sélection d'une étoile
    # @details Initialisation de certaines variables
    # - data_script(nombre_reference)
    # - coord_etoile_x
    # - coord_etoile_y
    # - mag_etoile
    # .
    # @param nom_image nom générique de l'image sur laquelle va se faire la sélection
    # @return
    proc AffichageMenuEtoile { nom_image } {
        variable calaphot
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        # Affichage de la première image de la série
        ChargementImageParNom ${nom_image}1 visu $data_script(premier_liste)

        set f [ toplevel $::audace(base).selection_etoile -class Toplevel -borderwidth 2 -relief groove ]
        wm resizable $f 0 0
        wm title $f $calaphot(texte,etoile_reference)
        wm transient $f .audace
        wm protocol $f WM_DELETE_WINDOW ::CalaPhot::Suppression

        set texte_bouton(validation_etoile) $calaphot(texte,validation_etoile)
        set texte_bouton(devalidation_etoile) $calaphot(texte,devalidation_etoile)
        set texte_bouton(continuation) $calaphot(texte,continuation)
        set texte_bouton(annulation) $calaphot(texte,annulation)

        set commande_bouton(validation_etoile) ::CalaPhot::SelectionneEtoiles
        set commande_bouton(devalidation_etoile) ::CalaPhot::DeselectionneEtoiles
        set commande_bouton(continuation) ::CalaPhot::ContinuationEtoiles
        set commande_bouton(annulation) ::CalaPhot::ArretScript

        set ff [ frame $f.f1 \
            -borderwidth 5 \
            -relief groove ]
        #----- Création du contenu de la fenêtre
        foreach champ { validation_etoile devalidation_etoile continuation annulation } {
            button $ff.b$champ \
                -text $texte_bouton($champ) \
                -command $commande_bouton($champ) \
                -bg $::audace(color,backColor2)
            pack $ff.b$champ \
                -anchor center \
                -side top \
                -padx 4 \
                -pady 4 \
                -in $ff \
                -anchor center \
                -expand 1 \
                -fill both \
                -side top
        }
        pack $ff \
            -fill both

        if { [ info exists coord_etoile_x ] } {
            unset coord_etoile_x
            set coord_etoile_x [ list ]
        }
        if { [ info exists coord_etoile_y ] } {
            unset coord_etoile_y
            set coord_etoile_y [ list ]
        }
        if { [ info exists mag_etoile ] } {
            unset mag_etoile
            set mag_etoile [ list ]
        }
        ::confColor::applyColor $f
        tkwait window $f
    }

    ##
    # @brief Affichage de la boite de suppression d'une étoile
    # @details Initialisation de certaines variables
    # - data_script(nombre_indes)
    # - coord_indes_x
    # - coord_indes_y
    # .
    # @param nom_image nom générique de l'image sur laquelle va se faire la sélection
    # @return
    proc AffichageMenuIndesirable { nom_image } {
        global audace
        variable calaphot
        variable data_script
        variable coord_indes_x
        variable coord_indes_y

        Message debug "%s\n" [info level [info level]]

        # Affichage de la première image de la série
        ChargementImageParNom ${nom_image}1 visu $data_script(premier_liste)

        toplevel $audace(base).selection_indes -class Toplevel -borderwidth 2 -relief groove
        wm resizable $audace(base).selection_indes 0 0
        wm title $audace(base).selection_indes $calaphot(texte,etoile_a_supprimer)
        wm transient $audace(base).selection_indes .audace
        wm protocol $audace(base).selection_indes WM_DELETE_WINDOW ::CalaPhot::Suppression

        set texte_bouton(validation_etoile) $calaphot(texte,validation_etoile)
        set texte_bouton(devalidation_etoile) $calaphot(texte,devalidation_etoile)
        set texte_bouton(continuation) $calaphot(texte,continuation)
        set texte_bouton(annulation) $calaphot(texte,annulation)

        set commande_bouton(validation_etoile) ::CalaPhot::SelectionneIndesirables
        set commande_bouton(devalidation_etoile) ::CalaPhot::DeselectionneIndesirables
        set commande_bouton(continuation) ::CalaPhot::ContinuationIndesirables
        set commande_bouton(annulation) ::CalaPhot::ArretScript

        #----- Création du contenu de la fenêtre
        foreach champ {validation_etoile devalidation_etoile continuation annulation} {
            button $audace(base).selection_indes.b$champ -text $texte_bouton($champ) -command $commande_bouton($champ) -bg $audace(color,backColor2)
            pack $audace(base).selection_indes.b$champ -anchor center -side top -fill x -padx 4 -pady 4 -in $audace(base).selection_indes -anchor center -expand 1 -fill both -side top
        }

        set data_script(nombre_indes) 0
        if {[info exists coord_indes_x]} {
            unset coord_indes_x
            list coord_indes_x {}
        }
        if {[info exists coord_indes_y]} {
            unset coord_indes_y
            list coord_indes_y {}
        }
        ::confColor::applyColor $audace(base).selection_indes
        tkwait window $audace(base).selection_indes
    }

    ##
    # @brief Affichage console des informations sur les objets de l'image courante
    # @param i : indice de l'image dans la séquence
    # @return
    proc AffichageResultatsBruts { i } {
        variable parametres
        variable data_image
        variable data_script
        variable calaphot
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set ymdhms [mc_date2ymdhms $data_image($i,date)]
        set y [lindex $ymdhms 0]
        set m [lindex $ymdhms 1]
        set d [lindex $ymdhms 2]
        set h [lindex $ymdhms 3]
        set mn [lindex $ymdhms 4]
        set s [lindex $ymdhms 5]

        # Génération d'un champ de taille fixe contenant le nom de l'image
        set nom_image [ file rootname [ file tail [ lindex $liste_image $i ] ] ]
        set taille_nom [ string length $nom_image ]
        set taille_champ_nom 20
        set champ_vide [ string repeat " " $taille_champ_nom ]
        Message debug "longueur_champ_vide = %d / longueur_nom = %d\n" [ string length $champ_vide ] $taille_nom
        set champ_nom [ string replace $champ_vide [ expr $taille_champ_nom - $taille_nom ] $taille_champ_nom $nom_image ]
        Message debug "longueur_champ_nom = %d\n" [ string length $champ_nom ]

        Message notice "%05u | %s | %f | %04d/%02d/%02d | %02d:%02d:%04.1f" $i $champ_nom $data_image($i,date) $y $m $d $h $mn $s
        TraceFichier "%05u | %s | %f | %04d/%02d/%02d | %02d:%02d:%04.1f" $i $champ_nom $data_image($i,date) $y $m $d $h $mn $s

        if { $data_image($i,qualite) != "mauvaise" } {
            for { set etoile 0 } { $etoile < $data_script(nombre_variable) } { incr etoile } {
                Message notice " | %07.4f" $data_image($i,var,mag_$etoile)
                TraceFichier " | %07.4f" $data_image($i,var,mag_$etoile)
                Message notice " %05.4f" $data_image($i,var,incertitude_$etoile)
                TraceFichier " %05.4f" $data_image($i,var,incertitude_$etoile)
                Message info " %07.0f" $data_image($i,var,flux_$etoile)
                Message info " %06.1f" $data_image($i,var,sb_$etoile)
                Message debug " N=%07.2f" $data_image($i,var,nb_pixels_$etoile)
                Message debug " B=%06.1f" $data_image($i,var,fond_$etoile)
                Message debug " Nb=%07.2f\n" $data_image($i,var,nb_pixels_fond_$etoile)
            }
            for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
                Message notice " | %07.4f" $data_image($i,ref,mag_$etoile)
                TraceFichier " | %07.4f" $data_image($i,ref,mag_$etoile)
                Message notice " %05.4f" $data_image($i,ref,incertitude_$etoile)
                TraceFichier " %05.4f" $data_image($i,ref,incertitude_$etoile)
                Message info " %07.0f" $data_image($i,ref,flux_$etoile)
                Message info " %06.1f" $data_image($i,ref,sb_$etoile)
                Message debug " N=%07.2f" $data_image($i,ref,nb_pixels_$etoile)
                Message debug " B=%06.1f" $data_image($i,ref,fond_$etoile)
                Message debug " Nb=%07.2f" $data_image($i,ref,nb_pixels_fond_$etoile)
            }
            Message notice " | %07.4f" $data_image($i,constante_mag)
            TraceFichier " | %07.4f" $data_image($i,constante_mag)
        } else {
            for { set etoile 0 } { $etoile < $data_script(nombre_variable) } { incr etoile } {
                Message notice " | -------"
                TraceFichier " | --V----"
                Message notice " ------"
                TraceFichier " ------"
                Message info " -------"
                Message info " ------"
                Message debug " N=-------"
                Message debug " B=------"
                Message debug " Nb=-------"
            }
            for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
                Message notice " | -------"
                TraceFichier " | --R----"
                Message notice " ------"
                TraceFichier " ------"
                Message info " -------"
                Message info " ------"
                Message debug " N=-------"
                Message debug " B=------"
                Message debug " Nb=-------"
            }
            Message notice " | -------"
            TraceFichier " | --C----"
        }
        Message notice " | %s" $data_image($i,qualite)
        TraceFichier " | %s" $data_image($i,qualite)
        if { $data_image($i,qualite) != "bonne" } {
            Message debug "( %s )" $data_script($i,invalidation)
            TraceFichier "( %s )" $data_script($i,invalidation)
        }
        Message notice "\n"
        TraceFichier "\n"
    }

    ##
    # @brief Affichage dynamique des trames de l'ecran de saisie des paramètres et ajustement des ascenseurs en conséquence
    # @param mode : mode de calcul choisi
    # @param c : handle du canvas qui contient ces trames
    # @param y : handle du scrollbar (ascenseur)
    # @param t : handle de la trame englobant les trames à afficher
    proc AffichageVariable {mode c y t} {
        global audace

        Message debug "%s\n" [info level [info level]]

        # Attention : le canevas $c fonctionne avec un grid manager !
        # Ne pas faire de mélange pack et grid
        catch {grid forget $t.trame1}
        catch {grid forget $t.trame2}
        catch {grid forget $t.trame_ouv}
        catch {grid forget $t.trame_mod}
        catch {grid forget $t.trame_sex}
        catch {grid forget $t.trame3}

        if {$mode == "ouverture"} {
            set fils $t.trame_ouv
        } elseif {$mode == "modelisation"} {
            set fils $t.trame_mod
        } elseif {$mode == "sextractor"} {
            set fils $t.trame_sex
        } else {
            Message erreur "mode=%s\n" $mode
            return
        }
        grid $t.trame1
        grid $t.trame2
        grid $fils
        grid $t.trame3

        # Il faut retailler les fenêtres avant de calculer leur largeur et hauteur
        ::confColor::applyColor $audace(base).saisie
        # Gestion dynamique de la taille du scrollbar
        # inspiré de Practical Programming in TclTk, exemple 34.13
        tkwait visibility $fils
        # L'instruction suivant semble servir pour reqwidth et reqheight
        # Ne pas effacer
        set bbox [ grid bbox $t 0 0 ]
#        set incr [lindex $bbox 3]
        set largeur [ winfo reqwidth $t ]
        set hauteur [ winfo reqheight $t ]
        $c config -scrollregion "0 0 $largeur $hauteur"
        $c config -yscrollincrement 5
        set hauteur_max [ expr [ winfo screenheight . ] * 3 / 4 ]
        if { $hauteur > $hauteur_max } {
            set hauteur $hauteur_max
        }
        $c config -width $largeur -height $hauteur
    }

    #*************************************************************************#
    #*************  AnnuleSaisie  ********************************************#
    #*************************************************************************#
    proc AnnuleSaisie {} {
        ArretScript
    }

    #*************************************************************************#
    #*************  ArretScript  *********************************************#
    #*************************************************************************#
    proc ArretScript { } {
        variable demande_arret
        variable calaphot

        Message debug "%s\n" [ info level [ info level ] ]

        set demande_arret 1
        EffaceMotif astres
        catch { destroy $calaphot(toplevel,saisie) }
        catch { destroy $::audace(base).selection_etoile }
        catch { destroy $::audace(base).selection_aster }
        catch { destroy $::audace(base).selection_indes }
        catch { destroy $::audace(base).bouton_arret_color_invariant }
        catch { destroy $::audace(base).pasapas }
        update idletasks
        DestructionFichiersAuxiliaires
        SauvegardeDecalages
    }

    ##
    # @brief Mise en place du bouton permettant d'arrêter les calculs.
    # @return
    proc BoutonArret {} {
        variable calaphot
        variable police

        Message debug "%s\n" [info level [info level]]

        set b [toplevel $::audace(base).bouton_arret_color_invariant -class Toplevel -borderwidth 2 -bg $::color(red) -relief groove]
        wm geometry $b +320+0
        wm resizable $b 0 0
        wm title $b ""
        wm transient $b .audace
        wm protocol $b WM_DELETE_WINDOW ::CalaPhot::Suppression

        frame $b.arret -borderwidth 5 \
            -relief groove \
            -bg $::color(red)
        button $b.arret.b \
            -text $calaphot(texte,arret) \
            -command {set ::CalaPhot::demande_arret 1} \
            -bg $::color(white) \
            -activebackground $::color(red) \
            -fg $::color(red)
        pack $b.arret.b -side left -padx 10 -pady 10
        pack $b.arret

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $b
    }

    #*************************************************************************#
    #*************  ContinuationAsteroide  ***********************************#
    #*************************************************************************#
    proc ContinuationAsteroide {} {
        global audace
        variable calaphot
        variable coord_aster
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        Message info "----------------------------\n"
        Message info "------------%s--------------\n" $calaphot(texte,asteroide)
        Message info "----------------------------\n"
        for { set a 0 } { $a < $data_script(nombre_variable) } {incr a} {
            Message info "--- %u : (%4.2f %4.2f) -> (%4.2f %4.2f)\n" $a [ lindex $coord_aster($a,1) 0 ] [ lindex $coord_aster($a,1) 1 ] [ lindex $coord_aster($a,2) 0 ] [ lindex $coord_aster($a,2) 1 ]
        }
        destroy $::audace(base).selection_aster
    }


    #*************************************************************************#
    #*************  ContinuationEtoiles  *************************************#
    #*************************************************************************#
    proc ContinuationEtoiles {} {
        global audace
        variable data_script
        variable calaphot
        variable pos_theo
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile

        Message debug "%s\n" [ info level [ info level ] ]

        if { $data_script(nombre_reference) <= 0 } {
            tk_messageBox -message $calaphot(texte,pas_etoile) -icon error -title $calaphot(texte,probleme)
        } else {
            # On initialise le tableau pos_theo
            Message info "----------------------------\n"
            Message info "------------%s--------------\n" $calaphot(texte,etoile_reference)
            Message info "----------------------------\n"
            for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
                set cx [lindex $coord_etoile_x $i]
                set cy [lindex $coord_etoile_y $i]
                set m [lindex $mag_etoile $i]
                set pos_theo(ref,$i) [list $cx $cy $m]
                Message info "%s n%d: %4.2f %4.2f %4.2f\n" $calaphot(texte,etoile) $i $cx $cy $m
            }
            destroy $::audace(base).selection_etoile
        }
    }

    #*************************************************************************#
    #*************  ContinuationIndesirables  ********************************#
    #*************************************************************************#
    proc ContinuationIndesirables {} {
        global audace
        variable data_script
        variable calaphot
        variable pos_theo
        variable coord_indes_x
        variable coord_indes_y

        Message debug "%s\n" [info level [info level]]

        # On initialise le tableau pos_theo_indes
        if {$data_script(nombre_indes) <= 0} {
            Message info "\n------------%s--------------\n" $calaphot(texte,pas_etoile_ind)
        } else {
            Message info "----------------------------\n"
            Message info "------------%s--------------\n" $calaphot(texte,et_indesirables)
            Message info "----------------------------\n"
            set j 0
            for {set i 0} {$i < $data_script(nombre_indes)} {incr i} {
                set cx [lindex $coord_indes_x $i]
                set cy [lindex $coord_indes_y $i]
                set pos_theo(indes,$j) [list $cx $cy]
                Message info "%s (%d): %4.2f %4.2f\n" $calaphot(texte,etoile) $j $cx $cy
                incr j
            }
        }
        EffaceMotif astres
        destroy $::audace(base).selection_indes
    }

    ##
    #@brief Crée une fenêtre contenant un graphique y=f(x)
    #
    proc GraphiqueDynamique { nom_graphique type titre geometrie liste_vecteur liste_couleur liste_etiquette } {
        variable parametres
        variable TempVectors
        variable calaphot

        Message debug "%s\n" [ info level [ info level ] ]

        catch { destroy $nom_graphique }
        toplevel $nom_graphique
        wm geometry $nom_graphique $geometrie
        wm maxsize $nom_graphique [ winfo screenwidth . ] [ winfo screenheight . ]
        wm minsize $nom_graphique 200 200
        wm resizable $nom_graphique 1 1

        wm title $nom_graphique $titre

        ::blt::graph $nom_graphique.xy \
            -title $titre

        Message debug "Class = %s\n" [ winfo class $nom_graphique.xy ]

        set courbe 0
        foreach vecteur $liste_vecteur {
            $nom_graphique.xy element create color_invariant_${type}_${courbe} \
                -xdata $TempVectors(temp.x) \
                -ydata $vecteur \
                -symbol plus \
                -color [ lindex $liste_couleur $courbe ] \
                -linewidth 0 \
                -pixels .05i \
                -label [ lindex $liste_etiquette $courbe ]
            incr courbe
        }
        $nom_graphique.xy axis configure x -title $calaphot(texte,jour_julien)
        $nom_graphique.xy axis configure y -title $calaphot(texte,magnitude)
        $nom_graphique.xy legend configure -position bottom
        $nom_graphique.xy grid on
        pack $nom_graphique.xy -expand 1 -fill both

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $nom_graphique.xy
        update idletasks

    }

    #*************************************************************************#
    #*************  CourbeLumiereTemporaire  *********************************#
    #*************************************************************************#
    #  Affichage de la courbe de lumière en cours de traitement (sans         #
    #  filtrage des données                                                   #
    #  Retourne la liste des fenêtres créées                                  #
    #*************************************************************************#
    proc CourbeLumiereTemporaire {} {
        global audace color
        variable calaphot
        variable parametres
        variable data_script
        variable TempVectors

        Message debug "%s\n" [ info level [ info level ] ]

        set liste_fenetres [ list ]
        set vector_list [ list ]
        catch { unset TempVectors }

        # On va créer autant de courbes de lumière que de variables
        # Une courbe pour les références
        # Une courbe pour la constante des mag.
        # Génération de la liste des vecteurs
        for { set i 0 } { $i < $data_script(nombre_variable) } { incr i } {
            set vector_list [ concat $vector_list [ list temp.var.$i vector[ uniq ] ] ]
        }
        for { set i 0 } { $i < $data_script(nombre_reference) } { incr i } {
            set vector_list [ concat $vector_list [ list temp.ref.$i vector[ uniq ] ] ]
        }
        set vector_list [ concat $vector_list [ list temp.cste vector[ uniq ] ] ]
        set vector_list [ concat $vector_list [ list temp.x vector[ uniq ] ] ]

        array set TempVectors $vector_list

        # On rend tous ces vecteurs globaux pour pouvoir s'en servir depuis une autre procédure
        foreach v [ array names TempVectors temp* ] {
            global $TempVectors($v)
        }

        foreach { key value } [ array get TempVectors ] {
            Message debug "TempsVectors(%s)=%s\n" $key $value
        }

        catch { ::blt::vector destroy $TempVectors(temp.x) }
        ::blt::vector create $TempVectors(temp.x)
        $TempVectors(temp.x) notify always
        for { set i 0 } { $i < $data_script(nombre_variable) } { incr i } {
            catch { ::blt::vector destroy $TempVectors(temp.var.$i) }
            ::blt::vector create $TempVectors(temp.var.$i)
        }
        for { set i 0 } { $i < $data_script(nombre_reference) } { incr i } {
            catch { ::blt::vector destroy $TempVectors(temp.ref.$i) }
            ::blt::vector create $TempVectors(temp.ref.$i)
        }
        catch { ::blt::vector destroy $TempVectors(temp.cste) }
        ::blt::vector create $TempVectors(temp.cste)

        set largeur_graphique [ expr [ winfo screenwidth . ] / 3 ]
        set hauteur_graphique [ expr [ winfo screenheight . ] / 4 ]

        #  Une fenêtre par variable
        for { set i 0 } { $i < $data_script(nombre_variable) } { incr i } {
            # Dans le tiers supérieur droit
            set x_graphique [ expr 2 * $largeur_graphique ]
            set y_graphique 0
            set nom_graphique "${::audace(base)}.calaphot_${i}"
            set geometrie "${largeur_graphique}x${hauteur_graphique}+${x_graphique}+${y_graphique}"
            set liste_vecteur [ list $TempVectors(temp.var.$i) ]
            set liste_couleur [ list $::color(blue) ]
            set liste_etiquette [ list $data_script(nom_var_$i) ]
            GraphiqueDynamique $nom_graphique var $parametres(objet) $geometrie $liste_vecteur $liste_couleur $liste_etiquette
        }

        # Une fenêtre pour toutes les références dans le tiers centre droit
        set x_graphique [ expr 2 * $largeur_graphique ]
        set y_graphique [ expr [ winfo screenheight . ] / 3 ]
        set nom_graphique "${::audace(base)}.calaphot_ref"
        set geometrie "${largeur_graphique}x${hauteur_graphique}+${x_graphique}+${y_graphique}"
        set liste_vecteur [ list ]
        set liste_couleur [ list ]
        set liste_etiquette [ list ]
        for { set ref 0 } { $ref < $data_script(nombre_reference) } { incr ref } {
            lappend liste_vecteur $TempVectors(temp.ref.${ref})
            lappend liste_couleur $calaphot(couleur,[ expr $ref % $calaphot(nombre_couleur) ])
            lappend liste_etiquette "ref_$ref"
        }
        GraphiqueDynamique $nom_graphique ref $calaphot(texte,reference_sans_accent) $geometrie $liste_vecteur $liste_couleur $liste_etiquette
        # Drapeau pour générer des valeurs affichées relatives
        set data_script(trace_premier,ref) 1

        # Une fenêtre pour toutes la constante des magnitudes dans le tiers inférieur droit
        # Dans le tiers supérieur droit
        set x_graphique [ expr 2 * $largeur_graphique ]
        set y_graphique [ expr 2 * [ winfo screenheight . ] / 3 ]
        set nom_graphique "${::audace(base)}.calaphot_cste"
        set geometrie "${largeur_graphique}x${hauteur_graphique}+${x_graphique}+${y_graphique}"
        set liste_vecteur [ list $TempVectors(temp.cste) ]
        set liste_couleur [ list $::color(black) ]
        set liste_etiquette [ list $calaphot(texte,constante_mag) ]
        GraphiqueDynamique $nom_graphique cste $calaphot(texte,constante_mag) $geometrie $liste_vecteur $liste_couleur $liste_etiquette

        return $liste_fenetres
    }

    #**************************************************************************#
    #*************  DeselectionneEtoile  **************************************#
    #**************************************************************************#
    proc DeselectionneEtoiles {} {
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile
        variable calaphot
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        if { ! [info exists data_script(nombre_reference) ] } {
            set data_script(nombre_reference) 0
        }
        Message debug "nombre_reference=%d\n" $data_script(nombre_reference)
        set pos [ Centroide ]
        Message debug "centroide=%s\n" $pos
        if { ( [llength $pos] != 0 ) && ( $data_script(nombre_reference ) > 0 ) } {
            incr data_script(nombre_reference) -1
            # Va permettre de reprendre le recalage photométrique de l'image
            if { ( $data_script(nombre_reference) == 0 ) } {
                unset data_script(flux_premiere_etoile)
            }
            set cx [ lindex $pos 0 ]
            set cy [ lindex $pos 1 ]
            set ix [ lsearch $coord_etoile_x $cx ]
            set iy [ lsearch $coord_etoile_y $cy ]
            if { ( $ix >=0 ) && ( $iy >=0 ) && ( $ix == $iy ) } {
                set coord_etoile_x [ lreplace $coord_etoile_x $ix $ix ]
                set coord_etoile_y [ lreplace $coord_etoile_y $iy $iy ]
                set mag_etoile [ lreplace $mag_etoile $iy $iy ]
                EffaceMotif etoile_${cx}_${cy}
            } else {
                tk_messageBox -message $calaphot(texte,etoile_inconnue) -icon error -title $calaphot(texte,probleme)
            }
        }
    }

    #**************************************************************************#
    #*************  DeselectionneIndesirables  ********************************#
    #**************************************************************************#
    proc DeselectionneIndesirables {} {
        variable coord_indes_x
        variable coord_indes_y
        variable calaphot
        variable data_script

        Message debug "%s\n" [info level [info level]]

        if {![info exists data_script(nombre_indes)]} {
            set data_script(nombre_indes) 0
        }
        set pos [Centroide]
        if {([llength $pos] != 0) && ($data_script(nombre_indes) > 0)} {
            incr data_script(nombre_indes) -1
            set cx [lindex $pos 0]
            set cy [lindex $pos 1]
            set ix [lsearch $coord_indes_x $cx]
            set iy [lsearch $coord_indes_y $cy]
            if {($ix >=0) && ($iy >=0) && ($ix == $iy)} {
                set coord_indes_x [lreplace $coord_indes_x $ix $ix]
                set coord_indes_y [lreplace $coord_indes_y $iy $iy]
                EffaceMotif etoile_${cx}_${cy}
            } else {
                tk_messageBox -message $calaphot(texte,etoile_inconnue) -icon error -title $calaphot(texte,probleme)
            }
        }
    }

    ##
    # @brief Dessin d'un motif géométrique sur l'image affichée
    # @details Les coordonnées image sont transformées en coordonnées écran (zoom, miroirs, et renversement en y)
    # @param motif : motif à afficher. Les valeurs peuvent être :
    # - ovale
    # - rectangle
    # - verticale (trait vertical)
    # - horizontale (trait horizontal)
    # .
    # @param centre : liste de corrdonnées en pixel du centre du motif [list x y] en cooordonnees image
    # @param taille : liste donnant la largeur et la hauteur du motif en pixels [list largeur hauteur]
    # @param couleur : couleur du motif. Voir la documentation de Tcl pour les valeurs possibles
    # @param marqueur : marqueur ("tag" au sens Tk) du motif
    # @return
    proc Dessin { motif centre taille couleur marqueur } {
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        # L'image peut être affichée avec un facteur d'échelle
        set zoom [ visu$::audace(visuNo) zoom ]

        set x [ lindex $centre 0 ]
        set y [ lindex $centre 1 ]
        set rh [ lindex $taille 0 ]
        set rv [ lindex $taille 1 ]
        set x1 [ expr round( ( $x - $rh ) * $zoom ) ]
        set y1 [ expr round( ( $y - $rv ) * $zoom ) ]
        set x2 [ expr round( ( $x + $rh ) * $zoom ) ]
        set y2 [ expr round( ( $y + $rv ) * $zoom ) ]
        set x0 [ expr round( $x * $zoom + 0.5 ) ]
        set y0 [ expr round( $y * $zoom + 0.5 ) ]
        set naxis2 [ expr round( $data_script(naxis2) * $zoom ) ]
        set naxis1 [ expr round( $data_script(naxis1) * $zoom ) ]
        # Correction des miroirs
        if { [ visu$::audace(visuNo) mirrorx ] == 1 } {
            set x0 [ expr $naxis1 - $x0 ]
            set x1 [ expr $naxis1 - $x1 ]
            set x2 [ expr $naxis1 - $x2 ]
        }
        if { [ visu$::audace(visuNo) mirrory ] == 1 } {
            set y0 [ expr $naxis2 - $y0 ]
            set y1 [ expr $naxis2 - $y1 ]
            set y2 [ expr $naxis2 - $y2 ]
        }
        switch -exact -- $motif {
            "ovale" {
                $::audace(hCanvas) create oval \
                [ expr $x1 - 1 ] \
                [ expr $naxis2 - $y1 ] \
                [ expr $x2 - 1 ] \
                [ expr $naxis2 - $y2 ] \
                -outline $couleur \
                -width 1.2 \
                -tags [ list astres $marqueur ]
            }
            "rectangle" {
                $::audace(hCanvas) create rect \
                [ expr $x1 - 1 ] \
                [ expr $naxis2 - $y1 ] \
                [ expr $x2 - 1 ] \
                [ expr $naxis2 - $y2 ] \
                -outline $couleur \
                -width 1.2 \
                -tags [ list astres $marqueur ]
            }
            "verticale" {
                $::audace(hCanvas) create line \
                $x0 \
                [ expr $naxis2 - $y1 ] \
                $x0 \
                [ expr $naxis2 - $y2 ] \
                -fill $couleur \
                -width 1.2 \
                -tags [ list astres $marqueur ]
            }
            "horizontale" {
                $::audace(hCanvas) create line \
                [ expr $x1 - 1 ] \
                [ expr $naxis2 - $y0 ] \
                [ expr $x2 ] \
                [ expr $naxis2 - $y0 ] \
                -fill $couleur \
                -width 1.2 \
                -tags [ list astres $marqueur ]
            }
        }
        update idletasks
    }

    ##
    # @brief Tracé d'une ellipse sur l'écran
    # @details Les coordonnées image sont transformées en coordonnées écran (zoom, miroirs, et renversement en y)
    #
    proc DessinTexte { image classe etoile facteur couleur marqueur } {
        variable data_image
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        # L'image peut être affichée avec un facteur d'echelle
        set zoom [ visu$::audace(visuNo) zoom ]

        set naxis2 [ expr $data_script(naxis2) * $zoom ]
        set naxis1 [ expr $data_script(naxis1) * $zoom ]
        # centroide
        set x0 [ expr $data_image($image,$classe,centroide_x_$etoile) * $zoom ]
        set y0 [ expr $data_image($image,$classe,centroide_y_$etoile) * $zoom ]

        set dy [ expr ( $data_image($image,$classe,fwhmy_$etoile) + 4.0 ) * $zoom ]

        # Correction des miroirs
        if { [ visu$::audace(visuNo) mirrorx ] == 1 } {
            set x0 [ expr $naxis1 - $x0 ]
        }
        if { [ visu$::audace(visuNo) mirrory ] == 1 } {
            set y0 [ expr $naxis2 - $y0 ]
        }

        if { $classe == "ref" } {
            set texte "ref_$etoile"
            $::audace(hCanvas) create text $x0 [ expr $naxis2 - $y0 - $facteur * $dy ] \
                -text $texte \
                -tags [ list astres $marqueur ] \
                -fill $couleur
        }
    }

    ##
    # @brief Tracé d'une ellipse sur l'écran
    # @details Les coordonnées image sont transformées en coordonnées écran (zoom, miroirs, et renversement en y)
    #
    proc Dessin2 { image classe etoile facteur couleur marqueur } {
        variable data_image
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        # L'image peut être affichée avec un facteur d'échelle
        set zoom [ visu$::audace(visuNo) zoom ]

        set naxis2 [ expr $data_script(naxis2) * $zoom ]
        set naxis1 [ expr $data_script(naxis1) * $zoom ]

        # Centroide
        set x0 [ expr $data_image($image,$classe,centroide_x_$etoile) * $zoom ]
        set y0 [ expr $data_image($image,$classe,centroide_y_$etoile) * $zoom ]
        # Fwhms
        set f1 [ expr $data_image($image,$classe,fwhm1_$etoile) * $zoom ]
        set f2 [ expr $data_image($image,$classe,fwhm2_$etoile) * $zoom ]
        # Angle
        set alpha $data_image($image,$classe,alpha_$etoile)

        # Correction des miroirs
        if { [ visu$::audace(visuNo) mirrorx ] == 1 } {
            set x0 [ expr $naxis1 - $x0 ]
            set alpha [ expr 180.0 - $alpha ]
        }
        if { [ visu$::audace(visuNo) mirrory ] == 1 } {
            set y0 [ expr $naxis2 - $y0 ]
            set alpha [ expr -$alpha ]
        }

        set ellipse [ DessinEllipse $x0 $y0 [ expr $f1 * $facteur ] [ expr $f2 * $facteur ] $alpha $naxis2 ]
        $::audace(hCanvas) create line $ellipse \
            -joinstyle round \
            -fill $couleur \
            -arrow none \
            -smooth true \
            -tags [list astres $marqueur]
    }

    ##
    # @brief : calcul d'une liste de pointreprésentant une ellipse
    # @details Les valeurs de x0, y0 et alpha sont données en coordonnées écran
    #
    proc DessinEllipse { x0 y0 a b alpha naxis2 } {

        Message debug "%s\n" [ info level [ info level ] ]

        set ellipse [list]

        # Conversion de alpha en radian
        set alphar [ expr $alpha * 0.017453 ]
        set c_alpha [ expr cos($alphar) ]
        set s_alpha [ expr sin($alphar) ]

        #Calcul de l'ellipse par son éq. paramétrique :
        # x = a * cos(t), y = b * sin(t)
        # t varie de 0 a 2*pi, par pas de pi/100
        # puis rotation d'angle a et translation  de (x0, y0)
        for { set t 0 } { $t < 6.2831853 } { set t [ expr $t + .0314259265 ] } {
            set x [ expr $a * cos($t) ]
            set y [ expr $b * sin($t) ]
            set X [ expr $x * $c_alpha - $y * $s_alpha + $x0 ]
            set Y [ expr $x * $s_alpha + $y * $c_alpha + $y0 ]
            set px [ expr int($X + 0.5) ]
            set py [ expr $naxis2 - int($Y + 0.5) ]
            lappend ellipse $px $py
        }
        return $ellipse
    }

    proc DessinSymboles { image } {
        variable data_script
        variable data_image
        variable parametres

        # Dessin des symboles
        for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
            # Dessin des axes principaux
            if { $data_image($image,ref,centroide_x_$j) >= 0 } {
                # La modélisation a réussi
                Dessin2 $image ref $j $parametres(rayon1) $::color(green) etoile_$j
                Dessin2 $image ref $j $parametres(rayon2) $::color(green) etoile_$j
                Dessin2 $image ref $j $parametres(rayon3) $::color(green) etoile_$j
                DessinTexte $image ref $j $parametres(rayon3) $::color(green) etoile_$j
            } else {
                # Pas de modélisation possible
                Dessin verticale [ list $data_image($image,ref,centroide_x_$j) $data_image($image,ref,centroide_y_$j) ] \
                    [ list $data_image($image,taille_boite) $data_image($image,taille_boite) ] \
                    $::color(red) etoile_$j
                Dessin horizontale [list $data_image($image,ref,centroide_x_$j) $data_image($image,ref,centroide_y_$j)] \
                    [list $data_image($image,taille_boite) $data_image($image,taille_boite) ] \
                    $::color(red) etoile_$j
            }
        }
        for { set j 0 } { $j < $data_script(nombre_variable) } { incr j } {
            # Dessin des axes principaux
            if {$data_image($image,var,centroide_x_$j) >= 0} {
                # La modélisation a reussi
                Dessin2 $image var $j $parametres(rayon1) $::color(yellow) etoile_$j
                Dessin2 $image var $j $parametres(rayon2) $::color(yellow) etoile_$j
                Dessin2 $image var $j $parametres(rayon3) $::color(yellow) etoile_$j
            } else {
                # Pas de modélisation possible
                Dessin verticale [list $data_image($image,var,centroide_x_$j) $data_image($image,var,centroide_y_$j)] \
                    [list $data_image($image,taille_boite) $data_image($image,taille_boite) ] \
                    $::color(red) etoile_$j
                Dessin horizontale [list $data_image($image,var,centroide_x_$j) $data_image($image,var,centroide_y_$j)] \
                    [list $data_image($image,taille_boite) $data_image($image,taille_boite) ] \
                    $::color(red) etoile_$j
            }
        }
        update
    }

    #*************************************************************************#
    #*************  DestructionCourbesTemporaires  ***************************#
    #*************************************************************************#
    proc DestructionCourbesTemporaires { liste_fenetres } {
        foreach fenetre $liste_fenetres {
            catch { destroy $fenetre }
        }
    }

    #*************************************************************************#
    #*************  EffaceMotif  *********************************************#
    #*************************************************************************#
    proc EffaceMotif { marqueur } {
        global audace

        Message debug "%s\n" [info level [info level]]

        $::audace(hCanvas) delete $marqueur
    }

    #*************************************************************************#
    #*************  Entete  **************************************************#
    #*************************************************************************#
    proc Entete {} {
        variable parametres
        variable data_script

        Message debug "%s\n" [info level [info level]]

        Message notice " No   |         Nom          |        JJ      |    Date    |    Heure   |   M var    +/- "
        TraceFichier " No   |         Nom          |        JJ      |    Date    |    Heure   |   M var    +/- "
        for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
            Message notice "| M ref %2d  +/-  " $etoile
            TraceFichier "| M ref %2d  +/-  " $etoile
        }
        Message notice "|  C mag  | Qualite\n"
        TraceFichier "|  C mag  | Qualite\n"
    }

    #**************************************************************************#
    #*************  PasAPas  **************************************************#
    #**************************************************************************#
    # Fenêtre pour le mode pas à pas utile au débogage                         #
    #**************************************************************************#
    proc PasAPas { } {
        variable calaphot
        variable pas_a_pas

        catch { destroy $calaphot(toplevel,pasapas) }
        if { [ info exists pas_a_pas ] } {
            set calaphot(suite_du_script) 0
            set f [ toplevel $::audace(base).pasapas ]
            set l [ label $f.l -text $calaphot(suite_du_script) -width 3 -height 3 ]
            pack $l -fill both
            bind $f <Shift-S> {
                incr ::CalaPhot::calaphot(suite_du_script)
                $::audace(base).pasapas.l configure -text $::CalaPhot::calaphot(suite_du_script)
            }
            set calaphot(toplevel,pasapas) $f
        }
    }

    #**************************************************************************#
    #*************  PreAffiche  ***********************************************#
    #**************************************************************************#
    # Crée ce qu'il faut pour la courbe de lumière temporaire                  #
    #**************************************************************************#
    proc PreAffiche {i} {
        global audace
        variable data_image
        variable data_script
        variable TempVectors

        Message debug "%s\n" [info level [info level]]

        foreach v [array names TempVectors temp*] {
            global $TempVectors($v)
        }

        if { $data_image($i,qualite) != "mauvaise" } {
            set $TempVectors(temp.x)(++end) $data_image($i,date)

            # Variables
            for { set var 0 } { $var < $data_script(nombre_variable) } { incr var } {
                if { $data_image($i,var,mag_$var) >= 99 } {
                    continue
                }
                set $TempVectors(temp.var.$var)(++end) $data_image($i,var,mag_$var)
            }

            # References
            # Génération du point relatif
            if { $data_script(trace_premier,ref) == 1 } {
                for { set e 0 } { $e < $data_script(nombre_reference) } { incr e } {
                    set data_script(trace_ref_premier_$e,$var) $data_image($i,ref,mag_$e)
                }
                # Pour être sur de ne plus y repasser
                set data_script(trace_premier,ref) 0
            }

            for { set e 0 } { $e < $data_script(nombre_reference) } { incr e } {
                set $TempVectors(temp.ref.$e)(++end) [ expr $data_image($i,ref,mag_$e) - $data_script(trace_ref_premier_$e,$var) ]
            }

            # Constantes des magnitudes
            set $TempVectors(temp.cste)(++end) $data_image($i,constante_mag)
        }
    }

    #*************************************************************************#
    #*************  Retour  **************************************************#
    #*************************************************************************#
    proc Retour {nom_image} {
        global audace

        Message debug "%s\n" [info level [info level]]

        destroy $audace(base).selection_aster
        AffichageMenuAsteroide 1 $nom_image
    }

    #*************************************************************************#
    #*************  SaisieParametres  ****************************************#
    #*************************************************************************#
    proc SaisieParametres {} {
        variable parametres
        variable calaphot
        variable police
        variable calaphot
        variable trace_log
        variable demande_arret

        Message debug "%s\n" [ info level [ info level ] ]

        # Construction de la fenêtre des paramètres
        set calaphot(toplevel,saisie) [ toplevel $::audace(base).saisie -borderwidth 2 -relief groove ]
        set s $calaphot(toplevel,saisie)
        set largeur_ecran_2 [ expr [ winfo screenwidth . ] / 2 ]
        wm geometry $s +320+0
        wm title $s $calaphot(texte,titre_saisie)
        wm protocol $s WM_DELETE_WINDOW ::CalaPhot::Suppression

        # Construction de la trame des listes qui contient les listes et l'ascenseur
        set f [ frame ${s}.listes ]

        # Construction du canevas qui va contenir toutes les trames et des ascenseurs
        set c [ canvas ${f}.canevas \
            -yscrollcommand [ list ${f}.yscroll set ] \
            -width 10 -height 10 ]
        set y [ scrollbar ${f}.yscroll \
            -orient vertical \
            -command [ list $c yview ] ]

        pack $y \
            -side right \
            -fill y
        pack $c \
            -side left \
            -fill both \
            -expand true
        pack $f \
            -side top \
            -fill both \
            -expand true

        # Construction d'une trame qui va englober toutes les listes dans le canevas
        set t [ frame $c.t ]
        $c create window 0 0 \
            -anchor nw \
            -window $t

        #--------------------------------------------------------------------------------
        # Trame des renseignements d'ordre général
        frame $t.trame1 \
            -borderwidth 5 \
            -relief groove
        label $t.trame1.titre \
            -text $calaphot(texte,param_generaux)
        grid $t.trame1.titre \
            -in $t.trame1 \
            -columnspan 2 \
            -sticky ew
        foreach champ { objet \
            operateur \
            code_UAI \
            type_capteur \
            type_telescope \
            diametre_telescope \
            focale_telescope \
            catalogue_reference \
            filtre_optique \
            source \
            indice_premier \
            nombre_images \
            niveau_minimal \
            niveau_maximal \
            signal_bruit \
            gain_camera \
            bruit_lecture \
            sortie } {
            set valeur_defaut($champ) $::CalaPhot::parametres($champ)
            label $t.trame1.l_$champ \
                -text $calaphot(texte,$champ)
            entry $t.trame1.e_$champ \
                -textvariable ::CalaPhot::parametres($champ) \
                -relief sunken
            $t.trame1.e_$champ delete 0 end
            $t.trame1.e_$champ insert 0 $valeur_defaut($champ)
            grid $t.trame1.l_$champ $t.trame1.e_$champ
        }
        #--------------------------------------------------------------------------------
        # Trame du cliquodrome
        set t2 [frame $t.trame2 \
            -borderwidth 5 \
            -relief groove ]

        set ligne 0
        set colonne 0
        label $t2.laffichage \
            -text $calaphot(texte,affichage)
        grid $t2.laffichage \
            -sticky w \
            -row $ligne \
            -column $colonne

        if {[ info exists trace_log ]} {
            set liste_niveau [ list erreur probleme notice info debug ]
        } else {
            set liste_niveau [ list erreur probleme notice info ]
            if { $parametres(niveau_message) == $calaphot(niveau_debug) } {
                set parametres(niveau_message) $calaphot(niveau_info)
            }
        }
        foreach champ $liste_niveau {
            radiobutton $t2.affichage$champ  \
                -variable ::CalaPhot::parametres(niveau_message) \
                -text $calaphot(texte,$champ) \
                -value $calaphot(niveau_$champ)
            incr colonne
            grid $t2.affichage$champ \
                -sticky w \
                -row $ligne \
                -column $colonne
        }

        set ligne 1
        set colonne 0
        label $t2.lmode \
            -text $calaphot(texte,mode)
        grid $t2.lmode \
            -sticky w \
            -row $ligne \
            -column $colonne
        foreach choix { modelisation ouverture sextractor } {
            radiobutton $t2.bmode$choix \
                -variable ::CalaPhot::parametres(mode) \
                -text $calaphot(texte,mode_$choix) \
                -value $choix \
                -command { ::CalaPhot::AffichageVariable $::CalaPhot::parametres(mode) $::audace(base).saisie.listes.canevas $::audace(base).saisie.listes.yscroll $::audace(base).saisie.listes.canevas.t }
            incr colonne
            grid $t2.bmode$choix \
                -sticky w \
                -row $ligne \
                -column $colonne
        }

        set ligne 2
        foreach champ { type_images defocalisation date_images tri_images pose_minute reprise_astres } \
                valeur(0) { non_recalees non debut_pose non seconde non } \
                valeur(1) { recalees oui milieu_pose oui minute oui } {
            label $t2.l$champ \
                -text $calaphot(texte,$champ)
            set colonne 0
            grid $t2.l$champ \
                -row $ligne \
                -column $colonne \
                -sticky w
            for { set i 0 } { $i <= 1 } { incr i } {
                radiobutton $t.trame2.b$i$champ \
                    -variable ::CalaPhot::parametres($champ) \
                    -text $calaphot(texte,${champ}_${i}) \
                    -value $valeur($i)
                incr colonne
                grid $t2.b$i$champ \
                    -row $ligne \
                    -column $colonne \
                    -sticky w
            }
            incr ligne
        }
        #--------------------------------------------------------------------------------
        # Trame spécifique au mode ouverture
        frame $t.trame_ouv \
            -borderwidth 5 \
            -relief groove
        label $t.trame_ouv.titre \
            -text $calaphot(texte,param_ouverture)
        grid $t.trame_ouv.titre \
            -in $t.trame_ouv \
            -columnspan 2

        foreach champ { surechantillonage rayon1 rayon2 rayon3 } {
            set valeur_defaut($champ) $::CalaPhot::parametres($champ)
            label $t.trame_ouv.l$champ \
                -text $calaphot(texte,o_$champ)
            entry $t.trame_ouv.e$champ \
                -textvariable ::CalaPhot::parametres($champ) \
                -width 3 \
                -relief sunken
            $t.trame_ouv.e$champ delete 0 end
            $t.trame_ouv.e$champ insert 0 $valeur_defaut($champ)
            grid $t.trame_ouv.l$champ $t.trame_ouv.e$champ
        }
        #--------------------------------------------------------------------------------
        # Trame spécifique au mode modélisation
        frame $t.trame_mod \
            -borderwidth 5 \
            -relief groove

        #--------------------------------------------------------------------------------
        # Trame spécifique au mode sextractor
        frame $t.trame_sex \
            -borderwidth 5 \
            -relief groove
        #label $t.trame_sex.titre \
            #-text $calaphot(texte,param_sextractor)
        #grid $t.trame_sex.titre \
            #-in $t.trame_sex \
            #-columnspan 2

        #foreach champ {saturation} {
            #set valeur_defaut($champ) $::CalaPhot::parametres($champ)
            #label $t.trame_sex.l$champ \
                #-text $calaphot(texte,s_$champ)
            #entry $t.trame_sex.e$champ \
                #-textvariable ::CalaPhot::parametres($champ) \
                #-width 7 \
                #-relief sunken
            #$t.trame_sex.e$champ delete 0 end
            #$t.trame_sex.e$champ insert 0 $valeur_defaut($champ)
            #grid $t.trame_sex.l$champ $t.trame_sex.e$champ
        #}

        #--------------------------------------------------------------------------------
        # Trame des boutons.
        set t3 [ frame $t.trame3 \
            -borderwidth 5 \
            -relief groove ]
        button $t3.b1 \
            -text $calaphot(texte,continuer) \
            -command {::CalaPhot::ValideSaisie}
        button $t3.b2 \
            -text $calaphot(texte,annuler) \
            -command {::CalaPhot::AnnuleSaisie}
        button $t3.b3 \
            -text $calaphot(texte,aide) \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::CalaPhot::getPluginType ] ] \
               [ ::CalaPhot::getPluginDirectory ] [ ::CalaPhot::getPluginHelp ]"
        pack $t3.b1 $t3.b2 $t3.b3 \
            -side left \
            -padx 10 \
            -pady 10
        AffichageVariable $parametres(mode) $c $y $t
        focus $calaphot(toplevel,saisie)
        grab $calaphot(toplevel,saisie)

        tkwait window $::audace(base).saisie

        return $demande_arret
    }

    #*************************************************************************#
    #*************  SelectionneEtoiles  **************************************#
    #*************************************************************************#
    #                                                                         #
    # Variables modifiees                                                     #
    #  - nombre_reference : incrémente si l'étoile de ref. n'a pas déjà été   #
    #    selectionnee                                                         #
    #  - coord_etoile_x et _y : liste des coord. des étoiles de ref.          #
    #  - data_script(flux_premiere_etoile) : flux de la première étoile de    #
    #    ref. Sert au calcul des magnitudes semi-automatiques pour les autres #
    #    ref.                                                                 #
    #  - mag_etoile :                                                         #
    #  - mag :                                                                #
    #                                                                         #
    #*************************************************************************#
    proc SelectionneEtoiles {} {
        global magnitude_saisie
        variable data_script
        variable parametres
        variable mag
        variable calaphot
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile

        Message debug "%s\n" [ info level  [info level ] ]

        # Recherche de la taille de boite en fonction du fwhm de l'image
        if { ![ info exists data_script(fwhm_selection_etoile) ] } {
            set data_script(fwhm_selection_etoile) [ TailleBoite $::audace(bufNo) ]
        }
        set boite $data_script(fwhm_selection_etoile)

        set mag 0.0

        set pos [ Centroide ]
        if { [ llength $pos ] != 0 } {
            set cx [ lindex $pos 0 ]
            set cy [ lindex $pos 1 ]

            # Recherche si l'étoile a déjà été sélectionnée
            if { [ info exists coord_etoile_x ] } {
                set ix [ lsearch $coord_etoile_x $cx ]
                set iy [ lsearch $coord_etoile_y $cy ]
            } else {
                set ix -1
                set iy -1
            }
            if { ( $ix >=0 ) && ( $iy >=0 ) && ( $ix == $iy ) } {
                tk_messageBox -message $calaphot(texte,etoile_prise) -icon error -title $calaphot(texte,probleme)
            } else {
                # Cas d'une nouvelle étoile
                lappend coord_etoile_x $cx
                lappend coord_etoile_y $cy

                # Calcul pour le pré-affichage des valeurs de magnitudes
                set cxx [ expr int( round( $cx ) ) ]
                set cyy [ expr int( round( $cy ) ) ]
                set q [ calaphot_fitgauss2d $::audace(bufNo) [ list [ expr $cxx - $boite ] [ expr $cyy - $boite ] [ expr $cxx + $boite ] [ expr $cyy + $boite ] ] ]
                if { ![ info exists data_script(flux_premiere_etoile) ] } {
                    set mag_affichage 13.5
                    if { [ lindex $q 1] != 0 } {
                        set data_script(flux_premiere_etoile) [ lindex $q 12 ]
                    }
                } else {
                    if { [lindex $q 1] != 0 } {
                        set mag_affichage [ format "%4.1f" [ expr [ lindex $mag_etoile 0 ] - 2.5 * log10( [ lindex $q 12 ] / $data_script(flux_premiere_etoile) ) ] ]
                    } else {
                        set mag_affichage 13.5
                    }
                }

                # Dessin d'un symbole
                Dessin ovale [list $cx $cy] [list $boite $boite] $::color(green) etoile_${cx}_${cy}
                Dessin verticale [list $cx $cy] [list $boite $boite] $::color(green) etoile_${cx}_${cy}
                Dessin horizontale [list $cx $cy] [list $boite $boite] $::color(green) etoile_${cx}_${cy}

                # La magnitude est saisie dans une trame attaché à celle de la sélection des étoiles
                set ff [ frame $::audace(base).selection_etoile.f2 \
                    -borderwidth 5 \
                    -relief groove ]

                set fft1 [ frame $ff.t1 ]
                label $fft1.lmagnitude \
                    -text $calaphot(texte,magnitude) \
                    -bg $::audace(color,backColor)
                entry $fft1.emagnitude \
                    -width 5 \
                    -textvariable ::CalaPhot::mag \
                    -relief sunken
                $fft1.emagnitude delete 0 end
                $fft1.emagnitude insert 0 $mag_affichage
                pack $fft1.lmagnitude \
                    -fill both \
                    -side left \
                    -expand 1
                pack $fft1.emagnitude \
                    -fill both \
                    -side right \
                    -expand 1

                set fft2 [ frame $ff.t2 \
                    -bg $::audace(color,backColor2) ]
                button $fft2.b1 \
                    -text $calaphot(texte,valider) \
                    -command {
                        global magnitude_saisie
                        grab release $::audace(base).selection_etoile.f2
                        focus $::audace(base).selection_etoile.f1
                        pack forget $::audace(base).selection_etoile.f2
                        destroy $::audace(base).selection_etoile.f2
                        set magnitude_saisie 1
                    } \
                    -bg $::audace(color,backColor2)
                pack $fft2.b1 \
                    -anchor center \
                    -side top \
                    -padx 4 \
                    -pady 4 \
                    -expand 1 \
                    -fill both \
                    -side top

                pack $fft1 $fft2 \
                    -in $ff \
                    -fill both
                pack $ff \
                    -fill both

                focus $fft1.emagnitude
                grab $ff
                tkwait variable magnitude_saisie
                unset magnitude_saisie
                lappend mag_etoile $mag
                incr data_script(nombre_reference)
            }
        }
    }

    #*************************************************************************#
    #*************  SelectionneIndesirables  *********************************#
    #*************************************************************************#
    proc SelectionneIndesirables {} {
        variable data_script
        variable calaphot
        variable coord_indes_x
        variable coord_indes_y

        Message debug "%s\n" [ info level [ info level ] ]

        set pos [ Centroide ]
        if { [ llength $pos ] != 0 } {
            set cx [ lindex $pos 0 ]
            set cy [ lindex $pos 1 ]

            # Recherche si l'étoile a ete deselectionnee
            if { [ info exists coord_indes_x ] } {
                set ix [ lsearch $coord_indes_x $cx ]
                set iy [ lsearch $coord_indes_y $cy ]
            } else {
                set ix -1
                set iy -1
            }
            if { ( $ix >= 0 ) && ( $iy >= 0 ) && ( $ix == $iy ) } {
                tk_messageBox -message $calaphot(texte,etoile_prise) -icon error -title $calaphot(texte,probleme)
            } else {
                # Cas d'une nouvelle étoile
                lappend coord_indes_x $cx
                lappend coord_indes_y $cy
                incr data_script(nombre_indes)
                set i $data_script(nombre_indes)

                # Dessin d'un symbole
                set taille [ TailleBoite $::audace(bufNo) ]
                Dessin ovale [ list $cx $cy ] [ list $taille $taille ] $::color(red) etoile_${cx}_${cy}
                Dessin verticale [ list $cx $cy ] [ list $taille $taille ] $::color(red) etoile_${cx}_${cy}
                Dessin horizontale [ list $cx $cy ] [ list $taille $taille ] $::color(red) etoile_${cx}_${cy}
                Message debug "Etoile indes n%d x=%f y=%f\n" $data_script(nombre_indes) $cx $cy
            }
        } else {
            Message debug "Etoile indesirable introuvable\n"
        }
    }

    #*************************************************************************#
    #*************  SuppressionEtoile  ***************************************#
    #*************************************************************************#
    proc SuppressionEtoile { image j } {
        variable parametres
        variable data_image
        variable data_script
        variable pos_reel

        Message debug "%s\n" [info level [info level]]

        set largeur $data_image($image,taille_boite)

        set x1 [ expr round( [ lindex $pos_reel($image,indes,$j) 0 ] - $largeur ) ]
        set y1 [ expr round( [ lindex $pos_reel($image,indes,$j) 1 ] - $largeur ) ]
        set x2 [ expr round( [ lindex $pos_reel($image,indes,$j) 0 ] + $largeur ) ]
        set y2 [ expr round( [ lindex $pos_reel($image,indes,$j) 1 ] + $largeur ) ]

        if { [ catch { calaphot_fitgauss2d $::audace(bufNo) [ list $x1 $y1 $x2 $y2 ] -sub } t ] } {
            set data_image($image,qualite) "mauvaise"
            set data_script($image,invalidation) $t
            Message debug "image %d etoile %d : $t\n" $image $j
            return
        } else {
            if { [ lindex t 0 ] == 0 } {
                buf$::audace(bufNo) fitgauss [list $x1 $y1 $x2 $y2] -sub
            }
        }
    }

    #*************************************************************************#
    #*************  SuppressionIndesirables  *********************************#
    #*************************************************************************#
    proc SuppressionIndesirables { indice } {
        variable data_script
        variable data_image
        variable pos_reel
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set nombre $data_script(nombre_indes)
        set largeur $data_image($indice,taille_boite)

        for { set j 0 } { $j < $nombre } { incr j } {
            Dessin rectangle $pos_reel($indice,indes,$j) [ list $largeur $largeur ] $::color(red) etoile_$j
            SuppressionEtoile $indice $j
        }
        # Rafraichissement de l'affichage
        VisualisationImage [ lindex $liste_image $indice ]
    }

    #*************************************************************************#
    #*************  ValideSaisie  ********************************************#
    #*************************************************************************#
    ##
    # @brief Validation générale de la saisie des paramètres
    #
    # Si manquent certains champs indispensables à ce script, la fenêtre de saisie des paramètres est maintenue
    # sinon, elle est détruite
    proc ValideSaisie {} {
        variable calaphot
        variable parametres
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        # Recherche si tous les champs critiques sont remplis.
        set pas_glop 0
        foreach champ {source  indice_premier nombre_images signal_bruit gain_camera bruit_lecture sortie fichier_cl} {
            if { $parametres($champ) == "" } {
                set message_erreur $calaphot(texte,champ1)
                append message_erreur $calaphot(texte,$champ)
                append message_erreur $calaphot(texte,champ2)
                tk_messageBox -message $message_erreur -icon error -title $calaphot(texte,probleme)
                set pas_glop 1
                break;
            }
        }

        # Seul le mode phot. d'ouverture permet de traiter le cas des images très fortement défocalisées
        if { ( $parametres(defocalisation) == "oui" ) && ( $parametres(mode) != "ouverture" ) } {
            tk_messageBox -message $calaphot(texte,implication_defoc) -icon error -title $calaphot(texte,probleme)
            set pas_glop 1
        }

        # S'il y a eu un changement, on force la saisie des astres
        set param_critiques [ list \
            source \
            indice_premier \
            nombre_images \
            tri_images \
            type_images \
            pose_minute \
            date_images \
        ]
        if { [ DetectionChangementParamCritiques $param_critiques ] } {
            set parametres(reprise_astres) non
        }

        # MultAster : remplacer cette ligne par qque chose dans SaisieParametres
        set data_script(nom_var_0) $parametres(objet)
        # /MultAster

        if { $pas_glop == 0 } {
            grab release $::audace(base).saisie
            destroy $::audace(base).saisie
            update
        }
    }

    #*************************************************************************#
    #*************  Suppression  *********************************************#
    #*************************************************************************#
    proc Suppression {} {
        # Procédure pour bloquer la suppression des fenêtres esclaves
    }

    proc SelectionFinaleImages {} {
        variable calaphot
        variable liste_image
        variable data_image
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        set tl [ toplevel $::audace(base).selection_finale_images \
            -class Toplevel \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $calaphot(texte,titre_selection_finale)
        wm protocol $tl WM_DELETE_WINDOW ::CalaPhot::Suppression
        wm transient $tl .audace
        set largeur_ecran [ winfo screenwidth . ]
        set hauteur_ecran [ winfo screenheight . ]
        set x_fen [ expr $largeur_ecran / 5 ]
        set y_fen [ expr $hauteur_ecran / 5 ]
        set lmax [ expr $largeur_ecran * 2 / 3 ]
        set hmax [ expr $hauteur_ecran * 3 / 5 ]
        wm geometry $tl +${x_fen}+${y_fen}
        wm maxsize $tl $lmax $hmax

        # Trame du haut (aide)
        set tlh [ frame $tl.haut ]
        label $tlh.l -text "Sélectionner les images à éliminer ou à garder"
        pack $tlh.l

        set tlm [ frame $tl.milieu ]

        # Construction du canevas qui va contenir toutes les trames et des ascenseurs
        set tlmc [ canvas $tlm.canevas \
            -yscrollcommand [ list $tlm.yscroll set ] ]
        set tlmy [ scrollbar $tlm.yscroll \
            -orient vertical \
            -command [ list $tlm.canevas yview ] ]

        pack $tlmy -side right -fill y
        pack $tlmc -side left -fill both -expand true

        # Trame du bas qui va contenir le bouton OK
        set tlb [ frame $tl.bas \
            -borderwidth 2 \
            -relief groove ]

        set tlbb1 [ button $tlb.b1 \
            -text "OK" \
            -command ::CalaPhot::ValidationSelectionFinaleImages ]

        pack $tlbb1 \
            -side left \
            -padx 10 \
            -pady 10 \
            -fill none \
            -expand false

        pack $tlh -expand false -side top
        pack $tlb -expand false -side bottom
        # tlm doit prendre la place restante entre tlh et tlb
        pack $tlm -side top -fill both -expand true

        # Construction d'une trame qui va englober toutes les listes dans le canevas
        set tlf1 [ frame $tlmc.t ]
        $tlmc create window 0 0 \
            -anchor nw \
            -window $tlf1

        label $tlf1.titre_id -text "numéro"
        label $tlf1.titre_nom -text "nom"
        label $tlf1.titre_jj -text "JJ"
        label $tlf1.titre_date -text "Date"
        label $tlf1.titre_erreur -text "Commentaire"
        label $tlf1.titre_oui -text "Eliminée"
        label $tlf1.titre_non -text "Gardée"
        grid $tlf1.titre_id $tlf1.titre_nom $tlf1.titre_jj $tlf1.titre_date $tlf1.titre_erreur $tlf1.titre_oui $tlf1.titre_non

        set ligne 0
        for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
            set image [ lindex $liste_image $i ]
            incr ligne

            if { $data_image($i,qualite) == "mauvaise" } {
                set couleur red
                set data_image($i,elimine) "O"
            } else {
                if { $data_image($i,qualite) == "bonne" } {
                    set couleur green
                    set data_image($i,elimine) "N"
                } else {
                    set couleur orange
                    set data_image($i,elimine) "O"
                }
            }

            set ymdhms [ mc_date2ymdhms $data_image($i,date) ]
            set y [ lindex $ymdhms 0 ]
            set m [ lindex $ymdhms 1 ]
            set d [ lindex $ymdhms 2 ]
            set h [ lindex $ymdhms 3 ]
            set mn [ lindex $ymdhms 4 ]
            set s [ lindex $ymdhms 5 ]
            set date [ format "%04d/%02d/%02d %02d:%02d:%04.1f" $y $m $d $h $mn $s ]

            label $tlf1.${ligne}_id_color_invariant \
                -text $i \
                -relief sunken \
                -foreground $couleur \
                -background  black \
                -borderwidth 2

            label $tlf1.${ligne}_nom_color_invariant \
                -text $image \
                -relief sunken \
                -foreground $couleur \
                -background  black \
                -borderwidth 2

            label $tlf1.${ligne}_jj_color_invariant \
                -text $data_image($i,date) \
                -relief sunken \
                -foreground $couleur \
                -background  black \
                -borderwidth 2

            label $tlf1.${ligne}_date_color_invariant \
                -text $date \
                -relief sunken \
                -foreground $couleur \
                -background  black \
                -borderwidth 2

            if { [ info exists data_script($i,invalidation) ] } {
                set texte "$data_image($i,qualite) : $data_script($i,invalidation)"
            } else {
                set texte $data_image($i,qualite)
            }
            label $tlf1.${ligne}_erreur_color_invariant \
                -text $texte \
                -relief sunken \
                -foreground $couleur \
                -background  black \
                -borderwidth 2

            radiobutton ${tlf1}.${ligne}_oui \
                    -variable ::CalaPhot::data_image($i,elimine) \
                    -value "O"
            radiobutton ${tlf1}.${ligne}_non \
                    -variable ::CalaPhot::data_image($i,elimine) \
                    -value "N"

            if { $data_image($i,qualite) == "mauvaise" } {
                ${tlf1}.${ligne}_oui configure -state disabled
                ${tlf1}.${ligne}_non configure -state disabled
            }

            grid ${tlf1}.${ligne}_id_color_invariant \
                ${tlf1}.${ligne}_nom_color_invariant \
                ${tlf1}.${ligne}_jj_color_invariant \
                ${tlf1}.${ligne}_date_color_invariant \
                ${tlf1}.${ligne}_erreur_color_invariant \
                ${tlf1}.${ligne}_oui \
                ${tlf1}.${ligne}_non \
                -row $ligne \
                -sticky news
        }

        ::confColor::applyColor $tl
        # Il faut que le processus d'affichage ait affiché les fenêtres les plus intérieures
        tkwait visibility $tlf1.1_id_color_invariant

        # L'instruction suivant semble servir pour reqwidth et reqheight
        # Ne pas effacer
        set bbox [ grid bbox $tlf1 0 0 ]
        set incr [lindex $bbox 3]
        # Il faut bien prendre reqwidth et reqheight car c'est ce qui définit la region possible de scroll
        set largeur [ winfo reqwidth $tlf1 ]
        set hauteur [ winfo reqheight $tlf1 ]
        Message debug "largeur = %d / hauteur = %d" $largeur $hauteur
        $tlmc config -scrollregion "0 0 $largeur $hauteur"
        $tlmc config -yscrollincrement $incr
        set ligne_max [ expr $hmax / $incr ]
        if { $ligne > $ligne_max } {
            set $hauteur [ expr $ligne_max * $incr ]
        } else {
            set $hauteur [ expr $ligne * $incr ]
        }
        $tlmc config -width $largeur -height $hauteur

        tkwait window $tl

        return $data_script(nombre_images_gardees)
    }

    proc ValidationSelectionFinaleImages {} {
        variable liste_image
        variable data_script
        variable data_image
        variable calaphot

        Message debug "%s\n" [ info level [ info level ] ]

        set u 0
        for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
            if { $data_image($i,elimine) == "N" } {
                incr u
            }
        }
        Message debug "nombre d'images gardées = %d\n" $u
        set data_script(nombre_images_gardees) $u
        if { $data_script(nombre_images_gardees) < 2 } {
            Message erreur "%s (%d)\n" $calaphot(texte,nom_gardes_faible) $data_script(nombre_images_gardees)
        }
        destroy $::audace(base).selection_finale_images
    }

}

