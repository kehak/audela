#
# Fichier : epixowl.tcl
# Description : Configuration de la camera Epix OWL
# Auteur : Matteo SCHIAVON
# Mise à jour $Id: epixowl.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::epixowl {
   package provide epixowl 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] epixowl.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::epixowl::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libepixowl.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::epixowl::getPluginType]] "epixowl" "libepixowl.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace XCLIBWNT.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::epixowl::getPluginType]] "epixowl" "XCLIBWNT.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(epixowl,installNewVersion) $sourceFileName [package version epixowl] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::epixowl::getPluginTitle { } {
   global caption

   return "$caption(epixowl,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::epixowl::getPluginHelp { } {
   return "epixowl.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::epixowl::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::epixowl::getPluginOS { } {
   return [ list Windows ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::epixowl::getPluginDirectory { } {
   return "epixowl"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::epixowl::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::epixowl::isReady { camItem } {
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
#    Initialise les variables conf(epixowl,...)
#
proc ::epixowl::initPlugin { } {
   variable private
   global audace conf caption

   #--- Initialise les variables de la camera Raptor OSPREY
   if { ! [ info exists conf(epixowl,tec) ] }         { set conf(epixowl,tec)       "1" }
   if { ! [ info exists conf(epixowl,framerate) ] }   { set conf(epixowl,framerate) "5" }
   if { ! [ info exists conf(epixowl,config) ] }      { set conf(epixowl,config)    "" }
   if { ! [ info exists conf(epixowl,mirh) ] }        { set conf(epixowl,mirh)      "0" }
   if { ! [ info exists conf(epixowl,mirv) ] }        { set conf(epixowl,mirv)      "0" }
   if { ! [ info exists conf(epixowl,CMOStemp) ] }    { set conf(epixowl,CMOStemp)  "" }
   if { ! [ info exists conf(epixowl,exposure) ] }    { set conf(epixowl,exposure)  "0.1" }
   if { ! [ info exists conf(epixowl,roi_x1) ] }      { set conf(epixowl,roi_x1)    "0" }
   if { ! [ info exists conf(epixowl,roi_y1) ] }      { set conf(epixowl,roi_y1)    "0" }
   if { ! [ info exists conf(epixowl,roi_x2 ] }       { set conf(epixowl,roi_x2)    "639" }
   if { ! [ info exists conf(epixowl,roi_y2) ] }      { set conf(epixowl,roi_y2)    "511" }
   if { ! [ info exists conf(epixowl,binning) ] }     { set conf(epixowl,binning)   "1" }
   if { ! [ info exists conf(epixowl,extconfig) ] }   { set conf(epixowl,extconfig) "0" }
   if { ! [ info exists conf(epixowl,hdr) ] }         { set conf(epixowl,hdr)       "0" }
   if { ! [ info exists conf(epixowl,videomode) ] }   { set conf(epixowl,videomode) "ffr" }

   #--- Initialisation
   set private(A,camNo)  "0"
   set private(B,camNo)  "0"
   set private(C,camNo)  "0"
   set private(CMOStemp) "$caption(epixowl,temperature_CCD)"
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::epixowl::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Raptor dans le tableau private(...)
   set private(tec)         $conf(epixowl,tec)
   set private(framerate)   $conf(epixowl,framerate)
   set private(config)      $conf(epixowl,config)
   set private(extconfig)   $conf(epixowl,extconfig)
   set private(mirh)        $conf(epixowl,mirh)
   set private(mirv)        $conf(epixowl,mirv)
   set private(CMOStemp)    $conf(epixowl,CMOStemp)
   set private(exposure)    $conf(epixowl,exposure)
   set private(roi_x1)      $conf(epixowl,roi_x1)
   set private(roi_y1)      $conf(epixowl,roi_y1)
   set private(roi_x2)      $conf(epixowl,roi_x2)
   set private(roi_y2)      $conf(epixowl,roi_y2)
   set private(hdr)         $conf(epixowl,hdr)
   set private(videomode)   $conf(epixowl,videomode)
   set private(binning)     "$conf(epixowl,binning)x$conf(epixowl,binning)"
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::epixowl::widgetToConf { camItem } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Raptor dans le tableau conf(epixowl,...)
   set conf(epixowl,tec)         $private(tec)
   set conf(epixowl,framerate)   $private(framerate)
   set conf(epixowl,config)      $private(config)
   set conf(epixowl,extconfig)   $private(extconfig)
   set conf(epixowl,mirh)        $private(mirh)
   set conf(epixowl,mirv)        $private(mirv)
   set conf(epixowl,CMOStemp)    $private(CMOStemp)
   set conf(epixowl,exposure)    $private(exposure)
   set conf(epixowl,roi_x1)      $private(roi_x1)
   set conf(epixowl,roi_y1)      $private(roi_y1)
   set conf(epixowl,roi_x2)      $private(roi_x2)
   set conf(epixowl,roi_y2)      $private(roi_y2)
   set conf(epixowl,hdr)         $private(hdr)
   set conf(epixowl,videomode)   $private(videomode)
   set conf(epixowl,binning)     [ string index $private(binning) 0 ]
}

#
# fillConfigPage
#    Interface de configuration de la camera Raptor
#
proc ::epixowl::fillConfigPage { frm camItem } {
   variable private
   global audace caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::epixowl::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- External file configuration frame
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Video format file definition
      frame $frm.frame1.frame1 -borderwidth 0 -relief raised

         checkbutton $frm.frame1.frame1.check -text "$caption(epixowl,extconfig)" -highlightthickness 0 -variable ::epixowl::private(extconfig) -command "::epixowl::extconfig $camItem"
         pack $frm.frame1.frame1.check -anchor w -side top -padx 10 -pady 1

         label $frm.frame1.frame1.lab2 -text "$caption(epixowl,config)"
         pack $frm.frame1.frame1.lab2 -anchor center -side left -padx 1

         entry $frm.frame1.frame1.host -width 30 -textvariable ::epixowl::private(config) -state disabled
         pack $frm.frame1.frame1.host -anchor center -side left -padx 1

         button $frm.frame1.frame1.explore -text "$caption(epixowl,browse)" -width 1 -command ::epixowl::explore -state disabled
         pack $frm.frame1.frame1.explore -side left -padx 10 -pady 5 -ipady 5

      pack $frm.frame1.frame1 -side top -fill none -anchor n

      #--- ROI and binning
      frame $frm.frame1.frame2 -borderwidth 0 -relief raised

         #--- ROI
         #frame $frm.frame1.frame2.frametitle -borderwidth 0 -relief raised

         label $frm.frame1.frame2.lab1 -text "$caption(epixowl,ROI)"
         pack $frm.frame1.frame2.lab1 -anchor center -side top -pady 2

         #pack $frm.frame1.frame2.frametitle -side top -fill both -expand 1 -anchor n -pady 2

         #--- Frame roi_x1
         frame $frm.frame1.frame2.frame1 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame1.lab1 -text "$caption(epixowl,x1)"
         pack $frm.frame1.frame2.frame1.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame1.roi_x1 -width 4 -textvariable ::epixowl::private(roi_x1) -state disabled
         pack $frm.frame1.frame2.frame1.roi_x1 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame1 -side top -fill both -expand 1 -anchor center -pady 2

         #--- Frame roi_y1
         frame $frm.frame1.frame2.frame2 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame2.lab1 -text "$caption(epixowl,y1)"
         pack $frm.frame1.frame2.frame2.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame2.roi_y1 -width 4 -textvariable ::epixowl::private(roi_y1) -state disabled
         pack $frm.frame1.frame2.frame2.roi_y1 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame2 -side top -fill both -expand 1 -anchor center -pady 2

         #--- Frame roi_x2
         frame $frm.frame1.frame2.frame3 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame3.lab1 -text "$caption(epixowl,x2)"
         pack $frm.frame1.frame2.frame3.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame3.roi_x2 -width 4 -textvariable ::epixowl::private(roi_x2) -state disabled
         pack $frm.frame1.frame2.frame3.roi_x2 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame3 -side top -fill both -expand 1 -anchor center -pady 2

         #--- Frame roi_y2
         frame $frm.frame1.frame2.frame4 -borderwidth 0 -relief raised

         label $frm.frame1.frame2.frame4.lab1 -text "$caption(epixowl,y2)"
         pack $frm.frame1.frame2.frame4.lab1 -anchor center -side left -padx 2

         entry $frm.frame1.frame2.frame4.roi_y2 -width 4 -textvariable ::epixowl::private(roi_y2) -state disabled
         pack $frm.frame1.frame2.frame4.roi_y2 -anchor center -side left -padx 2

         pack $frm.frame1.frame2.frame4 -side top -fill both -expand 1 -anchor center -pady 2

      pack $frm.frame1.frame2 -side left -fill none -expand 1 -anchor center

      #--- Frame binning
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

      label $frm.frame1.frame3.lab1 -text "$caption(epixowl,binning)"
      pack $frm.frame1.frame3.lab1 -anchor center -side top -pady 2

      set list_binning [ list "1x1" "2x2" "4x4" ]
      ComboBox $frm.frame1.frame3.bin -width 10 -height [ llength $list_binning ] -relief sunken -borderwidth 1 -editable 0 -textvariable ::epixowl::private(binning) -values $list_binning -state disabled
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
         checkbutton $frm.frame2.frame1.frame1.mirx -text "$caption(epixowl,mirror_x)" -highlightthickness 0 \
            -variable ::epixowl::private(mirh)
         pack $frm.frame2.frame1.frame1.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame2.frame1.frame1.miry -text "$caption(epixowl,mirror_y)" -highlightthickness 0 \
            -variable ::epixowl::private(mirv)
         pack $frm.frame2.frame1.frame1.miry -anchor w -side top -padx 20 -pady 10

         pack $frm.frame2.frame1.frame1 -side top -fill none -expand 1 -anchor center

         #--- Temperature and TEC frame
         #frame $frm.frame2.frame1.frame2 -borderwidth 0 -relief raised

         #-- CMOS sensor temperature
         #label $frm.frame2.frame1.frame2.cmostemp -textvariable ::epixowl::private(CMOStemp)
         #pack $frm.frame2.frame1.frame2.cmostemp -side top -fill x -padx 20 -pady 5

         #pack $frm.frame2.frame1.frame2 -side top -fill none -expand 1 -anchor center

      pack $frm.frame2.frame1 -side top -fill both -expand 1 -anchor center

      #--- Bottom frame
      frame $frm.frame2.frame2 -borderwidth 0 -relief raised

         #--- Exposure frame
         frame $frm.frame2.frame2.frame1 -borderwidth 0 -relief raised

            #--- Exposure time
            frame $frm.frame2.frame2.frame1.frame1 -borderwidth 0 -relief raised

            label $frm.frame2.frame2.frame1.frame1.lab1 -text "$caption(epixowl,exposure)"
            pack $frm.frame2.frame2.frame1.frame1.lab1 -anchor center -side left -padx 5 -pady 5

            entry $frm.frame2.frame2.frame1.frame1.exp -width 8 -textvariable ::epixowl::private(exposure)
            pack $frm.frame2.frame2.frame1.frame1.exp -anchor center -side left -padx 5 -pady 5

            pack $frm.frame2.frame2.frame1.frame1 -side top -fill none -expand 1 -anchor center

            #--- High dynamic range
            frame $frm.frame2.frame2.frame1.frame2 -borderwidth 0 -relief raised

            checkbutton $frm.frame2.frame2.frame1.frame2.hdr -text "$caption(epixowl,hdr)" -highlightthickness 0 \
               -variable ::epixowl::private(hdr)
            pack $frm.frame2.frame2.frame1.frame2.hdr -side top -fill none -expand 1 -anchor center

            pack $frm.frame2.frame2.frame1.frame2 -side top -fill none -expand 1 -anchor center

         pack $frm.frame2.frame2.frame1 -side top -fill none -expand 1 -anchor center

         #--- Frame rate frame
         frame $frm.frame2.frame2.frame2 -borderwidth 0 -relief raised

            #--- Frame rate
            frame $frm.frame2.frame2.frame2.frame1 -borderwidth 0 -relief raised

            label $frm.frame2.frame2.frame2.frame1.lab1 -text "$caption(epixowl,framerate)"
            pack $frm.frame2.frame2.frame2.frame1.lab1 -anchor w -side left -padx 5 -pady 5

            entry $frm.frame2.frame2.frame2.frame1.fr -width 5 -textvariable ::epixowl::private(framerate)
            pack $frm.frame2.frame2.frame2.frame1.fr -anchor center -side left -padx 5 -pady 5

            pack $frm.frame2.frame2.frame2.frame1 -side top -fill none -expand 1 -anchor center

            #--- Video mode (FFR or ITR)
            frame $frm.frame2.frame2.frame2.frame2 -borderwidth 0 -relief raised

            label $frm.frame2.frame2.frame2.frame2.lab1 -text "$caption(epixowl,videomode)"
            pack $frm.frame2.frame2.frame2.frame2.lab1 -anchor center -side left -padx 5 -pady 5

            set list_binning [ list "ffr" "itr" ]
            ComboBox $frm.frame2.frame2.frame2.frame2.bin -width 10 -height [ llength $list_binning ] -relief sunken -borderwidth 1 -editable 0 -textvariable ::epixowl::private(videomode) -values $list_binning
            pack $frm.frame2.frame2.frame2.frame2.bin -anchor center -side top -padx 10 -pady 5

            pack $frm.frame2.frame2.frame2.frame2 -side top -fill both -expand 1 -anchor center

         pack $frm.frame2.frame2.frame2 -side top -fill none -expand 1 -anchor center

      pack $frm.frame2.frame2 -side top -fill both -expand 1 -anchor center

   pack $frm.frame2 -side left -fill both -expand 1

   #::epixowl::dispTempCMOS

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la camera Raptor en fonction des donnees contenues dans les variables conf(epixowl,...)
#
proc ::epixowl::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         error "" "" "CameraUnique"
      }
      #--- Je mets conf(epixowl,config) entre guillemets pour le cas ou le nom du repertoire contient des espaces
      #--- Je cree la camera
      if {$private(config) eq ""} {
         set camNo [ cam::create epixowl \
            -log_file [::confCam::getLogFileName $camItem] \
            -log_level [::confCam::getLogLevel $camItem] \
         ]
      } else {
         set camNo [ cam::create epixowl \
            -log_file [::confCam::getLogFileName $camItem] \
            -log_level [::confCam::getLogLevel $camItem] \
            -config $conf(epixowl,config) $conf(epixowl,roi_x1) $conf(epixowl,roi_y1) $conf(epixowl,roi_x2) $conf(epixowl,roi_y2) $conf(epixowl,binning) $conf(epixowl,binning) \
         ]
      }
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je configure l'exposition
      cam$camNo exposure $conf(epixowl,exposure)
      #--- Je configure le refroidissement

      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(epixowl,mirh)
      cam$camNo mirrorv $conf(epixowl,mirv)
      #--- Je configure le frame rate
      cam$camNo framerate $conf(epixowl,framerate)
      #--- Je configure la ROI
      #cam$camNo roi $conf(epixowl,roi)
      #--- Je configure le binning
      #cam$camNo bin $conf(epixowl,binning)
      #--- Je mesure la temperature du capteur CMOS
      ::epixowl::dispTempCMOS $camItem
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::epixowl::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la camera Raptor
#
proc ::epixowl::stop { camItem } {
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
proc ::epixowl::dispTempCMOS { camItem } {
   variable private
   global caption

   if { [ catch { set temp_cmos [ cam$private($camItem,camNo) temperature ] } ] == "0" } {
      set temp_cmos [ format "%+5.2f" $temp_cmos ]
      set private(CMOStemp)   "$caption(epixowl,temperature_CCD) $temp_cmos $caption(epixowl,deg_c)"
   } else {
      set temp_cmos ""
      set private(CMOStemp) "$caption(epixowl,temperature_CCD) $temp_cmos"
   }
   console::affiche_entete $private(CMOStemp)
   console::affiche_saut "\n"
}

#
# explore
#    Procedure pour designer les fichiers de configuration
#
proc ::epixowl::explore { } {
   variable private
   global audace caption

   set types {
      {"Video Format Files" {.fmt} TEXT}
      {"All files" * TEXT}
   }

   set inDir [ file join /usr local xcap data ]

   set private(config) [ tk_getOpenFile -title "$caption(epixowl,folder)" \
      -initialdir $inDir -parent [ winfo toplevel $private(frm) ] -defaultextension {.fmt} -filetypes $types ]
}

#
# enable_config
#    Enables or disables ROI and binning
#
proc ::epixowl::extconfig { camNo } {
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
         set ::epixowl::private(roi_x1) "0"
         set ::epixowl::private(roi_y1) "0"
         set ::epixowl::private(roi_x2) "639"
         set ::epixowl::private(roi_y2) "511"
         set ::epixowl::private(config) ""
         set ::epixowl::private(binning) "1x1"
         $frm.frame1.frame3.bin configure -state disabled
         $frm.frame1.frame2.frame1.roi_x1 configure -state disabled
         $frm.frame1.frame2.frame2.roi_y1 configure -state disabled
         $frm.frame1.frame2.frame3.roi_x2 configure -state disabled
         $frm.frame1.frame2.frame4.roi_y2 configure -state disabled
         $frm.frame1.frame1.host configure -state disabled
         $frm.frame1.frame1.explore configure -state disabled
      }
   }

   ::epixowl::widgetToConf $camNo

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
proc ::epixowl::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 16384 0 ] }
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

