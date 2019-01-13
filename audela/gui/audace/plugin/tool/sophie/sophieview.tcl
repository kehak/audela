#
# @file     sophieview.tcl
# @brief    Fichier du namespace ::sophie::view
# @author   Michel PUJOL et Robert DELMAS
# $Id: sophieview.tcl 13349 2016-03-11 14:45:52Z rzachantke $
#

## namespace sophie::view
#  @brief   visualisation des images

namespace eval ::sophie::view {

}

#------------------------------------------------------------
## @brief affiche la fenêtre de configuration
#  @param sophieVisuNo  numéro de la visu de la fenêtre principale de l'outil sophie
#
proc ::sophie::view::run { sophieVisuNo } {
   variable private

   #--- je memorise le numero de la visu de la fenetre principale de sophie
   set private(sophieVisuNo) $sophieVisuNo
   #--- j'ouvre une visu pour afficher des profils
   set visuNo [::confVisu::create]

   #--- j'affiche l'outil
   #confVisu::selectTool $visuNo ""
   #Menu_Delete $visuNo $::caption(audace,menu,aiming) all
   #createPluginInstance [::confVisu::getBase $visuNo].tool $visuNo
   #lappend ::confVisu::private($visuNo,pluginInstanceList) "sophie::view"
   #set ::confVisu::private($visuNo,currentTool) "sophie::view"
   #startTool $visuNo
   ::confVisu::selectTool $visuNo ::sophie::view

   #--- j'affiche la fenetre au dessus de la fenetre principale de sophie
   wm transient [::confVisu::getBase $visuNo] [::confVisu::getBase $private(sophieVisuNo)]

   grid [::confVisu::getBase $visuNo].tool -row 0 -column 0 -rowspan 2 -sticky ns
}

#------------------------------------------------------------
#  brief créé une nouvelle instance de l'outil
#
proc ::sophie::view::createPluginInstance { base { visuNo 1 } } {
   variable private

   #--- je memorise le buffer initial
   set private(initialBuffer,$visuNo) [::confVisu::getBufNo $visuNo]

   set private(bufferName,$visuNo)    "sumBufNo"
   set private(valeurCompteur)        ""

   #--- Petit raccourci
   set private(frm) "$base.sophieview"
   set frm $private(frm)

   #--- je masque le nom de la camera et du telescope
   set tkBase [::confVisu::getBase $visuNo]
   grid forget $tkBase.fra1.labCam_labURL
   grid forget $tkBase.fra1.labCam_name_labURL
   grid forget $tkBase.fra1.labTel_labURL
   grid forget $tkBase.fra1.labTel_name_labURL

   #--- Interface graphique de l'outil
   frame $frm -borderwidth 2 -relief groove

      #--- Frame du titre et de la configuration
      frame $frm.select -borderwidth 2 -relief groove

         #--- Bouton de selection de l'image a afficher
         radiobutton $frm.select.sum -highlightthickness 0 -state normal \
            -text "$::caption(sophie,imageIntegree)" \
            -value "sumBufNo" \
            -variable ::sophie::view::private(bufferName,$visuNo) \
            -command "::sophie::view::setBuffer $visuNo"
         pack $frm.select.sum -side top -anchor w -ipady 2 -padx 2 -pady 2

         radiobutton $frm.select.mask -highlightthickness 0 -state normal \
            -text "$::caption(sophie,masque)" \
            -value "maskBufNo" \
            -variable ::sophie::view::private(bufferName,$visuNo) \
            -command "::sophie::view::setBuffer $visuNo"
         pack $frm.select.mask -side top -anchor w -ipady 2 -padx 2 -pady 2

         radiobutton $frm.select.fiber -highlightthickness 0 -state normal \
            -text "$::caption(sophie,imageInversee)" \
            -value "fiberBufNo" \
            -variable ::sophie::view::private(bufferName,$visuNo) \
            -command "::sophie::view::setBuffer $visuNo"
         pack $frm.select.fiber -side top -anchor w -ipady 2 -padx 2 -pady 2

      pack $frm.select -side top -fill x

      #--- Frame du titre et du compteur d'images integrees
      frame $frm.compteur -borderwidth 2 -relief groove

         #--- Label du compteur
         label $frm.compteur.label -text "$::caption(sophie,compteur)"
         pack $frm.compteur.label -side left -anchor w -ipady 2 -padx 5 -pady 2

         #--- Label de la valeur du compteur
         label $frm.compteur.valeurCompteur -textvariable ::sophie::view::private(valeurCompteur)
         pack $frm.compteur.valeurCompteur -side left -anchor w -ipady 2 -pady 2

      pack $frm.compteur -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm

      #---
      return $private(frm)
}

#------------------------------------------------------------
#  brief suppprime l'instance du plugin
#
proc ::sophie::view::deletePluginInstance { visuNo } {
   variable private
   #--- j'arrete le listener
   ::sophie::removeAcquisitionListener $private(sophieVisuNo) "::sophie::view::refresh $visuNo"
   #--- je restaure le numero du buffer initial pour qu'il soit supprime par confVisu::close
   visu$visuNo buf $private(initialBuffer,$visuNo)
   #--- je masque l'outil
   pack forget $private(frm)
}

#------------------------------------------------------------
#  brief affiche la fenêtre de l'outil
#
proc ::sophie::view::startTool { visuNo } {
   variable private

   #--- j'affiche l'outil
   pack $private(frm) -side left -fill y
   #--- je choisi les seuils initiaux par defaut
   set ::conf(seuils,visu$visuNo,mode) "initiaux"

   #--- je passe en zoom x4
   ::confVisu::setZoom  $visuNo 4
   #--- j'affiche l'image du buffer
   setBuffer $visuNo
   #--- je demarre le listener
   ::sophie::addAcquisitionListener $private(sophieVisuNo) "::sophie::view::refresh $visuNo"
}

#------------------------------------------------------------
# brief masque la fenêtre de l'outil
#
proc ::sophie::view::stopTool { visuNo } {
   variable private

}

#------------------------------------------------------------
#  brief retourne la valeur de la propriété
#  param propertyName : nom de la propriété
#
proc ::sophie::view::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "guiding" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
## @brief change le buffer et affiche le contenu
#  @param visuNo  numéro de la visu
#  @param bufferName  nom du buffer
#
proc ::sophie::view::setBuffer { visuNo { bufferName "" } } {
   variable private

   if { $bufferName == "" } {
      set bufferName $private(bufferName,$visuNo)
   } else {
      set private(bufferName,$visuNo) $bufferName
   }

   switch $bufferName {
      "maskBufNo" -
      "sumBufNo"  -
      "fiberBufNo" {
         visu$visuNo buf [::sophie::getBufNo $bufferName]
      }
      "initialBuffer" {
         visu$visuNo buf $private(initialBuffer,$visuNo)
      }
   }
   ::confVisu::autovisu $visuNo
}

#------------------------------------------------------------
## @brief rafraichît l'affichage
#  @param visuNo  numero de la visu
#  @param args    liste de parametres fournis par le listener
#
proc ::sophie::view::refresh { visuNo args } {
   variable private

   if { [winfo exists $private(frm) ] } {
      ::confVisu::autovisu $visuNo
      set private(valeurCompteur) [ lindex [ buf[::sophie::getBufNo $private(bufferName,$visuNo)] getkwd SUM_COUNT ] 1 ]
   }
}

