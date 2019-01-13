#
# Fichier : autoguider.tcl
# Description : Outil d'autoguidage
# Auteur : Michel PUJOL
# Mise à jour $Id: autoguider.tcl 12695 2016-01-17 08:23:30Z robertdelmas $
#

package provide autoguider 1.3

#==============================================================
#   Declaration du namespace autoguider
#    initialise le namespace
#==============================================================
namespace eval ::autoguider {

   #--- Je charge le fichier caption pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] autoguider.cap ]
}

#------------------------------------------------------------
# getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::autoguider::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "guiding" }
      display      { return "panel" }
      multivisu    { return 1 }
   }
}

#------------------------------------------------------------
# getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#
# return "Titre du plugin"
#------------------------------------------------------------
proc ::autoguider::getPluginTitle { } {
   global caption

   return "$caption(autoguider,menu)"
}

#------------------------------------------------------------
# getPluginType
#    retourne le type de plugin
#
# return "focuser"
#------------------------------------------------------------
proc ::autoguider::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::autoguider::getPluginHelp { } {
   return "autoguider.htm"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#------------------------------------------------------------
proc ::autoguider::getPluginDirectory { } {
   return "autoguider"
}

#------------------------------------------------------------
# getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::autoguider::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::autoguider::createPluginInstance { base { visuNo 1 } } {
   variable private
   global audace caption conf

   source [ file join $audace(rep_plugin) tool autoguider autoguiderconfig.tcl ]

   if { ! [ info exists conf(autoguider,pose) ] }                { set conf(autoguider,pose)                 "0" }
   if { ! [ info exists conf(autoguider,binning) ] }             { set conf(autoguider,binning)              [lindex $audace(list_binning) 1] }
   if { ! [ info exists conf(autoguider,intervalle)] }           { set conf(autoguider,intervalle)           ".5" }
   if { ! [ info exists conf(autoguider,alphaSpeed)] }           { set conf(autoguider,alphaSpeed)           "10" }
   if { ! [ info exists conf(autoguider,deltaSpeed)] }           { set conf(autoguider,deltaSpeed)           "10" }
   if { ! [ info exists conf(autoguider,seuilx)] }               { set conf(autoguider,seuilx)               "1" }
   if { ! [ info exists conf(autoguider,seuily)] }               { set conf(autoguider,seuily)               "1" }
   if { ! [ info exists conf(autoguider,detection)] }            { set conf(autoguider,detection)            "PSF" }
   if { ! [ info exists conf(autoguider,learn,delay)] }          { set conf(autoguider,learn,delay)          "5" }
   if { ! [ info exists conf(autoguider,angle)] }                { set conf(autoguider,angle)                "0" }
   if { ! [ info exists conf(autoguider,showAlphaDeltaAxis)] }   { set conf(autoguider,showAlphaDeltaAxis)   "1" }
   if { ! [ info exists conf(autoguider,showImage)] }            { set conf(autoguider,showImage)            "1" }
   if { ! [ info exists conf(autoguider,showTarget)] }           { set conf(autoguider,showTarget)           "1" }
   if { ! [ info exists conf(autoguider,targetBoxSize)] }        { set conf(autoguider,targetBoxSize)        "16" }
   if { ! [ info exists conf(autoguider,detectionThreshold)] }   { set conf(autoguider,detectionThreshold)   "10" }
   if { ! [ info exists conf(autoguider,originCoord)] }          { set conf(autoguider,originCoord)          [list 320 240 ] }
   if { ! [ info exists conf(autoguider,configWindowPosition)] } { set conf(autoguider,configWindowPosition) "+0+0" }
   if { ! [ info exists conf(autoguider,declinaisonEnabled)] }   { set conf(autoguider,declinaisonEnabled)   "1" }
   if { ! [ info exists conf(autoguider,cumulEnabled)] }         { set conf(autoguider,cumulEnabled)         "0" }
   if { ! [ info exists conf(autoguider,cumulNb)] }              { set conf(autoguider,cumulNb)              "5" }
   if { ! [ info exists conf(autoguider,slitWidth)] }            { set conf(autoguider,slitWidth)            "4" }
   if { ! [ info exists conf(autoguider,slitRatio)] }            { set conf(autoguider,slitRatio)            "1.0" }
   if { ! [ info exists conf(autoguider,alphaReverse)] }         { set conf(autoguider,alphaReverse)         "0" }
   if { ! [ info exists conf(autoguider,deltaReverse)] }         { set conf(autoguider,deltaReverse)         "0" }
   if { ! [ info exists conf(autoguider,searchThreshin)] }       { set conf(autoguider,searchThreshin)       "10" }
   if { ! [ info exists conf(autoguider,searchFwhm)] }           { set conf(autoguider,searchFwhm)           "3" }
   if { ! [ info exists conf(autoguider,searchRadius)] }         { set conf(autoguider,searchRadius)         "4" }
   if { ! [ info exists conf(autoguider,searchThreshold)] }      { set conf(autoguider,searchThreshold)      "40" }
   if { ! [ info exists conf(autoguider,centerSpeed)] }          { set conf(autoguider,centerSpeed)          "2" }
   if { ! [ info exists conf(autoguider,darkEnabled)] }          { set conf(autoguider,darkEnabled)          "0" }
   if { ! [ info exists conf(autoguider,darkFileName)] }         { set conf(autoguider,darkFileName)         ""}

   if { $conf(autoguider,originCoord) == "" }                    { set conf(autoguider,originCoord)          [list 320 240 ] }

   set private($visuNo,base)              $base
   set private($visuNo,This)              "$base.autoguider"
   set private($visuNo,hCanvas)           [::confVisu::getCanvas $visuNo]

   set private($visuNo,mountEnabled)      0
   set private($visuNo,acquisitionState)  0
   set private($visuNo,acquisitionResult) ""
   set private($visuNo,origin,x)          [lindex $::conf(autoguider,originCoord) 0]
   set private($visuNo,origin,y)          [lindex $::conf(autoguider,originCoord) 1]
   set private($visuNo,flux)              "0"
   set private($visuNo,dx)                "0.00"
   set private($visuNo,dy)                "0.00"
   set private($visuNo,delay,alpha)       "0.00"
   set private($visuNo,delay,delta)       "0.00"
   set private($visuNo,targetCoord)       "$conf(autoguider,originCoord)"
   set private($visuNo,interval)          ""
   set private($visuNo,updateAxis)        "0"
   set private($visuNo,camBufNo)          "0"
   set private($visuNo,darkBufNo)         "0"
   set private($visuNo,cumulCounter)      "0"
   set private($visuNo,currentMouseItem)  ""       ; #--- item en cous de deplacement avec la souris
   set private($visuNo,hCanvas)           [::confVisu::getCanvas $visuNo]

   set private($visuNo,redColor)          "#ff9582" ; #--- rouge tendre

   #--- Petit raccourci bien pratique
   set This $private($visuNo,This)

   #--- Cadre de l'outil
   frame $This -borderwidth 2 -relief groove

   #--- Cadre du titre de l'outil
   frame $This.titre -borderwidth 2 -relief groove
      Button $This.titre.but -borderwidth 1 \
         -text "$caption(autoguider,help_titre1)\n$caption(autoguider,titre)" \
         -command {
            ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::autoguider::getPluginType]] \
               [::autoguider::getPluginDirectory] [::autoguider::getPluginHelp]
         }
      pack $This.titre.but -side top -fill x
      DynamicHelp::add $This.titre.but -text "$caption(autoguider,help_titre)"
   grid $This.titre -sticky new

   #--- Cadre de la configuration
   frame $This.config -borderwidth 2 -relief groove
      button $This.config.but_config  -text "$caption(autoguider,config_guidage)" \
         -command "::autoguider::config::run $visuNo"
      pack $This.config.but_config -side top -fill x
   grid $This.config -sticky new

   #--- Cadre du temps de pose
   frame $This.pose -borderwidth 2 -relief ridge
      label $This.pose.lab1 -text "$caption(autoguider,pose)"
      set list_combobox {0 0.1 0.3 0.5 1 2 3 5 10}
      ComboBox $This.pose.combo \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 1 \
         -textvariable ::conf(autoguider,pose) \
         -modifycmd "::autoguider::onChangeExposure $visuNo" \
         -values $list_combobox
      button $This.pose.confwebcam -text "$caption(autoguider,pose)" \
         -command "::autoguider::webcamConfigure $visuNo"
   grid $This.pose -sticky new

   #--- Cadre du binning
   frame $This.binning -borderwidth 2 -relief ridge
      label $This.binning.lab1 -text "$caption(autoguider,binning)"
      pack $This.binning.lab1 -anchor center -side left -padx 5
      set list_combobox [list "" ]
      ComboBox $This.binning.combo \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 0 \
         -textvariable ::conf(autoguider,binning) \
         -values $list_combobox \
         -modifycmd "::autoguider::selectBinning $visuNo"
      pack $This.binning.combo -anchor center -side left -fill x -expand 1
   grid $This.binning -sticky new

   #--- Cadre de l'intervalle
   frame $This.intervalle -borderwidth 2 -relief ridge
      label $This.intervalle.lab1 -text "$caption(autoguider,intervalle)"
      pack $This.intervalle.lab1 -anchor center -side left -padx 5
      set list_combobox {0 0.1 0.3 0.5 1 2 3 5 10}
      ComboBox $This.intervalle.combo \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 0 \
         -textvariable conf(autoguider,intervalle) \
         -values $list_combobox
      pack $This.intervalle.combo -anchor center -side left -fill x -expand 1
   grid $This.intervalle -sticky new

   #--- Cadre du bouton Go/Stop
   frame $This.go_stop -borderwidth 2 -relief ridge
      button $This.go_stop.but -text "$caption(autoguider,GO)" -height 2 \
         -borderwidth 3 -pady 6 -command "::autoguider::startGuiding $visuNo"
      pack $This.go_stop.but -fill both -padx 0 -pady 0 -expand true
   grid $This.go_stop -sticky new

   #--- Frame pour l'autoguidage
   frame $This.suivi -borderwidth 2 -relief ridge
      ###checkbutton $This.suivi.but_autovisu -text "$caption(autoguider,image)" \
      ###   -variable ::conf(autoguider,showImage) \
      ###   -command "::autoguider::changeShowImage $visuNo"
      ###checkbutton $This.suivi.but_showtarget -text "$caption(autoguider,cible)" \
      ###   -variable ::conf(autoguider,showTarget) \
      ###   -command "::autoguider::setShowTarget $visuNo"
      Button $This.suivi.origin_but -text "Consigne" \
         -helptext "Appliquer les modifications" \
         -command "::autoguider::setOriginWithEntry $visuNo "
      entry $This.suivi.origin_x  -textvariable ::autoguider::private($visuNo,origin,x) \
         -width 6 \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      entry $This.suivi.origin_y  -textvariable ::autoguider::private($visuNo,origin,y) \
         -width 6 \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      checkbutton $This.suivi.but_showaxis -text "$caption(autoguider,axe_AD)" \
         -variable ::conf(autoguider,showAlphaDeltaAxis) \
         -command "::autoguider::setShowAlphaDeltaAxis $visuNo"
      checkbutton $This.suivi.montEnabled -padx 0 -pady 0 \
         -text "$caption(autoguider,ctrl_monture)" \
         -variable ::autoguider::private($visuNo,mountEnabled) -command "::autoguider::setMountEnabled $visuNo"
      button $This.suivi.search -text "$caption(autoguider,rechercher)" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::autoguider::startSearch $visuNo"
      button $This.suivi.clear -text "$caption(autoguider,effacer)" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::autoguider::clearSearchStar $visuNo"
      button $This.suivi.center -text "$caption(autoguider,centrer)" -height 1 \
        -borderwidth 1 -pady 2 -command "::autoguider::startCenter $visuNo"

      Label $This.suivi.fluxLabel    -text $caption(autoguider,intensiteMax)
      Label $This.suivi.fluxValue    -textvariable ::autoguider::private($visuNo,flux) -width 5 -justify right
      label $This.suivi.label_d      -text "$caption(autoguider,ecart_origine_etoile)"
      label $This.suivi.dx           -textvariable ::autoguider::private($visuNo,dx) -width 5
      label $This.suivi.dy           -textvariable ::autoguider::private($visuNo,dy) -width 5
      label $This.suivi.label_delay  -text "$caption(autoguider,impulsion)"
      label $This.suivi.delay_alpha  -textvariable ::autoguider::private($visuNo,delay,alpha) -width 5
      label $This.suivi.delay_delta  -textvariable ::autoguider::private($visuNo,delay,delta) -width 5
      label $This.suivi.label_clock  -text "$caption(autoguider,intervalle)"
      label $This.suivi.lab_clock    -textvariable ::autoguider::private($visuNo,interval) -justify right

      ###grid $This.suivi.but_autovisu   -row 0 -column 0 -columnspan 3 -sticky {}
      ###grid $This.suivi.but_showtarget -row 1 -column 0 -columnspan 3 -sticky {}
      grid $This.suivi.origin_but     -row 0 -column 0 -sticky w
      grid $This.suivi.origin_x       -row 0 -column 1 -sticky w
      grid $This.suivi.origin_y       -row 0 -column 2 -sticky w
      grid $This.suivi.but_showaxis   -row 1 -column 0 -columnspan 3 -sticky {}
      grid $This.suivi.montEnabled    -row 2 -column 0 -columnspan 3 -sticky {}
      grid $This.suivi.fluxLabel      -row 3 -column 0 -columnspan 2 -sticky w
      grid $This.suivi.fluxValue      -row 3 -column 2 -sticky w
      grid $This.suivi.label_d        -row 4 -column 0 -sticky w
      grid $This.suivi.dx             -row 4 -column 1 -sticky w
      grid $This.suivi.dy             -row 4 -column 2 -sticky w
      grid $This.suivi.label_delay    -row 5 -column 0 -sticky w
      grid $This.suivi.delay_alpha    -row 5 -column 1 -sticky w
      grid $This.suivi.delay_delta    -row 5 -column 2 -sticky w
      grid $This.suivi.label_clock    -row 6 -column 0 -sticky w
      grid $This.suivi.lab_clock      -row 6 -column 1 -columnspan 2
      grid $This.suivi.search         -row 7 -column 0 -columnspan 3 -sticky ew
      grid $This.suivi.clear          -row 8 -column 0 -columnspan 3 -sticky ew
      grid $This.suivi.center         -row 9 -column 0 -columnspan 3 -sticky ew
      grid $This.suivi -sticky nsew
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This

   #--- j'adapte l'affichage des boutons en fonction de la camera selectionnee
   adaptPanel $visuNo

   #---
   return $private($visuNo,This)
}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::autoguider::deletePluginInstance { visuNo } {
   variable private

   ::autoguider::stopAcquisition $visuNo

   #--- je detruis le panel
   destroy $private($visuNo,This)
}

#------------------------------------------------------------
# adaptPanel
#    adapte l'affichage des boutons en fonction de la camera
#------------------------------------------------------------
proc ::autoguider::adaptPanel { visuNo args } {
   variable private
   global conf

   set This $private($visuNo,This)
   set camItem [ ::confVisu::getCamItem $visuNo ]

   #--- j'adapte les boutons de selection de pose et de binning
   if { [::confCam::getPluginProperty $camItem longExposure] == "1" } {
      #--- cameras autre que webcam, ou webcam avec la longue pose
      pack $This.pose.lab1 -anchor center -side left -padx 5
      pack $This.pose.combo -anchor center -side left -fill x -expand 1
      pack forget $This.pose.confwebcam
   } else {
      #--- webcam
      pack forget $This.pose.lab1
      pack forget $This.pose.combo
      pack $This.pose.confwebcam -anchor center -side left -fill x -expand 1
      #--- je met la pose a zero car cette variable n'est utilisee et doit etre nulle
      set ::conf(autoguider,pose) "0"
   }

   if { [::confCam::getPluginProperty $camItem hasBinning] == "0" } {
     grid remove $This.binning
   } else {
     set list_binning [::confCam::getPluginProperty $camItem binningList]
     $This.binning.combo configure -values $list_binning -height [ llength $list_binning]
     grid $This.binning
   }

   #--- je calcule la position de l'orgine si elle est hors de l'image de la camera
   if { [::confCam::isReady $camItem] != 0 } {
      set camNo [::confCam::getCamNo $camItem ]
      set camSize [cam$camNo nbpix]
      if { [lindex $::conf(autoguider,originCoord) 0 ] >=  [lindex $camSize 0]
        || [lindex $::conf(autoguider,originCoord) 1 ] >=  [lindex $camSize 1] } {
         set ::conf(autoguider,originCoord) [list [expr [lindex $camSize 0]/2] [expr [lindex $camSize 1]/2] ]
      }

      #--- je configure le thread de la camera
      ::camera::setParam $camItem "detectionThreshold" $::conf(autoguider,detectionThreshold)

      #--- je configure l'acquisition du dark
      ::autoguider::setDarkSubstract $visuNo

   }

   #--- si la cible n'est pas deja fixee, je prends les coordonnees de l'origine
   if { [llength $private($visuNo,targetCoord)] != 2 } {
      set private($visuNo,targetCoord) $::conf(autoguider,originCoord)
   }
}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::autoguider::startTool { { visuNo 1 } } {
   variable private

   #--- je cree les bind pour l'item "::autoguider::axis"
   $private($visuNo,hCanvas) bind "::autoguider::axis" <ButtonPress-1>   "::autoguider::onMousePressButton1 $visuNo %W %x %y"
   $private($visuNo,hCanvas) bind "::autoguider::axis" <B1-Motion>       "::autoguider::onMouseMoveButton1  $visuNo %W %x %y"
   $private($visuNo,hCanvas) bind "::autoguider::axis" <ButtonRelease-1> "::autoguider::onMouseReleaseButton1 $visuNo %W %x %y"
   $private($visuNo,hCanvas) bind "::autoguider::axis" <Enter>           "::autoguider::onMouseEnter $visuNo"
   $private($visuNo,hCanvas) bind "::autoguider::axis" <Leave>           "::autoguider::onMouseLeave $visuNo"

   #--- je change le bind du double-clic du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <Double-1> "::autoguider::setTargetCoord $visuNo %x %y"

   #--- j'active la mise a jour automatique de l'affichage quand on change de camera
   ::confVisu::addCameraListener $visuNo "::autoguider::adaptPanel $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de zoom
   ::confVisu::addZoomListener $visuNo "::autoguider::onChangeZoom $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de fenetrage
   ::confVisu::addSubWindowListener $visuNo "::autoguider::onChangeSubWindow $visuNo"
   #--- j'active la mise a jour automatique de l'affichage quand on change de miroir
   ::confVisu::addMirrorListener $visuNo "::autoguider::onChangeSubWindow $visuNo"

   #--- j'affiche la cible
   createTarget $visuNo

   #--- j'affiche les axes
   createAlphaDeltaAxis $visuNo $::conf(autoguider,originCoord) $::conf(autoguider,angle)

   #--- je configure l'acquisition du dark
   ::autoguider::setDarkSubstract $visuNo
}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::autoguider::stopTool { visuNo } {
   variable private

   #--- je verifie si une operation est en cours
   if { $private($visuNo,acquisitionState) == 1 } {
      return -1
   }

   #--- j'arrete le suivi
   stopAcquisition $visuNo

   #--- je desactive l'adaptation de l'affichage quand on change de camera
   ::confVisu::removeCameraListener $visuNo "::autoguider::adaptPanel $visuNo"
   #--- je desactive l'adaptation de l'affichage quand on change de zoom
   ::confVisu::removeZoomListener $visuNo "::autoguider::onChangeZoom $visuNo"
   #--- je desactive l'adaptation de l'affichage quand on change de fenetrage
   ::confVisu::removeSubWindowListener $visuNo "::autoguider::onChangeSubWindow $visuNo"
   #--- je desactive l'adaptation de l'affichage quand on change de miroir
   ::confVisu::removeMirrorListener $visuNo "::autoguider::onChangeSubWindow $visuNo"

   #--- je supprime la cible
   ::autoguider::deleteTarget $visuNo

   #--- je masque les axes
   ::autoguider::deleteAlphaDeltaAxis $visuNo

   #--- je masque les marques des etoiles
   $private($visuNo,hCanvas) delete autoguiderstar

   #--- je restaure le bind par defaut du double-clic du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <Double-1> "default"
   #--- je restaure le bind par defaut du double-clic du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <Double-Button-1> "default"

   #--- je supprime les binds des items "::autoguider"
   $private($visuNo,hCanvas) bind "::autoguider::axis" <ButtonPress-1>   ""
   $private($visuNo,hCanvas) bind "::autoguider::axis" <B1-Motion>       ""
   $private($visuNo,hCanvas) bind "::autoguider::axis" <ButtonRelease-1> ""
   $private($visuNo,hCanvas) bind "::autoguider::axis" <Enter>           ""
   $private($visuNo,hCanvas) bind "::autoguider::axis" <Leave>           ""
}

#------------------------------------------------------------
#  startSearch
#     cherche l'etoile la plus brillante
#  parametres
#     visuNo : numero de visu
#  return :
#     - les coordonnees de l'etoile trouvee
#     - une chaine vide si une etoile n'est pas trouvee
#------------------------------------------------------------
proc ::autoguider::startSearch { visuNo } {
   variable private
   global conf

   #--- je ne fais rien si une demande d'arret est en cours
   if { $private($visuNo,acquisitionState) == 1 } {
      return 1
   }

   #--- Petits raccourcis bien pratiques
   set camItem [::confVisu::getCamItem $visuNo ]
   set camNo [::confCam::getCamNo $camItem ]

   #--- je verifie la presence la camera
   if { [::confCam::isReady $camItem] == 0 } {
      ::confCam::run
      return 1
   }

   ###set ::conf(autoguider,detection)       "PSF"
   set private($visuNo,acquisitionState)  1
   set private($visuNo,acquisitionResult) ""
   ::autoguider::createTarget $visuNo

   #--- J'affiche le bouton "STOP" et l'associe a la commande d'arret
   $private($visuNo,This).suivi.search configure \
      -text "Search STOP" \
      -command "::autoguider::stopAcquisition $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::autoguider::stopAcquisition $visuNo"

   #--- j'efface les etoiles
   clearSearchStar $visuNo

   #--- je lance la recherche
   ###set binning [list [string range $::conf(autoguider,binning) 0 0] [string range $::conf(autoguider,binning) 2 2]]
   set targetBoxSize 0
   ::camera::searchBrightestStar $camItem \
      "::autoguider::callbackAcquisition $visuNo" \
      $::conf(autoguider,pose) \
      $::conf(autoguider,originCoord) \
      $targetBoxSize \
      $conf(autoguider,searchThreshin) $conf(autoguider,searchFwhm) $conf(autoguider,searchRadius) $conf(autoguider,searchThreshold)

   #--- j'attends la fin de l'acquisition
   vwait ::autoguider::private($visuNo,acquisitionState)

   if { $private($visuNo,acquisitionResult) != "" } {
      set hCanvas [::confVisu::getCanvas $visuNo]
      #--- j'affiche les etoiles
      foreach star $private($visuNo,acquisitionResult) {
         #--- je dessine des cercles autour des etoiles
         set coord [::confVisu::picture2Canvas $visuNo [lrange $star 1 2]]
         set x  [lindex $coord 0]
         set y  [lindex $coord 1]
         $hCanvas create oval [expr $x-5] [expr $y-5] [expr $x+5] [expr $y+5] -fill {} -outline blue -width 2 -activewidth 3 -tag autoguiderstar
      }

      #--- je cree un deuxieme cercle autour de l'etoile la plus brillante
      set brigthestStarCoord [lrange [lindex $private($visuNo,acquisitionResult) 0 ] 1 2]
      set coord [::confVisu::picture2Canvas $visuNo $brigthestStarCoord ]
      set x  [lindex $coord 0]
      set y  [lindex $coord 1]
      $hCanvas create oval [expr $x-8] [expr $y-8] [expr $x+8] [expr $y+8] -fill {} -outline red -width 2 -activewidth 3 -tag autoguiderstar

      #--- je deplace la cible vers les ccordonnees de l'etoile la plus brillante
      set private($visuNo,targetCoord) $brigthestStarCoord
      moveTarget $visuNo $brigthestStarCoord

   } else {
      set brigthestStarCoord ""
   }

   return $brigthestStarCoord
}

proc ::autoguider::stopSearch { visuNo } {
   ::autoguider::stopAcquisition $visuNo
}


#------------------------------------------------------------
#  clearSearchStar
#     efface les marques des etoiles
#  parametres
#     visuNo : numero de visu
#  return :
#     rien
#------------------------------------------------------------
proc ::autoguider::clearSearchStar { visuNo } {
   variable private

   $private($visuNo,hCanvas) delete autoguiderstar
}

#------------------------------------------------------------
#  startCenter
#     centre l'etoile
#  parametres
#     visuNo : numero de visu
#  return :
#     - les coordonnees de l'etoile trouvee si l'etoile est centree
#     - une chaine vide si l'etoile n'est pas centree
#------------------------------------------------------------
proc ::autoguider::startCenter { visuNo } {
   variable private

   #--- je ne fais rien si une demande d'arret est en cours
   if { $private($visuNo,acquisitionState) == 1 } {
      return 1
   }

   #--- Petits raccourcis bien pratiques
   set camItem [::confVisu::getCamItem $visuNo ]
   set camNo [::confCam::getCamNo $camItem ]

   #--- je verifie la presence la camera
   if { [::confCam::isReady $camItem] == 0 } {
      ::confCam::run
      return 1
  }

   #--- j'active l'envoi des commandes a la monture si c'est demande
   if { $private($visuNo,mountEnabled) == 1 } {
      ::telescope::setSpeed $::conf(autoguider,centerSpeed)
   }

   ###set ::conf(autoguider,detection)       "PSF"
   set private($visuNo,acquisitionState)  1
   set private($visuNo,acquisitionResult) ""
   ::autoguider::createTarget $visuNo

   #--- J'affiche le bouton "STOP" et l'associe a la commande d'arret
   $private($visuNo,This).suivi.center configure \
      -text "Center STOP" \
      -command "::autoguider::stopCenter $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::autoguider::stopCenter $visuNo"
   update

   #--- je lance le centrage
   ###set binning [list [string range $::conf(autoguider,binning) 0 0] [string range $::conf(autoguider,binning) 2 2]]
   ::camera::centerBrightestStar $camItem "::autoguider::callbackAcquisition $visuNo" $::conf(autoguider,pose) $::conf(autoguider,originCoord) $private($visuNo,targetCoord) $::conf(autoguider,angle) $::conf(autoguider,targetBoxSize) $private($visuNo,mountEnabled) $::conf(autoguider,alphaSpeed) $::conf(autoguider,deltaSpeed) $::conf(autoguider,alphaReverse) $::conf(autoguider,deltaReverse) $::conf(autoguider,seuilx) $::conf(autoguider,seuily)

   #--- j'attends la fin du centrage
   vwait ::autoguider::private($visuNo,acquisitionState)

   return $private($visuNo,acquisitionResult)
}

proc ::autoguider::stopCenter { visuNo } {
   ::autoguider::stopAcquisition $visuNo
}

proc ::autoguider::startAcquisition { visuNo } {
   variable private

   #--- Petits raccourcis bien pratiques
   set camItem [::confVisu::getCamItem $visuNo ]

   ::camera::acquisition $camItem "::autoguider::callbackAcquisition $visuNo" $::conf(autoguider,pose)
   vwait ::autoguider::private($visuNo,acquisitionResult)
}

#------------------------------------------------------------
#  startGuiding
#     lance l'autoguidage
#  parametres
#     visuNo : numero de visu
#  return :
#     none
#------------------------------------------------------------
proc ::autoguider::startGuiding { visuNo } {
   variable private

   if { $private($visuNo,acquisitionState) == 1 } {
      return ""
   }

   #--- Petits raccourcis bien pratiques
   set camItem [::confVisu::getCamItem $visuNo ]

   #--- je verifie la presence la camera
   if { [::confCam::isReady $camItem] == 0 } {
      ::confCam::run
      return 1
   }

   #--- J'affiche le bouton "STOP" et l'associe a la commande d'arret
   $private($visuNo,This).go_stop.but configure \
      -text "$::caption(autoguider,STOP)" \
      -command "::autoguider::stopAcquisition $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::autoguider::stopAcquisition $visuNo"

   #--- j'initialise les valeurs affichees
   set private($visuNo,acquisitionState)  1
   set private($visuNo,acquisitionResult) ""

   #--- j'active l'envoi des commandes a la monture si c'est demande
   if { $private($visuNo,mountEnabled) == 1 } {
      ::telescope::setSpeed 1
   }






   #--- je fais l'acquisition
   ###set binning [list [string range $::conf(autoguider,binning) 0 0] [string range $::conf(autoguider,binning) 2 2]]
   ::camera::guide $camItem "::autoguider::callbackAcquisition $visuNo" \
      $::conf(autoguider,pose)         \
      $::conf(autoguider,detection)    \
      $::conf(autoguider,originCoord)   \
      $private($visuNo,targetCoord)    \
      $::conf(autoguider,angle)        \
      $::conf(autoguider,targetBoxSize) \
      $private($visuNo,mountEnabled)   \
      $::conf(autoguider,alphaSpeed)   \
      $::conf(autoguider,deltaSpeed)   \
      $::conf(autoguider,alphaReverse) \
      $::conf(autoguider,deltaReverse) \
      $::conf(autoguider,seuilx)       \
      $::conf(autoguider,seuily)       \
      $::conf(autoguider,slitWidth)    \
      $::conf(autoguider,slitRatio)    \
      $::conf(autoguider,intervalle)   \
      $::conf(autoguider,declinaisonEnabled)

   return 0
}

proc ::autoguider::callbackAcquisition { visuNo command args } {
   variable private

   set catchError [ catch {

      ###console::disp "callbackAcquisition visu=$visuNo command=$command args=$args\n"
      switch $command  {
         "autovisu" {
            if { $::conf(autoguider,showImage) == "1" } {
               ::confVisu::autovisu $visuNo
            }
            if { [winfo exists $private($visuNo,This) ] } {
               #--- j'affiche les axes si ce n'est pas deja fait
               if {  [$private($visuNo,hCanvas) gettags "::autoguider::axis" ] == "" } {
                  createAlphaDeltaAxis $visuNo $::conf(autoguider,originCoord) $::conf(autoguider,angle)
               }
               #--- j'affiche le temps ecoulee depuis l'image precedente
               set private($visuNo,interval) [format "%###0d ms" [lindex $args 0]]
            }
         }
         "error" {
            console::affiche_erreur "callbackGuide visu=$visuNo command=$command $args\n"
            ::autoguider::stopAcquisition $visuNo
         }
         "targetCoord" {
            # args : $starStatus $starCoord $dx $dy $maxIntensity $istar $cstar $astar $message
            if { [winfo exists $private($visuNo,This)] } {
               set starStatus [lindex $args 0]
               set private($visuNo,targetCoord) [lindex $args 1]
               set private($visuNo,dx) [format "%##0.1f" [lindex $args 2]]
               set private($visuNo,dy) [format "%##0.1f" [lindex $args 3]]
               set flux [lindex $args 4]
               if { $flux != "" } {
                  set private($visuNo,flux) [format "%##0.0f" $flux]
               } else {
                  set private($visuNo,flux) $flux
               }
               ::autoguider::setFlux $visuNo $starStatus
               ::autoguider::moveTarget $visuNo $private($visuNo,targetCoord)
            }
         }
         "mountInfo" {
            set private($visuNo,delay,alpha) "[lindex $args 1] [lindex $args 0]"
            set private($visuNo,delay,delta) "[lindex $args 3] [lindex $args 2]"
         }
         "acquisitionResult" {
            #--- je recupere la liste des etoiles
            set private($visuNo,acquisitionResult) [lindex $args 0]
            ::autoguider::stopAcquisition $visuNo
         }
      }

   } ]

   #--- je traite les erreur imprevues
   if { $catchError != 0 } {
      #--- J'arrete les acquisitions
      stopAcquisition $visuNo
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(autoguider,titre)
   }

}

#------------------------------------------------------------
# stopAcquisition
#    Demande l'arret des acquisitions . L'arret sera effectif apres la fin
#    de l'acquisition en cours
#------------------------------------------------------------
proc ::autoguider::stopAcquisition { visuNo } {
   variable private
   global caption

   if { $private($visuNo,acquisitionState) == 1 } {
      #--- je demande l'arret des acquisitions
      set camItem [ ::confVisu::getCamItem $visuNo ]
      if { $camItem != "" } {
         ::camera::stopAcquisition $camItem
      }
      $private($visuNo,This).go_stop.but configure \
         -text "$::caption(autoguider,GO)" \
         -command "::autoguider::startGuiding $visuNo"
      $private($visuNo,This).suivi.center configure \
         -text "$caption(autoguider,centrer)" \
         -command "::autoguider::startCenter $visuNo"
      $private($visuNo,This).suivi.search configure \
         -text "$caption(autoguider,rechercher)" \
         -command "::autoguider::startSearch $visuNo"

      #--- je supprime l'association du bouton escape
      bind all <Key-Escape> ""
      #--- j'initialise la variable
      set private($visuNo,acquisitionState) 0
      #--- j'applique les changements
      update
   }
}

##------------------------------------------------------------
# setOriginWithEntry
# Initialise la position de la consigne a partir des coordonnées saisies
# dans le widget entry
#
# @param visuNo    : numero de la visu courante
# @param x     : abcisse de l'origine des axes (referentiel ecran)
# @param y     : ordonnee de l'origine des axes (referentiel ecran)
#------------------------------------------------------------
proc ::autoguider::setOriginWithEntry { visuNo } {
   variable private
   setOrigin $visuNo [list $private($visuNo,origin,x) $private($visuNo,origin,y)]
   return
}

##------------------------------------------------------------
# setOrigin
#     initialise la position de la consigne
#
# @param visuNo    : numero de la visu courante
# @param coord  : coordonnees de l'origine des axes (referentiel Picture)
#------------------------------------------------------------
proc ::autoguider::setOrigin { visuNo coord } {
   variable private

   set xc [lindex $coord 0 ]
   set yc [lindex $coord 1 ]

   set margin 8
   set windowCoords [::confVisu::getWindow $visuNo]
   if { $windowCoords == [list 0 0 0 0] } {
      #--- il n'y a pas d'image dans le buffer
      #--- j'efface la consigne, sans modifier ses ccordonnees
      deleteAlphaDeltaAxis $visuNo
   } else {
      #--- il ya  une image dans le buffer
      #--- je verifie que la consigne est dans l'image
      set xmin [expr [lindex $windowCoords 0] + $margin]
      set ymin [expr [lindex $windowCoords 1] + $margin]
      set xmax [expr [lindex $windowCoords 2] - $margin]
      set ymax [expr [lindex $windowCoords 3] - $margin]
      if { $xc < $xmin || $xc > $xmax || $yc < $ymin || $yc >$ymax } {
         #--- la consigne n'est pas dans l'image
         #--- message sonore
         bell
         #--- je verifie que les coordonnes precedentes de la consigne sont dans l"image
         set xc [lindex $::conf(autoguider,originCoord) 0 ]
         set yc [lindex $::conf(autoguider,originCoord) 1 ]
         if { $xc < $xmin || $xc > $xmax || $yc < $ymin || $yc >$ymax } {
            #--- je place la consigne au centre de l'image
            set ::conf(autoguider,originCoord) [list [expr ($xmax - $xmin)/2.0 ] [expr ($ymax - $ymin)/2.0 ] ]
         }
      } else {
         #--- je memorise les nouvelles coordonnees de la consigne
         set ::conf(autoguider,originCoord) $coord
      }

      #--- je dessine les axes sur la nouvelle origine
      createAlphaDeltaAxis $visuNo $::conf(autoguider,originCoord) $::conf(autoguider,angle)
      #--- je met a ajour les entry
      set private($visuNo,origin,x)          [lindex $::conf(autoguider,originCoord) 0]
      set private($visuNo,origin,y)          [lindex $::conf(autoguider,originCoord) 1]
      #--- je met a jour le thread de la camera
      ::camera::setParam [::confVisu::getCamItem $visuNo] "originCoord" $::conf(autoguider,originCoord)
   }
   return
}

##------------------------------------------------------------
# setTargetCoord
#    initialise les coordonnees de la cible
#
# @param visuNo  numero de la visu courante
# @param x       abcisse de la cible (referentiel ecran)
# @param y       ordonnee de la cible (referentiel ecran)
#------------------------------------------------------------
proc ::autoguider::setTargetCoord { visuNo x y } {
   variable private

   #---
   if { [buf[visu$visuNo buf] imageready] == 0 } {
      return
   }

   #--- je calcule les coordonnees de l'etoile dans l'image
   set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
   set coord [::confVisu::canvas2Picture $visuNo $coord]
   set private($visuNo,targetCoord) $coord

   #--- je dessine la cible aux nouvelle coordonnee sur la nouvelle origine
   moveTarget $visuNo $private($visuNo,targetCoord)

   #--- je transmet les coordonnees a l'interperteur de la camera
   ::camera::setParam [::confVisu::getCamItem $visuNo] "targetCoord" $private($visuNo,targetCoord)
}

#------------------------------------------------------------
# createTarget
#    affiche la cible autour du point de coordonnees targetCoord
#
#           PSF                     SLIT
#       *----------* y1=y0+w   *----------*  y2=y0+w
#       |          |           |          |
#       |          |           *----------*  s2=y0+slitWidth/2
#     ..|..........|...........|..........|
#       |          |           *----------*  s1=y0-slitWidth/2
#       |          |           |          |
#       *----------* y1=y0-w   *----------*  y1=y0-w
#       x1         x2          x1         x2
# @param visuNo  numero de la visu courante
#------------------------------------------------------------
proc ::autoguider::createTarget { visuNo } {
   variable private

   #--- je supprime l'affichage precedent de la cible
   deleteTarget $visuNo

   if { $::conf(autoguider,detection) == "PSF" } {
      #--- je calcule les coordonnees dans l'image
      set x  [lindex $private($visuNo,targetCoord) 0]
      set y  [lindex $private($visuNo,targetCoord) 1]
      set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
      set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
      set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
      set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]

      #--- je calcule les coordonnees dans le canvas
      set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
      set x  [lindex $coord 0]
      set y  [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
      set x1 [lindex $coord 0]
      set y1 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
      set x2 [lindex $coord 0]
      set y2 [lindex $coord 1]

      #--- je cree les items graphiques dans le canvas
      $private($visuNo,hCanvas) create rect $x1 $y1 $x2 $y2 -outline red -offset center -tag target
   } else {
      #--- je calcule les coordonnees dans l'image
      set x  [lindex $private($visuNo,targetCoord) 0]
      set y  [lindex $private($visuNo,targetCoord) 1]
     set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
      set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
      set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
      set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]
      set s1 [expr int($y) - $::conf(autoguider,slitWidth)/2]
      set s2 [expr int($y) + $::conf(autoguider,slitWidth)/2]

      #--- je calcule les coordonnees dans le canvas
      set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
      set x  [lindex $coord 0]
      set y  [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
      set x1 [lindex $coord 0]
      set y1 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
      set x2 [lindex $coord 0]
      set y2 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x1 $s1 ]]
      set x1 [lindex $coord 0]
      set s1 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x2 $s2 ]]
      set x2 [lindex $coord 0]
      set s2 [lindex $coord 1]

      #--- je cree les items graphiques dans le canvas
      $private($visuNo,hCanvas) create rect $x1 $y1 $x2 $s1 -outline red -offset center -tag target1
      $private($visuNo,hCanvas) create rect $x1 $s2 $x2 $y2 -outline red -offset center -tag target2
   }

   setShowTarget $visuNo
}

#------------------------------------------------------------
# deleteTarget
#    supprime l'affichage de la cible
#
# @param visuNo      numero de la visu courante
#------------------------------------------------------------
proc ::autoguider::deleteTarget { visuNo } {
   variable private

   #--- je supprime l'ffichage de la cible
   $private($visuNo,hCanvas) delete "target" "target1" "target2"
   $private($visuNo,hCanvas) dtag "target"
   $private($visuNo,hCanvas) dtag "target1"
   $private($visuNo,hCanvas) dtag "target2"
}

##------------------------------------------------------------
# moveTarget
#    deplace l'affichage de la cible
#
# @param visuNo         numero de la visu courante
# @param targetCoord    coordonnees de la cible (referentiel buffer)
#------------------------------------------------------------
proc ::autoguider::moveTarget { visuNo targetCoord } {
   variable private

   if { $::conf(autoguider,detection) == "PSF" } {
      #--- je calcule les coordonnees dans le buffer
      set x  [lindex $targetCoord 0]
      set y  [lindex $targetCoord 1]
      set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
      set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
      set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
      set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]

      #--- je calcule les coordonnees dans le canvas
      #set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
      #set x  [lindex $coord 0]
      #set y  [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
      set xCan1 [lindex $coord 0]
      set yCan1 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
      set xCan2 [lindex $coord 0]
      set yCan2 [lindex $coord 1]

      #--- je deplace la cible aux nouvelles coordonnees
      $private($visuNo,hCanvas) coords "target" [list $xCan1 $yCan1 $xCan2 $yCan2]

   } else {
      #--- je calcule les coordonnees dans le buffer
      set x  [lindex $targetCoord 0]
      set y  [lindex $targetCoord 1]
      set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
      set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
      set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
      set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]
      set s1 [expr int($y) - $::conf(autoguider,slitWidth)/2]
     set s2 [expr int($y) + $::conf(autoguider,slitWidth)/2]

      #--- je calcule les coordonnees dans le canvas
      #set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
      #set x  [lindex $coord 0]
      #set y  [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
      set xCan1 [lindex $coord 0]
      set yCan1 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
      set xCan2 [lindex $coord 0]
      set yCan2 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x1 $s1 ]]
      set xCan1 [lindex $coord 0]
      set sCan1 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x2 $s2 ]]
      set xCan2 [lindex $coord 0]
      set sCan2 [lindex $coord 1]

      #--- je deplace la cible aux nouvelles coordonnees
      $private($visuNo,hCanvas) coords "target1" [list $xCan1 $yCan1 $xCan2 $sCan1]
      $private($visuNo,hCanvas) coords "target2" [list $xCan1 $sCan2 $xCan2 $yCan2]
   }
}

#------------------------------------------------------------
# setShowTarget
#    si showTarget==0 , efface la zone cible
#    si showTarget==1 , ne fait rien , la cible sera affichee apres la prochaine acquistion
#------------------------------------------------------------
proc ::autoguider::setShowTarget { visuNo } {
   variable private

   if { $::conf(autoguider,showTarget) == "1" } {
      $private($visuNo,hCanvas)  itemconfigure "target"  -state normal
      $private($visuNo,hCanvas)  itemconfigure "target1" -state normal
      $private($visuNo,hCanvas)  itemconfigure "target2" -state normal
   } else {
      $private($visuNo,hCanvas)  itemconfigure "target"  -state hidden
      $private($visuNo,hCanvas)  itemconfigure "target1" -state hidden
      $private($visuNo,hCanvas)  itemconfigure "target2" -state hidden
   }

   ###if { $::conf(autoguider,showTarget) == "0" } {
   ###   #--- j'efface la cible
   ###   deleteTarget $visuNo
   ###} else {
   ###   #--- je dessine la cible
   ###   if { $private($visuNo,targetCoord) == "" } {
   ###      set bufNo [::confVisu::getBufNo $visuNo ]
   ###      if { [buf$bufNo imageready] == 1  } {
   ###         set ::conf(autoguider,originCoord) [list [expr [buf$bufNo getpixelswidth]/2] [expr [buf$bufNo getpixelsheight]/2] ]
   ###      } else {
   ###         #--- impossible de calculer la position de la zone cible car il n'y a pas d'image
   ###         return
   ###      }
   ###      set private($visuNo,targetCoord) $::conf(autoguider,originCoord)
   ###   }
   ###
   ###   #--- j'affiche la zone cible
   ###   createTarget $visuNo
   ###}
}

#------------------------------------------------------------
# createAlphaDeltaAxis
#    dessine les axes alpha et delta centres sur l'origine
#
# parametres :
#    visuNo    : numero de la visu courante
#------------------------------------------------------------
proc ::autoguider::createAlphaDeltaAxis { visuNo originCoord angle } {
   variable private

   #--- je supprime les axes s'ils existent deja
   deleteAlphaDeltaAxis $visuNo
   #-- je verifie la presence d'une image dans le buffer
   set bufNo [::confVisu::getBufNo $visuNo ]
   if { [buf$bufNo imageready] == 0 } {
      return
   }
   #--- je dessine l'axe alpha
   drawAxis $visuNo $originCoord $angle "Est" "West"
   #--- je dessine l'axe delta
   drawAxis $visuNo $originCoord [expr $angle+90] "South" "North"

   if { $::conf(autoguider,showAlphaDeltaAxis) == "1" } {
      $private($visuNo,hCanvas)  itemconfigure "::autoguider::axis"  -state normal
   } else {
      $private($visuNo,hCanvas)  itemconfigure "::autoguider::axis"  -state hidden
   }
}

#------------------------------------------------------------
# deleteAlphaDeltaAxis
#    arrete l'affichage des axes alpha et delta
#
# parametres :
#    visuNo    : numero de la visu courante
#------------------------------------------------------------
proc ::autoguider::deleteAlphaDeltaAxis { visuNo } {
   variable private

   #--- je supprime les axes
   $private($visuNo,hCanvas) delete ::autoguider::axis
}

#------------------------------------------------------------
# drawAxis
#    trace un axe avec un libelle a chaque extremite
#
# parametres :
#    visuNo    : numero de la visu courante
#    coord     : coordonnees de l'origine des axes (referentiel buffer)
#    angle     : angle d'inclinaison des axes (en degres)
#    label1    : libelle de l'extremite negative de l'axe
#    label2    : libelle de l'extremite positive de l'axe
#------------------------------------------------------------
proc ::autoguider::drawAxis { visuNo coord angle label1 label2} {
   variable private
   global audace

   #--- j'inverse le signe de l'angle
   ###set angle [expr $angle * (-1) ]
   set margin 8
   set vide   2
   set windowCoords [::confVisu::getWindow $visuNo]
   set xmin [expr [lindex $windowCoords 0] + $margin]
   set ymin [expr [lindex $windowCoords 1] + $margin]
   set xmax [expr [lindex $windowCoords 2] - $margin]
   set ymax [expr [lindex $windowCoords 3] - $margin]

   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set a  [expr tan($angle*3.14159265359/180)]
   set b  [expr $y - $a * $x]

   #--- je calcule les coordonnees des extremites de l'axe
   if { $a > 1000000 || $a < -1000000 } {
      #--- l'axe est vertical
      if { [expr sin($angle*3.14159265359/180)] >= 0 } {
         set y1 $ymin
         set y2 $ymax
         set yc1 [expr $y - $vide]
         set yc2 [expr $y + $vide]
      } else {
         set y1 $ymax
         set y2 $ymin
         set yc1 [expr $y + $vide]
         set yc2 [expr $y - $vide]
      }
      set x1 $x
      set x2 $x
      set xc1 $x
      set xc2 $x
   } elseif { $a > 0.00000001 || $a < -0.00000001 } {
      #--- l'axe n'est ni vertical ni horizontal
      if { [expr sin($angle*3.14159265359/180)] >= 0 } {
         set y1 $ymin
         set y2 $ymax
         set yc1 [expr $y - $vide]
         set yc2 [expr $y + $vide]
      } else {
         set y1 $ymax
         set y2 $ymin
         set yc1 [expr $y + $vide]
         set yc2 [expr $y - $vide]
      }
      set x1 [expr ($y1 - $b) / $a ]
      if { $x1 < $xmin } {
         set x1 $xmin
         set y1 [expr $a * $x1 + $b]
      } elseif { $x1 > $xmax } {
         set x1 $xmax
         set y1 [expr $a * $x1 + $b]
      }
      set x2 [expr ($y2 - $b) / $a ]
      if { $x2 < $xmin } {
         set x2 $xmin
         set y2 [expr $a * $x2 + $b]
      } elseif { $x2 > $xmax } {
         set x2 $xmax
         set y2 [expr $a * $x2 + $b]
      }
      set xc1 [expr ($yc1 - $b) / $a ]
      set xc2 [expr ($yc2 - $b) / $a ]

   } else {
      #--- l'axe est horizontal
      if { [expr cos($angle*3.14159265359/180)] >= 0 } {
         set x1 $xmin
         set x2 $xmax
         set xc1 [expr $x - $vide]
         set xc2 [expr $x + $vide]
      } else {
         set x1 $xmax
         set x2 $xmin
         set xc1 [expr $x + $vide]
         set xc2 [expr $x - $vide]
      }
      set y1 $y
      set y2 $y
      set yc1 $y
      set yc2 $y
   }

   #--- je transforme les coordonnees dans le repere canvas
   set coord1 [::confVisu::picture2Canvas $visuNo [list $x1 $y1]]
   set coord2 [::confVisu::picture2Canvas $visuNo [list $x2 $y2]]
   set cc1 [::confVisu::picture2Canvas $visuNo [list $xc1 $yc1]]
   set cc2 [::confVisu::picture2Canvas $visuNo [list $xc2 $yc2]]
   #--- je trace l'axe et les libelles des extremites
   ###$private($visuNo,hCanvas) create line [lindex $coord1 0] [lindex $coord1 1] [lindex $coord2 0] [lindex $coord2 1] \
   ###   -fill $::audace(color,drag_rectangle) -tag "::autoguider::axis" -state normal \
   ###   -activewidth 4 -width 1
   $private($visuNo,hCanvas) create line [lindex $cc1 0] [lindex $cc1 1] [lindex $coord1 0] [lindex $coord1 1] \
      -fill $::audace(color,drag_rectangle) -tag "::autoguider::axis" -state normal \
      -activewidth 3 -width 1
   $private($visuNo,hCanvas) create line [lindex $cc2 0] [lindex $cc2 1] [lindex $coord2 0] [lindex $coord2 1] \
      -fill $::audace(color,drag_rectangle) -tag "::autoguider::axis" -state normal \
      -activewidth 3 -width 1

   $private($visuNo,hCanvas) create text [lindex $coord1 0] [lindex $coord1 1] -text $label1 -tag "::autoguider::axis"  -state normal -fill $::audace(color,drag_rectangle)
   $private($visuNo,hCanvas) create text [lindex $coord2 0] [lindex $coord2 1] -text $label2 -tag "::autoguider::axis"  -state normal -fill $::audace(color,drag_rectangle)
}

#------------------------------------------------------------
# setShowAlphaDeltaAxis
#    affiche/cache les axes alpha et delta centres sur l'origine
#------------------------------------------------------------
proc ::autoguider::setShowAlphaDeltaAxis { visuNo } {
   variable private

   #--- j'affiche la consigne
   setOrigin $visuNo $::conf(autoguider,originCoord)

}

#------------------------------------------------------------
# setFlux
#    affiche change la couleur de fond du widget du flux
#    si l'etoile n'est pas detectee, affiche le fond en rouge
#    sinon affiche le fond avec la couleur par defaut
#------------------------------------------------------------
proc ::autoguider::setFlux { visuNo starStatus } {
   variable private

   if { $starStatus == "NO_SIGNAL" } {
      #--- j'affiche le voyant en rouge
      $private($visuNo,This).suivi.fluxLabel configure \
         -bg   $private($visuNo,redColor) \
         -helptext $::caption(autoguider,noSignal)
      $private($visuNo,This).suivi.fluxValue configure \
         -bg   $private($visuNo,redColor) \
         -helptext $::caption(autoguider,noSignal)
   } else {
      #--- j'affiche le voyant avec la couleur par defaut
      $private($visuNo,This).suivi.fluxLabel configure \
         -bg $::audace(color,backColor) \
         -helptext ""
      $private($visuNo,This).suivi.fluxValue configure \
         -bg $::audace(color,backColor) \
         -helptext ""
   }
}

#------------------------------------------------------------
# changeShowImage
#    si showImage==0 , efface l'image
#    si showImage==1 , ne fait rien , l'image sera affiche apres la prochaine acquisition
#------------------------------------------------------------
proc ::autoguider::changeShowImage { visuNo } {
   if { $::conf(autoguider,showImage) == "0" } {
      #--- j'efface l'image
      visu$visuNo clear
   } else {
      #--- j'affiche l'image
      # rien a faire ici car l'image sera affichee apres la prochaine acquisition
   }
}

##------------------------------------------------------------
# configureWebcam
#    affiche la fenetre de configuration d'une webcam
# @param visuNo         numero de la visu courante
#------------------------------------------------------------
proc ::autoguider::webcamConfigure { visuNo } {
   global caption

   set result [::webcam::config::run $visuNo [::confVisu::getCamItem $visuNo]]
   if { $result == "1" } {
      if { [ ::confVisu::getCamItem $visuNo ] == "" } {
         ::audace::menustate disabled
         set choix [ tk_messageBox -title $caption(autoguider,pb) -type ok \
                -message $caption(autoguider,selcam) ]
         if { $choix == "ok" } {
             #--- Ouverture de la fenetre de selection des cameras
             ::confCam::run
             tkwait window $audace(base).confCam
         }
         ::audace::menustate normal
      }
   }
}

##------------------------------------------------------------
# onChangeExposure
#  cette procedure est appellee par la commbbo de choix du temps de pose
#  pour changer le temps de pose
#------------------------------------------------------------
proc ::autoguider::onChangeExposure { visuNo } {
   variable private

   #--- je change les paramètres dans le thread
   if { $private($visuNo,acquisitionState) != 0 } {
      ::camera::setAsynchroneParameter [::confVisu::getCamItem $visuNo] "exptime" $::conf(autoguider,pose)
   }
}


##------------------------------------------------------------
# onChangeZoom
#      appele par confVisu quand on change le zoom de la visu
#
# @param visuNo       numero de la visu courante
# @param args         valeur fournies par le gestionnaire de listener
#------------------------------------------------------------
proc ::autoguider::onChangeZoom { visuNo args } {
   variable private

   #--- je redessine l'origine
   createAlphaDeltaAxis $visuNo $::conf(autoguider,originCoord) $::conf(autoguider,angle)
   #--- je redessine la cible
   moveTarget $visuNo $private($visuNo,targetCoord)
}

#------------------------------------------------------------
#  onChangeSubWindow
#     appele par confVisu quand on applique un fenetrage sur la visu
#
# @param visuNo       numero de la visu courante
# @param args         valeur fournies par le gestionnaire de listener
#------------------------------------------------------------
proc ::autoguider::onChangeSubWindow { visuNo args } {
   variable private

   #--- je redessine l'origine
   createAlphaDeltaAxis $visuNo $::conf(autoguider,originCoord) $::conf(autoguider,angle)
   #--- je redessine la cible
   moveTarget $visuNo $private($visuNo,targetCoord)
}

##------------------------------------------------------------
# Affiche le curseur sous forme de main "hand2" quand le curseur de la souris
# passe au dessus de l'item declare dans le binds
#
# @param visuNo  numero de la visu courante
# @return  void
#------------------------------------------------------------
proc ::autoguider::onMouseEnter { visuNo  } {
   variable private

     $private($visuNo,hCanvas) configure -cursor hand2
}

##------------------------------------------------------------
# Affiche le curseur sous forme de croix "crosshair" quand le curseur de la souris
# ne passe plus au dessus de l'item declare dans le bind
#
# @param visuNo  numero de la visu courante
# @return  void
#------------------------------------------------------------
proc ::autoguider::onMouseLeave { visuNo  } {
   variable private

     $private($visuNo,hCanvas) configure -cursor crosshair
}

##------------------------------------------------------------
# onMousePressButton1
#   clique sur l'origine avec la souris
#
# @param visuNo  numero de la visu courante
# @param w       handle du canvas
# @param x       abcisse de la souris (referentiel ecran)
# @param y       ordonnee de la souris (referentiel ecran)
# @return  null
#------------------------------------------------------------
proc ::autoguider::onMousePressButton1 { visuNo w x y } {
   variable private

   #--- je verifie qu'une image est presente dans le buffer
   set bufNo [::confVisu::getBufNo $visuNo ]
   if { [buf$bufNo imageready] == 0 } {
      return
   }

   set tags [$w itemcget current -tags]
   #--- je recupere le type de l'item (deuxieme tag)
   set typeItem [lindex $tags 0]
   switch $typeItem  {
      "::autoguider::axis" {
         $private($visuNo,hCanvas) configure -cursor hand2
         set x [$w canvasx $x]
         set y [$w canvasy $y]
         set private($visuNo,currentx)       $x
         set private($visuNo,currenty)       $y
         set private($visuNo,startx)         $x
         set private($visuNo,starty)         $y
         set private($visuNo,currentMouseItem) $typeItem
      }
   }
}

##------------------------------------------------------------
# onMouseMoveButton1
#   deplace le cusrseur la souris
#
# @param visuNo  numero de la visu courante
# @param w       handle du canvas
# @param x       abcisse de la souris (referentiel ecran)
# @param y       ordonnee de la souris (referentiel ecran)
# @return  null
#------------------------------------------------------------
proc ::autoguider::onMouseMoveButton1 { visuNo w x y } {
   variable private

   switch $private($visuNo,currentMouseItem) {
      "::autoguider::axis" {
         #--- la consigne est selectionnee
         set x [$w canvasx $x]
         set y [$w canvasy $y]
         set dx [expr {$x - $private($visuNo,currentx)}]
         set dy [expr {$y - $private($visuNo,currenty)}]
         set private($visuNo,currentx) $x
         set private($visuNo,currenty) $y
         $w move "::autoguider::axis" $dx $dy
      }
      default {
         #--- la consigne n'est pas selectionnee
         ::confVisu::onMotionButton1 $visuNo $x $y
         return
      }
   }
}

##------------------------------------------------------------
# Traite l'evenement ReleaseButton1
# Si l'item ::autoguider::axis avait été sélectionné quand le bouton
# alors deplace l'item a la position du curseur de la souris
#
# Sinon appelle le traitement pasr defaut defini dans confVisu
#
# @param visuNo  numero de la visu courante
# @param w       handle du canvas
# @param x       abcisse de la souris (referentiel ecran)
# @param y       ordonnee de la souris (referentiel ecran)
# @return  null
#------------------------------------------------------------
proc ::autoguider::onMouseReleaseButton1 { visuNo w x y } {
   variable private

   switch $private($visuNo,currentMouseItem) {
      "::autoguider::axis" {
         #--- la consigne est selectionnee

         #--- je calcule les coordonnees du centre de l'origine dans l'image
         set coord [::confVisu::picture2Canvas $visuNo $::conf(autoguider,originCoord)]
         set moveCoord [::confVisu::screen2Canvas $visuNo [list [expr $x - $private($visuNo,startx)] [expr $y - $private($visuNo,starty)] ] ]
         set coord [list [expr [lindex $coord 0] + [lindex $moveCoord 0]] [expr [lindex $coord 1] + [lindex $moveCoord 1] ] ]

         set coord [::confVisu::picture2Canvas $visuNo $::conf(autoguider,originCoord)]
         set moveCoord [::confVisu::screen2Canvas $visuNo [list [expr $x - $private($visuNo,startx)] [expr $y - $private($visuNo,starty)] ] ]
         set coord [list [expr [lindex $coord 0] + [lindex $moveCoord 0]] [expr [lindex $coord 1] + [lindex $moveCoord 1] ] ]

         set coord [::confVisu::canvas2Picture $visuNo $coord]
         setOrigin $visuNo $coord

         #--- je libere le mouvement manuel du widget
         set private($visuNo,currentMouseItem) ""
      }
      default {
         #--- la consigne n'est pas selectionnee, j'appelle le traitement par defaut
         ::confVisu::onReleaseButton1 $visuNo $x $y
         return
      }
   }
}

#------------------------------------------------------------
#  setMountEnabled
#     active ou descative l'envoi des commandes de guidage a la monture
#     si state = 1 , les commandes sont envoyees
#     si state = 0 , les commandes ne sont pas envoyees
#     si state = "" , l'envoi depend du checkbutton "montEnabled"
#
# @param visuNo       numero de la visu courante
# @param state       state = 1 envoie les commandes a la monture
#                    state = 0 n'envoie pas les commandes a la monture
# @return  null
#------------------------------------------------------------
proc ::autoguider::setMountEnabled { visuNo { state "" } } {
   variable private

   if { $state != "" } {
      set private($visuNo,mountEnabled) $state
   }

   #--- j'active l'envoi des commandes a la monture si c'est demande
   if { $private($visuNo,mountEnabled) == 1 } {
      #--- je configure la monture avec la vitesse la plus lente
      ::telescope::setSpeed 1
   }

   set private($visuNo,delay,alpha)      "0.00"
   set private($visuNo,delay,delta)      "0.00"
   #--- je notifie l'interperteur de la camera
   ::camera::setParam [::confVisu::getCamItem $visuNo] "mountEnabled" $private($visuNo,mountEnabled)
}

#------------------------------------------------------------
# selectBinning
#    change le binning de la camera
# @param visuNo       numero de la visu courante
# @param state       activation/desactivation de l'envoi des commandes a la monture
# @return  null
#------------------------------------------------------------
proc ::autoguider::selectBinning { visuNo } {
   variable private

   set camItem [::confVisu::getCamItem $visuNo]
   set camNo   [::confCam::getCamNo $camItem ]

   #--- je verifie si le driver de la camera a une fenetre pour gerer le binning et la longue pose
   if { [confCam::getPluginProperty $camItem longExposure] == "0" } {
      #--- j'affiche la fenetre de choix de binning de la webcam
      set result [ catch { cam$camNo videoformat } ]
      if { $result == "1" } {
         if { [ ::confVisu::getCamItem $visuNo ] == "" } {
            ::audace::menustate disabled
            set choix [ tk_messageBox -title $::caption(autoguider,pb) -type ok \
                  -message $caption(autoguider,selcam) ]
            if { $choix == "ok" } {
               #--- Ouverture de la fenetre de selection des cameras
               ::confCam::run
               tkwait window $audace(base).confCam
            }
            ::audace::menustate normal
         }
      }
   } else {
      set binning [list [string range $::conf(autoguider,binning) 0 0] [string range $::conf(autoguider,binning) 2 2]]
      cam$camNo bin $binning
   }

   #--- je position l'indicateur qui doit mettre a jour les axes
   #--- a la prochaine acquisition
   set private($visuNo,updateAxis) "1"
}

#------------------------------------------------------------
# setDarkSubstract
#    active la soustraction du dark
# @param visuNo       numero de la visu courante
# @return  null
#------------------------------------------------------------
proc ::autoguider::setDarkSubstract { visuNo } {
   variable private

   set catchResult [ catch {
      #--- je supprime le buffer s'il existait
      if { $private($visuNo,darkBufNo) != 0 } {
         buf::delete $private($visuNo,darkBufNo)
      }
      set private($visuNo,darkBufNo) 0

      #--- je charge le dark dans un nouveau buffer
      if { $::conf(autoguider,darkEnabled) == 1 } {
         if { $private($visuNo,darkBufNo) != 0 } {
            buf::delete $private($visuNo,darkBufNo)
         }
         set private($visuNo,darkBufNo) [buf::create]
         buf$private($visuNo,darkBufNo) load $::conf(autoguider,darkFileName)
      }
      #--- je notifie le thread de la camera
      ::camera::setParam [::confVisu::getCamItem $visuNo] "darkBufNo" $private($visuNo,darkBufNo)
   }]
   if { $catchResult != 0 } {
      #--- j'affiche le message d'erreur
      ::tkutil::displayErrorInfo $::caption(autoguider,titre)
      #--- je desactive la soustraction du dark
      set ::conf(autoguider,darkEnabled) 0
   }

}


