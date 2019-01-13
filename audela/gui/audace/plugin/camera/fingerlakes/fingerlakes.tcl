#
# Fichier : fingerlakes.tcl
# Description : Configuration de la camera FLI (Finger Lakes Instrumentation)
# Auteur : Robert DELMAS
# Mise à jour $Id: fingerlakes.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::fingerlakes {
   package provide fingerlakes 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] fingerlakes.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::fingerlakes::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libfingerlakes.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::fingerlakes::getPluginType]] "fingerlakes" "libfingerlakes.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libfli.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::fingerlakes::getPluginType]] "fingerlakes" "libfli.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(fingerlakes,installNewVersion) $sourceFileName [package version fingerlakes] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::fingerlakes::getPluginTitle { } {
   global caption

   return "$caption(fingerlakes,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::fingerlakes::getPluginHelp { } {
   return "fingerlakes.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::fingerlakes::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::fingerlakes::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::fingerlakes::getPluginDirectory { } {
   return "fingerlakes"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::fingerlakes::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::fingerlakes::isReady { camItem } {
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
#    Initialise les variables conf(fingerlakes,...)
#
proc ::fingerlakes::initPlugin { } {
   variable private
   global conf caption

   #--- Initialise les variables de la camera FLI
   if { ! [ info exists conf(fingerlakes,cool) ] }     { set conf(fingerlakes,cool)     "0" }
   if { ! [ info exists conf(fingerlakes,foncobtu) ] } { set conf(fingerlakes,foncobtu) "2" }
   if { ! [ info exists conf(fingerlakes,readSpeed) ] } { set conf(fingerlakes,readSpeed) "" }
   if { ! [ info exists conf(fingerlakes,mirh) ] }     { set conf(fingerlakes,mirh)     "0" }
   if { ! [ info exists conf(fingerlakes,mirv) ] }     { set conf(fingerlakes,mirv)     "0" }
   if { ! [ info exists conf(fingerlakes,temp) ] }     { set conf(fingerlakes,temp)     -20 }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
   set private(ccdTemp) "$::caption(fingerlakes,temperature_CCD) -- $::caption(fingerlakes,deg_c) / -- $::caption(fingerlakes,deg_c) $::caption(fingerlakes,power) -- %"
   set private(readSpeed) ""
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::fingerlakes::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera fingerlakes dans le tableau private(...)
   set private(cool)     $conf(fingerlakes,cool)
   set private(foncobtu) [ lindex "$caption(fingerlakes,obtu_ouvert) $caption(fingerlakes,obtu_ferme) $caption(fingerlakes,obtu_synchro)" $conf(fingerlakes,foncobtu) ]
   set private(readSpeed) $conf(fingerlakes,readSpeed)
   set private(mirh)     $conf(fingerlakes,mirh)
   set private(mirv)     $conf(fingerlakes,mirv)
   set private(temp)     $conf(fingerlakes,temp)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::fingerlakes::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera FLI dans le tableau conf(fingerlakes,...)
   set conf(fingerlakes,cool)     $private(cool)
   set conf(fingerlakes,foncobtu) [ lsearch "$caption(fingerlakes,obtu_ouvert) $caption(fingerlakes,obtu_ferme) $caption(fingerlakes,obtu_synchro)" "$private(foncobtu)" ]
   set conf(fingerlakes,readSpeed) $private(readSpeed)
   set conf(fingerlakes,mirh)     $private(mirh)
   set conf(fingerlakes,mirv)     $private(mirv)
   set conf(fingerlakes,temp)     $private(temp)
}

#
# fillConfigPage
#    Interface de configuration de la camera FLI
#
proc ::fingerlakes::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::fingerlakes::confToWidget

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

            #--- Miroir en x et en y
            checkbutton $frm.frame1.frame3.frame4.mirx -text "$caption(fingerlakes,miroir_x)" -highlightthickness 0 \
               -variable ::fingerlakes::private(mirh)
            pack $frm.frame1.frame3.frame4.mirx -anchor w -side top -padx 20 -pady 10

            checkbutton $frm.frame1.frame3.frame4.miry -text "$caption(fingerlakes,miroir_y)" -highlightthickness 0 \
               -variable ::fingerlakes::private(mirv)
            pack $frm.frame1.frame3.frame4.miry -anchor w -side top -padx 20 -pady 10

         pack $frm.frame1.frame3.frame4 -anchor n -side left -fill x -padx 20

         #--- Frame du refroidissement et de la temperature du capteur CCD
         frame $frm.frame1.frame3.frame5 -borderwidth 0 -relief raised

            #--- Frame du refroidissement
            frame $frm.frame1.frame3.frame5.frame6 -borderwidth 0 -relief raised

               #--- Definition du refroidissement
               checkbutton $frm.frame1.frame3.frame5.frame6.cool -text "$caption(fingerlakes,refroidissement)" \
                  -highlightthickness 0 -variable ::fingerlakes::private(cool) \
                  -command "::fingerlakes::checkConfigRefroidissement"
               pack $frm.frame1.frame3.frame5.frame6.cool -anchor center -side left -padx 0 -pady 5

               entry $frm.frame1.frame3.frame5.frame6.temp -textvariable ::fingerlakes::private(temp) -width 4 \
                  -justify center \
                  -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double -274 50 }
               pack $frm.frame1.frame3.frame5.frame6.temp -anchor center -side left -padx 5 -pady 5

               label $frm.frame1.frame3.frame5.frame6.tempdeg \
                  -text "$caption(fingerlakes,refroidissement_1)"
               pack $frm.frame1.frame3.frame5.frame6.tempdeg -side left -fill x -padx 0 -pady 5

            pack $frm.frame1.frame3.frame5.frame6 -side top -fill x -padx 10

            #--- Frame de la temperature du capteur CCD
            frame $frm.frame1.frame3.frame5.frame7 -borderwidth 0 -relief raised

               #--- Definition de la temperature du capteur CCD
               label $frm.frame1.frame3.frame5.frame7.ccdtemp -textvariable ::fingerlakes::private(ccdTemp)
               pack $frm.frame1.frame3.frame5.frame7.ccdtemp -side left -fill x -padx 20 -pady 5

            pack $frm.frame1.frame3.frame5.frame7 -side top -fill x -padx 30

         pack $frm.frame1.frame3.frame5 -side left -fill x -expand 0

      pack $frm.frame1.frame3 -side top -fill x -expand 0

      #--- Frame du mode de fonctionnement de l'obturateur
      frame $frm.frame1.frame8 -borderwidth 0 -relief raised

         #--- Mode de fonctionnement de l'obturateur
         label $frm.frame1.frame8.lab3 -text "$caption(fingerlakes,fonc_obtu)"
         pack $frm.frame1.frame8.lab3 -anchor nw -side left -padx 10 -pady 5

         set list_combobox [ list $caption(fingerlakes,obtu_ouvert) $caption(fingerlakes,obtu_ferme) \
            $caption(fingerlakes,obtu_synchro) ]
         ComboBox $frm.frame1.frame8.foncobtu \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [ llength $list_combobox ] \
            -relief sunken      \
            -borderwidth 1      \
            -editable 0         \
            -textvariable ::fingerlakes::private(foncobtu) \
            -values $list_combobox
         pack $frm.frame1.frame8.foncobtu -anchor nw -side left -padx 0 -pady 5

      pack $frm.frame1.frame8 -side top -fill x -expand 0

      #--- Frame du mode de lecture du CCD
      frame $frm.frame1.readSpeed -borderwidth 0 -relief raised

         #--- Mode de lecture du CCD
         label $frm.frame1.readSpeed.label -text "$caption(fingerlakes,readSpeed)"
         pack $frm.frame1.readSpeed.label -anchor nw -side left -padx 10 -pady 5

         #--- Cette liste est vide au demarrage. Elle sera remplie apres la connexion de la camera
         set list_combobox ""
         ComboBox $frm.frame1.readSpeed.list \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [ llength $list_combobox ] \
            -relief sunken      \
            -borderwidth 1      \
            -editable 0         \
            -state disabled     \
            -textvariable ::fingerlakes::private(readSpeed) \
            -values $list_combobox
         pack $frm.frame1.readSpeed.list -anchor nw -side left -padx 0 -pady 5

      pack $frm.frame1.readSpeed -side top -fill x -expand 0

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la FLI
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(fingerlakes,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(fingerlakes,site_web_ref)" \
         "$caption(fingerlakes,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::fingerlakes::checkConfigRefroidissement

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   #--- Configure la liste des modes de lecture du CCD
   if { $private($camItem,camNo) != "0" } {
      set readSpeedList [cam$private($camItem,camNo) flimodes] ; #--- je recupere la liste des vitesses
      if { $readSpeedList != "" } {
         $private(frm).frame1.readSpeed.list configure \
            -values $readSpeedList \
            -width [ ::tkutil::lgEntryComboBox $readSpeedList ] \
            -height [ llength $readSpeedList ] \
            -state normal
      }
   }
}

#
# configureCamera
#    Configure la camera FLI en fonction des donnees contenues dans les variables conf(fingerlakes,...)
#
proc ::fingerlakes::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je cree la camera
      set camNo [ cam::create fingerlakes USB \
         -log_file [::confCam::getLogFileName $camItem] \
         -log_level [::confCam::getLogLevel $camItem] \
      ]
      console::affiche_entete "$caption(fingerlakes,port_camera) ([ cam$camNo name ]) $caption(fingerlakes,2points) USB\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je configure l'obturateur
      switch -exact -- $conf(fingerlakes,foncobtu) {
         0 {
            cam$camNo shutter "opened"
         }
         1 {
            cam$camNo shutter "closed"
         }
         2 {
            cam$camNo shutter "synchro"
         }
      }
      #--- Je configure le refroidissement
      if { $conf(fingerlakes,cool) == "1" } {
         cam$camNo cooler on
         cam$camNo cooler check $conf(fingerlakes,temp)
      } else {
         cam$camNo cooler off
      }
      #--- Je configure la vitesse de lecture
      set readSpeedList [cam$camNo flimodes] ; #--- je recupere la liste des vitesses
      if { $readSpeedList != "" } {
         if { [ info exists private(frm) ] } {
            if { [ winfo exists $private(frm) ] } {
               $private(frm).frame1.readSpeed.list configure \
                  -values $readSpeedList \
                  -width [ ::tkutil::lgEntryComboBox $readSpeedList ] \
                  -height [ llength $readSpeedList ] \
                  -state normal
            }
         }
         set speedNo [lsearch $readSpeedList $::conf(fingerlakes,readSpeed) ]
         if { $speedNo == -1 } {
            #--- si la vitesse de lecture n'existe pas, je selectionne la premiere
            set speedNo 0
            set conf(fingerlakes,readSpeed) [lindex $readSpeedList $speedNo]
         }
         cam$camNo flimode $speedNo
      }
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(fingerlakes,mirh)
      cam$camNo mirrorv $conf(fingerlakes,mirv)
      #--- Je mesure la temperature du capteur CCD
      if { [ info exists private(aftertemp) ] == "0" } {
         ::fingerlakes::dispTempFLI $camItem
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::fingerlakes::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la camera FLI
#
proc ::fingerlakes::stop { camItem } {
   variable private

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }

   #--- je desactive le choix de la vitesse de lecture
   if { [ info exists private(frm) ] } {
      if { [ winfo exists $private(frm) ] } {
         $private(frm).frame1.readSpeed.list configure -state disabled
      }
   }

}

#
# dispTempFLI
#    Affiche la temperature du CCD
#
proc ::fingerlakes::dispTempFLI { camItem } {
   variable private
   global caption

   if { [ catch { set temppower [ cam$private($camItem,camNo) temppower ] } ] == "0" } {
      set internTemp [ format "%+5.2f" [lindex $temppower 0] ]
      set externTemp [ format "%+5.2f" [lindex $temppower 1] ]
      set power      [ format "%+5.2f" [lindex $temppower 2] ]
      set private(ccdTemp)   "$caption(fingerlakes,temperature_CCD) $internTemp $caption(fingerlakes,deg_c) / $externTemp $caption(fingerlakes,deg_c) $caption(fingerlakes,power) $power %"
      set private(aftertemp) [ after 5000 ::fingerlakes::dispTempFLI $camItem ]
   } else {
      set temp_ccd ""
      set private(ccdTemp) "$caption(fingerlakes,temperature_CCD) -- $caption(fingerlakes,deg_c) / -- $caption(fingerlakes,deg_c) $caption(fingerlakes,power) -- %"
      if { [ info exists private(aftertemp) ] == "1" } {
         unset private(aftertemp)
      }
   }
}

#
# checkConfigRefroidissement
#    Configure le widget de la consigne en temperature
#
proc ::fingerlakes::checkConfigRefroidissement { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::fingerlakes::private(cool) == "1" } {
            pack $frm.frame1.frame3.frame5.frame6.temp -anchor center -side left -padx 5 -pady 5
            pack $frm.frame1.frame3.frame5.frame6.tempdeg -side left -fill x -padx 0 -pady 5
            $frm.frame1.frame3.frame5.frame7.ccdtemp configure -state normal
         } else {
            pack forget $frm.frame1.frame3.frame5.frame6.temp
            pack forget $frm.frame1.frame3.frame5.frame6.tempdeg
            $frm.frame1.frame3.frame5.frame7.ccdtemp configure -state disabled
         }
      }
   }
}

#
# setTempCCD
#    Procedure pour retourner la consigne de temperature du CCD
#
proc ::fingerlakes::setTempCCD { camItem } {
   global conf

   return "$conf(fingerlakes,temp)"
}

#
# getReadSpeed
#    retourne la vitesse de lecture
#
proc ::fingerlakes::getReadSpeed { } {
   return $::conf(fingerlakes,readSpeed)
}

#
# setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::fingerlakes::setShutter { camItem shutterState ShutterOptionList } {
   variable private
   global caption conf

   set conf(fingerlakes,foncobtu) $shutterState
   set camNo $private($camItem,camNo)

   #--- Gestion du mode de fonctionnement
   switch -exact -- $shutterState {
      0  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "opened"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(fingerlakes,obtu_ouvert)
      }
      1  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "closed"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(fingerlakes,obtu_ferme)
      }
      2  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "synchro"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(fingerlakes,obtu_synchro)
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
proc ::fingerlakes::getPluginProperty { camItem propertyName } {
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
      hasTempSensor    { return 1 }
      hasSetTemp       { return 1 }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
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
      shutterList      {
         #--- O + F + S - A confirmer avec le materiel
         return [ list $::caption(fingerlakes,obtu_ouvert) $::caption(fingerlakes,obtu_ferme) $::caption(fingerlakes,obtu_synchro) ]
      }
   }
}

