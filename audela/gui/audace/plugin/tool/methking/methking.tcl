#
# Fichier : methking.tcl
# Description : Outil d'aide a la mise en station par la methode de King
# Auteurs : Francois COCHARD et Jacques MICHELET
# Mise à jour $Id: methking.tcl 13000 2016-01-30 23:10:32Z robertdelmas $
#

#============================================================
# Declaration du namespace methking
#  initialise le namespace
#============================================================
namespace eval ::methking {
   package provide methking 1.19

   # Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] methking.cap ]

   variable This
   variable liste_motcle
   variable king_config
   variable fichier_log
   variable omega

   # Vitesse de rotation de la Terre (2*pi/86164.0905 rd/s)
   set omega 7.2921159e-5

   # Mots-cles et valeurs pour le fichier de configuration
   set liste_motcle [list config tempspose interpose binning poseparseq textex+ textex- textey+ textey- configdefaut focale pixel_x pixel_y nomking noir son test]
   set liste_valeur_defaut [list config 5 60 2 3 X+ X- X+ X- 0 0 0 0 king_ 0 0 0]
   set liste_valeur_max [list null 30 18000 2 15 null null null null 15 null null null null 1 60 20]
   set liste_valeur_min [list null 1 100 1 1 null null null null 0 null null null null 0 0 0]
   set liste_valeur_type [list 0 1 1 1 1 0 0 0 0 1 1 2 2 0 1 1 1] ; #vaut 1 si c'est une valeur entiere, 2 si c'est une valeur flottante

#-------------Partie Confking.tcl

   proc GetConfig {fichier tableau} {
      global caption
      global panneau
      global audace

      # passage de l'adresse du tableau de config
      upvar $tableau tableauConfig

      # Ouverture du fichier de config
      if ![file exists $fichier] {
         Message erreur "%s %s %s\n" $caption(methking,fichier) $fichier $caption(methking,non_existence)
         return
      }
      set file_id [open $fichier r]

      # Lecture des lignes et traitements
      set numero_ligne 1
      set numero_config -1

      while {[gets $file_id ligne] >= 0} {
         set motcle ""
         set valeur ""

         # Reperage des differents champs dans la ligne
         set resultat [BalayageLigne $ligne]
         if {$resultat == -1} {
            Message erreur "%s %02d : %s\n" $caption(methking,ligne) $numero_ligne $caption(methking,ecr_mot_cle)
      #  } elseif {$resultat == -2} {    ;# Cas de la ligne vide
      #     Message log "Ligne %02d OK : ligne de commentaires\n" $numero_ligne
         } elseif {$resultat == -3} {
            Message erreur "%s %02d : %s\n" $caption(methking,ligne) $numero_ligne $caption(methking,pas_valeur)
         } else { ;# Cas 'normal'

            # Verification de la syntaxe des commandes
            set resultat [FiltrageLigne]

            # Cas d'erreurs ou la ligne ne sera pas traitee
            if {$resultat == -1} {
               Message erreur "%s %02d : %s\n" $caption(methking,ligne) $numero_ligne caption(methking,mot_cle_invalide)
            } elseif {$resultat == -2} {
               Message erreur "%s %02d : %s\n" $caption(methking,ligne) $numero_ligne $caption(methking,valeur_non_entiere)
            } else { ;# Cas 'normal' ou la ligne sera effectivement traitee
               if {$resultat == -3} {
                  # Ce n'est qu'un warning
                  Message avertissement "%s %02d : %s %d\n" $caption(methking,ligne) $numero_ligne $caption(methking,recalage_min) $valeur
               } elseif {$resultat == -4} {  ;# Ce n'est qu'un warning
                  Message avertissement "%s %02d : %s %d\n" $caption(methking,ligne) $numero_ligne $caption(methking,recalage_max) $valeur
               }
               # Le mot cle et sa valeur associee sont declares corrects
               # Recherche du mot cle 'Config'
               switch -exact -- $motcle {
                  config {
                     incr numero_config
                     set tableauConfig($motcle,$numero_config) $valeur
                  }
                  configdefaut {set panneau(methking,config_defaut) $valeur}
                  nomking {set panneau(methking,nom_image_temp) $valeur}
                  default {
               # Tant que le premier mot cle [Config] n'a pas ete trouve rien ne se passe
                     if {$numero_config >= 0} {
                        # Enfin ! On attribue la valeur au mot cle de la config
                        set tableauConfig($motcle,$numero_config) $valeur
                     }
                  }
               }
            }
         }
         incr numero_ligne
         #  Message test "\n"
      }
      set panneau(methking,nombre_config) [expr $numero_config + 1]
      close $file_id

      # Verification
      Message log "%s\n" $caption(methking,recap_config)
      for {set i 0} {$i < $panneau(methking,nombre_config)} {incr i} {
         for {set j 0} {$j < [llength $::methking::liste_motcle]} {incr j} {
            set cle [lindex $::methking::liste_motcle $j]
            Message log "%s : %02d | %s : %s / %s : %s\n" $caption(methking,config) $i $caption(methking,mot_cle) $cle $caption(methking,valeur) $tableauConfig($cle,$i)
            #     Message console "Config : %02d | Mot cle : %s / Valeur : %s\n" $i $cle $tableauConfig($cle,$i)
         }
         Message log "---------------------------------------------------------\n"
      }

   }

   proc FiltrageLigne {} {
      upvar motcle motcle
      upvar valeur valeur

      #  Message test "Motcle = %s  Valeur = %s\n" $motcle $valeur

      # Recherche si le mot cle est defini dans la liste
      set indice [lsearch $::methking::liste_motcle $motcle]
      if {$indice<0} {
         return -1
      }

      # Si la valeur n'est pas un entier, les tests sont finis
      if {[lindex $::methking::liste_valeur_type $indice]==0} {
         return 0
      }

      if {[lindex $::methking::liste_valeur_type $indice]==1} {
         # Detection des valeurs entieres
         if {![TestEntier $valeur]} {
            return -2
         }
      }

      if {[lindex $::methking::liste_valeur_type $indice]==2} {
         # Detection des valeurs flottantes
         if {![string is double $valeur]} {
            return -2
         }
      }

      # Recalage de la valeur min
      if {[lindex $::methking::liste_valeur_min $indice] != "null"} {
         if {$valeur < [lindex $::methking::liste_valeur_min $indice]} {
            set valeur [lindex $::methking::liste_valeur_min $indice]
            return -3
         }
      }
      # Recalage de la valeur max
      if {[lindex $::methking::liste_valeur_max $indice] != "null"} {
         if {$valeur > [lindex $::methking::liste_valeur_max $indice]} {
            set valeur [lindex $::methking::liste_valeur_max $indice]
            return -4
         }
      }
   }

   proc BalayageLigne {ligne} {
   # Passage des parametres de retour (motcle et valeur)
      upvar motcle motcle
      upvar valeur valeur

      # Isolation de la partie de la chaine situee a gauche du premier #
      set premier_dieze [string first \# $ligne]
      if {$premier_dieze != -1} {
         set ligne [string range $ligne 0 [expr $premier_dieze-1]]
      }

      # Nettoyage des characteres <espace> en trop
      set ligne [string trim $ligne]

      # Cas de la ligne constituee uniquement de commentaires (sans mot cle)
      if {[string length $ligne] == 0} {
         return -2
      }

      # Isolation du mot cle
      set cg [string first \[ $ligne]
      set cd [string first \] $ligne]
      # Erreurs de syntaxe
      if {($cg<0 && $cd>=0) || ($cg>=0 && $cd<0)} {
         return -1
      }
      set motcle [string tolower [string range $ligne [expr $cg+1] [expr $cd-1]]]

      # Isolation de la valeur associee, et nettoyage des caracteres <espace> residuels
      set valeur [string trim [string range $ligne [expr $cd+1] end]]
      if {[string length $valeur] == 0} {
         return -3
      }
      return 0
   }

   proc TestEntier {valeur} {
      set test 1
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
         if {![string match {[0-9]} $a]} {
         set test 0
         }
      }
      return $test
   }

   proc TestEntierSigne {valeur} {
      set test 1
      # Cas du premier caractere
      set a [string index $valeur 0]
      if {![string match {[0-9-+]} $a]} {
         set test 0
      }
      # Cas des caracteres restants
      if {[string length $valeur] > 1} {
         for {set i 1} {$i < [string length $valeur]} {incr i} {
            set a [string index $valeur $i]
            if {![string match {[0-9]} $a]} {
               set test 0
            }
         }
      }
      return $test
   }

#-------------Partie Scriking.tcl
   #----- Procedure KingPreparation ------------------------------------------------------
   # La procedure KingPreparation est appelee par KingTraitement
   # (voir fichier methking.tcl)
   # Cette procedure a pour but de retourner les composantes du deplacement a effectuer sur
   # la monture (calcul de King proprement dit)
   proc KingPreparation {} {
      variable king_config
      global panneau audace caption color

      # Lance le fichier fichiertest.tcl si le parametre Test est valide dans la config active
      # (Test est un parametre du fichier methking.ini)
      if {$king_config(test,$panneau(methking,config_active)) != 0} {
         if {[file exists [file join $audace(rep_plugin) tool methking fichiertest.tcl]] == 1} {
            source [file join $audace(rep_gui) tool methking fichiertest.tcl]
         } else {
            tk_messageBox -title "$caption(methking,pb)" -type ok \
            -message "Le fichier de test\n[ file join audace plugin tool methking fichiertest.tcl ]\nest introuvable."
         }
      }

      # Initialisation des variables
      set panneau(methking,nbboites) 0
      set nom $panneau(methking,nom_image)
      set nom_reg ${nom}reg
      set nb_im_par_seq $panneau(methking,nb_im_par_seq)
      set nb_images [expr $nb_im_par_seq * 2]

      # Etape 1: Registration de toutes les images
      Message consolog $caption(methking,etape_1)
      Message status $caption(methking,status_reg)

      register [file tail $nom] [file tail $nom_reg] $nb_images
      Message consolog $caption(methking,fin_etape_1)

      # Etape 2: Recherche du decalage entre premiere et derniere image
      Message consolog $caption(methking,etape_2)
      loadima $nom_reg$nb_images
      ::audace::autovisu $audace(visuNo)
      set dec [decalage]
      set dec_max_x [lindex $dec 0]
      set dec_max_x [expr int($dec_max_x)]
      set dec_max_y [lindex $dec 1]
      set dec_max_y [expr int($dec_max_y)]
      # ----- Recherche de la taille de l'image
      set taille_image_x [lindex [buf$audace(bufNo) getkwd NAXIS1] 1 ]
      set taille_image_x [expr int($taille_image_x)]
      set taille_image_y [lindex [buf$audace(bufNo) getkwd NAXIS2] 1 ]
      set taille_image_y [expr int($taille_image_y)]
      # ----- Definition de la zone dans laquelle selectionner les etoiles
      if {$dec_max_x >= 0} {
         set cadre_x1 10
         set cadre_x2 [expr $taille_image_x - 10 - $dec_max_x]
      } else {
         set cadre_x1 [expr 10 - $dec_max_x]
         set cadre_x2 [expr $taille_image_x - 10]
      }
      if {$dec_max_y >= 0} {
         set cadre_y1 10
         set cadre_y2 [expr $taille_image_y - 10 - $dec_max_y]
      } else {
         set cadre_y1 [expr 10 - $dec_max_y]
         set cadre_y2 [expr $taille_image_y - 10]
      }
      # Je memorise le cadre dans panneau, pour pouvoir verifier plus tard que les etoiles
      # selectionnees sont bien dans ce cadre
      set panneau(methking,cadre_x1) $cadre_x1
      set panneau(methking,cadre_y1) $cadre_y1
      set panneau(methking,cadre_x2) $cadre_x2
      set panneau(methking,cadre_y2) $cadre_y2
      Message consolog $caption(methking,cadre) $cadre_x1 $cadre_y1 $cadre_x2 $cadre_y2
      Message consolog $caption(methking,fin_etape_2)

      # Etape 3: Chargement de la premiere image de la serie
      Message consolog $caption(methking,etape_3)
      Message status $caption(methking,status_selection)
      append nom 1
      loadima $nom
      ::audace::autovisu $audace(visuNo)

      # Affichage du cadre delimitant la zone acceptable pour la selection d'etoiles
      DessineRectangle [list $cadre_x1 $cadre_y1 $cadre_x2 $cadre_y2] $color(green)
      Message consolog $caption(methking,fin_etape_3) $nom
   }
   #----- Fin dela procedure KingPreparation ----------------------------

   #----- Procedure SelectionneEtoiles ---------------------------------
   proc SelectionneEtoiles {} {
      global audace panneau caption color
      set rect [ ::confVisu::getBox $audace(visuNo) ]
      if { $rect != "" } {
         # Je recupere les coordonnees de la boite de selection
         set x1 [lindex $rect 0]
         set y1 [lindex $rect 1]
         set x2 [lindex $rect 2]
         set y2 [lindex $rect 3]
         # Je teste si l'etoile selectionnee est bien dans le cadre
         set hors_cadre 0
         if {$x1 < $panneau(methking,cadre_x1)} {set hors_cadre 1}
         if {$x2 < $panneau(methking,cadre_x1)} {set hors_cadre 1}
         if {$x1 > $panneau(methking,cadre_x2)} {set hors_cadre 1}
         if {$x2 > $panneau(methking,cadre_x2)} {set hors_cadre 1}
         if {$y1 < $panneau(methking,cadre_y1)} {set hors_cadre 1}
         if {$y2 < $panneau(methking,cadre_y1)} {set hors_cadre 1}
         if {$y1 > $panneau(methking,cadre_y2)} {set hors_cadre 1}
         if {$y2 > $panneau(methking,cadre_y2)} {set hors_cadre 1}
         if {$hors_cadre == 1} {
            tk_messageBox -message $caption(methking,hors_cadre) -icon error -title $caption(methking,pb)
         } else {
            incr panneau(methking,nbboites)
            set i $panneau(methking,nbboites)
            set panneau(methking,boite$i) $rect
         # Je teste la validite de l'etoile...
            set valide [Centroide $x1 $y1 $x2 $y2]
            set code_erreur [lindex $valide 2]
            if {$code_erreur == 1} {
               # Recentrage du rectangle
               set xy [buf$audace(bufNo) centro $rect]
               set x1 [expr round([lindex $xy 0] - 7)]
               set y1 [expr round([lindex $xy 1] - 7)]
               set x2 [expr round([lindex $xy 0] + 7)]
               set y2 [expr round([lindex $xy 1] + 7)]
               # Trace du rectangle
               DessineRectangle [list $x1 $y1 $x2 $y2] $color(yellow)
               Message consolog $caption(methking,etoile) $i [lindex $valide 0] [lindex $valide 1]
            } else {
               set err(-1) $caption(methking,sb_insuffisant)
               set err(-2) $caption(methking,et_non_isolee)
               set err(-3) $caption(methking,pixel_chaud)
               tk_messageBox -message "$caption(methking,et_non_valide)\n$err($code_erreur)" \
               -icon error -title caption(methking,pb)
               incr panneau(methking,nbboites) -1
            }
         }
      }
   }
   #----- Fin dela procedure SelectionneEtoiles ------------------------

   #----- Procedure KingProcess ----------------------------------------
   proc KingProcess {} {
   global audace panneau caption conf
   # Pour ameliorer la lisibilite...
   set nom $panneau(methking,nom_image)
   set nom_reg ${nom}reg
   set nb_im_par_seq $panneau(methking,nb_im_par_seq)
   set nb_images [expr $nb_im_par_seq * 2]
   set nb_etoiles $panneau(methking,nbboites)
   buf$audace(bufNo) extension "$conf(extension,defaut)"
   set ext_fichier "$conf(extension,defaut)"

   if {$nb_etoiles == 0} {
      tk_messageBox -message $caption(methking,pas_selectionne) \
         -icon error -title caption(methking,pb)
      # Interruption du calcul !
      return
   } else {
      # J'efface les differents cadres (reperes par le tag "cadres")
      $audace(hCanvas) delete cadres

      Message consolog $caption(methking,et_selectionnees) $nb_etoiles
      Message consolog $caption(methking,fin_etape_4)

      # Etape 5: Epluchage de chaque image
      Message consolog $caption(methking,etape_5) $nb_images
      Message status $caption(methking,status_analyse)
      for {set image 1} {$image <= $nb_images} {incr image} {
      # Je charge l'image registree
      loadima $nom_reg$image
      ::audace::autovisu $audace(visuNo)
      Message consolog $caption(methking,image_no) $image

      # Lecture dans l'en-tete fi..chuut du decalage de l'image...
      set dec [decalage]
      set dec_im_x [lindex $dec 0]
      set dec_im_y [lindex $dec 1]
      Message consolog $caption(methking,decalage) $dec_im_x $dec_im_y

      # J'efface du disque l'image registree, qui ne sert plus a rien
      set a_effacer $nom_reg$image
      append a_effacer $ext_fichier
      file delete $a_effacer

      # Je charge l'image d'origine (Pas celle registree)
      loadima $nom$image

      # Extraction des date et heure de l'image
      set quand [DateHeureImage]
      set mesure(im_$image,date) $quand
      Message consolog $caption(methking,jj) $quand [mc_date2ymdhms $quand]

      # Pour chaque etoile selectionnee:
      for {set etoile 1} {$etoile <= $nb_etoiles} {incr etoile} {
         set uneetoile $panneau(methking,boite$etoile)
         # J'applique le decalage de l'image sur chaque boite, pour encadrer l'etoile:
         set x1 [expr int([lindex $uneetoile 0] + $dec_im_x)]
         set y1 [expr int([lindex $uneetoile 1] + $dec_im_y)]
         set x2 [expr int([lindex $uneetoile 2] + $dec_im_x)]
         set y2 [expr int([lindex $uneetoile 3] + $dec_im_y)]
         # Calcul du centroide de l'etoile:
         set centre [Centroide $x1 $y1 $x2 $y2]
         set mesure(im_$image,et$etoile,centre_x) [lindex $centre 0]
         set mesure(im_$image,et$etoile,centre_y) [lindex $centre 1]
         set mesure(im_$image,et$etoile,code_erreur) [lindex $centre 2]
         Message consolog $caption(methking,centre_etoile) $etoile [lindex $centre 0] [lindex $centre 1]
         if {[lindex $centre 2] != 1} {
         Message consolog $caption(methking,non_val,[lindex $centre 2])
         }
      }
      }
      Message consolog $caption(methking,fin_etape_5)

      # Etape 6: Pour chaque couple d'images...
      # J'initialise les variables contenant les corrections a apporter sur la monture
      # A la fin de la routine, je pourrai ainsi en faire la moyenne
      set corr_king_x 0.0
      set corr_king_y 0.0
      set corr2_king_x 0.0
      set corr2_king_y 0.0
      # J'initialise le nombre de couple d'images valides
      set nb_couple_valide_par_seq $nb_im_par_seq
      # Pour chaque couple d'image, donc...
      Message consolog $caption(methking,etape_6) $nb_im_par_seq
      Message status $caption(methking,status_couple)
      for {set i 1} {$i <= $nb_im_par_seq} {incr i} {
      # k est l'indice de la ieme image dans la seconde sequence
      set k [expr $i + $nb_im_par_seq]
      # J'initialise les variables contenant le decalage de chaque etoile
      # A la fin de la boucle, je pourrai ainsi en faire la moyenne
      set dec_x 0.0
      set dec_y 0.0
      # J'initialise le compteur d'etoiles valides
      set nb_etoiles_valides $nb_etoiles
      # Pour chaque etoile, donc...
      for {set j 1} {$j <= $nb_etoiles} {incr j} {
         if {$mesure(im_$i,et$j,code_erreur) == 1 && $mesure(im_$k,et$j,code_erreur) == 1} {
         # Dans le cas ou l'etoile est valide dans les deux images, je calcule le decalage
         set dx [expr $mesure(im_$k,et$j,centre_x) - $mesure(im_$i,et$j,centre_x)]
         set dy [expr $mesure(im_$k,et$j,centre_y) - $mesure(im_$i,et$j,centre_y)]
         # Et je le cumule
         set dec_x [expr $dec_x + $dx]
         set dec_y [expr $dec_y + $dy]
         } else {
         # Dans ce cas, l'etoile est non valide
         incr nb_etoiles_valides -1
         }
      }
      # Je divise par le nb d'etoiles valides pour avoir la moyenne
      if {$nb_etoiles_valides == 0} {
         # Le couple n'est pas valide: Aucune etoile n'est exploitable
         incr nb_couple_valide_par_seq -1
         Message consolog $caption(methking,couple_aucune) $i $k
      } else {
         # Dans le cas ou le couple est valide
         set mesure(im_$i,dec_x) [expr $dec_x / $nb_etoiles_valides]
         set mesure(im_$i,dec_y) [expr $dec_y / $nb_etoiles_valides]
         Message consolog $caption(methking,couple_no) $i $k \
            $mesure(im_$i,dec_x) $mesure(im_$i,dec_y) $nb_etoiles_valides

         # Je calcule le temps ecoule entre les deux images
         set dt [expr $mesure(im_$k,date) - $mesure(im_$i,date)]
         # Je convertis cette duree en secondes
         set dt [expr $dt * 86400.0]
         Message consolog $caption(methking,tps_entre) $dt

         # Je fais le calcul de King proprement dit (correction a apporter sur la monture)
         set king [KingBase $mesure(im_$i,dec_x) $mesure(im_$i,dec_y) $dt]
         Message consolog $caption(methking,correction) [lindex $king 0] [lindex $king 1]

         # Je calcule le temps ecoule entre l'image k (celle en cours de traitement, et
         # appartenant a la seconde sequence) et la derniere image de la sequence
         set dt [expr $mesure(im_$nb_images,date) - $mesure(im_$k,date)]
         # Je convertis cette duree en secondes
         set dt [expr $dt * 86400.0]

         # Je fais tourner le vecteur "correction a apporter sur la monture" de ce dt
         set king_x [lindex $king 0]
         set king_y [lindex $king 1]
         set king_corrige [KingRattrapage $king_x $king_y $dt ]
         Message consolog $caption(methking,correction_der) [lindex $king_corrige 0] [lindex $king_corrige 1]
         # Je cumule ces valeurs
         set corr_king_x [expr $corr_king_x + [lindex $king_corrige 0]]
         set corr_king_y [expr $corr_king_y + [lindex $king_corrige 1]]
         set corr2_king_x [expr $corr2_king_x + ([lindex $king_corrige 0] * [lindex $king_corrige 0])]
         set corr2_king_y [expr $corr2_king_y + ([lindex $king_corrige 1] * [lindex $king_corrige 1])]
      }
      }
      Message consolog $caption(methking,fin_etape_6)

      Message consolog $caption(methking,etape_7)
      Message status $caption(methking,status_calc_king)
      # Dans le cas o aucun couple n'est valide:
      if {$nb_couple_valide_par_seq == 0} {
      tk_messageBox -message $caption(methking,aucun_couple_ok) -icon error -title $caption(methking,pb)
      Message consolog $caption(methking,aucun_couple)
      set panneau(methking,status) 211
      } else {
      # Je divise maintenant par le nombre d'images, pour avoir la moyenne:
      set corr_king_x [expr +($corr_king_x / $nb_couple_valide_par_seq)]
      set corr_king_y [expr +($corr_king_y / $nb_couple_valide_par_seq)]

      #Et voila, j'ai mes valeurs de correction a apporter sur la monture:
      Message consolog $caption(methking,corr_king) $corr_king_x $corr_king_y

      set corr2_king_x [expr +($corr2_king_x / $nb_couple_valide_par_seq)]
      set corr2_king_y [expr +($corr2_king_y / $nb_couple_valide_par_seq)]
      set sigma2_dx [expr $corr2_king_x - (($corr_king_x) * ($corr_king_x))]
      set sigma2_dy [expr $corr2_king_y - (($corr_king_y) * ($corr_king_y))]
      if {($sigma2_dx >= 0) && ($sigma2_dy >= 0)} {
         set panneau(methking,sigma_dx) [expr sqrt($sigma2_dx)]
         set panneau(methking,sigma_dy) [expr sqrt($sigma2_dy)]
         Message consolog $caption(methking,ecart_type) $panneau(methking,sigma_dx) $panneau(methking,sigma_dy)
      }

      # Je stocke ces valeurs dans la variable globale "panneau"
      set panneau(methking,monture_dx) $corr_king_x
      set panneau(methking,monture_dy) $corr_king_y
      Message consolog $caption(methking,fin_etape_7)

      # Je valide le tout, en positionnant la variable status a 200 (= calcul termine OK)
      set panneau(methking,status) 200
      }
   }
   }
   #----- Procedure KingProcess ----------------------------------------

   #----- Procedure Decalage -------------------------------------------
   # Cette procedure releve le decalage opere sur l'image en cours
   # par la fonction register
   proc decalage {} {
      global audace

      # --- recupere la liste des mots cles de l'image Fi..chuuut
      set listkey [buf$audace(bufNo) getkwds]
      # --- on evalue chaque (each) mot cle
      foreach key $listkey {
         # --- on extrait les infos de la ligne
         # --- qui correspond au mot cle
         set listligne [buf$audace(bufNo) getkwd $key]
         set value [lindex $listligne 1]
         # --- si la valeur vaut IMA/SERIES REGISTER ...
         if {$value=="IMA/SERIES REGISTER"} {
            # --- alors on extrait l'indice du mot cle TT*
            set keyname [lindex $listligne 0]
            set lenkeyname [string length $keyname]
            set indice [string range $keyname 2 [expr $lenkeyname] ]
         }
      }
      # On a maintenant repere la fonction TT qui pointe sur la derniere registration
      # --- on recherche la ligne Fi..chuuuut contenant le mot cle indice+1
      incr indice
      set listligne [buf$audace(bufNo) getkwd "TT$indice"]

      # --- on evalue la valeur de la ligne
      set param1 [lindex $listligne 1]
      set dx [lindex [split $param1] 3]

      # --- on recherche la ligne contenant le mot cle indice+2
      incr indice
      set listligne [buf$audace(bufNo) getkwd "TT$indice"]

      set param2 [lindex $listligne 1]
      set dy [lindex $param2 2]

      # Fin de la lecture du decalage
      return [list $dx $dy]
   }
   #----- Fin dela procedure Decalage ---------------------------------------

   #----- Procedure DateHeureImage -------------------------------------------
   # Cette procedure Recupere la date et l'heure de l'image active
   proc DateHeureImage {} {
   global audace

   # Je vais chercher la ligne de l'en-tete f... qui contient la date:
   set date [buf$audace(bufNo) getkwd DATE-OBS]
   # Je recupere le second champ, qui contient la chaine de date et heure:
   set date [lindex $date 1]
   # Je le transforme en jour julien...
   set instant [mc_date2jd $date]
   # Et j'affiche tout ca:
   return $instant
   }
   #----- Fin dela procedure DateHeureImage ----------------------------------

   # -------- Procedure KingBase ---------------------------------------------
   # 7 decembre 2000
   #
   # Cette fonction est le coeur de la methode de King. Elle retourne le
   # deplacement a faire sur la monture, a partir de la mesure du
   # decalages entre deux images prises a un intervalle de temps dt
   #
   # Arguments:
   # - dx = Decalage en x mesure entre les deux images de reference
   # - dy = Decalage en y mesure entre les deux images de reference
   #     Pour dx et dy, l'unite de mesure est le pixel
   # - dt = Intervalle de temps entre les deux images de reference
   #
   # La valeur retournee est une liste avec deux elements:
   # - ciblex = correction a apporter en x (en pixels) sur la monture
   # - cibley = correction a apporter en y (en pixels) sur la monture
   #
   # Le calcul utilise est le calcul simplifie, sur la base des
   # developpements limites des fonction sin et cos

   proc KingBase {dx dy dt} {
      # On attribue a omega la vitesse de rotation de la terre (rad/s)
      variable omega
      set angle [expr $omega * $dt]
      set ciblex [expr -($dx / 2) + (sin($angle) * $dy) / (2 * (1 - cos($angle)))]
      set cibley [expr -(sin($angle) * $dx) / (2 * (1 - cos($angle))) - ($dy / 2)]
      return [list $ciblex $cibley]
   }
   # -------- Fin de la procedure KingBase dx dy dt -------------------------

   #--------- Procedure KingRattrapage --------------------------------
   # 11 decembre 2000
   #
   # Cette fonction permet de compenser la correction a
   # apporter a la monture si le reglage est fait sensiblement
   # plus tard que le calcul lui-meme
   #
   # Arguments:
   # - ciblex = Correction a apporter en x au moment de la seconde image
   # - cibley = Correction a apporter en y au moment de la seconde image
   #     Pour ciblex et cibley, l'unite de mesure est le pixel
   # - dt = Intervalle de temps ecoule depuis la seconde image
   #
   # La valeur retournee est une liste avec deux elements:
   # - ciblecorrx = nouvelle correction a apporter en x (en pixels)
   # - ciblecorry = nouvelle correction a apporter en y (en pixels)
   #
   proc KingRattrapage {ciblex cibley dt} {
      # On s'assure que les arguments sont des flottants
      set ciblex double($ciblex)
      set cibley double($cibley)
      set dt double($dt)
      # On attribue a omega la vitesse de rotation de la terre (rad/s)
      variable omega
      # Pour simplifier les expressions, on attribue a angle la valeur omega*dt
      set angle [expr ($omega * $dt)]
      set ciblecorrx [expr (($ciblex * cos($angle)) + ($cibley * sin($angle)))]
      set ciblecorry [expr (($cibley * cos($angle)) - ($ciblex * sin($angle)))]
      return [list $ciblecorrx $ciblecorry]
   }
   #--------- Fin de la procedure KingRattrapage -----------------------

   #--------- Procedure DessineRectangle -------------------------------
   proc DessineRectangle {rect couleur} {
      global audace

      # Recupere les 4 coordonnees du rectangle
      set x1 [lindex $rect 0]
      set y1 [lindex $rect 1]
      set x2 [lindex $rect 2]
      set y2 [lindex $rect 3]

      set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
      # Creation du cadre. Le tag "cadres" permettra par la suite de l'effacer facilement
      $audace(hCanvas) create rectangle [expr $x1-1] [expr $naxis2-$y1] \
         [expr $x2-1] [expr $naxis2-$y2] -outline $couleur -tags cadres
      # Rafraichissement de l'image
      ::audace::autovisu $audace(visuNo)
   }
   #--------- Fin de la procedure DessineRectangle ---------------------

   #--------- Procedure Centroide -----------------------------------------
   proc Centroide {x1 y1 x2 y2} {
   global audace

   # La fonction retourne les coordonnees du centre, et un code d'erreur
   # Le code d'erreur peut prendre les valeurs suivantes:
   #  > 1 si le resultat est valide
   #  > -1 si le rapport signal / bruit est insuffisant
   #  > -2 si l'etoile est trop etalee (non isolable dans un carre de 21*21 pixels)
   #  > -3 si l'etoile est ponctuelle (pixel chaud, cosmique)
   #
   # Definition du seuil de detection:
   set seuil 5.0

   # Recuperation le niveau de fond et le bruit de fond de l'image...
   set stat_image [stat]
   set fond [lindex $stat_image 6]
   set bruit_fond [lindex $stat_image 7]
   # Inverse les cood. en x si elles ne sont pas dans le bon ordre
   if {$x1 > $x2} {
      set echange $x1
      set x1 $x2
      set x2 $echange
   }
   # Inverse les cood. en y si elles ne sont pas dans le bon ordre
   if {$y1 > $y2} {
      set echange $y1
      set y1 $y2
      set y2 $echange
   }
   # Repere quel est le pixel le plus brillant
   set pixel_max 0
   set pixel_max_x 0
   set pixel_max_y 0
   for {set hor $x1} {$hor <= $x2} {incr hor} {
      for {set ver $y1} {$ver <= $y2} {incr ver} {
      set pixel_courant [lindex [buf$audace(bufNo) getpix [list $hor $ver] ] 1 ]
      if {$pixel_courant > $pixel_max} {
         set pixel_max $pixel_courant
         set pixel_max_x $hor
         set pixel_max_y $ver
      }
      }
   }
   # Calcul du rapport signal sur bruit
   set signal_bruit [expr ($pixel_max - $fond) / $bruit_fond]
   # Calcul invalide si signal sur bruit < seuil
   if {$signal_bruit < $seuil} {
      set code_erreur -1
      Message consolog "snr=%f < %f\n" $signal_bruit $seuil
      return [list 0 0 $code_erreur signal/bruit trop faible]
   }
   # Definition du seuil mini pour considerer qu'un pixel est significatif
   # set seuil_mini [expr int(($pixel_max - $fond) / 5.0 + $fond)]
   set seuil_mini [expr $fond + ($seuil * $bruit_fond)]
   set matrice($pixel_max_x,$pixel_max_y) [expr $pixel_max - $fond]

   # Identifie les pixels significatifs autour du sommet
   set couche 1
   set nb_pixels_valides 1
   while {$couche <= 10} {
      set couche_valide 0
      for {set hor [expr $pixel_max_x - $couche]} \
         {$hor <= [expr $pixel_max_x + $couche]} {incr hor} {
      set en_haut [expr $pixel_max_y + $couche]
      set pixel_haut [lindex [buf$audace(bufNo) getpix [list $hor $en_haut]] 1 ]
      set matrice($hor,$en_haut) 0
      if {$pixel_haut > $seuil_mini} {
         set matrice($hor,$en_haut) [expr $pixel_haut - $fond]
         set couche_valide 1
         incr nb_pixels_valides
      }
      set en_bas [expr $pixel_max_y - $couche]
      set pixel_bas [lindex [buf$audace(bufNo) getpix [list $hor $en_bas]] 1 ]
      set matrice($hor,$en_bas) 0
      if {$pixel_bas > $seuil_mini} {
         set matrice($hor,$en_bas) [expr $pixel_bas - $fond]
         set couche_valide 1
         incr nb_pixels_valides
      }
      }
      for {set ver [expr $pixel_max_y - $couche + 1]} \
         {$ver <= [expr $pixel_max_y + $couche - 1]} {incr ver} {
      set a_droite [expr $pixel_max_x + $couche]
      set pixel_droit [lindex [buf$audace(bufNo) getpix [list $a_droite $ver]] 1 ]
      set matrice($a_droite,$ver) 0
      if {$pixel_droit > $seuil_mini} {
         set matrice($a_droite,$ver) [expr $pixel_droit - $fond]
         set couche_valide 1
         incr nb_pixels_valides
      }
      set a_gauche [expr $pixel_max_x - $couche]
      set pixel_gauche [lindex [buf$audace(bufNo) getpix [list $a_gauche $ver]] 1]
      set matrice($a_gauche,$ver) 0
      if {$pixel_gauche > $seuil_mini} {
         set matrice($a_gauche,$ver) [expr $pixel_gauche - $fond]
         set couche_valide 1
         incr nb_pixels_valides
      }
      }
      set nb_couches $couche
      incr couche
      if {$couche_valide == 0} {set couche 100}
   }

   # Calcul invalide si 10 couches n'ont pas suffi a cerner l'etoile
   if {$couche == 11} {
      set code_erreur -2
      return [list 0 0 $code_erreur etoile non isolee]
   }

   # Calcul invalide si il n'y a pas au moins 9 pixels valides
   if {$nb_pixels_valides < 9} {
      set code_erreur -3
      return [list 0 0 $code_erreur pixel chaud]
   }

   # Calcul du centre...
   set centre_x 0.0
   set centre_y 0.0
   set flux 0
   for {set hor [expr $pixel_max_x - $nb_couches]} \
      {$hor <= [expr $pixel_max_x + $nb_couches]} {incr hor} {
      for {set ver [expr $pixel_max_y - $nb_couches + 1]} \
         {$ver <= [expr $pixel_max_y + $nb_couches - 1]} {incr ver} {
      set pixel [lindex [buf$audace(bufNo) getpix [list $hor $ver]] 1 ]
      set centre_x [expr $centre_x + ($hor * $matrice($hor,$ver))]
      set centre_y [expr $centre_y + ($ver * $matrice($hor,$ver))]
      set flux [expr $flux + $matrice($hor,$ver)]
      }
   }
   set centre_x [expr $centre_x / $flux]
   set centre_y [expr $centre_y / $flux]
   set code_erreur 1
   return [list $centre_x $centre_y $code_erreur]
   }
   #----- Fin dela procedure Centroide ------------------------

#-------------Partie Autoking.tcl
#----- Procedure KingAuto------------------------------------------------------
   proc KingAuto {} {
      variable king_config
      global panneau
      global audace
      global caption
      global conf

      # Lance la procedure FichierTest si le parametre Test est valide dans la config active
      #   (Test est un parametre du fichier methking.ini)
      if {$king_config(test,$panneau(methking,config_active)) != 0} {
         if {[file exists [file join $audace(rep_plugin) tool methking fichiertest.tcl]] == 1} {
            source [file join $audace(rep_gui) tool methking fichiertest.tcl]
         } else {
            tk_messageBox -title "$caption(methking,pb)" -type ok \
            -message "Le fichier de test\n[ file join audace plugin tool methking fichiertest.tcl ]\nest introuvable."
         }
      }

      set nom $panneau(methking,nom_image)
      set nom_reg ${nom}reg
      set nb_im_par_seq $panneau(methking,nb_im_par_seq)
      set nb_images [expr $nb_im_par_seq * 2]
      buf$audace(bufNo) extension "$conf(extension,defaut)"
      set ext_fichier "$conf(extension,defaut)"

      # Etape 1: Recalage de toutes les images
      Message consolog "%s\n" $caption(methking,recalage)
      Message status $caption(methking,recalage)
      register [file tail $nom] [file tail $nom_reg] $nb_images

      Message consolog "%s\n" $caption(methking,status_analyse)
      Message status $caption(methking,status_analyse)
      for {set image 1} {$image <= $nb_images} {incr image} {
         Message consolog "\t%s %s\n" $caption(methking,image) $image
         buf$audace(bufNo) load "$nom$image"

         # Extraction des date et heure de l'image
         set mesure(im_$image,date) [DateHeureImage]
         Message consolog "\t\t%s %s (%s)\n" $caption(methking,date) [mc_date2ymdhms $mesure(im_$image,date)] $mesure(im_$image,date)
      }

      set corr_king_x 0.0
      set corr_king_y 0.0
      set corr2_king_x 0.0
      set corr2_king_y 0.0

      # Pour chaque couple d'image, donc...
      Message consolog $caption(methking,status_couple)
      Message status $caption(methking,status_couple)
      for {set i 1} {$i <= $nb_im_par_seq} {incr i} {
         # k est l'indice de la ieme image dans la seconde sequence
         set k [expr $i + $nb_im_par_seq]

         Message consolog "\t%s %d / %d\n" $caption(methking,couple) $i $k

         # Mesure du decalage
         set dec_x 0.0
         set dec_y 0.0

         buf$audace(bufNo) load "$nom_reg$i"
         set decal_1 [decalage]

         buf$audace(bufNo) load "$nom_reg$k"
         set decal_2 [decalage]

         set decal_x [expr [lindex $decal_2 0] - [lindex $decal_1 0]]
         set decal_y [expr [lindex $decal_2 1] - [lindex $decal_1 1]]
         Message consolog "\t\tDx=%5.2f / Dy=%5.2f\n" $decal_x $decal_y

         # Calcul du temps ecoule entre les deux images
         set dt [expr $mesure(im_$k,date) - $mesure(im_$i,date)]
         set dt [expr $dt * 86400.0]
         Message consolog "\t\tDt=%5.2f\n" $dt

         # Calcul de King proprement dit (correction a apporter sur la monture)
         set king [KingBase $decal_x $decal_y $dt]
         Message consolog "\t\t%s x=%5.2f / y=%5.2f\n" $caption(methking,correction_brute) [lindex $king 0] [lindex $king 1]

         # Calcul du temps ecoule entre l'image k (celle en cours de traitement, et
         # appartenant a la seconde sequence) et la derniere image de la sequence
         set dt [expr $mesure(im_$nb_images,date) - $mesure(im_$k,date)]
         set dt [expr $dt * 86400.0]

         # Calcul de la compensation a apporter sur la monture
         set king_x [lindex $king 0]
         set king_y [lindex $king 1]
         set king_corrige [KingRattrapage $king_x $king_y $dt ]
         Message consolog "\t\t%s x=%5.2f / y=%5.2f\n" $caption(methking,corr_compensee) [lindex $king_corrige 0] [lindex $king_corrige 1]
         # Cumul des valeurs
         set corr_king_x [expr $corr_king_x + [lindex $king_corrige 0]]
         set corr_king_y [expr $corr_king_y + [lindex $king_corrige 1]]
         set corr2_king_x [expr $corr2_king_x + ([lindex $king_corrige 0] * [lindex $king_corrige 0])]
         set corr2_king_y [expr $corr2_king_y + ([lindex $king_corrige 1] * [lindex $king_corrige 1])]

         # Effacement des images registrees, qui ne servent plus a rien
#        set a_effacer $nom_reg$i
#        append a_effacer $ext_fichier
#        file delete $a_effacer
#        set a_effacer $nom_reg$k
#        append a_effacer $ext_fichier
#        file delete $a_effacer
      }

      Message consolog "%s \n" $caption(methking,status_calc_king)
      Message status $caption(methking,status_calc_king)

      set corr_king_x [expr +($corr_king_x / $nb_im_par_seq)]
      set corr_king_y [expr +($corr_king_y / $nb_im_par_seq)]

      Message consolog "\t%s dx=%5.2f /  dy=%5.2f\n" $caption(methking,corr_king_2) $corr_king_x $corr_king_y

      set corr2_king_x [expr +($corr2_king_x / $nb_im_par_seq)]
      set corr2_king_y [expr +($corr2_king_y / $nb_im_par_seq)]

      set sigma2_dx [expr $corr2_king_x - (($corr_king_x) * ($corr_king_x))]
      set sigma2_dy [expr $corr2_king_y - (($corr_king_y) * ($corr_king_y))]
      if {($sigma2_dx >= 0) && ($sigma2_dy >= 0)} {
         set panneau(methking,sigma_dx) [expr sqrt($sigma2_dx)]
         set panneau(methking,sigma_dy) [expr sqrt($sigma2_dy)]
         Message consolog "\t%s     sx = %5.2f /  sy = %5.2f\n" $caption(methking,sigma_king) $panneau(methking,sigma_dx) $panneau(methking,sigma_dy)
      }
      # Stockage de ces valeurs dans la variable globale "panneau"
      set panneau(methking,monture_dx) $corr_king_x
      set panneau(methking,monture_dy) $corr_king_y
      Message consolog "%s\n\n" $caption(methking,fin_calcul)

      #   Validation
      set panneau(methking,status) 200
   }
   #----- Procedure KingAuto ----------------------------------------

# --------------Partie methking.tcl
   #--------------------------------------------------------------------------#
   proc DemarrageKing { } {
      variable fichier_config
      variable fichier_log
      variable king_config
      variable liste_motcle
      variable log_id
      variable This
      global panneau audace caption conf

      # Gestion du fichier de log
      # Creation du nom de fichier log
      set formatdate [clock format [clock seconds] -format %Y%m%d_%H%M]
      set fichier_log $audace(rep_images)
      append fichier_log /methking_ $formatdate ".log"

      # Ouverture
      if [catch {open $fichier_log w} log_id] {
         Message console "%s \n" $caption(methking,erreur_fichier_log)
         stopTool
         return
      }

      # En-tete du fichier
      Message consolog "%s\n" $caption(methking,titre_console_1)
      Message consolog "%s %s\n" $caption(methking,titre_console_2) [ package version methking ]
      Message consolog "%s\n\n" $caption(methking,copyright)
      set temps [clock format [clock seconds] -format %Y%m%d]
      Message log "%s : %s\n" $caption(methking,date) $temps

      # Prise en compte du mode de compression des fichiers
      if {$conf(fichier,compres)==1} {
         buf$audace(bufNo) compress gzip
      } else {
         buf$audace(bufNo) compress none
      }

      # Creation et initialisation de quelques variables
      set panneau(methking,status) 0

      for {set i 0} {$i < 10} {incr i} {
         for {set j 0} {$j < [llength $liste_motcle]} {incr j} {
            set king_config([lindex $::methking::liste_motcle $j],$i) [lindex $::methking::liste_valeur_defaut $j]
         }
      }
      set king_config(nombre_config) 1
      set king_config(config_defaut) 0
      set fichier_config [file join $audace(rep_plugin) tool methking methking.ini]

      # Lecture du fichier de configuration
      Message log "%s\n" $caption(methking,lecture_config)
      GetConfig $fichier_config king_config
      Message log "%s\n" $caption(methking,fin_lecture_config)
      Message log "---------------------------------------------\n"
      set panneau(methking,config_active) $panneau(methking,config_defaut)
      set panneau(methking,nom_image) [file join $audace(rep_images) $panneau(methking,nom_image_temp)]

      # Creation et initialisation de la fenetre des parametres
      CreeFenetreParametres
      ModifieFenetreParametres
      for {set i 0} {$i < $panneau(methking,nombre_config)} {incr i} {
         $This.flisteconfig.configmb.menu insert $i radiobutton -label $king_config(config,$i) -variable panneau(methking,config_active) -value $i -command ::methking::ModifieFenetreParametres
      }
   }

   #--------------------------------------------------------------------------#
   proc ArretKing { } {
      global panneau caption audace
      variable This
      variable log_id

      # Effacement des entrees du menu Parametre
      $This.flisteconfig.configmb.menu delete 0 [expr $panneau(methking,nombre_config) - 1]

      # Fermeture du fichier de log
      Message log "%s\n\n" $caption(methking,fin_session)
      close $log_id

      # Fermeture de la fenetre des parametres
      destroy $audace(base).fenparam
   }

   #--------------------------------------------------------------------------#
   proc getPluginTitle { } {
      global caption

      return "$caption(methking,titre)"
   }

   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "methking.htm"
   }

   #--------------------------------------------------------------------------#
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "methking"
   }

   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #--------------------------------------------------------------------------#
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "aiming" }
         subfunction1 { return "" }
         display      { return "panel" }
      }
   }

   #--------------------------------------------------------------------------#
   proc createPluginInstance { base { visuNo 1 } } {
      variable fichier_config

      createPanel $base.methking king_config
      return $base.methking
   }

   #--------------------------------------------------------------------------#
   proc deletePluginInstance { visuNo } {

   }

   #--------------------------------------------------------------------------#
   proc createPanel {this king_config} {
      variable This
      global panneau caption
      upvar $king_config tableau

      set This $this

      set panneau(methking,status) ""
      set panneau(methking,infos) ""
      set panneau(methking,selection_cercle) -1
      set panneau(methking,nom_image_temp) "king_"

      methkingBuildIF $This tableau
   }

   #--------------------------------------------------------------------------#
   proc startTool { visuNo } {
      variable This
      variable methking_actif

      DemarrageKing
      set methking_actif 1
   }

   #--------------------------------------------------------------------------#
   proc stopTool { visuNo } {
      variable This
      variable methking_actif

      # Visiblement, stopTool est appelé plusieurs fois lors de la sortie de Audace => plantage
      # Mécanisme primaire pour empêcher les doubles appels à ArretKing
      if {$methking_actif != 0} {
          ArretKing
          set methking_actif 0
      }
   }

   #--------------------------------------------------------------------------#
   proc CmdAcquisition {} {
      global panneau
      global audace
      global conf
      global caption
      variable This
      variable king_config
      variable camera

      # Initialisations
      set image_noire [file join [file dirname $panneau(methking,nom_image)] king_noir_]

      # Definitions pour alleger l'ecriture du source
      set nom $panneau(methking,nom_image)
      set config_active $panneau(methking,config_active)

      if {[::cam::list]!=""} {
         # Mise en oeuvre du bouton d'arret
         $This.stop.b configure -command {::methking::ArretAcquisition} -state normal
         # Blocage de tous les boutons
         EtatBoutons disabled

         #1ere sequence
         Message consolog "%s\n" $caption(methking,sequence_1)
         set panneau(methking,demande_arret_acq) 0
         set t1 [clock second]
         cam$audace(camNo) buf $audace(bufNo)
         visu$audace(visuNo) buf $audace(bufNo)
         cam$audace(camNo) shutter synchro
         for {set image 1} {$image <= $king_config(poseparseq,$config_active)} {incr image} {
            if {$panneau(methking,demande_arret_acq) == 0} {
               # Acquisition
               Message status "%s %d" $caption(methking,acq_image) $image
               Message consolog "\t%s %d\n" $caption(methking,acq_image_bis) $image
               set panneau(methking,status_acq) 1
               Message infos "%s" $caption(methking,vidange)
               cam$audace(camNo) exptime $king_config(tempspose,$config_active)
               cam$audace(camNo) bin [list $king_config(binning,$config_active) $king_config(binning,$config_active)]
               cam$audace(camNo) acq
               ::methking::AfficheTimerAcq
               ::camera::waitStateStand $audace(camNo)
               Message infos ""
               set panneau(methking,status_acq) 0
               visu$audace(visuNo) cut [lrange [buf$audace(bufNo) stat] 0 1 ]
               visu$audace(visuNo) disp
               if {$panneau(methking,demande_arret_acq) == 0} {
                  # --- sauvegarde de l'image sur le disque
                  Message status "%s %s" $caption(methking,sauv_image) [file tail ${nom}${image}]
                  Message consolog "\t%s %s\n" $caption(methking,sauv_image_bis) ${nom}${image}
                  buf$audace(bufNo) save ${nom}${image}
               }
            }
         }

         # Sequence des noirs
         if {$king_config(noir,$config_active) != 0} {
            if {$panneau(methking,demande_arret_acq) == 0} {
               Message consolog "%s\n" $caption(methking,sequence_noirs)
               cam$audace(camNo) shutter closed
            }
            for {set image 1} {$image <= 3} {incr image} {
               if {$panneau(methking,demande_arret_acq) == 0} {
                  # Acquisition
                  Message status "%s %d" $caption(methking,acq_noir) $image
                  Message consolog "\t%s %d\n" $caption(methking,acq_noir_bis) $image

                  set panneau(methking,status_acq) 1
                  Message infos "%s" $caption(methking,vidange)
                  cam$audace(camNo) exptime $king_config(tempspose,$config_active)
                  cam$audace(camNo) bin [list $king_config(binning,$config_active) $king_config(binning,$config_active)]
                  cam$audace(camNo) acq
                  ::methking::AfficheTimerAcq
                  ::camera::waitStateStand $audace(camNo)
                  Message infos ""
                  set panneau(methking,status_acq) 0
                  visu$audace(visuNo) cut [lrange [buf$audace(bufNo) stat] 0 1 ]
                  visu$audace(visuNo) disp
                  if {$panneau(methking,demande_arret_acq) == 0} {
                     # --- sauvegarde de l'image sur le disque
                     Message status "%s %s" $caption(methking,sauv_noir) ${image_noire}${image}
                     Message consolog "\t%s %s\n" $caption(methking,sauv_noir_bis) ${image_noire}${image}
                     buf$audace(bufNo) save "${image_noire}${image}"
                  }
               }
            }
         }

         if {$panneau(methking,demande_arret_acq) == 0} {
            # Attente entre les poses
            set t2 [clock second]
            set t3 [expr ($king_config(interpose,$config_active) - ($t2 - $t1) - 1)]
            if {$t3 > 0} {
               Message status "%s \n %d s" $caption(methking,attente) $t3
               Message consolog "%s %d s\n" $caption(methking,attente) $t3
               set panneau(methking,timer) $t3
               AfficheTimer
               vwait panneau(methking,timer_fin)
            }
         }

         # 2eme sequence
         if {$panneau(methking,demande_arret_acq) == 0} {
            Message consolog "%s\n" $caption(methking,sequence_2)
            cam$audace(camNo) shutter synchro
         }
         for {set image [expr $king_config(poseparseq,$config_active) + 1]} {$image <= [expr 2*$king_config(poseparseq,$config_active)]} {incr image} {
            if {$panneau(methking,demande_arret_acq) == 0} {
               # Acquisition
               Message status "%s %d" $caption(methking,acq_image) $image
               Message consolog "\t%s %d\n" $caption(methking,acq_image_bis) $image

               set panneau(methking,status_acq) 1
               Message infos "%s" $caption(methking,vidange)
               cam$audace(camNo) exptime $king_config(tempspose,$config_active)
               cam$audace(camNo) bin [list $king_config(binning,$config_active) $king_config(binning,$config_active)]
               cam$audace(camNo) acq
               ::methking::AfficheTimerAcq
               ::camera::waitStateStand $audace(camNo)
               Message infos ""
               set panneau(methking,status_acq) 0
               visu$audace(visuNo) cut [lrange [buf$audace(bufNo) stat] 0 1 ]
               visu$audace(visuNo) disp
               # --- sauvegarde de l'image sur le disque
               if {$panneau(methking,demande_arret_acq) == 0} {
                  Message status "%s %s" $caption(methking,sauv_image) [file tail ${nom}${image}]
                  Message consolog "\t%s %s\n" $caption(methking,sauv_image_bis) ${nom}${image}
                  buf$audace(bufNo) save "${nom}${image}"
               }
            }
         }

         if {$king_config(noir,$config_active) != 0} {
            if {$panneau(methking,demande_arret_acq) == 0} {
               # Calcul du noir median
               Message status "%s" $caption(methking,noir_median)
               Message consolog "%s\n" $caption(methking,noir_median_bis)
               smedian [file tail $image_noire] [file tail $image_noire] 3

               # Destruction des fichiers de noir
               # note :delete2 ne marche pas avec des fichiers .gz
               for {set image 1} {$image <= 3} {incr image} {
                  set fichier_noir [file join $audace(rep_images) $image_noire]
                  append fichier_noir $image "$conf(extension,defaut)"
                  if {[buf$audace(bufNo) compress] == "gzip"} {
                     append fichier_noir ".gz"
                  }
                  file delete -force $fichier_noir
               }

               # Soustraction du noir a toutes les images acquises
               Message status "%s" $caption(methking,soust_noir)
               for {set image 1} {$image <= [expr 2*$king_config(poseparseq,$config_active)]} {incr image} {
                  Message consolog "%s %d\n" $caption(methking,soust_noir_bis) $image
                  buf$audace(bufNo) load "${nom}${image}"
                  buf$audace(bufNo) sub "$image_noire" 0
                  buf$audace(bufNo) save "${nom}${image}"
                  visu$audace(visuNo) cut [lrange [buf$audace(bufNo) stat] 0 1 ]
                  visu$audace(visuNo) disp
               }

               # Destruction du fichier de noir median
               set fichier_noir [file join $audace(rep_images) $image_noire]
               append fichier_noir "$conf(extension,defaut)"
               file delete -force $fichier_noir

            }
         }

         if {$panneau(methking,demande_arret_acq) == 0} {
            Message status "%s" $caption(methking,fin_acquisition)
            Message consolog "%s\n" $caption(methking,fin_acquisition)
         }

         # Bip pour reveiller l'observateur
         bell
         bell

         # Desactivation du bouton d'arret
         $This.stop.b configure -command {} -state disabled
         # Deblocage de tous les boutons
         EtatBoutons normal
      } else {
         Message status "%s" $caption(methking,pas_camera)
         Message erreur "%s\n" $caption(methking,pas_camera)
         BoiteMessage $caption(methking,erreur) $caption(methking,pas_camera)
      }
   }

   #--------------------------------------------------------------------------#
   proc ArretAcquisition {} {
      variable This
      global panneau caption audace

      # Bloque le bouton pour eviter de relancer ce binding
      $This.stop.b configure -state disabled

      Message status "%s" $caption(methking,arret_acquisition)
      Message consolog "%s\n" $caption(methking,arret_acquisition)
      set panneau(methking,demande_arret_acq) 1
      if {$panneau(methking,status_acq) == 1} {
         Message infos "%s" $caption(methking,lecture_ccd)
         ::camera::waitStateStand $audace(camNo)
      }
      Message infos ""
      set panneau(methking,timer_fin) -1
      set panneau(methking,timer) 0

      # Debloque le bouton
      $This.stop.b configure -state normal
   }

   #--------------------------------------------------------------------------#
   proc AfficheTimerAcq {} {
      variable This
      global audace
      global caption
      global panneau

      set t "[cam$audace(camNo) timer -1]"
      if {$t>1} {
         Message infos "%s\n%d / %d" $caption(methking,integration) $t [expr int([cam$audace(camNo) exptime])]
         after 1000 ::methking::AfficheTimerAcq
      } else {
         if {$panneau(methking,demande_arret_acq) == 0} {
         Message infos "%s" $caption(methking,lecture_ccd)
         }
      }
   }

   #--------------------------------------------------------------------------#
   proc CmdCalcul {} {
      global panneau audace caption conf
      variable king_config
      variable This

      # Blocage de tous les boutons
      EtatBoutons disabled

      # Simplification des ecritures
      set config_active $panneau(methking,config_active)
      set panneau(methking,nb_im_par_seq) $king_config(poseparseq,$config_active)
      set nom $panneau(methking,nom_image)

      # Verification de la presence des fichiers
      buf$audace(bufNo) extension "$conf(extension,defaut)"
      for {set image 1} {$image <= [expr $king_config(poseparseq,$config_active) * 2]} {incr image} {
         set nom_fichier $nom$image
         append nom_fichier "$conf(extension,defaut)"
         if {[buf$audace(bufNo) compress] == "gzip"} {
            append nom_fichier ".gz"
         }

         if {(![file exists $nom_fichier])} {
            set message $caption(methking,fichier)
            append message " " $nom_fichier " " $caption(methking,non_existence)
            Message erreur "%s\n" $message
            BoiteMessage $caption(methking,erreur) $message
            EtatBoutons normal
            return
         }
      }

      # Selection du mode de calcul
      set mode_calcul [tk_dialog .calcul $caption(methking,mode_calcul_1) $caption(methking,mode_calcul_2) {} 0 $caption(methking,bouton_auto) $caption(methking,bouton_manuel)]
      Message infos ""
      if {$mode_calcul == 1} {
         Message consolog "\n\n%s\n" $caption(methking,king_manuel)
         # Procedure manuelle
         KingPreparation

         # Selection manuelle des etoiles
         Message consolog "%s\n" $caption(methking,selection_etoile)
         CreeFenetreSelection

         # Attente de la fin des calculs
         vwait panneau(methking,status)
         destroy $audace(base).selectetoile
      } else {
         Message consolog "\n\n%s\n" $caption(methking,king_auto)
         KingAuto
      }

      if {$panneau(methking,status) == 200} {
         if {[expr $king_config(focale,$config_active) * $king_config(pixel_x,$config_active)] != 0} {
            set ecart_pole [CalculeEcartPole $panneau(methking,monture_dx) $panneau(methking,monture_dy) $king_config(pixel_x,$config_active) $king_config(focale,$config_active) $king_config(binning,$config_active)]
            Message consolog "%s: %3.1f '\n" $caption(methking,ecart_pole) $ecart_pole
         } else {
            set ecart_pole -1
         }

         # Isolation de la partie entiere de Dx et Dy
         set panneau(methking,monture_dx) [expr round($panneau(methking,monture_dx))]
         set panneau(methking,monture_dy) [expr round($panneau(methking,monture_dy))]

         # Affichage du DX et DY
         set resultat $caption(methking,resultat_dx)
         append resultat ": " $panneau(methking,monture_dx) "\n" $caption(methking,resultat_dy) ": " $panneau(methking,monture_dy)
         Message status $resultat
         set resultat $caption(methking,ecart_pole_bis)
         if {$ecart_pole >= 0} {
            append resultat " " $ecart_pole "'"
            Message infos $resultat
         }

         #Les reglages se feront en binning 2x2, il faut donc diviser dx et dy par 2 si les images de calcul ont ete faites en binning 1x1. De plus, le temps de pose doit etre divise par 4
         if {$king_config(binning,$config_active) == 1} {
            set panneau(methking,monture_dx) [expr $panneau(methking,monture_dx) / 2]
            set panneau(methking,monture_dy) [expr $panneau(methking,monture_dy) / 2]
            set panneau(methking,monture_dx) [expr int($panneau(methking,monture_dx))]
            set panneau(methking,monture_dy) [expr int($panneau(methking,monture_dy))]
         }

         # Recuperation de la date et de l'heure de la derniere image valide
         set panneau(methking,dateheure) [DateHeureImage]
      }

      # Deblocage de tous les boutons
      EtatBoutons normal
   }

   #--------------------------------------------------------------------------#
   proc CmdReglage {} {
      global panneau conf caption audace
      variable king_config
      variable This

      # Definitions pour alleger l'ecriture du source
      set config_active $panneau(methking,config_active)

      # Les reglages se feront en binning 2x2, il faut donc diviser le temps de pose par 4 si les images de calcul ont ete faites en binning 1x1
      if {$king_config(binning,$config_active) == 1} {
         set temps_pose_reglage [expr (int(1.00* $king_config(tempspose,$config_active) / 4)) + 1]
      } else {
         set temps_pose_reglage $king_config(tempspose,$config_active)
      }

      if {![info exists panneau(methking,monture_dx)]} {
         Message erreur "%s\n" $caption(methking,calcul_pas_fait)
         set choix [tk_messageBox -icon error -title $caption(methking,erreur) -message "$caption(methking,calcul_pas_fait)\n$caption(methking,prop_valeur)" -type yesno]
         update idletasks
         if {$choix == "yes"} {
            EntreeDxDy
            set panneau(methking,dateheure) [mc_date2jd now]
            tkwait window $audace(base).dxdy
         } else {return}
      }

      if {[::cam::list]!=""} {
         # Creation des buffers necessaires aux acquisitions et visualisations
         set numero_buffer_1 [::buf::create]
         buf$numero_buffer_1 extension $conf(extension,defaut)
         buf$numero_buffer_1 clear
         set numero_visu_1 [::visu::create $numero_buffer_1 $numero_buffer_1]
         set numero_buffer_2 [::buf::create]
         buf$numero_buffer_2 extension $conf(extension,defaut)
         buf$numero_buffer_2 clear
         set numero_visu_2 [::visu::create $numero_buffer_2 $numero_buffer_2]

         # Effacement de l'image precedente
         visu$numero_visu_1 disp
         visu$numero_visu_2 disp

         # Mise en memoire de ces infos (pour que ArretReglages puisse y acceder)
         set panneau(methking,numero_buffer_1) $numero_buffer_1
         set panneau(methking,numero_visu_1) $numero_visu_1
         set panneau(methking,numero_buffer_2) $numero_buffer_2
         set panneau(methking,numero_visu_2) $numero_visu_2

         # Mise en oeuvre du bouton d'arret
         $This.stop.b configure -command {::methking::ArretReglages} -state normal
         # Blocage de tous les boutons
         EtatBoutons disabled

         Message status $caption(methking,acq_im_ref)
         Message consolog "%s\n" $caption(methking,acq_im_ref_bis)
         set panneau(methking,demande_arret_acq) 0
         set panneau(methking,attente_cercle) 0
         if {$panneau(methking,demande_arret_acq) == 0} {
            CreePremiereFenetreReglages $numero_buffer_1 $numero_visu_1 2
         }

         if {$panneau(methking,demande_arret_acq) == 0} {
            set panneau(methking,status_regl) 1

            Message infos $caption(methking,vidange)
            cam$audace(camNo) buf $numero_buffer_1
            cam$audace(camNo) exptime $temps_pose_reglage
            cam$audace(camNo) bin {2 2}
            cam$audace(camNo) acq
            ::methking::AfficheTimerAcq
            ::camera::waitStateStand $audace(camNo)
            Message infos ""
            set panneau(methking,status_regl) 0
         }

         if {$panneau(methking,demande_arret_acq) == 0} {
            Message consolog "%s\n" $caption(methking,calcul_correction)
            set date [buf$numero_buffer_1 getkwd DATE-OBS]
            set date [lindex $date 1]
            set t2 [mc_date2jd $date]
            set dt [expr [expr $t2 - $panneau(methking,dateheure)] * 86400.0]
            set ultime_correction [KingRattrapage $panneau(methking,monture_dx) $panneau(methking,monture_dy) $dt]
            set panneau(methking,monture_dx) [lindex $ultime_correction 0]
            set panneau(methking,monture_dy) [lindex $ultime_correction 1]
            set panneau(methking,monture_dx) [expr int($panneau(methking,monture_dx))]
            set panneau(methking,monture_dy) [expr int($panneau(methking,monture_dy))]
            Message consolog "%s %4.2f\n" $caption(methking,nouveau_dx) $panneau(methking,monture_dx)
            Message consolog "%s %4.2f\n" $caption(methking,nouveau_dy) $panneau(methking,monture_dy)
            CreeCurseurPremiereFenetre
         }

         if {$panneau(methking,demande_arret_acq) == 0} {
            visu$numero_visu_1 cut [lrange [buf$numero_buffer_1 stat] 0 1 ]
            visu$numero_visu_1 disp
            ValidationBindingsPremiereFenetre
         }

         if {$panneau(methking,demande_arret_acq) == 0} {
            Message status $caption(methking,selection_etoile)
            set panneau(methking,attente_cercle) 1
            vwait panneau(methking,selection_cercle)
            set panneau(methking,attente_cercle) 0
         }

         if {$panneau(methking,demande_arret_acq) == 0} {
            CreeDeuxiemeFenetreReglages $numero_buffer_2 $numero_visu_2 2
         }

         cam$audace(camNo) buf $numero_buffer_2
         cam$audace(camNo) exptime $temps_pose_reglage
         cam$audace(camNo) bin {2 2}
         Message consolog "%s\n" $caption(methking,acq_continue_bis)
         while {$panneau(methking,demande_arret_acq) == 0} {
            Message status $caption(methking,acq_continue)
            set panneau(methking,status_regl) 1
            Message infos $caption(methking,vidange)
            cam$audace(camNo) acq
            ::methking::AfficheTimerAcq
            ::camera::waitStateStand $audace(camNo)
            Message infos ""
            set panneau(methking,status_regl) 0
            if {$panneau(methking,demande_arret_acq) == 0} {
               visu$numero_visu_2 cut [lrange [buf$numero_buffer_2 stat] 0 1 ]
               visu$numero_visu_2 disp
            }
         }

         # Desactivation du bouton d'arret
         $This.stop.b configure -command {} -state disabled
         # Deblocage de tous les boutons
         EtatBoutons normal
      } else {
         Message status $caption(methking,pas_de_camera)
         Message erreur "%s\n" $caption(methking,pas_de_camera)
         BoiteMessage $caption(methking,erreur) $caption(methking,pas_de_camera)
      }
   }

   #--------------------------------------------------------------------------#
   proc ArretReglages {} {
      variable This
      global panneau caption audace

      # Bloque le bouton pour eviter de relancer ce binding
      $This.stop.b configure -state disabled

      Message status $caption(methking,arret_reglage)
      #  Si l'utilisateur etait en train de selectionner une etoile, position-
      #  ner la variable indiquent que cette saisie est finie (qui va permettre
      #  au binding de reglage d'arreter d'attendre cette selection)
      if {$panneau(methking,attente_cercle) == 1} {
         set panneau(methking,selection_cercle) 1
      }
      #  Si l'utilisateur etait en train de faire une acquisition d'image,
      #  attendre la fin de l'acquisition
      if {$panneau(methking,status_regl) == 1} {
         Message infos $caption(methking,lecture_ccd)
         ::camera::waitStateStand $audace(camNo)
      }
      Message infos ""

      #  Faire la meme chose pour le timer
      set panneau(methking,timer_fin) -1
      set panneau(methking,timer) 0
      #  Detruire les fenetres de saisie
      destroy $audace(base).fenreglages
      destroy $audace(base).fenreglages2
      #  Liberer les ressources allouees (buffer et visu)
      ::buf::delete $panneau(methking,numero_buffer_1)
      ::buf::delete $panneau(methking,numero_buffer_2)
      ::visu::delete $panneau(methking,numero_visu_1)
      ::visu::delete $panneau(methking,numero_visu_2)
      #  Retablir le buffer ou pointe la camera (1 par defaut)
      cam$audace(camNo) buf 1

      # Debloquer le bouton
      $This.stop.b configure -state normal

      #  Positionner une variable indiquant le mode arret (qui va permettre
      #  au binding de reglage d'arreter les traitements en cours)
      set panneau(methking,demande_arret_acq) 1
   }

   #--------------------------------------------------------------------------#
   proc EntreeDxDy {} {
      global caption panneau audace
      variable This

      toplevel $audace(base).dxdy -borderwidth 2 -relief groove
      wm geometry $audace(base).dxdy +150+50
      wm title $audace(base).dxdy $caption(methking,entreedxdy)
      wm transient $audace(base).dxdy $audace(base)
      wm protocol $audace(base).dxdy WM_DELETE_WINDOW ::methking::Suppression

      set t1 [frame $audace(base).dxdy.trame1]

      foreach champ {dx dy} {
         label $t1.l$champ -text $caption(methking,entree$champ)
         entry $t1.e$champ -textvariable panneau(methking,monture_$champ) -relief sunken -width 4
         grid $t1.l$champ $t1.e$champ -sticky news
      }

      set t2 [frame $audace(base).dxdy.trame2 -borderwidth 2 -relief groove]
      button $t2.b1 -text $caption(methking,valider) -command {::methking::ValideEntreeDxDy} -height 1
      ::pack $t2.b1 -side top -padx 10 -pady 10

      ::pack $t1 $t2 -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).dxdy
   }

   #--------------------------------------------------------------------------#
   proc ValideEntreeDxDy {} {
      global panneau caption audace

      if {([TestEntierSigne $panneau(methking,monture_dx)] == 0) || ([TestEntierSigne $panneau(methking,monture_dy)] == 0)} {
         tk_messageBox -type ok -icon error -title $caption(methking,erreur) -message $caption(methking,valeur_illegale)
      } else {
         destroy $audace(base).dxdy
      }
   }

   #--------------------------------------------------------------------------#
   proc CreeFenetreParametres {} {
      global panneau audace caption
      variable This

      # Construction de la fenetre des parametres
      toplevel $audace(base).fenparam -borderwidth 2 -relief groove

      wm geometry $audace(base).fenparam +638+0
      wm title $audace(base).fenparam $caption(methking,parametres)
      wm transient $audace(base).fenparam $audace(base)
      wm protocol $audace(base).fenparam WM_DELETE_WINDOW ::methking::Suppression

      set valeur "   "
      set unite(binning) ""
      set unite(tempspose) " s"
      set unite(poseparseq) ""
      set unite(entrepose) " s"
      set unite(noir) ""
      set unite(auto) ""

      foreach champ {binning tempspose poseparseq entrepose noir} {
         label $audace(base).fenparam.l1$champ -text $caption(methking,$champ) -padx 0
         label $audace(base).fenparam.l2$champ -text "   " -relief sunken
         label $audace(base).fenparam.l3$champ -text $unite($champ)
         grid $audace(base).fenparam.l1$champ $audace(base).fenparam.l2$champ $audace(base).fenparam.l3$champ -sticky news
      }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).fenparam
   }

   #--------------------------------------------------------------------------#
   proc ModifieFenetreParametres {} {
      global panneau caption audace
      variable This

      set config $panneau(methking,config_active)

      if {[winfo exists $audace(base).fenparam] == 0} {
         CreeFenetreParametres
      }

      wm title $audace(base).fenparam $::methking::king_config(config,$config)

      switch -exact -- $::methking::king_config(binning,$config) {
         1 {set binning 1x1}
         2 {set binning 2x2}
         3 {set binning 3x3}
      }
      $audace(base).fenparam.l2binning configure -text $binning
      $audace(base).fenparam.l2tempspose configure -text $::methking::king_config(tempspose,$config)
      $audace(base).fenparam.l2poseparseq configure -text $::methking::king_config(poseparseq,$config)
      $audace(base).fenparam.l2entrepose configure -text $::methking::king_config(interpose,$config)
      if {$::methking::king_config(noir,$config) != 0} {
         set texte $caption(methking,oui)
      } else {
         set texte $caption(methking,non)
      }
      $audace(base).fenparam.l2noir configure -text $texte

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      update

      Message log "%s : %d %s\n" $caption(methking,config_active) $config $::methking::king_config(config,$config)
   }

   #--------------------------------------------------------------------------#
   proc EditeConfig {} {
      global conf panneau caption audace
      variable This

      # Suppression de toutes les entrees de config du menu, puisque l'utilisateur peut en modifier le nombre et l'intitule
      $This.flisteconfig.configmb.menu delete 0 [expr $panneau(methking,nombre_config) - 1]

      # Edition
      set fichier_config [file join $audace(rep_plugin) tool methking methking.ini]

      catch {eval exec \"$conf(editscript)\" \"$fichier_config\"} resultat

      # Gestion des cas d'erreurs
      if {$resultat == ""} {
         Message log "%s\n" $caption(methking,edite_config)
      } else {
         BoiteMessage $caption(methking,pas_editeur) $caption(methking,conseil_editeur)
         Message erreur "%s\n" $resultat
         Message erreur "%s\n" $caption(methking,pas_editeur)
      }
      Message log "%s\n" $caption(methking,nouv_lect_config)

      # Nouvelle lecture du fichier
      GetConfig $fichier_config ::methking::king_config
      set panneau(methking,config_active) $panneau(methking,config_defaut)
      #affichage des modifications dans la fenetre de parametres
      ModifieFenetreParametres

      set panneau(methking,config_active) $panneau(methking,config_defaut)
      # Actualisation des entrees du menu
      for {set i 0} {$i < $panneau(methking,nombre_config)} {incr i} {
         $This.flisteconfig.configmb.menu insert $i radiobutton -label $::methking::king_config(config,$i) -variable panneau(methking,config_active) -value $i -command ::methking::ModifieFenetreParametres
      }
   }

   #--------------------------------------------------------------------------#
   proc CreeFenetreSelection {} {
      global audace caption
      variable This

      toplevel $audace(base).selectetoile -class Toplevel -borderwidth 2 -relief groove
      wm geometry $audace(base).selectetoile +638+130
      wm resizable $audace(base).selectetoile 0 0
      wm title $audace(base).selectetoile $caption(methking,selection)
      wm transient $audace(base).selectetoile $audace(base)
      wm protocol $audace(base).selectetoile WM_DELETE_WINDOW ::methking::Suppression

      set texte_bouton(selection) $caption(methking,validation_etoile)
      set texte_bouton(lancement) $caption(methking,lancement_calcul)
      set texte_bouton(annulation) $caption(methking,annulation_calcul)

      set command_bouton(selection) ::methking::SelectionneEtoiles
      set command_bouton(lancement) ::methking::KingProcess
      set command_bouton(annulation) ::methking::AnnuleKing

      #----- Creation du contenu de la fenetre
      foreach champ {selection lancement annulation} {
         button $audace(base).selectetoile.b$champ -text $texte_bouton($champ) -command $command_bouton($champ)
         ::pack $audace(base).selectetoile.b$champ -anchor center -side top -fill x -padx 4 -pady 4 -in $audace(base).selectetoile  -anchor center -expand 1 -fill both -side top
      }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).selectetoile
   }

   #--------------------------------------------------------------------------#
   proc AnnuleKing {} {
      global panneau audace caption

      $audace(hCanvas) delete cadres
      set panneau(methking,status) 230
      Message console "%s\n" $caption(methking,arret_calcul_king)
   }

   #--------------------------------------------------------------------------#
   proc CreePremiereFenetreReglages {num_buf num_visu binning} {
      global audace panneau caption
      variable This

      toplevel $audace(base).fenreglages -borderwidth 2 -relief groove -cursor crosshair

      if {$binning == 1} {
      wm geometry $audace(base).fenreglages 768x512+120+50
      } else {
         # normalement, la fenetre a une taille de 386x272
         wm geometry $audace(base).fenreglages 386x356+120+50
      }
      wm title $audace(base).fenreglages $caption(methking,fenetre_reglages_1)
      wm transient $audace(base).fenreglages $audace(base)
      wm protocol $audace(base).fenreglages WM_DELETE_WINDOW ::methking::Suppression

      # Explications et conseils
      label $audace(base).fenreglages.explication -height 1 -justify left
      label $audace(base).fenreglages.conseil -height 1 -justify left
      pack $audace(base).fenreglages.explication $audace(base).fenreglages.conseil -side top -fill x -anchor nw

      canvas $audace(base).fenreglages.image1
      pack $audace(base).fenreglages.image1 -in $audace(base).fenreglages -expand 1 -side top -anchor center -fill both

      # Par rapport a la facon "normale", image2 est creee dans la routine ::visu::create grace au 2eme parametre de cette routine
      $audace(base).fenreglages.image1 create image 0 0 -image imagevisu$num_buf -anchor nw -tag image_ref
      tkwait visibility $audace(base).fenreglages

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).fenreglages
   }

   #--------------------------------------------------------------------------#
   proc CreeCurseurPremiereFenetre {} {
      global panneau caption audace color
      variable This

      # Definitions pour alleger l'ecriture du source
      set config_active $panneau(methking,config_active)
      set dx $panneau(methking,monture_dx)
      set dy $panneau(methking,monture_dy)

      set panneau(methking,cercle_cx) -200 ;# Pour le premier trace on le met a l'exterieur de la fenetre
      set panneau(methking,cercle_cy) -200 ;# idem

      #  Recuperation des dimensions de la fenetre
      set largeur [$audace(base).fenreglages.image1 cget -width]
      set hauteur [$audace(base).fenreglages.image1 cget -height]

      if {([expr abs($dx)] < $largeur) && ([expr abs($dy)] < $hauteur)} {
         set texte $caption(methking,explication_1)
      } else {
         set texte $caption(methking,explication_2)
      }
      $audace(base).fenreglages.explication configure -text $texte
      if {$dx > 0} {
         if {$dy > 0} {
            set texte $caption(methking,conseilx+y+)
         } else {
            set texte $caption(methking,conseilx+y-)
         }
      } else {
         if {$dy > 0} {
            set texte $caption(methking,conseilx-y+)
         } else {
            set texte $caption(methking,conseilx-y-)
         }
      }
      $audace(base).fenreglages.conseil configure -text $texte

      # Pour alleger l'ecriture
      set cx $panneau(methking,cercle_cx)
      set cy $panneau(methking,cercle_cy)

      #Trace du premier cercle autour du curseur
      $audace(base).fenreglages.image1 create oval [expr $cx-15] [expr $cy-15] [expr $cx+16] [expr $cy+16] -outline $color(red) -width 2 -tag cercle_1 -tag cercle
      $audace(base).fenreglages.image1 create oval [expr $cx-5] [expr $cy-5] [expr $cx+6] [expr $cy+6] -outline $color(red) -width 2 -tag cercle_2 -tag cercle

      #Trace des curseurs "esclave"
      # Le signe - pour $panneau(methking,monture_dy) est du a l'inversion du sens des y entre le canvas et l'image
      if {([expr abs($dx)] < $largeur) && ([expr abs($dy)] < $hauteur)} {
         $audace(base).fenreglages.image1 create rect [expr $dx + $cx - 15] [expr $cy - 15 - $dy] [expr $dx + $cx + 16] [expr $cy + 16 - $dy] -outline $color(green) -width 2 -tag cercle_3 -tag cercle
         $audace(base).fenreglages.image1 create rect [expr $dx + $cx - 5] [expr $cy - 5 - $dy] [expr $dx + $cx + 6] [expr $cy + 6 - $dy] -outline $color(green) -width 1 -tag cercle_4 -tag cercle
      } else {
         $audace(base).fenreglages.image1 create line $cx $cy [expr $cx + $dx] [expr $cy - $dy] -fill $color(green) -width 2 -tag cercle_3 -tag cercle
      }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #--------------------------------------------------------------------------#
   proc TraceCurseur {cx cy} {
      global panneau audace

      set dx [expr $cx - $panneau(methking,cercle_cx)]
      set dy [expr $cy - $panneau(methking,cercle_cy)]
      $audace(base).fenreglages.image1 move cercle $dx $dy
      set panneau(methking,cercle_cx) $cx
      set panneau(methking,cercle_cy) $cy
   }

   #--------------------------------------------------------------------------#
   proc MemoriseCurseur {cx cy} {
      global panneau caption audace

      # Definitions pour alleger l'ecriture du source
      set dx $panneau(methking,monture_dx)
      set dy $panneau(methking,monture_dy)

      #  Bloquer tout animation souris
      bind $audace(base).fenreglages.image1 <Motion> {}
      bind $audace(base).fenreglages.image1 <ButtonRelease-1> {}

      #  Recuperation des dimensions de la fenetre
      set dimensions [wm geometry $audace(base).fenreglages]
      set largeur [string range $dimensions 0 [expr [string first "x" $dimensions] - 1]]
      set hauteur [string range $dimensions [expr [string first "x" $dimensions ] + 1] [expr [string first "+" $dimensions] - 1]]

      set position_x [expr $cx + $dx]
      # le signe - vient de l'inversion des coordonnees entre le canvas et l'image
      set position_y [expr $cy - $dy]

      #  Si l'etoile cible est en dehors de cette fenetre
      if {([expr abs($dx)] < $largeur) && ([expr abs($dy)] < $hauteur)} {
         if {($position_x < 0) || ($position_y < 0) || ($position_x > $largeur) || ($position_y > $hauteur)} {
         #  Alors le signaler, retablir l'animation souris et sortir
            ::methking::BoiteMessage $caption(methking,etoile_fenetre) $caption(methking,refaire_selection)
            bind $audace(base).fenreglages.image1 <Motion> {::methking::TraceCurseur %x %y}
            bind $audace(base).fenreglages.image1 <ButtonRelease-1> {::methking::MemoriseCurseur %x %y}
            return
         }
      }

      #  Sinon demander confirmation du choix de l'etoile
      set choix [tk_messageBox -type yesno -default yes -message $caption(methking,valide_clic_1) -icon question -title $caption(methking,valide_clic_2)]

      #  Si ce choix est confirme
      if {$choix == "yes"} {
         #  Alors mettre les coordonnees en memoire,
         set panneau(methking,cercle_cx) $cx
         set panneau(methking,cercle_cy) $cy
         # retablir le curseur normal
         $audace(base).fenreglages configure -cursor crosshair
         # indiquer que la selection est faite  et sortir
         set panneau(methking,selection_cercle) [expr -$panneau(methking,selection_cercle)]
      } else {
         #  Sinon retablir l'animation souris et sortir                     #
         bind $audace(base).fenreglages.image1 <Motion> {::methking::TraceCurseur %x %y}
         bind $audace(base).fenreglages.image1 <ButtonRelease-1> {::methking::MemoriseCurseur %x %y}
      }
   }

   #--------------------------------------------------------------------------#
   proc ValidationBindingsPremiereFenetre {} {
      global audace

      $audace(base).fenreglages configure -cursor circle
      bind $audace(base).fenreglages.image1 <Motion> {::methking::TraceCurseur %x %y}
      bind $audace(base).fenreglages.image1 <ButtonRelease-1> {::methking::MemoriseCurseur %x %y}
   }

   #--------------------------------------------------------------------------#
   proc CreeDeuxiemeFenetreReglages {num_buf num_visu binning} {
      global audace panneau caption color
      variable This

      # Definitions pour alleger l'ecriture du source
      set config_active $panneau(methking,config_active)
      set dx $panneau(methking,monture_dx)
      set dy $panneau(methking,monture_dy)
      set cx $panneau(methking,cercle_cx)
      set cy $panneau(methking,cercle_cy)

      toplevel $audace(base).fenreglages2 -borderwidth 2 -relief groove -cursor crosshair

      wm title $audace(base).fenreglages2 $caption(methking,fenetre_reglages_2)
      wm transient $audace(base).fenreglages2 $audace(base)
      wm protocol $audace(base).fenreglages2 WM_DELETE_WINDOW ::methking::Suppression

      if {$binning == 1} {
         set position_x [expr 0.9*[winfo screenwidth $audace(base).fenreglages2] - 768]
         set position_x [expr int($position_x)]
         if {$position_x < 150} {
            set position_x 150
         }
         set position_y [expr 0.9*[winfo screenheight $audace(base).fenreglages2] - 612]
         set position_y [expr int($position_y)]
         if {$position_x < 60} {
            set position_x 60
         }
         wm geometry $audace(base).fenreglages2 768x612+$position_x+$position_y
      } else {
         set position_x [expr 0.9*[winfo screenwidth $audace(base).fenreglages2] - 386]
         set position_x [expr int($position_x)]
         if {$position_x < 150} {
            set position_x 150
         }
         set position_y [expr 0.9*[winfo screenheight $audace(base).fenreglages2] - 356]
         set position_y [expr int($position_y)]
         if {$position_x < 60} {
            set position_x 60
         }
         wm geometry $audace(base).fenreglages2 386x356+$position_x+$position_y
      }

      label $audace(base).fenreglages2.texte_x -height 1 -justify left
      label $audace(base).fenreglages2.texte_y -height 1 -justify left
      set texte "Axe X :"
      if {$dx > 0} {
         append texte $::methking::king_config(textex+,$config_active)
      } else {
         append texte $::methking::king_config(textex-,$config_active)
      }
      $audace(base).fenreglages2.texte_x configure -text $texte
      set texte "Axe Y :"
      if {$dy > 0} {
         append texte $::methking::king_config(textey+,$config_active)
      } else {
         append texte $::methking::king_config(textey-,$config_active)
      }
      $audace(base).fenreglages2.texte_y configure -text $texte
      pack $audace(base).fenreglages2.texte_x $audace(base).fenreglages2.texte_y -side top -fill x -anchor nw

      canvas $audace(base).fenreglages2.image1
      pack $audace(base).fenreglages2.image1 -in $audace(base).fenreglages2 -expand 1 -side top -anchor center -fill both

      #  Recuperation des dimensions de la fenetre
      tkwait visibility $audace(base).fenreglages2
      set largeur [$audace(base).fenreglages2.image1 cget -width]
      set hauteur [$audace(base).fenreglages2.image1 cget -height]

      #Empeche que cette fenetre soit detruite
      # NE MARCHE PAS
      bind $audace(base).fenreglages2 <Destroy> {}

      # Par rapport a la facon "normale", image3 est creee dans la routine ::visu::create grace au 2eme parametre de cette routine
      $audace(base).fenreglages2.image1 create image 0 0 -image imagevisu$num_buf -anchor nw -tag image_reglage
      $audace(base).fenreglages2.image1 create oval [expr $cx-15] [expr $cy-15] [expr $cx+16] [expr $cy+16] -outline $color(red) -width 2 -tag cercle_1
      $audace(base).fenreglages2.image1 create oval [expr $cx-5] [expr $cy-5] [expr $cx+6] [expr $cy+6] -outline $color(red) -width 2 -tag cercle_2

      #Trace des curseurs "esclave"
      # Le signe - pour $panneau(methking,monture_dy) est du a l'inversion du sens y entre le canvas et l'image
      if {([expr abs($dx)] < $largeur) && ([expr abs($dy)] < $hauteur)} {
         $audace(base).fenreglages2.image1 create rect [expr $dx + $cx - 15] [expr $cy - 15 - $dy] [expr $dx + $cx + 16] [expr $cy + 16 - $dy] -outline $color(green) -width 2 -tag cercle_3
         $audace(base).fenreglages2.image1 create rect [expr $dx + $cx - 5] [expr $cy - 5 - $dy] [expr $dx + $cx + 6] [expr $cy + 6 - $dy] -outline $color(green) -width 1 -tag cercle_4
      } else {
         set dy [expr -$dy]
         if {$dx >0} {set x1 $largeur; set y1 [expr $cy+(($largeur-$cx)*$dy/$dx)]}
         if {$dx <0} {set x1 0; set y1 [expr $cy-($cx*$dy/$dx)]}
         if {$dx == 0} {
            set x1 $cx
            if {$dy > 0} {set y1 $hauteur} else {set y1 0}
         }

         if {$dy >0} {set y2 $hauteur; set x2 [expr $cx+(($hauteur-$cy)*$dx/$dy)]}
         if {$dy <0} {set y2 0;set x2 [expr $cx-($cy*$dx/$dy)]}
         if {$dy == 0} {
            set y2 $cy
            if {$cx > 0} {set x2 $largeur} else {set x2 0}
         }

         if {($y1 > $hauteur) || ($y1 < 0)} {
            set bx $x2
            set by $y2
         } else {
            set bx $x1
            set by $y1
         }

         set rho 0.8
         set ax [expr $cx + $rho*($bx-$cx)]
         set ay [expr $cy + $rho*($by-$cy)]

         $audace(base).fenreglages2.image1 create line $cx $cy $ax $ay -fill $color(green) -width 2 -arrow last -arrowshape {16 20 6}
      }
      set panneau(methking,pare_au_reglages) 23

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).fenreglages2
   }

   #--------------------------------------------------------------------------#
   proc AfficheTimer {} {
      global panneau
      variable king_config

      Message infos "%d s" $panneau(methking,timer)
      incr panneau(methking,timer) -1
      if {$king_config(son,$panneau(methking,config_active)) != 0} {
         if {$panneau(methking,timer) == $king_config(son,$panneau(methking,config_active))} {
            bell
         }
      }
      if {$panneau(methking,timer) >0} {
         after 960 ::methking::AfficheTimer
      } else {
         Message infos ""
         set panneau(methking,timer_fin) -1
      }
   }

   #--------------------------------------------------------------------------#
   proc CalculeEcartPole {delta_x delta_y taille_pixel focale binning} {
      set delta_r [expr {sqrt([expr $delta_x*$delta_x + $delta_y*$delta_y])}]
      set echantillonage [expr $taille_pixel * $binning * 0.001]
      set echantillonage [expr $echantillonage / $focale]
      set echantillonage [expr atan($echantillonage)]
      set echantillonage [expr 180*60*$echantillonage/3.14159265]
      set ecart [expr $delta_r * $echantillonage]
      set ecart [format "%3.1f" $ecart]
      return $ecart
   }

   #--------------------------------------------------------------------------#
   proc EtatBoutons {etat} {
      variable This
      $This.boutons.bacquisition configure -state $etat
      $This.boutons.bcalcul configure -state $etat
      $This.boutons.breglage configure -state $etat
      $This.flisteconfig.configmb configure -state $etat
   }

   #--------------------------------------------------------------------------#
   proc printf {args} {
      ::console::disp [eval [concat {format} $args]]
   }

   #--------------------------------------------------------------------------#
   proc Suppression {} {
      # Empeche certaines fenetres d'etre effacees
   }

   #--------------------------------------------------------------------------#
   proc BoiteMessage {titre message} {
      tk_messageBox -type ok -title $titre -message $message -icon warning
   }

   #--------------------------------------------------------------------------#
   proc Message {niveau args} {
      variable This
      global caption
      global audace
      variable log_id

      switch -exact -- $niveau {
         console {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         log {
            set temps $audace(tu,format,dmyhmsint)
            append temps " "
            puts -nonewline $log_id $temps
            puts -nonewline $log_id [eval [concat {format} $args]]
         }
         consolog {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
            set temps $audace(tu,format,dmyhmsint)
            append temps " "
            puts -nonewline $::methking::log_id $temps
            puts -nonewline $::methking::log_id [eval [concat {format} $args]]
         }
         avertissement {
            ::console::disp $caption(methking,attention)
            ::console::disp " : "
            ::console::disp [eval [concat {format} $args]]
            update idletasks
            puts -nonewline $::methking::log_id $caption(methking,attention)
            puts -nonewline $::methking::log_id  " : "
            puts -nonewline $::methking::log_id [eval [concat {format} $args]]
         }
         erreur {
            ::console::disp $caption(methking,erreur)
            ::console::disp " : "
            ::console::disp [eval [concat {format} $args]]
            update idletasks
            puts -nonewline $::methking::log_id $caption(methking,erreur)
            puts -nonewline $::methking::log_id " : "
            puts -nonewline $::methking::log_id [eval [concat {format} $args]]
         }
         test {
            ::console::disp $caption(methking,test)
            ::console::disp " : "
            ::console::disp [eval [concat {format} $args]]
            update idletasks
            puts -nonewline $::methking::log_id $caption(methking,test)
            puts -nonewline $::methking::log_id " : "
            set temps $audace(tu,format,dmyhmsint)
            append temps " "
            puts -nonewline $::methking::log_id $temps
            puts -no newline $::methking::log_id [eval [concat {format} $args]]
         }
         status {
            set panneau(methking,status) [eval [concat {format} $args]]
            $This.fstatus.m configure -text $panneau(methking,status)
            update
         }
         infos {
            set panneau(methking,infos) [eval [concat {format} $args]]
            $This.finfos.m configure -text $panneau(methking,infos)
            update idletasks
         }
         default {
            ::console::disp $caption(methking,erreur_message)
            ::console::disp "\n"
            update idletasks
         }
      }
      update
   }
}
#-----Fin du namespace methking--------------------------------------------#

#--------------------------------------------------------------------------#
proc methkingBuildIF {This tableau} {
   # ============================
   # === graphisme du panneau ===
   # ============================
   global audace panneau caption

   #--- Trame du panneau
   frame $This -borderwidth 2 -height 75 -width 101 -borderwidth 2 -relief groove

   #--- Trame du titre du panneau
   frame $This.ftitre -borderwidth 2 -height 75 -relief groove -width 92

   #--- Bouton du titre
   Button $This.ftitre.l -borderwidth 2 \
      -text "$caption(methking,help,titre1)\n$caption(methking,titre)" \
      -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::methking::getPluginType ] ] \
         [ ::methking::getPluginDirectory ] [ ::methking::getPluginHelp ]"
   pack $This.ftitre.l -in $This.ftitre -anchor center -expand 1 -fill both -side top
   DynamicHelp::add $This.ftitre.l -text $caption(methking,help,titre)
   place $This.ftitre -x 4 -y 4 -width 92 -height 42 -anchor nw -bordermode ignore

   #Trame d'affichage des parametres
   set t1 [frame $This.flisteconfig -borderwidth 1 -height 100 -relief groove]

   menubutton $t1.configmb -text $caption(methking,parametres) -menu $t1.configmb.menu -height 1 -relief raised
   bind $t1.configmb <Button-1> {+ ::methking::ModifieFenetreParametres}
   pack $t1.configmb -in $t1 -pady 4

   set mc [menu $t1.configmb.menu -tearoff 0]
   $mc add separator
   $mc add command -label $caption(methking,edition) -command ::methking::EditeConfig

   place $t1 -x 4 -y 52 -width 92 -anchor nw -bordermode ignore

   # Trame des boutons
   set t2 [frame $This.boutons -borderwidth 1 -relief groove]
   set commande(acquisition) ::methking::CmdAcquisition
   set commande(calcul) ::methking::CmdCalcul
   set commande(reglage) ::methking::CmdReglage

   foreach champ {acquisition calcul reglage} {
      button $t2.b$champ -borderwidth 1 -text $caption(methking,$champ) -command $commande($champ) -width 10 -relief raised
      pack $t2.b$champ -in $t2 -anchor center -fill none -pady 4 -ipady 4
   }
   place $t2 -x 4 -y 94 -width 92  -anchor nw -bordermode ignore

   # Bouton d'arret
   frame $This.stop -borderwidth 1 -relief groove
   button $This.stop.b -borderwidth 1 -text $caption(methking,arret) -state disabled -width 10
   pack $This.stop.b -in $This.stop -anchor center -fill none -pady 4 -ipady 4
   place $This.stop -x 4 -y 240 -width 92  -anchor nw -bordermode ignore

   # Affichage des status
   frame $This.fstatus -borderwidth 1 -height 77 -relief groove
   label  $This.fstatus.l1 -text $caption(methking,label_status) -relief flat -height 1
   pack   $This.fstatus.l1 -in $This.fstatus -anchor center -fill both -padx 0 -pady 0
   label  $This.fstatus.m -text $panneau(methking,status) -justify center -padx 0 -pady 0 -relief flat -width 11 -height 3 -wraplength 88
   pack   $This.fstatus.m -in $This.fstatus -anchor center -fill both -padx 0 -pady 0
   place $This.fstatus -x 4 -y 290 -width 92 -anchor nw -bordermode ignore

   # Affichage des infos
   frame $This.finfos -borderwidth 1 -relief groove
   label  $This.finfos.m -text $panneau(methking,infos) -justify center -padx 0 -pady 0 -relief flat -width 11 -height 2 -wraplength 88
   pack   $This.finfos.m -in $This.finfos -anchor center -fill both -padx 0 -pady 0
   place $This.finfos -x 4 -y 390 -width 92 -anchor nw -bordermode ignore
}

# === fin du fichier methking.tcl ===

