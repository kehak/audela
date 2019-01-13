#
# Fichier : acqfast.tcl
# Description : Outil d'acquisition specifique pour la camera Raptor OSPREY
# Auteur : Matteo Schiavon
# Mise à jour $Id: acqfast.tcl 12977 2016-01-29 18:22:27Z robertdelmas $
#

#==============================================================
#   Declaration du namespace acqfast
#==============================================================

namespace eval ::acqfast {
   package provide acqfast 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] acqfast.cap ]
}


proc ::acqfast::ressource { } {
   global audace caption

   ::console::affiche_resultat "$caption(acqfast,rechargeScripts)"
   #uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfast acqfast.tcl ]\""
   #uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfast acqfast.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfast acqfastSetup.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfast gps.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfast cyclefast.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfast cyclefast.cap ]\""

   if {$::tcl_platform(os)=="Linux"} {
      load libmeinberg[info sharedlibextension]
   }
}




#***** Procedure createPluginInstance***************************
proc ::acqfast::createPluginInstance { base { visuNo 1 } } {
   variable parametres
   global audace caption conf panneau

   #--- Chargement des fichiers auxiliaires
   ::acqfast::ressource


   #---
   set panneau(acqfast,$visuNo,base) "$base"
   set panneau(acqfast,$visuNo,This) "$base.acqfast"

   set panneau(acqfast,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
   set panneau(acqfast,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqfast,$visuNo,camItem)]

   #--- Recuperation de la derniere configuration de l'outil
   ::acqfast::chargerVariable $visuNo

   #--- Initialisation des variables de la boite de configuration
   ::acqfastSetup::confToWidget $visuNo


   #--- Valeur par defaut du temps de pose
   if { ! [ info exists panneau(acqfast,$visuNo,pose) ] } {
      set panneau(acqfast,$visuNo,pose) "$parametres(acqfast,$visuNo,pose)"
   }

   #--- Valeur par defaut du framerate
   if { ! [ info exists panneau(acqfast,$visuNo,framerate) ] } {
      set panneau(acqfast,$visuNo,framerate) "$parametres(acqfast,$visuNo,framerate)"
   }

   #--- Valeur par defaut du maximum framerate
   if { ! [ info exists panneau(acqfast,$visuNo,maxframerate) ] } {
      set panneau(acqfast,$visuNo,maxframerate) "$parametres(acqfast,$visuNo,maxframerate)"
   }

   #--- Valeur par defaut de la pose maximale
   if { ! [ info exists panneau(acqfast,$visuNo,maxpose) ] } {
      set panneau(acqfast,$visuNo,maxpose) "$parametres(acqfast,$visuNo,maxpose)"
   }

   #--- Valeur par defaut du frame
   if { ! [ info exists panneau(acqfast,$visuNo,frame) ] } {
      set panneau(acqfast,$visuNo,frame) "$parametres(acqfast,$visuNo,frame)"
   }

   #--- Valeur par defaut du maximum frame
   if { ! [ info exists panneau(acqfast,$visuNo,lastframe) ] } {
      set panneau(acqfast,$visuNo,lastframe) "$parametres(acqfast,$visuNo,lastframe)"
   }

   #--- Valeur par defaut de la variable continu
   if { ! [ info exists panneau(acqfast,$visuNo,continu) ] } {
      set panneau(acqfast,$visuNo,continu) "$parametres(acqfast,$visuNo,continu)"
   }

   #--- Valeur par defaut du binning
   if { ! [ info exists panneau(acqfast,$visuNo,binning) ] } {
      set panneau(acqfast,$visuNo,binning) "$parametres(acqfast,$visuNo,bin)"
   }

   #--- Liste des modes disponibles
   set panneau(acqfast,$visuNo,list_mode) [ list $caption(acqfast,ffr) $caption(acqfast,itr) ]

   #--- Video mode
   if { ! [ info exists panneau(acqfast,$visuNo,mode) ] } {
      set panneau(acqfast,$visuNo,mode) "$parametres(acqfast,$visuNo,mode)"
   }

   #--- Cycle file
   if { ! [ info exists panneau(acqfast,$visuNo,cycfile) ] } {
      set panneau(acqfast,$visuNo,cycfile) "$parametres(acqfast,$visuNo,cycfile)"
   }

   #--- Video en cours
   #if { ! [ info exists panneau(acqfast,$visuNo,video_en_cours) ] } {
   #   set panneau(acqfast,$visuNo,video_en_cours) "0"
   #}

   #--- Valeur par defaut du maximum frame
   if { ! [ info exists panneau(acqfast,$visuNo,maxframe) ] } {
      set panneau(acqfast,$visuNo,maxframe) "1"
   }


   #--- Initialisation d'autres variables
   #set panneau(acqfast,$visuNo,index)                "1"
   set panneau(acqfast,$visuNo,date_gps,end)             ""
   set panneau(acqfast,$visuNo,date_gps,begin)             ""
   set panneau(acqfast,$visuNo,avancement,position)  "+120+315"

   #--- Mise en place de l'interface graphique
   acqfastBuildIF $visuNo


   #--- Ouverture de la session
   #set panneau(acqfast,$visuNo,session_ouverture) "1"

   #--- Surveillance de la connexion d'une camera
   ::confVisu::addCameraListener $visuNo "::acqfast::adaptOutilAcqfast $visuNo"
   #--- Surveillance de l'ajout ou de la suppression d'une extension
   trace add variable ::audace(extensionList) write "::acqfast::initExtensionList $visuNo"

   #---
   return $panneau(acqfast,$visuNo,This)
}
#***** Fin de la procedure createPluginInstance*****************



#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::acqfast::deletePluginInstance { visuNo } {
   global conf panneau

   #--- Je desactive la surveillance de la connexion d'une camera
   ::confVisu::removeCameraListener $visuNo "::acqfast::adaptOutilAcqfast $visuNo"
   #--- Je desactive la surveillance de l'ajout ou de la suppression d'une extension
   trace remove variable ::audace(extensionList) write "::acqfast::initExtensionList $visuNo"


   destroy $panneau(acqfast,$visuNo,This)
}


#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::acqfast::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "fast imaging" }
      display      { return "panel" }
      multivisu    { return 1 }
   }
}



#------------------------------------------------------------
#  getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::acqfast::getPluginTitle { } {
   global caption

   return "$caption(acqfast,titre)"
}


#------------------------------------------------------------
#  getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::acqfast::getPluginHelp { } {
   return "acqfast.htm"
}




#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::acqfast::getPluginType { } {
   return "tool"
}



#------------------------------------------------------------
#  getPluginDirectory
#     retourne le repertoire du plugin
#------------------------------------------------------------
proc ::acqfast::getPluginDirectory { } {
   return "acqfast"
}




#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::acqfast::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}




#***** Procedure Demarrageacqfast ********************************
proc ::acqfast::Demarrageacqfast { visuNo } {
   global audace caption panneau

   #--- Creation du sous-repertoire a la date du jour
   #--- en mode automatique s'il n'existe pas
   ::cwdWindow::updateImageDirectory

   #--- Gestion du fichier de log
   #--- Creation du nom du fichier log
   set nom_generique "acqfast-visu$visuNo-"
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
   set ::acqfast::fichier_log [ file join $audace(rep_images) [ append $file_log $nom_generique $formatdate ".log" ] ]

   #--- Ouverture du fichier de log
   if { [ catch { open $::acqfast::fichier_log a } ::acqfast::log_id($visuNo) ] } {
      Message $visuNo console $caption(acqfast,pbouvfichcons)
      tk_messageBox -title $caption(acqfast,pb) -type ok \
         -message $caption(acqfast,pbouvfich)
      #--- Note importante : Je detecte si j'ai un pb a l'ouverture du fichier, mais je ne sais pas traiter ce cas :
      #--- Il faudrait interdire l'ouverture du panneau, mais le processus est deja lance a ce stade...
      #--- Tout ce que je fais, c'est inviter l'utilisateur a changer d'outil !
   } else {
      #--- En-tete du fichier
      Message $visuNo log $caption(acqfast,ouvsess) [ package version acqfast ]
      set date [clock format [clock seconds] -format "%A %d %B %Y"]
      set date [ ::tkutil::transalteDate $date ]
      set heure $audace(tu,format,hmsint)
      Message $visuNo consolog $caption(acqfast,affheure) $date $heure
   }

   #--- Definition du binding pour declencher l'acquisition (ou l'arret) par Echap.
   bind all <Key-Escape> "::acqfast::Stop $visuNo"


   #--- Nom du fichier de backup (ou les dates sont enregistrees)
   set ::acqfast::fichier_backup [ file join $audace(rep_images) "acqfast.bak" ]

   #--- Cette variable est "1" s'il y a une sequence d'image qui a pas ete enregistre
   if { [ file exists $::acqfast::fichier_backup ] } {
      set panneau(acqfast,$visuNo,unsaved_seq)          "1"
   } else {
      set panneau(acqfast,$visuNo,unsaved_seq)          "0"
   }

}
#***** Fin de la procedure Demarrageacqfast **********************




















#***** Procedure Arretacqfast ************************************
proc ::acqfast::Arretacqfast { visuNo } {
   global audace caption panneau

   #--- Fermeture du fichier de log
   if { [ info exists ::acqfast::log_id($visuNo) ] } {
      set heure $audace(tu,format,hmsint)
      #--- Je m'assure que le fichier se termine correctement, en particulier pour le cas ou il y
      #--- a eu un probleme a l'ouverture (c'est un peu une rustine...)
      if { [ catch { Message $visuNo log $caption(acqfast,finsess) $heure } bug ] } {
         Message $visuNo console $caption(acqfast,pbfermfichcons)
      } else {
         Message $visuNo console "\n"
         close $::acqfast::log_id($visuNo)
         unset ::acqfast::log_id($visuNo)
      }
   }
   #--- Re-initialisation de la session
   #set panneau(acqfast,$visuNo,session_ouverture) "1"
   #--- Desactivation du binding pour declencher l'acquisition (ou l'arret) par Echap.
   bind all <Key-Escape> { }
}
#***** Fin de la procedure Arretacqfast **************************




















#***** Procedure initExtensionList ********************************
proc ::acqfast::initExtensionList { visuNo { a "" } { b "" } { c "" } } {
   global caption conf panneau

   #--- Mise a jour de l'extension par defaut
   set panneau(acqfast,$visuNo,extension) $conf(extension,defaut)
   set camItem [ ::confVisu::getCamItem $visuNo ]
   set extensionList " $::audace(extensionList) [ confCam::getPluginProperty $camItem rawExtension ]"
   ::console::affiche_resultat "$caption(acqfast,extensionFITS) $panneau(acqfast,$visuNo,extension)\n\n"
}
#***** Fin de la procedure initExtensionList **********************




















#***** Procedure adaptOutilAcqfast *******************************
proc ::acqfast::adaptOutilAcqfast { visuNo args } {
   global conf panneau

   set panneau(acqfast,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
   set panneau(acqfast,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqfast,$visuNo,camItem)]

   #--- petits reccorcis bien utiles
   set camItem $panneau(acqfast,$visuNo,camItem)
   set camNo   $panneau(acqfast,$visuNo,camNo)
   if { $camNo == "0" } {
      #--- La camera n'a pas ete encore selectionnee
      set camProduct ""
   } else {
      set camProduct [ cam$camNo product ]
   }



   #--- je mets a jour la liste des extensions
   ::acqfast::initExtensionList $visuNo
}




















#***** Procedure chargerVariable *******************************
proc ::acqfast::chargerVariable { visuNo } {
   variable parametres


   #--- Creation des variables si elles n'existent pas
   if { ! [ info exists parametres(acqfast,$visuNo,pose) ] }           { set parametres(acqfast,$visuNo,pose)   "0.001" }   ; #--- Temps de pose : 0.001s
   if { ! [ info exists parametres(acqfast,$visuNo,framerate) ] }      { set parametres(acqfast,$visuNo,framerate) "37.5" } ; #--- Framerate : 37.5 fps
   if { ! [ info exists parametres(acqfast,$visuNo,bin) ] }            { set parametres(acqfast,$visuNo,bin)    "1x1" } ; #--- Binning : 1x1
   if { ! [ info exists parametres(acqfast,$visuNo,mode) ] }           { set parametres(acqfast,$visuNo,mode)   "0" }   ; #--- Mode : FFR
   if { ! [ info exists parametres(acqfast,$visuNo,maxframerate) ] }   { set parametres(acqfast,$visuNo,maxframerate) "10000." } ; #--- Maxframerate : 37.5 fps
   if { ! [ info exists parametres(acqfast,$visuNo,lastframe) ] }   { set parametres(acqfast,$visuNo,lastframe) "1" } ; #--- Lastframe : 1
   if { ! [ info exists parametres(acqfast,$visuNo,frame) ] }   { set parametres(acqfast,$visuNo,frame) "1" } ; #--- Frame actuel : 1
   if { ! [ info exists parametres(acqfast,$visuNo,continu) ] }   { set parametres(acqfast,$visuNo,continu) "1" } ; #--- Montre en continu : 1
   if { ! [ info exists parametres(acqfast,$visuNo,maxpose) ] }   { set parametres(acqfast,$visuNo,maxpose) "9999" } ; #--- Pose maximale : 9999 s
   if { ! [ info exists parametres(acqfast,$visuNo,cycfile) ] }   { set parametres(acqfast,$visuNo,cycfile) "" } ; #--- File with the cycle



    #if { ! [ info exists parametres(acqfast,$visuNo,avancement_acq) ] } {
    #  if { $visuNo == "1" } {
    #     set parametres(acqfast,$visuNo,avancement_acq) "1" ; #--- Barre de progression de la pose : Oui
    #  } else {
    #     set parametres(acqfast,$visuNo,avancement_acq) "0" ; #--- Barre de progression de la pose : Non
    #  }
    #}

   #--- Creation des variables de la boite de configuration si elles n'existent pas
   ::acqfastSetup::initToConf $visuNo


}
#***** Fin de la procedure chargerVariable *********************




















#***** Procedure enregistrerVariable ***************************
proc ::acqfast::enregistrerVariable { visuNo } {
   variable parametres
   global panneau

   #---
   #---
   set parametres(acqfast,$visuNo,pose)           $panneau(acqfast,$visuNo,pose)
   set parametres(acqfast,$visuNo,bin)            $panneau(acqfast,$visuNo,binning)
   set parametres(acqfast,$visuNo,mode)           $panneau(acqfast,$visuNo,mode)
   set parametres(acqfast,$visuNo,avancement_acq) $panneau(acqfast,$visuNo,avancement_acq)
   set parametres(acqfast,$visuNo,enregistrer)    $panneau(acqfast,$visuNo,enregistrer)
   set parametres(acqfast,$visuNo,cycfile)        $panneau(acqfast,$visuNo,cycfile)

}
#***** Fin de la procedure enregistrerVariable *****************




#***** Procedure startTool *************************************
proc ::acqfast::startTool { { visuNo 1 } } {
   global panneau

   #--- On cree la variable de configuration des mots cles
   if { ! [ info exists ::conf(acqfast,keywordConfigName) ] } { set ::conf(acqfast,keywordConfigName) "default" }

   #--- Initialisatin des fichiers externes geres par le plugin
   Demarrageacqfast $visuNo

   #--- Creation du thread
   #set panneau(acqfast,$visuNo,threadid) [ thread::create { thread::wait } ]
   #thread::send -async $panneau(acqfast,$visuNo,threadid) { ::acqfast::threadinit $visuNo }
   ::acqfast::cycleinit $visuNo


   ::acqfast::adaptOutilAcqfast $visuNo
}
#***** Fin de la procedure startTool ***************************




















#***** Procedure stopTool **************************************
proc ::acqfast::stopTool { { visuNo 1 } } {
   global panneau


   #--- J'arrete le video
   set panneau(acqfast,$visuNo,cycle,action) "2"
   #after 50
   #thread::release $panneau(acqfast,$visuNo,threadid)

   Arretacqfast $visuNo


}
#***** Fin de la procedure stopTool ****************************




















#***** Procedure addinfoheader **************************************
#proc ::acqfast::addinfoheader { { visuNo 1 } } {
#   global panneau
#
#   #--- Je verifie si une operation est en cours
#   if { $panneau(acqfast,$visuNo,pose_en_cours) == 1 } {
#      return -1
#   }
#
#}
#***** Fin de la procedure stopTool ****************************






#------------------------------------------------------------
# testParametreAcquisition
#   Tests generaux d'integrite de la requete
#
# return
#   retourne oui ou non
#------------------------------------------------------------
proc ::acqfast::testParametreAcquisition { visuNo } {
   global audace caption panneau

   #--- Recopie de l'extension des fichiers image
   set ext $panneau(acqfast,$visuNo,extension)
   set camItem [ ::confVisu::getCamItem $visuNo ]

   #--- Desactive le bouton Go, pour eviter un double appui
   $panneau(acqfast,$visuNo,This).go_stop.but configure -state disabled

   #------ Tests generaux de l'integrite de la requete
   set integre oui

   #--- Tester si une camera est bien selectionnee
   if { [ ::confVisu::getCamItem $visuNo ] == "" } {
      ::audace::menustate disabled
      set choix [ tk_messageBox -title $caption(acqfast,pb) -type ok \
         -message $caption(acqfast,selcam) ]
      set integre non
      if { $choix == "ok" } {
         #--- Ouverture de la fenetre de selection des cameras
         ::confCam::run
      }
      ::audace::menustate normal
   }

   #--- Le temps de pose existe-t-il ?
   if { $panneau(acqfast,$visuNo,pose) == "" } {
      tk_messageBox -title $caption(acqfast,pb) -type ok \
         -message $caption(acqfast,saistps)
      set integre non
   }

   #--- Si mode FFR, il y a le framerate?
   if { $panneau(acqfast,$visuNo,mode) == "0" } {
      if { $panneau(acqfast,$visuNo,framerate) == "" } {
         tk_messageBox -title $caption(acqfast,pb) -type ok \
            -message $caption(acqfast,saisfr)
         set integre non
      }
   }

   #--- Apres les tests d'integrite, je reactive le bouton "Start/Pause"
   $panneau(acqfast,$visuNo,This).go_stop.but configure -state normal

   return $integre
}



#**** Fonctions du cycle de travail**********
proc ::acqfast::cycleinit { visuNo } {
   global panneau

   set panneau(acqfast,$visuNo,cycle,state) "WAIT"
   set panneau(acqfast,$visuNo,cycle,action) "0"
   set panneau(acqfast,$visuNo,cycle,golive) "0"
   #set panneau(acqfast,$visuNo,cycle,read_gps,end) 0
   #::gps::reset
   after 10 ::acqfast::cycleboucle $visuNo
}

#proc ::acqfast::run { visuNo } {
#
#      variable private
#      global panneau
#
#      set camNo $panneau(acqfast,$visuNo,camNo)
#
#      set s [ cam$camNo lastbuffer ]
#      puts $s
#      puts $panneau(acqfast,$visuNo,maxframe)
#      if { ($s > 0) && ($s < $panneau(acqfast,$visuNo,maxframe) } {
#         set panneau(acqfast,$visuNo,lastframe) $s
#         if { $panneau(acqfast,$visuNo,continu) == "1" } {
#            set panneau(acqfast,$visuNo,frame) $s
#            ::acqfast::display $visuNo $s
#         }
#      }
#
#      set l [ ::gps::fastread ]
#      if {( [ tsv::get gps first ] == 1 ) && ( $l != " " )} {
#         set l [lreplace $l 0 0]
#         tsv::set gps first "0"
#      }
#      set panneau(acqfast,$visuNo,date_gps,end) [concat $panneau(acqfast,$visuNo,date_gps,end) $l]
#
#}

proc ::acqfast::cyclegps { visuNo } {
   global panneau
   variable length

   set s [ cam$panneau(acqfast,$visuNo,camNo) lastbuffer ]
   if { ($s > 0) && ($s < $panneau(acqfast,$visuNo,maxframe)) } {
      set panneau(acqfast,$visuNo,lastframe) $s
      if { $panneau(acqfast,$visuNo,continu) == "1" } {
         set panneau(acqfast,$visuNo,frame) $s
         ::acqfast::display $visuNo $s
      }
   }

   set l [ ::gps::fastread ]

   set l0 {}
   set l1 {}
   # separation of the two dates in channel 0 and 1 into the two lists
   foreach a $l {
      set both [ split $a "X" ]
      set ch [ lindex $both 1 ]
      set date [ lindex $both 0 ]
      if { $ch == "1" } {
         lappend l1 $date
      } else {
         lappend l0 $date
      }
   }

   if { ( $panneau(acqfast,$visuNo,cycle,first,end) == "1" ) && ( $l0 != " " )} {
      set l0 [lreplace $l0 0 0]
      set panneau(acqfast,$visuNo,cycle,first,end) "0"
   }
   if { ( $panneau(acqfast,$visuNo,cycle,first,begin) == "1" ) && ( $l1 != " " )} {
      set l1 [lreplace $l1 0 0]
      set panneau(acqfast,$visuNo,cycle,first,begin) "0"
   }
   set panneau(acqfast,$visuNo,date_gps,end) [concat $panneau(acqfast,$visuNo,date_gps,end) $l0]
   set panneau(acqfast,$visuNo,date_gps,begin) [concat $panneau(acqfast,$visuNo,date_gps,begin) $l1]

   #set length 0
   foreach a $l1 b $l0 {
      Message $visuNo backup "%s %s\n" $a $b
      #incr length
   }

   foreach a $l {
      puts $a
   }

   #foreach a $l0 {
   #   puts $a
   #}
   #puts $l1
   #puts [ llength $l1 ]

   #puts [ concat "Length $length -- List length " [ llength $l ] ]
   return [ list [ llength $l0 ] [ llength $l1 ] ]

}

proc ::acqfast::cyclelive { visuNo } {
   global panneau

   if { $panneau(acqfast,$visuNo,continu) == "1" } {
      ::acqfast::display $visuNo $panneau(acqfast,$visuNo,maxframe)
   }

}

proc ::acqfast::cyclelivestart { visuNo } {
   global panneau

   set camNo $panneau(acqfast,$visuNo,camNo)

   if { [ string compare $panneau(acqfast,$visuNo,cycle,state) "WAIT" ] == "0" } {
      ::console::affiche_resultat "Starting live\n"
      #--- je verifie l'integrite des parametres
      #set integre [testParametreAcquisition $visuNo]
      #if { $integre != "oui" } {
      #   return
      #}

      #--- je configure la camera avec les parametres
      set conf_modes [ list "ffr" "itr" ]
      set mode [ lindex $conf_modes [ expr $panneau(acqfast,$visuNo,mode) ] ]
      cam$camNo videomode $mode
      if { $panneau(acqfast,$visuNo,mode) == "0" } {
         cam$camNo framerate $panneau(acqfast,$visuNo,framerate)
      }
      set panneau(acqfast,$visuNo,framerate) [ cam$camNo framerate ]
      cam$camNo exposure $panneau(acqfast,$visuNo,pose)
      set panneau(acqfast,$visuNo,pose) [ cam$camNo exposure ]
   }

   set panneau(acqfast,$visuNo,cycle,golive) "1"

   cam$camNo livestart

}

proc ::acqfast::cyclearretgps { visuNo acq r } {
   global panneau caption audace

   set length [ ::acqfast::cyclegps $visuNo ]
   set panneau(acqfast,$visuNo,cycle,read_gps,end) [ expr $panneau(acqfast,$visuNo,cycle,read_gps,end) + [ lindex $length 0 ] ]
   set panneau(acqfast,$visuNo,cycle,read_gps,begin) [ expr $panneau(acqfast,$visuNo,cycle,read_gps,begin) + [ lindex $length 1 ] ]

   #--- si la derniere image n'a pas ete lit, je efface sa date de la liste
   #puts $acq
   #puts $r
   set lastacq $panneau(acqfast,$visuNo,cycle,read_gps,end)
   set last [ expr [llength $panneau(acqfast,$visuNo,date_gps,end)] - 1 ]
   if { $lastacq > $r } {
      set cancel [ expr $lastacq-$r ]
      set panneau(acqfast,$visuNo,date_gps,end) [lreplace $panneau(acqfast,$visuNo,date_gps,end) [ expr $last-$cancel+1] $last]
   }

   #--- le meme pour la liste de debut, si elle existe
   if { $panneau(acqfast,$visuNo,date_gps,begin) != " " } {
      set lastacq $panneau(acqfast,$visuNo,cycle,read_gps,begin)
      set last [ expr [llength $panneau(acqfast,$visuNo,date_gps,begin)] - 1 ]
      if { $lastacq > $r } {
         set cancel [ expr $lastacq-$r ]
         set panneau(acqfast,$visuNo,date_gps,begin) [lreplace $panneau(acqfast,$visuNo,date_gps,begin) [ expr $last-$cancel+1] $last]
      }
   }


   if { $panneau(acqfast,$visuNo,cycle,action) == "1" } {
      #--- j'enregistre la pause de l'acquisition dans le fichier de log
      set heure $audace(tu,format,hmsint)
      Message $visuNo consolog $caption(acqfast,pauselog) $heure $panneau(acqfast,$visuNo,lastframe)
   } elseif { $panneau(acqfast,$visuNo,cycle,action) == "2" } {
      #--- j'enregistre la fin de l'acquisition dans le fichier de log
      set heure $audace(tu,format,hmsint)
      Message $visuNo consolog $caption(acqfast,stoplog) $heure $panneau(acqfast,$visuNo,lastframe)
   }

   #foreach a $panneau(acqfast,$visuNo,date_gps,end) {
   #   Message $visuNo backup "%s\n" $a
   #}

   Message $visuNo backup "Last valid framebuffer: %d\n" $panneau(acqfast,$visuNo,lastframe)
   Message $visuNo backup "Stop frame: %d\n" $panneau(acqfast,$visuNo,lastframe)

}

proc ::acqfast::cyclecamstart { visuNo } {
   global panneau audace caption
   variable local

   set camNo $panneau(acqfast,$visuNo,camNo)


   if { [ string compare $panneau(acqfast,$visuNo,cycle,state) "WAIT" ] == "0" || $panneau(acqfast,$visuNo,cycle,golive) == "1" }  {
      ::console::affiche_resultat "Starting again\n"
      #--- je verifie l'integrite des parametres
      #set integre [testParametreAcquisition $visuNo]
      #if { $integre != "oui" } {
      #   return
      #}

      set panneau(acqfast,$visuNo,cycle,golive) "0"

      #--- je configure la camera avec les parametres
      set conf_modes [ list "ffr" "itr" ]
      set mode [ lindex $conf_modes [ expr $panneau(acqfast,$visuNo,mode) ] ]
      cam$camNo videomode $mode
      if { $panneau(acqfast,$visuNo,mode) == "0" } {
         cam$camNo framerate $panneau(acqfast,$visuNo,framerate)
      }
      set panneau(acqfast,$visuNo,framerate) [ cam$camNo framerate ]
      cam$camNo exposure $panneau(acqfast,$visuNo,pose)
      set panneau(acqfast,$visuNo,pose) [ cam$camNo exposure ]

      #--- je prends la valeur des parametres ROI et bin
      set local(roi) [ cam$camNo roi ]
      set local(bin) [ cam$camNo bin ]

      #--- j'enregistre le debut de l'acquisition dans le fichier de log
      set heure $audace(tu,format,hmsint)
      set startframe [cam$camNo currentbuffer]
      Message $visuNo consolog $caption(acqfast,startlog) $heure $panneau(acqfast,$visuNo,pose) $mode $panneau(acqfast,$visuNo,framerate) $startframe

      #--- Ouverture du fichier de backup (s'il est deja ouvert, on le ferme)
      if { [ info exists ::acqfast::backup_id($visuNo) ] && [ file exists $::acqfast::fichier_backup ] } {
         close $::acqfast::backup_id($visuNo)
      }
      if { [ catch { open $::acqfast::fichier_backup w } ::acqfast::backup_id($visuNo) ] } {
         Message $visuNo console $caption(acqfast,pbouvfichbackcons)
         tk_messageBox -title $caption(acqfast,pb) -type ok \
            -message $caption(acqfast,pbouvfichbackcons)
      }

      #--- j'enregistre les parametres de l'acquisition dans le fichier de backup
      Message $visuNo backup "Start frame: %d\nExposition time: %f\nMode: %s\nFrame rate: %f\nROI: %s\nBin: %s\n" $startframe $panneau(acqfast,$visuNo,pose) $mode $panneau(acqfast,$visuNo,framerate) $local(roi) $local(bin)

   } else {
      #--- j'enregistre la reprise de l'acquisition dans le fichier de log
      set heure $audace(tu,format,hmsint)
      set startframe [cam$camNo currentbuffer]
      Message $visuNo consolog $caption(acqfast,resumelog) $heure $startframe
   }

   ::gps::reset
   set panneau(acqfast,$visuNo,cycle,read_gps,end) 0
   set panneau(acqfast,$visuNo,cycle,read_gps,begin) 0

   set panneau(acqfast,$visuNo,cycle,first,begin) "1"
   set panneau(acqfast,$visuNo,cycle,first,end) "1"
   set panneau(acqfast,$visuNo,unsaved_seq) "1"

   cam$camNo videostart

}

proc ::acqfast::cycleboucle { visuNo } {
   global panneau caption audace
   global state

   switch $panneau(acqfast,$visuNo,cycle,state) {
      "WAIT" { switch $panneau(acqfast,$visuNo,cycle,action) {
               "1" {
                     set panneau(acqfast,$visuNo,date_gps,end) ""
                     set panneau(acqfast,$visuNo,date_gps,begin) ""
                     #set panneau(acqfast,$visuNo,cycle,read_gps,end) 0
                     ::acqfast::cyclecamstart $visuNo
                     set panneau(acqfast,$visuNo,cycle,state) "GPS"
                     set panneau(acqfast,$visuNo,cycle,action) "0"                   }
               "2" {
                     set panneau(acqfast,$visuNo,cycle,action) "0"
                   }
               "3" {
                     set panneau(acqfast,$visuNo,date_gps,end) ""
                     set panneau(acqfast,$visuNo,date_gps,begin) ""
                     ::acqfast::cyclelivestart $visuNo
                     set panneau(acqfast,$visuNo,cycle,state) "LIVE"
                     set panneau(acqfast,$visuNo,cycle,action) "0"
                   }
               default {
                     #set panneau(acqfast,$visuNo,cycle,action) "0"
                   }
               }
               #puts "WAIT"
             }
      "GPS"  { switch $panneau(acqfast,$visuNo,cycle,action) {
               "1" {
                     set c [ cam$panneau(acqfast,$visuNo,camNo) videopause ]
                     ::acqfast::cyclearretgps $visuNo {*}$c
                     puts [ concat $panneau(acqfast,$visuNo,cycle,read_gps,begin) " " $panneau(acqfast,$visuNo,cycle,read_gps,end) " " $c ]
                     cam$panneau(acqfast,$visuNo,camNo) livestart
                     set panneau(acqfast,$visuNo,cycle,state) "LIVE"
                     set panneau(acqfast,$visuNo,cycle,action) "0"
                   }
               "2" {
                     set c [ cam$panneau(acqfast,$visuNo,camNo) videostop ]
                     ::acqfast::cyclearretgps $visuNo {*}$c
                     puts [ concat $panneau(acqfast,$visuNo,cycle,read_gps,begin) " " $panneau(acqfast,$visuNo,cycle,read_gps,end) " " $c ]
                     set panneau(acqfast,$visuNo,cycle,state) "WAIT"
                     set panneau(acqfast,$visuNo,cycle,action) "0"
                   }
                default {
                     set length [ ::acqfast::cyclegps $visuNo ]
                     set panneau(acqfast,$visuNo,cycle,read_gps,end) [ expr $panneau(acqfast,$visuNo,cycle,read_gps,end) + [ lindex $length 0 ] ]
                     set panneau(acqfast,$visuNo,cycle,read_gps,begin) [ expr $panneau(acqfast,$visuNo,cycle,read_gps,begin) + [ lindex $length 1 ] ]

                     #set panneau(acqfast,$visuNo,cycle,action) "0"
                   }
                }
                #puts "GPS"
             }
      "LIVE" { switch $panneau(acqfast,$visuNo,cycle,action) {
               "1" {
                     cam$panneau(acqfast,$visuNo,camNo) livestop
                     #::gps::reset
                     #set panneau(acqfast,$visuNo,cycle,read_gps,end) 0
                     ::acqfast::cyclecamstart $visuNo
                     set panneau(acqfast,$visuNo,cycle,state) "GPS"
                     set panneau(acqfast,$visuNo,cycle,action) "0"
                   }
               "2" {
                     #--- j'enregistre la fin de l'acquisition dans le fichier de log
                     set heure $audace(tu,format,hmsint)
                     Message $visuNo consolog $caption(acqfast,stoplog) $heure $panneau(acqfast,$visuNo,lastframe)

                     #cam$panneau(acqfast,$visuNo,camNo) livestop
                     cam$panneau(acqfast,$visuNo,camNo) videostop
                     ::gps::reset
                     set panneau(acqfast,$visuNo,cycle,state) "WAIT"
                     set panneau(acqfast,$visuNo,cycle,action) "0"
                   }
                default {
                     ::acqfast::cyclelive $visuNo
                     #set panneau(acqfast,$visuNo,cycle,action) "0"
                   }
                }
                #puts "LIVE"
             }
    }

   after 250 ::acqfast::cycleboucle $visuNo

}
#****** Fin fonction du cycle *************



#***** Procedure Start (appui sur le bouton Start/Pause) *********
proc ::acqfast::Start { visuNo } {

   global audace caption panneau
   variable local


   set camItem [::confVisu::getCamItem $visuNo]
   set camNo $panneau(acqfast,$visuNo,camNo)

   set local(visuNo) $visuNo

   if { $panneau(acqfast,$visuNo,unsaved_seq) == 1 && ( $panneau(acqfast,$visuNo,cycle,state) == "WAIT" || $panneau(acqfast,$visuNo,cycle,golive) == "1" ) } {
      set confirmation [tk_messageBox -title $caption(acqfast,conf) -type yesno \
         -message "$caption(acqfast,unsaved_seq)"]
      if { $confirmation == "no" } {
         return
      }
   }

   #--- Ouverture du fichier historique
   #if { $panneau(acqfast,$visuNo,save_file_log) == "1" } {
   #   if { $panneau(acqfast,$visuNo,session_ouverture) == "1" } {
   #      Demarrageacqfast $visuNo
   #      set panneau(acqfast,$visuNo,session_ouverture) "0"
   #   }
   #}

   #--- je verifie l'integrite des parametres
   set integre [testParametreAcquisition $visuNo]
   if { $integre != "oui" } {
      return
   }

   #--- je configure la camera avec les parametres
   #set conf_modes [ list "ffr" "itr" ]
   #set mode [ lindex $conf_modes [ expr $panneau(acqfast,$visuNo,mode) ] ]
   #cam$camNo videomode $mode
   #if { $panneau(acqfast,$visuNo,mode) == "0" } {
   #   cam$camNo framerate $panneau(acqfast,$visuNo,framerate)
   #}
   #cam$camNo exposure $panneau(acqfast,$visuNo,pose)

   #--- modification du bouton, pour eviter un second lancement
   $panneau(acqfast,$visuNo,This).go_stop.but configure -text $caption(acqfast,pause) -command "::acqfast::Pause $visuNo"
   #--- verrouille tous les boutons et champs de texte pendant les acquisitions
   $panneau(acqfast,$visuNo,This).pose.entr configure -state disabled
   $panneau(acqfast,$visuNo,This).video.mode.but configure -state disabled
   $panneau(acqfast,$visuNo,This).video.framerate.entr configure -state disabled
   #$panneau(acqfast,$visuNo,This).display.case configure -state disabled
   $panneau(acqfast,$visuNo,This).save.but configure -state disabled
   $panneau(acqfast,$visuNo,This).display.frame.entr configure -state disabled
   $panneau(acqfast,$visuNo,This).display.prev_next.prev configure -state disabled
   $panneau(acqfast,$visuNo,This).display.prev_next.next configure -state disabled
   $panneau(acqfast,$visuNo,This).display.but configure -state disabled
   $panneau(acqfast,$visuNo,This).display.live.but configure -state disabled

   #--- la derniere image acquis est la premiere
   #set panneau(acqfast,$visuNo,lastbuffer) "1"

   #--- prend le frame maximale
   set panneau(acqfast,$visuNo,maxframe) [ cam$camNo maxbuffer ]
   #puts $panneau(acqfast,$visuNo,maxframe)

   #--- si on commence un nuveau video, vide la liste des dates
   #if { $panneau(acqfast,$visuNo,video_en_cours) == "0" } {
   #}

   #--- video en cours
   #set panneau(acqfast,$visuNo,video_en_cours) "1"

   #::gps::fastread

   #---thread
   #tsv::set gps stop "0"
   #tsv::set gps first "1"
   #thread::send -async $panneau(acqfast,$visuNo,threadid) [ ::acqfast::boucle $visuNo ]

   #--- je commence le video
   #cam$camNo videostart
   set panneau(acqfast,$visuNo,cycle,action) "1"


}

#***** Fin de la procedure de lancement d'acquisition **********







#------------------------------------------------------------
# Stop
#     appui sur le bouton Stop
#
# Parameters
#  visuNo  : numero de la visu associee a la camera
#
# Return
#    rien
#------------------------------------------------------------
proc ::acqfast::Stop { visuNo } {
   global audace caption panneau

   #set camNo $panneau(acqfast,$visuNo,camNo)

   #set panneau(acqfast,$visuNo,cycle,action) "2"

   #--- si on est dans le mode live, il se limite a l'arreter
   #if { [ tsv::get video live ] == "1" } {
   #   set count [cam$camNo livestop]
   #   thread::send -async $panneau(acqfast,$visuNo,threadid) [ thread::wait ]
   #   tsv::set video live "0"
   #} elseif { [ tsv::get gps stop ] == "0" } {
   #   #--- arret de l'acquisition
   #   set count [ cam$camNo videostop ]
   #   set panneau(acqfast,$visuNo,lastframe) [ cam$camNo lastbuffer ]
   #   set ::acqfast::local(lastframe) $panneau(acqfast,$visuNo,lastframe)
   #   set panneau(acqfast,$visuNo,video_en_cours) "0"

   #   tsv::set gps stop "1"

      #after 10 ::acqfast::run $visuNo

      #--- si la derniere image n'a pas ete lit, je efface sa date de la liste
   #   set acq [lindex $count 0]
   #   set r [lindex $count 1]
   #   set lastacq [expr $acq-1]
   #   set last [ expr [llength $panneau(acqfast,$visuNo,date_gps,end)] - 1 ]
   #   if { $lastacq > $r } {
   #      set cancel [ expr $lastacq-$r ]
   #      set panneau(acqfast,$visuNo,date_gps,end) [lreplace $panneau(acqfast,$visuNo,date_gps,end) [ expr $last-$cancel+1] $last]
   #   }

   #}

   #--- je reactive les parametres de configuration
   $panneau(acqfast,$visuNo,This).pose.entr configure -state normal
   $panneau(acqfast,$visuNo,This).video.mode.but configure -state normal
   $panneau(acqfast,$visuNo,This).video.framerate.entr configure -state normal
   #$panneau(acqfast,$visuNo,This).display.case configure -state normal
   $panneau(acqfast,$visuNo,This).display.frame.entr configure -state normal
   $panneau(acqfast,$visuNo,This).display.prev_next.prev configure -state normal
   $panneau(acqfast,$visuNo,This).display.prev_next.next configure -state normal
   $panneau(acqfast,$visuNo,This).display.but configure -state normal
   $panneau(acqfast,$visuNo,This).save.but configure -state normal
   $panneau(acqfast,$visuNo,This).display.live.but configure -state normal
   #--- je reactive la fonction Start dans le bouton
   $panneau(acqfast,$visuNo,This).go_stop.but configure -text $caption(acqfast,start) -command "::acqfast::Start $visuNo"
   $panneau(acqfast,$visuNo,This).display.live.but configure -text $caption(acqfast,live) -command "::acqfast::Live $visuNo"

   #---je signale que on est pas dans une session d'acquisition
   #set panneau(acqfast,$visuNo,video_en_cours) "0"

   set panneau(acqfast,$visuNo,cycle,action) "2"

}
#***** Fin de la procedure Stop *****************************


#------------------------------------------------------------
# Pause
#     appui sur le bouton Start/Pause
#
# Parameters
#  visuNo  : numero de la visu associee a la camera
#
# Return
#    rien
#------------------------------------------------------------
proc ::acqfast::Pause { visuNo } {
   global audace caption panneau

   set camNo $panneau(acqfast,$visuNo,camNo)

   #--- pause de l'acquisition
   #set count [ cam$camNo videopause ]
   #set panneau(acqfast,$visuNo,lastframe) [ cam$camNo lastbuffer ]
   #set ::acqfast::local(lastframe) $panneau(acqfast,$visuNo,lastframe)

   #--- je reactive la fonction Start dans le bouton
   $panneau(acqfast,$visuNo,This).go_stop.but configure -text $caption(acqfast,start) -command "::acqfast::Start $visuNo"
   #--- je reactive la possibilite de voir les images en continu
   #$panneau(acqfast,$visuNo,This).display.case configure -state normal

   #tsv::set gps stop "1"

   #--- si la derniere image n'a pas ete lit, je efface sa date de la liste
   #set acq [lindex $count 0]
   #set r [lindex $count 1]
   #set lastacq [expr $acq-1]
   #set last [ expr [llength $panneau(acqfast,$visuNo,date_gps,end)] - 1 ]
   #if { $lastacq > $r } {
   #   set cancel [ expr $lastacq-$r ]
   #   set panneau(acqfast,$visuNo,date_gps,end) [lreplace $panneau(acqfast,$visuNo,date_gps,end) [ expr $last-$cancel+1 ] $last]
   #}

   #--- Selectionne le maximum framebuffer (pour le mode live)
   #set panneau(acqfast,$visuNo,maxframe) [cam$panneau(acqfast,$visuNo,camNo) maxbuffer]

   #--- je commence le mode live
   #tsv::set video live "1"
   #thread::send -async $panneau(acqfast,$visuNo,livethreadid) [ ::acqfast::liveboucle $visuNo ]

   set panneau(acqfast,$visuNo,cycle,action) "1"




}
#***** Fin de la procedure Start/Pause *****************************


#***** Procedure Live (appui sur le bouton live) *********
proc ::acqfast::Live { visuNo } {

   global audace caption panneau
   variable local


   set camItem [::confVisu::getCamItem $visuNo]
   set camNo $panneau(acqfast,$visuNo,camNo)

   set local(visuNo) $visuNo




   #--- je verifie l'integrite des parametres
   set integre [testParametreAcquisition $visuNo]
   if { $integre != "oui" } {
      return
   }

   #--- je configure la camera avec les parametres
   set conf_modes [ list "ffr" "itr" ]
   set mode [ lindex $conf_modes [ expr $panneau(acqfast,$visuNo,mode) ] ]
   #cam$camNo videomode $mode
   #if { $panneau(acqfast,$visuNo,mode) == "0" } {
   #   cam$camNo framerate $panneau(acqfast,$visuNo,framerate)
   #}
   #cam$camNo exposure $panneau(acqfast,$visuNo,pose)

   #--- modification du bouton, pour eviter un second lancement
   $panneau(acqfast,$visuNo,This).display.live.but configure -text $caption(acqfast,stoplive) -command "::acqfast::Stop $visuNo"
   #--- verrouille tous les boutons et champs de texte pendant les acquisitions
   $panneau(acqfast,$visuNo,This).pose.entr configure -state disabled
   $panneau(acqfast,$visuNo,This).video.mode.but configure -state disabled
   $panneau(acqfast,$visuNo,This).video.framerate.entr configure -state disabled
   $panneau(acqfast,$visuNo,This).save.but configure -state disabled
   $panneau(acqfast,$visuNo,This).display.frame.entr configure -state disabled
   $panneau(acqfast,$visuNo,This).display.prev_next.prev configure -state disabled
   $panneau(acqfast,$visuNo,This).display.prev_next.next configure -state disabled
   $panneau(acqfast,$visuNo,This).display.but configure -state disabled


   #--- prend le frame maximale
   set panneau(acqfast,$visuNo,maxframe) [ cam$camNo maxbuffer ]
   #puts $panneau(acqfast,$visuNo,maxframe)

   set panneau(acqfast,$visuNo,cycle,action) "3"


}

#***** Fin de la procedure de lancement d'acquisition **********




#***** Changement du mode video ***********
proc ::acqfast::ChangeMode { visuNo } {
   global panneau

   set camNo $panneau(acqfast,$visuNo,camNo)

   set modes [list "ffr" "itr"]
   set panneau(acqfast,$visuNo,mode) [lsearch $panneau(acqfast,$visuNo,list_mode) "$panneau(acqfast,$visuNo,mode_en_cours)"]
   set mode [lindex $modes $panneau(acqfast,$visuNo,mode)]

   if { $mode == "ffr" } {
      $panneau(acqfast,$visuNo,This).video.framerate.entr configure -state normal
   } else {
      $panneau(acqfast,$visuNo,This).video.framerate.entr configure -state disabled
   }

   if {  [ ::confVisu::getCamItem $visuNo ] == "" } {
   } else {
      cam$camNo videomode $mode
   }

}
#***** Fin changement du mode video **********


#***** Procedure d'ouverture de la connection GPS
proc ::acqfast::gps_open { visuNo } {

   global panneau

   set err [::gps::open]
   if {!$err} {
          $panneau(acqfast,$visuNo,This).gps.but configure -bg "green"
   } else {
          $panneau(acqfast,$visuNo,This).gps.but configure -bg "red"
   }
}
#***** Fin de la procedure d'ouverture de la connection GPS







#***** Procedure de sauvegarde des images **********************
proc ::acqfast::SauveImages { visuNo } {
   global audace caption panneau
   variable local

   #--- Tests d'integrite de la requete
   #--- Verifier qu'il y a bien un nom de fichier
   if { $panneau(acqfast,$visuNo,object) == "" } {
      tk_messageBox -title $caption(acqfast,pb) -type ok \
         -message $caption(acqfast,donnomfich)
      return
   }
   #--- Verifier que le nom de fichier n'a pas d'espace
   if { [ llength $panneau(acqfast,$visuNo,object) ] > "1" } {
      tk_messageBox -title $caption(acqfast,pb) -type ok \
         -message $caption(acqfast,nomblanc)
      return
   }
   #--- Verifier qu'il y a bien un index
   #if { $panneau(acqfast,$visuNo,index) == "" } {
   #   tk_messageBox -title $caption(acqfast,pb) -type ok \
   #      -message $caption(acqfast,saisind)
   #   return
   #}

   #--- Generer le nom du fichier
   set nom "$panneau(acqfast,$visuNo,object)"
   ::console::affiche_resultat "nom = $nom\n"

   #--- Pour eviter un nom de fichier qui commence par un blanc
   set nom [lindex $nom 0]

   #--- Verrouille les controls pendant l'enregistrement
   $panneau(acqfast,$visuNo,This).save.but configure -state disabled
   $panneau(acqfast,$visuNo,This).save.name.entr configure -state disabled
   #$panneau(acqfast,$visuNo,This).save.index.entr configure -state disabled
   #$panneau(acqfast,$visuNo,This).save.index.but configure -state disabled
   #--- je verrouille les bouton de debut et fin d'acquisition
   $panneau(acqfast,$visuNo,This).go_stop.but configure -state disabled
   $panneau(acqfast,$visuNo,This).stop.but configure -state disabled
   $panneau(acqfast,$visuNo,This).display.live.but configure -state disabled

   #--- si on verifie l'existence du fichier, initialise ecrase a zero
   #--- ecrase : 0 - a demander, 1 - ecrase, -1 - n'enregistre pas si le fichier existe deja
   #if { $panneau(acqfast,$visuNo,verifier_ecraser_fichier) == 1 } {
   #   set ecrase 0
   #} else {
   #   set ecrase 1
   #}

   #--- numero de buffer et de camera
   set camNo $panneau(acqfast,$visuNo,camNo)
   set bufNo [ ::confVisu::getBufNo $visuNo ]

   #--- informations pour l'entete FITS
   set bin [cam$camNo bin]
   set roi [cam$camNo roi]
   set exposure [cam$camNo exposure]
   set mode [cam$camNo videomode]
   if { $mode == "Fixed Frame Rate" } {
      set videomode "Fixed Frame Rate"
      set framerate [cam$camNo framerate]
   } else {
      set videomode "Integrate Then Read"
      set framerate [cam$camNo maxframerate]
   }


   set curbuf 1
   set panneau(acqfast,$visuNo,enreg_en_cours) 1

   set numlength [expr int(log10($panneau(acqfast,$visuNo,lastframe))) + 1]

   for {} { $curbuf <= $panneau(acqfast,$visuNo,lastframe) } { set curbuf [expr $curbuf + 1] } {
      set panneau(acqfast,$visuNo,index) $curbuf
      set noml $nom
      append noml [format "_%.0${numlength}d" $panneau(acqfast,$visuNo,index)]

      #--- Verifier que le nom du fichier n'existe pas
      set nom1 $noml
      append nom1 $panneau(acqfast,$visuNo,extension)
      if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" && $panneau(acqfast,$visuNo,verifier_ecraser_fichier) == 1 } {
         #--- Dans ce cas, le fichier existe deja...
         set confirmation [tk_messageBox -title $caption(acqfast,conf) -type yesno \
            -message "$caption(acqfast,fichdeja_1) $nom1 $caption(acqfast,fichdeja_2)"]
         if { $confirmation == "no" } {
            set panneau(acqfast,$visuNo,enreg_en_cours) "0"
            ::acqfast::avancementEnreg $visuNo $curbuf
            return
         }
      }

      #--- Charge le framebuffer
      cam$camNo getframebuffer $curbuf

      #--- Mots cles de l'en-tete FITS
      buf$bufNo setkwd [list BIN1 [lindex $bin 0] int "" ""]
      buf$bufNo setkwd [list BIN2 [lindex $bin 1] int "" ""]
      buf$bufNo setkwd [list ROI_X1 [lindex $roi 0] int "" ""]
      buf$bufNo setkwd [list ROI_Y1 [lindex $roi 1] int "" ""]
      buf$bufNo setkwd [list ROI_X2 [lindex $roi 2] int "" ""]
      buf$bufNo setkwd [list ROI_Y2 [lindex $roi 3] int "" ""]
      #buf$bufNo setkwd [list EXPOSURE $exposure float "" ""]
      #buf$bufNo setkwd [list VIDEOMODE "$videomode" string "" ""]
      #buf$bufNo setkwd [list FRAMERATE "$framerate" float "" ""]
      #--- je recupere la date GPS et celle imprime par le driver
      set datepc [cam$camNo getbufferts $curbuf]
      set dategps [ lindex $panneau(acqfast,$visuNo,date_gps,end) [expr $curbuf-1] ]
      set dateobsgps [ lindex $panneau(acqfast,$visuNo,date_gps,begin) [expr $curbuf-1] ]
      ::gps::getdate $bufNo $dategps $datepc $exposure $dateobsgps
      #--- je rajoute les mots cles dans l'en-tete FITS
      foreach keyword [ ::keyword::getKeywords $visuNo $::conf(acqfast,keywordConfigName) ] {
         buf$bufNo setkwd $keyword
      }

      #--- Sauvegarde de l'image
      saveima [append noml $panneau(acqfast,$visuNo,extension)] $visuNo

      #--- Mis a jour de l'avancement
      ::acqfast::avancementEnreg $visuNo $curbuf

   }

   set panneau(acqfast,$visuNo,enreg_en_cours) "0"
   ::acqfast::avancementEnreg $visuNo $curbuf

   #--- la sequence a ete enregistre
   set panneau(acqfast,$visuNo,unsaved_seq) "0"

   #--- je reactive les boutons
   $panneau(acqfast,$visuNo,This).save.but configure -state normal
   $panneau(acqfast,$visuNo,This).save.name.entr configure -state normal
   #$panneau(acqfast,$visuNo,This).save.index.entr configure -state normal
   #$panneau(acqfast,$visuNo,This).save.index.but configure -state normal
   $panneau(acqfast,$visuNo,This).display.live.but configure -state normal
   #--- je reactive les boutons de debut et fin d'acquisition
   $panneau(acqfast,$visuNo,This).go_stop.but configure -state normal
   $panneau(acqfast,$visuNo,This).stop.but configure -state normal

   #--- Fermeture et effacement du fichier de backup
   if { [ file exists $::acqfast::fichier_backup ] } {
      close $::acqfast::backup_id($visuNo)
      file delete $::acqfast::fichier_backup
   }



}
#***** Fin de la procedure de sauvegarde de l' image *************

#***** Procedure d'affichage d'une barre de progression ********
proc ::acqfast::avancementEnreg { visuNo { buf } } {
   global caption color panneau

   if { $panneau(acqfast,$visuNo,enreg_en_cours) == 0 } {
      #--- je supprime la fenetre s'il n'y a plus de pose en cours
      destroy $panneau(acqfast,$visuNo,base).progress
      return
   }


   #--- Recuperation de la position de la fenetre
   ::acqfast::recup_position $visuNo

   #---
   if { [ winfo exists $panneau(acqfast,$visuNo,base).progress ] != "1" } {

      #--- Cree la fenetre toplevel
      toplevel $panneau(acqfast,$visuNo,base).progress
      wm transient $panneau(acqfast,$visuNo,base).progress $panneau(acqfast,$visuNo,base)
      wm resizable $panneau(acqfast,$visuNo,base).progress 0 0
      wm title $panneau(acqfast,$visuNo,base).progress "$caption(acqfast,enreg_en_cours)"
      wm geometry $panneau(acqfast,$visuNo,base).progress $panneau(acqfast,$visuNo,avancement,position)

      #--- Cree le widget et le label des buffer a enregistrer
      label $panneau(acqfast,$visuNo,base).progress.lab_status -text "" -justify center
      pack $panneau(acqfast,$visuNo,base).progress.lab_status -side top -fill x -expand true -pady 5

      #---
      $panneau(acqfast,$visuNo,base).progress.lab_status configure -text "$caption(acqfast,buffer) $buf $caption(acqfast,of) $panneau(acqfast,$visuNo,lastframe)"
      set relbuf [ expr double($buf) / double($panneau(acqfast,$visuNo,lastframe)) ]

      catch {
         #--- Cree le widget pour la barre de progression
         frame $panneau(acqfast,$visuNo,base).progress.cadre -width 200 -height 30 -borderwidth 2 -relief groove
         pack $panneau(acqfast,$visuNo,base).progress.cadre -in $panneau(acqfast,$visuNo,base).progress -side top \
            -anchor center -fill x -expand true -padx 8 -pady 8

         #--- Affiche de la barre de progression
         frame $panneau(acqfast,$visuNo,base).progress.cadre.barre_color_invariant -height 26 -bg $color(blue)
         place $panneau(acqfast,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(acqfast,$visuNo,base).progress.cadre -x 0 -y 0 \
            -relwidth [ expr $relbuf ]
         update
      }

      #--- Mise a jour dynamique des couleurs
      if { [ winfo exists $panneau(acqfast,$visuNo,base).progress ] == "1" } {
         ::confColor::applyColor $panneau(acqfast,$visuNo,base).progress
      }

   } else {
      $panneau(acqfast,$visuNo,base).progress.lab_status configure -text "$caption(acqfast,buffer) $buf $caption(acqfast,of) $panneau(acqfast,$visuNo,lastframe)"
      set relbuf [ expr double($buf) / double($panneau(acqfast,$visuNo,lastframe)) ]

      #--- Met a jour la barre de progression
      place $panneau(acqfast,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(acqfast,$visuNo,base).progress.cadre -x 0 -y 0 \
         -relwidth [ expr $relbuf ]
      update
   }

}
#***** Fin de la procedure d'avancement de la pose *************

#***** Enregistrement de la position de la fenetre Avancement ********
proc ::acqfast::recup_position { visuNo } {
   global panneau

   #--- Cas de la fenetre Avancement
   if [ winfo exists $panneau(acqfast,$visuNo,base).progress ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqfast,$visuNo,base).progress ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set panneau(acqfast,$visuNo,avancement,position) "+[ string range $geometry $deb $fin ]"
   }
}
#***** Fin enregistrement de la position de la fenetre Avancement ****












#***** Procedure d'affichage des messages ************************
#--- Cette procedure est recopiee de methking.tcl, elle permet l'affichage de differents
#--- messages (dans la console, le fichier log, etc.)
proc ::acqfast::Message { visuNo niveau args } {
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
            puts -nonewline $::acqfast::log_id($visuNo) [eval [concat {format} $args]]
            #--- Force l'ecriture immediate sur le disque
            flush $::acqfast::log_id($visuNo)
         }
      }
      consolog {
         if { $panneau(acqfast,$visuNo,messages) == "1" } {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         set temps [clock format [clock seconds] -format %H:%M:%S]
         append temps " "
         catch {
            puts -nonewline $::acqfast::log_id($visuNo) [eval [concat {format} $args]]
            #--- Force l'ecriture immediate sur le disque
            flush $::acqfast::log_id($visuNo)
         }
      }
      backup {
         catch {
            puts -nonewline $::acqfast::backup_id($visuNo) [eval [concat {format} $args]]
            #--- Force l'ecriture immediate sur le disque
            flush $::acqfast::backup_id($visuNo)
        }
      }
      default {
         set b [ list "%s\n" $caption(acqfast,pbmesserr) ]
         ::console::disp [ eval [ concat {format} $b ] ]
         update idletasks
      }
   }
}
#***** Fin de la procedure d'affichage des messages ***************







#***** Enregistrement de la position de la fenetre Avancement ********
proc ::acqfast::recup_position_1 { visuNo } {
   global panneau

   #--- Cas de la fenetre Avancement
   if [ winfo exists $panneau(acqfast,$visuNo,base).progress ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $panneau(acqfast,$visuNo,base).progress ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set panneau(acqfast,$visuNo,avancement,position) "+[ string range $geometry $deb $fin ]"
   }
}
#***** Fin enregistrement de la position de la fenetre Avancement ****


#***** Montre l'imege choisi *****
proc ::acqfast::display { visuNo frnum } {

   global panneau

   set camNo $panneau(acqfast,$visuNo,camNo)

   cam$camNo getframebuffer $frnum
   ::confVisu::autovisu $visuNo

}
#***** Fin montre l'image choisi *********

#***** Montre l'image precedente *******
proc ::acqfast::prec { visuNo } {

   global panneau

   set camNo $panneau(acqfast,$visuNo,camNo)

   if { $panneau(acqfast,$visuNo,frame) > 1 } {
      set panneau(acqfast,$visuNo,frame) [ expr ( $panneau(acqfast,$visuNo,frame) - 1 ) ]
   }

   cam$camNo getframebuffer $panneau(acqfast,$visuNo,frame)
   ::confVisu::autovisu $visuNo

}
#***** Fin montre l'image precedente ********

#***** Montre l'image suivante *******
proc ::acqfast::succ { visuNo } {

   global panneau

   set camNo $panneau(acqfast,$visuNo,camNo)

   if { $panneau(acqfast,$visuNo,frame) < $panneau(acqfast,$visuNo,lastframe) } {
      set panneau(acqfast,$visuNo,frame) [ expr ( $panneau(acqfast,$visuNo,frame) + 1 ) ]
   }

   cam$camNo getframebuffer $panneau(acqfast,$visuNo,frame)
   ::confVisu::autovisu $visuNo

}
#***** Fin montre l'image suivante ********


#***** Procedure pour designer le fichier du cycle
proc ::acqfast::browse { visuNo } {
   global audace panneau caption

   set parent $audace(base)

   set panneau(acqfast,$visuNo,cycfile) [ tk_getOpenFile -title "$caption(acqfast,folder)" \
      -initialdir $audace(rep_images) -parent $parent ]

}
#***** Fin procedure pout designer le fichier du cycle


proc ::acqfast::acqfastBuildIF { visuNo } {
   global audace caption conf panneau
   variable local

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   set local(lastframe) $panneau(acqfast,$visuNo,lastframe)
   set local(maxframerate) $panneau(acqfast,$visuNo,maxframerate)
   set local(maxpose) $panneau(acqfast,$visuNo,maxpose)

   #--- Trame des informations
   #frame $panneau(acqfast,$visuNo,This) -borderwidth 2 -relief groove
   #   label $panneau(acqfast,$visuNo,This).lab -text "infoinfoinfoinfoinfoinfoinfoinfoinfoinfoinfoinfoinfo" -pady 0
   #   pack $panneau(acqfast,$visuNo,This).lab -fill x -side left
   #pack $panneau(acqfast,$visuNo,This) -side top -fill x

   frame $panneau(acqfast,$visuNo,This) -borderwidth 2 -relief groove

   #--- Trame du titre du panneau
   frame $panneau(acqfast,$visuNo,This).titre -borderwidth 2 -relief groove
      Button $panneau(acqfast,$visuNo,This).titre.but -borderwidth 1 \
         -text "$caption(acqfast,help_titre1)\n$caption(acqfast,titre)" \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqfast::getPluginType ] ] \
            [ ::acqfast::getPluginDirectory ] [ ::acqfast::getPluginHelp ]"
      pack $panneau(acqfast,$visuNo,This).titre.but -side top -fill x -in $panneau(acqfast,$visuNo,This).titre -ipadx 5
      DynamicHelp::add $panneau(acqfast,$visuNo,This).titre.but -text $caption(acqfast,help_titre)
   pack $panneau(acqfast,$visuNo,This).titre -side top -fill x

   #--- Trame du bouton de configuration
   frame $panneau(acqfast,$visuNo,This).config -borderwidth 2 -relief groove
      button $panneau(acqfast,$visuNo,This).config.but -borderwidth 1 -text $caption(acqfast,configuration) \
        -command "::acqfastSetup::run $visuNo $base.acqfastSetup"
      pack $panneau(acqfast,$visuNo,This).config.but -side top -fill x -in $panneau(acqfast,$visuNo,This).config -ipadx 5 -ipady 4
   pack $panneau(acqfast,$visuNo,This).config -side top -fill x

   #--- Trame du bouton d appel a Gps
   frame $panneau(acqfast,$visuNo,This).gps -borderwidth 2 -relief groove
      button $panneau(acqfast,$visuNo,This).gps.but -borderwidth 1 -text $caption(acqfast,gps) -command "::acqfast::gps_open $visuNo"
      pack $panneau(acqfast,$visuNo,This).gps.but -side top -fill x -in $panneau(acqfast,$visuNo,This).gps -ipadx 5 -ipady 4
   pack $panneau(acqfast,$visuNo,This).gps -side top -fill x
#$panneau(acqfast,$visuNo,This).gps.but  configure -bg "green"


   #--- Trame du temps de pose
   frame $panneau(acqfast,$visuNo,This).pose -borderwidth 2 -relief ridge
      label $panneau(acqfast,$visuNo,This).pose.but -text $caption(acqfast,pose) -relief raised
      #   -menu $panneau(acqfast,$visuNo,This).pose.but.menu -relief raised
      pack $panneau(acqfast,$visuNo,This).pose.but -side left -fill x -expand true -ipady 1
      #set m [ menu $panneau(acqfast,$visuNo,This).pose.but.menu -tearoff 0 ]
      #foreach temps $panneau(acqfast,$visuNo,temps_pose) {
      #  $m add radiobutton -label "$temps" \
           -indicatoron "1" \
           -value "$temps" \
           -variable panneau(acqfast,$visuNo,pose) \
           -command " "
      #}
      label $panneau(acqfast,$visuNo,This).pose.lab -text $caption(acqfast,sec)
      pack $panneau(acqfast,$visuNo,This).pose.lab -side right -fill x -expand true
      entry $panneau(acqfast,$visuNo,This).pose.entr -width 6 -relief groove \
         -textvariable panneau(acqfast,$visuNo,pose) -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $panneau(acqfast,$visuNo,This).pose.entr -side left -fill both -expand true
   pack $panneau(acqfast,$visuNo,This).pose -side top -fill x




   set caption(acqfastSetup,texte5)                 "Prompt the user if the index starts with a value different from 1"
   set caption(acqfastSetup,texte6)                 "Save an interrupted acquisition"

   #--- Trame du mode d'acquisition
   frame $panneau(acqfast,$visuNo,This).mode -borderwidth 5 -relief ridge

      #--- Trame du bouton Start/Pause
      frame $panneau(acqfast,$visuNo,This).go_stop -borderwidth 0 -relief ridge
         Button $panneau(acqfast,$visuNo,This).go_stop.but -text $caption(acqfast,start) -height 2 \
            -borderwidth 3 -command "::acqfast::Start $visuNo"
         pack $panneau(acqfast,$visuNo,This).go_stop.but -fill both -padx 0 -pady 0 -expand true
      pack $panneau(acqfast,$visuNo,This).go_stop -side top -fill x

      #--- Trame du bouton Stop
      frame $panneau(acqfast,$visuNo,This).stop -borderwidth 0 -relief ridge
         Button $panneau(acqfast,$visuNo,This).stop.but -text $caption(acqfast,stop) -height 2 \
            -borderwidth 3 -command "::acqfast::Stop $visuNo"
         pack $panneau(acqfast,$visuNo,This).stop.but -fill both -padx 0 -pady 0 -expand true
      pack $panneau(acqfast,$visuNo,This).stop -side top -fill x

      #--- Trame du frame rate
      frame $panneau(acqfast,$visuNo,This).video -borderwidth 2 -relief ridge

         set panneau(acqfast,$visuNo,mode_en_cours) [ lindex $panneau(acqfast,$visuNo,list_mode) [ expr $panneau(acqfast,$visuNo,mode) ] ]
         frame $panneau(acqfast,$visuNo,This).video.mode -borderwidth 0 -relief ridge
            label $panneau(acqfast,$visuNo,This).video.mode.lab -text $caption(acqfast,videomode)
            pack $panneau(acqfast,$visuNo,This).video.mode.lab -side left -fill x -expand true
            ComboBox $panneau(acqfast,$visuNo,This).video.mode.but \
               -width 5 \
               -height [llength $panneau(acqfast,$visuNo,list_mode)] \
               -relief raised    \
               -borderwidth 1    \
               -editable 0       \
               -takefocus 1      \
               -justify center   \
               -textvariable panneau(acqfast,$visuNo,mode_en_cours) \
               -values $panneau(acqfast,$visuNo,list_mode) \
               -modifycmd "::acqfast::ChangeMode $visuNo"
            pack $panneau(acqfast,$visuNo,This).video.mode.but -side left -fill x
         pack $panneau(acqfast,$visuNo,This).video.mode -side top -fill x

         frame $panneau(acqfast,$visuNo,This).video.framerate -borderwidth 0 -relief ridge
            label $panneau(acqfast,$visuNo,This).video.framerate.labfr -text $caption(acqfast,framerate)
            pack $panneau(acqfast,$visuNo,This).video.framerate.labfr -side left -fill x -expand true
            label $panneau(acqfast,$visuNo,This).video.framerate.lab -text $caption(acqfast,sec)
            pack $panneau(acqfast,$visuNo,This).video.framerate.lab -side right -fill x -expand true
            entry $panneau(acqfast,$visuNo,This).video.framerate.entr -width 6 -relief groove \
            -textvariable panneau(acqfast,$visuNo,framerate) -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 $::acqfast::local(maxframerate) }
            pack $panneau(acqfast,$visuNo,This).video.framerate.entr -side left -fill both -expand true
         pack $panneau(acqfast,$visuNo,This).video.framerate -side top -fill x

      pack $panneau(acqfast,$visuNo,This).video -side top -fill x


      pack $panneau(acqfast,$visuNo,This).mode -side top -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      #frame $panneau(acqfast,$visuNo,This).avancement_acq -borderwidth 2 -relief ridge
         #--- Checkbutton pour l'affichage de l'avancement de l'acqusition
      #   checkbutton $panneau(acqfast,$visuNo,This).avancement_acq.check -highlightthickness 0 \
            -text $caption(acqfast,avancement_acq) -variable panneau(acqfast,$visuNo,avancement_acq)
      #   pack $panneau(acqfast,$visuNo,This).avancement_acq.check -side left -fill x
      #pack $panneau(acqfast,$visuNo,This).avancement_acq -side top -fill x

      #--- Frame pour l'enregistrement
      frame $panneau(acqfast,$visuNo,This).save -borderwidth 2 -relief ridge

         #--- Bouton d'enregistrement
         Button $panneau(acqfast,$visuNo,This).save.but -text $caption(acqfast,sauvegde) -height 2 \
            -borderwidth 2 -command "::acqfast::SauveImages $visuNo" -state disabled
         pack $panneau(acqfast,$visuNo,This).save.but -fill both -padx 0 -pady 0 -expand true

         #--- Nom d'enregistrement
         frame $panneau(acqfast,$visuNo,This).save.name -borderwidth 2 -relief ridge
            label $panneau(acqfast,$visuNo,This).save.name.lab -text $caption(acqfast,nom) -pady 0
            pack $panneau(acqfast,$visuNo,This).save.name.lab -fill x
            entry $panneau(acqfast,$visuNo,This).save.name.entr -width 10 \
               -textvariable panneau(acqfast,$visuNo,object) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $panneau(acqfast,$visuNo,This).save.name.entr -fill x

         pack $panneau(acqfast,$visuNo,This).save.name -fill x

         #--- Index
         #frame $panneau(acqfast,$visuNo,This).save.index -relief ridge -borderwidth 2
         #   entry $panneau(acqfast,$visuNo,This).save.index.entr -width 3 -textvariable panneau(acqfast,$visuNo,index) \
         #      -relief groove -justify center \
         #      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
         #   pack $panneau(acqfast,$visuNo,This).save.index.entr -side left -fill x -expand true
         #   button $panneau(acqfast,$visuNo,This).save.index.but -text "1" -width 3 \
         #      -command "set panneau(acqfast,$visuNo,index) 1"
         #   pack $panneau(acqfast,$visuNo,This).save.index.but -side right -fill x
         #pack $panneau(acqfast,$visuNo,This).save.index -side top -fill x

      pack $panneau(acqfast,$visuNo,This).save -side top -fill x

      #--- Frame pour le display
      frame $panneau(acqfast,$visuNo,This).display -borderwidth -2 -relief ridge

         frame $panneau(acqfast,$visuNo,This).display.live -borderwidth 2 -relief ridge

            checkbutton $panneau(acqfast,$visuNo,This).display.live.case -pady 0 -text $caption(acqfast,continu) -variable panneau(acqfast,$visuNo,continu)
            pack $panneau(acqfast,$visuNo,This).display.live.case -side left -fill x

            Button $panneau(acqfast,$visuNo,This).display.live.but -text $caption(acqfast,live) -command "::acqfast::Live $visuNo"
            pack $panneau(acqfast,$visuNo,This).display.live.but -side right -fill x

         pack $panneau(acqfast,$visuNo,This).display.live -side top -fill x



         frame $panneau(acqfast,$visuNo,This).display.frame -borderwidth 2 -relief ridge
            label $panneau(acqfast,$visuNo,This).display.frame.lab -text $caption(acqfast,frame)
            pack $panneau(acqfast,$visuNo,This).display.frame.lab -side left -fill x
            entry $panneau(acqfast,$visuNo,This).display.frame.entr -width 6 -textvariable panneau(acqfast,$visuNo,frame) -relief groove -justify center \
              -validate all -validatecommand {::tkutil::validateNumber %W %V %P %s integer 1 $::acqfast::local(lastframe) }
            pack $panneau(acqfast,$visuNo,This).display.frame.entr -side left -fill x
            label $panneau(acqfast,$visuNo,This).display.frame.on -text $caption(acqfast,on)
            pack $panneau(acqfast,$visuNo,This).display.frame.on -side left -fill x
            label $panneau(acqfast,$visuNo,This).display.frame.max -textvariable panneau(acqfast,$visuNo,lastframe)
            pack $panneau(acqfast,$visuNo,This).display.frame.max -side left -fill x

         pack $panneau(acqfast,$visuNo,This).display.frame -side top -fill x

         frame $panneau(acqfast,$visuNo,This).display.prev_next -borderwidth 2 -relief ridge
            Button $panneau(acqfast,$visuNo,This).display.prev_next.prev -text $caption(acqfast,precedent) -height 2 \
            -borderwidth 2 -command "::acqfast::prec $visuNo"
            pack $panneau(acqfast,$visuNo,This).display.prev_next.prev -fill x -padx 0 -pady 0 -expand true -side left
            Button $panneau(acqfast,$visuNo,This).display.prev_next.next -text $caption(acqfast,suivant) -height 2 \
            -borderwidth 2 -command "::acqfast::succ $visuNo"
            pack $panneau(acqfast,$visuNo,This).display.prev_next.next -fill x -padx 0 -pady 0 -expand true -side left
         pack $panneau(acqfast,$visuNo,This).display.prev_next -fill x -side top

         Button $panneau(acqfast,$visuNo,This).display.but -text $caption(acqfast,display) -height 2 \
            -borderwidth 2 -command "::acqfast::display $visuNo $panneau(acqfast,$visuNo,frame)"
         pack $panneau(acqfast,$visuNo,This).display.but -fill x -padx 0 -pady 0 -expand true -side top

      pack $panneau(acqfast,$visuNo,This).display -fill x -side top

      #--- Frame pour le cycle
      frame $panneau(acqfast,$visuNo,This).cycle -borderwidth 2 -relief ridge

         #--- Frame for the filename
         frame $panneau(acqfast,$visuNo,This).cycle.fname -borderwidth 0 -relief flat
            #--- Entry for the name of cycle file
            entry $panneau(acqfast,$visuNo,This).cycle.fname.entry -textvariable panneau(acqfast,$visuNo,cycfile) -relief groove
            pack $panneau(acqfast,$visuNo,This).cycle.fname.entry -anchor center -expand 1 -fill both -padx 4 -pady 2 -side left
            #--- Button browse
            button $panneau(acqfast,$visuNo,This).cycle.fname.but -borderwidth 2 -text $caption(acqfast,browse) -command " ::acqfast::browse $visuNo "
            pack $panneau(acqfast,$visuNo,This).cycle.fname.but -anchor center -fill none -padx 2 -pady 1 -ipady 3 -side right
         pack $panneau(acqfast,$visuNo,This).cycle.fname -fill x -side top
         #--- Button for cycle start
         button $panneau(acqfast,$visuNo,This).cycle.but -text $caption(acqfast,cycle) -borderwidth 1 -command " ::cyclefast::init $visuNo "
         pack $panneau(acqfast,$visuNo,This).cycle.but -anchor center -expand 1 -fill both -padx 4 -pady 2 -side bottom

      pack $panneau(acqfast,$visuNo,This).cycle -side top -fill x

   pack $panneau(acqfast,$visuNo,This) -fill both -side top

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $panneau(acqfast,$visuNo,This)

}

