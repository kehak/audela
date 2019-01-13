#
## @file station_meteo.tcl
#  @brief Lit les données météorologiques des stations Sentinel (fichier infodata.txt) et Cumulus (fichier realtime.txt)
#  @author Robert DELMAS & Raymond ZACHANTKE
#  $Id: station_meteo.tcl 14242 2017-07-06 15:19:14Z rzachantke $
#

# Procedures generiques obligatoires (pour configurer tous les plugins camera, telescope, equipement) :
#     initPlugin      : Initialise le plugin
#     getStartFlag    : Retourne l'indicateur de lancement au demarrage
#     getPluginHelp   : Retourne la documentation htm associee
#     getPluginTitle  : Retourne le titre du plugin dans la langue de l'utilisateur
#     getPluginType   : Retourne le type de plugin
#     getPluginOS     : Retourne les OS sous lesquels le plugin fonctionne
#     fillConfigPage  : Affiche la fenetre de configuration de ce plugin
#     createPlugin    : Cree une instance du plugin
#     configurePlugin : Configure le plugin
#     deletePlugin    : Arrete une instance du plugin et libere les ressources occupees
#     isReady         : Informe de l'etat de fonctionnement du plugin
#

## @namespace station_meteo
#  @brief Lit les données météorologiques des stations Sentinel (fichier infodata.txt) et Cumulus (fichier realtime.txt)
namespace eval ::station_meteo {
   package provide station_meteo 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] station_meteo.cap ]
}

#------------------------------------------------------------
#  brief   retourne le titre du plugin dans la langue de l'utilisateur
#  return  titre du plugin
#
proc ::station_meteo::getPluginTitle { } {
   global caption

   return "$caption(station_meteo,label)"
}

#------------------------------------------------------------
## @brief    retourne l'indicateur de lancement au démarrage de Audela
#  @return   1 (lancé au démarrage) , 0 (pas lancé)
#
proc ::station_meteo::getStartFlag { } {
   return $::conf(station_meteo,start)
}

#------------------------------------------------------------
#  brief    retourne le nom du fichier d'aide principal
#  return  nom du fichier d'aide principal
#
proc ::station_meteo::getPluginHelp { } {
   return "station_meteo.htm"
}

#------------------------------------------------------------
#  brief    retourne le type de plugin
#  return   type de plugin
#
proc ::station_meteo::getPluginType { } {
   return "equipment"
}

#------------------------------------------------------------
#  brief    retourne le nom du répertoire du plugin
#  return   nom du répertoire du plugin : "station_meteo"
#
proc ::station_meteo::getPluginDirectory { } {
   return "station_meteo"
}

#------------------------------------------------------------
## @brief   retourne le ou les OS de fonctionnement du plugin
#  @return  liste des OS : "Windows Linux Darwin"
#
proc ::station_meteo::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief initialise le plugin
#
proc ::station_meteo::initPlugin { } {
   global audace

   ::station_meteo::initConf

   #--- Initialisation des variables audace
   set audace(meteo,obs,pressure)    "101325"
   set audace(meteo,obs,temperature) "16.85"
   set audace(meteo,obs,humidity)    "40"
   set audace(meteo,obs,temprose)    "3.21"
   set audace(meteo,obs,windsp)      "0"
   set audace(meteo,obs,winddir)     "0"
}

#------------------------------------------------------------
## @brief démarre le plugin
#
proc ::station_meteo::createPlugin { } {
   variable widget
   global conf

   #--   Initialise les variables widgets necessaires au lancement automatique
   if {$conf(station_meteo,start) ==1} {
      set widget(cycle) $conf(station_meteo,cycle)
      set widget(meteoFileAccess) $conf(station_meteo,meteoFileAccess)
      set widget(sensorName) [file tail $widget(meteoFileAccess)]
      set widget(frm) ".audace.confeqt.usr.onglet.fstation_meteo"
   }

   ::station_meteo::configState disabled
   ::station_meteo::onChangeMeteo refresh
}

#------------------------------------------------------------
#  brief mémorise la configuration dans le tableau conf(station_meteo,...)
#
proc ::station_meteo::configurePlugin { } {
   variable widget
   global conf

   set conf(station_meteo,meteoFileAccess) $widget(meteoFileAccess)
   set conf(station_meteo,cycle)           $widget(cycle)
}

#------------------------------------------------------------
## @brief commande du bouton "Arrêter" ;
#  libère les ressources occupées
#  @pre les variables conf(..) sont les variables des entrées
#
proc ::station_meteo::deletePlugin { } {
   variable widget

   ::station_meteo::onChangeMeteo stop
}

#------------------------------------------------------------
## @brief informe sur l'état de fonctionnement du plugin
#  @return 1 (ready) 0 (not ready)
#
proc ::station_meteo::isReady { } {
   variable widget

   if {[info exists widget(meteo)] && $widget(meteo) == 1} {
      return "1"
   } else {
      return "0"
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres de
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini"
#  - conf(station_meteo,start) définit l'indicateur de lancement au démarrage
#  - conf(station_meteo,meteoFileAccess) définit le chemin d'accès complet au fichier des données météo
#  - conf(station_meteo,cycle) définit l'intervalle de rafraichissement de la lecture des données météo
#
proc ::station_meteo::initConf { } {
   global conf

   if { ! [ info exists conf(station_meteo,start) ] }           { set conf(station_meteo,start) "0" }
   if { ! [ info exists conf(station_meteo,meteoFileAccess) ] } { set conf(station_meteo,meteoFileAccess) "" }
   if { ! [ info exists conf(station_meteo,cycle) ] }           { set conf(station_meteo,cycle) "60" }
}

#------------------------------------------------------------
#  brief créé la fenêtre de configuration du plugin
#
proc ::station_meteo::fillConfigPage { frm } {
   variable widget
   global audace caption conf

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   set widget(pressure)    $audace(meteo,obs,pressure)
   set widget(temperature) $audace(meteo,obs,temperature)
   set widget(humidity)    $audace(meteo,obs,humidity)

   if { $::tcl_platform(platform) == "windows" } {
      set sensorList [list "$caption(station_meteo,cumulus)"  "$caption(station_meteo,sentinel)"]
   } else {
      set sensorList [list "$caption(station_meteo,sentinel)"]
   }
   set widget(meteoFileAccess) $conf(station_meteo,meteoFileAccess)

   set fileName [file tail $widget(meteoFileAccess)]
   if {$fileName ne ""} {
      set widget(sensorName) $fileName
   } else {
      #--   Premier de la liste
      set widget(sensorName) [lindex "$sensorList" 0]
   }
   set widget(meteo) 0

   #--- Frame pour le choix de la liaison et de la combinaison
   frame $frm.frame1 -borderwidth 0 -relief raised

   pack $frm.frame1 -side top -fill x

   #--- Frame des boutons de commande
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Label du nom du fichier de donnees meteo
      label $frm.frame2.labelSensorname -text "$caption(station_meteo,sensname)"
      grid $frm.frame2.labelSensorname -row 0 -column 0 -padx 5 -pady 5 -sticky w

      #--- Choix de la liaison
      if { $::tcl_platform(platform) == "windows" } {
         set sensorList [list "$caption(station_meteo,cumulus)"  "$caption(station_meteo,sentinel)"]
      } else {
         set sensorList [list "$caption(station_meteo,sentinel)"]
      }
      ComboBox $frm.frame2.sensorname \
         -width [::tkutil::lgEntryComboBox "$sensorList"] \
         -height [llength $sensorList] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::station_meteo::widget(sensorName) \
         -modifycmd "::station_meteo::configCycle $frm.frame2.cycle" \
         -values $sensorList
      grid $frm.frame2.sensorname -row 0 -column 1 -sticky w

      #--- Label du nom du fichier de donnees meteo
      label $frm.frame2.labelAccess -text "$caption(station_meteo,meteoAcc)"
      grid $frm.frame2.labelAccess -row 1 -column 0 -padx 5 -pady 5 -sticky w

      #--  Chemin du fichier
      entry $frm.frame2.access -width 30 -justify right -state normal\
         -textvariable ::station_meteo::widget(meteoFileAccess)
      grid  $frm.frame2.access -row 1 -column 1 -padx 5 -pady 5 -sticky w

      #--- Bouton pour definir le chemin d'acces au fichier meteo
      button $frm.frame2.search -text "$caption(station_meteo,search)" -relief raised \
         -command "::station_meteo::configDirname $frm.frame2.search" -state normal
      grid $frm.frame2.search -row 1 -column 2 -padx 5 -pady 5 -sticky ew

      #--- Definition du delai de lecture du fichier
      label $frm.frame2.readfile -text "$caption(station_meteo,meteo)"
      grid $frm.frame2.readfile -row 2 -column 0 -padx 5 -pady 5 -sticky w

      #--- Choix du delai de lecture
      ComboBox $frm.frame2.cycle \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0
      grid $frm.frame2.cycle -row 2 -column 1 -sticky w
      ::station_meteo::configCycle $frm.frame2.cycle

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Frame pour le site web et le checkbutton creer au demarrage
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Site web officiel des stations meteo supportees
      label $frm.frame3.lab103 -text "$caption(station_meteo,site_web)"
      pack $frm.frame3.lab103 -side top -fill x -pady 2

      if { $widget(sensorName) == $caption(station_meteo,sentinel) } {
         set widget(site_web_ref) $caption(station_meteo,site_web_sentinel)
      } else {
         set widget(site_web_ref) $caption(station_meteo,site_web_cumulus)
      }

      set labelName [ ::confEqt::createUrlLabel $frm.frame3 "$widget(site_web_ref)" \
         "$widget(site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

      #--- Frame du bouton Arreter et du checkbutton creer au demarrage
      frame $frm.frame3.start -borderwidth 0 -relief flat

         #--- Bouton Arreter
         button $frm.frame3.start.stop -text "$caption(station_meteo,arreter)" -relief raised \
            -command { ::station_meteo::deletePlugin }
         pack $frm.frame3.start.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

         #--- Checkbutton demarrage automatique
         checkbutton $frm.frame3.start.chk -text "$caption(station_meteo,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(station_meteo,start)
         pack $frm.frame3.start.chk -side top -padx 10 -pady 3 -expand 1

      pack $frm.frame3.start -side left -expand 1

   pack $frm.frame3 -side bottom -fill x

   #--   Configure l'etat des entrees
   if {$conf(station_meteo,start) == 0} {
      ::station_meteo::configState normal
   } else {
      ::station_meteo::configState disabled
   }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#==============================================================
# Procedures specifiques du plugin
#==============================================================

#---------------------------------------------------------------------------
## @brief mise à jour de "Météo"
#
proc ::station_meteo::refreshMeteo { } {
   variable widget
   global audace caption

   #--   Arrete si demande
   if {$widget(meteo) == 0} {
      ::station_meteo::onChangeMeteo stop
      return
   }

   #--   Arrete si chemin incorrect
   if {![file exists $widget(meteoFileAccess)]} {
      onChangeMeteo stop
      tk_messageBox -title $caption(station_meteo,attention)\
         -icon error -type ok -message "$caption(station_meteo,erreur)"
      return
   }

   switch -exact $widget(sensorName) {
      realtime.txt {set catchResult [catch {readCumulus $widget(meteoFileAccess)} result]}
      infodata.txt {set catchResult [catch {readSentinelFile $widget(meteoFileAccess)} result]}
   }

   #--   Arrete si erreur a la lecture du fichier
   if { $catchResult != 0 } {
      onChangeMeteo stop
      tk_messageBox -title $caption(station_meteo,attention)\
         -icon error -type ok -message "$caption(station_meteo,erreur)"
      return
   }

   #--   Compare les dates jd et arrete si l'ecart est superieur a 10 cycles
   #     ou si le nb de donnes est incorrect
   set t1 [lindex $result 0]
   set t2 [mc_date2jd [clock format [clock seconds] -format "%Y %m %d %H %M %S" -timezone :localtime]]
   set deltaTime [expr { $t2-$t1 }]
   set seuil [expr { 10.*$widget(cycle)/86400 }]
   if {[llength $result] != 7 || $deltaTime > $seuil} {
      onChangeMeteo stop
      return
   }

   #--   Elimine la date JD et les unites
   #--   exemple result : 2457937.5084837964 {13.7 C} {90 %} {12.1 C} {0 m/s} {180 °} {100240.0 Pa}
   regsub -all {[\{|\}|(km/h)|(m/s)|(°C)|Pa)|(%)|(°)]} [lrange $result 1 end] "" data
   #--   exemple data : 13.7  90  12.1  0  180  100240.0
   lassign $data audace(meteo,obs,temperature) audace(meteo,obs,humidity) audace(meteo,obs,temprose) audace(meteo,obs,windsp) audace(meteo,obs,winddir) audace(meteo,obs,pressure)
   #::console::disp "$audace(meteo,obs,temperature) $audace(meteo,obs,humidity) $audace(meteo,obs,temprose) $audace(meteo,obs,windsp) $audace(meteo,obs,winddir) $audace(meteo,obs,pressure)\n"

   #::station_meteo::getValues $data

   #--   note : ne pas oublier de regler le zero de la direction du vent dans Cumulus
   #     pour que le Sud corresponde a 0°

   set cycle [expr { $widget(cycle)*1000 }] ; #convertit en ms
   set widget(afterID) [after $cycle ::station_meteo::refreshMeteo]
}

#---------------------------------------------------------------------------
#  brief rafraîchit si toutes les conditions sont réunies sinon désactive
#  param do refresh ou stop
#
proc ::station_meteo::onChangeMeteo { {do ""} } {
   variable widget
   global audace

   if {$do eq "refresh"} {

      set cycle [expr { $widget(cycle)*1000 }] ; #convertit en ms
      set widget(afterID) [after $cycle ::station_meteo::refreshMeteo]

      #--   Indicateur de lecture
      set widget(meteo) 1
      ::console::disp "Start reading $widget(sensorName)\n"

      #--   Demarre la mise a jour
      ::station_meteo::refreshMeteo

   } elseif {$do eq "stop"} {

      #--   Arrete la lecture
      if {[info exists widget(afterID)]} {
         after cancel ::station_meteo::refreshMeteo
         unset widget(afterID)
      }

      #--   Initialise par defaut
      #::station_meteo::getValues [list 16.85 40 3.21 0 0 101325]
      lassign [list 16.85 40 3.21 0 0 101325] audace(meteo,obs,temperature) audace(meteo,obs,humidity) audace(meteo,obs,temprose) \
         audace(meteo,obs,windsp) audace(meteo,obs,winddir) audace(meteo,obs,pressure)

      if {[info exists widget(meteo)] && $widget(meteo) == 1} {
         ::console::disp "Stop reading $widget(sensorName)\n"
      }

      #--   Indicateur de lecture
      if {[info exists widget(meteo)]} {
         set widget(meteo) 0
      }

      #--   Desinhibe
      ::station_meteo::configState normal
   }
}

#---------------------------------------------------------------------------
#  brief commande du bouton '...'
#  param this chemin du frame
#
proc ::station_meteo::configDirname { this } {
   variable widget
   global caption

   set dirname [tk_chooseDirectory -title "$caption(station_meteo,meteoAcc)" \
      -initialdir "C:/" -parent $this -mustexist 1]

   #--   verifie la presence du fichier
   set file [file join $dirname $widget(sensorName)]
   if {[file exists $file]} {
      set widget(meteoFileAccess) "$file"
   } else {
      set widget(meteoFileAccess) ""
      tk_messageBox -parent $widget(frm) -title Erreur \
      -message "Chemin erroné" -type ok -icon warning
   }
}

#---------------------------------------------------------------------------
#  brief configure le délai entre deux lectures
#  param w chemin du frame à modifier
#
proc ::station_meteo::configCycle { w } {
   variable widget
   global caption conf

   if {$widget(sensorName) eq "$caption(station_meteo,sentinel)"} {
      set cycleList [list 20 40 60 120 300 600]
   } else {
      set cycleList [list 60 300 600 900 1200 1800]
   }

   if {[info exists conf(station_meteo,cycle)]} {
      set widget(cycle) $conf(station_meteo,cycle)
   } else {
      set widget(cycle) [lindex $cycleList 0]
   }

   $w configure \
      -width [::tkutil::lgEntryComboBox "$cycleList"] \
      -height [llength $cycleList] \
      -textvariable ::station_meteo::widget(cycle) \
      -values $cycleList
}

#---------------------------------------------------------------------------
#  brief configure l'état du nom du fichier et de son chemin
#  param state normal ou disabled
#
proc ::station_meteo::configState { state } {
   variable widget

   if {[info exists widget(frm)]} {
      set w $widget(frm).frame2
      foreach child [list sensorname search] {
         if {[winfo exists $w.$child]} {
            $w.$child configure -state $state
         }
      }
   }
}

