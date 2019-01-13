#
# Fichier : webcam.tcl
# Description : Configuration des cameras WebCam
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise à jour $Id: webcam.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::webcam {
   package provide webcam 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] webcam.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::webcam::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libwebcam.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::webcam::getPluginType]] "webcam" "libwebcam.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(webcam,installNewVersion) $sourceFileName [package version webcam] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::webcam::getPluginTitle { } {
   global caption

   return "$caption(webcam,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::webcam::getPluginHelp { } {
   return "webcam.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::webcam::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::webcam::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le repertoire du plugin
#------------------------------------------------------------
proc getPluginDirectory { } {
   return "webcam"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::webcam::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::webcam::getPluginDirectory { } {
      return "webcam"
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::webcam::isReady { camItem } {
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
#    Initialise les variables conf(webcam,$camItem,...)
#
proc ::webcam::initPlugin { } {
   variable private
   global conf

   #--- Initialise les variable generales
   if { ! [ info exists conf(webcam,switchedConnexion) ] }                 { set conf(webcam,switchedConnexion)             "0" }

   #--- Initialise les variables de chaque item
   foreach camItem { A B C } {
      if { ! [ info exists conf(webcam,$camItem,select) ] }                { set conf(webcam,$camItem,select)               "0" }
      if { ! [ info exists conf(webcam,$camItem,longuepose) ] }            { set conf(webcam,$camItem,longuepose)           "0" }
      if { ! [ info exists conf(webcam,$camItem,longueposeport) ] }        { set conf(webcam,$camItem,longueposeport)       "LPT1:" }
      if { ! [ info exists conf(webcam,$camItem,longueposelinkbit) ] }     { set conf(webcam,$camItem,longueposelinkbit)    "0" }
      if { ! [ info exists conf(webcam,$camItem,longueposestartvalue) ] }  { set conf(webcam,$camItem,longueposestartvalue) "0" }
      if { ! [ info exists conf(webcam,$camItem,mirv) ] }                  { set conf(webcam,$camItem,mirv)                 "0" }
      if { ! [ info exists conf(webcam,$camItem,mirh) ] }                  { set conf(webcam,$camItem,mirh)                 "0" }
      if { ! [ info exists conf(webcam,$camItem,channel) ] }               { set conf(webcam,$camItem,channel)              "0" }
      if { ! [ info exists conf(webcam,$camItem,webcamCcd_N_B) ] }         { set conf(webcam,$camItem,webcamCcd_N_B)        "0" }
      if { ! [ info exists conf(webcam,$camItem,dim_ccd_N_B) ] }           { set conf(webcam,$camItem,dim_ccd_N_B)          "1/4''" }
      if { ! [ info exists conf(webcam,$camItem,ccd_N_B) ] }               { set conf(webcam,$camItem,ccd_N_B)              "0" }
      if { ! [ info exists conf(webcam,$camItem,dimPixX) ] }               { set conf(webcam,$camItem,dimPixX)              "8.6" }
      if { ! [ info exists conf(webcam,$camItem,dimPixY) ] }               { set conf(webcam,$camItem,dimPixY)              "8.3" }
      if { ! [ info exists conf(webcam,$camItem,ccd) ] }                   { set conf(webcam,$camItem,ccd)                  "ICX098BL-6" }
      if { ! [ info exists conf(webcam,$camItem,videoformat) ] }           { set conf(webcam,$camItem,videoformat)          "QCIF" }
      if { ! [ info exists conf(webcam,$camItem,port) ] }                  { set conf(webcam,$camItem,port)                 "/dev/video0" }
      if { ! [ info exists conf(webcam,$camItem,videomode) ] }             { set conf(webcam,$camItem,videomode)            "vfw" }

      if { $::tcl_platform(os) == "Linux" } {
         if { ! [ info exists conf(webcam,$camItem,configWindowPosition)]} { set conf(webcam,$camItem,configWindowPosition) "+0+0" }
         if { ! [ info exists conf(webcam,$camItem,framerate) ] }          { set conf(webcam,$camItem,framerate)            "5" }
         if { ! [ info exists conf(webcam,$camItem,shutter) ] }            { set conf(webcam,$camItem,shutter)              "1/25" }
         if { ! [ info exists conf(webcam,$camItem,gain) ] }               { set conf(webcam,$camItem,gain)                 "50" }
         if { ! [ info exists conf(webcam,$camItem,autoShutter) ] }        { set conf(webcam,$camItem,autoShutter)          "1" }
         if { ! [ info exists conf(webcam,$camItem,autoGain) ] }           { set conf(webcam,$camItem,autoGain)             "1" }
         if { ! [ info exists conf(webcam,$camItem,validFrame) ] }         { set conf(webcam,$camItem,validFrame)           "3" }
      }
   }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"

   #--- Definition des formats video
   #--- Attention : Les valeurs de private(videoFormatLabels) et private(videoFormatNames)
   #---             doivent etre dans le meme ordre
   set private(videoFormatLabels) [ list \
      "720x576 - 720 x 576"  \
      "VGA - 640 x 480"  \
      "CIF - 352 x 288"  \
      "SIF - 320 x 240"  \
      "SSIF - 240 x 176" \
      "QCIF - 176 x 144" \
      "QSIF - 160 x 120" \
      "SQCIF - 128 x 96" \
   ]
   set private(videoFormatNames) [ list "720x576" "VGA" "CIF" "SIF" "SSIF" "QCIF" "QSIF" "SQCIF" ]

   set private(portList) ""
}

#------------------------------------------------------------
# setConnection
#    connecte ou deconnecte la camera
#
# parametres :
#    camItem : item de la camera
#    state :   1=connecter la camera , 0= deconnecter la camera
# return
#    rien
#------------------------------------------------------------
proc ::webcam::setConnection { camItem state }  {
   variable private

   if { $::tcl_platform(platform) != "windows" }          return
   if { $::conf(webcam,$camItem,videomode) != "directx" } return
   if { $::conf(webcam,switchedConnexion) == 0 }          return
   if { [::webcam::isReady $camItem] != 1 }               return
   if { [cam$private($camItem,camNo) connect ] == 1 }     return

  ### console::disp "::webcam::setConnection $state \n"
   if { $state == 1 } {
      #--- Je deconnecte d'abord les autres cameras
      foreach camItem2 { A B C } {
         if { $camItem2 != $camItem && $private($camItem2,camNo) && $::conf(webcam,$camItem2,videomode) == "directx" != 0 } {
            if { [cam$private($camItem2,camNo) connect ] == 1 } {
               cam$private($camItem2,camNo) connect 0
            }
         }
      }
   }

   #--- Je connecte ou deconnecte la camera
   cam$private($camItem,camNo) connect $state
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::webcam::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la WebCam dans le tableau private($camItem,...)
   foreach camItem { A B C } {
      set private($camItem,select)               $conf(webcam,$camItem,select)
      set private($camItem,longuepose)           $conf(webcam,$camItem,longuepose)
      set private($camItem,longueposeport)       $conf(webcam,$camItem,longueposeport)
      set private($camItem,longueposelinkbit)    $conf(webcam,$camItem,longueposelinkbit)
      set private($camItem,longueposestartvalue) $conf(webcam,$camItem,longueposestartvalue)
      set private($camItem,switchedConnexion)    $conf(webcam,switchedConnexion)
      set private($camItem,mirh)                 $conf(webcam,$camItem,mirh)
      set private($camItem,mirv)                 $conf(webcam,$camItem,mirv)
      set private($camItem,channel)              $conf(webcam,$camItem,channel)
      set private($camItem,webcamCcd_N_B)        $conf(webcam,$camItem,webcamCcd_N_B)
      set private($camItem,dim_ccd_N_B)          $conf(webcam,$camItem,dim_ccd_N_B)
      set private($camItem,ccd_N_B)              $conf(webcam,$camItem,ccd_N_B)
      set private($camItem,dimPixX)              $conf(webcam,$camItem,dimPixX)
      set private($camItem,dimPixY)              $conf(webcam,$camItem,dimPixY)
      set private($camItem,ccd)                  $conf(webcam,$camItem,ccd)
      set private($camItem,videomode)            $conf(webcam,$camItem,videomode)
      set private($camItem,port)                 $conf(webcam,$camItem,port)

      if { $::tcl_platform(os) == "Linux" } {
         set private($camItem,validFrame)        $conf(webcam,$camItem,validFrame)
      }

      #--- je copie le label correspondant au format video
      set formatIndex [lsearch -exact $private(videoFormatNames) $conf(webcam,$camItem,videoformat)]
      set private($camItem,videoformat) [lindex $private(videoFormatLabels) $formatIndex]
   }
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::webcam::widgetToConf { camItem } {
   variable private
   global conf

   #--- Memorise la configuration de la WebCam dans le tableau conf(webcam,$camItem,...)
   set conf(webcam,$camItem,select)               $private($camItem,select)
   set conf(webcam,$camItem,longuepose)           $private($camItem,longuepose)
   set conf(webcam,$camItem,longueposeport)       $private($camItem,longueposeport)
   set conf(webcam,$camItem,longueposelinkbit)    $private($camItem,longueposelinkbit)
   set conf(webcam,$camItem,longueposestartvalue) $private($camItem,longueposestartvalue)
   set conf(webcam,switchedConnexion)             $private($camItem,switchedConnexion)
   set conf(webcam,$camItem,mirh)                 $private($camItem,mirh)
   set conf(webcam,$camItem,mirv)                 $private($camItem,mirv)
   set conf(webcam,$camItem,channel)              $private($camItem,channel)
   set conf(webcam,$camItem,webcamCcd_N_B)        $private($camItem,webcamCcd_N_B)
   set conf(webcam,$camItem,dim_ccd_N_B)          $private($camItem,dim_ccd_N_B)
   set conf(webcam,$camItem,ccd_N_B)              $private($camItem,ccd_N_B)
   set conf(webcam,$camItem,dimPixX)              $private($camItem,dimPixX)
   set conf(webcam,$camItem,dimPixY)              $private($camItem,dimPixY)
   set conf(webcam,$camItem,ccd)                  $private($camItem,ccd)
   set conf(webcam,$camItem,videomode)            $private($camItem,videomode)
   set conf(webcam,$camItem,port)                 $private($camItem,port)

   if { $::tcl_platform(os) == "Linux" } {
      set conf(webcam,$camItem,validFrame)        $private($camItem,validFrame)
   }

      #--- je copie le label correspondant au format video
   set formatIndex [lsearch -exact $private(videoFormatLabels) $private($camItem,videoformat)]
   set conf(webcam,$camItem,videoformat) [lindex $private(videoFormatNames) $formatIndex]
}

#
# fillConfigPage
#    Interface de configuration de la WebCam
#
proc ::webcam::fillConfigPage { frm camItem } {
   variable private
   global caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::webcam::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill both -expand 1

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -in $frm.frame1 -side left -fill x -expand 1 -anchor nw

   TitleFrame $frm.frame4 -borderwidth 2 -relief ridge -text "$caption(webcam,select)"
   pack $frm.frame4 -in $frm.frame1 -side left -fill x -anchor ne

   frame $frm.frame20 -borderwidth 0 -relief raised
   pack $frm.frame20 -in [ $frm.frame4 getframe ] -side left -fill y

   frame $frm.frame5 -borderwidth 1 -relief ridge
   pack $frm.frame5 -in [ $frm.frame4 getframe ] -side top -fill x -anchor e

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -in $frm.frame3 -side bottom -fill x -pady 5

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame3 -side bottom -fill x -pady 5

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame3 -side top -fill x -pady 5

   frame $frm.frame9 -borderwidth 0 -relief raised
   pack $frm.frame9 -in $frm.frame3 -side top -fill x -padx 20

   frame $frm.frame10 -borderwidth 0 -relief raised
   pack $frm.frame10 -in $frm.frame5 -side top -fill x

   frame $frm.frame11 -borderwidth 0 -relief raised
   pack $frm.frame11 -in $frm.frame5 -side top -fill x

   frame $frm.frame12 -borderwidth 0 -relief raised
   pack $frm.frame12 -in $frm.frame5 -side top -fill x

   frame $frm.frame13 -borderwidth 0 -relief raised
   pack $frm.frame13 -in $frm.frame5 -side top -fill x

   frame $frm.frame14 -borderwidth 1 -relief ridge
   pack $frm.frame14 -in [ $frm.frame4 getframe ] -side top -fill x -anchor ne

   frame $frm.frame15 -borderwidth 0 -relief raised
   pack $frm.frame15 -in $frm.frame14 -side right -fill x -pady 5

   frame $frm.frame16 -borderwidth 1 -relief ridge
   pack $frm.frame16 -in [ $frm.frame4 getframe ] -side bottom -fill x -anchor ne

   frame $frm.frame17 -borderwidth 0 -relief raised
   pack $frm.frame17 -in $frm.frame16 -side right -fill x -expand 1

   frame $frm.frame18 -borderwidth 0 -relief raised
   pack $frm.frame18 -in $frm.frame17 -side top -fill x

   frame $frm.frame19 -borderwidth 0 -relief raised
   pack $frm.frame19 -in $frm.frame17 -side top -fill x

   #--- Definition du canal USB
   label $frm.lab1 -text "$caption(webcam,canal_usb)"
   pack $frm.lab1 -in $frm.frame8 -anchor center -side left -padx 10

   #--- Je constitue la liste des canaux USB
   set list_combobox [ list 0 1 2 3 4 5 6 7 8 9 ]

   #--- Choix du canal USB
   ComboBox $frm.port \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken  \
      -borderwidth 1  \
      -textvariable ::webcam::private($camItem,channel) \
      -editable 0     \
      -values $list_combobox
   pack $frm.port -in $frm.frame8 -anchor center -side left -padx 0

   #--- Choix du mode video
   if { $::tcl_platform(platform) == "windows" } {
     ### set list_combobox [ list "vfw" "directx" ]
      set list_combobox [ list "vfw" ]
      #--- video mode
      ComboBox $frm.videomode \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken  \
         -borderwidth 1  \
         -textvariable ::webcam::private($camItem,videomode) \
         -editable 0     \
         -values $list_combobox
      pack $frm.videomode -in $frm.frame8 -anchor center -side left -padx 0
   }

   #--- Miroir en x et en y
   checkbutton $frm.mirx -text "$caption(webcam,miroir_x)" -highlightthickness 0 \
      -variable ::webcam::private($camItem,mirh)
   pack $frm.mirx -in $frm.frame9 -anchor w -side top -padx 20 -pady 10

   checkbutton $frm.miry -text "$caption(webcam,miroir_y)" -highlightthickness 0 \
      -variable ::webcam::private($camItem,mirv)
   pack $frm.miry -in $frm.frame9 -anchor w -side top -padx 20 -pady 10

   #--- Connexion alternee
  ### checkbutton $frm.switchedConnexion -text "$caption(webcam,switchedConnexion)" -highlightthickness 0 \
  ###    -variable ::webcam::private($camItem,switchedConnexion)
  ### pack $frm.switchedConnexion -in $frm.frame7 -anchor w -side top -padx 20 -pady 10

   #--- Boutons de configuration de la source
   if { $::tcl_platform(os) == "Linux" } {
      label $frm.frame7.portLabel -text "Port"
      pack $frm.frame7.portLabel -anchor nw -side top -padx 10
      listbox $frm.frame7.portList -listvariable ::webcam::private(portList) -state normal -height 3
      pack $frm.frame7.portList -anchor center -padx 10 -pady 5 -ipadx 10 -expand true
      bind $frm.frame7.portList <<ListboxSelect>> "::webcam::selectPort $camItem $frm.frame7.portList"
   } else {
      button $frm.frame7.conf_webcam -text "$caption(webcam,conf_source)"
      pack $frm.frame7.conf_webcam -in $frm.frame7 -anchor center -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true
   }
   #--- Boutons de configuration du format video
   if { $::tcl_platform(os) == "Linux" } {
      label $frm.frame6.videoFormatLabel -text "$caption(webcam,format_video)"
      pack $frm.frame6.videoFormatLabel -anchor nw -side top -padx 10
      ComboBox $frm.frame6.videoFormatList \
         -width [ ::tkutil::lgEntryComboBox $private(videoFormatLabels) ] \
         -height [ llength $private(videoFormatLabels) ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable ::webcam::private($camItem,videoformat) \
         -values $private(videoFormatLabels)
      pack $frm.frame6.videoFormatList -anchor center -padx 10 -pady 5 -ipadx 10 -expand true
   } else {
      button $frm.frame6.format_webcam -text "$caption(webcam,format_video)"
      pack $frm.frame6.format_webcam -in $frm.frame6 -anchor center -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true
   }

   #--- Selection WebCam
   radiobutton $frm.radioWebCam -anchor w -highlightthickness 0 \
      -text "$caption(webcam,webcam)" -value 0 \
      -variable ::webcam::private($camItem,select) -command "::webcam::selectCameraType $camItem"
   pack $frm.radioWebCam -in $frm.frame20 -anchor nw -side top -pady 10

   #--- Selection Autres cameras video
   radiobutton $frm.radioGrabber -anchor w -highlightthickness 0 \
      -text "$caption(webcam,grabber)" -value 1 \
      -variable ::webcam::private($camItem,select) -command "::webcam::selectCameraType $camItem"
   pack $frm.radioGrabber -in $frm.frame20 -anchor nw -side top -pady 10

   #--- Option longue pose avec lien au site web de Steve Chambers
   checkbutton $frm.longuepose -highlightthickness 0 -variable ::webcam::private($camItem,longuepose) \
      -command "::webcam::checkConfigLonguePose $camItem"
   pack $frm.longuepose -in $frm.frame10 -anchor center -side left -pady 3

   set labelName [::confCam::createUrlLabel $frm.frame10 "$caption(webcam,longuepose)" "$caption(webcam,site_web_chambers)"]
   pack $labelName -anchor center -side left -pady 3

   label $frm.lab2 -text "$caption(webcam,longueposeport)"
   pack $frm.lab2 -in $frm.frame11 -anchor center -side left -padx 3 -pady 5

   #--- Bouton de configuration des liaisons
   button $frm.configure -text "$caption(webcam,configurer)" -relief raised \
      -command "::webcam::configureLinkLonguePose $camItem ; \
         ::confLink::run ::webcam::private($camItem,longueposeport) \
         { parallelport quickremote serialport } \"- $caption(webcam,longuepose1) - $caption(webcam,webcam)\""
   pack $frm.configure -in $frm.frame11 -side left -pady 0 -ipadx 10 -ipady 1

   #--- Je constitue la liste des liaisons pour la longuepose
   set list_combobox [ ::confLink::getLinkLabels { "parallelport" "quickremote" "serialport" } ]

   #--- Je verifie le contenu de la liste
   if { [ llength $list_combobox ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- Je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_combobox $private($camItem,longueposeport) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- Je la remplace par le premier item de la liste
         set private($camItem,longueposeport) [ lindex $list_combobox 0 ]
      }
   } else {
      #--- Si la liste est vide
      #--- Je desactive l'option longue pose
      set private($camItem,longueposeport) ""
      set private($camItem,longuepose) 0
      #--- J'empeche de selectionner l'option longue
      $frm.longuepose configure -state disable
   }

   #--- Choix du port ou de la liaison
   ComboBox $frm.lpport \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -editable 0       \
      -textvariable ::webcam::private($camItem,longueposeport) \
      -values $list_combobox \
      -modifycmd "::webcam::configureLinkLonguePose $camItem"
   pack $frm.lpport -in $frm.frame11 -anchor center -side right -padx 10 -pady 5

   label $frm.lab3 -text "$caption(webcam,longueposebit)"
   pack $frm.lab3 -in $frm.frame12 -anchor center -side left -padx 3 -pady 5

   set bitList [ ::confLink::getPluginProperty $private($camItem,longueposeport) "bitList" ]
   ComboBox $frm.longueposelinkbit \
      -width [ ::tkutil::lgEntryComboBox $bitList ] \
      -height [ llength $bitList ] \
      -relief sunken               \
      -borderwidth 1               \
      -textvariable ::webcam::private($camItem,longueposelinkbit) \
      -editable 0                  \
      -values $bitList
   if { [lsearch $bitList $private($camItem,longueposelinkbit)] == -1 } {
      #--- si le bit n'existe pas dans la liste, je selectionne le premier element de la liste
      set private($camItem,longueposelinkbit) [lindex $bitList 0 ]
   }
   pack $frm.longueposelinkbit -in $frm.frame12 -anchor center -side right -padx 10 -pady 5

   label $frm.lab4 -text "$caption(webcam,longueposestart)"
   pack $frm.lab4 -in $frm.frame13 -anchor center -side left -padx 3 -pady 5

  ### entry $frm.longueposestartvalue -width 4 -textvariable ::webcam::private($camItem,longueposestartvalue) -justify center
   set longuePoseStartList [list "0" "1"]
   ComboBox $frm.longueposestartvalue \
      -width [ ::tkutil::lgEntryComboBox $longuePoseStartList ] \
      -height [ llength $longuePoseStartList ] \
      -relief sunken    \
      -borderwidth 1    \
      -editable 0       \
      -textvariable ::webcam::private($camItem,longueposestartvalue) \
      -values $longuePoseStartList
   pack $frm.longueposestartvalue -in $frm.frame13 -anchor center -side right -padx 10 -pady 5

   #--- numero de l'image (Linux uniquement)
   if { $::tcl_platform(os) == "Linux" } {
      frame $frm.frame13b -borderwidth 0 -relief raised
      pack $frm.frame13b -in $frm.frame5 -side top -fill x -pady 5

      label $frm.validFrameLabel -text "$caption(webcam,validFrame)"
      pack  $frm.validFrameLabel -in $frm.frame13b -anchor center -side left -padx 3 -pady 5

      set validFrameList [ list 0 1 2 3 4 5 6 7 8 9]
      ComboBox $frm.validFrame \
         -width [ ::tkutil::lgEntryComboBox $validFrameList ] \
         -height [ llength $validFrameList ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable ::webcam::private($camItem,validFrame) \
         -values $validFrameList
      pack $frm.validFrame -in $frm.frame13b -anchor center -side right -padx 10 -pady 5
   }

   #--- WebCam modifiee avec un capteur Noir et Blanc
   checkbutton $frm.webcamCcd_N_B -text "$caption(webcam,webcamCcd_N_B)" -highlightthickness 0 \
      -variable ::webcam::private($camItem,webcamCcd_N_B) -command "::webcam::checkConfigCCDNB $camItem"
   pack $frm.webcamCcd_N_B -in $frm.frame14 -anchor center -side left -pady 3 -pady 8

   set list_combobox [ list 1/4'' 1/3'' 1/2'' ]
   ComboBox $frm.dim_ccd_N_B \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken         \
      -borderwidth 1         \
      -editable 0            \
     -textvariable ::webcam::private($camItem,dim_ccd_N_B) \
      -modifycmd "::webcam::checkConfigCCDNB $camItem" \
      -values $list_combobox
   pack $frm.dim_ccd_N_B -in $frm.frame15 -anchor center -side right -padx 10 -pady 5

   #--- CCD N&B
   checkbutton $frm.ccd_N_B -text "$caption(webcam,ccd_N_B)" -highlightthickness 0 \
      -variable ::webcam::private($camItem,ccd_N_B)
   pack $frm.ccd_N_B -in $frm.frame16 -anchor center -side left -pady 3 -pady 5

   #--- Dimension des pixels sur l'axe X
   label $frm.labelDimPixX -text "$caption(webcam,dimPixelX)"
   pack $frm.labelDimPixX -in $frm.frame18 -anchor center -side left -padx 10 -pady 5

   entry $frm.entryDimPixX -textvariable ::webcam::private($camItem,dimPixX) -width 7 -justify center
   pack $frm.entryDimPixX -in $frm.frame18 -anchor center -side left -pady 5

   #--- Dimension des pixels sur l'axe Y
   label $frm.labelDimPixY -text "$caption(webcam,dimPixelY)"
   pack $frm.labelDimPixY -in $frm.frame19 -anchor center -side left -padx 10 -pady 5

   entry $frm.entryDimPixY -textvariable ::webcam::private($camItem,dimPixY) -width 7 -justify center
   pack $frm.entryDimPixY -in $frm.frame19 -anchor center -side left -pady 5

   #--- Frame du site web web officiel des WebCams
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(webcam,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [::confCam::createUrlLabel $frm.frame2 "$caption(webcam,site_web_ref)" \
         "$caption(webcam,site_web_ref)"]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::webcam::configWebCam $camItem

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# configureCamera
#    Configure la WebCam en fonction des donnees contenues dans les variables conf(webcam,$camItem,...)
#
proc ::webcam::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {

     ### if { $conf(webcam,switchedConnexion) == 1 } {
     ###   #--- je deconnecte les autres cameras
     ###   foreach camItem2 { A B C } {
     ###       if { $camItem2 != $camItem && $private($camItem2,camNo)!= 0 && $conf(webcam,$camItem2,videomode) == "directx" != 0 } {
     ###          if { [cam$private($camItem2,camNo) connect ] == 1 } {
     ###             cam$private($camItem2,camNo) connect 0
     ###          }
     ###       }
     ###    }
     ### }

      if { $conf(webcam,$camItem,longuepose) == "1" } {
         #--- Je cree la liaison longue pose
         set linkNo [ ::confLink::create $conf(webcam,$camItem,longueposeport) "temp" "" "" ]
        ### set linkNo [ ::confLink::create $conf(webcam,$camItem,longueposeport) "cam $camItem" "longuepose" "bit $conf(webcam,$camItem,longueposelinkbit)" ]
      } else {
         #--- Pas de liaison longue pose
         set linkNo 0
      }

      #--- Changement de variable pour les CCD N&B
      if { $conf(webcam,$camItem,select) == "0" } {
         set ccdNB $conf(webcam,$camItem,webcamCcd_N_B)
      } else {
         set ccdNB $conf(webcam,$camItem,ccd_N_B)
      }

      #--- Je cree la camera
      if { $::tcl_platform(os) == "Linux" } {
         if { $conf(webcam,$camItem,select) == "0" } {
            set camtype webcam
         } else {
            set camtype grabber
         }
      } else {
         # windows
         set camtype webcam
      }

      set camNo [ cam::create $camtype "$conf(webcam,$camItem,port)" \
         -channel $conf(webcam,$camItem,channel) \
         -lpport $conf(webcam,$camItem,longueposeport) \
         -name WEBCAM \
         -ccd $conf(webcam,$camItem,ccd) \
         -videomode $conf(webcam,$camItem,videomode) \
         -sensorcolor [expr $ccdNB==0 ] \
         -longuepose $conf(webcam,$camItem,longuepose) \
         -longueposelinkno $linkNo \
         -longueposelinkbit $conf(webcam,$camItem,longueposelinkbit) \
         -longueposestart $conf(webcam,$camItem,longueposestartvalue) \
         -log_file [::confCam::getLogFileName $camItem] \
         -log_level [::confCam::getLogLevel $camItem] \
      ]

      #--- J'envoie les dimensions des pixels a la librairie
      if { $conf(webcam,$camItem,select) == "1" } {
         cam$camNo celldim [ expr $conf(webcam,$camItem,dimPixX) / 1000000 ] [ expr $conf(webcam,$camItem,dimPixY) / 1000000 ]
      }

      #--- Affichage dans la Console
      if { $conf(webcam,$camItem,select) == "0" } {
         if { $::tcl_platform(os) == "Linux" } {
            #--- j'affiche le canal et le port
            console::affiche_entete "$caption(webcam,webcam) $conf(webcam,$camItem,port)\n"
         } else {
            #--- j'affiche la connexion de la camera
            console::affiche_entete "$caption(webcam,webcam) - $caption(webcam,mode_video) $caption(webcam,2points)\
            $conf(webcam,$camItem,videomode)\n"
         }
         console::affiche_entete "$caption(webcam,longuepose) $caption(webcam,2points)\
            $conf(webcam,$camItem,longuepose)\n"
         console::affiche_saut "\n"
       } else {
         if { $::tcl_platform(os) == "Linux" } {
            #--- j'affiche le canal et le port
            console::affiche_entete "$caption(webcam,grabber) $conf(webcam,$camItem,port)\n"
         } else {
            #--- j'affiche la connexion de la camera
            console::affiche_entete "$caption(webcam,grabber) - $caption(webcam,mode_video) $caption(webcam,2points)\
            $conf(webcam,$camItem,videomode)\n"
         }
         console::affiche_saut "\n"
      }

      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(webcam,$camItem,mirh)
      cam$camNo mirrorv $conf(webcam,$camItem,mirv)
      #--- Je configure le format video (pour Linux uniquement)
      if { $::tcl_platform(os) == "Linux" } {
         cam$camNo validframe  $conf(webcam,$camItem,validFrame)
         cam$camNo videoformat $conf(webcam,$camItem,videoformat)
         cam$camNo framerate   $conf(webcam,$camItem,framerate)
      }
      #--- Je cree la liaison longue pose
      if { $conf(webcam,$camItem,longuepose) == "1" } {
         link$linkNo use remove "temp" ""
         link$linkNo use add "cam$camNo" "longuepose" "bit $conf(webcam,$camItem,longueposelinkbit)"
      }
      #--- Gestion des widgets actifs/inactifs
      ::webcam::configWebCam $camItem

   } ]

   if { $catchResult == "1" } {
      #--- en cas d'erreur, je libere toutes les ressources allouees
      ::webcam::stop $camItem
      #--- je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }

}

#
# selectPort
#    selectionne un port
#
proc ::webcam::selectPort { camItem tklist } {
   variable private

   set index [$tklist curselection]
   set private($camItem,port) [lindex [lindex $private(portList) $index] 0]
}

#
# stop
#    Arrete la WebCam
#
proc ::webcam::stop { camItem } {
   variable private
   global conf

   #--- Gestion des widgets actifs/inactifs
   ::webcam::configWebCamInactif

   #--- Je ferme la liaison longuepose
   if { $conf(webcam,$camItem,longuepose) == 1 } {
      ::confLink::delete $conf(webcam,$camItem,longueposeport) "cam$private($camItem,camNo)" "longuepose"
   }

   #--- J'arrete le mode preview et la capture de film au cas ou ils seraient actifs
   if { $::tcl_platform(platform) == "windows" }  {
      catch {
         if { $private($camItem,camNo) != 0 } {
            cam$private($camItem,camNo) stopvideoview
            cam$private($camItem,camNo) stopvideocapture
         }
      }
   }

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# configWebCam
#    Configure les widgets de configuration de la WebCam
#
proc ::webcam::configWebCam { camItem } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::webcam::isReady $camItem ] == 1 } {
            #--- Boutons de configuration de la WebCam actif
            if { $::tcl_platform(os) == "Linux" } {
               $frm.frame6.videoFormatList configure -state normal
            } else {
               $frm.frame7.conf_webcam configure -state normal -command "cam$private($camItem,camNo) videosource"
               $frm.frame6.format_webcam configure -state normal -command "cam$private($camItem,camNo) videoformat window"
            }
         } else {
            #--- Boutons de configuration de la WebCam inactif
            if { $::tcl_platform(os) == "Linux" } {
               $frm.frame6.videoFormatList configure -state disabled
            } else {
               $frm.frame7.conf_webcam configure -state disabled
               $frm.frame6.format_webcam configure -state disabled
            }
         }

         #--- je mets a jour camItem dans la commande des widgets
         $frm.longuepose configure -command "::webcam::checkConfigLonguePose $camItem"
         $frm.lpport configure -modifycmd "::webcam::configureLinkLonguePose $camItem"
         $frm.webcamCcd_N_B configure -command "::webcam::checkConfigCCDNB $camItem"
         $frm.dim_ccd_N_B configure -modifycmd "::webcam::checkConfigCCDNB $camItem"

         #--- Configure les widgets associes a la selection d'une camera
         ::webcam::selectCameraType $camItem
         #--- Configure les widgets associes a la longue pose
         ::webcam::checkConfigLonguePose $camItem
         #--- Configure les widgets associes au choix du CCD pour la WebCam
         ::webcam::checkConfigCCDNB $camItem

         #--- actualise la liste des ports
         if { $::tcl_platform(os) == "Linux" } {
            #--- je remplis la liste avec la liste des ports
               set private(portList) [lsort -dictionary [ glob -nocomplain /dev/video? ]]
            #--- je selectionne le port courant
             set index [lsearch $private(portList) $private($camItem,port)]
             if { $index != -1 } {
                $frm.frame7.portList selection set $index
             }
         }
      }
   }
}

#
# configWebCamInactif
#    Permet de desactiver les widgets a l'arret de la WebCam
#
proc ::webcam::configWebCamInactif { } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         #--- Boutons de configuration de la WebCam actif
         if { $::tcl_platform(os) == "Linux" } {
            $frm.frame6.videoFormatList configure -state disabled
         } else {
            $frm.frame7.conf_webcam configure -state disabled
            $frm.frame6.format_webcam configure -state disabled
         }
      }
   }
}

#
# checkConfigLonguePose
#    Configure les widgets de configuration de la longue pose
#
proc ::webcam::checkConfigLonguePose { camItem } {
   variable private

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $private($camItem,longuepose) == "1" } {
            #--- Widgets de configuration de la longue pose actifs
            $frm.lpport configure -state normal
            $frm.configure configure -state normal
            $frm.longueposelinkbit configure -state normal
            $frm.longueposestartvalue configure -state normal
         } else {
            #--- Widgets de configuration de la longue pose inactifs
            $frm.lpport configure -state disabled
            $frm.configure configure -state disabled
            $frm.longueposelinkbit configure -state disabled
            $frm.longueposestartvalue configure -state disabled
         }
      }
   }
}

#
# checkConfigCCDNB
#    Configure les widgets de configuration du choix du CCD
#
proc ::webcam::checkConfigCCDNB { camItem } {
   variable private

   set frm $private(frm)
   if { $::webcam::private($camItem,webcamCcd_N_B) == "1" } {
      if { $::webcam::private($camItem,dim_ccd_N_B) == "1/4''" } {
         set ::webcam::private($camItem,ccd) "ICX098BL-6"
      } elseif { $::webcam::private($camItem,dim_ccd_N_B) == "1/3''" } {
         set ::webcam::private($camItem,ccd) "ICX424AL-6"
      } elseif { $::webcam::private($camItem,dim_ccd_N_B) == "1/2''" } {
         set ::webcam::private($camItem,ccd) "ICX414AL-6"
      }
      pack $frm.frame15 -in $frm.frame14 -side right -fill x -pady 5
   } else {
      set ::webcam::private($camItem,ccd) "ICX098BQ-A"
      pack forget $frm.frame15
   }
}

#
# selectCameraType
#    Configure les widgets de configuration du choix du CCD
#
proc ::webcam::selectCameraType { camItem } {
   variable private

   set frm $private(frm)
   if { $::webcam::private($camItem,select) == "1" } {
      #--- Cas du Grabber
      $frm.frame10.labURL configure -state disabled
      $frm.lab2 configure -state disabled
      $frm.lab3 configure -state disabled
      $frm.lab4 configure -state disabled
      $frm.longuepose configure -state disabled
      $frm.webcamCcd_N_B configure -state disabled
      $frm.lpport configure -state disabled
      $frm.configure configure -state disabled
      $frm.longueposelinkbit configure -state disabled
      $frm.longueposestartvalue configure -state disabled
      pack forget $frm.frame15
      $frm.ccd_N_B configure -state normal
      $frm.labelDimPixX configure -state normal
      $frm.entryDimPixX configure -state normal
      $frm.labelDimPixY configure -state normal
      $frm.entryDimPixY configure -state normal
   } else {
      #--- Cas de la WebCam
      $frm.frame10.labURL configure -state normal
      $frm.lab2 configure -state normal
      $frm.lab3 configure -state normal
      $frm.lab4 configure -state normal
      $frm.longuepose configure -state normal
      $frm.webcamCcd_N_B configure -state normal
      ::webcam::checkConfigLonguePose $camItem
      ::webcam::checkConfigCCDNB $camItem
      $frm.ccd_N_B configure -state disabled
      $frm.labelDimPixX configure -state disabled
      $frm.entryDimPixX configure -state disabled
      $frm.labelDimPixY configure -state disabled
      $frm.entryDimPixY configure -state disabled
   }
}

#
# configureLinkLonguePose
#    Positionne la liaison sur celle qui vient d'etre selectionnee pour la longue pose
#
proc ::webcam::configureLinkLonguePose { camItem } {
   variable private

   set frm $private(frm)

   #--- je rafraichis la liste des bits disponibles pour la commande de la longue pose
   set bitList [ ::confLink::getPluginProperty $private($camItem,longueposeport) "bitList" ]
   $frm.longueposelinkbit configure -values $bitList -height [ llength $bitList ] -width [::tkutil::lgEntryComboBox $bitList]
   if { [lsearch $bitList $private($camItem,longueposelinkbit)] == -1 } {
      #--- si le bit n'existe pas dans la liste, je selectionne le premier element de la liste
      set private($camItem,longueposelinkbit) [lindex $bitList 0 ]
   }

   #--- Je positionne startvalue par defaut en fonction du type de liaison
   switch [ ::confLink::getLinkNamespace $private($camItem,longueposeport) ] {
      "parallelport" {
         set private($camItem,longueposestartvalue) "0"
      }
      "quickremote" {
         set private($camItem,longueposestartvalue) "1"
      }
      "serialport" {
         set private($camItem,longueposestartvalue) "1"
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
proc ::webcam::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 255 0 ] }
      hasBinning       { return 0 }
      hasFormat        { return 0 }
      hasLongExposure  { return 1 }
      hasScan          { return 0 }
      hasShutter       { return 0 }
      hasTempSensor    { return 0 }
      hasSetTemp       { return 0 }
      hasVideo         { return 1 }
      hasWindow        { return 0 }
      longExposure     { return $::conf(webcam,$camItem,longuepose) }
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
      shutterList      { return [ list "" ] }
   }
}

# ========= Namespace de la fenetre de configuration ========
namespace eval ::webcam::config {
}

#------------------------------------------------------------
# run
#    affiche la fenetre de configuration
#------------------------------------------------------------
proc ::webcam::config::run { visuNo camItem } {
   variable private

   if { $::tcl_platform(os) == "Linux" } {
      set private($visuNo,toplevel) "[confVisu::getBase $visuNo].webcamconfig"
      set private($visuNo,camItem) $camItem

      set private(frameRateList) [list "5" "10" "15" "20" "25" "30" "50"]
      set private(shutterList)   [list "1/5" "1/10" "1/15" "1/20" "1/25" "1/33" "1/50" "1/100" "1/250" "1/500" "1/1000" "1/2500" "1/5000" "1/10000"]

      #--- j'affiche la fenetre de configuration
      if { [winfo exists $private($visuNo,toplevel)] == 0 } {
         ::confGenerique::run $visuNo $private($visuNo,toplevel) "::webcam::config" -modal 0
         wm transient $private($visuNo,toplevel) [winfo parent  $private($visuNo,toplevel) ]
         wm geometry $private($visuNo,toplevel) $::conf(webcam,$camItem,configWindowPosition)
      } else {
         focus $private($visuNo,toplevel)
      }
      set result 0
   } else {
      set result [ after 10 "cam$::webcam::private($camItem,camNo) videosource" ]
   }
   return $result
}

#------------------------------------------------------------
# cmdClose
#    ferme la fenetre de configuration
#------------------------------------------------------------
proc ::webcam::config::cmdClose { visuNo } {
   variable private

   #--- j'enregistre la position de la fentre de configuration
   set geometry [ wm geometry $private($visuNo,toplevel)]
   set deb [ expr 1 + [ string first + $geometry ] ]
   set fin [ string length $geometry ]
   set ::conf(webcam,$private($visuNo,camItem),configWindowPosition) "+[ string range $geometry $deb $fin ]"
}

#------------------------------------------------------------
# getLabel
#    retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::webcam::config::getLabel { } {
   global caption

   return "$caption(webcam,configurer) $caption(webcam,camera)"
}

#------------------------------------------------------------
# fillConfigPage
#    fenetre de configuration de la camera
# return rien
#------------------------------------------------------------
proc ::webcam::config::fillConfigPage { frm visuNo } {
   variable private
   global caption

   set private($visuNo,This) $frm

   #--- j'initialise les variables des widgets
   set private($visuNo,framerate)   $::conf(webcam,$private($visuNo,camItem),framerate)
   set private($visuNo,shutter)     $::conf(webcam,$private($visuNo,camItem),shutter)
   set private($visuNo,gain)        $::conf(webcam,$private($visuNo,camItem),gain)
   set private($visuNo,autoShutter) $::conf(webcam,$private($visuNo,camItem),autoShutter)
   set private($visuNo,autoGain)    $::conf(webcam,$private($visuNo,camItem),autoGain)

   TitleFrame $frm.shutter -borderwidth 2 -relief ridge -text "$caption(webcam,shutter)"
      checkbutton $frm.shutter.auto -text "$caption(webcam,auto)" -highlightthickness 0 \
         -variable ::webcam::config::private($visuNo,autoShutter) \
         -command "::webcam::config::onSetAutoShutter $visuNo $frm.shutter.scale"
      pack $frm.shutter.auto -in [$frm.shutter getframe] -anchor w -side top -fill none -expand 0
      #listbox $frm.shutter.list -state normal -width [llength $private(shutterList)] -listvariable ::webcam::config::private(shutterList)
      scale $frm.shutter.scale -from "0." -to "100." \
         -orient vertical -showvalue true -bigincrement 10 -tickinterval 5 -resolution 1 -width 8 \
         -borderwidth 1 -relief groove \
         -variable ::webcam::config::private($visuNo,shutter) \
         -command "::webcam::config::onSelectShutter $visuNo $frm.shutter.scale"
      pack $frm.shutter.scale -in [$frm.shutter getframe] -anchor w -side top -fill y -expand 1
      #bind $frm.shutter.list <<ListboxSelect>> "::webcam::config::onSelectShutter $visuNo $frm.shutter.list"
   pack $frm.shutter -anchor w -side left -fill y -expand 0

   TitleFrame $frm.gain -borderwidth 2 -relief ridge -text "$caption(webcam,gain)"
      checkbutton $frm.gain.auto -text "$caption(webcam,auto)" -highlightthickness 0 \
         -variable ::webcam::config::private($visuNo,autoGain) \
         -command "::webcam::config::onSetAutoGain $visuNo $frm.gain.scale"
      pack $frm.gain.auto -in [$frm.gain getframe] -anchor w -side top -fill none -expand 0
      scale $frm.gain.scale -from "0" -to "100" \
         -orient vertical -showvalue true -tickinterval 1 -resolution 1 -width 8 \
         -borderwidth 1 -relief groove \
         -variable ::webcam::config::private($visuNo,gain) \
         -command "::webcam::config::onSelectGain $visuNo $frm.gain.scale"
      pack $frm.gain.scale -in [$frm.gain getframe] -anchor w -side top -fill y -expand 1
   pack $frm.gain -anchor w -side left -fill y -expand 0

   TitleFrame $frm.framerate -borderwidth 2 -relief ridge -text "$caption(webcam,framerate)"
      listbox $frm.framerate.list -state normal  -width 8 -listvariable ::webcam::config::private(frameRateList)
      pack $frm.framerate.list -in [$frm.framerate getframe] -anchor w -side top -fill y -expand 0
      bind $frm.framerate.list <<ListboxSelect>> "::webcam::config::onSelectFrameRate $visuNo $frm.framerate.list"
   pack $frm.framerate -anchor w -side left -fill y -expand 0

   pack $frm -fill y -expand 1

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   $frm.framerate.list selection set [lsearch $private(frameRateList) $private($visuNo,framerate)]
   $frm.shutter.scale set $private($visuNo,shutter)
   $frm.gain.scale    set $private($visuNo,gain)
   ::webcam::config::onSetAutoShutter $visuNo $frm.shutter.scale
   ::webcam::config::onSetAutoGain $visuNo $frm.gain.scale
}

#------------------------------------------------------------
# onSelectFrameRate
#    selectionne le nombre d'images par seconde
#
# return null
#------------------------------------------------------------
proc ::webcam::config::onSelectFrameRate { visuNo tklist } {
   variable private

   #--- je copie la valeur selectionnee dans la variable private
   set index [$tklist curselection]
   if { $index != "" } {
      set private($visuNo,framerate) [$tklist get $index ]
      set camItem $private($visuNo,camItem)
      set camNo $::webcam::private($camItem,camNo)
      if { $private($visuNo,framerate) != $::conf(webcam,$camItem,framerate) } {
         set catchResult [ catch { cam$camNo framerate $private($visuNo,framerate) } catchMessage ]
         if { $catchResult == 0 } {
            set ::conf(webcam,$private($visuNo,camItem),framerate) $private($visuNo,framerate)
         } else {
            tk_messageBox -message "$catchMessage" -title [::webcam::config::getLabel] -icon error
            set private($visuNo,framerate) $::conf(webcam,$private($visuNo,camItem),framerate)
            $private($visuNo,This).framerate.list selection clear 0 end
            $private($visuNo,This).framerate.list selection set [lsearch $private(frameRateList) $private($visuNo,framerate)]
         }
      }
   }
}

#------------------------------------------------------------
# onSelectShutter
#    selectionne la vitesse d'obturation
#
#    A negative value sets the shutter speed to automatic
#    (controlled by the camera's firmware).
#    A value of 0..65535 will set manual mode, where the values
#    have been calibrated such that 65535 is the longest possible
#    exposure time. It is not a linear scale, where a value of '1'
#    is 1/65536th of a second, etc.
#
# return null
#------------------------------------------------------------
proc ::webcam::config::onSelectShutter { visuNo tklist value } {
   variable private

   set camItem $private($visuNo,camItem)
   if { $private($visuNo,shutter) != $::conf(webcam,$camItem,shutter) } {
      set camNo $::webcam::private($camItem,camNo)
      if { $private($visuNo,autoShutter) == 0 } {
         #--- j'ajoute un point pour transformer en valeur decimale
         append value "."
         set value [expr $value]
         #--- je convertis le pourcentage en fraction de 65535
         set value [expr int( $value * 65535. / 100. ) ]
         cam$camNo setvideoparameter -shutter $value
         #--- j'attends un peu pour ne pas saturer
         after 100
      } else {
         cam$camNo setvideoparameter -shutter "-1"
      }
      set ::conf(webcam,$camItem,shutter) $private($visuNo,shutter)
   }
}

#------------------------------------------------------------
# onSelectGain
#    selectionne le gain
#
# return null
#------------------------------------------------------------
proc ::webcam::config::onSelectGain { visuNo tkscale value } {
   variable private

   set camItem $private($visuNo,camItem)

   if { $private($visuNo,gain) != $::conf(webcam,$camItem,gain) } {
      set camNo $::webcam::private($camItem,camNo)
      if { $private($visuNo,autoGain) == 0 } {
         #--- j'ajoute un point pour transformer en valeur decimale
         append value "."
         #--- je convertis en fraction de 65535
         set value [expr int( 65535. * $value / 100.) ]
         cam$camNo setvideoparameter -gain $value
         #--- j'attends un peu pour ne pas saturer
         after 100
      } else {
         cam$camNo setvideoparameter -gain "-1"
      }
      set ::conf(webcam,$camItem,gain) $private($visuNo,gain)
   }
}

#------------------------------------------------------------
# onSetAutoShutter
#    change le mode automatique du shutter
#
# return null
#------------------------------------------------------------
proc ::webcam::config::onSetAutoShutter { visuNo tklist } {
   variable private

   if { $private($visuNo,autoShutter) == 0 } {
      $tklist configure -state normal
   } else {
      $tklist configure -state disabled
   }

   set camItem $private($visuNo,camItem)

   if { $private($visuNo,autoShutter) != $::conf(webcam,$camItem,autoShutter)  } {
      set camNo $::webcam::private($camItem,camNo)
      if { $private($visuNo,autoShutter) == 0 } {
         #--- j'ajoute un point pour transformer en valeur decimale
         set value $::conf(webcam,$camItem,shutter)
         append value "."
         #--- je convertis le pourcentage en fraction de 65535
         set value [expr $value]
         set value [expr int( $value * 65535. / 100. ) ]
         cam$camNo setvideoparameter -shutter $value
      } else {
         cam$camNo setvideoparameter -shutter "-1"
      }
      set ::conf(webcam,$camItem,autoShutter) $private($visuNo,autoShutter)
   }
}

#------------------------------------------------------------
# onSetGainAuto
#    change le mode automatique du gain
#
# return null
#------------------------------------------------------------
proc ::webcam::config::onSetAutoGain { visuNo tkscale } {
   variable private

   if { $private($visuNo,autoGain) == 0 } {
      $tkscale configure -state normal
   } else {
      $tkscale configure -state disabled
   }

   set camItem $private($visuNo,camItem)

    if { $private($visuNo,autoGain) != $::conf(webcam,$camItem,autoGain) } {
      set camNo $::webcam::private($camItem,camNo)
      if { $private($visuNo,autoGain) == 0 } {
         #--- j'ajoute un point pour transformer en valeur decimale
         set value $::conf(webcam,$camItem,autoGain)
         append value "."
         #--- je convertis en fraction de 65535
         set value [expr int( $value * 65535./ 100.) ]
         cam$camNo setvideoparameter -gain $value
      } else {
         cam$camNo setvideoparameter -gain "-1"
      }
      set ::conf(webcam,$camItem,autoGain) $private($visuNo,autoGain)
   }
}

