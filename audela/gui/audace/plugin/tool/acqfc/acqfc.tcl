#
# Fichier : acqfc.tcl
# Description : Outil d'acquisition
# Auteur : Francois Cochard
# Mise à jour $Id: acqfc.tcl 13161 2016-02-13 17:57:47Z robertdelmas $
#

#==============================================================
#   Declaration du namespace acqfc
#==============================================================

namespace eval ::acqfc {
   package provide acqfc 4.1

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] acqfc.cap ]
}

#***** Procedure createPluginInstance***************************
proc ::acqfc::createPluginInstance { base { visuNo 1 } } {
   variable parametres
   global audace caption conf panneau

   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfc acqfcSetup.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfc dlgshift.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfc acqfcAutoFlat.tcl ]\""

   #---
   set panneau(acqfc,$visuNo,base) "$base"
   set panneau(acqfc,$visuNo,This) "$base.acqfc"

   set panneau(acqfc,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
   set panneau(acqfc,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqfc,$visuNo,camItem)]

   #--- Recuperation de la derniere configuration de l'outil
   ::acqfc::chargerVariable $visuNo

   #--- Initialisation des variables de la boite de configuration
   ::acqfcSetup::confToWidget $visuNo

   #--- Initialisation des variables de la boite de decalage du telescope
   ::DlgShift::confToWidget $visuNo

   #--- Initialisation de la variable conf()
   if { ! [info exists conf(acqfc,avancement,position)] } { set conf(acqfc,avancement,position) "+120+315" }

   #--- Initialisation de variables
   set panneau(acqfc,$visuNo,simulation)            "0"
   set panneau(acqfc,$visuNo,simulation_deja_faite) "0"
   set panneau(acqfc,$visuNo,attente_pose)          "0"
   set panneau(acqfc,$visuNo,pose_en_cours)         "0"
   set panneau(acqfc,$visuNo,avancement,position)   "$conf(acqfc,avancement,position)"

   #--- Entrer ici les valeurs de temps de pose a afficher dans le menu "pose"
   set panneau(acqfc,$visuNo,temps_pose) { 0 0.1 0.3 0.5 1 2 3 5 10 15 20 30 60 90 120 180 300 600 }
   #--- Valeur par defaut du temps de pose
   if { ! [ info exists panneau(acqfc,$visuNo,pose) ] } {
      set panneau(acqfc,$visuNo,pose) "$parametres(acqfc,$visuNo,pose)"
   }

   #--- Valeur par defaut du binning
   if { ! [ info exists panneau(acqfc,$visuNo,binning) ] } {
      set panneau(acqfc,$visuNo,binning) "$parametres(acqfc,$visuNo,bin)"
   }

   #--- Valeur par defaut du zoom
   if { ! [ info exists panneau(acqfc,$visuNo,zoom) ] } {
      set panneau(acqfc,$visuNo,zoom) "$parametres(acqfc,$visuNo,zoom)"
   }

   #--- Valeur par defaut de la qualite
   if { ! [ info exists panneau(acqfc,$visuNo,format) ] } {
      set panneau(acqfc,$visuNo,format) "$parametres(acqfc,$visuNo,format)"
   }

   #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
   set panneau(acqfc,$visuNo,obt,0) "$caption(acqfc,ouv)"
   set panneau(acqfc,$visuNo,obt,1) "$caption(acqfc,ferme)"
   set panneau(acqfc,$visuNo,obt,2) "$caption(acqfc,auto)"

   #--- Obturateur par defaut : Synchro
   if { ! [ info exists panneau(acqfc,$visuNo,obt) ] } {
      set panneau(acqfc,$visuNo,obt) "$parametres(acqfc,$visuNo,obt)"
   }

   #--- Liste des modes disponibles
   set panneau(acqfc,$visuNo,list_mode) [ list $caption(acqfc,uneimage) $caption(acqfc,serie) $caption(acqfc,continu) \
      $caption(acqfc,continu_1) $caption(acqfc,continu_2) ]

   #--- Initialisation des modes
   set panneau(acqfc,$visuNo,mode,1) "$panneau(acqfc,$visuNo,This).mode.une"
   set panneau(acqfc,$visuNo,mode,2) "$panneau(acqfc,$visuNo,This).mode.serie"
   set panneau(acqfc,$visuNo,mode,3) "$panneau(acqfc,$visuNo,This).mode.continu"
   set panneau(acqfc,$visuNo,mode,4) "$panneau(acqfc,$visuNo,This).mode.serie_1"
   set panneau(acqfc,$visuNo,mode,5) "$panneau(acqfc,$visuNo,This).mode.continu_1"
   #--- Mode par defaut : Une image
   if { ! [ info exists panneau(acqfc,$visuNo,mode) ] } {
      set panneau(acqfc,$visuNo,mode) "$parametres(acqfc,$visuNo,mode)"
   } else {
      if { $panneau(acqfc,$visuNo,mode) > 5 } {
         #--- je positionne mode=1 si un mode > 5 dans le fichier de configuration,
         #--- car les modes 6 et 7 n'exitent plus. Ils sont deplaces dans l'outil d'acquisition video.
         set panneau(acqfc,$visuNo,mode) 1
      }
   }

   #--- Initialisation d'autres variables
   set panneau(acqfc,$visuNo,index)                "1"
   set panneau(acqfc,$visuNo,indexEndSerie)        ""
   set panneau(acqfc,$visuNo,indexEndSerieContinu) ""
   set panneau(acqfc,$visuNo,nom_image)            ""
   set panneau(acqfc,$visuNo,extension)            "$conf(extension,defaut)"
   set panneau(acqfc,$visuNo,indexer)              "0"
   set panneau(acqfc,$visuNo,indexerContinue)      "1"
   set panneau(acqfc,$visuNo,nb_images)            "5"
   set panneau(acqfc,$visuNo,session_ouverture)    "1"
   set panneau(acqfc,$visuNo,avancement_acq)       "$parametres(acqfc,$visuNo,avancement_acq)"
   set panneau(acqfc,$visuNo,enregistrer)          "$parametres(acqfc,$visuNo,enregistrer)"
   set panneau(acqfc,$visuNo,dispTimeAfterId)      ""
   set panneau(acqfc,$visuNo,intervalle_1)         ""
   set panneau(acqfc,$visuNo,intervalle_2)         ""
   #--- Mise en place de l'interface graphique
   acqfcBuildIF $visuNo

   pack $panneau(acqfc,$visuNo,mode,$panneau(acqfc,$visuNo,mode)) -anchor nw -fill x

   #--- Surveillance de la connexion d'une camera
   ::confVisu::addCameraListener $visuNo "::acqfc::adaptOutilAcqFC $visuNo"
   #--- Surveillance de l'ajout ou de la suppression d'une extension
   trace add variable ::audace(extensionList) write "::acqfc::initExtensionList $visuNo"

   #---
   return $panneau(acqfc,$visuNo,This)
}
#***** Fin de la procedure createPluginInstance*****************

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::acqfc::deletePluginInstance { visuNo } {
   global conf panneau


   #--- Je desactive la surveillance de la connexion d'une camera
   ::confVisu::removeCameraListener $visuNo "::acqfc::adaptOutilAcqFC $visuNo"
   #--- Je desactive la surveillance de l'ajout ou de la suppression d'une extension
   trace remove variable ::audace(extensionList) write "::acqfc::initExtensionList $visuNo"

   #---
   set conf(acqfc,avancement,position) $panneau(acqfc,$visuNo,avancement,position)

   #---
   destroy $panneau(acqfc,$visuNo,This)
   destroy $panneau(acqfc,$visuNo,This).pose.but.menu
   destroy $panneau(acqfc,$visuNo,This).binning.but.menu
   destroy $panneau(acqfc,$visuNo,This).format.but.menu
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::acqfc::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "" }
      display      { return "panel" }
      multivisu    { return 1 }
      rank         { return 1 }
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::acqfc::getPluginTitle { } {
   global caption

   return "$caption(acqfc,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::acqfc::getPluginHelp { } {
   return "acqfc.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::acqfc::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
#  getPluginDirectory
#     retourne le repertoire du plugin
#------------------------------------------------------------
proc ::acqfc::getPluginDirectory { } {
   return "acqfc"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::acqfc::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#***** Procedure DemarrageAcqFC ********************************
proc ::acqfc::DemarrageAcqFC { visuNo } {
   global audace caption

   #--- Creation du sous-repertoire a la date du jour
   #--- en mode automatique s'il n'existe pas
   ::cwdWindow::updateImageDirectory

   #--- Gestion du fichier de log
   #--- Creation du nom du fichier log
   set nom_generique "acqfc-visu$visuNo-"
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
   set ::acqfc::fichier_log [ file join $audace(rep_images) "$file_log$nom_generique$formatdate.log" ]

   #--- Ouverture du fichier de log
   if { [ catch { open $::acqfc::fichier_log a } ::acqfc::log_id($visuNo) ] } {
      Message $visuNo console $caption(acqfc,pbouvfichcons)
      tk_messageBox -title $caption(acqfc,pb) -type ok \
         -message $caption(acqfc,pbouvfich)
      #--- Note importante : Je detecte si j'ai un pb a l'ouverture du fichier, mais je ne sais pas traiter ce cas :
      #--- Il faudrait interdire l'ouverture du panneau, mais le processus est deja lance a ce stade...
      #--- Tout ce que je fais, c'est inviter l'utilisateur a changer d'outil !
   } else {
      #--- En-tete du fichier
      Message $visuNo log $caption(acqfc,ouvsess) [ package version acqfc ]
      set date [clock format [clock seconds] -format "%A %d %B %Y"]
      set date [ ::tkutil::transalteDate $date ]
      set heure $audace(tu,format,hmsint)
      Message $visuNo consolog $caption(acqfc,affheure) $date $heure
      #--- Definition du binding pour declencher l'acquisition (ou l'arret) par Echap.
      bind all <Key-Escape> "::acqfc::Stop $visuNo"
   }
}
#***** Fin de la procedure DemarrageAcqFC **********************

#***** Procedure ArretAcqFC ************************************
proc ::acqfc::ArretAcqFC { visuNo } {
   global audace caption panneau

   #--- Fermeture du fichier de log
   if { [ info exists ::acqfc::log_id($visuNo) ] } {
      set heure $audace(tu,format,hmsint)
      #--- Je m'assure que le fichier se termine correctement, en particulier pour le cas ou il y
      #--- a eu un probleme a l'ouverture (c'est un peu une rustine...)
      if { [ catch { Message $visuNo log $caption(acqfc,finsess) $heure } bug ] } {
         Message $visuNo console $caption(acqfc,pbfermfichcons)
      } else {
         Message $visuNo console "\n"
         close $::acqfc::log_id($visuNo)
         unset ::acqfc::log_id($visuNo)
      }
   }
   #--- Re-initialisation de la session
   set panneau(acqfc,$visuNo,session_ouverture) "1"
   #--- Desactivation du binding pour declencher l'acquisition (ou l'arret) par Echap.
   bind all <Key-Escape> { }
}
#***** Fin de la procedure ArretAcqFC **************************

#***** Procedure initExtensionList *****************************
proc ::acqfc::initExtensionList { visuNo { a "" } { b "" } { c "" } } {
   global conf panneau

   #--- Mise a jour de l'extension par defaut
   set panneau(acqfc,$visuNo,extension) $conf(extension,defaut)
   set camItem [ ::confVisu::getCamItem $visuNo ]
   set extensionList " $::audace(extensionList) [ confCam::getPluginProperty $camItem rawExtension ]"

   #--- Mise a jour de la liste des extensions disponibles pour le mode "Une seule image"
   $panneau(acqfc,$visuNo,This).mode.une.nom.extension.menu delete 0 20
   foreach extension $extensionList {
      $panneau(acqfc,$visuNo,This).mode.une.nom.extension.menu add radiobutton -label "$extension" \
         -indicatoron "1" \
         -value "$extension" \
         -variable panneau(acqfc,$visuNo,extension) \
         -command " "
   }
   #--- Mise a jour de la liste des extensions disponibles pour le mode "Serie d'images"
   $panneau(acqfc,$visuNo,This).mode.serie.nom.extension.menu delete 0 20
   foreach extension $extensionList {
      $panneau(acqfc,$visuNo,This).mode.serie.nom.extension.menu add radiobutton -label "$extension" \
         -indicatoron "1" \
         -value "$extension" \
         -variable panneau(acqfc,$visuNo,extension) \
         -command " "
   }
   #--- Mise a jour de la liste des extensions disponibles pour le mode "Continu"
   $panneau(acqfc,$visuNo,This).mode.continu.nom.extension.menu delete 0 20
   foreach extension $extensionList {
      $panneau(acqfc,$visuNo,This).mode.continu.nom.extension.menu add radiobutton -label "$extension" \
         -indicatoron "1" \
         -value "$extension" \
         -variable panneau(acqfc,$visuNo,extension) \
         -command " "
   }
   #--- Mise a jour de la liste des extensions disponibles pour le mode "Series d'images en continu avec intervalle entre chaque serie"
   $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension.menu delete 0 20
   foreach extension $extensionList {
      $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension.menu add radiobutton -label "$extension" \
         -indicatoron "1" \
         -value "$extension" \
         -variable panneau(acqfc,$visuNo,extension) \
         -command " "
   }
   #--- Mise a jour de la liste des extensions disponibles pour le mode "Continu avec intervalle entre chaque image"
   $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension.menu delete 0 20
   foreach extension $extensionList {
      $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension.menu add radiobutton -label "$extension" \
         -indicatoron "1" \
         -value "$extension" \
         -variable panneau(acqfc,$visuNo,extension) \
         -command " "
   }
}
#***** Fin de la procedure initExtensionList *******************

#***** Procedure adaptOutilAcqFC *******************************
proc ::acqfc::adaptOutilAcqFC { visuNo args } {
   global conf panneau

   set panneau(acqfc,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
   set panneau(acqfc,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqfc,$visuNo,camItem)]

   #--- petits reccorcis bien utiles
   set camItem $panneau(acqfc,$visuNo,camItem)
   set camNo   $panneau(acqfc,$visuNo,camNo)
   if { $camNo == "0" } {
      #--- La camera n'a pas ete encore selectionnee
      set camProduct ""
   } else {
      set camProduct [ cam$camNo product ]
   }

   #--- widgets de pose
   if { [ confCam::getPluginProperty $camItem longExposure ] == "1" } {
      #--- j'affiche les boutons standard de choix de pose
      pack $panneau(acqfc,$visuNo,This).pose.but -side left
      pack $panneau(acqfc,$visuNo,This).pose.lab -side right
      pack $panneau(acqfc,$visuNo,This).pose.entr -side left -fill both -expand true
      #---- je masque le widget specifique
      pack forget $panneau(acqfc,$visuNo,This).pose.conf
   } else {
      #--- je masque les widgets standards
      pack forget $panneau(acqfc,$visuNo,This).pose.but
      pack forget $panneau(acqfc,$visuNo,This).pose.lab
      pack forget $panneau(acqfc,$visuNo,This).pose.entr
      #--- j'affiche le bouton specifique
      pack $panneau(acqfc,$visuNo,This).pose.conf -fill x -expand true -ipady 3
   }

   #--- widgets de binning
   if { [ ::confCam::getPluginProperty $camItem hasBinning ] == "1" } {
      $panneau(acqfc,$visuNo,This).binning.but.menu delete 0 20
      set binningList [ ::confCam::getPluginProperty $camItem binningList ]
      foreach binning $binningList {
         $panneau(acqfc,$visuNo,This).binning.but.menu add radiobutton -label "$binning" \
            -indicatoron "1" \
            -value $binning \
            -variable panneau(acqfc,$visuNo,binning) \
            -command " "
      }
      #--- je verifie que le binning preselectionne existe dans la liste
      if { [lsearch $binningList $panneau(acqfc,$visuNo,binning) ] == -1 } {
         #--- si le binning n'existe pas je selectionne la première valeur par defaut
         set  panneau(acqfc,$visuNo,binning) [lindex $binningList 0]
      }
      #--- j'affiche la frame du binning
      pack $panneau(acqfc,$visuNo,This).binning -side top -fill x -before $panneau(acqfc,$visuNo,This).status
   } else {
      #--- je masque la frame du binning
      pack forget $panneau(acqfc,$visuNo,This).binning
   }

   #--- widgets du format d'image
   if { [ ::confCam::getPluginProperty $camItem hasFormat ] == "1" } {
      $panneau(acqfc,$visuNo,This).format.but.menu delete 0 20
      #--- j'affiche le bouton du format
      set formatList [ ::confCam::getPluginProperty $camItem formatList ]
      foreach format $formatList {
         $panneau(acqfc,$visuNo,This).format.but.menu add radiobutton -label $format \
            -indicatoron "1" \
            -value $format \
            -variable panneau(acqfc,$visuNo,format) \
            -command " "
      }
      #--- je verifie que le format preselectionne existe dans la liste
      if { [lsearch $formatList $panneau(acqfc,$visuNo,format) ] == -1 } {
         #--- si le format n'existe pas je selectionne la première valeur par defaut
         set panneau(acqfc,$visuNo,format) [lindex $formatList 0]
      }
      #--- j'affiche la frame du format
      pack $panneau(acqfc,$visuNo,This).format -side top -fill x -before $panneau(acqfc,$visuNo,This).status
   } else {
      #--- je masque la frame du format
      pack forget $panneau(acqfc,$visuNo,This).format
   }

   #--- widgets de l'obturateur
   if { [ ::confCam::getPluginProperty $camItem hasShutter ] == "1" } {
      if { ! [ info exists conf($camProduct,foncobtu) ] } {
         set conf($camProduct,foncobtu) "2"
      } else {
         if { $conf($camProduct,foncobtu) == "0" } {
            set panneau(acqfc,$visuNo,obt) "0"
         } elseif { $conf($camProduct,foncobtu) == "1" } {
            set panneau(acqfc,$visuNo,obt) "1"
         } elseif { $conf($camProduct,foncobtu) == "2" } {
            set panneau(acqfc,$visuNo,obt) "2"
         }
      }
      $panneau(acqfc,$visuNo,This).obt.lab configure -text $panneau(acqfc,$visuNo,obt,$panneau(acqfc,$visuNo,obt))
      #--- j'affiche la frame de l'obturateur
      pack $panneau(acqfc,$visuNo,This).obt -side top -fill x -before $panneau(acqfc,$visuNo,This).status
   } else {
      #--- je masque la frame de l'obturateur
      pack forget $panneau(acqfc,$visuNo,This).obt
   }

   #--- je mets a jour la liste des extensions
   ::acqfc::initExtensionList $visuNo
}

#***** Procedure chargerVariable *******************************
proc ::acqfc::chargerVariable { visuNo } {
   variable parametres

   #--- Ouverture du fichier de parametres
   set fichier [ file join $::audace(rep_home) acqfc.ini ]
   if { [ file exists $fichier ] } {
      source $fichier
   }

   #--- Creation des variables si elles n'existent pas
   if { ! [ info exists parametres(acqfc,$visuNo,pose) ] }           { set parametres(acqfc,$visuNo,pose)        "5" }   ; #--- Temps de pose : 5s
   if { ! [ info exists parametres(acqfc,$visuNo,bin) ] }            { set parametres(acqfc,$visuNo,bin)         "1x1" } ; #--- Binning : 2x2
   if { ! [ info exists parametres(acqfc,$visuNo,zoom) ] }           { set parametres(acqfc,$visuNo,zoom)        "1" }   ; #--- Zoom : 1
   if { ! [ info exists parametres(acqfc,$visuNo,format) ] }         { set parametres(acqfc,$visuNo,format)      "" }    ; #--- Format des APN
   if { ! [ info exists parametres(acqfc,$visuNo,obt) ] }            { set parametres(acqfc,$visuNo,obt)         "2" }   ; #--- Obturateur : Synchro
   if { ! [ info exists parametres(acqfc,$visuNo,mode) ] }           { set parametres(acqfc,$visuNo,mode)        "1" }   ; #--- Mode : Une image
   if { ! [ info exists parametres(acqfc,$visuNo,enregistrer) ] }    { set parametres(acqfc,$visuNo,enregistrer) "1" }   ; #--- Sauvegarde des images : Oui
   if { ! [ info exists parametres(acqfc,$visuNo,avancement_acq) ] } {
      if { $visuNo == "1" } {
         set parametres(acqfc,$visuNo,avancement_acq) "1" ; #--- Barre de progression de la pose : Oui
      } else {
         set parametres(acqfc,$visuNo,avancement_acq) "0" ; #--- Barre de progression de la pose : Non
      }
   }

   #--- Creation des variables de la boite de configuration si elles n'existent pas
   ::acqfcSetup::initToConf $visuNo

   #--- Creation des variables de la boite de decalage du telescope si elles n'existent pas
   ::DlgShift::initToConf $visuNo
}
#***** Fin de la procedure chargerVariable *********************

#***** Procedure enregistrerVariable ***************************
proc ::acqfc::enregistrerVariable { visuNo } {
   variable parametres
   global panneau

   #---
   set panneau(acqfc,$visuNo,mode)              [ expr [ lsearch "$panneau(acqfc,$visuNo,list_mode)" "$panneau(acqfc,$visuNo,mode_en_cours)" ] + 1 ]
   #---
   set parametres(acqfc,$visuNo,pose)           $panneau(acqfc,$visuNo,pose)
   set parametres(acqfc,$visuNo,bin)            $panneau(acqfc,$visuNo,binning)
   set parametres(acqfc,$visuNo,zoom)           $panneau(acqfc,$visuNo,zoom)
   set parametres(acqfc,$visuNo,format)         $panneau(acqfc,$visuNo,format)
   set parametres(acqfc,$visuNo,obt)            $panneau(acqfc,$visuNo,obt)
   set parametres(acqfc,$visuNo,mode)           $panneau(acqfc,$visuNo,mode)
   set parametres(acqfc,$visuNo,avancement_acq) $panneau(acqfc,$visuNo,avancement_acq)
   set parametres(acqfc,$visuNo,enregistrer)    $panneau(acqfc,$visuNo,enregistrer)

   #--- Sauvegarde des parametres
   catch {
     set nom_fichier [ file join $::audace(rep_home) acqfc.ini ]
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
proc ::acqfc::startTool { { visuNo 1 } } {
   global panneau

   #--- On cree la variable de configuration des mots cles
   if { ! [ info exists ::conf(acqfc,keywordConfigName) ] } { set ::conf(acqfc,keywordConfigName) "default" }

   #--- Creation des fenetres auxiliaires si necessaire
   if { $panneau(acqfc,$visuNo,mode) == "4" } {
      ::acqfc::Intervalle_continu_1 $visuNo
   } elseif { $panneau(acqfc,$visuNo,mode) == "5" } {
      ::acqfc::Intervalle_continu_2 $visuNo
   }

   #--- Je selectionne les mots cles selon les exigences de l'outil
   ::acqfc::configToolKeywords $visuNo

   ::acqfc::adaptOutilAcqFC $visuNo
}
#***** Fin de la procedure startTool ***************************

#***** Procedure isBusy **************************************
##@brief indique si l'outil est occupé par un traitement
#
# @param visuNo   numéro de la visu
# @return  1 si l'outil est occupé , sinon retourne 0
#
proc ::acqfc::isBusy { { visuNo 1 } } {
   global panneau

   #--- Je verifie si une operation est en cours
   if { $panneau(acqfc,$visuNo,pose_en_cours) == 1 } {
      return 1
   }

   #--- Je verifie si une operation est en cours (acquisition des flats auto)
   if { [ info exists ::acqfcAutoFlat::private(pose_en_cours) ] } {
      if { $::acqfcAutoFlat::private(pose_en_cours) == 1 } {
         return 1
      }
   }

   return 0
}

#***** Procedure stopTool **************************************
proc ::acqfc::stopTool { { visuNo 1 } } {
   global panneau

   #--- Je desactive le timer s'il existe
   if { $panneau(acqfc,$visuNo,dispTimeAfterId) != "" } {
      after cancel $panneau(acqfc,$visuNo,dispTimeAfterId)
      set panneau(acqfc,$visuNo,dispTimeAfterId) ""
   }

   #--- Sauvegarde de la configuration de prise de vue
   ::acqfc::enregistrerVariable $visuNo

   #--- Je supprime la liste des mots clefs non modifiables
   ::keyword::setKeywordState $visuNo $::conf(acqfc,keywordConfigName) [ list ]

   #--- Destruction des fenetres auxiliaires et sauvegarde de leurs positions si elles existent
   ::acqfc::recup_position $visuNo

   #--- J'arrete l'outil d'acquisition
   ArretAcqFC $visuNo
}
#***** Fin de la procedure stopTool ****************************

#***** Procedure de changement du mode d'acquisition ***********
proc ::acqfc::ChangeMode { visuNo { mode "" } } {
   global panneau

   pack forget $panneau(acqfc,$visuNo,mode,$panneau(acqfc,$visuNo,mode)) -anchor nw -fill x

   if { $mode != "" } {
      #--- j'applique le mode passe en parametre
      set panneau(acqfc,$visuNo,mode_en_cours) $mode
   }

   set panneau(acqfc,$visuNo,mode) [ expr [ lsearch "$panneau(acqfc,$visuNo,list_mode)" "$panneau(acqfc,$visuNo,mode_en_cours)" ] + 1 ]
   if { $panneau(acqfc,$visuNo,mode) == "1" } {
      ::acqfc::recup_position $visuNo
   } elseif { $panneau(acqfc,$visuNo,mode) == "2" } {
     ::acqfc::recup_position $visuNo
   } elseif { $panneau(acqfc,$visuNo,mode) == "3" } {
      ::acqfc::recup_position $visuNo
   } elseif { $panneau(acqfc,$visuNo,mode) == "4" } {
      ::acqfc::Intervalle_continu_1 $visuNo
   } elseif { $panneau(acqfc,$visuNo,mode) == "5" } {
      ::acqfc::Intervalle_continu_2 $visuNo
   }
   pack $panneau(acqfc,$visuNo,mode,$panneau(acqfc,$visuNo,mode)) -anchor nw -fill x
}
#***** Fin de la procedure de changement du mode d'acquisition *

#***** Procedure de changement de l'obturateur *****************
proc ::acqfc::ChangeObt { visuNo } {
   global panneau

   #---
   set camItem [ ::confVisu::getCamItem $visuNo ]
   set result [::confCam::setShutter $camItem $panneau(acqfc,$visuNo,obt) ]
   if { $result != -1 } {
      set panneau(acqfc,$visuNo,obt) $result
      $panneau(acqfc,$visuNo,This).obt.lab configure -text $panneau(acqfc,$visuNo,obt,$panneau(acqfc,$visuNo,obt))
   }
}
#***** Fin de la procedure de changement de l'obturateur *******

#----------------------------------------------------------------------------
# setShutter
#   force l'obturateur de la camera a l'etat donnee en parametre
#
# parametres :
#    visuNo: numero de la visu
#    state : etat de l'obturateur (0=ouvert 1=ferme 2=synchro )
#----------------------------------------------------------------------------
proc ::acqfc::setShutter { visuNo state } {
   global panneau

   set camItem [ ::confVisu::getCamItem $visuNo ]
   if { [ ::confCam::getPluginProperty $camItem hasShutter ] == 1 } {
      set panneau(acqfc,$visuNo,obt) [::confCam::setShutter $camItem $state "set" ]
      $panneau(acqfc,$visuNo,This).obt.lab configure -text $panneau(acqfc,$visuNo,obt,$panneau(acqfc,$visuNo,obt))
   }
}

#------------------------------------------------------------
# testParametreAcquisition
#   Tests generaux d'integrite de la requete
#
# return
#   retourne oui ou non
#------------------------------------------------------------
proc ::acqfc::testParametreAcquisition { visuNo } {
   global caption panneau

   #--- Recopie de l'extension des fichiers image
   set ext $panneau(acqfc,$visuNo,extension)
   set camItem [ ::confVisu::getCamItem $visuNo ]

   #--- Desactive le bouton Go, pour eviter un double appui
   $panneau(acqfc,$visuNo,This).go_stop.but configure -state disabled

   #------ Tests generaux de l'integrite de la requete
   set integre oui

   #--- Tester si une camera est bien selectionnee
   if { [ ::confVisu::getCamItem $visuNo ] == "" } {
      ::audace::menustate disabled
      set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
         -message $caption(acqfc,selcam) ]
      set integre non
      if { $choix == "ok" } {
         #--- Ouverture de la fenetre de selection des cameras
         ::confCam::run
      }
      ::audace::menustate normal
   }

   #--- Le temps de pose existe-t-il ?
   if { $panneau(acqfc,$visuNo,pose) == "" } {
      tk_messageBox -title $caption(acqfc,pb) -type ok \
         -message $caption(acqfc,saistps)
      set integre non
   }

   #--- Tests d'integrite specifiques a chaque mode d'acquisition
   if { $integre == "oui" } {
      #--- Branchement selon le mode de prise de vue
      switch $panneau(acqfc,$visuNo,mode) {
         1  {
            #--- Mode une image
            if { $panneau(acqfc,$visuNo,indexer) == "1" } {
               #--- Verifie que l'index existe
               if { $panneau(acqfc,$visuNo,index) == "" } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                      -message $caption(acqfc,saisind)
                  set integre non
               }
            }
            #--- Pas de decalage du telescope
            set panneau(DlgShift,buttonShift) "0"
         }
         2  {
            #--- Mode serie
            #--- Les tests ne sont pas necessaires pendant une simulation
            if { $panneau(acqfc,$visuNo,simulation) == "0" } {
               #--- Verifier qu'il y a bien un nom de fichier
               if { $panneau(acqfc,$visuNo,nom_image) == "" } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,donnomfich)
                  set integre non
               }
               #--- Verifier que le nom de fichier n'a pas d'espace
               if { [ llength $panneau(acqfc,$visuNo,nom_image) ] > "1" } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,nomblanc)
                  set integre non
               }
               #--- Verifier que l'index existe
               if { $panneau(acqfc,$visuNo,index) == "" } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                      -message $caption(acqfc,saisind)
                  set integre non
               }
               #--- Envoyer un warning si l'index n'est pas a 1
               if { $panneau(acqfc,$visuNo,index) != "1" && $panneau(acqfc,$visuNo,verifier_index_depart) == 1 } {
                  set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                     -message $caption(acqfc,indpasun)]
                  if { $confirmation == "no" } {
                     set integre non
                  }
               }
               #--- Verifier que le nombre de poses existe
               if { $panneau(acqfc,$visuNo,nb_images) == "" } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                      -message $caption(acqfc,nbinv)
                  set integre non
               }
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShift,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,seltel) ]
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
            if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
               #--- Verifier qu'il y a bien un nom de fichier
               if { $panneau(acqfc,$visuNo,nom_image) == "" } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,donnomfich)
                  set integre non
               }
               #--- Verifier que le nom de fichier n'a pas d'espace
               if { [ llength $panneau(acqfc,$visuNo,nom_image) ] > "1" } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,nomblanc)
                  set integre non
               }
               #--- Verifier que l'index existe
               if { $panneau(acqfc,$visuNo,indexerContinue) == "1" } {
                  if { $panneau(acqfc,$visuNo,index) == "" } {
                     tk_messageBox -title $caption(acqfc,pb) -type ok \
                         -message $caption(acqfc,saisind)
                     set integre non
                  }
               }
               #--- Envoyer un warning si l'index n'est pas a 1
               if { $panneau(acqfc,$visuNo,indexerContinue) == "1" } {
                  if { $panneau(acqfc,$visuNo,index) != "1" && $panneau(acqfc,$visuNo,verifier_index_depart) == 1 } {
                     set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                        -message $caption(acqfc,indpasun)]
                     if { $confirmation == "no" } {
                        set integre non
                     }
                  }
               }
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShift,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,seltel) ]
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
            if { $panneau(acqfc,$visuNo,nom_image) == "" } {
               tk_messageBox -title $caption(acqfc,pb) -type ok \
                  -message $caption(acqfc,donnomfich)
               set integre non
            }
            #--- Verifier que le nom de fichier n'a pas d'espace
            if { [ llength $panneau(acqfc,$visuNo,nom_image) ] > "1" } {
               tk_messageBox -title $caption(acqfc,pb) -type ok \
                  -message $caption(acqfc,nomblanc)
               set integre non
            }
            #--- Verifier que l'index existe
            if { $panneau(acqfc,$visuNo,index) == "" } {
               tk_messageBox -title $caption(acqfc,pb) -type ok \
                   -message $caption(acqfc,saisind)
               set integre non
            }
            #--- Envoyer un warning si l'index n'est pas a 1
            if { $panneau(acqfc,$visuNo,index) != "1" && $panneau(acqfc,$visuNo,verifier_index_depart) == 1 } {
               set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                  -message $caption(acqfc,indpasun)]
               if { $confirmation == "no" } {
                  set integre non
               }
            }
            #--- Verifier que le nombre de poses existe
            if { $panneau(acqfc,$visuNo,nb_images) == "" } {
               tk_messageBox -title $caption(acqfc,pb) -type ok \
                   -message $caption(acqfc,nbinv)
               set integre non
            }
            #--- Verifier que la simulation a ete lancee
            if { $panneau(acqfc,$visuNo,intervalle) == "...." } {
               tk_messageBox -title $caption(acqfc,pb) -type ok \
                  -message $caption(acqfc,interinv_2)
               set integre non
            #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
            } elseif { ( $panneau(acqfc,$visuNo,intervalle) > $panneau(acqfc,$visuNo,intervalle_1) ) && \
              ( $panneau(acqfc,$visuNo,intervalle) != "xxxx" ) } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,interinv_1)
                  set integre non
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShift,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,seltel) ]
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
            if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
               #--- Verifier qu'il y a bien un nom de fichier
               if { $panneau(acqfc,$visuNo,nom_image) == "" } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,donnomfich)
                  set integre non
               }
               #--- Verifier que le nom de fichier n'a pas d'espace
               if { [ llength $panneau(acqfc,$visuNo,nom_image) ] > "1" } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,nomblanc)
                  set integre non
               }
               #--- Verifier que l'index existe
               if { $panneau(acqfc,$visuNo,index) == "" } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                      -message $caption(acqfc,saisind)
                  set integre non
               }
               #--- Envoyer un warning si l'index n'est pas a 1
               if { $panneau(acqfc,$visuNo,index) != "1" && $panneau(acqfc,$visuNo,verifier_index_depart) == 1 } {
                  set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                     -message $caption(acqfc,indpasun)]
                  if { $confirmation == "no" } {
                     set integre non
                  }
               }
               #--- Verifier que la simulation a ete lancee
               if { $panneau(acqfc,$visuNo,intervalle) == "...." } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,interinv_2)
                  set integre non
               #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
               } elseif { ( $panneau(acqfc,$visuNo,intervalle) > $panneau(acqfc,$visuNo,intervalle_2) ) && \
                 ( $panneau(acqfc,$visuNo,intervalle) != "xxxx" ) } {
                     tk_messageBox -title $caption(acqfc,pb) -type ok \
                        -message $caption(acqfc,interinv_1)
                     set integre non
               }
            } else {
               #--- Verifier que la simulation a ete lancee
               if { $panneau(acqfc,$visuNo,intervalle) == "...." } {
                  tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,interinv_2)
                  set integre non
               #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
               } elseif { ( $panneau(acqfc,$visuNo,intervalle) > $panneau(acqfc,$visuNo,intervalle_2) ) && \
                 ( $panneau(acqfc,$visuNo,intervalle) != "xxxx" ) } {
                     tk_messageBox -title $caption(acqfc,pb) -type ok \
                        -message $caption(acqfc,interinv_1)
                     set integre non
               }
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShift,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,seltel) ]
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
   $panneau(acqfc,$visuNo,This).go_stop.but configure -state normal

   return $integre

}

#------------------------------------------------------------
# getInfo
#   retourne les informations courantes sur l'etat de l'outil
#
# @param visuNo
# @return
#   * exptime
#   * binning
#   * mode
#   * status de pose (en cours = 1
#   * nom de la camera
#------------------------------------------------------------
proc ::acqfc::getInfo { visuNo } {
   set result ""

   lappend result $::panneau(acqfc,$visuNo,pose)
   lappend result $::panneau(acqfc,$visuNo,binning)
   lappend result $::panneau(acqfc,$visuNo,mode)
   lappend result $::panneau(acqfc,$visuNo,pose_en_cours)
   set camNo [::confCam::getCamNo $::panneau(acqfc,$visuNo,camItem)]
   if { $camNo != 0 } {
      lappend result [cam$camNo name]
   } else {
      lappend result ""
   }
   return $result
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
proc ::acqfc::startAcquisitionUneImage { visuNo expTime binning fileName} {

   set ::panneau(acqfc,$visuNo,pose)      $expTime
   set ::panneau(acqfc,$visuNo,binning)   $binning
   set ::panneau(acqfc,$visuNo,nom_image) $fileName
   set ::panneau(acqfc,$visuNo,mode)      "1"
   set ::panneau(acqfc,$visuNo,indexer)   "0"

   ChangeMode $visuNo $::caption(acqfc,uneimage)

   #--- je lance l'acquisition
   ::acqfc::Go $visuNo

   if { $fileName != "" } {
      ::acqfc::SauveUneImage $visuNo
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
proc ::acqfc::startAcquisitionSerieImage { visuNo expTime binning fileName imageNb} {

   set ::panneau(acqfc,$visuNo,pose)      $expTime
   set ::panneau(acqfc,$visuNo,binning)   $binning
   set ::panneau(acqfc,$visuNo,nom_image) $fileName
   set ::panneau(acqfc,$visuNo,nb_images) $imageNb
   set ::panneau(acqfc,$visuNo,indexer)   "1"
   set ::panneau(acqfc,$visuNo,index)     "1"

   ChangeMode $visuNo $::caption(acqfc,serie)

   #--- je lance les acquisitions
   ::acqfc::Go $visuNo

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
proc ::acqfc::stopAcquisition { visuNo } {
   global panneau

   if { $panneau(acqfc,$visuNo,pose_en_cours) == 1 } {
      Stop $visuNo
   }
}

#***** Procedure Go (appui sur le bouton Go/Stop) *********
proc ::acqfc::Go { visuNo } {
   global audace caption panneau

   set camItem [::confVisu::getCamItem $visuNo]
   set camNo $panneau(acqfc,$visuNo,camNo)

   #--- Ouverture du fichier historique
   if { $panneau(acqfc,$visuNo,save_file_log) == "1" } {
      if { $panneau(acqfc,$visuNo,session_ouverture) == "1" } {
         DemarrageAcqFC $visuNo
         set panneau(acqfc,$visuNo,session_ouverture) "0"
      }
   }

   #--- je verifie l'integrite des parametres
   set integre [testParametreAcquisition $visuNo]
   if { $integre != "oui" } {
      return
   }

   #--- Modification du bouton, pour eviter un second lancement
   $panneau(acqfc,$visuNo,This).go_stop.but configure -text $caption(acqfc,stop) \
      -command "::acqfc::Stop $visuNo"
   #--- Verrouille tous les boutons et champs de texte pendant les acquisitions
   $panneau(acqfc,$visuNo,This).pose.but configure -state disabled
   $panneau(acqfc,$visuNo,This).pose.entr configure -state disabled
   $panneau(acqfc,$visuNo,This).binning.but configure -state disabled
   $panneau(acqfc,$visuNo,This).format.but configure -state disabled
   $panneau(acqfc,$visuNo,This).obt.but configure -state disabled
   $panneau(acqfc,$visuNo,This).mode.but configure -state disabled
   #--- Desactive toute demande d'arret
   set panneau(acqfc,$visuNo,demande_arret) "0"
   #--- Pose en cours
   set panneau(acqfc,$visuNo,pose_en_cours) "1"
   #--- Enregistrement d'une image interrompue
   set panneau(acqfc,$visuNo,sauve_img_interrompue) "0"

   set catchResult [catch {
      #--- Cas particulier du passage WebCam LP en WebCam normale pour inhiber la barre progression
      if { ( [::confCam::getPluginProperty $camItem "hasVideo"] == 1 ) && ( [ confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] longExposure ] == "0" ) } {
         set panneau(acqfc,$visuNo,pose) "0"
      }

      #--- Si je fais un offset (pose de 0s) alors l'obturateur reste ferme
      if { $panneau(acqfc,$visuNo,pose) == "0" } {
         cam$camNo shutter "closed"
      }

      if { [::confCam::getPluginProperty $panneau(acqfc,$visuNo,camItem) hasBinning] == "1" } {
         #--- je selectionne le binning
         set binning [list [string range $panneau(acqfc,$visuNo,binning) 0 0] [string range $panneau(acqfc,$visuNo,binning) 2 2]]
         #--- je verifie que le binning est conforme
         set ctrl [ scan $panneau(acqfc,$visuNo,binning) "%dx%d" binx biny ]
         if { $ctrl == 2 } {
            set ctrlValue [ format $binx%s$biny x ]
            if { $ctrlValue != $panneau(acqfc,$visuNo,binning) } {
               set binning "1 1"
               set panneau(acqfc,$visuNo,binning) "1x1"
            }
         } else {
            set binning "1 1"
            set panneau(acqfc,$visuNo,binning) "1x1"
         }
         #--- j'applique le binning
         cam$camNo bin $binning
         set binningMessage $panneau(acqfc,$visuNo,binning)
      } else {
         set binningMessage "1x1"
      }

      if { [::confCam::getPluginProperty $panneau(acqfc,$visuNo,camItem) hasFormat] == "1" } {
         #--- je selectionne le format des images
         ::confCam::setFormat $panneau(acqfc,$visuNo,camItem) $panneau(acqfc,$visuNo,format)
         set binningMessage "$panneau(acqfc,$visuNo,format)"
      }

      #--- je verrouille les widgets selon le mode de prise de vue
      switch $panneau(acqfc,$visuNo,mode) {
         1  {
            #--- Mode une image
            #--- Verrouille les boutons du mode "une image"
            $panneau(acqfc,$visuNo,This).mode.une.nom.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.une.index.case configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.une.index.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.une.index.but configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.une.sauve configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqfc,acquneim) \
               $panneau(acqfc,$visuNo,pose) $binningMessage $heure
            #--- je ne fais qu'une image dans ce mode
            set nbImages 1
         }
         2  {
            #--- Mode serie
            #--- Verrouille les boutons du mode "serie"
            $panneau(acqfc,$visuNo,This).mode.serie.nom.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.serie.nb.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.serie.index.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.serie.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            if { $panneau(acqfc,$visuNo,simulation) != "0" } {
               Message $visuNo consolog $caption(acqfc,lance_simu)
               #--- Heure de debut de la premiere pose
               set panneau(acqfc,$visuNo,debut) [ clock second ]
            }
            Message $visuNo consolog $caption(acqfc,lanceserie) \
               $panneau(acqfc,$visuNo,nb_images) $heure
            Message $visuNo consolog $caption(acqfc,nomgen) $panneau(acqfc,$visuNo,nom_image) \
               $panneau(acqfc,$visuNo,pose) $binningMessage $panneau(acqfc,$visuNo,index)
            #--- je recupere le nombre d'images de la serie donne par l'utilisateur
            set nbImages $panneau(acqfc,$visuNo,nb_images)
         }
         3  {
            #--- Mode continu
            #--- Verrouille les boutons du mode "continu"
            $panneau(acqfc,$visuNo,This).mode.continu.sauve.case configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.continu.nom.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.continu.index.case configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.continu.index.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.continu.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqfc,lancecont) $panneau(acqfc,$visuNo,pose) \
               $binningMessage $heure
            if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
               if { $panneau(acqfc,$visuNo,indexerContinue) == "1" } {
                  Message $visuNo consolog $caption(acqfc,enregen) \
                    $panneau(acqfc,$visuNo,nom_image)
               } else {
                  Message $visuNo consolog $caption(acqfc,enrenongen) \
                    $panneau(acqfc,$visuNo,nom_image)
               }
            } else {
               Message $visuNo consolog $caption(acqfc,sansenr)
            }
            #--- il n'y a pas de nombre d'image
            set nbImages ""
         }
         4  {
            #--- Mode series d'images en continu avec intervalle entre chaque serie
            #--- Verrouille les boutons du mode "continu 1"
            $panneau(acqfc,$visuNo,This).mode.serie_1.nom.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.serie_1.nb.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.serie_1.index.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.serie_1.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqfc,lanceserie_int) \
               $panneau(acqfc,$visuNo,nb_images) $panneau(acqfc,$visuNo,intervalle_1) $heure
            Message $visuNo consolog $caption(acqfc,nomgen) $panneau(acqfc,$visuNo,nom_image) \
               $panneau(acqfc,$visuNo,pose) $binningMessage $panneau(acqfc,$visuNo,index)
            #--- Je note l'heure de debut de la premiere serie (utile pour les series espacees)
            set panneau(acqfc,$visuNo,deb_serie) [ clock second ]
            #--- je recupere le nombre d'images des series donne par l'utilisateur
            set nbImages $panneau(acqfc,$visuNo,nb_images)
         }
         5  {
            #--- Mode continu avec intervalle entre chaque image
            #--- Verrouille les boutons du mode "continu 2"
            $panneau(acqfc,$visuNo,This).mode.continu_1.sauve.case configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.continu_1.nom.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.continu_1.index.entr configure -state disabled
            $panneau(acqfc,$visuNo,This).mode.continu_1.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqfc,lancecont_int) $panneau(acqfc,$visuNo,intervalle_2) \
               $panneau(acqfc,$visuNo,pose) $binningMessage $heure
            if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
               Message $visuNo consolog $caption(acqfc,enregen) \
                 $panneau(acqfc,$visuNo,nom_image)
            } else {
               Message $visuNo consolog $caption(acqfc,sansenr)
            }
            #--- il n'y a pas de nombre d'image
            set nbImages ""
         }
      }

      set camNo $panneau(acqfc,$visuNo,camNo)
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set loadMode [::confCam::getPluginProperty $panneau(acqfc,$visuNo,camItem) "loadMode" ]

      #--- j'initialise l'indicateur d'etat de l'acquisition
      set panneau(acqfc,$visuNo,acquisitionState) ""
      set compteurImageSerie 1

      #--- Je calcule le dernier index de la serie
      if { $panneau(acqfc,$visuNo,mode) == "2" } {
         set panneau(acqfc,$visuNo,indexEndSerie) [ expr $panneau(acqfc,$visuNo,index) + $panneau(acqfc,$visuNo,nb_images) - 1 ]
         set panneau(acqfc,$visuNo,indexEndSerie) "$caption(acqfc,dernierIndex) $panneau(acqfc,$visuNo,indexEndSerie)"
      } elseif { $panneau(acqfc,$visuNo,mode) == "4" } {
         set panneau(acqfc,$visuNo,indexEndSerieContinu) [ expr $panneau(acqfc,$visuNo,index) + $panneau(acqfc,$visuNo,nb_images) - 1 ]
         set panneau(acqfc,$visuNo,indexEndSerieContinu) "$caption(acqfc,dernierIndex) $panneau(acqfc,$visuNo,indexEndSerieContinu)"
      }

      #--- Boucle d'acquisition des images
      while { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
         #--- si un nombre d'image est precise, je verifie
         if { $nbImages != "" && $compteurImageSerie > $nbImages } {
            #--- alerte sonore de fin de serie
            if { $panneau(acqfc,$visuNo,alarme_fin_serie) == "1" } {
               if { $nbImages > "0" && $panneau(acqfc,$visuNo,mode) == "2" } {
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
         set panneau(acqfc,$visuNo,deb_im) [ clock second ]
         #--- Alarme sonore de fin de pose
         ::camera::alarmeSonore $panneau(acqfc,$visuNo,pose)
         #--- Declenchement l'acquisition (voir la suite dans callbackAcquition)
         ::camera::acquisition $panneau(acqfc,$visuNo,camItem) "::acqfc::callbackAcquisition $visuNo" $panneau(acqfc,$visuNo,pose)
         #--- je lance la boucle d'affichage du status
         after 10 ::acqfc::dispTime $visuNo
         #--- j'attends la fin de l'acquisition (voir ::acqfc::callbackAcquisition)
         vwait panneau(acqfc,$visuNo,acquisitionState)

         if { $panneau(acqfc,$visuNo,acquisitionState) == "error" } {
            #--- j'interromps la boucle des acquisitions dans la thread de la camera
            ::acqfc::stopAcquisition $visuNo
            #--- je ferme la fenetre de décompte
            if { $panneau(acqfc,$visuNo,dispTimeAfterId) != "" } {
               after cancel $panneau(acqfc,$visuNo,dispTimeAfterId)
               set panneau(acqfc,$visuNo,dispTimeAfterId) ""
            }
            #--- j'affiche le message d'erreur
            tk_messageBox -message $::caption(acqfc,acquisitionError) -title $::caption(acqfc,pb) -icon error
            break
         }

         #--- Rajoute des mots cles dans l'en-tete FITS
         foreach keyword [ ::keyword::getKeywords $visuNo $::conf(acqfc,keywordConfigName) ] {
            buf$bufNo setkwd $keyword
         }

         #--- je trace la duree réelle de la pose s'il y a eu une interruption
         if { $panneau(acqfc,$visuNo,demande_arret) == "1" } {
            set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
            #--- je verifie qu'il y eu interruption vraiment pendant l'acquisition
            set dateEnd [mc_date2ymdhms [ lindex [ buf$bufNo getkwd DATE-END ] 1 ]]
            set dateEnd [format "%02dh %02dm %02ds" [lindex $dateEnd 3] [lindex $dateEnd 4] [expr int([lindex $dateEnd 5])]]
            if { $exposure != $panneau(acqfc,$visuNo,pose) } {
               Message $visuNo consolog $caption(acqfc,arrprem) $dateEnd
               Message $visuNo consolog $caption(acqfc,lg_pose_arret) $exposure
            } else {
               Message $visuNo consolog $caption(acqfc,arrprem) $dateEnd
            }
         }

         #--- j'enregistre l'image et je decale le telescope
         switch $panneau(acqfc,$visuNo,mode) {
            1  {
               #--- mode une image
               incr compteurImageSerie
               #--- J'efface le nom du fichier dans le titre de la fenetre et dans la fenetre du header
               ::confVisu::setFileName $visuNo ""
            }
            2  {
               #--- Mode serie
               #--- Je sauvegarde l'image
               set nom $panneau(acqfc,$visuNo,nom_image)
               #--- Pour eviter un nom de fichier qui commence par un blanc
               set nom [lindex $nom 0]
               if { $panneau(acqfc,$visuNo,simulation) == "0" } {
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqfc,$visuNo,index) $panneau(acqfc,$visuNo,extension)
                  set sauvegardeValidee "1"
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfc,$visuNo,verifier_ecraser_fichier) == 1 } {
                     #--- Dans ce cas, le fichier existe deja...
                     set lastFile [ ::acqfc::dernierFichier $visuNo ]
                     set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                        -message "$caption(acqfc,fichdeja_1) $lastFile $caption(acqfc,fichdeja_2)"]
                     if { $confirmation == "no" } {
                        #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                        set sauvegardeValidee "0"
                        set panneau(acqfc,$visuNo,demande_arret) "1"
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqfc,$visuNo,sauve_img_interrompue) == "0" } {
                     #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                     set name [append nom $panneau(acqfc,$visuNo,index) $panneau(acqfc,$visuNo,extension)]
                     ::confVisu::setFileName $visuNo $name
                     #--- Sauvegarde de l'image
                     saveima $name $visuNo
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                     incr panneau(acqfc,$visuNo,index)
                  }
               }
               #--- Deplacement du telescope
               ::DlgShift::decalageTelescope
               #--- j'incremente le nombre d'images de la serie
               incr compteurImageSerie
            }
            3  {
               #--- Mode continu
               #--- Je sauvegarde l'image
               if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
                  $panneau(acqfc,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
                  set nom $panneau(acqfc,$visuNo,nom_image)
                  #--- Pour eviter un nom de fichier qui commence par un blanc
                  set nom [lindex $nom 0]
                  #--- Verifie que le nom du fichier n'existe pas si on utilise l'index
                  set sauvegardeValidee "1"
                  if { $panneau(acqfc,$visuNo,indexerContinue) == "1" } {
                     set nom1 "$nom"
                     append nom1 $panneau(acqfc,$visuNo,index) $panneau(acqfc,$visuNo,extension)
                     if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfc,$visuNo,verifier_ecraser_fichier) == 1} {
                        #--- Dans ce cas, le fichier existe deja...
                        set lastFile [ ::acqfc::dernierFichier $visuNo ]
                        set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                           -message "$caption(acqfc,fichdeja_1) $lastFile $caption(acqfc,fichdeja_2)"]
                        if { $confirmation == "no" } {
                           #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                           set sauvegardeValidee "0"
                           set panneau(acqfc,$visuNo,demande_arret) "1"
                        }
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqfc,$visuNo,sauve_img_interrompue) == "0" } {
                     #--- Sauvegarde de l'image
                     if { $panneau(acqfc,$visuNo,indexerContinue) == "1" } {
                        #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                        set name [append nom $panneau(acqfc,$visuNo,index) $panneau(acqfc,$visuNo,extension)]
                        ::confVisu::setFileName $visuNo $name
                        #--- Sauvegarde de l'image
                        saveima $name $visuNo
                     } else {
                        #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                        set name [append nom $panneau(acqfc,$visuNo,extension)]
                        ::confVisu::setFileName $visuNo $name
                        #--- Sauvegarde de l'image
                        saveima $name $visuNo
                     }
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                     if { $panneau(acqfc,$visuNo,indexerContinue) == "1" } {
                        incr panneau(acqfc,$visuNo,index)
                     }
                  }
               } else {
                  ::confVisu::setFileName $visuNo ""
               }
               #--- Deplacement du telescope
               ::DlgShift::decalageTelescope
            }
            4  {
               #--- Je sauvegarde l'image
               set nom $panneau(acqfc,$visuNo,nom_image)
               #--- Pour eviter un nom de fichier qui commence par un blanc
               set nom [lindex $nom 0]
               if { $panneau(acqfc,$visuNo,simulation) == "0" } {
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqfc,$visuNo,index) $panneau(acqfc,$visuNo,extension)
                  set sauvegardeValidee "1"
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfc,$visuNo,verifier_ecraser_fichier) == 1 } {
                     #--- Dans ce cas, le fichier existe deja...
                     set lastFile [ ::acqfc::dernierFichier $visuNo ]
                     set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                        -message "$caption(acqfc,fichdeja_1) $lastFile $caption(acqfc,fichdeja_2)"]
                     if { $confirmation == "no" } {
                        #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                        set sauvegardeValidee "0"
                        set panneau(acqfc,$visuNo,demande_arret) "1"
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqfc,$visuNo,sauve_img_interrompue) == "0" } {
                     #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                     set name [append nom $panneau(acqfc,$visuNo,index) $panneau(acqfc,$visuNo,extension)]
                     ::confVisu::setFileName $visuNo $name
                     #--- Sauvegarde de l'image
                     saveima $name $visuNo
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                     incr panneau(acqfc,$visuNo,index)
                  }
               }
               #---
               if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
                  #--- Deplacement du telescope
                  ::DlgShift::decalageTelescope
                  if { $compteurImageSerie < $nbImages } {
                     #--- j'incremente le compteur d'image
                     incr compteurImageSerie
                  } else {
                     #--- j'attends que la fin de la temporisation entre 2 series
                     set panneau(acqfc,$visuNo,attente_pose) "1"
                     set panneau(acqfc,$visuNo,fin_im) [ clock second ]
                     set panneau(acqfc,$visuNo,intervalle_im_1) [ expr $panneau(acqfc,$visuNo,fin_im) - $panneau(acqfc,$visuNo,deb_serie) ]
                     while { ( $panneau(acqfc,$visuNo,demande_arret) == "0" ) && ( $panneau(acqfc,$visuNo,intervalle_im_1) <= $panneau(acqfc,$visuNo,intervalle_1) ) } {
                        after 500
                        set panneau(acqfc,$visuNo,fin_im) [ clock second ]
                        set panneau(acqfc,$visuNo,intervalle_im_1) [ expr $panneau(acqfc,$visuNo,fin_im) - $panneau(acqfc,$visuNo,deb_serie) + 1 ]
                        set t [ expr $panneau(acqfc,$visuNo,intervalle_1) - $panneau(acqfc,$visuNo,intervalle_im_1) ]
                        ::acqfc::avancementPose $visuNo $t
                     }
                     set panneau(acqfc,$visuNo,attente_pose) "0"
                     #--- Je note l'heure de debut des series suivantes (utile pour les series espacees)
                     set panneau(acqfc,$visuNo,deb_serie) [ clock second ]
                     #--- je reinitalise le compteur d'image
                     set compteurImageSerie 1
                     #--- Je calcule le dernier index de la serie
                     set panneau(acqfc,$visuNo,indexEndSerieContinu) [ expr $panneau(acqfc,$visuNo,index) + $panneau(acqfc,$visuNo,nb_images) - 1 ]
                     set panneau(acqfc,$visuNo,indexEndSerieContinu) "$caption(acqfc,dernierIndex) $panneau(acqfc,$visuNo,indexEndSerieContinu)"
                  }
               }
            }
            5  {
               #--- Je sauvegarde l'image
               set nom $panneau(acqfc,$visuNo,nom_image)
               #--- Pour eviter un nom de fichier qui commence par un blanc
               set nom [lindex $nom 0]
               if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqfc,$visuNo,index) $panneau(acqfc,$visuNo,extension)
                  set sauvegardeValidee "1"
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfc,$visuNo,verifier_ecraser_fichier) == 1 } {
                     #--- Dans ce cas, le fichier existe deja...
                     set lastFile [ ::acqfc::dernierFichier $visuNo ]
                     set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                        -message "$caption(acqfc,fichdeja_1) $lastFile $caption(acqfc,fichdeja_2)"]
                     if { $confirmation == "no" } {
                        #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                        set sauvegardeValidee "0"
                        set panneau(acqfc,$visuNo,demande_arret) "1"
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqfc,$visuNo,sauve_img_interrompue) == "0" } {
                     #--- Je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre du header
                     set name [append nom $panneau(acqfc,$visuNo,index) $panneau(acqfc,$visuNo,extension)]
                     ::confVisu::setFileName $visuNo $name
                     #--- Sauvegarde de l'image
                     saveima $name $visuNo
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                     incr panneau(acqfc,$visuNo,index)
                  }
               } else {
                  ::confVisu::setFileName $visuNo ""
               }
               #---
               if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
                  #--- Deplacement du telescope
                  ::DlgShift::decalageTelescope
                  set panneau(acqfc,$visuNo,attente_pose) "1"
                  set panneau(acqfc,$visuNo,fin_im) [ clock second ]
                  set panneau(acqfc,$visuNo,intervalle_im_2) [ expr $panneau(acqfc,$visuNo,fin_im) - $panneau(acqfc,$visuNo,deb_im) ]
                  while { ( $panneau(acqfc,$visuNo,demande_arret) == "0" ) && ( $panneau(acqfc,$visuNo,intervalle_im_2) <= $panneau(acqfc,$visuNo,intervalle_2) ) } {
                     after 500
                     set panneau(acqfc,$visuNo,fin_im) [ clock second ]
                     set panneau(acqfc,$visuNo,intervalle_im_2) [ expr $panneau(acqfc,$visuNo,fin_im) - $panneau(acqfc,$visuNo,deb_im) + 1 ]
                     set t [ expr $panneau(acqfc,$visuNo,intervalle_2) - $panneau(acqfc,$visuNo,intervalle_im_2) ]
                     ::acqfc::avancementPose $visuNo $t
                  }
                  set panneau(acqfc,$visuNo,attente_pose) "0"
               }
            }
         } ; #--- fin du switch d'acquisition

         #--- Je retablis le choix du fonctionnement de l'obturateur
         if { $panneau(acqfc,$visuNo,pose) == "0" } {
            switch -exact -- $panneau(acqfc,$visuNo,obt) {
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
      switch $panneau(acqfc,$visuNo,mode) {
         1  {
            #--- Deverrouille les boutons du mode "une image"
            $panneau(acqfc,$visuNo,This).mode.une.nom.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.une.index.case configure -state normal
            $panneau(acqfc,$visuNo,This).mode.une.index.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.une.index.but configure -state normal
            $panneau(acqfc,$visuNo,This).mode.une.sauve configure -state normal
         }
         2  {
            #--- Mode serie
            #--- Fin de la derniere pose et intervalle mini entre 2 poses ou 2 series
            if { $panneau(acqfc,$visuNo,simulation) == "1" } {
               #--- Affichage de l'intervalle mini simule
               set panneau(acqfc,$visuNo,fin) [ clock second ]
               set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
               if { $exposure == $panneau(acqfc,$visuNo,pose) } {
                  set panneau(acqfc,$visuNo,intervalle) [ expr $panneau(acqfc,$visuNo,fin) - $panneau(acqfc,$visuNo,debut) ]
               } else {
                  set panneau(acqfc,$visuNo,intervalle) "...."
               }
               set simu1 "$caption(acqfc,int_mini_serie) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
               $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
               #--- Je retablis les reglages initiaux
               set panneau(acqfc,$visuNo,simulation) "0"
               set panneau(acqfc,$visuNo,mode)       "4"
               set panneau(acqfc,$visuNo,index)      $panneau(acqfc,$visuNo,index_temp)
               set panneau(acqfc,$visuNo,nb_images)  $panneau(acqfc,$visuNo,nombre_temp)
               #--- Fin de la simulation
               Message $visuNo consolog $caption(acqfc,fin_simu)
            } elseif { $panneau(acqfc,$visuNo,simulation) == "2" } {
               #--- Affichage de l'intervalle mini simule
               set panneau(acqfc,$visuNo,fin) [ clock second ]
               set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
               if { $exposure == $panneau(acqfc,$visuNo,pose) } {
                  set panneau(acqfc,$visuNo,intervalle) [ expr $panneau(acqfc,$visuNo,fin) - $panneau(acqfc,$visuNo,debut) ]
               } else {
                  set panneau(acqfc,$visuNo,intervalle) "...."
               }
               set simu2 "$caption(acqfc,int_mini_image) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
               $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
               #--- Je retablis les reglages initiaux
               set panneau(acqfc,$visuNo,simulation) "0"
               set panneau(acqfc,$visuNo,mode)       "5"
               set panneau(acqfc,$visuNo,index)      $panneau(acqfc,$visuNo,index_temp)
               set panneau(acqfc,$visuNo,nb_images)  $panneau(acqfc,$visuNo,nombre_temp)
               #--- Fin de la simulation
               Message $visuNo consolog $caption(acqfc,fin_simu)
            }
            #--- Deverrouille les boutons du mode "serie"
            $panneau(acqfc,$visuNo,This).mode.serie.nom.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.serie.nb.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.serie.index.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.serie.index.but configure -state normal
         }
         3  {
            #--- Mode continu
            #--- Deverrouille les boutons du mode "continu"
            $panneau(acqfc,$visuNo,This).mode.continu.sauve.case configure -state normal
            $panneau(acqfc,$visuNo,This).mode.continu.nom.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.continu.index.case configure -state normal
            $panneau(acqfc,$visuNo,This).mode.continu.index.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.continu.index.but configure -state normal
         }
         4  {
            #--- Mode continu
            #--- Deverrouille les boutons du mode "continu 1"
            $panneau(acqfc,$visuNo,This).mode.serie_1.nom.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.serie_1.nb.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.serie_1.index.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.serie_1.index.but configure -state normal
         }
         5  {
            #--- Deverrouille les boutons du mode "continu 2"
            $panneau(acqfc,$visuNo,This).mode.continu_1.sauve.case configure -state normal
            $panneau(acqfc,$visuNo,This).mode.continu_1.nom.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.continu_1.index.entr configure -state normal
            $panneau(acqfc,$visuNo,This).mode.continu_1.index.but configure -state normal
         }
      } ; #--- fin du switch de deverrouillage
   }] ; #--- fin du catch

   if { $catchResult == 1 } {
      ::tkutil::displayErrorInfo $caption(acqfc,titre)
      #--- J'arrete la capture de l'image
      ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
   }

   #--- Pose en cours
   set panneau(acqfc,$visuNo,pose_en_cours) "0"
   #--- Pas de demande d'arret
   set panneau(acqfc,$visuNo,demande_arret) 0
   #--- Effacement de la barre de progression quand la pose est terminee
   ::acqfc::avancementPose $visuNo -1
   $panneau(acqfc,$visuNo,This).status.lab configure -text ""
   #--- Deverrouille tous les boutons et champs de texte pendant les acquisitions
   $panneau(acqfc,$visuNo,This).pose.but configure -state normal
   $panneau(acqfc,$visuNo,This).pose.entr configure -state normal
   $panneau(acqfc,$visuNo,This).binning.but configure -state normal
   $panneau(acqfc,$visuNo,This).format.but configure -state normal
   $panneau(acqfc,$visuNo,This).obt.but configure -state normal
   $panneau(acqfc,$visuNo,This).mode.but configure -state normal
   #--- Je restitue l'affichage du bouton "GO"
   $panneau(acqfc,$visuNo,This).go_stop.but configure -text $caption(acqfc,GO) -state normal -command "::acqfc::Go $visuNo"
   #--- je positionne l'indateur de fin d'acquisition (pour startAcquisitionSerieImage)
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
proc ::acqfc::callbackAcquisition { visuNo message args } {
   switch $message {
      "autovisu" {
         #--- ce message signale que l'image est prete dans le buffer
         #--- on peut l'afficher sans attendre la fin complete de la thread de la camera
         ::confVisu::autovisu $visuNo
      }
      "acquisitionResult" {
         #--- ce message signale que la thread de la camera a termine completement l'acquisition
         #--- je peux traiter l'image
         set ::panneau(acqfc,$visuNo,acquisitionState) "acquisitionResult"
      }
      "error" {
         #--- ce message signale qu'une erreur est survenue dans la thread de la camera
         #--- j'affiche l'erreur dans la console
         ::console::affiche_erreur "acqfc::acq error: $args\n"
         set ::panneau(acqfc,$visuNo,acquisitionState) "error"
      }
   }
}

#***** Procedure Stop (appui sur le bouton Go/Stop) *********
proc ::acqfc::Stop { visuNo } {
   global audace caption panneau

   #--- Je desactive le bouton "STOP"
   $panneau(acqfc,$visuNo,This).go_stop.but configure -state disabled

   #--- j'interromps la pose
   if { $panneau(acqfc,$visuNo,mode) == "1" } {
      #--- Je positionne l'indicateur d'interruption de pose
      set panneau(acqfc,$visuNo,demande_arret) "1"
      #--- On annule la sonnerie
      catch { after cancel $audace(after,bell,id) }
      #--- Annulation de l'alarme de fin de pose
      catch { after cancel bell }
      #--- J'arrete la capture de l'image
      ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
   } else {
      if { $panneau(acqfc,$visuNo,enregistrer_acquisiton_interrompue) == 1 } {
         if { [cam$panneau(acqfc,$visuNo,camNo) timer -1 ] > 10 } {
             #--- s'il reste plus de 10 seconde , je demande si on interromp la pose courante
             set choix [ tk_messageBox -title $caption(acqfc,serie) -type yesno -icon info \
                 -message $caption(acqfc,arret_serie) \
             ]
            if { $choix == "no" } {
               #--- Je positionne l'indicateur d'interruption de pose
               set panneau(acqfc,$visuNo,demande_arret) "1"
               #--- Je positionne l'indicateur d'enregistrement d'image interrompue
               set panneau(acqfc,$visuNo,sauve_img_interrompue) "1"
               #--- On annule la sonnerie
               catch { after cancel $audace(after,bell,id) }
               #--- Annulation de l'alarme de fin de pose
               catch { after cancel bell }
               #--- J'arrete l'acquisition courante
               ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
            } else {
               #--- Je positionne l'indicateur d'interruption de pose a 1 s de la fin de la pose
               ::acqfc::stopSerie $visuNo
               #--- Je positionne l'indicateur d'enregistrement d'image interrompue
               set panneau(acqfc,$visuNo,sauve_img_interrompue) "0"
            }
         } else {
            #--- Je positionne l'indicateur d'interruption de pose a 1 s de la fin de la pose
            ::acqfc::stopSerie $visuNo
            #--- s'il reste moins de 10 secondes, je ne pose pas de question a l'utilisateur
            #--- la serie s'arretera a la fin de l'image en cours
            set panneau(acqfc,$visuNo,sauve_img_interrompue) "0"
         }
      } else {
         #--- Je positionne l'indicateur d'interruption de pose
         set panneau(acqfc,$visuNo,demande_arret) "1"
         #--- Je positionne l'indicateur d'enregistrement d'image interrompue
         set panneau(acqfc,$visuNo,sauve_img_interrompue) "1"
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
proc ::acqfc::stopSerie { visuNo } {
   global panneau

   set t [cam$panneau(acqfc,$visuNo,camNo) timer -1 ]
   if { $t > 1 } {
      #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
      #--- (mode asynchone pour eviter l'empilement des appels recursifs)
      set valeur [after 1000 ::acqfc::stopSerie $visuNo]
   } else {
      #--- je ne relance pas le timer et j'arrete la pose
      set panneau(acqfc,$visuNo,demande_arret) "1"
   }
}
#***** Fin de la procedure arret de la serie *******************


#------------------------------------------------------------
# configToolKeywords
#    configure les mots cles FITS de l'outil
#------------------------------------------------------------
proc ::acqfc::configToolKeywords { visuNo { configName "" } } {
   #--- Je traite la variable configName
   if { $configName == "" } {
      set configName $::conf(acqfc,keywordConfigName)
   }

   #--- Je selectionne les mots cles optionnels a ajouter dans les images
   #--- Ce sont les mots cles CRPIX1, CRPIX2
   ::keyword::selectKeywords $visuNo $configName [ list CRPIX1 CRPIX2 ]

   #--- Je selectionne la liste des mots cles non modifiables
   ::keyword::setKeywordState $visuNo $configName [ list CRPIX1 CRPIX2 ]
}

proc ::acqfc::dispTime { visuNo } {
   global caption panneau

   #--- j'arrete le timer s'il est deja lance
   if { [info exists panneau(acqfc,$visuNo,dispTimeAfterId)] && $panneau(acqfc,$visuNo,dispTimeAfterId)!="" } {
      after cancel $panneau(acqfc,$visuNo,dispTimeAfterId)
      set panneau(acqfc,$visuNo,dispTimeAfterId) ""
   }

   set t [cam$panneau(acqfc,$visuNo,camNo) timer -1 ]
   #--- je mets a jour le status
   if { $panneau(acqfc,$visuNo,pose_en_cours) == 0 } {
      #--- je supprime la fenetre s'il n'y a plus de pose en cours
      set status ""
   } else {
      if { $panneau(acqfc,$visuNo,attente_pose) == "0" } {
         if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
            if { [expr $t > 0] } {
               set status "[ expr $t ] / [ format "%d" [ expr int($panneau(acqfc,$visuNo,pose)) ] ]"
            } else {
               set status "$caption(acqfc,lect)"
            }
         } else {
            set status "$caption(acqfc,lect)"
         }
      } else {
         set status $caption(acqfc,attente)
      }
   }
   $panneau(acqfc,$visuNo,This).status.lab configure -text $status
   update

   #--- je mets a jour la fenetre de progression
   avancementPose $visuNo $t

   if { $t > 0 } {
      #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
      #--- (mode asynchone pour eviter l'empilement des appels recursifs)
      set panneau(acqfc,$visuNo,dispTimeAfterId) [after 1000 ::acqfc::dispTime $visuNo]
   } else {
      #--- je ne relance pas le timer
      set panneau(acqfc,$visuNo,dispTimeAfterId) ""
   }
}

#***** Procedure d'affichage d'une barre de progression ********
proc ::acqfc::avancementPose { visuNo { t } } {
   global caption color panneau

   #--- Fenetre d'avancement de la pose non demandee
   if { $panneau(acqfc,$visuNo,avancement_acq) != "1" } {
      return
   }

   #--- Recuperation de la position de la fenetre
   ::acqfc::recup_position_1 $visuNo

   #--- Initialisation de la barre de progression
   set cpt "100"

   #---
   if { [ winfo exists $panneau(acqfc,$visuNo,base).progress ] != "1" } {

      #--- Cree la fenetre toplevel
      toplevel $panneau(acqfc,$visuNo,base).progress
      wm transient $panneau(acqfc,$visuNo,base).progress $panneau(acqfc,$visuNo,base)
      wm resizable $panneau(acqfc,$visuNo,base).progress 0 0
      wm title $panneau(acqfc,$visuNo,base).progress "$caption(acqfc,en_cours)"
      wm geometry $panneau(acqfc,$visuNo,base).progress $panneau(acqfc,$visuNo,avancement,position)

      #--- Cree le widget et le label du temps ecoule
      label $panneau(acqfc,$visuNo,base).progress.lab_status -text "" -justify center
      pack $panneau(acqfc,$visuNo,base).progress.lab_status -side top -fill x -expand true -pady 5

      #---
      if { $panneau(acqfc,$visuNo,attente_pose) == "0" } {
         if { $panneau(acqfc,$visuNo,demande_arret) == "1" && $panneau(acqfc,$visuNo,mode) != "2" && $panneau(acqfc,$visuNo,mode) != "4" } {
            $panneau(acqfc,$visuNo,base).progress.lab_status configure -text $caption(acqfc,lect)
         } else {
            if { $t < 0 } {
               destroy $panneau(acqfc,$visuNo,base).progress
            } elseif { $t > 0 } {
               $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$t $caption(acqfc,sec) /\
                  [ format "%d" [ expr int( $panneau(acqfc,$visuNo,pose) ) ] ] $caption(acqfc,sec)"
               set cpt [ expr $t * 100 / int( $panneau(acqfc,$visuNo,pose) ) ]
               set cpt [ expr 100 - $cpt ]
            } else {
               $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,lect)"
           }
         }
      } else {
         if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
            if { $t < 0 } {
               destroy $panneau(acqfc,$visuNo,base).progress
            } else {
               if { $panneau(acqfc,$visuNo,mode) == "4" } {
                  $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                     $caption(acqfc,sec) / $panneau(acqfc,$visuNo,intervalle_1) $caption(acqfc,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqfc,$visuNo,intervalle_1) ]
               } elseif { $panneau(acqfc,$visuNo,mode) == "5" } {
                  $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                     $caption(acqfc,sec) / $panneau(acqfc,$visuNo,intervalle_2) $caption(acqfc,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqfc,$visuNo,intervalle_2) ]
               }
               set cpt [ expr 100 - $cpt ]
            }
         }
      }

      catch {
         #--- Cree le widget pour la barre de progression
         frame $panneau(acqfc,$visuNo,base).progress.cadre -width 200 -height 30 -borderwidth 2 -relief groove
         pack $panneau(acqfc,$visuNo,base).progress.cadre -in $panneau(acqfc,$visuNo,base).progress -side top \
            -anchor center -fill x -expand true -padx 8 -pady 8

         #--- Affiche de la barre de progression
         frame $panneau(acqfc,$visuNo,base).progress.cadre.barre_color_invariant -height 26 -bg $color(blue)
         place $panneau(acqfc,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(acqfc,$visuNo,base).progress.cadre -x 0 -y 0 \
            -relwidth [ expr $cpt / 100.0 ]
         update
      }

      #--- Mise a jour dynamique des couleurs
      if { [ winfo exists $panneau(acqfc,$visuNo,base).progress ] == "1" } {
         ::confColor::applyColor $panneau(acqfc,$visuNo,base).progress
      }

   } else {

      if { $panneau(acqfc,$visuNo,pose_en_cours) == 0 } {
         #--- je supprime la fenetre s'il n'y a plus de pose en cours
         destroy $panneau(acqfc,$visuNo,base).progress
      } else {
         if { $panneau(acqfc,$visuNo,attente_pose) == "0" } {
            if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
               if { $t > 0 } {
                  $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "[ expr $t ] $caption(acqfc,sec) /\
                     [ format "%d" [ expr int( $panneau(acqfc,$visuNo,pose) ) ] ] $caption(acqfc,sec)"
                  set cpt [ expr $t * 100 / int( $panneau(acqfc,$visuNo,pose) ) ]
                 set cpt [ expr 100 - $cpt ]
               } else {
                  $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,lect)"
               }
            } else {
               #--- j'affiche "lecture" des qu'une demande d'arret est demandee
               $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,lect)"
            }
         } else {
            if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
               if { $panneau(acqfc,$visuNo,mode) == "4" } {
                  $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                     $caption(acqfc,sec) / $panneau(acqfc,$visuNo,intervalle_1) $caption(acqfc,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqfc,$visuNo,intervalle_1) ]
               } elseif { $panneau(acqfc,$visuNo,mode) == "5" } {
                  $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                     $caption(acqfc,sec) / $panneau(acqfc,$visuNo,intervalle_2) $caption(acqfc,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqfc,$visuNo,intervalle_2) ]
               }
               set cpt [ expr 100 - $cpt ]
            }
         }

         #--- Met a jour la barre de progression
         place $panneau(acqfc,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(acqfc,$visuNo,base).progress.cadre -x 0 -y 0 \
            -relwidth [ expr $cpt / 100.0 ]
         update
      }

   }

}
#***** Fin de la procedure d'avancement de la pose *************

#*********** Procedure dernier fichier d'une liste *************
proc ::acqfc::dernierFichier { visuNo } {
   global panneau

   #--- Liste par ordre croissant les index du nom generique
   set a [ lsort -integer [ liste_index $panneau(acqfc,$visuNo,nom_image) ] ]
   set b [ llength $a ]
   #--- Extrait le dernier index de la liste
   set c [ lindex $a [ expr $b - 1 ] ]
   #--- Retourne le dernier fichier de la liste
   set d $panneau(acqfc,$visuNo,nom_image)$c$panneau(acqfc,$visuNo,extension)
   return $d
}
#****Fin de la procedure dernier fichier d'une liste ***********

#***** Procedure de sauvegarde de l'image **********************
#--- Procedure lancee par appui sur le bouton "enregistrer", uniquement dans le mode "Une image"
proc ::acqfc::SauveUneImage { visuNo } {
   global audace caption panneau

   #--- Tests d'integrite de la requete
   #--- Verifier qu'il y a bien un nom de fichier
   if { $panneau(acqfc,$visuNo,nom_image) == "" } {
      tk_messageBox -title $caption(acqfc,pb) -type ok \
         -message $caption(acqfc,donnomfich)
      return
   }
   #--- Verifier que le nom de fichier n'a pas d'espace
   if { [ llength $panneau(acqfc,$visuNo,nom_image) ] > "1" } {
      tk_messageBox -title $caption(acqfc,pb) -type ok \
         -message $caption(acqfc,nomblanc)
      return
   }
   #--- Si la case index est cochee, verifier qu'il y a bien un index
   if { $panneau(acqfc,$visuNo,indexer) == "1" } {
      #--- Verifier que l'index existe
      if { $panneau(acqfc,$visuNo,index) == "" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,saisind)
         return
      }
   }

   #--- Generer le nom du fichier
   set nom $panneau(acqfc,$visuNo,nom_image)
   #--- Pour eviter un nom de fichier qui commence par un blanc
   set nom [lindex $nom 0]
   if { $panneau(acqfc,$visuNo,indexer) == "1" } {
      append nom $panneau(acqfc,$visuNo,index)
   }

   #--- Verifier que le nom du fichier n'existe pas
   set nom1 "$nom"
   append nom1 $panneau(acqfc,$visuNo,extension)
   if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfc,$visuNo,verifier_ecraser_fichier) == 1 } {
      #--- Dans ce cas, le fichier existe deja...
      set lastFile [ ::acqfc::dernierFichier $visuNo ]
      set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
         -message "$caption(acqfc,fichdeja_1) $lastFile $caption(acqfc,fichdeja_2)"]
      if { $confirmation == "no" } {
         return
      }
   }

   #--- Incrementer l'index
   set bufNo [ visu$visuNo buf ]
   if { $panneau(acqfc,$visuNo,indexer) == "1" } {
      if { [ buf$bufNo imageready ] != "0" } {
         incr panneau(acqfc,$visuNo,index)
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
   set name [append nom $panneau(acqfc,$visuNo,extension)]
   ::confVisu::setFileName $visuNo $name

   #--- Sauvegarde de l'image
   saveima $name $visuNo

   #--- Indique l'heure d'enregistrement dans le fichier log
   set heure $audace(tu,format,hmsint)
   Message $visuNo consolog $caption(acqfc,demsauv) $heure
   Message $visuNo consolog $caption(acqfc,imsauvnom) $nom
}
#***** Fin de la procedure de sauvegarde de l'image *************

#***** Procedure d'affichage des messages ************************
#--- Cette procedure est recopiee de methking.tcl, elle permet l'affichage de differents
#--- messages (dans la console, le fichier log, etc.)
proc ::acqfc::Message { visuNo niveau args } {
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
            puts -nonewline $::acqfc::log_id($visuNo) [eval [concat {format} $args]]
            #--- Force l'ecriture immediate sur le disque
            flush $::acqfc::log_id($visuNo)
         }
      }
      consolog {
         if { $panneau(acqfc,$visuNo,messages) == "1" } {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         set temps [clock format [clock seconds] -format %H:%M:%S]
         append temps " "
         catch {
            puts -nonewline $::acqfc::log_id($visuNo) [eval [concat {format} $args]]
            #--- Force l'ecriture immediate sur le disque
            flush $::acqfc::log_id($visuNo)
         }
      }
      default {
         set b [ list "%s\n" $caption(acqfc,pbmesserr) ]
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
proc ::acqfc::cmdShiftConfig { visuNo } {
   global panneau

   set shiftConfig [ ::DlgShift::run $visuNo $panneau(acqfc,$visuNo,This).dlgShift ]
   return
}
#***** Fin du bouton pour le decalage du telescope *****************

#***** Fenetre de configuration series d'images a intervalle regulier en continu *********
proc ::acqfc::Intervalle_continu_1 { visuNo } {
   global caption conf panneau

   set panneau(acqfc,$visuNo,intervalle)            "...."
   set panneau(acqfc,$visuNo,simulation_deja_faite) "0"

   ::acqfc::recup_position $visuNo

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(acqfc,continu1,position) ] } { set conf(acqfc,continu1,position) "+120+260" }

   #--- Creation de la fenetre Continu 1
   toplevel $panneau(acqfc,$visuNo,base).intervalle_continu_1
   wm transient $panneau(acqfc,$visuNo,base).intervalle_continu_1 $panneau(acqfc,$visuNo,base)
   wm resizable $panneau(acqfc,$visuNo,base).intervalle_continu_1 0 0
   wm title $panneau(acqfc,$visuNo,base).intervalle_continu_1 "$caption(acqfc,continu_1)"
   wm geometry $panneau(acqfc,$visuNo,base).intervalle_continu_1 $conf(acqfc,continu1,position)
   wm protocol $panneau(acqfc,$visuNo,base).intervalle_continu_1 WM_DELETE_WINDOW " \
      set panneau(acqfc,$visuNo,mode_en_cours) \"$caption(acqfc,continu_1)\" \
   "

   #--- Create the message
   label $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab1 -text "$caption(acqfc,titre_1)"
   pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab1 -padx 20 -pady 5

   frame $panneau(acqfc,$visuNo,base).intervalle_continu_1.a
      label $panneau(acqfc,$visuNo,base).intervalle_continu_1.a.lab2 -text "$caption(acqfc,intervalle_1)"
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.a.lab2 -anchor center -expand 1 -fill none -side left \
         -padx 10 -pady 5
      entry $panneau(acqfc,$visuNo,base).intervalle_continu_1.a.ent1 -width 5 -relief groove \
         -textvariable panneau(acqfc,$visuNo,intervalle_1) -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.a.ent1 -anchor center -expand 1 -fill none -side left \
         -padx 10
   pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.a -padx 10 -pady 5

   frame $panneau(acqfc,$visuNo,base).intervalle_continu_1.b
      checkbutton $panneau(acqfc,$visuNo,base).intervalle_continu_1.b.check_simu \
         -text "$caption(acqfc,simu_deja_faite)" \
         -variable panneau(acqfc,$visuNo,simulation_deja_faite) -command "::acqfc::Simu_deja_faite_1 $visuNo"
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.b.check_simu -anchor w -expand 1 -fill none \
         -side left -padx 10 -pady 5
   pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.b -side bottom -anchor w -padx 10 -pady 5

   button $panneau(acqfc,$visuNo,base).intervalle_continu_1.but1 -text "$caption(acqfc,simulation)" \
      -command "::acqfc::Command_continu_1 $visuNo"
   pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.but1 -anchor center -expand 1 -fill none -side left \
      -ipadx 5 -ipady 3 -padx 10 -pady 5

   set simu1 "$caption(acqfc,int_mini_serie) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
   label $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 -text "$simu1"
   pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 -anchor center -expand 1 -fill none -side left -padx 10

   #--- New message window is on
   focus $panneau(acqfc,$visuNo,base).intervalle_continu_1

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $panneau(acqfc,$visuNo,base).intervalle_continu_1
}
#***** Fin fenetre de configuration series d'images a intervalle regulier en continu *****

#***** Commande associee au bouton simulation de la fenetre Continu (1) ******************
proc ::acqfc::Command_continu_1 { visuNo } {
   global caption panneau

   set panneau(acqfc,$visuNo,intervalle) "...."
   set simu1 "$caption(acqfc,int_mini_serie) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
   $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
   set panneau(acqfc,$visuNo,simulation)  "1"
   set panneau(acqfc,$visuNo,mode)        "2"
   set panneau(acqfc,$visuNo,index_temp)  $panneau(acqfc,$visuNo,index)
   set panneau(acqfc,$visuNo,nombre_temp) $panneau(acqfc,$visuNo,nb_images)
   ::acqfc::Go $visuNo
}
#***** Fin de la commande associee au bouton simulation de la fenetre Continu (1) ********

#***** Si une simulation a deja ete faite pour la fenetre Continu (1) ********************
proc ::acqfc::Simu_deja_faite_1 { visuNo } {
   global caption panneau

   if { $panneau(acqfc,$visuNo,simulation_deja_faite) == "1" } {
      set panneau(acqfc,$visuNo,intervalle) "xxxx"
      $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 configure \
         -text "$caption(acqfc,int_mini_serie) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
      focus $panneau(acqfc,$visuNo,base).intervalle_continu_1.a.ent1
   } else {
      set panneau(acqfc,$visuNo,intervalle) "...."
      $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 configure \
         -text "$caption(acqfc,int_mini_serie) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
      focus $panneau(acqfc,$visuNo,base).intervalle_continu_1.but1
   }
}
#***** Fin de si une simulation a deja ete faite pour la fenetre Continu (1) *************

#***** Fenetre de configuration images a intervalle regulier en continu ******************
proc ::acqfc::Intervalle_continu_2 { visuNo } {
   global caption conf panneau

   set panneau(acqfc,$visuNo,intervalle)            "...."
   set panneau(acqfc,$visuNo,simulation_deja_faite) "0"

   ::acqfc::recup_position $visuNo

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(acqfc,continu2,position) ] } { set conf(acqfc,continu2,position) "+120+260" }

   #--- Creation de la fenetre Continu 2
   toplevel $panneau(acqfc,$visuNo,base).intervalle_continu_2
   wm transient $panneau(acqfc,$visuNo,base).intervalle_continu_2 $panneau(acqfc,$visuNo,base)
   wm resizable $panneau(acqfc,$visuNo,base).intervalle_continu_2 0 0
   wm title $panneau(acqfc,$visuNo,base).intervalle_continu_2 "$caption(acqfc,continu_2)"
   wm geometry $panneau(acqfc,$visuNo,base).intervalle_continu_2 $conf(acqfc,continu2,position)
   wm protocol $panneau(acqfc,$visuNo,base).intervalle_continu_2 WM_DELETE_WINDOW " \
      set panneau(acqfc,$visuNo,mode_en_cours) \"$caption(acqfc,continu_2)\" \
   "

   #--- Create the message
   label $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab1 -text "$caption(acqfc,titre_2)"
   pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab1 -padx 10 -pady 5

   frame $panneau(acqfc,$visuNo,base).intervalle_continu_2.a
      label $panneau(acqfc,$visuNo,base).intervalle_continu_2.a.lab2 -text "$caption(acqfc,intervalle_2)"
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.a.lab2 -anchor center -expand 1 -fill none -side left \
         -padx 10 -pady 5
      entry $panneau(acqfc,$visuNo,base).intervalle_continu_2.a.ent1 -width 5 -relief groove \
         -textvariable panneau(acqfc,$visuNo,intervalle_2) -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.a.ent1 -anchor center -expand 1 -fill none -side left \
         -padx 10
   pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.a -padx 10 -pady 5

   frame $panneau(acqfc,$visuNo,base).intervalle_continu_2.b
      checkbutton $panneau(acqfc,$visuNo,base).intervalle_continu_2.b.check_simu \
         -text "$caption(acqfc,simu_deja_faite)" \
         -variable panneau(acqfc,$visuNo,simulation_deja_faite) -command "::acqfc::Simu_deja_faite_2 $visuNo"
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.b.check_simu -anchor w -expand 1 -fill none \
         -side left -padx 10 -pady 5
   pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.b -side bottom -anchor w -padx 10 -pady 5

   button $panneau(acqfc,$visuNo,base).intervalle_continu_2.but1 -text "$caption(acqfc,simulation)" \
      -command "::acqfc::Command_continu_2 $visuNo"
   pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.but1 -anchor center -expand 1 -fill none -side left \
      -ipadx 5 -ipady 3 -padx 10 -pady 5

   set simu2 "$caption(acqfc,int_mini_image) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
   label $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 -text "$simu2"
   pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 -anchor center -expand 1 -fill none -side left -padx 10

   #--- New message window is on
   focus $panneau(acqfc,$visuNo,base).intervalle_continu_2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $panneau(acqfc,$visuNo,base).intervalle_continu_2
}
#***** Fin fenetre de configuration images a intervalle regulier en continu **************

#***** Commande associee au bouton simulation de la fenetre Continu (2) ******************
proc ::acqfc::Command_continu_2 { visuNo } {
   global caption panneau

   set panneau(acqfc,$visuNo,intervalle) "...."
   set simu2 "$caption(acqfc,int_mini_image) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
   $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
   set panneau(acqfc,$visuNo,simulation)  "2"
   set panneau(acqfc,$visuNo,mode)        "2"
   set panneau(acqfc,$visuNo,index_temp)  $panneau(acqfc,$visuNo,index)
   set panneau(acqfc,$visuNo,nombre_temp) $panneau(acqfc,$visuNo,nb_images)
   set panneau(acqfc,$visuNo,nb_images)   "1"
   ::acqfc::Go $visuNo
}
#***** Fin de la commande associee au bouton simulation de la fenetre Continu (2) ********

#***** Si une simulation a deja ete faite pour la fenetre Continu (2) ********************
proc ::acqfc::Simu_deja_faite_2 { visuNo } {
   global caption panneau

   if { $panneau(acqfc,$visuNo,simulation_deja_faite) == "1" } {
      set panneau(acqfc,$visuNo,intervalle) "xxxx"
      $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 configure \
         -text "$caption(acqfc,int_mini_image) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
      focus $panneau(acqfc,$visuNo,base).intervalle_continu_2.a.ent1
   } else {
      set panneau(acqfc,$visuNo,intervalle) "...."
      $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 configure \
         -text "$caption(acqfc,int_mini_image) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
      focus $panneau(acqfc,$visuNo,base).intervalle_continu_2.but1
   }
}
#***** Fin de si une simulation a deja ete faite pour la fenetre Continu (2) *************

#***** Enregistrement de la position des fenetres Continu (1) et Continu (2) *************
proc ::acqfc::recup_position { visuNo } {
   global conf panneau

   #--- Cas de la fenetre Continu (1)
   if [ winfo exists $panneau(acqfc,$visuNo,base).intervalle_continu_1 ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqfc,$visuNo,base).intervalle_continu_1 ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(acqfc,continu1,position) "+[ string range $geometry $deb $fin ]"
      #--- Fermeture de la fenetre
      destroy $panneau(acqfc,$visuNo,base).intervalle_continu_1
   }
   #--- Cas de la fenetre Continu (2)
   if [ winfo exists $panneau(acqfc,$visuNo,base).intervalle_continu_2 ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqfc,$visuNo,base).intervalle_continu_2 ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(acqfc,continu2,position) "+[ string range $geometry $deb $fin ]"
      #--- Fermeture de la fenetre
      destroy $panneau(acqfc,$visuNo,base).intervalle_continu_2
   }
}
#***** Fin enregistrement de la position des fenetres Continu (1) et Continu (2) *********

#***** Enregistrement de la position de la fenetre Avancement ********
proc ::acqfc::recup_position_1 { visuNo } {
   global panneau

   #--- Cas de la fenetre Avancement
   if [ winfo exists $panneau(acqfc,$visuNo,base).progress ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqfc,$visuNo,base).progress ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set panneau(acqfc,$visuNo,avancement,position) "+[ string range $geometry $deb $fin ]"
   }
}
#***** Fin enregistrement de la position de la fenetre Avancement ****

#***** Affichage de la fenetre de configuration de WebCam ************
proc ::acqfc::webcamConfigure { visuNo } {
   global caption

   set result [::webcam::config::run $visuNo [::confVisu::getCamItem $visuNo]]
   if { $result == "1" } {
      if { [ ::confVisu::getCamItem $visuNo ] == "" } {
         ::audace::menustate disabled
         set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,selcam) ]
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

################ EMCCD ##############################
proc ::acqfc::updateGainEMCCD { camNo visuNo gain } {
   global caption

   ::console::affiche_resultat "$caption(acqfc,emccd,gain:) $gain\n"
   cam$camNo native SetEMCCDGain $gain
}

#***** Procedure de changement du mode d'acquisition ***********
proc ::acqfc::EmccdValid { visuNo { mode "" } } {
   global panneau

   set camNo [::confCam::getCamNo $panneau(acqfc,$visuNo,camItem)]
   cam$camNo exptime $panneau(acqfc,$visuNo,pose)
   ::console::affiche_resultat "cam$camNo exptime $panneau(acqfc,$visuNo,pose)\n"

   if {$panneau(acqfc,$visuNo,emccdmode)=="0"} {
      set acqmodeemccd "series"
      cam$camNo acqmode $acqmodeemccd 1 0 $panneau(acqfc,$visuNo,emccdtriggermode)
      ::console::affiche_resultat "cam$camNo acqmode $acqmodeemccd 1 0 $panneau(acqfc,$visuNo,emccdtriggermode)\n"
   } else {
      set acqmodeemccd "accumulate"
      set panneau(acqfc,$visuNo,emccdtriggermode) 0
      cam$camNo acqmode $acqmodeemccd $panneau(acqfc,$visuNo,emccd_nb) $panneau(acqfc,$visuNo,AccuCycleTme) 0
      ::console::affiche_resultat "cam$camNo acqmode $acqmodeemccd $panneau(acqfc,$visuNo,emccd_nb) $panneau(acqfc,$visuNo,AccuCycleTme) 0\n"
   }
}
#***** Fin de la procedure de changement du mode d'acquisition *
################ FIN EMCCD ##############################

proc ::acqfc::acqfcBuildIF { visuNo } {
   global audace caption conf panneau

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   #--- Trame du panneau
   frame $panneau(acqfc,$visuNo,This) -borderwidth 2 -relief groove -bg $audace(color,backColor)

   #--- Trame du titre du panneau
   frame $panneau(acqfc,$visuNo,This).titre -borderwidth 2 -relief groove
      Button $panneau(acqfc,$visuNo,This).titre.but -borderwidth 1 \
         -text "$caption(acqfc,help_titre1)\n$caption(acqfc,titre)" \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqfc::getPluginType ] ] \
            [ ::acqfc::getPluginDirectory ] [ ::acqfc::getPluginHelp ]"
      pack $panneau(acqfc,$visuNo,This).titre.but -side top -fill x -in $panneau(acqfc,$visuNo,This).titre -ipadx 5
      DynamicHelp::add $panneau(acqfc,$visuNo,This).titre.but -text $caption(acqfc,help_titre)
   pack $panneau(acqfc,$visuNo,This).titre -side top -fill x

   #--- Trame du bouton de configuration
   frame $panneau(acqfc,$visuNo,This).config -borderwidth 2 -relief groove
      button $panneau(acqfc,$visuNo,This).config.but -borderwidth 1 -text $caption(acqfc,configuration) \
        -command "::acqfcSetup::run $visuNo $base.acqfcSetup"
      pack $panneau(acqfc,$visuNo,This).config.but -side top -fill x -in $panneau(acqfc,$visuNo,This).config -ipadx 5
   pack $panneau(acqfc,$visuNo,This).config -side top -fill x

   #--- Trame du temps de pose
   frame $panneau(acqfc,$visuNo,This).pose -borderwidth 2 -relief ridge
      menubutton $panneau(acqfc,$visuNo,This).pose.but -text $caption(acqfc,pose) \
         -menu $panneau(acqfc,$visuNo,This).pose.but.menu -relief raised
      pack $panneau(acqfc,$visuNo,This).pose.but -side left -fill x -expand true -ipady 1
      set m [ menu $panneau(acqfc,$visuNo,This).pose.but.menu -tearoff 0 ]
      foreach temps $panneau(acqfc,$visuNo,temps_pose) {
        $m add radiobutton -label "$temps" \
           -indicatoron "1" \
           -value "$temps" \
           -variable panneau(acqfc,$visuNo,pose) \
           -command " "
      }
      label $panneau(acqfc,$visuNo,This).pose.lab -text $caption(acqfc,sec)
      pack $panneau(acqfc,$visuNo,This).pose.lab -side right -fill x -expand true
          entry $panneau(acqfc,$visuNo,This).pose.entr -width 6 -relief groove \
            -textvariable panneau(acqfc,$visuNo,pose) -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $panneau(acqfc,$visuNo,This).pose.entr -side left -fill both -expand true
   pack $panneau(acqfc,$visuNo,This).pose -side top -fill x

   #--- Bouton de configuration de la WebCam en lieu et place du widget pose
   button $panneau(acqfc,$visuNo,This).pose.conf -text $caption(acqfc,pose+reglages) \
      -command "::acqfc::webcamConfigure $visuNo"
   pack $panneau(acqfc,$visuNo,This).pose.conf -fill x -expand true -ipady 3

   #--- Trame du binning
   frame $panneau(acqfc,$visuNo,This).binning -borderwidth 2 -relief ridge
      menubutton $panneau(acqfc,$visuNo,This).binning.but -text $caption(acqfc,bin) \
         -menu $panneau(acqfc,$visuNo,This).binning.but.menu -relief raised
      pack $panneau(acqfc,$visuNo,This).binning.but -side left -fill y -expand true -ipady 1
      set m [ menu $panneau(acqfc,$visuNo,This).binning.but.menu -tearoff 0 ]
      foreach valbin [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] binningList ] {
         $m add radiobutton -label "$valbin" \
            -indicatoron "1" \
            -value "$valbin" \
            -variable panneau(acqfc,$visuNo,binning) \
            -command " "
      }
      entry $panneau(acqfc,$visuNo,This).binning.lab -width 10 -relief groove \
         -textvariable panneau(acqfc,$visuNo,binning) -justify center \
         -validate all -validatecommand { ::tkutil::validateString %W %V %P %s binning 1 5 }
      pack $panneau(acqfc,$visuNo,This).binning.lab -side left -fill both -expand true
   pack $panneau(acqfc,$visuNo,This).binning -side top -fill x

   #--- Trame du format
   frame $panneau(acqfc,$visuNo,This).format -borderwidth 2 -relief ridge
      menubutton $panneau(acqfc,$visuNo,This).format.but -text $caption(acqfc,format) \
         -menu $panneau(acqfc,$visuNo,This).format.but.menu -relief raised
      pack $panneau(acqfc,$visuNo,This).format.but -side left -fill y -expand true -ipady 1
      set m [ menu $panneau(acqfc,$visuNo,This).format.but.menu -tearoff 0 ]
      foreach format [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] formatList ] {
         $m add radiobutton -label "$format" \
            -indicatoron "1" \
            -value "$format" \
            -variable panneau(acqfc,$visuNo,format) \
            -command " "
      }
      entry $panneau(acqfc,$visuNo,This).format.lab -width 10 -relief groove \
         -textvariable panneau(acqfc,$visuNo,format) -justify center -state readonly
      pack $panneau(acqfc,$visuNo,This).format.lab -side left -fill both -expand true
   pack $panneau(acqfc,$visuNo,This).format -side top -fill x

   #--- Trame de l'obturateur
   frame $panneau(acqfc,$visuNo,This).obt -borderwidth 2 -relief ridge -width 16
      button $panneau(acqfc,$visuNo,This).obt.but -text $caption(acqfc,obt) -command "::acqfc::ChangeObt $visuNo" \
         -state normal
      pack $panneau(acqfc,$visuNo,This).obt.but -side left -ipady 3
      label $panneau(acqfc,$visuNo,This).obt.lab -text $panneau(acqfc,$visuNo,obt,$panneau(acqfc,$visuNo,obt)) -width 6 \
        -relief groove
      pack $panneau(acqfc,$visuNo,This).obt.lab -side left -fill x -expand true -ipady 3
   pack $panneau(acqfc,$visuNo,This).obt -side top -fill x

   #--- Trame du Status
   frame $panneau(acqfc,$visuNo,This).status -borderwidth 2 -relief ridge
      label $panneau(acqfc,$visuNo,This).status.lab -text "" -relief ridge \
         -justify center -width 16
      pack $panneau(acqfc,$visuNo,This).status.lab -side top -fill x -pady 1
   pack $panneau(acqfc,$visuNo,This).status -side top -fill x

   #--- Trame du bouton Go/Stop
   frame $panneau(acqfc,$visuNo,This).go_stop -borderwidth 2 -relief ridge
      Button $panneau(acqfc,$visuNo,This).go_stop.but -text $caption(acqfc,GO) -height 2 \
         -borderwidth 3 -command "::acqfc::Go $visuNo"
      pack $panneau(acqfc,$visuNo,This).go_stop.but -fill both -padx 0 -pady 0 -expand true
   pack $panneau(acqfc,$visuNo,This).go_stop -side top -fill x

   #--- Trame du mode d'acquisition
   set panneau(acqfc,$visuNo,mode_en_cours) [ lindex $panneau(acqfc,$visuNo,list_mode) [ expr $panneau(acqfc,$visuNo,mode) - 1 ] ]
   frame $panneau(acqfc,$visuNo,This).mode -borderwidth 5 -relief ridge
      ComboBox $panneau(acqfc,$visuNo,This).mode.but \
         -width 15         \
         -height [llength $panneau(acqfc,$visuNo,list_mode)] \
         -relief raised    \
         -borderwidth 1    \
         -editable 0       \
         -takefocus 1      \
         -justify center   \
         -textvariable panneau(acqfc,$visuNo,mode_en_cours) \
         -values $panneau(acqfc,$visuNo,list_mode) \
         -modifycmd "::acqfc::ChangeMode $visuNo"
      pack $panneau(acqfc,$visuNo,This).mode.but -side top -fill x

      #--- Definition du sous-panneau "Mode : Une seule image"
      frame $panneau(acqfc,$visuNo,This).mode.une -borderwidth 0
         frame $panneau(acqfc,$visuNo,This).mode.une.nom -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.une.nom.but -text $caption(acqfc,nom) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.une.nom.but -fill x -side top
            entry $panneau(acqfc,$visuNo,This).mode.une.nom.entr -width 10 \
               -textvariable panneau(acqfc,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqfc,$visuNo,This).mode.une.nom.entr -fill x -side top
            label $panneau(acqfc,$visuNo,This).mode.une.nom.lab_extension -text $caption(acqfc,extension) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.une.nom.lab_extension -fill x -side left
            menubutton $panneau(acqfc,$visuNo,This).mode.une.nom.extension -textvariable panneau(acqfc,$visuNo,extension) \
               -menu $panneau(acqfc,$visuNo,This).mode.une.nom.extension.menu -relief raised
            pack $panneau(acqfc,$visuNo,This).mode.une.nom.extension -side right -fill x -expand true -ipady 1
            set m [ menu $panneau(acqfc,$visuNo,This).mode.une.nom.extension.menu -tearoff 0 ]
            foreach extension $::audace(extensionList) {
              $m add radiobutton -label "$extension" \
                 -indicatoron "1" \
                 -value "$extension" \
                 -variable panneau(acqfc,$visuNo,extension) \
                 -command " "
            }
         pack $panneau(acqfc,$visuNo,This).mode.une.nom -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.une.index -relief ridge -borderwidth 2
            checkbutton $panneau(acqfc,$visuNo,This).mode.une.index.case -pady 0 -text $caption(acqfc,index) \
               -variable panneau(acqfc,$visuNo,indexer)
            pack $panneau(acqfc,$visuNo,This).mode.une.index.case -side top -fill x
            entry $panneau(acqfc,$visuNo,This).mode.une.index.entr -width 3 -textvariable panneau(acqfc,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqfc,$visuNo,This).mode.une.index.entr -side left -fill x -expand true
            button $panneau(acqfc,$visuNo,This).mode.une.index.but -text "1" -width 3 \
               -command "set panneau(acqfc,$visuNo,index) 1"
            pack $panneau(acqfc,$visuNo,This).mode.une.index.but -side right -fill x
         pack $panneau(acqfc,$visuNo,This).mode.une.index -side top -fill x
         button $panneau(acqfc,$visuNo,This).mode.une.sauve -text $caption(acqfc,sauvegde) \
            -command "::acqfc::SauveUneImage $visuNo"
         pack $panneau(acqfc,$visuNo,This).mode.une.sauve -side top -fill x

      #--- Definition du sous-panneau "Mode : Serie d'images"
      frame $panneau(acqfc,$visuNo,This).mode.serie
         frame $panneau(acqfc,$visuNo,This).mode.serie.nom -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.serie.nom.but -text $caption(acqfc,nom) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.serie.nom.but -fill x
            entry $panneau(acqfc,$visuNo,This).mode.serie.nom.entr -width 10 \
               -textvariable panneau(acqfc,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqfc,$visuNo,This).mode.serie.nom.entr -fill x
            label $panneau(acqfc,$visuNo,This).mode.serie.nom.lab_extension -text $caption(acqfc,extension) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.serie.nom.lab_extension -fill x -side left
            menubutton $panneau(acqfc,$visuNo,This).mode.serie.nom.extension -textvariable panneau(acqfc,$visuNo,extension) \
               -menu $panneau(acqfc,$visuNo,This).mode.serie.nom.extension.menu -relief raised
            pack $panneau(acqfc,$visuNo,This).mode.serie.nom.extension -side right -fill x -expand true -ipady 1
            set m [ menu $panneau(acqfc,$visuNo,This).mode.serie.nom.extension.menu -tearoff 0 ]
            foreach extension $::audace(extensionList) {
              $m add radiobutton -label "$extension" \
                 -indicatoron "1" \
                 -value "$extension" \
                 -variable panneau(acqfc,$visuNo,extension) \
                 -command " "
            }
         pack $panneau(acqfc,$visuNo,This).mode.serie.nom -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.serie.nb -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.serie.nb.but -text $caption(acqfc,nombre) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.serie.nb.but -side left -fill y
            entry $panneau(acqfc,$visuNo,This).mode.serie.nb.entr -width 3 -textvariable panneau(acqfc,$visuNo,nb_images) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqfc,$visuNo,This).mode.serie.nb.entr -side left -fill x -expand true
         pack $panneau(acqfc,$visuNo,This).mode.serie.nb -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.serie.index -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.serie.index.lab -text $caption(acqfc,index) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.serie.index.lab -side top -fill x
            entry $panneau(acqfc,$visuNo,This).mode.serie.index.entr -width 3 -textvariable panneau(acqfc,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqfc,$visuNo,This).mode.serie.index.entr -side left -fill x -expand true
            button $panneau(acqfc,$visuNo,This).mode.serie.index.but -text "1" -width 3 \
               -command "set panneau(acqfc,$visuNo,index) 1"
            pack $panneau(acqfc,$visuNo,This).mode.serie.index.but -side right -fill x
         pack $panneau(acqfc,$visuNo,This).mode.serie.index -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.serie.indexEnd -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.serie.indexEnd.lab1 \
               -textvariable panneau(acqfc,$visuNo,indexEndSerie) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.serie.indexEnd.lab1 -side top -fill x
         pack $panneau(acqfc,$visuNo,This).mode.serie.indexEnd -side top -fill x

      #--- Definition du sous-panneau "Mode : Continu"
      frame $panneau(acqfc,$visuNo,This).mode.continu
         frame $panneau(acqfc,$visuNo,This).mode.continu.sauve -relief ridge -borderwidth 2
            checkbutton $panneau(acqfc,$visuNo,This).mode.continu.sauve.case -text $caption(acqfc,enregistrer) \
               -variable panneau(acqfc,$visuNo,enregistrer)
            pack $panneau(acqfc,$visuNo,This).mode.continu.sauve.case -side left -fill x  -expand true
         pack $panneau(acqfc,$visuNo,This).mode.continu.sauve -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.continu.nom -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.continu.nom.but -text $caption(acqfc,nom) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.continu.nom.but -fill x
            entry $panneau(acqfc,$visuNo,This).mode.continu.nom.entr -width 10 \
               -textvariable panneau(acqfc,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqfc,$visuNo,This).mode.continu.nom.entr -fill x
            label $panneau(acqfc,$visuNo,This).mode.continu.nom.lab_extension -text $caption(acqfc,extension) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.continu.nom.lab_extension -fill x -side left
            menubutton $panneau(acqfc,$visuNo,This).mode.continu.nom.extension -textvariable panneau(acqfc,$visuNo,extension) \
               -menu $panneau(acqfc,$visuNo,This).mode.continu.nom.extension.menu -relief raised
            pack $panneau(acqfc,$visuNo,This).mode.continu.nom.extension -side right -fill x -expand true -ipady 1
            set m [ menu $panneau(acqfc,$visuNo,This).mode.continu.nom.extension.menu -tearoff 0 ]
            foreach extension $::audace(extensionList) {
              $m add radiobutton -label "$extension" \
                 -indicatoron "1" \
                 -value "$extension" \
                 -variable panneau(acqfc,$visuNo,extension) \
                 -command " "
            }
         pack $panneau(acqfc,$visuNo,This).mode.continu.nom -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.continu.index -relief ridge -borderwidth 2
            checkbutton $panneau(acqfc,$visuNo,This).mode.continu.index.case -pady 0 -text $caption(acqfc,index) \
               -variable panneau(acqfc,$visuNo,indexerContinue)
            pack $panneau(acqfc,$visuNo,This).mode.continu.index.case -side top -fill x
            entry $panneau(acqfc,$visuNo,This).mode.continu.index.entr -width 3 -textvariable panneau(acqfc,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqfc,$visuNo,This).mode.continu.index.entr -side left -fill x -expand true
            button $panneau(acqfc,$visuNo,This).mode.continu.index.but -text "1" -width 3 \
               -command "set panneau(acqfc,$visuNo,index) 1"
            pack $panneau(acqfc,$visuNo,This).mode.continu.index.but -side right -fill x
         pack $panneau(acqfc,$visuNo,This).mode.continu.index -side top -fill x

      #--- Definition du sous-panneau "Mode : Series d'images en continu avec intervalle entre chaque serie"
      frame $panneau(acqfc,$visuNo,This).mode.serie_1
         frame $panneau(acqfc,$visuNo,This).mode.serie_1.nom -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.serie_1.nom.but -text $caption(acqfc,nom) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.serie_1.nom.but -fill x
            entry $panneau(acqfc,$visuNo,This).mode.serie_1.nom.entr -width 10 \
               -textvariable panneau(acqfc,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqfc,$visuNo,This).mode.serie_1.nom.entr -fill x
            label $panneau(acqfc,$visuNo,This).mode.serie_1.nom.lab_extension -text $caption(acqfc,extension) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.serie_1.nom.lab_extension -fill x -side left
            menubutton $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension -textvariable panneau(acqfc,$visuNo,extension) \
               -menu $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension.menu -relief raised
            pack $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension -side right -fill x -expand true -ipady 1
            set m [ menu $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension.menu -tearoff 0 ]
            foreach extension $::audace(extensionList) {
              $m add radiobutton -label "$extension" \
                 -indicatoron "1" \
                 -value "$extension" \
                 -variable panneau(acqfc,$visuNo,extension) \
                 -command " "
            }
         pack $panneau(acqfc,$visuNo,This).mode.serie_1.nom -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.serie_1.nb -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.serie_1.nb.but -text $caption(acqfc,nombre) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.serie_1.nb.but -side left -fill y
            entry $panneau(acqfc,$visuNo,This).mode.serie_1.nb.entr -width 3 -textvariable panneau(acqfc,$visuNo,nb_images) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqfc,$visuNo,This).mode.serie_1.nb.entr -side left -fill x -expand true
         pack $panneau(acqfc,$visuNo,This).mode.serie_1.nb -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.serie_1.index -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.serie_1.index.lab -text $caption(acqfc,index) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.serie_1.index.lab -side top -fill x
            entry $panneau(acqfc,$visuNo,This).mode.serie_1.index.entr -width 3 -textvariable panneau(acqfc,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqfc,$visuNo,This).mode.serie_1.index.entr -side left -fill x -expand true
            button $panneau(acqfc,$visuNo,This).mode.serie_1.index.but -text "1" -width 3 \
               -command "set panneau(acqfc,$visuNo,index) 1"
            pack $panneau(acqfc,$visuNo,This).mode.serie_1.index.but -side right -fill x
         pack $panneau(acqfc,$visuNo,This).mode.serie_1.index -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.serie_1.indexEnd -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.serie_1.indexEnd.lab1 \
               -textvariable panneau(acqfc,$visuNo,indexEndSerieContinu) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.serie_1.indexEnd.lab1 -side top -fill x
         pack $panneau(acqfc,$visuNo,This).mode.serie_1.indexEnd -side top -fill x

      #--- Definition du sous-panneau "Mode : Continu avec intervalle entre chaque image"
      frame $panneau(acqfc,$visuNo,This).mode.continu_1
         frame $panneau(acqfc,$visuNo,This).mode.continu_1.sauve -relief ridge -borderwidth 2
            checkbutton $panneau(acqfc,$visuNo,This).mode.continu_1.sauve.case -text $caption(acqfc,enregistrer) \
               -variable panneau(acqfc,$visuNo,enregistrer)
            pack $panneau(acqfc,$visuNo,This).mode.continu_1.sauve.case -side left -fill x  -expand true
         pack $panneau(acqfc,$visuNo,This).mode.continu_1.sauve -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.continu_1.nom -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.continu_1.nom.but -text $caption(acqfc,nom) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.continu_1.nom.but -fill x
            entry $panneau(acqfc,$visuNo,This).mode.continu_1.nom.entr -width 10 \
               -textvariable panneau(acqfc,$visuNo,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqfc,$visuNo,This).mode.continu_1.nom.entr -fill x
            label $panneau(acqfc,$visuNo,This).mode.continu_1.nom.lab_extension -text $caption(acqfc,extension) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.continu_1.nom.lab_extension -fill x -side left
            menubutton $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension -textvariable panneau(acqfc,$visuNo,extension) \
               -menu $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension.menu -relief raised
            pack $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension -side right -fill x -expand true -ipady 1
            set m [ menu $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension.menu -tearoff 0 ]
            foreach extension $::audace(extensionList) {
              $m add radiobutton -label "$extension" \
                 -indicatoron "1" \
                 -value "$extension" \
                 -variable panneau(acqfc,$visuNo,extension) \
                 -command " "
            }
         pack $panneau(acqfc,$visuNo,This).mode.continu_1.nom -side top -fill x
         frame $panneau(acqfc,$visuNo,This).mode.continu_1.index -relief ridge -borderwidth 2
            label $panneau(acqfc,$visuNo,This).mode.continu_1.index.lab -text $caption(acqfc,index) -pady 0
            pack $panneau(acqfc,$visuNo,This).mode.continu_1.index.lab -side top -fill x
            entry $panneau(acqfc,$visuNo,This).mode.continu_1.index.entr -width 3 -textvariable panneau(acqfc,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqfc,$visuNo,This).mode.continu_1.index.entr -side left -fill x -expand true
            button $panneau(acqfc,$visuNo,This).mode.continu_1.index.but -text "1" -width 3 \
               -command "set panneau(acqfc,$visuNo,index) 1"
            pack $panneau(acqfc,$visuNo,This).mode.continu_1.index.but -side right -fill x
         pack $panneau(acqfc,$visuNo,This).mode.continu_1.index -side top -fill x
      pack $panneau(acqfc,$visuNo,This).mode -side top -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $panneau(acqfc,$visuNo,This).avancement_acq -borderwidth 2 -relief ridge
         #--- Checkbutton pour l'affichage de l'avancement de l'acqusition
         checkbutton $panneau(acqfc,$visuNo,This).avancement_acq.check -highlightthickness 0 \
            -text $caption(acqfc,avancement_acq) -variable panneau(acqfc,$visuNo,avancement_acq)
         pack $panneau(acqfc,$visuNo,This).avancement_acq.check -side left -fill x
      pack $panneau(acqfc,$visuNo,This).avancement_acq -side top -fill x

      #--- Frame petit decalage
      frame $panneau(acqfc,$visuNo,This).shift -borderwidth 2 -relief ridge
         #--- Checkbutton petit deplacement
         checkbutton $panneau(acqfc,$visuNo,This).shift.buttonShift -highlightthickness 0 \
            -variable panneau(DlgShift,buttonShift)
         pack $panneau(acqfc,$visuNo,This).shift.buttonShift -side left -fill x
         #--- Bouton configuration petit deplacement
         button $panneau(acqfc,$visuNo,This).shift.buttonShiftConfig -text "$caption(acqfc,buttonShiftConfig)" \
            -command "::acqfc::cmdShiftConfig $visuNo"
         pack $panneau(acqfc,$visuNo,This).shift.buttonShiftConfig -side right -fill x -expand true
      pack $panneau(acqfc,$visuNo,This).shift -side top -fill x

      #--- Frame Flat Auto
      frame $panneau(acqfc,$visuNo,This).special -borderwidth 2 -relief ridge
         #--- Bouton Flat auto
         button $panneau(acqfc,$visuNo,This).special.flatauto -text "$caption(acqfc,flatAuto)" \
            -command "::acqfcAutoFlat::run $visuNo"
         pack $panneau(acqfc,$visuNo,This).special.flatauto -side top -fill x -expand true
      pack $panneau(acqfc,$visuNo,This).special -side top -fill x

      set camname ""
      catch {set camname [cam1 name]}

      if {$camname=="Luc285_MONO"} {

         ::console::affiche_resultat "$caption(acqfc,emccd,mode) \n"
         set camNo [::confCam::getCamNo $panneau(acqfc,$visuNo,camItem)]

         #--- Parametres par defaut
         set panneau(acqfc,$visuNo,emccd_nb)         0
         set panneau(acqfc,$visuNo,AccuCycleTme)     [expr $panneau(acqfc,$visuNo,pose)+1]
         set panneau(acqfc,$visuNo,emccdmode)        0
         set panneau(acqfc,$visuNo,emccdtriggermode) 0

         #--- Create a dummy space
         frame $panneau(acqfc,$visuNo,This).vide -height 10 -borderwidth 0 -relief flat -background $audace(color,listBox)
         pack $panneau(acqfc,$visuNo,This).vide -side top -fill x -fill y

         #--- Frame Titre EMCCD
         frame $panneau(acqfc,$visuNo,This).param -bg $audace(color,activeTextColor)
            label $panneau(acqfc,$visuNo,This).param.paramEMCCD -text $caption(acqfc,emccd,parametres) -foreground $audace(color,activeBackColor) -background $audace(color,listBox) \
               -font {-size 15 -weight bold}
            pack $panneau(acqfc,$visuNo,This).param.paramEMCCD -side right -fill x -expand true
         pack $panneau(acqfc,$visuNo,This).param -side top -fill x -pady 5

         #--- Create a dummy space
         frame $panneau(acqfc,$visuNo,This).vide3 -height 5 -borderwidth 0 -relief flat -background $audace(color,listBox)
         pack $panneau(acqfc,$visuNo,This).vide3 -side top -fill x -fill y

         #--- Frame Mode EMCCD : Fonction meo_acq_execute de meo_com.tcl
         frame $panneau(acqfc,$visuNo,This).acqexecute
            button $panneau(acqfc,$visuNo,This).acqexecute.but -text $caption(acqfc,emccd,paramAcqAuto) -borderwidth 1\
               -command "meo_acq_execute"
            pack $panneau(acqfc,$visuNo,This).acqexecute.but -side top -fill x
         pack $panneau(acqfc,$visuNo,This).acqexecute -side top -fill x

         #--- Create a dummy space
         frame $panneau(acqfc,$visuNo,This).vide4 -height 5 -borderwidth 0 -relief flat -background $audace(color,listBox)
         pack $panneau(acqfc,$visuNo,This).vide4 -side top -fill x -fill y

         #--- Frame Mode EMCCD : Single or accumulate
         frame $panneau(acqfc,$visuNo,This).modechoix
            label $panneau(acqfc,$visuNo,This).modechoix.titre -text $caption(acqfc,emccd,mode) -font {-size 10 -weight bold}
            pack $panneau(acqfc,$visuNo,This).modechoix.titre -side top -fill x -expand true
            radiobutton $panneau(acqfc,$visuNo,This).modechoix.but1 -text $caption(acqfc,emccd,single) -variable panneau(acqfc,$visuNo,emccdmode) -value "0"
            radiobutton $panneau(acqfc,$visuNo,This).modechoix.but2 -text $caption(acqfc,emccd,accumulate) -variable panneau(acqfc,$visuNo,emccdmode) -value "1"
            pack $panneau(acqfc,$visuNo,This).modechoix.but1 $panneau(acqfc,$visuNo,This).modechoix.but2 -side right -fill x -expand true
         pack $panneau(acqfc,$visuNo,This).modechoix -side top -fill x

         #--- Frame Mode EMCCD : Accumulate parameter
         frame $panneau(acqfc,$visuNo,This).modeaccu -borderwidth 0
            frame $panneau(acqfc,$visuNo,This).modeaccu.nom -relief ridge -borderwidth 2
               label $panneau(acqfc,$visuNo,This).modeaccu.nom.but -text $caption(acqfc,emccd,accuCycleTime) -pady 0
               pack $panneau(acqfc,$visuNo,This).modeaccu.nom.but -side left -fill x -expand true
               entry $panneau(acqfc,$visuNo,This).modeaccu.nom.entr -width 10 \
                  -textvariable panneau(acqfc,$visuNo,AccuCycleTme) -relief groove \
                  -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
               pack $panneau(acqfc,$visuNo,This).modeaccu.nom.entr -fill x -side top
               frame $panneau(acqfc,$visuNo,This).modeaccu.nb -relief ridge -borderwidth 2
                  label $panneau(acqfc,$visuNo,This).modeaccu.nb.but -text $caption(acqfc,nombre) -pady 0
                  pack $panneau(acqfc,$visuNo,This).modeaccu.nb.but -side left -fill y
                  entry $panneau(acqfc,$visuNo,This).modeaccu.nb.entr -width 3 -textvariable panneau(acqfc,$visuNo,emccd_nb) \
                     -relief groove -justify center \
                     -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
                  pack $panneau(acqfc,$visuNo,This).modeaccu.nb.entr -side left -fill x -expand true
               pack $panneau(acqfc,$visuNo,This).modeaccu.nb -side top -fill x
            pack $panneau(acqfc,$visuNo,This).modeaccu.nom -side top -fill x
         pack $panneau(acqfc,$visuNo,This).modeaccu -side top -fill x

         #--- Create a dummy space
         frame $panneau(acqfc,$visuNo,This).vide6 -height 5 -borderwidth 0 -relief flat -background $audace(color,listBox)
         pack $panneau(acqfc,$visuNo,This).vide6 -side top -fill x -fill y

         #--- Frame Mode EMCCD : Trigger mode
         frame $panneau(acqfc,$visuNo,This).modetrigger
            label $panneau(acqfc,$visuNo,This).modetrigger.titre -text $caption(acqfc,emccd,modeTrigger) -font {-size 10 -weight bold}
            pack $panneau(acqfc,$visuNo,This).modetrigger.titre -side top -fill x -expand true
            radiobutton $panneau(acqfc,$visuNo,This).modetrigger.but1 -text $caption(acqfc,emccd,internal) -variable panneau(acqfc,$visuNo,emccdtriggermode) -value "0"
            radiobutton $panneau(acqfc,$visuNo,This).modetrigger.but2 -text $caption(acqfc,emccd,external) -variable panneau(acqfc,$visuNo,emccdtriggermode) -value "1"
            pack $panneau(acqfc,$visuNo,This).modetrigger.but1 $panneau(acqfc,$visuNo,This).modetrigger.but2 -side right -fill x -expand true
         pack $panneau(acqfc,$visuNo,This).modetrigger -side top -fill x

         #--- Create a dummy space
         frame $panneau(acqfc,$visuNo,This).vide5 -height 5 -borderwidth 0 -relief flat -background $audace(color,listBox)
         pack $panneau(acqfc,$visuNo,This).vide5 -side top -fill x -fill y

         #--- Frame Mode EMCCD : validation
         frame $panneau(acqfc,$visuNo,This).valiemccd
            button $panneau(acqfc,$visuNo,This).valiemccd.but -text $caption(acqfc,emccd,validation) -borderwidth 1\
               -command "::acqfc::EmccdValid $visuNo"
            pack $panneau(acqfc,$visuNo,This).valiemccd.but -side top -fill x
         pack $panneau(acqfc,$visuNo,This).valiemccd -side top -fill x

         #--- Create a dummy space
         frame $panneau(acqfc,$visuNo,This).vide2 -height 2 -borderwidth 0 -relief flat
         pack $panneau(acqfc,$visuNo,This).vide2 -side top -fill x -pady 5

         #--- Frame Titre Gain EMCCD
         frame $panneau(acqfc,$visuNo,This).titregain
            label $panneau(acqfc,$visuNo,This).titregain.titre -text $caption(acqfc,emccd,gain) -font {-size 10 -weight bold}
            pack $panneau(acqfc,$visuNo,This).titregain.titre -side right -fill x -expand true
         pack $panneau(acqfc,$visuNo,This).titregain -side top -fill x

         #--- Frame Gain EMCCD
         frame $panneau(acqfc,$visuNo,This).gain
            scale $panneau(acqfc,$visuNo,This).gain.scrolbar -orient horizontal -length 200 -from 0 -to 200 \
            -tickinterval 50 -activebackground red -bg $audace(color,entryBackColor) -relief sunken -command "::acqfc::updateGainEMCCD $camNo $visuNo"
            #\-highlightbackground backColor
            pack $panneau(acqfc,$visuNo,This).gain.scrolbar -side right -fill x -expand true
         pack $panneau(acqfc,$visuNo,This).gain -side top -fill x

         #--- Create a dummy space
         frame $panneau(acqfc,$visuNo,This).vide7 -height 2 -borderwidth 0 -relief flat
         pack $panneau(acqfc,$visuNo,This).vide7 -side top -fill x -pady 5

         #--- Frame Titre Zoom EMCCD
         frame $panneau(acqfc,$visuNo,This).titrezoom
            label $panneau(acqfc,$visuNo,This).titrezoom.titre -text $caption(acqfc,emccd,ZOOM) -font {-size 10 -weight bold}
            pack $panneau(acqfc,$visuNo,This).titrezoom.titre -side right -fill x -expand true
         pack $panneau(acqfc,$visuNo,This).titrezoom -side top -fill x

         #--- Taille Zoom
         frame $panneau(acqfc,$visuNo,This).zoom -borderwidth 2 -relief ridge
            menubutton $panneau(acqfc,$visuNo,This).zoom.but -text $caption(acqfc,emccd,Zoom) \
               -menu $panneau(acqfc,$visuNo,This).zoom.but.menu -relief raised
            pack $panneau(acqfc,$visuNo,This).zoom.but -side left -fill y -expand true -ipady 1

            set m [ menu $panneau(acqfc,$visuNo,This).zoom.but.menu -tearoff 0 ]
            foreach zoom { 0.125 0.25 0.5 1 2 4 8 } {
               $m add radiobutton -label "$zoom" \
                  -indicatoron "1" \
                  -value "$zoom" \
                  -variable panneau(acqfc,$visuNo,zoom) \
                  -command {set visuNo $::audace(visuNo); ::confVisu::setZoom $visuNo $panneau(acqfc,1,zoom)}
            }

            label $panneau(acqfc,$visuNo,This).zoom.lab -width 10 -relief groove \
               -textvariable panneau(acqfc,$visuNo,zoom) -justify center
            pack $panneau(acqfc,$visuNo,This).zoom.lab -side left -fill both -expand true

         pack $panneau(acqfc,$visuNo,This).zoom -side top -fill x

      }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(acqfc,$visuNo,This)

}

