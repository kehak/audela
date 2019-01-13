#
# Fichier : sbig.tcl
# Description : Configuration de la camera SBIG
# Auteur : Robert DELMAS
# Mise à jour $Id: sbig.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::sbig {
   package provide sbig 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] sbig.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::sbig::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libsbig.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::sbig::getPluginType]] "sbig" "libsbig.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(sbig,installNewVersion) $sourceFileName [package version sbig] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::sbig::getPluginTitle { } {
   global caption

   return "$caption(sbig,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::sbig::getPluginHelp { } {
   return "sbig.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::sbig::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::sbig::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::sbig::getPluginDirectory { } {
   return "sbig"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::sbig::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::sbig::isReady { camItem } {
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
#    Initialise les variables conf(sbig,...)
#
proc ::sbig::initPlugin { } {
   variable private
   global conf caption

   #--- Initialise les variables de la camera SBIG
   if { ! [ info exists conf(sbig,cool) ] }              { set conf(sbig,cool)              "0" }
   if { ! [ info exists conf(sbig,foncobtu) ] }          { set conf(sbig,foncobtu)          "2" }
   if { ! [ info exists conf(sbig,host) ] }              { set conf(sbig,host)              "192.168.0.2" }
   if { ! [ info exists conf(sbig,mirh) ] }              { set conf(sbig,mirh)              "0" }
   if { ! [ info exists conf(sbig,mirv) ] }              { set conf(sbig,mirv)              "0" }
   if { ! [ info exists conf(sbig,port) ] }              { set conf(sbig,port)              "LPT1:" }
   if { ! [ info exists conf(sbig,temp) ] }              { set conf(sbig,temp)              "0" }
   if { ! [ info exists conf(sbig,lptAddressValue) ] }   { set conf(sbig,lptAddressValue)   "" }
   if { ! [ info exists conf(sbig,lptAddressEnabled) ] } { set conf(sbig,lptAddressEnabled) "0" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
   set private(power)   "$caption(sbig,puissance_peltier_--)"
   set private(ccdTemp) "$caption(sbig,temp_ext)"
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::sbig::confToWidget { } {
   variable widget
   global caption conf

   #--- Copie la configuration de la camera SBIG dans le tableau widget(...)
   switch $conf(sbig,foncobtu) {
      1  {
         set widget(foncobtu) $caption(sbig,obtu_ferme)
      }
      2  {
         set widget(foncobtu) $caption(sbig,obtu_synchro)
      }
      default {
         #--- je mets "syncho" dans tous les autres cas pour eviter les erreurs
         set widget(foncobtu) $caption(sbig,obtu_synchro)
      }
   }
   set widget(cool)              $conf(sbig,cool)
   set widget(host)              $conf(sbig,host)
   set widget(mirh)              $conf(sbig,mirh)
   set widget(mirv)              $conf(sbig,mirv)
   set widget(port)              $conf(sbig,port)
   set widget(temp)              $conf(sbig,temp)
   set widget(lptAddressValue)   $conf(sbig,lptAddressValue)
   set widget(lptAddressEnabled) $conf(sbig,lptAddressEnabled)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::sbig::widgetToConf { camItem } {
   variable widget
   global caption conf

   #--- Memorise la configuration de la camera SBIG dans le tableau conf(sbig,...)
   switch $widget(foncobtu) {
      $caption(sbig,obtu_ferme)    { set conf(sbig,foncobtu) 1     }
      $caption(sbig,obtu_synchro)  { set conf(sbig,foncobtu) 2     }
      default                      { set conf(sbig,foncobtu) 2     }
   }

   set conf(sbig,cool)              $widget(cool)
   set conf(sbig,host)              $widget(host)
   set conf(sbig,mirh)              $widget(mirh)
   set conf(sbig,mirv)              $widget(mirv)
   set conf(sbig,port)              $widget(port)
   set conf(sbig,temp)              $widget(temp)
   set conf(sbig,lptAddressValue)   $widget(lptAddressValue)
   set conf(sbig,lptAddressEnabled) $widget(lptAddressEnabled)
}

#
# fillConfigPage
#    Interface de configuration de la camera SBIG
#
proc ::sbig::fillConfigPage { frm camItem } {
   variable private
   variable widget
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::sbig::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Je recupere la liste des ports paralelles
   set list_combobox [ ::confLink::getLinkLabels { "parallelport" } ]
   lappend list_combobox $caption(sbig,usb) $caption(sbig,ethernet)

   #--- Je verifie le contenu de la liste
   if { [llength $list_combobox ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_combobox $widget(port) ] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(port) [lindex $list_combobox 0]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
   }

   #--- Frame de la configuration du port
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Definition du port
      label $frm.frame1.lab1 -text "$caption(sbig,port)"
      pack $frm.frame1.lab1 -anchor center -side left -padx 10

      #--- Bouton de configuration des ports et liaisons
      button $frm.frame1.configure -text "$caption(sbig,configurer)" -relief raised \
         -command {
            ::confLink::run ::sbig::widget(port) { parallelport } \
               "- $caption(sbig,acquisition) - $caption(sbig,camera)"
         }
      pack $frm.frame1.configure -anchor center -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Choix du port ou de la liaison
      ComboBox $frm.frame1.port \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::sbig::widget(port) \
         -values $list_combobox \
         -modifycmd "::sbig::configurePort"
      pack $frm.frame1.port -anchor center -side left -padx 10

      #--- Frame pour la definition de l'adresse optionnelle de LPT et du host pour une connexion Ethernet
      frame $frm.frame1.address -borderwidth 0 -relief raised

         #--- Frame pour la definition de l'adresse optionnelle de LPT
         frame $frm.frame1.address.lpt -borderwidth 0 -relief flat

            #--- Definition de l'adresse optionnelle de LPT
            checkbutton $frm.frame1.address.lpt.checkbutton -text "$caption(sbig,lpt_custom)" \
               -highlightthickness 0 -variable ::sbig::widget(lptAddressEnabled) \
               -command "::sbig::configurePort"
            pack  $frm.frame1.address.lpt.checkbutton -anchor center -side left -padx 10

            entry $frm.frame1.address.lpt.entry -width 18 -textvariable ::sbig::widget(lptAddressValue)
            pack  $frm.frame1.address.lpt.entry -anchor center -side right -padx 10

         pack $frm.frame1.address.lpt -anchor center -side top -padx 10 -fill both -expand 1

         #--- Frame pour la definition du host pour une connexion Ethernet
         frame $frm.frame1.address.ethernet -borderwidth 0 -relief flat

            #--- Definition du host pour une connexion Ethernet
            label $frm.frame1.address.ethernet.lab2 -text "$caption(sbig,host)"
            pack  $frm.frame1.address.ethernet.lab2 -anchor center -side left -padx 10

            entry $frm.frame1.address.ethernet.host -width 18 -textvariable ::sbig::widget(host)
            pack  $frm.frame1.address.ethernet.host -anchor center -side right -padx 10

         pack $frm.frame1.address.ethernet -anchor center -side top -padx 10 -fill both -expand 1

      pack $frm.frame1.address -anchor center -side right -padx 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame des miroirs en x et en y, du refroidissement et de la temperature (du capteur CCD et exterieure)
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Frame des miroirs en x et en y
      frame $frm.frame2.frame5 -borderwidth 0 -relief raised

         #--- Miroirs en x et en y
         checkbutton $frm.frame2.frame5.mirx -text "$caption(sbig,miroir_x)" -highlightthickness 0 \
            -variable ::sbig::widget(mirh)
         pack $frm.frame2.frame5.mirx -anchor w -side top -padx 10 -pady 10

         checkbutton $frm.frame2.frame5.miry -text "$caption(sbig,miroir_y)" -highlightthickness 0 \
            -variable ::sbig::widget(mirv)
         pack $frm.frame2.frame5.miry -anchor w -side top -padx 10 -pady 10

      pack $frm.frame2.frame5 -side left -fill x -expand 0

      #--- Frame du refroidissement et de la temperature du capteur CCD
      frame $frm.frame2.frame6 -borderwidth 0 -relief raised

         #--- Frame du refroidissement
         frame $frm.frame2.frame6.frame7 -borderwidth 0 -relief raised

            #--- Definition du refroidissement
            checkbutton $frm.frame2.frame6.frame7.cool -text "$caption(sbig,refroidissement)" -highlightthickness 0 \
               -variable ::sbig::widget(cool) -command "::sbig::checkConfigRefroidissement"
            pack $frm.frame2.frame6.frame7.cool -anchor center -side left -padx 0 -pady 5

            entry $frm.frame2.frame6.frame7.temp -textvariable ::sbig::widget(temp) -width 4 \
               -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double -274 50 }
            pack $frm.frame2.frame6.frame7.temp -anchor center -side left -padx 5 -pady 5

            label $frm.frame2.frame6.frame7.tempdeg -text "$caption(sbig,refroidissement_1)"
            pack $frm.frame2.frame6.frame7.tempdeg -anchor center -side left -padx 0 -pady 5

         pack $frm.frame2.frame6.frame7 -side top -fill none -padx 30

         #--- Frame de la puissance de refroidissement
         frame $frm.frame2.frame6.frame8 -borderwidth 0 -relief raised

            label $frm.frame2.frame6.frame8.power -textvariable ::sbig::private(power)
            pack $frm.frame2.frame6.frame8.power -side left -fill x -padx 20 -pady 5

         pack $frm.frame2.frame6.frame8 -side top -fill x -padx 30

         #--- Frame de la temperature exterieure
         frame $frm.frame2.frame6.frame9 -borderwidth 0 -relief raised

            label $frm.frame2.frame6.frame9.ccdtemp -textvariable ::sbig::private(ccdTemp)
            pack $frm.frame2.frame6.frame9.ccdtemp -side left -fill x -padx 20 -pady 5

         pack $frm.frame2.frame6.frame9 -side top -fill x -padx 30

      pack $frm.frame2.frame6 -side left -expand 0 -padx 60

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Frame du mode de fonctionnement de l'obturateur
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Mode de fonctionnement de l'obturateur
      label $frm.frame3.lab3 -text "$caption(sbig,fonc_obtu)"
      pack $frm.frame3.lab3 -anchor center -side left -padx 10

      set list_combobox [ list $caption(sbig,obtu_ferme) $caption(sbig,obtu_synchro) ]
      ComboBox $frm.frame3.foncobtu \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken             \
         -borderwidth 1             \
         -editable 0                \
         -textvariable ::sbig::widget(foncobtu) \
         -values $list_combobox
      pack $frm.frame3.foncobtu -anchor center -side left -padx 10

   pack $frm.frame3 -side top -fill both -expand 1

   #--- Frame du site web officiel de la SBIG
   frame $frm.frame4 -borderwidth 0 -relief raised

      label $frm.frame4.lab103 -text "$caption(sbig,titre_site_web)"
      pack $frm.frame4.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame4 "$caption(sbig,site_web_ref)" \
         "$caption(sbig,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame4 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::sbig::configurePort
   ::sbig::checkConfigRefroidissement

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la camera SBIG en fonction des donnees contenues dans les variables conf(sbig,...)
#
proc ::sbig::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
     ### set conf(sbig,host) [ ::audace::verifip $conf(sbig,host) ]
      #--- Je configure l'adresse LPT personnalisee
      if { $conf(sbig,lptAddressEnabled) == 1 } {
         set lptAddress $conf(sbig,lptAddressValue)
      } else {
         set lptAddress ""
      }
      #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
      set linkNo [ ::confLink::create $conf(sbig,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
      #--- Je cree la camera
      if { $::tcl_platform(platform) == "windows" } {
         set camNo [ cam::create sbig $conf(sbig,port) \
            -log_file [::confCam::getLogFileName $camItem] \
            -log_level [::confCam::getLogLevel $camItem] \
            -ip $conf(sbig,host) \
            -lptaddress $lptAddress \
         ]
      } else {
         if { $conf(sbig,port)=="USB" || $conf(sbig,port)=="Ethernet" } {
            set camNo [ cam::create sbig $conf(sbig,port) \
               -log_file [::confCam::getLogFileName $camItem] \
               -log_level [::confCam::getLogLevel $camItem] \
               -ip $conf(sbig,host) \
            ]
         } else {
            set camNo [ cam::create sbigparallel $conf(sbig,port) \
               -log_file [::confCam::getLogFileName $camItem] \
               -log_level [::confCam::getLogLevel $camItem] \
               -lptaddress $lptAddress \
            ]
         }
      }
      console::affiche_entete "$caption(sbig,port_camera) ([ cam$camNo name ]) $caption(sbig,2points) $conf(sbig,port)\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je configure l'obturateur
      switch -exact -- $conf(sbig,foncobtu) {
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
      if { $conf(sbig,cool) == "1" } {
         cam$camNo cooler check $conf(sbig,temp)
      } else {
         cam$camNo cooler off
      }
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(sbig,mirh)
      cam$camNo mirrorv $conf(sbig,mirv)
      #--- Je mesure la temperature du capteur CCD
      if { [ info exists private(aftertemp) ] == "0" } {
         ::sbig::dispTempSbig $camItem
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::sbig::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la camera SBIG
#
proc ::sbig::stop { camItem } {
   variable private
   global conf

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(sbig,port) "cam$camItem" "acquisition"

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# dispTempSbig
#    Affiche la temperature du CCD
#
proc ::sbig::dispTempSbig { camItem } {
   variable private
   global caption

   if { [ catch { set tempstatus [ cam$private($camItem,camNo) infotemp ] } ] == "0" } {
      set temp_check         [ format "%+5.2f" [ lindex $tempstatus 0 ] ]
      set temp_ccd           [ format "%+5.2f" [ lindex $tempstatus 1 ] ]
      set temp_ambiant       [ format "%+5.2f" [ lindex $tempstatus 2 ] ]
      set regulation         [ lindex $tempstatus 3 ]
      set private(power)     "$caption(sbig,puissance_peltier) [ format "%3.0f" [ expr 100.*[ lindex $tempstatus 4 ]/255. ] ] %"
      set private(ccdTemp)   "$caption(sbig,temp_ext) $temp_ccd $caption(sbig,deg_c) / $temp_ambiant $caption(sbig,deg_c)"
      set private(aftertemp) [ after 5000 ::sbig::dispTempSbig $camItem ]
   } else {
      set temp_check       ""
      set temp_ccd         ""
      set temp_ambiant     ""
      set regulation       ""
      set power            "--"
      set private(power)   "$caption(sbig,puissance_peltier) $power"
      set private(ccdTemp) "$caption(sbig,temp_ext) $temp_ccd"
      if { [ info exists private(aftertemp) ] == "1" } {
        unset private(aftertemp)
      }
   }
}

#
# configurePort
#    Configure le bouton "Configurer" et le host
#
proc ::sbig::configurePort { } {
   variable private
   variable widget
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $widget(port) == "$caption(sbig,usb)" || $widget(port) == "$caption(sbig,ethernet)" } {
            $frm.frame1.configure configure -state disabled
         } else {
            $frm.frame1.configure configure -state normal
         }
         if { $widget(port) == "$caption(sbig,ethernet)" } {
            $frm.frame1.address.ethernet.lab2 configure -state normal
            $frm.frame1.address.ethernet.host configure -state normal
         } else {
            $frm.frame1.address.ethernet.lab2 configure -state disabled
            $frm.frame1.address.ethernet.host configure -state disabled
         }
         if { [string equal -length 3 $widget(port) "LPT"] == 1
              || [string equal -length 4 $widget(port) "/dev"] == 1 } {
            $frm.frame1.address.lpt.checkbutton configure -state normal
            if { $widget(lptAddressEnabled) == 1 } {
               $frm.frame1.address.lpt.entry configure -state normal
            } else {
               $frm.frame1.address.lpt.entry configure -state disabled
            }
         } else {
            $frm.frame1.address.lpt.checkbutton configure -state disabled
            $frm.frame1.address.lpt.entry configure -state disabled
         }
      }
   }
}

#
# checkConfigRefroidissement
#    Configure le widget de la consigne en temperature
#
proc ::sbig::checkConfigRefroidissement { } {
   variable private
   variable widget

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::sbig::widget(cool) == "1" } {
            pack $frm.frame2.frame6.frame7.temp -anchor center -side left -padx 5 -pady 5
            pack $frm.frame2.frame6.frame7.tempdeg -side left -fill x -padx 0 -pady 5
            $frm.frame2.frame6.frame8.power configure -state normal
            $frm.frame2.frame6.frame9.ccdtemp configure -state normal
         } else {
            pack forget $frm.frame2.frame6.frame7.temp
            pack forget $frm.frame2.frame6.frame7.tempdeg
            $frm.frame2.frame6.frame8.power configure -state disabled
            $frm.frame2.frame6.frame9.ccdtemp configure -state disabled
         }
      }
   }
}

#
# setTempCCD
#    Procedure pour retourner la consigne de temperature du CCD
#
proc ::sbig::setTempCCD { camItem } {
   global conf

   return "$conf(sbig,temp)"
}

#
# setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::sbig::setShutter { camItem shutterState ShutterOptionList } {
   variable private
   variable widget
   global caption conf

   set conf(sbig,foncobtu) $shutterState
   set camNo $private($camItem,camNo)

   #--- Gestion du mode de fonctionnement
   switch -exact -- $shutterState {
      1  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "closed"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set widget(foncobtu) $caption(sbig,obtu_ferme)
      }
      2  {
         #--- j'envoie la commande a la camera
         cam$camNo shutter "synchro"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set widget(foncobtu) $caption(sbig,obtu_synchro)
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
# shutterList :      Retourne l'etat de l'obturateur (F : Ferme, S : Synchro)
#
proc ::sbig::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
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
         #--- F + S
         return [ list $::caption(sbig,obtu_ferme) $::caption(sbig,obtu_synchro) ]
      }
   }
}

