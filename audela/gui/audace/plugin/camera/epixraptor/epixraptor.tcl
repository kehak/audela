#
# Fichier : epixraptor.tcl
# Description : Configuration de la camera Raptor
# Auteur : Matteo SCHIAVON
# Mise à jour $Id: epixraptor.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::epixraptor {
   package provide epixraptor 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] epixraptor.cap ]
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::epixraptor::getPluginTitle { } {
   global caption

   return "$caption(epixraptor,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::epixraptor::getPluginHelp { } {
   return "epixraptor.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::epixraptor::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::epixraptor::getPluginOS { } {
   return [ list Linux ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::epixraptor::getPluginDirectory { } {
   return "epixraptor"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::epixraptor::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::epixraptor::isReady { camItem } {
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
#    Initialise les variables conf(epixraptor,...)
#
proc ::epixraptor::initPlugin { } {
   variable private
   global audace conf caption

   #--- Initialise les variables de la camera Raptor OSPREY
   if { ! [ info exists conf(epixraptor,tec) ] }         { set conf(epixraptor,tec)       "1" }
   if { ! [ info exists conf(epixraptor,framerate) ] }   { set conf(epixraptor,framerate) "37.5" }
   if { ! [ info exists conf(epixraptor,config) ] }      { set conf(epixraptor,config)    "" }
   if { ! [ info exists conf(epixraptor,mirh) ] }        { set conf(epixraptor,mirh)      "0" }
   if { ! [ info exists conf(epixraptor,mirv) ] }        { set conf(epixraptor,mirv)      "0" }
   if { ! [ info exists conf(epixraptor,CMOStemp) ] }    { set conf(epixraptor,CMOStemp)  "" }
   if { ! [ info exists conf(epixraptor,exposure) ] }    { set conf(epixraptor,exposure)  "0.001" }
   if { ! [ info exists conf(epixraptor,roi_x1) ] }      { set conf(epixraptor,roi_x1)    "0" }
   if { ! [ info exists conf(epixraptor,roi_y1) ] }      { set conf(epixraptor,roi_y1)    "0" }
   if { ! [ info exists conf(epixraptor,roi_x2 ] }       { set conf(epixraptor,roi_x2)    "2047" }
   if { ! [ info exists conf(epixraptor,roi_y2) ] }      { set conf(epixraptor,roi_y2)    "2047" }
   if { ! [ info exists conf(epixraptor,binning) ] }     { set conf(epixraptor,binning)   "1" }
   if { ! [ info exists conf(epixraptor,extconfig) ] }   { set conf(epixraptor,extconfig) "0" }
   if { ! [ info exists conf(epixraptor,hdr) ] }         { set conf(epixraptor,hdr)       "0" }
   if { ! [ info exists conf(epixraptor,videomode) ] }   { set conf(epixraptor,videomode) "ffr" }

   #--- Initialisation
   set private(A,camNo)  "0"
   set private(B,camNo)  "0"
   set private(C,camNo)  "0"
   set private(CMOStemp) "$caption(epixraptor,temperature_CCD)"
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::epixraptor::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Raptor dans le tableau private(...)
   set private(tec)         $conf(epixraptor,tec)
   set private(framerate)   $conf(epixraptor,framerate)
   set private(config)      $conf(epixraptor,config)
   set private(extconfig)   $conf(epixraptor,extconfig)
   set private(mirh)        $conf(epixraptor,mirh)
   set private(mirv)        $conf(epixraptor,mirv)
   set private(CMOStemp)    $conf(epixraptor,CMOStemp)
   set private(exposure)    $conf(epixraptor,exposure)
   set private(roi_x1)      $conf(epixraptor,roi_x1)
   set private(roi_y1)      $conf(epixraptor,roi_y1)
   set private(roi_x2)      $conf(epixraptor,roi_x2)
   set private(roi_y2)      $conf(epixraptor,roi_y2)
   set private(hdr)         $conf(epixraptor,hdr)
   set private(videomode)   $conf(epixraptor,videomode)
   set private(binning)     "$conf(epixraptor,binning)x$conf(epixraptor,binning)"
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::epixraptor::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Raptor dans le tableau conf(epixraptor,...)
   set conf(epixraptor,tec)         $private(tec)
   set conf(epixraptor,framerate)   $private(framerate)
   set conf(epixraptor,config)      $private(config)
   set conf(epixraptor,extconfig)   $private(extconfig)
   set conf(epixraptor,mirh)        $private(mirh)
   set conf(epixraptor,mirv)        $private(mirv)
   set conf(epixraptor,CMOStemp)    $private(CMOStemp)
   set conf(epixraptor,exposure)    $private(exposure)
   set conf(epixraptor,roi_x1)      $private(roi_x1)
   set conf(epixraptor,roi_y1)      $private(roi_y1)
   set conf(epixraptor,roi_x2)      $private(roi_x2)
   set conf(epixraptor,roi_y2)      $private(roi_y2)
   set conf(epixraptor,hdr)         $private(hdr)
   set conf(epixraptor,videomode)   $private(videomode)
   set conf(epixraptor,binning)     [ string index $private(binning) 0 ]
}

#
# fillConfigPage
#    Interface de configuration de la camera Raptor
#
proc ::epixraptor::fillConfigPage { frm camItem } {
   variable private
   global audace caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::epixraptor::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- External file configuration frame
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Video format file definition
      frame $frm.frame1.frame1 -borderwidth 0 -relief raised

         checkbutton $frm.frame1.frame1.check -text "$caption(epixraptor,extconfig)" -highlightthickness 0 -variable ::epixraptor::private(extconfig) -command "::epixraptor::extconfig $camItem"
         pack $frm.frame1.frame1.check -anchor w -side top -padx 10 -pady 1

         label $frm.frame1.frame1.lab2 -text "$caption(epixraptor,config)"
         pack $frm.frame1.frame1.lab2 -anchor center -side left -padx 1

         entry $frm.frame1.frame1.host -width 30 -textvariable ::epixraptor::private(config) -state disabled
         pack $frm.frame1.frame1.host -anchor center -side left -padx 1

         button $frm.frame1.frame1.explore -text "$caption(epixraptor,browse)" -width 1 -command ::epixraptor::explore -state disabled
         pack $frm.frame1.frame1.explore -side left -padx 10 -pady 5 -ipady 5

      pack $frm.frame1.frame1 -side top -fill none -anchor n

      #--- ROI and binning
      frame $frm.frame1.frame2 -borderwidth 0 -relief raised

         #--- ROI
         #frame $frm.frame1.frame2.frametitle -borderwidth 0 -relief raised

         label $frm.frame1.frame2.lab1 -text "$caption(epixraptor,ROI)"
         pack $frm.frame1.frame2.lab1 -anchor center -side top -pady 2

         #pack $frm.frame1.frame2.frametitle -side top -fill both -expand 1 -anchor n -pady 2

         #--- Frame roi_x1
         frame $frm.frame1.frame2.frame1 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame1.lab1 -text "$caption(epixraptor,x1)"
         pack $frm.frame1.frame2.frame1.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame1.roi_x1 -width 4 -textvariable ::epixraptor::private(roi_x1) -state disabled
         pack $frm.frame1.frame2.frame1.roi_x1 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame1 -side top -fill both -expand 1 -anchor center -pady 2

         #--- Frame roi_y1
         frame $frm.frame1.frame2.frame2 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame2.lab1 -text "$caption(epixraptor,y1)"
         pack $frm.frame1.frame2.frame2.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame2.roi_y1 -width 4 -textvariable ::epixraptor::private(roi_y1) -state disabled
         pack $frm.frame1.frame2.frame2.roi_y1 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame2 -side top -fill both -expand 1 -anchor center -pady 2

         #--- Frame roi_x2
         frame $frm.frame1.frame2.frame3 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame3.lab1 -text "$caption(epixraptor,x2)"
         pack $frm.frame1.frame2.frame3.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame3.roi_x2 -width 4 -textvariable ::epixraptor::private(roi_x2) -state disabled
         pack $frm.frame1.frame2.frame3.roi_x2 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame3 -side top -fill both -expand 1 -anchor center -pady 2

         #--- Frame roi_y2
         frame $frm.frame1.frame2.frame4 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame4.lab1 -text "$caption(epixraptor,y2)"
         pack $frm.frame1.frame2.frame4.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame4.roi_y2 -width 4 -textvariable ::epixraptor::private(roi_y2) -state disabled
         pack $frm.frame1.frame2.frame4.roi_y2 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame4 -side top -fill both -expand 1 -anchor center -pady 2

      pack $frm.frame1.frame2 -side left -fill none -expand 1 -anchor center

      #--- Frame binning
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

      label $frm.frame1.frame3.lab1 -text "$caption(epixraptor,binning)"
      pack $frm.frame1.frame3.lab1 -anchor center -side top -pady 2

      set list_binning [ list "1x1" "2x2" "4x4" ]
      ComboBox $frm.frame1.frame3.bin -width 10 -height [ llength $list_binning ] -relief sunken -borderwidth 1 -editable 0 -textvariable ::epixraptor::private(binning) -values $list_binning -state disabled
      pack $frm.frame1.frame3.bin -anchor center -side top -padx 10 -pady 5

      pack $frm.frame1.frame3 -side left -fill none -expand 1 -anchor center

   pack $frm.frame1 -side left -fill both -expand 1

   #--- Configuration frame
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Top frame
      frame $frm.frame2.frame1 -borderwidth 0  -relief raised

         #--- Mirror configuration frame
         frame $frm.frame2.frame1.frame1 -borderwidth 0 -relief raised

         #--- Mirror in x and in y
         checkbutton $frm.frame2.frame1.frame1.mirx -text "$caption(epixraptor,mirror_x)" -highlightthickness 0 \
            -variable ::epixraptor::private(mirh)
         pack $frm.frame2.frame1.frame1.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame2.frame1.frame1.miry -text "$caption(epixraptor,mirror_y)" -highlightthickness 0 \
            -variable ::epixraptor::private(mirv)
         pack $frm.frame2.frame1.frame1.miry -anchor w -side top -padx 20 -pady 10

         pack $frm.frame2.frame1.frame1 -side top -fill none -expand 1 -anchor center

         #--- Temperature and TEC frame
         #frame $frm.frame2.frame1.frame2 -borderwidth 0 -relief raised

         #-- CMOS sensor temperature
         #label $frm.frame2.frame1.frame2.cmostemp -textvariable ::epixraptor::private(CMOStemp)
         #pack $frm.frame2.frame1.frame2.cmostemp -side top -fill x -padx 20 -pady 5

         #pack $frm.frame2.frame1.frame2 -side top -fill none -expand 1 -anchor center

      pack $frm.frame2.frame1 -side top -fill both -expand 1 -anchor center

      #--- Bottom frame
      frame $frm.frame2.frame2 -borderwidth 0 -relief raised

         #--- Exposure frame
         frame $frm.frame2.frame2.frame1 -borderwidth 0 -relief raised

            #--- Exposure time
            frame $frm.frame2.frame2.frame1.frame1 -borderwidth 0 -relief raised

            label $frm.frame2.frame2.frame1.frame1.lab1 -text "$caption(epixraptor,exposure)"
            pack $frm.frame2.frame2.frame1.frame1.lab1 -anchor center -side left -padx 5 -pady 5

            entry $frm.frame2.frame2.frame1.frame1.exp -width 8 -textvariable ::epixraptor::private(exposure)
            pack $frm.frame2.frame2.frame1.frame1.exp -anchor center -side left -padx 5 -pady 5

            pack $frm.frame2.frame2.frame1.frame1 -side top -fill none -expand 1 -anchor center

            #--- High dynamic range
            frame $frm.frame2.frame2.frame1.frame2 -borderwidth 0 -relief raised

            checkbutton $frm.frame2.frame2.frame1.frame2.hdr -text "$caption(epixraptor,hdr)" -highlightthickness 0 \
               -variable ::epixraptor::private(hdr)
            pack $frm.frame2.frame2.frame1.frame2.hdr -side top -fill none -expand 1 -anchor center

            pack $frm.frame2.frame2.frame1.frame2 -side top -fill none -expand 1 -anchor center

         pack $frm.frame2.frame2.frame1 -side top -fill none -expand 1 -anchor center

         #--- Frame rate frame
         frame $frm.frame2.frame2.frame2 -borderwidth 0 -relief raised

            #--- Frame rate
            frame $frm.frame2.frame2.frame2.frame1 -borderwidth 0 -relief raised

            label $frm.frame2.frame2.frame2.frame1.lab1 -text "$caption(epixraptor,framerate)"
            pack $frm.frame2.frame2.frame2.frame1.lab1 -anchor w -side left -padx 5 -pady 5

            entry $frm.frame2.frame2.frame2.frame1.fr -width 5 -textvariable ::epixraptor::private(framerate)
            pack $frm.frame2.frame2.frame2.frame1.fr -anchor center -side left -padx 5 -pady 5

            pack $frm.frame2.frame2.frame2.frame1 -side top -fill none -expand 1 -anchor center

            #--- Video mode (FFR or ITR)
            frame $frm.frame2.frame2.frame2.frame2 -borderwidth 0 -relief raised

            label $frm.frame2.frame2.frame2.frame2.lab1 -text "$caption(epixraptor,videomode)"
            pack $frm.frame2.frame2.frame2.frame2.lab1 -anchor center -side left -padx 5 -pady 5

            set list_binning [ list "ffr" "itr" ]
            ComboBox $frm.frame2.frame2.frame2.frame2.bin -width 10 -height [ llength $list_binning ] -relief sunken -borderwidth 1 -editable 0 -textvariable ::epixraptor::private(videomode) -values $list_binning
            pack $frm.frame2.frame2.frame2.frame2.bin -anchor center -side top -padx 10 -pady 5

            pack $frm.frame2.frame2.frame2.frame2 -side top -fill both -expand 1 -anchor center

         pack $frm.frame2.frame2.frame2 -side top -fill none -expand 1 -anchor center

      pack $frm.frame2.frame2 -side top -fill both -expand 1 -anchor center

   pack $frm.frame2 -side left -fill both -expand 1

   #::epixraptor::dispTempCMOS

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la camera Raptor en fonction des donnees contenues dans les variables conf(epixraptor,...)
#
proc ::epixraptor::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je mets conf(epixraptor,config) entre guillemets pour le cas ou le nom du repertoire contient des espaces
      #--- Je cree la camera
      if {$private(config) eq ""} {
         set camNo [ cam::create epixraptor \
            -log_file [::confCam::getLogFileName $camItem] \
            -log_level [::confCam::getLogLevel $camItem] \
         ]
      } else {
         set camNo [ cam::create epixraptor \
            -log_file [::confCam::getLogFileName $camItem] \
            -log_level [::confCam::getLogLevel $camItem] \
            -config $conf(epixraptor,config) $conf(epixraptor,roi_x1) $conf(epixraptor,roi_y1) $conf(epixraptor,roi_x2) $conf(epixraptor,roi_y2) $conf(epixraptor,binning) $conf(epixraptor,binning) \
         ]
      }
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je configure l'exposition
      cam$camNo exposure $conf(epixraptor,exposure)
      #--- Je configure le refroidissement

      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(epixraptor,mirh)
      cam$camNo mirrorv $conf(epixraptor,mirv)
      #--- Je configure le frame rate
      cam$camNo framerate $conf(epixraptor,framerate)
      #--- Je configure la ROI
      #cam$camNo roi $conf(epixraptor,roi)
      #--- Je configure le binning
      #cam$camNo bin $conf(epixraptor,binning)
      #--- Je mesure la temperature du capteur CMOS
      ::epixraptor::dispTempCMOS $camItem
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::epixraptor::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la camera Raptor
#
proc ::epixraptor::stop { camItem } {
   variable private

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# dispTempCMOS
#    Affiche la temperature du capteur CMOS
#
proc ::epixraptor::dispTempCMOS { camItem } {
   variable private
   global caption

   if { [ catch { set temp_cmos [ cam$private($camItem,camNo) temperature ] } ] == "0" } {
      set temp_cmos [ format "%+5.2f" $temp_cmos ]
      set private(CMOStemp)   "$caption(epixraptor,temperature_CCD) $temp_cmos $caption(epixraptor,deg_c)"
   } else {
      set temp_cmos ""
      set private(CMOStemp) "$caption(epixraptor,temperature_CCD) $temp_cmos"
   }
   console::affiche_entete $private(CMOStemp)
   console::affiche_saut "\n"
}

#
# explore
#    Procedure pour designer les fichiers de configuration
#
proc ::epixraptor::explore { } {
   variable private
   global audace caption

   set types {
      {"Video Format Files" {.fmt} TEXT}
      {"All files" * TEXT}
   }

   set inDir [ file join /usr local xcap data ]

   set private(config) [ tk_getOpenFile -title "$caption(epixraptor,folder)" \
      -initialdir $inDir -parent [ winfo toplevel $private(frm) ] -defaultextension {.fmt} -filetypes $types ]
}

#
# enable_config
#    Enables or disables ROI and binning
#
proc ::epixraptor::extconfig { camNo } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if {$private(extconfig) == "1"} {
         $frm.frame1.frame3.bin configure -state normal
         $frm.frame1.frame2.frame1.roi_x1 configure -state normal
         $frm.frame1.frame2.frame2.roi_y1 configure -state normal
         $frm.frame1.frame2.frame3.roi_x2 configure -state normal
         $frm.frame1.frame2.frame4.roi_y2 configure -state normal
         $frm.frame1.frame1.host configure -state normal
         $frm.frame1.frame1.explore configure -state normal
      } else {
         set ::epixraptor::private(roi_x1) "0"
         set ::epixraptor::private(roi_y1) "0"
         set ::epixraptor::private(roi_x2) "2047"
         set ::epixraptor::private(roi_y2) "2047"
         set ::epixraptor::private(config) ""
         set ::epixraptor::private(binning) "1x1"
         $frm.frame1.frame3.bin configure -state disabled
         $frm.frame1.frame2.frame1.roi_x1 configure -state disabled
         $frm.frame1.frame2.frame2.roi_y1 configure -state disabled
         $frm.frame1.frame2.frame3.roi_x2 configure -state disabled
         $frm.frame1.frame2.frame4.roi_y2 configure -state disabled
         $frm.frame1.frame1.host configure -state disabled
         $frm.frame1.frame1.explore configure -state disabled
      }
   }

   ::epixraptor::widgetToConf $camNo

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
proc ::epixraptor::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 4x4 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 4095 0 ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 0 }
      hasTempSensor    { return 1 }
      hasSetTemp       { return 0 }
      hasVideo         { return 1 }
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
      shutterList      { return [ list "" ] }
   }
}

