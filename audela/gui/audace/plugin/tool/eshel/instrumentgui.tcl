#
## @file instrumentgui.tcl
#  @brief fenêtre de configuration instrument eShel
#  @author Michel PUJOL
#  $Id: instrumentgui.tcl 13444 2016-03-20 15:19:06Z rzachantke $

## namespace eshel::instrumentgui
#  @brief fenêtre de configuration instrument eShel

namespace eval ::eshel::instrumentgui {

   package require tablelist

}

#------------------------------------------------------------
# ::eshel::process::run
#    affiche la fenetre du traitement
#
proc ::eshel::instrumentgui::run { tkbase visuNo } {
   variable private

   set private(configList)  [list]

   #Modif OTz20110826-start
   set private(actionTypeList)  [ list biasSerie darkSerie flatfieldSerie ledSerie tharSerie tungstenSerie mirrorON mirrorOFF wait readOut]
   #Modif OTz20110826-end

   #--- liste des paraemtres des actions
   set private(actionParamNames)                 [ list expTime expNb ]
   set private(action,biasSerie,paramNames)      [ list expNb ]
   set private(action,darkSerie,paramNames)      [ list expTime expNb ]
   set private(action,flatfieldSerie,paramNames) [ list expTime expNb ]
   set private(action,ledSerie,paramNames)       [ list expTime expNb ]
   set private(action,tharSerie,paramNames)      [ list expTime expNb ]
   set private(action,tungstenSerie,paramNames)  [ list expTime expNb ]
   set private(action,wait,paramNames)           [ list expTime ]
   set private(action,mirrorON,paramNames)       [ list expTime ]
   set private(action,mirrorOFF,paramNames)      [ list expTime ]
   set private(action,readOut,paramNames)        [ list expNb ]
   set private(action,expTime)                   1
   set private(action,expNb)                     1
   set private(closeWindow)                      1

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,instrumentWindowPosition) ] } { set ::conf(eshel,instrumentWindowPosition)     "650x240+350+15" }

   #--- j'affiche la fenetre
   set private($visuNo,This) ".eshelprocess"
   ::confGenerique::run  $visuNo $private($visuNo,This) "::eshel::instrumentgui" -modal 0 -geometry $::conf(eshel,instrumentWindowPosition) -resizable 1
   wm minsize $private($visuNo,This) 430 505
}

#------------------------------------------------------------
# ::eshel::instrumentgui::cmdClose
#   ferme la fenetre
#
proc ::eshel::instrumentgui::cmdClose { visuNo } {
   variable private
   variable widget

   if { $private(closeWindow) == 0 } {
      set private(closeWindow) 1
      #--- j'annule la fermeture s'il y a une erreur
      return 0
   }

   #--- j'efface les indicateurs d'erreur
   array unset widget error,*

   #--- je memoririse la position courante de la fenetre
   set ::conf(eshel,instrumentWindowPosition) [ wm geometry $private($visuNo,This) ]
}

#------------------------------------------------------------
# showHelp
#   affiche l'aide de cet outil
#
proc ::eshel::instrumentgui::showHelp { } {
   ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::eshel::getPluginType]] \
      [::eshel::getPluginDirectory] [::eshel::getPluginHelp] "instrument"
}

#------------------------------------------------------------
# ::eshel::instrumentgui::getLabel
#   retourne le nom de la fenetre de traitement
#
proc ::eshel::instrumentgui::getLabel { } {

   return "$::caption(eshel,title) $::caption(eshel,instrument,title)"
}

#------------------------------------------------------------
# ::eshel::instrumentgui::fillConfigPage
#   cree les widgets de la fenetre de configuration du traitement
#   return rien
#
proc ::eshel::instrumentgui::fillConfigPage { frm visuNo } {
   variable private

   set private($visuNo,frm) $frm

   #--- Frame select config
   TitleFrame $frm.config  -borderwidth 2 -relief ridge -text "$::caption(eshel,instrument,selectConfig)"
      #--- Liste des configurations
      set configList [::eshel::instrument::getConfigurationList]

      #--- Bouton create new configuration
      Button $frm.config.create -text "$::caption(eshel,instrument,createConfig)" -command "::eshel::instrumentgui::createConfig $visuNo"
      pack $frm.config.create -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

      #--- j'affiche la liste des configurations
      ComboBox $frm.config.combo \
         -width 20 -height [ llength $configList ] \
         -relief sunken -borderwidth 1 -editable 0 \
         -modifycmd "::eshel::instrumentgui::onSelectConfig $visuNo" \
         -values $configList
      pack $frm.config.combo -in [$frm.config getframe] -side left -fill none -padx 2
      if { [info exists ::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),configName)] != 0 } {
         set index [lsearch $configList $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),configName)]
         if { $index == -1 } {
            #--- je selectionne la premiere configuration , si celle de la derniere utilisee n'existe plus
            set index 0
         }
      } else {
         #--- je selectionne la premiere configuration , si celle de la derniere utilisee n'existe plus
         set index 0
      }

      #--- je selectionne la configuration dans la combobox
      $frm.config.combo setvalue "@$index"

      #--- Bouton copy configuration
      Button $frm.config.copy -text "$::caption(eshel,instrument,copyConfig)" -command "::eshel::instrumentgui::copyConfig $visuNo"
      pack $frm.config.copy -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

      #--- Bouton delete configuration
      Button $frm.config.delete -text "$::caption(eshel,instrument,deleteConfig)" -command "::eshel::instrumentgui::deleteConfig $visuNo"
      pack $frm.config.delete -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

      #--- Bouton import configuration
      Button $frm.config.importCalibration -text "$::caption(eshel,instrument,importCalibrationConfig)" -command "::eshel::instrumentgui::importCalibrationConfig $visuNo"
      pack $frm.config.importCalibration -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

      #--- Bouton import configuration
      Button $frm.config.import -text "$::caption(eshel,instrument,importConfig)" -command "::eshel::instrumentgui::importConfig $visuNo"
      pack $frm.config.import -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

      #--- Bouton import configuration
      Button $frm.config.export -text "$::caption(eshel,instrument,exportConfig)" -command "::eshel::instrumentgui::exportConfig $visuNo"
      pack $frm.config.export -in [$frm.config getframe] -side left -fill none -expand 0 -padx 2

   pack $frm.config -side top -fill x -expand 0

   #--- Creation des onglets
   set notebook [ NoteBook $frm.notebook ]
      $notebook insert end "spectrograph" -text $::caption(eshel,instrument,spectrograph)
      $notebook insert end "camera"       -text $::caption(eshel,instrument,camera)
      $notebook insert end "telescope"    -text $::caption(eshel,instrument,telescope)
      $notebook insert end "process"      -text $::caption(eshel,instrument,process)
      $notebook insert end "reference"    -text $::caption(eshel,instrument,reference)
   pack $frm.notebook  -side top -fill both -expand 1

   #--- j'affiche les wigdets dans les onglets
   fillSpectrographPage [$notebook getframe "spectrograph"] $visuNo
   fillCameraPage       [$notebook getframe "camera"]       $visuNo
   fillTelescopePage    [$notebook getframe "telescope"]    $visuNo
   fillProcessPage      [$notebook getframe "process"]     $visuNo
   fillReferencePage    [$notebook getframe "reference"]     $visuNo

   #--- j'affiche les paramametres de la configuration courante
   onSelectConfig $visuNo

   pack $frm  -side top -fill both -expand 1

   #--- je selectionne le premier onglet
   $notebook raise "spectrograph"

}

#------------------------------------------------------------
## @brief créé les widgets dans l'onglet
#
proc ::eshel::instrumentgui::fillSpectrographPage { frm visuNo } {
   variable private

   #--- name
   LabelEntry $frm.name  -label $::caption(eshel,instrument,spectrograph,name)\
      -labeljustify left -labelwidth 30  -width 30 -justify left \
      -validate key -validatecommand { ::eshel::validateString %W %V %P %s fits 1 70 ::eshel::instrumentgui::widget(error,spectroName) } \
      -textvariable ::eshel::instrumentgui::private(spectroName)
   #--- resolution
   LabelEntry $frm.grating  -label $::caption(eshel,instrument,spectrograph,grating)\
      -labeljustify left -labelwidth 30  -width 10 -justify right \
      -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s double 10.0 3000.0 ::eshel::instrumentgui::widget(error,grating) } \
      -textvariable ::eshel::instrumentgui::private(grating)
   #--- angle alpha
   LabelEntry $frm.alpha  -label $::caption(eshel,instrument,spectrograph,alpha)\
      -labeljustify left -labelwidth 30  -width 10 -justify right \
      -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s double 0.0 180.0 ::eshel::instrumentgui::widget(error,alpha) } \
      -textvariable ::eshel::instrumentgui::private(alpha)
   #--- angle beta
   LabelEntry $frm.beta  -label $::caption(eshel,instrument,spectrograph,beta)\
      -labeljustify left -labelwidth 30  -width 10 -justify right \
      -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s double 0.0 180.0 ::eshel::instrumentgui::widget(error,beta) } \
      -textvariable ::eshel::instrumentgui::private(beta)
   #--- angle gamma
   LabelEntry $frm.gamma  -label $::caption(eshel,instrument,spectrograph,gamma)\
      -labeljustify left -labelwidth 30  -width 10 -justify right \
      -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s double 0.0 180.0 ::eshel::instrumentgui::widget(error,gamma) } \
      -textvariable ::eshel::instrumentgui::private(gamma)
   #--- focale
   LabelEntry $frm.focale  -label $::caption(eshel,instrument,spectrograph,focale) \
      -labeljustify left -labelwidth 30 -width 10 -justify right \
      -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s double 0.0 1000.0 ::eshel::instrumentgui::widget(error,focale) } \
      -textvariable ::eshel::instrumentgui::private(focale)

   #--- liaison
   TitleFrame $frm.link -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,spectrograph,command)
      #--- Label de la liaison
      label $frm.link.label -text $::caption(eshel,instrument,spectrograph,linkLabel)
      Entry $frm.link.linkList  \
         -justify left -editable 0 \
         -textvariable ::eshel::instrumentgui::private(spectrograhLink)

      #--- Bouton de configuration de la liaison
      button $frm.link.configure -text $::caption(eshel,instrument,spectrograph,linkConfigure) -relief raised \
         -command {
            ::confLink::run ::eshel::instrumentgui::private(spectrograhLink) { vellemank8056  } $::caption(eshel,instrument,spectrograph)
         }

      #--- Commande du miroir de la bonnette
      label $frm.link.mirrorlabel -text $::caption(eshel,instrument,spectrograph,mirrorBit) -justify left
      set bitList [ list 1 2 3 4 5 6 7 8 ]
      ComboBox $frm.link.mirrorBit \
         -width 3                   \
         -height [ llength $bitList ] \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::eshel::instrumentgui::private(mirrorBit) \
         -editable 0                \
         -values $bitList

      #--- Commande de la lampe Flat
     label $frm.link.flatLabel -text $::caption(eshel,instrument,spectrograph,ledBit) -justify left
      set bitList [ list 1 2 3 4 5 6 7 8 ]
      ComboBox $frm.link.ledBit \
         -width 3                       \
         -height [ llength $bitList ]   \
         -relief sunken                 \
         -borderwidth 1                 \
         -textvariable ::eshel::instrumentgui::private(ledBit) \
         -editable 0                    \
         -values $bitList

      #--- Commande de la lampe Thar
      label $frm.link.tharlabel -text $::caption(eshel,instrument,spectrograph,tharBit) -justify left
      set bitList [ list 1 2 3 4 5 6 7 8 ]
      ComboBox $frm.link.tharBit \
         -width 3                   \
         -height [ llength $bitList ] \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::eshel::instrumentgui::private(tharBit) \
         -editable 0                \
         -values $bitList

      #--- Commande de la lampe Tungsten
      label $frm.link.tungstenLabel -text $::caption(eshel,instrument,spectrograph,tungstenBit) -justify left
      set bitList [ list 1 2 3 4 5 6 7 8 ]
      ComboBox $frm.link.tungstenBit \
         -width 3                       \
         -height [ llength $bitList ]   \
         -relief sunken                 \
         -borderwidth 1                 \
         -textvariable ::eshel::instrumentgui::private(tungstenBit) \
         -editable 0                    \
         -values $bitList

      button $frm.wizard -text "Assistant de configuration" -height 2 \
         -borderwidth 1 -padx 10 -pady 10 -command "::eshel::wizard::run $frm $visuNo"

      grid $frm.link.label       -in [$frm.link getframe] -row 0 -column 0 -sticky ewns
      grid $frm.link.linkList    -in [$frm.link getframe] -row 0 -column 1 -sticky ewns
      grid $frm.link.configure   -in [$frm.link getframe] -row 0 -column 2 -sticky ewns

      grid $frm.link.mirrorlabel -in [$frm.link getframe] -row 1 -column 0 -sticky w
      grid $frm.link.mirrorBit   -in [$frm.link getframe] -row 1 -column 1 -sticky ens
      grid $frm.link.flatLabel   -in [$frm.link getframe] -row 2 -column 0 -sticky w
      grid $frm.link.ledBit     -in [$frm.link getframe] -row 2 -column 1 -sticky ens
      grid $frm.link.tharlabel   -in [$frm.link getframe] -row 3 -column 0 -sticky w
      grid $frm.link.tharBit     -in [$frm.link getframe] -row 3 -column 1 -sticky ens
      grid $frm.link.tungstenLabel   -in [$frm.link getframe] -row 4 -column 0 -sticky w
      grid $frm.link.tungstenBit     -in [$frm.link getframe] -row 4 -column 1 -sticky ens

   pack $frm.name    -side top -anchor w -fill none -expand 0
   pack $frm.grating -side top -anchor w -fill none -expand 0
   pack $frm.alpha   -side top -anchor w -fill none -expand 0
   pack $frm.beta    -side top -anchor w -fill none -expand 0
   pack $frm.gamma   -side top -anchor w -fill none -expand 0
   pack $frm.focale  -side top -anchor w -fill none -expand 0
   pack $frm.link    -side top -anchor w -fill none -expand 0
   pack $frm.wizard  -side top -anchor w -fill none -expand 0 -pady 4 -ipadx 10

}

#------------------------------------------------------------
# fillCameraPage
#   cree les widgets dans l'onglet camera
#   return rien
#
proc ::eshel::instrumentgui::fillCameraPage { frm visuNo } {
   variable private

   frame $frm.camera
      #--- camera name
      LabelEntry $frm.camera.cameraName  -label $::caption(eshel,instrument,camera,cameraName) \
         -labeljustify left -labelwidth 20 -width 20 -justify left \
         -validate key -validatecommand { ::eshel::validateString %W %V %P %s fits 1 70 ::eshel::instrumentgui::widget(error,cameraName) } \
         -textvariable ::eshel::instrumentgui::private(cameraName)
      #--- camera type
      frame $frm.camera.config -borderwidth 0
         label $frm.camera.config.label -text $::caption(eshel,instrument,camera,cameraLabel) \
             -width 20 -justify left -anchor w
         set cameraList $::confCam::private(pluginLabelList)
         ComboBox $frm.camera.config.cameraLabel \
            -width 10 -height [ llength $cameraList ] \
            -relief sunken -borderwidth 1 -editable 0 \
            -textvariable ::eshel::instrumentgui::private(cameraLabel) \
            -modifycmd "::eshel::instrumentgui::onSelectCamera $visuNo" \
            -values $cameraList
         pack $frm.camera.config.label       -side left  -anchor w -fill none -expand 0
         pack $frm.camera.config.cameraLabel -side left  -anchor w -fill none -expand 0

      #--- binning
      frame $frm.camera.binning -borderwidth 0
         label $frm.camera.binning.label -text $::caption(eshel,instrument,camera,binning) -width 20 -justify left -anchor w
         set binningList [list "1x1" "2x2" "4x4"]
         ComboBox $frm.camera.binning.combo \
            -width [ ::tkutil::lgEntryComboBox $binningList ] \
            -height [ llength $binningList ] \
            -relief sunken -borderwidth 1 -editable 0 \
            -textvariable ::eshel::instrumentgui::private(binning) \
            -values $binningList
         pack $frm.camera.binning.label -side left  -anchor w -fill none -expand 0
         pack $frm.camera.binning.combo -side left  -anchor w -fill none -expand 0

      #--- pixel size
      LabelEntry $frm.camera.pixelSize  -label $::caption(eshel,instrument,camera,pixelSize) \
         -labeljustify left -labelwidth 20 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s double 0.001 0.100 ::eshel::instrumentgui::widget(error,pixelSize) } \
         -textvariable ::eshel::instrumentgui::private(pixelSize)
      #--- image width
      LabelEntry $frm.camera.width  -label $::caption(eshel,instrument,camera,width) \
         -labeljustify left -labelwidth 20 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 10000 ::eshel::instrumentgui::widget(error,width) } \
         -textvariable ::eshel::instrumentgui::private(width)
      #--- image height
      LabelEntry $frm.camera.height  -label $::caption(eshel,instrument,camera,height) \
         -labeljustify left -labelwidth 20 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 10000 ::eshel::instrumentgui::widget(error,height) } \
         -textvariable ::eshel::instrumentgui::private(height)

      #--- crop window
      frame $frm.camera.window
         LabelEntry $frm.camera.window.x1  -label $::caption(eshel,instrument,camera,window) \
            -labeljustify left -labelwidth 20 -width 5 -justify right \
            -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 10000 ::eshel::instrumentgui::widget(error,x1) } \
            -textvariable ::eshel::instrumentgui::private(x1)
         Entry $frm.camera.window.y1  -text "" \
            -width 5 -justify right \
            -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 10000 ::eshel::instrumentgui::widget(error,y1) } \
            -textvariable ::eshel::instrumentgui::private(y1)
         Entry $frm.camera.window.x2  -text "" \
            -width 5 -justify right \
            -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 10000 ::eshel::instrumentgui::widget(error,x2) } \
            -textvariable ::eshel::instrumentgui::private(x2)
         Entry $frm.camera.window.y2  -text "" \
            -width 5 -justify right \
            -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 10000 ::eshel::instrumentgui::widget(error,y2) } \
            -textvariable ::eshel::instrumentgui::private(y2)
         pack $frm.camera.window.x1 -side left
         pack $frm.camera.window.y1 -side left
         pack $frm.camera.window.x2 -side left
         pack $frm.camera.window.y2 -side left

      grid $frm.camera.cameraName  -row 0 -column 0 -columnspan 2 -sticky wn
      grid $frm.camera.config      -row 1 -column 0 -columnspan 2 -sticky wn
      grid $frm.camera.binning     -row 2 -column 0 -columnspan 2 -sticky wn
      grid $frm.camera.pixelSize   -row 3 -column 0 -columnspan 2 -sticky wn
      grid $frm.camera.width       -row 4 -column 0 -columnspan 2 -sticky wn
      grid $frm.camera.height      -row 5 -column 0 -columnspan 2 -sticky wn
      grid $frm.camera.window      -row 6 -column 0 -columnspan 2 -sticky wn

      grid rowconfig    $frm.camera 7 -weight 0
      grid columnconfig $frm.camera 0 -weight 1
      grid columnconfig $frm.camera 1 -weight 1
      grid columnconfig $frm.camera 2 -weight 1

   #--- liste des pixels chauds a reparer
   TitleFrame $frm.hotpixel -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,camera,hotPixel)
      checkbutton $frm.hotpixel.enabled  -justify left -text $::caption(eshel,instrument,camera,hotPixelEnabled) -variable ::eshel::instrumentgui::private(hotPixelEnabled)
      scrollbar $frm.hotpixel.ysb -command "$frm.hotpixel.text yview"
      text $frm.hotpixel.text -yscrollcommand [list $frm.hotpixel.ysb set] \
         -wrap word -width 15
      pack $frm.hotpixel.enabled -in [$frm.hotpixel getframe] -side top -anchor w -fill x -expand 0
      pack $frm.hotpixel.text -in [$frm.hotpixel getframe] -side left -anchor w -fill both -expand 1
      pack $frm.hotpixel.ysb -in [$frm.hotpixel getframe]  -side left -anchor w -fill y -expand 1

   #--- Parametres de reparation des cosmiques
   TitleFrame $frm.cosmic -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,camera,cosmic)
      checkbutton $frm.cosmic.enabled  -justify left -text $::caption(eshel,instrument,camera,cosmicEnabled) -variable ::eshel::instrumentgui::private(cosmicEnabled)
      LabelEntry $frm.cosmic.threshold -label $::caption(eshel,instrument,camera,cosmicThreshold) \
         -labeljustify left -labelwidth 20 -width 10 -justify right \
            -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 100 500 ::eshel::instrumentgui::widget(error,cosmicThreshold) } \
         -textvariable ::eshel::instrumentgui::private(cosmicThreshold)

      pack $frm.cosmic.enabled -in [$frm.cosmic getframe] -side top -anchor w -fill x -expand 0
      pack $frm.cosmic.threshold -in [$frm.cosmic getframe] -side top -anchor w -fill x -expand 0

   grid $frm.camera   -in $frm  -row 0 -column 0 -columnspan 2 -sticky ewn
   grid $frm.hotpixel -in $frm  -row 1 -column 0 -columnspan 1 -sticky ewns
   grid $frm.cosmic   -in $frm  -row 1 -column 1 -columnspan 1 -sticky ewn

   grid rowconfig    $frm 1 -weight 1
   grid columnconfig $frm 0 -weight 1
   grid columnconfig $frm 1 -weight 1
   grid columnconfig $frm 2 -weight 1

}

#------------------------------------------------------------
# fillTelescopePage
#   cree les widgets dans l'onglet camera
#
proc ::eshel::instrumentgui::fillTelescopePage { frm visuNo } {
   variable private

   #--- telescope name
   LabelEntry $frm.telescopeName  -label $::caption(eshel,instrument,telescope,telescopeName) \
      -labeljustify left -labelwidth 20 -width 30 -justify left \
      -validate key -validatecommand { ::eshel::validateString %W %V %P %s fits 0 70 ::eshel::instrumentgui::widget(error,telescopeName) } \
      -textvariable ::eshel::instrumentgui::private(telescopeName)
   pack $frm.telescopeName -side top -fill none -anchor nw  -expand 0

}

#------------------------------------------------------------
# fillReferencePage
#   cree les widgets dans l'onglet reference
#
proc ::eshel::instrumentgui::fillReferencePage { frm visuNo } {
   variable private

   set private(referencePage) $frm
   set private(referenceTable) $frm.table.table

   #--- table des references
   TitleFrame $frm.table  -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,reference)
      scrollbar $frm.table.ysb -command "$private(referenceTable) yview"
      scrollbar $frm.table.xsb -command "$private(referenceTable) xview" -orient horizontal

      #--- Table des reference
      ::tablelist::tablelist $private(referenceTable) \
         -columns [list 0 $::caption(eshel,instrument,reference,stateColumn) left 0 $::caption(eshel,instrument,reference,nameColumn) left] \
         -xscrollcommand [list $frm.table.xsb set] \
         -yscrollcommand [list $frm.table.ysb set] \
         -exportselection 0 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      #--- j'ajoute l'option -stretchable pour que la colonne s'etire jusqu'au bord droit de la table
      #--- j'ajoute l'option -sortmode dictionary pour le tri soit independant de la casse
      $private(referenceTable) columnconfigure 0 -name state -editwindow checkbutton
      $private(referenceTable) columnconfigure 1 -name name -stretchable 1 -sortmode dictionary

      bind $private(referenceTable) <<ListboxSelect>>  [list ::eshel::instrumentgui::onSelectReference $visuNo]

      #--- boutons de gestion des references
      frame $frm.table.button  -borderwidth 0 -relief flat
         #--- Bouton create new reference
         Button $frm.table.button.create -text "$::caption(eshel,instrument,reference,createReference)" -command "::eshel::instrumentgui::createReference $visuNo"
         pack $frm.table.button.create -side top -fill x -expand 0 -padx 20 -pady 2

         #--- Bouton copy reference
         Button $frm.table.button.copy -text "$::caption(eshel,instrument,reference,copy)" -command "::eshel::instrumentgui::copyReference $visuNo"
         pack $frm.table.button.copy  -side top -fill x -expand 0 -padx 20 -pady 2

         #--- Bouton delete reference
         Button $frm.table.button.delete -text "$::caption(eshel,instrument,reference,delete)" -command "::eshel::instrumentgui::deleteReference $visuNo"
         pack $frm.table.button.delete -side top -fill x -expand 0 -padx 20 -pady 2

      #--- je place la table et les scrollbars dans la frame
      grid $private(referenceTable) -in [$frm.table getframe] -row 0 -column 0 -sticky ewns
      grid $frm.table.ysb  -in [$frm.table getframe] -row 0 -column 1 -sticky nsew
      grid $frm.table.xsb  -in [$frm.table getframe] -row 1 -column 0 -sticky ew
      grid $frm.table.button  -in [$frm.table getframe] -row 0 -column 2 -rowspan 2  -sticky ewns
      grid rowconfig    [$frm.table getframe] 0 -weight 1
      grid columnconfig [$frm.table getframe] 0 -weight 1
      grid columnconfig [$frm.table getframe] 2 -weight 1

   ###pack $frm.table -side left -fill both -expand 1
   grid $frm.table -row 0 -column 0 -columnspan 2 -sticky ewns

   ##pack $frm.button -side left -fill x -expand 1

   #--- modification des actions d'une sequence de reference
   TitleFrame $frm.edit  -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,reference,edit)
      set private(actionTable) $frm.edit.table
      scrollbar $frm.edit.ysb -command "$private(actionTable) yview"
      scrollbar $frm.edit.xsb -command "$private(actionTable) xview" -orient horizontal

      #--- Table des reference
      ::tablelist::tablelist $private(actionTable) \
         -columns [list 0 $::caption(eshel,instrument,reference,actionColumn) left 0 $::caption(eshel,instrument,reference,parameterColumn) left] \
         -xscrollcommand [list $frm.edit.xsb set] \
         -yscrollcommand [list $frm.edit.ysb set] \
         -exportselection 0 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      $private(actionTable) columnconfigure 0 -name actionType
      $private(actionTable) columnconfigure 1 -name parameters  -stretchable 1

      bind $private(actionTable) <<ListboxSelect>>  [list ::eshel::instrumentgui::onSelectAction $visuNo]

      frame $frm.edit.action  -borderwidth 0 -relief flat
         frame $frm.edit.action.buttons  -borderwidth 0 -relief flat
         Button $frm.edit.action.create -text "$::caption(eshel,instrument,reference,createAction)" -command "::eshel::instrumentgui::createAction $visuNo"
         Button $frm.edit.action.copy -text "$::caption(eshel,instrument,reference,copy)" -command "::eshel::instrumentgui::copyAction $visuNo"
         Button $frm.edit.action.delete -text "$::caption(eshel,instrument,reference,delete)" -command "::eshel::instrumentgui::deleteAction $visuNo"
         Button $frm.edit.action.moveUp  -text "$::caption(eshel,instrument,reference,moveUp)" -command "::eshel::instrumentgui::moveActionUp $visuNo"
         Button $frm.edit.action.moveDown -text "$::caption(eshel,instrument,reference,moveDown)" -command "::eshel::instrumentgui::moveActionDown $visuNo"

         Label $frm.edit.action.actionLabel  -text $::caption(eshel,instrument,reference,actionType)
         ComboBox $frm.edit.action.action \
            -width 6                  \
            -height [ llength $private(actionTypeList) ] \
            -relief sunken             \
            -borderwidth 1             \
            -textvariable ::eshel::instrumentgui::private(action,type) \
            -editable 0                \
            -modifycmd  "::eshel::instrumentgui::onSelectActionType $visuNo" \
            -values $private(actionTypeList)

         Label $frm.edit.action.expTimeLabel  -text $::caption(eshel,instrument,reference,expTime)
         set list_combobox {0 0.5 1 3 5 10 15 30 60 120 180 300 600 900 }
         ComboBox $frm.edit.action.expTime \
            -width 4  -height [ llength $list_combobox ] \
            -relief sunken -borderwidth 1 -editable 1 \
            -textvariable ::eshel::instrumentgui::private(action,expTime) \
            -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s double 0 10000 ::eshel::instrumentgui::private(error,action,expTime) } \
            -values $list_combobox

         Label $frm.edit.action.expNbLabel -text $::caption(eshel,instrument,reference,expNb)
         set list_combobox [list 1 2 3 5 10 15 20 ]
         ComboBox $frm.edit.action.expNb \
            -width 4 -height [ llength $list_combobox ] \
            -relief sunken -borderwidth 1 -editable 1 \
            -textvariable ::eshel::instrumentgui::private(action,expNb) \
            -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 1000 ::eshel::instrumentgui::private(error,action,expNb) } \
            -values $list_combobox

         Button $frm.edit.action.apply -text "$::caption(eshel,instrument,reference,apply)" -command "::eshel::instrumentgui::modifyAction $visuNo"

         ###pack $frm.edit.action.apply -side bottom -fill none -expand 0 -padx 2
         ###
         ###pack $frm.edit.action.create -side top -fill x -expand 0 -padx 10
         ###pack $frm.edit.action.copy   -side top -fill  x -expand 0 -padx 10
         ###pack $frm.edit.action.delete -side top -fill x -expand 0 -padx 10
         ###pack $frm.edit.action.action -side top -fill x -expand 0 -padx 2
         ###pack $frm.edit.action.expTime -side top -fill x -expand 0 -padx 2
         ###pack $frm.edit.action.expNb  -side top -fill x -expand 0 -padx 2

         ###grid $frm.edit.action.create  -row 0 -column 0 -columnspan 2 -sticky nwe -padx 20
         ###grid $frm.edit.action.copy    -row 1 -column 0 -columnspan 2 -sticky nwe -padx 20
         ### grid $frm.edit.action.delete  -row 2 -column 0 -columnspan 2 -sticky nwe -padx 20
         pack $frm.edit.action.create  -in $frm.edit.action.buttons -side left -fill none -expand 0 -padx 2
         pack $frm.edit.action.copy    -in $frm.edit.action.buttons -side left -fill none -expand 0 -padx 2
         pack $frm.edit.action.delete  -in $frm.edit.action.buttons -side left -fill none -expand 0 -padx 2
         pack $frm.edit.action.moveUp  -in $frm.edit.action.buttons -side left -fill none -expand 0 -padx 2
         pack $frm.edit.action.moveDown -in $frm.edit.action.buttons -side left -fill none -expand 0 -padx 2
         grid $frm.edit.action.buttons  -row 0 -column 0 -columnspan 2 -sticky nwe

         grid $frm.edit.action.actionLabel  -row 3 -column 0 -sticky w
         grid $frm.edit.action.action       -row 3 -column 1 -sticky ew
         grid $frm.edit.action.expTimeLabel  -row 4 -column 0 -sticky w
         grid $frm.edit.action.expTime       -row 4 -column 1 -sticky ew
         grid $frm.edit.action.expNbLabel  -row 5 -column 0 -sticky w
         grid $frm.edit.action.expNb       -row 5 -column 1 -sticky ew

         grid $frm.edit.action.apply -row 7 -column 0 -columnspan 2 -sticky ew -padx 20

      #--- je place la table et les scrollbars dans la frame
      grid $private(actionTable) -in [$frm.edit getframe] -row 0 -column 0 -sticky ewns
      grid $frm.edit.ysb -in [$frm.edit getframe] -row 0 -column 1 -sticky nsew
      grid $frm.edit.xsb -in [$frm.edit getframe] -row 1 -column 0 -sticky ew
      grid $frm.edit.action -in [$frm.edit getframe] -row 0 -column 2 -rowspan 2 -sticky ewn
      grid rowconfig    [$frm.edit getframe] 0 -weight 1
      grid columnconfig [$frm.edit getframe] 0 -weight 1

   ###pack $frm.edit -side bottom -fill x -expand 1
   grid $frm.edit -row 1 -column 0 -columnspan 2 -sticky ewns

   grid rowconfig    $frm 0 -weight 1
   grid columnconfig $frm 0 -weight 1
   grid columnconfig $frm 1 -weight 1

   #--- j'ajoute les references dans la table
   foreach referencePath [array names ::conf eshel,instrument,reference,*,name] {
      set referenceId [lindex [split $referencePath "," ] 3]
      set referenceName   $::conf(eshel,instrument,reference,$referenceId,name)
      set referenceState  $::conf(eshel,instrument,reference,$referenceId,state)
      set private($referenceId,actionList) $::conf(eshel,instrument,reference,$referenceId,actionList)
      addReference end $referenceId $referenceName $referenceState
   }
   selectReference $visuNo ""

}

#------------------------------------------------------------
# fillProcessPage
#   cree les widgets dans l'onglet camera
#
proc ::eshel::instrumentgui::fillProcessPage { frm visuNo } {
   variable private


   #--- detection des ordres
   TitleFrame $frm.detection -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,process,detectionOrder)
      LabelEntry $frm.detection.minOrder  -label $::caption(eshel,instrument,process,minOrder)\
         -labeljustify left -labelwidth 30 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 60 ::eshel::instrumentgui::widget(error,minOrder) } \
         -textvariable ::eshel::instrumentgui::private(minOrder)
      pack $frm.detection.minOrder -in [$frm.detection getframe] -side top  -anchor w -fill none -expand 1 -pady 2
      LabelEntry $frm.detection.maxOrder  -label $::caption(eshel,instrument,process,maxOrder)\
         -labeljustify left -labelwidth 30 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 60 ::eshel::instrumentgui::widget(error,maxOrder) } \
         -textvariable ::eshel::instrumentgui::private(maxOrder)
      pack $frm.detection.maxOrder -in [$frm.detection getframe] -side top  -anchor w -fill none -expand 1 -pady 2
      LabelEntry $frm.detection.wideOrder  -label $::caption(eshel,instrument,process,wideOrder)\
         -labeljustify left -labelwidth 30 -wraplength 180 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 100 ::eshel::instrumentgui::widget(error,wideOrder) } \
         -textvariable ::eshel::instrumentgui::private(wideOrder)
      pack $frm.detection.wideOrder -in [$frm.detection getframe] -side top  -anchor w -fill none -expand 1 -pady 2
      LabelEntry $frm.detection.boxWide  -label $::caption(eshel,instrument,process,boxWide)\
         -labeljustify left -labelwidth 30 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 100 ::eshel::instrumentgui::widget(error,boxWide) } \
         -textvariable ::eshel::instrumentgui::private(boxWide)
      pack $frm.detection.boxWide -in [$frm.detection getframe] -side top  -anchor w -fill none -expand 1 -pady 2

   grid $frm.detection -in $frm -row 0 -column 0 -sticky nw

   #--- ordre de reference
   TitleFrame $frm.reference -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,process,referenceOrder)
      LabelEntry $frm.reference.refNum  -label $::caption(eshel,instrument,process,refNum)\
         -labeljustify left -labelwidth 30 -wraplength 180 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 54 ::eshel::instrumentgui::widget(error,refNum) } \
         -textvariable ::eshel::instrumentgui::private(refNum)
      LabelEntry $frm.reference.refY  -label $::caption(eshel,instrument,process,refY)\
         -labeljustify left -labelwidth 30 -wraplength 180 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 9999 ::eshel::instrumentgui::widget(error,refY) } \
         -textvariable ::eshel::instrumentgui::private(refY)
      LabelEntry $frm.reference.refX  -label $::caption(eshel,instrument,process,refX)\
         -labeljustify left -labelwidth 30 -wraplength 180 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 9999 ::eshel::instrumentgui::widget(error,refX) } \
         -textvariable ::eshel::instrumentgui::private(refX)
      LabelEntry $frm.reference.refLambda  -label $::caption(eshel,instrument,process,refLambda)\
         -labeljustify left -labelwidth 30 -wraplength 180 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s double 3000 10000 ::eshel::instrumentgui::widget(error,refLambda) } \
         -textvariable ::eshel::instrumentgui::private(refLambda)
      LabelEntry $frm.reference.threshold  -label $::caption(eshel,instrument,process,threshold)\
         -labeljustify left -labelwidth 30 -width 10 -justify right \
         -validate key -validatecommand { ::eshel::validateNumber %W %V %P %s integer 0 65535 ::eshel::instrumentgui::widget(error,threshold) } \
         -textvariable ::eshel::instrumentgui::private(threshold)

      Button $frm.reference.findOrder -text $::caption(eshel,instrument,process,findOrder) -state disabled

      pack $frm.reference.refNum -in [$frm.reference getframe] -side top  -anchor w -fill none -expand 1 -pady 2
      pack $frm.reference.refY -in [$frm.reference getframe] -side top  -anchor e -fill none -expand 1 -pady 2
      pack $frm.reference.refLambda -in [$frm.reference getframe] -side top  -anchor w -fill none -expand 1 -pady 2
      pack $frm.reference.refX -in [$frm.reference getframe] -side top  -anchor w -fill none -expand 1 -pady 2
      pack $frm.reference.threshold -in [$frm.reference getframe] -side top  -anchor w -fill none -expand 1 -pady 2
      pack $frm.reference.findOrder  -in [$frm.reference getframe] -side top -fill none -expand 0 -pady 10 -pady 2

   grid $frm.reference -in $frm -row 1 -column 0 -sticky nw

   #--- liste des raies
   TitleFrame $frm.lineList -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,process,lineList)
      scrollbar $frm.lineList.ysb -command "$frm.lineList.text yview"
      text $frm.lineList.text -yscrollcommand [list $frm.lineList.ysb set] \
         -wrap word -width 13 -height 10

      grid $frm.lineList.text -in [$frm.lineList getframe] -row 0 -column 0 -sticky wns
      grid $frm.lineList.ysb  -in [$frm.lineList getframe] -row 0 -column 1 -sticky wns

      grid rowconfig    [$frm.lineList getframe] 0 -weight 1
      grid columnconfig [$frm.lineList getframe] 0 -weight 1
      grid columnconfig [$frm.lineList getframe] 1 -weight 0

   grid $frm.lineList -in $frm -row 0 -column 1 -rowspan 3 -sticky wns

   #--- definition des ordres
   TitleFrame $frm.definition -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,process,orderDefinition)
      scrollbar $frm.definition.ysb -command "$frm.definition.table yview"
      set columnList [list]
      lappend columnList 0 $::caption(eshel,instrument,process,orderNum)    center
      lappend columnList 0 $::caption(eshel,instrument,process,leftMargin)  center
      lappend columnList 0 $::caption(eshel,instrument,process,rightMargin) center
      lappend columnList 0 $::caption(eshel,instrument,process,slant)       center

      ::tablelist::tablelist $frm.definition.table \
         -columns $columnList \
         -yscrollcommand [list $frm.definition.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -forceeditendcommand  0 \
         -activestyle none

      $frm.definition.table columnconfigure 0 -editable no
      $frm.definition.table columnconfigure 1 -editable yes
      $frm.definition.table columnconfigure 2 -editable yes
      $frm.definition.table columnconfigure 3 -editable yes

      grid $frm.definition.table -in [$frm.definition getframe] -row 0 -column 0 -sticky nsew
      grid $frm.definition.ysb   -in [$frm.definition getframe] -row 0 -column 1 -sticky wns

      grid rowconfig    [$frm.definition getframe] 0 -weight 1
      grid columnconfig [$frm.definition getframe] 0 -weight 1
      grid columnconfig [$frm.definition getframe] 1 -weight 0

   grid $frm.definition -in $frm -row 0 -column 2 -rowspan 3 -sticky ewns

   #--- Limite lambda des ordres
   TitleFrame $frm.cropLambda -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,process,cropLambda)
      scrollbar $frm.cropLambda.ysb -command "$frm.cropLambda.table yview"
      set columnList [list]
      lappend columnList 0 $::caption(eshel,instrument,process,orderNum)    center
      lappend columnList 0 $::caption(eshel,instrument,process,minLambda)  center
      lappend columnList 0 $::caption(eshel,instrument,process,maxLambda) center

      ::tablelist::tablelist $frm.cropLambda.table \
         -columns $columnList \
         -yscrollcommand [list $frm.cropLambda.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -forceeditendcommand  0 \
         -activestyle none

      $frm.cropLambda.table columnconfigure 0 -editable no
      $frm.cropLambda.table columnconfigure 1 -editable yes
      $frm.cropLambda.table columnconfigure 2 -editable yes

      grid $frm.cropLambda.table -in [$frm.cropLambda getframe] -row 0 -column 0 -sticky nsew
      grid $frm.cropLambda.ysb   -in [$frm.cropLambda getframe] -row 0 -column 1 -sticky wns

      grid rowconfig    [$frm.cropLambda getframe] 0 -weight 1
      grid columnconfig [$frm.cropLambda getframe] 0 -weight 1
      grid columnconfig [$frm.cropLambda getframe] 1 -weight 0

   grid $frm.cropLambda -in $frm -row 0 -column 3 -rowspan 3 -sticky ewns

   grid rowconfig    $frm 0 -weight 0
   grid rowconfig    $frm 1 -weight 0
   grid rowconfig    $frm 2 -weight 1
   grid columnconfig $frm 0 -weight 0
   grid columnconfig $frm 1 -weight 0
   grid columnconfig $frm 2 -weight 1
   grid columnconfig $frm 3 -weight 1


}

####------------------------------------------------------------
#### fillProcessPage
####   cree les widgets dans l'onglet camera
####   return rien
#
###proc ::eshel::instrumentgui::fillObjectProcessPage { frm visuNo } {
###   variable private
###
###   #--- flatfield
###   checkbutton $frm.flatFieldEnabled  -justify left \
###      -text $::caption(eshel,instrument,process,flatFieldEnabled) \
###      -variable ::eshel::instrumentgui::private(flatFieldEnabled)
###
###   #--- reponse instrumentale
###   TitleFrame $frm.response -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,process,response,title)
###      radiobutton $frm.response.manual -highlightthickness 0 -padx 0 -pady 0 -state normal \
###         -text $::caption(eshel,instrument,process,response,manual) \
###         -value "MANUAL" \
###         -variable ::eshel::instrumentgui::private(responseOption) \
###         -command  "::eshel::instrumentgui::onSelectResponseOption $visuNo"
###
###      #--- Bouton selection de la reponse isntrumentale
###      frame  $frm.response.select -borderwidth 0
###         entry $frm.response.select.entry   -textvariable ::eshel::instrumentgui::private(responseFileName) -state readonly -justify left
###         pack $frm.response.select.entry   -side left -fill x -expand 1 -padx 8
###         Button $frm.response.select.button -text "..." -command "::eshel::instrumentgui::selectResponseFileName $visuNo"
###         pack $frm.response.select.button -side left -fill none -expand 0 -padx 2
###
###      radiobutton $frm.response.auto -highlightthickness 0 -padx 0 -pady 0 -state normal \
###         -text $::caption(eshel,instrument,process,response,auto) \
###         -value "AUTO" \
###         -variable ::eshel::instrumentgui::private(responseOption) \
###         -command  "::eshel::instrumentgui::onSelectResponseOption $visuNo"
###      radiobutton $frm.response.none -highlightthickness 0 -padx 0 -pady 0 -state normal \
###         -text $::caption(eshel,instrument,process,response,none) \
###         -value "NONE" \
###         -variable ::eshel::instrumentgui::private(responseOption) \
###         -command  "::eshel::instrumentgui::onSelectResponseOption $visuNo"
###
###      pack $frm.response.manual -in [$frm.response getframe] -side top  -anchor w -fill none -expand 0
###      pack $frm.response.select -in [$frm.response getframe] -side top  -anchor w -fill x    -expand 1
###      pack $frm.response.auto -in [$frm.response getframe] -side top  -anchor w -fill none -expand 0
###      pack $frm.response.none -in [$frm.response getframe] -side top  -anchor w -fill none -expand 0
###
###   grid $frm.flatFieldEnabled -in $frm -row 0 -column 0 -sticky w -pady 4
###   grid $frm.response         -in $frm -row 1 -column 0 -sticky ewn
###
###   grid rowconfig    $frm 0 -weight 0
###   grid rowconfig    $frm 1 -weight 1
###   grid columnconfig $frm 0 -weight 1
###}

#----------------------------------------------------------------------------
# onSelectConfig
#    met a jour les variables et les widgets quand on selectionne une configuration
#    dans la combobox
#
proc ::eshel::instrumentgui::onSelectConfig { visuNo } {
   variable private

   set tkCombo $private($visuNo,frm).config.combo

   #--- je recupere l'identifiant de la configuration correspondant la ligne selectionne dans la combobox
   set configId [::eshel::instrument::getConfigIdentifiant [$tkCombo get]]

   #--- je copie les parametres dans les variables de widgets
   ###setConfig $visuNo $configId
   set catchResult [ catch {
      ::eshel::instrument::setCurrentConfig $configId
   }]
   if { $catchResult !=0 } {
     ::tkutil::displayErrorInfo $::caption(eshel,instrument,importConfigTitle)
     return
   }

   #--- je copie les parametres dans les variables des widgets

   #--- widgets spectrographe
   set private(spectroName) $::conf(eshel,instrument,config,$configId,spectroName)
   set private(grating)    $::conf(eshel,instrument,config,$configId,grating)
   set private(alpha)      $::conf(eshel,instrument,config,$configId,alpha)
   set private(beta)       $::conf(eshel,instrument,config,$configId,beta)
   set private(gamma)      $::conf(eshel,instrument,config,$configId,gamma)
   set private(focale)     $::conf(eshel,instrument,config,$configId,focale)
   set private(spectrograhLink)   $::conf(eshel,instrument,config,$configId,spectrograhLink)
   set private(mirrorBit)  $::conf(eshel,instrument,config,$configId,mirror,bit)
   set private(ledBit)     $::conf(eshel,instrument,config,$configId,led,bit)
   set private(tharBit)    $::conf(eshel,instrument,config,$configId,thar,bit)
   set private(tungstenBit)   $::conf(eshel,instrument,config,$configId,tungsten,bit)
   #--- widgets telescope
   set private(telescopeName) $::conf(eshel,instrument,config,$configId,telescopeName)
   #--- widgets camera
   set private(cameraName) $::conf(eshel,instrument,config,$configId,cameraName)
   set private(cameraLabel) $::conf(eshel,instrument,config,$configId,cameraLabel)
   set private(binning)    "[lindex $::conf(eshel,instrument,config,$configId,binning) 0]x[lindex $::conf(eshel,instrument,config,$configId,binning) 1]"
   set private(pixelSize)  $::conf(eshel,instrument,config,$configId,pixelSize)
   set private(width)      $::conf(eshel,instrument,config,$configId,width)
   set private(height)     $::conf(eshel,instrument,config,$configId,height)
   set private(x1)         $::conf(eshel,instrument,config,$configId,x1)
   set private(y1)         $::conf(eshel,instrument,config,$configId,y1)
   set private(x2)         $::conf(eshel,instrument,config,$configId,x2)
   set private(y2)         $::conf(eshel,instrument,config,$configId,y2)
   #--- widgets traitement
   set private(refNum)     $::conf(eshel,instrument,config,$configId,refNum)
   set private(refX)       $::conf(eshel,instrument,config,$configId,refX)
   set private(refY)       $::conf(eshel,instrument,config,$configId,refY)
   set private(refLambda)  $::conf(eshel,instrument,config,$configId,refLambda)
   set private(wideOrder)  $::conf(eshel,instrument,config,$configId,wideOrder)
   set private(threshold)  $::conf(eshel,instrument,config,$configId,threshold)
   set private(boxWide)    $::conf(eshel,instrument,config,$configId,boxWide)
   set private(minOrder)   $::conf(eshel,instrument,config,$configId,minOrder)
   set private(maxOrder)   $::conf(eshel,instrument,config,$configId,maxOrder)

   set private(hotPixelEnabled)   $::conf(eshel,instrument,config,$configId,hotPixelEnabled)
   set private(cosmicEnabled)     $::conf(eshel,instrument,config,$configId,cosmicEnabled)
   set private(cosmicThreshold)   $::conf(eshel,instrument,config,$configId,cosmicThreshold)
   ###set private(flatFieldEnabled)  $::conf(eshel,instrument,config,$configId,flatFieldEnabled)
   ###set private(responseOption)    $::conf(eshel,instrument,config,$configId,responseOption)
   ###set private(responseFileName)  [file nativename $::conf(eshel,instrument,config,$configId,responseFileName)]

   #--- j'affiche la liste des pixels chauds
   set tkHotPixelList [$private($visuNo,frm).notebook getframe "camera"].hotpixel.text
   $tkHotPixelList delete 1.0 end
   foreach hotpixel $::conf(eshel,instrument,config,$configId,hotPixelList) {
      #--- j'affiche une raie par ligne
      $tkHotPixelList insert end "$hotpixel\n"
   }

   #--- j'affiche la liste des raies
   set tkLineList [$private($visuNo,frm).notebook getframe "process"].lineList.text
   $tkLineList delete 1.0 end
   foreach line $::conf(eshel,instrument,config,$configId,lineList) {
      #--- j'affiche une raie par ligne
      $tkLineList insert end "$line\n"
   }

   #--- j'affiche la definition des ordres
   set tkOrderDefinition [$private($visuNo,frm).notebook getframe "process"].definition.table
   $tkOrderDefinition delete 0 end
   foreach definition $::conf(eshel,instrument,config,$configId,orderDefinition) {
      $tkOrderDefinition insert end $definition
   }

   #--- j'affiche la limite  des ordres
   set tkCropLambda [$private($visuNo,frm).notebook getframe "process"].cropLambda.table
   $tkCropLambda delete 0 end
   foreach cropLambda $::conf(eshel,instrument,config,$configId,cropLambda) {
      $tkCropLambda insert end $cropLambda
   }

   #--- je memorise l'identifant de la nouvelle configuration
   #--- attention : cette variable est surveillee par listener
   set ::conf(eshel,currentInstrument) $configId

}

#----------------------------------------------------------------------------
# onSelectCamera
#    met a jour les variables et les widgets quand on selectionne une camera
#
proc ::eshel::instrumentgui::onSelectCamera { visuNo } {
   variable private

   set index [lsearch $::confCam::private(pluginLabelList) $private(cameraLabel)]
   set private(cameraNamespace) [lindex $::confCam::private(pluginNamespaceList) $index]
   set camItem [::confVisu::getCamItem $visuNo]

   if { [ ::confCam::getPluginProperty $camItem hasBinning ] == "1" } {
       set binningList [ ::confCam::getPluginProperty $camItem binningList ]
   } else {

   }
}

#----------------------------------------------------------------------------
# cmdApply
#    met a jour les variables et les widgets quand on applique les modifications d'une configuration
#
proc ::eshel::instrumentgui::cmdApply { visuNo } {
   variable private
   variable widget

   set private(closeWindow) 1

   #--- je controle les donnees et je cumule les messages d'erreur
   set errorMessage ""
   foreach name [array names ::eshel::instrumentgui::widget error,*] {
      #--- je recupere le nom de la valeur
      set valueName [lindex [split $name "," ] 1]
      switch $valueName {
         spectroName -
         grating -
         alpha -
         beta -
         alpha -
         gamma -
         focale {
            append errorMessage "$::caption(eshel,instrument,spectrograph,$valueName): $widget(error,$valueName)\n"
         }

         cameraName -
         width -
         height -
         cosmicThreshold -
         pixelSize {
            append errorMessage "$::caption(eshel,instrument,camera,$valueName): $widget(error,$valueName)\n"
         }
         x1 -
         y1 -
         x2 -
         y2 {
            append errorMessage "$::caption(eshel,instrument,camera,window): $widget(error,$valueName)\n"
         }

         refNum -
         refX -
         refY -
         refLambda -
         wideOrder -
         threshold -
         boxWide -
         minOrder -
         maxOrder {
            append errorMessage "$::caption(eshel,instrument,process,$valueName): $widget(error,$valueName)\n"
         }
         default {
            append errorMessage "$widget(error,$valueName)\n"
         }
      }
   }
   if { $errorMessage != "" } {
      #--- j'affiche les erreurs
      tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
      #--- j'annule la fermeture de la fenetre
      set private(closeWindow) 0
      return
   }
   set configId $::conf(eshel,currentInstrument)

   set ::conf(eshel,instrument,config,$configId,spectroName)   $private(spectroName)
   set ::conf(eshel,instrument,config,$configId,grating)       $private(grating)
   set ::conf(eshel,instrument,config,$configId,alpha)         $private(alpha)
   set ::conf(eshel,instrument,config,$configId,beta)          $private(beta)
   set ::conf(eshel,instrument,config,$configId,gamma)         $private(gamma)
   set ::conf(eshel,instrument,config,$configId,focale)        $private(focale)
   set ::conf(eshel,instrument,config,$configId,spectrograhLink) $private(spectrograhLink)
   set ::conf(eshel,instrument,config,$configId,mirror,bit)    $private(mirrorBit)
   set ::conf(eshel,instrument,config,$configId,led,bit)       $private(ledBit)
   set ::conf(eshel,instrument,config,$configId,thar,bit)      $private(tharBit)
   set ::conf(eshel,instrument,config,$configId,tungsten,bit)  $private(tungstenBit)

   set ::conf(eshel,instrument,config,$configId,cameraName)    $private(cameraName)
   set ::conf(eshel,instrument,config,$configId,cameraLabel)   $private(cameraLabel)
   set ::conf(eshel,instrument,config,$configId,binning)       [list [string range $private(binning) 0 0] [string range $private(binning) 2 2]]
   set ::conf(eshel,instrument,config,$configId,pixelSize)     $private(pixelSize)
   set ::conf(eshel,instrument,config,$configId,width)         $private(width)
   set ::conf(eshel,instrument,config,$configId,height)        $private(height)
   if { $private(x1) < 1 } { set private(x1) 1 }
   if { $private(x2) < 2 } { set private(x2) 2 }
   if { $private(y1) < 1 } { set private(y1) 1 }
   if { $private(y2) < 2 } { set private(y2) 2 }
   if { $private(x2) > $private(width) }  { set private(x2) $private(width) }
   if { $private(y2) > $private(height) } { set private(y2) $private(height) }
   if { $private(x1) >= $private(x2) } { set private(x1) [expr $private(x2) -1] }
   if { $private(y1) >= $private(y2) } { set private(y1) [expr $private(y2) -1] }
   set ::conf(eshel,instrument,config,$configId,x1)            $private(x1)
   set ::conf(eshel,instrument,config,$configId,y1)            $private(y1)
   set ::conf(eshel,instrument,config,$configId,x2)            $private(x2)
   set ::conf(eshel,instrument,config,$configId,y2)            $private(y2)

   set ::conf(eshel,instrument,config,$configId,telescopeName) $private(telescopeName)
   set ::conf(eshel,instrument,config,$configId,refNum)        $private(refNum)
   set ::conf(eshel,instrument,config,$configId,refX)          $private(refX)
   set ::conf(eshel,instrument,config,$configId,refY)          $private(refY)
   set ::conf(eshel,instrument,config,$configId,refLambda)     $private(refLambda)
   set ::conf(eshel,instrument,config,$configId,wideOrder)     $private(wideOrder)
   set ::conf(eshel,instrument,config,$configId,threshold)     $private(threshold)
   set ::conf(eshel,instrument,config,$configId,boxWide)       $private(boxWide)
   set ::conf(eshel,instrument,config,$configId,minOrder)      $private(minOrder)
   set ::conf(eshel,instrument,config,$configId,maxOrder)      $private(maxOrder)

   set ::conf(eshel,instrument,config,$configId,hotPixelEnabled)   $private(hotPixelEnabled)
   set ::conf(eshel,instrument,config,$configId,cosmicEnabled)     $private(cosmicEnabled)
   set ::conf(eshel,instrument,config,$configId,cosmicThreshold)   $private(cosmicThreshold)

   #--- je recupere la liste des pixels chauds de reference
   set tkHotPixelList [$private($visuNo,frm).notebook getframe "camera"].hotpixel.text
   set a [$tkHotPixelList get 1.0 {end -1ch}]
   set b [split $a "\n"]
   set ::conf(eshel,instrument,config,$configId,hotPixelList) [list ]
   foreach line [split [$tkHotPixelList get 1.0 {end -1ch}] "\n"] {
      if { $line == "" } {
         #--- j'ignore les lignes vides
         continue
      }
      #--- je controle le contenu
      if { [ llength $line] == 2 }  {
         set type [lindex $line 0]
         if { $type != "C" && $type != "R"  } {
            #--- le type incorrect
            continue
         } else {
            set x [lindex $line 1]
            if { [string is integer $x]== 0 } {
               #--- la valeur n'est pas un entier
               continue
            }
         }
      } elseif { [llength $line] == 3 } {
         set type [lindex $line 0]
         if { $type != "P" } {
            #--- le type est incorrect
            continue
         } else {
            set x [lindex $line 1]
            set y [lindex $line 2]
            if { [string is integer $x]== 0 } {
               #--- x n'est pas un entier
               continue
            }
            if { [string is integer $y]== 0 } {
               #--- y n'est pas un entier
               continue
            }
         }
      } else {
         #--- j'ignore les lignes qui n'ont pas 2 ou 3 valeurs
         continue
      }

      lappend ::conf(eshel,instrument,config,$configId,hotPixelList) $line
   }

   #--- je recupere la liste des raies de reference
   set tkLineList [$private($visuNo,frm).notebook getframe "process"].lineList.text
   set a [$tkLineList get 1.0 {end -1ch}]
   set b [split $a "\n"]
   set ::conf(eshel,instrument,config,$configId,lineList) [list ]
   foreach line [split [$tkLineList get 1.0 {end -1ch}] "\n"] {
      if { $line == "" } {
         continue
      }
      if { [ string is double $line ] == 0 } {
         continue
      }
      lappend ::conf(eshel,instrument,config,$configId,lineList) $line
   }

   #--- je recupere la definition des ordres
   set tkOrderDefinition [$private($visuNo,frm).notebook getframe "process"].definition.table
   set ::conf(eshel,instrument,config,$configId,orderDefinition) [list]
   for { set rowIndex 0 } { $rowIndex < [$tkOrderDefinition size] } { incr rowIndex } {
      lappend ::conf(eshel,instrument,config,$configId,orderDefinition) [$tkOrderDefinition  get $rowIndex]
   }

   #--- je recupere la definition des ordres
   set tkCropLambda [$private($visuNo,frm).notebook getframe "process"].cropLambda.table
   set ::conf(eshel,instrument,config,$configId,cropLambda) [list]
   for { set rowIndex 0 } { $rowIndex < [$tkCropLambda size] } { incr rowIndex } {
      lappend ::conf(eshel,instrument,config,$configId,cropLambda) [$tkCropLambda  get $rowIndex]
   }

   #--- je recupere les series de reference
   modifyReferenceActionList $visuNo

   array unset ::conf eshel,instrument,reference,*

   #--- je recupere la liste des actions dans la table des actions
   set referenceNb [ $private(referenceTable) size ]
   for { set referenceIndex 0 } { $referenceIndex < $referenceNb } { incr referenceIndex } {
      set referenceId     [$private(referenceTable) rowcget $referenceIndex -name ]
      set referenceName   [$private(referenceTable) cellcget $referenceIndex,1 -text ]
      #--- je copie la reference dans la variable conf
      set ::conf(eshel,instrument,reference,$referenceId,name)  $referenceName
      set ::conf(eshel,instrument,reference,$referenceId,state) $private($referenceId,state)
      set ::conf(eshel,instrument,reference,$referenceId,actionList) $private($referenceId,actionList)
   }

   #--- j'enregistre les modifications sur disque
   set filename [ file join $::audace(rep_home) audace.ini ]
   set filebak  [ file join $::audace(rep_home) audace.bak ]
   array set file_conf [ ::audace::ini_getArrayFromFile $filename ]
   set currentConfig    [array get ::conf eshel,instrument,config,* ]
   set currentReference [array get ::conf eshel,instrument,reference,* ]

   #--- je sauvegarde le fichier de configuration
   if { [file exists $filename ] } {
      #--- je sauvegarde le fichier de configuration
      file copy -force $filename $filebak
   }
   #--- je purge les configurations et les sequences du fichier que celles qui ont ete effacees ne soient pas conservees
   array unset file_conf eshel,instrument,config,*
   array unset file_conf eshel,instrument,reference,*
   #--- j'ajoute les variables
   foreach { paramName paramValue } $currentConfig {
      set file_conf($paramName) $paramValue
   }
   foreach { paramName paramValue } $currentReference {
      set file_conf($paramName) $paramValue
   }

   set file_conf(eshel,currentInstrument) $::conf(eshel,currentInstrument)

   #--- j'enregistre les modifications dans le fichier ini
   ::audace::ini_writeIniFile $filename file_conf

   #--- je mets a jour les sequences de reference dans la fenetre principale.
   ::eshel::setSequenceList $visuNo

   #--- je memorise l'identifant de la nouvelle configuration
   #--- attention : cette variable est surveillee par listener
   set ::conf(eshel,currentInstrument) $configId
}

#------------------------------------------------------------
# createConfig
#   cree une nouvelle configuration
#
proc ::eshel::instrumentgui::createConfig { visuNo } {
   variable private

   set parent [winfo toplevel $private($visuNo,frm)]
   set result [::eshel::instrumentgui::nameDialog::run $parent $visuNo $::caption(eshel,instrument,createConfig)]
   if { $result == 0 } {
      #--- j'abandonne la creation
      return
   }

   set configName $::eshel::instrumentgui::nameDialog::private(name)

   #--- je verifie que le nom n'est pas vide
   if { $configName== "" } {
      tk_messageBox -message  $::caption(eshel,instrument,errorEmptyName) -icon error -title $::caption(eshel,title)
      return
   }

   #--- je fabrique l'identifiant a partie du nom en replacant les caracteres interdits pas un "_"
   set configId [::eshel::instrument::getConfigIdentifiant $configName]

   #--- je verifie que cette configuration n'existe pas deja
   if { [info exists ::conf(eshel,instrument,config,$configId,configName)] == 1 } {
      tk_messageBox -message  $::caption(eshel,instrument,errorExistingName) -icon error -title $::caption(eshel,title)
     return
   }

   #--- j'initialise les parametres de la nouvelle configuration avec ceux de la configuration par defaut
   foreach { paramName paramValue } [array get ::conf eshel,instrument,config,default,*] {
      #--- je prepare le nom de la nouvelle variable
      set paramName [string map [list ",default," ",$configId,"] $paramName ]
      #--- je cree la nouvelle variable avec la valeur par defaut
      set ::conf($paramName) $paramValue
   }
   #--- j'ajoute le nom de la configuration
   set ::conf(eshel,instrument,config,$configId,configName) $configName

   #--- j'ajoute la nouvelle config dans la combo
   set tkCombo $::eshel::instrumentgui::private($visuNo,frm).config.combo
   set configList [$tkCombo cget -values]
   lappend configList $configName
   set configList [lsort $configList]
   $tkCombo configure -values $configList -height [ llength $configList ]

   #--- je selectionne la nouvelle liste dans la combo
   set index [lsearch $configList $configName]
   $tkCombo setvalue "@$index"
   #--- j'affiche les valeurs dans les widgets
   onSelectConfig $visuNo

}

#------------------------------------------------------------
# copyConfig
#   copie une configuration sous un nouveau nom
#
proc ::eshel::instrumentgui::copyConfig { visuNo } {
   variable private

   #--- j'affiche la fenetre de saisie du nom de la nouvelle configuration
   set result [::eshel::instrumentgui::nameDialog::run [winfo toplevel $private($visuNo,frm)] $visuNo $::caption(eshel,instrument,createConfig)]
   if { $result == 0 } {
      #--- j'abandonne la creation
      return
   }

   #--- je recupere le nom de la nouvelle configuration
   set configName $::eshel::instrumentgui::nameDialog::private(name)

   #--- je verifie que le nom n'est pas vide
   if { $configName == "" } {
      tk_messageBox -message  $::caption(eshel,instrument,errorEmptyName) \
         -icon error -title $::caption(eshel,title)
      return
   }

   #--- je fabrique l'identifiant a partie du nom en replacant les caracteres interdits pas un "_"
   set configId [::eshel::instrument::getConfigIdentifiant $configName]

   #--- je verifie que l'identifiant n'est pas deja attribue a une autre configuration
   if { [info exists ::conf(eshel,instrument,config,$configId,configName)] == 1 } {
      tk_messageBox -message  $::caption(eshel,instrument,errorExistingName) \
         -icon error -title $::caption(eshel,title)
      return
   }

   #--- j'initialise les parametres de la nouvelle configuration avec ceux de la configuration a copier
   foreach { paramName paramValue } [array get ::conf eshel,instrument,config,$::conf(eshel,currentInstrument),*] {
      #--- je prepare le nom de la nouvelle variable du parametre
      set paramName [string map [list ",$::conf(eshel,currentInstrument)," ",$configId,"] $paramName ]
      #--- je cree la nouvelle variable du parametre avec la valeur par defaut
      set ::conf($paramName) $paramValue
   }
   #--- j'ajoute le nom de la configuration
   set ::conf(eshel,instrument,config,$configId,configName) $configName

   #--- j'ajoute la nouvelle config dans la combo
   set tkCombo $::eshel::instrumentgui::private($visuNo,frm).config.combo
   set configList [$tkCombo cget -values]
   lappend configList $configName
   set configList [lsort $configList]
   $tkCombo configure -values $configList -height [ llength $configList ]

   #--- je selectionne la nouvelle liste dans la combo
   set index [lsearch $configList $configName]
   $tkCombo setvalue "@$index"
   ::eshel::instrumentgui::onSelectConfig $visuNo
}

#------------------------------------------------------------
# deleteConfig
#   supprime la configuration courante
#
proc ::eshel::instrumentgui::deleteConfig { visuNo } {
   variable private

   #--- je recupere le nom de la configuration courante
   set configId $::conf(eshel,currentInstrument)

   #--- je verifie que ce n'est pas la configuration par defaut
   if { $configId == "default" } {
      #--- j'abandonne la suppression s'il s'agit de la configuration par defaut
      tk_messageBox -message  $::caption(eshel,instrument,errorDefaultName) \
         -icon error -title $::caption(eshel,title)
      return
   }

   #--- je demande la confirmation de la suppression
   set result [tk_messageBox -message "$::caption(eshel,instrument,confirmDeleteConfig): $::conf(eshel,instrument,config,$configId,configName)" \
       -type okcancel -icon question -title $::caption(eshel,title)]

   if { $result == "ok" } {
      #--- je supprime le nom de la configuration dans la combo
      set tkCombo $::eshel::instrumentgui::private($visuNo,frm).config.combo
      set configList [$tkCombo cget -values]
      set index [lsearch $configList $::conf(eshel,instrument,config,$configId,configName)]
      set configList [lreplace $configList $index $index]
      $tkCombo configure -values $configList -height [ llength $configList ]

      #--- je supprime les parametres de la configuration
      array unset ::conf eshel,instrument,config,$configId,*

      #--- je selectionne l'item suivant a la place de celui qui vient d'etre supprime
      if { $index == [llength $configList] } {
         #--- je decrement l'index si l'element supprime etait le dernier de la liste
         incr index -1
      }
      $tkCombo setvalue "@$index"
      ::eshel::instrumentgui::onSelectConfig $visuNo

   }
}

#------------------------------------------------------------
## @brief ouvre la fenêtre pour importer une configuration.
#  @param   visuNo numero de la visu
#  @private
#
proc ::eshel::instrumentgui::importConfig { visuNo } {
   variable private

   #--- j'affiche la fenetre de saisie du nom de la nouvelle configuration
   set fileName [ tk_getOpenFile \
      -title $::caption(eshel,instrument,importConfigTitle) \
      -filetypes [list [ list "CONF File"  {.conf} ]] \
      -initialdir $::conf(eshel,mainDirectory) \
      -parent $private($visuNo,frm) \
   ]

   if { $fileName != "" } {
      set catchResult [ catch {
         #--- je lis le fichier
         array set paramsArray [::eshel::instrument::readConfigFile $fileName ]
         #--- je verifie que la configuration n'existe pas deja
         set configName $paramsArray(configName)
         set configId [::eshel::instrument::getConfigIdentifiant $configName]
         if { [info exists ::conf(eshel,instrument,config,$configId,configName)]==1 } {
            #--- je demande si on veut ecraser la configuration existante
            set message [format $::caption(eshel,instrument,configAlreadyExist) $configName]
            set choice [tk_messageBox -title "$::caption(eshel,instrument,importConfigTitle)" -type okcancel -message "$message" -icon question]
            set alreadyExist 1
         } else {
            set choice "ok"
            set alreadyExist 0
         }

         if { $choice == "ok" } {
            #--- je supprime les anciens parametres
            array unset conf eshel,instrument,config,$configId,*
            #--- je copie les parametres de la configuration dans la variable ::conf
            foreach { paramName paramValue } [array get paramsArray] {
               set ::conf(eshel,instrument,config,$configId,$paramName) $paramValue
            }

            set tkCombo $::eshel::instrumentgui::private($visuNo,frm).config.combo
            set configList [$tkCombo cget -values]
            #--- j'ajoute la nouvelle config dans la combobox si elle n'existe pas deja
            if { $alreadyExist == 0 } {
               lappend configList $configName
               set configList [lsort $configList]
               $tkCombo configure -values $configList -height [ llength $configList ]
            }
            #--- je selectionne la nouvelle liste dans la combo
            set index [lsearch $configList $configName]
            $tkCombo setvalue "@$index"

            #--- j'affiche les valeurs dans les widgets
            onSelectConfig $visuNo
         }
      }]

      if { $catchResult !=0 } {
        ::tkutil::displayErrorInfo $::caption(eshel,instrument,importConfigTitle)
      }
   }
}

#------------------------------------------------------------
## @brief importe une configuration à partir d'un fichier FITS de calibration
#  @param   visuNo num"ro de la visu
#  @private
#
proc ::eshel::instrumentgui::importCalibrationConfig { visuNo } {
   variable private

   #--- j'affiche la fenetre pour selectionne le fichier de calibration
   set fileName [ tk_getOpenFile \
      -title $::caption(eshel,instrument,importConfigTitle) \
      -filetypes [list [ list "FITS File"  {.fit} ]] \
      -initialdir $::conf(eshel,mainDirectory) \
      -parent $private($visuNo,frm) \
   ]

   if { $fileName != "" } {
      set catchResult [ catch {
         #--- je lis le fichier
         array set paramsArray [::eshel::instrument::importCalibrationConfig $fileName ]
         #--- je verifie que la configuration n'existe pas deja
         set configName $paramsArray(configName)
         set configId [::eshel::instrument::getConfigIdentifiant $configName]
         if { [info exists ::conf(eshel,instrument,config,$configId,configName)]==1 } {
            #--- je demande si on veut ecraser la configuration existante
            set message [format $::caption(eshel,instrument,configAlreadyExist) $configName]
            set choice [tk_messageBox -title "$::caption(eshel,instrument,importConfigTitle)" -type okcancel -message "$message" -icon question]
           set alreadyExist 1
         } else {
            set choice "ok"
            set alreadyExist 0
         }

         if { $choice == "ok" } {
            #--- je supprime les anciens parametres de ::conf
            array unset conf eshel,instrument,config,$configId,*
             #--- je copie les parametres de la configuration dans la variable ::conf
            foreach { paramName paramValue } [array get paramsArray] {
               set ::conf(eshel,instrument,config,$configId,$paramName) $paramValue
            }

            #--- j'ajoute la nouvelle config dans la combobox si elle n'existe pas deja
            set tkCombo $::eshel::instrumentgui::private($visuNo,frm).config.combo
            set configList [$tkCombo cget -values]
            if { $alreadyExist == 0 } {
               lappend configList $configName
               set configList [lsort $configList]
               $tkCombo configure -values $configList -height [ llength $configList ]
            }

            #--- je selectionne la nouvelle liste dans la combo
            set index [lsearch $configList $configName]
            $tkCombo setvalue "@$index"

            #--- j'affiche les valeurs dans les widgets
            onSelectConfig $visuNo
         }
      }]

      if { $catchResult !=0 } {
        ::tkutil::displayErrorInfo $::caption(eshel,instrument,importConfigTitle)
      }
   }
}

#------------------------------------------------------------
## @brief ouvre la fenêtre pour exporter une configuration.
#  @details appelle  @ref ::eshel::instrumentgui::exportConfigDialog::run
#  @param   visuNo numero de la visu
#  @private
#
proc ::eshel::instrumentgui::exportConfig { visuNo } {
   variable private

   set fileName [ tk_getSaveFile \
      -title $::caption(eshel,instrument,exportConfigTitle) \
      -filetypes [list [ list "CONF File"  {.conf} ]] \
      -initialdir $::conf(eshel,mainDirectory) \
      -parent $private($visuNo,frm) \
   ]

   if { $fileName != "" } {
      set extension [file extension $fileName]
      if { $extension == "" } {
         append fileName ".conf"
      } elseif { $extension == "." } {
         append fileName "conf"
      }
      ::eshel::instrument::exportConfig $fileName
   }
}


#------------------------------------------------------------
# addConfigListener
#    ajoute une procedure a appeler si on change des parametres des la conguration
#  parametres :
#    visuNo: numero de la visu
#    cmd : commande TCL a lancer quand la configuration change
#
proc ::eshel::instrumentgui::addConfigListener { visuNo cmd } {
   trace add variable ::conf(eshel,currentInstrument) write $cmd
}

#------------------------------------------------------------
# removeConfigListener
#    supprime une procedure a appeler si on change des parametres des la conguration
#  parametres :
#    visuNo: numero de la visu
#    cmd : commande TCL a lancer quand la configuration change
#
proc ::eshel::instrumentgui::removeConfigListener { visuNo cmd } {
   trace remove variable ::conf(eshel,currentInstrument) write $cmd
}

#------------------------------------------------------------
# createReference
#   cree une nouvelle sequence de reference
#
proc ::eshel::instrumentgui::createReference { visuNo } {
   variable private

   set parent [winfo toplevel $private($visuNo,frm)]
   set result [::eshel::instrumentgui::nameDialog::run $parent $visuNo $::caption(eshel,instrument,reference,createReference)]
   if { $result == 0 } {
      #--- j'abandonne la creation
      return
   }

   #--- je recupere le nom qui vient d'etre saisi.
   set referenceName $::eshel::instrumentgui::nameDialog::private(name)

   #--- je verifie que le nom n'est pas vide
   if { $referenceName == "" } {
      tk_messageBox -message $::caption(eshel,instrument,errorEmptyName) -icon error -title $::caption(eshel,title)
      return
   }

   #--- je fabrique l'identifiant a partie du nom en replacant les caracteres interdits pas un "_"
   set referenceId ""
   for { set i 0 } { $i < [string length $referenceName] } { incr i } {
      set c [string index $referenceName $i]
      if { [string is wordchar $c ] == 0 } {
         #--- je remplace le caractere par underscore, si le caractere n'est pas une lettre , un chiffre ou underscore
         set c "_"
      }
      append referenceId $c
   }

   #--- je verifie que l'identifiant n'existe pas deja
   if { [info exists private($referenceId,actionList) ] == 1 } {
      tk_messageBox -message "$referenceName\n$::caption(eshel,instrument,reference,alreadyExist)" -icon error -title $::caption(eshel,title)
      return
   }

   #--- j'initialise les parametres de la nouvelle reference avec des valeurs par defaut
   set private($referenceId,actionList) ""

   #--- j'ajoute la nouvelle reference dans la table
   addReference end $referenceId $referenceName 1

   #--- j'affiche les valeurs dans les widgets
   selectReference $visuNo $referenceId
}

#------------------------------------------------------------
# copyReference
#   copie une reference
#
proc ::eshel::instrumentgui::copyReference { visuNo } {
   variable private

   set index [$private(referenceTable) curselection]
   #--- retourne immediatemment si aucun item selectionne
   if { $index == "" } {
      tk_messageBox -message $::caption(eshel,instrument,reference,selectReference) -icon error -title $::caption(eshel,title)
      return
   }

   #--- je recupere l'identifiant de la reference selectionnee
   set copiedReferenceId  [$private(referenceTable) rowcget $index -name]

   #--- j'affiche la fenetre pour saisir le nom de la nouvelle reference
   set parent [winfo toplevel $private($visuNo,frm)]
   set result [::eshel::instrumentgui::nameDialog::run $parent $visuNo $::caption(eshel,instrument,reference,createReference)]
   if { $result == 0 } {
      #--- l'utilisateur abandonne la copie
      return
   }

   #--- je recupere le nom qui vient d'etre saisi.
   set referenceName $::eshel::instrumentgui::nameDialog::private(name)

   #--- je verifie que le nom n'est pas vide
   if { $referenceName == "" } {
      tk_messageBox -message $::caption(eshel,instrument,errorEmptyName) -icon error -title $::caption(eshel,title)
      return
   }

   #--- je fabrique l'identifiant a partir du nom en replacant les caracteres interdits pas "_"
   set referenceId ""
   for { set i 0 } { $i < [string length $referenceName] } { incr i } {
      set c [string index $referenceName $i]
      if { [string is wordchar $c ] == 0 } {
         #--- je remplace le caractere par underscore, si le caractere n'est pas une lettre , un chiffre ou underscore
         set c "_"
      }
      append referenceId $c
   }

   #--- je verifie que l'identifiant n'existe pas deja
   if { [info exists private($referenceId,actionList) ] == 1 } {
      tk_messageBox -message "$referenceName\n$::caption(eshel,instrument,reference,alreadyExist)" -icon error -title $::caption(eshel,title)
      return
   }

   #--- j'initialise les parametres de la nouvelle reference avec ceux de la reference a copier
   set private($referenceId,actionList) $private($copiedReferenceId,actionList)

   #--- j'ajoute la nouvelle reference dans la table
   addReference end $referenceId $referenceName 1

   #--- j'affiche les valeurs dans les widgets
   selectReference $visuNo $referenceId

}

#------------------------------------------------------------
# deleteReference
#   supprime une reference
#
proc ::eshel::instrumentgui::deleteReference { visuNo } {
   variable private

   set referenceIndex [$private(referenceTable) curselection]
   #--- retourne immediatemment si aucun item selectionne
   if { $referenceIndex == "" } {
      tk_messageBox -message $::caption(eshel,instrument,reference,selectReference) -icon error -title $::caption(eshel,title)
      return
   }

   #--- je recupere l'identifiant de la reference selectionnee
   set referenceId   [$private(referenceTable) rowcget  $referenceIndex -name]
   set referenceName [$private(referenceTable) cellcget $referenceIndex,1 -text ]

   #--- je demande la confirmation de la suppression
   set result [tk_messageBox -message "$::caption(eshel,instrument,reference,confirmDelete): $referenceName" \
       -type okcancel -icon question -title $::caption(eshel,title)]

   if { $result == "ok" } {
      #--- je supprime la selection
      selectReference $visuNo ""

      #--- je supprime les parametres de la reference
      array unset private $referenceId,*

      #--- je supprime la reference dans la table
      $private(referenceTable) delete $referenceId

   }
}

#----------------------------------------------------------------------------
# selectReference
#   selectionne une reference dans la table et affiche la liste des actions
#   Si le parametre referenceId est vide, supprime la selection courante
#
# Parameters;
#  visuNo  : numero de la visu
#  referenceId : identifiant de la reference.
#
proc ::eshel::instrumentgui::selectReference { visuNo referenceId } {
   variable private

   #--- je supprime la selection precedente
   $private(referenceTable) select clear 0 end

   if { $referenceId != "" } {
      #--- je selectionne la ligne a la place de l'utilisateur
      $private(referenceTable) select set $referenceId
      #--- j'adapte l'affichage de la table pour voir la ligne selectionnee
      $private(referenceTable) see $referenceId
   }
   #--- j'affiche les parametres de la reference
   onSelectReference $visuNo

}

#----------------------------------------------------------------------------
# onSelectReference
#   affiche la liste des actions de la reference selectionnee par l'utilisateur
#
# Parameters;
#  visuNo  : numero de la visu
#  referenceId : identifiant de la reference.
#                Si ce parametre est vide, le ligne selectionne par l'utilisateur dans la table est selectionne
#
proc ::eshel::instrumentgui::onSelectReference { visuNo  } {
   variable private

   #--- je recupere la ligne slectionnee par l'utilisateur
   set referenceIndex [$private(referenceTable) curselection]
   if { $referenceIndex == "" } {
      #--- Pas de reference selectionnee
      #--- j'efface le contenu de la table des actions
      $private(actionTable) delete 0 end
      $private(referencePage).edit  configure -text $::caption(eshel,instrument,reference,edit)
      $private(referencePage).edit.action.create  configure -state disabled
      selectAction $visuNo ""
      return
   }
   #--- je recupere referenceId
   set referenceId  [$private(referenceTable) rowcget $referenceIndex -name]

   #--- j'affiche les actions de la reference
   $private(actionTable) delete 0 end
   foreach action $private($referenceId,actionList) {
      set actionType [lindex $action 0]
      set actionParams [lindex $action 1]
      addAction end $actionType $actionParams
   }

   #--- j'affiche le nom de la reference dans le titre de la frame
   set referenceName   [$private(referenceTable) cellcget $referenceIndex,1 -text ]
   $private(referencePage).edit  configure -text "$::caption(eshel,instrument,reference,edit): $referenceName"
   $private(referencePage).edit.action.create  configure -state normal

   #--- je selectionne aucune action
   selectAction $visuNo ""

}

#------------------------------------------------------------
#  addReference
#     ajoute une reference dans la table des references
#
# Parametres :
#    rowIndex    : numero de la ligne (end= derniere ligne)
#    id          : identifiant de la reference
#    name        : nom de la reference
#    state       : 1= reference utilisable,  0= reference non utilisable
#------------------------------------------------------------
proc ::eshel::instrumentgui::addReference { rowIndex id name state } {
   variable private

   $private(referenceTable) insert $rowIndex [list "" $name]
   $private(referenceTable) rowconfigure $rowIndex -name $id
   $private(referenceTable) cellconfigure $rowIndex,state \
      -window [ list ::eshel::instrumentgui::createCheckbutton ] \
      -windowdestroy [ list ::eshel::instrumentgui::deleteCheckbutton ]
   #--- je coche le checkButton
   setCheckbutton $private(referenceTable) $id "state" $state
   #--- je trie la table par ordre alphabetique
   $private(referenceTable) sortbycolumn "name"
   update
}

#------------------------------------------------------------
#  modifyReferenceActionList
#    modifie la liste des actions de la reference selectionne
#    cette procedure est appellee chaque fois que l'utilisateur modifie la liste des actions
#
# Parametres :
#    visuNo    : numero de la visu
#
proc ::eshel::instrumentgui::modifyReferenceActionList { visuNo } {
   variable private

   #--- je recupere l'index de la reference selectionnee
   set referenceIndex [$private(referenceTable) curselection]
   if { $referenceIndex == "" } {
      return
   }

   #--- je recupere les actions en cours de modification
   modifyAction  $visuNo

   #--- je recupere la liste des actions dans la table des actions
   set actionList ""
   set actionNb [ $private(actionTable) size ]
   for { set actionIndex 0 } { $actionIndex < $actionNb } { incr actionIndex } {
      set actionType   [$private(actionTable) cellcget $actionIndex,0 -text ]
      set actionParams [$private(actionTable) cellcget $actionIndex,1 -text ]
      lappend actionList [list $actionType $actionParams]
   }
   set referenceId  [$private(referenceTable) rowcget $referenceIndex -name]
   set private($referenceId,actionList) $actionList
}

#------------------------------------------------------------
#  addAction
#     ajoute une action dans la table des actions
#
# Parametres :
#    rowIndex    : numero de la ligne (end= derniere ligne)
#    actionType  : type de l'action
#    name        : liste des parametres (exemple: { exptime 15 expnb 3 }
#
proc ::eshel::instrumentgui::addAction { rowIndex actionType actionParams } {
   variable private

   $private(actionTable) insert $rowIndex [list $actionType "$actionParams" ]
   update
}

#------------------------------------------------------------
#  selectAction
#   selectionne une action et affiche les parametres de l'action
#   si le parametre actionIndex est vide ou absent , supprime la selection
#
# Parametres :
#   visuNo  : numero de la visu
#   actionIndex  :  numero de l'action dasn la table (index=0 pour la premiere ligne)
#
proc ::eshel::instrumentgui::selectAction { visuNo { actionIndex "" } } {
   variable private

   #--- je supprime la selection courante
   $private(actionTable) select clear 0 end

   if { $actionIndex != "" } {
      #--- je selectionne la ligne a la place de l'utilisateur
      $private(actionTable) select set $actionIndex
      #--- j'adapte l'affichage de la table pour voir la ligne selectionnee
      $private(actionTable) see $actionIndex
   }
   #--- j'affiche les parametres de l'action
   onSelectAction $visuNo
}

#----------------------------------------------------------------------------
# onSelectAction
#   affiche les parametres de l'action selectionne dans les widgets
#   Si aucune action n'est selectionnee, affiche aucun widget
# Parameters;
#  visuNo  : numero de la visu
#
proc ::eshel::instrumentgui::onSelectAction { visuNo  } {
   variable private

   #--- j'efface les widgets
   foreach paramName $private(actionParamNames) {
      grid remove $private(referencePage).edit.action.${paramName}Label
      grid remove $private(referencePage).edit.action.$paramName
   }

   #--- je recupere l'action selectionnee par l'utilisateur
   set index [$private(actionTable) curselection]
   if { $index == "" } {
      #--- si aucun item n'est selectionne, je desactive les boutons copier et supprimer
      $private(referencePage).edit.action.apply    configure -state disabled
      $private(referencePage).edit.action.copy     configure -state disabled
      $private(referencePage).edit.action.delete   configure -state disabled
      $private(referencePage).edit.action.moveUp   configure -state disabled
      $private(referencePage).edit.action.moveDown configure -state disabled
      grid remove $private(referencePage).edit.action.actionLabel
      grid remove $private(referencePage).edit.action.action
      return
   } else {
      $private(referencePage).edit.action.apply    configure -state normal
      $private(referencePage).edit.action.copy     configure -state normal
      $private(referencePage).edit.action.delete   configure -state normal
      $private(referencePage).edit.action.moveUp   configure -state normal
      $private(referencePage).edit.action.moveDown configure -state normal
      grid $private(referencePage).edit.action.actionLabel
      grid $private(referencePage).edit.action.action
   }

   #--- je recupere le type de l'action
   set private(action,type)  [$private(actionTable) cellcget $index,0 -text ]

   #--- j'affiche les widgets des parametres de l'action
   foreach paramName $private(action,$private(action,type),paramNames) {
      #--- j'affiche le widget et son label
      grid $private(referencePage).edit.action.${paramName}Label
      grid $private(referencePage).edit.action.${paramName}
   }

   #--- je recupere les parametres de l'action
   set actionParams [$private(actionTable) cellcget $index,1 -text ]

   #--- j'affiche les valeurs des parametres de l'action dans les widgets
   foreach {paramName paramValue} $actionParams {
      set private(action,$paramName) $paramValue
   }
}

#----------------------------------------------------------------------------
# onSelectActionType
#   Cette procedure est appelee quand l'utilsateur selectionne un type d'action dans la combobox
#   affiche les wigets des parametres de l'action
# Parameters;
#   visuNo  : numero de la visu
#
proc ::eshel::instrumentgui::onSelectActionType { visuNo  } {
   variable private

   #--- j'efface les widgets des parametres
   foreach paramName $private(actionParamNames) {
      grid remove $private(referencePage).edit.action.${paramName}Label
      grid remove $private(referencePage).edit.action.$paramName
   }

   #--- j'affiche les widgets des parametres de l'action
   foreach paramName $private(action,$private(action,type),paramNames) {
      #--- j'affiche le widget
      grid $private(referencePage).edit.action.${paramName}Label
      grid $private(referencePage).edit.action.$paramName
   }

   #--- je recupere lindex de l'action selectionnee
   set index [$private(actionTable) curselection]
   #--- je recupere les parametres de l'action
   set actionParams [$private(actionTable) cellcget $index,1 -text ]

   #--- j'affiche les valeurs des parametres de l'action dans les widgets
   foreach {paramName paramValue} $actionParams {
      set private(action,$paramName) $paramValue
   }
}

#------------------------------------------------------------
#  createAction
#     cree une nouvelle action
#
# Parametres :
#    visuNo    : numero de la visu
#
proc ::eshel::instrumentgui::createAction { visuNo } {
   variable private

   #--- je recupere lindex de l'action selectionnee par l'utilisateur
   set index [$private(actionTable) curselection]
   if { $index == "" } {
      #--- si aucune action n'est selectionnee, j'ajoute la nouvelle action a la fin de la table
      set index end
   } else {
      #--- j'ajoute la nouvelle action juste apres celle qui est selectionnee
      incr index
   }

   #--- je cree c'est une serie d'un Bias par defaut
   set actionType "biasSerie"
   set actionParams "expNb 1"
   $private(actionTable) insert $index [list $actionType $actionParams ]

   #--- je selectionne la nouvelle action dans la table des actions
   selectAction $visuNo $index

   #--- je mets a jour la liste des actions dans la reference
   modifyReferenceActionList $visuNo
}

#------------------------------------------------------------
#  copyAction
#     copie l'action selectionnee
#
# Parametres :
#    visuNo    : numero de la visu
#
proc ::eshel::instrumentgui::copyAction { visuNo } {
   variable private

   #--- je recupere l'action selectionnee par l'utilisateur
   set actionIndex [$private(actionTable) curselection]
   if { $actionIndex == "" } {
      #--- si aucune action n'est selectionnee, j'affiche un message d'erreur
      tk_messageBox -message $::caption(eshel,instrument,selectAction) -icon error -title $::caption(eshel,title)
      return
   }
   #--- je copie l'action
   set actionType [$private(actionTable) cellcget $actionIndex,0 -text ]
   set actionParams [$private(actionTable) cellcget $actionIndex,1 -text ]
   #--- j'increment l'index pour placer la nouvelle action juste apres celle qui est selectionnee
   incr actionIndex
   $private(actionTable) insert $actionIndex [list $actionType $actionParams ]

   #--- je selectionne la nouvelle action
   selectAction $visuNo $actionIndex

   #--- je mets a jour la liste des actions de la reference
   modifyReferenceActionList $visuNo
}

#------------------------------------------------------------
#  deleteAction
#     supprime l'action selectionnee
#
# Parametres :
#    visuNo    : numero de la visu
#
proc ::eshel::instrumentgui::deleteAction { visuNo } {
   variable private

   #--- je recupere l'action selectionnee par l'utilisateur
   set index [$private(actionTable) curselection]
   if { $index == "" } {
      #--- si aucune action n'est selectionnee, j'affiche un message d'erreur
      tk_messageBox -message $::caption(eshel,instrument,selectAction) -icon error -title $::caption(eshel,title)
      return
   }
   #--- j'efface la selection
   selectAction $visuNo ""

   #--- je supprime l'action dans la table
   $private(actionTable) delete $index

   #--- je mets a jour la liste des actions de la reference
   modifyReferenceActionList $visuNo
}

#------------------------------------------------------------
#  modifyAction
#     modifie l'action selectionnee
#
# Parametres :
#    visuNo    : numero de la visu
#
proc ::eshel::instrumentgui::modifyAction { visuNo } {
   variable private

   #--- je recupere l'action selectionnee par l'utilisateur
   set actionIndex [$private(actionTable) curselection]
   if { $actionIndex == "" } {
      #--- rien a faire car pas d'action selectionnee
      return
   }

   #--- je recupere le type de l'action
   set actionType $private(action,type)

   #--- je recupere les parametres de l'action
   set actionParams ""
   foreach paramName $private(action,$actionType,paramNames) {
      #--- je verifie que le nom de l'obet est correct
      if { [info exists ::eshel::instrumentgui::private(error,action,$paramName)] } {
         set errorMessage "$::caption(eshel,instrument,reference,$paramName): $private(error,action,$paramName)"
         tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
         return
      }
      #--- j'ajoute le nom du parametre et sa valeur
      lappend actionParams $paramName $private(action,$paramName)
   }

   #--- je mets a jour la table des actions
   $private(actionTable) cellconfigure $actionIndex,0 -text $actionType
   $private(actionTable) cellconfigure $actionIndex,1 -text $actionParams
}

#------------------------------------------------------------
#  moveActionDown
#     deplace une action vers la fin de la liste
#
proc ::eshel::instrumentgui::moveActionDown { visuNo } {
   variable private

   #--- je recupere l'action selectionnee par l'utilisateur
   set actionIndex [$private(actionTable) curselection]
   if { $actionIndex == "" } {
      #--- si aucune action n'est selectionnee, j'affiche un message d'erreur
      tk_messageBox -message $::caption(eshel,instrument,selectAction) -icon error -title $::caption(eshel,title)
      return
   }
   set newIndex [expr $actionIndex +2]
   $private(actionTable) move $actionIndex $newIndex

   #--- je mets a jour la liste des actions de la reference
   modifyReferenceActionList $visuNo
}

#------------------------------------------------------------
#  moveActionUp
#     deplace une action vers le debut de la liste
#
proc ::eshel::instrumentgui::moveActionUp { visuNo } {
   variable private

   #--- je recupere l'action selectionnee par l'utilisateur
   set actionIndex [$private(actionTable) curselection]
   if { $actionIndex == "" } {
      #--- si aucune action n'est selectionnee, j'affiche un message d'erreur
      tk_messageBox -message $::caption(eshel,instrument,selectAction) -icon error -title $::caption(eshel,title)
      return
   }
   if { $actionIndex > 0 } {
      set newIndex [expr $actionIndex -1]
      $private(actionTable) move $actionIndex $newIndex
   }

   #--- je mets a jour la liste des actions de la reference
   modifyReferenceActionList $visuNo
}

#------------------------------------------------------------------------------
# createCheckbutton
#    cree un checkbutton dans la table
#
# Parametres :
#    tkTable      : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
#
proc ::eshel::instrumentgui::createCheckbutton { tkTable row col w } {
   variable private
   #--- je cree le checkbutton avec une variable qui porte le nom du checkbutton
   ###checkbutton $w -highlightthickness 0 -takefocus 0 -variable ::eshel::instrumentgui::private($w)
   set referenceId [$tkTable rowcget $row -name ]
   checkbutton $w -highlightthickness 0 -takefocus 0 -variable ::eshel::instrumentgui::private($referenceId,state)
}

#------------------------------------------------------------------------------
# deleteCheckbutton
#    supprime un checkbutton dans la table
#
# Parametres :
#    tkTable      : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
#
proc ::eshel::instrumentgui::deleteCheckbutton { tkTable row col w } {
   variable private

   #--- je supprime le checkbutton et sa variable
   destroy $w
   #unset ::eshel::instrumentgui::private($w)

}

#------------------------------------------------------------------------------
# setCheckbutton
#    change l'etat du checkbutton dans la table
#
# Parametres :
#    tkTable      : nom Tk de la table
#    lineName     : nom de ligne
#    columnName   : nom de la colonne
#    value        : 0 ou 1
#
proc ::eshel::instrumentgui::setCheckbutton { tkTable lineName columnName value } {
   variable private
   set w [ $tkTable windowpath $lineName,$columnName]
   if { $value == 1 } {
      $w select
   } else {
      $w deselect
   }
}

#------------------------------------------------------------------------------
# getCheckbutton
#    retourne l'etat du checkbutton dans la table
#
# Parametres :
#    tkTable      : nom Tk de la table
#    lineName     : nom de ligne
#    columnName   : nom de la colonne
#
#  Return :
#    1 si le checkbutton est coche
#    0 si le checkbutton n'est pas coche
#
proc ::eshel::instrumentgui::getCheckbutton { tkTable lineName columnName } {
   variable private
   #--- je recupere le nom tk du checkbutton
   set w [ $tkTable windowpath $lineName,$columnName]
   #--- je recupere le nom de la variable du checkbutton
   set variableName [$w cget -variable]

   #--- je recupere le contenu de la variable
   return [set $variableName]
}


proc ::eshel::instrumentgui::wrap {W w} {

    set px [$W cget -padx]

    if { [catch {$W cget -compound} side] } {
      set wl [expr {$w - (2 * $px)}]
    } else {
      switch -- $side {
        left -
        right {
          set image [$W cget -image]
          if { [string length $image] } {
            set iw [image width $image]
          } else {
            set iw 0
          }
          set wl [expr {$w - (3 * $px) - $iw}]
        }
        default {
          set wl [expr {$w - (2 * $px)}]
        }
      }
    }
console::disp "wrap $wl\n"
    $W configure -wraplength $wl
  }


################################################################
# namespace ::eshel::instrumentgui::nameDialog
#  fenetre de saisie du nom de configuration
#
#  Remarque IMPORTANTE : le nom de configuration ne doit contenir
#  que des caracrteres alphanumeriques ou underscore car il est
#  est utilise en tant qu'indice d' array
################################################################

namespace eval ::eshel::instrumentgui::nameDialog {
   variable private

}

#------------------------------------------------------------
# ::eshel::instrumentgui::nameDialog::run
#    affiche la fenetre du traitement
# return
#   1 si la saisie est validee
#   0 si la saisie est abandonne
#
proc ::eshel::instrumentgui::nameDialog::run { tkbase visuNo title } {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,instrumentConfigPosition) ] } { set ::conf(eshel,instrumentConfigPosition)     "650x140+100+15" }
   set private($visuNo,This) "$tkbase.getname"
   set private(title) $title

   #--- j'affiche la fenetre modale et j'attend que l'utilisateur la referme
   set result [::confGenerique::run $visuNo $private($visuNo,This) "::eshel::instrumentgui::nameDialog" \
      -modal 1 -geometry $::conf(eshel,instrumentConfigPosition) -resizable 1 ]

   #--- je retourne 1 si l'utilisateur a valide la saisie, ou 0 si l'utilisateur a abandonne la saisie
   return $result
}

#------------------------------------------------------------
# ::eshel::instrumentgui::nameDialog::getLabel
#   retourne le titre de la fenetre
#
proc ::eshel::instrumentgui::nameDialog::getLabel { } {
   variable private

   return "$::caption(eshel,title) - $private(title)"
}

#------------------------------------------------------------
# ::eshel::instrumentgui::nameDialog::cmdApply
#   enregistre la valeur des widgets
#
proc ::eshel::instrumentgui::nameDialog::cmdApply { visuNo } {
   variable private
   #--- rien a enregistrer
   #--- cette fonction existe pour faire apparaitre le bouton "OK"
}

#------------------------------------------------------------
# ::eshel::instrumentgui::nameDialog::cmdClose
#   ferme la fenetre
#
proc ::eshel::instrumentgui::nameDialog::cmdClose { visuNo } {
   variable private

   #--- je memorise la position courante de la fenetre
   set ::conf(eshel,instrumentConfigPosition) [ wm geometry $private($visuNo,This) ]
}

#------------------------------------------------------------
# ::eshel::instrumentgui::nameDialog::fillConfigPage
#   cree les widgets de la fenetre
#
proc ::eshel::instrumentgui::nameDialog::fillConfigPage { frm visuNo } {
   variable private

   set private(name)  ""

   #---Widget de saisie du nom de la configuration.
   #--- le parametre -validatecommand renvoi vers une procedure qui controle le contenu du widget
   #---  afin d'ignorer les caracteres interdits
   LabelEntry $frm.name  -label $private(title)\
      -labeljustify left -width 5 -justify left -editable true \
      -textvariable ::eshel::instrumentgui::nameDialog::private(name) \
      -validate all -validatecommand { ::eshel::instrumentgui::nameDialog::validateConfigName %W %V %P %s }
   pack $frm.name  -side left -fill x -expand 1 -padx 2

   #--- je donne le focus a la zone de saisie
}

#------------------------------------------------------------
# ::eshel::instrumentgui::nameDialog::validateConfigName
#
#   verifie les caracteres saisis en temps reel d'un widget
#   et restaure le contenu precedent si un caractere interdit vient d'etre saisi
#   caracteres autorises : lettres, chiffres , underscore
#   return
#    1 : control OK
#    0 : contrl failed
#
proc ::eshel::instrumentgui::nameDialog::validateConfigName {  win event X oldX  } {
   variable private

   switch $event {
      key {
         if { [string is print $X ] == 0 && $X != " " } {
            set X oldX
            bell
            return 0
         } else {
            return 1
         }
      }
      default {
          return 1
      }
   }
}

