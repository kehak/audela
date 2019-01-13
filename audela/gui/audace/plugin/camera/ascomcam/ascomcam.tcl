#
# Fichier : ascomcam.tcl
# Description : Configuration de la camera ASCOM
# Auteur : Michel PUJOL et Robert DELMAS
# Mise à jour $Id: ascomcam.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::ascomcam {
   package provide ascomcam 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] ascomcam.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::ascomcam::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libascomcam.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::ascomcam::getPluginType]] "ascomcam" "libascomcam.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(ascomcam,installNewVersion) $sourceFileName [package version ascomcam] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::ascomcam::getPluginTitle { } {
   global caption

   return "$caption(ascomcam,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::ascomcam::getPluginHelp { } {
   return "ascomcam.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::ascomcam::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::ascomcam::getPluginOS { } {
   return [ list Windows ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::ascomcam::getPluginDirectory { } {
   return "ascomcam"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::ascomcam::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::ascomcam::isReady { camItem } {
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
#    Initialise les variables conf(ascomcam,...)
#
proc ::ascomcam::initPlugin { } {
   variable private

   #--- Initialise les variables de la camera ASCOM pour chaque item
   foreach camItem { A B C } {
      if { ! [ info exists ::conf(ascomcam,$camItem,modele) ] }   { set ::conf(ascomcam,$camItem,modele)   "" }
      if { ! [ info exists ::conf(ascomcam,$camItem,mirh) ] }     { set ::conf(ascomcam,$camItem,mirh)     "0" }
      if { ! [ info exists ::conf(ascomcam,$camItem,mirv) ] }     { set ::conf(ascomcam,$camItem,mirv)     "0" }
      if { ! [ info exists ::conf(ascomcam,$camItem,foncobtu) ] } { set ::conf(ascomcam,$camItem,foncobtu) "2" }
      if { ! [ info exists ::conf(ascomcam,$camItem,dimPixX) ] }  { set ::conf(ascomcam,$camItem,dimPixX)  "5.2" }
      if { ! [ info exists ::conf(ascomcam,$camItem,dimPixY) ] }  { set ::conf(ascomcam,$camItem,dimPixY)  "5.2" }
      if { ! [ info exists ::conf(ascomcam,$camItem,mode) ] }     { set ::conf(ascomcam,$camItem,mode)     "1" }

      set private($camItem,modele) ""
   }

   #--- Initialisation
   set private(A,camNo)      "0"
   set private(B,camNo)      "0"
   set private(C,camNo)      "0"
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::ascomcam::confToWidget { } {
   variable private

   #--- Recupere la configuration de la camera ASCOM dans le tableau private($camItem,...)
   foreach camItem { A B C } {
      set private($camItem,modele)   $::conf(ascomcam,$camItem,modele)
      set private($camItem,mirh)     $::conf(ascomcam,$camItem,mirh)
      set private($camItem,mirv)     $::conf(ascomcam,$camItem,mirv)
      set private($camItem,foncobtu) [ lindex "$::caption(ascomcam,obtu_ouvert) $::caption(ascomcam,obtu_ferme) $::caption(ascomcam,obtu_synchro)" $::conf(ascomcam,$camItem,foncobtu) ]
      set private($camItem,dimPixX)  $::conf(ascomcam,$camItem,dimPixX)
      set private($camItem,dimPixY)  $::conf(ascomcam,$camItem,dimPixY)
      set private($camItem,mode)     $::conf(ascomcam,$camItem,mode)
   }
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::ascomcam::widgetToConf { camItem } {
   variable private

   #--- Memorise la configuration de la camera ASCOM dans le tableau conf(ascomcam,...)
   set ::conf(ascomcam,$camItem,modele)   $private($camItem,modele)
   set ::conf(ascomcam,$camItem,mirh)     $private($camItem,mirh)
   set ::conf(ascomcam,$camItem,mirv)     $private($camItem,mirv)
   set ::conf(ascomcam,$camItem,foncobtu) [ lsearch "$::caption(ascomcam,obtu_ouvert) $::caption(ascomcam,obtu_ferme) $::caption(ascomcam,obtu_synchro)" "$private($camItem,foncobtu)" ]
   set ::conf(ascomcam,$camItem,dimPixX)  $private($camItem,dimPixX)
   set ::conf(ascomcam,$camItem,dimPixY)  $private($camItem,dimPixY)
   set ::conf(ascomcam,$camItem,mode)     $private($camItem,mode)
}

#
# fillConfigPage
#    Interface de configuration de la camera ASCOM
#
proc ::ascomcam::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm)                      $frm
   set private($camItem,ascomDriverName) ""

   #--- confToWidget
   ::ascomcam::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Plugins ASCOM installes sur le PC
   package require registry
   set private(ascomDriverNameList) ""
   set private(ascomDriverKeyList)  ""

   #--- je chercher les plugins ASCOM 6.0
   set catchError [ catch {
      set keyList [ ::registry keys "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Camera Drivers" ]
   }]
   if { $catchError == 0 } {
      foreach key $keyList {
         if { [ catch { ::registry get "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Camera Drivers\\$key" "" } name ] == 0 } {
         lappend private(ascomDriverNameList) $name
         lappend private(ascomDriverKeyList)  $key
         }
      }
   }

   #--- Je verifie le contenu de la liste
   if { [llength $private(ascomDriverNameList) ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      set index [ lsearch -exact $private(ascomDriverKeyList) $private($camItem,modele) ]
      if { $index == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private($camItem,modele)          [lindex $private(ascomDriverKeyList) 0]
         set private($camItem,ascomDriverName) [lindex $private(ascomDriverNameList) 0]
      } else {
         set private($camItem,ascomDriverName) [lindex $private(ascomDriverNameList) $index]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
      set private($camItem,modele)          ""
      set private($camItem,ascomDriverName) ""
   }

   #--- Frame de la configuration du plugin et des miroirs en x et en y
   frame $frm.frame1 -borderwidth 0 -relief raised

      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         #--- Frame de la configuration du plugin
         frame $frm.frame1.frame3.frame4 -borderwidth 0 -relief raised

            #--- Definition du plugin
            label $frm.frame1.frame3.frame4.lab1 -text "$caption(ascomcam,modele)"
            pack $frm.frame1.frame3.frame4.lab1 -anchor center -side left -padx 10 -pady 30

            #--- Choix du plugin
            ComboBox $frm.frame1.frame3.frame4.driver \
               -width [ ::tkutil::lgEntryComboBox $private(ascomDriverNameList) ] \
               -height [ llength $private(ascomDriverNameList) ] \
               -relief sunken                \
               -borderwidth 1                \
               -editable 0                   \
               -textvariable ::ascomcam::private($camItem,ascomDriverName) \
               -modifycmd ::ascomcam::onSelectDriver \
               -values $private(ascomDriverNameList)
            pack $frm.frame1.frame3.frame4.driver -fill x -expand 1 -anchor center -side left -padx 10 -pady 10

            #--- Bouton de configuration du plugin
            button $frm.frame1.frame3.frame4.configure -text "$caption(ascomcam,configurer)" -relief raised \
               -command "::ascomcam::displayDriverSetupDialog "
            pack $frm.frame1.frame3.frame4.configure -anchor center -side left -pady 28 -ipadx 10 -ipady 1 -expand 0

         pack $frm.frame1.frame3.frame4 -anchor nw -side left -fill x

         #--- Frame des miroirs en x et en y
         frame $frm.frame1.frame3.frame5 -borderwidth 0 -relief raised

            #--- Miroir en x et en y
            checkbutton $frm.frame1.frame3.frame5.mirx -text "$caption(ascomcam,miroir_x)" -highlightthickness 0 \
               -variable ::ascomcam::private($camItem,mirh)
            pack $frm.frame1.frame3.frame5.mirx -anchor w -side top -padx 20 -pady 10

            checkbutton $frm.frame1.frame3.frame5.miry -text "$caption(ascomcam,miroir_y)" -highlightthickness 0 \
               -variable ::ascomcam::private($camItem,mirv)
            pack $frm.frame1.frame3.frame5.miry -anchor w -side top -padx 20 -pady 10

         pack $frm.frame1.frame3.frame5 -anchor nw -side top -fill x -padx 20

      pack $frm.frame1.frame3 -anchor nw -side top -fill x

      frame $frm.frame1.frame6 -borderwidth 0 -relief raised

         frame $frm.frame1.frame6.frame7 -borderwidth 0 -relief raised

            frame $frm.frame1.frame6.frame7.frame8 -borderwidth 0 -relief raised

               #--- Dimension des pixels sur l'axe X
               label $frm.frame1.frame6.frame7.frame8.labelDimPixX -text "$caption(ascomcam,dimPixelX)"
               pack $frm.frame1.frame6.frame7.frame8.labelDimPixX -anchor w -side left -padx 10 -pady 10

               entry $frm.frame1.frame6.frame7.frame8.entryDimPixX -textvariable ::ascomcam::private($camItem,dimPixX) \
                  -width 7 -justify center
               pack $frm.frame1.frame6.frame7.frame8.entryDimPixX -anchor w -side left -pady 10

            pack $frm.frame1.frame6.frame7.frame8 -anchor nw -side top -fill x

            frame $frm.frame1.frame6.frame7.frame9 -borderwidth 0 -relief raised

               #--- Dimension des pixels sur l'axe Y
               label $frm.frame1.frame6.frame7.frame9.labelDimPixY -text "$caption(ascomcam,dimPixelY)"
               pack $frm.frame1.frame6.frame7.frame9.labelDimPixY -anchor w -side left -padx 10 -pady 10

               entry $frm.frame1.frame6.frame7.frame9.entryDimPixY -textvariable ::ascomcam::private($camItem,dimPixY) \
                  -width 7 -justify center
               pack $frm.frame1.frame6.frame7.frame9.entryDimPixY -anchor w -side left -pady 10

            pack $frm.frame1.frame6.frame7.frame9 -anchor nw -side top -fill x

         pack $frm.frame1.frame6.frame7 -anchor nw -side left -fill x

         frame $frm.frame1.frame6.frame9 -borderwidth 0 -relief raised

            frame $frm.frame1.frame6.frame9.frame10 -borderwidth 0 -relief raised

               #--- Selection mode manuel
               radiobutton $frm.frame1.frame6.frame9.frame10.radioManuel -anchor w -highlightthickness 0 \
                  -text "$caption(ascomcam,manuel)" -value 0 \
                  -variable ::ascomcam::private($camItem,mode) -command "::ascomcam::selectMode $camItem"
               pack $frm.frame1.frame6.frame9.frame10.radioManuel -anchor nw -side top -padx 20 -pady 10

            pack $frm.frame1.frame6.frame9.frame10 -anchor nw -side top -fill x

            frame $frm.frame1.frame6.frame9.frame11 -borderwidth 0 -relief raised

               #--- Selection mode automatique
               radiobutton $frm.frame1.frame6.frame9.frame11.radioAuto -anchor w -highlightthickness 0 \
                  -text "$caption(ascomcam,auto)" -value 1 \
                  -variable ::ascomcam::private($camItem,mode) -command "::ascomcam::selectMode $camItem"
               pack $frm.frame1.frame6.frame9.frame11.radioAuto -anchor nw -side top -padx 20 -pady 10

            pack $frm.frame1.frame6.frame9.frame11 -anchor nw -side top -fill x

         pack $frm.frame1.frame6.frame9 -anchor nw -side left -fill x

         frame $frm.frame1.frame6.frame12 -borderwidth 0 -relief raised

            #--- Bouton de rafraichissement
            Button $frm.frame1.frame6.frame12.refresh -highlightthickness 0 -padx 10 -pady 3 -state normal \
               -text "$caption(ascomcam,rafraichir)" -command "::ascomcam::refreshCellDim $camItem"
            pack $frm.frame1.frame6.frame12.refresh -side left

         pack $frm.frame1.frame6.frame12 -anchor nw -side left -fill both

      pack $frm.frame1.frame6 -anchor center -side left -fill x

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la ASCOM
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(ascomcam,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(ascomcam,site_web_ref)" \
         "$caption(ascomcam,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::ascomcam::selectMode $camItem

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la camera en fonction des donnees contenues dans les variables conf(ascomcam,...)
#
proc ::ascomcam::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la camera
      set camNo [ cam::create ascomcam $conf(ascomcam,$camItem,modele) \
         -log_file [::confCam::getLogFileName $camItem] \
         -log_level [::confCam::getLogLevel $camItem] \
      ]
      #--- J'affiche dans la Console
      console::affiche_entete "$caption(ascomcam,port_camera) $caption(ascomcam,2points) [cam$camNo name]\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je rafraichit les dimensions des pixels
      ::ascomcam::refreshCellDim $camItem
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(ascomcam,$camItem,mirh)
      cam$camNo mirrorv $conf(ascomcam,$camItem,mirv)
      #--- Je configure l'obturateur
      switch -exact -- $conf(ascomcam,$camItem,foncobtu) {
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
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::ascomcam::stop $camItem
      #--- Je transmets l'erreur a la procedure appellante
      error $::errorInfo
   }
}

#
# stop
#    Arrete la camera
#
proc ::ascomcam::stop { camItem } {
   variable private

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# selectMode
#    Configure les widgets de configuration du choix du CCD
#
proc ::ascomcam::selectMode { camItem } {
   variable private

   set frm $private(frm)
   if { $::ascomcam::private($camItem,mode) == "0" } {
      #--- Cas du mode manuel
      $frm.frame1.frame6.frame7.frame8.entryDimPixX configure -state normal
      $frm.frame1.frame6.frame7.frame9.entryDimPixY configure -state normal
   } else {
      #--- Cas du mode automatique
      $frm.frame1.frame6.frame7.frame8.entryDimPixX configure -state disabled
      $frm.frame1.frame6.frame7.frame9.entryDimPixY configure -state disabled
   }
}

#
# refreshCellDim
#    Rafraichit les dimensions des pixels
#
proc ::ascomcam::refreshCellDim { camItem } {
   variable private

   #--- Si une camera est connectee
   if { $private($camItem,camNo) != 0 } {
      #--- J'envoie les dimensions des pixels a la librairie
      if { $::conf(ascomcam,$camItem,mode) == 0 } {
         cam$private($camItem,camNo) celldim [ expr $private($camItem,dimPixX) / 1000000 ] [ expr $private($camItem,dimPixY) / 1000000 ]
      } else {
      #--- Je lis les dimensions des pixels de la librairie
         set celldim [ cam$private($camItem,camNo) celldim ]
         set private($camItem,dimPixX) [ expr [ lindex $celldim 0 ] * 1000000 ]
         set private($camItem,dimPixY) [ expr [ lindex $celldim 1 ] * 1000000 ]
      }
   }
}

#
# selectCamera
#    affiche la fenetre pour selectionner une camera
#
proc ::ascomcam::selectCamera { camItem } {
   variable private

   load [file join $::audela_start_dir libascomcam.dll]
}

#
# setShutter
#    Procedure pour la commande de l'obturateur
#
proc ::ascomcam::setShutter { camItem shutterState ShutterOptionList } {
   variable private

   set ::conf(ascomcam,$camItem,foncobtu) $shutterState

   #--- Gestion du mode de fonctionnement
   switch -exact -- $shutterState {
      1  {
         #--- j'envoie la commande a la camera
         cam$private($camItem,camNo) shutter "closed"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private($camItem,foncobtu) $::caption(ascomcam,obtu_ferme)
      }
      2  {
         #--- j'envoie la commande a la camera
         cam$private($camItem,camNo) shutter "synchro"
         #--- je mets a jour le widget dans la fenetre de configuration si elle est ouverte
         set private($camItem,foncobtu) $::caption(ascomcam,obtu_synchro)
      }
   }
}

#
# onSelectDriver
#    copie la cle du driver choisi dans la variable private($camItem,modele)
#s
proc ::ascomcam::onSelectDriver { } {
   variable private

   set camItem                  [::confCam::getCurrentCamItem]
   set index                    [ $private(frm).frame1.frame3.frame4.driver getvalue ]
   set private($camItem,modele) [ lindex $private(ascomDriverKeyList) $index ]
}

#
# displayDriverSetupDialog
#    affiche la fenetre de configuration
#    fournie par le driver de la monture
#
proc ::ascomcam::displayDriverSetupDialog { } {
   variable private

   set camItem [::confCam::getCurrentCamItem]
   if { [ ::ascomcam::isReady $camItem] == 1 } {
      #--- la camera est deja connectee
      cam$private($camItem,camNo) setup
   } else {
      #--- la camera n'est pas connectée , je dois charger la librairie
      if { $private($camItem,modele) != "" } {
         load [file join $::audela_start_dir libascomcam.dll]
         ascomcam setup $private($camItem,modele)
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
proc ::ascomcam::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      {
         if { [::ascomcam::isReady $camItem ] == 1 } {
            set maxBin [cam$private($camItem,camNo) property maxbin]
            set binningList ""
            for { set i 1 } { $i <= $maxBin } { incr i } {
               lappend binningList "${i}x${i}"
            }
            return $binningList
         } else {
            return [ list 1x1 ]
         }
      }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 4096 -4096 ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       {
         if { [::ascomcam::isReady $camItem ] == 1 } {
            return [cam$private($camItem,camNo) property hasShutter]
         } else {
            return 0
         }
      }
      hasTempSensor    { return 0 }
      hasSetTemp       { return 0 }
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
      shutterList      { return [ list $::caption(sbig,obtu_ferme) $::caption(sbig,obtu_synchro)] }
   }
}

