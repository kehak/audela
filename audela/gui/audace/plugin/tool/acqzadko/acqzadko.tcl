#
# Fichier : acqzadko.tcl
# Description : Outil d'acquisition
# Auteurs : Francois Cochard et Myrtille Laas
# Mise à jour $Id: acqzadko.tcl 12688 2016-01-16 18:53:20Z robertdelmas $
#

#==============================================================
#   Declaration du namespace acqzadko
#==============================================================

namespace eval ::acqzadko {
   package provide acqzadko 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] acqzadko.cap ]
}

#***** Procedure createPluginInstance***************************
proc ::acqzadko::createPluginInstance { base { visuNo 1 } } {
   variable parametres
   global audace caption conf panneau

   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqzadko acqzadkoSetup.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqzadko dlgshiftzadko.tcl ]\""

   #---
   set panneau(acqzadko,$visuNo,base) "$base"
   set panneau(acqzadko,$visuNo,This) "$base.acqzadko"

   set panneau(acqzadko,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
   set panneau(acqzadko,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqzadko,$visuNo,camItem)]

   #--- Recuperation de la derniere configuration de l'outil
   ::acqzadko::chargerVariable $visuNo

   #--- Initialisation des variables de la boite de configuration
   ::acqzadkoSetup::confToWidget $visuNo

   #--- Initialisation des variables de la boite de decalage du telescope
   ::DlgShiftZadko::confToWidget $visuNo

   #--- Initialisation de la variable conf()
   if { ! [info exists conf(acqzadko,avancement,position)] } { set conf(acqzadko,avancement,position) "+120+315" }

   #--- Initialisation de variables
   set panneau(acqzadko,$visuNo,simulation)            "0"
   set panneau(acqzadko,$visuNo,simulation_deja_faite) "0"
   set panneau(acqzadko,$visuNo,attente_pose)          "0"
   set panneau(acqzadko,$visuNo,pose_en_cours)         "0"
   set panneau(acqzadko,$visuNo,avancement,position)   "$conf(acqzadko,avancement,position)"

   #--- Entrer ici les valeurs de temps de pose a afficher dans le menu "pose"
   set panneau(acqzadko,$visuNo,temps_pose) { 0 0.1 0.3 0.5 1 2 3 5 10 15 20 30 60 90 120 180 300 600 }
   #--- Valeur par defaut du temps de pose
   if { ! [ info exists panneau(acqzadko,$visuNo,pose) ] } {
      set panneau(acqzadko,$visuNo,pose) "$parametres(acqzadko,$visuNo,pose)"
   }

   #--- Valeur par defaut du binning
   if { ! [ info exists panneau(acqzadko,$visuNo,binning) ] } {
      set panneau(acqzadko,$visuNo,binning) "$parametres(acqzadko,$visuNo,bin)"
   }

   #--- Valeur par defaut de la qualite
   if { ! [ info exists panneau(acqzadko,$visuNo,format) ] } {
      set panneau(acqzadko,$visuNo,format) "$parametres(acqzadko,$visuNo,format)"
   }

   #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
   set panneau(acqzadko,$visuNo,obt,0) "$caption(acqzadko,ouv)"
   set panneau(acqzadko,$visuNo,obt,1) "$caption(acqzadko,ferme)"
   set panneau(acqzadko,$visuNo,obt,2) "$caption(acqzadko,auto)"
   #--- Obturateur par defaut : Synchro
   if { ! [ info exists panneau(acqzadko,$visuNo,obt) ] } {
      set panneau(acqzadko,$visuNo,obt) "$parametres(acqzadko,$visuNo,obt)"
   }

   #--- Liste des modes disponibles
   set panneau(acqzadko,$visuNo,list_mode) [ list $caption(acqzadko,uneimage) $caption(acqzadko,serie) $caption(acqzadko,continu) \
      $caption(acqzadko,continu_1) $caption(acqzadko,continu_2) ]

   #--- Initialisation des modes
   set panneau(acqzadko,$visuNo,mode,1) "$panneau(acqzadko,$visuNo,This).mode.une"
   set panneau(acqzadko,$visuNo,mode,2) "$panneau(acqzadko,$visuNo,This).mode.serie"
   set panneau(acqzadko,$visuNo,mode,3) "$panneau(acqzadko,$visuNo,This).mode.continu"
   set panneau(acqzadko,$visuNo,mode,4) "$panneau(acqzadko,$visuNo,This).mode.serie_1"
   set panneau(acqzadko,$visuNo,mode,5) "$panneau(acqzadko,$visuNo,This).mode.continu_1"
   #--- Mode par defaut : Une image
   if { ! [ info exists panneau(acqzadko,$visuNo,mode) ] } {
      set panneau(acqzadko,$visuNo,mode) "$parametres(acqzadko,$visuNo,mode)"
   } else {
      if { $panneau(acqzadko,$visuNo,mode) > 5 } {
         #--- je positionne mode=1 si un mode > 5 dans le fichier de configuration,
         #--- car les modes 6 et 7 n'exitent plus. Ils sont deplaces dans l'outil d'acquisition video.
         set panneau(acqzadko,$visuNo,mode) 1
      }
   }

   #--- Initialisation d'autres variables
   set panneau(acqzadko,$visuNo,index)                "1"
   set panneau(acqzadko,$visuNo,indexEndSerie)        ""
   set panneau(acqzadko,$visuNo,indexEndSerieContinu) ""
   set panneau(acqzadko,$visuNo,nom_image)            ""
   set panneau(acqzadko,$visuNo,extension)            "$conf(extension,defaut)"
   set panneau(acqzadko,$visuNo,indexer)              "0"
   set panneau(acqzadko,$visuNo,indexerContinue)      "1"
   set panneau(acqzadko,$visuNo,nb_images)            "5"
   set panneau(acqzadko,$visuNo,session_ouverture)    "1"
   set panneau(acqzadko,$visuNo,avancement_acq)       "$parametres(acqzadko,$visuNo,avancement_acq)"
   set panneau(acqzadko,$visuNo,enregistrer)          "$parametres(acqzadko,$visuNo,enregistrer)"
   set panneau(acqzadko,$visuNo,dispTimeAfterId)      ""
   #--- Mise en place de l'interface graphique
   acqzadkoBuildIF $visuNo

   pack $panneau(acqzadko,$visuNo,mode,$panneau(acqzadko,$visuNo,mode)) -anchor nw -fill x

   #--- Surveillance de la connexion d'une camera
   ::confVisu::addCameraListener $visuNo "::acqzadko::adaptOutilAcqzadko $visuNo"
   #--- Surveillance de l'ajout ou de la suppression d'une extension
   trace add variable ::audace(extensionList) write "::acqzadko::initExtensionList $visuNo"

   #---
   return $panneau(acqzadko,$visuNo,This)
}
#***** Fin de la procedure createPluginInstance*****************

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::acqzadko::deletePluginInstance { visuNo } {
   global conf panneau

   #--- Je desactive la surveillance de la connexion d'une camera
   ::confVisu::removeCameraListener $visuNo "::acqzadko::adaptOutilAcqzadko $visuNo"
   #--- Je desactive la surveillance de l'ajout ou de la suppression d'une extension
   trace remove variable ::audace(extensionList) write "::acqzadko::initExtensionList $visuNo"

   #---
   set conf(acqzadko,avancement,position) $panneau(acqzadko,$visuNo,avancement,position)
   #relancer camera.exe
   if {([file exists "[pwd]/../bin/camera.exe"]==1)&&([lindex [hostaddress] end]=="ikon")} {
       package require twapi
       set res [twapi::get_process_ids -glob -name "camera.exe"]
       if {($res=="")&&($visuNo=="1")} {
          set res [twapi::create_process "[pwd]/../bin/camera.exe" -startdir "[pwd]/../bin"]
       }
   }

   #set process_id [lindex $res 0]
   #set thread_id [lindex $res 1]
   #---
   destroy $panneau(acqzadko,$visuNo,This)
   destroy $panneau(acqzadko,$visuNo,This).pose.but.menu
   destroy $panneau(acqzadko,$visuNo,This).binning.but.menu
   destroy $panneau(acqzadko,$visuNo,This).format.but.menu
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::acqzadko::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "" }
      display      { return "panel" }
      multivisu    { return 1 }
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::acqzadko::getPluginTitle { } {
   global caption

   return "$caption(acqzadko,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::acqzadko::getPluginHelp { } {
   return "acqzadko.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::acqzadko::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
#  getPluginDirectory
#     retourne le repertoire du plugin
#------------------------------------------------------------
proc ::acqzadko::getPluginDirectory { } {
   return "acqzadko"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::acqzadko::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#***** Procedure Demarrageacqzadko ********************************
proc ::acqzadko::Demarrageacqzadko { visuNo } {
   global audace caption

   #--- Creation du sous-repertoire a la date du jour
   #--- en mode automatique s'il n'existe pas
   ::cwdWindow::updateImageDirectory

   #--- Gestion du fichier de log
   #--- Creation du nom du fichier log
   set nom_generique "acqzadko-visu$visuNo-"
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
   set ::acqzadko::fichier_log [ file join $audace(rep_images) [ append $file_log $nom_generique $formatdate ".log" ] ]

   #--- Ouverture du fichier de log
   if { [ catch { open $::acqzadko::fichier_log a } ::acqzadko::log_id($visuNo) ] } {
      Message $visuNo console $caption(acqzadko,pbouvfichcons)
      tk_messageBox -title $caption(acqzadko,pb) -type ok \
         -message $caption(acqzadko,pbouvfich)
      #--- Note importante : Je detecte si j'ai un pb a l'ouverture du fichier, mais je ne sais pas traiter ce cas :
      #--- Il faudrait interdire l'ouverture du panneau, mais le processus est deja lance a ce stade...
      #--- Tout ce que je fais, c'est inviter l'utilisateur a changer d'outil !
   } else {
      #--- En-tete du fichier
      Message $visuNo log $caption(acqzadko,ouvsess) [ package version acqzadko ]
      set date [clock format [clock seconds] -format "%A %d %B %Y"]
      set date [ ::tkutil::transalteDate $date ]
      set heure $audace(tu,format,hmsint)
      Message $visuNo consolog $caption(acqzadko,affheure) $date $heure
      #--- Definition du binding pour declencher l'acquisition (ou l'arret) par Echap.
      bind all <Key-Escape> "::acqzadko::Stop $visuNo"
   }
}
#***** Fin de la procedure Demarrageacqzadko **********************

#***** Procedure Arretacqzadko ************************************
proc ::acqzadko::Arretacqzadko { visuNo } {
   global audace caption panneau

   #--- Fermeture du fichier de log
   if { [ info exists ::acqzadko::log_id($visuNo) ] } {
      set heure $audace(tu,format,hmsint)
      #--- Je m'assure que le fichier se termine correctement, en particulier pour le cas ou il y
      #--- a eu un probleme a l'ouverture (c'est un peu une rustine...)
      if { [ catch { Message $visuNo log $caption(acqzadko,finsess) $heure } bug ] } {
         Message $visuNo console $caption(acqzadko,pbfermfichcons)
      } else {
         Message $visuNo console "\n"
         close $::acqzadko::log_id($visuNo)
         unset ::acqzadko::log_id($visuNo)
      }
   }
   #--- Re-initialisation de la session
   set panneau(acqzadko,$visuNo,session_ouverture) "1"
   #--- Desactivation du binding pour declencher l'acquisition (ou l'arret) par Echap.
   bind all <Key-Escape> { }
}
#***** Fin de la procedure Arretacqzadko **************************

#***** Procedure initExtensionList ********************************
proc ::acqzadko::initExtensionList { visuNo { a "" } { b "" } { c "" } } {
   global conf panneau

   #--- Mise a jour de l'extension par defaut
   set panneau(acqzadko,$visuNo,extension) $conf(extension,defaut)
   set camItem [ ::confVisu::getCamItem $visuNo ]
   set extensionList " $::audace(extensionList) [ confCam::getPluginProperty $camItem rawExtension ]"

   #--- Mise a jour de la liste des extensions disponibles pour le mode "Une seule image"
   $panneau(acqzadko,$visuNo,This).mode.une.nom.extension.menu delete 0 20
   foreach extension $extensionList {
      $panneau(acqzadko,$visuNo,This).mode.une.nom.extension.menu add radiobutton -label "$extension" \
         -indicatoron "1" \
         -value "$extension" \
         -variable panneau(acqzadko,$visuNo,extension) \
         -command " "
   }
   #--- Mise a jour de la liste des extensions disponibles pour le mode "Serie d'images"
   $panneau(acqzadko,$visuNo,This).mode.serie.nom.extension.menu delete 0 20
   foreach extension $extensionList {
      $panneau(acqzadko,$visuNo,This).mode.serie.nom.extension.menu add radiobutton -label "$extension" \
         -indicatoron "1" \
         -value "$extension" \
         -variable panneau(acqzadko,$visuNo,extension) \
         -command " "
   }
   #--- Mise a jour de la liste des extensions disponibles pour le mode "Continu"
   $panneau(acqzadko,$visuNo,This).mode.continu.nom.extension.menu delete 0 20
   foreach extension $extensionList {
      $panneau(acqzadko,$visuNo,This).mode.continu.nom.extension.menu add radiobutton -label "$extension" \
         -indicatoron "1" \
         -value "$extension" \
         -variable panneau(acqzadko,$visuNo,extension) \
         -command " "
   }
   #--- Mise a jour de la liste des extensions disponibles pour le mode "Series d'images en continu avec intervalle entre chaque serie"
   $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.extension.menu delete 0 20
   foreach extension $extensionList {
      $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.extension.menu add radiobutton -label "$extension" \
         -indicatoron "1" \
         -value "$extension" \
         -variable panneau(acqzadko,$visuNo,extension) \
         -command " "
   }
   #--- Mise a jour de la liste des extensions disponibles pour le mode "Continu avec intervalle entre chaque image"
   $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.extension.menu delete 0 20
   foreach extension $extensionList {
      $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.extension.menu add radiobutton -label "$extension" \
         -indicatoron "1" \
         -value "$extension" \
         -variable panneau(acqzadko,$visuNo,extension) \
         -command " "
   }
}
#***** Fin de la procedure initExtensionList **********************

#***** Procedure adaptOutilAcqzadko *******************************
proc ::acqzadko::adaptOutilAcqzadko { visuNo args } {
   global conf panneau

   set panneau(acqzadko,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
   set panneau(acqzadko,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqzadko,$visuNo,camItem)]

   #--- petits reccorcis bien utiles
   set camItem $panneau(acqzadko,$visuNo,camItem)
   set camNo   $panneau(acqzadko,$visuNo,camNo)
   if { $camNo == "0" } {
      #--- La camera n'a pas ete encore selectionnee
      set camProduct ""
   } else {
      set camProduct [ cam$camNo product ]
   }

   #--- widgets de pose
   if { [ confCam::getPluginProperty $camItem longExposure ] == "1" } {
      #--- j'affiche les boutons standard de choix de pose
      pack $panneau(acqzadko,$visuNo,This).pose.but -side left
      pack $panneau(acqzadko,$visuNo,This).pose.lab -side right
      pack $panneau(acqzadko,$visuNo,This).pose.entr -side left -fill both -expand true
      #---- je masque le widget specifique
      pack forget $panneau(acqzadko,$visuNo,This).pose.conf
   } else {
      #--- je masque les widgets standards
      pack forget $panneau(acqzadko,$visuNo,This).pose.but
      pack forget $panneau(acqzadko,$visuNo,This).pose.lab
      pack forget $panneau(acqzadko,$visuNo,This).pose.entr
      #--- j'affiche le bouton specifique
      pack $panneau(acqzadko,$visuNo,This).pose.conf -fill x -expand true -ipady 3
   }

   #--- widgets de binning
   if { [ ::confCam::getPluginProperty $camItem hasBinning ] == "1" } {
      $panneau(acqzadko,$visuNo,This).binning.but.menu delete 0 20
      set binningList [ ::confCam::getPluginProperty $camItem binningList ]
      foreach binning $binningList {
         $panneau(acqzadko,$visuNo,This).binning.but.menu add radiobutton -label "$binning" \
            -indicatoron "1" \
            -value $binning \
            -variable panneau(acqzadko,$visuNo,binning) \
            -command " "
      }
      #--- je verifie que le binning preselectionne existe dans la liste
      if { [lsearch $binningList $panneau(acqzadko,$visuNo,binning) ] == -1 } {
         #--- si le binning n'existe pas je selectionne la première valeur par defaut
         set  panneau(acqzadko,$visuNo,binning) [lindex $binningList 0]
      }
      #--- j'affiche la frame du binning
      pack $panneau(acqzadko,$visuNo,This).binning -side top -fill x -before $panneau(acqzadko,$visuNo,This).status
   } else {
      #--- je masque la frame du binning
      pack forget $panneau(acqzadko,$visuNo,This).binning
   }

   #--- widgets du format d'image
   if { [ ::confCam::getPluginProperty $camItem hasFormat ] == "1" } {
      $panneau(acqzadko,$visuNo,This).format.but.menu delete 0 20
      #--- j'affiche le bouton du format
      set formatList [ ::confCam::getPluginProperty $camItem formatList ]
      foreach format $formatList {
         $panneau(acqzadko,$visuNo,This).format.but.menu add radiobutton -label $format \
            -indicatoron "1" \
            -value $format \
            -variable panneau(acqzadko,$visuNo,format) \
            -command " "
      }
      #--- je verifie que le format preselectionne existe dans la liste
      if { [lsearch $formatList $panneau(acqzadko,$visuNo,format) ] == -1 } {
         #--- si le format n'existe pas je selectionne la première valeur par defaut
         set  panneau(acqzadko,$visuNo,format) [lindex $formatList 0]
      }
      #--- j'affiche la frame du format
      pack $panneau(acqzadko,$visuNo,This).format -side top -fill x -before $panneau(acqzadko,$visuNo,This).status
   } else {
      #--- je masque la frame du format
      pack forget $panneau(acqzadko,$visuNo,This).format
   }

   #--- widgets de l'obturateur
   if { [ ::confCam::getPluginProperty $camItem hasShutter ] == "1" } {
      if { ! [ info exists conf($camProduct,foncobtu) ] } {
         set conf($camProduct,foncobtu) "2"
      } else {
         if { $conf($camProduct,foncobtu) == "0" } {
            set panneau(acqzadko,$visuNo,obt) "0"
         } elseif { $conf($camProduct,foncobtu) == "1" } {
            set panneau(acqzadko,$visuNo,obt) "1"
         } elseif { $conf($camProduct,foncobtu) == "2" } {
            set panneau(acqzadko,$visuNo,obt) "2"
         }
      }
      $panneau(acqzadko,$visuNo,This).obt.lab configure -text $panneau(acqzadko,$visuNo,obt,$panneau(acqzadko,$visuNo,obt))
      #--- j'affiche la frame de l'obturateur
      pack $panneau(acqzadko,$visuNo,This).obt -side top -fill x -before $panneau(acqzadko,$visuNo,This).status
   } else {
      #--- je masque la frame de l'obturateur
      pack forget $panneau(acqzadko,$visuNo,This).obt
   }

   #--- je mets a jour la liste des extensions
   ::acqzadko::initExtensionList $visuNo
}

#***** Procedure chargerVariable *******************************
proc ::acqzadko::chargerVariable { visuNo } {
   variable parametres

   #--- Ouverture du fichier de parametres
   set fichier [ file join $::audace(rep_home) acqzadko.ini ]
   if { [ file exists $fichier ] } {
      source $fichier
   }

   #--- Creation des variables si elles n'existent pas
   if { ! [ info exists parametres(acqzadko,$visuNo,pose) ] }           { set parametres(acqzadko,$visuNo,pose)   "5" }   ; #--- Temps de pose : 5s
   if { ! [ info exists parametres(acqzadko,$visuNo,bin) ] }            { set parametres(acqzadko,$visuNo,bin)    "1x1" } ; #--- Binning : 2x2
   if { ! [ info exists parametres(acqzadko,$visuNo,format) ] }         { set parametres(acqzadko,$visuNo,format) "" }    ; #--- Format des APN
   if { ! [ info exists parametres(acqzadko,$visuNo,obt) ] }            { set parametres(acqzadko,$visuNo,obt)    "2" }   ; #--- Obturateur : Synchro
   if { ! [ info exists parametres(acqzadko,$visuNo,mode) ] }           { set parametres(acqzadko,$visuNo,mode)   "1" }   ; #--- Mode : Une image
   if { ! [ info exists parametres(acqzadko,$visuNo,avancement_acq) ] } {
      if { $visuNo == "1" } {
         set parametres(acqzadko,$visuNo,avancement_acq) "1" ; #--- Barre de progression de la pose : Oui
      } else {
         set parametres(acqzadko,$visuNo,avancement_acq) "0" ; #--- Barre de progression de la pose : Non
      }
   }
   if { ! [ info exists parametres(acqzadko,$visuNo,enregistrer) ] } { set parametres(acqzadko,$visuNo,enregistrer) "1" } ; #--- Sauvegarde des images : Oui

   #--- Creation des variables de la boite de configuration si elles n'existent pas
   ::acqzadkoSetup::initToConf $visuNo

   #--- Creation des variables de la boite de decalage du telescope si elles n'existent pas
   ::DlgShiftZadko::initToConf $visuNo
}
#***** Fin de la procedure chargerVariable *********************

#***** Procedure enregistrerVariable ***************************
proc ::acqzadko::enregistrerVariable { visuNo } {
   variable parametres
   global panneau

   #---
   set panneau(acqzadko,$visuNo,mode)              [ expr [ lsearch "$panneau(acqzadko,$visuNo,list_mode)" "$panneau(acqzadko,$visuNo,mode_en_cours)" ] + 1 ]
   #---
   set parametres(acqzadko,$visuNo,pose)           $panneau(acqzadko,$visuNo,pose)
   set parametres(acqzadko,$visuNo,bin)            $panneau(acqzadko,$visuNo,binning)
   set parametres(acqzadko,$visuNo,format)         $panneau(acqzadko,$visuNo,format)
   set parametres(acqzadko,$visuNo,obt)            $panneau(acqzadko,$visuNo,obt)
   set parametres(acqzadko,$visuNo,mode)           $panneau(acqzadko,$visuNo,mode)
   set parametres(acqzadko,$visuNo,avancement_acq) $panneau(acqzadko,$visuNo,avancement_acq)
   set parametres(acqzadko,$visuNo,enregistrer)    $panneau(acqzadko,$visuNo,enregistrer)

   #--- Sauvegarde des parametres
   catch {
     set nom_fichier [ file join $::audace(rep_home) acqzadko.ini ]
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
proc ::acqzadko::startTool { { visuNo 1 } } {
   global panneau

   #--- On cree la variable de configuration des mots cles
   if { ! [ info exists ::conf(acqzadko,keywordConfigName) ] } { set ::conf(acqzadko,keywordConfigName) "default" }

   #--- Creation des fenetres auxiliaires si necessaire
   if { $panneau(acqzadko,$visuNo,mode) == "4" } {
      ::acqzadko::Intervalle_continu_1 $visuNo
   } elseif { $panneau(acqzadko,$visuNo,mode) == "5" } {
      ::acqzadko::Intervalle_continu_2 $visuNo
   }

   #--- Je selectionne les mots cles selon les exigences de l'outil
   ::acqzadko::configToolKeywords $visuNo

   ::acqzadko::adaptOutilAcqzadko $visuNo
}
#***** Fin de la procedure startTool ***************************

#***** Procedure stopTool **************************************
proc ::acqzadko::stopTool { { visuNo 1 } } {
   global panneau

   #--- Je verifie si une operation est en cours
   if { $panneau(acqzadko,$visuNo,pose_en_cours) == 1 } {
      return -1
   }

   #--- Sauvegarde de la configuration de prise de vue
   ::acqzadko::enregistrerVariable $visuNo

   #--- Je supprime la liste des mots clefs non modifiables
   ::keyword::setKeywordState $visuNo $::conf(acqzadko,keywordConfigName) [ list ]

   #--- Destruction des fenetres auxiliaires et sauvegarde de leurs positions si elles existent
   ::acqzadko::recup_position $visuNo

   Arretacqzadko $visuNo
}
#***** Fin de la procedure stopTool ****************************

#***** Procedure de changement du mode d'acquisition ***********
proc ::acqzadko::ChangeMode { visuNo { mode "" } } {
   global panneau

   pack forget $panneau(acqzadko,$visuNo,mode,$panneau(acqzadko,$visuNo,mode)) -anchor nw -fill x

   if { $mode != "" } {
      #--- j'applique le mode passe en parametre
      set panneau(acqzadko,$visuNo,mode_en_cours) $mode
   }

   set panneau(acqzadko,$visuNo,mode) [ expr [ lsearch "$panneau(acqzadko,$visuNo,list_mode)" "$panneau(acqzadko,$visuNo,mode_en_cours)" ] + 1 ]
   if { $panneau(acqzadko,$visuNo,mode) == "1" } {
      ::acqzadko::recup_position $visuNo
   } elseif { $panneau(acqzadko,$visuNo,mode) == "2" } {
     ::acqzadko::recup_position $visuNo
   } elseif { $panneau(acqzadko,$visuNo,mode) == "3" } {
      ::acqzadko::recup_position $visuNo
   } elseif { $panneau(acqzadko,$visuNo,mode) == "4" } {
      ::acqzadko::Intervalle_continu_1 $visuNo
   } elseif { $panneau(acqzadko,$visuNo,mode) == "5" } {
      ::acqzadko::Intervalle_continu_2 $visuNo
   }
   pack $panneau(acqzadko,$visuNo,mode,$panneau(acqzadko,$visuNo,mode)) -anchor nw -fill x
}
#***** Fin de la procedure de changement du mode d'acquisition *

#***** Procedure de changement de l'obturateur *****************
proc ::acqzadko::ChangeObt { visuNo } {
   global panneau

   #---
   set camItem [ ::confVisu::getCamItem $visuNo ]
   set result [::confCam::setShutter $camItem $panneau(acqzadko,$visuNo,obt) ]
   if { $result != -1 } {
      set panneau(acqzadko,$visuNo,obt) $result
      $panneau(acqzadko,$visuNo,This).obt.lab configure -text $panneau(acqzadko,$visuNo,obt,$panneau(acqzadko,$visuNo,obt))
   }
}
#***** Fin de la procedure de changement de l'obturateur *******

#----------------------------------------------------------------------------
# setObt
#   force l'obturateur de la camera a l'etat donnee en parametre
#
# parametres :
#    visuNo: numero de la visu
#    state : etat de l'obturateur (0=ouvert 1=ferme 2=synchro )
#----------------------------------------------------------------------------
proc ::acqzadko::setShutter { visuNo state } {
   global panneau

   set camItem [ ::confVisu::getCamItem $visuNo ]
   if { [ ::confCam::getPluginProperty $camItem hasShutter ] == 1 } {
      set panneau(acqzadko,$visuNo,obt) [::confCam::setShutter $camItem $state  "set" ]
      $panneau(acqzadko,$visuNo,This).obt.lab configure -text $panneau(acqzadko,$visuNo,obt,$panneau(acqzadko,$visuNo,obt))
   }
}

#------------------------------------------------------------
# testParametreAcquisition
#   Tests generaux d'integrite de la requete
#
# return
#   retourne oui ou non
#------------------------------------------------------------
proc ::acqzadko::testParametreAcquisition { visuNo } {
   global audace caption panneau

   #--- Recopie de l'extension des fichiers image
   set ext $panneau(acqzadko,$visuNo,extension)
   set camItem [ ::confVisu::getCamItem $visuNo ]

   #--- Desactive le bouton Go, pour eviter un double appui
   $panneau(acqzadko,$visuNo,This).go_stop.but configure -state disabled

   #------ Tests generaux de l'integrite de la requete
   set integre oui

   #--- Tester si une camera est bien selectionnee
   if { [ ::confVisu::getCamItem $visuNo ] == "" } {
      ::audace::menustate disabled
      set choix [ tk_messageBox -title $caption(acqzadko,pb) -type ok \
         -message $caption(acqzadko,selcam) ]
      set integre non
      if { $choix == "ok" } {
         #--- Ouverture de la fenetre de selection des cameras
         ::confCam::run
      }
      ::audace::menustate normal
   }

   #--- Le temps de pose existe-t-il ?
   if { $panneau(acqzadko,$visuNo,pose) == "" } {
      tk_messageBox -title $caption(acqzadko,pb) -type ok \
         -message $caption(acqzadko,saistps)
      set integre non
   }

   #--- Tests d'integrite specifiques a chaque mode d'acquisition
   if { $integre == "oui" } {
      #--- Branchement selon le mode de prise de vue
      switch $panneau(acqzadko,$visuNo,mode) {
         1  {
            #--- Mode une image
            if { $panneau(acqzadko,$visuNo,indexer) == "1" } {
               #--- Verifie que l'index existe
               if { $panneau(acqzadko,$visuNo,index) == "" } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                      -message $caption(acqzadko,saisind)
                  set integre non
               }
            }
            #--- Pas de decalage du telescope
            set panneau(DlgShiftZadko,buttonShift) "0"
         }
         2  {
            #--- Mode serie
            #--- Les tests ne sont pas necessaires pendant une simulation
            if { $panneau(acqzadko,$visuNo,simulation) == "0" } {
               #--- Verifier qu'il y a bien un nom de fichier
               if { $panneau(acqzadko,$visuNo,nom_image) == "" } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,donnomfich)
                  set integre non
               }
               #--- Verifier que le nom de fichier n'a pas d'espace
               if { [ llength $panneau(acqzadko,$visuNo,nom_image) ] > "1" } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,nomblanc)
                  set integre non
               }
               #--- Verifier que l'index existe
               if { $panneau(acqzadko,$visuNo,index) == "" } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                      -message $caption(acqzadko,saisind)
                  set integre non
               }
               #--- Envoyer un warning si l'index n'est pas a 1
               if { $panneau(acqzadko,$visuNo,index) != "1" && $panneau(acqzadko,$visuNo,verifier_index_depart) == 1 } {
                  set confirmation [tk_messageBox -title $caption(acqzadko,conf) -type yesno \
                     -message $caption(acqzadko,indpasun)]
                  if { $confirmation == "no" } {
                     set integre non
                  }
               }
               #--- Verifier que le nombre de poses existe
               if { $panneau(acqzadko,$visuNo,nb_images) == "" } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                      -message $caption(acqzadko,nbinv)
                  set integre non
               }
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShiftZadko,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,seltel) ]
                  set integre non
                  if { $choix == "ok" } {
                     #--- Ouverture de la fenetre de selection des cameras
                     ::confTel::run
                  }
                  ::audace::menustate normal
               }
            }
         }
         3  {
            #--- Mode continu
            #--- Les tests ne sont necessaires que si l'enregistrement est demande
            if { $panneau(acqzadko,$visuNo,enregistrer) == "1" } {
               #--- Verifier qu'il y a bien un nom de fichier
               if { $panneau(acqzadko,$visuNo,nom_image) == "" } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,donnomfich)
                  set integre non
               }
               #--- Verifier que le nom de fichier n'a pas d'espace
               if { [ llength $panneau(acqzadko,$visuNo,nom_image) ] > "1" } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,nomblanc)
                  set integre non
               }
               #--- Verifier que l'index existe
               if { $panneau(acqzadko,$visuNo,indexerContinue) == "1" } {
                  if { $panneau(acqzadko,$visuNo,index) == "" } {
                     tk_messageBox -title $caption(acqzadko,pb) -type ok \
                         -message $caption(acqzadko,saisind)
                     set integre non
                  }
               }
               #--- Envoyer un warning si l'index n'est pas a 1
               if { $panneau(acqzadko,$visuNo,indexerContinue) == "1" } {
                  if { $panneau(acqzadko,$visuNo,index) != "1" && $panneau(acqzadko,$visuNo,verifier_index_depart) == 1 } {
                     set confirmation [tk_messageBox -title $caption(acqzadko,conf) -type yesno \
                        -message $caption(acqzadko,indpasun)]
                     if { $confirmation == "no" } {
                        set integre non
                     }
                  }
               }
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShiftZadko,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,seltel) ]
                  set integre non
                  if { $choix == "ok" } {
                     #--- Ouverture de la fenetre de selection des cameras
                     ::confTel::run
                  }
                  ::audace::menustate normal
               }
            }
         }
         4  {
            #--- Mode series d'images en continu avec intervalle entre chaque serie
            #--- Verifier qu'il y a bien un nom de fichier
            if { $panneau(acqzadko,$visuNo,nom_image) == "" } {
               tk_messageBox -title $caption(acqzadko,pb) -type ok \
                  -message $caption(acqzadko,donnomfich)
               set integre non
            }
            #--- Verifier que le nom de fichier n'a pas d'espace
            if { [ llength $panneau(acqzadko,$visuNo,nom_image) ] > "1" } {
               tk_messageBox -title $caption(acqzadko,pb) -type ok \
                  -message $caption(acqzadko,nomblanc)
               set integre non
            }
            #--- Verifier que l'index existe
            if { $panneau(acqzadko,$visuNo,index) == "" } {
               tk_messageBox -title $caption(acqzadko,pb) -type ok \
                   -message $caption(acqzadko,saisind)
               set integre non
            }
            #--- Envoyer un warning si l'index n'est pas a 1
            if { $panneau(acqzadko,$visuNo,index) != "1" && $panneau(acqzadko,$visuNo,verifier_index_depart) == 1 } {
               set confirmation [tk_messageBox -title $caption(acqzadko,conf) -type yesno \
                  -message $caption(acqzadko,indpasun)]
               if { $confirmation == "no" } {
                  set integre non
               }
            }
            #--- Verifier que le nombre de poses existe
            if { $panneau(acqzadko,$visuNo,nb_images) == "" } {
               tk_messageBox -title $caption(acqzadko,pb) -type ok \
                   -message $caption(acqzadko,nbinv)
               set integre non
            }
            #--- Verifier que la simulation a ete lancee
            if { $panneau(acqzadko,$visuNo,intervalle) == "...." } {
               tk_messageBox -title $caption(acqzadko,pb) -type ok \
                  -message $caption(acqzadko,interinv_2)
               set integre non
            #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
            } elseif { ( $panneau(acqzadko,$visuNo,intervalle) > $panneau(acqzadko,$visuNo,intervalle_1) ) && \
              ( $panneau(acqzadko,$visuNo,intervalle) != "xxxx" ) } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,interinv_1)
                  set integre non
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShiftZadko,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,seltel) ]
                  set integre non
                  if { $choix == "ok" } {
                     #--- Ouverture de la fenetre de selection des cameras
                     ::confTel::run
                  }
                  ::audace::menustate normal
               }
            }
         }
         5  {
            #--- Mode continu avec intervalle entre chaque image
            #--- Les tests ne sont necessaires que si l'enregistrement est demande
            if { $panneau(acqzadko,$visuNo,enregistrer) == "1" } {
               #--- Verifier qu'il y a bien un nom de fichier
               if { $panneau(acqzadko,$visuNo,nom_image) == "" } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,donnomfich)
                  set integre non
               }
               #--- Verifier que le nom de fichier n'a pas d'espace
               if { [ llength $panneau(acqzadko,$visuNo,nom_image) ] > "1" } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,nomblanc)
                  set integre non
               }
               #--- Verifier que l'index existe
               if { $panneau(acqzadko,$visuNo,index) == "" } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                      -message $caption(acqzadko,saisind)
                  set integre non
               }
               #--- Envoyer un warning si l'index n'est pas a 1
               if { $panneau(acqzadko,$visuNo,index) != "1" && $panneau(acqzadko,$visuNo,verifier_index_depart) == 1 } {
                  set confirmation [tk_messageBox -title $caption(acqzadko,conf) -type yesno \
                     -message $caption(acqzadko,indpasun)]
                  if { $confirmation == "no" } {
                     set integre non
                  }
               }
               #--- Verifier que la simulation a ete lancee
               if { $panneau(acqzadko,$visuNo,intervalle) == "...." } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,interinv_2)
                  set integre non
               #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
               } elseif { ( $panneau(acqzadko,$visuNo,intervalle) > $panneau(acqzadko,$visuNo,intervalle_2) ) && \
                 ( $panneau(acqzadko,$visuNo,intervalle) != "xxxx" ) } {
                     tk_messageBox -title $caption(acqzadko,pb) -type ok \
                        -message $caption(acqzadko,interinv_1)
                     set integre non
               }
            } else {
               #--- Verifier que la simulation a ete lancee
               if { $panneau(acqzadko,$visuNo,intervalle) == "...." } {
                  tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,interinv_2)
                  set integre non
               #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
               } elseif { ( $panneau(acqzadko,$visuNo,intervalle) > $panneau(acqzadko,$visuNo,intervalle_2) ) && \
                 ( $panneau(acqzadko,$visuNo,intervalle) != "xxxx" ) } {
                     tk_messageBox -title $caption(acqzadko,pb) -type ok \
                        -message $caption(acqzadko,interinv_1)
                     set integre non
               }
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShiftZadko,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqzadko,pb) -type ok \
                     -message $caption(acqzadko,seltel) ]
                  set integre non
                  if { $choix == "ok" } {
                     #--- Ouverture de la fenetre de selection des cameras
                     ::confTel::run
                  }
                  ::audace::menustate normal
               }
            }
         }
      }
   }
   #------ Fin des tests de l'integrite de la requete

   #--- Apres les tests d'integrite, je reactive le bouton "GO"
   $panneau(acqzadko,$visuNo,This).go_stop.but configure -state normal

   return $integre

}

#------------------------------------------------------------
# startAcquisitionUneImage
#   fait l'acquisition d'une image
#
# Parameters
#   visuNo
#   expTime
#   binning
#   fileName
# return
#   retourne rien
#------------------------------------------------------------
proc ::acqzadko::startAcquisitionUneImage { visuNo expTime binning fileName} {

   set ::panneau(acqzadko,$visuNo,pose)      $expTime
   set ::panneau(acqzadko,$visuNo,binning)   $binning
   set ::panneau(acqzadko,$visuNo,nom_image) $fileName
   set ::panneau(acqzadko,$visuNo,mode)      "1"
   set ::panneau(acqzadko,$visuNo,indexer)   "0"

   ChangeMode $visuNo $::caption(acqzadko,uneimage)

   #--- je lance l'acquisition
   set ::panneau(acqzadko,$visuNo,acqImageEnd) "0"
   ::acqzadko::Go $visuNo
   #--- j'attends la fin de l'acquisition
   vwait ::panneau(acqzadko,$visuNo,acqImageEnd)

   if { $fileName != "" } {
      ::acqzadko::SauveUneImage $visuNo
   }
}

#------------------------------------------------------------
# startAcquisitionSerieImage
#   fait l'acquisition d'une image (procedure appelee depuis un autre outil)
#
# Parameters
#   visuNo
#   expTime
#   binning
#   fileName
#   imageNb
# return
#   retourne rien
#------------------------------------------------------------
proc ::acqzadko::startAcquisitionSerieImage { visuNo expTime binning fileName imageNb} {

   set ::panneau(acqzadko,$visuNo,pose)      $expTime
   set ::panneau(acqzadko,$visuNo,binning)   $binning
   set ::panneau(acqzadko,$visuNo,nom_image) $fileName
   set ::panneau(acqzadko,$visuNo,nb_images) $imageNb
   set ::panneau(acqzadko,$visuNo,indexer)   "1"
   set ::panneau(acqzadko,$visuNo,index)     "1"

   ChangeMode $visuNo $::caption(acqzadko,serie)

   #--- je lance les acquisitions
   set ::panneau(acqzadko,$visuNo,acqImageEnd) "0"
   ::acqzadko::Go $visuNo
   #--- j'attends la fin des acquisitions
   vwait ::panneau(acqzadko,$visuNo,acqImageEnd)
}

#------------------------------------------------------------
# stopAcquisition
#   arrete une acquisition en cours (procedure appelee depuis un autre outil)
#
# Parameters
#   visuNo
# return
#   retourne rien
#------------------------------------------------------------
proc ::acqzadko::stopAcquisition { visuNo } {
   global panneau

   if { $panneau(acqzadko,$visuNo,pose_en_cours) == 1 } {
      Stop $visuNo
   }
}

#***** Procedure Go (appui sur le bouton Go/Stop) *********
proc ::acqzadko::Go { visuNo } {
   global audace caption panneau

   set camItem [::confVisu::getCamItem $visuNo]
   set camNo $panneau(acqzadko,$visuNo,camNo)

   #--- Ouverture du fichier historique
   if { $panneau(acqzadko,$visuNo,save_file_log) == "1" } {
      if { $panneau(acqzadko,$visuNo,session_ouverture) == "1" } {
         Demarrageacqzadko $visuNo
         set panneau(acqzadko,$visuNo,session_ouverture) "0"
      }
   }

   #--- je verifie l'integrite des parametres
   set integre [testParametreAcquisition $visuNo]
   if { $integre != "oui" } {
      return
   }

   #--- Modification du bouton, pour eviter un second lancement
   $panneau(acqzadko,$visuNo,This).go_stop.but configure -text $caption(acqzadko,stop) -command "::acqzadko::Stop $visuNo"
   #--- Verrouille tous les boutons et champs de texte pendant les acquisitions
   $panneau(acqzadko,$visuNo,This).pose.but configure -state disabled
   $panneau(acqzadko,$visuNo,This).pose.entr configure -state disabled
   $panneau(acqzadko,$visuNo,This).binning.but configure -state disabled
   $panneau(acqzadko,$visuNo,This).format.but configure -state disabled
   $panneau(acqzadko,$visuNo,This).obt.but configure -state disabled
   $panneau(acqzadko,$visuNo,This).mode.but configure -state disabled
   #--- Desactive toute demande d'arret
   set panneau(acqzadko,$visuNo,demande_arret) "0"
   #--- Pose en cours
   set panneau(acqzadko,$visuNo,pose_en_cours) "1"
   #--- Enregistrement d'une image interrompue
   set panneau(acqzadko,$visuNo,sauve_img_interrompue) "0"

   set catchResult [catch {
      #--- Cas particulier du passage WebCam LP en WebCam normale pour inhiber la barre progression
      if { ( [::confCam::getPluginProperty $camItem "hasVideo"] == 1 ) && ( [ confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] longExposure ] == "0" ) } {
         set panneau(acqzadko,$visuNo,pose) "0"
      }

      #--- Si je fais un offset (pose de 0s) alors l'obturateur reste ferme
      if { $panneau(acqzadko,$visuNo,pose) == "0" } {
         cam$camNo shutter "closed"
      }

      if { [::confCam::getPluginProperty $panneau(acqzadko,$visuNo,camItem) hasBinning] == "1" } {
         #--- je selectionne le binning
         set binning [list [string range $panneau(acqzadko,$visuNo,binning) 0 0] [string range $panneau(acqzadko,$visuNo,binning) 2 2]]
         #--- je verifie que le binning est conforme
         set ctrl [ scan $panneau(acqzadko,$visuNo,binning) "%dx%d" binx biny ]
         if { $ctrl == 2 } {
            set ctrlValue [ format $binx%s$biny x ]
            if { $ctrlValue != $panneau(acqzadko,$visuNo,binning) } {
               set binning "1 1"
               set panneau(acqzadko,$visuNo,binning) "1x1"
            }
         } else {
            set binning "1 1"
            set panneau(acqzadko,$visuNo,binning) "1x1"
         }
         #--- j'applique le binning
         cam$camNo bin $binning
         set binningMessage $panneau(acqzadko,$visuNo,binning)
      } else {
         set binningMessage "1x1"
      }

      if { [::confCam::getPluginProperty $panneau(acqzadko,$visuNo,camItem) hasFormat] == "1" } {
         #--- je selectionne le format des images
         ::confCam::setFormat $panneau(acqzadko,$visuNo,camItem) $panneau(acqzadko,$visuNo,format)
         set binningMessage "$panneau(acqzadko,$visuNo,format)"
      }

      #--- je verrouille les widgets selon le mode de prise de vue
      switch $panneau(acqzadko,$visuNo,mode) {
         1  {
            #--- Mode une image
            #--- Verrouille les boutons du mode "une image"
            $panneau(acqzadko,$visuNo,This).mode.une.nom.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.une.index.case configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.une.index.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.une.index.but configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.une.sauve configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqzadko,acquneim) \
               $panneau(acqzadko,$visuNo,pose) $binningMessage $heure
            #--- je ne fais qu'une image dans ce mode
            set nbImages 1
         }
         2  {
            #--- Mode serie
            #--- Verrouille les boutons du mode "serie"
            $panneau(acqzadko,$visuNo,This).mode.serie.nom.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.serie.nb.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.serie.index.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.serie.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            if { $panneau(acqzadko,$visuNo,simulation) != "0" } {
               Message $visuNo consolog $caption(acqzadko,lance_simu)
               #--- Heure de debut de la premiere pose
               set panneau(acqzadko,$visuNo,debut) [ clock second ]
            }
            Message $visuNo consolog $caption(acqzadko,lanceserie) \
               $panneau(acqzadko,$visuNo,nb_images) $heure
            Message $visuNo consolog $caption(acqzadko,nomgen) $panneau(acqzadko,$visuNo,nom_image) \
               $panneau(acqzadko,$visuNo,pose) $binningMessage $panneau(acqzadko,$visuNo,index)
            #--- je recupere le nombre d'images de la serie donne par l'utilisateur
            set nbImages $panneau(acqzadko,$visuNo,nb_images)
         }
         3  {
            #--- Mode continu
            #--- Verrouille les boutons du mode "continu"
            $panneau(acqzadko,$visuNo,This).mode.continu.sauve.case configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.continu.nom.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.continu.index.case configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.continu.index.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.continu.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqzadko,lancecont) $panneau(acqzadko,$visuNo,pose) \
               $binningMessage $heure
            if { $panneau(acqzadko,$visuNo,enregistrer) == "1" } {
               if { $panneau(acqzadko,$visuNo,indexerContinue) == "1" } {
                  Message $visuNo consolog $caption(acqzadko,enregen) \
                    $panneau(acqzadko,$visuNo,nom_image)
               } else {
                  Message $visuNo consolog $caption(acqzadko,enrenongen) \
                    $panneau(acqzadko,$visuNo,nom_image)
               }
            } else {
               Message $visuNo consolog $caption(acqzadko,sansenr)
            }
            #--- il n'y a pas de nombre d'image
            set nbImages ""
         }
         4  {
            #--- Mode series d'images en continu avec intervalle entre chaque serie
            #--- Verrouille les boutons du mode "continu 1"
            $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.serie_1.nb.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.serie_1.index.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.serie_1.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqzadko,lanceserie_int) \
               $panneau(acqzadko,$visuNo,nb_images) $panneau(acqzadko,$visuNo,intervalle_1) $heure
            Message $visuNo consolog $caption(acqzadko,nomgen) $panneau(acqzadko,$visuNo,nom_image) \
               $panneau(acqzadko,$visuNo,pose) $binningMessage $panneau(acqzadko,$visuNo,index)
            #--- Je note l'heure de debut de la premiere serie (utile pour les series espacees)
            set panneau(acqzadko,$visuNo,deb_serie) [ clock second ]
            #--- je recupere le nombre d'images des series donne par l'utilisateur
            set nbImages $panneau(acqzadko,$visuNo,nb_images)
         }
         5  {
            #--- Mode continu avec intervalle entre chaque image
            #--- Verrouille les boutons du mode "continu 2"
            $panneau(acqzadko,$visuNo,This).mode.continu_1.sauve.case configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.continu_1.index.entr configure -state disabled
            $panneau(acqzadko,$visuNo,This).mode.continu_1.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqzadko,lancecont_int) $panneau(acqzadko,$visuNo,intervalle_2) \
               $panneau(acqzadko,$visuNo,pose) $binningMessage $heure
            if { $panneau(acqzadko,$visuNo,enregistrer) == "1" } {
               Message $visuNo consolog $caption(acqzadko,enregen) \
                 $panneau(acqzadko,$visuNo,nom_image)
            } else {
               Message $visuNo consolog $caption(acqzadko,sansenr)
            }
            #--- il n'y a pas de nombre d'image
            set nbImages ""
         }
      }

      set camNo $panneau(acqzadko,$visuNo,camNo)
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set loadMode [::confCam::getPluginProperty $panneau(acqzadko,$visuNo,camItem) "loadMode" ]

      #--- j'initialise l'indicateur d'etat de l'acquisition
      set panneau(acqzadko,$visuNo,acquisitionState) ""
      set compteurImageSerie 1

      #--- Je calcule le dernier index de la serie
      if { $panneau(acqzadko,$visuNo,mode) == "2" } {
         set panneau(acqzadko,$visuNo,indexEndSerie) [ expr $panneau(acqzadko,$visuNo,index) + $panneau(acqzadko,$visuNo,nb_images) - 1 ]
         set panneau(acqzadko,$visuNo,indexEndSerie) "$caption(acqzadko,dernierIndex) $panneau(acqzadko,$visuNo,indexEndSerie)"
      } elseif { $panneau(acqzadko,$visuNo,mode) == "4" } {
         set panneau(acqzadko,$visuNo,indexEndSerieContinu) [ expr $panneau(acqzadko,$visuNo,index) + $panneau(acqzadko,$visuNo,nb_images) - 1 ]
         set panneau(acqzadko,$visuNo,indexEndSerieContinu) "$caption(acqzadko,dernierIndex) $panneau(acqzadko,$visuNo,indexEndSerieContinu)"
      }

      #--- Boucle d'acquisition des images
      while { $panneau(acqzadko,$visuNo,demande_arret) == "0" } {
         #--- si un nombre d'image est precise, je verifie
         if { $nbImages != "" && $compteurImageSerie > $nbImages } {
            #--- alerte sonore de fin de serie
            if { $panneau(acqzadko,$visuNo,alarme_fin_serie) == "1" } {
               if { $nbImages > "0" && $panneau(acqzadko,$visuNo,mode) == "2" } {
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
            #--- le nombre d'image est atteint, j'arrete la boucle
            break
         }
         #--- Je note l'heure de debut de l'image (utile pour les images espacees)
         set panneau(acqzadko,$visuNo,deb_im) [ clock second ]
         #--- Alarme sonore de fin de pose
         ::camera::alarmeSonore $panneau(acqzadko,$visuNo,pose)
         #--- Declenchement l'acquisition (voir la suite dans callbackAcquition)
         ::camera::acquisition $panneau(acqzadko,$visuNo,camItem) "::acqzadko::callbackAcquisition $visuNo" $panneau(acqzadko,$visuNo,pose)
         #--- je lance la boucle d'affichage du status
         after 10 ::acqzadko::dispTime $visuNo
         #--- j'attends la fin de l'acquisition (voir ::acqzadko::callbackAcquisition)
         vwait panneau(acqzadko,$visuNo,acquisitionState)

         if { $panneau(acqzadko,$visuNo,acquisitionState) == "error" } {
            #--- j'interromps la boucle des acquisitions dans la thread de la camera
            ::acqzadko::stopAcquisition $visuNo
            #--- je ferme la fenetre de décompte
            if { $panneau(acqzadko,$visuNo,dispTimeAfterId) != "" } {
               after cancel $panneau(acqzadko,$visuNo,dispTimeAfterId)
               set panneau(acqzadko,$visuNo,dispTimeAfterId) ""
            }
            #--- j'affiche le message d'erreur
            tk_messageBox -message $::caption(acqzadko,acquisitionError) -title $::caption(acqzadko,pb) -icon error
            break
         }

         #--- Rajoute des mots cles dans l'en-tete FITS
         foreach keyword [ ::keyword::getKeywords $visuNo $::conf(acqzadko,keywordConfigName) ] {
            buf$bufNo setkwd $keyword
         }
         #--- je trace la duree réelle de la pose s'il y a eu une interruption
         if { $panneau(acqzadko,$visuNo,demande_arret) == "1" } {
            set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
            #--- je verifie qu'il y eu interruption vraiment pendant l'acquisition
            set dateEnd [mc_date2ymdhms [ lindex [ buf$bufNo getkwd DATE-END ] 1 ]]
            set dateEnd [format "%02dh %02dm %02ds" [lindex $dateEnd 3] [lindex $dateEnd 4] [expr int([lindex $dateEnd 5])]]
            if { $exposure != $panneau(acqzadko,$visuNo,pose) } {
               Message $visuNo consolog $caption(acqzadko,arrprem) $dateEnd
               Message $visuNo consolog $caption(acqzadko,lg_pose_arret) $exposure
            } else {
               Message $visuNo consolog $caption(acqzadko,arrprem) $dateEnd
            }
         }

         #--- j'enregistre l'image et je decale le telescope
         switch $panneau(acqzadko,$visuNo,mode) {
            1  {
               #--- mode une image
               incr compteurImageSerie
               #--- J'efface le nom du fichier dans le titre de la fenetre et dans la fenetre du header
               ::confVisu::setFileName $visuNo ""
            }
            2  {
               #--- Mode serie
               #--- Je sauvegarde l'image
               set nom $panneau(acqzadko,$visuNo,nom_image)
               #--- Pour eviter un nom de fichier qui commence par un blanc
               set nom [lindex $nom 0]
               if { $panneau(acqzadko,$visuNo,simulation) == "0" } {
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqzadko,$visuNo,index) $panneau(acqzadko,$visuNo,extension)
                  set sauvegardeValidee "1"
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" &&  $panneau(acqzadko,$visuNo,verifier_ecraser_fichier) == 1 } {
                     #--- Dans ce cas, le fichier existe deja...
                     set lastFile [ ::acqzadko::dernierFichier $visuNo ]
                     set confirmation [tk_messageBox -title $caption(acqzadko,conf) -type yesno \
                        -message "$caption(acqzadko,fichdeja_1) $lastFile $caption(acqzadko,fichdeja_2)"]
                     if { $confirmation == "no" } {
                        #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                        set sauvegardeValidee "0"
                        set panneau(acqzadko,$visuNo,demande_arret) "1"
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqzadko,$visuNo,sauve_img_interrompue) == "0" } {
                     #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                     set name [append nom $panneau(acqzadko,$visuNo,index) $panneau(acqzadko,$visuNo,extension)]
                     ::confVisu::setFileName $visuNo $name
                     #--- Sauvegarde de l'image
                     saveima $name $visuNo
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqzadko,enrim) $heure $nom
                     incr panneau(acqzadko,$visuNo,index)
                  }
               }
               #--- Deplacement du telescope
               ::DlgShiftZadko::decalageTelescope
               #--- j'incremente le nombre d'images de la serie
               incr compteurImageSerie
            }
            3  {
               #--- Mode continu
               #--- Je sauvegarde l'image
               if { $panneau(acqzadko,$visuNo,enregistrer) == "1" } {
                  $panneau(acqzadko,$visuNo,This).status.lab configure -text $caption(acqzadko,enreg)
                  set nom $panneau(acqzadko,$visuNo,nom_image)
                  #--- Pour eviter un nom de fichier qui commence par un blanc
                  set nom [lindex $nom 0]
                  #--- Verifie que le nom du fichier n'existe pas
                  set sauvegardeValidee "1"
                  if { $panneau(acqzadko,$visuNo,indexerContinue) == "1" } {
                     set nom1 "$nom"
                     append nom1 $panneau(acqzadko,$visuNo,index) $panneau(acqzadko,$visuNo,extension)
                     if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" &&  $panneau(acqzadko,$visuNo,verifier_ecraser_fichier) == 1} {
                        #--- Dans ce cas, le fichier existe deja...
                        set lastFile [ ::acqzadko::dernierFichier $visuNo ]
                        set confirmation [tk_messageBox -title $caption(acqzadko,conf) -type yesno \
                           -message "$caption(acqzadko,fichdeja_1) $lastFile $caption(acqzadko,fichdeja_2)"]
                        if { $confirmation == "no" } {
                           #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                           set sauvegardeValidee "0"
                           set panneau(acqzadko,$visuNo,demande_arret) "1"
                        }
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqzadko,$visuNo,sauve_img_interrompue) == "0" } {
                     #--- Sauvegarde de l'image
                     if { $panneau(acqzadko,$visuNo,indexerContinue) == "1" } {
                        #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                        set name [append nom $panneau(acqzadko,$visuNo,index) $panneau(acqzadko,$visuNo,extension)]
                        ::confVisu::setFileName $visuNo $name
                        #--- Sauvegarde de l'image
                        saveima $name $visuNo
                     } else {
                        #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                        set name [append nom $panneau(acqzadko,$visuNo,extension)]
                        ::confVisu::setFileName $visuNo $name
                        #--- Sauvegarde de l'image
                        saveima $name $visuNo
                     }
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqzadko,enrim) $heure $nom
                     if { $panneau(acqzadko,$visuNo,indexerContinue) == "1" } {
                        incr panneau(acqzadko,$visuNo,index)
                     }
                  }
               } else {
                  ::confVisu::setFileName $visuNo ""
               }
               #--- Deplacement du telescope
               ::DlgShiftZadko::decalageTelescope
            }
            4  {
               #--- Je sauvegarde l'image
               set nom $panneau(acqzadko,$visuNo,nom_image)
               #--- Pour eviter un nom de fichier qui commence par un blanc
               set nom [lindex $nom 0]
               if { $panneau(acqzadko,$visuNo,simulation) == "0" } {
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqzadko,$visuNo,index) $panneau(acqzadko,$visuNo,extension)
                  set sauvegardeValidee "1"
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" &&  $panneau(acqzadko,$visuNo,verifier_ecraser_fichier) == 1 } {
                     #--- Dans ce cas, le fichier existe deja...
                     set lastFile [ ::acqzadko::dernierFichier $visuNo ]
                     set confirmation [tk_messageBox -title $caption(acqzadko,conf) -type yesno \
                        -message "$caption(acqzadko,fichdeja_1) $lastFile $caption(acqzadko,fichdeja_2)"]
                     if { $confirmation == "no" } {
                        #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                        set sauvegardeValidee "0"
                        set panneau(acqzadko,$visuNo,demande_arret) "1"
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqzadko,$visuNo,sauve_img_interrompue) == "0" } {
                     #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                     set name [append nom $panneau(acqzadko,$visuNo,index) $panneau(acqzadko,$visuNo,extension)]
                     ::confVisu::setFileName $visuNo $name
                     #--- Sauvegarde de l'image
                     saveima $name $visuNo
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqzadko,enrim) $heure $nom
                     incr panneau(acqzadko,$visuNo,index)
                  }
               }
               #---
               if { $panneau(acqzadko,$visuNo,demande_arret) == "0" } {
                  #--- Deplacement du telescope
                  ::DlgShiftZadko::decalageTelescope
                  if { $compteurImageSerie < $nbImages } {
                     #--- j'incremente le compteur d'image
                     incr compteurImageSerie
                  } else {
                     #--- j'attends que la fin de la temporisation entre 2 series
                     set panneau(acqzadko,$visuNo,attente_pose) "1"
                     set panneau(acqzadko,$visuNo,fin_im) [ clock second ]
                     set panneau(acqzadko,$visuNo,intervalle_im_1) [ expr $panneau(acqzadko,$visuNo,fin_im) - $panneau(acqzadko,$visuNo,deb_serie) ]
                     while { ( $panneau(acqzadko,$visuNo,demande_arret) == "0" ) && ( $panneau(acqzadko,$visuNo,intervalle_im_1) <= $panneau(acqzadko,$visuNo,intervalle_1) ) } {
                        after 500
                        set panneau(acqzadko,$visuNo,fin_im) [ clock second ]
                        set panneau(acqzadko,$visuNo,intervalle_im_1) [ expr $panneau(acqzadko,$visuNo,fin_im) - $panneau(acqzadko,$visuNo,deb_serie) + 1 ]
                        set t [ expr $panneau(acqzadko,$visuNo,intervalle_1) - $panneau(acqzadko,$visuNo,intervalle_im_1) ]
                        ::acqzadko::avancementPose $visuNo $t
                     }
                     set panneau(acqzadko,$visuNo,attente_pose) "0"
                     #--- Je note l'heure de debut des series suivantes (utile pour les series espacees)
                     set panneau(acqzadko,$visuNo,deb_serie) [ clock second ]
                     #--- je reinitalise le compteur d'image
                     set compteurImageSerie 1
                     #--- Je calcule le dernier index de la serie
                     set panneau(acqzadko,$visuNo,indexEndSerieContinu) [ expr $panneau(acqzadko,$visuNo,index) + $panneau(acqzadko,$visuNo,nb_images) - 1 ]
                     set panneau(acqzadko,$visuNo,indexEndSerieContinu) "$caption(acqzadko,dernierIndex) $panneau(acqzadko,$visuNo,indexEndSerieContinu)"
                  }
               }
            }
            5  {
               #--- Je sauvegarde l'image
               set nom $panneau(acqzadko,$visuNo,nom_image)
               #--- Pour eviter un nom de fichier qui commence par un blanc
               set nom [lindex $nom 0]
               if { $panneau(acqzadko,$visuNo,enregistrer) == "1" } {
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqzadko,$visuNo,index) $panneau(acqzadko,$visuNo,extension)
                  set sauvegardeValidee "1"
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" &&  $panneau(acqzadko,$visuNo,verifier_ecraser_fichier) == 1 } {
                     #--- Dans ce cas, le fichier existe deja...
                     set lastFile [ ::acqzadko::dernierFichier $visuNo ]
                     set confirmation [tk_messageBox -title $caption(acqzadko,conf) -type yesno \
                        -message "$caption(acqzadko,fichdeja_1) $lastFile $caption(acqzadko,fichdeja_2)"]
                     if { $confirmation == "no" } {
                        #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                        set sauvegardeValidee "0"
                        set panneau(acqzadko,$visuNo,demande_arret) "1"
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqzadko,$visuNo,sauve_img_interrompue) == "0" } {
                     #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                     set name [append nom $panneau(acqzadko,$visuNo,index) $panneau(acqzadko,$visuNo,extension)]
                     ::confVisu::setFileName $visuNo $name
                     #--- Sauvegarde de l'image
                     saveima $name $visuNo
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqzadko,enrim) $heure $nom
                     incr panneau(acqzadko,$visuNo,index)
                  }
               } else {
                  ::confVisu::setFileName $visuNo ""
               }
               #---
               if { $panneau(acqzadko,$visuNo,demande_arret) == "0" } {
                  #--- Deplacement du telescope
                  ::DlgShiftZadko::decalageTelescope
                  set panneau(acqzadko,$visuNo,attente_pose) "1"
                  set panneau(acqzadko,$visuNo,fin_im) [ clock second ]
                  set panneau(acqzadko,$visuNo,intervalle_im_2) [ expr $panneau(acqzadko,$visuNo,fin_im) - $panneau(acqzadko,$visuNo,deb_im) ]
                  while { ( $panneau(acqzadko,$visuNo,demande_arret) == "0" ) && ( $panneau(acqzadko,$visuNo,intervalle_im_2) <= $panneau(acqzadko,$visuNo,intervalle_2) ) } {
                     after 500
                     set panneau(acqzadko,$visuNo,fin_im) [ clock second ]
                     set panneau(acqzadko,$visuNo,intervalle_im_2) [ expr $panneau(acqzadko,$visuNo,fin_im) - $panneau(acqzadko,$visuNo,deb_im) + 1 ]
                     set t [ expr $panneau(acqzadko,$visuNo,intervalle_2) - $panneau(acqzadko,$visuNo,intervalle_im_2) ]
                     ::acqzadko::avancementPose $visuNo $t
                  }
                  set panneau(acqzadko,$visuNo,attente_pose) "0"
               }
            }
         } ; #--- fin du switch d'acquisition

         #--- Je retablis le choix du fonctionnement de l'obturateur
         if { $panneau(acqzadko,$visuNo,pose) == "0" } {
            switch -exact -- $panneau(acqzadko,$visuNo,obt) {
               0  {
                  cam$camNo shutter "opened"
               }
               1  {
                  cam$camNo shutter "closed"
               }
               2  {
                  cam$camNo shutter "synchro"
               }
            }
         }
      }  ; #--- fin de la boucle d'acquisition

         #--- je deverrouille des widgets selon le mode d'acquisition
         switch $panneau(acqzadko,$visuNo,mode) {
            1  {
               #--- Deverrouille les boutons du mode "une image"
               $panneau(acqzadko,$visuNo,This).mode.une.nom.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.une.index.case configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.une.index.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.une.index.but configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.une.sauve configure -state normal
            }
            2  {
               #--- Mode serie
               #--- Fin de la derniere pose et intervalle mini entre 2 poses ou 2 series
               if { $panneau(acqzadko,$visuNo,simulation) == "1" } {
                  #--- Affichage de l'intervalle mini simule
                  set panneau(acqzadko,$visuNo,fin) [ clock second ]
                  set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
                  if { $exposure == $panneau(acqzadko,$visuNo,pose) } {
                     set panneau(acqzadko,$visuNo,intervalle) [ expr $panneau(acqzadko,$visuNo,fin) - $panneau(acqzadko,$visuNo,debut) ]
                  } else {
                     set panneau(acqzadko,$visuNo,intervalle) "...."
                  }
                  set simu1 "$caption(acqzadko,int_mini_serie) $panneau(acqzadko,$visuNo,intervalle) $caption(acqzadko,sec)"
                  $panneau(acqzadko,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
                  #--- Je retablis les reglages initiaux
                  set panneau(acqzadko,$visuNo,simulation) "0"
                  set panneau(acqzadko,$visuNo,mode)       "4"
                  set panneau(acqzadko,$visuNo,index)      $panneau(acqzadko,$visuNo,index_temp)
                  set panneau(acqzadko,$visuNo,nb_images)  $panneau(acqzadko,$visuNo,nombre_temp)
                  #--- Fin de la simulation
                  Message $visuNo consolog $caption(acqzadko,fin_simu)
               } elseif { $panneau(acqzadko,$visuNo,simulation) == "2" } {
                  #--- Affichage de l'intervalle mini simule
                  set panneau(acqzadko,$visuNo,fin) [ clock second ]
                  set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
                  if { $exposure == $panneau(acqzadko,$visuNo,pose) } {
                     set panneau(acqzadko,$visuNo,intervalle) [ expr $panneau(acqzadko,$visuNo,fin) - $panneau(acqzadko,$visuNo,debut) ]
                  } else {
                     set panneau(acqzadko,$visuNo,intervalle) "...."
                  }
                  set simu2 "$caption(acqzadko,int_mini_image) $panneau(acqzadko,$visuNo,intervalle) $caption(acqzadko,sec)"
                  $panneau(acqzadko,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
                  #--- Je retablis les reglages initiaux
                  set panneau(acqzadko,$visuNo,simulation) "0"
                  set panneau(acqzadko,$visuNo,mode)       "5"
                  set panneau(acqzadko,$visuNo,index)      $panneau(acqzadko,$visuNo,index_temp)
                  set panneau(acqzadko,$visuNo,nb_images)  $panneau(acqzadko,$visuNo,nombre_temp)
                  #--- Fin de la simulation
                  Message $visuNo consolog $caption(acqzadko,fin_simu)
               }
               #--- Deverrouille les boutons du mode "serie"
               $panneau(acqzadko,$visuNo,This).mode.serie.nom.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.serie.nb.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.serie.index.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.serie.index.but configure -state normal
            }
            3  {
               #--- Mode continu
               #--- Deverrouille les boutons du mode "continu"
               $panneau(acqzadko,$visuNo,This).mode.continu.sauve.case configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.continu.nom.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.continu.index.case configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.continu.index.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.continu.index.but configure -state normal
            }
            4  {
               #--- Mode continu
               #--- Deverrouille les boutons du mode "continu 1"
               $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.serie_1.nb.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.serie_1.index.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.serie_1.index.but configure -state normal
            }
            5 {
               #--- Deverrouille les boutons du mode "continu 2"
               $panneau(acqzadko,$visuNo,This).mode.continu_1.sauve.case configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.continu_1.index.entr configure -state normal
               $panneau(acqzadko,$visuNo,This).mode.continu_1.index.but configure -state normal
            }
         } ; #--- fin du switch de deverrouillage
   }] ; #--- fin du catch

   if { $catchResult == 1 } {
      ::tkutil::displayErrorInfo $caption(acqzadko,titre)
      #--- J'arrete la capture de l'image
      ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
   }

   #--- Pose en cours
   set panneau(acqzadko,$visuNo,pose_en_cours) "0"

   set panneau(acqzadko,$visuNo,demande_arret) 0
   #--- Effacement de la barre de progression quand la pose est terminee
   ::acqzadko::avancementPose $visuNo -1
   $panneau(acqzadko,$visuNo,This).status.lab configure -text ""
   #--- Deverrouille tous les boutons et champs de texte pendant les acquisitions
   $panneau(acqzadko,$visuNo,This).pose.but configure -state normal
   $panneau(acqzadko,$visuNo,This).pose.entr configure -state normal
   $panneau(acqzadko,$visuNo,This).binning.but configure -state normal
   $panneau(acqzadko,$visuNo,This).format.but configure -state normal
   $panneau(acqzadko,$visuNo,This).obt.but configure -state normal
   $panneau(acqzadko,$visuNo,This).mode.but configure -state normal
   #--- Je restitue l'affichage du bouton "GO"
   $panneau(acqzadko,$visuNo,This).go_stop.but configure -text $caption(acqzadko,GO) -state normal -command "::acqzadko::Go $visuNo"
   #--- je positionne l'indateur de fin d'acquisition (pour startAcquisitionSerieImage)
   set ::panneau(acqzadko,$visuNo,acqImageEnd) "1"
}
#***** Fin de la procedure de lancement d'acquisition **********

#------------------------------------------------------------
# callbackAcquisition
#     cette procedure est appelee par la thread de la camera
#     pour informer de l'avancement des acquisitions.
# Parameters
#  visuNo  : numero de la visu associee a la camera
#  message : message envoye par la thread de la camera (voir la description dans camera.tcl)
#  args    : parametres du message (voir la description dans camera.tcl)
# Return
#    rien
#------------------------------------------------------------
proc ::acqzadko::callbackAcquisition { visuNo message args } {
   switch $message {
      "autovisu" {
         #--- ce message signale que l'image est prete dans le buffer
         #--- on peut l'afficher sans attendre la fin complete de la thread de la camera
         ::confVisu::autovisu $visuNo
      }
      "acquisitionResult" {
         #--- ce message signale que la thread de la camera a termine completement l'acquisition
         #--- je peux traiter l'image
         set ::panneau(acqzadko,$visuNo,acquisitionState) "acquisitionResult"
      }
      "error" {
         #--- ce message signale qu'une erreur est survenue dans la thread de la camera
         #--- j'affiche l'erreur dans la console
         ::console::affiche_erreur "acqzadko::acq error: $args\n"
         set ::panneau(acqzadko,$visuNo,acquisitionState) "error"
      }
   }
}

#***** Procedure Stop (appui sur le bouton Go/Stop) *********
proc ::acqzadko::Stop { visuNo } {
   global audace caption panneau

   #--- Je desactive le bouton "STOP"
   $panneau(acqzadko,$visuNo,This).go_stop.but configure -state disabled

   #--- j'interromps la pose
   if { $panneau(acqzadko,$visuNo,mode) == "1" } {
      #--- Je positionne l'indicateur d'interruption de pose
      set panneau(acqzadko,$visuNo,demande_arret) "1"
      #--- On annule la sonnerie
      catch { after cancel $audace(after,bell,id) }
      #--- Annulation de l'alarme de fin de pose
      catch { after cancel bell }
      #--- J'arrete la capture de l'image
      ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
   } else {
      if { $panneau(acqzadko,$visuNo,enregistrer_acquisiton_interrompue) == 1 } {
         if { [cam$panneau(acqzadko,$visuNo,camNo) timer -1 ] > 10 } {
             #--- s'il reste plus de 10 seconde , je demande si on interromp la pose courante
             set choix [ tk_messageBox -title $caption(acqzadko,serie) -type yesno -icon info \
                 -message $caption(acqzadko,arret_serie) \
             ]
            if { $choix == "no" } {
               #--- Je positionne l'indicateur d'interruption de pose
               set panneau(acqzadko,$visuNo,demande_arret) "1"
               #--- Je positionne l'indicateur d'enregistrement d'image interrompue
               set panneau(acqzadko,$visuNo,sauve_img_interrompue) "1"
               #--- On annule la sonnerie
               catch { after cancel $audace(after,bell,id) }
               #--- Annulation de l'alarme de fin de pose
               catch { after cancel bell }
               #--- J'arrete l'acquisition courante
               ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
            } else {
               #--- Je positionne l'indicateur d'interruption de pose a 1 s de la fin de la pose
               ::acqzadko::stopSerie $visuNo
               #--- Je positionne l'indicateur d'enregistrement d'image interrompue
               set panneau(acqzadko,$visuNo,sauve_img_interrompue) "0"
            }
         } else {
            #--- Je positionne l'indicateur d'interruption de pose a 1 s de la fin de la pose
            ::acqzadko::stopSerie $visuNo
            #--- s'il reste moins de 10 secondes, je ne pose pas de question a l'utilisateur
            #--- la serie s'arretera a la fin de l'image en cours
            set panneau(acqzadko,$visuNo,sauve_img_interrompue) "0"
         }
      } else {
         #--- Je positionne l'indicateur d'interruption de pose
         set panneau(acqzadko,$visuNo,demande_arret) "1"
         #--- Je positionne l'indicateur d'enregistrement d'image interrompue
         set panneau(acqzadko,$visuNo,sauve_img_interrompue) "1"
         #--- On annule la sonnerie
         catch { after cancel $audace(after,bell,id) }
         #--- Annulation de l'alarme de fin de pose
         catch { after cancel bell }
         #--- J'arrete l'acquisition courante
         ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
      }
   }
}
#***** Fin de la procedure Go/Stop *****************************

#***** Procedure arret de la serie *****************************
proc ::acqzadko::stopSerie { visuNo } {
   global panneau

   set t [cam$panneau(acqzadko,$visuNo,camNo) timer -1 ]
   if { $t > 1 } {
      #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
      #--- (mode asynchone pour eviter l'empilement des appels recursifs)
      set valeur [after 1000 ::acqzadko::stopSerie $visuNo]
   } else {
      #--- je ne relance pas le timer et j'arrete la pose
      set panneau(acqzadko,$visuNo,demande_arret) "1"
   }
}
#***** Fin de la procedure arret de la serie *******************

#------------------------------------------------------------
# configToolKeywords
#    configure les mots cles FITS de l'outil
#------------------------------------------------------------
proc ::acqzadko::configToolKeywords { visuNo { configName "" } } {
   #--- Je traite la variable configName
   if { $configName == "" } {
      set configName $::conf(acqzadko,keywordConfigName)
   }

   #--- Je selectionne les mots cles optionnels a ajouter dans les images
   #--- Ce sont les mots cles CRPIX1, CRPIX2
   ::keyword::selectKeywords $visuNo $configName [ list CRPIX1 CRPIX2 ]

   #--- Je selectionne la liste des mots cles non modifiables
   ::keyword::setKeywordState $visuNo $configName [ list CRPIX1 CRPIX2 ]
}

proc ::acqzadko::dispTime { visuNo } {
   global caption panneau

   #--- j'arrete le timer s'il est deja lance
   if { [info exists panneau(acqzadko,$visuNo,dispTimeAfterId)] && $panneau(acqzadko,$visuNo,dispTimeAfterId)!="" } {
      after cancel $panneau(acqzadko,$visuNo,dispTimeAfterId)
      set panneau(acqzadko,$visuNo,dispTimeAfterId) ""
   }

   set t [cam$panneau(acqzadko,$visuNo,camNo) timer -1 ]
   #--- je mets a jour le status
   if { $panneau(acqzadko,$visuNo,pose_en_cours) == 0 } {
      #--- je supprime la fenetre s'il n'y a plus de pose en cours
      set status ""
   } else {
      if { $panneau(acqzadko,$visuNo,attente_pose) == "0" } {
         if { $panneau(acqzadko,$visuNo,demande_arret) == "0" } {
            if { [expr $t > 0] } {
               set status "[ expr $t ] / [ format "%d" [ expr int($panneau(acqzadko,$visuNo,pose)) ] ]"
            } else {
               set status "$caption(acqzadko,lect)"
            }
         } else {
            set status "$caption(acqzadko,lect)"
         }
      } else {
         set status $caption(acqzadko,attente)
      }
   }
   $panneau(acqzadko,$visuNo,This).status.lab configure -text $status
   update

   #--- je mets a jour la fenetre de progression
   avancementPose $visuNo $t

   if { $t > 0 } {
      #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
      #--- (mode asynchone pour eviter l'empilement des appels recursifs)
      set panneau(acqzadko,$visuNo,dispTimeAfterId) [after 1000 ::acqzadko::dispTime $visuNo]
   } else {
      #--- je ne relance pas le timer
      set panneau(acqzadko,$visuNo,dispTimeAfterId) ""
   }
}

#***** Procedure d'affichage d'une barre de progression ********
proc ::acqzadko::avancementPose { visuNo { t } } {
   global caption color panneau

   if { $panneau(acqzadko,$visuNo,avancement_acq) != "1" } {
      return
   }

   #--- Recuperation de la position de la fenetre
   ::acqzadko::recup_position_1 $visuNo

   #--- Initialisation de la barre de progression
   set cpt "100"

   #---
   if { [ winfo exists $panneau(acqzadko,$visuNo,base).progress ] != "1" } {

      #--- Cree la fenetre toplevel
      toplevel $panneau(acqzadko,$visuNo,base).progress
      wm transient $panneau(acqzadko,$visuNo,base).progress $panneau(acqzadko,$visuNo,base)
      wm resizable $panneau(acqzadko,$visuNo,base).progress 0 0
      wm title $panneau(acqzadko,$visuNo,base).progress "$caption(acqzadko,en_cours)"
      wm geometry $panneau(acqzadko,$visuNo,base).progress $panneau(acqzadko,$visuNo,avancement,position)

      #--- Cree le widget et le label du temps ecoule
      label $panneau(acqzadko,$visuNo,base).progress.lab_status -text "" -justify center
      pack $panneau(acqzadko,$visuNo,base).progress.lab_status -side top -fill x -expand true -pady 5

      #---
      if { $panneau(acqzadko,$visuNo,attente_pose) == "0" } {
         if { $panneau(acqzadko,$visuNo,demande_arret) == "1" && $panneau(acqzadko,$visuNo,mode) != "2" && $panneau(acqzadko,$visuNo,mode) != "4" } {
            $panneau(acqzadko,$visuNo,base).progress.lab_status configure -text $caption(acqzadko,lect)
         } else {
            if { $t < 0 } {
               destroy $panneau(acqzadko,$visuNo,base).progress
            } elseif { $t > 0 } {
               $panneau(acqzadko,$visuNo,base).progress.lab_status configure -text "$t $caption(acqzadko,sec) /\
                  [ format "%d" [ expr int( $panneau(acqzadko,$visuNo,pose) ) ] ] $caption(acqzadko,sec)"
               set cpt [ expr $t * 100 / int( $panneau(acqzadko,$visuNo,pose) ) ]
               set cpt [ expr 100 - $cpt ]
            } else {
               $panneau(acqzadko,$visuNo,base).progress.lab_status configure -text "$caption(acqzadko,lect)"
           }
         }
      } else {
         if { $panneau(acqzadko,$visuNo,demande_arret) == "0" } {
            if { $t < 0 } {
               destroy $panneau(acqzadko,$visuNo,base).progress
            } else {
               if { $panneau(acqzadko,$visuNo,mode) == "4" } {
                  $panneau(acqzadko,$visuNo,base).progress.lab_status configure -text "$caption(acqzadko,attente) [ expr $t + 1 ]\
                     $caption(acqzadko,sec) / $panneau(acqzadko,$visuNo,intervalle_1) $caption(acqzadko,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqzadko,$visuNo,intervalle_1) ]
               } elseif { $panneau(acqzadko,$visuNo,mode) == "5" } {
                  $panneau(acqzadko,$visuNo,base).progress.lab_status configure -text "$caption(acqzadko,attente) [ expr $t + 1 ]\
                     $caption(acqzadko,sec) / $panneau(acqzadko,$visuNo,intervalle_2) $caption(acqzadko,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqzadko,$visuNo,intervalle_2) ]
               }
               set cpt [ expr 100 - $cpt ]
            }
         }
      }

      catch {
         #--- Cree le widget pour la barre de progression
         frame $panneau(acqzadko,$visuNo,base).progress.cadre -width 200 -height 30 -borderwidth 2 -relief groove
         pack $panneau(acqzadko,$visuNo,base).progress.cadre -in $panneau(acqzadko,$visuNo,base).progress -side top \
            -anchor center -fill x -expand true -padx 8 -pady 8

         #--- Affiche de la barre de progression
         frame $panneau(acqzadko,$visuNo,base).progress.cadre.barre_color_invariant -height 26 -bg $color(blue)
         place $panneau(acqzadko,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(acqzadko,$visuNo,base).progress.cadre -x 0 -y 0 \
            -relwidth [ expr $cpt / 100.0 ]
         update
      }

      #--- Mise a jour dynamique des couleurs
      if { [ winfo exists $panneau(acqzadko,$visuNo,base).progress ] == "1" } {
         ::confColor::applyColor $panneau(acqzadko,$visuNo,base).progress
      }

   } else {

      if { $panneau(acqzadko,$visuNo,pose_en_cours) == 0 } {
         #--- je supprime la fenetre s'il n'y a plus de pose en cours
         destroy $panneau(acqzadko,$visuNo,base).progress
      } else {
         if { $panneau(acqzadko,$visuNo,attente_pose) == "0" } {
            if { $panneau(acqzadko,$visuNo,demande_arret) == "0" } {
               if { $t > 0 } {
                  $panneau(acqzadko,$visuNo,base).progress.lab_status configure -text "[ expr $t ] $caption(acqzadko,sec) /\
                     [ format "%d" [ expr int( $panneau(acqzadko,$visuNo,pose) ) ] ] $caption(acqzadko,sec)"
                  set cpt [ expr $t * 100 / int( $panneau(acqzadko,$visuNo,pose) ) ]
                 set cpt [ expr 100 - $cpt ]
               } else {
                  $panneau(acqzadko,$visuNo,base).progress.lab_status configure -text "$caption(acqzadko,lect)"
               }
            } else {
               #--- j'affiche "lecture" des qu'une demande d'arret est demandee
               $panneau(acqzadko,$visuNo,base).progress.lab_status configure -text "$caption(acqzadko,lect)"
            }
         } else {
            if { $panneau(acqzadko,$visuNo,demande_arret) == "0" } {
               if { $panneau(acqzadko,$visuNo,mode) == "4" } {
                  $panneau(acqzadko,$visuNo,base).progress.lab_status configure -text "$caption(acqzadko,attente) [ expr $t + 1 ]\
                     $caption(acqzadko,sec) / $panneau(acqzadko,$visuNo,intervalle_1) $caption(acqzadko,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqzadko,$visuNo,intervalle_1) ]
               } elseif { $panneau(acqzadko,$visuNo,mode) == "5" } {
                  $panneau(acqzadko,$visuNo,base).progress.lab_status configure -text "$caption(acqzadko,attente) [ expr $t + 1 ]\
                     $caption(acqzadko,sec) / $panneau(acqzadko,$visuNo,intervalle_2) $caption(acqzadko,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqzadko,$visuNo,intervalle_2) ]
               }
               set cpt [ expr 100 - $cpt ]
            }
         }

         #--- Met a jour la barre de progression
         place $panneau(acqzadko,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(acqzadko,$visuNo,base).progress.cadre -x 0 -y 0 \
            -relwidth [ expr $cpt / 100.0 ]
         update
      }

   }

}
#***** Fin de la procedure d'avancement de la pose *************

#*********** Procedure dernier fichier d'une liste *************
proc ::acqzadko::dernierFichier { visuNo } {
   global panneau

   #--- Liste par ordre croissant les index du nom generique
   set a [ lsort -integer [ liste_index $panneau(acqzadko,$visuNo,nom_image) ] ]
   set b [ llength $a ]
   #--- Extrait le dernier index de la liste
   set c [ lindex $a [ expr $b - 1 ] ]
   #--- Retourne le dernier fichier de la liste
   set d $panneau(acqzadko,$visuNo,nom_image)$c$panneau(acqzadko,$visuNo,extension)
   return $d
}
#****Fin de la procedure dernier fichier d'une liste ***********

#***** Procedure de sauvegarde de l'image **********************
#--- Procedure lancee par appui sur le bouton "enregistrer", uniquement dans le mode "Une image"
proc ::acqzadko::SauveUneImage { visuNo } {
   global audace caption panneau

   #--- Tests d'integrite de la requete
   #--- Verifier qu'il y a bien un nom de fichier
   if { $panneau(acqzadko,$visuNo,nom_image) == "" } {
      tk_messageBox -title $caption(acqzadko,pb) -type ok \
         -message $caption(acqzadko,donnomfich)
      return
   }
   #--- Verifier que le nom de fichier n'a pas d'espace
   if { [ llength $panneau(acqzadko,$visuNo,nom_image) ] > "1" } {
      tk_messageBox -title $caption(acqzadko,pb) -type ok \
         -message $caption(acqzadko,nomblanc)
      return
   }
   #--- Si la case index est cochee, verifier qu'il y a bien un index
   if { $panneau(acqzadko,$visuNo,indexer) == "1" } {
      #--- Verifier que l'index existe
      if { $panneau(acqzadko,$visuNo,index) == "" } {
         tk_messageBox -title $caption(acqzadko,pb) -type ok \
            -message $caption(acqzadko,saisind)
         return
      }
   }

   #--- Generer le nom du fichier
   set nom $panneau(acqzadko,$visuNo,nom_image)
   #--- Pour eviter un nom de fichier qui commence par un blanc
   set nom [lindex $nom 0]
   if { $panneau(acqzadko,$visuNo,indexer) == "1" } {
      append nom $panneau(acqzadko,$visuNo,index)
   }

   #--- Verifier que le nom du fichier n'existe pas
   set nom1 "$nom"
   append nom1 $panneau(acqzadko,$visuNo,extension)
   if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" &&  $panneau(acqzadko,$visuNo,verifier_ecraser_fichier) == 1 } {
      #--- Dans ce cas, le fichier existe deja...
      set lastFile [ ::acqzadko::dernierFichier $visuNo ]
      set confirmation [tk_messageBox -title $caption(acqzadko,conf) -type yesno \
         -message "$caption(acqzadko,fichdeja_1) $lastFile $caption(acqzadko,fichdeja_2)"]
      if { $confirmation == "no" } {
         return
      }
   }

   #--- Incrementer l'index
   set bufNo [ visu$visuNo buf ]
   if { $panneau(acqzadko,$visuNo,indexer) == "1" } {
      if { [ buf$bufNo imageready ] != "0" } {
         incr panneau(acqzadko,$visuNo,index)
      } else {
         #--- Sortir immediatement s'il n'y a pas d'image dans le buffer
         return
      }
   } else {
      if { [ buf$bufNo imageready ] == "0" } {
         #--- Sortir immediatement s'il n'y a pas d'image dans le buffer
         return
      }
   }

   #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
   set name [append nom $panneau(acqzadko,$visuNo,extension)]
   ::confVisu::setFileName $visuNo $name

   #--- Sauvegarde de l'image
   saveima $name $visuNo

   #--- Indique l'heure d'enregistrement dans le fichier log
   set heure $audace(tu,format,hmsint)
   Message $visuNo consolog $caption(acqzadko,demsauv) $heure
   Message $visuNo consolog $caption(acqzadko,imsauvnom) $nom
}
#***** Fin de la procedure de sauvegarde de l'image *************

#***** Procedure d'affichage des messages ************************
#--- Cette procedure est recopiee de methking.tcl, elle permet l'affichage de differents
#--- messages (dans la console, le fichier log, etc.)
proc ::acqzadko::Message { visuNo niveau args } {
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
            puts -nonewline $::acqzadko::log_id($visuNo) [eval [concat {format} $args]]
            #--- Force l'ecriture immediate sur le disque
            flush $::acqzadko::log_id($visuNo)
         }
      }
      consolog {
         if { $panneau(acqzadko,$visuNo,messages) == "1" } {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         set temps [clock format [clock seconds] -format %H:%M:%S]
         append temps " "
         catch {
            puts -nonewline $::acqzadko::log_id($visuNo) [eval [concat {format} $args]]
            #--- Force l'ecriture immediate sur le disque
            flush $::acqzadko::log_id($visuNo)
         }
      }
      default {
         set b [ list "%s\n" $caption(acqzadko,pbmesserr) ]
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
proc ::acqzadko::cmdShiftConfig { visuNo } {
   global audace

   set shiftConfig [ ::DlgShiftZadko::run $visuNo $audace(base).dlgShiftZadko ]
   return
}
#***** Fin du bouton pour le decalage du telescope *****************

#***** Fenetre de configuration series d'images a intervalle regulier en continu *********
proc ::acqzadko::Intervalle_continu_1 { visuNo } {
   global caption conf panneau

   set panneau(acqzadko,$visuNo,intervalle)            "...."
   set panneau(acqzadko,$visuNo,simulation_deja_faite) "0"

   ::acqzadko::recup_position $visuNo

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(acqzadko,continu1,position) ] } { set conf(acqzadko,continu1,position) "+120+260" }

   #--- Creation de la fenetre Continu 1
   toplevel $panneau(acqzadko,$visuNo,base).intervalle_continu_1
   wm transient $panneau(acqzadko,$visuNo,base).intervalle_continu_1 $panneau(acqzadko,$visuNo,base)
   wm resizable $panneau(acqzadko,$visuNo,base).intervalle_continu_1 0 0
   wm title $panneau(acqzadko,$visuNo,base).intervalle_continu_1 "$caption(acqzadko,continu_1)"
   wm geometry $panneau(acqzadko,$visuNo,base).intervalle_continu_1 $conf(acqzadko,continu1,position)
   wm protocol $panneau(acqzadko,$visuNo,base).intervalle_continu_1 WM_DELETE_WINDOW " \
      set panneau(acqzadko,$visuNo,mode_en_cours) \"$caption(acqzadko,continu_1)\" \
   "

   #--- Create the message
   label $panneau(acqzadko,$visuNo,base).intervalle_continu_1.lab1 -text "$caption(acqzadko,titre_1)"
   pack $panneau(acqzadko,$visuNo,base).intervalle_continu_1.lab1 -padx 20 -pady 5

   frame $panneau(acqzadko,$visuNo,base).intervalle_continu_1.a
      label $panneau(acqzadko,$visuNo,base).intervalle_continu_1.a.lab2 -text "$caption(acqzadko,intervalle_1)"
      pack $panneau(acqzadko,$visuNo,base).intervalle_continu_1.a.lab2 -anchor center -expand 1 -fill none -side left \
         -padx 10 -pady 5
      entry $panneau(acqzadko,$visuNo,base).intervalle_continu_1.a.ent1 -width 5 -relief groove \
         -textvariable panneau(acqzadko,$visuNo,intervalle_1) -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $panneau(acqzadko,$visuNo,base).intervalle_continu_1.a.ent1 -anchor center -expand 1 -fill none -side left \
         -padx 10
   pack $panneau(acqzadko,$visuNo,base).intervalle_continu_1.a -padx 10 -pady 5

   frame $panneau(acqzadko,$visuNo,base).intervalle_continu_1.b
      checkbutton $panneau(acqzadko,$visuNo,base).intervalle_continu_1.b.check_simu \
         -text "$caption(acqzadko,simu_deja_faite)" \
         -variable panneau(acqzadko,$visuNo,simulation_deja_faite) -command "::acqzadko::Simu_deja_faite_1 $visuNo"
      pack $panneau(acqzadko,$visuNo,base).intervalle_continu_1.b.check_simu -anchor w -expand 1 -fill none \
         -side left -padx 10 -pady 5
   pack $panneau(acqzadko,$visuNo,base).intervalle_continu_1.b -side bottom -anchor w -padx 10 -pady 5

   button $panneau(acqzadko,$visuNo,base).intervalle_continu_1.but1 -text "$caption(acqzadko,simulation)" \
      -command "::acqzadko::Command_continu_1 $visuNo"
   pack $panneau(acqzadko,$visuNo,base).intervalle_continu_1.but1 -anchor center -expand 1 -fill none -side left \
      -ipadx 5 -ipady 3 -padx 10 -pady 5

   set simu1 "$caption(acqzadko,int_mini_serie) $panneau(acqzadko,$visuNo,intervalle) $caption(acqzadko,sec)"
   label $panneau(acqzadko,$visuNo,base).intervalle_continu_1.lab3 -text "$simu1"
   pack $panneau(acqzadko,$visuNo,base).intervalle_continu_1.lab3 -anchor center -expand 1 -fill none -side left -padx 10

   #--- New message window is on
   focus $panneau(acqzadko,$visuNo,base).intervalle_continu_1

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $panneau(acqzadko,$visuNo,base).intervalle_continu_1
}
#***** Fin fenetre de configuration series d'images a intervalle regulier en continu *****

#***** Commande associee au bouton simulation de la fenetre Continu (1) ******************
proc ::acqzadko::Command_continu_1 { visuNo } {
   global caption panneau

   set panneau(acqzadko,$visuNo,intervalle) "...."
   set simu1 "$caption(acqzadko,int_mini_serie) $panneau(acqzadko,$visuNo,intervalle) $caption(acqzadko,sec)"
   $panneau(acqzadko,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
   set panneau(acqzadko,$visuNo,simulation)  "1"
   set panneau(acqzadko,$visuNo,mode)        "2"
   set panneau(acqzadko,$visuNo,index_temp)  $panneau(acqzadko,$visuNo,index)
   set panneau(acqzadko,$visuNo,nombre_temp) $panneau(acqzadko,$visuNo,nb_images)
   ::acqzadko::Go $visuNo
}
#***** Fin de la commande associee au bouton simulation de la fenetre Continu (1) ********

#***** Si une simulation a deja ete faite pour la fenetre Continu (1) ********************
proc ::acqzadko::Simu_deja_faite_1 { visuNo } {
   global caption panneau

   if { $panneau(acqzadko,$visuNo,simulation_deja_faite) == "1" } {
      set panneau(acqzadko,$visuNo,intervalle) "xxxx"
      $panneau(acqzadko,$visuNo,base).intervalle_continu_1.lab3 configure \
         -text "$caption(acqzadko,int_mini_serie) $panneau(acqzadko,$visuNo,intervalle) $caption(acqzadko,sec)"
      focus $panneau(acqzadko,$visuNo,base).intervalle_continu_1.a.ent1
   } else {
      set panneau(acqzadko,$visuNo,intervalle) "...."
      $panneau(acqzadko,$visuNo,base).intervalle_continu_1.lab3 configure \
         -text "$caption(acqzadko,int_mini_serie) $panneau(acqzadko,$visuNo,intervalle) $caption(acqzadko,sec)"
      focus $panneau(acqzadko,$visuNo,base).intervalle_continu_1.but1
   }
}
#***** Fin de si une simulation a deja ete faite pour la fenetre Continu (1) *************

#***** Fenetre de configuration images a intervalle regulier en continu ******************
proc ::acqzadko::Intervalle_continu_2 { visuNo } {
   global caption conf panneau

   set panneau(acqzadko,$visuNo,intervalle)            "...."
   set panneau(acqzadko,$visuNo,simulation_deja_faite) "0"

   ::acqzadko::recup_position $visuNo

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(acqzadko,continu2,position) ] } { set conf(acqzadko,continu2,position) "+120+260" }

   #--- Creation de la fenetre Continu 2
   toplevel $panneau(acqzadko,$visuNo,base).intervalle_continu_2
   wm transient $panneau(acqzadko,$visuNo,base).intervalle_continu_2 $panneau(acqzadko,$visuNo,base)
   wm resizable $panneau(acqzadko,$visuNo,base).intervalle_continu_2 0 0
   wm title $panneau(acqzadko,$visuNo,base).intervalle_continu_2 "$caption(acqzadko,continu_2)"
   wm geometry $panneau(acqzadko,$visuNo,base).intervalle_continu_2 $conf(acqzadko,continu2,position)
   wm protocol $panneau(acqzadko,$visuNo,base).intervalle_continu_2 WM_DELETE_WINDOW " \
      set panneau(acqzadko,$visuNo,mode_en_cours) \"$caption(acqzadko,continu_2)\" \
   "

   #--- Create the message
   label $panneau(acqzadko,$visuNo,base).intervalle_continu_2.lab1 -text "$caption(acqzadko,titre_2)"
   pack $panneau(acqzadko,$visuNo,base).intervalle_continu_2.lab1 -padx 10 -pady 5

   frame $panneau(acqzadko,$visuNo,base).intervalle_continu_2.a
      label $panneau(acqzadko,$visuNo,base).intervalle_continu_2.a.lab2 -text "$caption(acqzadko,intervalle_2)"
      pack $panneau(acqzadko,$visuNo,base).intervalle_continu_2.a.lab2 -anchor center -expand 1 -fill none -side left \
         -padx 10 -pady 5
      entry $panneau(acqzadko,$visuNo,base).intervalle_continu_2.a.ent1 -width 5 -relief groove \
         -textvariable panneau(acqzadko,$visuNo,intervalle_2) -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $panneau(acqzadko,$visuNo,base).intervalle_continu_2.a.ent1 -anchor center -expand 1 -fill none -side left \
         -padx 10
   pack $panneau(acqzadko,$visuNo,base).intervalle_continu_2.a -padx 10 -pady 5

   frame $panneau(acqzadko,$visuNo,base).intervalle_continu_2.b
      checkbutton $panneau(acqzadko,$visuNo,base).intervalle_continu_2.b.check_simu \
         -text "$caption(acqzadko,simu_deja_faite)" \
         -variable panneau(acqzadko,$visuNo,simulation_deja_faite) -command "::acqzadko::Simu_deja_faite_2 $visuNo"
      pack $panneau(acqzadko,$visuNo,base).intervalle_continu_2.b.check_simu -anchor w -expand 1 -fill none \
         -side left -padx 10 -pady 5
   pack $panneau(acqzadko,$visuNo,base).intervalle_continu_2.b -side bottom -anchor w -padx 10 -pady 5

   button $panneau(acqzadko,$visuNo,base).intervalle_continu_2.but1 -text "$caption(acqzadko,simulation)" \
      -command "::acqzadko::Command_continu_2 $visuNo"
   pack $panneau(acqzadko,$visuNo,base).intervalle_continu_2.but1 -anchor center -expand 1 -fill none -side left \
      -ipadx 5 -ipady 3 -padx 10 -pady 5

   set simu2 "$caption(acqzadko,int_mini_image) $panneau(acqzadko,$visuNo,intervalle) $caption(acqzadko,sec)"
   label $panneau(acqzadko,$visuNo,base).intervalle_continu_2.lab3 -text "$simu2"
   pack $panneau(acqzadko,$visuNo,base).intervalle_continu_2.lab3 -anchor center -expand 1 -fill none -side left -padx 10

   #--- New message window is on
   focus $panneau(acqzadko,$visuNo,base).intervalle_continu_2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $panneau(acqzadko,$visuNo,base).intervalle_continu_2
}
#***** Fin fenetre de configuration images a intervalle regulier en continu **************

#***** Commande associee au bouton simulation de la fenetre Continu (2) ******************
proc ::acqzadko::Command_continu_2 { visuNo } {
   global caption panneau

   set panneau(acqzadko,$visuNo,intervalle) "...."
   set simu2 "$caption(acqzadko,int_mini_image) $panneau(acqzadko,$visuNo,intervalle) $caption(acqzadko,sec)"
   $panneau(acqzadko,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
   set panneau(acqzadko,$visuNo,simulation)  "2"
   set panneau(acqzadko,$visuNo,mode)        "2"
   set panneau(acqzadko,$visuNo,index_temp)  $panneau(acqzadko,$visuNo,index)
   set panneau(acqzadko,$visuNo,nombre_temp) $panneau(acqzadko,$visuNo,nb_images)
   set panneau(acqzadko,$visuNo,nb_images)   "1"
   ::acqzadko::Go $visuNo
}
#***** Fin de la commande associee au bouton simulation de la fenetre Continu (2) ********

#***** Si une simulation a deja ete faite pour la fenetre Continu (2) ********************
proc ::acqzadko::Simu_deja_faite_2 { visuNo } {
   global caption panneau

   if { $panneau(acqzadko,$visuNo,simulation_deja_faite) == "1" } {
      set panneau(acqzadko,$visuNo,intervalle) "xxxx" ; \
      $panneau(acqzadko,$visuNo,base).intervalle_continu_2.lab3 configure \
         -text "$caption(acqzadko,int_mini_image) $panneau(acqzadko,$visuNo,intervalle) $caption(acqzadko,sec)"
      focus $panneau(acqzadko,$visuNo,base).intervalle_continu_2.a.ent1
   } else {
      set panneau(acqzadko,$visuNo,intervalle) "...."
      $panneau(acqzadko,$visuNo,base).intervalle_continu_2.lab3 configure \
         -text "$caption(acqzadko,int_mini_image) $panneau(acqzadko,$visuNo,intervalle) $caption(acqzadko,sec)"
      focus $panneau(acqzadko,$visuNo,base).intervalle_continu_2.but1
   }
}
#***** Fin de si une simulation a deja ete faite pour la fenetre Continu (2) *************

#***** Enregistrement de la position des fenetres Continu (1) et Continu (2) *************
proc ::acqzadko::recup_position { visuNo } {
   global conf panneau

   #--- Cas de la fenetre Continu (1)
   if [ winfo exists $panneau(acqzadko,$visuNo,base).intervalle_continu_1 ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqzadko,$visuNo,base).intervalle_continu_1 ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(acqzadko,continu1,position) "+[ string range $geometry $deb $fin ]"
      #--- Fermeture de la fenetre
      destroy $panneau(acqzadko,$visuNo,base).intervalle_continu_1
   }
   #--- Cas de la fenetre Continu (2)
   if [ winfo exists $panneau(acqzadko,$visuNo,base).intervalle_continu_2 ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqzadko,$visuNo,base).intervalle_continu_2 ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(acqzadko,continu2,position) "+[ string range $geometry $deb $fin ]"
      #--- Fermeture de la fenetre
      destroy $panneau(acqzadko,$visuNo,base).intervalle_continu_2
   }
}
#***** Fin enregistrement de la position des fenetres Continu (1) et Continu (2) *********

#***** Enregistrement de la position de la fenetre Avancement ********
proc ::acqzadko::recup_position_1 { visuNo } {
   global panneau

   #--- Cas de la fenetre Avancement
   if [ winfo exists $panneau(acqzadko,$visuNo,base).progress ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqzadko,$visuNo,base).progress ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set panneau(acqzadko,$visuNo,avancement,position) "+[ string range $geometry $deb $fin ]"
   }
}
#***** Fin enregistrement de la position de la fenetre Avancement ****

#***** Affichage de la fenetre de configuration de WebCam ************
proc ::acqzadko::webcamConfigure { visuNo } {
   global audace caption

   set result [::webcam::config::run $visuNo [::confVisu::getCamItem $visuNo]]
   if { $result == "1" } {
      if { [ ::confVisu::getCamItem $visuNo ] == "" } {
         ::audace::menustate disabled
         set choix [ tk_messageBox -title $caption(acqzadko,pb) -type ok \
            -message $caption(acqzadko,selcam) ]
         set integre non
         if { $choix == "ok" } {
            #--- Ouverture de la fenetre de selection des cameras
            #--- Tue camera.exe
            if {[lindex [hostaddress] end]=="ikon"} {
               package require twapi
               set res [twapi::get_process_ids -glob -name "camera.exe"]
               if {$res!=""} {
                  twapi::end_process $res -force
               }
            }
            ::confCam::run
         }
         ::audace::menustate normal
      }
   }
}
#***** Affichage de la fenetre de configuration de WebCam ************
proc ::acqzadko::camConfigure { visuNo } {
   global audace caption

   #--- Tue camera.exe
   if {[lindex [hostaddress] end]=="ikon"} {
      package require twapi
      set res [twapi::get_process_ids -glob -name "camera.exe"]
      if {$res!=""} {
         twapi::end_process $res -force
      }
   }
   ::confCam::run
}

#***** Fin de la fenetre de configuration de WebCam ******************

proc ::acqzadko::acqzadkoBuildIF { visuNo } {
   global audace caption conf panneau

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   #--- Trame du panneau
   frame $panneau(acqzadko,$visuNo,This) -borderwidth 2 -relief groove

   #--- Trame du titre du panneau
   frame $panneau(acqzadko,$visuNo,This).titre -borderwidth 2 -relief groove
      Button $panneau(acqzadko,$visuNo,This).titre.but -borderwidth 1 \
         -text "$caption(acqzadko,help_titre1)\n$caption(acqzadko,titre)" \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqzadko::getPluginType ] ] \
            [ ::acqzadko::getPluginDirectory ] [ ::acqzadko::getPluginHelp ]"
      pack $panneau(acqzadko,$visuNo,This).titre.but -side top -fill x -in $panneau(acqzadko,$visuNo,This).titre -ipadx 5
      DynamicHelp::add $panneau(acqzadko,$visuNo,This).titre.but -text $caption(acqzadko,help_titre)
   pack $panneau(acqzadko,$visuNo,This).titre -side top -fill x

   #--- Trame du bouton de configuration
   frame $panneau(acqzadko,$visuNo,This).config -borderwidth 2 -relief groove
      button $panneau(acqzadko,$visuNo,This).config.but -borderwidth 1 -text $caption(acqzadko,configuration) \
        -command "::acqzadkoSetup::run $visuNo $base.acqzadkoSetup"
      pack $panneau(acqzadko,$visuNo,This).config.but -side top -fill x -in $panneau(acqzadko,$visuNo,This).config -ipadx 5 -ipady 4
   pack $panneau(acqzadko,$visuNo,This).config -side top -fill x

   #--- Trame du bouton de connection de la camera
   frame $panneau(acqzadko,$visuNo,This).camera -borderwidth 2 -relief groove
      button $panneau(acqzadko,$visuNo,This).camera.but -borderwidth 1 -text $caption(acqzadko,connectioncamera) \
        -command "::acqzadko::camConfigure $visuNo"
      pack $panneau(acqzadko,$visuNo,This).camera.but -side top -fill x -in $panneau(acqzadko,$visuNo,This).camera -ipadx 5 -ipady 4
   pack $panneau(acqzadko,$visuNo,This).camera -side top -fill x

   #--- Trame du bouton affichage de la raquette
   frame $panneau(acqzadko,$visuNo,This).raquette -borderwidth 2 -relief groove
      button $panneau(acqzadko,$visuNo,This).raquette.but -borderwidth 1 -text $caption(acqzadko,raquettetel) \
        -command "::confPad::run"
      pack $panneau(acqzadko,$visuNo,This).raquette.but -side top -fill x -in $panneau(acqzadko,$visuNo,This).raquette -ipadx 5 -ipady 4
   pack $panneau(acqzadko,$visuNo,This).raquette -side top -fill x

   #--- Trame du temps de pose
   frame $panneau(acqzadko,$visuNo,This).pose -borderwidth 2 -relief ridge
      menubutton $panneau(acqzadko,$visuNo,This).pose.but -text $caption(acqzadko,pose) \
         -menu $panneau(acqzadko,$visuNo,This).pose.but.menu -relief raised
      pack $panneau(acqzadko,$visuNo,This).pose.but -side left -fill x -expand true -ipady 1
      set m [ menu $panneau(acqzadko,$visuNo,This).pose.but.menu -tearoff 0 ]
      foreach temps $panneau(acqzadko,$visuNo,temps_pose) {
        $m add radiobutton -label "$temps" \
           -indicatoron "1" \
           -value "$temps" \
           -variable panneau(acqzadko,$visuNo,pose) \
           -command " "
      }
      label $panneau(acqzadko,$visuNo,This).pose.lab -text $caption(acqzadko,sec)
      pack $panneau(acqzadko,$visuNo,This).pose.lab -side right -fill x -expand true
      entry $panneau(acqzadko,$visuNo,This).pose.entr -width 6 -relief groove \
         -textvariable panneau(acqzadko,$visuNo,pose) -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $panneau(acqzadko,$visuNo,This).pose.entr -side left -fill both -expand true
   pack $panneau(acqzadko,$visuNo,This).pose -side top -fill x

   #--- Bouton de configuration de la WebCam en lieu et place du widget pose
   button $panneau(acqzadko,$visuNo,This).pose.conf -text $caption(acqzadko,pose) \
      -command "::acqzadko::webcamConfigure $visuNo"
   pack $panneau(acqzadko,$visuNo,This).pose.conf -fill x -expand true -ipady 3

   #--- Trame du binning
   frame $panneau(acqzadko,$visuNo,This).binning -borderwidth 2 -relief ridge
      menubutton $panneau(acqzadko,$visuNo,This).binning.but -text $caption(acqzadko,bin) \
         -menu $panneau(acqzadko,$visuNo,This).binning.but.menu -relief raised
      pack $panneau(acqzadko,$visuNo,This).binning.but -side left -fill y -expand true -ipady 1
      set m [ menu $panneau(acqzadko,$visuNo,This).binning.but.menu -tearoff 0 ]
      foreach valbin [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] binningList ] {
         $m add radiobutton -label "$valbin" \
            -indicatoron "1" \
            -value "$valbin" \
            -variable panneau(acqzadko,$visuNo,binning) \
            -command " "
      }
      entry $panneau(acqzadko,$visuNo,This).binning.lab -width 10 -relief groove \
         -textvariable panneau(acqzadko,$visuNo,binning) -justify center \
         -validate all -validatecommand { ::tkutil::validateString %W %V %P %s binning 1 5 }
      pack $panneau(acqzadko,$visuNo,This).binning.lab -side left -fill both -expand true
   pack $panneau(acqzadko,$visuNo,This).binning -side top -fill x

   #--- Trame du format
   frame $panneau(acqzadko,$visuNo,This).format -borderwidth 2 -relief ridge
      menubutton $panneau(acqzadko,$visuNo,This).format.but -text $caption(acqzadko,format) \
         -menu $panneau(acqzadko,$visuNo,This).format.but.menu -relief raised
      pack $panneau(acqzadko,$visuNo,This).format.but -side left -fill y -expand true -ipady 1
      set m [ menu $panneau(acqzadko,$visuNo,This).format.but.menu -tearoff 0 ]
      foreach format [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] formatList ] {
         $m add radiobutton -label "$format" \
            -indicatoron "1" \
            -value "$format" \
            -variable panneau(acqzadko,$visuNo,format) \
            -command " "
      }
      entry $panneau(acqzadko,$visuNo,This).format.lab -width 10 -relief groove \
         -textvariable panneau(acqzadko,$visuNo,format) -justify center -state readonly
      pack $panneau(acqzadko,$visuNo,This).format.lab -side left -fill both -expand true
   pack $panneau(acqzadko,$visuNo,This).format -side top -fill x

   #--- Trame de l'obturateur
   frame $panneau(acqzadko,$visuNo,This).obt -borderwidth 2 -relief ridge -width 16
      button $panneau(acqzadko,$visuNo,This).obt.but -text $caption(acqzadko,obt) -command "::acqzadko::ChangeObt $visuNo" \
         -state normal
      pack $panneau(acqzadko,$visuNo,This).obt.but -side left -ipady 3
      label $panneau(acqzadko,$visuNo,This).obt.lab -text $panneau(acqzadko,$visuNo,obt,$panneau(acqzadko,$visuNo,obt)) -width 6 \
        -relief groove
      pack $panneau(acqzadko,$visuNo,This).obt.lab -side left -fill x -expand true -ipady 3
   pack $panneau(acqzadko,$visuNo,This).obt -side top -fill x

   #--- Trame du Status
   frame $panneau(acqzadko,$visuNo,This).status -borderwidth 2 -relief ridge
      label $panneau(acqzadko,$visuNo,This).status.lab -text "" -relief ridge \
         -justify center -width 16
      pack $panneau(acqzadko,$visuNo,This).status.lab -side top -fill x -pady 1
   pack $panneau(acqzadko,$visuNo,This).status -side top -fill x

   #--- Trame du bouton Go/Stop
   frame $panneau(acqzadko,$visuNo,This).go_stop -borderwidth 2 -relief ridge
      Button $panneau(acqzadko,$visuNo,This).go_stop.but -text $caption(acqzadko,GO) -height 2 \
         -borderwidth 3 -command "::acqzadko::Go $visuNo"
      pack $panneau(acqzadko,$visuNo,This).go_stop.but -fill both -padx 0 -pady 0 -expand true
   pack $panneau(acqzadko,$visuNo,This).go_stop -side top -fill x

   #--- Trame du mode d'acquisition
   set panneau(acqzadko,$visuNo,mode_en_cours) [ lindex $panneau(acqzadko,$visuNo,list_mode) [ expr $panneau(acqzadko,$visuNo,mode) - 1 ] ]
   frame $panneau(acqzadko,$visuNo,This).mode -borderwidth 5 -relief ridge
      ComboBox $panneau(acqzadko,$visuNo,This).mode.but \
         -width 15         \
         -height [llength $panneau(acqzadko,$visuNo,list_mode)] \
         -relief raised    \
         -borderwidth 1    \
         -editable 0       \
         -takefocus 1      \
         -justify center   \
         -textvariable panneau(acqzadko,$visuNo,mode_en_cours) \
         -values $panneau(acqzadko,$visuNo,list_mode) \
         -modifycmd "::acqzadko::ChangeMode $visuNo"
      pack $panneau(acqzadko,$visuNo,This).mode.but -side top -fill x

      #--- Definition du sous-panneau "Mode : Une seule image"
      frame $panneau(acqzadko,$visuNo,This).mode.une -borderwidth 0
         frame $panneau(acqzadko,$visuNo,This).mode.une.nom -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.une.nom.but -text $caption(acqzadko,nom) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.une.nom.but -fill x -side top
            entry $panneau(acqzadko,$visuNo,This).mode.une.nom.entr -width 10 \
               -textvariable panneau(acqzadko,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqzadko,$visuNo,This).mode.une.nom.entr -fill x -side top
            label $panneau(acqzadko,$visuNo,This).mode.une.nom.lab_extension -text $caption(acqzadko,extension) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.une.nom.lab_extension -fill x -side left
            menubutton $panneau(acqzadko,$visuNo,This).mode.une.nom.extension -textvariable panneau(acqzadko,$visuNo,extension) \
               -menu $panneau(acqzadko,$visuNo,This).mode.une.nom.extension.menu -relief raised
            pack $panneau(acqzadko,$visuNo,This).mode.une.nom.extension -side right -fill x -expand true -ipady 1
            set m [ menu $panneau(acqzadko,$visuNo,This).mode.une.nom.extension.menu -tearoff 0 ]
            foreach extension $::audace(extensionList) {
              $m add radiobutton -label "$extension" \
                 -indicatoron "1" \
                 -value "$extension" \
                 -variable panneau(acqzadko,$visuNo,extension) \
                 -command " "
            }
         pack $panneau(acqzadko,$visuNo,This).mode.une.nom -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.une.index -relief ridge -borderwidth 2
            checkbutton $panneau(acqzadko,$visuNo,This).mode.une.index.case -pady 0 -text $caption(acqzadko,index) \
               -variable panneau(acqzadko,$visuNo,indexer)
            pack $panneau(acqzadko,$visuNo,This).mode.une.index.case -side top -fill x
            entry $panneau(acqzadko,$visuNo,This).mode.une.index.entr -width 3 -textvariable panneau(acqzadko,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqzadko,$visuNo,This).mode.une.index.entr -side left -fill x -expand true
            button $panneau(acqzadko,$visuNo,This).mode.une.index.but -text "1" -width 3 \
               -command "set panneau(acqzadko,$visuNo,index) 1"
            pack $panneau(acqzadko,$visuNo,This).mode.une.index.but -side right -fill x
         pack $panneau(acqzadko,$visuNo,This).mode.une.index -side top -fill x
         button $panneau(acqzadko,$visuNo,This).mode.une.sauve -text $caption(acqzadko,sauvegde) \
            -command "::acqzadko::SauveUneImage $visuNo"
         pack $panneau(acqzadko,$visuNo,This).mode.une.sauve -side top -fill x

      #--- Definition du sous-panneau "Mode : Serie d'images"
      frame $panneau(acqzadko,$visuNo,This).mode.serie
         frame $panneau(acqzadko,$visuNo,This).mode.serie.nom -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.serie.nom.but -text $caption(acqzadko,nom) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.serie.nom.but -fill x
            entry $panneau(acqzadko,$visuNo,This).mode.serie.nom.entr -width 10 \
               -textvariable panneau(acqzadko,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqzadko,$visuNo,This).mode.serie.nom.entr -fill x
            label $panneau(acqzadko,$visuNo,This).mode.serie.nom.lab_extension -text $caption(acqzadko,extension) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.serie.nom.lab_extension -fill x -side left
            menubutton $panneau(acqzadko,$visuNo,This).mode.serie.nom.extension -textvariable panneau(acqzadko,$visuNo,extension) \
               -menu $panneau(acqzadko,$visuNo,This).mode.serie.nom.extension.menu -relief raised
            pack $panneau(acqzadko,$visuNo,This).mode.serie.nom.extension -side right -fill x -expand true -ipady 1
            set m [ menu $panneau(acqzadko,$visuNo,This).mode.serie.nom.extension.menu -tearoff 0 ]
            foreach extension $::audace(extensionList) {
              $m add radiobutton -label "$extension" \
                 -indicatoron "1" \
                 -value "$extension" \
                 -variable panneau(acqzadko,$visuNo,extension) \
                 -command " "
            }
         pack $panneau(acqzadko,$visuNo,This).mode.serie.nom -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.serie.nb -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.serie.nb.but -text $caption(acqzadko,nombre) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.serie.nb.but -side left -fill y
            entry $panneau(acqzadko,$visuNo,This).mode.serie.nb.entr -width 3 -textvariable panneau(acqzadko,$visuNo,nb_images) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqzadko,$visuNo,This).mode.serie.nb.entr -side left -fill x -expand true
         pack $panneau(acqzadko,$visuNo,This).mode.serie.nb -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.serie.index -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.serie.index.lab -text $caption(acqzadko,index) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.serie.index.lab -side top -fill x
            entry $panneau(acqzadko,$visuNo,This).mode.serie.index.entr -width 3 -textvariable panneau(acqzadko,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqzadko,$visuNo,This).mode.serie.index.entr -side left -fill x -expand true
            button $panneau(acqzadko,$visuNo,This).mode.serie.index.but -text "1" -width 3 \
               -command "set panneau(acqzadko,$visuNo,index) 1"
            pack $panneau(acqzadko,$visuNo,This).mode.serie.index.but -side right -fill x
         pack $panneau(acqzadko,$visuNo,This).mode.serie.index -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.serie.indexEnd -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.serie.indexEnd.lab1 \
               -textvariable panneau(acqzadko,$visuNo,indexEndSerie) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.serie.indexEnd.lab1 -side top -fill x
         pack $panneau(acqzadko,$visuNo,This).mode.serie.indexEnd -side top -fill x

      #--- Definition du sous-panneau "Mode : Continu"
      frame $panneau(acqzadko,$visuNo,This).mode.continu
         frame $panneau(acqzadko,$visuNo,This).mode.continu.sauve -relief ridge -borderwidth 2
            checkbutton $panneau(acqzadko,$visuNo,This).mode.continu.sauve.case -text $caption(acqzadko,enregistrer) \
               -variable panneau(acqzadko,$visuNo,enregistrer)
            pack $panneau(acqzadko,$visuNo,This).mode.continu.sauve.case -side left -fill x  -expand true
         pack $panneau(acqzadko,$visuNo,This).mode.continu.sauve -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.continu.nom -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.continu.nom.but -text $caption(acqzadko,nom) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.continu.nom.but -fill x
            entry $panneau(acqzadko,$visuNo,This).mode.continu.nom.entr -width 10 \
               -textvariable panneau(acqzadko,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqzadko,$visuNo,This).mode.continu.nom.entr -fill x
            label $panneau(acqzadko,$visuNo,This).mode.continu.nom.lab_extension -text $caption(acqzadko,extension) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.continu.nom.lab_extension -fill x -side left
            menubutton $panneau(acqzadko,$visuNo,This).mode.continu.nom.extension -textvariable panneau(acqzadko,$visuNo,extension) \
               -menu $panneau(acqzadko,$visuNo,This).mode.continu.nom.extension.menu -relief raised
            pack $panneau(acqzadko,$visuNo,This).mode.continu.nom.extension -side right -fill x -expand true -ipady 1
            set m [ menu $panneau(acqzadko,$visuNo,This).mode.continu.nom.extension.menu -tearoff 0 ]
            foreach extension $::audace(extensionList) {
              $m add radiobutton -label "$extension" \
                 -indicatoron "1" \
                 -value "$extension" \
                 -variable panneau(acqzadko,$visuNo,extension) \
                 -command " "
            }
         pack $panneau(acqzadko,$visuNo,This).mode.continu.nom -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.continu.index -relief ridge -borderwidth 2
            checkbutton $panneau(acqzadko,$visuNo,This).mode.continu.index.case -pady 0 -text $caption(acqzadko,index) \
               -variable panneau(acqzadko,$visuNo,indexerContinue)
            pack $panneau(acqzadko,$visuNo,This).mode.continu.index.case -side top -fill x
            entry $panneau(acqzadko,$visuNo,This).mode.continu.index.entr -width 3 -textvariable panneau(acqzadko,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqzadko,$visuNo,This).mode.continu.index.entr -side left -fill x -expand true
            button $panneau(acqzadko,$visuNo,This).mode.continu.index.but -text "1" -width 3 \
               -command "set panneau(acqzadko,$visuNo,index) 1"
            pack $panneau(acqzadko,$visuNo,This).mode.continu.index.but -side right -fill x
         pack $panneau(acqzadko,$visuNo,This).mode.continu.index -side top -fill x

      #--- Definition du sous-panneau "Mode : Series d'images en continu avec intervalle entre chaque serie"
      frame $panneau(acqzadko,$visuNo,This).mode.serie_1
         frame $panneau(acqzadko,$visuNo,This).mode.serie_1.nom -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.but -text $caption(acqzadko,nom) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.but -fill x
            entry $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.entr -width 10 \
               -textvariable panneau(acqzadko,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.entr -fill x
            label $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.lab_extension -text $caption(acqzadko,extension) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.lab_extension -fill x -side left
            menubutton $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.extension -textvariable panneau(acqzadko,$visuNo,extension) \
               -menu $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.extension.menu -relief raised
            pack $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.extension -side right -fill x -expand true -ipady 1
            set m [ menu $panneau(acqzadko,$visuNo,This).mode.serie_1.nom.extension.menu -tearoff 0 ]
            foreach extension $::audace(extensionList) {
              $m add radiobutton -label "$extension" \
                 -indicatoron "1" \
                 -value "$extension" \
                 -variable panneau(acqzadko,$visuNo,extension) \
                 -command " "
            }
         pack $panneau(acqzadko,$visuNo,This).mode.serie_1.nom -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.serie_1.nb -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.serie_1.nb.but -text $caption(acqzadko,nombre) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.serie_1.nb.but -side left -fill y
            entry $panneau(acqzadko,$visuNo,This).mode.serie_1.nb.entr -width 3 -textvariable panneau(acqzadko,$visuNo,nb_images) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqzadko,$visuNo,This).mode.serie_1.nb.entr -side left -fill x -expand true
         pack $panneau(acqzadko,$visuNo,This).mode.serie_1.nb -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.serie_1.index -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.serie_1.index.lab -text $caption(acqzadko,index) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.serie_1.index.lab -side top -fill x
            entry $panneau(acqzadko,$visuNo,This).mode.serie_1.index.entr -width 3 -textvariable panneau(acqzadko,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqzadko,$visuNo,This).mode.serie_1.index.entr -side left -fill x -expand true
            button $panneau(acqzadko,$visuNo,This).mode.serie_1.index.but -text "1" -width 3 \
               -command "set panneau(acqzadko,$visuNo,index) 1"
            pack $panneau(acqzadko,$visuNo,This).mode.serie_1.index.but -side right -fill x
         pack $panneau(acqzadko,$visuNo,This).mode.serie_1.index -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.serie_1.indexEnd -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.serie_1.indexEnd.lab1 \
               -textvariable panneau(acqzadko,$visuNo,indexEndSerieContinu) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.serie_1.indexEnd.lab1 -side top -fill x
         pack $panneau(acqzadko,$visuNo,This).mode.serie_1.indexEnd -side top -fill x

      #--- Definition du sous-panneau "Mode : Continu avec intervalle entre chaque image"
      frame $panneau(acqzadko,$visuNo,This).mode.continu_1
         frame $panneau(acqzadko,$visuNo,This).mode.continu_1.sauve -relief ridge -borderwidth 2
            checkbutton $panneau(acqzadko,$visuNo,This).mode.continu_1.sauve.case -text $caption(acqzadko,enregistrer) \
               -variable panneau(acqzadko,$visuNo,enregistrer)
            pack $panneau(acqzadko,$visuNo,This).mode.continu_1.sauve.case -side left -fill x  -expand true
         pack $panneau(acqzadko,$visuNo,This).mode.continu_1.sauve -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.continu_1.nom -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.but -text $caption(acqzadko,nom) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.but -fill x
            entry $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.entr -width 10 \
               -textvariable panneau(acqzadko,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.entr -fill x
            label $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.lab_extension -text $caption(acqzadko,extension) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.lab_extension -fill x -side left
            menubutton $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.extension -textvariable panneau(acqzadko,$visuNo,extension) \
               -menu $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.extension.menu -relief raised
            pack $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.extension -side right -fill x -expand true -ipady 1
            set m [ menu $panneau(acqzadko,$visuNo,This).mode.continu_1.nom.extension.menu -tearoff 0 ]
            foreach extension $::audace(extensionList) {
              $m add radiobutton -label "$extension" \
                 -indicatoron "1" \
                 -value "$extension" \
                 -variable panneau(acqzadko,$visuNo,extension) \
                 -command " "
            }
         pack $panneau(acqzadko,$visuNo,This).mode.continu_1.nom -side top -fill x
         frame $panneau(acqzadko,$visuNo,This).mode.continu_1.index -relief ridge -borderwidth 2
            label $panneau(acqzadko,$visuNo,This).mode.continu_1.index.lab -text $caption(acqzadko,index) -pady 0
            pack $panneau(acqzadko,$visuNo,This).mode.continu_1.index.lab -side top -fill x
            entry $panneau(acqzadko,$visuNo,This).mode.continu_1.index.entr -width 3 -textvariable panneau(acqzadko,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqzadko,$visuNo,This).mode.continu_1.index.entr -side left -fill x -expand true
            button $panneau(acqzadko,$visuNo,This).mode.continu_1.index.but -text "1" -width 3 \
               -command "set panneau(acqzadko,$visuNo,index) 1"
            pack $panneau(acqzadko,$visuNo,This).mode.continu_1.index.but -side right -fill x
         pack $panneau(acqzadko,$visuNo,This).mode.continu_1.index -side top -fill x
     pack $panneau(acqzadko,$visuNo,This).mode -side top -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $panneau(acqzadko,$visuNo,This).avancement_acq -borderwidth 2 -relief ridge
         #--- Checkbutton petit deplacement
         checkbutton $panneau(acqzadko,$visuNo,This).avancement_acq.check -highlightthickness 0 \
            -text $caption(acqzadko,avancement_acq) -variable panneau(acqzadko,$visuNo,avancement_acq)
         pack $panneau(acqzadko,$visuNo,This).avancement_acq.check -side left -fill x
      pack $panneau(acqzadko,$visuNo,This).avancement_acq -side top -fill x

      #--- Frame petit decalage
      frame $panneau(acqzadko,$visuNo,This).shift -borderwidth 2 -relief ridge
         #--- Checkbutton petit deplacement
         checkbutton $panneau(acqzadko,$visuNo,This).shift.buttonShift -highlightthickness 0 \
            -variable panneau(DlgShiftZadko,buttonShift)
         pack $panneau(acqzadko,$visuNo,This).shift.buttonShift -side left -fill x
         #--- Bouton configuration petit deplacement
         button $panneau(acqzadko,$visuNo,This).shift.buttonShiftConfig -text "$caption(acqzadko,buttonShiftConfig)" \
            -command "::acqzadko::cmdShiftConfig $visuNo"
         pack $panneau(acqzadko,$visuNo,This).shift.buttonShiftConfig -side right -fill x -expand true
      pack $panneau(acqzadko,$visuNo,This).shift -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(acqzadko,$visuNo,This)
}

