#
## @file     sophiefiberview.tcl
#  @brief    Fichier du namespace ::sophie::fiberview
#  @author   Michel PUJOL et Robert DELMAS
#  $Id: sophiefiberview.tcl 13349 2016-03-11 14:45:52Z rzachantke $
#

## namespace sophie::fiberview
# @brief   visualisation de la fibre

namespace eval ::sophie::fiberview {
   variable private
   set private(visuNo) 0

}

#------------------------------------------------------------
## @brief créé une visu pour voir la fibre
#  @param sophieVisuNo  numéro de la visu de la fenêtre principale de l'outil sophie
#
proc ::sophie::fiberview::run { sophieVisuNo  } {
   variable private

   if { $private(visuNo) == 0 } {
      if { ! [ info exists ::conf(sophie,fiberVisu,geometry) ] } {
         set ::conf(sophie,fiberVisu,geometry) "430x540+400+300"
      }

      #--- je memorise le numero de la visu de la fenetre principale de sophie
      set private(sophieVisuNo) $sophieVisuNo

      #--- j'ouvre une visu pour afficher la fibre A
      set visuNo [::confVisu::create]

      #--- j'affiche l'outil
      #confVisu::selectTool $visuNo ""
      #createPluginInstance [::confVisu::getBase $visuNo].tool $visuNo
      #lappend ::confVisu::private($visuNo,pluginInstanceList) "sophie::fiberview"
      #set ::confVisu::private($visuNo,currentTool) "sophie::fiberview"
      ::confVisu::selectTool $visuNo ::sophie::fiberview
      ###startTool $visuNo
   }
}

#------------------------------------------------------------
## @brief ferme la visu
#
proc ::sophie::fiberview::closeWindow { } {
   variable private

   if { $private(visuNo) != 0 } {
      ::confVisu::close $private(visuNo)
   }
}

#------------------------------------------------------------
## @brief créé une nouvelle instance de l'outil
#  @param in ??
#  @param visuNo numéro de la visu
#  @todo commenter le param in
#
proc ::sophie::fiberview::createPluginInstance { in visuNo } {
   variable private

   set tkBase [::confVisu::getBase $visuNo]
   #--- je vide le menu des outils Telescope
   Menu_Delete $visuNo $::caption(audace,menu,aiming) all
   #--- j'affiche la fentre au dessus de la fenetre principale de sophie
   wm transient $tkBase [::confVisu::getBase $private(sophieVisuNo)]
   #--- je change le titre
   wm title $tkBase $::caption(sophie,visuFibreA)
   #--- je change la position
   wm geometry $tkBase $::conf(sophie,fiberVisu,geometry)
   #--- je passe en zoom x4
   ::confVisu::setZoom $visuNo 4
   #--- je memorise le buffer initial
   set private(initialBufferNo) [::confVisu::getBufNo $visuNo]
   #--- je change le buffer
   visu$visuNo buf [::confVisu::getBufNo $private(sophieVisuNo)]
   #--- je masque le nom de la camera et du telescope
   grid forget $tkBase.fra1.labCam_labURL
   grid forget $tkBase.fra1.labCam_name_labURL
   grid forget $tkBase.fra1.labTel_labURL
   grid forget $tkBase.fra1.labTel_name_labURL

   #--- je memorise le numero de la visu
   set private(visuNo) $visuNo

}

#------------------------------------------------------------
## @brief suppprime l'instance du plugin
#  @param visuNo numéro de la visu
#
proc ::sophie::fiberview::deletePluginInstance { visuNo } {
   variable private

   #--- j'arrete le listener
   ::sophie::removeAcquisitionListener $private(sophieVisuNo) "::sophie::fiberview::refresh $visuNo"
   #--- je restaure le numero du buffer initial pour qu'il soit supprime par confVisu::close
   visu$visuNo buf $private(initialBufferNo)

   #--- j'enregistre la position de la fenetre
   set ::conf(sophie,fiberVisu,geometry) [winfo geometry [::confVisu::getBase $visuNo]]
   set private(visuNo) 0
}

#------------------------------------------------------------
#  brief affiche la fenêtre de l'outil
#
proc ::sophie::fiberview::startTool { visuNo } {
   variable private

   #--- je demarre le listener
   ::sophie::addAcquisitionListener $private(sophieVisuNo) "::sophie::fiberview::refresh $visuNo"
}

#------------------------------------------------------------
#  brief masque la fenêtre de l'outil
#
proc ::sophie::fiberview::stopTool { visuNo } {
   variable private

   #--- je passe en zoom x1
   ::confVisu::setZoom $visuNo 1

}

#------------------------------------------------------------
#  brief retourne la valeur de la propriete
#  param propertyName : nom de la propriete
#  return
#  - valeur de la propriété
#  - "" si la propriété n'existe pas
#
proc ::sophie::fiberview::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "guiding" }
      display      { return "window" }
      default      { return "" }
   }
}

#------------------------------------------------------------
#  brief affiche une fenêtre centrée sur la consigne
#
proc ::sophie::fiberview::refresh { visuNo args } {
   variable private

   if { [info command visu$visuNo] == "" } {
      return
   }
   #--- j'applique un fenetrage centre sur la fibreAHR
   set dispWindowCoord [visu$visuNo window]
   set x  $::conf(sophie,fiberHRX)
   set y  $::conf(sophie,fiberHRY)
   set size $::sophie::private(targetBoxSize)

   set x1 [expr int(($x - $size) / $::sophie::private(xBinning))]
   set x2 [expr int(($x + $size) / $::sophie::private(xBinning))]
   set y1 [expr int(($y - $size) / $::sophie::private(yBinning))]
   set y2 [expr int(($y + $size) / $::sophie::private(yBinning))]
   if { $dispWindowCoord != [list $x1 $y1 $x2 $y2] } {
      #--- j'annule le fenetrage precedent
      if { $dispWindowCoord != "full" } {
         visu$visuNo window "full"
      }
      #--- j'applique le nouveau fenetrage
      catch {
         visu$visuNo window [list $x1 $y1 $x2 $y2]
         set ::confVisu::private($visuNo,window) 1
      }
   }
   #--- j'affiche l'image
   ::confVisu::autovisu $visuNo
   #--- je change le titre
   wm title [::confVisu::getBase $visuNo] $::caption(sophie,visuFibreA)
}

