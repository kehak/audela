#
## @file session.tcl
#  @brief Configuration des paramètres de session
#  @author Michel PUJOL
#  $Id: session.tcl 13356 2016-03-11 21:30:34Z rzachantke $
#

## namespace eshel::session
#  @brief Configuration des paramètres de session

namespace eval ::eshel::session {

}

#------------------------------------------------------------
## @brief affiche la fenêtre du traitement
#  @details utilise les fonctions de la classe parent ::confGenerique
#  @param tkbase nom tk de la fenetre parent
#  @param visuNo  numero de la visu parent
#  @public
#
proc ::eshel::session::run { tkbase visuNo } {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,sessionWindowPosition) ] } { set ::conf(eshel,sessionWindowPosition) "400x300+20+10" }

   set private(upFolderIcon) [image create photo upfolder -data {
      R0lGODlhEAAQAIMAAAAAAP//AOzp2AAAAORY6APBJwAAAHcS9zNuXPMhXDNu
      UMbGxhZhOfEAFwAAAAD//yH5BAAAAP8ALAAAAAAQABAAAAQ3cMlJq70WaI0l
      CAIYANhmntwChKzYCuTHrq4Yz9oLxrup37baTOWi/VQt1FAmrAF1rxhqSupc
      IgA7}]

   #--- j'affiche la fenetre
   set private($visuNo,This) "$tkbase.session"
   set private(apply)  ""
   ::confGenerique::run  $visuNo $private($visuNo,This) "::eshel::session" -modal 0 -geometry $::conf(eshel,sessionWindowPosition) -resizable 1

}

#------------------------------------------------------------
## @brief ferme la fenetre
#  @details cette procédure est appelée par ::confGenerique::cmdClose
#  @param visuNo  numéro de la visu
#  @return
#   - 0  s'il ne faut pas fermer la fenetre
#   - 1  s'il faut fermer la fenetre
#  @public
#
proc ::eshel::session::cmdClose { visuNo } {
   variable private
   global caption

   if { $private(apply) == "error" } {
      set private(apply)  ""
      #--- je retourne 0 pour empecher de fermer la fenetre (voir ::confGenerique::run)
      return 0
   }
   #--- je memorise la position courante de la fenetre
   set ::conf(eshel,sessionWindowPosition) [ wm geometry $private($visuNo,This) ]
}

#------------------------------------------------------------
## @brief affiche l'aide de cet outil
#  @details cette procédure est appelée par ::confGenerique::showHelp
#  @private
#
proc ::eshel::session::showHelp { } {
   ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::eshel::getPluginType]] \
      [::eshel::getPluginDirectory] [::eshel::getPluginHelp] "session"
}

#------------------------------------------------------------
## @brief enregistre les modifications
#  @details cette procédure est appelée par ::confGenerique::cmdApply
#  @param visuNo  numero de la visu parent
#  @private
#
proc ::eshel::session::cmdApply { visuNo } {
   variable widget

   set private(apply)  ""
   set errorMessage    ""
   #--- je verifie s'il existe des erreurs (existance de variables widget(error,...)
   foreach name [array names widget error,*] {
      #--- je recupere le nom de la valeur
      set valueName [lindex [split $name "," ] 1]
      switch $valueName {
         observer {
            append errorMessage "$::caption(eshel,session,observer): $widget(error,$valueName)\n"
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

   set catchResult [ catch {
      ::eshel::setSessionDirectory $widget(mainDirectory)

      set ::conf(eshel,masterDirectory) [file normalize $widget(masterDirectory)]
   }]

   if { $catchResult == 1 } {
      tk_messageBox -message "$::caption(eshel,session,directoryError)\n$::errorInfo" -icon error -title $::caption(eshel,title)
      set private(apply)  "error"
      return
   }

   #--- je copie les autres valeurs dans les variables
   set ::conf(posobs,nom_observateur)  $widget(observer)
   set ::conf(eshel,showProfile)       $widget(showProfile)
   set ::conf(eshel,enabledLogFile)    $widget(enabledLogFile)
   set ::conf(eshel,enableComment)     $widget(enableComment)
   set ::conf(eshel,enableGuidingUnit) $widget(enableGuidingUnit)

   #--- je mets a jour la fenetre principale pour prendre en compte les modifications de la session
   ::eshel::adaptPanel $visuNo

}

#------------------------------------------------------------
## @brief créé les widgets de la fenêtre de configuration de la session
#  @details cette procédure est appelée par ::confGenerique::fillConfigPage a la creation de la fenetre
#  @param frm nom tk de la frame cree par ::confgene::fillConfigPage
#  @param visuNo numero de la visu
#  @private
#
proc ::eshel::session::fillConfigPage { frm visuNo } {
   variable widget
   variable private
   global caption

   set private($visuNo,frm) $frm

   #--- j'initalise les variables temporaires
   set widget(observer)      $::conf(posobs,nom_observateur)
   set widget(mainDirectory) [file nativename $::conf(eshel,mainDirectory)]
   set widget(subDirectory)  [clock format [clock seconds] -format "%Y%m%d"]
   set widget(masterDirectory) [file nativename $::conf(eshel,masterDirectory)]
   set widget(showProfile)    $::conf(eshel,showProfile)
   set widget(enabledLogFile) $::conf(eshel,enabledLogFile)
   set widget(enableComment)    $::conf(eshel,enableComment)
   set widget(enableGuidingUnit) $::conf(eshel,enableGuidingUnit)

   #--- je controle le contenu du repertoire
   set rawDirectory        "$widget(mainDirectory)/raw"
   set tempDirectory       "$widget(mainDirectory)/temp"
   set archiveDirectory    "$widget(mainDirectory)/archive"
   set referenceDirectory  "$widget(mainDirectory)/reference"
   set processedDirectory  "$widget(mainDirectory)/processed"
   set masterDirectory     "$widget(masterDirectory)"
   ###if { [file exists $rawDirectory] == 0
   ###   || [file exists $tempDirectory] == 0
   ###   || [file exists $archiveDirectory] == 0
   ###   || [file exists $referenceDirectory] == 0
   ###   || [file exists $processedDirectory] == 0 } {
   ###   #--- si un sous repertoire n'existe pas , je ne ne prend pas en compte le repertoire principal
   ###   set widget(mainDirectory) ""
   ###}

   #--- Noms des observeteurs
   label $frm.observerLabel   -text $caption(eshel,session,observer) -justify left
   entry $frm.observerEntry   -textvariable ::eshel::session::widget(observer)  -justify left \
      -validate key -validatecommand { ::eshel::validateString %W %V %P %s fits 0 70 :::eshel::session::widget(error,observer) }

   DynamicHelp::add $frm.observerLabel -text $::caption(eshel,session,observerHelp)
   DynamicHelp::add $frm.observerEntry -text $::caption(eshel,session,observerHelp)

   #--- Repertoire des images de la session
   label  $frm.directoryLabel  -text $caption(eshel,session,mainDirectory) -justify left
   entry  $frm.directoryEntry  -textvariable ::eshel::session::widget(mainDirectory) -justify left
   Button $frm.directoryButton  -text "..." -command "::eshel::session::selectSessionDirectory $visuNo"
   Button $frm.upButton  -image $private(upFolderIcon) -command "::eshel::session::selectParentDirectory $visuNo"
   label  $frm.subDirectoryLabel  -text $caption(eshel,session,subDirectoryLabel) -justify left
   entry  $frm.subDirectoryEntry  -textvariable ::eshel::session::widget(subDirectory) -justify left
   Button $frm.subDirectoryButton  -text $caption(eshel,session,subDirectoryButton) -command "::eshel::session::createSubDirectory $visuNo"
   #--- master directory
   label  $frm.masterDirectoryLabel  -text $caption(eshel,session,masterDirectory) -justify left
   entry  $frm.masterDirectoryEntry  -textvariable ::eshel::session::widget(masterDirectory) -justify left
   Button $frm.masterDirectoryButton  -text "..." -command "::eshel::session::selectMasterDirectory $visuNo"

   checkbutton $frm.showProfile  -justify left -text $::caption(eshel,session,showProfile) \
       -variable ::eshel::session::widget(showProfile)
   checkbutton $frm.enabledLogFile  -justify left -text $::caption(eshel,session,enabledLogFile) \
      -variable ::eshel::session::widget(enabledLogFile)
   checkbutton $frm.enableComment  -justify left -text $::caption(eshel,session,enableComment) \
      -variable ::eshel::session::widget(enableComment)
   checkbutton $frm.enableGuidingUnit  -justify left -text $::caption(eshel,session,enableGuidingUnit) \
      -variable ::eshel::session::widget(enableGuidingUnit)

   #--- Label de l'en-tete FITS
   label $frm.fitsKeywordLabel -text "$::caption(eshel,session,fitsKeywordLabel)"
   button $frm.fitsKeywordButton -text "$::caption(eshel,session,fitsKeywordButton)" \
      -command "::keyword::run $visuNo ::conf(eshel,keywordConfigName)"
   entry $frm.fitsKeywordLabelNom -textvariable ::conf(eshel,keywordConfigName) \
      -state readonly -takefocus 0 -justify center

   #--- nom du site
   label $frm.siteLabel       -text $caption(eshel,session,site) -justify left
   entry $frm.siteEntry       -textvariable ::conf(posobs,nom_observatoire) -state readonly -justify left
   #--- nom de la configuration
   label $frm.configurationLabel   -text $caption(eshel,session,configuration) -justify left
   entry $frm.configurationEntry   -text ::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),configName) -state readonly -justify left

   #--- placement dans la grille
   grid $frm.observerLabel       -in $frm -row 0 -column 0 -sticky wn  -padx 2
   grid $frm.observerEntry       -in $frm -row 0 -column 1 -sticky wen -padx 2
   grid $frm.directoryLabel      -in $frm -row 1 -column 0 -sticky wn  -padx 2
   grid $frm.directoryEntry      -in $frm -row 1 -column 1 -sticky wen -padx 2
   grid $frm.directoryButton     -in $frm -row 1 -column 2 -sticky wen -padx 2
   grid $frm.upButton            -in $frm -row 1 -column 3 -sticky wn  -padx 2
   grid $frm.subDirectoryLabel   -in $frm -row 2 -column 0 -sticky wn  -padx 2
   grid $frm.subDirectoryEntry   -in $frm -row 2 -column 1 -sticky wen -padx 2
   grid $frm.subDirectoryButton  -in $frm -row 2 -column 2 -sticky wen -padx 2 -columnspan 2
   grid $frm.masterDirectoryLabel  -in $frm -row 3 -column 0 -sticky wn  -padx 2
   grid $frm.masterDirectoryEntry  -in $frm -row 3 -column 1 -sticky wen -padx 2
   grid $frm.masterDirectoryButton -in $frm -row 3 -column 2 -sticky wen -padx 2

   grid $frm.siteLabel           -in $frm -row 4 -column 0 -sticky wn  -padx 2 -pady 2
   grid $frm.siteEntry           -in $frm -row 4 -column 1 -sticky wen -padx 2
   grid $frm.configurationLabel  -in $frm -row 5 -column 0 -sticky wn  -padx 2
   grid $frm.configurationEntry  -in $frm -row 5 -column 1 -sticky wen -padx 2
   grid $frm.showProfile         -in $frm -row 6 -column 0 -sticky wn  -padx 2 -columnspan 4
   grid $frm.enabledLogFile      -in $frm -row 7 -column 0 -sticky wn  -padx 2 -columnspan 4
   grid $frm.enableComment       -in $frm -row 8 -column 0 -sticky wn  -padx 2 -columnspan 4
   grid $frm.enableGuidingUnit   -in $frm -row 9 -column 0 -sticky wn  -padx 2 -columnspan 4

   grid $frm.fitsKeywordLabel    -in $frm -row 10 -column 0 -sticky wn  -padx 2 -columnspan 1
   grid $frm.fitsKeywordButton   -in $frm -row 10 -column 1 -sticky wn  -padx 2 -columnspan 1
   grid $frm.fitsKeywordLabelNom -in $frm -row 10 -column 2 -sticky wn  -padx 2 -columnspan 1

   grid rowconfig  $frm 10 -weight 1
   ##grid columnconfig $frm 0 -weight 1
   ##grid columnconfig $frm 1 -weight 0
   grid columnconfig $frm 1 -weight 1

   pack $frm  -side top -fill x -expand 1
}

#------------------------------------------------------------
## @brief retourne le titre de la fenetre
#  @details cette procédure est appelée par ::confGenerique::getLabel
#  @private
#
proc ::eshel::session::getLabel { } {
   global caption

   return "$caption(eshel,title) $caption(eshel,session)"
}

#------------------------------------------------------------
## @brief choix du répertoire de la session
#  @param visuNo : numero de la visu
#  @private
#
proc ::eshel::session::selectSessionDirectory { visuNo } {
   variable widget
   variable private

   set result [ tk_chooseDirectory -title "$::caption(eshel,title) - $::caption(eshel,session,mainDirectory)" \
      -initialdir $widget(mainDirectory) -parent $private($visuNo,This)  ]
   if {$result!=""} {
      set widget(mainDirectory) [file nativename $result]
   }
}

#------------------------------------------------------------
## @brief choix du répertoire des images maîtres
#  @param visuNo numéro de la visu
#  @private
#
proc ::eshel::session::selectMasterDirectory { visuNo } {
   variable widget
   variable private

   set result [ tk_chooseDirectory -title "$::caption(eshel,title) - $::caption(eshel,session,masterDirectory)" \
      -initialdir $widget(masterDirectory) -parent $private($visuNo,This)  ]
   if {$result!=""} {
      set widget(masterDirectory) [file nativename $result]
   }
}


#------------------------------------------------------------
## @brief sélectionne le répertoire parent comme répertoire principal
#  @param visuNo numéro de la visu
#
proc ::eshel::session::selectParentDirectory { visuNo } {
   variable widget

   #--- j'affiche le contenu du repertoire parent
   set widget(mainDirectory) [file nativename [ file dirname $widget(mainDirectory) ]]
}

#------------------------------------------------------------
## @brief créé un sous répertoire et le sélectionne comme répertoire principal
#  @param visuNo : numero de la visu
#
proc ::eshel::session::createSubDirectory { visuNo } {
   variable widget

   set subDirectory [ file join $widget(mainDirectory) $widget(subDirectory) ]
   file mkdir $subDirectory
   #--- le sous repertoire devient le repertoire principal
   set widget(mainDirectory) [file nativename $subDirectory]
}

