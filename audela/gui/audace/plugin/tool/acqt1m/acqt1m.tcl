#
# Fichier : acqt1m.tcl
# Description : Outil d'acquisition specifique pour le T1m
# Auteur : Frédéric Vachier
# Mise à jour $Id: acqt1m.tcl 14060 2016-10-03 15:24:58Z fredvachier $
#

#==============================================================
#   Declaration du namespace acqt1m
#==============================================================

namespace eval ::acqt1m {

   package provide acqt1m 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] acqt1m.cap ]
}




















proc ::acqt1m::ressource { } {

      global audace caption

      ::console::affiche_resultat "$caption(acqt1m,rechargeScripts)"
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m acqt1m.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m acqt1m.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m cycle.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m cycle.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m t1m_roue_a_filtre.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m t1m_roue_a_filtre.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m acqt1mSetup.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m dlgshiftt1m.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m gps.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m flatcielplus.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m flatcielplus.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m offsetdark.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m configuration.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m mycycle.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m astroid.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m astroid.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqt1m horloge_astro2.tcl ]\""

      # bddimages
      source [file join $audace(rep_install) gui audace plugin tool bddimages utils astroid visu.tcl ]
      source [file join $audace(rep_install) gui audace plugin tool bddimages utils astroid manage_source.tcl ]
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_admin.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_go.tcl ]\""
      ::bddimages::ressource_tools

      package require math::statistics

      if {$::tcl_platform(os)=="Linux"} {
         set err [catch {load libmeinberg[info sharedlibextension]} msg]
         if {$err} {
            gren_erreur "Meinberg ERR = $err ($msg)\n"
         }
      }

      set ::cycle::go 0
      puts "ressource acqt1m"

   }




















#***** Procedure createPluginInstance***************************
proc ::acqt1m::createPluginInstance { base { visuNo 1 } } {
   variable parametres
   global audace caption conf panneau

   #--- Chargement des fichiers auxiliaires
   ::acqt1m::ressource


   #---
   set panneau(acqt1m,$visuNo,base) "$base"
   set panneau(acqt1m,$visuNo,This) "$base.acqt1m"

   set panneau(acqt1m,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
   set panneau(acqt1m,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqt1m,$visuNo,camItem)]

   #--- Recuperation de la derniere configuration de l'outil
   ::acqt1m::chargerVariable $visuNo

   #--- Initialisation des variables de la boite de configuration
   ::acqt1mSetup::confToWidget $visuNo

   #--- Initialisation de la roue a filtres
   ::t1m_roue_a_filtre::initFiltre $visuNo

   #--- Initialisation des variables de la boite de decalage du telescope
   ::DlgShiftt1m::confToWidget $visuNo

   #--- Initialisation de la variable conf()
   if { ! [info exists conf(acqt1m,avancement,position)] } { set conf(acqt1m,avancement,position) "+120+315" }

   #--- Initialisation de variables
   set panneau(acqt1m,$visuNo,simulation)            "0"
   set panneau(acqt1m,$visuNo,simulation_deja_faite) "0"
   set panneau(acqt1m,$visuNo,attente_pose)          "0"
   set panneau(acqt1m,$visuNo,pose_en_cours)         "0"
   set panneau(acqt1m,$visuNo,avancement,position)   "$conf(acqt1m,avancement,position)"

   #--- Entrer ici les valeurs de temps de pose a afficher dans le menu "pose"
   set panneau(acqt1m,$visuNo,temps_pose) { 0 0.1 0.3 0.5 1 2 3 5 10 15 20 30 60 90 120 180 300 600 }
   #--- Valeur par defaut du temps de pose
   if { ! [ info exists panneau(acqt1m,$visuNo,pose) ] } {
      set panneau(acqt1m,$visuNo,pose) "$parametres(acqt1m,$visuNo,pose)"
   }

   #--- Valeur par defaut du binning
   if { ! [ info exists panneau(acqt1m,$visuNo,binning) ] } {
      set panneau(acqt1m,$visuNo,binning) "$parametres(acqt1m,$visuNo,bin)"
   }

   #--- Valeur par defaut de la qualite
   if { ! [ info exists panneau(acqt1m,$visuNo,format) ] } {
      set panneau(acqt1m,$visuNo,format) "$parametres(acqt1m,$visuNo,format)"
   }

   #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
   set panneau(acqt1m,$visuNo,obt,0) "$caption(acqt1m,ouv)"
   set panneau(acqt1m,$visuNo,obt,1) "$caption(acqt1m,ferme)"
   set panneau(acqt1m,$visuNo,obt,2) "$caption(acqt1m,auto)"
   #--- Obturateur par defaut : Synchro
   if { ! [ info exists panneau(acqt1m,$visuNo,obt) ] } {
      set panneau(acqt1m,$visuNo,obt) "$parametres(acqt1m,$visuNo,obt)"
   }

   #--- Liste des modes disponibles
   set panneau(acqt1m,$visuNo,list_mode) [ list $caption(acqt1m,uneimage) $caption(acqt1m,serie) $caption(acqt1m,continu) \
      $caption(acqt1m,continu_1) $caption(acqt1m,continu_2) ]

   #--- Initialisation des modes
   set panneau(acqt1m,$visuNo,mode,1) "$panneau(acqt1m,$visuNo,This).mode.une"
   set panneau(acqt1m,$visuNo,mode,2) "$panneau(acqt1m,$visuNo,This).mode.serie"
   set panneau(acqt1m,$visuNo,mode,3) "$panneau(acqt1m,$visuNo,This).mode.continu"
   set panneau(acqt1m,$visuNo,mode,4) "$panneau(acqt1m,$visuNo,This).mode.serie_1"
   set panneau(acqt1m,$visuNo,mode,5) "$panneau(acqt1m,$visuNo,This).mode.continu_1"
   #--- Mode par defaut : Une image
   if { ! [ info exists panneau(acqt1m,$visuNo,mode) ] } {
      set panneau(acqt1m,$visuNo,mode) "$parametres(acqt1m,$visuNo,mode)"
   } else {
      if { $panneau(acqt1m,$visuNo,mode) > 5 } {
         #--- je positionne mode=1 si un mode > 5 dans le fichier de configuration,
         #--- car les modes 6 et 7 n'exitent plus. Ils sont deplaces dans l'outil d'acquisition video.
         set panneau(acqt1m,$visuNo,mode) 1
      }
   }

   #--- Initialisation d'autres variables
   set panneau(acqt1m,$visuNo,index)                "1"
   set panneau(acqt1m,$visuNo,indexEndSerie)        ""
   set panneau(acqt1m,$visuNo,indexEndSerieContinu) ""
   set panneau(acqt1m,$visuNo,object)               ""
   set panneau(acqt1m,$visuNo,extension)            "$conf(extension,defaut)"
   set panneau(acqt1m,$visuNo,indexer)              "0"
   set panneau(acqt1m,$visuNo,indexerContinue)      "1"
   set panneau(acqt1m,$visuNo,nb_images)            "5"
   set panneau(acqt1m,$visuNo,session_ouverture)    "1"
   set panneau(acqt1m,$visuNo,avancement_acq)       "$parametres(acqt1m,$visuNo,avancement_acq)"
   set panneau(acqt1m,$visuNo,enregistrer)          "$parametres(acqt1m,$visuNo,enregistrer)"
   set panneau(acqt1m,$visuNo,dispTimeAfterId)      ""
   #--- Mise en place de l'interface graphique
   acqt1mBuildIF $visuNo

   pack $panneau(acqt1m,$visuNo,mode,$panneau(acqt1m,$visuNo,mode)) -anchor nw -fill x

   #--- Surveillance de la connexion d'une camera
   ::confVisu::addCameraListener $visuNo "::acqt1m::adaptOutilAcqt1m $visuNo"
   #--- Surveillance de l'ajout ou de la suppression d'une extension
   trace add variable ::audace(extensionList) write "::acqt1m::initExtensionList $visuNo"

   #---
   return $panneau(acqt1m,$visuNo,This)
}
#***** Fin de la procedure createPluginInstance*****************




















#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::acqt1m::deletePluginInstance { visuNo } {
   global conf panneau

   #--- Je desactive la surveillance de la connexion d'une camera
   ::confVisu::removeCameraListener $visuNo "::acqt1m::adaptOutilAcqt1m $visuNo"
   #--- Je desactive la surveillance de l'ajout ou de la suppression d'une extension
   trace remove variable ::audace(extensionList) write "::acqt1m::initExtensionList $visuNo"

   #---
   set conf(acqt1m,avancement,position) $panneau(acqt1m,$visuNo,avancement,position)
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
   destroy $panneau(acqt1m,$visuNo,This)
   destroy $panneau(acqt1m,$visuNo,This).pose.but.menu
   destroy $panneau(acqt1m,$visuNo,This).binning.but.menu
}




















#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::acqt1m::getPluginProperty { propertyName } {
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
proc ::acqt1m::getPluginTitle { } {
   global caption
   return "$caption(acqt1m,titre)"
}




















#------------------------------------------------------------
#  getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::acqt1m::getPluginHelp { } {
   return "acqt1m.htm"
}




















#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::acqt1m::getPluginType { } {
   return "tool"
}




















#------------------------------------------------------------
#  getPluginDirectory
#     retourne le repertoire du plugin
#------------------------------------------------------------
proc ::acqt1m::getPluginDirectory { } {
   return "acqt1m"
}




















#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::acqt1m::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}


















#***** Procedure Demarrageacqt1m ********************************
proc ::acqt1m::Demarrageacqt1m { visuNo } {

   global audace caption

   #--- Creation du sous-repertoire a la date du jour
   #--- en mode automatique s'il n'existe pas
   ::cwdWindow::updateImageDirectory

   #--- Gestion du fichier de log
   #--- Creation du nom du fichier log
   set nom_generique "acqt1m-visu$visuNo-"
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
   set ::acqt1m::fichier_log [ file join $audace(rep_images) [ append $file_log $nom_generique $formatdate ".log" ] ]

   #--- Ouverture du fichier de log
   if { [ catch { open $::acqt1m::fichier_log a } ::acqt1m::log_id($visuNo) ] } {
      Message $visuNo console $caption(acqt1m,pbouvfichcons)
      tk_messageBox -title $caption(acqt1m,pb) -type ok \
         -message $caption(acqt1m,pbouvfich)
      #--- Note importante : Je detecte si j'ai un pb a l'ouverture du fichier, mais je ne sais pas traiter ce cas :
      #--- Il faudrait interdire l'ouverture du panneau, mais le processus est deja lance a ce stade...
      #--- Tout ce que je fais, c'est inviter l'utilisateur a changer d'outil !
   } else {
      #--- En-tete du fichier
      Message $visuNo log $caption(acqt1m,ouvsess) [ package version acqt1m ]
      set date [clock format [clock seconds] -format "%A %d %B %Y"]
      set date [ ::tkutil::transalteDate $date ]
      set heure $audace(tu,format,hmsint)
      Message $visuNo consolog $caption(acqt1m,affheure) $date $heure
      #--- Definition du binding pour declencher l'acquisition (ou l'arret) par Echap.
      bind all <Key-Escape> "::acqt1m::Stop $visuNo"
   }
}
#***** Fin de la procedure Demarrageacqt1m **********************




















#***** Procedure Arretacqt1m ************************************
proc ::acqt1m::Arretacqt1m { visuNo } {

   global audace caption panneau

   #--- Fermeture du fichier de log
   if { [ info exists ::acqt1m::log_id($visuNo) ] } {
      set heure $audace(tu,format,hmsint)
      #--- Je m'assure que le fichier se termine correctement, en particulier pour le cas ou il y
      #--- a eu un probleme a l'ouverture (c'est un peu une rustine...)
      if { [ catch { Message $visuNo log $caption(acqt1m,finsess) $heure } bug ] } {
         Message $visuNo console $caption(acqt1m,pbfermfichcons)
      } else {
         Message $visuNo console "\n"
         close $::acqt1m::log_id($visuNo)
         unset ::acqt1m::log_id($visuNo)
      }
   }
   #--- Re-initialisation de la session
   set panneau(acqt1m,$visuNo,session_ouverture) "1"
   #--- Desactivation du binding pour declencher l'acquisition (ou l'arret) par Echap.
   bind all <Key-Escape> { }
}
#***** Fin de la procedure Arretacqt1m **************************




















#***** Procedure initExtensionList ********************************
proc ::acqt1m::initExtensionList { visuNo { a "" } { b "" } { c "" } } {

   global caption conf panneau

   #--- Mise a jour de l'extension par defaut
   set panneau(acqt1m,$visuNo,extension) $conf(extension,defaut)
   set camItem [ ::confVisu::getCamItem $visuNo ]
   set extensionList " $::audace(extensionList) [ confCam::getPluginProperty $camItem rawExtension ]"
   ::console::affiche_resultat "$caption(acqt1m,extensionFITS) $panneau(acqt1m,$visuNo,extension)\n\n"
}
#***** Fin de la procedure initExtensionList **********************




















#***** Procedure adaptOutilAcqt1m *******************************
proc ::acqt1m::adaptOutilAcqt1m { visuNo args } {

   global conf panneau

   set panneau(acqt1m,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
   set panneau(acqt1m,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqt1m,$visuNo,camItem)]

   #--- petits reccorcis bien utiles
   set camItem $panneau(acqt1m,$visuNo,camItem)
   set camNo   $panneau(acqt1m,$visuNo,camNo)
   if { $camNo == "0" } {
      #--- La camera n'a pas ete encore selectionnee
      set camProduct ""
   } else {
      set camProduct [ cam$camNo product ]
   }

   #--- widgets de pose
   if { [ confCam::getPluginProperty $camItem longExposure ] == "1" } {
      #--- j'affiche les boutons standard de choix de pose
      pack $panneau(acqt1m,$visuNo,This).pose.but -side left
      pack $panneau(acqt1m,$visuNo,This).pose.lab -side right
      pack $panneau(acqt1m,$visuNo,This).pose.entr -side left -fill both -expand true
      #---- je masque le widget specifique
      pack forget $panneau(acqt1m,$visuNo,This).pose.conf
   } else {
      #--- je masque les widgets standards
      pack forget $panneau(acqt1m,$visuNo,This).pose.but
      pack forget $panneau(acqt1m,$visuNo,This).pose.lab
      pack forget $panneau(acqt1m,$visuNo,This).pose.entr
      #--- j'affiche le bouton specifique
      pack $panneau(acqt1m,$visuNo,This).pose.conf -fill x -expand true -ipady 3
   }

   #--- widgets de l'obturateur
   if { [ ::confCam::getPluginProperty $camItem hasShutter ] == "1" } {
      if { ! [ info exists conf($camProduct,foncobtu) ] } {
         set conf($camProduct,foncobtu) "2"
      } else {
         if { $conf($camProduct,foncobtu) == "0" } {
            set panneau(acqt1m,$visuNo,obt) "0"
         } elseif { $conf($camProduct,foncobtu) == "1" } {
            set panneau(acqt1m,$visuNo,obt) "1"
         } elseif { $conf($camProduct,foncobtu) == "2" } {
            set panneau(acqt1m,$visuNo,obt) "2"
         }
      }
      $panneau(acqt1m,$visuNo,This).obt.lab configure -text $panneau(acqt1m,$visuNo,obt,$panneau(acqt1m,$visuNo,obt))
      #--- j'affiche la frame de l'obturateur
      pack $panneau(acqt1m,$visuNo,This).obt -side top -fill x -before $panneau(acqt1m,$visuNo,This).status
   } else {
      #--- je masque la frame de l'obturateur
      pack forget $panneau(acqt1m,$visuNo,This).obt
   }

   #--- je mets a jour la liste des extensions
   ::acqt1m::initExtensionList $visuNo
}




















#***** Procedure chargerVariable *******************************
proc ::acqt1m::chargerVariable { visuNo } {

   variable parametres

   #--- Ouverture du fichier de parametres
   set fichier [ file join $::audace(rep_home) acqt1m.ini ]
   if { [ file exists $fichier ] } {
      source $fichier
   }

   #--- Creation des variables si elles n'existent pas
   if { ! [ info exists parametres(acqt1m,$visuNo,pose) ] }           { set parametres(acqt1m,$visuNo,pose)   "5" }   ; #--- Temps de pose : 5s
   if { ! [ info exists parametres(acqt1m,$visuNo,bin) ] }            { set parametres(acqt1m,$visuNo,bin)    "1x1" } ; #--- Binning : 2x2
   if { ! [ info exists parametres(acqt1m,$visuNo,format) ] }         { set parametres(acqt1m,$visuNo,format) "" }    ; #--- Format des APN
   if { ! [ info exists parametres(acqt1m,$visuNo,obt) ] }            { set parametres(acqt1m,$visuNo,obt)    "2" }   ; #--- Obturateur : Synchro
   if { ! [ info exists parametres(acqt1m,$visuNo,mode) ] }           { set parametres(acqt1m,$visuNo,mode)   "1" }   ; #--- Mode : Une image
   if { ! [ info exists parametres(acqt1m,$visuNo,avancement_acq) ] } {
      if { $visuNo == "1" } {
         set parametres(acqt1m,$visuNo,avancement_acq) "1" ; #--- Barre de progression de la pose : Oui
      } else {
         set parametres(acqt1m,$visuNo,avancement_acq) "0" ; #--- Barre de progression de la pose : Non
      }
   }
   if { ! [ info exists parametres(acqt1m,$visuNo,enregistrer) ] } { set parametres(acqt1m,$visuNo,enregistrer) "1" } ; #--- Sauvegarde des images : Oui

   #--- Creation des variables de la boite de configuration si elles n'existent pas
   ::acqt1mSetup::initToConf $visuNo

   #--- Creation des variables de la boite de decalage du telescope si elles n'existent pas
   ::DlgShiftt1m::initToConf $visuNo
}
#***** Fin de la procedure chargerVariable *********************




















#***** Procedure enregistrerVariable ***************************
proc ::acqt1m::enregistrerVariable { visuNo } {

   variable parametres

   global panneau

   #---
   set panneau(acqt1m,$visuNo,mode)              [ expr [ lsearch "$panneau(acqt1m,$visuNo,list_mode)" "$panneau(acqt1m,$visuNo,mode_en_cours)" ] + 1 ]
   #---
   set parametres(acqt1m,$visuNo,pose)           $panneau(acqt1m,$visuNo,pose)
   set parametres(acqt1m,$visuNo,bin)            $panneau(acqt1m,$visuNo,binning)
   set parametres(acqt1m,$visuNo,format)         $panneau(acqt1m,$visuNo,format)
   set parametres(acqt1m,$visuNo,obt)            $panneau(acqt1m,$visuNo,obt)
   set parametres(acqt1m,$visuNo,mode)           $panneau(acqt1m,$visuNo,mode)
   set parametres(acqt1m,$visuNo,avancement_acq) $panneau(acqt1m,$visuNo,avancement_acq)
   set parametres(acqt1m,$visuNo,enregistrer)    $panneau(acqt1m,$visuNo,enregistrer)

   #--- Sauvegarde des parametres
   catch {
     set nom_fichier [ file join $::audace(rep_home) acqt1m.ini ]
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




#***** Procedure push_gui ***************************
# Sauvegarde les valeurs de champs de la GUI
# et les stoque dans une variable de classe
# s'utilise avec la fonction pop_gui
#
proc ::acqt1m::push_gui { visuNo } {

   variable parametres_sav
   global panneau


      # Mode Debug ++
      if {1==1} {
         ::console::affiche_resultat "Lecture des parametres de la GUI\n"
         ::console::affiche_resultat "\n"
         foreach {x y} [ array get panneau ] {
            set ok [ string first "acqt1m" $x ]
            if {$ok>-1} {::console::affiche_resultat "$x = $y\n"}
         }
      }



      set parametres_sav(acqt1m,$visuNo,mode)                                  [ expr [ lsearch "$panneau(acqt1m,$visuNo,list_mode)" "$panneau(acqt1m,$visuNo,mode_en_cours)" ] + 1 ]
      set parametres_sav(acqt1m,$visuNo,mode_en_cours)                         $panneau(acqt1m,$visuNo,mode_en_cours)
      set parametres_sav(acqt1m,$visuNo,pose)                                  $panneau(acqt1m,$visuNo,pose)
      set parametres_sav(acqt1m,$visuNo,bin)                                   $panneau(acqt1m,$visuNo,binning)
      set parametres_sav(acqt1m,$visuNo,format)                                $panneau(acqt1m,$visuNo,format)
      set parametres_sav(acqt1m,$visuNo,obt)                                   $panneau(acqt1m,$visuNo,obt)
      set parametres_sav(acqt1m,$visuNo,avancement_acq)                        $panneau(acqt1m,$visuNo,avancement_acq)
      set parametres_sav(acqt1m,$visuNo,enregistrer)                           $panneau(acqt1m,$visuNo,enregistrer)
      set parametres_sav(acqt1m,$visuNo,verifier_ecraser_fichier)              $panneau(acqt1m,$visuNo,verifier_ecraser_fichier)
      set parametres_sav(acqt1m,$visuNo,nb_images)                             $panneau(acqt1m,$visuNo,nb_images)
      set parametres_sav(acqt1m,$visuNo,ra)                                    $panneau(acqt1m,$visuNo,ra)
      set parametres_sav(acqt1m,$visuNo,object)                                $panneau(acqt1m,$visuNo,object)
      set parametres_sav(acqt1m,$visuNo,pose_en_cours)                         $panneau(acqt1m,$visuNo,pose_en_cours)
      set parametres_sav(acqt1m,$visuNo,indexer)                               $panneau(acqt1m,$visuNo,indexer)
      set parametres_sav(acqt1m,$visuNo,save_file_log)                         $panneau(acqt1m,$visuNo,save_file_log)
      set parametres_sav(acqt1m,$visuNo,index)                                 $panneau(acqt1m,$visuNo,index)
      set parametres_sav(acqt1m,$visuNo,verifier_index_depart)                 $panneau(acqt1m,$visuNo,verifier_index_depart)
      set parametres_sav(acqt1m,$visuNo,enregistrer_acquisiton_interrompue)    $panneau(acqt1m,$visuNo,enregistrer_acquisiton_interrompue)
      set parametres_sav(acqt1m,$visuNo,avancement_acq)                        $panneau(acqt1m,$visuNo,avancement_acq)
      set parametres_sav(acqt1m,$visuNo,indexerContinue)                       $panneau(acqt1m,$visuNo,indexerContinue)
      set parametres_sav(acqt1m,$visuNo,binning)                               $panneau(acqt1m,$visuNo,binning)
      set parametres_sav(acqt1m,$visuNo,pose)                                  $panneau(acqt1m,$visuNo,pose)
      set parametres_sav(acqt1m,$visuNo,enregistrer)                           $panneau(acqt1m,$visuNo,enregistrer)
      set parametres_sav(acqt1m,$visuNo,attente_pose)                          $panneau(acqt1m,$visuNo,attente_pose)
      set parametres_sav(acqt1m,$visuNo,filtrecourant)                         $panneau(acqt1m,$visuNo,filtrecourant)
      set parametres_sav(acqt1m,$visuNo,dec)                                   $panneau(acqt1m,$visuNo,dec)
      set parametres_sav(acqt1m,$visuNo,session_ouverture)                     $panneau(acqt1m,$visuNo,session_ouverture)
      set parametres_sav(acqt1m,$visuNo,alarme_fin_serie)                      $panneau(acqt1m,$visuNo,alarme_fin_serie)


      # Mode Debug
      if {1==1} {
         ::console::affiche_resultat "Lecture des parametres de la GUI\n"
         ::console::affiche_resultat "mode           = $parametres_sav(acqt1m,$visuNo,mode)\n"
         ::console::affiche_resultat "mode_en_cours  = $parametres_sav(acqt1m,$visuNo,mode_en_cours)\n"
         ::console::affiche_resultat "pose           = $parametres_sav(acqt1m,$visuNo,pose)\n"
         ::console::affiche_resultat "bin            = $parametres_sav(acqt1m,$visuNo,bin)\n"
         ::console::affiche_resultat "format         = $parametres_sav(acqt1m,$visuNo,format)\n"
         ::console::affiche_resultat "obturateur     = $panneau(acqt1m,$visuNo,obt,$parametres_sav(acqt1m,$visuNo,obt))\n"
         ::console::affiche_resultat "avancement_acq = $parametres_sav(acqt1m,$visuNo,avancement_acq)\n"
         ::console::affiche_resultat "enregistrer    = $parametres_sav(acqt1m,$visuNo,enregistrer)\n"

         ::console::affiche_resultat "verifier_ecraser_fichier           = $parametres_sav(acqt1m,$visuNo,verifier_ecraser_fichier)          \n"
         ::console::affiche_resultat "nb_images                          = $parametres_sav(acqt1m,$visuNo,nb_images)                         \n"
         ::console::affiche_resultat "ra                                 = $parametres_sav(acqt1m,$visuNo,ra)                                \n"
         ::console::affiche_resultat "object                             = $parametres_sav(acqt1m,$visuNo,object)                            \n"
         ::console::affiche_resultat "pose_en_cours                      = $parametres_sav(acqt1m,$visuNo,pose_en_cours)                     \n"
         ::console::affiche_resultat "indexer                            = $parametres_sav(acqt1m,$visuNo,indexer)                           \n"
         ::console::affiche_resultat "save_file_log                      = $parametres_sav(acqt1m,$visuNo,save_file_log)                     \n"
         ::console::affiche_resultat "index                              = $parametres_sav(acqt1m,$visuNo,index)                             \n"
         ::console::affiche_resultat "verifier_index_depart              = $parametres_sav(acqt1m,$visuNo,verifier_index_depart)             \n"
         ::console::affiche_resultat "enregistrer_acquisiton_interrompue = $parametres_sav(acqt1m,$visuNo,enregistrer_acquisiton_interrompue)\n"
         ::console::affiche_resultat "avancement_acq                     = $parametres_sav(acqt1m,$visuNo,avancement_acq)                    \n"
         ::console::affiche_resultat "indexerContinue                    = $parametres_sav(acqt1m,$visuNo,indexerContinue)                   \n"
         ::console::affiche_resultat "binning                            = $parametres_sav(acqt1m,$visuNo,binning)                           \n"
         ::console::affiche_resultat "pose                               = $parametres_sav(acqt1m,$visuNo,pose)                              \n"
         ::console::affiche_resultat "enregistrer                        = $parametres_sav(acqt1m,$visuNo,enregistrer)                       \n"
         ::console::affiche_resultat "attente_pose                       = $parametres_sav(acqt1m,$visuNo,attente_pose)                      \n"
         ::console::affiche_resultat "filtrecourant                      = $parametres_sav(acqt1m,$visuNo,filtrecourant)                     \n"
         ::console::affiche_resultat "dec                                = $parametres_sav(acqt1m,$visuNo,dec)                               \n"
         ::console::affiche_resultat "session_ouverture                  = $parametres_sav(acqt1m,$visuNo,session_ouverture)                 \n"
         ::console::affiche_resultat "alarme_fin_serie                   = $parametres_sav(acqt1m,$visuNo,alarme_fin_serie)                  \n"
      }


      # acqt1m,1,verifier_ecraser_fichier = 1
      # acqt1m,1,demande_arret = 0
      # acqt1m,1,nb_images = 5
      # acqt1m,1,sauve_img_interrompue = 0
      # acqt1m,1,format =
      # acqt1m,1,ra =
      # acqt1m,1,object = test
      # acqt1m,1,pose_en_cours = 0
      # acqt1m,1,mode = 2
      # acqt1m,1,indexer = 0
      # acqt1m,1,save_file_log = 1
      # acqt1m,1,index = 1
      # acqt1m,1,enregistrer_acquisiton_interrompue = 1
      # acqt1m,1,extension = .fit
      # acqt1m,1,avancement_acq = 1
      # acqt1m,1,indexerContinue = 1
      # acqt1m,1,binning = 2x2
      # acqt1m,1,acqImageEnd = 1
      # acqt1m,1,pose = 3
      # acqt1m,1,enregistrer = 0
      # acqt1m,1,attente_pose = 0
      # acqt1m,1,obt = 1
      # acqt1m,1,mode_en_cours = Une s豩e
      # acqt1m,1,filtrecourant = Rs
      # acqt1m,1,filtrelist = Large B V R Us Gs Rs Is Zs Large B V R Us Gs Rs Is Zs Large B V R Us Gs Rs Is Zs Large B V R Us Gs Rs Is Zs Large B V R Us Gs Rs Is Zs Large B V R Us Gs Rs Is Zs Large B V R Us Gs Rs Is Zs Large B V R Us Gs Rs Is Zs Large B V R Us Gs Rs Is Zs Large B V R Us Gs Rs Is Zs Large B V R Us Gs Rs Is Zs
      # acqt1m,1,obt,0 = Ouvert
      # acqt1m,1,obt,1 = Ferm爠     # acqt1m,1,obt,2 = Synchro
      # acqt1m,1,dec =
      # acqt1m,1,session_ouverture = 0
      # acqt1m,1,alarme_fin_serie = 1

      return
}



#***** Procedure pop_gui ***************************
# Charge les valeurs de champs de la GUI
# depuis une variable de classe
# s'utilise avec la fonction push_gui
#
proc ::acqt1m::pop_gui { visuNo } {

   variable parametres_sav
   global panneau


      set panneau(acqt1m,$visuNo,mode_en_cours) [ lindex $panneau(acqt1m,$visuNo,list_mode) [ expr $parametres_sav(acqt1m,$visuNo,mode) - 1 ] ]
      ::console::affiche_resultat "MODE_EN_COURS=$panneau(acqt1m,$visuNo,mode_en_cours)\n"

      ::acqt1m::ChangeMode $visuNo $panneau(acqt1m,$visuNo,mode_en_cours)

      set panneau(acqt1m,$visuNo,mode) $parametres_sav(acqt1m,$visuNo,mode)
      ::console::affiche_resultat "MODE=$panneau(acqt1m,$visuNo,mode)\n"


      set panneau(acqt1m,$visuNo,mode)                               $parametres_sav(acqt1m,$visuNo,mode)
      set panneau(acqt1m,$visuNo,mode_en_cours)                      $parametres_sav(acqt1m,$visuNo,mode_en_cours)
      set panneau(acqt1m,$visuNo,pose)                               $parametres_sav(acqt1m,$visuNo,pose)
      set panneau(acqt1m,$visuNo,binning)                            $parametres_sav(acqt1m,$visuNo,bin)
      set panneau(acqt1m,$visuNo,format)                             $parametres_sav(acqt1m,$visuNo,format)
      set panneau(acqt1m,$visuNo,obt)                                $parametres_sav(acqt1m,$visuNo,obt)
      set panneau(acqt1m,$visuNo,avancement_acq)                     $parametres_sav(acqt1m,$visuNo,avancement_acq)
      set panneau(acqt1m,$visuNo,enregistrer)                        $parametres_sav(acqt1m,$visuNo,enregistrer)
      set panneau(acqt1m,$visuNo,verifier_ecraser_fichier)           $parametres_sav(acqt1m,$visuNo,verifier_ecraser_fichier)
      set panneau(acqt1m,$visuNo,nb_images)                          $parametres_sav(acqt1m,$visuNo,nb_images)
      set panneau(acqt1m,$visuNo,ra)                                 $parametres_sav(acqt1m,$visuNo,ra)
      set panneau(acqt1m,$visuNo,object)                             $parametres_sav(acqt1m,$visuNo,object)
      set panneau(acqt1m,$visuNo,pose_en_cours)                      $parametres_sav(acqt1m,$visuNo,pose_en_cours)
      set panneau(acqt1m,$visuNo,indexer)                            $parametres_sav(acqt1m,$visuNo,indexer)
      set panneau(acqt1m,$visuNo,save_file_log)                      $parametres_sav(acqt1m,$visuNo,save_file_log)
      set panneau(acqt1m,$visuNo,index)                              $parametres_sav(acqt1m,$visuNo,index)
      set panneau(acqt1m,$visuNo,verifier_index_depart)              $parametres_sav(acqt1m,$visuNo,verifier_index_depart)
      set panneau(acqt1m,$visuNo,enregistrer_acquisiton_interrompue) $parametres_sav(acqt1m,$visuNo,enregistrer_acquisiton_interrompue)
      set panneau(acqt1m,$visuNo,avancement_acq)                     $parametres_sav(acqt1m,$visuNo,avancement_acq)
      set panneau(acqt1m,$visuNo,indexerContinue)                    $parametres_sav(acqt1m,$visuNo,indexerContinue)
      set panneau(acqt1m,$visuNo,binning)                            $parametres_sav(acqt1m,$visuNo,binning)
      set panneau(acqt1m,$visuNo,pose)                               $parametres_sav(acqt1m,$visuNo,pose)
      set panneau(acqt1m,$visuNo,enregistrer)                        $parametres_sav(acqt1m,$visuNo,enregistrer)
      set panneau(acqt1m,$visuNo,attente_pose)                       $parametres_sav(acqt1m,$visuNo,attente_pose)
      set panneau(acqt1m,$visuNo,filtrecourant)                      $parametres_sav(acqt1m,$visuNo,filtrecourant)
      set panneau(acqt1m,$visuNo,dec)                                $parametres_sav(acqt1m,$visuNo,dec)
      set panneau(acqt1m,$visuNo,session_ouverture)                  $parametres_sav(acqt1m,$visuNo,session_ouverture)
      set panneau(acqt1m,$visuNo,alarme_fin_serie)                   $parametres_sav(acqt1m,$visuNo,alarme_fin_serie)

      ::acqt1m::changebinning $visuNo
      ::acqt1m::setShutter $visuNo $panneau(acqt1m,$visuNo,obt)

      ::t1m_roue_a_filtre::changeFiltreInfini $visuNo

      return
}












#***** Procedure startTool *************************************
proc ::acqt1m::startTool { { visuNo 1 } } {
   global panneau

   #--- On cree la variable de configuration des mots cles
   if { ! [ info exists ::conf(acqt1m,keywordConfigName) ] } { set ::conf(acqt1m,keywordConfigName) "default" }

   #--- Creation des fenetres auxiliaires si necessaire
   if { $panneau(acqt1m,$visuNo,mode) == "4" } {
      ::acqt1m::Intervalle_continu_1 $visuNo
   } elseif { $panneau(acqt1m,$visuNo,mode) == "5" } {
      ::acqt1m::Intervalle_continu_2 $visuNo
   }

   ::acqt1m::adaptOutilAcqt1m $visuNo
}
#***** Fin de la procedure startTool ***************************




















#***** Procedure stopTool **************************************
proc ::acqt1m::stopTool { { visuNo 1 } } {
   global panneau

   #--- Je verifie si une operation est en cours
   if { $panneau(acqt1m,$visuNo,pose_en_cours) == 1 } {
      return -1
   }

   #--- Je verifie si une operation est en cours (acquisition des flats auto)
   if { [ info exists ::acqt1m_flatcielplus::private(pose_en_cours) ] } {
      if { $::acqt1m_flatcielplus::private(pose_en_cours) == 1 } {
         return -1
      }
   }

   #--- Sauvegarde de la configuration de prise de vue
   ::acqt1m::enregistrerVariable $visuNo

   #--- Destruction des fenetres auxiliaires et sauvegarde de leurs positions si elles existent
   ::acqt1m::recup_position $visuNo

   Arretacqt1m $visuNo
}
#***** Fin de la procedure stopTool ****************************




















#***** Procedure addinfoheader **************************************
proc ::acqt1m::addinfoheader { { visuNo 1 } } {
   global panneau

   #--- Je verifie si une operation est en cours
   if { $panneau(acqt1m,$visuNo,pose_en_cours) == 1 } {
      return -1
   }

}
#***** Fin de la procedure stopTool ****************************




















#***** Procedure de changement du mode d'acquisition ***********
proc ::acqt1m::ChangeMode { visuNo { mode "" } } {
   global panneau

   pack forget $panneau(acqt1m,$visuNo,mode,$panneau(acqt1m,$visuNo,mode)) -anchor nw -fill x

   if { $mode != "" } {
      #--- j'applique le mode passe en parametre
      set panneau(acqt1m,$visuNo,mode_en_cours) $mode
   }

   set panneau(acqt1m,$visuNo,mode) [ expr [ lsearch "$panneau(acqt1m,$visuNo,list_mode)" "$panneau(acqt1m,$visuNo,mode_en_cours)" ] + 1 ]
   if { $panneau(acqt1m,$visuNo,mode) == "1" } {
      ::acqt1m::recup_position $visuNo
   } elseif { $panneau(acqt1m,$visuNo,mode) == "2" } {
     ::acqt1m::recup_position $visuNo
   } elseif { $panneau(acqt1m,$visuNo,mode) == "3" } {
      ::acqt1m::recup_position $visuNo
   } elseif { $panneau(acqt1m,$visuNo,mode) == "4" } {
      ::acqt1m::Intervalle_continu_1 $visuNo
   } elseif { $panneau(acqt1m,$visuNo,mode) == "5" } {
      ::acqt1m::Intervalle_continu_2 $visuNo
   }
   pack $panneau(acqt1m,$visuNo,mode,$panneau(acqt1m,$visuNo,mode)) -anchor nw -fill x
}
#***** Fin de la procedure de changement du mode d'acquisition *













#--- Procedure de changement du binning de la GUI
# affiche le binning courant dans le panneau de la GUI

proc ::acqt1m::changebinning { visuNo } {

      global caption panneau

      $panneau(acqt1m,$visuNo,This).binningt.but configure -text $caption(acqt1m,bin,$panneau(acqt1m,$visuNo,binning))
      ::console::affiche_resultat "** BINNING=$panneau(acqt1m,$visuNo,binning)\n"

}







#--- Procedure de changement du binning
proc ::acqt1m::changerBinningCent { { visuNo 1 } } {
   global audace caption panneau

   switch -exact -- $panneau(acqt1m,$visuNo,binning) {
      "1x1" {
         set panneau(acqt1m,$visuNo,binning) "2x2"
      }
      "2x2" {
         set panneau(acqt1m,$visuNo,binning) "4x4"
      }
      "4x4" {
         set panneau(acqt1m,$visuNo,binning) "1x1"
      }
   }
   #::console::affiche_resultat "bin = $caption(acqt1m,bin,$panneau(acqt1m,$visuNo,binning))\n"
   $panneau(acqt1m,$visuNo,This).binningt.but configure -text $caption(acqt1m,bin,$panneau(acqt1m,$visuNo,binning))
   if { [ winfo exists $audace(base).selection_filtre ] } {
      ::acqt1m_flatcielplus::changeBin $visuNo $panneau(acqt1m,$visuNo,binning)
   }
}




















#***** Procedure de changement de l'obturateur *****************
proc ::acqt1m::ChangeObt { visuNo } {
   global audace panneau

   #---
   set camItem [ ::confVisu::getCamItem $visuNo ]
   set camNo $panneau(acqt1m,$visuNo,camNo)

   set result [::confCam::setShutter $camItem $panneau(acqt1m,$visuNo,obt) ]
   if { $result != -1 } {
      set panneau(acqt1m,$visuNo,obt) $result
      $panneau(acqt1m,$visuNo,This).obt.lab configure -text $panneau(acqt1m,$visuNo,obt,$panneau(acqt1m,$visuNo,obt))
      if { [ winfo exists $audace(base).selection_filtre ] } {
         $audace(base).selection_filtre.a2.lb2 configure -text [ cam$camNo shutter ]
      }
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
proc ::acqt1m::setShutter { visuNo state } {
   global panneau

   set camItem [ ::confVisu::getCamItem $visuNo ]
   if { [ ::confCam::getPluginProperty $camItem hasShutter ] == 1 } {
      set panneau(acqt1m,$visuNo,obt) [::confCam::setShutter $camItem $state  "set" ]
      $panneau(acqt1m,$visuNo,This).obt.lab configure -text $panneau(acqt1m,$visuNo,obt,$panneau(acqt1m,$visuNo,obt))
   }
}






















#------------------------------------------------------------
# testParametreAcquisition
#   Tests generaux d'integrite de la requete
#
# return
#   retourne oui ou non
#------------------------------------------------------------
proc ::acqt1m::testParametreAcquisition { visuNo } {
   global audace caption panneau

   #--- Recopie de l'extension des fichiers image
   set ext $panneau(acqt1m,$visuNo,extension)
   set camItem [ ::confVisu::getCamItem $visuNo ]

   #--- Desactive le bouton Go, pour eviter un double appui
   $panneau(acqt1m,$visuNo,This).go_stop.but configure -state disabled

   #------ Tests generaux de l'integrite de la requete
   set integre oui

   #--- Tester si une camera est bien selectionnee
   if { [ ::confVisu::getCamItem $visuNo ] == "" } {
      set ::cycle::stop 1
      ::audace::menustate disabled
      set choix [ tk_messageBox -title $caption(acqt1m,pb) -type ok \
         -message $caption(acqt1m,selcam) ]
      set integre non
      if { $choix == "ok" } {
         #--- Ouverture de la fenetre de selection des cameras
         ::confCam::run
      }
      ::audace::menustate normal
   }

   #--- Le temps de pose existe-t-il ?
   if { $panneau(acqt1m,$visuNo,pose) == "" } {
      tk_messageBox -title $caption(acqt1m,pb) -type ok \
         -message $caption(acqt1m,saistps)
      set integre non
   }

   #--- Tests d'integrite specifiques a chaque mode d'acquisition
   if { $integre == "oui" } {
      #--- Branchement selon le mode de prise de vue
      switch $panneau(acqt1m,$visuNo,mode) {
         1  {
            #--- Mode une image
            if { $panneau(acqt1m,$visuNo,indexer) == "1" } {
               #--- Verifie que l'index existe
               if { $panneau(acqt1m,$visuNo,index) == "" } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                      -message $caption(acqt1m,saisind)
                  set integre non
               }
            }
            #--- Pas de decalage du telescope
            set panneau(DlgShiftt1m,buttonShift) "0"
         }
         2  {
            #--- Mode serie
            #--- Les tests ne sont pas necessaires pendant une simulation
            if { $panneau(acqt1m,$visuNo,simulation) == "0" } {
               #--- Verifier qu'il y a bien un nom de fichier
               if { $panneau(acqt1m,$visuNo,object) == "" } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,donnomfich)
                  set integre non
               }
               #--- Verifier que le nom de fichier n'a pas d'espace
               if { [ llength $panneau(acqt1m,$visuNo,object) ] > "1" } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,nomblanc)
                  set integre non
               }
               #--- Verifier que l'index existe
               if { $panneau(acqt1m,$visuNo,index) == "" } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                      -message $caption(acqt1m,saisind)
                  set integre non
               }
               #--- Envoyer un warning si l'index n'est pas a 1
               if { $panneau(acqt1m,$visuNo,index) != "1" && $panneau(acqt1m,$visuNo,verifier_index_depart) == 1 } {
                  set confirmation [tk_messageBox -title $caption(acqt1m,conf) -type yesno \
                     -message $caption(acqt1m,indpasun)]
                  if { $confirmation == "no" } {
                     set integre non
                  }
               }
               #--- Verifier que le nombre de poses existe
               if { $panneau(acqt1m,$visuNo,nb_images) == "" } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                      -message $caption(acqt1m,nbinv)
                  set integre non
               }
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShiftt1m,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,seltel) ]
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
            if { $panneau(acqt1m,$visuNo,enregistrer) == "1" } {
               #--- Verifier qu'il y a bien un nom de fichier
               if { $panneau(acqt1m,$visuNo,object) == "" } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,donnomfich)
                  set integre non
               }
               #--- Verifier que le nom de fichier n'a pas d'espace
               if { [ llength $panneau(acqt1m,$visuNo,object) ] > "1" } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,nomblanc)
                  set integre non
               }
               #--- Verifier que l'index existe
               if { $panneau(acqt1m,$visuNo,indexerContinue) == "1" } {
                  if { $panneau(acqt1m,$visuNo,index) == "" } {
                     tk_messageBox -title $caption(acqt1m,pb) -type ok \
                         -message $caption(acqt1m,saisind)
                     set integre non
                  }
               }
               #--- Envoyer un warning si l'index n'est pas a 1
               if { $panneau(acqt1m,$visuNo,indexerContinue) == "1" } {
                  if { $panneau(acqt1m,$visuNo,index) != "1" && $panneau(acqt1m,$visuNo,verifier_index_depart) == 1 } {
                     set confirmation [tk_messageBox -title $caption(acqt1m,conf) -type yesno \
                        -message $caption(acqt1m,indpasun)]
                     if { $confirmation == "no" } {
                        set integre non
                     }
                  }
               }
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShiftt1m,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,seltel) ]
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
            if { $panneau(acqt1m,$visuNo,object) == "" } {
               tk_messageBox -title $caption(acqt1m,pb) -type ok \
                  -message $caption(acqt1m,donnomfich)
               set integre non
            }
            #--- Verifier que le nom de fichier n'a pas d'espace
            if { [ llength $panneau(acqt1m,$visuNo,object) ] > "1" } {
               tk_messageBox -title $caption(acqt1m,pb) -type ok \
                  -message $caption(acqt1m,nomblanc)
               set integre non
            }
            #--- Verifier que l'index existe
            if { $panneau(acqt1m,$visuNo,index) == "" } {
               tk_messageBox -title $caption(acqt1m,pb) -type ok \
                   -message $caption(acqt1m,saisind)
               set integre non
            }
            #--- Envoyer un warning si l'index n'est pas a 1
            if { $panneau(acqt1m,$visuNo,index) != "1" && $panneau(acqt1m,$visuNo,verifier_index_depart) == 1 } {
               set confirmation [tk_messageBox -title $caption(acqt1m,conf) -type yesno \
                  -message $caption(acqt1m,indpasun)]
               if { $confirmation == "no" } {
                  set integre non
               }
            }
            #--- Verifier que le nombre de poses existe
            if { $panneau(acqt1m,$visuNo,nb_images) == "" } {
               tk_messageBox -title $caption(acqt1m,pb) -type ok \
                   -message $caption(acqt1m,nbinv)
               set integre non
            }
            #--- Verifier que la simulation a ete lancee
            if { $panneau(acqt1m,$visuNo,intervalle) == "...." } {
               tk_messageBox -title $caption(acqt1m,pb) -type ok \
                  -message $caption(acqt1m,interinv_2)
               set integre non
            #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
            } elseif { ( $panneau(acqt1m,$visuNo,intervalle) > $panneau(acqt1m,$visuNo,intervalle_1) ) && \
              ( $panneau(acqt1m,$visuNo,intervalle) != "xxxx" ) } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,interinv_1)
                  set integre non
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShiftt1m,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,seltel) ]
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
            if { $panneau(acqt1m,$visuNo,enregistrer) == "1" } {
               #--- Verifier qu'il y a bien un nom de fichier
               if { $panneau(acqt1m,$visuNo,object) == "" } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,donnomfich)
                  set integre non
               }
               #--- Verifier que le nom de fichier n'a pas d'espace
               if { [ llength $panneau(acqt1m,$visuNo,object) ] > "1" } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,nomblanc)
                  set integre non
               }
               #--- Verifier que l'index existe
               if { $panneau(acqt1m,$visuNo,index) == "" } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                      -message $caption(acqt1m,saisind)
                  set integre non
               }
               #--- Envoyer un warning si l'index n'est pas a 1
               if { $panneau(acqt1m,$visuNo,index) != "1" && $panneau(acqt1m,$visuNo,verifier_index_depart) == 1 } {
                  set confirmation [tk_messageBox -title $caption(acqt1m,conf) -type yesno \
                     -message $caption(acqt1m,indpasun)]
                  if { $confirmation == "no" } {
                     set integre non
                  }
               }
               #--- Verifier que la simulation a ete lancee
               if { $panneau(acqt1m,$visuNo,intervalle) == "...." } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,interinv_2)
                  set integre non
               #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
               } elseif { ( $panneau(acqt1m,$visuNo,intervalle) > $panneau(acqt1m,$visuNo,intervalle_2) ) && \
                 ( $panneau(acqt1m,$visuNo,intervalle) != "xxxx" ) } {
                     tk_messageBox -title $caption(acqt1m,pb) -type ok \
                        -message $caption(acqt1m,interinv_1)
                     set integre non
               }
            } else {
               #--- Verifier que la simulation a ete lancee
               if { $panneau(acqt1m,$visuNo,intervalle) == "...." } {
                  tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,interinv_2)
                  set integre non
               #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
               } elseif { ( $panneau(acqt1m,$visuNo,intervalle) > $panneau(acqt1m,$visuNo,intervalle_2) ) && \
                 ( $panneau(acqt1m,$visuNo,intervalle) != "xxxx" ) } {
                     tk_messageBox -title $caption(acqt1m,pb) -type ok \
                        -message $caption(acqt1m,interinv_1)
                     set integre non
               }
            }
            #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
            if { $panneau(DlgShiftt1m,buttonShift) == "1" } {
               if { [ ::tel::list ] == "" } {
                  ::audace::menustate disabled
                  set choix [ tk_messageBox -title $caption(acqt1m,pb) -type ok \
                     -message $caption(acqt1m,seltel) ]
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
   $panneau(acqt1m,$visuNo,This).go_stop.but configure -state normal

   return $integre
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
proc ::acqt1m::stopAcquisition { visuNo } {
   global panneau

   set ::cycle::stop 1

   if { $panneau(acqt1m,$visuNo,pose_en_cours) == 1 } {
      Stop $visuNo
   }
}




















#***** Procedure Go (appui sur le bouton Go/Stop) *********
proc ::acqt1m::Go { visuNo } {

   global audace caption panneau



   set camItem [::confVisu::getCamItem $visuNo]
   set camNo $panneau(acqt1m,$visuNo,camNo)

   #--- Ouverture du fichier historique
   if { $panneau(acqt1m,$visuNo,save_file_log) == "1" } {
      if { $panneau(acqt1m,$visuNo,session_ouverture) == "1" } {
         Demarrageacqt1m $visuNo
         set panneau(acqt1m,$visuNo,session_ouverture) "0"
      }
   }

   #--- je verifie l'integrite des parametres
   set integre [testParametreAcquisition $visuNo]
   if { $integre != "oui" } {
      return
   }

   #--- Modification du bouton, pour eviter un second lancement
   $panneau(acqt1m,$visuNo,This).go_stop.but configure -text $caption(acqt1m,stop) -command "::acqt1m::Stop $visuNo"
   #--- Verrouille tous les boutons et champs de texte pendant les acquisitions
   $panneau(acqt1m,$visuNo,This).pose.but configure -state disabled
   $panneau(acqt1m,$visuNo,This).pose.entr configure -state disabled
   $panneau(acqt1m,$visuNo,This).binningt.but configure -state disabled
   $panneau(acqt1m,$visuNo,This).obt.but configure -state disabled
   $panneau(acqt1m,$visuNo,This).mode.but configure -state disabled
   #--- Desactive toute demande d'arret
   set panneau(acqt1m,$visuNo,demande_arret) "0"
   #--- Pose en cours
   set panneau(acqt1m,$visuNo,pose_en_cours) "1"
   #--- Enregistrement d'une image interrompue
   set panneau(acqt1m,$visuNo,sauve_img_interrompue) "0"

   set catchResult [catch {
      #--- Cas particulier du passage WebCam LP en WebCam normale pour inhiber la barre progression
      if { ( [::confCam::getPluginProperty $camItem "hasVideo"] == 1 ) && ( [ confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] longExposure ] == "0" ) } {
         set panneau(acqt1m,$visuNo,pose) "0"
      }

      #--- Si je fais un offset (pose de 0s) alors l'obturateur reste ferme
      if { $panneau(acqt1m,$visuNo,pose) == "0" } {
         cam$camNo shutter "closed"
      }

      if { [::confCam::getPluginProperty $panneau(acqt1m,$visuNo,camItem) hasBinning] == "1" } {
         #--- je selectionne le binning
         set binning [list [string range $panneau(acqt1m,$visuNo,binning) 0 0] [string range $panneau(acqt1m,$visuNo,binning) 2 2]]
         #--- je verifie que le binning est conforme
         set ctrl [ scan $panneau(acqt1m,$visuNo,binning) "%dx%d" binx biny ]
         if { $ctrl == 2 } {
            set ctrlValue [ format $binx%s$biny x ]
            if { $ctrlValue != $panneau(acqt1m,$visuNo,binning) } {
               set binning "1 1"
               set panneau(acqt1m,$visuNo,binning) "1x1"
            }
         } else {
            set binning "1 1"
            set panneau(acqt1m,$visuNo,binning) "1x1"
         }
         #--- j'applique le binning
         cam$camNo bin $binning
         set binningMessage $panneau(acqt1m,$visuNo,binning)
      } else {
         set binningMessage "1x1"
      }

      if { [::confCam::getPluginProperty $panneau(acqt1m,$visuNo,camItem) hasFormat] == "1" } {
         #--- je selectionne le format des images
         ::confCam::setFormat $panneau(acqt1m,$visuNo,camItem) $panneau(acqt1m,$visuNo,format)
         set binningMessage "$panneau(acqt1m,$visuNo,format)"
      }

      #--- je verrouille les widgets selon le mode de prise de vue
      switch $panneau(acqt1m,$visuNo,mode) {
         1  {
            #--- Mode une image
            #--- Verrouille les boutons du mode "une image"
            $panneau(acqt1m,$visuNo,This).mode.une.index.case configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.une.index.entr configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.une.index.but configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.une.sauve configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqt1m,acquneim) \
               $panneau(acqt1m,$visuNo,pose) $binningMessage $heure
            #--- je ne fais qu'une image dans ce mode
            set nbImages 1
         }
         2  {
            #--- Mode serie

            #--- Verifie que le filtre correspond
            set sortie "no"
            set msg    "$caption(acqt1m,message1)\n\n"
            append msg "$caption(acqt1m,message2)\n\n"
            append msg "$caption(acqt1m,message3)\n\n"
            append msg "$caption(acqt1m,message4)"
            append msg "   FILTER='$panneau(acqt1m,$visuNo,filtrecourant)' $caption(acqt1m,message5)\n"

            while {$sortie=="no"} {
               set verif [::t1m_roue_a_filtre::verifFiltre $panneau(acqt1m,$visuNo,filtrecourant)]
               if {$verif=="yes"} {
                  # ok on est tout bon !
                  set sortie "yes"
               } else {
                  set reponse [tk_messageBox -message $msg -default retry -icon warning -title "$caption(acqt1m,attention+)" -type abortretryignore]
                  if { $reponse == "abort"} {
                     return
                  }
                  if { $reponse == "retry"} {
                  }
                  if { $reponse == "ignore"} {
                     set sortie "yes"
                  }
               }
            }

            #--- Verrouille les boutons du mode "serie"
            $panneau(acqt1m,$visuNo,This).mode.serie.nb.entr configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.serie.index.entr configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.serie.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            if { $panneau(acqt1m,$visuNo,simulation) != "0" } {
               Message $visuNo consolog $caption(acqt1m,lance_simu)
               #--- Heure de debut de la premiere pose
               set panneau(acqt1m,$visuNo,debut) [ clock second ]
            }
            Message $visuNo consolog $caption(acqt1m,lanceserie) \
               $panneau(acqt1m,$visuNo,nb_images) $heure
            Message $visuNo consolog $caption(acqt1m,nomgen) $panneau(acqt1m,$visuNo,object) \
               $panneau(acqt1m,$visuNo,pose) $binningMessage $panneau(acqt1m,$visuNo,index)
            #--- je recupere le nombre d'images de la serie donne par l'utilisateur
            set nbImages $panneau(acqt1m,$visuNo,nb_images)
         }
         3  {
            #--- Mode continu
            #--- Verrouille les boutons du mode "continu"
            $panneau(acqt1m,$visuNo,This).mode.continu.sauve.case configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.continu.index.case configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.continu.index.entr configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.continu.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqt1m,lancecont) $panneau(acqt1m,$visuNo,pose) \
               $binningMessage $heure
            if { $panneau(acqt1m,$visuNo,enregistrer) == "1" } {
               if { $panneau(acqt1m,$visuNo,indexerContinue) == "1" } {
                  Message $visuNo consolog $caption(acqt1m,enregen) \
                    $panneau(acqt1m,$visuNo,object)
               } else {
                  Message $visuNo consolog $caption(acqt1m,enrenongen) \
                    $panneau(acqt1m,$visuNo,object)
               }
            } else {
               Message $visuNo consolog $caption(acqt1m,sansenr)
            }
            #--- il n'y a pas de nombre d'image
            set nbImages ""
         }
         4  {
            #--- Mode series d'images en continu avec intervalle entre chaque serie
            #--- Verrouille les boutons du mode "continu 1"
            $panneau(acqt1m,$visuNo,This).mode.serie_1.nb.entr configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.serie_1.index.entr configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.serie_1.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqt1m,lanceserie_int) \
               $panneau(acqt1m,$visuNo,nb_images) $panneau(acqt1m,$visuNo,intervalle_1) $heure
            Message $visuNo consolog $caption(acqt1m,nomgen) $panneau(acqt1m,$visuNo,object) \
               $panneau(acqt1m,$visuNo,pose) $binningMessage $panneau(acqt1m,$visuNo,index)
            #--- Je note l'heure de debut de la premiere serie (utile pour les series espacees)
            set panneau(acqt1m,$visuNo,deb_serie) [ clock second ]
            #--- je recupere le nombre d'images des series donne par l'utilisateur
            set nbImages $panneau(acqt1m,$visuNo,nb_images)
         }
         5  {
            #--- Mode continu avec intervalle entre chaque image
            #--- Verrouille les boutons du mode "continu 2"
            $panneau(acqt1m,$visuNo,This).mode.continu_1.sauve.case configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.continu_1.index.entr configure -state disabled
            $panneau(acqt1m,$visuNo,This).mode.continu_1.index.but configure -state disabled
            set heure $audace(tu,format,hmsint)
            Message $visuNo consolog $caption(acqt1m,lancecont_int) $panneau(acqt1m,$visuNo,intervalle_2) \
               $panneau(acqt1m,$visuNo,pose) $binningMessage $heure
            if { $panneau(acqt1m,$visuNo,enregistrer) == "1" } {
               Message $visuNo consolog $caption(acqt1m,enregen) \
                 $panneau(acqt1m,$visuNo,object)
            } else {
               Message $visuNo consolog $caption(acqt1m,sansenr)
            }
            #--- il n'y a pas de nombre d'image
            set nbImages ""
         }
      }

      set camNo $panneau(acqt1m,$visuNo,camNo)
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set loadMode [::confCam::getPluginProperty $panneau(acqt1m,$visuNo,camItem) "loadMode" ]

      #--- j'initialise l'indicateur d'etat de l'acquisition
      set panneau(acqt1m,$visuNo,acquisitionState) ""
      set compteurImageSerie 1

      #--- Je calcule le dernier index de la serie
      if { $panneau(acqt1m,$visuNo,mode) == "2" } {
         set panneau(acqt1m,$visuNo,indexEndSerie) [ expr $panneau(acqt1m,$visuNo,index) + $panneau(acqt1m,$visuNo,nb_images) - 1 ]
         set panneau(acqt1m,$visuNo,indexEndSerie) "$caption(acqt1m,dernierIndex) $panneau(acqt1m,$visuNo,indexEndSerie)"
      } elseif { $panneau(acqt1m,$visuNo,mode) == "4" } {
         set panneau(acqt1m,$visuNo,indexEndSerieContinu) [ expr $panneau(acqt1m,$visuNo,index) + $panneau(acqt1m,$visuNo,nb_images) - 1 ]
         set panneau(acqt1m,$visuNo,indexEndSerieContinu) "$caption(acqt1m,dernierIndex) $panneau(acqt1m,$visuNo,indexEndSerieContinu)"
      }

      #--- Boucle d'acquisition des images
      while { $panneau(acqt1m,$visuNo,demande_arret) == "0" } {
         #--- si un nombre d'image est precise, je verifie
         if { $nbImages != "" && $compteurImageSerie > $nbImages } {
            #--- alerte sonore de fin de serie
            if { $panneau(acqt1m,$visuNo,alarme_fin_serie) == "1" } {
               if { $nbImages > "0" && $panneau(acqt1m,$visuNo,mode) == "2" } {
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
         set panneau(acqt1m,$visuNo,deb_im) [ clock second ]
         #--- Alarme sonore de fin de pose
         ::camera::alarmeSonore $panneau(acqt1m,$visuNo,pose)
         #--- Declenchement l'acquisition (voir la suite dans callbackAcquition)
         ::camera::acquisition $panneau(acqt1m,$visuNo,camItem) "::acqt1m::callbackAcquisition $visuNo" $panneau(acqt1m,$visuNo,pose)
         #--- je lance la boucle d'affichage du status
         after 10 ::acqt1m::dispTime $visuNo
         #--- j'attends la fin de l'acquisition (voir ::acqt1m::callbackAcquisition)
         vwait panneau(acqt1m,$visuNo,acquisitionState)

         if { $panneau(acqt1m,$visuNo,acquisitionState) == "error" } {
            #--- j'interromps la boucle des acquisitions dans la thread de la camera
            ::acqt1m::stopAcquisition $visuNo
            #--- je ferme la fenetre de décompte
            if { $panneau(acqt1m,$visuNo,dispTimeAfterId) != "" } {
               after cancel $panneau(acqt1m,$visuNo,dispTimeAfterId)
               set panneau(acqt1m,$visuNo,dispTimeAfterId) ""
            }
            #--- j'affiche le message d'erreur
            tk_messageBox -message $::caption(acqt1m,acquisitionError) -title $::caption(acqt1m,pb) -icon error
            break
         }

         # Recupere la date GPS
         if {[::acqt1m::gps::getdate $panneau(acqt1m,$visuNo,pose) $bufNo]} {
            $panneau(acqt1m,$visuNo,This).gps.but configure -bg "green"
         } else {
            $panneau(acqt1m,$visuNo,This).gps.but configure -bg "red"
         }

         #--- Rajoute des mots cles dans l'en-tete FITS
         foreach keyword [ ::keyword::getKeywords $visuNo $::conf(acqt1m,keywordConfigName) ] {
            buf$bufNo setkwd $keyword
         }
         #--- je trace la duree réelle de la pose s'il y a eu une interruption
         if { $panneau(acqt1m,$visuNo,demande_arret) == "1" } {
            set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
            #--- je verifie qu'il y eu interruption vraiment pendant l'acquisition
            set dateEnd [mc_date2ymdhms [ lindex [ buf$bufNo getkwd DATE-END ] 1 ]]
            set dateEnd [format "%02dh %02dm %02ds" [lindex $dateEnd 3] [lindex $dateEnd 4] [expr int([lindex $dateEnd 5])]]
            if { $exposure != $panneau(acqt1m,$visuNo,pose) } {
               Message $visuNo consolog $caption(acqt1m,arrprem) $dateEnd
               Message $visuNo consolog $caption(acqt1m,lg_pose_arret) $exposure
            } else {
               Message $visuNo consolog $caption(acqt1m,arrprem) $dateEnd
            }
         }


         #--- j'enregistre l'image et je decale le telescope
         switch $panneau(acqt1m,$visuNo,mode) {
            1  {
               #--- mode une image
               incr compteurImageSerie
            }
            2  {
               #--- Mode serie
               #--- Je sauvegarde l'image
               set filenamelist [::acqt1m::get_filename $visuNo]
               set nom   [lindex $filenamelist 1]
               set bufNo [lindex $filenamelist 0]

               #--- Pour eviter un nom de fichier qui commence par un blanc
               set nom [lindex $nom 0]
               if { $panneau(acqt1m,$visuNo,simulation) == "0" } {
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqt1m,$visuNo,index) $panneau(acqt1m,$visuNo,extension)
                  set sauvegardeValidee "1"
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" &&  $panneau(acqt1m,$visuNo,verifier_ecraser_fichier) == 1 } {
                     #--- Dans ce cas, le fichier existe deja...
                     set lastFile [ ::acqt1m::dernierFichier $visuNo ]
                     set confirmation [tk_messageBox -title $caption(acqt1m,conf) -type yesno \
                        -message "$caption(acqt1m,fichdeja_1) $lastFile $caption(acqt1m,fichdeja_2)"]
                     if { $confirmation == "no" } {
                        #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                        set sauvegardeValidee "0"
                        set panneau(acqt1m,$visuNo,demande_arret) "1"
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqt1m,$visuNo,sauve_img_interrompue) == "0" } {


                     #--- Derniere verif de l'image
                     set naxis1 [ lindex [ buf$bufNo getkwd NAXIS1 ] 1 ]
                     set naxis2 [ lindex [ buf$bufNo getkwd NAXIS2 ] 1 ]
                     if { [lsearch {2048 1024 682 512 } $naxis1] == -1 || [lsearch {2048 1024 682 512 } $naxis2] == -1 } {
                        ::console::affiche_erreur "NAXIS1 = $naxis1 NAXIS2 = $naxis2\n"
                     }


                     #--- Sauvegarde de l'image
                     saveima [append nom "." $panneau(acqt1m,$visuNo,index) $panneau(acqt1m,$visuNo,extension)] $visuNo

                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqt1m,enrim) $heure $nom
                     incr panneau(acqt1m,$visuNo,index)
                  }
               }
               #--- Deplacement du telescope
               ::DlgShiftt1m::decalageTelescope
               #--- j'incremente le nombre d'images de la serie
               incr compteurImageSerie
            }
            3  {
               #--- Mode continu
               #--- Je sauvegarde l'image
               if { $panneau(acqt1m,$visuNo,enregistrer) == "1" } {
                  $panneau(acqt1m,$visuNo,This).status.lab configure -text $caption(acqt1m,enreg)

                  set filenamelist [::acqt1m::get_filename $visuNo]
                  set nom   [lindex $filenamelist 1]
                  set bufNo [lindex $filenamelist 0]
                  #--- Pour eviter un nom de fichier qui commence par un blanc
                  set nom [lindex $nom 0]
                  #--- Verifie que le nom du fichier n'existe pas
                  set sauvegardeValidee "1"
                  if { $panneau(acqt1m,$visuNo,indexerContinue) == "1" } {
                     set nom1 "$nom"
                     append nom1 $panneau(acqt1m,$visuNo,index) $panneau(acqt1m,$visuNo,extension)
                     if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" &&  $panneau(acqt1m,$visuNo,verifier_ecraser_fichier) == 1} {
                        #--- Dans ce cas, le fichier existe deja...
                        set lastFile [ ::acqt1m::dernierFichier $visuNo ]
                        set confirmation [tk_messageBox -title $caption(acqt1m,conf) -type yesno \
                           -message "$caption(acqt1m,fichdeja_1) $lastFile $caption(acqt1m,fichdeja_2)"]
                        if { $confirmation == "no" } {
                           #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                           set sauvegardeValidee "0"
                           set panneau(acqt1m,$visuNo,demande_arret) "1"
                        }
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqt1m,$visuNo,sauve_img_interrompue) == "0" } {
                     #--- Sauvegarde de l'image
                     if { $panneau(acqt1m,$visuNo,indexerContinue) == "1" } {
                        saveima [append nom $panneau(acqt1m,$visuNo,index) $panneau(acqt1m,$visuNo,extension)] $visuNo
                     } else {
                        saveima [append nom $panneau(acqt1m,$visuNo,extension)] $visuNo
                     }
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqt1m,enrim) $heure $nom
                     if { $panneau(acqt1m,$visuNo,indexerContinue) == "1" } {
                        incr panneau(acqt1m,$visuNo,index)
                     }
                  }
               }
               #--- Deplacement du telescope
               ::DlgShiftt1m::decalageTelescope
            }
            4  {
               #--- Je sauvegarde l'image
               set filenamelist [::acqt1m::get_filename $visuNo]
               set nom   [lindex $filenamelist 1]
               set bufNo [lindex $filenamelist 0]
               #--- Pour eviter un nom de fichier qui commence par un blanc
               set nom [lindex $nom 0]
               if { $panneau(acqt1m,$visuNo,simulation) == "0" } {
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqt1m,$visuNo,index) $panneau(acqt1m,$visuNo,extension)
                  set sauvegardeValidee "1"
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" &&  $panneau(acqt1m,$visuNo,verifier_ecraser_fichier) == 1 } {
                     #--- Dans ce cas, le fichier existe deja...
                     set lastFile [ ::acqt1m::dernierFichier $visuNo ]
                     set confirmation [tk_messageBox -title $caption(acqt1m,conf) -type yesno \
                        -message "$caption(acqt1m,fichdeja_1) $lastFile $caption(acqt1m,fichdeja_2)"]
                     if { $confirmation == "no" } {
                        #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                        set sauvegardeValidee "0"
                        set panneau(acqt1m,$visuNo,demande_arret) "1"
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqt1m,$visuNo,sauve_img_interrompue) == "0" } {


                     #--- Derniere verif de l'image
                     set naxis1 [ lindex [ buf$bufNo getkwd NAXIS1 ] 1 ]
                     set naxis2 [ lindex [ buf$bufNo getkwd NAXIS2 ] 1 ]
                     if { [lsearch {2048 1024 682 512 } $naxis1] == -1 || [lsearch {2048 1024 682 512 } $naxis2] == -1 } {
                        ::console::affiche_erreur "NAXIS1 = $naxis1 NAXIS2 = $naxis2\n"
                     }



                     #--- Sauvegarde de l'image
                     saveima [append nom $panneau(acqt1m,$visuNo,index) $panneau(acqt1m,$visuNo,extension)] $visuNo
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqt1m,enrim) $heure $nom
                     incr panneau(acqt1m,$visuNo,index)
                  }
               }
               #---
               if { $panneau(acqt1m,$visuNo,demande_arret) == "0" } {
                  #--- Deplacement du telescope
                  ::DlgShiftt1m::decalageTelescope
                  if { $compteurImageSerie < $nbImages } {
                     #--- j'incremente le compteur d'image
                     incr compteurImageSerie
                  } else {
                     #--- j'attends que la fin de la temporisation entre 2 series
                     set panneau(acqt1m,$visuNo,attente_pose) "1"
                     set panneau(acqt1m,$visuNo,fin_im) [ clock second ]
                     set panneau(acqt1m,$visuNo,intervalle_im_1) [ expr $panneau(acqt1m,$visuNo,fin_im) - $panneau(acqt1m,$visuNo,deb_serie) ]
                     while { ( $panneau(acqt1m,$visuNo,demande_arret) == "0" ) && ( $panneau(acqt1m,$visuNo,intervalle_im_1) <= $panneau(acqt1m,$visuNo,intervalle_1) ) } {
                        after 500
                        set panneau(acqt1m,$visuNo,fin_im) [ clock second ]
                        set panneau(acqt1m,$visuNo,intervalle_im_1) [ expr $panneau(acqt1m,$visuNo,fin_im) - $panneau(acqt1m,$visuNo,deb_serie) + 1 ]
                        set t [ expr $panneau(acqt1m,$visuNo,intervalle_1) - $panneau(acqt1m,$visuNo,intervalle_im_1) ]
                        ::acqt1m::avancementPose $visuNo $t
                     }
                     set panneau(acqt1m,$visuNo,attente_pose) "0"
                     #--- Je note l'heure de debut des series suivantes (utile pour les series espacees)
                     set panneau(acqt1m,$visuNo,deb_serie) [ clock second ]
                     #--- je reinitalise le compteur d'image
                     set compteurImageSerie 1
                     #--- Je calcule le dernier index de la serie
                     set panneau(acqt1m,$visuNo,indexEndSerieContinu) [ expr $panneau(acqt1m,$visuNo,index) + $panneau(acqt1m,$visuNo,nb_images) - 1 ]
                     set panneau(acqt1m,$visuNo,indexEndSerieContinu) "$caption(acqt1m,dernierIndex) $panneau(acqt1m,$visuNo,indexEndSerieContinu)"
                  }
               }
            }
            5  {
               #--- Je sauvegarde l'image
               set filenamelist [::acqt1m::get_filename $visuNo]
               set nom   [lindex $filenamelist 1]
               set bufNo [lindex $filenamelist 0]
               #--- Pour eviter un nom de fichier qui commence par un blanc
               set nom [lindex $nom 0]
               if { $panneau(acqt1m,$visuNo,enregistrer) == "1" } {
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqt1m,$visuNo,index) $panneau(acqt1m,$visuNo,extension)
                  set sauvegardeValidee "1"
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" &&  $panneau(acqt1m,$visuNo,verifier_ecraser_fichier) == 1 } {
                     #--- Dans ce cas, le fichier existe deja...
                     set lastFile [ ::acqt1m::dernierFichier $visuNo ]
                     set confirmation [tk_messageBox -title $caption(acqt1m,conf) -type yesno \
                        -message "$caption(acqt1m,fichdeja_1) $lastFile $caption(acqt1m,fichdeja_2)"]
                     if { $confirmation == "no" } {
                        #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                        set sauvegardeValidee "0"
                        set panneau(acqt1m,$visuNo,demande_arret) "1"
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqt1m,$visuNo,sauve_img_interrompue) == "0" } {


                     #--- Derniere verif de l'image
                     set naxis1 [ lindex [ buf$bufNo getkwd NAXIS1 ] 1 ]
                     set naxis2 [ lindex [ buf$bufNo getkwd NAXIS2 ] 1 ]
                     if { [lsearch {2048 1024 682 512 } $naxis1] == -1 || [lsearch {2048 1024 682 512 } $naxis2] == -1 } {
                        ::console::affiche_erreur "NAXIS1 = $naxis1 NAXIS2 = $naxis2\n"
                     }



                     #--- Sauvegarde de l'image
                     saveima [append nom $panneau(acqt1m,$visuNo,index) $panneau(acqt1m,$visuNo,extension)] $visuNo
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqt1m,enrim) $heure $nom
                     incr panneau(acqt1m,$visuNo,index)
                  }
               }
               #---
               if { $panneau(acqt1m,$visuNo,demande_arret) == "0" } {
                  #--- Deplacement du telescope
                  ::DlgShiftt1m::decalageTelescope
                  set panneau(acqt1m,$visuNo,attente_pose) "1"
                  set panneau(acqt1m,$visuNo,fin_im) [ clock second ]
                  set panneau(acqt1m,$visuNo,intervalle_im_2) [ expr $panneau(acqt1m,$visuNo,fin_im) - $panneau(acqt1m,$visuNo,deb_im) ]
                  while { ( $panneau(acqt1m,$visuNo,demande_arret) == "0" ) && ( $panneau(acqt1m,$visuNo,intervalle_im_2) <= $panneau(acqt1m,$visuNo,intervalle_2) ) } {
                     after 500
                     set panneau(acqt1m,$visuNo,fin_im) [ clock second ]
                     set panneau(acqt1m,$visuNo,intervalle_im_2) [ expr $panneau(acqt1m,$visuNo,fin_im) - $panneau(acqt1m,$visuNo,deb_im) + 1 ]
                     set t [ expr $panneau(acqt1m,$visuNo,intervalle_2) - $panneau(acqt1m,$visuNo,intervalle_im_2) ]
                     ::acqt1m::avancementPose $visuNo $t
                  }
                  set panneau(acqt1m,$visuNo,attente_pose) "0"
               }
            }
         } ; #--- fin du switch d'acquisition

         #--- Je retablis le choix du fonctionnement de l'obturateur
         if { $panneau(acqt1m,$visuNo,pose) == "0" } {
            switch -exact -- $panneau(acqt1m,$visuNo,obt) {
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
         switch $panneau(acqt1m,$visuNo,mode) {
            1  {
               #--- je mets a jour le nom du fichier dans le titre de la fenetre et dans la fenetre des header
               ::confVisu::setFileName $visuNo ""
               #--- Deverrouille les boutons du mode "une image"
               $panneau(acqt1m,$visuNo,This).mode.une.index.case configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.une.index.entr configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.une.index.but configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.une.sauve configure -state normal
            }
            2  {
               #--- Mode serie
               #--- Fin de la derniere pose et intervalle mini entre 2 poses ou 2 series
               if { $panneau(acqt1m,$visuNo,simulation) == "1" } {
                  #--- Affichage de l'intervalle mini simule
                  set panneau(acqt1m,$visuNo,fin) [ clock second ]
                  set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
                  if { $exposure == $panneau(acqt1m,$visuNo,pose) } {
                     set panneau(acqt1m,$visuNo,intervalle) [ expr $panneau(acqt1m,$visuNo,fin) - $panneau(acqt1m,$visuNo,debut) ]
                  } else {
                     set panneau(acqt1m,$visuNo,intervalle) "...."
                  }
                  set simu1 "$caption(acqt1m,int_mini_serie) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
                  $panneau(acqt1m,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
                  #--- Je retablis les reglages initiaux
                  set panneau(acqt1m,$visuNo,simulation) "0"
                  set panneau(acqt1m,$visuNo,mode)       "4"
                  set panneau(acqt1m,$visuNo,index)      $panneau(acqt1m,$visuNo,index_temp)
                  set panneau(acqt1m,$visuNo,nb_images)  $panneau(acqt1m,$visuNo,nombre_temp)
                  #--- Fin de la simulation
                  Message $visuNo consolog $caption(acqt1m,fin_simu)
               } elseif { $panneau(acqt1m,$visuNo,simulation) == "2" } {
                  #--- Affichage de l'intervalle mini simule
                  set panneau(acqt1m,$visuNo,fin) [ clock second ]
                  set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
                  if { $exposure == $panneau(acqt1m,$visuNo,pose) } {
                     set panneau(acqt1m,$visuNo,intervalle) [ expr $panneau(acqt1m,$visuNo,fin) - $panneau(acqt1m,$visuNo,debut) ]
                  } else {
                     set panneau(acqt1m,$visuNo,intervalle) "...."
                  }
                  set simu2 "$caption(acqt1m,int_mini_image) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
                  $panneau(acqt1m,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
                  #--- Je retablis les reglages initiaux
                  set panneau(acqt1m,$visuNo,simulation) "0"
                  set panneau(acqt1m,$visuNo,mode)       "5"
                  set panneau(acqt1m,$visuNo,index)      $panneau(acqt1m,$visuNo,index_temp)
                  set panneau(acqt1m,$visuNo,nb_images)  $panneau(acqt1m,$visuNo,nombre_temp)
                  #--- Fin de la simulation
                  Message $visuNo consolog $caption(acqt1m,fin_simu)
               }
               #--- Deverrouille les boutons du mode "serie"
               $panneau(acqt1m,$visuNo,This).mode.serie.nb.entr configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.serie.index.entr configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.serie.index.but configure -state normal
            }
            3  {
               #--- Mode continu
               #--- Deverrouille les boutons du mode "continu"
               $panneau(acqt1m,$visuNo,This).mode.continu.sauve.case configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.continu.index.case configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.continu.index.entr configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.continu.index.but configure -state normal
            }
            4  {
               #--- Mode continu
               #--- Deverrouille les boutons du mode "continu 1"
               $panneau(acqt1m,$visuNo,This).mode.serie_1.nb.entr configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.serie_1.index.entr configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.serie_1.index.but configure -state normal
            }
            5 {
               #--- Deverrouille les boutons du mode "continu 2"
               $panneau(acqt1m,$visuNo,This).mode.continu_1.sauve.case configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.continu_1.index.entr configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.continu_1.index.but configure -state normal
            }
         } ; #--- fin du switch de deverrouillage
   }] ; #--- fin du catch

   if { $catchResult == 1 } {
      ::tkutil::displayErrorInfo $caption(acqt1m,titre)
      #--- J'arrete la capture de l'image
      ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
   }

   #--- Pose en cours
   set panneau(acqt1m,$visuNo,pose_en_cours) "0"

   set panneau(acqt1m,$visuNo,demande_arret) 0
   #--- Effacement de la barre de progression quand la pose est terminee
   ::acqt1m::avancementPose $visuNo -1
   $panneau(acqt1m,$visuNo,This).status.lab configure -text ""
   #--- Deverrouille tous les boutons et champs de texte pendant les acquisitions
   $panneau(acqt1m,$visuNo,This).pose.but configure -state normal
   $panneau(acqt1m,$visuNo,This).pose.entr configure -state normal
   $panneau(acqt1m,$visuNo,This).binningt.but configure -state normal
   $panneau(acqt1m,$visuNo,This).obt.but configure -state normal
   $panneau(acqt1m,$visuNo,This).mode.but configure -state normal
   #--- Je restitue l'affichage du bouton "GO"
   $panneau(acqt1m,$visuNo,This).go_stop.but configure -text $caption(acqt1m,GO) -state normal -command "::acqt1m::Go $visuNo"
   #--- je positionne l'indateur de fin d'acquisition (pour startAcquisitionSerieImage)
   set ::panneau(acqt1m,$visuNo,acqImageEnd) "1"
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
proc ::acqt1m::callbackAcquisition { visuNo message args } {

   switch $message {
      "autovisu" {
         #--- ce message signale que l'image est prete dans le buffer
         #--- on peut l'afficher sans attendre la fin complete de la thread de la camera
         ::confVisu::autovisu $visuNo
      }
      "acquisitionResult" {
         #--- ce message signale que la thread de la camera a termine completement l'acquisition
         #--- je peux traiter l'image
         set ::panneau(acqt1m,$visuNo,acquisitionState) "acquisitionResult"
      }
      "error" {
         #--- ce message signale qu'une erreur est survenue dans la thread de la camera
         #--- j'affiche l'erreur dans la console
         ::console::affiche_erreur "acqt1m::acq error: $args\n"
         set ::panneau(acqt1m,$visuNo,acquisitionState) "error"
      }
   }
}

















#------------------------------------------------------------
# Stop
#     appui sur le bouton Go/Stop
#
# Parameters
#  visuNo  : numero de la visu associee a la camera
#
# Return
#    rien
#------------------------------------------------------------
proc ::acqt1m::Stop { visuNo } {
   global audace caption panneau

   set ::cycle::stop 1

   #--- Je desactive le bouton "STOP"
   $panneau(acqt1m,$visuNo,This).go_stop.but configure -state disabled

   #--- j'interromps la pose
   if { $panneau(acqt1m,$visuNo,mode) == "1" } {
      #--- Je positionne l'indicateur d'interruption de pose
      set panneau(acqt1m,$visuNo,demande_arret) "1"
      #--- On annule la sonnerie
      catch { after cancel $audace(after,bell,id) }
      #--- Annulation de l'alarme de fin de pose
      catch { after cancel bell }
      #--- J'arrete la capture de l'image
      ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
   } else {
      if { $panneau(acqt1m,$visuNo,enregistrer_acquisiton_interrompue) == 1 } {
         if { [cam$panneau(acqt1m,$visuNo,camNo) timer -1 ] > 10 } {
             #--- s'il reste plus de 10 seconde , je demande si on interromp la pose courante
             set choix [ tk_messageBox -title $caption(acqt1m,serie) -type yesno -icon info \
                 -message $caption(acqt1m,arret_serie) \
             ]
            if { $choix == "no" } {
               #--- Je positionne l'indicateur d'interruption de pose
               set panneau(acqt1m,$visuNo,demande_arret) "1"
               #--- Je positionne l'indicateur d'enregistrement d'image interrompue
               set panneau(acqt1m,$visuNo,sauve_img_interrompue) "1"
               #--- On annule la sonnerie
               catch { after cancel $audace(after,bell,id) }
               #--- Annulation de l'alarme de fin de pose
               catch { after cancel bell }
               #--- J'arrete l'acquisition courante
               ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
            } else {
               #--- Je positionne l'indicateur d'interruption de pose a 1 s de la fin de la pose
               ::acqt1m::stopSerie $visuNo
               #--- Je positionne l'indicateur d'enregistrement d'image interrompue
               set panneau(acqt1m,$visuNo,sauve_img_interrompue) "0"
            }
         } else {
            #--- Je positionne l'indicateur d'interruption de pose a 1 s de la fin de la pose
            ::acqt1m::stopSerie $visuNo
            #--- s'il reste moins de 10 secondes, je ne pose pas de question a l'utilisateur
            #--- la serie s'arretera a la fin de l'image en cours
            set panneau(acqt1m,$visuNo,sauve_img_interrompue) "0"
         }
      } else {
         #--- Je positionne l'indicateur d'interruption de pose
         set panneau(acqt1m,$visuNo,demande_arret) "1"
         #--- Je positionne l'indicateur d'enregistrement d'image interrompue
         set panneau(acqt1m,$visuNo,sauve_img_interrompue) "1"
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
proc ::acqt1m::stopSerie { visuNo } {
   global panneau

   set t [cam$panneau(acqt1m,$visuNo,camNo) timer -1 ]
   if { $t > 1 } {
      #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
      #--- (mode asynchone pour eviter l'empilement des appels recursifs)
      set valeur [after 1000 ::acqt1m::stopSerie $visuNo]
   } else {
      #--- je ne relance pas le timer et j'arrete la pose
      set panneau(acqt1m,$visuNo,demande_arret) "1"
   }
}
#***** Fin de la procedure arret de la serie *******************

















proc ::acqt1m::dispTime { visuNo } {
   global caption panneau

   #--- j'arrete le timer s'il est deja lance
   if { [info exists panneau(acqt1m,$visuNo,dispTimeAfterId)] && $panneau(acqt1m,$visuNo,dispTimeAfterId)!="" } {
      after cancel $panneau(acqt1m,$visuNo,dispTimeAfterId)
      set panneau(acqt1m,$visuNo,dispTimeAfterId) ""
   }

   set t [cam$panneau(acqt1m,$visuNo,camNo) timer -1 ]
   #--- je mets a jour le status
   if { $panneau(acqt1m,$visuNo,pose_en_cours) == 0 } {
      #--- je supprime la fenetre s'il n'y a plus de pose en cours
      set status ""
   } else {
      if { $panneau(acqt1m,$visuNo,attente_pose) == "0" } {
         if { $panneau(acqt1m,$visuNo,demande_arret) == "0" } {
            if { [expr $t > 0] } {
               set status "[ expr $t ] / [ format "%d" [ expr int($panneau(acqt1m,$visuNo,pose)) ] ]"
            } else {
               set status "$caption(acqt1m,lect)"
            }
         } else {
            set status "$caption(acqt1m,lect)"
         }
      } else {
         set status $caption(acqt1m,attente)
      }
   }
   $panneau(acqt1m,$visuNo,This).status.lab configure -text $status
   update

   #--- je mets a jour la fenetre de progression
   ::acqt1m::avancementPose $visuNo $t

   if { $t > 0 } {
      #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
      #--- (mode asynchone pour eviter l'empilement des appels recursifs)
      set panneau(acqt1m,$visuNo,dispTimeAfterId) [after 1000 ::acqt1m::dispTime $visuNo]
   } else {
      #--- je ne relance pas le timer
      set panneau(acqt1m,$visuNo,dispTimeAfterId) ""
   }
}

















#***** Procedure d'affichage d'une barre de progression ********
proc ::acqt1m::avancementPose { visuNo { t } } {
   global caption color panneau

   if { $panneau(acqt1m,$visuNo,avancement_acq) != "1" } {
      return
   }

   #--- Recuperation de la position de la fenetre
   ::acqt1m::recup_position_1 $visuNo

   #--- Initialisation de la barre de progression
   set cpt "100"

   #---
   if { [ winfo exists $panneau(acqt1m,$visuNo,base).progress ] != "1" } {

      #--- Cree la fenetre toplevel
      toplevel $panneau(acqt1m,$visuNo,base).progress
      wm transient $panneau(acqt1m,$visuNo,base).progress $panneau(acqt1m,$visuNo,base)
      wm resizable $panneau(acqt1m,$visuNo,base).progress 0 0
      wm title $panneau(acqt1m,$visuNo,base).progress "$caption(acqt1m,en_cours)"
      wm geometry $panneau(acqt1m,$visuNo,base).progress $panneau(acqt1m,$visuNo,avancement,position)

      #--- Cree le widget et le label du temps ecoule
      label $panneau(acqt1m,$visuNo,base).progress.lab_status -text "" -justify center
      pack $panneau(acqt1m,$visuNo,base).progress.lab_status -side top -fill x -expand true -pady 5

      #---
      if { $panneau(acqt1m,$visuNo,attente_pose) == "0" } {
         if { $panneau(acqt1m,$visuNo,demande_arret) == "1" && $panneau(acqt1m,$visuNo,mode) != "2" && $panneau(acqt1m,$visuNo,mode) != "4" } {
            $panneau(acqt1m,$visuNo,base).progress.lab_status configure -text $caption(acqt1m,lect)
         } else {
            if { $t < 0 } {
               destroy $panneau(acqt1m,$visuNo,base).progress
            } elseif { $t > 0 } {
               $panneau(acqt1m,$visuNo,base).progress.lab_status configure -text "$t $caption(acqt1m,sec) /\
                  [ format "%d" [ expr int( $panneau(acqt1m,$visuNo,pose) ) ] ] $caption(acqt1m,sec)"
               set cpt [ expr $t * 100 / int( $panneau(acqt1m,$visuNo,pose) ) ]
               set cpt [ expr 100 - $cpt ]
            } else {
               $panneau(acqt1m,$visuNo,base).progress.lab_status configure -text "$caption(acqt1m,lect)"
           }
         }
      } else {
         if { $panneau(acqt1m,$visuNo,demande_arret) == "0" } {
            if { $t < 0 } {
               destroy $panneau(acqt1m,$visuNo,base).progress
            } else {
               if { $panneau(acqt1m,$visuNo,mode) == "4" } {
                  $panneau(acqt1m,$visuNo,base).progress.lab_status configure -text "$caption(acqt1m,attente) [ expr $t + 1 ]\
                     $caption(acqt1m,sec) / $panneau(acqt1m,$visuNo,intervalle_1) $caption(acqt1m,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqt1m,$visuNo,intervalle_1) ]
               } elseif { $panneau(acqt1m,$visuNo,mode) == "5" } {
                  $panneau(acqt1m,$visuNo,base).progress.lab_status configure -text "$caption(acqt1m,attente) [ expr $t + 1 ]\
                     $caption(acqt1m,sec) / $panneau(acqt1m,$visuNo,intervalle_2) $caption(acqt1m,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqt1m,$visuNo,intervalle_2) ]
               }
               set cpt [ expr 100 - $cpt ]
            }
         }
      }

      catch {
         #--- Cree le widget pour la barre de progression
         frame $panneau(acqt1m,$visuNo,base).progress.cadre -width 200 -height 30 -borderwidth 2 -relief groove
         pack $panneau(acqt1m,$visuNo,base).progress.cadre -in $panneau(acqt1m,$visuNo,base).progress -side top \
            -anchor center -fill x -expand true -padx 8 -pady 8

         #--- Affiche de la barre de progression
         frame $panneau(acqt1m,$visuNo,base).progress.cadre.barre_color_invariant -height 26 -bg $color(blue)
         place $panneau(acqt1m,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(acqt1m,$visuNo,base).progress.cadre -x 0 -y 0 \
            -relwidth [ expr $cpt / 100.0 ]
         update
      }

      #--- Mise a jour dynamique des couleurs
      if { [ winfo exists $panneau(acqt1m,$visuNo,base).progress ] == "1" } {
         ::confColor::applyColor $panneau(acqt1m,$visuNo,base).progress
      }

   } else {

      if { $panneau(acqt1m,$visuNo,pose_en_cours) == 0 } {
         #--- je supprime la fenetre s'il n'y a plus de pose en cours
         destroy $panneau(acqt1m,$visuNo,base).progress
      } else {
         if { $panneau(acqt1m,$visuNo,attente_pose) == "0" } {
            if { $panneau(acqt1m,$visuNo,demande_arret) == "0" } {
               if { $t > 0 } {
                  $panneau(acqt1m,$visuNo,base).progress.lab_status configure -text "[ expr $t ] $caption(acqt1m,sec) /\
                     [ format "%d" [ expr int( $panneau(acqt1m,$visuNo,pose) ) ] ] $caption(acqt1m,sec)"
                  set cpt [ expr $t * 100 / int( $panneau(acqt1m,$visuNo,pose) ) ]
                 set cpt [ expr 100 - $cpt ]
               } else {
                  $panneau(acqt1m,$visuNo,base).progress.lab_status configure -text "$caption(acqt1m,lect)"
               }
            } else {
               #--- j'affiche "lecture" des qu'une demande d'arret est demandee
               $panneau(acqt1m,$visuNo,base).progress.lab_status configure -text "$caption(acqt1m,lect)"
            }
         } else {
            if { $panneau(acqt1m,$visuNo,demande_arret) == "0" } {
               if { $panneau(acqt1m,$visuNo,mode) == "4" } {
                  $panneau(acqt1m,$visuNo,base).progress.lab_status configure -text "$caption(acqt1m,attente) [ expr $t + 1 ]\
                     $caption(acqt1m,sec) / $panneau(acqt1m,$visuNo,intervalle_1) $caption(acqt1m,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqt1m,$visuNo,intervalle_1) ]
               } elseif { $panneau(acqt1m,$visuNo,mode) == "5" } {
                  $panneau(acqt1m,$visuNo,base).progress.lab_status configure -text "$caption(acqt1m,attente) [ expr $t + 1 ]\
                     $caption(acqt1m,sec) / $panneau(acqt1m,$visuNo,intervalle_2) $caption(acqt1m,sec)"
                  set cpt [ expr $t * 100 / $panneau(acqt1m,$visuNo,intervalle_2) ]
               }
               set cpt [ expr 100 - $cpt ]
            }
         }

         #--- Met a jour la barre de progression
         place $panneau(acqt1m,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(acqt1m,$visuNo,base).progress.cadre -x 0 -y 0 \
            -relwidth [ expr $cpt / 100.0 ]
         update
      }

   }

}
#***** Fin de la procedure d'avancement de la pose *************



















#*********** Procedure dernier fichier d'une liste *************
proc ::acqt1m::dernierFichier { visuNo } {
   global panneau

   #--- Liste par ordre croissant les index du nom generique
   set a [ lsort -integer [ liste_index $panneau(acqt1m,$visuNo,object) ] ]
   set b [ llength $a ]
   #--- Extrait le dernier index de la liste
   set c [ lindex $a [ expr $b - 1 ] ]
   #--- Retourne le dernier fichier de la liste
   set d $panneau(acqt1m,$visuNo,object)$c$panneau(acqt1m,$visuNo,extension)
   return $d
}
#****Fin de la procedure dernier fichier d'une liste ***********




















proc ::acqt1m::get_filename { visuNo } {

   global panneau audace

   set bufNo [ visu$visuNo buf ]
   set key [ buf$bufNo getkwd "DATE-OBS" ]
   set iso [lindex $key 1]
   set ctrl [ scan $iso "%4s-%2s-%2sT%2s:%2s:%2s.%3s" a m j h min sec ms ]

   set obj [string trim [string tolower $panneau(acqt1m,$visuNo,object)] ]
   set filtre $panneau(acqt1m,$visuNo,filtrecourant)
   set bin $panneau(acqt1m,$visuNo,binning)

   switch $obj {
      "flat" -
      "plat"   {
               set type "FLAT"
               set object "FLAT"
               set dirfinal "CALIB/"
               }
      "offset" -
      "bias"   {
               set type "OFFSET"
               set object "OFFSET"
               set dirfinal "CALIB/"
               set filtre "none"
               }
      "dark" -
      "noir"   {
               set type "DARK"
               set object "DARK"
               set dirfinal "CALIB/"
               set filtre "none"
               }
      default  {
               set type "IMG"
               set object [string trim $panneau(acqt1m,$visuNo,object)]
               set dirfinal ""
               }
   }

   buf$bufNo setkwd [list "TELESCOP" "t1m" string "Telescop name" ""]
   buf$bufNo setkwd [list "FILTER" $filtre string "Filter used" ""]
   buf$bufNo setkwd [list "OBJECT" $object string "Name or catalog number of object being imaged" ""]
   buf$bufNo setkwd [list "CCDGAIN" "4.8" float "CCD gain" "electrons/adu"]

   if {$panneau(acqt1m,$visuNo,ra)!=""} {
      set ra [mc_angle2deg "$panneau(acqt1m,$visuNo,ra) h"]
      buf$bufNo setkwd [list "RA" $ra double "Right Ascension" "degrees"]
   }
   if {$panneau(acqt1m,$visuNo,dec)!=""} {
      set dec [mc_angle2deg $panneau(acqt1m,$visuNo,dec)]
      buf$bufNo setkwd [list "DEC" $dec double "Declination" "degrees"]
   }

   # hauteur du soleil
   set t [lindex [mc_ephem sun now -equinox apparent] 0]
   set sunelev [lindex [mc_radec2altaz [lindex $t 1] [lindex $t 2] $audace(posobs,observateur,gps) now] 1]
   #gren_info "Sun Elev = [mc_angle2dms $sunelev 90 zero 2]\n"
   buf$bufNo setkwd [list "SUNELEV" $sunelev float "Sun Elevation" "degrees"]


   if {$panneau(acqt1m,$visuNo,launchastroid) && $type=="IMG"} {
       ::t1mastroid::astroid_acqu $visuNo
   }


   # Champs BDDIMAGES
   ::bddimagesAdmin::bdi_setcompat $bufNo
   set key [buf$bufNo getkwd "BDDIMAGES STATE"]
   set key [lreplace $key 1 1 "RAW"]
   buf$bufNo setkwd $key

   set key [buf$bufNo getkwd "BDDIMAGES TYPE"]
   set key [lreplace $key 1 1 $type]
   buf$bufNo setkwd $key

   if {$dirfinal!=""} {
      set rep [ file join $::audace(rep_images) "CALIB" ]
      if { [file exists $rep]==0} {
         if { [ catch {file mkdir $rep} msg] } {
             ::console::affiche_erreur "$::caption(acqt1m_flatcielplus,msgRepertoire) $rep/n"
         }
      }
   }

   #--- Generer le nom du fichier
   return [list $bufNo \
                "${dirfinal}T1M_${a}${m}${j}_${h}${min}${sec}_${ms}_${object}_Filtre_${filtre}_bin${bin}"\
                ]
}




















#***** Procedure de sauvegarde de l'image **********************
#--- Procedure lancee par appui sur le bouton "enregistrer", uniquement dans le mode "Une image"
proc ::acqt1m::SauveUneImage { visuNo } {
   global audace caption panneau

   #--- Tests d'integrite de la requete
   #--- Verifier qu'il y a bien un nom de fichier
   if { $panneau(acqt1m,$visuNo,object) == "" } {
      tk_messageBox -title $caption(acqt1m,pb) -type ok \
         -message $caption(acqt1m,donnomfich)
      return
   }
   #--- Verifier que le nom de fichier n'a pas d'espace
   if { [ llength $panneau(acqt1m,$visuNo,object) ] > "1" } {
      tk_messageBox -title $caption(acqt1m,pb) -type ok \
         -message $caption(acqt1m,nomblanc)
      return
   }
   #--- Si la case index est cochee, verifier qu'il y a bien un index
   if { $panneau(acqt1m,$visuNo,indexer) == "1" } {
      #--- Verifier que l'index existe
      if { $panneau(acqt1m,$visuNo,index) == "" } {
         tk_messageBox -title $caption(acqt1m,pb) -type ok \
            -message $caption(acqt1m,saisind)
         return
      }
   }

   #--- Generer le nom du fichier et Charge l image dans le buffer
   set filenamelist [::acqt1m::get_filename $visuNo]
   set nom   [lindex $filenamelist 1]
   set bufNo [lindex $filenamelist 0]

   ::console::affiche_resultat "nom = $nom\n"

   #--- Pour eviter un nom de fichier qui commence par un blanc
   set nom [lindex $nom 0]
   if { $panneau(acqt1m,$visuNo,indexer) == "1" } {
      append nom ".$panneau(acqt1m,$visuNo,index)"
   }

   #--- Verifier que le nom du fichier n'existe pas
   set nom1 "$nom"
   append nom1 $panneau(acqt1m,$visuNo,extension)
   if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" &&  $panneau(acqt1m,$visuNo,verifier_ecraser_fichier) == 1 } {
      #--- Dans ce cas, le fichier existe deja...
      set lastFile [ ::acqt1m::dernierFichier $visuNo ]
      set confirmation [tk_messageBox -title $caption(acqt1m,conf) -type yesno \
         -message "$caption(acqt1m,fichdeja_1) $lastFile $caption(acqt1m,fichdeja_2)"]
      if { $confirmation == "no" } {
         return
      }
   }

   #--- Incrementer l'index
   if { $panneau(acqt1m,$visuNo,indexer) == "1" } {
      if { [ buf$bufNo imageready ] != "0" } {
         incr panneau(acqt1m,$visuNo,index)
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

   #--- Derniere verif de l'image
   set naxis1 [ lindex [ buf$bufNo getkwd NAXIS1 ] 1 ]
   set naxis2 [ lindex [ buf$bufNo getkwd NAXIS2 ] 1 ]
   if { [lsearch {2048 1024 682 512 } $naxis1] == -1 || [lsearch {2048 1024 682 512 } $naxis2] == -1 } {
      ::console::affiche_erreur "NAXIS1 = $naxis1 NAXIS2 = $naxis2\n"
   }



   #--- Sauvegarde de l'image
   saveima [append nom $panneau(acqt1m,$visuNo,extension)] $visuNo
   #--- Indique l'heure d'enregistrement dans le fichier log
   set heure $audace(tu,format,hmsint)
   Message $visuNo consolog $caption(acqt1m,demsauv) $heure
   Message $visuNo consolog $caption(acqt1m,imsauvnom) $nom
}
#***** Fin de la procedure de sauvegarde de l'image *************




















#***** Procedure d'affichage des messages ************************
#--- Cette procedure est recopiee de methking.tcl, elle permet l'affichage de differents
#--- messages (dans la console, le fichier log, etc.)
proc ::acqt1m::Message { visuNo niveau args } {
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
            puts -nonewline $::acqt1m::log_id($visuNo) [eval [concat {format} $args]]
            #--- Force l'ecriture immediate sur le disque
            flush $::acqt1m::log_id($visuNo)
         }
      }
      consolog {
         if { $panneau(acqt1m,$visuNo,messages) == "1" } {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         set temps [clock format [clock seconds] -format %H:%M:%S]
         append temps " "
         catch {
            puts -nonewline $::acqt1m::log_id($visuNo) [eval [concat {format} $args]]
            #--- Force l'ecriture immediate sur le disque
            flush $::acqt1m::log_id($visuNo)
         }
      }
      default {
         set b [ list "%s\n" $caption(acqt1m,pbmesserr) ]
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
proc ::acqt1m::cmdShiftConfig { visuNo } {
   global audace

   set shiftConfig [ ::DlgShiftt1m::run $visuNo $audace(base).dlgShiftt1m ]
   return
}
#***** Fin du bouton pour le decalage du telescope *****************




















#***** Fenetre de configuration series d'images a intervalle regulier en continu *********
proc ::acqt1m::Intervalle_continu_1 { visuNo } {
   global caption conf panneau

   set panneau(acqt1m,$visuNo,intervalle)            "...."
   set panneau(acqt1m,$visuNo,simulation_deja_faite) "0"

   ::acqt1m::recup_position $visuNo

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(acqt1m,continu1,position) ] } { set conf(acqt1m,continu1,position) "+120+260" }

   #--- Creation de la fenetre Continu 1
   toplevel $panneau(acqt1m,$visuNo,base).intervalle_continu_1
   wm transient $panneau(acqt1m,$visuNo,base).intervalle_continu_1 $panneau(acqt1m,$visuNo,base)
   wm resizable $panneau(acqt1m,$visuNo,base).intervalle_continu_1 0 0
   wm title $panneau(acqt1m,$visuNo,base).intervalle_continu_1 "$caption(acqt1m,continu_1)"
   wm geometry $panneau(acqt1m,$visuNo,base).intervalle_continu_1 $conf(acqt1m,continu1,position)
   wm protocol $panneau(acqt1m,$visuNo,base).intervalle_continu_1 WM_DELETE_WINDOW " \
      set panneau(acqt1m,$visuNo,mode_en_cours) \"$caption(acqt1m,continu_1)\" \
   "

   #--- Create the message
   label $panneau(acqt1m,$visuNo,base).intervalle_continu_1.lab1 -text "$caption(acqt1m,titre_1)"
   pack $panneau(acqt1m,$visuNo,base).intervalle_continu_1.lab1 -padx 20 -pady 5

   frame $panneau(acqt1m,$visuNo,base).intervalle_continu_1.a
      label $panneau(acqt1m,$visuNo,base).intervalle_continu_1.a.lab2 -text "$caption(acqt1m,intervalle_1)"
      pack $panneau(acqt1m,$visuNo,base).intervalle_continu_1.a.lab2 -anchor center -expand 1 -fill none -side left \
         -padx 10 -pady 5
      entry $panneau(acqt1m,$visuNo,base).intervalle_continu_1.a.ent1 -width 5 -relief groove \
         -textvariable panneau(acqt1m,$visuNo,intervalle_1) -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $panneau(acqt1m,$visuNo,base).intervalle_continu_1.a.ent1 -anchor center -expand 1 -fill none -side left \
         -padx 10
   pack $panneau(acqt1m,$visuNo,base).intervalle_continu_1.a -padx 10 -pady 5

   frame $panneau(acqt1m,$visuNo,base).intervalle_continu_1.b
      checkbutton $panneau(acqt1m,$visuNo,base).intervalle_continu_1.b.check_simu \
         -text "$caption(acqt1m,simu_deja_faite)" \
         -variable panneau(acqt1m,$visuNo,simulation_deja_faite) -command "::acqt1m::Simu_deja_faite_1 $visuNo"
      pack $panneau(acqt1m,$visuNo,base).intervalle_continu_1.b.check_simu -anchor w -expand 1 -fill none \
         -side left -padx 10 -pady 5
   pack $panneau(acqt1m,$visuNo,base).intervalle_continu_1.b -side bottom -anchor w -padx 10 -pady 5

   button $panneau(acqt1m,$visuNo,base).intervalle_continu_1.but1 -text "$caption(acqt1m,simulation)" \
      -command "::acqt1m::Command_continu_1 $visuNo"
   pack $panneau(acqt1m,$visuNo,base).intervalle_continu_1.but1 -anchor center -expand 1 -fill none -side left \
      -ipadx 5 -ipady 3 -padx 10 -pady 5

   set simu1 "$caption(acqt1m,int_mini_serie) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
   label $panneau(acqt1m,$visuNo,base).intervalle_continu_1.lab3 -text "$simu1"
   pack $panneau(acqt1m,$visuNo,base).intervalle_continu_1.lab3 -anchor center -expand 1 -fill none -side left -padx 10

   #--- New message window is on
   focus $panneau(acqt1m,$visuNo,base).intervalle_continu_1

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $panneau(acqt1m,$visuNo,base).intervalle_continu_1
}
#***** Fin fenetre de configuration series d'images a intervalle regulier en continu *****




















#***** Commande associee au bouton simulation de la fenetre Continu (1) ******************
proc ::acqt1m::Command_continu_1 { visuNo } {
   global caption panneau

   set panneau(acqt1m,$visuNo,intervalle) "...."
   set simu1 "$caption(acqt1m,int_mini_serie) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
   $panneau(acqt1m,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
   set panneau(acqt1m,$visuNo,simulation)  "1"
   set panneau(acqt1m,$visuNo,mode)        "2"
   set panneau(acqt1m,$visuNo,index_temp)  $panneau(acqt1m,$visuNo,index)
   set panneau(acqt1m,$visuNo,nombre_temp) $panneau(acqt1m,$visuNo,nb_images)
   ::acqt1m::Go $visuNo
}
#***** Fin de la commande associee au bouton simulation de la fenetre Continu (1) ********




















#***** Si une simulation a deja ete faite pour la fenetre Continu (1) ********************
proc ::acqt1m::Simu_deja_faite_1 { visuNo } {
   global caption panneau

   if { $panneau(acqt1m,$visuNo,simulation_deja_faite) == "1" } {
      set panneau(acqt1m,$visuNo,intervalle) "xxxx"
      $panneau(acqt1m,$visuNo,base).intervalle_continu_1.lab3 configure \
         -text "$caption(acqt1m,int_mini_serie) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
      focus $panneau(acqt1m,$visuNo,base).intervalle_continu_1.a.ent1
   } else {
      set panneau(acqt1m,$visuNo,intervalle) "...."
      $panneau(acqt1m,$visuNo,base).intervalle_continu_1.lab3 configure \
         -text "$caption(acqt1m,int_mini_serie) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
      focus $panneau(acqt1m,$visuNo,base).intervalle_continu_1.but1
   }
}
#***** Fin de si une simulation a deja ete faite pour la fenetre Continu (1) *************




















#***** Fenetre de configuration images a intervalle regulier en continu ******************
proc ::acqt1m::Intervalle_continu_2 { visuNo } {
   global caption conf panneau

   set panneau(acqt1m,$visuNo,intervalle)            "...."
   set panneau(acqt1m,$visuNo,simulation_deja_faite) "0"

   ::acqt1m::recup_position $visuNo

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(acqt1m,continu2,position) ] } { set conf(acqt1m,continu2,position) "+120+260" }

   #--- Creation de la fenetre Continu 2
   toplevel $panneau(acqt1m,$visuNo,base).intervalle_continu_2
   wm transient $panneau(acqt1m,$visuNo,base).intervalle_continu_2 $panneau(acqt1m,$visuNo,base)
   wm resizable $panneau(acqt1m,$visuNo,base).intervalle_continu_2 0 0
   wm title $panneau(acqt1m,$visuNo,base).intervalle_continu_2 "$caption(acqt1m,continu_2)"
   wm geometry $panneau(acqt1m,$visuNo,base).intervalle_continu_2 $conf(acqt1m,continu2,position)
   wm protocol $panneau(acqt1m,$visuNo,base).intervalle_continu_2 WM_DELETE_WINDOW " \
      set panneau(acqt1m,$visuNo,mode_en_cours) \"$caption(acqt1m,continu_2)\" \
   "

   #--- Create the message
   label $panneau(acqt1m,$visuNo,base).intervalle_continu_2.lab1 -text "$caption(acqt1m,titre_2)"
   pack $panneau(acqt1m,$visuNo,base).intervalle_continu_2.lab1 -padx 10 -pady 5

   frame $panneau(acqt1m,$visuNo,base).intervalle_continu_2.a
      label $panneau(acqt1m,$visuNo,base).intervalle_continu_2.a.lab2 -text "$caption(acqt1m,intervalle_2)"
      pack $panneau(acqt1m,$visuNo,base).intervalle_continu_2.a.lab2 -anchor center -expand 1 -fill none -side left \
         -padx 10 -pady 5
      entry $panneau(acqt1m,$visuNo,base).intervalle_continu_2.a.ent1 -width 5 -relief groove \
         -textvariable panneau(acqt1m,$visuNo,intervalle_2) -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $panneau(acqt1m,$visuNo,base).intervalle_continu_2.a.ent1 -anchor center -expand 1 -fill none -side left \
         -padx 10
   pack $panneau(acqt1m,$visuNo,base).intervalle_continu_2.a -padx 10 -pady 5

   frame $panneau(acqt1m,$visuNo,base).intervalle_continu_2.b
      checkbutton $panneau(acqt1m,$visuNo,base).intervalle_continu_2.b.check_simu \
         -text "$caption(acqt1m,simu_deja_faite)" \
         -variable panneau(acqt1m,$visuNo,simulation_deja_faite) -command "::acqt1m::Simu_deja_faite_2 $visuNo"
      pack $panneau(acqt1m,$visuNo,base).intervalle_continu_2.b.check_simu -anchor w -expand 1 -fill none \
         -side left -padx 10 -pady 5
   pack $panneau(acqt1m,$visuNo,base).intervalle_continu_2.b -side bottom -anchor w -padx 10 -pady 5

   button $panneau(acqt1m,$visuNo,base).intervalle_continu_2.but1 -text "$caption(acqt1m,simulation)" \
      -command "::acqt1m::Command_continu_2 $visuNo"
   pack $panneau(acqt1m,$visuNo,base).intervalle_continu_2.but1 -anchor center -expand 1 -fill none -side left \
      -ipadx 5 -ipady 3 -padx 10 -pady 5

   set simu2 "$caption(acqt1m,int_mini_image) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
   label $panneau(acqt1m,$visuNo,base).intervalle_continu_2.lab3 -text "$simu2"
   pack $panneau(acqt1m,$visuNo,base).intervalle_continu_2.lab3 -anchor center -expand 1 -fill none -side left -padx 10

   #--- New message window is on
   focus $panneau(acqt1m,$visuNo,base).intervalle_continu_2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $panneau(acqt1m,$visuNo,base).intervalle_continu_2
}
#***** Fin fenetre de configuration images a intervalle regulier en continu **************




















#***** Commande associee au bouton simulation de la fenetre Continu (2) ******************
proc ::acqt1m::Command_continu_2 { visuNo } {
   global caption panneau

   set panneau(acqt1m,$visuNo,intervalle) "...."
   set simu2 "$caption(acqt1m,int_mini_image) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
   $panneau(acqt1m,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
   set panneau(acqt1m,$visuNo,simulation)  "2"
   set panneau(acqt1m,$visuNo,mode)        "2"
   set panneau(acqt1m,$visuNo,index_temp)  $panneau(acqt1m,$visuNo,index)
   set panneau(acqt1m,$visuNo,nombre_temp) $panneau(acqt1m,$visuNo,nb_images)
   set panneau(acqt1m,$visuNo,nb_images)   "1"
   ::acqt1m::Go $visuNo
}
#***** Fin de la commande associee au bouton simulation de la fenetre Continu (2) ********




















#***** Si une simulation a deja ete faite pour la fenetre Continu (2) ********************
proc ::acqt1m::Simu_deja_faite_2 { visuNo } {
   global caption panneau

   if { $panneau(acqt1m,$visuNo,simulation_deja_faite) == "1" } {
      set panneau(acqt1m,$visuNo,intervalle) "xxxx" ; \
      $panneau(acqt1m,$visuNo,base).intervalle_continu_2.lab3 configure \
         -text "$caption(acqt1m,int_mini_image) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
      focus $panneau(acqt1m,$visuNo,base).intervalle_continu_2.a.ent1
   } else {
      set panneau(acqt1m,$visuNo,intervalle) "...."
      $panneau(acqt1m,$visuNo,base).intervalle_continu_2.lab3 configure \
         -text "$caption(acqt1m,int_mini_image) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
      focus $panneau(acqt1m,$visuNo,base).intervalle_continu_2.but1
   }
}
#***** Fin de si une simulation a deja ete faite pour la fenetre Continu (2) *************




















#***** Enregistrement de la position des fenetres Continu (1) et Continu (2) *************
proc ::acqt1m::recup_position { visuNo } {
   global conf panneau

   #--- Cas de la fenetre Continu (1)
   if [ winfo exists $panneau(acqt1m,$visuNo,base).intervalle_continu_1 ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqt1m,$visuNo,base).intervalle_continu_1 ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(acqt1m,continu1,position) "+[ string range $geometry $deb $fin ]"
      #--- Fermeture de la fenetre
      destroy $panneau(acqt1m,$visuNo,base).intervalle_continu_1
   }
   #--- Cas de la fenetre Continu (2)
   if [ winfo exists $panneau(acqt1m,$visuNo,base).intervalle_continu_2 ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqt1m,$visuNo,base).intervalle_continu_2 ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(acqt1m,continu2,position) "+[ string range $geometry $deb $fin ]"
      #--- Fermeture de la fenetre
      destroy $panneau(acqt1m,$visuNo,base).intervalle_continu_2
   }
}
#***** Fin enregistrement de la position des fenetres Continu (1) et Continu (2) *********




















#***** Enregistrement de la position de la fenetre Avancement ********
proc ::acqt1m::recup_position_1 { visuNo } {
   global panneau

   #--- Cas de la fenetre Avancement
   if [ winfo exists $panneau(acqt1m,$visuNo,base).progress ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqt1m,$visuNo,base).progress ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set panneau(acqt1m,$visuNo,avancement,position) "+[ string range $geometry $deb $fin ]"
   }
}
#***** Fin enregistrement de la position de la fenetre Avancement ****




















#***** Affichage de la fenetre de configuration de WebCam ************
proc ::acqt1m::webcamConfigure { visuNo } {

   global audace caption

   set result [::webcam::config::run $visuNo [::confVisu::getCamItem $visuNo]]
   if { $result == "1" } {
      if { [ ::confVisu::getCamItem $visuNo ] == "" } {
         set ::cycle::stop 1
         ::audace::menustate disabled
         set choix [ tk_messageBox -title $caption(acqt1m,pb) -type ok \
            -message $caption(acqt1m,selcam) ]
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
proc ::acqt1m::camConfigure { visuNo } {
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


proc ::acqt1m::gps_open { visuNo } {

   global panneau

   set err [::acqt1m::gps::openGPS]
   if {!$err} {
          $panneau(acqt1m,$visuNo,This).gps.but configure -bg "green"
   } else {
          $panneau(acqt1m,$visuNo,This).gps.but configure -bg "red"
   }
}

#***** Fin de la fenetre de configuration de WebCam ******************



proc ::acqt1m::ccdtemp { visuNo } {

      global  panneau

      set camNo $panneau(acqt1m,$visuNo,camNo)
      if { $camNo == "0" } {
         ::console::affiche_resultat "il n y a pas de camera\n"
      } else {
         set state [ cam$camNo cooler ]
         if {$state != "off"} {
            set cons [lindex $state 1]
            if {[string is double $cons]} {
               set cons [format "%.1f" $cons]
               set cons "Consigne = $cons °C"
            } else {
               set cons ""
            }
            set state "on"
         }
         set err [catch {set temp  [format "%.1f" [ cam$camNo native GetTemperature ] ] } msg ]
         if {$err} {
            gren_erreur "$err $msg\n"
            return
         }
         #set cons  [format "%.1f" [ cam$camNo cooler check  ] ]
         ::console::affiche_resultat "Refroidissement ($state)  Temperature CCD = $temp °C  $cons\n"
      }
}


   proc ::acqt1m::saturation { visuNo } {
      global caption

      set max 50000

      set bufNo  [ ::confVisu::getBufNo $visuNo ]
      set naxis1 [ lindex [ buf$bufNo getkwd NAXIS1 ] 1 ]
      set naxis2 [ lindex [ buf$bufNo getkwd NAXIS2 ] 1 ]

      affich_un_rond_xy [expr int($naxis1/2)] [expr int($naxis2/2)] "yellow" 5 1

      set err [ catch {set rect  [ ::confVisu::getBox $visuNo ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "$caption(acqt1m,select_carre)" -type ok -title $caption(acqt1m,saturation)
         return
      }
      set x1 [lindex $rect 0]
      set y1 [lindex $rect 1]
      set x2 [lindex $rect 2]
      set y2 [lindex $rect 3]

      if {$x1<$x2} {
        set xa $x1
        set xb $x2
      } else {
        set xa $x2
        set xb $x1
      }
      if {$y1<$y2} {
        set ya $y1
        set yb $y2
      } else {
        set ya $y2
        set yb $y1
      }

      set step [expr ( ( $xb - $xa + 1) / 10)]
      set pass [expr $step + $xa - 1 ]
      set cpt 0
#      ::console::affiche_resultat "Recherche des Pixels satures\n"
#      ::console::affiche_resultat ".# .# .# .# .# .# .# .# .# .#\n"
      for {set x $xa} {$x <= $xb} {incr x} {
         if {$x > $pass} {
#            ::console::affiche_resultat "."
            incr pass $step
         }
         for {set y $ya} {$y <= $yb} {incr y} {

            set a [buf$bufNo getpix [list $x $y]]
            set adu [lindex $a 1]
            if {$adu > $max} {
              #::console::affiche_resultat "$x $y $adu \n"
              affich_un_rond_xy $x $y "red" 2 2
              incr cpt
            }
         }
      }
#      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "Nb saturated pixel : $cpt \n"
   }


   proc ::acqt1m::horloge_astro {  } {

      global audace

      if {![winfo exists .horloge_astro]} {
         ::acqt1m_ha::horloge_astro2
      }
   }







proc ::acqt1m::acqt1mBuildIF { visuNo } {
   global audace caption conf panneau

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   #--- Trame des informations
   #frame $panneau(acqt1m,$visuNo,This) -borderwidth 2 -relief groove
   #   label $panneau(acqt1m,$visuNo,This).lab -text "infoinfoinfoinfoinfoinfoinfoinfoinfoinfoinfoinfoinfo" -pady 0
   #   pack $panneau(acqt1m,$visuNo,This).lab -fill x -side left
   #pack $panneau(acqt1m,$visuNo,This) -side top -fill x

   frame $panneau(acqt1m,$visuNo,This) -borderwidth 2 -relief groove

   #--- Trame du titre du panneau
   frame $panneau(acqt1m,$visuNo,This).titre -borderwidth 2 -relief groove
      Button $panneau(acqt1m,$visuNo,This).titre.but -borderwidth 1 \
         -text "$caption(acqt1m,help_titre1)\n$caption(acqt1m,titre)" \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqt1m::getPluginType ] ] \
            [ ::acqt1m::getPluginDirectory ] [ ::acqt1m::getPluginHelp ]"
      pack $panneau(acqt1m,$visuNo,This).titre.but -side top -fill x -in $panneau(acqt1m,$visuNo,This).titre -ipadx 5
      DynamicHelp::add $panneau(acqt1m,$visuNo,This).titre.but -text $caption(acqt1m,help_titre)
   pack $panneau(acqt1m,$visuNo,This).titre -side top -fill x

   #--- Trame du bouton de configuration
   frame $panneau(acqt1m,$visuNo,This).config -borderwidth 2 -relief groove
      button $panneau(acqt1m,$visuNo,This).config.but -borderwidth 1 -text $caption(acqt1m,configuration) \
        -command "::acqt1mSetup::run $visuNo $base.acqt1mSetup"
      pack $panneau(acqt1m,$visuNo,This).config.but -side top -fill x -in $panneau(acqt1m,$visuNo,This).config -ipadx 5 -ipady 4
   pack $panneau(acqt1m,$visuNo,This).config -side top -fill x

   #--- Trame du bouton d appel a Gps
   frame $panneau(acqt1m,$visuNo,This).gps -borderwidth 2 -relief groove
      button $panneau(acqt1m,$visuNo,This).gps.but -borderwidth 1 -text $caption(acqt1m,gps) -command "::acqt1m::gps_open $visuNo"
      pack $panneau(acqt1m,$visuNo,This).gps.but -side top -fill x -in $panneau(acqt1m,$visuNo,This).gps -ipadx 5 -ipady 4
   pack $panneau(acqt1m,$visuNo,This).gps -side top -fill x
$panneau(acqt1m,$visuNo,This).gps.but  configure -bg "green"
   #--- Trame pour les filtres
   frame $panneau(acqt1m,$visuNo,This).filtre -borderwidth 2 -relief ridge
      button $panneau(acqt1m,$visuNo,This).filtre.but -borderwidth 1 -text $caption(acqt1m,filtre) -command "::t1m_roue_a_filtre::infoFiltre $visuNo"
      pack $panneau(acqt1m,$visuNo,This).filtre.but -fill x -side left
      menubutton $panneau(acqt1m,$visuNo,This).filtre.filtrecourant -textvariable panneau(acqt1m,$visuNo,filtrecourant) \
         -menu $panneau(acqt1m,$visuNo,This).filtre.filtrecourant.menu -relief raised
      pack $panneau(acqt1m,$visuNo,This).filtre.filtrecourant -side right -fill x -expand true -ipady 1
      set m [ menu $panneau(acqt1m,$visuNo,This).filtre.filtrecourant.menu -tearoff 0 ]
      foreach filtrecourant $panneau(acqt1m,$visuNo,filtrelist) {
        $m add radiobutton -label "$filtrecourant" \
           -indicatoron "1" \
           -value "$filtrecourant" \
           -variable panneau(acqt1m,$visuNo,filtrecourant) \
           -command "::t1m_roue_a_filtre::changeFiltre $visuNo"
      }
   pack $panneau(acqt1m,$visuNo,This).filtre -side top -fill x

   #--- Trame du bouton du binning
   frame $panneau(acqt1m,$visuNo,This).binningt -borderwidth 2 -relief ridge
      button $panneau(acqt1m,$visuNo,This).binningt.but -borderwidth 1 -text $caption(acqt1m,bin,$panneau(acqt1m,$visuNo,binning)) \
         -command "::acqt1m::changerBinningCent $visuNo"
      pack $panneau(acqt1m,$visuNo,This).binningt.but -fill x -expand true -ipady 3 -in $panneau(acqt1m,$visuNo,This).binningt
   pack $panneau(acqt1m,$visuNo,This).binningt -side top -fill x

   #--- Trame du temps de pose
   frame $panneau(acqt1m,$visuNo,This).pose -borderwidth 2 -relief ridge
      menubutton $panneau(acqt1m,$visuNo,This).pose.but -text $caption(acqt1m,pose) \
         -menu $panneau(acqt1m,$visuNo,This).pose.but.menu -relief raised
      pack $panneau(acqt1m,$visuNo,This).pose.but -side left -fill x -expand true -ipady 1
      set m [ menu $panneau(acqt1m,$visuNo,This).pose.but.menu -tearoff 0 ]
      foreach temps $panneau(acqt1m,$visuNo,temps_pose) {
        $m add radiobutton -label "$temps" \
           -indicatoron "1" \
           -value "$temps" \
           -variable panneau(acqt1m,$visuNo,pose) \
           -command " "
      }
      label $panneau(acqt1m,$visuNo,This).pose.lab -text $caption(acqt1m,sec)
      pack $panneau(acqt1m,$visuNo,This).pose.lab -side right -fill x -expand true
      entry $panneau(acqt1m,$visuNo,This).pose.entr -width 6 -relief groove \
         -textvariable panneau(acqt1m,$visuNo,pose) -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $panneau(acqt1m,$visuNo,This).pose.entr -side left -fill both -expand true
   pack $panneau(acqt1m,$visuNo,This).pose -side top -fill x

   #--- Trame du nom de l'objet, AD et Dec.
   frame $panneau(acqt1m,$visuNo,This).object -borderwidth 2 -relief ridge
      label $panneau(acqt1m,$visuNo,This).object.lab -text $caption(acqt1m,objet) -pady 0
      pack $panneau(acqt1m,$visuNo,This).object.lab -fill x
      entry $panneau(acqt1m,$visuNo,This).object.entr -width 10 \
         -textvariable panneau(acqt1m,$visuNo,object) -relief groove \
         -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
      pack $panneau(acqt1m,$visuNo,This).object.entr -fill x

      frame $panneau(acqt1m,$visuNo,This).object.ra
         label $panneau(acqt1m,$visuNo,This).object.ra.lab -text $caption(acqt1m,ra) -pady 0
         pack $panneau(acqt1m,$visuNo,This).object.ra.lab -fill x -side left
         entry $panneau(acqt1m,$visuNo,This).object.ra.entr -width 10 \
            -textvariable panneau(acqt1m,$visuNo,ra) -relief groove
         pack $panneau(acqt1m,$visuNo,This).object.ra.entr -fill x
      pack $panneau(acqt1m,$visuNo,This).object.ra -fill x

      frame $panneau(acqt1m,$visuNo,This).object.dec
         label $panneau(acqt1m,$visuNo,This).object.dec.lab -text $caption(acqt1m,dec) -pady 0
         pack $panneau(acqt1m,$visuNo,This).object.dec.lab -fill x -side left
         entry $panneau(acqt1m,$visuNo,This).object.dec.entr -width 10 \
            -textvariable panneau(acqt1m,$visuNo,dec) -relief groove
         pack $panneau(acqt1m,$visuNo,This).object.dec.entr -fill x
      pack $panneau(acqt1m,$visuNo,This).object.dec -fill x

   pack $panneau(acqt1m,$visuNo,This).object -side top -fill x

   #--- Bouton de configuration de la WebCam en lieu et place du widget pose
   button $panneau(acqt1m,$visuNo,This).pose.conf -text $caption(acqt1m,pose) \
      -command "::acqt1m::webcamConfigure $visuNo"
   pack $panneau(acqt1m,$visuNo,This).pose.conf -fill x -expand true -ipady 3

   #--- Trame de l'obturateur
   frame $panneau(acqt1m,$visuNo,This).obt -borderwidth 2 -relief ridge -width 16
      button $panneau(acqt1m,$visuNo,This).obt.but -text $caption(acqt1m,obt) -command "::acqt1m::ChangeObt $visuNo" \
         -state normal
      pack $panneau(acqt1m,$visuNo,This).obt.but -side left -ipady 3
      label $panneau(acqt1m,$visuNo,This).obt.lab -text $panneau(acqt1m,$visuNo,obt,$panneau(acqt1m,$visuNo,obt)) -width 6 \
        -relief groove
      pack $panneau(acqt1m,$visuNo,This).obt.lab -side left -fill x -expand true -ipady 3
   pack $panneau(acqt1m,$visuNo,This).obt -side top -fill x

   #--- Trame du Status
   frame $panneau(acqt1m,$visuNo,This).status -borderwidth 2 -relief ridge
      label $panneau(acqt1m,$visuNo,This).status.lab -text "" -relief ridge \
         -justify center -width 16
      pack $panneau(acqt1m,$visuNo,This).status.lab -side top -fill x -pady 1
   pack $panneau(acqt1m,$visuNo,This).status -side top -fill x

   #--- Trame du bouton Go/Stop
   frame $panneau(acqt1m,$visuNo,This).go_stop -borderwidth 2 -relief ridge
      Button $panneau(acqt1m,$visuNo,This).go_stop.but -text $caption(acqt1m,GO) -height 2 \
         -borderwidth 3 -command "::acqt1m::Go $visuNo"
      pack $panneau(acqt1m,$visuNo,This).go_stop.but -fill both -padx 0 -pady 0 -expand true
   pack $panneau(acqt1m,$visuNo,This).go_stop -side top -fill x

   #--- Trame du mode d'acquisition
   set panneau(acqt1m,$visuNo,mode_en_cours) [ lindex $panneau(acqt1m,$visuNo,list_mode) [ expr $panneau(acqt1m,$visuNo,mode) - 1 ] ]
   frame $panneau(acqt1m,$visuNo,This).mode -borderwidth 5 -relief ridge
      ComboBox $panneau(acqt1m,$visuNo,This).mode.but \
         -width 15         \
         -height [llength $panneau(acqt1m,$visuNo,list_mode)] \
         -relief raised    \
         -borderwidth 1    \
         -editable 0       \
         -takefocus 1      \
         -justify center   \
         -textvariable panneau(acqt1m,$visuNo,mode_en_cours) \
         -values $panneau(acqt1m,$visuNo,list_mode) \
         -modifycmd "::acqt1m::ChangeMode $visuNo"
      pack $panneau(acqt1m,$visuNo,This).mode.but -side top -fill x

      #--- Definition du sous-panneau "Mode : Une seule image"
      frame $panneau(acqt1m,$visuNo,This).mode.une -borderwidth 0
         frame $panneau(acqt1m,$visuNo,This).mode.une.index -relief ridge -borderwidth 2
            checkbutton $panneau(acqt1m,$visuNo,This).mode.une.index.case -pady 0 -text $caption(acqt1m,index) \
               -variable panneau(acqt1m,$visuNo,indexer)
            pack $panneau(acqt1m,$visuNo,This).mode.une.index.case -side top -fill x
            entry $panneau(acqt1m,$visuNo,This).mode.une.index.entr -width 3 -textvariable panneau(acqt1m,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqt1m,$visuNo,This).mode.une.index.entr -side left -fill x -expand true
            button $panneau(acqt1m,$visuNo,This).mode.une.index.but -text "1" -width 3 \
               -command "set panneau(acqt1m,$visuNo,index) 1"
            pack $panneau(acqt1m,$visuNo,This).mode.une.index.but -side right -fill x
         pack $panneau(acqt1m,$visuNo,This).mode.une.index -side top -fill x
         button $panneau(acqt1m,$visuNo,This).mode.une.sauve -text $caption(acqt1m,sauvegde) \
            -command "::acqt1m::SauveUneImage $visuNo"
         pack $panneau(acqt1m,$visuNo,This).mode.une.sauve -side top -fill x

      #--- Definition du sous-panneau "Mode : Serie d'images"
      frame $panneau(acqt1m,$visuNo,This).mode.serie
         frame $panneau(acqt1m,$visuNo,This).mode.serie.nb -relief ridge -borderwidth 2
            label $panneau(acqt1m,$visuNo,This).mode.serie.nb.but -text $caption(acqt1m,nombre) -pady 0
            pack $panneau(acqt1m,$visuNo,This).mode.serie.nb.but -side left -fill y
            entry $panneau(acqt1m,$visuNo,This).mode.serie.nb.entr -width 3 -textvariable panneau(acqt1m,$visuNo,nb_images) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqt1m,$visuNo,This).mode.serie.nb.entr -side left -fill x -expand true
         pack $panneau(acqt1m,$visuNo,This).mode.serie.nb -side top -fill x
         frame $panneau(acqt1m,$visuNo,This).mode.serie.index -relief ridge -borderwidth 2
            label $panneau(acqt1m,$visuNo,This).mode.serie.index.lab -text $caption(acqt1m,index) -pady 0
            pack $panneau(acqt1m,$visuNo,This).mode.serie.index.lab -side top -fill x
            entry $panneau(acqt1m,$visuNo,This).mode.serie.index.entr -width 3 -textvariable panneau(acqt1m,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqt1m,$visuNo,This).mode.serie.index.entr -side left -fill x -expand true
            button $panneau(acqt1m,$visuNo,This).mode.serie.index.but -text "1" -width 3 \
               -command "set panneau(acqt1m,$visuNo,index) 1"
            pack $panneau(acqt1m,$visuNo,This).mode.serie.index.but -side right -fill x
         pack $panneau(acqt1m,$visuNo,This).mode.serie.index -side top -fill x
         frame $panneau(acqt1m,$visuNo,This).mode.serie.indexEnd -relief ridge -borderwidth 2
            label $panneau(acqt1m,$visuNo,This).mode.serie.indexEnd.lab1 \
               -textvariable panneau(acqt1m,$visuNo,indexEndSerie) -pady 0
            pack $panneau(acqt1m,$visuNo,This).mode.serie.indexEnd.lab1 -side top -fill x
         pack $panneau(acqt1m,$visuNo,This).mode.serie.indexEnd -side top -fill x

      #--- Definition du sous-panneau "Mode : Continu"
      frame $panneau(acqt1m,$visuNo,This).mode.continu
         frame $panneau(acqt1m,$visuNo,This).mode.continu.sauve -relief ridge -borderwidth 2
            checkbutton $panneau(acqt1m,$visuNo,This).mode.continu.sauve.case -text $caption(acqt1m,enregistrer) \
               -variable panneau(acqt1m,$visuNo,enregistrer)
            pack $panneau(acqt1m,$visuNo,This).mode.continu.sauve.case -side left -fill x  -expand true
         pack $panneau(acqt1m,$visuNo,This).mode.continu.sauve -side top -fill x
         frame $panneau(acqt1m,$visuNo,This).mode.continu.index -relief ridge -borderwidth 2
            checkbutton $panneau(acqt1m,$visuNo,This).mode.continu.index.case -pady 0 -text $caption(acqt1m,index) \
               -variable panneau(acqt1m,$visuNo,indexerContinue)
            pack $panneau(acqt1m,$visuNo,This).mode.continu.index.case -side top -fill x
            entry $panneau(acqt1m,$visuNo,This).mode.continu.index.entr -width 3 -textvariable panneau(acqt1m,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqt1m,$visuNo,This).mode.continu.index.entr -side left -fill x -expand true
            button $panneau(acqt1m,$visuNo,This).mode.continu.index.but -text "1" -width 3 \
               -command "set panneau(acqt1m,$visuNo,index) 1"
            pack $panneau(acqt1m,$visuNo,This).mode.continu.index.but -side right -fill x
         pack $panneau(acqt1m,$visuNo,This).mode.continu.index -side top -fill x

      #--- Definition du sous-panneau "Mode : Series d'images en continu avec intervalle entre chaque serie"
      frame $panneau(acqt1m,$visuNo,This).mode.serie_1
         frame $panneau(acqt1m,$visuNo,This).mode.serie_1.nb -relief ridge -borderwidth 2
            label $panneau(acqt1m,$visuNo,This).mode.serie_1.nb.but -text $caption(acqt1m,nombre) -pady 0
            pack $panneau(acqt1m,$visuNo,This).mode.serie_1.nb.but -side left -fill y
            entry $panneau(acqt1m,$visuNo,This).mode.serie_1.nb.entr -width 3 -textvariable panneau(acqt1m,$visuNo,nb_images) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqt1m,$visuNo,This).mode.serie_1.nb.entr -side left -fill x -expand true
         pack $panneau(acqt1m,$visuNo,This).mode.serie_1.nb -side top -fill x
         frame $panneau(acqt1m,$visuNo,This).mode.serie_1.index -relief ridge -borderwidth 2
            label $panneau(acqt1m,$visuNo,This).mode.serie_1.index.lab -text $caption(acqt1m,index) -pady 0
            pack $panneau(acqt1m,$visuNo,This).mode.serie_1.index.lab -side top -fill x
            entry $panneau(acqt1m,$visuNo,This).mode.serie_1.index.entr -width 3 -textvariable panneau(acqt1m,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqt1m,$visuNo,This).mode.serie_1.index.entr -side left -fill x -expand true
            button $panneau(acqt1m,$visuNo,This).mode.serie_1.index.but -text "1" -width 3 \
               -command "set panneau(acqt1m,$visuNo,index) 1"
            pack $panneau(acqt1m,$visuNo,This).mode.serie_1.index.but -side right -fill x
         pack $panneau(acqt1m,$visuNo,This).mode.serie_1.index -side top -fill x
         frame $panneau(acqt1m,$visuNo,This).mode.serie_1.indexEnd -relief ridge -borderwidth 2
            label $panneau(acqt1m,$visuNo,This).mode.serie_1.indexEnd.lab1 \
               -textvariable panneau(acqt1m,$visuNo,indexEndSerieContinu) -pady 0
            pack $panneau(acqt1m,$visuNo,This).mode.serie_1.indexEnd.lab1 -side top -fill x
         pack $panneau(acqt1m,$visuNo,This).mode.serie_1.indexEnd -side top -fill x

      #--- Definition du sous-panneau "Mode : Continu avec intervalle entre chaque image"
      frame $panneau(acqt1m,$visuNo,This).mode.continu_1
         frame $panneau(acqt1m,$visuNo,This).mode.continu_1.sauve -relief ridge -borderwidth 2
            checkbutton $panneau(acqt1m,$visuNo,This).mode.continu_1.sauve.case -text $caption(acqt1m,enregistrer) \
               -variable panneau(acqt1m,$visuNo,enregistrer)
            pack $panneau(acqt1m,$visuNo,This).mode.continu_1.sauve.case -side left -fill x  -expand true
         pack $panneau(acqt1m,$visuNo,This).mode.continu_1.sauve -side top -fill x
         frame $panneau(acqt1m,$visuNo,This).mode.continu_1.index -relief ridge -borderwidth 2
            label $panneau(acqt1m,$visuNo,This).mode.continu_1.index.lab -text $caption(acqt1m,index) -pady 0
            pack $panneau(acqt1m,$visuNo,This).mode.continu_1.index.lab -side top -fill x
            entry $panneau(acqt1m,$visuNo,This).mode.continu_1.index.entr -width 3 -textvariable panneau(acqt1m,$visuNo,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $panneau(acqt1m,$visuNo,This).mode.continu_1.index.entr -side left -fill x -expand true
            button $panneau(acqt1m,$visuNo,This).mode.continu_1.index.but -text "1" -width 3 \
               -command "set panneau(acqt1m,$visuNo,index) 1"
            pack $panneau(acqt1m,$visuNo,This).mode.continu_1.index.but -side right -fill x
         pack $panneau(acqt1m,$visuNo,This).mode.continu_1.index -side top -fill x
     pack $panneau(acqt1m,$visuNo,This).mode -side top -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $panneau(acqt1m,$visuNo,This).avancement_acq -borderwidth 2 -relief ridge
         #--- Checkbutton pour l'affichage de l'avancement de l'acqusition
         checkbutton $panneau(acqt1m,$visuNo,This).avancement_acq.check -highlightthickness 0 \
            -text $caption(acqt1m,avancement_acq) -variable panneau(acqt1m,$visuNo,avancement_acq)
         pack $panneau(acqt1m,$visuNo,This).avancement_acq.check -side left -fill x
      pack $panneau(acqt1m,$visuNo,This).avancement_acq -side top -fill x

      #--- Frame traitement special
      frame $panneau(acqt1m,$visuNo,This).special -borderwidth 2 -relief ridge
         #--- Bouton Horloge astro
         button $panneau(acqt1m,$visuNo,This).special.horloge -text "$caption(acqt1m,horloge_astro)" \
            -command "::acqt1m::horloge_astro"
         pack $panneau(acqt1m,$visuNo,This).special.horloge -side top -fill x -expand true
         #--- Bouton OFFSET/DARK
         button $panneau(acqt1m,$visuNo,This).special.offsetdark -text "$caption(acqt1m,offset_dark)" \
            -command "::acqt1m_offsetdark::run $visuNo"
         pack $panneau(acqt1m,$visuNo,This).special.offsetdark -side top -fill x -expand true
         #--- Bouton Flat auto +
         button $panneau(acqt1m,$visuNo,This).special.flatautoplus -text "$caption(acqt1m,flatAuto)+" \
            -command "::acqt1m_flatcielplus::run $visuNo"
         pack $panneau(acqt1m,$visuNo,This).special.flatautoplus -side top -fill x -expand true
         #--- Bouton Cycle
         button $panneau(acqt1m,$visuNo,This).special.cyclepose -text "$caption(acqt1m,cycle)" \
            -command "::cycle::run $visuNo"
         pack $panneau(acqt1m,$visuNo,This).special.cyclepose -side top -fill x -expand true
         #--- Bouton Astroid

         frame $panneau(acqt1m,$visuNo,This).special.astroid -borderwidth 2 -relief ridge
         pack $panneau(acqt1m,$visuNo,This).special.astroid -side top -fill x -expand true

            checkbutton $panneau(acqt1m,$visuNo,This).special.astroid.check -pady 0 \
                  -variable panneau(acqt1m,$visuNo,launchastroid)
            pack $panneau(acqt1m,$visuNo,This).special.astroid.check -side left -fill x -expand true

            button $panneau(acqt1m,$visuNo,This).special.astroid.manuel -text "$caption(acqt1m,astroid)" \
               -command "::t1mastroid::astroid $visuNo"
            pack $panneau(acqt1m,$visuNo,This).special.astroid.manuel -side left -fill x -expand true

         #--- Bouton CCD Temp
         button $panneau(acqt1m,$visuNo,This).special.ccdtemp -text "$caption(acqt1m,ccdtemp)" \
            -command "::acqt1m::ccdtemp $visuNo"
         pack $panneau(acqt1m,$visuNo,This).special.ccdtemp -side top -fill x -expand true
         #--- Bouton Saturation
         button $panneau(acqt1m,$visuNo,This).special.saturation -text "$caption(acqt1m,saturation)" \
            -command "::acqt1m::saturation $visuNo"
         pack $panneau(acqt1m,$visuNo,This).special.saturation -side top -fill x -expand true
         #--- Bouton Clean
         button $panneau(acqt1m,$visuNo,This).special.clean -text "$caption(acqt1m,clean)" \
            -command "cleanmark"
         pack $panneau(acqt1m,$visuNo,This).special.clean -side top -fill x -expand true
         #--- Bouton Ressource
         button $panneau(acqt1m,$visuNo,This).special.ressource -text "$caption(acqt1m,ressource)" \
            -command "::acqt1m::ressource"
         pack $panneau(acqt1m,$visuNo,This).special.ressource -side top -fill x -expand true
      pack $panneau(acqt1m,$visuNo,This).special -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(acqt1m,$visuNo,This)
}



proc subcrop { a b x y } {

   set bufnoa [::buf::create]
   set bufnob [::buf::create]
   buf$bufnoa load $a
   buf$bufnob load $b

   set naxis1 [ lindex [ buf$bufnoa getkwd NAXIS1 ] 1 ]
   set naxis2 [ lindex [ buf$bufnoa getkwd NAXIS2 ] 1 ]

   if {$x > 0} {
      buf$bufnoa window [list $x 1 $naxis1 $naxis2]
      buf$bufnob window [list 1 1 [expr $naxis1-$x+1] $naxis2]
   }
   if {$x < 0} {
      set x [expr -$x]
      buf$bufnoa window [list 1 1 [expr $naxis1-$x+1] $naxis2]
      buf$bufnob window [list $x 1 $naxis1 $naxis2]
   }
   if {$y > 0} {
      buf$bufnoa window [list 1 $y $naxis1 $naxis2]
      buf$bufnob window [list 1 1 $naxis1 [expr $naxis2-$y+1]]
   }
   if {$y < 0} {
      set y [expr -$y]
      buf$bufnoa window [list 1 1 $naxis1 [expr $naxis2-$y+1]]
      buf$bufnob window [list 1 $y $naxis1 $naxis2]
   }

   buf$bufnob save b
   buf$bufnoa save a
   buf1 load a
   buf1 sub b
   buf1 save c
   loadima c
   ::buf::delete  $bufnoa
   ::buf::delete  $bufnob

}

