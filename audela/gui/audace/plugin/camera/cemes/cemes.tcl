#
# Fichier : cemes.tcl
# Description : Configuration de la camera Cemes
# Auteur : Robert DELMAS
# Mise à jour $Id: cemes.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::cemes {
   package provide cemes 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] cemes.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::cemes::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libcemes.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::cemes::getPluginType]] "cemes" "libcemes.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(cemes,installNewVersion) $sourceFileName [package version cemes] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::cemes::getPluginTitle { } {
   global caption

   return "$caption(cemes,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::cemes::getPluginHelp { } {
   return "cemes.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::cemes::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::cemes::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::cemes::getPluginDirectory { } {
   return "cemes"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::cemes::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::cemes::isReady { camItem } {
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
#    Initialise les variables conf(cemes,...)
#
proc ::cemes::initPlugin { } {
   variable private
   global conf caption

   #--- Initialise les variables de la camera Cemes
   if { ! [ info exists conf(cemes,cool) ] }     { set conf(cemes,cool)     "0" }
   if { ! [ info exists conf(cemes,foncobtu) ] } { set conf(cemes,foncobtu) "2" }
   if { ! [ info exists conf(cemes,mirh) ] }     { set conf(cemes,mirh)     "0" }
   if { ! [ info exists conf(cemes,mirv) ] }     { set conf(cemes,mirv)     "0" }
   if { ! [ info exists conf(cemes,temp) ] }     { set conf(cemes,temp)     "-50" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
   set private(ccdTemp) "$caption(cemes,temperature_CCD)"
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::cemes::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Cemes dans le tableau private(...)
   set private(cool)     $conf(cemes,cool)
   set private(foncobtu) [ lindex "$caption(cemes,obtu_ouvert) $caption(cemes,obtu_ferme) $caption(cemes,obtu_synchro)" $conf(cemes,foncobtu) ]
   set private(mirh)     $conf(cemes,mirh)
   set private(mirv)     $conf(cemes,mirv)
   set private(temp)     $conf(cemes,temp)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::cemes::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Cemes dans le tableau conf(cemes,...)
   set conf(cemes,cool)     $private(cool)
   set conf(cemes,foncobtu) [ lsearch "$caption(cemes,obtu_ouvert) $caption(cemes,obtu_ferme) $caption(cemes,obtu_synchro)" "$private(foncobtu)" ]
   set conf(cemes,mirh)     $private(mirh)
   set conf(cemes,mirv)     $private(mirv)
   set conf(cemes,temp)     $private(temp)
}

#
# fillConfigPage
#    Interface de configuration de la camera Cemes
#
proc ::cemes::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::cemes::confToWidget

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
            checkbutton $frm.frame1.frame3.frame4.mirx -text "$caption(cemes,miroir_x)" -highlightthickness 0 \
               -variable ::cemes::private(mirh)
            pack $frm.frame1.frame3.frame4.mirx -anchor w -side top -padx 20 -pady 10

            checkbutton $frm.frame1.frame3.frame4.miry -text "$caption(cemes,miroir_y)" -highlightthickness 0 \
               -variable ::cemes::private(mirv)
            pack $frm.frame1.frame3.frame4.miry -anchor w -side top -padx 20 -pady 10

         pack $frm.frame1.frame3.frame4 -anchor n -side left -fill x -padx 20

         #--- Frame du refroidissement et de la temperature du capteur CCD
         frame $frm.frame1.frame3.frame5 -borderwidth 0 -relief raised

            #--- Frame du refroidissement
            frame $frm.frame1.frame3.frame5.frame6 -borderwidth 0 -relief raised

               #--- Definition du refroidissement
               checkbutton $frm.frame1.frame3.frame5.frame6.cool -text "$caption(cemes,refroidissement)" \
                  -highlightthickness 0 -variable ::cemes::private(cool) -command "::cemes::checkConfigRefroidissement"
               pack $frm.frame1.frame3.frame5.frame6.cool -anchor center -side left -padx 0 -pady 5

               entry $frm.frame1.frame3.frame5.frame6.temp -textvariable ::cemes::private(temp) -width 4 \
                  -justify center \
                  -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double -274 50 }
               pack $frm.frame1.frame3.frame5.frame6.temp -anchor center -side left -padx 5 -pady 5

               label $frm.frame1.frame3.frame5.frame6.tempdeg \
                  -text "$caption(cemes,refroidissement_1)"
               pack $frm.frame1.frame3.frame5.frame6.tempdeg -side left -fill x -padx 0 -pady 5

            pack $frm.frame1.frame3.frame5.frame6 -side top -fill x -padx 10

            #--- Frame de la temperature du capteur CCD
            frame $frm.frame1.frame3.frame5.frame7 -borderwidth 0 -relief raised

               #--- Definition de la temperature du capteur CCD
               label $frm.frame1.frame3.frame5.frame7.ccdtemp -textvariable ::cemes::private(ccdTemp)
               pack $frm.frame1.frame3.frame5.frame7.ccdtemp -side left -fill x -padx 20 -pady 5

            pack $frm.frame1.frame3.frame5.frame7 -side top -fill x -padx 30

         pack $frm.frame1.frame3.frame5 -side left -fill x -expand 0

      pack $frm.frame1.frame3 -side top -fill x -expand 0

      #--- Frame du mode de fonctionnement de l'obturateur
      frame $frm.frame1.frame8 -borderwidth 0 -relief raised

         #--- Mode de fonctionnement de l'obturateur
         label $frm.frame1.frame8.lab3 -text "$caption(cemes,fonc_obtu)"
         pack $frm.frame1.frame8.lab3 -anchor nw -side left -padx 10 -pady 5

         set list_combobox [ list $caption(cemes,obtu_ouvert) $caption(cemes,obtu_ferme) $caption(cemes,obtu_synchro) ]
         ComboBox $frm.frame1.frame8.foncobtu \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [ llength $list_combobox ] \
            -relief sunken      \
            -borderwidth 1      \
            -editable 0         \
            -textvariable ::cemes::private(foncobtu) \
            -values $list_combobox
         pack $frm.frame1.frame8.foncobtu -anchor nw -side left -padx 0 -pady 5

      pack $frm.frame1.frame8 -side top -fill x -expand 0

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la Cemes
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(cemes,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(cemes,site_web_ref)" \
         "$caption(cemes,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::cemes::checkConfigRefroidissement

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la camera Cemes en fonction des donnees contenues dans les variables conf(cemes,...)
#
proc ::cemes::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je cree la camera
      set camNo [ cam::create cemes PCI \
         -log_file [::confCam::getLogFileName $camItem] \
         -log_level [::confCam::getLogLevel $camItem] \
      ]
      console::affiche_entete "$caption(cemes,port_camera) $caption(cemes,2points) [ cam$camNo port ]\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je configure l'obturateur
      switch -exact -- $conf(cemes,foncobtu) {
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
      if { $conf(cemes,cool) == "1" } {
         cam$camNo cooler on
         cam$camNo cooler check $conf(cemes,temp)
      } else {
         cam$camNo cooler off
      }
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(cemes,mirh)
      cam$camNo mirrorv $conf(cemes,mirv)
      #--- Je mesure la temperature du capteur CCD
      if { [ info exists private(aftertemp) ] == "0" } {
         ::cemes::dispTempCemes $camItem
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::cemes::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la camera Cemes
#
proc ::cemes::stop { camItem } {
   variable private

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# dispTempCemes
#    Affiche la temperature du CCD
#
proc ::cemes::dispTempCemes { camItem } {
   variable private
   global caption

   if { [ catch { set temp_ccd [ cam$private($camItem,camNo) temperature ] } ] == "0" } {
      set temp_ccd [ format "%+5.2f" $temp_ccd ]
      set private(ccdTemp)   "$caption(cemes,temperature_CCD) $temp_ccd $caption(cemes,deg_c)"
      set private(aftertemp) [ after 5000 ::cemes::dispTempCemes $camItem ]
   } else {
      set temp_ccd ""
      set private(ccdTemp) "$caption(cemes,temperature_CCD) $temp_ccd"
      if { [ info exists private(aftertemp) ] == "1" } {
         unset private(aftertemp)
      }
   }
}

#
# checkConfigRefroidissement
#    Configure le widget de la consigne en temperature
#
proc ::cemes::checkConfigRefroidissement { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::cemes::private(cool) == "1" } {
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
proc ::cemes::setTempCCD { camItem } {
   global conf

   return "$conf(cemes,temp)"
}

#
# setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::cemes::setShutter { camItem shutterState ShutterOptionList } {
   variable private
   global caption conf

   set conf(cemes,foncobtu) $shutterState
   set camNo $private($camItem,camNo)

   #--- Gestion du mode de fonctionnement
   switch -exact -- $shutterState {
      0  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "opened"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(cemes,obtu_ouvert)
      }
      1  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "closed"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(cemes,obtu_ferme)
      }
      2  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "synchro"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private(foncobtu) $caption(cemes,obtu_synchro)
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
proc ::cemes::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 4x4 8x8 ] }
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
      shutterList      { return [ list $::caption(cemes,obtu_ouvert) $::caption(cemes,obtu_ferme) $::caption(cemes,obtu_synchro) ] }
   }
}

