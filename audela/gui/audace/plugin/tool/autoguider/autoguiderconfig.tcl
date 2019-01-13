#
# Fichier : autoguiderconfig.tcl
# Description : Fenetre de configuration de l'autoguidage
# Auteur : Michel PUJOL
# Mise à jour $Id: autoguiderconfig.tcl 13000 2016-01-30 23:10:32Z robertdelmas $
#

################################################################
# namespace ::autoguider::config
#    fenetre de configuration de l'outil autoguider
################################################################

namespace eval ::autoguider::config {

}

#------------------------------------------------------------
# ::autoguider::config::run
#    affiche la fenetre de configuration de l'autoguidage
#
#------------------------------------------------------------
proc ::autoguider::config::run { visuNo } {
   variable private

   set private($visuNo,learnPendingStop) "2"
   set private($visuNo,learn,stepLabel)  ""
   set private($visuNo,fullImage)        0
   set private($visuNo,selectedPoint)    ""
   set private($visuNo,applyError)       0

   #--- j'affiche la fenetre de configuration
   set private($visuNo,This) ".autoguiderconfig$visuNo"
   ::confGenerique::run  $visuNo $private($visuNo,This) "::autoguider::config" \
      -modal 0 -resizable 1 -geometry $::conf(autoguider,configWindowPosition)
}

#------------------------------------------------------------
# ::autoguider::config::acq { }
#   fait une acquisition et affiche l'image
# return
#------------------------------------------------------------
proc ::autoguider::config::acq { visuNo } {
   variable private

   if { $private($visuNo,learnPendingStop) == 0 } {
      set camNo  [::confCam::getCamNo [::confVisu::getCamItem $visuNo] ]
      cam$camNo acq
      ::camera::waitStateStand $camNo
      ::confVisu::autovisu $visuNo
   }
}

#------------------------------------------------------------
# ::autoguider::config::cmdApply { }
#   copie les variables widget() dans le tableau conf()
#------------------------------------------------------------
proc ::autoguider::config::cmdApply { visuNo } {
   variable private
   variable widget
   global conf

   set pendingUpdateTarget 0
   set pendingUpdateAxis 0
   set private($visuNo,applyError)       0

   #--- je verifie s'il faut redessiner la cible si le mode de detection a change
   if {  $widget($visuNo,detection)       != $conf(autoguider,detection)
        || $widget($visuNo,slitWidth)     != $conf(autoguider,slitWidth)
        || $widget($visuNo,targetBoxSize) != $conf(autoguider,targetBoxSize) } {
      if { $::conf(autoguider,showTarget) } {
         set pendingUpdateTarget 1
      }
   }

   #--- je verifie s'il faut redessiner les axes si l'angle a change
   if {  $widget($visuNo,angle) != $conf(autoguider,angle) } {
      set pendingUpdateAxis 1
   }

   set conf(autoguider,learn,delay)       $widget($visuNo,learn,delay)

   set conf(autoguider,seuilx)            $widget($visuNo,seuilx)
   set conf(autoguider,seuily)            $widget($visuNo,seuily)
   set conf(autoguider,detection)         $widget($visuNo,detection)
   set conf(autoguider,alphaSpeed)        $widget($visuNo,alphaSpeed)
   set conf(autoguider,alphaReverse)      $widget($visuNo,alphaReverse)
   set conf(autoguider,deltaSpeed)        $widget($visuNo,deltaSpeed)
   set conf(autoguider,deltaReverse)      $widget($visuNo,deltaReverse)
   set conf(autoguider,angle)             $widget($visuNo,angle)
   set conf(autoguider,targetBoxSize)     $widget($visuNo,targetBoxSize)
   set conf(autoguider,detectionThreshold) $widget($visuNo,detectionThreshold)
   set conf(autoguider,cumulEnabled)      $widget($visuNo,cumulEnabled)
   set conf(autoguider,cumulNb)           $widget($visuNo,cumulNb)
   set conf(autoguider,slitWidth)         $widget($visuNo,slitWidth)
   set conf(autoguider,slitRatio)         $widget($visuNo,slitRatio)
   set conf(autoguider,declinaisonEnabled) $widget($visuNo,declinaisonEnabled)
   set conf(autoguider,darkEnabled)       $widget($visuNo,darkEnabled)
   set conf(autoguider,darkFileName)      [file normalize $widget($visuNo,darkFileName)]

   set conf(autoguider,searchThreshin)    $widget($visuNo,searchThreshin)
   set conf(autoguider,searchFwhm)        $widget($visuNo,searchFwhm)
   set conf(autoguider,searchRadius)      $widget($visuNo,searchRadius)
   set conf(autoguider,searchThreshold)    $widget($visuNo,searchThreshold)
   set conf(autoguider,centerSpeed)        $widget($visuNo,centerSpeed)

   #--- je notifie la thread de la camera
   ::camera::setParam [::confVisu::getCamItem $visuNo] "seuilx" $::conf(autoguider,seuilx)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "seuily" $::conf(autoguider,seuily)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "detection"   $::conf(autoguider,detection)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "alphaSpeed" $::conf(autoguider,alphaSpeed)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "deltaSpeed" $::conf(autoguider,deltaSpeed)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "alphaReverse" $::conf(autoguider,alphaReverse)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "deltaReverse" $::conf(autoguider,deltaReverse)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "angle" $::conf(autoguider,angle)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "targetBoxSize" $::conf(autoguider,targetBoxSize)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "detectionThreshold" $::conf(autoguider,detectionThreshold)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "slitWidth"   $::conf(autoguider,slitWidth)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "slitRatio"   $::conf(autoguider,slitRatio)

   ::camera::setParam [::confVisu::getCamItem $visuNo] "searchThreshin"   $::conf(autoguider,searchThreshin)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "searchFwhm"   $::conf(autoguider,searchFwhm)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "searchRadius"   $::conf(autoguider,searchRadius)
   ::camera::setParam [::confVisu::getCamItem $visuNo] "searchThreshold"   $::conf(autoguider,searchThreshold)

   #--- je redessine la cible si le mode de detection a change
   if { $pendingUpdateTarget } {
         ::autoguider::createTarget $visuNo
   }
   #--- je redessine les axes si l'angle a change
   if {  $pendingUpdateAxis } {
      autoguider::createAlphaDeltaAxis $visuNo $::conf(autoguider,originCoord) $::conf(autoguider,angle)
   }
   #--- je change le cumul des images
   if {  $widget($visuNo,cumulEnabled) != $conf(autoguider,cumulEnabled) } {
      set conf(autoguider,cumulEnabled) $widget($visuNo,cumulEnabled)
      ::autoguider::setCumul $visuNo $conf(autoguider,cumulEnabled)
   }

   #--- j'active ou desactive la soustraction du dark
   ::autoguider::setDarkSubstract $visuNo

   update

}

#------------------------------------------------------------
# ::autoguider::config::cmdClose
#   ferme la fenetre de configuration
#------------------------------------------------------------
proc ::autoguider::config::cmdClose { visuNo } {
   variable private
   global caption

   if { $private($visuNo,learnPendingStop) != 2 } {
      tk_messageBox -title [getLabel] -type ok -message "$caption(autoguider,running)" -icon warning
      return 0
   }
   if { $private($visuNo,applyError)== 1} {
      #--- je reinitilise pour la fermeture suivante
      set private($visuNo,applyError) 0
      return 0
   }

   set geometry [ wm geometry $private($visuNo,This) ]
   set deb [ expr 1 + [ string first + $geometry ] ]
   set fin [ string length $geometry ]
   set ::conf(autoguider,configWindowPosition) "+[ string range $geometry $deb $fin ]"

}

#------------------------------------------------------------
# ::autoguider::config::fillConfigPage { }
#   fenetre de configuration du panneau
#   return rien
#------------------------------------------------------------
proc ::autoguider::config::fillConfigPage { frm visuNo } {
   variable widget
   variable private
   global caption

   set private($visuNo,frm) $frm
   #--- j'initialise les variables des widgets
   #--- j'initialise les variables utilisees par le widgets
   set widget($visuNo,seuilx)            $::conf(autoguider,seuilx)
   set widget($visuNo,seuily)            $::conf(autoguider,seuily)
   set widget($visuNo,detection)         $::conf(autoguider,detection)
   set widget($visuNo,alphaSpeed)        $::conf(autoguider,alphaSpeed)
   set widget($visuNo,deltaSpeed)        $::conf(autoguider,deltaSpeed)
   set widget($visuNo,alphaReverse)      $::conf(autoguider,alphaReverse)
   set widget($visuNo,deltaSpeed)        $:::conf(autoguider,deltaSpeed)
   set widget($visuNo,deltaReverse)      $::conf(autoguider,deltaReverse)
   set widget($visuNo,learn,delay)       $::conf(autoguider,learn,delay)
   set widget($visuNo,angle)             $::conf(autoguider,angle)
   set widget($visuNo,declinaisonEnabled) $::conf(autoguider,declinaisonEnabled)
   set widget($visuNo,targetBoxSize)     $::conf(autoguider,targetBoxSize)
   set widget($visuNo,detectionThreshold) $::conf(autoguider,detectionThreshold)
   set widget($visuNo,cumulEnabled)      $::conf(autoguider,cumulEnabled)
   set widget($visuNo,cumulNb)           $::conf(autoguider,cumulNb)
   set widget($visuNo,slitWidth)         $::conf(autoguider,slitWidth)
   set widget($visuNo,slitRatio)         $::conf(autoguider,slitRatio)
   set widget($visuNo,searchThreshin)    $::conf(autoguider,searchThreshin)
   set widget($visuNo,searchFwhm)        $::conf(autoguider,searchFwhm)
   set widget($visuNo,searchRadius)      $::conf(autoguider,searchRadius)
   set widget($visuNo,searchThreshold)   $::conf(autoguider,searchThreshold)
   set widget($visuNo,centerSpeed)       $::conf(autoguider,centerSpeed)
   set widget($visuNo,darkEnabled)       $::conf(autoguider,darkEnabled)
   set widget($visuNo,darkFileName)      [file nativename $::conf(autoguider,darkFileName) ]

   #--- Frame detection etoile
   TitleFrame $frm.detection -borderwidth 2 -relief ridge -text "$caption(autoguider,detection)"
      radiobutton $frm.detection.psf -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text "$caption(autoguider,detection_psf)" -value "PSF" \
         -command "::autoguider::config::setDetection $visuNo" \
         -variable ::autoguider::config::widget($visuNo,detection)
      grid $frm.detection.psf -in [$frm.detection getframe]  -row 0 -column 0 -columnspan 1  -pady 4 -sticky ewns
      radiobutton $frm.detection.slit -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text "$caption(autoguider,detection_fente)" -value "SLIT" \
         -command "::autoguider::config::setDetection $visuNo" \
         -variable ::autoguider::config::widget($visuNo,detection)
      grid $frm.detection.slit -in [$frm.detection getframe]  -row 0 -column 1 -columnspan 1 -sticky ewns

      LabelEntry $frm.detection.targetBox -label "$caption(autoguider,targetBoxSize) (pixels)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -textvariable ::autoguider::config::widget($visuNo,targetBoxSize)
      grid $frm.detection.targetBox -in [$frm.detection getframe] -row 1 -column 0 -columnspan 2 -sticky ewns
      LabelEntry $frm.detection.detectionThreshold -label "$caption(autoguider,detectionThreshold) (pixels)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -validate all -validatecommand { ::autoguider::config::validateNumber %W %V %P %s 1 999} \
         -textvariable ::autoguider::config::widget($visuNo,detectionThreshold)
      grid $frm.detection.detectionThreshold -in [$frm.detection getframe] -row 2 -column 0 -columnspan 2 -sticky ewns
      LabelEntry $frm.detection.slitWidth -label "$caption(autoguider,slitWidth)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -validate all -validatecommand { ::autoguider::config::validateNumber %W %V %P %s 1 999} \
         -textvariable ::autoguider::config::widget($visuNo,slitWidth)
      grid $frm.detection.slitWidth -in [$frm.detection getframe] -row 3 -column 0 -columnspan 2 -sticky ewns
      LabelEntry $frm.detection.slitRatio -label "$caption(autoguider,slitRatio)" \
         -labeljustify left -labelwidth 22 -width 5 -justify right \
         -validate all -validatecommand { ::autoguider::config::validateNumber %W %V %P %s 1 9999} \
         -textvariable ::autoguider::config::widget($visuNo,slitRatio)
      grid $frm.detection.slitRatio -in [$frm.detection getframe] -row 4 -column 0 -columnspan 2 -sticky ewns
   grid $frm.detection -row 0 -column 0 -columnspan 1 -sticky ewns

   #--- Frame apprentissage
   TitleFrame $frm.apprenti -borderwidth 2 -relief ridge -text "$caption(autoguider,apprenti)"
      Button $frm.apprenti.go -text "$caption(autoguider,go)" -width 10 -command "::autoguider::config::startLearn $visuNo"
      pack $frm.apprenti.go -in [$frm.apprenti getframe] -side top -fill none -expand 0
      LabelEntry $frm.apprenti.delay -label "$caption(autoguider,delay)" \
         -labeljustify left -labelwidth 14 -width 5 -justify right \
         -validate all -validatecommand { ::autoguider::config::validateNumber %W %V %P %s 1 999} \
         -textvariable ::autoguider::config::widget($visuNo,learn,delay)
      pack $frm.apprenti.delay -in [$frm.apprenti getframe] -anchor w -side top -fill x -expand 1
      Label $frm.apprenti.step -justify right -relief groove \
         -textvariable ::autoguider::config::private($visuNo,learn,stepLabel)
      pack $frm.apprenti.step -in [$frm.apprenti getframe] -anchor w -side top -fill x -expand 1
   grid $frm.apprenti -row 0 -column 1 -columnspan 1 -sticky ewns

   #--- Frame ascension droite
   TitleFrame $frm.alpha -borderwidth 2 -relief ridge -text "$caption(autoguider,AD)"
      LabelEntry $frm.alpha.gainprop -label "$caption(autoguider,vitesse)" \
         -labeljustify left -labelwidth 16 -width 5 -justify right \
         -textvariable ::autoguider::config::widget($visuNo,alphaSpeed)
      pack $frm.alpha.gainprop -in [$frm.alpha getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.alpha.seuil -label "$caption(autoguider,seuil)" \
         -labeljustify left -labelwidth 16 -width 5 -justify right \
         -validate all -validatecommand { ::autoguider::config::validateNumber %W %V %P %s 0 99} \
         -textvariable ::autoguider::config::widget($visuNo,seuilx)
      pack $frm.alpha.seuil -in [$frm.alpha getframe] -anchor w -side top -fill x -expand 0
      checkbutton $frm.alpha.reverse -text "$caption(autoguider,alphaReverse)" \
         -variable ::autoguider::config::widget($visuNo,alphaReverse)
      pack $frm.alpha.reverse -in [$frm.alpha getframe] -anchor w -side top -fill x -expand 0
   grid $frm.alpha -row 1 -column 0 -columnspan 1 -rowspan 2 -sticky ewns

   #--- Frame declinaison
   TitleFrame $frm.delta -borderwidth 2 -text "$caption(autoguider,declinaison)"
      LabelEntry $frm.delta.gainprop -label "$caption(autoguider,vitesse)" \
         -labeljustify left -labelwidth 16 -width 5 -justify right \
         -textvariable ::autoguider::config::widget($visuNo,deltaSpeed)
##         -validate all -validatecommand { ::autoguider::config::validateNumber %W %V %P %s -9999 9999}

      pack $frm.delta.gainprop -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.delta.seuil -label "$caption(autoguider,seuil)" \
         -labeljustify left -labelwidth 16 -width 5 -justify right \
         -validate all -validatecommand { ::autoguider::config::validateNumber %W %V %P %s 0 99} \
         -textvariable ::autoguider::config::widget($visuNo,seuily)
      pack $frm.delta.seuil -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0
      checkbutton $frm.delta.reverse -text "$caption(autoguider,deltaReverse)" \
         -variable ::autoguider::config::widget($visuNo,deltaReverse)
      pack $frm.delta.reverse -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0
      checkbutton $frm.delta.enabledec -text "$caption(autoguider,declinaison)" \
         -variable ::autoguider::config::widget($visuNo,declinaisonEnabled) \
         -command "::autoguider::config::setDeclinaison $visuNo"
      pack $frm.delta.enabledec -in [$frm.delta getframe] -anchor w -pady 2 -side top -fill x -expand 0
   grid $frm.delta -row 1 -column 1 -columnspan 1 -rowspan 2 -sticky ewns

   #--- Frame inclinaison
   TitleFrame $frm.orientation -borderwidth 2 -text "$caption(autoguider,inclinaison)"
      LabelEntry $frm.orientation.angle -label "$caption(autoguider,angle)" \
         -labeljustify left -labelwidth 14 -width 5 -justify right \
         -validate all -validatecommand { ::autoguider::config::validateNumber %W %V %P %s -360 360} \
         -textvariable ::autoguider::config::widget($visuNo,angle)
      pack $frm.orientation.angle -in [$frm.orientation getframe] -anchor w -side top -fill x -expand 0
   grid $frm.orientation -row 3 -column 0 -columnspan 1 -sticky ewns

   #--- Frame telescope
   TitleFrame $frm.telescope -borderwidth 2 -text "$caption(autoguider,telescope)"
      label $frm.telescope.speedLabel -text "$caption(autoguider,centerSpeed)"
      pack $frm.telescope.speedLabel -in [$frm.telescope getframe] -anchor w -side left -fill x -expand 0
      set speedList [::telescope::getSpeedValueList]
      ComboBox $frm.telescope.speedList -relief sunken -borderwidth 1 -editable 0 \
         -height [llength $speedList] \
         -width [ ::tkutil::lgEntryComboBox $speedList ] \
         -textvariable ::autoguider::config::widget($visuNo,centerSpeed) \
         -values $speedList
      pack $frm.telescope.speedList -in [$frm.telescope getframe] -anchor w -side left -fill x -expand 0
   grid $frm.telescope -row 4 -column 0 -columnspan 1 -sticky ewns

   #--- Frame Cumul
   TitleFrame $frm.cumul -borderwidth 2 -text "$caption(autoguider,cumulTitle)"
      LabelEntry $frm.cumul.nb -label "$caption(autoguider,cumulNb)" \
         -labeljustify left -labelwidth 18 -width 5 -justify right \
         -validate all -validatecommand { ::autoguider::config::validateNumber %W %V %P %s 0 100} \
         -textvariable ::autoguider::config::widget($visuNo,cumulNb)
      pack $frm.cumul.nb -in [$frm.cumul getframe] -anchor w -side top -fill x -expand 0
      checkbutton $frm.cumul.cumulEnabled -text "$caption(autoguider,cumulEnabled)" \
         -command "::autoguider::config::setCumul $visuNo" \
         -variable ::autoguider::config::widget($visuNo,cumulEnabled)
      pack $frm.cumul.cumulEnabled -in [$frm.cumul getframe] -anchor w -pady 2 -side top -fill x -expand 0
   grid $frm.cumul -row 3 -column 1 -columnspan 1 -rowspan 2 -sticky ewns

   #--- Frame dark
   TitleFrame $frm.dark -borderwidth 2 -text "$caption(autoguider,darkTitle)"
      checkbutton $frm.dark.darkEnabled -text $::caption(autoguider,darkEnabled) \
         -variable ::autoguider::config::widget($visuNo,darkEnabled)
      grid $frm.dark.darkEnabled -in [$frm.dark getframe]  -row 0 -column 0 -columnspan 1  -pady 1 -sticky w
      Entry $frm.dark.fileName -justify right \
        -textvariable ::autoguider::config::widget($visuNo,darkFileName)
      grid $frm.dark.fileName -in [$frm.dark getframe] -row 1 -column 0 -columnspan 1  -pady 1 -sticky ew
      #--- Bouton '...'
      button $frm.dark.select -text "..." \
         -borderwidth 2 -command "::autoguider::config::selectDarkFile $visuNo"
      grid $frm.dark.select -in [$frm.dark getframe] -row 1 -column 1 -columnspan 1  -pady 1 -sticky w

      grid columnconfigure [ $frm.dark getframe ] 0 -weight 1

   grid $frm.dark -row 5 -column 1 -columnspan 1 -rowspan 1 -sticky ewns

   #--- Frame search
   TitleFrame $frm.search -borderwidth 2 -text "$caption(autoguider,searchTitle)"
      LabelEntry $frm.search.threshin -label "$caption(autoguider,searchThreshin)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -textvariable ::autoguider::config::widget($visuNo,searchThreshin)
      pack $frm.search.threshin -in [$frm.search getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.search.fwhm -label "$caption(autoguider,searchFwhm)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -textvariable ::autoguider::config::widget($visuNo,searchFwhm)
      pack $frm.search.fwhm -in [$frm.search getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.search.radius -label "$caption(autoguider,searchRadius)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -textvariable ::autoguider::config::widget($visuNo,searchRadius)
      pack $frm.search.radius -in [$frm.search getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.search.threshold -label "$caption(autoguider,searchThreshold)" \
         -labeljustify left -labelwidth 22 -width 3 -justify right \
         -textvariable ::autoguider::config::widget($visuNo,searchThreshold)
      pack $frm.search.threshold -in [$frm.search getframe] -anchor w -side top -fill x -expand 0
   grid $frm.search -row 5 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

   grid columnconfigure  $frm 0 -weight 1
   grid columnconfigure  $frm 1 -weight 1

   ::autoguider::config::setCumul $visuNo
   ::autoguider::config::setDeclinaison $visuNo
   ::autoguider::config::setDetection $visuNo

   pack $frm  -side top -fill x
}

#------------------------------------------------------------
# ::autoguider::config::getLabel
#   retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::autoguider::config::getLabel { } {
   global caption

   return "$caption(autoguider,titre) $caption(autoguider,config_guidage)"
}

#------------------------------------------------------------
# ::autoguider::config::markStarPosition { }
#   marque la position de l'etoile
# return
#    retourne une liste contenant les coordonnes de l'etoile ( referentiel buffer)
#------------------------------------------------------------
proc ::autoguider::config::markPosition { visuNo step} {
   variable private
   variable widget
   global caption

   set bufNo [::confVisu::getBufNo $visuNo ]
   if  { $private($visuNo,fullImage) == 1 } {
      set box [list 10 10 [expr [buf$bufNo getpixelswidth] -10] [expr [buf$bufNo getpixelsheight] -10] ]
      set starCoords [lrange [buf$bufNo centro $box ] 0 1]
   } else {
      #--- j'affiche le message invitant a cliquer sur l'etoile
      displayLearnMessage $visuNo "$caption(autoguider,clic_etoile) $step"
      #--- j'attends que l'etoile soit selectionnee avec la souris
      vwait ::autoguider::config::private($visuNo,selectedPoint)
      #--- je convertis les coordonnees du referentiel ecran en coordonnes referentiel canvas
      set coord [::confVisu::screen2Canvas $visuNo $private($visuNo,selectedPoint) ]
      #--- je convertis les coordonnees du referentiel canvas en coordonnes referentiel image
      set coord [::confVisu::canvas2Picture $visuNo $coord]
      set size 16
      set x  [lindex $coord 0]
      set y  [lindex $coord 1]
      set x1 [expr $x - $size]
      set x2 [expr $x + $size]
      set y1 [expr $y - $size]
      set y2 [expr $y + $size]
      set zone1 [list $x1 $y1 $x2 $y2 ]
      #--- je recupere les coordonnees de l'etoile la plus brillante dans la zone
      set starCoords [lrange [buf$bufNo centro $zone1 ] 0 1]
   }

   #--- je dessine un rectangle autour de l'etoile
   set size 8
   set x  [lindex $starCoords 0]
   set y  [lindex $starCoords 1]
   set x1 [expr $x - $size]
   set x2 [expr $x + $size]
   set y1 [expr $y - $size]
   set y2 [expr $y + $size]
   #--- je convertis les coordonnees "buffer" en coordonnees "canvas"
   set coord1 [::confVisu::picture2Canvas $visuNo [list $x1 $y1]]
   set coord2 [::confVisu::picture2Canvas $visuNo [list $x2 $y2]]
   #--- je dessine le rectangle
   [::confVisu::getCanvas $visuNo] create rect [lindex $coord1 0] [lindex $coord1 1] [lindex $coord2 0] [lindex $coord2 1] -outline red -offset center -tag learnrect

   return $starCoords
}

#------------------------------------------------------------
# ::autoguider::config::moveTelescope { }
#
#------------------------------------------------------------
proc ::autoguider::config::moveTelescope { visuNo direction label} {
   variable private
   variable widget
   global caption

   #--- je demarre le deplacement
   ::telescope::move $direction

   #--- j'attend l'expiration du delai par tranche de 1 seconde
   set delay [expr int( $widget($visuNo,learn,delay) * 1000)]
   while { $delay  > 0 } {
      displayLearnMessage $visuNo "$caption(autoguider,aller_vers) $label ($delay)"
      if { $private($visuNo,learnPendingStop) == 0 } {
         if { $delay > 1000 } {
            after 999
            set delay [expr $delay - 1000 ]
         } else {
            after $delay
            set delay 0
         }
      } else {
         #--- j'interromp l'attente s'il y a une demande d'arret
         set delay 0
      }
      #--- laisse la main pour traiter une eventuelle demande d'arret
      update
   }

   #--- j'arrete le deplacement
   ::telescope::stop $direction
}

#------------------------------------------------------------
# selectDarkFile
#    Ouvre la fentre de selection d'un fichier dark
#------------------------------------------------------------
proc ::autoguider::config::selectDarkFile { visuNo } {
   variable private
   variable widget

   #--- je recupere le repertoire initial
   if { $widget($visuNo,darkFileName) == "" } {
      set  initialDirectory $::audace(rep_images)
   } else {
      set  initialDirectory [file dir $widget($visuNo,darkFileName) ]
      if { [file exists $initialDirectory ] == 0 } {
         set initialDirectory $::audace(rep_images)
      }
   }
   #--- Ouvre la fenetre de choix des images
   set widget($visuNo,darkFileName) [file native [::tkutil::box_load $private($visuNo,frm) $initialDirectory $::audace(bufNo) "1"]]
   #--- j'affiche la fin du nom
   $private($visuNo,frm).dark.fileName xview end

}

#------------------------------------------------------------
# ::autoguider::config::selectStar
#   enregistre les coordonnees de l'etoile selectionnee avec la souris
#   dans private(visuNo,selectedPoint)
# parameters :
#   visuNo : numero de la visu courante
#   x y    : coordonnees du pointeur de la souris (coordonnes ecran)
# return
#   rien
#------------------------------------------------------------
proc ::autoguider::config::selectStar { visuNo x y  } {
   variable private

   set private($visuNo,selectedPoint) [list $x $y]
}

#------------------------------------------------------------
# ::autoguider::config::setCumul
#    active/desactive le widget de saisie du nombre de d'acquisitions
#
#------------------------------------------------------------
proc ::autoguider::config::setCumul { visuNo } {
   variable private
   variable widget

   if { $widget($visuNo,cumulEnabled) == 1 } {
      $private($visuNo,frm).cumul.nb configure -state normal
   } else {
      $private($visuNo,frm).cumul.nb configure -state disabled
   }
}

#------------------------------------------------------------
# ::autoguider::config::setDeclinaison
#    active/desactive la saisie des parametres de la declinaison
#------------------------------------------------------------
proc ::autoguider::config::setDeclinaison { visuNo } {
   variable widget
   variable private

   if { $widget($visuNo,declinaisonEnabled) == 1 } {
      $private($visuNo,frm).delta.gainprop configure -state normal
      $private($visuNo,frm).delta.seuil configure -state normal
      $private($visuNo,frm).delta.reverse configure -state normal
   } else {
      $private($visuNo,frm).delta.gainprop configure -state disabled
      $private($visuNo,frm).delta.seuil configure -state disabled
      $private($visuNo,frm).delta.reverse configure -state disabled
   }
}

#------------------------------------------------------------
# ::autoguider::config::setDetection
#    active/desactive le widget de saisie de la largeur la fente si la detection
#------------------------------------------------------------
proc ::autoguider::config::setDetection { visuNo } {
   variable private
   variable widget

   if { $widget($visuNo,detection) != "SLIT" } {
      $private($visuNo,frm).detection.slitWidth configure -state disabled
      $private($visuNo,frm).detection.slitRatio configure -state disabled
   } else {
      $private($visuNo,frm).detection.slitWidth configure -state normal
      $private($visuNo,frm).detection.slitRatio configure -state normal
   }
}

#------------------------------------------------------------
# ::autoguider::config::showHelp
#   affiche l'aide de cet outil
#------------------------------------------------------------
proc ::autoguider::config::showHelp { } {
   ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::autoguider::getPluginType]] \
      [::autoguider::getPluginDirectory] [::autoguider::getPluginHelp] "configure"
}

#------------------------------------------------------------
# ::autoguider::config::startLearn { }
#   Execute l'apprentissage.  A tout moment l'apprentissage est arrete
#   si private($visuNo,learnPendingStop) n'est pas nul
#
#   return rien
#------------------------------------------------------------
proc ::autoguider::config::startLearn { visuNo } {
   variable private
   variable widget

   #--- Petits raccourcis bien pratiques
   set camNo [::confCam::getCamNo [::confVisu::getCamItem $visuNo] ]

   #--- je verifie la presence la camera
   if { $camNo == 0 } {
      ::confCam::run
      return
   }

   #--- je verifie la presence du telescope
   if { [ ::tel::list ] == "" } {
      ::confTel::run
      return
   }

   #--- j'arrete les acquisitions si elles sont en cours
   ::autoguider::stopAcquisition $visuNo

   #--- je supprime les axes alpha et delta
   ::autoguider::deleteAlphaDeltaAxis $visuNo

   #--- je supprime la cible
   ::autoguider::deleteTarget $visuNo

   #--- je remets a zero l'indicateur de fin d'apprentissage
   set private($visuNo,learnPendingStop) 0

   #--- j'associe le bouton droit a la selection de l'etoile
   set private($visuNo,previousRightButtonBind) [ bind [::confVisu::getCanvas $visuNo] <ButtonPress-3> ]
   bind [::confVisu::getCanvas $visuNo] <ButtonPress-3> "::autoguider::config::selectStar $visuNo %x %y"

   #--- je configure le bouton STOP
   $private($visuNo,frm).apprenti.go configure -text "$::caption(autoguider,stop)" \
      -command "::autoguider::config::stopLearn $visuNo"
   update

   #--- je configure la camera
   cam$camNo exptime $::conf(autoguider,pose)
   cam$camNo bin [list [string range $::conf(autoguider,binning) 0 0] [string range $::conf(autoguider,binning) 2 2]]
   cam$camNo radecfromtel 0

   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je marque le point depart
      set step "center"
      set private($visuNo,learn,coords,$step) [markPosition $visuNo $step]
      set widget($visuNo,originCoord) $private($visuNo,learn,coords,$step)
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je deplace le telescope vers l'est
      set step "est"
      moveTelescope $visuNo e $step
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je marque le point
      set private($visuNo,learn,coords,$step) [markPosition $visuNo $step]
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je deplace le telescope vers l'ouest
      moveTelescope $visuNo w "center"
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je deplace le telescope vers l'ouest
      set step "west"
      moveTelescope $visuNo w $step
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je marque le point
      set private($visuNo,learn,coords,$step) [markPosition $visuNo $step]
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je deplace le telescope vers le point de depart
      moveTelescope $visuNo e "center"
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je deplace le telescope vers le sud
      set step "south"
      moveTelescope $visuNo s $step
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je marque le point
      set private($visuNo,learn,coords,$step) [markPosition $visuNo $step]
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je deplace le telescope vers le point de depart
      moveTelescope $visuNo n "center"
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je deplace le telescope vers le nord
      set step "north"
      moveTelescope $visuNo n $step
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je marque le point
      set private($visuNo,learn,coords,$step) [markPosition $visuNo $step]
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je deplace le telescope vers le point de depart
      moveTelescope $visuNo s "center"
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {
      #--- je calcule la vitesse de deplacement sur l'axe alpha (en milliseconde/pixel)
      set dxAlpha [expr  [lindex $private($visuNo,learn,coords,west) 0] - [lindex $private($visuNo,learn,coords,est) 0]]
      set dyAlpha [expr  [lindex $private($visuNo,learn,coords,west) 1] - [lindex $private($visuNo,learn,coords,est) 1]]
      set dAlpha [expr sqrt($dxAlpha*$dxAlpha + $dyAlpha*$dyAlpha) ]
      set penteAlpha [expr $dyAlpha / $dxAlpha ]
      #set widget($visuNo,alphaSpeed) [expr $dAlpha / $widget($visuNo,learn,delay) / 2 ]
      set widget($visuNo,alphaSpeed) [expr 1000.0 * 2.0 *$widget($visuNo,learn,delay) / $dAlpha ]
      set widget($visuNo,alphaSpeed) [format "%0.1f" $widget($visuNo,alphaSpeed)]

      #--- je calcule la vitesse de deplacement sur l'axe delta
      set dxDelta [expr  [lindex $private($visuNo,learn,coords,north) 0] - [lindex $private($visuNo,learn,coords,south) 0]]
      set dyDelta [expr  [lindex $private($visuNo,learn,coords,north) 1] - [lindex $private($visuNo,learn,coords,south) 1]]
      set dDelta [expr sqrt($dxDelta*$dxDelta + $dyDelta*$dyDelta) ]
      set penteDelta [expr $dyDelta / $dxDelta ]
      #set widget($visuNo,deltaSpeed) [expr $dDelta / $widget($visuNo,learn,delay) / 2 ]
      set widget($visuNo,deltaSpeed) [expr 1000.0 * 2.0 * $widget($visuNo,learn,delay) / $dDelta ]
      set widget($visuNo,deltaSpeed) [format "%0.1f" $widget($visuNo,deltaSpeed)]

      #--- je calcule l'angle d'inclinaison de la camera
      set angleAlpha [expr 180*atan($penteAlpha)/3.14159265359 ]
      if { ($dxAlpha>0 && $dyAlpha<0) || ($dxAlpha>0 && $dyAlpha>0) } {
         set angleAlpha2 [expr fmod($angleAlpha+180, 360)]
      } else {
         set angleAlpha2 $angleAlpha
      }
      if { $angleAlpha2 < 0 } {
         set angleAlpha2  [expr $angleAlpha2+360 ]
      }
      set angleDelta [expr 180*atan($penteDelta)/3.14159265359 ]
      if { ($dxDelta<0 && $dyDelta>0) || ($dxDelta<0 && $dyDelta<0) } {
         set angleDelta2 [expr fmod($angleDelta +90 +180, 360) ]
      } else {
         set angleDelta2 [expr fmod($angleDelta +90, 360) ]
      }
      if { $angleDelta2 < 0 } {
         set angleDelta2  [expr $angleDelta2+360 ]
      }
      #--- je calcule la moyenne des 2 angles
      set widget($visuNo,angle) [expr ($angleAlpha2 + $angleDelta2)/2]
      set widget($visuNo,angle) [format "%0.1f" $widget($visuNo,angle)]
      ###console::disp "angleAlpha=$angleAlpha angleDelta=$angleDelta angleDelta2=$angleDelta2 angle=$widget($visuNo,angle)\n"
      #--- j'affiche les axes alpha et delta temporaires
      ::autoguider::createAlphaDeltaAxis $visuNo $widget($visuNo,originCoord) $widget($visuNo,angle)
   }

   #--- j'efface tous les rectangles d'apprentissage
   [::confVisu::getCanvas $visuNo] delete learnrect
   #--- je supprime les variables contenant les coordonnees
   foreach {key value} [array get private $visuNo,learn,rect,* ] {
      unset private($key)
   }

   #--- j'efface le dernier message
   displayLearnMessage $visuNo ""

   #--- je restaure le bind du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3>  $private($visuNo,previousRightButtonBind)

   #--- j'affiche le bouton GO
   $private($visuNo,frm).apprenti.go configure -text "$::caption(autoguider,GO)" \
      -command "::autoguider::config::startLearn $visuNo"

   #-- fin de l'arret de l'apprentissage
   set private($visuNo,learnPendingStop) 2
}

#------------------------------------------------------------
# ::autoguider::config::stopLearn { }
#   demande l'arret de l'apprentissage
# return
#
#------------------------------------------------------------
proc ::autoguider::config::stopLearn { visuNo } {
   variable private

   #--- je demande l'arret de l'apprentissage
   set private($visuNo,learnPendingStop) 1

   #--- je debloque l'attente sur selectStar au cas ou on serait en attente
   set private($visuNo,selectedPoint) [list 1 1]
   update
}

#------------------------------------------------------------
# ::autoguider::config::displayLearnMessage { }
#   affiche un message d'invite pour selectionner une etoile
# return
#   rien
#------------------------------------------------------------
proc ::autoguider::config::displayLearnMessage { visuNo message} {
   variable private

   set private($visuNo,learn,stepLabel) $message
   update
}

proc ::autoguider::config::validateNumber { win event X oldX  min max} {
   global audace
   # Make sure min<=max
   if {$min > $max} {
      set tmp $min; set min $max; set max $tmp
   }
   # Allow valid integers, empty strings, sign without number
   # Reject Octal numbers, but allow a single "0"
   # Which signes are allowed ?
   if {($min <= 0) && ($max >= 0)} {   ;# positive & negative sign
      set pattern {^[+-]?(()|0|([1-9\.][0-9\.]*))$}
   } elseif {$max < 0} {               ;# negative sign
      set pattern {^[-]?(()|0|([1-9\.][0-9\.]*))$}
   } else {                            ;# positive sign
      set pattern {^[+]?(()|0|([1-9\.][0-9\.]*))$}
   }
   # Weak integer checking: allow empty string, empty sign, reject octals
   set weakCheck [regexp $pattern $X]
   # if weak check fails, continue with old value
   if {! $weakCheck} {set X $oldX}
   # Strong integer checking with range
   set strongCheck [expr {[string is double  $X] && ($X >= $min) && ($X <= $max)}]

   switch $event {
      key {
         if { $strongCheck == 0 } {
            $win configure -bg $audace(color,entryTextColor) -fg $audace(color,entryBackColor)
         } else {
            $win configure -bg $audace(color,entryBackColor) -fg $audace(color,entryTextColor)
         }
         return $weakCheck
      }
      focusout {
         if { $strongCheck == 0} {
            $win configure -bg $audace(color,entryTextColor) -fg $audace(color,entryBackColor)
         } else {
            $win configure -bg $audace(color,entryBackColor) -fg $audace(color,entryTextColor)
         }
         return $strongCheck
      }
      default {
          return 1
      }
   }
}

