#
## @file scopedome.tcl
#  @brief Interface graphique de l'équipement ScopeDome ASCOM
#  @author Raymond ZACHANTKE
#  @namespace scopedome
#  @brief Interface graphique de l'équipement ScopeDome ASCOM
#  $Id: scopedome.tcl 14247 2017-07-08 06:28:29Z robertdelmas $
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
#     deletePlugin    : Arrete une instance du plugin et libere les ressources occupees
#     configurePlugin : Configure le plugin
#     isReady         : Informe de l'etat de fonctionnement du plugin
#

namespace eval ::scopedome {

   package provide scopedome 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] scopedome.cap ]
}

#------------------------------------------------------------
#  brief   retourne le titre du plugin dans la langue de l'utilisateur
#  return  titre du plugin
#
proc ::scopedome::getPluginTitle { } {
   return "$::caption(scopedome,label)"
}

#------------------------------------------------------------
## @brief   retourne l'indicateur de lancement au démarrage de Audela
#  @return  1 (lancé au démarrage) , 0 (pas lancé)
#
proc ::scopedome::getStartFlag { } {
   return $::conf(scopedome,start)
}

#------------------------------------------------------------
#  brief   retourne le nom du fichier d'aide principal
#  return  nom du fichier d'aide principal
#
proc ::scopedome::getPluginHelp { } {
   return "scopedome.htm"
}

#------------------------------------------------------------
#  brief   retourne le type de plugin
#  return  type de plugin
#
proc ::scopedome::getPluginType { } {
   return "equipment"
}

#------------------------------------------------------------
#  brief   retourne le nom du répertoire du plugin
#  return  nom du répertoire du plugin : "scopedome"
#
proc ::scopedome::getPluginDirectory { } {
   return "scopedome"
}

#------------------------------------------------------------
## @brief  retourne le ou les OS de fonctionnement du plugin
#  @return liste des OS : "Windows"
#
proc ::scopedome::getPluginOS { } {
   return [ list Windows ]
}

#------------------------------------------------------------
#  initPlugin
#     initialise le plugin
#------------------------------------------------------------
proc ::scopedome::initPlugin { } {
   variable widget

   #--- Initialise les variables conf
   if { ! [ info exists ::conf(scopedome,fileName) ] }     { set ::conf(scopedome,fileName)     "ASCOM.ScopeDomeUSBDome.exe" }
   if { ! [ info exists ::conf(scopedome,fileAccess) ] }   { set ::conf(scopedome,fileAccess)   "" }
   if { ! [ info exists ::conf(scopedome,start) ] }        { set ::conf(scopedome,start)        "0" }
   if { ! [ info exists ::conf(scopedome,windowName) ] }   { set ::conf(scopedome,windowName)   "ScopeDome LS"}
   if { ! [ info exists ::conf(scopedome,connectScope) ] } { set ::conf(scopedome,connectScope) "1"}

}

#------------------------------------------------------------
## @brief démarre le plugin
#  @details si la connexion avec ScopeDome a réussi la variable widget(domNo) vaut 1
#
proc ::scopedome::createPlugin { } {
   variable widget

   package require twapi
   package require tcom

   source [ file join $::audace(rep_plugin) equipment scopedome scopedome_driver.tcl ]

   #--   Initialise les variables widgets necessaires au lancement automatique
   if {$::conf(scopedome,start) ==1} {
      ::scopedome::confToWidget
      set widget(frm) ".audace.confeqt.usr.onglet.fscopedome"
   }

   if {[info exists widget(domNo)] ==0 || $widget(domNo) == 0} {

      lassign [::scopedome::createProcess "$::conf(scopedome,fileAccess)" "$::conf(scopedome,windowName)"] \
         widget(comobj) widget(domNo)

      if {$widget(comobj) ne ""} {

         #--  Recupere les infos sur le driver
         set widget(driverversion) [$widget(comobj) DriverInfo]
         ::console::disp "Start $widget(driverversion)\n"

         #--   Libere les combobox
         ::scopedome::configStateComboBox normal

         #--   Lance le transfert des cordonnees du telescope
         if {$::conf(scopedome,connectScope) ==1} {
            ::scopedome::onChangeScope refresh
         } else {
            ::scopedome::onChangeScope stop
         }
      }
   }
}

#------------------------------------------------------------
## @brief commande du bouton "Arrêter"
#  @details arrête le plugin, libère les ressources et ferme ScopeDome
#
proc ::scopedome::deletePlugin { } {
   variable widget

   if {$widget(domNo) ==1} {

      ::scopedome::killCom

      #--   Remet a 0 l'indicateur
      set widget(domNo) 0
      ::console::disp "Stop $::caption(scopedome,label)\n"

      #--   Arrete le transfert des coordonnees du telescope
      ::scopedome::onChangeScope stop

      #--   Reinitialise les variables
      ::scopedome::confToWidget

      #--   Vide les valeurs
      set widget(propertyResult) ""
      set widget(cmdValue) ""

      #--   Inhibe les combobox
      ::scopedome::configStateComboBox disabled
   }
}

#------------------------------------------------------------
## @brief   informe de l'état de fonctionnement du plugin
#  @return  1 (ready) , 0 (not ready)
#
proc ::scopedome::isReady { } {
   variable widget

   #--- Dome KO
   set result 0
   if {[info exists widget(domNo)] ==1 && $widget(domNo) == "1" } {
      #--- Dome OK
      set result 1
   }
   return $result
}

#------------------------------------------------------------
## @brief sauve les variable locales dans conf()
#
proc ::scopedome::configurePlugin { } {
   variable widget
   global conf

   set conf(scopedome,fileName)   $widget(scopedome,fileName)
   set conf(scopedome,fileAccess) $widget(scopedome,fileAccess)
}

#------------------------------------------------------------
#  brief charge les variables de configuration dans des variables locales
#
proc ::scopedome::confToWidget { } {
   variable widget

   #--- Recupere la configuration du driver
   set widget(scopedome,fileName)   $::conf(scopedome,fileName)
   set widget(scopedome,fileAccess) $::conf(scopedome,fileAccess)
   set widget(scopedome,windowName) $::conf(scopedome,windowName) ; # nom de l'interface
   set widget(filesystem)           "C:/ScopeDome/CurrentTelescopeStatus.txt"
   set widget(driverversion)        ""

   #--   Properties list
   set widget(propertyList)   [list Azimuth AtHome AtPark Connected ShutterStatus \
                              Slaved Slewing Dome_Scope_Is_Connected \
                              Dome_Scope_Ra Dome_Scope_Dec Dome_Scope_Alt Dome_Scope_Az \
                              Temperature_In_Dome Temperature_Outside_Dome \
                              Temperature_Humidity_Sensor Humidity_Humidity_Sensor \
                              Pressure Dew_Point Wind_Speed Wind_Direction \
                              Temperature_In_From_Weather_Station \
                              Temperature_Out_From_Weather_Station \
                              Cloud_Sensor_Day_Night Cloud_Sensor_Clear_Cloudy Cloud_Sensor_Rain \
                              Shutter_Link_Strength Internal_Sensor_Observatory_Safe \
                              Internal_Sensor_Clouds Internal_Sensor_Rain \
                              Internal_Sensor_Power_Failure Internal_Sensor_Free_Input \
                              Internal_Sensor_Scope_At_Home \
                              Internal_Sensor_Dome_At_Home Dome_Error \
                              Internal_Sensor_Dome_Encoder_Counter \
                              Internal_Sensor_Dome_Roatate_Counter \
                              Analog_Input_Shutter Analog_Input_Main \
                              Rel_Scope_Get_State Rel_CCD_Get_State \
                              Rel_Light_Get_State Rel_Fan_Get_State \
                              Rel_REL_1_Get_State Rel_REL_2_Get_State \
                              Rel_REL_3_Get_State Rel_REL_4_Get_State \
                              Rel_Shutter_1_Open_Get_State Rel_Shutter_1_Close_Get_State \
                              Shutter_2_Open_Get_State Rel_Shutter_2_Close_Get_State \
                              Rel_Dome_CW_Get_State Rel_Dome_CCW_Get_State \
                              Card_Power_Get_State Get_TelescopeToDomePosition]

   #--   Ascom command list with boolean parameter (True|False)
   #--   suppression de Slaved (doublon avec Scope_Sync)
   set widget(switchList)      [list Scope_Sync Wind_Sync Sky_Sync Weather_Protect Slaved]
   set widget(switchValueList) [list On Off Toggle Dome_Relative_Rotate]
   set widget(switchValue)     [lindex $widget(switchValueList) 0]


   #--   Ascom command list with numerical parameter
   set widget(cmdList)    [list SyncToAzimuth GoTo Enc_GoTo SlewToAltitude \
                           SlewToAzimuth Dome_Relative_Rotate]

   #--   Ascom + Action list excluding :
   #--   Excluding configuration command : SetUpDialog SetPark Dispose
   #  Calibrate_Dome_Az_Encoder Calibrate_Dome_Inertia Restore_Default
   set widget(actionList)    [list AbortSlew Park Stop CloseShutter OpenShutter \
                                 Rel_Scope_On Rel_Scope_Off Rel_CCD_On Rel_CCD_Off \
                                 Rel_Light_On Rel_Light_Off Rel_Fan_On Rel_Fan_Off \
                                 Rel_1_On Rel_1_Off Rel_2_On Rel_2_Off \
                                 Rel_3_On Rel_3_Off Rel_4_On Rel_4_Off \
                                 Switch_All_On Switch_All_Off \
                                 Dome_Scope_Connect Dome_Scope_DisConnect \
                                 Shutter_1_Open Shutter_1_Close \
                                 Shutter_2_Open Shutter_2_Close \
                                 Dome_Wait_1000ms Reset_Dome_Az_Encoder \
                                 Reset_Dome_Rotate_Encoder Dome_Derotate \
                                 Card_Power_Off Card_Power_On Find_Home]

   #--   Selectionne le premier de la liste
   foreach f [list property switch cmd action] {
      set widget(${f}) [lindex $widget(${f}List) 0]
   }
}

#------------------------------------------------------------
#  brief retourne le numéro du dôme
#
proc ::scopedome::getDomNo { } {
   variable widget

   return $widget(domNo)
}

#------------------------------------------------------------
#  brief  affiche la frame configuration du focuseur
#  param  frm généré automatiquement (.audace.confeqt.usr.onglet.fscopedome)
#
proc ::scopedome::fillConfigPage { frm } {
   variable widget

   package require twapi

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   ::scopedome::confToWidget

   set state disabled
   if {$widget(scopedome,fileAccess) ne ""} {
      set pid [twapi::get_process_ids -name $widget(scopedome,fileName)]
      if {$pid ne ""} {
         set state normal
      }
   }

   #--- Frame des boutons de commande
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Label du nom du fichier
      label $frm.frame2.labelFile -text "$::caption(scopedome,fileName)"
      grid $frm.frame2.labelFile -row 0 -column 0 -padx 5 -pady 5 -sticky w

      #--  Nom du fichier
      entry $frm.frame2.file -width 40 -justify right -state normal \
         -textvariable ::scopedome::widget(scopedome,fileName)
      grid  $frm.frame2.file -row 0 -column 1 -padx 5 -pady 5 -sticky w

      #--- Label du chemin du driver
      label $frm.frame2.labelAccess -text "$::caption(scopedome,fileAccess)"
      grid $frm.frame2.labelAccess -row 1 -column 0 -padx 5 -pady 5 -sticky w

      #--  Chemin complet du driver
      entry $frm.frame2.access -width 40 -justify right -state normal \
         -textvariable ::scopedome::widget(scopedome,fileAccess)
      grid  $frm.frame2.access -row 1 -column 1 -padx 5 -pady 5 -sticky w

      #--- Bouton pour definir chemin
      button $frm.frame2.search -text "$::caption(scopedome,search)" -relief raised \
         -command "::scopedome::configDirname $frm.frame2.search"
      grid $frm.frame2.search -row 1 -column 2 -padx 5 -pady 5 -sticky ew

      #--   Label d'Info sur le driver connecte
      label $frm.frame2.labelVersion -text "$::caption(scopedome,version)"
      grid $frm.frame2.labelVersion -row 2 -column 0 -padx 5 -pady 5 -sticky w

      #--- N° de version
      label $frm.frame2.version -justify left -textvariable ::scopedome::widget(driverversion)
      grid  $frm.frame2.version -row 2 -column 1 -padx 5 -pady 5 -sticky w

      #--- Checkbutton pour le transfert des coordonnees du telescope
      checkbutton $frm.frame2.connect -text "$::caption(scopedome,connectScope)" \
            -highlightthickness 0 -variable conf(scopedome,connectScope)
      grid $frm.frame2.connect -row 3 -column 0 -columnspan 2 -padx 5 -pady 5 -sticky w

      #--- Label des proprietes
      label $frm.frame2.labelProperty -text "$::caption(scopedome,sensor) "
      grid  $frm.frame2.labelProperty -row 4 -column 0 -padx 5 -pady 5 -sticky w
      ::scopedome::buildComboBox property 4 $state
      #--- Label du resultat
      label $frm.frame2.labelPropertyResult -textvariable ::scopedome::widget(propertyResult)
      grid  $frm.frame2.labelPropertyResult -row 4 -column 2 -padx 5 -pady 5 -sticky w

      #--- Label des commandes ascom avec boolen
      label $frm.frame2.labelSwitch -text "$::caption(scopedome,cmdswitch)"
      grid  $frm.frame2.labelSwitch -row 5 -column 0 -padx 5 -pady 5 -sticky w
      ::scopedome::buildComboBox switch 5 $state
      ComboBox $frm.frame2.switchvalue -width 5 -height 2 -relief sunken \
         -borderwidth 1 -editable 0 -state $state -values $widget(switchValueList) \
         -textvariable ::scopedome::widget(switchValue)
      grid  $frm.frame2.switchvalue -row 5 -column 2 -padx 5 -pady 5 -sticky w

      #--- Label des commandes ascom avec 1 parametre
      label $frm.frame2.labelCmd -text "$::caption(scopedome,cmddbl)"
      grid  $frm.frame2.labelCmd -row 6 -column 0 -padx 5 -pady 5 -sticky w
      ::scopedome::buildComboBox cmd 6 $state
      entry $frm.frame2.cmdvalue -width 5 -justify right -state $state \
         -textvariable ::scopedome::widget(cmdValue)
      grid  $frm.frame2.cmdvalue -row 6 -column 2 -padx 5 -pady 5 -sticky w

      #--- Label des commandes avec Action
      label $frm.frame2.labelAction -text "$::caption(scopedome,action)"
      grid  $frm.frame2.labelAction -row 7 -column 0 -padx 5 -pady 5 -sticky w
      ::scopedome::buildComboBox action 7 $state

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Frame pour le site web et le checkbutton creer au demarrage
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Site web officiel de scopedome
      label $frm.frame3.lab103 -text "$::caption(scopedome,site_web)"
      pack $frm.frame3.lab103 -side top -fill x -pady 2

      set widget(site_web_ref) "$::caption(scopedome,site_web_scopedome)"
      set labelName [ ::confEqt::createUrlLabel $frm.frame3 "$widget(site_web_ref)" \
         "$widget(site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

      #--- Frame du bouton Arreter et du checkbutton creer au demarrage
      frame $frm.frame3.start -borderwidth 0 -relief flat

         #--- Bouton Arreter
         button $frm.frame3.start.stop -text "$::caption(scopedome,arreter)" -relief raised \
            -command { ::scopedome::deletePlugin }
         pack $frm.frame3.start.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

         #--- Checkbutton demarrage automatique
         checkbutton $frm.frame3.start.chk -text "$::caption(scopedome,creer_au_demarrage)" \
           -highlightthickness 0 -variable conf(scopedome,start)
         pack $frm.frame3.start.chk -side top -padx 10 -pady 3 -expand 1

      pack $frm.frame3.start -side left -expand 1

   pack $frm.frame3 -side bottom -fill x

   update

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#==============================================================
# Procedures utilitaires
#==============================================================

#---------------------------------------------------------------------------
#  brief commande du bouton '...'
#  param this chemin de l'entrée à modifier
#
proc ::scopedome::configDirname { this } {
   variable widget

   set dirname [tk_chooseDirectory -title "$::caption(scopedome,fileAccess)" \
      -initialdir "C:/" -parent $this]

   #--   verifie la presence du fichier
   set file [file join $dirname $widget(scopedome,fileName)]

   if {[file exists $file]} {
      set widget(scopedome,fileAccess) "$file"
   } else {
      set widget(scopedome,fileAccess) ""
      ::scopedome::errorBox error
   }
}

#---------------------------------------------------------------------------
#  brief construit une comboBox
#  param type ID du widget et des variables
#  param row numéro de la ligne du grid
#  param state normal ou disabled  (par defaut)
#
proc ::scopedome::buildComboBox { type row {state disabled} } {
   variable widget

   set frame $widget(frm).frame2.$type

   set height [llength $widget(${type}List)]
   #set widget(${type}) [lindex $widget(${type}List) 0]
   ComboBox $frame \
        -width 40 \
         -height $height \
         -relief sunken \
         -borderwidth 1 \
         -editable 0 \
         -state $state \
         -textvariable ::scopedome::widget(${type}) \
         -values [lsort -dictionary $widget(${type}List)] \
         -modifycmd "::scopedome::cmd $type"
   grid $frame -row $row -column 1 -padx 5 -pady 5 -sticky w
}

#---------------------------------------------------------------------------
#  brief configure l'état d'une Combobox
#  param state normal ou disabled
#
proc ::scopedome::configStateComboBox { state } {
   variable widget

   if {[info exists widget(frm)] ==0} {
      set widget(frm) ".audace.confeqt.usr.onglet.fscopedome"
   }

   #--   Disable les combobox
   foreach child [list property switch cmd action] {
      if {[winfo exists $widget(frm).frame2.$child] ==1} {
         $widget(frm).frame2.$child configure -state $state
      }
   }
   if {[winfo exists $widget(frm).frame2.switchvalue] ==1} {
      $widget(frm).frame2.switchvalue configure -state $state
   }
   if {[winfo exists $widget(frm).frame2.cmdvalue] ==1} {
      $widget(frm).frame2.cmdvalue configure -state $state
   }
}

#---------------------------------------------------------------------------
#  brief affiche un message d'erreur
#  param error spécification du caption
#
proc ::scopedome::errorBox { error } {
   variable widget

   tk_messageBox -parent $widget(frm).frame2 -title $::caption(scopedome,warning) \
      -message "$::caption(scopedome,$error)" -type ok -icon warning
}

