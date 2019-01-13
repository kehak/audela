##
# @file photometrie.tcl
#
# @author Jacques Michelet (jacques.michelet@aquitania.org)
#
# @brief Outil pour l'analyse photométrique d'une image.
#
# $Id: photometrie.tcl 12795 2016-01-21 20:21:18Z rzachantke $
#

namespace eval ::Photometrie {
    variable photometrie

    catch { unset photometrie }

    ##
    # @brief Séquencement principal des opérations
    proc Principal {} {
        package require http

        variable photometrie_texte
        variable photometrie

        # Message console "%s\n" [ info level  [info level ] ]

        Initialisations

        # Séquenceur
        set tout_va_bien "oui"
        set etape presence_image
        while { $tout_va_bien == "oui" } {
            # Message console "%s %s\n" "etape avant traitement" $etape

            switch -exact -- $etape {
                presence_image {
                    if { [ PresenceImage ] < 0 } {
                        set tout_va_bien "non"
                    }
                    set etape analyse_image
                }

                analyse_image {
                    if { [ catch { AnalyseImage } ] } {
                        set tout_va_bien "non"
                    }
                    set etape selection_reference
                }

                selection_reference {
                    ChoixManuelAutomatique
                    switch -exact -- $photometrie(choix_mode) {
                        arret {
                            set tout_va_bien "non"
                        }
                        auto_internet {
                            if { [ ModeAutoInternet ] != 0 } {
                                set tout_va_bien "non"
                            }
                        }
                        manuel {
                            if { [ ModeManuel ] != 0 } {
                                set tout_va_bien "non"
                            }
                        }
                    }
                    set etape photometrie_ecran
                }

                photometrie_ecran {
                    PhotometrieEcran
                    set etape fin
                }

                default {
                    set tout_va_bien "non"
                }
            }
            # Message console "%s %s\n" "étape après traitement" $etape
            # Message console "%s %s\n" "tout va bien : " $tout_va_bien
        }

        ::confVisu::removeZoomListener $::audace(visuNo) "::Photometrie::ChangementZoom"
    }

    ##
    # @brief initialisation de valeurs par défaut
    proc Initialisations {} {
        variable photometrie

        # Message console "%s\n" [ info level  [info level ] ]
        set photometrie(etat) indefini

        set photometrie(defaut,diametre,interieur) 2.25
        set photometrie(defaut,diametre,exterieur1) 6.0
        set photometrie(defaut,diametre,exterieur2) 8.0
        set photometrie(defaut,carre,modelisation) 4.0

        set photometrie(champ,nomad1) [ list RAJ2000 DEJ2000 NOMAD1 Bmag Rmag ]
        set photometrie(champ,usnob1) [ list RAJ2000 DEJ2000 USNO-B1.0 B1mag R1mag ]
        set photometrie(champ,usnoa2) [ list RAJ2000 DEJ2000 USNO-A2.0 Bmag Rmag ]
        set photometrie(champ,ucac3) [ list RAJ2000 DEJ2000 3UC Bmag R2mag ]
        set photometrie(champ,loneos) [ list RAJ2000 DEJ2000 LN Bmag R2mag ]


        set photometrie(mode_debug) 0
        calaphot_niveau_traces 0

        # Pour la gestion dynamique des zooms
        ::confVisu::addZoomListener $::audace(visuNo) { ::Photometrie::ChangementZoom }
    }

    ##
    # @brief Détecte la présence d'une image valide
    #### param[out] photometrie(astrometrie) = 1 si l'image contient tous les mot-clés, 0 sinon
    # @return -1 si l'image est absente ou non pertinente
    proc PresenceImage {} {
        variable photometrie_texte
        variable photometrie

        # Message console "%s\n" [ info level  [info level ] ]

        #--- Recherche une image dans le buffer
        if { [ buf$::audace(bufNo) imageready ] == "0" } {
            tk_messageBox -message "$photometrie_texte(err_pas_d_image)" -title "$photometrie_texte(titre_menu)" -icon error
            return -1
        }

        #--- Recherche du type d'image
        if { [ lindex [ buf$::audace(bufNo) getkwd NAXIS ] 1 ] == "1" } {
            tk_messageBox -message "$photometrie_texte(err_spectro)" -title "$photometrie_texte(titre_menu)" -icon error
            return -1
        }
        return 0
    }

    ##
    # @brief Calcul du champ couvert par l'image
    # return : le champ en arcmin sur la diagonale
    proc CalculChampImage {} {
        variable photometrie

        #Message console "%s\n" [ info level [ info level ] ]

        # Récupération des ad et dec des points extrêmes de l'image
        set addec1 [ buf$::audace(bufNo) xy2radec [ list 1 1 ] ]
        set addec2 [ buf$::audace(bufNo) xy2radec [ list $photometrie(naxis1) $photometrie(naxis2) ] ]

        # Conversion en radian
        set a1 [ expr [ lindex $addec1 0 ] * 0.01745 ]
        set d1 [ expr [ lindex $addec1 1 ] * 0.01745 ]
        set a2 [ expr [ lindex $addec2 0 ] * 0.01745 ]
        set d2 [ expr [ lindex $addec2 1 ] * 0.01745 ]

        # Calcul du champ de la diagonale en arcmin
        set coschamp [ expr sin($d1) * sin($d2) + cos($d1) * cos($d2) * cos($a1 - $a2) ]
        set champ [ expr acos($coschamp) * 3437.75 ]

        return [ expr int(ceil($champ)) ]
    }

    ##
    # @brief Recherche de mots-clés typiques d'une image recalée astrométriquement
    # param[out] photometrie(astrometrie) = 1 si l'image contient tous les mot-clés, 0 sinon
    # param[out] photometrie(internet) si l'image est recalée astrométriquement et si le champ a une taille inférieure à 30 min d'arc
    proc AnalyseImage {} {
        variable photometrie_texte
        variable photometrie

        # Message console "%s\n" [ info level  [info level ] ]

        set photometrie(astrometrie) 1
        set liste_cle [ buf$::audace(bufNo) getkwds ]
        foreach cle_majuscule [ list NAXIS1 NAXIS2 ] {
            set cle [ string tolower $cle_majuscule ]
            if { [ lsearch -exact $liste_cle $cle_majuscule ] > 0 } {
                set photometrie($cle) [ lindex [ buf$::audace(bufNo) getkwd $cle_majuscule ] 1 ]
            } else {
                ::console::affiche_erreur "$photometrie_texte(err_pas_astrometrie) $cle_majuscule\n"
                return -code error
            }
        }

        # Positionnement des valeurs min et max possibles pour les intensités des pixels
        switch -exact -- [ buf$::audace(bufNo) bitpix ] {
            byte { photom_minmax [ list 0 255 ] }
            short { photom_minmax [ list -32768 32767 ] }
            ushort { photom_minmax [ list 0 65535 ] }
            long { photom_minmax [ list -2147483648 2147483647 ] }
            ulong { photom_minmax [ list 0 4294967295 ] }
            float { photom_minmax [ list -3.4e+38 3.4e+38 ] }
            double { photom_minmax [ list -1.7e+308 1.7e+308 ] }
        }

        if { [ catch { buf$::audace(bufNo) xy2radec [ list 1 1 ] } ] } {
            ::console::affiche_erreur "$photometrie_texte(err_pas_astrometrie)\n"
            set photometrie(astrometrie) 0
        }

        if { $photometrie(astrometrie) == 1 } {
            set photometrie(champ) [ CalculChampImage ]
            # Limite à 45 minutes d'arc
            if { $photometrie(champ) > 45 } {
                ::console::affiche_erreur "$photometrie_texte(err_champ_trop_large) : $photometrie(champ) ' \n"
                set photometrie(internet) 0
            } else {
                set photometrie(internet) 1
            }
        } else {
            set photometrie(internet) 0
        }

        return -code ok
    }


    ##
    # @brief Colorie l'étoile sélectionnée en vert, les autres en rouge.
    # @details Très important pour la suite : stocke l'id de l'étoile sélectionnée.
    proc AnimationSelectionCatalogue { fen id } {
        variable photometrie

        # Animation sur l'image
        $::audace(hCanvas) itemconfigure ovale_$photometrie(ancienne_selection) -outline red
        $::audace(hCanvas) itemconfigure texte_$photometrie(ancienne_selection) -fill red
        $::audace(hCanvas) itemconfigure ovale_$photometrie(selection_reference) -outline green
        $::audace(hCanvas) itemconfigure texte_$photometrie(selection_reference) -fill green

        # Animation sur la fenêtre de sélection
        ::confColor::applyColor $fen
        ${fen}.${photometrie(selection_reference)}_$photometrie(selection_couleur) configure -foreground blue

        set photometrie(ancienne_selection) $photometrie(selection_reference)
        set photometrie(selection,id) $id
    }

    ##
    # @brief Affichage des valeurs de photométrie (référence et variable)
    # @return id de la fenetre d'affichage
    proc CadreMesurePhotometrie {} {
        variable photometrie_texte
        variable photometrie
        variable data

        set tl [ toplevel $::audace(base).photometrie_mesure \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace

        set tlf1 [ frame $tl.f1 ]

        set tlf1f1 [ frame $tlf1.f1 -borderwidth 1 -relief solid ]
        set tlf1f1l [ label $tlf1f1.l ]
        grid $tlf1f1l -columnspan 2
        set tlf1f1l00 [ label $tlf1f1.l00 ]
        set tlf1f1l01 [ label $tlf1f1.l01 \
            -text $photometrie_texte(nom) ]
        grid $tlf1f1l00 $tlf1f1l01
        set tlf1f1l10 [ label $tlf1f1.l10 \
            -text $photometrie_texte(reference) ]
        set tlf1f1l11 [ label $tlf1f1.l11 \
            -text $photometrie(reference,nom) ]
        grid $tlf1f1l10 $tlf1f1l11
        set tlf1f1l20 [ label $tlf1f1.l20 \
            -text $photometrie_texte(mesure) ]
        set tlf1f1l21 [ label $tlf1f1.l21 ]
        grid $tlf1f1l20 $tlf1f1l21

        set tlf1f2 [ frame $tlf1.f2  -borderwidth 1 -relief solid ]
        set tlf1f2l [ label $tlf1f2.l \
            -text $photometrie_texte(ouverture) ]
        grid $tlf1f2l -columnspan 2
        set tlf1f2l00 [ label $tlf1f2.l00 \
            -text $photometrie_texte(magnitude) ]
        set tlf1f2l01 [ label $tlf1f2.l01 \
            -text $photometrie_texte(flux) ]
        grid $tlf1f2l00 $tlf1f2l01
        set tlf1f2l10 [ label $tlf1f2.color_invariant_l10 \
            -text $photometrie(reference,magnitude) \
            -fg red \
            -bg $::audace(color,backColor) ]
        set tlf1f2l11 [ label $tlf1f2.color_invariant_l11 \
            -text "---" \
            -fg red \
            -bg black ]
        grid $tlf1f2l10 $tlf1f2l11
        set tlf1f2l20 [ label $tlf1f2.color_invariant_l20 \
            -text "---" \
            -fg red \
            -bg black ]
        set tlf1f2l21 [ label $tlf1f2.color_invariant_l21 \
            -text "---" \
            -fg red \
            -bg black ]
        grid $tlf1f2l20 $tlf1f2l21
        set photometrie(label_flux_ouv_ref) $tlf1f2l11
        set photometrie(label_flux_ouv_inc) $tlf1f2l21
        set photometrie(label_mag_ouv_inc) $tlf1f2l20

        set tlf1f3 [ frame $tlf1.f3  -borderwidth 1 -relief solid ]
        set tlf1f3l [ label $tlf1f3.l \
            -text $photometrie_texte(modelisation) ]
        grid $tlf1f3l -columnspan 2
        set tlf1f3l00 [ label $tlf1f3.l00 \
            -text $photometrie_texte(magnitude) ]
        set tlf1f3l01 [ label $tlf1f3.l01 \
            -text $photometrie_texte(flux) ]
        grid $tlf1f3l00 $tlf1f3l01
        set tlf1f3l10 [ label $tlf1f3.color_invariant_l10 \
            -text $photometrie(reference,magnitude) \
            -fg DarkGreen \
            -bg $::audace(color,backColor) ]
        set tlf1f3l11 [ label $tlf1f3.l_color_invariant_11 \
            -text "---" \
            -fg green \
            -bg black ]
        grid $tlf1f3l10 $tlf1f3l11
        set tlf1f3l20 [ label $tlf1f3.color_invariant_l20 \
            -text "---" \
            -fg green \
            -bg black ]
        set tlf1f3l21 [ label $tlf1f3.color_invariant_l21 \
            -text "---" \
            -fg green \
            -bg black ]
        grid $tlf1f3l20 $tlf1f3l21
        set photometrie(label_flux_mod_ref) $tlf1f3l11
        set photometrie(label_flux_mod_inc) $tlf1f3l21
        set photometrie(label_mag_mod_inc) $tlf1f3l20

        grid $tlf1f1 $tlf1f2 $tlf1f3
        grid $tlf1

        set tlf2 [ frame $tl.f2 \
            -borderwidth 1 \
            -relief solid ]
        set tlf2ltitre [ label $tlf2.ltitre \
            -text $photometrie_texte(param_ouv) ]
        grid $tlf2ltitre -columnspan 2
        foreach champ [ list interieur exterieur1 exterieur2 ] {
            label $tlf2.l$champ \
                -text $photometrie_texte($champ)
            entry $tlf2.e$champ \
                -textvariable ::Photometrie::photometrie(diametre,$champ) \
                -width -1 \
                -relief sunken
            $tlf2.e$champ delete 0 end
            $tlf2.e$champ insert 0 $photometrie(defaut,diametre,$champ)
            bind $tlf2.e$champ <Return> { ::Photometrie::ChangementsCercles %W }
            grid $tlf2.l$champ $tlf2.e$champ
        }
        grid $tlf2

        set tlf3 [ frame $tl.f3 \
            -borderwidth 5 \
            -relief groove ]

        set tlf3b [ button $tlf3.b \
            -text $photometrie_texte(fin) \
            -command {
                $::audace(hCanvas) delete photom
                bind $::audace(hCanvas) <Motion> {}
                bind $::audace(hCanvas) <ButtonRelease> {}
                $::audace(hCanvas) configure -cursor $::Photometrie::photometrie(fleche_souris)
                catch { unset ::Photometrie::data }
                unset ::Photometrie::photometrie
                destroy $::audace(base).photometrie_mesure
            } ]
        pack $tlf3b \
            -side left \
            -padx 10 \
            -pady 10
        grid $tlf3

        ::confColor::applyColor $tl
        update idletasks

        return $tl
    }

    ##
    # @brief Calcul sur l'objet pointé par la souris
    # @param canevas sur lequel s'éxécute le mouvement
    # @param xe abscisse de la souris dans le canevas (repère écran)
    # @param ye ordonnée de la souris dans le canevas (repère écran)
    proc CalculFluxMagnitude { canevas xe ye } {

        set xe [ $canevas canvasx $xe ]
        set ye [ $canevas canvasy $ye ]

        set xyi [ ConvEcranImage [ list $xe $ye ] ]
        MesureFlux inc $xyi
        CalculMagnitude
    }

    proc CalculMagnitude {} {
        variable photometrie

        if { ( [ lindex $photometrie(flux_mod_ref) 1 ] > 0 ) && ( [ lindex $photometrie(flux_mod_inc) 1 ]  > 0 ) } {
            set photometrie(magnitude_inc,mod) [ expr $photometrie(reference,magnitude) + 2.5 * log10( [ lindex $photometrie(flux_mod_ref) 1 ] / [ lindex $photometrie(flux_mod_inc) 1 ] ) ]
            $photometrie(label_mag_mod_inc) configure -text [ format "%.3f" $photometrie(magnitude_inc,mod) ]
        } else {
            set photometrie(magnitude_inc,mod) 99
            $photometrie(label_mag_mod_inc) configure -text "???"
        }

        if { ( $photometrie(flux_ouv_ref) > 0 ) && ( $photometrie(flux_ouv_inc)  > 0 ) } {
            set photometrie(magnitude_inc,ouv) [ expr $photometrie(reference,magnitude) + 2.5 * log10( $photometrie(flux_ouv_ref) / $photometrie(flux_ouv_inc) ) ]
            $photometrie(label_mag_ouv_inc) configure -text [ format "%.3f" $photometrie(magnitude_inc,ouv) ]
        } else {
            set photometrie(magnitude_inc,ouv) 99
            $photometrie(label_mag_ouv_inc) configure -text "???"
        }
    }

    ##
    # @brief Prise en compte des modifications de la taille des cercles d'ouverture
    proc ChangementsCercles { entree } {
        variable photometrie_texte
        variable photometrie

        set valeur_ok 1
        foreach cercle [ list interieur exterieur1 exterieur2 ] {
            set valeur $photometrie(diametre,$cercle)
            if { [ string is integer -strict $valeur ] || [ string is double -strict $valeur ] } {
                if { $valeur <= 0 } {
                    set valeur_ok 0
                }
            } else {
                set valeur_ok 0
            }
        }

        if { $valeur_ok == 0 } {
            tk_messageBox -message $photometrie_texte(err_nombre_positif) -title "$photometrie_texte(titre_menu)" -icon error
            $entree delete 0 end
            return
        }

        if { $photometrie(diametre,interieur) > $photometrie(diametre,exterieur1) } {
            tk_messageBox -message $photometrie_texte(err_dia_interieur) -title "$photometrie_texte(titre_menu)" -icon error
            $entree delete 0 end
            return
        }

        if { $photometrie(diametre,exterieur1) >= $photometrie(diametre,exterieur2) } {
            tk_messageBox -message $photometrie_texte(err_dia_exterieur) -title "$photometrie_texte(titre_menu)" -icon error
            $entree delete 0 end
            return
        }

        # Récupération des coordonnées des tags
        set boite [ $::audace(hCanvas) bbox ref ]
        set xe [ expr ( [ lindex $boite 0 ] + [ lindex $boite 2 ] ) / 2 ]
        set ye [ expr ( [ lindex $boite 1 ] + [ lindex $boite 3 ] ) / 2 ]
        DessinCercles ref [ list $xe $ye ]
        set xyi [ ConvEcranImage [ list $xe $ye ] ]
        MesureFlux ref $xyi

        set boite [ $::audace(hCanvas) bbox inc ]
        set xe [ expr ( [ lindex $boite 0 ] + [ lindex $boite 2 ] ) / 2 ]
        set ye [ expr ( [ lindex $boite 1 ] + [ lindex $boite 3 ] ) / 2 ]
        DessinCercles inc [ list $xe $ye ]
        set xyi [ ConvEcranImage [ list $xe $ye ] ]
        MesureFlux inc $xyi
        CalculMagnitude
    }

    ##
    # @brief Call-back pour les changement au niveau de l'affichage : retrace les graphismes insérés à l'image
    proc ChangementZoom { args } {
        variable photometrie

        #set zoom [ visu$::audace(visuNo) zoom ]
        #::console::affiche_resultat "Le zoom vaut $zoom\n"
        #::console::affiche_resultat "photometrie(etat)=$photometrie(etat)\n"
        if { $photometrie(etat) == "selection_etoiles_reference" } {
            AffichageEtoilesReference
        }
        if { $photometrie(etat) == "photometrie_ecran" } {
            set xy_ecran [ ConvImageEcran $photometrie(reference,xy) ]
            DessinCercles ref $xy_ecran
            DessinTexte ref $xy_ecran
        }
    }

    ##
    # @brief Permet de choisir entre le catalogue internet
    # @return photometrie(cata_internet)
    proc ChoixCatalogueInternet {} {
        variable photometrie_texte
        variable photometrie

        set tl [ toplevel $::audace(base).photometrie_cata_internet \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace

        set tlf1 [ frame $tl.f1 \
            -borderwidth 5 \
            -relief groove ]

        set photometrie(cata_internet) nomad1
        foreach cata_internet [ list usnoa2 usnob1 ucac3 nomad1 ] {
            radiobutton $tlf1.rb_$cata_internet -variable ::Photometrie::photometrie(cata_internet) -text $photometrie_texte($cata_internet) -value $cata_internet
            pack $tlf1.rb_$cata_internet -fill both -expand true
        }

        set tlf2 [ frame $tl.f2 \
            -borderwidth 5 \
            -relief groove ]

        set tlf2b1 [ button $tlf2.b1 \
            -text $photometrie_texte(ok) \
            -command {
                destroy $::audace(base).photometrie_cata_internet
                set ::Photometrie::photometrie(choix_mode) 0
            } ]
        set tlf2b2 [ button $tlf2.b2 \
            -text $photometrie_texte(arret) \
            -command {
                destroy $::audace(base).photometrie_cata_internet
                set ::Photometrie::photometrie(choix_mode) -1
            } ]
        pack $tlf2b1 $tlf2b2 \
            -side left \
            -padx 10 \
            -pady 10

        pack $tlf1 $tlf2

        #--- Mise à jour dynamique des couleurs
        ::confColor::applyColor $tl
        update idletasks

        tkwait window $tl

        return $photometrie(choix_mode)
    }

    ##
    # @brief Permet de choisir entre le mode manuel, le mode catalogue local (plus tard) ou le mode catalogue internet
    proc ChoixManuelAutomatique {} {
        variable photometrie_texte
        variable photometrie

        # Message console "%s\n" [ info level  [info level ] ]

        # Si pas de recalage astrométrique, pas de possibilité de récupérer un catalogue local ou distant
        if { $photometrie(astrometrie) == 0 } {
            ::console::affiche_erreur "$photometrie_texte(err_pas_internet) \n"
            set photometrie(choix_mode) manuel
            return
        }

        # Temporaire en attendant le mode catalogue local qui pourra être valide
        #if { $photometrie(internet) == 0 } {
            #::console::affiche_erreur "$photometrie_texte(err_pas_internet) \n"
            #set photometrie(choix_mode) manuel
            #return
        #}

        set tl [ toplevel $::audace(base).photometrie_auto_manuel \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace

        set tlf1 [ frame $tl.f1 \
            -borderwidth 5 \
            -relief groove ]

        set photometrie(choix_mode) manuel
        set liste_choix [ list manuel ]
        if { $photometrie(internet) == 1 } {
            lappend liste_choix auto_internet
            set photometrie(choix_mode) auto_internet
        }

        # Si le choix est réduit, pas d'écran de sélection
        if { [ llength $liste_choix ] == 1 } {
            set photometrie(choix_mode) manuel
            destroy $tl
            return
        }

        foreach choix $liste_choix {
            radiobutton $tlf1.rb_$choix -variable ::Photometrie::photometrie(choix_mode) -text $photometrie_texte($choix) -value $choix
            pack $tlf1.rb_$choix -fill both -expand true
        }

        set tlf2 [ frame $tl.f2 \
            -borderwidth 5 \
            -relief groove ]

        set tlf2b1 [ button $tlf2.b1 \
            -text $photometrie_texte(ok) \
            -command {
                destroy $::audace(base).photometrie_auto_manuel
            } ]
        set tlf2b2 [ button $tlf2.b2 \
            -text $photometrie_texte(arret) \
            -command {
                set ::Photometrie::photometrie(choix_mode) arret
                destroy $::audace(base).photometrie_auto_manuel
            } ]
        pack $tlf2b1 $tlf2b2 \
            -side left \
            -padx 10 \
            -pady 10

        pack $tlf1 $tlf2

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $tl
        update idletasks

        tkwait window $tl
    }

    ##
    # @brief Transformation de coordonnées écran (canevas) en coordonnées image
    # @param xye liste des coordonnées dans le repère écran
    # @return liste des coordonnées dans le repère image
    proc ConvEcranImage { xye } {
        variable photometrie_texte
        variable photometrie

        set zoom [ visu$::audace(visuNo) zoom ]
        set xi [ expr [ lindex $xye 0 ] / $zoom ]
        set yi [ expr $photometrie(naxis2) - [ lindex $xye 1 ] / $zoom ]
        return [ list $xi $yi ]
    }

    ##
    # @brief Transformation de coordonnées image en coordonnées écran (canevas)
    # @param xyi liste des coordonnées dans le repère image
    # @return liste des coordonnées dans le repère écran
    proc ConvImageEcran { xyi } {
        variable photometrie

        set zoom [ visu$::audace(visuNo) zoom ]
        set xe [ expr [ lindex $xyi 0 ] * $zoom ]
        set ye [ expr ( $photometrie(naxis2) - [ lindex $xyi 1 ] ) * $zoom ]
        return [ list $xe $ye ]
    }

    ##
    # @brief Lecture de la première ligne du fichier pour trouver la position des champs
    # @param fichier canal du fichier catalogue
    # @return 0 si on trouve tous les champs, -1 sinon
    proc RecherchePositionDonnees { fichier } {
        variable photometrie

        set catalogue $photometrie(cata_internet)

        # Recherche de la première ligne non commentée (cad qui ne commence pas par un #)
        set trouve 0
        while { ( ( $trouve == 0 ) && ( [ gets $fichier ligne ] >= 0 ) ) } {
            set liste_ligne [ split $ligne \t ]
            if { [ llength $liste_ligne ] != 0 } {
                set premier_mot [ lindex $liste_ligne 0 ]
                set premier_car [ string index $premier_mot 0 ]
                if { $premier_car != "#" } {
                    set trouve 1
                }
            }
        }
        if { $trouve == 0 } {
            # On a atteint la fin du fichier, et pas de ligne non commentée. Donc erreur.
            return -1
        }

        # Message console "%s %s\n" $premier_car $liste_ligne
        set probleme 0
        foreach champ_catalogue $photometrie(champ,$catalogue) champ_script [ list ad dec nom mag_b mag_r ] {
            set t [ lsearch -exact $liste_ligne $champ_catalogue ]
            if { $t < 0 } {
                set probleme -1
            } else {
                set photometrie(position,$catalogue,$champ_script) $t
            }
        }
        return $probleme
    }

    ##
    # @brief Lecture du catalogue, et création d'une base de donnée indexée par les magnitudes
    # @return -1 en cas de probleme, 0 sinon
    proc CreationBaseDonnées {} {
        variable photometrie
        variable photometrie_texte

        set catalogue $photometrie(cata_internet)

        catch { unset data }
        catch { unset index_rouge }
        catch { unset index_bleu }

        variable data
        variable index_rouge
        variable index_bleu

        set uid 0
        if { [ catch { open $photometrie(catalogue) r } f ] } {
            tk_messageBox -message "$f" -title "$photometrie_texte(titre_menu)" -icon error
            return -1
        }
        if { [ RecherchePositionDonnees $f ] < 0 } {
            tk_messageBox -message "$photometrie_texte(err_champ_catalogue)" -title "$photometrie_texte(titre_menu)" -icon error
            close $f
            return -1
        }
        set indice 0
        while { [ gets $f ligne ] > 0 } {
            set liste_ligne [ split $ligne \t ]
            # Message console "%s\n" $liste_ligne
            set cle_rouge [ lindex $liste_ligne $photometrie(position,$catalogue,mag_r) ]
            set cle_bleue [ lindex $liste_ligne $photometrie(position,$catalogue,mag_b) ]
            # Message console "cr %s\n" $cle_rouge
            # Base à double clé
            # index_rouge a pour clé la magnitude rouge, et pour valeur un id unique (idem pour index_bleu)
            # data a pour clé l'id unique, et contient toutes les données du catalogue.
            # Donc, on peut, à partir de la magnitude rouge (ou bleue), retrouver toutes les données d'une étoile dans le catalogue.
            set data([ incr uid ]) $liste_ligne
            # Il faut que les 2 magnitudes rouge et bleue soient définies pour qu'on stocke l'id de l'étoile
            if { [ string is double -strict $cle_rouge ] && [ string is double -strict $cle_bleue ] } {
                lappend index_rouge($cle_rouge) $uid
                lappend index_bleu($cle_bleue) $uid
            }
        }
        close $f
        if { $photometrie(mode_debug) == 0 } {
            # Toutes les données sont dans data(), plus besoin du fichier catalogue
            file delete $photometrie(catalogue)
        }

        return 0
    }

    ##
    # @brief Dessin des textes accompagnant les étoiles
    # @param tag du texte à gérer
    # @param xy liste des coordonnées dans le repère écran
    proc DessinTexte { tag xy } {
        variable photometrie

        $::audace(hCanvas) delete texte_$tag

        set zoom [ visu$::audace(visuNo) zoom ]
        set fwhm $photometrie(fwhm)

        set xy $photometrie(reference,xy)
        set x [ expr round( [ lindex $xy 0 ] ) ]
        set y [ expr round( [ lindex $xy 1 ] ) ]
        $::audace(hCanvas) create text \
            [ expr $x * $zoom ] \
            [ expr ( $photometrie(naxis2) - $y ) * $zoom - 3 * $fwhm ] \
            -text $photometrie(reference,nom) \
            -tags [ list photom texte_$tag ]\
            -fill red \
            -anchor n \
    }

    ##
    # @brief Dessin des cercles représentant les ouvertures
    # @param tag du texte à gérer
    # @param xy liste des coordonnées dans le repère écran
    proc DessinCercles { tag xy } {
        variable photometrie

        $::audace(hCanvas) delete cercle_$tag

        set zoom [ visu$::audace(visuNo) zoom ]
        set fwhm $photometrie(fwhm)

        set x [ lindex $xy 0 ]
        set y [ lindex $xy 1 ]
        foreach cercle [ list interieur exterieur1 exterieur2 ] {
            set rayon [ expr $photometrie(diametre,$cercle) * $fwhm / 2 *$zoom ]
            $::audace(hCanvas) create oval \
                [ expr $x - $rayon ] \
                [ expr $y + $rayon ] \
                [ expr $x + $rayon ] \
                [ expr $y - $rayon ] \
                -outline red \
                -width 1 \
                -tags [ list photom cercle_$tag $cercle ]
        }
#        $::audace(hCanvas) itemconfigure exterieur1 -dash { 3 6 3 3 }
#        $::audace(hCanvas) itemconfigure exterieur2 -dash { 3 6 3 3 }

#        set demi_largeur [ expr $photometrie(defaut,carre,modelisation) * $fwhm / 2 * $zoom ]
#        $::audace(hCanvas) create rectangle \
            [ expr $x - $demi_largeur ] \
            [ expr $y + $demi_largeur ] \
            [ expr $x + $demi_largeur ] \
            [ expr $y - $demi_largeur ] \
            -outline green \
            -width 1 \
            -tags [ list photom $tag carre ]
    }

    ##
    # @brief Mise en place des évènements souris
    proc GestionSouris {} {

        # Message console "%s\n" [ info level  [ info level ] ]

        variable photometrie_texte
        variable photometrie

        set xy_image [ list 1 1 ]
        set xy_ecran [ ConvImageEcran $xy_image ]
        DessinCercles inc $xy_ecran
        set photometrie(coord_souris) $xy_ecran
        set photometrie(fleche_souris) [ $::audace(hCanvas) cget -cursor ]
        $::audace(hCanvas) configure -cursor { tcross blue }
        bind $::audace(hCanvas) <Motion> { ::Photometrie::MouvementSouris %W %x %y }
        bind $::audace(hCanvas) <ButtonRelease> { ::Photometrie::CalculFluxMagnitude %W %x %y }
    }


    ##
    # @brief Requête HTTP de type POST sur Vizier
    # @return -1 en cas d'échec, 0 sinon
    proc InterfaceHttp {} {
        variable photometrie_texte
        variable photometrie

        set erreur 0
        set photometrie(catalogue) [ file join $::audace(rep_travail) photometrie.txt ]
        file delete $photometrie(catalogue)

        # Récupération des coordonnées (le champ est déjà connu)
        set res [ buf$::audace(bufNo) xy2radec [ list [ expr $photometrie(naxis1) / 2 ] [ expr $photometrie(naxis2) / 2 ] ] ]
        set ra [ lindex $res 0 ]
        set dec [ lindex $res 1 ]
        set coords "$ra $dec"

        switch -exact -- $photometrie(cata_internet) {
            usnoa2 { set catalog "USNOA2" }
            usnob1 { set catalog "USNOB1" }
            nomad1 { set catalog "NOMAD1" }
            ucac3 { set catalog "UCAC3" }
            loneos { set catalog "LONEOS" }
        }

        # Création de la requête
        catch { unset requete }
        set requete [ ::http::formatQuery "-mime" "tsv" "-source" $catalog "-out" "**" "-c" $coords "-c.rm" $photometrie(champ) ]
        # Message console "%s\n" $requete

        #::http::config -proxyhost "blablabla" -proxyport 8080

        # Calcul du temps d'attente max
        # Empirisme : 1 s par minute d'arc
        set temps_attente_max [ expr $photometrie(champ) * 1000 ]
        # Voir les commentaires sur ::http:geturl plus bas
        if { $temps_attente_max > 20000 } {
            set temps_attente_max 20000
        }

        # Fenêtre informative pour faire patienter
        set tl [ toplevel $::audace(base).photometrie_http_vizier \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace
        label $tl.l1 -text "$photometrie_texte(temps_attente_chargement) [ expr $temps_attente_max / 1000 ] s"
        label $tl.l2 -text $photometrie_texte(patience)
        pack $tl.l1 $tl.l2
        ::confColor::applyColor $tl
        update

        # la routine :http::geturl a un comportement très spécial.
        # Le mode -command la rend non bloquante, les timers continuent de courir, et c'est bien comme ça
        # Si la commande ne peut pas envoyer la requête (pb de proxy, par ex.), elle ne rend pas la main (bien qu'étant non bloquante). Donc tcl n'exécute pas les instruction suivantes (vwait ou tkwait). De plus, # elle a un timout interne fixé en dur à 20s, sans possibilité de le changer apparement.
        # Si la requête peut partir, elle rend la main tout de suite.
        # D'où cette bizarrerie sur photometrie(synchro) pour tenir compte des 2 cas.
        set photometrie(synchro) 0
        ::http::geturl http://vizier.u-strasbg.fr/viz-bin/asu-tsv -query $requete -blocksize 4096 -timeout $temps_attente_max -command ::Photometrie::FinHttp -progress ::Photometrie::ProgressionHttp
        if { $photometrie(synchro) == 0 } {
            vwait ::Photometrie::photometrie(synchro)
        }

        if { ![ file exists $photometrie(catalogue) ] } {
            tk_messageBox -message "$photometrie_texte(err_reseau)" -title "$photometrie_texte(titre_menu)" -icon error
            set erreur -1
        }

        return $erreur
    }

    ##
    # @brief Callback appelé tous les "blocksize" octets reçus
    proc ProgressionHttp { token total current } {
        # Sert au debogage
        # Message console "p"
    }

    ##
    # @brief Callback appelé à la fin de la requête sur Vizier
    proc FinHttp { token } {
        variable photometrie

        set e [ ::http::status $token ]
        if { $e != "ok" } {
            # Message console "status %s\n" $e
            # Message console "error %s\n" [ ::http::error $token ]
        } else {
            # Message console "status %s\n" $e
            set a [ ::http::ncode $token ]
            # Message console "ncode %s\n" $a
            if { $a == 200 } {
                set fout [ open $photometrie(catalogue) w ]
                puts $fout [ ::http::data $token ]
                close $fout
            }
        }
        destroy $::audace(base).photometrie_http_vizier
        set photometrie(synchro) 1
        ::http::cleanup $token
    }

    proc Message { niveau args } {
        switch -exact -- $niveau {
            console {
                ::console::disp [ eval {format} $args ]
                update idletasks
            }
        }
    }

    ##
    # @brief Mesure et affichage des flux par modélisation et ouverture
    # @param tag de l'objet (reference ou inconnu)
    # @param xy liste des coordonnées dans le repère image
    #
    proc MesureFlux { tag xy } {
        variable photometrie
        variable photometrie_texte

        set fwhm $photometrie(fwhm)
        set f $photometrie(defaut,carre,modelisation)
        if { $photometrie(mode_debug) != 0 } {
            Message console "fwhm=%f\n" $fwhm
            Message console "f=%f\n" $f
        }

        set photometrie(flux_mod_$tag) [ Modelisation $xy ]
        if { [ lindex $photometrie(flux_mod_$tag) 0 ] < 0 } {
            $photometrie(label_flux_mod_$tag) configure -text "???"
        } else {
            $photometrie(label_flux_mod_$tag) configure -text [ expr round( [ lindex $photometrie(flux_mod_$tag) 1 ] + 0.5 ) ]
        }

        set x [ lindex $xy 0 ]
        set y [ lindex $xy 1 ]
        set xr [ expr round( $x + .5 ) ]
        set yr [ expr round( $y + .5 ) ]
        catch { calaphot_fluxellipse \
            $::audace(bufNo) \
            $xr $yr \
            [ expr $photometrie(diametre,interieur) * $fwhm / 2 ] [ expr $photometrie(diametre,interieur) * $fwhm / 2 ] \
            0 \
            [ expr $photometrie(diametre,exterieur1) * $fwhm / 2 ] [ expr $photometrie(diametre,exterieur2) * $fwhm / 2 ] \
            10 } mesure_ouv
        if { $photometrie(mode_debug) != 0 } {
            Message console "Ouv %s\n" [ list $xr $yr  [ expr $photometrie(diametre,interieur) * $fwhm / 2 ] [ expr $photometrie(diametre,interieur) * $fwhm / 2 ] [ expr $photometrie(diametre,exterieur1) * $fwhm / 2 ] [ expr $photometrie(diametre,exterieur2) * $fwhm / 2 ] ]
            Message console "Ouv %s\n" $mesure_ouv
        }
        if { [ string is double [ lindex $mesure_ouv 0 ] ] } {
            set photometrie(flux_ouv_$tag) [ lindex $mesure_ouv 0 ]
            if { $photometrie(flux_ouv_$tag) > 0 } {
                $photometrie(label_flux_ouv_$tag) configure -text [ expr round( [ lindex $mesure_ouv 0 ] ) ]
            } else {
                $photometrie(label_flux_ouv_$tag) configure -text "???"
            }
        } else {
            ::console::affiche_erreur "$mesure_ouv\n"
            # la valeur <0 va empêcher le calcul de la magnitude
            set photometrie(flux_ouv_$tag) -1
            $photometrie(label_flux_ouv_$tag) configure -text "???"
        }
    }


    ##
    # @brief Séquencement du mode de sélection via un catalogue téléchargé par Internet
    # @return -1 si l'utilisateur veut arrêter, ou en cas d'erreur bloquante. 0 sinon.
    proc ModeAutoInternet {} {
        variable photometrie

        if { [ ChoixCatalogueInternet ] < 0 } { return -1 }
        if { [ InterfaceHttp ] < 0 } { return -1 }
        if { [ CreationBaseDonnées ] < 0 } { return -1 }
        if { [ SelectionReference ] < 0 } { return -1 }
        return 0
    }

    ##
    # @brief Affichage de la boite de sélection d'une étoile
    # @return
    proc ModeManuel {} {
        variable photometrie_texte
        variable photometrie

        set photometrie(selection_manuelle) 0
        set tl [ toplevel $::audace(base).photometrie_selection_manuelle \
            -class Toplevel \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm resizable $tl 0 0
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace

        set tlfaide [ frame $tl.aide ]
        label $tlfaide.l -text $photometrie_texte(aide_mode_manuel)
        pack $tlfaide.l

        set tlf1 [ frame $tl.f1 \
            -borderwidth 2 \
            -relief groove ]

        set tlf1l [ label $tlf1.l -text $photometrie_texte(magnitude) ]
        set tlf1e [ entry $tlf1.e \
                -textvariable ::Photometrie::photometrie(reference,magnitude) \
                -width -1 \
                -relief sunken ]
        $tlf1.e delete 0 end
        $tlf1.e insert 0 13.5
        grid $tlf1l $tlf1e

        set tlf2 [ frame $tl.f2 \
            -borderwidth 2 \
            -relief groove ]

        set tlf2b1 [ button $tlf2.b1 \
            -text $photometrie_texte(ok) \
            -command { Photometrie::ValidationModeManuel } ]

        set tlf2b2 [ button $tlf2.b2 \
            -text $photometrie_texte(arret) \
            -command {
                set ::Photometrie::photometrie(selection_manuelle) -1
                update idletasks
                destroy $::audace(base).photometrie_selection_manuelle
            } ]

        pack $tlf2b1 $tlf2b2 \
            -side left \
            -padx 10 \
            -pady 10

        pack $tlfaide $tlf1 $tlf2

        ::confColor::applyColor $tl
        tkwait window $tl

        set photometrie(reference,nom) "---"

        return $photometrie(selection_manuelle)
    }

    proc Modelisation { xy } {
        variable photometrie_texte
        variable photometrie

        set fwhm $photometrie(fwhm)
        set f $photometrie(defaut,carre,modelisation)

        set x [ lindex $xy 0 ]
        set y [ lindex $xy 1 ]
        set x1 [ expr round( $x - $f * $fwhm ) ]
        set y1 [ expr round( $y - $f * $fwhm ) ]
        set x2 [ expr round( $x + $f * $fwhm ) ]
        set y2 [ expr round( $y + $f * $fwhm ) ]

        if { ( $x1 <= 0 )
        || ( $y1 <= 0 )
        || ( $x2 >= $photometrie(naxis1) )
        || ( $y2 >= $photometrie(naxis2) ) } {
            tk_messageBox -message "$photometrie_texte(err_hors_clou)" -title "$photometrie_texte(titre_menu)" -icon error
            set mesure_mod [ list -1 -1 ]
        } else {
            if { [ catch { calaphot_fitgauss2d $::audace(bufNo) [ list $x1 $y1 $x2 $y2 ] } mm ] } {
                ::console::affiche_erreur "$mm\n"
                set mesure_mod [ list -1 -1 ]
            } else {
                if { ( [ lindex $mm 1 ] <= 0 ) || ( [ lindex $mm 12 ] <= 0 ) } {
                    tk_messageBox -message "$photometrie_texte(err_etoile_faible)" -title "$photometrie_texte(titre_menu)" -icon error
                    set mesure_mod [ list -1 -1 ]
                } else {
                    set mesure_mod [ list [ lindex $mm 1 ] [ lindex $mm 12 ] ]
                }
            }
        }
        return $mesure_mod
    }

    ##
    # @brief Gestion des mouvements de souris
    # @param canevas sur lequel s'éxécute le mouvement
    # @param x abscisse de la souris dans le canevas (repère écran)
    # @param y ordonnée de la souris dans le canevas (repère écran)
    proc MouvementSouris { canevas x y } {
        variable photometrie

        set x [ $canevas canvasx $x ]
        set y [ $canevas canvasy $y ]
        set dx [ expr $x - [ lindex $photometrie(coord_souris) 0 ] ]
        set dy [ expr $y - [ lindex $photometrie(coord_souris) 1 ] ]
        $canevas move cercle_inc $dx $dy
        set photometrie(coord_souris) [ list $x $y ]
    }

    proc AffichageEtoilesReference { } {
        variable photometrie

        $::audace(hCanvas) delete photom
        for { set e 1 } { $e < $photometrie(nbre_pos_ref) } { incr e } {
            set xyi $photometrie(pos_etoile_ref,$e)

            set xye [ ConvImageEcran $xyi ]
            set xe [ lindex $xye 0 ]
            set ye [ lindex $xye 1 ]
            set f3 [ expr $photometrie(fwhm) * 1.5 ]
            $::audace(hCanvas) create oval \
                [ expr $xe - $f3 ] \
                [ expr $ye + $f3 ] \
            [ expr $xe + $f3 ] \
            [ expr $ye - $f3 ] \
            -outline red \
            -width 1 \
            -tags [ list photom ovale_$e ]
            $::audace(hCanvas) create text \
            $xe \
            [ expr $ye - 1.5 * $f3 ] \
            -text $e \
            -tags [ list photom texte_$e ] \
            -fill red \
            -anchor n \
            -tags [ list photom texte_$e ]
        }
    }

    proc SelectionReference {} {
        variable photometrie_texte
        variable photometrie
        variable data
        variable index_rouge
        variable index_bleu

        set liste_rouge_triee [ lsort -real  [ array names index_rouge ] ]
        set liste_bleue_triee [ lsort -real  [ array names index_bleu ] ]

        set tl [ toplevel $::audace(base).photometrie_selection_internet \
            -class Toplevel \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm resizable $tl 0 0
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace

        set tlfaide [ frame $tl.aide ]
        label $tlfaide.l -text $photometrie_texte(aide_selection_reference)
        pack $tlfaide.l

        set tlf1 [ frame $tl.f1 \
            -borderwidth 2 \
            -relief groove ]

        set zoom 1

        label $tlf1.titre_selection -text ""
        label $tlf1.titre_id -text $photometrie_texte(numero)
        label $tlf1.titre_x -text "X"
        label $tlf1.titre_y -text "Y"
        label $tlf1.titre_nom -text $photometrie_texte(nom)
        label $tlf1.titre_mag_r -text $photometrie_texte(mag_r)
        label $tlf1.titre_mag_b -text $photometrie_texte(mag_b)
        label $tlf1.titre_mag_b_r -text $photometrie_texte(mag_b_r)
        grid $tlf1.titre_selection $tlf1.titre_id $tlf1.titre_x $tlf1.titre_y $tlf1.titre_nom $tlf1.titre_mag_r $tlf1.titre_mag_b $tlf1.titre_mag_b_r

        set ligne 1
        set photometrie(selection_couleur) mag_r
        set tlf1mr [ radiobutton $tlf1.mag_rouge \
            -variable ::Photometrie::photometrie(selection_couleur) \
            -value mag_r ]
        grid $tlf1mr -row $ligne -column 5
        set tlf1mb [ radiobutton $tlf1.mag_bleue \
            -variable ::Photometrie::photometrie(selection_couleur) \
            -value mag_b ]
        grid $tlf1mb -row $ligne -column 6

        set n 0
        set photometrie(selection_reference) 1
        set photometrie(ancienne_selection) 1
        set premier_id 0
        set zoom [ visu$::audace(visuNo) zoom ]
        set catalogue $photometrie(cata_internet)
        foreach cle $liste_rouge_triee {
            foreach id $index_rouge($cle) {
                set param $data($id)
                set ad [ expr [ lindex $param $photometrie(position,$catalogue,ad) ] * 1.0 ]
                set dec [ expr [ lindex $param $photometrie(position,$catalogue,dec) ] * 1.0 ]
                set nom [ lindex $param $photometrie(position,$catalogue,nom) ]
                set mag_r [ lindex $param $photometrie(position,$catalogue,mag_r) ]
                set mag_b [ lindex $param $photometrie(position,$catalogue,mag_b) ]
                # Message console "n:%s ad:%f dec:%f r:%f b:%f\n" $nom $ad $dec $mag_r $mag_b
                set xyi [ buf$::audace(bufNo) radec2xy [ list $ad $dec ] ]
                set x [ expr round( [ lindex $xyi 0 ] ) ]
                set y [ expr round( [ lindex $xyi 1 ] ) ]
                if { [ ValidationMotifs [ list $x $y ] ] == 0 } {
                    incr n
                    incr ligne
                    if { $n == 1 } {
                        set premier_id $id
                    }

                    set photometrie(pos_etoile_ref,$n) $xyi

                    set val(n) $n
                    set val(x) $x
                    set val(y) $y
                    set val(nom) $nom
                    set val(mag_r) $mag_r
                    set val(mag_b) $mag_b
                    if { [ string is double -strict $mag_r ]
                    && [ string is double -strict $mag_b ] } {
                        set val(mag_b_r) [ expr $mag_b - $mag_r ]
                    } else {
                        set val(mag_b_r) "---"
                    }
                    set col 0
                    radiobutton ${tlf1}.${n}_cb \
                        -variable ::Photometrie::photometrie(selection_reference) \
                        -command "::Photometrie::AnimationSelectionCatalogue $tlf1 $id" \
                        -value $n
                    grid ${tlf1}.${n}_cb -row $ligne -column $col
                    foreach champ { n x y nom mag_r mag_b mag_b_r } {
                        incr col
                        label ${tlf1}.${n}_$champ \
                            -text $val($champ) \
                            -relief solid
                        grid ${tlf1}.${n}_$champ -row $ligne -column $col -sticky news
                    }
                }
            }
            if { $n > 29 } { break }
        }

        set photometrie(nbre_pos_ref) $n
        AffichageEtoilesReference
        set photometrie(etat) selection_etoiles_reference

        if { $n == 0 } {
            destroy $tl
            tk_messageBox -message "$photometrie_texte(err_pas_de_ref)" -title "$photometrie_texte(titre_menu)" -icon error
            return -1
        }

        set tlf2 [ frame $tl.f2 \
            -borderwidth 2 \
            -relief groove ]

        set tlf2b1 [ button $tlf2.b1 \
            -text $photometrie_texte(ok) \
            -command {
                $::audace(hCanvas) delete photom
                update idletasks
                destroy $::audace(base).photometrie_selection_internet
            } ]

        set tlf2b2 [ button $tlf2.b2 \
            -text $photometrie_texte(arret) \
            -command {
                set ::Photometrie::photometrie(selection_reference) -1
                $::audace(hCanvas) delete photom
                update idletasks
                destroy $::audace(base).photometrie_selection_internet
            } ]
        pack $tlf2b1 $tlf2b2 \
            -side left \
            -padx 10 \
            -pady 10

        unset index_rouge
        unset index_bleu

        pack $tlfaide $tlf1 $tlf2
        ::confColor::applyColor $tl

        AnimationSelectionCatalogue $tlf1 $premier_id
        $tlf1mr configure -command { ::Photometrie::AnimationSelectionCatalogue $::audace(base).photometrie_selection_internet.f1 $::Photometrie::photometrie(selection,id) }
        $tlf1mb configure -command { ::Photometrie::AnimationSelectionCatalogue $::audace(base).photometrie_selection_internet.f1 $::Photometrie::photometrie(selection,id) }

        tkwait window $tl

        # Récupération des informations sur la référence
        set id $photometrie(selection,id)
        set param $data($id)
        set photometrie(reference,nom) [ lindex $param $photometrie(position,$catalogue,nom) ]
        set photometrie(reference,xy) [ buf$::audace(bufNo) radec2xy \
            [ list [ expr [ lindex $param $photometrie(position,$catalogue,ad) ] * 1.0 ] \
            [ expr [ lindex $param $photometrie(position,$catalogue,dec) ] * 1.0 ] ] ]
        if { $photometrie(selection_couleur) == "mag_r" } {
            set photometrie(reference,magnitude) [ lindex $param $photometrie(position,$catalogue,mag_r) ]
        } else {
            set photometrie(reference,magnitude) [ lindex $param $photometrie(position,$catalogue,mag_b) ]
        }

        return $photometrie(selection_reference)
    }

    ##
    # @brief Mesure de valeurs de magnitudes directement sur une image
    proc PhotometrieEcran {} {
        variable photometrie

        # Message console "%s\n" [ info level  [ info level ] ]

        set tl [ CadreMesurePhotometrie ]

        set photometrie(etat) photometrie_ecran
        set xy_ecran [ ConvImageEcran $photometrie(reference,xy) ]
        DessinCercles ref $xy_ecran
        DessinTexte ref $xy_ecran
        MesureFlux ref $photometrie(reference,xy)

        GestionSouris

        tkwait window $tl
    }

    # @brief Procédure pour bloquer la suppression des fenêtres esclaves
    proc Suppression {} {

    }

    # @brief Validation de la saisie d'une étoile en mode manuel
    proc ValidationModeManuel {} {
        variable photometrie_texte
        variable photometrie

        set rect [ ::confVisu::getBox $::audace(visuNo) ]
        if { [ llength $rect ] <= 0 } {
            tk_messageBox -message "$photometrie_texte(err_pas_de_sel)" -title "$photometrie_texte(titre_menu)" -icon error
        } else {
            set photometrie(reference,xy) [ buf$::audace(bufNo) centro $rect ]
            set fwhm [ buf$::audace(bufNo) fwhm $rect ]
            set photometrie(fwhm) [ expr ( [ lindex $fwhm 0 ] + [ lindex $fwhm 1 ] ) / 2 ]
            if { [ ValidationMotifs $photometrie(reference,xy) ] < 0 } {
                tk_messageBox -message "$photometrie_texte(err_hors_clou)" -title "$photometrie_texte(titre_menu)" -icon error
            } else {
                set mm [ Modelisation $photometrie(reference,xy) ]
                if { [ lindex $mm 1 ] > 0 } {
                    destroy $::audace(base).photometrie_selection_manuelle
                }
            }
        }
    }

    # @brief Validation de ce que les cercles d'ouverture et la fenêtre de modélisation sont bien dans l'image
    # @param : liste des coordonnées dans le repère image
    # @return -1 si les motifs débordent de l'image, 0 dans le cas contraire
    proc ValidationMotifs { xy } {
        variable photometrie

        set x [ lindex $xy 0 ]
        set y [ lindex $xy 1 ]

        # Le cercle exterieur2 est le plus grand des 3 cercles, il y a juste à le comparer au carré de modélisation
        if { $photometrie(defaut,diametre,exterieur2) > $photometrie(defaut,carre,modelisation) } {
            set max $photometrie(defaut,diametre,exterieur2)
        } else {
            set max $photometrie(defaut,carre,modelisation)
        }

        set f [ buf$::audace(bufNo) fwhm [ list [ expr round($x - $max) ] [ expr round($y - $max) ] [ expr round($x + $max) ] [ expr round($y + $max) ] ] ]
        set fwhm [ expr ( [ lindex $f 0 ] + [ lindex $f 1 ] ) / 2 ]
        if { ( [ expr $x - $max * $fwhm ] < 1 )
        || ( [ expr $x + $max * $fwhm ] > $photometrie(naxis1) )
        || ( [ expr $y - $max * $fwhm ] < 1 )
        || ( [ expr $y + $max * $fwhm ] > $photometrie(naxis2) ) } {
            return -1
        } else {
            set photometrie(fwhm) $fwhm
            return 0
        }
    }
}
