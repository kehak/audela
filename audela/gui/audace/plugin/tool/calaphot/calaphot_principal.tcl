##
# @file calaphot_principal.tcl
#
# @author Olivier Thizy (thizy@free.fr) & Jacques Michelet (jacques.michelet@laposte.net)
#
# @brief Script pour la photometrie d'asteroides ou d'etoiles variables.
#
# $Id: calaphot_principal.tcl 14222 2017-06-05 19:10:56Z robertdelmas $
#

###catch {namespace delete ::Calaphot}


##
# @defgroup calaphot_notice_fr Calaphot
#
# @defgroup calaphot_presentation Presentation
# Calaphot est un script permettant de faire de la photometrie differentielle sur un lot d'images
# @ingroup calaphot_notice_fr
#
# @section calaphot_presentation Presentation
# Plusieurs méthodes de calcul de photometrie sont proposees
# - photometrie par ouverture : le flux de chaque astre est calcule dans une fenetre elliptique, auxquel est soustrait la flux de fond de ciel mesure dans un anneau elliptique entourant la fenetre precedente
# - photometrie par modelisation : les niveaux de gris de chaque astre sont modelises par une nappe gaussienne. On obtient ainsi directement le flux de chaque astre.
# - photometrie par @c sextractor : @c sextractor est un logiciel libre (developpe par Emmanuel Bertin) dont la finalite premiere est d'effectuer des mesures astrometriques sur les images. Il comporte aussi des fonctions de photometrie qui sont exploitees dans Calaphot.
# .
# Pour utiliser Calaphot, sont fournis :
# - @link calaphot_documentation_fr le mode d'emploi @endlink .
# - @link calaphot_documentation_technique_fr La documentation technique @endlink détaillant les calculs effectués.
# .
#
# @todo Choses à faire
# - Fonctionnel
#   - multiples asteroides en // : voir le tag MultAster pour retablir la fonctionnalite
#   - differencier les aster. par couleur dans le graph. de la cl.
#   - pouvoir les nommer individuellement dans le graph. de la cl.
#   - nommer les etoiles de ref : voir le tag NomRef
#   .
# - L'ensemble des ajouts indiqués au-dessus ne sera pas intégré à Calaphot, mais fera l'objet d'un autre outil dont la publication est prévue en 2016.
# .
#
# @bug Bogues connues a ce jour :
# - pas de suppression des fichiers de config sextractor en cas d'arret anticipe
# - mode sextractor ne marche pas si les repertoires ont des blancs dans leurs noms (exe, images ou configs)
# - pb d'affichage des valeurs numériques si on refait le pointage de l'astéroïde sur la 1ere image
# .
#
#

##
# @brief Calaphot est un script permettant de faire de la photométrie différentielle sur un lot d'images
# @namespace CalaPhot
namespace eval ::CalaPhot {
    ##
    # @brief Initialisation générale des variables par défaut
    # - Suppression de fenêtres restantes.
    # - Initialisation de divers compteurs d'objets
    # @return
    #
    proc InitialisationGenerale {} {
        variable parametres
        variable calaphot
        variable police
        variable trace_log
        variable pas_a_pas
        variable data_script
        variable data_image

        # L'existence de trace_log crée le ficher debug.log et le mode d'affichage debug
        catch { unset trace_log }
        # set trace_log 1
        # L'existence de pas_a_pas permet de ne traiter une image que si on tape une séquence de caractères
        # Utile en mode debug
        catch { unset pas_a_pas }
        # set pas_a_pas 1

        set version_majeure 7
        set version_mineure 4
        set version_indice "20161106"
        set numero_version_abrege [ format "v%d.%d" $version_majeure $version_mineure ]
        set numero_version_complet [ format "v%d.%d.%s" $version_majeure $version_mineure $version_indice ]

        catch { destroy $::audace(base).saisie }
        catch { destroy $::audace(base).selection_etoile }
        catch { destroy $::audace(base).selection_aster }
        catch { destroy $::audace(base).courbe_lumiere }
        catch { destroy $::audace(base).bouton_arret_color_invariant }

        if { [ array exist data_script ] } {
            unset data_script
        }
        if { [ array exist data_image ] } {
            unset data_image
        }
        if { [ array exist parametres ] } {
            unset parametres
        }

        set data_script(nombre_variable) 0
        set data_script(nombre_reference) 0
        set data_script(nombre_indes) 0

        set data_script(nombre_fichier_ouvert) 0

        set calaphot(niveau_debug) 0
        set calaphot(niveau_info) 1
        set calaphot(niveau_notice) 2
        set calaphot(niveau_probleme) 3
        set calaphot(niveau_erreur) 4

        set calaphot(texte,debug)               "debug"
        set calaphot(texte,info)                "info"
        set calaphot(texte,notice)              "notice"
        set calaphot(texte,probleme)            "probleme"
        set calaphot(texte,erreur)              "erreur"

        set calaphot(nom_fichier_ini)           [ file join $::audace(rep_images) calaphot.ini ]
        set calaphot(nom_fichier_log)           [ file join $::audace(rep_images) calaphot.log ]

        set calaphot(sextractor,catalog)        [ file join $::audace(rep_images) calaphot_sext.cat ]
        set calaphot(sextractor,config)         [ file join $::audace(rep_images) calaphot_sext.conf ]
        set calaphot(sextractor,param)          [ file join $::audace(rep_images) calaphot_sext.param ]
        set calaphot(sextractor,neurone)        [ file join $::audace(rep_images) calaphot_sext.nnw ]
        set calaphot(sextractor,assoc)          [ file join $::audace(rep_images) calaphot_sext.assoc ]

        set calaphot(init,mode)                 ouverture
        set calaphot(init,operateur)            "Tycho Brahe"
        set calaphot(init,source)               images_
        set calaphot(init,indice_premier)       1
        set calaphot(init,nombre_images)        100
        set calaphot(init,gain_camera)          3
        set calaphot(init,bruit_lecture)        20
        set calaphot(init,niveau_maximal)       45000
        set calaphot(init,niveau_minimal)       -100
        set calaphot(init,rayon1)               2.5
        set calaphot(init,rayon2)               4
        set calaphot(init,rayon3)               6
        set calaphot(init,sortie)               "variable"
        set calaphot(init,fichier_cl)           "variable"
        set calaphot(init,objet)                "(125) Liberatrix"
        set calaphot(init,code_UAI)             615
        set calaphot(init,surechantillonage)    20
        set calaphot(init,type_capteur)         "QSI-632 / Kaf3200"
        set calaphot(init,type_telescope)       "Schmidt-Cassegrain"
        set calaphot(init,diametre_telescope)   "0.280"
        set calaphot(init,focale_telescope)     "2.750"
        set calaphot(init,catalogue_reference)  "NOMAD1, R"
        set calaphot(init,filtre_optique)       "Clair"
        set calaphot(init,niveau_message)       $calaphot(niveau_notice)
        set calaphot(init,tri_images)           "non"
        set calaphot(init,type_images)          "non_recalees"
        set calaphot(init,pose_minute)          "seconde"
        set calaphot(init,date_images)          "debut_pose"
        set calaphot(init,reprise_astres)       "non"
        set calaphot(init,signal_bruit)         20
        set calaphot(init,type_objet)           0
        set calaphot(init,defocalisation)       "non"
        set calaphot(init,version_ini)          $numero_version_abrege
        set calaphot(init,version_complete)     $numero_version_complet
        set calaphot(nombre_couleur)            10
        set calaphot(couleur,0)                 "#ff0000"
        set calaphot(couleur,1)                 "#ffff00"
        set calaphot(couleur,2)                 "#ffc040"
        set calaphot(couleur,3)                 "#ff8080"
        set calaphot(couleur,4)                 "#ff40c0"
        set calaphot(couleur,5)                 "#ff00ff"
        set calaphot(couleur,6)                 "#80ff00"
        set calaphot(couleur,7)                 "#808040"
        set calaphot(couleur,8)                 "#804080"
        set calaphot(couleur,9)                 "#8000ff"
        set calaphot(champ,nomad1)              [ list RAJ2000 DEJ2000 NOMAD1 Bmag Rmag ]
        set calaphot(champ,usnob1)              [ list RAJ2000 DEJ2000 USNO-B1.0 B1mag R1mag ]
        set calaphot(champ,usnoa2)              [ list RAJ2000 DEJ2000 USNO-A2.0 Bmag Rmag ]
        set calaphot(champ,ucac3)               [ list RAJ2000 DEJ2000 3UC Bmag R2mag ]
        set calaphot(champ,loneos)              [ list RAJ2000 DEJ2000 LN Bmag R2mag ]


        if { [ info exists trace_log ] } {
            set parametres(niveau_message) $calaphot(niveau_debug)
        } else {
            set parametres(niveau_message) $calaphot(niveau_notice)
        }

        # Couleur des affichages console
        foreach niveau { debug info notice probleme erreur } couleur_style { black purple blue orange red } {
            $::audace(Console).txt1 tag configure calaphot(style_$niveau) -foreground $couleur_style
        }

        # Nettoyage du fichier de log
        catch { [ file delete $calaphot(nom_fichier_log) ] }
    }

    ##
    # @brief Programme principal (séquenceur)
    # @return 0 si tout va bien
    # @return !=0 en cas de demande d'arrêt, ou d'erreur dans le script
    proc Principal {} {
        variable demande_arret
        variable parametres
        variable data_image
        variable data_script
        variable liste_image
        variable calaphot

        set probleme "non"
        set etape init_script
        while { $probleme == "non" } {
            Message debug "début de l'étape : %s\n" $etape
            set etape_courante $etape

            switch -exact -- $etape {
                init_script {
                    # Initialisation générale
                    InitialisationGenerale

                    # Chargement des bibliothèques ressources
                    if { [ Ressources ] != 0 } {
                        set probleme "oui"
                    }
                    set etape init_data
                }

                init_data {
                    # Paramétrage du script
                    RecuperationParametres

                    Console notice "%s %s\n" $calaphot(texte,titre) $calaphot(init,version_complete)
                    Console notice "%s\n" $calaphot(texte,copyright)

                    PasAPas

                    set demande_arret 0
                    if { [ SaisieParametres ] } {
                        set probleme "oui"
                    }
                    SauvegardeParametres
                    set etape init_images
                }

                init_images {
                    catch { file delete [ file join $::audace(rep_images) $parametres(sortie).txt ] }
                    TraceFichier "%s %s\n" $calaphot(texte,titre) $calaphot(init,version_complete)
                    TraceFichier "%s\n" $calaphot(texte,copyright)

                    # Initialisations spécifiques à Sextractor
                    if {( $parametres(mode) == "sextractor" )} {
                        CreationFichiersSextractor
                    }

                    # Récapitulation des options choisies
                    RecapitulationOptions
                    # Tri des images par date croissante et constitution de la liste des indices
                    set liste_image [ GenerationListeImage ]
                    if { [ llength $liste_image ] < 2 } {
                        set probleme "oui"
                    } else {
                        set etape recalage_images
                    }
                }

                recalage_images {
                    # Récupération d'informations sur les images
                    InformationsImages

                    # Récupération des décalages entre les images (s'ils existent)
                    RecuperationDecalages

                    set images_initiales [ RecalageInitial ]
                    if { $images_initiales == "z" } {
                        set probleme "oui"
                    } else {
                        if { [ AffichageMenus $images_initiales ] } {
                            set probleme "oui"
                        }
                    }

                    # 2ème sauvegarde, avec les coordonnées graphiques des astres
                    SauvegardeParametres

                    set etape post_init
                }

                post_init {
                    # Calcul des dates extrêmes
                    DatesReferences

                    # Calcul de la vitesse apparente des astéroïdes
                    VitesseAsteroide

                    # Calcul de magnitude de la super-étoile
                    CalculMagSuperEtoile

                    # Quelques initialisations encore
                    PostInit

                    # Affiche les titres des colonnes
                    Entete

                    # Mise en place du bouton d'arrêt
                    BoutonArret

                    # Affichage de la courbe de lumière dynamique
                    set liste_courbes_temporaires [ ::CalaPhot::CourbeLumiereTemporaire ]

                    set etape boucle_image
                }

                boucle_image {
                    # Boucle principale sur les images de la série
                    if { [ BoucleImages ] } {
                        set probleme "oui"
                    }
                    set etape fin_boucle
                }

                fin_boucle {
                     # Effacement des marqueurs d'étoile
                     EffaceMotif astres

                    # Suppression du bouton d'arrêt
                     destroy $::audace(base).bouton_arret_color_invariant

                     # Sauvegarde des décalages entre images
                     SauvegardeDecalages

                     set etape validation_resultats
                }

                validation_resultats {
                    # Deuxième filtrage sur les images pour filtrer celles douteuses
                    FiltrageConstanteMag

                    FiltrageFinal

                    if { [ SelectionFinaleImages ] < 2 } {
                        # Moins de 2 images gardées, on arrête tout
                        set probleme "oui"
                    }

                    set etape publication_resultats
                }

                publication_resultats {
                    AffichageMagnitudesMoyennes

                    CoefficientsPhotometriques

                    GenerationFichiersResultats

                    DestructionFichiersAuxiliaires

                    # Affiche l'heure de fin de traitement
                    Message notice "\n\n%s %s\n" $calaphot(texte,heure_fin) [clock format [clock seconds]]
                    Message notice "%s\n" $calaphot(texte,fin_normale)
                    TraceFichier "%s\n" $calaphot(texte,fin_normale)

                    # Destruction des courbes de lumière temporaires
                    # DestructionCourbesTemporaires $liste_courbes_temporaires

                     # Affichage de la courbe de lumière
                    ExecutionGnuplot

                    set etape fin
                }

                fin {
                    set probleme "aucun_probleme"
                }

                default {
                    Console error "Etape inconnue"
                    set probleme "oui"
                }

            }

            Message debug "problème : %s\n" $probleme

        }

        if { $probleme == "oui" } {
            $::audace(hCanvas) delete marqueurs
            Message notice "%s %s\n" $calaphot(texte,etape) $etape_courante
            Message probleme "%s\n" $calaphot(texte,fin_anticipee)
            return
        }

        # Affiche l'heure du début de traitement
        # Message notice "%s %s\n\n" $calaphot(texte,heure_debut) [ clock format [ clock seconds ] ]


        #set data_image(0,valide) "Y"
        #Message debug "existence de data_image : %s\n" [ array exists data_image ]
        #Message debug "indices de data_image : %s\n" [ array names data_image ]
        return
    }

    proc BoucleImages { } {
        variable liste_image
        variable data_image
        variable calaphot
        variable demande_arret

        set arret "non"
        set etape debut_boucle
        set indice 0
        while { ( $arret == "non" ) && ( $indice < [ llength $liste_image ] ) } {
            switch -exact -- $etape {
                debut_boucle {
                    set image [ lindex $liste_image $indice ]
                    Message debug "Traitement de l'image %d ( %s )\n" $indice $image

                    # A priori, l'image est bonne. On verra par la suite
                    set data_image($indice,qualite) "bonne"

                    # Effacement des symboles mis sur l'image précédente
                    EffaceMotif astres

                    # Détection de l'appui sur le bouton d'arrêt
                    if { $demande_arret == 1 } {
                        set arret "oui"
                    }

                    set etape parametres_image
                }

                parametres_image {
                    # Chargement et visualisation de l'image traitée
                    ChargementImageParIndice $indice

                    set etape position_astres
                    # Recherche la date de l'image dans l'entête FITS (déjà fait si les images étaient déclarées non triées)
                    if { [ DateImage $indice ] } {
                        set arret "oui"
                        EliminationImage $indice "Bad date"
                    } else {
                        if { [ DateCroissante $indice ] } {
                            EliminationImage $indice "Date not in an ascending order"
                            set etape affichage_resultats
                        }
                    }
                }

                position_astres {
                    set etape modelisation
                    # Détermination du décalage géometrique
                    if { [ MesureDecalage $indice ] } {
                        EliminationImage $indice "Poor shift measurement"
                        AttentePasAPas
                        set etape affichage_resultats
                    } else {
                        # Calcule la position des astéroides par interpolation sur les dates (sans tenir compte du décalage des images)
                        CalculPositionsTheoriques $indice
                        # Calcul de toutes les positions réelles des astres (astéroides compris) à considérer ET à supprimer, en tenant compte du décalage en coordonnées des images
                        if { [ CalculPositionsReelles $indice ] } {
                            EliminationImage $indice "Poor position measurement"
                            AttentePasAPas
                            set etape affichage_resultats
                        }
                    }
                }

                modelisation {
                    # Recalage astrometrique
                    # RecalageAstrometrique $i

                    # Calcul des coordonnees equatoriales
                    # XyAddec $i

                    # Calcul de la masse d'air
                    # MasseAir $i

                    # Suppression de toutes les etoiles indesirables
                    SuppressionIndesirables $indice

                    # Les astres (étoiles + astéroides) sont modélisées dans TOUS les cas
                    #  Un certain nombre de valeurs individuelles sont mises à jour dans data_image
                    if { [ Modelisation $indice ] != 0 } {
                        # Au moins un astéroide ou une étoile de ref. n'a pas été modélisée correctement
                        # Donc on élimine l'image
                        EliminationImage $indice "Poor fitting"
                        AttentePasAPas
                        set etape affichage_resultats
                    } else {
                        set etape photometrie
                    }
                }

                photometrie {
                    if { [ Photometrie $indice ] != 0 } {
                        EliminationImage $indice "Poor photometry"
                        AttentePasAPas
                        set etape image_suivante
                    } else {
                        set etape mode_catalogue_automatique
                    }
                }

                mode_catalogue_automatique {
                    if { [ ModeCatalogueAutomatique $indice ] } {
                        set etape calculs_finaux_mode_automatique
                    } else {
                        set etape calculs_finaux_mode_manuel
                    }
                }

                calculs_finaux_mode_manuel {
                    FluxReference $indice

                    # Calcul des magnitudes et des incertitudes de tous les astres (astéroïdes et étoiles)
                    MagnitudesEtoiles $indice

                    # Premier filtrage sur les rapports signal à bruit
                    FiltrageSB $indice

                    # Calcul d'incertitude global
                    CalculErreurGlobal $indice

                    # Calculs des vecteurs pour le pré-affichage de la courbe de lumière
                    PreAffiche $indice

                    # Calcul de la masse d'air
                    MasseAir $indice

                    # Mode pas à pas
                    AttentePasAPas

                    set etape affichage_resultats
                }

                calculs_finaux_mode_automatique {
                    # Calculs des vecteurs pour le pré-affichage de la courbe de lumière
                    PreAffiche $indice

                    # Calcul de la masse d'air
                    MasseAir $indice

                    # Mode pas à pas
                    AttentePasAPas

                    set etape affichage_resultats
                }

                affichage_resultats {
                    # Affiche le résultat dans la console
                    AffichageResultatsBruts $indice

                    set etape image_suivante
                }

                image_suivante {
                    incr indice
                    set etape debut_boucle
                }
            }
        }

        if { $arret == "oui" } {
            ArretScript
            EffaceMotif astres
            return -1
        } else {
            return 0
        }
    }

    proc PostInit {} {
        variable data_script
        variable liste_image

        Message debug "%s\n" [ info level  [info level ] ]

        set data_script(nombre_image) [ llength $liste_image ]

        for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
            set data_script(compteur_image,ref_$j) 0
        }
    }

    proc ModeCatalogueAutomatique { indice } {
        variable data_script
        variable data_image

        Message debug "%s\n" [ info level  [info level ] ]

        set retour 0
        if { $data_script(choix_mode_reference) != "manuel" } {
            # Si le calcul du flux de l'étoile a pu se faire, on incrémente son compteur d'image
            for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
                if { ( $data_image($indice,ref,centroide_x_$j) >= 0 )
                     && ( $data_image($indice,ref,centroide_x_$j) >= 0 )
                     && ( $data_image($indice,ref,flux_$j) ) } {
                    incr data_script(compteur_image,ref_$j)
                }
            }
            set retour 1
        }
        return $retour
    }

    proc AffichageMagnitudesMoyennes { } {
        variable data_script
        variable calaphot
        variable moyenne
        variable ecart_type

        Message debug "%s\n" [ info level  [ info level ] ]

        for { set etoile 0 } { $etoile < $data_script(nombre_variable) } { incr etoile 1 } {
            Message notice "%s : %s %07.4f %s %6.4f\n" $calaphot(texte,asteroide)  $calaphot(texte,moyenne) $moyenne(var,$etoile) $calaphot(texte,ecart_type) $ecart_type(var,$etoile)
            TraceFichier "%s : %s %07.4f %s %6.4f\n" $calaphot(texte,asteroide)  $calaphot(texte,moyenne) $moyenne(var,$etoile) $calaphot(texte,ecart_type) $ecart_type(var,$etoile)
        }

        for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile 1 } {
            Message notice "%s %2d : %s %07.4f %s %6.4f\n" $calaphot(texte,etoile) $etoile $calaphot(texte,moyenne) $moyenne(ref,$etoile) $calaphot(texte,ecart_type) $ecart_type(ref,$etoile)
            TraceFichier "%s %2d : %s %07.4f %s %6.4f\n" $calaphot(texte,etoile) $etoile $calaphot(texte,moyenne) $moyenne(ref,$etoile) $calaphot(texte,ecart_type) $ecart_type(ref,$etoile)
        }
    }

    proc Photometrie { indice } {
        variable parametres
        variable data_script
        variable data_image
        variable liste_image

        Message debug "%s\n" [ info level  [info level ] ]

        set retour 0
        if { $parametres(mode) == "ouverture" } {
            # Effacement des marqueurs d'étoile
            EffaceMotif astres

            # Dessin des symboles
            DessinSymboles $indice

            # Cas ouverture
#           set rayon_optimal 0.0
#           for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
#              set rayon_optimal [ expr max($rayon_optimal, [ TestFluxOuverture $image ref $j ] ) ]
#           }
#           for { set j 0 } { $j < $data_script(nombre_variable) } { incr j } {
#              set rayon_optimal [ expr max($rayon_optimal, [ TestFluxOuverture $image var $j ] ) ]
#           }

#           Message info "rayon_optimal = %f\n" $rayon_optimal
            # set parametres(rayon1) $rayon_optimal
            for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
               FluxOuverture $indice ref $j
            }
            for { set j 0 } { $j < $data_script(nombre_variable) } { incr j } {
               FluxOuverture $indice var $j
            }
        }

        if { ( $parametres(mode) == "sextractor" ) } {
            # Cas Sextractor
            set image [ lindex $liste_image $indice ]
            set test [ Sextractor [ file join $::audace(rep_images) $image ] $indice ]
            if { $test != 0 } {
                set data_script($indice,invalidation) [ list sextractor ]
                set data_image($indice,qualite) "mauvaise"
                set retour -1
            } else {
                for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
                    set temp [ RechercheCatalogue $indice ref $j ]
                    if { [ llength $temp ] != 0 } {
                        FluxSextractor $indice ref $j $temp
                    } else {
                        set data_script($indice,invalidation) [ list sextractor ref $j ]
                        set data_image($indice,qualite) "mauvaise"
                        set retour -1
                        break
                    }
                }
                for { set j 0 } { $j < $data_script(nombre_variable) } { incr j } {
                    set temp [ RechercheCatalogue $indice var $j ]
                    Message debug "temp=%s (l=%d)\n" $temp [ llength $temp ]
                    if { [ llength $temp ] != 0 } {
                        FluxSextractor $indice var $j $temp
                    } else {
                        set data_script($indice,invalidation) [ list sextractor var $j ]
                        set data_image($indice,qualite) "mauvaise"
                        set retour -1
                        break
                    }
                }
            }
        }
        return $retour
    }

    proc Modelisation { indice } {
        variable data_script
        variable pos_reel
        variable data_image

        Message debug "%s\n" [ info level  [info level ] ]

        set test 0
        for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
            # Dessin d un rectangle
            Dessin rectangle $pos_reel($indice,ref,$j) [ list $data_image($indice,taille_boite) $data_image($indice,taille_boite) ] $::color(green) etoile_$j
            # Modélisation
            incr test [ Modelisation2D $indice $j ref $pos_reel($indice,ref,$j) ]
        }
        for { set j 0 } { $j < $data_script(nombre_variable) } { incr j } {
            # Dessin d un rectangle
            Dessin rectangle $pos_reel($indice,var,$j) [ list $data_image($indice,taille_boite) $data_image($indice,taille_boite) ] $::color(yellow) etoile_$j
            # Modélisation
            incr test [ Modelisation2D $indice $j var $pos_reel($indice,var,$j) ]
        }
        return $test
    }

    ##
    # @brief Charge et visualise une image (en mode rapide)
    # @param bandeau : nom à afficher dans le bandeau
    # @return 0
    #
    proc VisualisationImage { bandeau } {

        Message debug "%s\n" [ info level  [info level ] ]

        if { [ buf$::audace(bufNo) imageready ] != 0 } {
            set valeur [ buf$::audace(bufNo) stat full ]
            set m [ lindex $valeur 6 ]
            set s [ lindex $valeur 7 ]
            set bas [ expr $m - 3 * $s ]
            set haut [ expr $m + 25 * $s ]
            ::confVisu::autovisu $::audace(visuNo) "-no"
            ::confVisu::visu $::audace(visuNo) [ list $haut $bas ]
            if { [ string length $bandeau ] != 0 } {
                ::confVisu::setFileName $::audace(visuNo) $bandeau
            }
        } else {
            Message debug "Pas de visualisation possible\n"
        }
    }

    ##
    # @brief Charge, visualise et recueille quelques informations sur les images
    # @param indice indice de l'image
    # @param visu option d'affichage de l'image (novisu => pas d'affichage)
    # @param bandeau option d'affichage du nom de l'image dans le bandeau
    #
    proc ChargementImageParIndice { indice { visu "" } { bandeau "" } } {
        variable data_image
        variable liste_image

        Message debug "%s\n" [ info level  [info level ] ]

        set image [ lindex $liste_image $indice ]
        ChargementImageParNom $image $visu $bandeau
        if { ![info exists data_image($indice,fwhm)] } {
            set data_image($indice,fwhm) [ FWHMImage $::audace(bufNo) ]
            set data_image($indice,taille_boite) [ TailleBoite $::audace(bufNo) $data_image($indice,fwhm) ]
        }
        Message debug "Image %s indice %d fwhm=%f taille_boite=%d\n" $image $indice $data_image($indice,fwhm) $data_image($indice,taille_boite)
    }

    proc ChargementImageParNom { image { visu "" } { bandeau "" } } {

        Message debug "%s\n" [ info level  [ info level ] ]

        buf$::audace(bufNo) load [ file join $::audace(rep_images) $image ]
        if { $visu != "-novisu" } {
            if { $bandeau == "" } {
                VisualisationImage $image
            } else {
                VisualisationImage $bandeau
            }
        }
    }

    ##
    # @brief Attente que l'utilisateur valide la suite du script. NE SERT QU'AU DEBOGAGE
    # @return
    proc AttentePasAPas {} {
        variable pas_a_pas
        if { [ info exists pas_a_pas ] } {
            vwait ::CalaPhot::calaphot(suite_du_script)
        }
    }

    ##
    # @brief Affichage dans la console
    # @details Le niveau d'affichage est comparé au niveau defini dans la saisie des parametres. S'il est plus faible (plus grande priorité)
    # le message sera affiche. Les couleurs d'affichage sont definies par des 'tags' (cf InitialisationGenerale)
    # @param[in] niveau_info : le niveau d'affichage
    # @param[in] args : le message formatte a afficher
    # @return
    proc Console { niveau_info args } {
        variable trace_log
        variable calaphot
        variable parametres

        if { [ info exists parametres(niveau_message) ] } {
            if { $parametres(niveau_message) <= $calaphot(niveau_$niveau_info) } {
                $::audace(Console).txt1 insert end [ string repeat " " [ expr [ info level ] - 1 ] ] calaphot(style_$niveau_info)
                $::audace(Console).txt1 insert end [ eval [ concat {format} $args ] ] calaphot(style_$niveau_info)
                $::audace(Console).txt1 see insert
                update

                if { [ info exists trace_log ] } {
                    set filetest [ open $calaphot(nom_fichier_log) a ]
                    if { $filetest != "" } {
                        puts $filetest [ concat [ string repeat "." [ expr [ info level ] - 1 ] ] [ eval [ concat { format } $args ] ] ]
                        flush $filetest
                    }
                    close $filetest
                }
            }
        } else {
#            ::console::affiche_resultat [ eval [ concat {format} $args ] ]
        }
    }

    ##
    # @brief Vérification que les images sont dans un ordre de date croissante
    # @param[in] i : numéro de l'image dans la séquence
    # @return : -1 si le temps de l'image est plus petit que celui de l'image précédente, 0, dans le cas normal
    proc DateCroissante { i } {
        variable data_script
        variable liste_image
        variable data_image
        variable calaphot

        Message debug "%s\n" [ info level [ info level ] ]

        if { $i != 0 } {
            # Recherche de l'image précédente
            if { $data_image($i,date) > $data_script(date_courante) } {
                set data_script(date_courante) $data_image($i,date)
                return 0
            } else {
                Message probleme "Date image %s %d %f <= date derniere image %f\n" [ lindex $liste_image $i ] $i $data_image($i,date) $data_script(date_courante)
                set data_script($i,invalidation) $calaphot(texte,plus_jeune)
                set data_image($i,qualite) "mauvaise"
                return -1
            }
        } else {
            set data_script(date_courante) $data_image($i,date)
            return 0
        }
    }

    ##
    # @brief Extraction de la date et du temps d'exposition d'une image a partir de l'entete FITS
    # @param[in] i : numero de l'image dans la séquence
    # @retval data_image($i,date) : date en jour julien
    # @retval data_image($i,temps_expo) : temps d'exposition en s
    # @return : -1 si le temps d'exposition trouvé est nul, 0, dans le cas normal
    proc DateImage { i } {
        variable data_image
        variable data_script
        variable parametres
        variable parametres
        variable liste_image
        variable calaphot

        Message debug "%s\n" [ info level [ info level ] ]

        set image [ lindex $liste_image $i ]

        # Détermination du temps de pose de l'image
        # !!! On suppose que la date stockée dans l'image est celle du DEBUT de la pose
        set expo [ lindex [ buf$::audace(bufNo) getkwd "EXPTIME" ] 1 ]
        if { [ string length $expo ] == 0 } {
            set expo [ lindex [ buf$::audace(bufNo) getkwd "EXPOSURE" ] 1 ]
        }
        if { [ string length $expo ] == 0 } {
            set expo [ lindex [ buf$::audace(bufNo) getkwd "EXP_TIME" ] 1 ]
        }

        Message debug "Image %s %d: Temps exposition : %f\n" $image $i $expo
        if { ( [ string length $expo ] == 0 ) || ( $expo == 0 ) } {
            Message probleme "%s %s %i : %s\n" $calaphot(texte,image) $image $i $calaphot(texte,temps_pose_nul)
            set data_script($i,invalidation) $calaphot(texte,temps_pose_nul)
            set data_image($i,qualite) "mauvaise"
            return -1
        }

        if { $parametres(pose_minute) == "minute" } {
            set expo [ expr $expo * 60.0 ]
        }
        set data_image($i,temps_expo) $expo

        # Calcul de la date exacte
        set jd [ JourJulienImage ]
        if { $parametres(date_images) == "debut_pose" } {
            # Cas début de pose (on rajoute le 1/2 temps de pose converti en jour julien).
            set data_image($i,date) [ expr $jd + ( $expo / 172800.0 ) ]
        } else {
            # Cas milieu de pose
            set data_image($i,date) $jd
        }
        Message debug "Image %s indice %d: Date %s\n" $image $i $data_image($i,date)

        return 0
    }

    ##
    # @brief Recherche des dates de la 1ère et de la dernière image de la séquence et calcul de la difference
    # @retval data_script(jd_premier) : date en jour julien de la 1ère image
    # @retval data_script(jd_dernier) : date en jour julien de la dernière image
    # @retval data_script(jd_delta) : difference des dates précédentes
    proc DatesReferences {} {
        variable data_script
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        # Charge et affiche la première image
        ChargementImageParNom [ lindex $liste_image 0 ] -novisu
        set jd_premiere [ JourJulienImage ]
        set data_script(jd_premier) $jd_premiere

        # Charge et affiche la dernière image
        ChargementImageParNom [ lindex $liste_image end ] -novisu
        set jd_derniere [ JourJulienImage ]
        set data_script(jd_dernier) $jd_derniere

        set delta_jd [ expr $jd_derniere - $jd_premiere ]
        set data_script(delta_jd) $delta_jd
    }

    ##
    # @brief Lecture du décalage en (x,y) de l'image recalée préalablement
    # @details Le décalage est lu a partir du mot cle IMA/SERIES REGISTER dans l'entête FITS de l'image
    # @param[in] image : no de l'image dans la séquence
    # @return liste contenant le décalage en x et y
    proc DecalageImage { image } {
        Message debug "%s\n" [ info level [ info level ] ]

        # --- recupere la liste des mots cles de l'image FITS
        set listkey [ lsort -dictionary [ buf$::audace(bufNo) getkwds ] ]
        # Recherche de la dernière ligne contenant la chaîne IMA/SERIES REGISTER
        foreach key $listkey {
            set listligne [ buf$::audace(bufNo) getkwd $key ]
            set value [ lindex $listligne 1 ]
            if { $value == "IMA/SERIES REGISTER" } {
                # Extraction de l'indice du mot cle TT
                set keyname [ lindex $listligne 0 ]
                set indice [ string range $keyname 2 end ]
            }
        }

        if { ![ info exists indice ] } {
            set dec [ list 0 0 0 ]
        } else {
            # On a maintenant repéré la fonction TT qui pointe sur la dernière registration.
            # --- on recherche la ligne FITS contenant le mot clé indice + 1
            incr indice
            set listligne [ buf$::audace(bufNo) getkwd "TT$indice" ]
            set param [ lindex $listligne 1 ]
            set dx [ lindex $param 2 ]

            # --- on recherche la ligne FITS contenant le mot clé indice + 2
            incr indice
            set listligne [ buf$::audace(bufNo) getkwd "TT$indice" ]
            set param [ lindex $listligne 1 ]
            set dy [ lindex $param 2 ]

            # --- on recherche la ligne FITS contenant le mot clé indice + 2
            incr indice
            set listligne [ buf$::audace(bufNo) getkwd "TT$indice" ]
            set param [ lindex $listligne 1 ]
            set nbre_etoiles [ lindex $param 0 ]

            # Fin de la lecture du décalage
            set dec [ list $dx $dy $nbre_etoiles ]
        }
        return $dec
    }

    ##
    # @brief Destruction des fichiers auxiliaires
    # @return rien
    proc DestructionFichiersAuxiliaires { } {
        variable calaphot
        variable parametres

        Message debug "%s\n" [ info level [ info level ] ]

        # On efface les fichiers sextractor sauf en mode debug
        if { $parametres(niveau_message) > $calaphot(niveau_debug) } {
            catch { file delete $calaphot(sextractor,param) }
            catch { file delete $calaphot(sextractor,config) }
            catch { file delete $calaphot(sextractor,neurone) }
            catch { file delete $calaphot(sextractor,assoc) }
            catch { file delete $calaphot(sextractor,catalog) }
        }
        catch { file delete [ file join $::audace(rep_images) t1.fit ] }
        catch { file delete [ file join $::audace(rep_images) t2.fit ] }
        catch { file delete [ file join $::audace(rep_images) u1.fit ] }
        catch { file delete [ file join $::audace(rep_images) u2.fit ] }
    }

    ##
    # @brief Permet de détecter si des paramètres critiques ont changé
    # return changement
    proc DetectionChangementParamCritiques { liste_parametres } {
        variable parametres

        Message debug "%s\n" [ info level [ info level ] ]

        set changement 0
        foreach champ $liste_parametres {
            if { $parametres(origine,$champ) != $parametres($champ) } {
                set changement 1
            }
        }
        return $changement
    }

    ##
    # @brief Conversion de degrés sexagésimaux en degrés décimaux
    # @param[in] dms : valeur en degrés sexagésimaux à convertir
    # @return valeur en degrés décimaux
    proc DmsDd { dms } {

        Message debug "%s\n" [ info level [ info level ] ]

        set d [ expr double( [ lindex $dms 0 ] ) ]
        set m [ expr double( [ lindex $dms 1 ] ) ]
        set s [ expr double( [ lindex $dms 2 ] ) ]
        return [ expr ( $d + $m/60.0 + $s/3600 ) ]
    }

    ##
    # @brief Elimination d'une image
    # @param indice image à marquer invalide
    # @return
    proc EliminationImage { indice motif } {
        variable data_image
        variable data_script
        variable calaphot
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set image [ lindex $liste_image $indice ]
        Message probleme "%s %s : %s" $image $calaphot(texte,image_rejetee) $motif
        if { [ info exists data_script($indice,invalidation) ] } {
            Message notice "%s\n" $data_script($indice,invalidation)
        } else {
            Message notice "\n"
        }
        if { $data_image($indice,qualite) == "bonne" } {
            # Trappe pour les images mal classées
            Message erreur "ALERTE MAUVAISE IMAGE : YA UN PEPIN"
        }
    }

    ##
    # @brief Execution du fichier Gnuplot créé par GenerationFichierGnuplot
    # @details Uniquement sous Linux
    # @return toujours 0
    proc ExecutionGnuplot {} {
        variable parametres
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        if { ( $::tcl_platform(os) == "Linux" ) && ( $data_script(images_valides) != 0 ) } {
            set nom_fichier_gplt [ file join $::audace(rep_images) ${parametres(sortie)}.plt ]
#            set commande { exec gnuplot $nom_fichier_gplt & }
            set commande { exec gnuplot $nom_fichier_gplt }
            eval $commande
#            ::console::affiche_resultat $commande
#            canvas .c ; pack .c
#            gnuplot .c
        }
    }

    ##
    # @brief Fermeture de fichier
    # @details L'intérêt de ce code est de pouvoir tracer le nombre de fichier ouverts à un moment donné. Cela sert à détecter les "fuites de fileid", c'est-a-dire les fichiers qui sont ouverts et jamais fermés. On peut aussi tracer les fichiers qu'on tente de fermer alors qu'ils n'ont pas été ouverts.
    # @param[in] fid : 'channel' à fermer
    # @return
    proc FermetureFichier { fid } {
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        if { [ catch { close $fid } retour ] } {
            Message erreur $retour
        } else {
            incr data_script(nombre_fichier_ouvert) -1
            # A ne pas retablir sans modifier Message (risque de re-entrance infinie)
#            Message debug "nombre fichier ouvert : %d\n" $data_script(nombre_fichier_ouvert)
        }
    }

    ##
    # @brief Stockage des résultats au format Canopus
    # @return
    proc GenerationFichierCanopus {} {
        variable calaphot
        variable parametres
        variable data_image
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set nom_fichier [ file join $::audace(rep_images) ${parametres(sortie)}.cnp ]

        # effacement de la version précédente
        catch { [ file delete -force $nom_fichier ] }

        set f [open $nom_fichier "w"]
        puts -nonewline $f "Observation Data:\n"
        puts -nonewline $f "-----------------\n"
        puts -nonewline $f "    Date          UT           OM           C1         C2        C3         C4        C5         U          CA        O-C\n"

        for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
            if { $data_image($i,elimine) == "N" } {
                set temps [ mc_date2ymdhms $data_image($i,date) ]
                puts -nonewline $f [ format "%02d/%02d/%04d    " [ lindex $temps 2 ] [ lindex $temps 1 ] [ lindex $temps 0 ] ]
                puts -nonewline $f [ format "%02d:%02d:%02d    " [ lindex $temps 3 ] [ lindex $temps 4 ] [ expr round( [ lindex $temps 5 ] ) ] ]
                if { [ info exists data_image($i,var,mag_0) ] } {
                    puts -nonewline $f [ format "%7.2f     " $data_image($i,var,mag_0) ]
                } else {
                    puts -nonewline $f "99.99     "
                }
                for { set etoile 0 } { $etoile <= 5 } { incr etoile } {
                    if { [ info exists data_image($i,mag_ref_$etoile) ] } {
                        puts -nonewline $f [ format "%7.2f     " $data_image($i,ref,mag_$etoile) ]
                    } else {
                        puts -nonewline $f "99.99     "
                    }
                }
                puts -nonewline $f [ format "%s       " $data_image($i,qualite) ]
                puts -nonewline $f [ format "%7.2f    " $data_image($i,constante_mag) ]
                puts -nonewline $f [ format "%7.2f\n" [ expr $data_image($i,constante_mag) - $data_image($i,var,mag_0) ] ]
            }
        }
        close $f
    }

    ##
    # @brief Stockage des résultats avec le format CDR (cf site de Raoul Behrend)
    # @details Le contenu de ce fichier peut directement etre exporté pour le logiciel Courbrot
    # @return toujours 0
    proc GenerationFichierCDR {} {
        global audace
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        set nom_fichier [file join $::audace(rep_images) ${parametres(sortie)}.cdr]
        # effacement de la version précédente
        catch {[file delete -force $nom_fichier]}

        set f [open $nom_fichier "w"]
        puts -nonewline $f [format "NOM %s\n" $parametres(objet)]
        puts -nonewline $f [format "MES %s" $parametres(operateur)]
        if {[string length $parametres(code_UAI)] != 0} {
            puts -nonewline $f [format " @%s\n" $parametres(code_UAI)]
        } else {
            puts $f "\n"
        }
        puts -nonewline $f [format "POS 0 %5.2f\n" $data_image(0,temps_expo)]
        puts -nonewline $f [format "CAP %s\n" $parametres(type_capteur)]
        puts -nonewline $f [format "TEL %s %s %s\n" $parametres(diametre_telescope) $parametres(focale_telescope) $parametres(type_telescope)]
        puts -nonewline $f [format "CAT %s\n" $parametres(catalogue_reference)]
        puts -nonewline $f [format "FIL %s\n" $parametres(filtre_optique)]
        puts -nonewline $f [format "; %s %s %s\n" $calaphot(texte,banniere_CDR_1) $calaphot(init,version_ini) $calaphot(texte,banniere_CDR_2)]
        set image 0

        for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
            if { $data_image($i,elimine) == "N" } {
                incr image
                puts -nonewline $f " 1 1"
                # Passage de la date en format amj,ddd
                set amjhms [mc_date2ymdhms $data_image($i,date)]
                set date_claire "[format %04d [lindex $amjhms 0]]"
                append date_claire "[format %02d [lindex $amjhms 1]]"
                append date_claire "[format %02d [lindex $amjhms 2]]"
                set hms [format %6.5f [expr double([lindex $amjhms 3])/24.0 + double([lindex $amjhms 4])/1440.0 + double([lindex $amjhms 5])/86400.0]]
                set hms [string range $hms [string first . $hms] end]
                append date_claire $hms
                puts -nonewline $f [format " %14.5f" $date_claire]
                puts -nonewline $f " T"
                puts -nonewline $f [format " %6.3f" $data_image($i,var,mag_0)]
                puts -nonewline $f [format " %6.3f\n" $data_image($i,var,incertitude_0)]
            }
        }
        close $f
    }

    ##
    # @brief Stockage des résultats avec le format CdRCdL (cf http://obswww.unige.ch/~behrend/page_fmt.html)
    # @details Le contenu de ce fichier peut directement etre exporté pour le logiciel Courbrot
    # @return toujours 0
    proc GenerationFichierRBe {} {
        global audace
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        set nom_fichier [file join $::audace(rep_images) ${parametres(sortie)}.rbe]
        # effacement de la version précédente
        catch {[file delete -force $nom_fichier]}

        set f [open $nom_fichier "w"]
        puts $f "FMT xDVvRr"
        puts -nonewline $f [format "NOM %s\n" $parametres(objet)]
        puts -nonewline $f [format "MES %s" $parametres(operateur)]
        if {[string length $parametres(code_UAI)] != 0} {
            puts -nonewline $f [format " @%s\n" $parametres(code_UAI)]
        } else {
            puts -nonewline $f "\n"
        }
        puts -nonewline $f [format "POS 0 %5.2f\n" $data_image(0,temps_expo)]
        puts -nonewline $f [format "CAP %s\n" $parametres(type_capteur)]
        puts -nonewline $f [format "TEL %s %s %s\n" $parametres(diametre_telescope) $parametres(focale_telescope) $parametres(type_telescope)]
        puts -nonewline $f [format "CAT %s\n" $parametres(catalogue_reference)]
        puts -nonewline $f [format "FIL %s\n" $parametres(filtre_optique)]
        puts -nonewline $f [format "; %s %s %s\n" $calaphot(texte,banniere_CDR_1) $calaphot(init,version_ini) $calaphot(texte,banniere_CDR_2)]
        puts -nonewline $f [format "; %s\n" $calaphot(texte,format_raoul1)]
        puts -nonewline $f [format "; %s\n" $calaphot(texte,format_raoul2)]
        set image 0

        for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
            if { $data_image($i,elimine) == "N" } {
                incr image
                puts -nonewline $f [format "%03d" $image]
                # Passage de la date en format amj,ddd
                set amjhms [mc_date2ymdhms $data_image($i,date)]
                puts -nonewline $f [format " %14.5f" $data_image($i,date)]
                puts -nonewline $f [format " %6.3f" $data_image($i,var,mag_0)]
                puts -nonewline $f [format " %6.3f" $data_image($i,var,incertitude_0)]
                puts -nonewline $f [format " %6.3f" $data_image($i,ref,mag_0)]
                puts -nonewline $f [format " %6.3f\n" $data_image($i,ref,incertitude_0)]
            }
        }
        close $f
    }

    ##
    # @brief Stockage des résultats avec le format Petr Pravec
    # @return toujours 0
    proc GenerationFichierPPr {} {
        global audace
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        set nom_fichier [file join $::audace(rep_images) ${parametres(sortie)}.ppr]
        # effacement de la version précédente
        catch {[file delete -force $nom_fichier]}

        set f [open $nom_fichier "w"]
        set image 0

        for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
            if { $data_image($i,elimine) == "N" } {
                incr image
                puts -nonewline $f [format " %14.5f" $data_image($i,date)]
                puts -nonewline $f [format " %6.3f" $data_image($i,var,mag_0)]
                puts -nonewline $f [format " %6.3f\n" $data_image($i,var,incertitude_0)]
            }
        }
        close $f
    }

    ##
    # @brief Conversion de nombre décimaux en notation française
    # @return chaine convertie
    proc FormatDecimal { formattage nombre_decimal } {
        global langage

        # Message debug "%s\n" [ info level [ info level ] ]

        set nombre_formatte [ format $formattage $nombre_decimal ]
        # Message debug "nombre_formatte %s\n" $nombre_formatte
        if { [ string compare $langage "french" ] == "0" } {
            set position_point [ string first "." $nombre_formatte ]
            set partie_entiere [ string range $nombre_formatte 0 [ expr $position_point - 1 ] ]
            set partie_decimale [ string range $nombre_formatte [ expr $position_point + 1 ] end ]
            set nombre "${partie_entiere},${partie_decimale}"
        } else {
            set nombre $nombre_formatte
        }
        return $nombre
    }

    ##
    # @brief Stockage des résultats avec le format CSV (Comma Separated Values)
    # @details Le resultat de cet affichage peut directement être importé par un tableur. Le séparateur de champ est un point-virgule pour que, dans la version française, les nombres décimaux puissent avoir la virgule comme séparateur décimal.
    # @return toujours 0
    proc GenerationFichierCSV { } {
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set nom_fichier [ file join $::audace(rep_images) ${parametres(sortie)}.csv ]
        # effacement de la version précédente
        catch { file delete -force $nom_fichier }
        if { [ catch { open $nom_fichier "w" } f ] } {
            Message erreur $f
            return
        }

        puts -nonewline $f [ format "year;month;day;hour;min;sec;" ]
        puts -nonewline $f [ format "file name;no;julian day;var flux;var mag;+/-;" ]
        for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
            puts -nonewline $f [ format "ref%d flux;ref%d mag;+/-;" $etoile $etoile ]
        }
        puts -nonewline $f [ format "const. mag;quality\n" ]
        for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
            set temps [ mc_date2ymdhms $data_image($i,date) ]
            puts -nonewline $f [ format "%02d;%02d;%04d;" [ lindex $temps 0 ] [ lindex $temps 1 ] [ lindex $temps 2 ] ]
            puts -nonewline $f [ format "%02d;%02d;%02d;" [ lindex $temps 3 ] [ lindex $temps 4 ] [ expr round( [lindex $temps 5 ] ) ] ]
            puts -nonewline $f [ format "%s;%04d;%s;" [ lindex $liste_image $i ] $i [ FormatDecimal "%.5f" $data_image($i,date) ] ]
            if { [ info exists data_image($i,var,mag_0) ] } {
                puts -nonewline $f [ format "%s;%s;%s;" \
                    [ FormatDecimal "%.4f" $data_image($i,var,flux_0) ] \
                    [ FormatDecimal "%.4f" $data_image($i,var,mag_0) ] \
                    [ FormatDecimal "%.4f" $data_image($i,var,incertitude_0) ] ]
                for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
                    puts -nonewline $f [ format "%s;%s;%s;" \
                        [ FormatDecimal "%.4f" $data_image($i,ref,flux_$etoile) ] \
                        [ FormatDecimal "%.4f" $data_image($i,ref,mag_$etoile) ] \
                        [ FormatDecimal "%.4f" $data_image($i,ref,incertitude_$etoile) ] ]
                }
                puts -nonewline $f [ format "%s;" [ FormatDecimal "%.4f" $data_image($i,constante_mag) ] ]
            } else {
                puts -nonewline $f [ format "%s;%s;%s;" \
                    [ FormatDecimal "%f" "99.9999" ] \
                    [ FormatDecimal "%f" "99.9999" ] \
                    [ FormatDecimal "%f" "0.0000" ] ]
                for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
                    puts -nonewline $f [ format "%s;%s;%s;" \
                        [ FormatDecimal "%f" "99.9999" ] \
                        [ FormatDecimal "%f" "99.9999" ] \
                        [ FormatDecimal "%f" "0.0000" ] ]
                }
                puts -nonewline $f [ format "%s;" [ FormatDecimal "%f" "99.9999" ] ]
            }
            puts -nonewline $f [ format "%s\n" $data_image($i,qualite) ]
        }
        close $f
    }

    ##
    # @brief Stockage des résultats avec le format TSV (Tab Separated Values)
    # @details Le resultat de cet affichage peut directement etre importé dans la base de données du projet ETD (Exoplanet Transit Database)
    # @return toujours 0
    proc GenerationFichierETD { } {
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set nom_fichier [ file join $::audace(rep_images) ${parametres(sortie)}.etd ]
        # effacement de la version précédente
        catch { file delete -force $nom_fichier }
        if { [ catch { open $nom_fichier "w" } f ] } {
            Message erreur $f
            return
        }

        for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
            if { $data_image($i,elimine) == "N" } {
                puts $f [ format "%.5f\t%.4f\t%.4f" $data_image($i,date) $data_image($i,var,mag_0) $data_image($i,var,incertitude_0) ]
            }
        }
        close $f
    }

    ##
    # @brief Stockage des résultats avec le format TSV (Tab Separated Values)
    # @details Le resultat de cet affichage peut directement etre importé dans la base AAVSO
    # @return toujours 0
    proc GenerationFichierAAVSO { } {
    variable data_image
    variable parametres
    variable calaphot
    variable data_script
    variable liste_image
    variable ecart_type

    Message debug "%s\n" [ info level [ info level ] ]

    # Recherche de la 'check star', cad l'étoile qui a la plus faible dispersion de mesure
    set ecart_type_min 1000000
    for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile 1 } {
        if { $ecart_type(ref,$etoile) < $ecart_type_min } {
            set ecart_type_min $$ecart_type(ref,$etoile)
            set check_star $etoile
        }
    }

    set nom_fichier [ file join $::audace(rep_images) ${parametres(sortie)}.vso ]

    # effacement de la version précédente
    catch { file delete -force $nom_fichier }
    if { [ catch { open $nom_fichier "w" } f ] } {
        Message erreur $f
        return
    }

    puts $f "#ATTENTION : Avant de publier ce fichier, il convient de :"
    puts $f "# -compléter le champ OBSCODE dans l'entête avec le code AAVSO de l'observatoire"
    puts $f "# -remplacer, dans la partie data, les valeurs <cname> et <ref_?> par le nom réel de l'étoile ('comp' ou 'check' star)"
    puts $f "# -remplacer, dans la partie data, la valeur <chart> par le nom de la carte AAVSO (ou autre)"
    puts $f "#Le but étant que ce fichier soit conforme au format décrit dans http://www.aavso.org/aavso-extended-file-format"
    puts $f "#"
    puts $f "#Pour info, les mesures retenues pour le champ 'comp star' sont celles de la super-étoile."
    puts $f "#Les mesures pour le champ 'check star' correspondent à l'étoile de référence qui a la plus faible dispersion de mesure"
    puts $f "#"
    puts $f "#---8<----------------------------------------------------------------------------------------------------------"
    puts $f "#TYPE=Extended"
    puts $f "#OBSCODE="
    puts $f [ format "#SOFTWARE=%s %s" $calaphot(texte,titre) $calaphot(init,version_complete) ]
    puts $f "#DELIM=,"
    puts $f "#DATE=JD"
    puts $f "#OBSTYPE=CCD"
    puts $f "#NAME,DATE,MAG,MERR,FILT,TRANS,MTYPE,CNAME,CMAG,KNAME,KMAG,AMASS,GROUP,CHART,NOTES"

    for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
        if { $data_image($i,elimine) == "N" } {
            puts $f [ format "%s,%.5f,%.3f,%.3f,%s,NO,DIF,<cname>,%.3f,<ref_%d>,%.3f,na,na,<chart>,na" \
            $parametres(objet) \
            $data_image($i,date) \
            $data_image($i,var,mag_0) \
            $data_image($i,var,incertitude_0) \
            $parametres(filtre_optique) \
            $data_script(mag_ref_totale) \
            $check_star \
            $data_image($i,ref,mag_${check_star}) ]
        }
    }
    close $f

    }

    ##
    # @brief Stockage des résultats avec un format CSV pour Gnuplot
    # @details Le resultat de cet affichage peut directement etre importé lu par Gnuplot
    # @return la partie entière du jour julien de la première image
    proc GenerationFichierDAT { } {
        global audace
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set nom_fichier [file join $::audace(rep_images) ${parametres(sortie)}.dat]
        # effacement de la version précédente
        catch { file delete -force $nom_fichier }
        if { [ catch { open $nom_fichier "w" } f ] } {
            Message erreur $f
            return
        }

        if { $data_script(images_valides) == 0 } {
            return
        }

        set premier 1
        for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
            set temps [mc_date2ymdhms $data_image($i,date)]
            if { $data_image($i,elimine) == "N" } {
                if { $premier != 0 } {
                    # Mise en mémoire de la première donnée valide
                    set orig_temps [ expr floor($data_image($i,date)) ]
                    set orig_mag_var_0 $data_image($i,var,mag_0)
                    for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
                        set orig_mag_ref($etoile) $data_image($i,ref,mag_$etoile)
                    }
                    set orig_cste_mag $data_image($i,constante_mag)
                    set premier 0
                }
                # Enregistrement des données relatives à la première donnée
                # Pour que le diagramme soit plus lisible, les références ont un décalage de 1 mag, la cste des mag de 2
                puts -nonewline $f [ format "%04d;%15.5f;" $i [ expr $data_image($i,date) - $orig_temps ] ]
                puts -nonewline $f [ format "%07.4f;%07.4f;" [ expr $data_image($i,var,mag_0) - $orig_mag_var_0 ] $data_image($i,var,incertitude_0) ]
                for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
                    puts -nonewline $f [ format "%07.4f;%07.4f;" [ expr $data_image($i,ref,mag_$etoile) - $orig_mag_ref($etoile) + 1.0 ] $data_image($i,ref,incertitude_$etoile) ]
                }
                puts -nonewline $f [ format "%7.4f\n" [ expr $data_image($i,constante_mag) - $orig_cste_mag + 2.0 ] ]
            }
        }
        close $f
        return $orig_temps
    }

    ##
    # @brief Création d'un fichier destiné à être exécuté par Gnuplot
    # @details Ce fichier script utilise le fichier DAT comme source des données
    # @return toujours 0
    proc GenerationFichierGnuplot { origine_temps } {
        global audace
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set nom_fichier_gplt [ file join $::audace(rep_images) ${parametres(sortie)}.plt ]
        set nom_fichier_dat [ file join $::audace(rep_images) ${parametres(sortie)}.dat ]
        # effacement de la version précédente
        catch { [ file delete -force $nom_fichier_plt ] }

        if { $data_script(images_valides) == 0 } {
            return
        }

        set f [ open $nom_fichier_gplt "w" ]
        # puts $f "set terminal tkcanvas"
        puts $f "set datafile separator \";\""
        puts $f "set title \"$parametres(objet)\""
        puts $f "set xlabel \"$calaphot(texte,jour_julien) - $origine_temps\""
        puts $f "set ylabel \"$calaphot(texte,mag_relative)\""
        puts $f "set object 1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb\"white\" behind"
        puts -nonewline $f "plot \'$nom_fichier_dat\' using 2:3:4 with errorbars title \"$parametres(objet)\""
        for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
            puts $f " , \\"
            puts -nonewline $f "    \'\' using 2:[expr 5 + 2 * $etoile]:[expr 6 + 2* $etoile] with errorbars title \"$calaphot(texte,etoile_reference)  $etoile\""
        }
        puts $f " , \\"
        puts -nonewline $f "    \'\' using 2:[expr 5 + 2 * $etoile] with lines title \"$calaphot(texte,constante_mag)\""
        puts $f ""
        puts $f "pause -1"
        close $f
    }

    ##
    # @brief Génération des fichiers résultats
    # @return
    proc GenerationFichiersResultats { } {
        GenerationFichierCanopus
        GenerationFichierRBe
        GenerationFichierPPr
        GenerationFichierCSV
        GenerationFichierETD
        GenerationFichierAAVSO
        set origine_temps [ GenerationFichierDAT ]
        GenerationFichierGnuplot $origine_temps
    }

    ##
    # @brief Lecture de la taille d'une image affichée par AudACE
    # @retval data_script(naxis1) : taille de l'image sur l'axe 1 (X)
    # @retval data_script(naxis2) : taille de l'image sur l'axe 2 (Y)
    proc InformationsImages {} {
        variable data_script
        variable liste_image
        variable parametres

        Message debug "%s\n" [ info level [ info level ] ]

        buf$::audace(bufNo) bitpix float
        buf$::audace(bufNo) load [ file join $::audace(rep_images) [ lindex $liste_image 0 ] ]
        set data_script(naxis1) [ lindex [ buf$::audace(bufNo) getkwd NAXIS1 ] 1 ]
        set data_script(naxis2) [ lindex [ buf$::audace(bufNo) getkwd NAXIS2 ] 1 ]

        # Positionnement des valeurs min et max possibles pour les intensités des pixels
        Message debug "Bitpix=%s\n" [ buf$::audace(bufNo) bitpix ]
        photom_minmax [ list -3.4e+38 3.4e+38 ]

        set data_script(astrometrie) 0
        set data_script(internet) 0


        # if { $parametres(operateur) != "Etchepare" } {
            # return
        # }

        # # Recherche si cette image est recalée par astrométrie et si on peut calculer la masse d'air
        set data_script(astrometrie) 0
        if { [ catch { buf$::audace(bufNo) xy2radec [ list [ expr $data_script(naxis1) / 2.0 ]  [ expr $data_script(naxis2) / 2.0 ] ] } radec_centre ] } {
            Message debug "Série non recalée astrométriquement\n"
        } else {
            set data_script(radec_centre) $radec_centre
            set data_script(param_astrometrie) [ mc_buf2field $::audace(bufNo) ]
            Message debug "Série recalée astrométriquement : field = %s\n" $data_script(param_astrometrie)
            set latitude_site [ lindex [ buf$::audace(bufNo) getkwd "SITELAT" ] 1 ]
            set longitude_site [ lindex [ buf$::audace(bufNo) getkwd "SITELONG" ] 1 ]
            Message debug "lat = %s / long = %s \n" $latitude_site $longitude_site
            if { ( [ string length (data_script(latitude_site) ] != 0 ) && ( [ string length (data_script(longitude_site) ] != 0 ) } {
                set lat [ mc_angle2deg $latitude_site ]
                set long [ mc_angle2deg $longitude_site ]
                Message debug "lat = %f / long = %f \n" $lat $long
                if { $long > 0 } {
                    set est_ouest W
                } else {
                    set est_ouest E
                }
                set data_script(site) [ list "GPS" [ format %f $long ] $est_ouest [ format %f $lat ] 0 ]
                Message debug "site = %s\n" $data_script(site)
                set data_script(ascension_droite) [ format %f [ mc_angle2deg [ lindex $data_script(param_astrometrie) 9 ] ] ]
                set data_script(declinaison) [ format %f [ mc_angle2deg [ lindex $data_script(param_astrometrie) 11 ] ] ]
                Message debug "alpha = %f / delta = %f\n" $data_script(ascension_droite) $data_script(declinaison)
                set data_script(astrometrie) 1
                set radec [ buf$::audace(bufNo) xy2radec [ list [ expr $data_script(naxis1) / 2 ] [ expr $data_script(naxis2) / 2 ] ] ]
                set ad [ mc_angle2hms [ lindex $radec 0 ] limit=360 zero 0 auto string ]
                set dec [ mc_angle2dms [ lindex $radec 1 ]  limit=90 zero 0 + string ]
                Message notice "Coordonnées du centre de l'image : %s / %s\n" $ad $dec
                TraceFichier "Coordonnées du centre de l'image : %s / %s\n" $ad $dec
            }
        }

        # Fonctionnalité de photométrie absolue et de catalogue automatique
        # dévalidée pour cette version de Calaphot
        # return

        # if { $data_script(astrometrie) == 1 } {
            # set data_script(champ) [ CalculChampImage ]
            # Message debug "Champ image = %d'\n" $data_script(champ)
            # # Limite à 45 minutes d'arc
            # if { $data_script(champ) > 45 } {
                # Message notice "%s : %f'\n" $calaphot(texte,champ_trop_large) $data_script(champ)
                # set data_script(internet) 0
                # Message debug "%s\n" "Internet dévalidé"
            # } else {
                # set data_script(internet) 1
                # Message debug "%s\n" "Internet validé"
            # }
        # } else {
            # set data_script(internet) 0
        # }

    }

    ##
    # @brief Calcule le jour julien de la date d'exposition d'une image affichée par AudACE
    #
    # @details La date d'exposition d'une image est definie comme étant l'instant du milieu de la pose
    #
    # Cette procedure récupère le jour julien de l'image active.
    # Elle marche pour les images des logiciels suivants:
    # - CCDSoft v5, Audela et Maxim-DL:
    #   - DATE-OBS = la date uniquement,
    #   - TIME-OBS = l'heure de debut en TU,
    #   - EXPOSURE = le temps d'exposition en secondes
    #   .
    # - PRISM v4  :
    #   - DATE-OBS = date & heure de début de pose (formt Y2K: 'aaaa-mm-jjThh:mm:ss.sss')
    #   - UT-START & UT-END sont valides mais non utilisés
    #   - EXPOSURE = le temps d'exposition en minutes !
    #   .
    # .
    # @return la date exprimée en jour julien
    #
    proc JourJulienImage {} {
        global audace

        Message debug "%s\n" [info level [info level]]

        # Recherche du mot cle DATE-OBS dans l'en-tete FITS
        set date [ lindex [ buf$audace(bufNo) getkwd DATE-OBS ] 1 ]
        # Si la date n'est pas au format Y2K (date+heure)...
        if { ([ string range $date 10 10 ] != "T") \
            || ([ string range $date 4 4 ] != "-") \
            || ([ string range $date 7 7 ] != "-") } {
            # Recherche mot cle TIME-OBS
            set time [ lindex [ buf$audace(bufNo) getkwd TIME-OBS ] 1 ]
            if {[string length $time] != 0} {
                # ...convertit en format Y2K!
                set date [string range $date 0 9]
                set time [string range $time 0 7]
                append date "T"
                append date $time
            } else {
                set time [buf$audace(bufNo) getkwd UT-START]
                set time [lindex $time 1]
                if {[string length $time] != 0} {
                    # ...convertit en format Y2K!
                    set date [string range $date 0 9]
                    set time [string range $time 0 7]
                    append date "T"
                    append date $time
                } else {
                    Message erreur "Pas d'heure"
                    set date "0000-00-00T00:00:00"
                }
            }
        } else {
            set date [string range $date 0 22]
        }

        Message debug "Date=%s\n" $date
        # Conversion en jour julien (Julian Day)
        set jd_instant [mc_date2jd $date]
        return $jd_instant
    }

    ##
    # @brief Sortie de valeur sur la console et le fichier de log
    # @details @see @ref Console
    # @param[in] niveau_info : le niveau d'affichage
    # @param[in] args : le message formatté à afficher
    # @return
    proc Message { niveau_info args } {
        global audace
        variable parametres
        variable calaphot

        set param [ eval [ concat format $args ] ]
        if { $niveau_info == "debug" } {
            set niveau_pile [ info level ]
            incr niveau_pile -1
            if { $niveau_pile >= 0 } {
                set procedure [ lindex [ info level $niveau_pile ] 0 ]
            } else {
                set procedure ""
            }
            Console $niveau_info "$procedure :: $param"
        } else {
            Console $niveau_info $param
#            if { [ info exists parametres(sortie) ] } {
#                # parametres n'existe pas au tout début du script
#                TraceFichier ${parametres(sortie)}.txt $niveau_info $param
#            }
        }
    }

    # L'image dans la mémoire est celle à tester
    proc TestWCS { } {
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        set r 1
        if { [ catch { buf$::audace(bufNo) xy2radec [ list [ expr $data_script(naxis1) / 2.0 ]  [ expr $data_script(naxis2) / 2.0 ] ] } ] } {
            set r 0
        }
        if { ( [ string length [ buf$::audace(bufNo) getkwd "CD1_1" ] ] == 0 ) \
            || ( [ string length [ buf$::audace(bufNo) getkwd "CD1_2" ] ] == 0 ) \
            || ( [ string length [ buf$::audace(bufNo) getkwd "CD2_1" ] ] == 0 ) \
            || ( [ string length [ buf$::audace(bufNo) getkwd "CD2_2" ] ] == 0 ) } {
            set r 0
        }
        Message debug "r = %d\n" $r
        return $r
    }


    # L'image dans la mémoire est celle à recaler
    proc RecalageImages { entree sortie nombre i } {
        variable data_script
        variable data_image
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set image [ lindex $liste_image $i ]

        # registerwcs
        Message debug "Recalage par registerwcs\n"
        set c1 [ info exists data_script(radec_centre) ]
        set c2 [ TestWCS ]
        if  { $c1 && $c2 && ( ![ catch { registerwcs $entree $sortie $nombre } ] ) } {
            buf$::audace(bufNo) load [ file join $::audace(rep_images) ${sortie}2 ]
            set radec [ buf$::audace(bufNo) xy2radec [ list [ expr $data_script(naxis1) / 2.0 ]  [ expr $data_script(naxis2) / 2.0 ] ] ]
            if { $radec == $data_script(radec_centre) } {
                set decalage [ DecalageImage $i ]
                set data_image($i,decalage_x) [ lindex $decalage 0 ]
                set data_image($i,decalage_y) [ lindex $decalage 1 ]
                return 0
            }
        }

        # register2
        Message debug "Recalage par register2\n"
        if { ! [ catch { register2 $entree $sortie $nombre } ] } {
            buf$::audace(bufNo) load [ file join $::audace(rep_images) ${sortie}2 ]
            set decalage [ DecalageImage $i ]
            set data_image($i,decalage_x) [ lindex $decalage 0 ]
            set data_image($i,decalage_y) [ lindex $decalage 1 ]

            # Le nombre d'objets ayant servi au recalage doit être pifométriquement supérieur au tiers du nombre initial
            Message debug "image %s %d : %d objets pour recaler \n" $image $i [ lindex $decalage 2 ]
            set objets [ lindex $decalage 2 ]
            if { [ info exists data_script(nombre_objets_recales) ] } {
                if { $objets >= [ expr $data_script(nombre_objets_recales) / 3 ] } {
                    return 0
                }
            } else {
                set data_script(nombre_objets_recales) [ lindex $decalage 2 ]
                Message debug "%d objets utilisés au recalage \n" $data_script(nombre_objets_recales)
                return 0
            }
        }

        # register
        Message debug "Recalage par register\n"
        if { ! [ catch { register $entree $sortie $nombre } ] } {
            buf$::audace(bufNo) load [ file join $::audace(rep_images) ${sortie}2 ]
            set decalage [ DecalageImage $i ]
            set data_image($i,decalage_x) [ lindex $decalage 0 ]
            set data_image($i,decalage_y) [ lindex $decalage 1 ]

            # Le nombre d'objets ayant servi au recalage doit être pifométriquement supérieur au tiers du nombre initial
            Message debug "image %s %d : %d objets pour recaler \n" $image $i [ lindex $decalage 2 ]
            set objets [ lindex $decalage 2 ]
            if { [ info exists data_script(nombre_objets_recales) ] } {
                if { $objets >= [ expr $data_script(nombre_objets_recales) / 3 ] } {
                    return 0
                }
            } else {
                set data_script(nombre_objets_recales) [ lindex $decalage 2 ]
                Message debug "%d objets utilisés au recalage \n" $data_script(nombre_objets_recales)
                return 0
            }
        }
        return -1
    }

    ##
    # @brief Mesure du décalage (x,y) entre 2 images par recalage entre elles
    # @details Si cette valeur a été mesurée auparavant dans une session précédente de Calaphot
    # cette valeur sera extraite du fichier de décalage
    # Sinon le décalage est effectué par recalage (register) de l'image par rapport à une image t1.fit
    # La valeur du recalage est stockée dans l'entete FITS de l'image.
    # On mesure la qualité du recalage par le nombre d'objets ayant servi au recalage.
    # @param[in] i : numero de l'image dans la séquence
    # @retval data_image($i,decalage_x) : decalage en x
    # @retval data_image($i,decalage_y) : decalage en y
    # @return 0 si recalage correct, -1 sinon.
    proc MesureDecalage { i } {
        variable parametres
        variable liste_decalage
        variable data_image
        variable data_script
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set retour 0
        set image [ lindex $liste_image $i ]
        # Détermination du décalage des images par rapport à la première
        if { $parametres(type_images) == "non_recalees" } {
            # Images non recalées
            if [ info exist liste_decalage($image) ] {
                # Cette valeur existe dans le fichier .lst
                Message debug "Décalage déjà calculé\n"
                set data_image($i,decalage_x) [ lindex $liste_decalage($image) 0 ]
                set data_image($i,decalage_y) [ lindex $liste_decalage($image) 1 ]
            } else {
                # Recalage des images par rapport à la première image pour connaître le décalage en coordonnées
                Message debug "Décalage en cours de calcul\n"
                buf$::audace(bufNo) load [ file join $::audace(rep_images) $image ]
                buf$::audace(bufNo) save [ file join $::audace(rep_images) t2 ]

                set v [ RecalageImages t u 2 $i ]
                if { $v < 0 } {
                    set data_image($i,qualite) "mauvaise"
                    set retour -1
                    set data_script($i,invalidation) "Probleme de recalage"
                }

                # Rétablissement de l'image sur laquelle seront faites les mesures
                ChargementImageParIndice $i
                update
            }
        } else {
            # Les images sont déjà recalées, pas de décalage entre elles
            Message debug "Les images sont toutes recalées\n"
            set data_image($i,decalage_x) 0.0
            set data_image($i,decalage_y) 0.0
        }
        Message debug "image %s %d: decalage_x=%10.4f decalage_y=%10.4f\n" $image $i $data_image($i,decalage_x) $data_image($i,decalage_y)
        return $retour
    }


    ##
    # @brief Ouverture de fichier
    # @details L'interet de ce code est de pouvoir tracer le nombre de fichier ouverts à un moment donne. Cela sert a detecter les "fuites de fileid", c'est-a-dire les fichiers qui sont ouverts et jamais fermes. On peut aussi tracer les fichiers qu'on tente de fermer alors qu'ils n'ont pas été ouverts.
    # @param[in] nom_fichier : nom du fichier
    # @param[in] mode : mode d'ouverture comme defini par TCL
    # @param[in] fatal : drapeau. Si fatal = oui(defaut), affichage d'un message d'ereeur dans la console
    # @retval data_script(nombre_fichier_ouvert) : nombre de fichiers ouverts par ce script
    # @return 'channel' du fichier ouvert si l'ouverture a eu lieu
    # @return "" si l'ouverture a echoue
    proc OuvertureFichier {nom_fichier mode {fatal "oui"} } {
        variable data_script

        Message debug "%s\n" [info level [info level]]

        if {[catch {open $nom_fichier $mode} fid]} {
            if {$fatal == "oui"} {
                Message erreur $fid
            }
            return ""
        } else {
            incr data_script(nombre_fichier_ouvert)
            # A ne pas retablir sans modifir Message (risque de re-entrance infinie)
#            Message debug "nombre fichier ouvert : %d\n" $data_script(nombre_fichier_ouvert)
            return $fid
        }
    }

    ##
    # @brief Affichage des options et paramètres qui ont ete saisis
    # @return
    proc RecapitulationOptions {} {
        variable parametres
        variable calaphot

        Message debug "%s\n" [info level [info level]]

        Message notice "--------------------------\n"
        TraceFichier "--------------------------\n"
        Message notice "%s\n" $calaphot(texte,recapitulation)
        TraceFichier "%s\n" $calaphot(texte,recapitulation)
        foreach champ { objet operateur code_UAI type_capteur type_telescope diametre_telescope focale_telescope catalogue_reference source indice_premier nombre_images signal_bruit gain_camera bruit_lecture sortie fichier_cl } {
            Message notice "\t%s : %s\n" $calaphot(texte,$champ) $parametres($champ)
            TraceFichier "\t%s : %s\n" $calaphot(texte,$champ) $parametres($champ)
        }
        foreach champ { mode type_images date_images pose_minute } {
            Message notice "\t%s : %s\n" $calaphot(texte,$champ) $parametres($champ)
            TraceFichier "\t%s : %s\n" $calaphot(texte,$champ) $parametres($champ)
        }
        if { $parametres(mode) == "ouverture" } {
            foreach champ { surechantillonage rayon1 rayon2 rayon3 } {
                Message notice "\t%s : %s\n" $calaphot(texte,o_$champ) $parametres($champ)
                TraceFichier "\t%s : %s\n" $calaphot(texte,o_$champ) $parametres($champ)
            }
        }
        # pas de parametre specifique a la modelisation
#        if {$parametres(mode) == "modelisation"} {
#        }
        #if { $parametres(mode) == "sextractor" } {
            #foreach champ {saturation} {
                #Message notice "\t%s : %s\n" $calaphot(texte,s_$champ) $parametres($champ)
            #}
        #}
        Message notice "--------------------------\n"
        TraceFichier "--------------------------\n"
    }

    ##
    # @brief Recherche de l'etoile selectionne la plus brillante
    # @details Parcours de la liste pos_theo(ref,i)
    # @return indice de l'etoile la plus brillante de la liste
    proc RecherchePlusBrillante {} {
        variable parametres
        variable data_script
        variable pos_theo

        Message debug "%s\n" [info level [info level]]

        set plus_brillante 0
        set mag_min [lindex $pos_theo(ref,0) 2]
        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            if {[lindex $pos_theo(ref,$i) 2] < $mag_min} {
                set mag_min [lindex $pos_theo(ref,$i) 2]
                set plus_brillante $i
            }
        }
        return $plus_brillante
    }

    ##
    # @brief Recalage des première et dernière image (si nécessaire)
    # @details Extraction du nombre d'objets utilisés au recalage pour pouvoir qualifier le recalage des autres images
    # @retval le nom des images recalées (ou pas)
    proc RecalageInitial {} {
        variable parametres
        variable data_script
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        # Création des images t1 et t2, copies de la première et de la dernière image
        buf$::audace(bufNo) load [ file join $::audace(rep_images) [ lindex $liste_image 0 ] ]
        buf$::audace(bufNo) save [ file join $::audace(rep_images) t1 ]
        buf$::audace(bufNo) load [ file join $::audace(rep_images) [ lindex $liste_image end ] ]
        buf$::audace(bufNo) save [ file join $::audace(rep_images) t2 ]

        if { $parametres(type_images) == "non_recalees" } {
            # Recalage de la première et de la dernière image en u1 et u2
            set v [ RecalageImages t u 2 [ llength $liste_image ] ]
            if { $v < 0 } {
                return z
            } else {
                return u
            }
        } else {
            return t
        }
    }

    ##
    # @brief Lecture conditionnelle du fichier .lst qui,s'il existe, contient les décalages entre images calculés lors d'une session précédente de Calaphot
    # @return
    proc RecuperationDecalages {} {
        global audace
        variable parametres
        variable liste_decalage
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        catch { unset liste_decalage }

        # On détecte des changements dans certains paramètres saisis.
        set param_critiques [ list \
            source \
            indice_premier \
        ]
        set changement [ DetectionChangementParamCritiques $param_critiques ]

        # S'il y a eu un changement, on efface le fichier .lst
        if { $changement } {
            catch { [ file delete [ file join $::audace(rep_images) $parametres(source).lst ] ] }
            Message debug "Changement dans un paramètre critique : suppression de la liste et du fichier des décalages\n"
            return
        }

        set erreur 0
        set fichier [ OuvertureFichier [ file join $::audace(rep_images) $parametres(source).lst ] r "non" ]
        if { $fichier != "" } {
            set premiere_ligne 1
            while { ( [ gets $fichier line ] >= 0 ) && ( $erreur == 0 ) } {
                set image [ lindex $line 0 ]
                set dec_x [ lindex $line 1 ]
                set dec_y [ lindex $line 2 ]
                set liste_decalage($image) [ list $dec_x $dec_y ]
                # Capture de l'index de l'image origine des recalages
                if { ( $premiere_ligne == 1 ) } {
                    if { ( $image != [ lindex $liste_image 0 ] ) || ( $dec_x != 0 ) || ( $dec_y != 0 ) } {
                        Message debug "L'image origine des décalages n'est pas en tête de fichier\n"
                        Message debug "image %s: dec_x=%f dec_y=%f\n" $image $dec_x $dec_y
                        set erreur 1
                    }
                    set premiere_ligne 0
                } else {
                    Message debug "image %s: dec_x=%10.4f dec_y=%10.4f\n" $image $dec_x $dec_y
                }
            }
            FermetureFichier $fichier
        } else {
            set erreur 1
        }

        if { $erreur != 0 } {
            catch { unset liste_decalage }
        }

    }

    #*************************************************************************#
    #*************  RecuperationParametres  **********************************#
    #*************************************************************************#
    ##
    # @brief Lecture des paramètres stockés dans calaphot.ini et initialisations
    # @details Si certains paramètres n'existent pas dans ce fichier, ou si ce fichier n'existe pas lui-même,
    # ou encore si on a changé de version de Calaphot,
    # les paramètres sont initialisés avec des valeurs par défaut (cf Calaphot::InitialisationStatique )
    # @retval parametres
    # @return 0
    proc RecuperationParametres {} {
        variable parametres
        variable data_script
        variable pos_theo
        variable coord_aster
        variable calaphot

        # Verrue pour renommer les anciens fichiers .ini dans le répertoire des logs.
        # Ces fichiers ne serviront plus à l'avenir.
        set ancien_fichier_ini [ file join $::audace(rep_home) calaphot.ini ]
        if { [ file exists $ancien_fichier_ini ] } {
            set ancien_fichier_ini_renomme [ file join $::audace(rep_home) calaphot.ini.old ]
            catch { file rename -force $ancien_fichier_ini $ancien_fichier_ini_renomme }
        }

        # Initialisation
        if { [ info exists parametres ] } { unset parametres }

        # Ouverture du fichier de paramètres
        set fichier $calaphot(nom_fichier_ini)

        if { [ file exists $fichier ] } {
            source $fichier
            # Vérification de la version du calaphot.ini et invalidation éventuelle du contenu
            if { ( ( ![ info exists parametres(version_ini) ] ) \
                || ( [ string compare $parametres(version_ini) $calaphot(init,version_ini) ] != 0 ) ) } {
                set fichier_renomme "${fichier}.old"
                catch { file rename -force $fichier $fichier_renomme }
                set parametres(niveau_message) $calaphot(init,niveau_message)
                # Il n'est pas possible d'utiliser Message à cause de $parametres qui n'existe plus
                ::console::affiche_erreur "$calaphot(texte,detection_ini) \n"
                foreach { a b } [ array get parametres ] { unset parametres($a) }
            }
        }

        foreach choix { mode \
            operateur \
            source \
            indice_premier \
            nombre_images \
            gain_camera \
            bruit_lecture \
            niveau_minimal \
            niveau_maximal \
            rayon1 \
            rayon2 \
            rayon3 \
            sortie \
            fichier_cl \
            objet \
            code_UAI \
            surechantillonage \
            type_capteur \
            type_telescope \
            diametre_telescope \
            focale_telescope \
            catalogue_reference \
            filtre_optique \
            niveau_message \
            tri_images \
            type_images \
            pose_minute \
            date_images \
            reprise_astres \
            signal_bruit \
            type_objet \
            defocalisation \
            version_ini } {
            if { ![ info exists parametres($choix) ] } {
                set parametres($choix) $calaphot(init,$choix)
            }
        }

        # parametres(origine,xxx) va contenir la même chose que parametres(xxx).
        # Le but est de détecter des changements dans les paramètres pour éviter d'utiliser un mauvais fichier .lst de décalage par exemple
        foreach { a b } [ array get parametres ] {
            # On refuse de recopier les clés contenant déjà le mot "origine"
            if { [ string first "origine" $a ] == -1 } {
                set parametres(origine,$a) $b
            }
        }
    }

    ##
    # @brief Verification que la libjm charge est d'une version correcte
    # @return 0 la libjm est de la bonne version
    # @return 1 cas contraire
    proc Ressources {} {
        global blt_version
        global audace
        variable calaphot

#        Message debug "%s\n" [info level [info level]]

        if { [ catch { jm_versionlib } version_lib ] } {
            Message console "%s\n" $calaphot(texte,mauvaise_version)
            return 1
        } else {
            if { [ expr double( [ string range $version_lib 0 2 ] ) ] < 4.0 } {
                Message console "%s\n" $calaphot(texte,mauvaise_version)
                return 1
            }
        }
        return 0
    }

    ##
    # @brief Sauvegarde dans un fichier des décalages entre images
    # @details Le but de ceci est d'accélérer les traitements lors d'un session Calaphot qui porterait sur les mêmes images
    # Le nom du fichier dépend du répertoire d'images et du nom générique des images
    # @return
    proc SauvegardeDecalages {} {
        variable parametres
        variable data_image
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        if { ( [ info exists liste_image ] ) && ( $parametres(type_images) == "non_recalees" ) } {
            # On ne sauvegarde les décalages que si les images ne sont pas recalées à la base

            set fichier [ OuvertureFichier [ file join $::audace(rep_images) $parametres(source).lst ] w ]
            if { ( $fichier != "" ) } {
                for { set i 0 } { $i < [ llength $liste_image ] } { incr i } {
                    set image [ lindex $liste_image $i ]
                    if { ( [ info exists data_image($i,decalage_x) ] ) && ( [ info exists data_image($i,decalage_x) ] ) } {
                        puts $fichier "$image $data_image($i,decalage_x) $data_image($i,decalage_y)"
                        Message debug "image %s %i: dec_x=%10.4f dec_y=%10.4f\n" $image $i $data_image($i,decalage_x) $data_image($i,decalage_y)
                    }
                }
            }
            FermetureFichier $fichier
        }
    }

    ##
    # @brief Sauvegarde dans un fichier des paramètres de la session courante
    # @details Ces paramètres ont été lus dans le fichier calaphot.ini, et éventuellement
    # modifiés dans l'écran de saisie
    # @return
    proc SauvegardeParametres {} {
        variable parametres
        variable data_script
        variable coord_aster
        variable pos_theo
        variable calaphot

        Message debug "%s\n" [ info level [ info level ] ]

        set fichier [ OuvertureFichier $calaphot(nom_fichier_ini) w ]
        if { ( $fichier != "" ) } {
            foreach { a b } [ array get parametres ] {
                if { [ string first "origine" $a ] == -1 } {
                    puts $fichier "set parametres($a) \"$b\""
                }
            }

            if { [ info exists data_script(nombre_variable) ] } {
                puts $fichier "set data_script(nombre_variable) $data_script(nombre_variable)"
                for { set i 0 } { $i < $data_script(nombre_variable) } { incr i } {
                    puts $fichier "set coord_aster($i,1) \{$coord_aster($i,1)\}"
                    puts $fichier "set coord_aster($i,2) \{$coord_aster($i,2)\}"
                }
            }
            if { [ info exists data_script(nombre_reference) ] } {
                puts $fichier "set data_script(nombre_reference) $data_script(nombre_reference)"
                for { set i 0 } { $i < $data_script(nombre_reference) } { incr i } {
                    # Il se peut que l'utilisateur ait arrêté avant de positionner les astéroides
                    if [ info exist pos_theo(ref,$i) ] {
                        puts $fichier "set pos_theo(ref,$i) \{$pos_theo(ref,$i)\}"
                    }
                }
            }
            if { [ info exists data_script(nombre_indes) ] } {
                puts $fichier "set data_script(nombre_indes) $data_script(nombre_indes)"
                for { set i 0 } { $i < $data_script(nombre_indes) } { incr i } {
                    # Il se peut que l'utilisateur ait arrêté avant de positionner les astéroides
                    if [ info exist pos_theo(indes,$i) ] {
                        puts $fichier "set pos_theo(indes,$i) \{$pos_theo(indes,$i)\}"
                    }
                }
            }
        }
        FermetureFichier $fichier
    }

    ##
    # @brief Ecrit des messages dans un fichier de log
    # @details @see @ref Console
    # @param args : le message formaté à afficher
    # @return
    proc TraceFichier { args } {
        variable calaphot
        variable parametres

        set fid [ open [ file join $::audace(rep_images) ${parametres(sortie)}.txt ] a ]
        puts -nonewline $fid [ eval [ concat { format } $args ] ]
        close $fid
    }

    ##
    # @brief Géneration de la liste des images, et éventuellement tri des images par dates croissantes, et éliminant les doublons.
    # @details : ATTENTION : cette liste va contenir tous les noms d'image qui commencent par parametres(source), même celles qui ne sont pas concernées
    # @retval liste_image : liste triée de tous les noms des images
    # @retval data_script(premier_liste) : nom de la premiere image
    # @retval data_script(dernier_liste) : nom de la derniere image
    # @return
    proc GenerationListeImage {} {
        global audace
        variable parametres
        variable data_script
        variable data_image
        variable calaphot

        Message debug "%s\n" [ info level [ info level ] ]

        # Recherche brutale de toutes les images .fit dont le nom commence par le nom générique
        set expression_glob "$parametres(source)*.fit"
        Message debug "expression_glob %s\n" $expression_glob
        set liste_glob [ lsort -dictionary [ glob -nocomplain -directory $::audace(rep_images) -tails -- $expression_glob ] ]
        Message debug "Taille de la 1ère liste d'image %d\n" [ llength $liste_glob ]
        # Recherche d'un nom dont le début est le nom générique, suivi par aucun, un ou plusieurs 0, et finissant par l'indice de la 1ère image
        set indice [ lsearch -regex $liste_glob "$parametres(source)(0*)${parametres(indice_premier)}.fit" ]
        # Création de la sous-liste
        set sous_liste_glob [ lrange $liste_glob $indice [ expr $indice + $parametres(nombre_images) - 1 ] ]
        Message debug "Taille de la liste d'image %d\n" [ llength $sous_liste_glob ]
        if { [ llength $sous_liste_glob ] == 0 } {
            set message "$calaphot(texte,liste_vide) $parametres(source)*.fit"
            Message erreur "%s\n" $message
            tk_messageBox -message $message -icon error -title $calaphot(texte,probleme)
            return [ list ]
        }
        if { $indice < 0 } {
            set message "$calaphot(texte,liste_vide) $parametres(source)\*$parametres(indice_premier).fit"
            Message erreur "%s\n" $message
            tk_messageBox -message $message -icon error -title $calaphot(texte,probleme)
            return [ list ]
        }
        if { [ llength $sous_liste_glob ] < 2 } {
            Message erreur "$calaphot(texte,liste_image) %s\n" $sous_liste_glob
            tk_messageBox -message $calaphot(texte,trop_peu_image) -icon error -title $calaphot(texte,probleme)
            return [ list ]
        }
        if { [ llength $sous_liste_glob ] < $parametres(nombre_images) } {
            set message "$calaphot(texte,trop_peu_image_2) \([ llength $sous_liste_glob ] < $parametres(nombre_images)\)\n$calaphot(texte,question_continuer)"
            Message erreur "%s\n" "$calaphot(texte,trop_peu_image_2) \([ llength $sous_liste_glob ] < $parametres(nombre_images)\)"
            set choix [ tk_messageBox -message $message -type yesno -icon error -title $calaphot(texte,probleme) ]
            if { $choix == "no" } {
                return [ list ]
            }
        }

        if { $parametres(tri_images) == "oui" } {
            # Les images ne sont pas triées par date, il faut donc le faire
            Message info "%s\n" $calaphot(texte,tri_images)
            set liste_date [ list ]
            set liste_image_triee [ list ]
            catch { unset tableau_date }

            set i 0
            foreach image $sous_liste_glob {
                buf$::audace(bufNo) load [ file join $::audace(rep_images) $image ]
                DateImage $i
                # Pour éviter les doublons
                if { ![ info exists tableau_date($data_image($i,date)) ] } {
                    set tableau_date($data_image($i,date)) $image
                    lappend liste_date $data_image($i,date)
                }
                incr i
            }

            # Tri proprement dit
            set liste_date_triee [ lsort -real -increasing $liste_date ]
            # Création de la liste triée
            foreach date $liste_date_triee {
                lappend liste_image_triee $tableau_date($date)
            }

            # On efface une éventuelle liste de recalage, pour ne pas prendre de risque
            catch { file delete [ file join $::audace(rep_images) $parametres(source).lst ] }
        } else {
            set liste_image_triee $sous_liste_glob
        }
        set data_script(premier_liste) [ lindex $liste_image_triee 0 ]
        set data_script(dernier_liste) [ lindex $liste_image_triee end ]
        set data_script(premier_indice) 0
        set data_script(dernier_indice) [ expr [ llength $liste_image_triee ] - 1 ]
        Message debug "liste d'image %s\n" $liste_image_triee
        return $liste_image_triee
    }

    proc TailleBoite { mem { fwhm 0 } } {
        Message debug "%s\n" [ info level [ info level ] ]

        if { $fwhm == 0 } {
            #set largeur [ LargeurImage $mem ]
            #set hauteur [ HauteurImage $mem ]
            set fwhm [ FWHMImage $mem ]
        }
        set taille [ expr round($fwhm) * 2 ]
        Message debug "taille : %d\n" $taille
        return $taille
    }

    proc TailleBoiteEtoile { mem coord } {
        Message debug "%s\n" [ info level [ info level ] ]

        set x_etoile [ lindex $coord 0 ]
        set y_etoile [ lindex $coord 1 ]
        set fwhm [ FWHMImage $mem ]
        set x1 [ expr round( $x_etoile - $fwhm ) ]
        set y1 [ expr round( $y_etoile - $fwhm ) ]
        set x2 [ expr round( $x_etoile + $fwhm ) ]
        set y2 [ expr round( $y_etoile + $fwhm ) ]
        Message debug "Boite temporaire %s\n" [ list $x1 $y1 $x2 $y2 ]
        set f [ buf$mem fwhm [ list $x1 $y1 $x2 $y2 ] ]
        set fwhm_etoile [ expr max( [ lindex $f 0 ], [ lindex $f 1 ] ) ]
        Message debug "FWHM Etoile : %f\n" $fwhm_etoile
        set taille [ expr round($fwhm_etoile) * 2 ]
        Message debug "taille : %d\n" $taille
        return $taille
    }

    proc FWHMImage { mem } {
        Message debug "%s\n" [ info level [ info level ] ]

        set largeur [ LargeurImage $mem ]
        set hauteur [ HauteurImage $mem ]

        # Recherche de la dynamique de l'image
        set stats [ buf$mem stat [ list 1 1 $largeur $hauteur ] ]
        set max [ lindex $stats 2 ]
        set moy_image [ lindex $stats 4 ]
        set dyn_image [ expr $max - $moy_image ]
        Message debug "max=%.1f moy=%.1f dyn=%.1f\n" $max $moy_image $dyn_image

        # L'image est divisée en 100 rectangles
        set dl [ expr $largeur / 10 ]
        set dh [ expr $hauteur / 10 ]
        set fwhm_valide 0
        set k 0.7
        while { $fwhm_valide == 0 } {
            set liste_fwhm [ list ]
            set sfd 0
            # Message debug "k=%f\n" $k
            for { set h 0 } { $h < 10 } { incr h } {
                for { set l 0 } { $l < 10 } { incr l } {
                    set x1 [ expr $l * $dl + 1 ]
                    set y1 [ expr $h * $dh + 1 ]
                    set x2 [ expr ( $l + 1 ) * $dl ]
                    set y2 [ expr ( $h + 1 ) * $dh ]
                    set r [ list $x1 $y1 $x2 $y2 ]
                    # Recherche de la dynamique dans le rectangle
                    set stats [ buf$mem stat $r ]
                    set max [ lindex $stats 2 ]
                    # Message debug "h=%d l=%d (x1=%d y1=%d x2=%d y2=%d) max=%.1f\n" $h $l $x1 $y1 $x2 $y2 $max

                    if { $max > [ expr $moy_image + $dyn_image * $k ] } {
                        # Dans ce rectangle, il semble y avoir des étoiles.
                        set f [ buf$mem fwhm $r ]
                        set fm [ expr max( [ lindex $f 0 ], [ lindex $f 1 ] ) ]
                        lappend liste_fwhm $fm
                        # sfd = nombre de rectangles valides
                        incr sfd
                        # Message debug "h=%d l=%d (x1=%d y1=%d x2=%d y2=%d) max=%.1f fwhm=%.1f\n" $h $l $x1 $y1 $x2 $y2 $max $fm
                    }
                }
            }
            Message debug "sfd=%d\n" $sfd
            if { $sfd < 20 } {
                # Pas assez de rectangles (moins de 10% sont valides), on diminue le critère de sélection
                set k [ expr $k * 0.7 ]
                if { $k < 0.02 } {
                    # C'est une image quasiment vide ! Mais on arrete la boucle quand même
                    set fwhm_valide 1
                    Message probleme "Calcul de FWHM imprécis\n"
                }
            } else {
                Message debug "sfd=%d" $sfd
                set fwhm_valide 1
            }
        }
        set resultat [ FiltrageSigmaKappaListe $liste_fwhm 1.8 ]
        set fwhm [ lindex $resultat 1 ]
        set sfd2 [ llength [ lindex $resultat 0 ] ]
        Message debug "k=%f sfd2=%d FWHM=%f\n" $k $sfd2 $fwhm
#        set f [ buf$mem fwhm [ list 1 1 $largeur $hauteur ] ]
#        set fwhm [ expr max( [ lindex $f 0 ], [ lindex $f 1 ] ) ]
        return $fwhm
    }

    proc LargeurImage { mem } {
        Message debug "%s\n" [ info level [ info level ] ]
        set largeur [ lindex [ buf$mem getkwd NAXIS1 ] 1 ]
        Message debug "largeur : %d\n" $largeur
        return $largeur
    }

    proc HauteurImage { mem } {
        Message debug "%s\n" [ info level [ info level ] ]
        set hauteur [ lindex [ buf$mem getkwd NAXIS2 ] 1 ]
        Message debug "hauteur : %d\n" $hauteur
        return $hauteur
    }


}
# Fin du namespace Calaphot

