#
## @file camera.tcl
#  @brief Utilitaires liés aux caméras CCD
#  @authors Robert DELMAS et Michel PUJOL
#  @namespace camera
#  @brief Utilitaires liés aux caméras CCD
#  $Id: camera.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#  @todo améliorer la doc pour les exemples de commande et supprimer les messages d'erreur

# Procedures utilisees par confCam
#   ::camera::create : cree une camera
#   ::camera::delete : detruit une camera
#
# Procedures utilisees par les outils et les scripts des utilisateurs
#   ::camera::acquisition
#       fait une acquition
#   ::camera::centerBrightestStar
#       fait des acquisitions jusqu'a ce que l'etoile la plus brillante soit a la position (x,y) donnee en parametre
#   ::camera::centerRadec
#       fait des acquisitions jusqu'a ce que l'etoile de coordonnee (ra,dec) soit a la position (x,y) donnee en parametre
#   ::camera::guide
#       fait des acquisitions et guide le telescope pour garder l'etoile a la position (x,y)
#   ::camera::stopAcquisition :
#       interrompt les acquisitions
#
#   Pendant les acquisitions, les procedures envoient des messages pour
#   informer le programme appelant de l'avancement des acquisitions.
#   Les messages sont transmis en appelant la procedure dont le nom est passe dans le parametre "callback"
#
#   Liste des messages :
#      targetCoord       : position (x,y) de l'etoile
#      mountInfo         : deplacement de la monture a faire
#      autovisu          : l'image est disponible dans le buffer
#      acquisitionResult : resultat final
#      error             : signale une erreur bloquante
#

namespace eval ::camera {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_caption) camera.cap ]

   #--- Autorise d'exporter la procedure "::camera::acq" sous nom d'alias "acq"
   namespace export acq
}

#------------------------------------------------------------
# init
#------------------------------------------------------------
proc ::camera::init { } {
   variable private

   #--- Initialisation d'une variable
   set variable(dispTimeAfterId) ""

   bind . "<<cameraEventA>>" "::camera::processCameraEvent A"
   bind . "<<cameraEventB>>" "::camera::processCameraEvent B"
   bind . "<<cameraEventC>>" "::camera::processCameraEvent C"
}

#------------------------------------------------------------
## @brief créé une caméra
#  @remarks procédure utilisée par confCam
#  @param camItem lettre de la caméra (A B ou C)
#  @return 0 si OK , 1 si erreur
#
proc ::camera::create { camItem } {
   variable private

   #--- cas multi thread
   #--- je recupere le numero de la camera
   set private($camItem,camNo)    [::confCam::getCamNo $camItem]
   #--- je recupere l'indentifiant de la thread de la camera
   set private($camItem,threadNo) [ cam$private($camItem,camNo) threadid]

   #--- J'ajoute la commande de liaison longue pose dans la thread de la camera
   if { [::confCam::getPluginProperty $camItem "hasLongExposure"] == 1 } {
      if { [cam$private($camItem,camNo) longueposelinkno] != 0} {
         ### A faire
         ### thread::copycommand $private($camItem,threadNo) "link[cam$private($camItem,camNo) longueposelinkno]"
      }
   }
   #--- je desactive la recuperation des coordonnees du telescope
   cam$private($camItem,camNo) radecfromtel 0

   #--- j'initialise la file d'evenement  pour la communication entre les deux threads
   set private($camItem,eventList) [list]

   if { $private($camItem,threadNo) != "" } {
      #--- je charge camerathread.tcl dans l'intepreteur de la thread de la camera
      ::thread::send $private($camItem,threadNo) [list uplevel #0 source \"[file join $::audace(rep_gui) audace camerathread.tcl]\"]
      ::thread::send $private($camItem,threadNo) "::camerathread::init $camItem $private($camItem,camNo) [thread::id]"
   }
   return 0
}

#------------------------------------------------------------
## @brief supprime une caméra
#  @remarks procédure utilisée par confCam
#  @param camItem lettre de la caméra (A B ou C)
#
proc ::camera::delete { camItem } {
   variable private
}

#------------------------------------------------------------
#  brief charge un fichier source TCL supplémentaire dans l'interpréteur de la thread de la camera
#  param  camItem          lettre de la caméra (A B ou C)
#  param  sourceFileName   nom complet du fichier source ( avec le répertoire )
#  return résultat du chargement exécuté dans la thread de la camera
#
proc ::camera::loadSource { camItem sourceFileName } {
   variable private

   ::thread::send $private($camItem,threadNo) [list uplevel #0 source \"$sourceFileName\"]
}

#------------------------------------------------------------
## @brief déclenche l'acquisition et affiche l'image une fois l'acquisition terminée dans la visu 1
#  @remarks procédure conservée pour compatibilité avec les anciennes versions de Audela (pour les scripts perso des utilisateurs)
#  @code Exemple : '::camera::acq 10 2' ou 'acq 10 2' (10 secondes de pose et binning 2x2) ces 2 écritures sont équivalentes
#  @endcode
#  @param exptime temps d'exposition
#  @param binning coefficient de binning
#
proc ::camera::acq { exptime binning } {
   global audace caption

   #--- Petit raccourci
   set camera cam$audace(camNo)

   #--- La commande exptime permet de fixer le temps de pose de l'image
   $camera exptime $exptime

   #--- La commande bin permet de fixer le binning
   $camera bin [ list $binning $binning ]

   #--- Declenchement l'acquisition
   $camera acq

   #--- Attente de la fin de la pose
   ::camera::waitStateStand $audace(camNo)

   #--- Visualisation de l'image
   ::audace::autovisu $audace(visuNo)

   #--- Mise a jour du titre
   ::confVisu::setFileName $audace(visuNo) "$caption(camera,image_acquisition) $exptime $caption(camera,sec)"
}

#------------------------------------------------------------
#  brief attente de la fin d'une pose lancée par '$camNo acq'
#  param camNo numéro de la caméra
#
proc ::camera::waitStateStand { camNo } {
   set statusVariableName "::status_cam$camNo"
   update
   while { [set $statusVariableName] != "stand" } {
      vwait status_cam$camNo
   }
}

#------------------------------------------------------------
#  brief alarme sonore de fin de pose
#  param exptime temps d'exposition
#
proc ::camera::alarmeSonore { { exptime } } {
   global audace conf

   #--- Appel de la sonnerie a $conf(acq,bell) secondes de la fin de pose
   #--- Sonnerie immediate pour des temps de pose < $conf(acq,bell) et > 1 seconde
   #--- Pas de sonnerie pour des temps de pose inferieurs a 1 seconde
   #--- $conf(acq,bell) < "0" pour ne pas sonner
   if { [ info exists conf(acq,bell) ] == "0" } {
      set conf(acq,bell) "-1"
   }
   if { ( $conf(acq,bell) >= "0" ) && ( $exptime > "1" ) } {
      if { $conf(acq,bell) >= $exptime } {
         set delay "0.1"
      } else {
         set delay [ expr $exptime-$conf(acq,bell) ]
         if { $delay <= "0" } {
            set delay "0.1"
         }
      }
      if { $delay > "0" } {
         set audace(after,bell,id) [ after [ expr int($delay*1000) ] bell ]
      }
   }
}

#------------------------------------------------------------
# dispLine t Nb_Line_sec Nb_Line_Total scan_Delai
#    Decompte du nombre de lignes du scan
#------------------------------------------------------------
proc ::camera::dispLine { t Nb_Line_sec Nb_Line_Total scan_Delai } {
   global audace panneau

   set t [ expr $t-1 ]
   set tt [ expr $t*$Nb_Line_sec ]
   if { $panneau(Scan,Stop) == "0" } {
      if { $t > "1" } {
         after 1000 ::camera::dispLine $t $Nb_Line_sec $Nb_Line_Total $scan_Delai
         if { $Nb_Line_Total >= "30" } {
            ::camera::avancementScan $tt $Nb_Line_Total $scan_Delai
         }
      }
   } else {
      destroy $audace(base).progress_scan
   }
}

#------------------------------------------------------------
# avancementScan tt Nb_Line_Total scan_Delai
#    Affichage de la progression en lignes du scan
#------------------------------------------------------------
proc ::camera::avancementScan { tt Nb_Line_Total scan_Delai } {
   global audace caption conf

   #--- Recuperation de la position de la fenetre
   ::camera::recupPositionAvancementScan

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(avancement_scan,position) ] } { set conf(avancement_scan,position) "+120+315" }

   #---
   if { [ winfo exists $audace(base).progress_scan ] != "1" } {
      #---
      toplevel $audace(base).progress_scan
      wm transient $audace(base).progress_scan $audace(base)
      wm resizable $audace(base).progress_scan 0 0
      wm title $audace(base).progress_scan "$caption(camera,en_cours)"
      wm geometry $audace(base).progress_scan 250x30$conf(avancement_scan,position)

      #--- Cree le widget et le label du temps ecoule
      label $audace(base).progress_scan.lab_status -text "" -justify center
      pack $audace(base).progress_scan.lab_status -side top -fill x -expand true -pady 5
      if { $tt == "-10" } {
         if { $scan_Delai > "1" } {
            $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $scan_Delai \
               $caption(camera,secondes)"
         } else {
            $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $scan_Delai \
               $caption(camera,seconde)"
         }
      } else {
         if { [ expr int($tt) ] >= "2" } {
            $audace(base).progress_scan.lab_status configure -text "[ expr int($tt) ] $caption(camera,lignes) \
               / $Nb_Line_Total $caption(camera,lignes)"
         } else {
            $audace(base).progress_scan.lab_status configure -text "[ expr int($tt) ] $caption(camera,ligne) \
               / $Nb_Line_Total $caption(camera,lignes)"
         }
      }
      #--- Mise a jour dynamique des couleurs
      if { [ winfo exists $audace(base).progress_scan ] } {
         ::confColor::applyColor $audace(base).progress_scan
      }
   } else {
      if { $tt == "-10" } {
         if { $scan_Delai > "1" } {
            $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $scan_Delai \
               $caption(camera,secondes)"
         } else {
            $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $scan_Delai \
               $caption(camera,seconde)"
         }
      } else {
         if { [ expr int($tt) ] >= "2" } {
            $audace(base).progress_scan.lab_status configure -text "[ expr int($tt) ] $caption(camera,lignes) \
               / $Nb_Line_Total $caption(camera,lignes)"
         } else {
            $audace(base).progress_scan.lab_status configure -text "[ expr int($tt) ] $caption(camera,ligne) \
               / $Nb_Line_Total $caption(camera,lignes)"
         }
      }
   }
}

#------------------------------------------------------------
#  brief récupération de la position de la fenêtre de progression du scan
#
proc ::camera::recupPositionAvancementScan { } {
   global audace conf

   if [ winfo exists $audace(base).progress_scan ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $audace(base).progress_scan ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(avancement_scan,position) "+[ string range $geometry $deb $fin ]"
   }
}

#------------------------------------------------------------
# addEvent
#
## parametres :
#------------------------------------------------------------
proc ::camera::addCameraEvent { camItem args } {
   variable private

   ###console::disp "::camera::addCameraEvent camItem=$camItem args=$args arg0=[lindex $args 0] \n"
   if { [lsearch $private($camItem,eventList) [list [lindex $args 0] *]] == -1 } {
      lappend private($camItem,eventList) $args
      event generate . "<<cameraEvent$camItem>>" -when tail
   } else {
      ###console::disp "::camera::addCameraEvent camItem=$camItem [lindex $args 0] already exist\n"
   }
}

#------------------------------------------------------------
#  brief traite un évènement Tk
#  param camItem lettre de la caméra (A B ou C)
#
proc ::camera::processCameraEvent { camItem } {
   variable private

   ###console::disp "::camera::processCameraEvent eventList=$private($camItem,eventList)\n"
   if { [llength $private($camItem,eventList)] > 0 } {
      set args [lindex $private($camItem,eventList) 0]
      set private($camItem,eventList) [lrange $private($camItem,eventList) 1 end]
      eval $private($camItem,callback) $args
   }
}

#------------------------------------------------------------
## @brief lance une session d'aquisitions
#  @param camItem lettre de la caméra (A B ou C)
#  @param callback procédure à appeler
#  @param exptime temps d'exposition
#
proc ::camera::acquisition { camItem callback exptime } {
   variable private

   #--- je connecte la camera
   ###::confCam::setConnection $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback

   if { $private($camItem,threadNo) != "" } {

      set camThreadNo $private($camItem,threadNo)
      ::thread::send -async $camThreadNo [list ::camerathread::acquisition $exptime ]
   } else {
      console::disp  "::camera::acquisition camNo=$private($camItem,camNo)\n"
      cam$private($camItem,camNo) callback $callback
      cam$private($camItem,camNo) exptime $exptime
      cam$private($camItem,camNo) acq
      console::disp  "::camera::acquisition après acq\n"
   }
}

#------------------------------------------------------------
#  @brief  lance une session d'aquisitions continues
#  @param  camItem  lettre de la camera (A B ou C)
#  @param  callback procédure à appeler après chaque acquisition
#  @param  exptime  temps de pose en secondes
#  @param  intervalle délai entre 2 poses
#
proc ::camera::acquisitionContinuous { camItem callback exptime intervalle } {
   variable private

   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   ::thread::send -async $camThreadNo [list ::camerathread::acquisitionContinuous $exptime $intervalle]
}

#------------------------------------------------------------
## @brief centre sur l'étoile la plus brillante
#  @param camItem     lettre de la camera (A B ou C)
#  @param callback    procédure à appeler
#  @param exptime     temps d'exposition
#  @param originCoord coordonnées de la destination du centrage
#  @param targetCoord coordonnées du centre de la zone de recherche de l'étoile
#  @param angle       angle d'inclinaison de la caméra (en degrés decimaux)
#  @param targetBoxSize taille de la zone de recherche
#  @param mountEnabled
#  @param alphaSpeed  coefficient de rattrapage de la monture en alpha (ms/pixels)
#  @param deltaSpeed  coefficient de rattrapage de la monture en delta (ms/pixels)
#  @param alphaReverse sens de rattrapage de la monture en alpha (0=normal ou 1=inverse)
#  @param deltaReverse sens de rattrapage de la monture en delta (0=normal ou 1=inverse
#  @param seuilx       seuil minimal de rattrapage sur l'axe des x (pixels)
#  @param seuily       seuil minimal de rattrapage sur l'axe des y (pixels)
#
proc ::camera::centerBrightestStar { camItem callback exptime originCoord targetCoord angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily } {
   variable private

   #--- je connecte la camera
   ###::confCam::setConnection $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   ###console::disp "::camera::centerBrightestStar targetCoord=$targetCoord targetBoxSize=$targetBoxSize\n"
   ::thread::send -async $camThreadNo [list ::camerathread::centerBrightestStar $exptime $originCoord $targetCoord $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily]
}

#------------------------------------------------------------
## @brief centre les coordonnées
#
proc ::camera::centerRadec { camItem callback exptime originCoord raDec angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily foclen detection catalogue kappa threshin fwhm radius threshold maxMagnitude delta epsilon  catalogueName cataloguePath } {
   variable private

   #--- je connecte la camera
   ###::confCam::setConnection $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   ###console::disp "::camera::centerRadec raDec=$raDec targetBoxSize=$targetBoxSize\n"
   ::thread::send -async $camThreadNo [list ::camerathread::centerRadec $exptime $originCoord $raDec $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily $foclen $detection $catalogue $kappa $threshin $fwhm $radius $threshold $maxMagnitude $delta $epsilon $catalogueName $cataloguePath]
}

#------------------------------------------------------------
## @brief lance une session guidage
#
proc ::camera::guide { camItem callback exptime detection originCoord targetCoord angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily slitWidth slitRatio intervalle declinaisonEnabled } {
   variable private

   #--- je connecte la camera
   ###::confCam::setConnection $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   ::thread::send -async $camThreadNo [list ::camerathread::guide $exptime $detection $originCoord $targetCoord $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily $slitWidth $slitRatio $intervalle $declinaisonEnabled ]
}

#------------------------------------------------------------
## @brief lance une session guidage
#
proc ::camera::searchBrightestStar { camItem callback exptime originCoord targetBoxSize searchThreshin searchFwhm searchRadius searchThreshold} {
   variable private

   #--- je connecte la camera
   ###::confCam::setConnection $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   ::thread::send -async $camThreadNo [list ::camerathread::searchBrightestStar $exptime $originCoord $targetBoxSize $searchThreshin $searchFwhm $searchRadius $searchThreshold]
}

#------------------------------------------------------------
#  brief modifie un paramètre
#  param camItem lettre de la caméra (A B ou C)
#  param paramName  nom du paramètre
#  param paramValue valeur du paramètre
#
proc ::camera::setParam { camItem  paramName paramValue } {
   variable private

   if { $camItem == "" } {
      return
   }
   set camThreadNo $private($camItem,threadNo)
   #--- je notifie la camera
   ::thread::send -async -head $camThreadNo [list ::camerathread::setParam $paramName $paramValue]
}

#------------------------------------------------------------
#  brief modifie plusieurs paramètres en mode asynchrone
#  param camItem lettre de la caméra (A B ou C)
#  param args liste de couples (nom paramètre, valeur paramètre)
#
proc ::camera::setAsynchroneParameter { camItem  args } {
   variable private

   if { $camItem == "" } {
      return
   }
   set camThreadNo $private($camItem,threadNo)
   #--- je notifie la camera
   ::thread::send -async $camThreadNo [list ::camerathread::setAsynchroneParameter $args]
}

#------------------------------------------------------------
## @brief arrête une acquisition en cours
#  @param camItem lettre de la caméra (A B ou C)
#
proc ::camera::stopAcquisition { camItem } {
   variable private

   if { $private($camItem,threadNo) != "" } {
      set camThreadNo $private($camItem,threadNo)
      ::thread::send -async $camThreadNo [list ::camerathread::stopAcquisition ]
   } else {
      cam$private($camItem,camNo) stop
   }
}

#--- Importe la procedure acq dans le namespace global
###rename cam::create cam::create_old
###rename cam::delete cam::delete_old
###interp alias "" cam::create "" ::camera::create
###interp alias "" cam::delete "" ::camera::delete

###proc ::cam::create { args } {
###   ::thread::send -async $camThreadNo [list ::camerathread::stopAcquisition ]
###}

#--- import de acq dan le namespace principal pour compatibilite avec les anciens scripts
namespace import ::camera::acq

::camera::init

