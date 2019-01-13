#
# Fichier : apogee.tcl
# Description : Configuration de la camera Apogee
# Auteur : Robert DELMAS
# Mise à jour $Id: apogee.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::apogee {
   package provide apogee 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] apogee.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::apogee::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libapogee.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::apogee::getPluginType]] "apogee" "libapogee.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace Apogee.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::apogee::getPluginType]] "apogee" "Apogee.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(apogee,installNewVersion) $sourceFileName [package version apogee] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::apogee::getPluginTitle { } {
   global caption

   return "$caption(apogee,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::apogee::getPluginHelp { } {
   return "apogee.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::apogee::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::apogee::getPluginOS { } {
   return [ list Windows ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::apogee::getPluginDirectory { } {
   return "apogee"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::apogee::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::apogee::isReady { camItem } {
   variable private

   if { $private($camItem,camNo) == "0" } {
      #--- Camera KO
      return 0
   } else {
      #--- Camera OK
      return 1
   }
}

#
# initPlugin
#    Initialise les variables conf(apogee,...)
#
proc ::apogee::initPlugin { } {
   variable private
   global conf caption

   #--- Initialise les variables de la camera Apogee
   foreach camItem { A B C } {
      if { ! [ info exists conf(apogee,$camItem,device) ] }   { set conf(apogee,$camItem,device)   "0" }
      if { ! [ info exists conf(apogee,$camItem,cool) ] }     { set conf(apogee,$camItem,cool)     "0" }
      if { ! [ info exists conf(apogee,$camItem,foncobtu) ] } { set conf(apogee,$camItem,foncobtu) "0" }
      if { ! [ info exists conf(apogee,$camItem,mirh) ] }     { set conf(apogee,$camItem,mirh)     "0" }
      if { ! [ info exists conf(apogee,$camItem,mirv) ] }     { set conf(apogee,$camItem,mirv)     "0" }
      if { ! [ info exists conf(apogee,$camItem,temp) ] }     { set conf(apogee,$camItem,temp)     "-10" }

      #--- Initialisation
      set private($camItem,power)   "$caption(apogee,puissance_peltier_--)"
      set private($camItem,ccdTemp) "$caption(apogee,temperature_CCD)"
   }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::apogee::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Apogee dans le tableau private(...)
   foreach camItem { A B C } {
      set private($camItem,device)   $conf(apogee,$camItem,device)
      set private($camItem,cool)     $conf(apogee,$camItem,cool)
      set private($camItem,foncobtu) [ lindex "$caption(apogee,obtu_synchro) $caption(apogee,obtu_ferme)" $conf(apogee,$camItem,foncobtu) ]
      set private($camItem,mirh)     $conf(apogee,$camItem,mirh)
      set private($camItem,mirv)     $conf(apogee,$camItem,mirv)
      set private($camItem,temp)     $conf(apogee,$camItem,temp)
   }
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::apogee::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Apogee dans le tableau conf(apogee,...)
   set conf(apogee,$camItem,device)   $private($camItem,device)
   set conf(apogee,$camItem,cool)     $private($camItem,cool)
   set conf(apogee,$camItem,foncobtu) [ lsearch "$caption(apogee,obtu_synchro) $caption(apogee,obtu_ferme)" "$private($camItem,foncobtu)" ]
   set conf(apogee,$camItem,mirh)     $private($camItem,mirh)
   set conf(apogee,$camItem,mirv)     $private($camItem,mirv)
   set conf(apogee,$camItem,temp)     $private($camItem,temp)
}

#
# fillConfigPage
#    Interface de configuration de la camera Apogee
#
proc ::apogee::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::apogee::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Frame du refroidissement, de la temperature du capteur CCD, des miroirs en x et en y et de l'obturateur
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame des miroirs en x et en y, du refroidissement et de la temperature du capteur CCD
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         #--- Frame des miroirs en x et en y
         frame $frm.frame1.frame3.frame4 -borderwidth 0 -relief raised

            #--- Miroirs en x et en y
            checkbutton $frm.frame1.frame3.frame4.mirx -text "$caption(apogee,miroir_x)" -highlightthickness 0 \
               -variable ::apogee::private($camItem,mirh)
            pack $frm.frame1.frame3.frame4.mirx -anchor w -side top -padx 20 -pady 15

            checkbutton $frm.frame1.frame3.frame4.miry -text "$caption(apogee,miroir_y)" -highlightthickness 0 \
               -variable ::apogee::private($camItem,mirv)
            pack $frm.frame1.frame3.frame4.miry -anchor w -side top -padx 20 -pady 15

         pack $frm.frame1.frame3.frame4 -anchor n -side left -fill x -padx 20

         #--- Frame du refroidissement et de la temperature du capteur CCD
         frame $frm.frame1.frame3.frame5 -borderwidth 0 -relief raised

            #--- Frame du refroidissement
            frame $frm.frame1.frame3.frame5.frame6 -borderwidth 0 -relief raised

               #--- Definition du refroidissement
               checkbutton $frm.frame1.frame3.frame5.frame6.cool -text "$caption(apogee,refroidissement)" \
                  -highlightthickness 0 -variable ::apogee::private($camItem,cool) -command "::apogee::checkConfigRefroidissement $camItem"
               pack $frm.frame1.frame3.frame5.frame6.cool -anchor center -side left -padx 0 -pady 5

               entry $frm.frame1.frame3.frame5.frame6.temp -textvariable ::apogee::private($camItem,temp) -width 4 \
                  -justify center \
                  -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double -274 50 }
               pack $frm.frame1.frame3.frame5.frame6.temp -anchor center -side left -padx 5 -pady 5

               label $frm.frame1.frame3.frame5.frame6.tempdeg \
                  -text "$caption(apogee,refroidissement_1)"
               pack $frm.frame1.frame3.frame5.frame6.tempdeg -side left -fill x -padx 0 -pady 5

            pack $frm.frame1.frame3.frame5.frame6 -anchor nw -side top -fill x -padx 10

            #--- Frame de la puissance de refroidissement
            frame $frm.frame1.frame3.frame5.frame7 -borderwidth 0 -relief raised

               label $frm.frame1.frame3.frame5.frame7.power -textvariable ::apogee::private($camItem,power)
               pack $frm.frame1.frame3.frame5.frame7.power -side left -fill x -padx 20 -pady 5

            pack $frm.frame1.frame3.frame5.frame7 -side top -fill x -padx 30

            #--- Frame de la temperature du capteur CCD
            frame $frm.frame1.frame3.frame5.frame8 -borderwidth 0 -relief raised

               #--- Definition de la temperature du capteur CCD
               label $frm.frame1.frame3.frame5.frame8.ccdtemp -textvariable ::apogee::private($camItem,ccdTemp)
               pack $frm.frame1.frame3.frame5.frame8.ccdtemp -side left -fill x -padx 20 -pady 5

            pack $frm.frame1.frame3.frame5.frame8 -side top -fill x -padx 30

         pack $frm.frame1.frame3.frame5 -anchor nw -side left -fill x -expand 0

      pack $frm.frame1.frame3 -side top -fill x -expand 0

      #--- Frame du device
      frame $frm.frame1.frame3.frame9 -borderwidth 0 -relief raised

         #--- Definition du Device
         label $frm.frame1.frame3.frame9.lab1 -text "$caption(apogee,device)"
         pack $frm.frame1.frame3.frame9.lab1 -anchor center -side left -padx 0 -pady 5

         #--- Je constitue la liste des canaux USB
         set list_combobox [ list 0 1 2 3 4 5 ]

         #--- Choix du Device
         ComboBox $frm.frame1.frame3.frame9.port \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [ llength $list_combobox ] \
            -relief sunken  \
            -borderwidth 1  \
            -textvariable ::apogee::private($camItem,device) \
            -editable 0     \
            -values $list_combobox
         pack $frm.frame1.frame3.frame9.port -anchor center -side left -padx 0 -pady 5

      pack $frm.frame1.frame3.frame9 -anchor nw -side left -padx 20

      #--- Frame du mode de fonctionnement de l'obturateur
      frame $frm.frame1.frame8 -borderwidth 0 -relief raised

         #--- Mode de fonctionnement de l'obturateur
         label $frm.frame1.frame8.lab3 -text "$caption(apogee,fonc_obtu)"
         pack $frm.frame1.frame8.lab3 -anchor nw -side left -padx 10 -pady 5

         set list_combobox [ list $caption(apogee,obtu_synchro) $caption(apogee,obtu_ferme) ]
         ComboBox $frm.frame1.frame8.foncobtu \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [ llength $list_combobox ] \
            -relief sunken      \
            -borderwidth 1      \
            -editable 0         \
            -textvariable ::apogee::private($camItem,foncobtu) \
            -values $list_combobox
         pack $frm.frame1.frame8.foncobtu -anchor nw -side left -padx 0 -pady 5

      pack $frm.frame1.frame8 -side top -fill x -expand 0

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la Apogee
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(apogee,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(apogee,site_web_ref)" \
         "$caption(apogee,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::apogee::checkConfigRefroidissement $camItem

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la camera Apogee en fonction des donnees contenues dans les variables conf(apogee,...)
#
proc ::apogee::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la camera
      set camNo [ cam::create apogee USB \
         -device $conf(apogee,$camItem,device) \
         -log_file [::confCam::getLogFileName $camItem] \
         -log_level [::confCam::getLogLevel $camItem] \
      ]
      console::affiche_entete "$caption(apogee,port_camera) $caption(apogee,2points) [ cam$camNo port ]\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je configure l'obturateur
      switch -exact -- $conf(apogee,$camItem,foncobtu) {
         0 {
            cam$camNo shutter "synchro"
         }
         1 {
            cam$camNo shutter "closed"
         }
      }
      #--- Je configure le refroidissement
      if { $conf(apogee,$camItem,cool) == "1" } {
         cam$camNo cooler on
         cam$camNo cooler check $conf(apogee,$camItem,temp)
      } else {
         cam$camNo cooler off
      }
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(apogee,$camItem,mirh)
      cam$camNo mirrorv $conf(apogee,$camItem,mirv)
      #--- Je mesure la temperature du capteur CCD et la puissance du Peltier
      if { [ ::apogee::getPluginProperty $camItem hasTempSensor ] == "1" } {
         if { [ info exists private(aftertemp) ] == "0" } {
            ::apogee::dispTempApogee $camItem
         }
      }
      #--- Gestion des widgets actifs/inactifs
      if { [ ::apogee::getPluginProperty $camItem hasTempSensor ] == "0" } {
         set ::apogee::private($camItem,cool) "0"
         set conf(apogee,$camItem,cool)       $private($camItem,cool)
      }
      ::apogee::checkConfigRefroidissement $camItem
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::apogee::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la camera Apogee
#
proc ::apogee::stop { camItem } {
   variable private

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# dispTempApogee
#    Affiche la temperature du CCD et la puissance du Peltier
#
proc ::apogee::dispTempApogee { camItem } {
   variable private
   global caption

   if { [ catch { set tempstatus [ cam$private($camItem,camNo) infotemp ] } ] == "0" } {
      set temp_check                [ format "%+5.1f" [ lindex $tempstatus 0 ] ]
      set temp_ccd                  [ format "%+5.1f" [ lindex $tempstatus 1 ] ]
      set temp_ambiant              [ format "%+5.1f" [ lindex $tempstatus 2 ] ]
      set regulation                [ lindex $tempstatus 3 ]
      set private($camItem,power)   "$caption(apogee,puissance_peltier) [ format "%3.0f" [ expr 100.*[ lindex $tempstatus 4 ]/255. ] ] %"
      set private($camItem,ccdTemp) "$caption(apogee,temperature_CCD) $temp_ccd $caption(apogee,deg_c)"
      set private(aftertemp) [ after 5000 ::apogee::dispTempApogee $camItem ]
   } else {
      set temp_check                ""
      set temp_ccd                  ""
      set temp_ambiant              ""
      set regulation                ""
      set power                     "--"
      set private($camItem,power)   "$caption(apogee,puissance_peltier) $power"
      set private($camItem,ccdTemp) "$caption(apogee,temperature_CCD) $temp_ccd"
      if { [ info exists private(aftertemp) ] == "1" } {
        unset private(aftertemp)
      }
   }
}

#
# checkConfigRefroidissement
#    Configure le widget de la consigne en temperature
#
proc ::apogee::checkConfigRefroidissement { camItem } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::apogee::private($camItem,cool) == "1" } {
            pack $frm.frame1.frame3.frame5.frame6.temp -anchor center -side left -padx 5 -pady 5
            pack $frm.frame1.frame3.frame5.frame6.tempdeg -side left -fill x -padx 0 -pady 5
            if { [ ::apogee::getPluginProperty $camItem hasTempSensor ] == "1" } {
               pack $frm.frame1.frame3.frame5.frame7.power -side left -fill x -padx 20 -pady 5
               pack $frm.frame1.frame3.frame5.frame8.ccdtemp -side left -fill x -padx 20 -pady 5
            } else {
               pack forget $frm.frame1.frame3.frame5.frame7.power
               pack forget $frm.frame1.frame3.frame5.frame8.ccdtemp
            }
         } else {
            pack forget $frm.frame1.frame3.frame5.frame6.temp
            pack forget $frm.frame1.frame3.frame5.frame6.tempdeg
            pack forget $frm.frame1.frame3.frame5.frame7.power
            pack forget $frm.frame1.frame3.frame5.frame8.ccdtemp
         }
      }
   }
}

#
# setTempCCD
#    Procedure pour retourner la consigne de temperature du CCD
#
proc ::apogee::setTempCCD { camItem } {
   global conf

   return "$conf(apogee,$camItem,temp)"
}

#
# setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::apogee::setShutter { camItem shutterState ShutterOptionList } {
   variable private
   global caption conf

   set conf(apogee,$camItem,foncobtu) $shutterState
   set camNo $private($camItem,camNo)

   console::affiche_resultat "camItem=$camItem shutterState=$shutterState ShutterOptionList=$ShutterOptionList\n"

   #--- Gestion du mode de fonctionnement
   switch -exact -- $shutterState {
      2  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "synchro"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private($camItem,foncobtu) $caption(apogee,obtu_synchro)
      }
      1  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "closed"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private($camItem,foncobtu) $caption(apogee,obtu_ferme)
      }
   }
}

#
# getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# binningList :      Retourne la liste des binnings disponibles
# binningXListScan : Retourne la liste des binnings en x disponibles en mode scan
# binningYListScan : Retourne la liste des binnings en y disponibles en mode scan
# dynamic :          Retourne la liste de la dynamique haute et basse
# hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
# hasFormat :        Retourne l'existence d'un format (1 : Oui, 0 : Non)
# hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
# hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
# hasShutter :       Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
# hasTempSensor      Retourne l'existence du capteur de temperature (1 : Oui, 0 : Non)
# hasSetTemp         Retourne l'existence d'une consigne de temperature (1 : Oui, 0 : Non)
# hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# name :             Retourne le modele de la camera
# product :          Retourne le nom du produit
# shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)
#
proc ::apogee::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 7x7 8x8 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 65535 0 ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 1 }
      hasTempSensor    {
         if { $private($camItem,camNo) != "0" } {
            return [ lindex [ lindex [ cam$private($camItem,camNo) coolerinformations ] 0 ] 1 ]
            #return 1
         } else {
            return ""
         }
      }
      hasSetTemp       {
         if { $private($camItem,camNo) != "0" } {
            return [ lindex [ lindex [ cam$private($camItem,camNo) coolerinformations ] 0 ] 1 ]
            #return 1
         } else {
            return ""
         }
      }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 1 }
      name             {
         if { $private($camItem,camNo) != "0" } {
            return [ cam$private($camItem,camNo) name ]
         } else {
            return ""
         }
      }
      product          {
         if { $private($camItem,camNo) != "0" } {
            return [ cam$private($camItem,camNo) product ]
         } else {
            return ""
         }
      }
      shutterList      { return [ list $::caption(apogee,obtu_synchro) $::caption(apogee,obtu_ferme) ] }
   }
}

