#
# Fichier : acqvideo.tcl
# Description : Outil d'acquisition video
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise à jour $Id: acqvideo.tcl 12688 2016-01-16 18:53:20Z robertdelmas $
#

#==============================================================
#   Declaration du namespace acqvideo
#==============================================================

namespace eval ::acqvideo {
   package provide acqvideo 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] acqvideo.cap ]

#***** Procedure createPluginInstance***************************
   proc createPluginInstance { base { visuNo 1 } } {
      variable parametres
      global audace caption conf panneau

      #--- Chargement des fichiers auxiliaires
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqvideo acqvideoSetup.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqvideo dlgshiftvideo.tcl ]\""

      #---
      set panneau(acqvideo,$visuNo,base) "$base"
      set panneau(acqvideo,$visuNo,This) "$base.acqvideo"

      #---
      set panneau(acqvideo,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
      set panneau(acqvideo,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqvideo,$visuNo,camItem)]

      #--- Recuperation de la derniere configuration de l'outil
      ::acqvideo::chargerVariable $visuNo

      #--- Initialisation des variables de la boite de configuration
      ::acqvideoSetup::confToWidget $visuNo

      #--- Initialisation des variables de la boite de decalage du telescope
      ::DlgShiftVideo::confToWidget $visuNo

      #--- Initialisation de la variable conf()
      if { ! [info exists conf(acqvideo,avancement,position)] } { set conf(acqvideo,avancement,position) "+120+315" }

      #--- Initialisation de variables
      set panneau(acqvideo,$visuNo,simulation)            "0"
      set panneau(acqvideo,$visuNo,simulation_deja_faite) "0"
      set panneau(acqvideo,$visuNo,avancement,position)   "$conf(acqvideo,avancement,position)"

      #--- Entrer ici les valeurs de temps de pose a afficher dans le menu "pose"
      set panneau(acqvideo,$visuNo,temps_pose) { 0 0.1 0.3 0.5 1 2 3 5 10 15 20 30 60 90 120 180 300 600 }

      #--- Liste des modes disponibles
      set panneau(acqvideo,$visuNo,list_mode) [ list $caption(acqvideo,video) $caption(acqvideo,video1) ]

      #--- Initialisation des modes
      set panneau(acqvideo,$visuNo,mode,1) "$panneau(acqvideo,$visuNo,This).mode.video"
      set panneau(acqvideo,$visuNo,mode,2) "$panneau(acqvideo,$visuNo,This).mode.video_1"
      #--- Mode par defaut : Video
      if { ! [ info exists panneau(acqvideo,$visuNo,mode) ] } {
         set panneau(acqvideo,$visuNo,mode) "$parametres(acqvideo,$visuNo,mode)"
      }

      #--- Initialisation de variables
      set panneau(acqvideo,$visuNo,go_stop)           "go"
      set panneau(acqvideo,$visuNo,nom_image)         ""
      set panneau(acqvideo,$visuNo,indexer)           "0"
      set panneau(acqvideo,$visuNo,index)             "1"
      set panneau(acqvideo,$visuNo,session_ouverture) "1"
      set panneau(acqvideo,$visuNo,avancement_acq)    "$parametres(acqvideo,$visuNo,avancement_acq)"
      set panneau(acqvideo,$visuNo,intervalle_video)  ""

      #--- Initialisation de variables pour l'acquisition video fenetree
      set panneau(acqvideo,$visuNo,fenetre)           "0"
      set panneau(acqvideo,$visuNo,largeur)           ""
      set panneau(acqvideo,$visuNo,hauteur)           ""
      set panneau(acqvideo,$visuNo,x1)                "$parametres(acqvideo,$visuNo,x1)"
      set panneau(acqvideo,$visuNo,y1)                "$parametres(acqvideo,$visuNo,y1)"
      set panneau(acqvideo,$visuNo,x2)                "$parametres(acqvideo,$visuNo,x2)"
      set panneau(acqvideo,$visuNo,y2)                "$parametres(acqvideo,$visuNo,y2)"

      #--- Initialisation pour le mode video
      set panneau(acqvideo,$visuNo,showvideopreview)  "0"
      set panneau(acqvideo,$visuNo,ratelist)          { 5 10 15 20 25 30 }
      set panneau(acqvideo,$visuNo,status)            "                              "

      #--- Frequence images par defaut : 5 images/sec.
      if { ! [ info exists panneau(acqvideo,$visuNo,rate) ] } {
         set panneau(acqvideo,$visuNo,rate) "$parametres(acqvideo,$visuNo,rate)"
      }

      #--- Duree du film par defaut : 10s
      if { ! [ info exists panneau(acqvideo,$visuNo,lg_film) ] } {
         set panneau(acqvideo,$visuNo,lg_film) "$parametres(acqvideo,$visuNo,lg_film)"
      }

      #--- Mise en place de l'interface graphique
      acqvideoBuildIF $visuNo

      pack $panneau(acqvideo,$visuNo,mode,$panneau(acqvideo,$visuNo,mode)) -anchor nw -fill x

      #--- Surveillance de la connexion d'une camera
      ::confVisu::addCameraListener $visuNo "::acqvideo::adaptOutilAcqVideo $visuNo"

      #---
      return $panneau(acqvideo,$visuNo,This)
   }
#***** Fin de la procedure createPluginInstance*****************

   #------------------------------------------------------------
   #  deletePluginInstance
   #     suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {
      global conf panneau

      #--- Je desactive la surveillance de la connexion d'une camera
      ::confVisu::removeCameraListener $visuNo "::acqvideo::adaptOutilAcqVideo $visuNo"

      #---
      set conf(acqvideo,avancement,position) $panneau(acqvideo,$visuNo,avancement,position)

      #---
      destroy $panneau(acqvideo,$visuNo,This)
      destroy $panneau(acqvideo,$visuNo,base).status_video.pose.but.menu
      destroy $panneau(acqvideo,$visuNo,base).status_video.rate.cb.menu
   }

   #------------------------------------------------------------
   #  getPluginProperty
   #     retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "acquisition" }
         subfunction1 { return "video" }
         display      { return "panel" }
         multivisu    { return 1 }
      }
   }

   #------------------------------------------------------------
   #  getPluginTitle
   #     retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(acqvideo,titre)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "acqvideo.htm"
   }

   #------------------------------------------------------------
   #  getPluginType
   #     retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   #  getPluginDirectory
   #     retourne le nom du repertoire du plugin
   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "acqvideo"
   }

   #------------------------------------------------------------
   #  getPluginOS
   #     retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Darwin ]
   }

#***** Procedure demarrageAcqVideo *****************************
   proc demarrageAcqVideo { visuNo } {
      global audace caption

      #--- Creation du sous-repertoire a la date du jour
      #--- en mode automatique s'il n'existe pas
      ::cwdWindow::updateImageDirectory

      #--- Gestion du fichier de log
      #--- Creation du nom du fichier log
      set nom_generique "acqvideo-visu$visuNo-"
      #--- Heure a partir de laquelle on passe sur un nouveau fichier de log
      if { $::conf(rep_images,refModeAuto) == "0" } {
         set heure_nouveau_fichier "0"
      } else {
         set heure_nouveau_fichier "12"
      }
      set heure_courante [lindex [split $audace(tu,format,hmsint) h] 0]
      if { $heure_courante < $heure_nouveau_fichier } {
         #--- Si avant l'heure de changement, je prends la date de la veille
         set formatdate [clock format [expr {[clock seconds] - 86400}] -format "%Y-%m-%d"]
      } else {
         #--- Sinon, je prends la date du jour
         set formatdate [clock format [clock seconds] -format "%Y-%m-%d"]
      }
      set file_log ""
      set ::acqvideo::fichier_log [ file join $audace(rep_images) [ append $file_log $nom_generique $formatdate ".log" ] ]

      #--- Ouverture du fichier de log
      if { [ catch { open $::acqvideo::fichier_log a } ::acqvideo::log_id($visuNo) ] } {
         Message $visuNo console $caption(acqvideo,pbouvfichcons)
         tk_messageBox -title $caption(acqvideo,pb) -type ok \
            -message $caption(acqvideo,pbouvfich)
         #--- Note importante : Je detecte si j'ai un pb a l'ouverture du fichier, mais je ne sais pas traiter ce cas :
         #--- Il faudrait interdire l'ouverture de l'outil, mais le processus est deja lance a ce stade...
         #--- Tout ce que je fais, c'est inviter l'utilisateur a changer d'outil !
      } else {
         #--- En-tete du fichier
         Message $visuNo log $caption(acqvideo,ouvsess) [ package version acqvideo ]
         set date [clock format [clock seconds] -format "%A %d %B %Y"]
         set date [ ::tkutil::transalteDate $date ]
         set heure $audace(tu,format,hmsint)
         Message $visuNo consolog $caption(acqvideo,affheure) $date $heure
         #--- Definition du binding pour declencher l'acquisition (ou l'arret) par Echap.
         bind all <Key-Escape> "::acqvideo::goStop $visuNo"
      }
   }
#***** Fin de la procedure demarrageAcqVideo *******************

#***** Procedure arretAcqVideo *********************************
   proc arretAcqVideo { visuNo } {
      global audace caption panneau

      #--- Fermeture du fichier de log
      if { [ info exists ::acqvideo::log_id($visuNo) ] } {
         set heure $audace(tu,format,hmsint)
         #--- Je m'assure que le fichier se termine correctement, en particulier pour le cas ou il y
         #--- a eu un probleme a l'ouverture (c'est un peu une rustine...)
         if { [ catch { Message $visuNo log $caption(acqvideo,finsess) $heure } bug ] } {
            Message $visuNo console $caption(acqvideo,pbfermfichcons)
         } else {
            Message $visuNo console "\n"
            close $::acqvideo::log_id($visuNo)
            unset ::acqvideo::log_id($visuNo)
         }
      }
      #--- Re-initialisation de la session
      set panneau(acqvideo,$visuNo,session_ouverture) "1"
      #--- Desactivation du binding pour declencher l'acquisition (ou l'arret) par Echap.
      bind all <Key-Escape> { }
   }
#***** Fin de la procedure arretAcqVideo ***********************

#***** Procedure adaptOutilAcqVideo ****************************
   proc adaptOutilAcqVideo { visuNo args } {
      global panneau

      set panneau(acqvideo,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
      set panneau(acqvideo,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqvideo,$visuNo,camItem)]

      #--- Decoche le checkbutton Apercu des modes Video
      set panneau(acqvideo,$visuNo,showvideopreview) "0"
      #---
      set camNo $panneau(acqvideo,$visuNo,camNo)
      if { $camNo == "0" } {
         #--- La camera n'a pas ete encore selectionnee
         set camProduct ""
      } else {
         set camProduct [ cam$camNo product ]
      }
      #---
      if { "$camProduct" == "webcam" } {
         #--- C'est une WebCam
         pack $panneau(acqvideo,$visuNo,This).pose.conf -fill x -expand true -ipady 3
      } else {
         #--- Ce n'est pas une WebCam
         pack forget $panneau(acqvideo,$visuNo,This).pose.conf
      }

      if { [::confCam::getPluginProperty $panneau(acqvideo,$visuNo,camItem) "hasVideo"] == 1 } {
         if { [ ::confVisu::getTool $visuNo ] == "acqvideo" } {
            set panneau(acqvideo,$visuNo,showvideopreview) 1
            changerVideoPreview $visuNo
            #--- Creation des fenetres auxiliaires
            ::acqvideo::selectVideoMode $visuNo
         }
      } elseif { [ winfo exists $panneau(acqvideo,$visuNo,base).status_video ] } {
         destroy $panneau(acqvideo,$visuNo,base).status_video
      }

   }
#***** Fin de la procedure adaptOutilAcqVideo ******************

#***** Procedure chargerVariable *******************************
   proc chargerVariable { visuNo } {
      variable parametres

      #--- Ouverture du fichier de parametres
      set fichier [ file join $::audace(rep_home) acqvideo.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }

      #--- Creation des variables si elles n'existent pas
      if { ! [ info exists parametres(acqvideo,$visuNo,mode) ] }           { set parametres(acqvideo,$visuNo,mode)    "1" }   ; #--- Mode : Video
      if { ! [ info exists parametres(acqvideo,$visuNo,lg_film) ] }        { set parametres(acqvideo,$visuNo,lg_film) "10" }  ; #--- Duree de la video : 10s
      if { ! [ info exists parametres(acqvideo,$visuNo,rate) ] }           { set parametres(acqvideo,$visuNo,rate)    "5" }   ; #--- Images/sec. : 5
      if { ! [ info exists parametres(acqvideo,$visuNo,x1) ] }             { set parametres(acqvideo,$visuNo,x1)      "100" } ; #--- Video fenetree : x1
      if { ! [ info exists parametres(acqvideo,$visuNo,y1) ] }             { set parametres(acqvideo,$visuNo,y1)      "100" } ; #--- Video fenetree : y1
      if { ! [ info exists parametres(acqvideo,$visuNo,x2) ] }             { set parametres(acqvideo,$visuNo,x2)      "350" } ; #--- Video fenetree : x2
      if { ! [ info exists parametres(acqvideo,$visuNo,y2) ] }             { set parametres(acqvideo,$visuNo,y2)      "250" } ; #--- Video fenetree : y2
      if { ! [ info exists parametres(acqvideo,$visuNo,avancement_acq) ] } {
         if { $visuNo == "1" } {
            set parametres(acqvideo,$visuNo,avancement_acq) "1" ; #--- Barre de progression de la pose : Oui
         } else {
            set parametres(acqvideo,$visuNo,avancement_acq) "0" ; #--- Barre de progression de la pose : Non
         }
      }

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      ::acqvideoSetup::initToConf $visuNo

      #--- Creation des variables de la boite de decalage du telescope si elles n'existent pas
      ::DlgShiftVideo::initToConf $visuNo
   }
#***** Fin de la procedure chargerVariable *********************

#***** Procedure enregistrerVariable ***************************
   proc enregistrerVariable { visuNo } {
      variable parametres
      global panneau

      #---
      set panneau(acqvideo,$visuNo,mode)              [ expr [ lsearch "$panneau(acqvideo,$visuNo,list_mode)" "$panneau(acqvideo,$visuNo,mode_en_cours)" ] + 1 ]
      #---
      set parametres(acqvideo,$visuNo,mode)           $panneau(acqvideo,$visuNo,mode)
      set parametres(acqvideo,$visuNo,lg_film)        $panneau(acqvideo,$visuNo,lg_film)
      set parametres(acqvideo,$visuNo,rate)           $panneau(acqvideo,$visuNo,rate)
      set parametres(acqvideo,$visuNo,x1)             $panneau(acqvideo,$visuNo,x1)
      set parametres(acqvideo,$visuNo,y1)             $panneau(acqvideo,$visuNo,y1)
      set parametres(acqvideo,$visuNo,x2)             $panneau(acqvideo,$visuNo,x2)
      set parametres(acqvideo,$visuNo,y2)             $panneau(acqvideo,$visuNo,y2)
      set parametres(acqvideo,$visuNo,avancement_acq) $panneau(acqvideo,$visuNo,avancement_acq)
      #--- Sauvegarde des parametres
      catch {
        set nom_fichier [ file join $::audace(rep_home) acqvideo.ini ]
        if [ catch { open $nom_fichier w } fichier ] {
           #---
        } else {
           foreach { a b } [ array get parametres ] {
              puts $fichier "set parametres($a) \"$b\""
           }
           close $fichier
        }
      }
   }
#***** Fin de la procedure enregistrerVariable *****************

#***** Procedure startTool *************************************
   proc startTool { { visuNo 1 } } {
      global panneau

      #--- J'active le preview
      if { [::confCam::isReady $panneau(acqvideo,$visuNo,camItem)] == 1 } {

         #--- je mets a jour les widgets de l'outil
         ::acqvideo::adaptOutilAcqVideo $visuNo

         if { [::confCam::getPluginProperty $panneau(acqvideo,$visuNo,camItem) "hasVideo"] == 1 } {
            if { $panneau(acqvideo,$visuNo,showvideopreview) == 0 } {
               set panneau(acqvideo,$visuNo,showvideopreview) 1
               changerVideoPreview $visuNo
            }
            #--- Creation des fenetres auxiliaires
            ::acqvideo::selectVideoMode $visuNo
         }

      } else {

         #--- je mets a jour les widgets de l'outil
         ::acqvideo::adaptOutilAcqVideo $visuNo

      }
   }

#***** Fin de la procedure startTool ***************************

#***** Procedure stopTool **************************************
   proc stopTool { { visuNo 1 } } {
      global panneau

      #--- Sauvegarde de la configuration de prise de vue
      ::acqvideo::enregistrerVariable $visuNo

      #--- Recuperation de la position de la fenetre
      ::acqvideo::recupPosition $visuNo

      #--- Arret de l'aprecu video s'il est en action
      if { [ ::confVisu::getCamItem $visuNo ] != "" && $panneau(acqvideo,$visuNo,showvideopreview) == "1" } {
         stopVideoPreview $visuNo
      }

      #---
      arretAcqVideo $visuNo
   }
#***** Fin de la procedure stopTool ****************************

#***** Procedure de changement du mode d'acquisition ***********
   proc changerMode { visuNo } {
      global panneau

      pack forget $panneau(acqvideo,$visuNo,mode,$panneau(acqvideo,$visuNo,mode)) -anchor nw -fill x

      set panneau(acqvideo,$visuNo,mode) [ expr [ lsearch "$panneau(acqvideo,$visuNo,list_mode)" "$panneau(acqvideo,$visuNo,mode_en_cours)" ] + 1 ]
      if { [::confCam::getPluginProperty $panneau(acqvideo,$visuNo,camItem) "hasVideo"] == 1 } {
         ::acqvideo::selectVideoMode $visuNo
      }
      pack $panneau(acqvideo,$visuNo,mode,$panneau(acqvideo,$visuNo,mode)) -anchor nw -fill x
   }
#***** Fin de la procedure de changement du mode d'acquisition *

#***** Procedure Go/Stop (appui sur le bouton Go/Stop) *********
   proc goStop { visuNo } {
      global audace caption panneau

      set camItem [::confVisu::getCamItem $visuNo]

      switch $panneau(acqvideo,$visuNo,go_stop) {
         go {
            #--- Desactive le bouton Go, pour eviter un double appui
            $panneau(acqvideo,$visuNo,This).go_stop.but configure -state disabled

            #--- Tests generaux de l'integrite de la requete
            set integre    "oui"
            set existeDeja "non"

            #--- Verifier si une camera est selectionnee
            if { [ ::confVisu::getCamItem $visuNo ] == "" } {
               ::audace::menustate disabled
               set choix [ tk_messageBox -title $caption(acqvideo,pb) -type ok \
                  -message $caption(acqvideo,selcam) ]
               set integre non
               if { $choix == "ok" } {
                  #--- Ouverture de la fenetre de selection des cameras
                  ::confCam::run
               }
               ::audace::menustate normal
            }

            #--- Tests d'integrite specifiques a chaque mode d'acquisition
            if { $integre == "oui" } {

               #--- Verifier qu'il s'agit d'une WebCam
               if { [::confCam::getPluginProperty $camItem "hasVideo"] != 1 } {
                  set choix [ tk_messageBox -title $caption(acqvideo,pb) -type ok \
                     -message "$caption(acqvideo,pb_camera1) [::confCam::getPluginProperty $camItem "name"] $caption(acqvideo,pb_camera2)" ]
                  set integre non
                  if { $choix == "ok" } {
                     #--- Ouverture de la fenetre de selection des cameras
                     ::confCam::run
                  }
               #--- Verifier qu'il y a un nom de fichier
               } elseif { $panneau(acqvideo,$visuNo,nom_image) == "" } {
                  tk_messageBox -title $caption(acqvideo,pb) -type ok \
                     -message $caption(acqvideo,donnomfich)
                  set integre non
               #--- Verifier que le nom de fichier n'a pas d'espace
               } elseif { [ llength $panneau(acqvideo,$visuNo,nom_image) ] > "1" } {
                  tk_messageBox -title $caption(acqvideo,pb) -type ok \
                     -message $caption(acqvideo,nomblanc)
                  set integre non
               }

               #--- Branchement selon le mode de prise de video
               switch $panneau(acqvideo,$visuNo,mode) {
                  1  {
                     #--- Mode Video
                     #--- Verifications liees a la presence de l'indice
                     if { $panneau(acqvideo,$visuNo,indexer) == "1" } {
                        #--- Verifier que l'index existe
                        if { $panneau(acqvideo,$visuNo,index) == "" } {
                           tk_messageBox -title $caption(acqvideo,pb) -type ok \
                               -message $caption(acqvideo,saisind)
                           set integre non
                        #--- Envoyer un warning si l'index n'est pas a 1
                        } elseif { $panneau(acqvideo,$visuNo,index) != "1" } {
                           set confirmation [tk_messageBox -title $caption(acqvideo,conf) -type yesno \
                              -message $caption(acqvideo,indpasun)]
                           if { $confirmation == "no" } {
                              set integre non
                           }
                        }
                     }
                  }
                  2  {
                     #--- Mode Videos espacees
                     if { $integre == "oui" } {
                        #--- Verifier que l'index existe
                        if { $panneau(acqvideo,$visuNo,index) == "" } {
                           tk_messageBox -title $caption(acqvideo,pb) -type ok \
                               -message $caption(acqvideo,saisind)
                           set integre non
                        #--- Envoyer un warning si l'index n'est pas a 1
                        } elseif { $panneau(acqvideo,$visuNo,index) != "1" } {
                           set confirmation [tk_messageBox -title $caption(acqvideo,conf) -type yesno \
                              -message $caption(acqvideo,indpasun)]
                           if { $confirmation == "no" } {
                              set integre non
                           }
                        #--- Verifier que l'intervalle est superieur a la duree du film
                        } elseif { $panneau(acqvideo,$visuNo,lg_film) > $panneau(acqvideo,$visuNo,intervalle_video) } {
                           tk_messageBox -title $caption(acqvideo,pb) -type ok \
                              -message $caption(acqvideo,interinv1)
                           set integre non
                        }
                     }
                  }
               }

            }
            #--- Fin des tests d'integrite de la requete

            #--- Apres les tests d'integrite, je reactive le bouton "GO"
            $panneau(acqvideo,$visuNo,This).go_stop.but configure -state normal

            #--- Apres tous les tests d'integrite, je peux maintenant lancer les acquisitions
            if { $integre == "oui" } {

                #--- Ouverture du fichier historique
                if { $panneau(acqvideo,$visuNo,save_file_log) == "1" } {
                   if { $panneau(acqvideo,$visuNo,session_ouverture) == "1" } {
                      demarrageAcqVideo $visuNo
                      set panneau(acqvideo,$visuNo,session_ouverture) "0"
                   }
                }

               #--- Modification du bouton, pour eviter un second lancement
               set panneau(acqvideo,$visuNo,go_stop) stop
               $panneau(acqvideo,$visuNo,This).go_stop.but configure -text $caption(acqvideo,stop)
               #--- Verrouille le bouton pendant les acquisitions
               $panneau(acqvideo,$visuNo,This).mode.but configure -state disabled
               #--- Desactive toute demande d'arret
               set panneau(acqvideo,$visuNo,demande_arret) "0"
               #--- Branchement selon le mode de prise de vue
               switch $panneau(acqvideo,$visuNo,mode) {
                  1  {
                     #--- Mode Video
                     #--- Pour eviter un nom de fichier qui commence par un blanc
                     set nom $panneau(acqvideo,$visuNo,nom_image)
                     set nom [lindex $nom 0]
                     if { $panneau(acqvideo,$visuNo,indexer) == "1" } {
                        set nom [append nom $panneau(acqvideo,$visuNo,index)]
                     }
                     set nom_rep [ file join $audace(rep_images) "$nom.avi" ]
                     #--- Verifier que le nom du fichier n'existe pas
                     if { [ file exists $nom_rep ] == "1" } {
                        #--- Dans ce cas, le fichier existe deja
                        set confirmation [tk_messageBox -title $caption(acqvideo,conf) -type yesno \
                           -message $caption(acqvideo,fichdeja)]
                        if { $confirmation == "no" } {
                           #--- Deverrouille le bouton pendant les acquisitions
                           $panneau(acqvideo,$visuNo,This).mode.but configure -state normal
                           #--- Je restitue l'affichage du bouton "GO"
                           set panneau(acqvideo,$visuNo,go_stop) go
                           $panneau(acqvideo,$visuNo,This).go_stop.but configure -text $caption(acqvideo,GO)
                           #--- J'autorise le bouton "GO"
                           $panneau(acqvideo,$visuNo,This).go_stop.but configure -state normal
                           #--- Je sors de la procedure
                           return
                        }
                     }
                     #--- Verrouille les widgets du mode "Video"
                     $panneau(acqvideo,$visuNo,This).mode.video.nom.entr configure -state disabled
                     $panneau(acqvideo,$visuNo,This).mode.video.index.case configure -state disabled
                     $panneau(acqvideo,$visuNo,This).mode.video.index.entr configure -state disabled
                     $panneau(acqvideo,$visuNo,This).mode.video.index.but configure -state disabled
                     $panneau(acqvideo,$visuNo,This).mode.video.show.case configure -state disabled
                     #--- Message
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqvideo,acqvideo) \
                        $panneau(acqvideo,$visuNo,lg_film) $panneau(acqvideo,$visuNo,rate) $heure
                     #--- Je positionne la fenetre video
                     if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
                        cam$panneau(acqvideo,$visuNo,camNo) setvideocroprect $panneau(acqvideo,$visuNo,x1) \
                           $panneau(acqvideo,$visuNo,y1) $panneau(acqvideo,$visuNo,x2) $panneau(acqvideo,$visuNo,y2)
                     }
                     #--- Je declare la variable qui sera mise a jour par le driver avec le decompte des frames
                     cam$panneau(acqvideo,$visuNo,camNo) setvideostatusvariable ::panneau(acqvideo,$visuNo,status)
                     set result [ catch { after idle [list cam$panneau(acqvideo,$visuNo,camNo) startvideocapture "$nom_rep" "$panneau(acqvideo,$visuNo,lg_film)" "$panneau(acqvideo,$visuNo,rate)" "1"] } msg ]
                     if { $result == "1" } {
                        #--- En cas d'erreur, j'affiche un message d'erreur
                        #--- Et je passe a la suite sans attendre
                        ::console::affiche_resultat "$caption(acqvideo,start_capture_error) $msg \n"
                     } else {
                        #--- J'attends la fin de l'acquisition
                        vwait ::status_cam$panneau(acqvideo,$visuNo,camNo)
                     }
                     #--- Incrementer l'index
                     if { $panneau(acqvideo,$visuNo,indexer) == "1" } {
                        incr panneau(acqvideo,$visuNo,index)
                     }
                     #--- Message
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqvideo,enrim_video) $heure $nom
                     #--- Deverrouille les widgets du mode "Video"
                     $panneau(acqvideo,$visuNo,This).mode.video.nom.entr configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video.index.case configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video.index.entr configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video.index.but configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video.show.case configure -state normal
                  }
                  2  {
                     #--- Mode Videos espacees
                     #--- Pour eviter un nom de fichier qui commence par un blanc
                     set nom $panneau(acqvideo,$visuNo,nom_image)
                     set nom [lindex $nom 0]
                     set nom [append nom $panneau(acqvideo,$visuNo,index)]
                     set nom_rep [ file join $audace(rep_images) "$nom.avi" ]
                     #--- Verifier que le nom du fichier n'existe pas
                     if { [ file exists $nom_rep ] == "1" } {
                        #--- Dans ce cas, le fichier existe deja
                        set confirmation [tk_messageBox -title $caption(acqvideo,conf) -type yesno \
                           -message $caption(acqvideo,fichdeja)]
                        if { $confirmation == "no" } {
                           #--- Deverrouille le bouton pendant les acquisitions
                           $panneau(acqvideo,$visuNo,This).mode.but configure -state normal
                           #--- Je restitue l'affichage du bouton "GO"
                           set panneau(acqvideo,$visuNo,go_stop) go
                           $panneau(acqvideo,$visuNo,This).go_stop.but configure -text $caption(acqvideo,GO)
                           #--- J'autorise le bouton "GO"
                           $panneau(acqvideo,$visuNo,This).go_stop.but configure -state normal
                           #--- Je sors de la procedure
                           return
                        } else {
                           set existeDeja "oui"
                        }
                     }
                     #--- Verrouille les widgets du mode "Videos espacees"
                     $panneau(acqvideo,$visuNo,This).mode.video_1.nom.entr configure -state disabled
                     $panneau(acqvideo,$visuNo,This).mode.video_1.index.entr configure -state disabled
                     $panneau(acqvideo,$visuNo,This).mode.video_1.index.but configure -state disabled
                     $panneau(acqvideo,$visuNo,This).mode.video_1.show.case configure -state disabled
                     #--- Message
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqvideo,acqvideo_cont) $panneau(acqvideo,$visuNo,intervalle_video) \
                        $panneau(acqvideo,$visuNo,lg_film) $panneau(acqvideo,$visuNo,rate) $heure
                     #--- Boucle des acquisitions
                     while { ( $panneau(acqvideo,$visuNo,demande_arret) == "0" ) && ( $panneau(acqvideo,$visuNo,mode) == "2" ) } {
                        set panneau(acqvideo,$visuNo,deb_video) [ clock second ]
                        #--- Pour eviter un nom de fichier qui commence par un blanc
                        set nom $panneau(acqvideo,$visuNo,nom_image)
                        set nom [lindex $nom 0]
                        set nom [append nom $panneau(acqvideo,$visuNo,index)]
                        set nom_rep [ file join $audace(rep_images) "$nom.avi" ]
                        #--- Verifier que le nom du fichier n'existe pas
                        if { $existeDeja == "non" } {
                           if { [ file exists $nom_rep ] == "1" } {
                              #--- Dans ce cas, le fichier existe deja
                              set confirmation [tk_messageBox -title $caption(acqvideo,conf) -type yesno \
                                 -message $caption(acqvideo,fichdeja)]
                              if { $confirmation == "no" } {
                                 #--- Deverrouille le bouton pendant les acquisitions
                                 $panneau(acqvideo,$visuNo,This).mode.but configure -state normal
                                 #--- Je restitue l'affichage du bouton "GO"
                                 set panneau(acqvideo,$visuNo,go_stop) go
                                 $panneau(acqvideo,$visuNo,This).go_stop.but configure -text $caption(acqvideo,GO)
                                 #--- J'autorise le bouton "GO"
                                 $panneau(acqvideo,$visuNo,This).go_stop.but configure -state normal
                                 #--- Message
                                 set heure $audace(tu,format,hmsint)
                                 Message $visuNo consolog $caption(acqvideo,arrcont1) $heure
                                 #--- Deverrouille les widgets du mode "Videos espacees"
                                 $panneau(acqvideo,$visuNo,This).mode.video_1.nom.entr configure -state normal
                                 $panneau(acqvideo,$visuNo,This).mode.video_1.index.entr configure -state normal
                                 $panneau(acqvideo,$visuNo,This).mode.video_1.index.but configure -state normal
                                 $panneau(acqvideo,$visuNo,This).mode.video_1.show.case configure -state normal
                                 #--- Je sors de la procedure
                                 return
                              }
                           }
                        } else {
                           set existeDeja "non"
                        }
                        #--- J'autorise le bouton "STOP"
                        $panneau(acqvideo,$visuNo,This).go_stop.but configure -state normal
                        #--- Je positionne la fenetre video
                        if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
                           cam$panneau(acqvideo,$visuNo,camNo) setvideocroprect $panneau(acqvideo,$visuNo,x1) \
                              $panneau(acqvideo,$visuNo,y1) $panneau(acqvideo,$visuNo,x2) $panneau(acqvideo,$visuNo,y2)
                        }
                        #--- Je declare la variable qui sera mise a jour par le driver avec le decompte des frames
                        cam$panneau(acqvideo,$visuNo,camNo) setvideostatusvariable ::panneau(acqvideo,$visuNo,status)
                        set result [ catch { after idle [cam$panneau(acqvideo,$visuNo,camNo) startvideocapture "$nom_rep" "$panneau(acqvideo,$visuNo,lg_film)" "$panneau(acqvideo,$visuNo,rate)" "1" ]} msg ]
                        if { $result == "1" } {
                           #--- En cas d'erreur, j'affiche un message d'erreur
                           #--- Et je passe a la suite sans attendre
                           ::console::affiche_resultat "$caption(acqvideo,start_capture_error) $msg \n"
                        } else {
                           #--- J'attends la fin de l'acquisition
                           vwait ::status_cam$panneau(acqvideo,$visuNo,camNo)
                           #--- Je desactive le bouton "STOP"
                           $panneau(acqvideo,$visuNo,This).go_stop.but configure -state disabled
                        }
                        #--- Incrementer l'index
                        incr panneau(acqvideo,$visuNo,index)
                        #--- Message
                        set heure $audace(tu,format,hmsint)
                        Message $visuNo consolog $caption(acqvideo,enrim_video1) $heure $nom
                        #--- Deplacement du telescope entre chaque acquisition
                        ::DlgShiftVideo::decalageTelescope
                        set panneau(acqvideo,$visuNo,fin_video) [ clock second ]
                        set panneau(acqvideo,$visuNo,intervalle_film) [ expr $panneau(acqvideo,$visuNo,fin_video) - $panneau(acqvideo,$visuNo,deb_video) ]
                        while { ( $panneau(acqvideo,$visuNo,demande_arret) == "0" ) && ( $panneau(acqvideo,$visuNo,intervalle_film) <= $panneau(acqvideo,$visuNo,intervalle_video) ) } {
                           after 500
                           set panneau(acqvideo,$visuNo,fin_video) [ clock second ]
                           set panneau(acqvideo,$visuNo,intervalle_film) [ expr $panneau(acqvideo,$visuNo,fin_video) - $panneau(acqvideo,$visuNo,deb_video) + 1 ]
                           set t [ expr $panneau(acqvideo,$visuNo,intervalle_video) - $panneau(acqvideo,$visuNo,intervalle_film) ]
                           ::acqvideo::avancementPose $visuNo $t
                        }
                     }
                     #--- Message
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqvideo,arrcont) $heure
                     Message $visuNo consolog $caption(acqvideo,dersauve_video) $nom
                     #--- Deverrouille les widgets du mode "Videos espacees"
                     $panneau(acqvideo,$visuNo,This).mode.video_1.nom.entr configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video_1.index.entr configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video_1.index.but configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video_1.show.case configure -state normal
                  }
               }
               #--- Deverrouille le bouton pendant les acquisitions
               $panneau(acqvideo,$visuNo,This).mode.but configure -state normal
               #--- Je restitue l'affichage du bouton "GO"
               set panneau(acqvideo,$visuNo,go_stop) go
              $panneau(acqvideo,$visuNo,This).go_stop.but configure -text $caption(acqvideo,GO)
               #--- J'autorise le bouton "GO"
               $panneau(acqvideo,$visuNo,This).go_stop.but configure -state normal
            }
         }
         stop {
            #--- Je desactive le bouton "STOP"
            $panneau(acqvideo,$visuNo,This).go_stop.but configure -state disabled
            #--- J'arrete l'acquisition
            arretImage $visuNo
            #--- Message suite a l'arret
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqvideo,arrprem) $heure
            switch $panneau(acqvideo,$visuNo,mode) {
               1  {
                     #--- Deverrouille les widgets du mode "Video"
                     $panneau(acqvideo,$visuNo,This).mode.video.nom.entr configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video.index.case configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video.index.entr configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video.index.but configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video.show.case configure -state normal
               }
               2  {
                     #--- Deverrouille les widgets du mode "Videos espacees"
                     $panneau(acqvideo,$visuNo,This).mode.video_1.nom.entr configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video_1.index.entr configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video_1.index.but configure -state normal
                     $panneau(acqvideo,$visuNo,This).mode.video_1.show.case configure -state normal
               }
            }
            #--- Deverrouille le bouton apres les acquisitions
            $panneau(acqvideo,$visuNo,This).mode.but configure -state normal
            #--- Je restitue l'affichage du bouton "GO"
            set panneau(acqvideo,$visuNo,go_stop) go
            $panneau(acqvideo,$visuNo,This).go_stop.but configure -text $caption(acqvideo,GO)
            #--- J'autorise le bouton "GO"
            $panneau(acqvideo,$visuNo,This).go_stop.but configure -state normal
         }
      }
   }
#***** Fin de la procedure Go/Stop *****************************

#***** Procedure d'apercu en mode video ************************
   proc changerVideoPreview { visuNo } {
      global panneau

      if { $panneau(acqvideo,$visuNo,showvideopreview) == 1 } {
         ::acqvideo::startVideoPreview $visuNo
      } else {
         ::acqvideo::stopVideoPreview $visuNo
      }
   }

#***** Demarre le mode video************************
# retourne 0 si OK, 1 si erreur
   proc startVideoPreview { visuNo } {
      global audace caption panneau

      set camItem [::confVisu::getCamItem $visuNo]

      if { [ ::confCam::isReady $camItem ] == 0 } {
         ::confCam::run
         #--- Je decoche la checkbox
         set panneau(acqvideo,$visuNo,showvideopreview) "0"
         #--- Je decoche le fenetrage
         if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
            set panneau(acqvideo,$visuNo,fenetre) "0"
            ::acqvideo::optionWindowedFenster $visuNo
         }
         #---
         return 1
      } elseif { [::confCam::getPluginProperty $camItem "hasVideo"] != 1 } {
         tk_messageBox -title $caption(acqvideo,pb) -type ok \
            -message $caption(acqvideo,no_video_mode)
         #--- Je decoche la checkbox
         set panneau(acqvideo,$visuNo,showvideopreview) "0"
         #--- Je decoche le fenetrage
         if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
            set panneau(acqvideo,$visuNo,fenetre) "0"
            ::acqvideo::optionWindowedFenster $visuNo
         }
         #---
         return 1
      }

      #--- Je connecte la sortie de la camera a l'image
      set result [::confVisu::setVideo $visuNo 1 ]
      if { $result == "1" } {
        #--- Je decoche la checkbox
        set panneau(acqvideo,$visuNo,showvideopreview) "0"
        #--- Je decoche le fenetrage
        if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
           set panneau(acqvideo,$visuNo,fenetre) "0"
           ::acqvideo::optionWindowedFenster $visuNo
        }
        #---
        return 1
      }

      set panneau(acqvideo,$visuNo,showvideopreview) "1"
      return 0
   }
#***** Fin de la procedure d'apercu en mode video ******************

#***** Procedure fin d'apercu en mode video ************************
   proc stopVideoPreview { visuNo } {
      global panneau

      #--- J'arrete l'aquisition fenetree si elle est active
      if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
         ::acqvideo::stopWindowedFenster $visuNo
         set panneau(acqvideo,$visuNo,fenetre) "0"
         ::acqvideo::optionWindowedFenster $visuNo
      }
      #---
      set camNo $panneau(acqvideo,$visuNo,camNo)
      if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] hasVideo ] == "1" } {
         #--- Arret de la visualisation video
         ::confVisu::setVideo $visuNo 0
         set panneau(acqvideo,$visuNo,showvideopreview) "0"
      }
   }
#***** Fin de la procedure fin d'apercu en mode video **************

#***** Procedure d'affichage d'une barre de progression ********
   proc avancementPose { visuNo { t } } {
      global caption color panneau

      if { $panneau(acqvideo,$visuNo,avancement_acq) == "1" } {
         #--- Recuperation de la position de la fenetre Avancement
         ::acqvideo::recupPositionAvancementPose $visuNo

         #--- Initialisation de la barre de progression
         set cpt "100"

         #--- Creation de la fenetre de progression
         if { [ winfo exists $panneau(acqvideo,$visuNo,base).progress ] != "1" } {
            #--- Creation de la toplevel
            toplevel $panneau(acqvideo,$visuNo,base).progress
            wm transient $panneau(acqvideo,$visuNo,base).progress $panneau(acqvideo,$visuNo,base)
            wm resizable $panneau(acqvideo,$visuNo,base).progress 0 0
            wm title $panneau(acqvideo,$visuNo,base).progress "$caption(acqvideo,en_cours)"
            wm geometry $panneau(acqvideo,$visuNo,base).progress $panneau(acqvideo,$visuNo,avancement,position)

            #--- Creation du label du temps d'attente
            label $panneau(acqvideo,$visuNo,base).progress.lab_status -text "" -justify center
            pack $panneau(acqvideo,$visuNo,base).progress.lab_status -side top -fill x -expand true -pady 5

            #--- Creation des frames pour la barre de progression
            frame $panneau(acqvideo,$visuNo,base).progress.cadre -width 200 -height 30 -borderwidth 2 -relief groove
            pack $panneau(acqvideo,$visuNo,base).progress.cadre -in $panneau(acqvideo,$visuNo,base).progress -side top \
               -anchor center -fill x -expand true -padx 8 -pady 8
            frame $panneau(acqvideo,$visuNo,base).progress.cadre.barre_color_invariant -height 26 -bg $color(blue)
         }

         #---
         if { $t < "0" } {
            destroy $panneau(acqvideo,$visuNo,base).progress
         } else {
            $panneau(acqvideo,$visuNo,base).progress.lab_status configure -text "$caption(acqvideo,attente) [ expr $t + 1 ]\
               $caption(acqvideo,sec) / $panneau(acqvideo,$visuNo,intervalle_video) $caption(acqvideo,sec)"
            set cpt [expr $t*100 / $panneau(acqvideo,$visuNo,intervalle_video) ]
            set cpt [expr 100 - $cpt]
         }

         catch {
            #--- Affichage de la barre de progression
            place $panneau(acqvideo,$visuNo,base).progress.cadre.barre_color_invariant \
               -in $panneau(acqvideo,$visuNo,base).progress.cadre -x 0 -y 0 \
               -relwidth [ expr $cpt / 100.0 ]
            update
         }

         #--- Mise a jour dynamique des couleurs
         if [ winfo exists $panneau(acqvideo,$visuNo,base).progress ] {
            ::confColor::applyColor $panneau(acqvideo,$visuNo,base).progress
         }
      } else {
         return
      }
   }
#***** Fin de la procedure d'avancement de la pose *************

#***** Procedure d'arret de l'acquisition **********************
   proc arretImage { visuNo } {
      global audace panneau

      #--- Positionne un indicateur de demande d'arret
      set panneau(acqvideo,$visuNo,demande_arret) "1"
      #--- Annulation de la sonnerie
      catch { after cancel $audace(after,bell,id) }
      #--- Annulation de l'alarme de fin de pose
      catch { after cancel bell }
      #--- J'arrete la capture de la video
      catch { cam$panneau(acqvideo,$visuNo,camNo) stopvideocapture }
      #--- Je positionne la fenetre video
      if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
         cam$panneau(acqvideo,$visuNo,camNo) setvideocroprect $panneau(acqvideo,$visuNo,x1) \
            $panneau(acqvideo,$visuNo,y1) $panneau(acqvideo,$visuNo,x2) $panneau(acqvideo,$visuNo,y2)
      }
   }
#***** Fin de la procedure d'arret de l'acquisition ************

#***** Procedure d'affichage des messages ************************
#--- Cette procedure est recopiee de methking.tcl, elle permet l'affichage de differents
#--- messages (dans la console, le fichier log, etc.)
   proc Message { visuNo niveau args } {
      global caption panneau

      switch -exact -- $niveau {
         console {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         log {
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch {
               puts -nonewline $::acqvideo::log_id($visuNo) [eval [concat {format} $args]]
               #--- Force l'ecriture immediate sur le disque
               flush $::acqvideo::log_id($visuNo)
            }
         }
         consolog {
            if { $panneau(acqvideo,$visuNo,messages) == "1" } {
               ::console::disp [eval [concat {format} $args]]
               update idletasks
            }
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch {
               puts -nonewline $::acqvideo::log_id($visuNo) [eval [concat {format} $args]]
               #--- Force l'ecriture immediate sur le disque
               flush $::acqvideo::log_id($visuNo)
            }
         }
         default {
            set b [ list "%s\n" $caption(acqvideo,pbmesserr) ]
            ::console::disp [ eval [ concat {format} $b ] ]
            update idletasks
         }
      }
   }
#***** Fin de la procedure d'affichage des messages ***************

#***** Bouton pour le decalage du telescope ***********************
# cmdShiftConfig{}
#    affiche la fenetre de configuration pour modifier les parametres
#    de deplacement du telescope entre 2 acquisitions d'une serie
#------------------------------------------------------------------
   proc cmdShiftConfig { visuNo } {
      global audace

      set shiftConfig [ ::DlgShiftVideo::run $visuNo $audace(base).dlgShiftVideo ]
      return
   }
#***** Fin du bouton pour le decalage du telescope *****************

#***** Fenetre de configuration video ****************************************************
   proc selectVideoMode { visuNo } {
      global caption conf panneau

      #--- Recuperation de la position de la fenetre
      ::acqvideo::recupPosition $visuNo

      #--- J'arrete l'aquisition fenetree si elle est active
      if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
         ::acqvideo::stopWindowedFenster $visuNo
         set panneau(acqvideo,$visuNo,fenetre) "0"
         ::acqvideo::optionWindowedFenster $visuNo
      }

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqvideo,video,position) ] } { set conf(acqvideo,video,position) "+120+260" }

      #--- Creation de la fenetre Video
      toplevel $panneau(acqvideo,$visuNo,base).status_video
      wm transient $panneau(acqvideo,$visuNo,base).status_video $panneau(acqvideo,$visuNo,base)
      wm resizable $panneau(acqvideo,$visuNo,base).status_video 1 1
      wm title $panneau(acqvideo,$visuNo,base).status_video "$caption(acqvideo,capture_video)"
      wm geometry $panneau(acqvideo,$visuNo,base).status_video $conf(acqvideo,video,position)
      wm protocol $panneau(acqvideo,$visuNo,base).status_video WM_DELETE_WINDOW " \
         if { $panneau(acqvideo,$visuNo,mode) == \"1\" } { \
            set panneau(acqvideo,$visuNo,mode_en_cours) \"$caption(acqvideo,video)\" \
         } elseif { $panneau(acqvideo,$visuNo,mode) == \"2\" } { \
            set panneau(acqvideo,$visuNo,mode_en_cours) \"$caption(acqvideo,video1)\" \
         } \
      "

      #--- Trame de l'intervalle entre les videos
      if { $panneau(acqvideo,$visuNo,mode) == "2" } {
         label $panneau(acqvideo,$visuNo,base).status_video.lab1 -text "$caption(acqvideo,titre1)"
         pack $panneau(acqvideo,$visuNo,base).status_video.lab1 -padx 10 -pady 5
         frame $panneau(acqvideo,$visuNo,base).status_video.a
            label $panneau(acqvideo,$visuNo,base).status_video.a.lab2 -text "$caption(acqvideo,intervalle_video)"
            pack $panneau(acqvideo,$visuNo,base).status_video.a.lab2 -anchor center -expand 1 -fill none -side left \
               -padx 10 -pady 5
            entry $panneau(acqvideo,$visuNo,base).status_video.a.ent1 -width 5 \
               -relief groove -textvariable panneau(acqvideo,$visuNo,intervalle_video) -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
            pack $panneau(acqvideo,$visuNo,base).status_video.a.ent1 -anchor center -expand 1 -fill none \
               -side left -padx 10
         pack $panneau(acqvideo,$visuNo,base).status_video.a -padx 10 -pady 5
      }

      #--- Trame de la duree du film
      frame $panneau(acqvideo,$visuNo,base).status_video.pose -borderwidth 2
         menubutton $panneau(acqvideo,$visuNo,base).status_video.pose.but -text $caption(acqvideo,lg_film) \
            -menu $panneau(acqvideo,$visuNo,base).status_video.pose.but.menu -relief raised
         pack $panneau(acqvideo,$visuNo,base).status_video.pose.but -side left -ipadx 5 -ipady 0
         set m [ menu $panneau(acqvideo,$visuNo,base).status_video.pose.but.menu -tearoff 0 ]
         foreach temps $panneau(acqvideo,$visuNo,temps_pose) {
            $m add radiobutton -label "$temps" \
               -indicatoron "1" \
               -value "$temps" \
               -variable panneau(acqvideo,$visuNo,lg_film) \
               -command " "
         }
         entry $panneau(acqvideo,$visuNo,base).status_video.pose.entr -width 5 \
            -relief groove -textvariable panneau(acqvideo,$visuNo,lg_film) -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $panneau(acqvideo,$visuNo,base).status_video.pose.entr -side left -fill x -expand 0
         label $panneau(acqvideo,$visuNo,base).status_video.pose.lab -text $caption(acqvideo,sec)
         pack $panneau(acqvideo,$visuNo,base).status_video.pose.lab -side left -anchor w -fill x \
            -pady 0 -ipadx 5 -ipady 0
      pack $panneau(acqvideo,$visuNo,base).status_video.pose -anchor center -side top -pady 0 -ipadx 0 -ipady 0 \
         -expand true

      #--- Nombre d'images/seconde
      frame $panneau(acqvideo,$visuNo,base).status_video.rate -borderwidth 2
         menubutton $panneau(acqvideo,$visuNo,base).status_video.rate.cb -text $caption(acqvideo,rate) \
            -menu $panneau(acqvideo,$visuNo,base).status_video.rate.cb.menu -relief raised
         pack $panneau(acqvideo,$visuNo,base).status_video.rate.cb -side left -ipadx 5 -ipady 0
         set m [ menu $panneau(acqvideo,$visuNo,base).status_video.rate.cb.menu -tearoff 0 ]
         foreach rate $panneau(acqvideo,$visuNo,ratelist) {
            $m add radiobutton -label "$rate" \
               -indicatoron "1" \
               -value "$rate" \
               -variable panneau(acqvideo,$visuNo,rate) \
               -command " "
         }
         entry $panneau(acqvideo,$visuNo,base).status_video.rate.entr -width 5 \
            -relief groove -textvariable panneau(acqvideo,$visuNo,rate) -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 99 }
         pack $panneau(acqvideo,$visuNo,base).status_video.rate.entr -side left -fill x -expand 0
         label $panneau(acqvideo,$visuNo,base).status_video.rate.unite -text $caption(acqvideo,rate_unite)
         pack $panneau(acqvideo,$visuNo,base).status_video.rate.unite -anchor center -expand 0 -fill x -side left \
            -ipadx 5 -ipady 0
      pack $panneau(acqvideo,$visuNo,base).status_video.rate -anchor center -side top -pady 0 -ipadx 0 -ipady 0 \
         -expand true

      #--- Label affichant le status de la camera en mode video
      frame $panneau(acqvideo,$visuNo,base).status_video.status -borderwidth 2 -relief ridge
         label $panneau(acqvideo,$visuNo,base).status_video.status.label -textvariable panneau(acqvideo,$visuNo,status) \
            -wraplength 150 -height 4 -pady 0
         pack $panneau(acqvideo,$visuNo,base).status_video.status.label -anchor center -expand 1 -fill both -side top
      pack $panneau(acqvideo,$visuNo,base).status_video.status -anchor center -fill both -pady 0 -ipadx 5 -ipady 0

      #--- Frame pour l'acquisition fenetree
      frame $panneau(acqvideo,$visuNo,base).status_video.fenetrer -borderwidth 2 -relief ridge

         frame $panneau(acqvideo,$visuNo,base).status_video.fenetrer.check -borderwidth 0 -relief ridge
            checkbutton $panneau(acqvideo,$visuNo,base).status_video.fenetrer.check.case -pady 0 \
               -text "$caption(acqvideo,acquisition_fenetree)" -variable panneau(acqvideo,$visuNo,fenetre) \
               -command "::acqvideo::cmdAcqFenetree $visuNo"
            pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.check.case -anchor w -expand 0 -side top
         pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.check -anchor w -expand 0 -fill x -side top

         button $panneau(acqvideo,$visuNo,base).status_video.fenetrer.but_select -borderwidth 1 \
            -text $caption(acqvideo,acq_fen_msg) -command "::acqvideo::selectWindowedFenster $visuNo"
         # pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.but_select -anchor w -expand 0 -fill x -side top
         frame $panneau(acqvideo,$visuNo,base).status_video.fenetrer.left1 -borderwidth 0 -relief ridge
            label $panneau(acqvideo,$visuNo,base).status_video.fenetrer.left1.largeur \
               -text "$caption(acqvideo,largeur_hauteur)"
            pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.left1.largeur -anchor w -expand 0 \
               -side top -ipadx 15 -ipady 0
            label $panneau(acqvideo,$visuNo,base).status_video.fenetrer.left1.x1 -text "$caption(acqvideo,coord_x1_y1)"
            pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.left1.x1 -anchor w -expand 0 \
               -side top -ipadx 15 -ipady 0
            label $panneau(acqvideo,$visuNo,base).status_video.fenetrer.left1.x2 -text "$caption(acqvideo,coord_x2_y2)"
            pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.left1.x2 -anchor w -expand 0 \
               -side top -ipadx 15 -ipady 0
         # pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.left1 -anchor w -expand 0 -fill x -side left
         frame $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right -borderwidth 0 -relief ridge
            label $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right.hauteur \
               -textvariable panneau(acqvideo,$visuNo,largeur)
            pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right.hauteur -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
            label $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right.y1 -textvariable panneau(acqvideo,$visuNo,x1)
            pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right.y1 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
            label $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right.y2 -textvariable panneau(acqvideo,$visuNo,x2)
            pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right.y2 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
         # pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right -anchor w -expand 0 -fill x -side left
         frame $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right1 -borderwidth 0 -relief ridge
            label $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right1.hauteur \
               -textvariable panneau(acqvideo,$visuNo,hauteur)
            pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right1.hauteur -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
            label $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right1.y1 -textvariable panneau(acqvideo,$visuNo,y1)
            pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right1.y1 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
            label $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right1.y2 -textvariable panneau(acqvideo,$visuNo,y2)
            pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right1.y2 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
         # pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right1 -anchor w -expand 0 -fill x -side left

      pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer -anchor center -fill both -pady 0 -ipadx 5 -ipady 0

      #--- Focus a la fenetre
      focus $panneau(acqvideo,$visuNo,base).status_video

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(acqvideo,$visuNo,base).status_video
   }
#***** Fin fenetre de configuration video ****************************************************

#***** Procedure d'ouverture des options de fenetrage ****************************************
   proc optionWindowedFenster { visuNo } {
      global panneau

      if { $panneau(acqvideo,$visuNo,fenetre) == "0" } {
         #--- Sans le fenetrage
         pack forget $panneau(acqvideo,$visuNo,base).status_video.fenetrer.but_select
         pack forget $panneau(acqvideo,$visuNo,base).status_video.fenetrer.left1
         pack forget $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right
         pack forget $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right1
      } else {
         #--- Avec le fenetrage
         pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.but_select -anchor w -expand 0 -fill x -side top
         pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.left1 -anchor w -expand 0 -fill x -side left
         pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right -anchor w -expand 0 -fill x -side left
         pack $panneau(acqvideo,$visuNo,base).status_video.fenetrer.right1 -anchor w -expand 0 -fill x -side left
      }
   }
#***** Fin de la procedure d'ouverture des options de fenetrage ******************************

#***** Procedure de demarrage du fenetrage video *********************************************
   proc startWindowedFenster { visuNo } {
      global audace caption panneau

      set camItem [::confVisu::getCamItem $visuNo]

      #--- Active le mode preview
      if { $panneau(acqvideo,$visuNo,showvideopreview) == "0" } {
         set result [ ::acqvideo::startVideoPreview $visuNo ]
      } else {
         set result "0"
      }
      #---
      if { $result == "0" } {
         if { [ ::confVisu::getCamItem $visuNo ] == "" } {
            ::confCam::run
            #--- Je decoche la checkbox
            set panneau(acqvideo,$visuNo,showvideopreview) "0"
            #--- Je decoche le fenetrage
            if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
               set panneau(acqvideo,$visuNo,fenetre) "0"
               ::acqvideo::optionWindowedFenster $visuNo
            }
         } elseif { [::confCam::getPluginProperty $camItem "hasVideo"] != 1 } {
            tk_messageBox -title $caption(acqvideo,pb) -type ok \
               -message $caption(acqvideo,no_video_mode)
            #--- Je decoche la checkbox
            set panneau(acqvideo,$visuNo,showvideopreview) "0"
            #--- Je decoche le fenetrage
            if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
               set panneau(acqvideo,$visuNo,fenetre) "0"
               ::acqvideo::optionWindowedFenster $visuNo
            }
         } else {
            #--- Je demarre le mode video fenetree
            cam$panneau(acqvideo,$visuNo,camNo) startvideocrop
         }
      } else {
         set panneau(acqvideo,$visuNo,fenetre) "0"
      }
   }
#***** Fin de la procedure de demarrage du fenetrage video ***********************************

#***** Procedure d'arret du fenetrage video **************************************************
   proc stopWindowedFenster { visuNo } {
      global panneau

      set camItem [::confVisu::getCamItem $visuNo]

      #---
      if { [ winfo exists $panneau(acqvideo,$visuNo,base).selectWindowedFenster ] } {
         ::acqvideo::closeWindowedFenster $visuNo
      }
      #---
      if { [ ::confVisu::getCamItem $visuNo ] == "" } {
         #--- Je decoche la checkbox
         set panneau(acqvideo,$visuNo,showvideopreview) "0"
         #--- Je decoche le fenetrage
         if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
            set panneau(acqvideo,$visuNo,fenetre) "0"
            ::acqvideo::optionWindowedFenster $visuNo
         }
      } elseif { [::confCam::getPluginProperty $camItem "hasVideo"] == 0 } {
         #--- Je decoche la checkbox
         set panneau(acqvideo,$visuNo,showvideopreview) "0"
         #--- Je decoche le fenetrage
         if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
            set panneau(acqvideo,$visuNo,fenetre) "0"
            ::acqvideo::optionWindowedFenster $visuNo
         }
      } else {
         #--- J'arrete la capture si elle est encours
         catch {
            cam$panneau(acqvideo,$visuNo,camNo) stopvideocrop
         }
      }
   }
#***** Fin de la procedure d'arret du fenetrage video ****************************************

#***** Procedure de selection du fenetrage video *********************************************
   proc selectWindowedFenster { visuNo } {
      global audace caption conf panneau zone

      #--- Une camera est connectee
      if { [ ::confVisu::getCamItem $visuNo ] == "" } {
         return
      } elseif { [::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] "hasVideo"] != 1  } {
         return
      }

      #---
      if { [ winfo exists $panneau(acqvideo,$visuNo,base).selectWindowedFenster ] } {
         wm withdraw $panneau(acqvideo,$visuNo,base).selectWindowedFenster
         wm deiconify $panneau(acqvideo,$visuNo,base).selectWindowedFenster
         focus $panneau(acqvideo,$visuNo,base).selectWindowedFenster
         return
      }

      #--- Cree la fenetre $panneau(acqvideo,$visuNo,base).selectWindowedFenster de niveau le plus haut
      toplevel $panneau(acqvideo,$visuNo,base).selectWindowedFenster -class Toplevel
      wm geometry $panneau(acqvideo,$visuNo,base).selectWindowedFenster $conf(acqvideo,video,position)
      wm resizable $panneau(acqvideo,$visuNo,base).selectWindowedFenster 0 0
      wm title $panneau(acqvideo,$visuNo,base).selectWindowedFenster $caption(acqvideo,acq_fen_msg)

      #--- Creation des differents frames
      frame $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame1 -borderwidth 1 -relief raised
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame1 -side top -fill both -expand 1

      frame $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame2 -borderwidth 1 -relief raised
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame2 -side top -fill x

      frame $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame3 -borderwidth 0 -relief raised
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame3 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame1 -side top -fill both -expand 1

      frame $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame4 -borderwidth 0 -relief raised
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame4 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame1 -side top -fill both -expand 1

      frame $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame5 -borderwidth 0 -relief raised
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame5 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame4 -side left -fill both -expand 1

      frame $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame6 -borderwidth 0 -relief raised
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame6 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame4 -side left -fill both -expand 1

      frame $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame7 -borderwidth 0 -relief raised
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame7 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame5 -side top -fill both -expand 1

      frame $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame8 -borderwidth 0 -relief raised
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame8 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame5 -side top -fill both -expand 1

      frame $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame9 -borderwidth 0 -relief raised
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame9 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame6 -side top -fill both -expand 1

      frame $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame10 -borderwidth 0 -relief raised
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame10 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame6 -side top -fill both -expand 1

      #--- Rafraichir le nombre de pixels du CCD en x et en y
      button $panneau(acqvideo,$visuNo,base).selectWindowedFenster.but_refresh -text "$caption(acqvideo,refresh)" \
         -borderwidth 2 -command "::acqvideo::refreshNumberPixel $visuNo"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.but_refresh \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame3 -side top -anchor center \
         -padx 3 -pady 3 -ipadx 5 -ipady 5

      #--- Creation d'un canvas pour affichage de la fenetre dans la video
      canvas $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame3.image1_color_invariant \
         -width 340 -height 260 -highlightthickness 0
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame3.image1_color_invariant
      set zone(image1) $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame3.image1_color_invariant

      #--- Representation de la video
      $zone(image1) create line 10 10 10 250 -fill $audace(color,textColor) -tags cadres -width 2.0
      $zone(image1) create line 10 250 330 250 -fill $audace(color,textColor) -tags cadres -width 2.0
      $zone(image1) create line 330 250 330 10 -fill $audace(color,textColor) -tags cadres -width 2.0
      $zone(image1) create line 330 10 10 10 -fill $audace(color,textColor) -tags cadres -width 2.0

      #--- Representation de la fenetre
      $zone(image1) create line 50 80 50 200 -fill $audace(color,drag_rectangle) -tags cadres -width 2.0
      $zone(image1) create line 50 200 250 200 -fill $audace(color,drag_rectangle) -tags cadres -width 2.0
      $zone(image1) create line 250 200 250 80 -fill $audace(color,drag_rectangle) -tags cadres -width 2.0
      $zone(image1) create line 250 80 50 80 -fill $audace(color,drag_rectangle) -tags cadres -width 2.0

      #--- Largeur et hauteur de la video
      ::acqvideo::refreshNumberPixel $visuNo

      #--- Abcisses et ordonnees des 4 coins de la fenetre
      $zone(image1) create text 30 200 -text "(x1,y1)" \
         -justify center -fill $audace(color,drag_rectangle) -tags cadres
      $zone(image1) create text 30 80 -text "(x1,y2)" \
         -justify center -fill $audace(color,drag_rectangle) -tags cadres
      $zone(image1) create text 270 80 -text "(x2,y2)" \
         -justify center -fill $audace(color,drag_rectangle) -tags cadres
      $zone(image1) create text 270 200 -text "(x2,y1)" \
         -justify center -fill $audace(color,drag_rectangle) -tags cadres

      #--- Cree la zone a renseigner pour x1
      label $panneau(acqvideo,$visuNo,base).selectWindowedFenster.lab1 -text "$caption(acqvideo,x1)"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.lab1 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame7 -anchor w -side left -padx 30 -pady 3

      entry $panneau(acqvideo,$visuNo,base).selectWindowedFenster.ent1 -textvariable panneau(acqvideo,$visuNo,x1) \
         -width 6 -justify center \
         -validate all -validatecommand "::tkutil::validateNumber %W %V %P %s integer 1 [ lindex [ cam$panneau(acqvideo,$visuNo,camNo) nbpix ] 0 ]"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.ent1 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame7 -anchor w -side left -padx 0 -pady 3

      #--- Cree la zone a renseigner pour y1
      label $panneau(acqvideo,$visuNo,base).selectWindowedFenster.lab2 -text "$caption(acqvideo,y1)"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.lab2 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame8 -anchor w -side left -padx 30 -pady 3

      entry $panneau(acqvideo,$visuNo,base).selectWindowedFenster.ent2 -textvariable panneau(acqvideo,$visuNo,y1) \
         -width 6 -justify center \
         -validate all -validatecommand "::tkutil::validateNumber %W %V %P %s integer 1 [ lindex [ cam$panneau(acqvideo,$visuNo,camNo) nbpix ] 1 ]"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.ent2 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame8 -anchor w -side left -padx 0 -pady 3

      #--- Cree la zone a renseigner pour x2
      label $panneau(acqvideo,$visuNo,base).selectWindowedFenster.lab3 -text "$caption(acqvideo,x2)"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.lab3 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame9 -anchor w -side left -padx 10 -pady 3

      entry $panneau(acqvideo,$visuNo,base).selectWindowedFenster.ent3 -textvariable panneau(acqvideo,$visuNo,x2) \
         -width 6 -justify center \
         -validate all -validatecommand "::tkutil::validateNumber %W %V %P %s integer 1 [ lindex [ cam$panneau(acqvideo,$visuNo,camNo) nbpix ] 0 ]"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.ent3 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame9 -anchor w -side left -padx 20 -pady 3

      #--- Cree la zone a renseigner pour y2
      label $panneau(acqvideo,$visuNo,base).selectWindowedFenster.lab4 -text "$caption(acqvideo,y2)"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.lab4 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame10 -anchor w -side left -padx 10 -pady 3

      entry $panneau(acqvideo,$visuNo,base).selectWindowedFenster.ent4 -textvariable panneau(acqvideo,$visuNo,y2) \
         -width 6 -justify center \
         -validate all -validatecommand "::tkutil::validateNumber %W %V %P %s integer 1 [ lindex [ cam$panneau(acqvideo,$visuNo,camNo) nbpix ] 1 ]"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.ent4 \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame10 -anchor w -side left -padx 20 -pady 3

      #--- Cree le bouton 'OK'
      button $panneau(acqvideo,$visuNo,base).selectWindowedFenster.but_ok -text "$caption(acqvideo,ok)" -width 7 \
         -borderwidth 2 \
         -command "::acqvideo::setvideocroprectWindowedFenster $visuNo ; ::acqvideo::closeWindowedFenster $visuNo"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.but_ok \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Appliquer'
      button $panneau(acqvideo,$visuNo,base).selectWindowedFenster.but_appliquer -text "$caption(acqvideo,appliquer)" \
         -width 7 -borderwidth 2 -command "::acqvideo::setvideocroprectWindowedFenster $visuNo"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.but_appliquer \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $panneau(acqvideo,$visuNo,base).selectWindowedFenster.but_fermer -text "$caption(acqvideo,fermer)" -width 7 \
         -borderwidth 2 -command "::acqvideo::closeWindowedFenster $visuNo"
      pack $panneau(acqvideo,$visuNo,base).selectWindowedFenster.but_fermer \
         -in $panneau(acqvideo,$visuNo,base).selectWindowedFenster.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $panneau(acqvideo,$visuNo,base).selectWindowedFenster

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $panneau(acqvideo,$visuNo,base).selectWindowedFenster <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
     ::confColor::applyColor $panneau(acqvideo,$visuNo,base).selectWindowedFenster
   }
#***** Fin de la procedure de selection du fenetrage video ***********************************

#***** Procedure de rafraississement du nombre de pixels *************************************
   proc refreshNumberPixel { visuNo } {
      global audace panneau zone

      #--- J'arrete le mode video fenetree
      catch { cam$panneau(acqvideo,$visuNo,camNo) stopvideocrop }

      #--- Largeur et hauteur de l'image
      set largeur [ lindex [ cam$panneau(acqvideo,$visuNo,camNo) nbpix ] 0 ]
      set hauteur [ lindex [ cam$panneau(acqvideo,$visuNo,camNo) nbpix ] 1 ]

      #--- Effacement de la largeur et la hauteur de la video
      $zone(image1) delete label_nb_pixel_x_y

      #--- Largeur et hauteur de la video
      $zone(image1) create text 170 20 -text "$largeur" \
         -justify center -fill $audace(color,textColor) -tags label_nb_pixel_x_y
      $zone(image1) create text 25 130 -text "$hauteur" \
         -justify center -fill $audace(color,textColor) -tags label_nb_pixel_x_y

      #--- Controle la coordonnee x1
      if { ( $panneau(acqvideo,$visuNo,x1) > $largeur ) || ( $panneau(acqvideo,$visuNo,x1) ) < "1" } {
         set panneau(acqvideo,$visuNo,x1) "1"
      }

      #--- Controle la coordonnee y1
      if { ( $panneau(acqvideo,$visuNo,y1) > $hauteur ) || ( $panneau(acqvideo,$visuNo,y1) ) < "1" } {
         set panneau(acqvideo,$visuNo,y1) "1"
      }

      #--- Controle la coordonnee x2
      if { ( $panneau(acqvideo,$visuNo,x2) > $largeur ) || ( $panneau(acqvideo,$visuNo,x2) < "1" ) } {
         set panneau(acqvideo,$visuNo,x2) "$largeur"
      }

      #--- Controle la coordonnee y2
      if { ( $panneau(acqvideo,$visuNo,y2) > $hauteur ) || ( $panneau(acqvideo,$visuNo,y2) < "1" ) } {
         set panneau(acqvideo,$visuNo,y2) "$hauteur"
      }

      #--- Je demarre le mode video fenetree
      catch { cam$panneau(acqvideo,$visuNo,camNo) startvideocrop }
   }
#***** Fin de la procedure de rafraississement du nombre de pixels ***************************

#***** Procedure d'acquisition du fenetrage video ********************************************
   proc setvideocroprectWindowedFenster { visuNo } {
      global panneau

      #--- Largeur et hauteur de l'image
      set largeur [ lindex [ cam$panneau(acqvideo,$visuNo,camNo) nbpix ] 0 ]
      set hauteur [ lindex [ cam$panneau(acqvideo,$visuNo,camNo) nbpix ] 1 ]

      #--- Controle la coordonnee x1
      if { ( $panneau(acqvideo,$visuNo,x1) > $largeur ) || ( $panneau(acqvideo,$visuNo,x1) ) < "1" } {
         set panneau(acqvideo,$visuNo,x1) "1"
      }

      #--- Controle la coordonnee y1
      if { ( $panneau(acqvideo,$visuNo,y1) > $hauteur ) || ( $panneau(acqvideo,$visuNo,y1) ) < "1" } {
         set panneau(acqvideo,$visuNo,y1) "1"
      }

      #--- Controle la coordonnee x2
      if { ( $panneau(acqvideo,$visuNo,x2) > $largeur ) || ( $panneau(acqvideo,$visuNo,x2) < "1" ) } {
         set panneau(acqvideo,$visuNo,x2) "$largeur"
      }

      #--- Controle la coordonnee y2
      if { ( $panneau(acqvideo,$visuNo,y2) > $hauteur ) || ( $panneau(acqvideo,$visuNo,y2) < "1" ) } {
         set panneau(acqvideo,$visuNo,y2) "$hauteur"
      }

      #--- Largeur et hauteur de la fenetre vidieo
      set panneau(acqvideo,$visuNo,largeur) [ expr $panneau(acqvideo,$visuNo,y2) - $panneau(acqvideo,$visuNo,y1) ]
      set panneau(acqvideo,$visuNo,hauteur) [ expr $panneau(acqvideo,$visuNo,x2) - $panneau(acqvideo,$visuNo,x1) ]

      #--- Je positionne la fenetre video
      cam$panneau(acqvideo,$visuNo,camNo) setvideocroprect $panneau(acqvideo,$visuNo,x1) $panneau(acqvideo,$visuNo,y1) \
         $panneau(acqvideo,$visuNo,x2) $panneau(acqvideo,$visuNo,y2)
   }
#***** Fin de la procedure d'acquisition du fenetrage video **********************************

#***** Procedure de fermeture de la fenetre du fenetrage video *******************************
   proc closeWindowedFenster { visuNo } {
      global panneau

      #--- Fermeture de la fenetre
      destroy $panneau(acqvideo,$visuNo,base).selectWindowedFenster
   }
#***** Fin de la procedure de fermeture de la fenetre du fenetrage video *********************

#***** Enregistrement de la position des fenetres Video et Video (1) *************************
   proc recupPosition { visuNo } {
      global conf panneau

      #--- Cas de la fenetre Video et Video (1)
      if [ winfo exists $panneau(acqvideo,$visuNo,base).status_video ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $panneau(acqvideo,$visuNo,base).status_video ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqvideo,video,position) "+[ string range $geometry $deb $fin ]"
         #--- Fermeture de la fenetre
         destroy $panneau(acqvideo,$visuNo,base).status_video
      }
   }
#***** Fin enregistrement de la position des fenetres Continu (1), Continu (2), Video et Video (1) ****

#***** Enregistrement de la position de la fenetre Avancement ********
   proc recupPositionAvancementPose { visuNo } {
      global panneau

      #--- Cas de la fenetre Avancement
      if [ winfo exists $panneau(acqvideo,$visuNo,base).progress ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $panneau(acqvideo,$visuNo,base).progress ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set panneau(acqvideo,$visuNo,avancement,position) "+[ string range $geometry $deb $fin ]"
      }
   }
#***** Fin enregistrement de la position de la fenetre Avancement ****

#***** Aquisition fenetree avec une WebCam ***************************
   proc cmdAcqFenetree { visuNo } {
      global panneau

      ::acqvideo::optionWindowedFenster $visuNo
      if { $panneau(acqvideo,$visuNo,fenetre) == "1" } {
         #--- Demarrage du fenetrage video
         ::acqvideo::startWindowedFenster $visuNo
         #--- Largeur et hauteur de l'image
         set largeur [ lindex [ cam$panneau(acqvideo,$visuNo,camNo) nbpix ] 0 ]
         set hauteur [ lindex [ cam$panneau(acqvideo,$visuNo,camNo) nbpix ] 1 ]
         #--- Controle la coordonnee x1
         if { ( $panneau(acqvideo,$visuNo,x1) > $largeur ) || ( $panneau(acqvideo,$visuNo,x1) ) < "1" } {
            set panneau(acqvideo,$visuNo,x1) "1"
         }
         #--- Controle la coordonnee y1
         if { ( $panneau(acqvideo,$visuNo,y1) > $hauteur ) || ( $panneau(acqvideo,$visuNo,y1) ) < "1" } {
            set panneau(acqvideo,$visuNo,y1) "1"
         }
         #--- Controle la coordonnee x2
         if { ( $panneau(acqvideo,$visuNo,x2) > $largeur ) || ( $panneau(acqvideo,$visuNo,x2) < "1" ) } {
            set panneau(acqvideo,$visuNo,x2) "$largeur"
         }
         #--- Controle la coordonnee y2
         if { ( $panneau(acqvideo,$visuNo,y2) > $hauteur ) || ( $panneau(acqvideo,$visuNo,y2) < "1" ) } {
            set panneau(acqvideo,$visuNo,y2) "$hauteur"
         }
         #--- Largeur et hauteur de la fenetre vidieo
         set panneau(acqvideo,$visuNo,largeur) [ expr $panneau(acqvideo,$visuNo,y2) - $panneau(acqvideo,$visuNo,y1) ]
         set panneau(acqvideo,$visuNo,hauteur) [ expr $panneau(acqvideo,$visuNo,x2) - $panneau(acqvideo,$visuNo,x1) ]
      } else {
         #--- Arret du fenetrage video
         ::acqvideo::stopWindowedFenster $visuNo
      }
   }
#***** Fin de l'aquisition fenetree avec une WebCam ******************

#***** Affichage de la fenetre de configuration de WebCam ************
   proc webcamConfigure { visuNo } {
      global audace caption

      set result [::webcam::config::run $visuNo [::confVisu::getCamItem $visuNo]]
      if { $result == "1" } {
         if { [ ::confVisu::getCamItem $visuNo ] == "" } {
            ::audace::menustate disabled
            set choix [ tk_messageBox -title $caption(acqvideo,pb) -type ok \
               -message $caption(acqvideo,selcam) ]
            set integre non
            if { $choix == "ok" } {
               #--- Ouverture de la fenetre de selection des cameras
               ::confCam::run
            }
            ::audace::menustate normal
         }
      }
   }
#***** Fin de la fenetre de configuration de WebCam ******************

}
#==============================================================
#   Fin de la declaration du namespace acqvideo
#==============================================================

proc acqvideoBuildIF { visuNo } {
   global audace caption panneau

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   #--- Trame de l'outil
   frame $panneau(acqvideo,$visuNo,This) -borderwidth 2 -relief groove

   #--- Trame du titre de l'outil
   frame $panneau(acqvideo,$visuNo,This).titre -borderwidth 2 -relief groove
      Button $panneau(acqvideo,$visuNo,This).titre.but -borderwidth 1 \
         -text "$caption(acqvideo,help_titre1)\n$caption(acqvideo,titre)" \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqvideo::getPluginType ] ] \
            [ ::acqvideo::getPluginDirectory ] [ ::acqvideo::getPluginHelp ]"
      pack $panneau(acqvideo,$visuNo,This).titre.but -side top -fill x -in $panneau(acqvideo,$visuNo,This).titre -ipadx 5
      DynamicHelp::add $panneau(acqvideo,$visuNo,This).titre.but -text $caption(acqvideo,help_titre)
   pack $panneau(acqvideo,$visuNo,This).titre -side top -fill x

   #--- Trame du bouton de configuration
   frame $panneau(acqvideo,$visuNo,This).config -borderwidth 2 -relief groove
      button $panneau(acqvideo,$visuNo,This).config.but -borderwidth 1 -text $caption(acqvideo,configuration) \
        -command "::acqvideoSetup::run $visuNo $base.acqvideoSetup"
      pack $panneau(acqvideo,$visuNo,This).config.but -side top -fill x -in $panneau(acqvideo,$visuNo,This).config -ipadx 5
   pack $panneau(acqvideo,$visuNo,This).config -side top -fill x

   #--- Bouton de configuration de la WebCam
   frame $panneau(acqvideo,$visuNo,This).pose -borderwidth 2 -relief ridge
      button $panneau(acqvideo,$visuNo,This).pose.conf -text $caption(acqvideo,pose+reglages) \
         -command "::acqvideo::webcamConfigure $visuNo"
      pack $panneau(acqvideo,$visuNo,This).pose.conf -fill x -expand true -ipady 3
   pack $panneau(acqvideo,$visuNo,This).pose -side top -fill x

   #--- Trame du bouton Go/Stop
   frame $panneau(acqvideo,$visuNo,This).go_stop -borderwidth 2 -relief ridge
      Button $panneau(acqvideo,$visuNo,This).go_stop.but -text $caption(acqvideo,GO) -height 2 \
         -borderwidth 3 -command "::acqvideo::goStop $visuNo"
      pack $panneau(acqvideo,$visuNo,This).go_stop.but -fill both -padx 0 -pady 0 -expand true
   pack $panneau(acqvideo,$visuNo,This).go_stop -side top -fill x

   #--- Trame du mode d'acquisition
   set panneau(acqvideo,$visuNo,mode_en_cours) [ lindex $panneau(acqvideo,$visuNo,list_mode) [ expr $panneau(acqvideo,$visuNo,mode) - 1 ] ]
   frame $panneau(acqvideo,$visuNo,This).mode -borderwidth 5 -relief ridge
      ComboBox $panneau(acqvideo,$visuNo,This).mode.but \
         -width 15         \
         -height [llength $panneau(acqvideo,$visuNo,list_mode)] \
         -relief raised    \
         -borderwidth 1    \
         -editable 0       \
         -takefocus 1      \
         -justify center   \
         -textvariable panneau(acqvideo,$visuNo,mode_en_cours) \
         -values $panneau(acqvideo,$visuNo,list_mode) \
         -modifycmd "::acqvideo::changerMode $visuNo"
      pack $panneau(acqvideo,$visuNo,This).mode.but -side top -fill x

      #--- Definition du sous-panneau "Mode : Video"
      frame $panneau(acqvideo,$visuNo,This).mode.video -borderwidth 0
         frame $panneau(acqvideo,$visuNo,This).mode.video.nom -relief ridge -borderwidth 2
            label $panneau(acqvideo,$visuNo,This).mode.video.nom.but -text $caption(acqvideo,nom) -pady 0
            pack $panneau(acqvideo,$visuNo,This).mode.video.nom.but -fill x -side top
            entry $panneau(acqvideo,$visuNo,This).mode.video.nom.entr -width 10 \
               -textvariable panneau(acqvideo,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqvideo,$visuNo,This).mode.video.nom.entr -fill x -side top
         pack $panneau(acqvideo,$visuNo,This).mode.video.nom -side top -fill x
         frame $panneau(acqvideo,$visuNo,This).mode.video.index -relief ridge -borderwidth 2
            checkbutton $panneau(acqvideo,$visuNo,This).mode.video.index.case -pady 0 -text $caption(acqvideo,index)\
               -variable panneau(acqvideo,$visuNo,indexer)
            pack $panneau(acqvideo,$visuNo,This).mode.video.index.case -side top -fill x
            entry $panneau(acqvideo,$visuNo,This).mode.video.index.entr -width 3 \
               -textvariable panneau(acqvideo,$visuNo,index) -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqvideo,$visuNo,This).mode.video.index.entr -side left -fill x -expand true
            button $panneau(acqvideo,$visuNo,This).mode.video.index.but -text "1" -width 3 \
               -command "set panneau(acqvideo,$visuNo,index) 1"
            pack $panneau(acqvideo,$visuNo,This).mode.video.index.but -side right -fill x
         pack $panneau(acqvideo,$visuNo,This).mode.video.index -side top -fill x
         frame $panneau(acqvideo,$visuNo,This).mode.video.show -relief ridge -borderwidth 2
            checkbutton $panneau(acqvideo,$visuNo,This).mode.video.show.case -text $caption(acqvideo,show_video) \
               -variable panneau(acqvideo,$visuNo,showvideopreview) \
               -command "::acqvideo::changerVideoPreview $visuNo"
            pack $panneau(acqvideo,$visuNo,This).mode.video.show.case -side left -fill x -expand true
         pack $panneau(acqvideo,$visuNo,This).mode.video.show -side top -fill x

      #--- Definition du sous-panneau "Mode : Video avec intervalle entre chaque video"
      frame $panneau(acqvideo,$visuNo,This).mode.video_1 -borderwidth 0
         frame $panneau(acqvideo,$visuNo,This).mode.video_1.nom -relief ridge -borderwidth 2
            label $panneau(acqvideo,$visuNo,This).mode.video_1.nom.but -text $caption(acqvideo,nom) -pady 0
            pack $panneau(acqvideo,$visuNo,This).mode.video_1.nom.but -fill x -side top
            entry $panneau(acqvideo,$visuNo,This).mode.video_1.nom.entr -width 10 \
               -textvariable panneau(acqvideo,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqvideo,$visuNo,This).mode.video_1.nom.entr -fill x -side top
         pack $panneau(acqvideo,$visuNo,This).mode.video_1.nom -side top -fill x
         frame $panneau(acqvideo,$visuNo,This).mode.video_1.index -relief ridge -borderwidth 2
            label $panneau(acqvideo,$visuNo,This).mode.video_1.index.lab -text $caption(acqvideo,index) -pady 0
            pack $panneau(acqvideo,$visuNo,This).mode.video_1.index.lab -side top -fill x
            entry $panneau(acqvideo,$visuNo,This).mode.video_1.index.entr -width 3 \
               -textvariable panneau(acqvideo,$visuNo,index) -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqvideo,$visuNo,This).mode.video_1.index.entr -side left -fill x -expand true
            button $panneau(acqvideo,$visuNo,This).mode.video_1.index.but -text "1" -width 3 \
               -command "set panneau(acqvideo,$visuNo,index) 1"
            pack $panneau(acqvideo,$visuNo,This).mode.video_1.index.but -side right -fill x
         pack $panneau(acqvideo,$visuNo,This).mode.video_1.index -side top -fill x
         frame $panneau(acqvideo,$visuNo,This).mode.video_1.show -relief ridge -borderwidth 2
            checkbutton $panneau(acqvideo,$visuNo,This).mode.video_1.show.case -text $caption(acqvideo,show_video) \
               -variable panneau(acqvideo,$visuNo,showvideopreview) \
               -command "::acqvideo::changerVideoPreview $visuNo"
            pack $panneau(acqvideo,$visuNo,This).mode.video_1.show.case -side left -fill x -expand true
         pack $panneau(acqvideo,$visuNo,This).mode.video_1.show -side top -fill x
      pack $panneau(acqvideo,$visuNo,This).mode -side top -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $panneau(acqvideo,$visuNo,This).avancement_acq -borderwidth 2 -relief ridge
         #--- Checkbutton petit deplacement
         checkbutton $panneau(acqvideo,$visuNo,This).avancement_acq.check -highlightthickness 0 \
            -text $caption(acqvideo,avancement_acq) -variable panneau(acqvideo,$visuNo,avancement_acq)
         pack $panneau(acqvideo,$visuNo,This).avancement_acq.check -side left -fill x
      pack $panneau(acqvideo,$visuNo,This).avancement_acq -side top -fill x

      #--- Frame petit decalage
      frame $panneau(acqvideo,$visuNo,This).shift -borderwidth 2 -relief ridge
         #--- Checkbutton petit deplacement
         checkbutton $panneau(acqvideo,$visuNo,This).shift.buttonShift -highlightthickness 0 \
            -variable panneau(DlgShiftVideo,buttonShift) \
            -command { if { $panneau(DlgShiftVideo,buttonShift) == "1" } { if { [ ::confTel::isReady ] == "0" } { ::confTel::run } } }
         pack $panneau(acqvideo,$visuNo,This).shift.buttonShift -side left -fill x
         #--- Bouton configuration petit deplacement
         button $panneau(acqvideo,$visuNo,This).shift.buttonShiftConfig -text "$caption(acqvideo,buttonShiftConfig)" \
            -command "::acqvideo::cmdShiftConfig $visuNo"
         pack $panneau(acqvideo,$visuNo,This).shift.buttonShiftConfig -side right -fill x -expand true
      pack $panneau(acqvideo,$visuNo,This).shift -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(acqvideo,$visuNo,This)
}

