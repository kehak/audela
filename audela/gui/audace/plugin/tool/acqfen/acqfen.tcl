#
# Fichier : acqfen.tcl
# Description : Outil d'acquisition d'images fenetrees
# Auteur : Benoit MAUGIS
# Mise à jour $Id: acqfen.tcl 12990 2016-01-29 23:42:15Z michelpujol $
#

# =========================================================
# === definition du namespace acqfen pour creer l'outil ===
# =========================================================

namespace eval ::acqfen {
   package provide acqfen 1.2.1

   # =======================================================================
   # === definition des fonctions de construction automatique de l'outil ===
   # =======================================================================

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] acqfen.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(acqfen,titre)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "acqfen.htm"
   }

   #------------------------------------------------------------
   # getPluginType
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # getPluginDirectory
   #    retourne le repertoire du plugin
   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "acqfen"
   }

   #------------------------------------------------------------
   # getPluginOS
   #    retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   # getPluginProperty
   #    retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "acquisition" }
         subfunction1 { return "windowed" }
         display      { return "panel" }
      }
   }

   #------------------------------------------------------------
   # createPluginInstance
   #    cree une nouvelle instance de l'outil
   #------------------------------------------------------------
   proc createPluginInstance { base { visuNo 1 } } {
      variable This
      global audace caption panneau

      #--- Initialisation
      set This $base.acqfen

      #--- Liste des modes disponibles
      set panneau(acqfen,list_mode) [ list $caption(acqfen,uneimage) $caption(acqfen,serie) \
         $caption(acqfen,continu) ]

      #--- Initialisation des modes
      set panneau(acqfen,mode,1) "$This.mode.une"
      set panneau(acqfen,mode,2) "$This.mode.serie"
      set panneau(acqfen,mode,3) "$This.mode.continu"

      #--- Preparation de la creation de la fenetre de l'outil
      createPanel $This

      #--- Affichage du mode choisi
      pack $panneau(acqfen,mode,$panneau(acqfen,mode)) -anchor nw -fill x

      #--- Surveillance de la connexion d'une camera
      ::confVisu::addCameraListener $audace(visuNo) "::acqfen::adaptOutilAcqFen"

      #---
      return $This
   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {
      global audace

      #--- Je desactive la surveillance de la connexion d'une camera
      ::confVisu::removeCameraListener $audace(visuNo) "::acqfen::adaptOutilAcqFen"
   }

   #------------------------------------------------------------
   # createPanel
   #    prepare la creation de la fenetre de l'outil
   #------------------------------------------------------------
   proc createPanel { this } {
      variable This
      variable parametres
      global caption panneau

      set This $this

      #--- Recuperation de la derniere configuration de prise de vue
      ::acqfen::chargerParametres
      set panneau(acqfen,titre)        $caption(acqfen,titre)
      set panneau(acqfen,ht_onglet)    280
      set panneau(acqfen,go_stop_cent) "go"
      set panneau(acqfen,go_stop)      "go"

      #--- Valeurs par defaut d'acquisition (centrage)
      #--- Liste de valeurs du temps de pose disponibles par defaut
      set panneau(acqfen,temps_pose_centrage) {.1 .2 .5 1 2 3 5}
      #--- Valeur par defaut du temps de pose:
      if { ! [ info exists panneau(acqfen,pose_centrage) ] } {
         set panneau(acqfen,pose_centrage) "$parametres(acqfen,pose_centrage)"
      }
      #--- Binning par defaut: 4x4
      if { ! [ info exists panneau(acqfen,bin_centrage) ] } {
         set panneau(acqfen,bin_centrage) "$parametres(acqfen,bin_centrage)"
      }

      #--- Valeurs par defaut d'acquisition (mode "planetaire", fenetre)
      #--- Liste de valeurs du temps de pose disponibles par defaut
      set panneau(acqfen,temps_pose) {.01 .02 .03 .05 .08 .1 .15 .2 .3 .5 1 2 3 5}
      #--- Valeur par defaut du temps de pose:
      if { ! [ info exists panneau(acqfen,pose) ] } {
         set panneau(acqfen,pose) "$parametres(acqfen,pose)"
      }
      #--- Binning par defaut: 1x1
      if { ! [ info exists panneau(acqfen,bin) ] } {
         set panneau(acqfen,bin) "$parametres(acqfen,bin)"
      }

      #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
      set panneau(acqfen,obt,0) "$caption(acqfen,ouv)"
      set panneau(acqfen,obt,1) "$caption(acqfen,ferme)"
      set panneau(acqfen,obt,2) "$caption(acqfen,auto)"

      #--- Obturateur par defaut : Synchro
      if { ! [ info exists panneau(acqfen,obt) ] } {
         set panneau(acqfen,obt) "$parametres(acqfen,obt)"
      }

      #--- Coordonnees de la fenetre
      if { ! [ info exists panneau(acqfen,X1) ] } {
         set panneau(acqfen,X1) "$parametres(acqfen,X1)"
      }
      if { ! [ info exists panneau(acqfen,Y1) ] } {
         set panneau(acqfen,Y1) "$parametres(acqfen,Y1)"
      }
      if { ! [ info exists panneau(acqfen,X2) ] } {
         set panneau(acqfen,X2) "$parametres(acqfen,X2)"
      }
      if { ! [ info exists panneau(acqfen,Y2) ] } {
         set panneau(acqfen,Y2) "$parametres(acqfen,Y2)"
      }

      #--- Taille par defaut de la petite matrice schematisant le fenetrage
      set panneau(acqfen,mtx_x) 81
      set panneau(acqfen,mtx_y) 54

      #--- Type scale par defaut (scale ou zoom)
      set panneau(acqfen,typezoom) "scale"

      #--- Mode d'acquisition par defaut
      if { ! [ info exists panneau(acqfen,mode) ] } {
         set panneau(acqfen,mode) "$parametres(acqfen,mode)"
      }

      #--- Valeur par defaut du nombre de poses d'une serie
      if { ! [ info exists panneau(acqfen,nb_images) ] } {
         set panneau(acqfen,nb_images) "$parametres(acqfen,nb_images)"
      }

      #--- Fenetre d'avancement de la pose
      if { ! [ info exists panneau(acqfen,avancement_acq) ] } {
         set panneau(acqfen,avancement_acq) "$parametres(acqfen,avancement_acq)"
      }

      #--- Mode de la combobox de changement de mode
      if { $panneau(acqfen,mode) == "1" } {
         set panneau(acqfen,frame_mode) "une"
      } elseif { $panneau(acqfen,mode) == "2" } {
         set panneau(acqfen,frame_mode) "serie"
      } else {
         set panneau(acqfen,frame_mode) "continu"
      }

      #--- Variables diverses
      set panneau(acqfen,index)           1
      set panneau(acqfen,enregistrer)     0
      set panneau(acqfen,acquisition)     0
      set panneau(acqfen,demande_arret)   0
      set panneau(acqfen,dispTimeAfterId) ""
      set panneau(acqfen,finAquisition)   ""

      #--- Reglages acquisitions serie et continu par defaut
      set panneau(acqfen,fenreglfen1)     1
      set panneau(acqfen,fenreglfen12)    0
      set panneau(acqfen,fenreglfen2)     1
      set panneau(acqfen,fenreglfen22)    2
      set panneau(acqfen,fenreglfen3)     1
      set panneau(acqfen,fenreglfen4)     1

      #--- Alarme sonore de fin de serie
      set panneau(acqfen,fenreglfen5)     1

      #--- Pourcentage de correction des defauts de suivi (doit etre compris entre 1 et 100)
      set panneau(acqfen,fenreglfen42)    70

      #--- Au debut les reglages de temps de pose et de binning sont "accessibles" pour les 2 modes d'acquisition
      set panneau(acqfen,affpleinetrame)  1
      set panneau(acqfen,afffenetrees)    1

      #--- Autres configurations
      set panneau(acqfen,verifier_ecraser_fichier) "$parametres(acqfen,verifier_ecraser_fichier)"
      set panneau(acqfen,verifier_index_depart)    "$parametres(acqfen,verifier_index_depart)"

      ::acqfenBuildIF $This

      ::acqfen::actualiserAffichage

      pack $This.mode.$panneau(acqfen,frame_mode) -anchor nw -fill x

   }

   #--- Procedure pour charger les parametres de configuration
   proc chargerParametres { } {
      variable parametres

      #--- Ouverture du fichier de parametres
      set fichier [ file join $::audace(rep_home) acqfen.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }
      if { ! [ info exists parametres(acqfen,pose_centrage) ] }            { set parametres(acqfen,pose_centrage)            ".2" }  ; #--- Temps de pose : 0.2s
      if { ! [ info exists parametres(acqfen,obt) ] }                      { set parametres(acqfen,obt)                      "2" }   ; #--- Obturateur : Synchro
      if { ! [ info exists parametres(acqfen,bin_centrage) ] }             { set parametres(acqfen,bin_centrage)             "4" }   ; #--- Binning : 4x4
      if { ! [ info exists parametres(acqfen,pose) ] }                     { set parametres(acqfen,pose)                     ".05" } ; #--- Temps de pose : 0.05s
      if { ! [ info exists parametres(acqfen,bin) ] }                      { set parametres(acqfen,bin)                      "1" }   ; #--- Binning : 1x1
      if { ! [ info exists parametres(acqfen,mode) ] }                     { set parametres(acqfen,mode)                     "1" }   ; #--- Mode : Une image
      if { ! [ info exists parametres(acqfen,nb_images) ] }                { set parametres(acqfen,nb_images)                "5" }   ; #--- Serie : Nombre de poses
      if { ! [ info exists parametres(acqfen,avancement_acq) ] }           { set parametres(acqfen,avancement_acq)           "1" }   ; #--- Barre de progression de la pose : Oui
      if { ! [ info exists parametres(acqfen,X1) ] }                       { set parametres(acqfen,X1)                       "" }    ; #--- Coordonnees de la fenetre
      if { ! [ info exists parametres(acqfen,Y1) ] }                       { set parametres(acqfen,Y1)                       "" }    ; #--- Coordonnees de la fenetre
      if { ! [ info exists parametres(acqfen,X2) ] }                       { set parametres(acqfen,X2)                       "" }    ; #--- Coordonnees de la fenetre
      if { ! [ info exists parametres(acqfen,Y2) ] }                       { set parametres(acqfen,Y2)                       "" }    ; #--- Coordonnees de la fenetre
      if { ! [ info exists parametres(acqfen,verifier_ecraser_fichier) ] } { set parametres(acqfen,verifier_ecraser_fichier) "1" }   ; #--- Flag ecrasement fichier
      if { ! [ info exists parametres(acqfen,verifier_index_depart) ] }    { set parametres(acqfen,verifier_index_depart)    "1" }   ; #--- Flag index a 1

      #--- je convertis les anciennes valeurs pour assurer la compatibilite
      if { $parametres(acqfen,mode) == "une" }     { set parametres(acqfen,mode) 1 }
      if { $parametres(acqfen,mode) == "serie" }   { set parametres(acqfen,mode) 2 }
      if { $parametres(acqfen,mode) == "continu" } { set parametres(acqfen,mode) 3 }
   }

   #--- Procedure pour enregistrer les parametres de configuration
   proc enregistrerParametres { } {
      variable parametres
      global panneau

      #---
      set parametres(acqfen,pose_centrage)            $panneau(acqfen,pose_centrage)
      set parametres(acqfen,obt)                      $panneau(acqfen,obt)
      set parametres(acqfen,bin_centrage)             $panneau(acqfen,bin_centrage)
      set parametres(acqfen,pose)                     $panneau(acqfen,pose)
      set parametres(acqfen,bin)                      $panneau(acqfen,bin)
      set parametres(acqfen,mode)                     $panneau(acqfen,mode)
      set parametres(acqfen,nb_images)                $panneau(acqfen,nb_images)
      set parametres(acqfen,avancement_acq)           $panneau(acqfen,avancement_acq)
      set parametres(acqfen,X1)                       $panneau(acqfen,X1)
      set parametres(acqfen,Y1)                       $panneau(acqfen,Y1)
      set parametres(acqfen,X2)                       $panneau(acqfen,X2)
      set parametres(acqfen,Y2)                       $panneau(acqfen,Y2)
      set parametres(acqfen,verifier_ecraser_fichier) $panneau(acqfen,verifier_ecraser_fichier)
      set parametres(acqfen,verifier_index_depart)    $panneau(acqfen,verifier_index_depart)

      #--- Sauvegarde des parametres
      set nom_fichier [ file join $::audace(rep_home) acqfen.ini ]
      if [ catch { open $nom_fichier w } fichier ] {
         return
      } else {
         foreach { a b } [ array get parametres ] {
            puts $fichier "set parametres($a) \"$b\""
         }
         close $fichier
      }
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This

      #--- On cree la variable de configuration des mots cles
      if { ! [ info exists ::conf(acqfen,keywordConfigName) ] } { set ::conf(acqfen,keywordConfigName) "default" }

      #--- Je selectionne les mots cles selon les exigences de l'outil
      ::acqfen::configToolKeywords $visuNo

      ::acqfen::adaptOutilAcqFen
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable This
      global audace panneau

      #--- Je verifie si une operation est en cours
      if { $panneau(acqfen,acquisition) == "1" } {
         return -1
      }

      #--- Sauvegarde de la configuration de prise de vue
      ::acqfen::enregistrerParametres

      #--- Je supprime la liste des mots clefs non modifiables
      ::keyword::setKeywordState $visuNo $::conf(acqfen,keywordConfigName) [ list ]

      #--- Initialisation du fenetrage
      set camItem [ ::confVisu::getCamItem $audace(visuNo) ]
      if { [ ::confCam::isReady $camItem ] == "1" } {
         set n1n2 [cam$audace(camNo) nbcells]
         cam$audace(camNo) window [ list 1 1 [lindex $n1n2 0] [lindex $n1n2 1] ]
      }
   }

   # ==================================================================
   # === definition des fonctions generales a executer dans l'outil ===
   # ==================================================================

   #--- Procedure de changement de l'etat de l'obturateur
   proc changeObt { } {
      variable This
      global audace panneau

      #---
      set camItem [ ::confVisu::getCamItem $audace(visuNo) ]
      set result  [ ::confCam::setShutter $camItem $panneau(acqfen,obt) ]
      if { $result != -1 } {
         set panneau(acqfen,obt) $result
         $This.obt.lab configure -text $panneau(acqfen,obt,$panneau(acqfen,obt))
      }
   }

   #--- Procedure pour recuperer l'etat de l'obturateur a la connexion d'une camera
   proc adaptOutilAcqFen { args } {
      variable This
      global audace conf panneau

      #--- petits reccorcis bien utiles
      set camItem [ ::confVisu::getCamItem $audace(visuNo) ]
      set camNo   [ ::confCam::getCamNo $camItem ]
      if { $camNo == "0" } {
         #--- La camera n'a pas ete encore selectionnee
         set camProduct ""
      } else {
         set camProduct [ cam$camNo product ]
      }

      #--- widgets de l'obturateur
      if { [ ::confCam::getPluginProperty $camItem hasShutter ] == "1" } {
         if { ! [ info exists conf($camProduct,foncobtu) ] } {
            set conf($camProduct,foncobtu) "2"
         } else {
            if { $conf($camProduct,foncobtu) == "0" } {
               set panneau(acqfen,obt) "0"
            } elseif { $conf($camProduct,foncobtu) == "1" } {
               set panneau(acqfen,obt) "1"
            } elseif { $conf($camProduct,foncobtu) == "2" } {
               set panneau(acqfen,obt) "2"
            }
         }
         $This.obt.lab configure -text $panneau(acqfen,obt,$panneau(acqfen,obt))
         #--- j'affiche la frame de l'obturateur
         pack $This.obt -side top -fill x -after $This.config.but
      } else {
         #--- je masque la frame de l'obturateur
         pack forget $This.obt
      }
   }

   #--- Procedure de changement du binning (acquisitions fenetrees)
   proc changerBinning { } {
      variable This
      global caption panneau

      switch -exact -- $panneau(acqfen,bin) {
         "2" {
            set panneau(acqfen,bin) 1
         }
         "1" {
            set panneau(acqfen,bin) 2
         }
      }
      $This.acq.butbin configure -text $caption(acqfen,bin,$panneau(acqfen,bin))
   }

   #--- Procedure de changement du binning (acquisitions pleine trame)
   proc changerBinningCent { } {
      variable This
      global caption panneau

      switch -exact -- $panneau(acqfen,bin_centrage) {
         "1" {
            set panneau(acqfen,bin_centrage) 2
         }
         "2" {
            set panneau(acqfen,bin_centrage) 3
         }
         "3" {
            set panneau(acqfen,bin_centrage) 4
         }
         "4" {
            set panneau(acqfen,bin_centrage) 1
         }
      }
      $This.acqcent.butbin configure -text $caption(acqfen,bin,$panneau(acqfen,bin_centrage))
   }

   #--- Procedure de mise a jour de l'interface graphique de l'outil
   proc changerAffPleineTrame { } {
      variable This
      global panneau

      switch -exact -- $panneau(acqfen,affpleinetrame)$panneau(acqfen,afffenetrees) {
         "00" {
            set panneau(acqfen,affpleinetrame) 1
            pack forget $This.acqcentred
            pack forget $This.acqred
         }
         "01" {
            set panneau(acqfen,affpleinetrame) 1
            pack forget $This.acqcentred
            pack forget $This.acq
         }
         "10" {
            set panneau(acqfen,affpleinetrame) 0
            pack forget $This.acqcent
            pack forget $This.acqred
         }
         "11" {
            set panneau(acqfen,affpleinetrame) 0
            pack forget $This.acqcent
            pack forget $This.acq
         }
      }
      pack forget $This.mode
      ::acqfen::actualiserAffichage
   }

   #--- Procedure de mise a jour de l'interface graphique de l'outil
   proc changerAffFenetrees { } {
      variable This
      global panneau

      switch -exact -- $panneau(acqfen,affpleinetrame)$panneau(acqfen,afffenetrees) {
         "00" {
            set panneau(acqfen,afffenetrees) 1
            pack forget $This.acqcentred
            pack forget $This.acqred
         }
         "01" {
            set panneau(acqfen,afffenetrees) 0
            pack forget $This.acqcentred
            pack forget $This.acq
         }
         "10" {
            set panneau(acqfen,afffenetrees) 1
            pack forget $This.acqcent
            pack forget $This.acqred
         }
         "11" {
            set panneau(acqfen,afffenetrees) 0
            pack forget $This.acqcent
            pack forget $This.acq
         }
      }
      pack forget $This.mode
      ::acqfen::actualiserAffichage
   }

   #--- Procedure de mise a jour de l'affichage du fenetrage sur la pleine trame
   proc actualiserAffichage { } {
      variable This
      global panneau

      switch -exact -- $panneau(acqfen,affpleinetrame)$panneau(acqfen,afffenetrees) {
         00 {
            pack $This.acqcentred -side top -fill x
            pack $This.acqred -side top -fill x
            pack $This.mode -side top -fill x
         }
         01 {
            pack $This.acqcentred -side top -fill x
            pack $This.acq -side top -fill x
            pack $This.mode -side top -fill x
         }
         10 {
            pack $This.acqcent -side top -fill x
            pack $This.acqred -side top -fill x
            pack $This.mode -side top -fill x
         }
         11 {
            pack $This.acqcent -side top -fill x
            pack $This.acq -side top -fill x
            pack $This.mode -side top -fill x
         }
      }
   }

   #--- Procedure d'acquisition pleine trame
   proc goStopCent { } {
      variable This
      global audace caption panneau

      if { [::cam::list] != "" } {

         switch -exact -- $panneau(acqfen,go_stop_cent) {
            "go" {
               set catchError [ catch {
                  #--- Mise a jour de variable
                  set panneau(acqfen,acquisition) "1"

                  #--- Modification du bouton, pour eviter un second lancement
                  set panneau(acqfen,go_stop_cent) stop
                  $This.acqcent.but configure -text $caption(acqfen,stop)
                  $This.acqcentred.but configure -text $caption(acqfen,stop)

                  #--- Suppression de la zone selectionnee avec la souris
                  if { [ lindex [ list [ ::confVisu::getBox 1 ] ] 0 ] != "" } {
                     ::confVisu::deleteBox
                  }

                  #--- La commande exptime permet de fixer le temps de pose de l'image.
                  cam$audace(camNo) exptime $panneau(acqfen,pose_centrage)

                  #--- La commande bin permet de fixer le binning.
                  cam$audace(camNo) bin [list $panneau(acqfen,bin_centrage) $panneau(acqfen,bin_centrage)]

                  #--- La commande window permet de fixer le fenetrage de numerisation du CCD
                  cam$audace(camNo) window [list 1 1 [lindex [cam$audace(camNo) nbcells] 0] [lindex [cam$audace(camNo) nbcells] 1]]

                  #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
                  if { $panneau(acqfen,pose_centrage) >= "0" && $panneau(acqfen,pose_centrage) < "1" } {
                     ::acqfen::avancementPose $panneau(acqfen,pose_centrage) 0
                  }

                  #--- Alarme sonore de fin de pose
                  ::camera::alarmeSonore $panneau(acqfen,pose_centrage)

                  #--- Declenchement de l'acquisition
                  ::camera::acquisition [ ::confVisu::getCamItem $audace(visuNo) ] "::acqfen::attendImage" $panneau(acqfen,pose_centrage)

                  #--- Appel du timer
                  after 10 ::acqfen::dispTime $panneau(acqfen,pose_centrage)

                  #--- Attente de la fin de l'acquisition
                  vwait panneau(acqfen,finAquisition)

                  #--- Applique un zoom ou un scale (re-echantillonnage)
                  if {$panneau(acqfen,typezoom)=="zoom"} {
                     #--- Applique un zoom
                     visu$audace(visuNo) zoom $panneau(acqfen,bin_centrage)
                  } else {
                     #--- Applique un scale (re-echantillonne) si la camera possede bien le binning demande
                     #--- L'image finale a la meme dimension a l'ecran que l'image en binning 1x1
                     set binningCamera "$panneau(acqfen,bin_centrage)x$panneau(acqfen,bin_centrage)"
                     if { [ lsearch [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningList ] $binningCamera ] != "-1" } {
                        buf$audace(bufNo) scale [list $panneau(acqfen,bin_centrage) $panneau(acqfen,bin_centrage)] 1
                     }
                  }

                  #--- Rajoute des mots cles dans l'en-tete FITS
                  foreach keyword [ ::keyword::getKeywords $audace(visuNo) $::conf(acqfen,keywordConfigName) ] {
                     buf$audace(bufNo) setkwd $keyword
                  }

                  #--- Mise a jour du nom du fichier dans le titre et de la fenetre de l'en-tete FITS
                  ::confVisu::setFileName $audace(visuNo) ""

                  #--- Affichage avec visu auto
                  ::audace::autovisu $audace(visuNo)

                  #--- On restitue l'affichage du bouton "GO":
                  set panneau(acqfen,go_stop_cent) go
                  $This.acqcent.but configure -text $caption(acqfen,GO)
                  $This.acqcentred.but configure -text $caption(acqfen,GO)

                  #--- On modifie le bouton "Go" des acquisitions fenetrees
                  $This.acq.but configure -text $caption(acqfen,actuxy) -command ::acqfen::actualiserCoordonnees
                  $This.acqred.but configure -text $caption(acqfen,actuxy) -command ::acqfen::actualiserCoordonnees

                  #--- Configuration du fenetrage
                  place forget $This.acq.matrice_color_invariant.fen
                  place forget $This.acqred.matrice_color_invariant.fen
                  $This.acq.matrice_color_invariant.fen configure -width $panneau(acqfen,mtx_x) -height $panneau(acqfen,mtx_y)
                  $This.acqred.matrice_color_invariant.fen configure -width $panneau(acqfen,mtx_x) -height $panneau(acqfen,mtx_y)
                  place $This.acq.matrice_color_invariant.fen -x 0 -y 0
                  place $This.acqred.matrice_color_invariant.fen -x 0 -y 0

                  #--- Mise a jour de variables
                  set panneau(acqfen,acquisition)   "0"
                  set panneau(acqfen,demande_arret) "0"

                  #--- je ferme la fenetre d'avancement
                  ::acqfen::avancementPose $panneau(acqfen,pose_centrage) -1

               } ]

               if { $catchError == 1 } {
                  #--- j'affiche et je trace le message d'erreur
                  ::tkutil::displayErrorInfo $::caption(acqfen,titre_fenetrees)

                  #--- je restaure les boutons
                  set panneau(acqfen,go_stop_cent) go
                  $This.acqcent.but configure -text $::caption(acqfen,GO)
                  $This.acqcentred.but configure -text $::caption(acqfen,GO)
                  set panneau(acqfen,acquisition)   "0"
                  set panneau(acqfen,demande_arret) "0"

                  #--- je ferme la fenetre d'avancement
                  ::acqfen::avancementPose $panneau(acqfen,pose_centrage) -1
               }
            }

            "stop" {
               #--- On positionne un indicateur de demande d'arret
               set panneau(acqfen,demande_arret) "1"

               #--- Annulation de l'alarme de fin de pose
               catch { after cancel bell }

               #--- Arret de la capture de l'image
               ::camera::stopAcquisition [ ::confVisu::getCamItem $audace(visuNo) ]

               #--- J'attends la fin de l'acquisition
               vwait panneau(acqfen,finAquisition)
            }
         }

         #--- On rend les entry inactives
         $This.acq.x1.entryX1 configure -state normal
         $This.acq.y1.entryY1 configure -state normal
         $This.acq.x2.entryX2 configure -state normal
         $This.acq.y2.entryY2 configure -state normal

         #--- On rend les entry inactives
         $This.acqred.x1.entryX1 configure -state normal
         $This.acqred.y1.entryY1 configure -state normal
         $This.acqred.x2.entryX2 configure -state normal
         $This.acqred.y2.entryY2 configure -state normal

      } else {
         ::confCam::run
      }
   }

   #--- Procedure d'acquisitions fenetrees
   proc goStop { } {
      variable This
      global audace caption conf panneau

      if { [::cam::list] != "" } {

         #--- Enregistrement de l'extension des fichiers
         set ext $conf(extension,defaut)
         #---
         switch -exact -- $panneau(acqfen,go_stop) {
            "go" {
               #--- Mise a jour de variable
               set panneau(acqfen,acquisition) "1"

               #--- Modification du bouton, pour eviter un second lancement
               set panneau(acqfen,go_stop) stop
               $This.acq.but configure -text $caption(acqfen,stop)
               $This.acqred.but configure -text $caption(acqfen,stop)

               #--- on desactive toute demande d'arret
               set panneau(acqfen,demande_arret) "0"

               #--- Suppression de la zone selectionnee avec la souris
               if { [ lindex [ list [ ::confVisu::getBox 1 ] ] 0 ] != "" } {
                  ::confVisu::deleteBox
               }

               switch -exact -- $panneau(acqfen,mode) {
                  "1" {
                     set panneau(acqfen,enregistrer) 0
                     ::acqfen::acqAcqfen
                     #--- Affichage avec visu auto
                     ::audace::autovisu $audace(visuNo)
                  }
                  "2" {
                     #--- On verifie l'integrite des parametres d'entree :

                     #--- On verifie qu'il y a bien un nom de fichier
                     if {$panneau(acqfen,nom_image) == ""} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,donnomfich)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que le nom de fichier n'a pas d'espace
                     if {[llength $panneau(acqfen,nom_image)] > 1} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,nomblanc)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que l'index existe
                     if {$panneau(acqfen,index) == ""} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,saisind)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- Envoie un warning si l'index n'est pas a 1
                     if { $panneau(acqfen,index) != "1" && $panneau(acqfen,verifier_index_depart) == 1 } {
                        set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                           -message $caption(acqfen,indpasun)]
                        if { $confirmation == "no" } {
                           #--- On restitue l'affichage du bouton "GO" :
                           set panneau(acqfen,go_stop) go
                           $This.acq.but configure -text $caption(acqfen,GO)
                           $This.acqred.but configure -text $caption(acqfen,GO)
                           return
                        }
                     }
                     #--- On verifie que le nombre d'images a faire existe
                     if {$panneau(acqfen,nb_images) == ""} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,saisnbim)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- Verifie que le nom des fichiers n'existe pas deja...
                     set nom $panneau(acqfen,nom_image)
                     #--- Pour eviter un nom de fichier qui commence par un blanc
                     set nom [lindex $nom 0]
                     append nom $panneau(acqfen,index) $ext
                     if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                        #--- Dans ce cas, le fichier existe deja...
                        set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                        -message $caption(acqfen,fichdeja)]
                        if { $confirmation == "no" } {
                           #--- On restitue l'affichage du bouton "GO" :
                           set panneau(acqfen,go_stop) go
                           $This.acq.but configure -text $caption(acqfen,GO)
                           $This.acqred.but configure -text $caption(acqfen,GO)
                           return
                        }
                     }

                     switch -exact -- $panneau(acqfen,fenreglfen2)$panneau(acqfen,fenreglfen3) {
                        "11" {
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage avec visu auto
                              ::audace::autovisu $audace(visuNo)
                              #--- Sauvegarde de l'image
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              #--- Verifie que le nom du fichier n'existe pas deja...
                              set nom1 "$nom"
                              append nom1 $panneau(acqfen,index) $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                    -message $caption(acqfen,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                              set name [append nom $panneau(acqfen,index)]
                              ::confVisu::setFileName $audace(visuNo) $name$ext
                              #--- Sauvegarde de l'image
                              saveima $name $audace(visuNo)
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Alerte sonore de fin de serie
                           if { $panneau(acqfen,fenreglfen5) == "1" } {
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                           }
                        }
                        "21" {
                           set nbint 1
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 ::audace::autovisu $audace(visuNo)
                                 set nbint 1
                              } else {
                                 incr nbint
                              }
                              #--- Sauvegarde de l'image
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              #--- Verifie que le nom du fichier n'existe pas deja...
                              set nom1 "$nom"
                              append nom1 $panneau(acqfen,index) $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                    -message $caption(acqfen,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                              set name [append nom $panneau(acqfen,index)]
                              ::confVisu::setFileName $audace(visuNo) $name$ext
                              #--- Sauvegarde de l'image
                              saveima $name $audace(visuNo)
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Alerte sonore de fin de serie
                           if { $panneau(acqfen,fenreglfen5) == "1" } {
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                           }
                        }
                        "31" {
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Sauvegarde de l'image
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              #--- Verifie que le nom du fichier n'existe pas deja...
                              set nom1 "$nom"
                              append nom1 $panneau(acqfen,index) $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                    -message $caption(acqfen,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                              set name [append nom $panneau(acqfen,index)]
                              ::confVisu::setFileName $audace(visuNo) $name$ext
                              #--- Sauvegarde de l'image
                              saveima $name $audace(visuNo)
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Affichage avec visu auto
                           ::audace::autovisu $audace(visuNo)
                           #--- Alerte sonore de fin de serie
                           if { $panneau(acqfen,fenreglfen5) == "1" } {
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                           }
                        }
                        "12" {
                           set liste_buffers ""
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage avec visu auto
                              ::audace::autovisu $audace(visuNo)
                              #--- Sauvegarde temporaire de l'image
                              set buftmp [buf::create]
                              buf$buftmp extension $conf(extension,defaut)
                              buf$audace(bufNo) copyto $buftmp
                              lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
                              #--- Verifie que le nom du fichier n'existe pas deja...
                              set nom1 "$nom"
                              append nom1 [lindex $ima 1] $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                    -message $caption(acqfen,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                              set name [append nom [lindex $ima 1]]
                              ::confVisu::setFileName $audace(visuNo) $name$ext
                              #--- Sauvegarde de l'image
                              saveima $name $audace(visuNo)
                           }
                           #--- Alerte sonore de fin de serie
                           if { $panneau(acqfen,fenreglfen5) == "1" } {
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                           }
                           #--- On libere les buffers temporaires
                           foreach ima $liste_buffers {buf::delete [lindex $ima 0]}
                        }
                        "22" {
                           set liste_buffers ""
                           set nbint 1
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 ::audace::autovisu $audace(visuNo)
                                 set nbint 1
                              } else {
                                 incr nbint
                              }
                              #--- Sauvegarde temporaire de l'image
                              set buftmp [buf::create]
                              buf$buftmp extension $conf(extension,defaut)
                              buf$audace(bufNo) copyto $buftmp
                              lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
                              #--- Verifie que le nom du fichier n'existe pas deja...
                              set nom1 "$nom"
                              append nom1 [lindex $ima 1] $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                    -message $caption(acqfen,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                              set name [append nom [lindex $ima 1]]
                              ::confVisu::setFileName $audace(visuNo) $name$ext
                              #--- Sauvegarde de l'image
                              saveima $name $audace(visuNo)
                           }
                           #--- Alerte sonore de fin de serie
                           if { $panneau(acqfen,fenreglfen5) == "1" } {
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                           }
                           #--- On libere les buffers temporaires
                           foreach ima $liste_buffers {buf::delete [lindex $ima 0]}
                        }
                        "32" {
                           set liste_buffers ""
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Sauvegarde temporaire de l'image
                              set buftmp [buf::create]
                              buf$buftmp extension $conf(extension,defaut)
                              buf$audace(bufNo) copyto $buftmp
                              lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
                              #--- Verifie que le nom du fichier n'existe pas deja...
                              set nom1 "$nom"
                              append nom1 [lindex $ima 1] $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                    -message $caption(acqfen,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                              set name [append nom [lindex $ima 1]]
                              ::confVisu::setFileName $audace(visuNo) $name$ext
                              #--- Sauvegarde de l'image
                              saveima $name $audace(visuNo)
                           }
                           #--- Affichage avec visu auto
                           ::audace::autovisu $audace(visuNo)
                           #--- Alerte sonore de fin de serie
                           if { $panneau(acqfen,fenreglfen5) == "1" } {
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                              after 200
                              bell
                           }
                           #--- On libere les buffers temporaires
                           foreach ima $liste_buffers {buf::delete [lindex $ima 0]}
                        }
                     }
                  }
                  "3" {
                     #--- On verifie l'integrite des parametres d'entree :

                     #--- On fait les verifications que si on enregistre les images
                     if { $panneau(acqfen,enregistrer) == "1" } {
                        #--- On verifie qu'il y a bien un nom de fichier
                        if {$panneau(acqfen,nom_image) == ""} {
                           tk_messageBox -title $caption(acqfen,pb) -type ok \
                              -message $caption(acqfen,donnomfich)
                           #--- On restitue l'affichage du bouton "GO" :
                           set panneau(acqfen,go_stop) go
                           $This.acq.but configure -text $caption(acqfen,GO)
                           $This.acqred.but configure -text $caption(acqfen,GO)
                           return
                        }
                        #--- On verifie que le nom de fichier n'a pas d'espace
                        if {[llength $panneau(acqfen,nom_image)] > 1} {
                           tk_messageBox -title $caption(acqfen,pb) -type ok \
                              -message $caption(acqfen,nomblanc)
                           #--- On restitue l'affichage du bouton "GO" :
                           set panneau(acqfen,go_stop) go
                           $This.acq.but configure -text $caption(acqfen,GO)
                           $This.acqred.but configure -text $caption(acqfen,GO)
                           return
                        }
                        #--- On verifie que l'index existe
                        if {$panneau(acqfen,index) == ""} {
                           tk_messageBox -title $caption(acqfen,pb) -type ok \
                              -message $caption(acqfen,saisind)
                           #--- On restitue l'affichage du bouton "GO" :
                           set panneau(acqfen,go_stop) go
                           $This.acq.but configure -text $caption(acqfen,GO)
                           $This.acqred.but configure -text $caption(acqfen,GO)
                           return
                        }
                        #--- Envoie un warning si l'index n'est pas a 1
                        if { $panneau(acqfen,index) != "1" && $panneau(acqfen,verifier_index_depart) == 1 } {
                           set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                              -message $caption(acqfen,indpasun)]
                           if { $confirmation == "no" } {
                              #--- On restitue l'affichage du bouton "GO" :
                              set panneau(acqfen,go_stop) go
                              $This.acq.but configure -text $caption(acqfen,GO)
                              $This.acqred.but configure -text $caption(acqfen,GO)
                              return
                           }
                        }
                        #--- Verifie que le nom des fichiers n'existe pas deja...
                        set nom $panneau(acqfen,nom_image)
                        #--- Pour eviter un nom de fichier qui commence par un blanc
                        set nom [lindex $nom 0]
                        append nom $panneau(acqfen,index) $ext
                        if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                           #--- Dans ce cas, le fichier existe deja...
                           set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                              -message $caption(acqfen,fichdeja)]
                           if { $confirmation == "no" } {
                              #--- On restitue l'affichage du bouton "GO" :
                              set panneau(acqfen,go_stop) go
                              $This.acq.but configure -text $caption(acqfen,GO)
                              $This.acqred.but configure -text $caption(acqfen,GO)
                              return
                           }
                        }
                     }

                     switch -exact -- $panneau(acqfen,fenreglfen2)$panneau(acqfen,fenreglfen3) {
                        "11" {
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage avec visu auto
                              ::audace::autovisu $audace(visuNo)
                              #--- Si demande, sauvegarde de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set nom $panneau(acqfen,nom_image)
                                 #--- Pour eviter un nom de fichier qui commence par un blanc :
                                 set nom [lindex $nom 0]
                                 #--- Verifie que le nom du fichier n'existe pas deja...
                                 set nom1 "$nom"
                                 append nom1 $panneau(acqfen,index) $ext
                                 if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                    #--- Dans ce cas, le fichier existe deja...
                                    set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                       -message $caption(acqfen,fichdeja)]
                                    if { $confirmation == "no" } {
                                       break
                                    }
                                 }
                                 #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                                 set name [append nom $panneau(acqfen,index)]
                                 ::confVisu::setFileName $audace(visuNo) $name$ext
                                 #--- Sauvegarde de l'image
                                 saveima $name $audace(visuNo)
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                        }
                        "21" {
                           set nbint 1
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 ::audace::autovisu $audace(visuNo)
                                 set nbint 1
                              } else {
                                 incr nbint
                              }
                              #--- Si demande, sauvegarde de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set nom $panneau(acqfen,nom_image)
                                 #--- Pour eviter un nom de fichier qui commence par un blanc :
                                 set nom [lindex $nom 0]
                                 #--- Verifie que le nom du fichier n'existe pas deja...
                                 set nom1 "$nom"
                                 append nom1 $panneau(acqfen,index) $ext
                                 if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                    #--- Dans ce cas, le fichier existe deja...
                                    set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                       -message $caption(acqfen,fichdeja)]
                                    if { $confirmation == "no" } {
                                       break
                                    }
                                 }
                                 #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                                 set name [append nom $panneau(acqfen,index)]
                                 ::confVisu::setFileName $audace(visuNo) $name$ext
                                 #--- Sauvegarde de l'image
                                 saveima $name $audace(visuNo)
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                        }
                        "31" {
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Si demande, sauvegarde de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set nom $panneau(acqfen,nom_image)
                                 #--- Pour eviter un nom de fichier qui commence par un blanc :
                                 set nom [lindex $nom 0]
                                 #--- Verifie que le nom du fichier n'existe pas deja...
                                 set nom1 "$nom"
                                 append nom1 $panneau(acqfen,index) $ext
                                 if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                    #--- Dans ce cas, le fichier existe deja...
                                    set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                       -message $caption(acqfen,fichdeja)]
                                    if { $confirmation == "no" } {
                                       break
                                    }
                                 }
                                 #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                                 set name [append nom $panneau(acqfen,index)]
                                 ::confVisu::setFileName $audace(visuNo) $name$ext
                                 #--- Sauvegarde de l'image
                                 saveima $name $audace(visuNo)
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Affichage avec visu auto
                           ::audace::autovisu $audace(visuNo)
                        }
                        "12" {
                           set liste_buffers ""
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage avec visu auto
                              ::audace::autovisu $audace(visuNo)
                              #--- Si demande, sauvegarde temporaire de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set buftmp [buf::create]
                                 buf$buftmp extension $conf(extension,defaut)
                                 buf$audace(bufNo) copyto $buftmp
                                 lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
                              #--- Verifie que le nom du fichier n'existe pas deja
                              set nom1 "$nom"
                              append nom1 [lindex $ima 1] $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                    -message $caption(acqfen,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                              set name [append nom [lindex $ima 1]]
                              ::confVisu::setFileName $audace(visuNo) $name$ext
                              #--- Sauvegarde de l'image
                              saveima $name $audace(visuNo)
                           }
                        }
                        "22" {
                           set nbint 1
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 ::audace::autovisu $audace(visuNo)
                                 set nbint 1
                              } else {
                                 incr nbint
                              }
                              #--- Si demande, sauvegarde temporaire de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set buftmp [buf::create]
                                 buf$buftmp extension $conf(extension,defaut)
                                 buf$audace(bufNo) copyto $buftmp
                                 lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
                              #--- Verifie que le nom du fichier n'existe pas deja...
                              set nom1 "$nom"
                              append nom1 [lindex $ima 1] $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                    -message $caption(acqfen,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                              set name [append nom [lindex $ima 1]]
                              ::confVisu::setFileName $audace(visuNo) $name$ext
                              #--- Sauvegarde de l'image
                              saveima $name $audace(visuNo)
                           }
                        }
                        "32" {
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Si demande, sauvegarde temporaire de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set buftmp [buf::create]
                                 buf$buftmp extension $conf(extension,defaut)
                                 buf$audace(bufNo) copyto $buftmp
                                 lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
                              #--- Verifie que le nom du fichier n'existe pas deja...
                              set nom1 "$nom"
                              append nom1 [lindex $ima 1] $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                                    -message $caption(acqfen,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                              set name [append nom [lindex $ima 1]]
                              ::confVisu::setFileName $audace(visuNo) $name$ext
                              #--- Sauvegarde de l'image
                              saveima $name $audace(visuNo)
                           }
                           #--- Affichage avec visu auto
                           ::audace::autovisu $audace(visuNo)
                        }
                     }
                  }
               }
               #--- On restitue l'affichage du bouton "GO" :
               set panneau(acqfen,go_stop) go
               $This.acq.but configure -text $caption(acqfen,GO)
               $This.acqred.but configure -text $caption(acqfen,GO)
               #--- Mise a jour de variables
               set panneau(acqfen,acquisition)   "0"
               set panneau(acqfen,demande_arret) "0"
            }
            "stop" {
               #--- On positionne un indicateur de demande d'arret
               set panneau(acqfen,demande_arret) "1"
               #--- Annulation de l'alarme de fin de pose
               catch { after cancel bell }
               #--- Arret de la capture de l'image
               ::camera::stopAcquisition [ ::confVisu::getCamItem $audace(visuNo) ]
               #--- J'attends la fin de l'acquisition
               vwait panneau(acqfen,finAquisition)
            }
         }

      } else {
         ::confCam::run
      }
   }

   #--- Procedure d'acquisition elementaire
   proc acqAcqfen { } {
      global audace panneau

      set catchError [ catch {
         #--- Raccourcis
         set camxis1 [lindex [cam$audace(camNo) nbcells] 0]
         set camxis2 [lindex [cam$audace(camNo) nbcells] 1]

         #--- La commande bin permet de fixer le binning.
         cam$audace(camNo) bin [list $panneau(acqfen,bin) $panneau(acqfen,bin)]

         #--- La commande window permet de fixer le fenetrage de numerisation du CCD
         if {($panneau(acqfen,X1) == "") || ($panneau(acqfen,Y1) == "") || ($panneau(acqfen,X2) == "") || ($panneau(acqfen,Y2) == "")} {
            cam$audace(camNo) window [list 1 1 $camxis1 $camxis2]
         } else {
            cam$audace(camNo) window [list $panneau(acqfen,X1) $panneau(acqfen,Y1) \
            $panneau(acqfen,X2) $panneau(acqfen,Y2)]
         }

         #--- Acquisition
         if {$panneau(acqfen,fenreglfen1)=="1"} {
            #--- Acquisitions avec nombre d'effacements prealables par defaut
            #--- La commande exptime permet de fixer le temps de pose de l'image.
            cam$audace(camNo) exptime $panneau(acqfen,pose)
            #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
            if { $panneau(acqfen,pose) >= "0" && $panneau(acqfen,pose) < "1" } {
               ::acqfen::avancementPose $panneau(acqfen,pose) 0
            }
            #--- Alarme sonore de fin de pose
            ::camera::alarmeSonore $panneau(acqfen,pose)
            #--- Declenchement de l'acquisition
            ::camera::acquisition [ ::confVisu::getCamItem $audace(visuNo) ] "::acqfen::attendImage" $panneau(acqfen,pose)
            #--- Appel du timer
            after 10 ::acqfen::dispTime $panneau(acqfen,pose)
            #--- Attente de la fin de l'acquisition
            vwait panneau(acqfen,finAquisition)
            #--- Effacement de la fenetre de progression
            if [ winfo exists .progress_pose ] {
               destroy .progress_pose
            }
         } else {
            for {set k 1} {$k<=$panneau(acqfen,fenreglfen12)} {incr k} {cam$audace(camNo) wipe}
            after [expr int(1000*$panneau(acqfen,pose))] [cam$audace(camNo) read]
         }

         #--- Rajoute des mots cles dans l'en-tete FITS
         foreach keyword [ ::keyword::getKeywords $audace(visuNo) $::conf(acqfen,keywordConfigName) ] {
            buf$audace(bufNo) setkwd $keyword
         }

         #--- Rajoute les coordonnees de la fenetre dans l'en-tete FITS
         buf$::audace(bufNo) setkwd [list WINDOWX1 $panneau(acqfen,X1) int "Window coordinate" "pixel"]
         buf$::audace(bufNo) setkwd [list WINDOWY1 $panneau(acqfen,Y1) int "Window coordinate" "pixel"]
         buf$::audace(bufNo) setkwd [list WINDOWX2 $panneau(acqfen,X2) int "Window coordinate" "pixel"]
         buf$::audace(bufNo) setkwd [list WINDOWY2 $panneau(acqfen,Y2) int "Window coordinate" "pixel"]

         #--- Mise a jour du nom du fichier dans le titre et de la fenetre de l'en-tete FITS
         ::confVisu::setFileName $audace(visuNo) ""

         #--- Fenetrage sur le buffer si la camera ne possede pas le mode fenetrage (APN et WebCam)
         if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $audace(visuNo) ] hasWindow ] == "0" } {
            buf$audace(bufNo) window [list $panneau(acqfen,X1) $panneau(acqfen,Y1) \
            $panneau(acqfen,X2) $panneau(acqfen,Y2)]
         }
      } ]

      if { $catchError == 1 } {
         #--- j'affiche et je trace le message d'erreur
         ::tkutil::displayErrorInfo $::caption(acqfen,titre_fenetrees)

         #--- Effacement de la fenetre de progression
         if [ winfo exists .progress_pose ] {
            destroy .progress_pose
         }
      }
   }

   #--- Procedure appelee par la thread de la camera pour informer de l'avancement des acquisitions
   proc attendImage { message args } {
      global audace panneau

      switch $message {
         "autovisu" {
            #--- ce message signale que l'image est prete dans le buffer
            #--- on peut l'afficher sans attendre la fin complete de la thread de la camera
            ::confVisu::autovisu $audace(visuNo)
         }
         "acquisitionResult" {
            #--- ce message signale que la thread de la camera a termine completement l'acquisition
            #--- je peux traiter l'image
            set panneau(acqfen,finAquisition) "acquisitionResult"
         }
         "error" {
            #--- ce message signale qu'une erreur est survenue dans la thread de la camera
            #--- j'affiche l'erreur dans la console
            ::console::affiche_erreur "::acqfen::acqAcqfen error: $args\n"
            set panneau(acqfen,finAquisition) "error"
         }
      }
   }

   #------------------------------------------------------------
   # configToolKeywords
   #    configure les mots cles FITS de l'outil
   #------------------------------------------------------------
   proc configToolKeywords { visuNo { configName "" } } {
      #--- Je traite la variable configName
      if { $configName == "" } {
         set configName $::conf(acqfen,keywordConfigName)
      }

      #--- Je selectionne les mots cles optionnels a ajouter dans les images
      #--- Ce sont les mots cles CRPIX1, CRPIX2
      ::keyword::selectKeywords $visuNo $configName [ list CRPIX1 CRPIX2 ]

      #--- Je selectionne la liste des mots cles non modifiables
      ::keyword::setKeywordState $visuNo $configName [ list CRPIX1 CRPIX2 ]
   }

   #------------------------------------------------------------
   # dispTime
   #    Decompte du temps d'exposition
   #    Utilisation dans les scripts : acqfen.tcl + snacq.tcl
   #------------------------------------------------------------
   proc dispTime { exptime } {
      global audace panneau

      #--- j'arrete le timer s'il est deja lance
      if { [ info exists panneau(acqfen,dispTimeAfterId) ] && $panneau(acqfen,dispTimeAfterId) != "" } {
         after cancel $panneau(acqfen,dispTimeAfterId)
         set panneau(acqfen,dispTimeAfterId) ""
      }

      #--- je mets a jour la fenetre de progression
      set t [ cam$audace(camNo) timer -1 ]
      ::acqfen::avancementPose $exptime $t

      if { $t > 0 } {
         #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
         #--- (mode asynchone pour eviter l'empilement des appels recursifs)
         set panneau(acqfen,dispTimeAfterId) [ after 1000 ::acqfen::dispTime $exptime ]
      } else {
         #--- je ne relance pas le timer
         set panneau(acqfen,dispTimeAfterId) ""
      }
   }

   #------------------------------------------------------------
   # avancementPose exptime t
   #    Affichage d'une barre de progression qui simule l'avancement de la pose dans la visu 1
   #------------------------------------------------------------
   proc avancementPose { exptime t } {
      variable This
      global audace caption color conf panneau

      #--- Fenetre d'avancement de la pose non demandee
      if { $panneau(acqfen,avancement_acq) == "0" } {
         return
      }

      #--- Recuperation de la position de la fenetre
      ::acqfen::recupPositionAvancementPose

      #--- Initialisation de la barre de progression
      set cpt "100"

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfen,avancement,position) ] } { set conf(acqfen,avancement,position) "+120+315" }

      #---
      if { [ winfo exists .progress_pose ] != "1" } {

         #--- Cree la fenetre toplevel
         toplevel .progress_pose
         wm transient .progress_pose $This
         wm resizable .progress_pose 0 0
         wm title .progress_pose "$caption(acqfen,en_cours)"
         wm geometry .progress_pose $conf(acqfen,avancement,position)

         #--- Cree le widget et le label du temps ecoule
         label .progress_pose.lab_status -text "" -justify center
         pack .progress_pose.lab_status -side top -fill x -expand true -pady 5

         #---
         if { $panneau(acqfen,demande_arret) == "1" } {
            .progress_pose.lab_status configure -text "$caption(acqfen,numerisation)"
         } else {
            if { $t < 0 } {
               destroy .progress_pose
            } elseif { $t > 0 } {
               .progress_pose.lab_status configure -text "$t $caption(acqfen,sec) / \
                  [ format "%d" [ expr int( $exptime ) ] ] $caption(acqfen,sec)"
               set cpt [ expr $t * 100 / int( $exptime ) ]
               set cpt [ expr 100 - $cpt ]
            } else {
               .progress_pose.lab_status configure -text "$caption(acqfen,numerisation)"
            }
         }

         #---
         if { [ winfo exists .progress_pose ] == "1" } {
            #--- Cree le widget pour la barre de progression
            frame .progress_pose.cadre -width 200 -height 30 -borderwidth 2 -relief groove
            pack .progress_pose.cadre -in .progress_pose -side top \
               -anchor center -fill x -expand true -padx 8 -pady 8

            #--- Affiche de la barre de progression
            frame .progress_pose.cadre.barre_color_invariant -height 26 -bg $color(blue)
            place .progress_pose.cadre.barre_color_invariant -in .progress_pose.cadre \
               -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
            update
         }

         #--- Mise a jour dynamique des couleurs
         if { [ winfo exists .progress_pose ] == "1" } {
            ::confColor::applyColor .progress_pose
         }

      } else {

         #---
         if { $panneau(acqfen,acquisition) == "0" } {
            #--- Je supprime la fenetre s'il n'y a plus de pose en cours
            destroy .progress_pose
         } else {
            if { $panneau(acqfen,demande_arret) == "0" } {
               if { $t > 0 } {
                  .progress_pose.lab_status configure -text "$t $caption(acqfen,sec) / \
                     [ format "%d" [ expr int( $exptime ) ] ] $caption(acqfen,sec)"
                  set cpt [ expr $t * 100 / int( $exptime ) ]
                  set cpt [ expr 100 - $cpt ]
               } else {
                  .progress_pose.lab_status configure -text "$caption(acqfen,numerisation)"
               }
            } else {
               #--- J'affiche "Lecture" des qu'une demande d'arret est demandee
               .progress_pose.lab_status configure -text "$caption(acqfen,numerisation)"
            }
            #--- Affiche de la barre de progression
            place .progress_pose.cadre.barre_color_invariant -in .progress_pose.cadre \
               -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
            update
         }

      }

   }

   #------------------------------------------------------------
   # recupPositionAvancementPose
   #    Recuperation de la position de la fenetre de progression de la pose
   #------------------------------------------------------------
   proc recupPositionAvancementPose { } {
      global conf

      if [ winfo exists .progress_pose ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry .progress_pose ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfen,avancement,position) "+[ string range $geometry $deb $fin ]"
      }
   }

   #--- Procedures d'actualisation des coordonnees
   proc actualiserCoordonnees { { visuNo "1" } } {
      variable This
      global audace caption panneau

      if { [::cam::list] != "" } {
         set box [ ::confVisu::getBox $visuNo ]
         if { $box != "" } {

            if {[lindex $box 0]<[lindex $box 2]} {
               set panneau(acqfen,X1) [lindex $box 0]
               set panneau(acqfen,X2) [lindex $box 2]
            } else {
               set panneau(acqfen,X1) [lindex $box 2]
               set panneau(acqfen,X2) [lindex $box 0]
            }
            if {[lindex $box 1]<[lindex $box 3]} {
               set panneau(acqfen,Y1) [lindex $box 1]
               set panneau(acqfen,Y2) [lindex $box 3]
            } else {
               set panneau(acqfen,Y1) [lindex $box 3]
               set panneau(acqfen,Y2) [lindex $box 1]
            }

         } else {

            if { $panneau(acqfen,X1) == "" } {
               return
            }
            if { $panneau(acqfen,Y1) == "" } {
               return
            }
            if { $panneau(acqfen,X2) == "" } {
               return
            }
            if { $panneau(acqfen,Y2) == "" } {
               return
            }

            if { $panneau(acqfen,X1) < $panneau(acqfen,X2) } {
               set panneau(acqfen,X1) $panneau(acqfen,X1)
               set panneau(acqfen,X2) $panneau(acqfen,X2)
            } else {
               set panneau(acqfen,X1) $panneau(acqfen,X2)
               set panneau(acqfen,X2) $panneau(acqfen,X1)
            }
            if { $panneau(acqfen,Y1) < $panneau(acqfen,Y2) } {
               set panneau(acqfen,Y1) $panneau(acqfen,Y1)
               set panneau(acqfen,Y2) $panneau(acqfen,Y2)
            } else {
               set panneau(acqfen,Y1) $panneau(acqfen,Y2)
               set panneau(acqfen,Y2) $panneau(acqfen,Y1)
            }

         }

         set hauteur [expr $panneau(acqfen,mtx_y)*($panneau(acqfen,Y2)-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]]
         $This.acq.matrice_color_invariant.fen configure -height $hauteur \
            -width [expr $panneau(acqfen,mtx_x)*($panneau(acqfen,X2)-$panneau(acqfen,X1))/[lindex [cam$audace(camNo) nbcells] 0]]
         $This.acqred.matrice_color_invariant.fen configure -height $hauteur \
            -width [expr $panneau(acqfen,mtx_x)*($panneau(acqfen,X2)-$panneau(acqfen,X1))/[lindex [cam$audace(camNo) nbcells] 0]]
         place forget $This.acq.matrice_color_invariant.fen
         place forget $This.acqred.matrice_color_invariant.fen
         place $This.acq.matrice_color_invariant.fen \
            -x [expr $panneau(acqfen,mtx_x)*$panneau(acqfen,X1)/[lindex [cam$audace(camNo) nbcells] 0]] \
            -y [expr $panneau(acqfen,mtx_y)*([lindex [cam$audace(camNo) nbcells] 1]-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]-$hauteur]
         place $This.acqred.matrice_color_invariant.fen \
            -x [expr $panneau(acqfen,mtx_x)*$panneau(acqfen,X1)/[lindex [cam$audace(camNo) nbcells] 0]] \
            -y [expr $panneau(acqfen,mtx_y)*([lindex [cam$audace(camNo) nbcells] 1]-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]-$hauteur]

         #--- On modifie le bouton "Go" des acquisitions fenetrees
         $This.acq.but configure -text $caption(acqfen,GO) -command ::acqfen::goStop
         $This.acqred.but configure -text $caption(acqfen,GO) -command ::acqfen::goStop

         #--- On rend les entry inactives
         $This.acq.x1.entryX1 configure -state disabled
         $This.acq.y1.entryY1 configure -state disabled
         $This.acq.x2.entryX2 configure -state disabled
         $This.acq.y2.entryY2 configure -state disabled

         #--- On rend les entry inactives
         $This.acqred.x1.entryX1 configure -state disabled
         $This.acqred.y1.entryY1 configure -state disabled
         $This.acqred.x2.entryX2 configure -state disabled
         $This.acqred.y2.entryY2 configure -state disabled

      } else {
         ::confCam::run
      }
   }

   proc ChangeMode { { mode "" } } {
      global panneau

      pack forget $panneau(acqfen,mode,$panneau(acqfen,mode)) -anchor nw -fill x

      if { $mode != "" } {
         #--- j'applique le mode passe en parametre
         set panneau(acqfen,mode_en_cours) $mode
      }

      set panneau(acqfen,mode) [ expr [ lsearch "$panneau(acqfen,list_mode)" "$panneau(acqfen,mode_en_cours)" ] + 1 ]
      pack $panneau(acqfen,mode,$panneau(acqfen,mode)) -anchor nw -fill x
   }

   #--- Procedure de suivi par deplacement de la fenetre
   proc deplacerFenetre { } {
      global audace

      set dimx [lindex [buf$audace(bufNo) getkwd NAXIS1 ] 1]
      set dimy [lindex [buf$audace(bufNo) getkwd NAXIS2 ] 1]
      set centro [buf$audace(bufNo) centro [list 1 1 $dimx $dimy ]]
      set depl [list [expr [lindex $centro 0]-0.5*[lindex $format 0]] [expr [lindex $centro 1]-0.5*[lindex $format 1]]]
      set depl_corr [list [expr 1.*[lindex $depl 0]*$panneau(acqfen,fenreglfen42)] [expr 1.*[lindex $depl 1]*$panneau(acqfen,fenreglfen42)]]

      incr panneau(acqfen,X1) [lindex $depl_corr 0]
      incr panneau(acqfen,X2) [lindex $depl_corr 0]
      incr panneau(acqfen,Y1) [lindex $depl_corr 1]
      incr panneau(acqfen,Y2) [lindex $depl_corr 1]

      set hauteur [expr $panneau(acqfen,mtx_y)*($panneau(acqfen,Y2)-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]]
      $This.acq.matrice_color_invariant.fen configure -height $hauteur \
         -width [expr $panneau(acqfen,mtx_x)*($panneau(acqfen,X2)-$panneau(acqfen,X1))/[lindex [cam$audace(camNo) nbcells] 0]]
      $This.acqred.matrice_color_invariant.fen configure -height $hauteur \
         -width [expr $panneau(acqfen,mtx_x)*($panneau(acqfen,X2)-$panneau(acqfen,X1))/[lindex [cam$audace(camNo) nbcells] 0]]
      place forget $This.acq.matrice_color_invariant.fen
      place forget $This.acqred.matrice_color_invariant.fen
      place $This.acq.matrice_color_invariant.fen \
         -x [expr $panneau(acqfen,mtx_x)*$panneau(acqfen,X1)/[lindex [cam$audace(camNo) nbcells] 0]] \
         -y [expr $panneau(acqfen,mtx_y)*([lindex [cam$audace(camNo) nbcells] 1]-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]-$hauteur]
      place $This.acqred.matrice_color_invariant.fen \
         -x [expr $panneau(acqfen,mtx_x)*$panneau(acqfen,X1)/[lindex [cam$audace(camNo) nbcells] 0]] \
         -y [expr $panneau(acqfen,mtx_y)*([lindex [cam$audace(camNo) nbcells] 1]-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]-$hauteur]
   }

   #--- Procedure de sauvegarde de l'image
   #--- Procedure lancee par appui sur le bouton "enregistrer", uniquement dans le
   #--- mode "Une image".
   proc sauveUneImage { } {
      global audace caption conf panneau

      #--- Enregistrement de l'extension des fichiers
      set ext $conf(extension,defaut)

      #--- Verifier qu'il y a bien un nom de fichier
      if {$panneau(acqfen,nom_image) == ""} {
         tk_messageBox -title $caption(acqfen,pb) -type ok \
            -message $caption(acqfen,donnomfich)
         return
      }
      #--- Verifie que le nom de fichier n'a pas d'espace
      if {[llength $panneau(acqfen,nom_image)] > 1} {
         tk_messageBox -title $caption(acqfen,pb) -type ok \
            -message $caption(acqfen,nomblanc)
         return
      }
      #--- Si la case index est cochee, verifier qu'il y a bien un index
      if {$panneau(acqfen,indexer) == 1} {
         #--- Verifie que l'index existe
         if {$panneau(acqfen,index) == ""} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
               -message $caption(acqfen,saisind)
            return
         }
      }

      #--- Generation du nom de fichier
      set nom $panneau(acqfen,nom_image)
      #--- Pour eviter un nom de fichier qui commence par un blanc:
      set nom [lindex $nom 0]
      if {$panneau(acqfen,indexer) == 1 } {
         append nom $panneau(acqfen,index)
      }

      #--- Verifie que le nom du fichier n'existe pas deja...
      set nom1 "$nom"
      append nom1 $ext
      if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfen,verifier_ecraser_fichier) == 1 } {
         #--- Dans ce cas, le fichier existe deja...
         set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
            -message $caption(acqfen,fichdeja)]
         if { $confirmation == "no" } {
            return
         }
      }

      #--- Incremente l'index
      if {$panneau(acqfen,indexer) == 1 } {
         incr panneau(acqfen,index)
      }

      #--- Mise a jour du nom du fichier dans le titre et de la fenetre de l'en-tete FITS
      ::confVisu::setFileName $audace(visuNo) $nom$ext

      #--- Sauvegarde de l'image
      saveima $nom $audace(visuNo)
   }

   #---Procedure de fermeture de la fenetre des reglages
   proc quitFenReglFen { this } {
   global conf panneau

      set This $this

      set panneau(acqfen,fenreglfen1)  $panneau(acqfen,oldfenreglfen1)
      set panneau(acqfen,fenreglfen12) $panneau(acqfen,oldfenreglfen12)
      set panneau(acqfen,fenreglfen2)  $panneau(acqfen,oldfenreglfen2)
      set panneau(acqfen,fenreglfen22) $panneau(acqfen,oldfenreglfen22)
      set panneau(acqfen,fenreglfen3)  $panneau(acqfen,oldfenreglfen3)
      set panneau(acqfen,fenreglfen4)  $panneau(acqfen,oldfenreglfen4)
      #--- Recuperation de la position de la fenetre de reglages
      ::acqfen::recupPosition $This
      set conf(fenreglfen,position)    $panneau(acqfen,position)
      #---
      destroy $This
   }

   #---Procedure de recuperation de la position de la fenetre de reglage
   proc recupPosition { this } {
      global panneau

      set This $this

      set panneau(acqfen,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $panneau(acqfen,geometry) ] ]
      set fin [ string length $panneau(acqfen,geometry) ]
      set panneau(acqfen,position) "+[string range $panneau(acqfen,geometry) $deb $fin]"
   }

}

# ===============================
# === fin du namespace acqfen ===
# ===============================

#------------------------------------------------------------
# acqfenBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc acqfenBuildIF { This } {
global caption color panneau

#--- Trame du panneau

frame $This -borderwidth 2 -relief groove

   #--- Trame du titre panneau
   frame $This.titre -borderwidth 2 -relief groove
   pack $This.titre -side top -fill x

      Button $This.titre.but -borderwidth 1 \
         -text "$caption(acqfen,help_titre1)\n$caption(acqfen,titre_fenetrees)" \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqfen::getPluginType ] ] \
            [ ::acqfen::getPluginDirectory ] [ ::acqfen::getPluginHelp ]"
      pack $This.titre.but -in $This.titre -anchor center -expand 1 -fill both -side top -ipadx 5
      DynamicHelp::add $This.titre.but -text $caption(acqfen,help_titre)

   #--- Trame de la configuration
   frame $This.config -borderwidth 2 -relief groove
   pack $This.config -side top -fill x

      #--- Bonton de Configuration
      button $This.config.but -text $caption(acqfen,congiguration) -borderwidth 1 -command "creeFenReglFen $This"
      pack $This.config.but -in $This.config -anchor center -expand 1 -fill both -side top -ipadx 5

   #--- Trame de l'obturateur
   frame $This.obt -borderwidth 2 -relief ridge -width 16
      button $This.obt.but -text $caption(acqfen,obt) -command ::acqfen::changeObt \
         -state normal
      pack $This.obt.but -side left -ipady 3
      label $This.obt.lab -text $panneau(acqfen,obt,$panneau(acqfen,obt)) -width 6 \
        -relief groove
      pack $This.obt.lab -side left -fill x -expand true -ipady 3
   pack $This.obt -side top -fill x

   #--- Trame acquisition centrage (version complete)
   frame $This.acqcent -borderwidth 1 -relief groove

      #--- Sous-titre "acquisition pleine trame"
      button $This.acqcent.titre -text $caption(acqfen,titre_centrage) -borderwidth 0 \
         -command ::acqfen::changerAffPleineTrame
      pack $This.acqcent.titre -expand true -fill x -pady 2

      #--- Sous-trame pour temps de pose
      frame $This.acqcent.pose -borderwidth 1 -height 77 -relief groove

         #--- Bouton temps de pose
         menubutton $This.acqcent.pose.posebut -text $caption(acqfen,pose) -relief raised \
            -menu $This.acqcent.pose.posebut.menu
         pack $This.acqcent.pose.posebut -side left
         set m [menu $This.acqcent.pose.posebut.menu -tearoff 0]
         foreach temps $panneau(acqfen,temps_pose_centrage) {
            $m add radiobutton -label "$temps" \
               -indicatoron "1" \
               -value "$temps" \
               -variable panneau(acqfen,pose_centrage) \
               -command { }
         }

         #--- Label des secondes
         label $This.acqcent.pose.sec -text $caption(acqfen,sec)
         pack $This.acqcent.pose.sec -side right

         #--- Ligne de saisie du temps de pose
         entry $This.acqcent.pose.pose_ent -width 4 -textvariable panneau(acqfen,pose_centrage) \
            -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $This.acqcent.pose.pose_ent -side left -fill y

      pack $This.acqcent.pose -expand true

      #--- Bouton binning
      button $This.acqcent.butbin -text $caption(acqfen,bin,$panneau(acqfen,bin_centrage)) \
         -command ::acqfen::changerBinningCent
      pack $This.acqcent.butbin -expand true

      #--- Bouton Go/Stop
      button $This.acqcent.but -text $caption(acqfen,GO) -borderwidth 3 -command ::acqfen::goStopCent
      pack $This.acqcent.but -expand true -fill both

   #--- Trame acquisition centrage (version reduite)
   frame $This.acqcentred -borderwidth 1 -relief groove

      #--- Sous-titre "acquisition pleine trame"
      button $This.acqcentred.titre -text $caption(acqfen,titre_centrage) -borderwidth 0 \
         -command ::acqfen::changerAffPleineTrame
      pack $This.acqcentred.titre -expand true -fill x -pady 2

      #--- Bouton Go/Stop
      button $This.acqcentred.but -text $caption(acqfen,GO) -borderwidth 3 -command ::acqfen::goStopCent
      pack $This.acqcentred.but -expand true -fill both

   #--- Trame acquisition fenetree (version complete)
   frame $This.acq -borderwidth 1 -relief groove

      #--- Sous-titre "acquisitions fenetrees"
      button $This.acq.titre -text $caption(acqfen,titre_fenetrees) -borderwidth 0 \
         -command ::acqfen::changerAffFenetrees
      pack $This.acq.titre -expand true -fill x -pady 2

      #--- Sous-trame pour temps de pose
      frame $This.acq.pose -borderwidth 1 -height 77 -relief groove

         #--- Bouton temps de pose
         menubutton $This.acq.pose.posebut -text $caption(acqfen,pose) -relief raised \
            -menu $This.acq.pose.posebut.menu
         pack $This.acq.pose.posebut -side left
         set m [menu $This.acq.pose.posebut.menu -tearoff 0]
         foreach temps $panneau(acqfen,temps_pose) {
            $m add radiobutton -label "$temps" \
               -indicatoron "1" \
               -value "$temps" \
               -variable panneau(acqfen,pose) \
               -command { }
         }

         #--- Label des secondes
         label $This.acq.pose.sec -text $caption(acqfen,sec)
         pack $This.acq.pose.sec -side right

         #--- Ligne de saisie du temps de pose
         entry $This.acq.pose.pose_ent -width 4 -textvariable panneau(acqfen,pose) \
            -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $This.acq.pose.pose_ent -side left -fill y

      pack $This.acq.pose -expand true

      #--- Bouton binning
      button $This.acq.butbin -text $caption(acqfen,bin,$panneau(acqfen,bin)) \
         -command ::acqfen::changerBinning
      pack $This.acq.butbin -expand true

      #--- Representation matrice CCD
      frame $This.acq.matrice_color_invariant -bg $color(blue) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acq.matrice_color_invariant
      frame $This.acq.matrice_color_invariant.fen -bg $color(cyan) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acq.matrice_color_invariant.fen

      #--- Affichage des coordonnees de la fenetre
      frame $This.acq.x1 -borderwidth 1 -relief flat
         label $This.acq.x1.labelX1 -text $caption(acqfen,x1) -padx 5
         pack $This.acq.x1.labelX1 -fill none -side left
         entry $This.acq.x1.entryX1 -textvariable panneau(acqfen,X1) -width 8 -relief groove \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100000 }
         pack $This.acq.x1.entryX1 -fill none -side left
      pack $This.acq.x1 -fill none -side top
      frame $This.acq.y1 -borderwidth 1 -relief flat
         label $This.acq.y1.labelY1 -text $caption(acqfen,y1) -padx 5
         pack $This.acq.y1.labelY1 -fill none -side left
         entry $This.acq.y1.entryY1 -textvariable panneau(acqfen,Y1) -width 8 -relief groove \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100000 }
         pack $This.acq.y1.entryY1 -fill none -side left
      pack $This.acq.y1 -fill none -side top
      frame $This.acq.x2 -borderwidth 1 -relief flat
         label $This.acq.x2.labelX2 -text $caption(acqfen,x2) -padx 5
         pack $This.acq.x2.labelX2 -fill none -side left
         entry $This.acq.x2.entryX2 -textvariable panneau(acqfen,X2) -width 8 -relief groove \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100000 }
         pack $This.acq.x2.entryX2 -fill none -side left
      pack $This.acq.x2 -fill none -side top
      frame $This.acq.y2 -borderwidth 1 -relief flat
         label $This.acq.y2.labelY2 -text $caption(acqfen,y2) -padx 5
         pack $This.acq.y2.labelY2 -fill none -side left
         entry $This.acq.y2.entryY2 -textvariable panneau(acqfen,Y2) -width 8 -relief groove \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100000 }
         pack $This.acq.y2.entryY2 -fill none -side left
      pack $This.acq.y2 -fill none -side top

      #--- Bouton Go/Stop
      button $This.acq.but -text $caption(acqfen,actuxy) -borderwidth 3 -command ::acqfen::actualiserCoordonnees
      pack $This.acq.but -expand true -fill both

   #--- Trame acquisition fenetree (version reduite)
   frame $This.acqred -borderwidth 1 -relief groove

      #--- Sous-titre "acquisitions fenetrees"
      button $This.acqred.titre -text $caption(acqfen,titre_fenetrees) -borderwidth 0 \
         -command ::acqfen::changerAffFenetrees
      pack $This.acqred.titre -expand true -fill x -pady 2

      #--- Representation matrice CCD
      frame $This.acqred.matrice_color_invariant -bg $color(blue) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acqred.matrice_color_invariant
      frame $This.acqred.matrice_color_invariant.fen -bg $color(cyan) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acqred.matrice_color_invariant.fen

      #--- Affichage des coordonnees de la fenetre
      frame $This.acqred.x1 -borderwidth 1 -relief flat
         label $This.acqred.x1.labelX1 -text $caption(acqfen,x1) -padx 5
         pack $This.acqred.x1.labelX1 -fill none -side left
         entry $This.acqred.x1.entryX1 -textvariable panneau(acqfen,X1) -width 8 -relief groove \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100000 }
         pack $This.acqred.x1.entryX1 -fill none -side left
      pack $This.acqred.x1 -fill none -side top
      frame $This.acqred.y1 -borderwidth 1 -relief flat
         label $This.acqred.y1.labelY1 -text $caption(acqfen,y1) -padx 5
         pack $This.acqred.y1.labelY1 -fill none -side left
         entry $This.acqred.y1.entryY1 -textvariable panneau(acqfen,Y1) -width 8 -relief groove \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100000 }
         pack $This.acqred.y1.entryY1 -fill none -side left
      pack $This.acqred.y1 -fill none -side top
      frame $This.acqred.x2 -borderwidth 1 -relief flat
         label $This.acqred.x2.labelX2 -text $caption(acqfen,x2) -padx 5
         pack $This.acqred.x2.labelX2 -fill none -side left
         entry $This.acqred.x2.entryX2 -textvariable panneau(acqfen,X2) -width 8 -relief groove \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100000 }
         pack $This.acqred.x2.entryX2 -fill none -side left
      pack $This.acqred.x2 -fill none -side top
      frame $This.acqred.y2 -borderwidth 1 -relief flat
         label $This.acqred.y2.labelY2 -text $caption(acqfen,y2) -padx 5
         pack $This.acqred.y2.labelY2 -fill none -side left
         entry $This.acqred.y2.entryY2 -textvariable panneau(acqfen,Y2) -width 8 -relief groove \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100000 }
         pack $This.acqred.y2.entryY2 -fill none -side left
      pack $This.acqred.y2 -fill none -side top

      #--- Bouton Go/Stop
      button $This.acqred.but -text $caption(acqfen,actuxy) -borderwidth 3 -command ::acqfen::actualiserCoordonnees
      pack $This.acqred.but -expand true -fill both

   #--- Trame du mode d'acquisition
   frame $This.mode -borderwidth 2 -relief groove

      #--- Trame du mode d'acquisition
      set panneau(acqfen,mode_en_cours) [ lindex $panneau(acqfen,list_mode) [ expr $panneau(acqfen,mode) - 1 ] ]
      ComboBox $This.mode.but \
         -width 15         \
         -height [llength $panneau(acqfen,list_mode)] \
         -relief raised    \
         -borderwidth 1    \
         -editable 0       \
         -takefocus 1      \
         -justify center   \
         -textvariable panneau(acqfen,mode_en_cours) \
         -values $panneau(acqfen,list_mode) \
         -modifycmd "::acqfen::ChangeMode"
      pack $This.mode.but -side top -fill x

      #--- Definition du sous-panneau "Mode: Une seule image"
      frame $This.mode.une -borderwidth 0

         frame $This.mode.une.nom -relief ridge -borderwidth 2
            label $This.mode.une.nom.but -text $caption(acqfen,nom) -pady 0
            pack $This.mode.une.nom.but -fill x -side top
            entry $This.mode.une.nom.entr -width 10 -textvariable panneau(acqfen,nom_image) \
               -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $This.mode.une.nom.entr -fill x -side top
         pack $This.mode.une.nom -expand true -fill both
         frame $This.mode.une.index -relief ridge -borderwidth 2
            checkbutton $This.mode.une.index.case -pady 0 -text $caption(acqfen,index)\
               -variable panneau(acqfen,indexer)
            pack $This.mode.une.index.case -expand true -fill both
            entry $This.mode.une.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $This.mode.une.index.entr -side left -fill x -expand true
            button $This.mode.une.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.une.index.but -side right -fill x
         pack $This.mode.une.index -expand true -fill both
         button $This.mode.une.sauve -text $caption(acqfen,sauvegde) -command ::acqfen::sauveUneImage
         pack $This.mode.une.sauve -expand true -fill both

      #--- Definition du sous-panneau "Mode: Serie d'image"
      frame $This.mode.serie -borderwidth 0
         frame $This.mode.serie.nom -relief ridge -borderwidth 2
            label $This.mode.serie.nom.but -text $caption(acqfen,nom) -pady 0
            pack $This.mode.serie.nom.but -fill x
            entry $This.mode.serie.nom.entr -width 10 -textvariable panneau(acqfen,nom_image) \
               -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $This.mode.serie.nom.entr -fill x
         pack $This.mode.serie.nom -expand true -fill both
         frame $This.mode.serie.nb -relief ridge -borderwidth 2
            label $This.mode.serie.nb.but -text $caption(acqfen,nombre) -pady 0
            pack $This.mode.serie.nb.but -side left -fill y
            entry $This.mode.serie.nb.entr -width 3 -textvariable panneau(acqfen,nb_images) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $This.mode.serie.nb.entr -side left -fill x -expand true
         pack $This.mode.serie.nb -expand true -fill both
         frame $This.mode.serie.index -relief ridge -borderwidth 2
            label $This.mode.serie.index.lab -text $caption(acqfen,index) -pady 0
            pack $This.mode.serie.index.lab -expand true -fill both
            entry $This.mode.serie.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $This.mode.serie.index.entr -side left -fill x -expand true
            button $This.mode.serie.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.serie.index.but -side right -fill x
         pack $This.mode.serie.index -expand true -fill both

      #--- Definition du sous-panneau "Mode: Continu"
      frame $This.mode.continu -borderwidth 0
         frame $This.mode.continu.sauve -relief ridge -borderwidth 2
            checkbutton $This.mode.continu.sauve.case -text $caption(acqfen,enregistrer) \
               -variable panneau(acqfen,enregistrer)
            pack $This.mode.continu.sauve.case -side left -fill x  -expand true
         pack $This.mode.continu.sauve -expand true -fill both
         frame $This.mode.continu.nom -relief ridge -borderwidth 2
            label $This.mode.continu.nom.but -text $caption(acqfen,nom) -pady 0
            pack $This.mode.continu.nom.but -fill x
            entry $This.mode.continu.nom.entr -width 10 -textvariable panneau(acqfen,nom_image) \
               -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $This.mode.continu.nom.entr -fill x
         pack $This.mode.continu.nom -expand true -fill both
         frame $This.mode.continu.index -relief ridge -borderwidth 2
            label $This.mode.continu.index.lab -text $caption(acqfen,index) -pady 0
            pack $This.mode.continu.index.lab -expand true -fill both
            entry $This.mode.continu.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $This.mode.continu.index.entr -side left -fill x -expand true
            button $This.mode.continu.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.continu.index.but -side right -fill x
         pack $This.mode.continu.index -expand true -fill both

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $This.mode.avancement_acq -borderwidth 2 -relief ridge
        #--- Checkbutton pour l'affichage de l'avancement de l'acqusition
        checkbutton $This.mode.avancement_acq.check -highlightthickness 0 \
           -text $caption(acqfen,avancement_acq) -variable panneau(acqfen,avancement_acq)
        pack $This.mode.avancement_acq.check -side left -fill x
     pack $This.mode.avancement_acq -side bottom -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#---Procedure d'affichage de la fenetre de reglages acquisition serie et continu
proc creeFenReglFen { this } {
   global audace caption conf panneau

   set This $this.fenreglfen

   if { ! [ info exists conf(fenreglfen,position) ] } { set conf(fenreglfen,position) "+0+0" }

   set panneau(acqfen,position) $conf(fenreglfen,position)

   if { [ info exists panneau(acqfen,geometry) ] } {
      set deb [ expr 1 + [ string first + $panneau(acqfen,geometry) ] ]
      set fin [ string length $panneau(acqfen,geometry) ]
      set panneau(acqfen,position) "+[string range $panneau(acqfen,geometry) $deb $fin]"
   }

   if {[winfo exists $This] == 0} {
      #--- Creation de la fenetre
      toplevel $This
      wm geometry $This 400x480$panneau(acqfen,position)
      wm title $This $caption(acqfen,fenreglfen)
      wm protocol $This WM_DELETE_WINDOW "::acqfen::quitFenReglFen $This"

      #--- Enregistrement des reglages courants
      set panneau(acqfen,oldfenreglfen1)  $panneau(acqfen,fenreglfen1)
      set panneau(acqfen,oldfenreglfen12) $panneau(acqfen,fenreglfen12)
      set panneau(acqfen,oldfenreglfen2)  $panneau(acqfen,fenreglfen2)
      set panneau(acqfen,oldfenreglfen22) $panneau(acqfen,fenreglfen22)
      set panneau(acqfen,oldfenreglfen3)  $panneau(acqfen,fenreglfen3)
      set panneau(acqfen,oldfenreglfen4)  $panneau(acqfen,fenreglfen4)

      #--- Frame pour l'en-tete FITS
      frame $This.setup -borderwidth 0 -relief raise

         #--- Label de l'en-tete FITS
         label $This.setup.lab -text "$caption(acqfen,en-tete_fits)"
         pack $This.setup.lab -side left -padx 6

         #--- Bouton d'acces aux mots cles
         button $This.setup.but1 -text "$caption(acqfen,mots_cles)" \
            -command "::keyword::run $audace(visuNo) ::conf(acqfen,keywordConfigName)"
         pack $This.setup.but1 -side left -padx 6 -pady 10 -ipadx 20

         #--- Label du nom de la configuration de l'en-tete FITS
         entry $This.setup.labNom \
            -state readonly -takefocus 0 -textvariable ::conf(acqfen,keywordConfigName) -justify center
         pack $This.setup.labNom -side left -padx 6

      pack $This.setup -side top -fill both -expand 1

      #--- Trame reglages
      frame $This.1
      pack $This.1 -expand true -fill x
      label $This.1.lab -text $caption(acqfen,fenreglfen1)
      pack $This.1.lab
      frame $This.1.1
      pack $This.1.1 -expand true -fill x
      radiobutton $This.1.1.but -text $caption(acqfen,fenreglfen11) \
         -variable panneau(acqfen,fenreglfen1) -value 1
      pack $This.1.1.but -side left
      frame $This.1.2
      pack $This.1.2 -expand true -fill x
      radiobutton $This.1.2.but -text $caption(acqfen,fenreglfen12) \
         -variable panneau(acqfen,fenreglfen1) -value 2
      pack $This.1.2.but -side left
      entry $This.1.2.ent -textvariable panneau(acqfen,fenreglfen12) \
         -width 10 -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 9999 }
      pack $This.1.2.ent -side left
      frame $This.2
      pack $This.2 -expand true -fill x
      label $This.2.lab -text $caption(acqfen,fenreglfen2)
      pack $This.2.lab
      frame $This.2.1
      pack $This.2.1 -expand true -fill x
      radiobutton $This.2.1.but -text $caption(acqfen,fenreglfen21) \
         -variable panneau(acqfen,fenreglfen2) -value 1
      pack $This.2.1.but -side left
      frame $This.2.2
      pack $This.2.2 -expand true -fill x
      radiobutton $This.2.2.but -text $caption(acqfen,fenreglfen22) \
         -variable panneau(acqfen,fenreglfen2) -value 2
      pack $This.2.2.but -side left
      entry $This.2.2.ent -textvariable panneau(acqfen,fenreglfen22) \
         -width 10 -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 2 9999 }
      pack $This.2.2.ent -side left
      frame $This.2.3
      pack $This.2.3 -expand true -fill x
      radiobutton $This.2.3.but -text $caption(acqfen,fenreglfen23) \
         -variable panneau(acqfen,fenreglfen2) -value 3
      pack $This.2.3.but -side left
      frame $This.3
      pack $This.3 -expand true -fill x
      label $This.3.lab -text $caption(acqfen,fenreglfen3)
      pack $This.3.lab
      frame $This.3.1
      pack $This.3.1 -expand true -fill x
      radiobutton $This.3.1.but -text $caption(acqfen,fenreglfen31) \
         -variable panneau(acqfen,fenreglfen3) -value 1
      pack $This.3.1.but -side left
      frame $This.3.2
      pack $This.3.2 -expand true -fill x
      radiobutton $This.3.2.but -text $caption(acqfen,fenreglfen32) \
         -variable panneau(acqfen,fenreglfen3) -value 2
      pack $This.3.2.but -side left
      frame $This.4
      pack $This.4 -expand true -fill x
      label $This.4.lab -text $caption(acqfen,fenreglfen4)
      pack $This.4.lab
      frame $This.4.1
      pack $This.4.1 -expand true -fill x
      radiobutton $This.4.1.but -text $caption(acqfen,fenreglfen41) \
        -variable panneau(acqfen,fenreglfen4) -value 1
      pack $This.4.1.but -side left
      frame $This.4.2
      pack $This.4.2 -expand true -fill x
      radiobutton $This.4.2.but -text $caption(acqfen,fenreglfen42) \
         -variable panneau(acqfen,fenreglfen4) -value 2
      pack $This.4.2.but -side left
      frame $This.5
      pack $This.5 -expand true -fill x
      label $This.5.lab -text $caption(acqfen,fenreglfen5)
      pack $This.5.lab
      frame $This.5.1
      pack $This.5.1 -expand true -fill x
      checkbutton $This.5.1.check -text $caption(acqfen,fenreglfen51) \
         -variable panneau(acqfen,fenreglfen5)
      pack $This.5.1.check -side left
      frame $This.6
      pack $This.6 -expand true -fill x
      label $This.6.lab -text $caption(acqfen,fenreglfen6)
      pack $This.6.lab
      frame $This.6.1
      pack $This.6.1 -expand true -fill x
      checkbutton $This.6.1.check -text $caption(acqfen,fenreglfen61) \
         -variable panneau(acqfen,verifier_ecraser_fichier)
      pack $This.6.1.check -side left
      frame $This.6.2
      pack $This.6.2 -expand true -fill x
      checkbutton $This.6.2.check -text $caption(acqfen,fenreglfen62) \
         -variable panneau(acqfen,verifier_index_depart)
      pack $This.6.2.check -side left

      #--- Sous-trame boutons OK & quitter
      frame $This.buttons
      pack $This.buttons
      button $This.buttons.ok -text $caption(acqfen,ok) -width 19 \
         -command "
            ::acqfen::enregistrerParametres
            ::acqfen::recupPosition $This
            set conf(fenreglfen,position) $panneau(acqfen,position)
            destroy $This
         "
      pack $This.buttons.ok -side left -expand true -padx 10 -pady 10
      button $This.buttons.quit -command "::acqfen::quitFenReglFen $This" \
         -text $caption(acqfen,quitter) -width 19
      pack $This.buttons.quit -side left -expand true -padx 10 -pady 10

      #--- Focus
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   } else {
      focus $This
   }
}

