#
## @file     sophieconfig.tcl
#  @brief    Fichier du namespace ::sophie::config
#  @author   Michel PUJOL et Robert DELMAS
#  $Id: sophieconfig.tcl 13349 2016-03-11 14:45:52Z rzachantke $
#

## namespace sophie::config
#  @brief   configuration de l'outil sophie

namespace eval ::sophie::config {

}

#------------------------------------------------------------
# run
#    affiche la fenêtre de configuration
#------------------------------------------------------------
proc ::sophie::config::run { visuNo tkbase  } {
   variable private

   #--- Initialisation de variables
   set private(frm) "$::audace(base).sophieconfig"

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(sophie,configWindowPosition) ] } { set ::conf(sophie,configWindowPosition) "430x540+565+160" }

   #--- j'affiche la fenetre
   ::confGenerique::run $visuNo $private(frm) "::sophie::config" -modal 0 -geometry $::conf(sophie,configWindowPosition) -resizable 1

   #--- je deplace la consigne a la position du mode courant de la fibre
   ###onFiberMode $visuNo
}

#------------------------------------------------------------
# cmdClose
#   ferme la fenetre
#------------------------------------------------------------
proc ::sophie::config::cmdClose { visuNo } {
   variable private

   #--- je memorise la position courante de la fenetre
   set ::conf(sophie,configWindowPosition) [ winfo geometry [ winfo toplevel $private(frm) ] ]
}

#------------------------------------------------------------
# showHelp
#   affiche l'aide de cet outil
#------------------------------------------------------------
proc ::sophie::config::showHelp { } {
   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory \
      [ ::sophie::getPluginType ] ] [ ::sophie::getPluginDirectory ] [ ::sophie::getPluginHelp ]
}

#------------------------------------------------------------
# getLabel
#   retourne le nom de la fenetre de traitement
#------------------------------------------------------------
proc ::sophie::config::getLabel { } {
   return "$::caption(sophie,titre) - $::caption(sophie,config)"
}

#------------------------------------------------------------
# fillConfigPage
#   cree les widgets de la fenetre de configuration du traitement
#   return rien
#------------------------------------------------------------
proc ::sophie::config::fillConfigPage { frm visuNo } {
   variable private
   variable widget

   set private(frm) $frm

   #--- Je positionne la fenetre
   wm geometry [ winfo toplevel $frm ] $::conf(sophie,configWindowPosition)

   #--- j'initalise les variables des widgets
  ### set widget(poseDefaut)               $::conf(sophie,exposure)
   set widget(binCentrageDefaut)        $::conf(sophie,centerBinning)
   set widget(binFocalisationDefaut)    $::conf(sophie,focuseBinning)
   set widget(binGuidageDefaut)         $::conf(sophie,guideBinning)
   set widget(echelle)                  $::conf(sophie,pixelScale)
   set widget(tailleFenetreGuidage)     $::conf(sophie,guidingWindowSize)
   set widget(tailleFenetreCentrage)    $::conf(sophie,centerWindowSize)
   set widget(alphaProportionalGain)    [expr $::conf(sophie,alphaProportionalGain) * 100.0]
   set widget(deltaProportionalGain)    [expr $::conf(sophie,deltaProportionalGain) * 100.0]
   set widget(alphaIntegralGain)        [expr $::conf(sophie,alphaIntegralGain) * 100.0]
   set widget(deltaIntegralGain)        [expr $::conf(sophie,deltaIntegralGain) * 100.0]
   set widget(alphaDerivativeGain)      [expr $::conf(sophie,alphaDerivativeGain) * 100.0]
   set widget(deltaDerivativeGain)      [expr $::conf(sophie,deltaDerivativeGain) * 100.0]
   set widget(minMaxDiff)               $::conf(sophie,minMaxDiff)

   set widget(prefixeImageCentrage)     $::conf(sophie,centerFileNameprefix)
   set widget(prefixeImageFocalisation) $::conf(sophie,focusFileNameprefix)
   set widget(prefixeImageGuidage)      $::conf(sophie,guidingFileNameprefix)

  ### set widget(fiberGuigindMode)         $::conf(sophie,fiberGuigindMode)
   set widget(fiberHRX)                 $::conf(sophie,fiberHRX)
   set widget(fiberHRY)                 $::conf(sophie,fiberHRY)
   set widget(fiberHEX)                 $::conf(sophie,fiberHEX)
   set widget(fiberHEY)                 $::conf(sophie,fiberHEY)
   set widget(fiberBX)                  $::conf(sophie,fiberBX)
   set widget(fiberBY)                  $::conf(sophie,fiberBY)
   set widget(angle)                    $::conf(sophie,angle)

   set widget(biasFileName,1,slow)      $::conf(sophie,biasFileName,1,slow)
   set widget(biasFileName,1,fast)      $::conf(sophie,biasFileName,1,fast)
   set widget(biasFileName,2,slow)      $::conf(sophie,biasFileName,2,slow)
   set widget(biasFileName,2,fast)      $::conf(sophie,biasFileName,2,fast)
   set widget(biasFileName,3,slow)      $::conf(sophie,biasFileName,3,slow)
   set widget(biasFileName,3,fast)      $::conf(sophie,biasFileName,3,fast)

   set widget(maskRadius)               $::conf(sophie,maskRadius)
   set widget(maskFwhm)                 $::conf(sophie,maskFwhm)
   set widget(maskPercent)              [expr int( $::conf(sophie,maskPercent) * 100)]
   set widget(pixelMinCount)            $::conf(sophie,pixelMinCount)

   #--- Creation des onglets
   set notebook [ NoteBook $frm.notebook ]
      $notebook insert end "configStandard" -text $::caption(sophie,configStandard)
      $notebook insert end "configAvancee"  -text $::caption(sophie,configAvancee)
   pack $frm.notebook -side top -fill both -expand 1

   #--- j'affiche les wigdets dans les onglets
   fillConfigStandardPage [ $notebook getframe "configStandard" ] 1
   fillConfigAvanceePage  [ $notebook getframe "configAvancee" ] 1

   pack $frm -side top -fill x -expand 1

   #--- je selectionne le premier onglet
   $notebook raise "configStandard"
}

#------------------------------------------------------------
# fillConfigStandardPage
#   cree les widgets dans l'onglet configuration standard
#   return rien
#------------------------------------------------------------
proc ::sophie::config::fillConfigStandardPage { frm visuNo } {
   variable private

   #--- Frame pour la configuration des binnings de centrage et de guidage
   TitleFrame $frm.acq -borderwidth 2 -relief ridge -text $::caption(sophie,binnings)

      #--- Binning par defaut du mode centrage
      label $frm.acq.labelbincentrage -text $::caption(sophie,binningCentrage) -justify left
      grid $frm.acq.labelbincentrage -in [ $frm.acq getframe ] -row 1 -column 0 -sticky w

      ComboBox $frm.acq.valeurbincentrage \
         -width [ ::tkutil::lgEntryComboBox $::sophie::private(listeBinning) ] \
         -height [ llength $::sophie::private(listeBinning) ] \
         -justify center            \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::sophie::config::widget(binCentrageDefaut) \
         -editable 0                \
         -values $::sophie::private(listeBinning)
      grid $frm.acq.valeurbincentrage -in [ $frm.acq getframe ] -row 1 -column 1 -sticky ens

      #--- Binning par defaut du mode guidage
      label $frm.acq.labelbinguidage -text $::caption(sophie,binningGuidage) -justify left
      grid $frm.acq.labelbinguidage -in [ $frm.acq getframe ] -row 3 -column 0 -sticky w

      ComboBox $frm.acq.valeurbinguidage \
         -width [ ::tkutil::lgEntryComboBox $::sophie::private(listeBinning) ] \
         -height [ llength $::sophie::private(listeBinning) ] \
         -justify center            \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::sophie::config::widget(binGuidageDefaut) \
         -editable 0                \
         -values $::sophie::private(listeBinning)
      grid $frm.acq.valeurbinguidage -in [ $frm.acq getframe ] -row 3 -column 1 -sticky ens

   pack $frm.acq -side top -anchor w -fill x -expand 0

   #--- Frame pour la configuration du guidage
   TitleFrame $frm.guidage -borderwidth 2 -relief ridge -text $::caption(sophie,gainsGuidage)

      #--- Gain proportionnel
      label $frm.guidage.labelGainAlpha -text $::caption(sophie,alpha)
      grid $frm.guidage.labelGainAlpha -in [ $frm.guidage getframe ] -row 5 -column 1 -sticky we

      label $frm.guidage.labelGainDelta -text $::caption(sophie,delta)
      grid $frm.guidage.labelGainDelta -in [ $frm.guidage getframe ] -row 5 -column 2 -sticky we

      label $frm.guidage.labelgainProportionnel -text $::caption(sophie,gainProportionnel)
      grid $frm.guidage.labelgainProportionnel -in [ $frm.guidage getframe ] -row 6 -column 0 -sticky w

      Entry $frm.guidage.entryAlphaProportionalGain \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(alphaProportionalGain)
      grid $frm.guidage.entryAlphaProportionalGain -in [ $frm.guidage getframe ] -row 6 -column 1 -sticky ens

      Entry $frm.guidage.entryDeltaProportionalGain \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(deltaProportionalGain)
      grid $frm.guidage.entryDeltaProportionalGain -in [ $frm.guidage getframe ] -row 6 -column 2 -sticky ens

      #--- Gain integrateur
      label $frm.guidage.labelgainIntegrateur -text $::caption(sophie,gainIntegrateur)
      grid $frm.guidage.labelgainIntegrateur -in [ $frm.guidage getframe ] -row 7 -column 0 -sticky w

      Entry $frm.guidage.entryAlphaIntegralGain \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(alphaIntegralGain)
      grid $frm.guidage.entryAlphaIntegralGain -in [ $frm.guidage getframe ] -row 7 -column 1 -sticky ens

      Entry $frm.guidage.entryDeltaIntegralGain \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(deltaIntegralGain)
      grid $frm.guidage.entryDeltaIntegralGain -in [ $frm.guidage getframe ] -row 7 -column 2 -sticky ens

      #--- Gain differentiel
      label $frm.guidage.labelgainDifferentiel -text $::caption(sophie,gainDifferentiel)
      grid $frm.guidage.labelgainDifferentiel -in [ $frm.guidage getframe ] -row 8 -column 0 -sticky w

      Entry $frm.guidage.entryAlphaDerivativeGain \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(alphaDerivativeGain)
      grid $frm.guidage.entryAlphaDerivativeGain -in [ $frm.guidage getframe ] -row 8 -column 1 -sticky ens

      Entry $frm.guidage.entryDeltaDerivativeGain \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(deltaDerivativeGain)
      grid $frm.guidage.entryDeltaDerivativeGain -in [ $frm.guidage getframe ] -row 8 -column 2 -sticky ens

   pack $frm.guidage -side top -anchor w -fill x -expand 0

   #--- Frame pour la position des fibres
   TitleFrame $frm.fibre -borderwidth 2 -relief ridge -text $::caption(sophie,positionFibres)

      label $frm.fibre.xLabel -text "X"
      grid $frm.fibre.xLabel -in [ $frm.fibre getframe ] -row 0 -column 1 -sticky we
      label $frm.fibre.yLabel -text "Y"
      grid $frm.fibre.yLabel -in [ $frm.fibre getframe ] -row 0 -column 2 -sticky we

      #--- Fibre A HR
      label $frm.fibre.labelfibreAHR -text $::caption(sophie,fibreAHR)
      grid $frm.fibre.labelfibreAHR -in [ $frm.fibre getframe ] -row 1 -column 0 -sticky w

      Entry $frm.fibre.spinboxfiberHRX \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(fiberHRX)
      grid $frm.fibre.spinboxfiberHRX -in [ $frm.fibre getframe ] -row 1 -column 1 -sticky ens

      Entry $frm.fibre.spinboxfiberHRY \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(fiberHRY)
      grid $frm.fibre.spinboxfiberHRY -in [ $frm.fibre getframe ] -row 1 -column 2 -sticky ens

      Button $frm.fibre.replaceOriginHR -text $::caption(sophie,replaceCrossPosition) \
         -command "::sophie::config::replaceOriginCoordinates $visuNo HR"
      grid $frm.fibre.replaceOriginHR -in [ $frm.fibre getframe ] -row 1 -column 3 -sticky ens \
         -padx 2 -pady 2

      #--- Fibre A HE
      label $frm.fibre.labelfibreAHE -text $::caption(sophie,fibreAHE)
      grid $frm.fibre.labelfibreAHE -in [ $frm.fibre getframe ] -row 2 -column 0 -sticky w

      Entry $frm.fibre.spinboxfiberHEX \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(fiberHEX)
      grid $frm.fibre.spinboxfiberHEX -in [ $frm.fibre getframe ] -row 2 -column 1 -sticky ens

      Entry $frm.fibre.spinboxfiberHEY \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(fiberHEY)
      grid $frm.fibre.spinboxfiberHEY -in [ $frm.fibre getframe ] -row 2 -column 2 -sticky ens

      Button $frm.fibre.replaceOriginHE -text $::caption(sophie,replaceCrossPosition) \
         -command "::sophie::config::replaceOriginCoordinates $visuNo HE"
      grid $frm.fibre.replaceOriginHE -in [ $frm.fibre getframe ] -row 2 -column 3 -sticky ens \
         -padx 2 -pady 2

      #--- Fibre B
      label $frm.fibre.labelfibreB -text $::caption(sophie,fibreB)
      grid $frm.fibre.labelfibreB -in [ $frm.fibre getframe ] -row 3 -column 0 -sticky w

      Entry $frm.fibre.spinboxxfibreB\
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(fiberBX)
      grid $frm.fibre.spinboxxfibreB -in [ $frm.fibre getframe ] -row 3 -column 1 -sticky ens

      Entry $frm.fibre.spinboxyfibreB\
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(fiberBY)
      grid $frm.fibre.spinboxyfibreB -in [ $frm.fibre getframe ] -row 3 -column 2 -sticky ens

      Button $frm.fibre.replaceOriginFiberB -text $::caption(sophie,replaceCirclePosition) \
         -command "::sophie::config::replaceOriginCoordinates $visuNo FIBER_B"
      grid $frm.fibre.replaceOriginFiberB -in [ $frm.fibre getframe ] -row 3 -column 3 -sticky ens \
         -padx 2 -pady 2

   pack $frm.fibre -side top -anchor w -fill x -expand 0

   #--- Frame pour la position des fibres
   TitleFrame $frm.angle -borderwidth 2 -relief ridge -text $::caption(sophie,angleBonnette)

      #--- Fibre A HR
      label $frm.angle.labelAngle -text $::caption(sophie,angle)
      grid $frm.angle.labelAngle  -in [ $frm.angle getframe ] -row 1 -column 0 -sticky w

      Entry $frm.angle.entryAngle \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(angle)
      grid $frm.angle.entryAngle -in [ $frm.angle getframe ] -row 1 -column 1 -sticky e

     label $frm.angle.angleRemark -text $::caption(sophie,angleRemark)
      grid $frm.angle.angleRemark  -in [ $frm.angle getframe ] -row 2 -column 0 -columnspan 2 -sticky w

   pack $frm.angle -side top -anchor w -fill x -expand 0

}

#------------------------------------------------------------
# fillConfigAvanceePage
#   cree les widgets dans l'onglet configuration avancee
#   return rien
#------------------------------------------------------------
proc ::sophie::config::fillConfigAvanceePage { frm visuNo } {
   variable private

   #--- Frame pour la configuration du guidage
   TitleFrame $frm.echelle -borderwidth 2 -relief ridge -text $::caption(sophie,echelle)

      #--- Echelle
      label $frm.echelle.labelechelle -text $::caption(sophie,echelleArcSec)
      grid $frm.echelle.labelechelle -in [ $frm.echelle getframe ] -row 0 -column 0 -sticky w

      Entry $frm.echelle.entryechelle \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(echelle)
      grid $frm.echelle.entryechelle -in [ $frm.echelle getframe ] -row 0 -column 1 -sticky ens

   pack $frm.echelle -side top -anchor w -fill x -expand 0

   #--- Frame pour la configuration du binning de la focalisation
   TitleFrame $frm.focBinning -borderwidth 2 -relief ridge -text $::caption(sophie,binning)

      #--- Binning par defaut du mode focalisation
      label $frm.focBinning.labelbinfocalisation -text $::caption(sophie,binningFocalisation) -justify left
      grid $frm.focBinning.labelbinfocalisation -in [ $frm.focBinning getframe ] -row 2 -column 0 -sticky w

      ComboBox $frm.focBinning.valeurbinfocalisation \
         -width [ ::tkutil::lgEntryComboBox $::sophie::private(listeBinning) ] \
         -height [ llength $::sophie::private(listeBinning) ] \
         -justify center            \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::sophie::config::widget(binFocalisationDefaut) \
         -editable 0                \
         -values $::sophie::private(listeBinning)
      grid $frm.focBinning.valeurbinfocalisation -in [ $frm.focBinning getframe ] -row 2 -column 1 \
         -sticky ens

   pack $frm.focBinning -side top -anchor w -fill x -expand 0

   #--- Frame pour la configuration du guidage
   TitleFrame $frm.guidageAvancee -borderwidth 2 -relief ridge -text $::caption(sophie,parametreAlgo)

      #--- Valeur de Bias 1 Slow
      label $frm.guidageAvancee.labelImageBias1Slow -text "$::caption(sophie,valeurBias,bin1Slow)"
      grid $frm.guidageAvancee.labelImageBias1Slow -in [ $frm.guidageAvancee getframe ] \
         -row 1 -column 0 -sticky w

      Entry $frm.guidageAvancee.entryImageBias1Slow \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,1,slow)
      grid $frm.guidageAvancee.entryImageBias1Slow -in [ $frm.guidageAvancee getframe ] \
         -row 1 -column 1 -sticky ew

      #--- Valeur de Bias 1 Fast
      label $frm.guidageAvancee.labelImageBias1Fast -text "$::caption(sophie,valeurBias,bin1Fast)"
      grid $frm.guidageAvancee.labelImageBias1Fast -in [ $frm.guidageAvancee getframe ] \
         -row 2 -column 0 -sticky w

      Entry $frm.guidageAvancee.entryImageBias1Fast \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,1,fast)
      grid $frm.guidageAvancee.entryImageBias1Fast -in [ $frm.guidageAvancee getframe ] \
         -row 2 -column 1 -sticky ew

      #--- Valeur de Bias 2 Slow
      label $frm.guidageAvancee.labelImageBias2Slow -text "$::caption(sophie,valeurBias,bin2Slow)"
      grid $frm.guidageAvancee.labelImageBias2Slow -in [ $frm.guidageAvancee getframe ] \
         -row 3 -column 0 -sticky w

      Entry $frm.guidageAvancee.entryImageBias2Slow \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,2,slow)
      grid $frm.guidageAvancee.entryImageBias2Slow -in [ $frm.guidageAvancee getframe ] \
         -row 3 -column 1 -sticky ew

      #--- Valeur de Bias 2 Fast
      label $frm.guidageAvancee.labelImageBias2Fast -text "$::caption(sophie,valeurBias,bin2Fast)"
      grid $frm.guidageAvancee.labelImageBias2Fast -in [ $frm.guidageAvancee getframe ] \
         -row 4 -column 0 -sticky w

      Entry $frm.guidageAvancee.entryImageBias2Fast \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,2,fast)
      grid $frm.guidageAvancee.entryImageBias2Fast -in [ $frm.guidageAvancee getframe ] \
         -row 4 -column 1 -sticky ew

      #--- Valeur de Bias 3 Slow
      label $frm.guidageAvancee.labelImageBias3Slow -text "$::caption(sophie,valeurBias,bin3Slow)"
      grid $frm.guidageAvancee.labelImageBias3Slow -in [ $frm.guidageAvancee getframe ] \
         -row 5 -column 0 -sticky w

      Entry $frm.guidageAvancee.entryImageBias3Slow \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,3,slow)
      grid $frm.guidageAvancee.entryImageBias3Slow -in [ $frm.guidageAvancee getframe ] \
         -row 5 -column 1 -sticky ew

      #--- Valeur de Bias 3 Fast
      label $frm.guidageAvancee.labelImageBias3Fast -text "$::caption(sophie,valeurBias,bin3Fast)"
      grid $frm.guidageAvancee.labelImageBias3Fast -in [ $frm.guidageAvancee getframe ] \
         -row 6 -column 0 -sticky w

      Entry $frm.guidageAvancee.entryImageBias3Fast \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(biasFileName,3,fast)
      grid $frm.guidageAvancee.entryImageBias3Fast -in [ $frm.guidageAvancee getframe ] \
         -row 6 -column 1 -sticky ew

      #--- Ecart min max
      label $frm.guidageAvancee.labelEcartMinMax -text $::caption(sophie,ecartMinMax)
      grid $frm.guidageAvancee.labelEcartMinMax -in [ $frm.guidageAvancee getframe ] \
         -row 7 -column 0 -sticky w

      Entry $frm.guidageAvancee.entryEcartMinMax \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(minMaxDiff)
      grid $frm.guidageAvancee.entryEcartMinMax -in [ $frm.guidageAvancee getframe ] \
         -row 7 -column 1 -sticky ens

      #--- Precision du centrage
      label $frm.guidageAvancee.labelprecisionCentrage -text $::caption(sophie,arretCentrage)
      grid $frm.guidageAvancee.labelprecisionCentrage -in [ $frm.guidageAvancee getframe ] \
         -row 8 -column 0 -sticky w

      Entry $frm.guidageAvancee.entryprecisionCentrage \
         -width 8 -justify center -editable 1 \
         -textvariable ::conf(sophie,centerMaxLimit)
      grid $frm.guidageAvancee.entryprecisionCentrage -in [ $frm.guidageAvancee getframe ] \
         -row 8 -column 1 -sticky ens

      #--- Taille de la fenetre de centrage
      label $frm.guidageAvancee.labeltailleFenetreCentrage -text $::caption(sophie,tailleFenetreCentrage)
      grid $frm.guidageAvancee.labeltailleFenetreCentrage -in [ $frm.guidageAvancee getframe ] \
         -row 9 -column 0 -sticky w

      Entry $frm.guidageAvancee.entrytailleFenetreCentrage \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(tailleFenetreCentrage)
      grid $frm.guidageAvancee.entrytailleFenetreCentrage -in [ $frm.guidageAvancee getframe ] \
         -row 9 -column 1 -sticky ens

      #--- Taille de la fenetre de guidage
      label $frm.guidageAvancee.labeltailleFenetreGuidage -text $::caption(sophie,tailleFenetreGuidage)
      grid $frm.guidageAvancee.labeltailleFenetreGuidage -in [ $frm.guidageAvancee getframe ] \
         -row 10 -column 0 -sticky w

      Entry $frm.guidageAvancee.entrytailleFenetreGuidage \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(tailleFenetreGuidage)
      grid $frm.guidageAvancee.entrytailleFenetreGuidage -in [ $frm.guidageAvancee getframe ] \
         -row 10 -column 1 -sticky ens

   pack $frm.guidageAvancee -side top -anchor w -fill x -expand 0

   #--- Frame pour les parametres du masque
   TitleFrame $frm.paraMasque -borderwidth 2 -relief ridge -text $::caption(sophie,paraMasque)

      #--- Diametre du masque
      label $frm.paraMasque.labelDiametreMasque -text $::caption(sophie,diametreMasque)
      grid $frm.paraMasque.labelDiametreMasque -in [ $frm.paraMasque getframe ]\
         -row 0 -column 1 -sticky w

      Entry $frm.paraMasque.entryDiametreMasque \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(maskRadius)
      grid $frm.paraMasque.entryDiametreMasque -in [ $frm.paraMasque getframe ] \
         -row 0 -column 2 -sticky ens

      #--- Largeur de la gaussienne du masque
      label $frm.paraMasque.labelLargeurGaussMasque -text $::caption(sophie,largeurGaussMasque)
      grid $frm.paraMasque.labelLargeurGaussMasque -in [ $frm.paraMasque getframe ] \
         -row 1 -column 1 -sticky w

      Entry $frm.paraMasque.entryLargeurGaussMasque \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(maskFwhm)
      grid $frm.paraMasque.entryLargeurGaussMasque -in [ $frm.paraMasque getframe ] \
         -row 1 -column 2 -sticky ens

      #--- Pourcentage du seuil du masque
      label $frm.paraMasque.labelPourcentageGaussMasque -text $::caption(sophie,pourcentageGaussMasque)
      grid $frm.paraMasque.labelPourcentageGaussMasque -in [ $frm.paraMasque getframe ] \
         -row 2 -column 1 -sticky w

      Entry $frm.paraMasque.entryPourcentageGaussMasque \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(maskPercent)
      grid $frm.paraMasque.entryPourcentageGaussMasque -in [ $frm.paraMasque getframe ] \
         -row 2 -column 2 -sticky ens

      #--- Nombre minimal de pixels
      label $frm.paraMasque.labelSeuilMini -text $::caption(sophie,seuilMini)
      grid $frm.paraMasque.labelSeuilMini -in [ $frm.paraMasque getframe ] \
         -row 3 -column 1 -sticky w

      Entry $frm.paraMasque.entrySeuilMini \
         -width 8 -justify center -editable 1 \
         -textvariable ::sophie::config::widget(pixelMinCount)
      grid $frm.paraMasque.entrySeuilMini -in [ $frm.paraMasque getframe ] \
         -row 3 -column 2 -sticky ens

   pack $frm.paraMasque -side top -anchor w -fill x -expand 0

   #--- Frame pour les images
   TitleFrame $frm.imageAvancee -borderwidth 2 -relief ridge -text $::caption(sophie,images)

      #--- Prefixe des images de centrage
      label $frm.imageAvancee.labelprefixeImageCentrage -text $::caption(sophie,prefixeImageCentrage)
      grid $frm.imageAvancee.labelprefixeImageCentrage -in [ $frm.imageAvancee getframe ] \
         -row 1 -column 1 -sticky w

      Entry $frm.imageAvancee.entryprefixeImageCentrage \
         -width 13 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(prefixeImageCentrage)
      grid $frm.imageAvancee.entryprefixeImageCentrage -in [ $frm.imageAvancee getframe ] \
         -row 1 -column 2 -sticky ew

      #--- Prefixe des images de focalisation
      label $frm.imageAvancee.labelprefixeImageFocalisation -text $::caption(sophie,prefixeImageFocalisation)
      grid $frm.imageAvancee.labelprefixeImageFocalisation -in [ $frm.imageAvancee getframe ] \
         -row 2 -column 1 -sticky w

      Entry $frm.imageAvancee.entryprefixeImageFocalisation \
         -width 13 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(prefixeImageFocalisation)
      grid $frm.imageAvancee.entryprefixeImageFocalisation -in [ $frm.imageAvancee getframe ] \
         -row 2 -column 2 -sticky ew

      #--- Prefixe des images de guidage
      label $frm.imageAvancee.labelprefixeImageGuidage -text $::caption(sophie,prefixeImageGuidage)
      grid $frm.imageAvancee.labelprefixeImageGuidage -in [ $frm.imageAvancee getframe ] \
         -row 3 -column 1 -sticky w

      Entry $frm.imageAvancee.entryprefixeImageGuidage \
         -width 13 -justify left -editable 1 \
         -textvariable ::sophie::config::widget(prefixeImageGuidage)
      grid $frm.imageAvancee.entryprefixeImageGuidage -in [ $frm.imageAvancee getframe ] \
         -row 3 -column 2 -sticky ew

   pack $frm.imageAvancee -side top -anchor w -fill x -expand 0

   #--- Frame pour le bouton de lancement des simulations
   TitleFrame $frm.simulation -borderwidth 2 -relief ridge \
      -text $::caption(sophie,simulation)

      #--- Bouton de lancement des simulations
      Button $frm.simulation.but -text $::caption(sophie,simulation) -relief raised \
         -command "::sophie::simul"
      grid $frm.simulation.but -in [ $frm.simulation getframe ] -row 0 -column 1 -sticky e -padx 2

   pack $frm.simulation -side left -anchor w -fill x -expand 1

   #--- Frame pour le bouton d'acces aux mots cles de l'en-tete FITS
   TitleFrame $frm.en-tete_fits -borderwidth 2 -relief ridge \
      -text $::caption(sophie,en-tete_fits)

      #--- Bouton de lancement de l'acces aux mots cles de l'en-tete FITS
      Button $frm.en-tete_fits.but -text $::caption(sophie,mots_cles) -relief raised \
         -command "::keyword::run $::audace(visuNo) ::conf(sophie,keywordConfigName)"
      grid $frm.en-tete_fits.but -in [ $frm.en-tete_fits getframe ] -row 0 -column 1 -sticky e -padx 2

      #--- Label du nom de la configuration de l'en-tete FITS
      entry $frm.en-tete_fits.labNom -textvariable ::conf(sophie,keywordConfigName) \
         -state readonly -takefocus 0 -justify center
      grid $frm.en-tete_fits.labNom -in [ $frm.en-tete_fits getframe ] -row 0 -column 2 -sticky e -padx 2

   pack $frm.en-tete_fits -side left -anchor w -fill x -expand 1
}

#----------------------------------------------------------------------------
# cmdApply
#    met a jour les variables et les widgets quand on applique les modifications d'une configuration
#----------------------------------------------------------------------------
proc ::sophie::config::cmdApply { visuNo } {
   variable widget

   #--- j'initalise les variables des widgets
   ### set ::conf(sophie,exposure)              $widget(poseDefaut)
   set ::conf(sophie,centerBinning)         $widget(binCentrageDefaut)
   set ::conf(sophie,focuseBinning)         $widget(binFocalisationDefaut)
   set ::conf(sophie,guideBinning)          $widget(binGuidageDefaut)
   set ::conf(sophie,pixelScale)            $widget(echelle)
   set ::conf(sophie,guidingWindowSize)     $widget(tailleFenetreGuidage)
   set ::conf(sophie,centerWindowSize)      $widget(tailleFenetreCentrage)
   set ::conf(sophie,alphaProportionalGain) [expr double($widget(alphaProportionalGain)) / 100.0]
   set ::conf(sophie,deltaProportionalGain) [expr double($widget(deltaProportionalGain)) / 100.0]
   set ::conf(sophie,alphaIntegralGain)     [expr double($widget(alphaIntegralGain)) / 100.0]
   set ::conf(sophie,deltaIntegralGain)     [expr double($widget(deltaIntegralGain)) / 100.0]
   set ::conf(sophie,alphaDerivativeGain)   [expr double($widget(alphaDerivativeGain)) / 100.0]
   set ::conf(sophie,deltaDerivativeGain)   [expr double($widget(deltaDerivativeGain)) / 100.0]
   set ::conf(sophie,minMaxDiff)            $widget(minMaxDiff)
   set ::conf(sophie,centerFileNameprefix)  $widget(prefixeImageCentrage)
   set ::conf(sophie,focusFileNameprefix)   $widget(prefixeImageFocalisation)
   set ::conf(sophie,guidingFileNameprefix) $widget(prefixeImageGuidage)

  ### set ::conf(sophie,fiberGuigindMode)      $widget(fiberGuigindMode)
   set ::conf(sophie,fiberHRX)               $widget(fiberHRX)
   set ::conf(sophie,fiberHRY)               $widget(fiberHRY)
   set ::conf(sophie,fiberHEX)               $widget(fiberHEX)
   set ::conf(sophie,fiberHEY)               $widget(fiberHEY)
   set ::conf(sophie,fiberBX)                $widget(fiberBX)
   set ::conf(sophie,fiberBY)                $widget(fiberBY)
   set ::conf(sophie,angle)                  $widget(angle)

   set ::conf(sophie,biasFileName,1,slow)    $widget(biasFileName,1,slow)
   set ::conf(sophie,biasFileName,1,fast)    $widget(biasFileName,1,fast)
   set ::conf(sophie,biasFileName,2,slow)    $widget(biasFileName,2,slow)
   set ::conf(sophie,biasFileName,2,fast)    $widget(biasFileName,2,fast)
   set ::conf(sophie,biasFileName,3,slow)    $widget(biasFileName,3,slow)
   set ::conf(sophie,biasFileName,3,fast)    $widget(biasFileName,3,fast)

   set ::conf(sophie,maskRadius)             $widget(maskRadius)
   set ::conf(sophie,maskFwhm)               $widget(maskFwhm)
   set ::conf(sophie,maskPercent)            [expr double($widget(maskPercent)) / 100 ]
   set ::conf(sophie,pixelMinCount)          $widget(pixelMinCount)

   #--- je communique les nouveaux parametres au thread de la camera
   set ::sophie::private(AsynchroneParameter) 1
   ::camera::setAsynchroneParameter $::sophie::private(camItem)\
         "alphaProportionalGain"    $::conf(sophie,alphaProportionalGain) \
         "deltaProportionalGain"    $::conf(sophie,deltaProportionalGain) \
         "alphaIntegralGain"        $::conf(sophie,alphaIntegralGain) \
         "deltaIntegralGain"        $::conf(sophie,deltaIntegralGain) \
         "alphaDerivativeGain"      $::conf(sophie,alphaDerivativeGain) \
         "deltaDerivativeGain"      $::conf(sophie,deltaDerivativeGain) \
         "originSumMinCounter"      $::conf(sophie,originSumMinCounter) \
         "originSumCounter"         0 \
         "maskRadius"               $::conf(sophie,maskRadius) \
         "maskFwhm"                 $::conf(sophie,maskFwhm)  \
         "maskPercent"              $::conf(sophie,maskPercent) \
         "pixelMinCount"            $::conf(sophie,pixelMinCount)

   #---  je re-positionne la consigne
   ::sophie::setGuidingMode $visuNo
   #--- j'affiche ou je supprime les axes visalisant la rotation de la bonette
   if { $::conf(sophie,angle) != 0 } {
      ::sophie::createAlphaDeltaAxis $visuNo $::conf(sophie,angle)
   } else {
      ::sophie::deleteAlphaDeltaAxis $visuNo
   }
   #--- j'applique le mode courant pour prendre en compte les nouvelles valeurs des parametres
   ::sophie::setMode
   #--- je met a jour la fenetre de controle
   ::sophie::control::setMinMaxDiff $::conf(sophie,minMaxDiff)

}

#------------------------------------------------------------
# choseBiasFile
#    choisi le nom de l'image de bias
# @param  cameraBinning  binning de la camera
# @param  cameraMode     mode de la camera
# @return rien
#------------------------------------------------------------
###proc ::sophie::config::chooseBiasFile { cameraBinning cameraMode } {
###   variable widget
###
###   #--- Ouvre la fenetre de choix des images
###   set widget(biasFileName,$cameraBinning,$cameraMode) [ ::tkutil::box_load $::private(frm) $::audace(rep_images) $::audace(bufNo) "1" ]
###}

#------------------------------------------------------------
# onScroll
#    scroll de la consigne
#------------------------------------------------------------
###proc ::sophie::config::onScroll { visuNo name  args } {
###   variable widget
###
###   switch $name {
###      "fiberHRX" -
###      "fiberHRY" {
###         set ::sophie::private(originCoord) [list $widget(fiberHRX) $widget(fiberHRY)]
###         ::sophie::createOrigin $visuNo
###      }
###      "fiberHEX" -
###      "fiberHEY" {
###         set ::sophie::private(originCoord) [list $widget(fiberHEX) $widget(fiberHEY)]
###         ::sophie::createOrigin $visuNo
###      }
###      "fiberBX" -
###      "fiberBY" {
###         ###set ::sophie::private(originCoord) [list $widget(fiberHEX) $widget(fiberHEY)]
###         ###::sophie::createFiberB $visuNo
###      }
###   }
###}

#------------------------------------------------------------
# onFiberMode
#   change le mode
#------------------------------------------------------------
###proc ::sophie::config::onFiberMode { visuNo args } {
###   variable widget
###
###   switch $widget(fiberGuigindMode) {
###      "HR" {
###         set ::sophie::private(originCoord) [list $widget(fiberHRX) $widget(fiberHRY)]
###         ::sophie::createOrigin $visuNo
###      }
###      "HE" {
###         set ::sophie::private(originCoord) [list $widget(fiberHEX) $widget(fiberHEY)]
###         ::sophie::createOrigin $visuNo
###      }
###   }
###
###}

#------------------------------------------------------------
## @brief remplace la position de la consigne par la position courante de la consigne
#  @param visuNo numéro de la visu
#  @param positionType  type de position (HR ou HE ou FIBER_B)
#
proc ::sophie::config::replaceOriginCoordinates { visuNo positionType } {
   variable widget

   switch $positionType {
      "HR" {
         set widget(fiberHRX) [format "%.1f" [lindex $::sophie::private(originCoord) 0]]
         set widget(fiberHRY) [format "%.1f" [lindex $::sophie::private(originCoord) 1]]
      }
      "HE" {
         set widget(fiberHEX) [format "%.1f" [lindex $::sophie::private(originCoord) 0]]
         set widget(fiberHEY) [format "%.1f" [lindex $::sophie::private(originCoord) 1]]
      }
      "FIBER_B" {
         set widget(fiberBX) [format "%.1f" [lindex $::sophie::private(fiberBCoord) 0]]
         set widget(fiberBY) [format "%.1f" [lindex $::sophie::private(fiberBCoord) 1]]
      }
   }
}

