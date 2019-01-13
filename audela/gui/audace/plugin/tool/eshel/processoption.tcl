#
## @file processoption.tcl
#  @brief fenêtre des options des traitements
#  @author Michel PUJOL
#  $Id: processoption.tcl 13378 2016-03-15 21:19:06Z rzachantke $
#

## namespace eshel::process::option
#  @brief fenêtre des options des traitements

namespace eval ::eshel::process::option {

}

#------------------------------------------------------------
## @brief affiche la fenêtre de choix des options de traitement
#  @details utilise les fonctions de la classe parent ::confGenerique
#  @param tkbase nom tk de la fenêtre parent
#  @param visuNo  numero de la visu parent
#  @public
#-
proc ::eshel::process::option::run { tkbase visuNo } {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,processOptionWindowPosition) ] } { set ::conf(eshel,processOptionWindowPosition) "400x200" }

   set private(tkbase) $tkbase
   #--- j'affiche la fenetre
   set private($visuNo,This) "$tkbase.option"
   set private(apply)  ""
   ::confGenerique::run  $visuNo $private($visuNo,This) "::eshel::process::option" -modal 0 -geometry $::conf(eshel,processOptionWindowPosition) -resizable 1
   wm minsize $private($visuNo,This) 400 200
   wm transient $private($visuNo,This) $tkbase
}

#------------------------------------------------------------
## @brief ferme la fenêtre
#  @details cette procédure est appelée par ::confGenerique::cmdClose
#  @param visuNo  numéro de la visu
#  @return
#   - 0  s'il ne faut pas fermer la fenetre
#   - 1  s'il faut fermer la fenetre
#  @public
#
proc ::eshel::process::option::cmdClose { visuNo } {
   variable private

   if { $private(apply) == "error" } {
      set private(apply)  ""
      #--- je retourne 0 pour empecher de fermer la fenetre (voir ::confGenerique::run)
      return 0
   }

   #--- je supprime l'abonnement au listener de configuration
   ::eshel::instrumentgui::removeConfigListener $visuNo "::eshel::process::option::onChangeConfig $visuNo"

   #--- je memorise la position courante de la fenetre
   set ::conf(eshel,processOptionWindowPosition) [ wm geometry $private($visuNo,This) ]
}

#------------------------------------------------------------
## @brief affiche l'aide de cet outil
#  @details cette procédure est appelée par ::confGenerique::showHelp
#  @private
#
proc ::eshel::process::option::showHelp { } {
   ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::eshel::getPluginType]] \
      [::eshel::getPluginDirectory] [::eshel::getPluginHelp] "option"
}

#------------------------------------------------------------
## @brief enregistre les modifications
#  @details cette procédure est appelée par ::confGenerique::cmdApply
#  @param visuNo  numero de la visu parent
#  @private
#
proc ::eshel::process::option::cmdApply { visuNo } {
   variable private
   variable widget

   set private(apply)  ""
   set errorMessage    ""

   set configId $::conf(eshel,currentInstrument)
   set ::conf(eshel,instrument,config,$configId,flatFieldEnabled)  $widget(flatFieldEnabled)
   set ::conf(eshel,instrument,config,$configId,responseOption)    $widget(responseOption)
   set ::conf(eshel,instrument,config,$configId,responseFileName) [file normalize $widget(responseFileName)]
   set ::conf(eshel,instrument,config,$configId,responsePerOrder)  $widget(responsePerOrder)
   set ::conf(eshel,instrument,config,$configId,saveObjectImage)   $widget(saveObjectImage)
   set ::conf(eshel,instrument,config,$configId,debugLog)          $widget(debugLog)
}

#------------------------------------------------------------
## @brief créé les widgets de la fenêtre de configuration de la session
#  @details cette procédure est appelée par ::confGenerique::fillConfigPage à la création de la fenêtre
#  @param frm nom tk de la frame cree par ::confgene::fillConfigPage
#  @param visuNo numero de la visu
#  @private
#
proc ::eshel::process::option::fillConfigPage { frm visuNo } {
   variable widget
   variable private

   set private(frm) $frm

   #--- j'ajoute l'abonnement au listener de configuration
   ::eshel::instrumentgui::addConfigListener $visuNo "::eshel::process::option::onChangeConfig $visuNo"

   #--- je copie les options dans les widgets
   copyOptionToWidget

   #--- nom de la configuration
   frame $frm.config -borderwidth 0
      label $frm.config.nameLabel  -text "$::caption(eshel,instrument,title) :"
      pack $frm.config.nameLabel   -side left -fill none -expand 1 -padx 2
      entry $frm.config.nameValue  -textvariable ::eshel::process::option::widget(configName) -state readonly
      pack $frm.config.nameValue   -side left -fill x -expand 1 -padx 2

   #--- flatfield
   checkbutton $frm.flatFieldEnabled  -justify left \
      -text $::caption(eshel,process,flatFieldEnabled) \
      -variable ::eshel::process::option::widget(flatFieldEnabled)

   #--- saveObjectImage
   checkbutton $frm.saveObjectImage  -justify left \
      -text $::caption(eshel,process,saveObjectImage) \
      -variable ::eshel::process::option::widget(saveObjectImage)

   #--- debugLog
   checkbutton $frm.debugLog  -justify left \
      -text $::caption(eshel,process,debugLog) \
      -variable ::eshel::process::option::widget(debugLog)


   #--- reponse instrumentale
   TitleFrame $frm.response -borderwidth 2 -relief ridge -text $::caption(eshel,instrument,process,response,title)
      radiobutton $frm.response.manual -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text $::caption(eshel,instrument,process,response,manual) \
         -value "MANUAL" \
         -variable ::eshel::process::option::widget(responseOption) \
         -command  "::eshel::process::option::onSelectResponseOption"

      #--- Bouton selection de la reponse instrumentale
      frame  $frm.response.select -borderwidth 0
         entry $frm.response.select.entry   -textvariable ::eshel::process::option::widget(responseFileName) -state readonly -justify left
         pack $frm.response.select.entry   -side left -fill x -expand 1 -padx 8
         Button $frm.response.select.button -text "..." -command "::eshel::process::option::selectResponseFileName"
         pack $frm.response.select.button -side left -fill none -expand 0 -padx 2

      radiobutton $frm.response.auto -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text $::caption(eshel,instrument,process,response,auto) \
         -value "AUTO" \
         -variable ::eshel::process::option::widget(responseOption) \
         -command  "::eshel::process::option::onSelectResponseOption"
      radiobutton $frm.response.none -highlightthickness 0 -padx 0 -pady 0 -state normal \
         -text $::caption(eshel,instrument,process,response,none) \
         -value "NONE" \
         -variable ::eshel::process::option::widget(responseOption) \
         -command  "::eshel::process::option::onSelectResponseOption"
      checkbutton $frm.response.perOrder \
         -text $::caption(eshel,instrument,process,response,perOrder) \
         -variable ::eshel::process::option::widget(responsePerOrder)

      pack $frm.response.manual   -in [$frm.response getframe] -side top  -anchor w -fill none -expand 0
      pack $frm.response.select   -in [$frm.response getframe] -side top  -anchor w -fill x    -expand 1
      pack $frm.response.auto     -in [$frm.response getframe] -side top  -anchor w -fill none -expand 0
      pack $frm.response.none     -in [$frm.response getframe] -side top  -anchor w -fill none -expand 0
      pack $frm.response.perOrder -in [$frm.response getframe] -side top  -anchor w -fill none -expand 0


   Button $frm.makeri -text  $::caption(eshel,instrument,process,option,makeri) \
      -command "::eshel::response::run $private(tkbase) $visuNo"

   grid $frm.config           -in $frm -row 0 -column 0 -sticky ew -pady 4
   grid $frm.flatFieldEnabled -in $frm -row 1 -column 0 -sticky w -pady 4
   grid $frm.saveObjectImage  -in $frm -row 2 -column 0 -sticky w -pady 4
   grid $frm.debugLog         -in $frm -row 3 -column 0 -sticky w -pady 4
   grid $frm.response         -in $frm -row 4 -column 0 -sticky ewn
   grid $frm.makeri           -in $frm -row 5 -column 0 -sticky ewn

   grid rowconfig    $frm 0 -weight 0
   grid rowconfig    $frm 1 -weight 0
   grid rowconfig    $frm 2 -weight 0
   grid rowconfig    $frm 3 -weight 0
   grid rowconfig    $frm 4 -weight 0
   grid columnconfig $frm 0 -weight 1

   pack $frm  -side top -fill x -expand 1

   #--- je copie les options de la configuration dans les variables des widgets
   onSelectResponseOption
}

#------------------------------------------------------------
## @brief retourne le titre de la fenêtre
#  @details cette procédure est appelée par ::confGenerique::getLabel
#  @private
#
proc ::eshel::process::option::getLabel { } {
   return "$::caption(eshel,title) $::caption(eshel,instrument,optionProcess)"
}

#------------------------------------------------------------
## @brief met à jour les options quand on change de configuration
#  @param visuNo numéro de la visu
#  @param args ??
#  @public
#  @todo commenter le param args
#
proc ::eshel::process::option::onChangeConfig { visuNo args } {

   #--- je copie les options de la configuration dans les widgets
   copyOptionToWidget
   #--- je rafraichis les widgets de la reponse instrumentale
   onSelectResponseOption

}

#----------------------------------------------------------------------------
# copyOptionToWidget
#   copie les options dans les widgets
#
proc ::eshel::process::option::copyOptionToWidget { } {
   variable private
   variable widget

   set configId $::conf(eshel,currentInstrument)
   set widget(flatFieldEnabled)  $::conf(eshel,instrument,config,$configId,flatFieldEnabled)
   set widget(responseOption)    $::conf(eshel,instrument,config,$configId,responseOption)
   set widget(responseFileName)  [file nativename $::conf(eshel,instrument,config,$configId,responseFileName)]
   set widget(responsePerOrder)  $::conf(eshel,instrument,config,$configId,responsePerOrder)
   set widget(saveObjectImage)   $::conf(eshel,instrument,config,$configId,saveObjectImage)
   set widget(debugLog)          $::conf(eshel,instrument,config,$configId,debugLog)

   set widget(configName)        $::conf(eshel,instrument,config,$configId,configName)
}

#----------------------------------------------------------------------------
# onSelectResponseOption
#    met a jour les variables et les widgets quand on selectionne une option de la reponse instrumentale
#
proc ::eshel::process::option::onSelectResponseOption { } {
   variable private
   variable widget

   set frm $private(frm)
   if { $widget(responseOption) == "MANUAL" } {
      #--- j'active le widget de saisie du nom de fichier
      $frm.response.select.entry  configure -state normal
      $frm.response.select.button configure -state normal
   } else {
      #--- je desactive le widget de saisie du nom de fichier
      $frm.response.select.entry  configure -state disabled
      $frm.response.select.button configure -state disabled
   }

   if { $widget(responseOption) == "NONE" } {
      #--- je desactive le wigdet perOrder
      $frm.response.perOrder configure -state disabled
   } else {
     #--- j'active le wigdet perOrder
      $frm.response.perOrder configure -state normal
   }
}

#------------------------------------------------------------
## @brief ouvre la fenêtre pour sélectionner une réponse instrumentale
#  @param   visuNo numéro de la visu
#  @private
#
proc ::eshel::process::option::selectResponseFileName { } {
   variable private
   variable widget

   #--- j'affiche la fenetre de saisie du nom de la nouvelle configuration
   set fileName [ tk_getOpenFile \
      -title $::caption(eshel,instrument,process,response,title) \
      -filetypes [list [ list "FITS File"  {.fit} ]] \
      -initialdir $::conf(eshel,mainDirectory) \
      -parent $private(frm) \
   ]

   if { $fileName != "" } {
      set catchResult [ catch {
         #--- je verifie que le fichier est une reponse instrumentale
         # TODO
         set widget(responseFileName) [file nativename $fileName]
      }]

      if { $catchResult !=0 } {
        ::tkutil::displayErrorInfo $::caption(eshel,instrument,process,response,title)
      }
   }
}

