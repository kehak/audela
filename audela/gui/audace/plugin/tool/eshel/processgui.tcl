##
# @file processgui.tcl
# @brief Fenêtre de configuration des traitements eShel
# @author Michel PUJOL
# $Id: processgui.tcl 13378 2016-03-15 21:19:06Z rzachantke $
#

## namespace eshel::processgui
#  @brief Fenêtre de configuration des traitements eShel
#  @details Point d'entrée principal \::eshel::processgui::run

namespace eval ::eshel::processgui {
   variable private

   package require dom
   set private(frm) ""
}

#------------------------------------------------------------
## @brief affiche la fenêtre de configuration des traitements
#  @param tkbase nom tk de la visu qui lance la fenêtre
#  @param visuNo numéro de la visu qui lance la fenêtre
#  @public
#
proc ::eshel::processgui::run { tkbase visuNo } {
   variable private

   package require Tablelist
   tablelist::addBWidgetComboBox

   set private(modifiedTable) 0
   set private(sortedColumn)  0

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,processWindowPosition) ] } { set ::conf(eshel,processWindowPosition)     "650x240+350+15" }

   #--- j'affiche la fenetre
   set private(This) "$tkbase.process"
   ::confGenerique::run  $visuNo $private(This) "::eshel::processgui" -modal 0 -geometry $::conf(eshel,processWindowPosition) -resizable 1
   wm minsize $private(This) 450 450
}

#------------------------------------------------------------
## @brief ferme la fenêtre
#  @param visuNo numéro de la visu qui lance la fenêtre
#  @public
#
proc ::eshel::processgui::cmdClose { visuNo } {
   variable private

   #--- je memoririse la position courante de la fenetre
   set ::conf(eshel,processWindowPosition) [ wm geometry $private(This) ]
}

#------------------------------------------------------------
# brief affiche l'aide de cet outil
# @public
#
proc ::eshel::processgui::showHelp { } {
   ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::eshel::getPluginType]] \
      [::eshel::getPluginDirectory] [::eshel::getPluginHelp] "process"
}

#------------------------------------------------------------
## @brief retourne le titre de la fenêtre de traitement
#  @public
#
proc ::eshel::processgui::getLabel { } {
   return "$::caption(eshel,title) $::caption(eshel,process)"
}

#------------------------------------------------------------
## @brief créé les onglets dans la fenêtre
#  @param frm nom tk de la frame créée par ::confgene::fillConfigPage
#  @param visuNo numéro de la visu qui lance la fenêtre
#  @private
#
proc ::eshel::processgui::fillConfigPage { frm visuNo } {
   variable private

   set private(frm) $frm

   #--- creation des boutons
   TitleFrame $frm.button -borderwidth 2 -relief ridge -text $::caption(eshel,process,manualCommand)
      Button  $frm.generate -text $::caption(eshel,process,generateRoadmap) \
         -command "::eshel::processgui::generateRoadmap "
      pack  $frm.generate  -in [$frm.button getframe] -side left -fill none -expand 1 -pady 4

      Button  $frm.generateAndStart -text $::caption(eshel,process,generateAndStart) \
         -command ::eshel::processgui::generateAndStartStartScript
      pack  $frm.generateAndStart  -in [$frm.button getframe] -side left -fill none -expand 1 -pady 4
      Button  $frm.displayOption -text $::caption(eshel,instrument,optionProcess) \
         -command "::eshel::processgui::displayOption $visuNo"
      pack  $frm.displayOption  -in [$frm.button getframe] -side right -fill none -expand 1 -pady 4

      ##checkbutton $frm.auto -text "$::caption(eshel,processAuto)" \
      ##   -variable ::conf(eshel,processAuto) \
      ##   -command "::eshel::processgui::setProcessAuto"
      ##pack  $frm.auto  -in [$frm.button getframe] -side right -fill none -expand 0 -pady 4
      ###Button  $frm.stop -text "$::caption(eshel,process,stop)" \
      ###   -command "::eshel::processgui::stopScript"
      ###pack  $frm.stop  -in [$frm.button getframe] -side left -fill none -expand 1 -pady 4
   pack $frm.button -side top -fill x -expand 0

   #--- Creation des onglets
   set notebook [ NoteBook $frm.notebook ]
   $notebook insert end "roadmap"  -text $::caption(eshel,process,roadmap)
   $notebook insert end "nightlog" -text $::caption(eshel,process,rawImage)
   $notebook insert end "reference" -text $::caption(eshel,process,referenceImage)
   $notebook insert end "archive" -text   $::caption(eshel,process,archiveImage)
   pack $frm.notebook  -side top -fill both -expand 1


   #--- j'affiche les wigdets dans les frames
   fillRawPage       [$notebook getframe "nightlog"]  $visuNo
   fillReferencePage [$notebook getframe "reference"] $visuNo
   fillRoadmapPage   [$notebook getframe "roadmap"]   $visuNo
   fillArchivePage   [$notebook getframe "archive"]   $visuNo
   pack $frm  -side top -fill both -expand 1

   #--- je mets a jour les widgets en fonction du mode de traitement
   setProcessAuto

   #--- je selectionne le premier onglet
   $notebook raise "roadmap"

   #--- j'affiche les traitements en cours
   ::eshel::processgui::copyRawToTable
   ::eshel::processgui::copyReferenceToTable
   ::eshel::processgui::copyRoadmapToTable

}

#------------------------------------------------------------
## @brief créé les widgets dans l'onglet des images brutes
#  @param frm nom tk de la frame créée par ::eshel::processgui::fillConfigPage
#  @param visuNo numéro visu qui lance la fenêtre
#  @private
#
proc ::eshel::processgui::fillRawPage { frm visuNo } {
   variable private

   #--- frame des boutons
   frame $frm.button -borderwidth 0 -relief raised
      button $frm.button.makeSerie -text $::caption(eshel,process,makeSerie) -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::processgui::makeSeries $visuNo"
      pack $frm.button.makeSerie  -side left -fill none -expand 0
      button $frm.button.unmakeSerie -text $::caption(eshel,process,remove) -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::processgui::unmakeSerie"
      pack $frm.button.unmakeSerie  -side left -fill none -expand 0

   pack $frm.button -side bottom -fill x -expand 0

   set paned [PanedWindow $frm.paned -side left]
   set paned1 [$frm.paned add]
   set private(serieTable) $paned1.serie.table

   #--- frame des series
   TitleFrame $paned1.serie -borderwidth 2 -relief ridge -text "$::caption(eshel,process,serie)"
      #--- scrollbars
      scrollbar $paned1.serie.ysb -command "$private(serieTable) yview"
      scrollbar $paned1.serie.xsb -command "$private(serieTable) xview" -orient horizontal

      #--- je cree la liste des colonnes
      foreach keywordName [::eshel::process::getSerieAttributeNames] {
         lappend columnList 0 $keywordName center
      }

      #--- Table des series
      ::tablelist::tablelist $private(serieTable) \
         -columns $columnList \
         -xscrollcommand [list $paned1.serie.xsb set] \
         -yscrollcommand [list $paned1.serie.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -exportselection 0 \
         -selectmode extended \
         -setfocus 1 \
         -forceeditendcommand  0 \
         -editstartcommand "::eshel::processgui::onEditStartTable"  \
         -activestyle none

      #--- je donne un nom a chaque colonne
      set col 0
      foreach keywordName [::eshel::process::getSerieAttributeNames] {
         $private(serieTable) columnconfigure $col -name $keywordName
         incr col
      }

      $private(serieTable) columnconfigure FILES -editable yes -editwindow ComboBox

      #--- je place la table et les scrollbars dans la frame
      grid $private(serieTable) -in [$paned1.serie getframe] -row 0 -column 0 -sticky ewns
      grid $paned1.serie.ysb -in [$paned1.serie getframe] -row 0 -column 1 -sticky nsew
      grid $paned1.serie.xsb -in [$paned1.serie getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$paned1.serie getframe] 0 -weight 1
      grid columnconfig [$paned1.serie getframe] 0 -weight 1

   pack $paned1.serie -side top -fill both -expand 1

   #--- frame de la table des fichiers
   set paned2 [$frm.paned add]
   set private(fileTable) $paned2.file.table

   TitleFrame $paned2.file -borderwidth 2 -relief ridge -text "$::caption(eshel,process,file)"
      #--- scrollbars
      scrollbar $paned2.file.ysb -command "$private(fileTable) yview"
      scrollbar $paned2.file.xsb -command "$private(fileTable) xview" -orient horizontal

      #--- je cree la liste des colonnes
      set columnList [list 0 FileName left ]
      foreach keywordName [::eshel::process::getFileAttributeNames] {
         lappend columnList 0 $keywordName center
      }

      #--- Table des fichiers
      ::tablelist::tablelist $private(fileTable) \
         -columns $columnList \
         -xscrollcommand [list $paned2.file.xsb set] \
         -yscrollcommand [list $paned2.file.ysb set] \
         -labelcommand "::eshel::processgui::cmdSortColumn" \
         -exportselection 0 \
         -selectmode extended \
         -setfocus 1 \
         -forceeditendcommand  0 \
         -editendcommand "::eshel::processgui::onEditEndTable"  \
         -activestyle none

      #--- je donne un nom a chaque colonne
      $private(fileTable) columnconfigure 0 -name "FILENAME" -align left
      set col 1
      foreach keywordName [::eshel::process::getFileAttributeNames] {
         $private(fileTable) columnconfigure $col -name $keywordName
         incr col
      }

      #--- je place la table et les scrollbars dans la frame
      grid $private(fileTable) -in [$paned2.file getframe] -row 0 -column 0 -sticky ewns
      grid $paned2.file.ysb -in [$paned2.file getframe] -row 0 -column 1 -sticky nsew
      grid $paned2.file.xsb -in [$paned2.file getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$paned2.file getframe] 0 -weight 1
      grid columnconfig [$paned2.file getframe] 0 -weight 1

   pack $paned2.file -side top -fill both -expand 1

   pack $paned -side top -fill both -expand 1

   #--- pop-up menu associe a la table des series
   set private(serieMenu)  $paned1.serie.menu
   menu $private(serieMenu) -tearoff no
   $private(serieMenu) add command -label $::caption(eshel,process,remove)  \
      -command "::eshel::processgui::unmakeSerie"
   $private(serieMenu) add command -label $::caption(eshel,process,moveRawToArchive)  \
      -command "::eshel::processgui::moveRawToArchive $visuNo"

   bind [$private(serieTable) bodypath] <<Button3>> [list tk_popup $private(serieMenu) %X %Y]

   #--- pop-up menu associe a la table des fichiers ignores
   set private(fileMenu)  $paned2.file.menu
   menu $private(fileMenu) -tearoff no
   $private(fileMenu) add command -label $::caption(eshel,process,makeSerie)  \
      -command "::eshel::processgui::makeSeries $visuNo"

   bind [$private(fileTable) bodypath] <<Button3>> [list tk_popup $private(fileMenu) %X %Y]

}

#------------------------------------------------------------
## @brief créé les widgets dans l'onglet des images de référence
#  @param frm nom tk de la frame créée par \::eshel::processgui::fillConfigPage
#  @param visuNo numéro visu qui lance la fenêtre
#  @private
#
proc ::eshel::processgui::fillReferencePage { frm visuNo } {
   variable private

   set private(referenceTable) $frm.reference.table

   #--- frame des series de reference
   TitleFrame $frm.reference -borderwidth 2 -relief ridge -text "$::caption(eshel,process,referenceImage)"
      #--- scrollbars
      scrollbar $frm.reference.ysb -command "$private(referenceTable) yview"
      scrollbar $frm.reference.xsb -command "$private(referenceTable) xview" -orient horizontal

      #--- je cree la liste des colonnes
      foreach keywordName [::eshel::process::getReferenceAttributeNames] {
         lappend columnList 0 $keywordName center
      }

      #--- Table des series
      ::tablelist::tablelist $private(referenceTable) \
         -columns $columnList \
         -xscrollcommand [list $frm.reference.xsb set] \
         -yscrollcommand [list $frm.reference.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      set col 0
      foreach keywordName [::eshel::process::getReferenceAttributeNames] {
         $private(referenceTable) columnconfigure $col -name $keywordName
         incr col
      }
      $private(referenceTable) columnconfigure FILENAME -align left

      #--- je place la table et les scrollbars dans la frame
      grid $private(referenceTable) -in [$frm.reference getframe] -row 0 -column 0 -sticky ewns
      grid $frm.reference.ysb -in [$frm.reference getframe] -row 0 -column 1 -sticky nsew
      grid $frm.reference.xsb -in [$frm.reference getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$frm.reference getframe] 0 -weight 1
      grid columnconfig [$frm.reference getframe] 0 -weight 1

   pack $frm.reference -side top -fill both -expand 1
}

#------------------------------------------------------------
## @brief créé les widgets dans l'onglet des traitements
#  @param frm nom tk de la frame cree par ::eshel::processgui::fillConfigPage
#  @param visuNo numéro visu qui lance la fenêtre
#  @private
#
proc ::eshel::processgui::fillRoadmapPage { frm visuNo } {
   variable private
   set private(roadmapTable) $frm.roadmap.table

   #--- frame des boutons
   frame $frm.button -borderwidth 0 -relief raised
      ###Button  $frm.button.generate -text "$::caption(eshel,process,generateRoadmap)" \
      ###   -command "::eshel::processgui::generateRoadmap "
      ###pack  $frm.button.generate -side left -fill none -expand 1 -pady 4
      Button $frm.button.editScript -text "$::caption(eshel,process,editScript)" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::processgui::editScript"
      pack $frm.button.editScript  -side left -fill none -expand 0
      Button  $frm.button.startScript -text "$::caption(eshel,process,startScript)" \
         -command "::eshel::processgui::startScript"
      pack  $frm.button.startScript -side left -fill none -expand 1 -pady 4
   pack $frm.button -side bottom -fill x -expand 0

   #--- frame de la table
   TitleFrame $frm.roadmap -borderwidth 2 -relief ridge -text "$::caption(eshel,process,roadmap)"
      #--- scrollbars
      scrollbar $frm.roadmap.ysb -command "$private(roadmapTable) yview"
      scrollbar $frm.roadmap.xsb -command "$private(roadmapTable) xview" -orient horizontal

      #--- je cree la liste des colonnes
      set columnList [list 0 "PROCESS" left 0 "OUTPUTFILE" left 0 "STATUS" left 0 "COMMENT" left ]

      #--- Table des series
      ::tablelist::tablelist $private(roadmapTable) \
         -columns $columnList \
         -xscrollcommand [list $frm.roadmap.xsb set] \
         -yscrollcommand [list $frm.roadmap.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      $private(roadmapTable) columnconfigure 0 -name "PROCESS"
      $private(roadmapTable) columnconfigure 1 -name "OUTPUTFILE"
      $private(roadmapTable) columnconfigure 2 -name "STATUS"
      $private(roadmapTable) columnconfigure 3 -name "COMMENT"

      #--- je place la table et les scrollbars dans la frame
      grid $private(roadmapTable) -in [$frm.roadmap getframe] -row 0 -column 0 -sticky ewns
      grid $frm.roadmap.ysb -in [$frm.roadmap getframe] -row 0 -column 1 -sticky nsew
      grid $frm.roadmap.xsb -in [$frm.roadmap getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$frm.roadmap getframe] 0 -weight 1
      grid columnconfig [$frm.roadmap getframe] 0 -weight 1

   pack $frm.roadmap -side top -fill both -expand 1
}

#------------------------------------------------------------
## @brief créé les widgets dans l'onglet des images d'archive
#  @param frm nom tk de la frame créée par ::eshel::processgui::fillConfigPage
#  @param visuNo numéro visu qui lance la fenêtre
#  @private
#
proc ::eshel::processgui::fillArchivePage { frm visuNo } {
   variable private

   set private(archiveTable) $frm.archive.table

   #--- frame des series de archive
   TitleFrame $frm.archive -borderwidth 2 -relief ridge -text $::caption(eshel,process,archiveImage)
      #--- scrollbars
      scrollbar $frm.archive.ysb -command "$private(archiveTable) yview"
      scrollbar $frm.archive.xsb -command "$private(archiveTable) xview" -orient horizontal

      #--- je cree la liste des colonnes
      foreach keywordName [::eshel::process::getSerieAttributeNames] {
         lappend columnList 0 $keywordName center
      }

      #--- Table des series d'archive
      ::tablelist::tablelist $private(archiveTable) \
         -columns $columnList \
         -xscrollcommand [list $frm.archive.xsb set] \
         -yscrollcommand [list $frm.archive.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -exportselection 0 \
         -selectmode extended \
         -setfocus 1 \
         -forceeditendcommand  0 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      set col 0
      foreach keywordName [::eshel::process::getSerieAttributeNames] {
         $private(archiveTable) columnconfigure $col -name $keywordName
         incr col
      }

      #--- je place la table et les scrollbars dans la frame
      grid $private(archiveTable) -in [$frm.archive getframe] -row 0 -column 0 -sticky ewns
      grid $frm.archive.ysb -in [$frm.archive getframe] -row 0 -column 1 -sticky nsew
      grid $frm.archive.xsb -in [$frm.archive getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$frm.archive getframe] 0 -weight 1
      grid columnconfig [$frm.archive getframe] 0 -weight 1

      #--- menu
      set private(archiveMenu)  $frm.archive.menu
      #--- pop-up menu associe a la table des archives
      menu $private(archiveMenu) -tearoff no
      $private(archiveMenu) add command -label $::caption(eshel,process,moveArchiveToRaw) \
         -command "::eshel::processgui::moveArchiveToRaw $visuNo"

      bind [$private(archiveTable) bodypath] <<Button3>> [list tk_popup $private(archiveMenu) %X %Y]

   pack $frm.archive -side top -fill both -expand 1
}

#----------------------------------------------------------------------------
## @brief
#  - désactive les boutons manuels si le mode automatique est sélectionné
#  - active les boutons manuels si le mode manuel est sélectionné
#  @public
#
proc ::eshel::processgui::setProcessAuto {  } {
   setFrameState
}

#------------------------------------------------------------------------------
## @brief trie les lignes par ordre alphabétique de la colonne
#   (est appelé quand on clique sur le titre de la colonne)
#  @private
#
proc ::eshel::processgui::cmdSortColumn { tbl col } {
   variable private
   set private(sortedColumn) $col
   tablelist::sortByColumn $tbl $col
}

#-----------------------------------------------------------
## @brief génère et affiche la roadmap des traitements à faire.
#  @details d&sactive les boutons manuels pendant le calcul de la roadmap
#  @private
#
proc ::eshel::processgui::generateRoadmap { } {
   variable private

   set catchResult [catch {
      ::eshel::process::generateAll
   } ]

   if { $catchResult != 0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }
}

#------------------------------------------------------------
## @brief affiche la liste des images brutes
#  @private
#
proc ::eshel::processgui::copyRawToTable { } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }

   #--- je vide la table des fichiers ignores
   $private(fileTable)  delete 0 end
   #--- je vide la table des series identifiees
   $private(serieTable)  delete 0 end

   #--- je remplis les tables des fichiers bruts isoles et la table des series de fichiers
   set filesNode [::eshel::process::getFilesNode]
   foreach fileNode [::dom::tcl::node children $filesNode] {
      if { [::dom::tcl::node cget $fileNode -nodeName] == "FILE" } {
         #--- c'est un fichier brut isolé
         set fileName [::dom::element getAttribute $fileNode "FILENAME"]
         #--- j'insere la nouvelle ligne a la fin de la table
         $private(fileTable) insert end $fileName
         foreach keywordName [::eshel::process::getFileAttributeNames] {
            set keywordValue [ ::dom::element getAttribute $fileNode $keywordName]
            #--- je copie l'attribut dans la colonne du mot cle
            $private(fileTable) cellconfigure end,$keywordName -text $keywordValue -editable 1
         }
      } else {
         #--- c'est une serie de fichiers bruts
         if { [::dom::element getAttribute $fileNode "RAW"] == 1 } {
            #--- j'insere une ligne vide a la fin de la table
            $private(serieTable) insert end " "
            #--- je renseigne les cellules de la ligne vide
            foreach keywordName [::eshel::process::getSerieAttributeNames] {
               switch $keywordName {
                  "FILES" {
                     #--- j'affiche le nombre de fichiers
                     ##set firstFileNode [::dom::tcl::node cget $fileNode -firstChild ]
                     ##set firstFileName [::dom::element getAttribute $firstFileNode "FILENAME"]
                     set nbFiles [llength [::dom::tcl::node children $fileNode]]
                     #--- la cellule est editable pour pouvoir conculter son contenu (voir onEditStartTable)
                     $private(serieTable) cellconfigure end,$keywordName -text $nbFiles -editable 1
                  }
                  default {
                     set keywordValue [::dom::element getAttribute $fileNode $keywordName]
                     $private(serieTable) cellconfigure end,$keywordName -text $keywordValue
                  }
               }
            }
         }
      }
   }

   #--- je trie la table
   $private(fileTable) sortbycolumn  $private(sortedColumn) -increasing
}

#------------------------------------------------------------
## @brief affiche le nom des images de référence dans la table de référence
#  @private
#
proc ::eshel::processgui::copyReferenceToTable { } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }
   #--- je vide la table des fichiers de reference
   $private(referenceTable)  delete 0 end

   #--- je remplis les tables des fichiers de reference
   set filesNode [::eshel::process::getFilesNode]
   foreach fileNode [::dom::tcl::node children $filesNode] {
      if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
         set fileName [::dom::element getAttribute $fileNode "FILENAME"]
         #--- j'insere la nouvelle ligne a la fin de la table
         $private(referenceTable) insert end $fileName
         foreach keywordName [::eshel::process::getReferenceAttributeNames] {
            set keywordValue [ ::dom::element getAttribute $fileNode $keywordName]
            #--- je copie l'attribut dans la colonne du mot cle
            $private(referenceTable) cellconfigure end,$keywordName -text $keywordValue -editable 0
         }
         set nodeName [::dom::tcl::node cget $fileNode -nodeName]
         if { $nodeName == "BAD_REF" } {
            $private(referenceTable) rowconfigure end -foreground red
         }
      }
   }
}

#------------------------------------------------------------
## @brief affiche les processus dans la table
#  @private
#
proc ::eshel::processgui::copyRoadmapToTable { } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }
   #--- je vide la table des traitements
   $private(roadmapTable)  delete 0 end

   #--- je remplis les tables des fichiers de reference
   foreach processNode [::dom::tcl::node children [::eshel::process::getRoadmapNode]] {
      set nodeName [::dom::tcl::node cget $processNode -nodeName]
      #--- je recupere le premier node qui est l'image en sortie
      set fileName   [::dom::element getAttribute $processNode "FILENAME"]
      set status     [::dom::element getAttribute $processNode "STATUS"]
      set comment    [::dom::element getAttribute $processNode "COMMENT"]

      $private(roadmapTable) insert end [list $nodeName $fileName $status $comment ]
      #--- je donne un nom a la ligne = nom de l'image en sortie du traitement
      $private(roadmapTable) rowconfigure end -name $fileName
      #--- j'affiche le status et la couleur associee
      setProcessStatus $fileName $status
   }
}

#------------------------------------------------------------
## @brief copie les nom des fichiers archives dans la table des archives
#  @private
#
proc ::eshel::processgui::copyArchiveToTable { } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }

   #--- je vide la table des fichiers archives
   $private(archiveTable)  delete 0 end

   #--- je remplis les tables des fichiers bruts isoles et la table des series de fichiers
   set archiveNode [::eshel::process::getArchiveNode]
   foreach fileNode [::dom::tcl::node children $archiveNode] {
      if { [::dom::tcl::node cget $fileNode -nodeName] == "FILE" } {
         #--- c'est un fichier brut isolé
         set fileName [::dom::element getAttribute $fileNode "FILENAME"]
         #--- j'insere la nouvelle ligne a la fin de la table
         $private(archiveTable) insert end $fileName
         foreach keywordName [::eshel::process::getFileAttributeNames] {
            set keywordValue [ ::dom::element getAttribute $fileNode $keywordName]
            #--- je copie l'attribut dans la colonne du mot cle
            $private(archiveTable) cellconfigure end,$keywordName -text $keywordValue -editable 1
         }
      } else {
         #--- c'est une serie de fichiers bruts
         #--- j'insere une ligne vide a la fin de la table
         $private(archiveTable) insert end " "
         #--- je renseigne les cellules de la ligne vide
         foreach keywordName [::eshel::process::getSerieAttributeNames] {
            switch $keywordName {
               "FILES" {
                  #--- j'affiche le nombre de fichiers
                  set nbFiles [llength [::dom::tcl::node children $fileNode]]
                  $private(archiveTable) cellconfigure end,$keywordName -text $nbFiles -editable 1
               }
               default {
                  set keywordValue [::dom::element getAttribute $fileNode $keywordName]
                  $private(archiveTable) cellconfigure end,$keywordName -text $keywordValue
               }
            }
         }
      }
   }

   #--- je trie la table
   ###$private(archiveTable) sortbycolumn  $private(sortedColumn) -increasing
}

#----------------------------------------------------------------------------
## @brief met à jour l'état de traitement d'un fichier
#   - todo    : traitement à faire
#   - running : traitement en cours
#   - done    : traitement termine correctement.
#   - error   : erreur pendant le traitement
#  @param fileName nom du fichier
#  @param status   état du fichier
#  @public
#
proc ::eshel::processgui::setProcessStatus { fileName status } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }

   #--- j'affiche le status
   $private(roadmapTable) cellconfigure $fileName,STATUS -text $status
   #--- je change la couleur
   switch $status {
      todo {
         $private(roadmapTable) rowconfigure $fileName -foreground black
      }
      running {
         $private(roadmapTable) rowconfigure $fileName -foreground blue
      }
      done {
         $private(roadmapTable) rowconfigure $fileName -foreground black
      }
      error {
         $private(roadmapTable) rowconfigure $fileName -foreground red
      }
   }
}

#------------------------------------------------------------
## @private enregistre les modifications des fichiers ignorés faites par l'utilisateur
#  @private
#
proc ::eshel::processgui::copyTableToNightlog { } {
   variable private

   #--- je copie les donnees de la table dans attributeList
   for { set rowIndex 0 } { $rowIndex < [$private(fileTable) size] } { incr rowIndex } {
      set attributeList ""
      set fileName  [$private(fileTable) cellcget $rowIndex,FILENAME -text]
      foreach keywordName [::eshel::process::getFileAttributeNames] {
         set keywordValue [string trim [$private(fileTable) cellcget $rowIndex,$keywordName -text]]
         lappend attributeList $keywordName $keywordValue
      }
      #--- je mets a jour les donnees de nightlog
      ::eshel::process::setFileAttributes $fileName $attributeList
   }
}

#------------------------------------------------------------
## @brief efface le contenu des tables
#  @private
#
proc ::eshel::processgui::resetTables { } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }

   set private(roadmapDate)   ""
   set private(validNb)       0
   set private(referenceNb)   0
   set private(ignoredNb)     0
   set private(processNb)     0

   #--- je vide la table des fichiers ignores
   $private(fileTable)  delete 0 end
   #--- je vide la table des series identifiees
   $private(serieTable)  delete 0 end
   #--- je vide la table des fichiers de reference
   $private(referenceTable)  delete 0 end
   #--- je vide la table des traitements
   $private(roadmapTable)  delete 0 end
   #--- je vide la table des archives
   $private(archiveTable)  delete 0 end
   update

}

#------------------------------------------------------------
## @brief affiche le détail de fichiers dans la colonne FILES de la table des séries
# @details cette procédure est appellée par le ::tablelist quand l'utilisateur sélectionne une cellule
# @param tktable  nom tk de la table
# @param row      numéro de ligne
# @param col      numéro de colonne
# @param value    valeur de la cellule
# @return  valeur validée de la cellule
# @private
#
proc ::eshel::processgui::onEditStartTable { tktable row col value } {
   variable private
   set w [$tktable editwinpath]
   switch [$tktable columncget $col -name] {
      FILES {
         #--- petite astuce pour toujours afficher le nombre de fichier dans l'entry de la combobox
         $w configure -modifycmd "$w.e configure -text [$w get]" -editable 0
         #--- je recupere l'indentifant de la serie
         set serieId [$tktable cellcget $row,SERIESID -text]
         #--- j'affiche la liste des fichiers de la serie
         set filesNode [::eshel::process::getFilesNode]
         foreach serieNode [::dom::tcl::node children $filesNode] {
            if { [::dom::element getAttribute $serieNode "SERIESID"] == $serieId } {
               foreach fileNode [::dom::tcl::node children $serieNode] {
                  $w insert end [::dom::element getAttribute $fileNode "FILENAME"]
               }
               break
            }
         }

      }
   }
   return $value
}

#------------------------------------------------------------
## @brief positionne le flag quand la table des fichiers non identifiés est modifiée
#  @param tktable nom tk de la table
#  @param row      numero de ligne
#  @param col      numero de colonne
#  @param value    valeur de la cellule
#  @return  valeur validee de la cellule
#  @private
#
proc ::eshel::processgui::onEditEndTable { tktable row col value } {
   variable private

   set private(modifiedTable) 1
   return $value
}

#------------------------------------------------------------
## @brief affiche la fenêtre des options du traitement
#  @private
#
proc ::eshel::processgui::displayOption { visuNo } {
   variable private
   ::eshel::process::option::run $private(This) $visuNo
}


#------------------------------------------------------------
## @brief affiche le script avec l'éditeur de texte par défaut défini dans la configuration d'Audela
#  @private
#
proc ::eshel::processgui::editScript { } {

   set fileName [file join $::conf(eshel,tempDirectory) $::conf(eshel,scriptFileName)]
   if { [file exists $fileName] == 1 } {
      exec "$::conf(editscript)" "$fileName" &
   } else {
      tk_messageBox -title "$::caption(eshel,title) - $::caption(eshel,process,editScript)" \
         -type ok -message $::caption(eshel,process,scriptNotFound) -icon error
   }
}

#------------------------------------------------------------
## @brief fabrique une série avec les fichiers sélectionnés pas l'utilisateur
#  @param visuNo  numero de la visu
#  @private
#
proc ::eshel::processgui::makeSeries { visuNo } {
   variable private

   #--- je recupere les index des fichiers selectionnes dans la table
   set fileIndexes [$private(fileTable)  curselection]
   #--- je retourne immediatemment si aucun item n'est selectionne
   if { [llength $fileIndexes] < 1 } {
      tk_messageBox -title "$::caption(eshel,title) - $::caption(eshel,process,serie)" \
         -type ok -message $::caption(eshel,process,selectFiles) -icon error
      return
   }

   #--- j'affiche la fenetre de mise a jour des mots cles
   set result [::eshel::makeseries::run $private(This) $visuNo $private(fileTable) $fileIndexes]

   if { $result == 0 } {
      #--- j'abandonne la saisie
      return
   }

   #--- j'enregistre les mots cles modifies
   ::eshel::processgui::copyTableToNightlog

   #--- je recupere les noms de fichiers
   set fileNames ""
   foreach fileIndex $fileIndexes  {
      lappend fileNames [$private(fileTable) cellcget $fileIndex,FILENAME -text]
   }

   #--- je constitue la serie
   set catchResult [catch {
      #--- je constitue la serie
      ::eshel::process::makeSerie $fileNames
      #--- je refraichis le contenu des tables
      copyRawToTable
      #--- j'enregistre les modifications des mots cles dans les images
      ::eshel::process::updateFileKeywords
      #--- je supprime la roadmap (actualiser la raodmap prendrait trop de temps)
      ::eshel::process::deleteRoadmap
      ::eshel::processgui::copyRoadmapToTable
   }]
   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }
}

#------------------------------------------------------------
## @brief déplace une série du répertoire archive vers le répertoire raw
#  @param visuNo  numero de la visu
#  @private
#
proc ::eshel::processgui::moveArchiveToRaw { visuNo } {
   variable private

   #--- je recupere la liste des lignes selectionnees
   set selection [$private(archiveTable)  curselection]

   #--- je retourne immediatemment si aucun item n'est selectionne
   if { $selection == "" } {
      tk_messageBox -title "$::caption(eshel,title) - $::caption(eshel,process,serie)" -type ok \
         -message $::caption(eshel,process,selectSeries) -icon error
      return
   }

   #--- je procede en deux temps car les index des series changent a chaque deplacement de serie
   #--- je recupere les serieId avant de deplacer
   set serieIdList ""
   foreach serieIndex $selection {
      #--- je recupere l'ID de la serie
      lappend serieIdList [$private(archiveTable) cellcget $serieIndex,SERIESID -text]
   }


   #--- je deplace les series
   foreach serieId $serieIdList {
      set catchResult [catch {
         #--- je deplace les fichiers dans le repertoire RAW
         ::eshel::process::moveArchiveToRaw $serieId
      }]
      if { $catchResult !=0 } {
         ::tkutil::displayErrorInfo $::caption(eshel,title)
      }
   }

   #--- je rafraichis l'affichage des listes
   set catchResult [catch {
      #--- je refraichis le contenu des tables des fichiers bruts
      copyRawToTable
      #--- je refraichis le contenu des tables des archives
      copyArchiveToTable
      #--- je supprime la roadmap (actualiser la roadmap prendrait trop de temps)
      ::eshel::process::deleteRoadmap
      ::eshel::processgui::copyRoadmapToTable
   }]
   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }

}

#------------------------------------------------------------
## @brief déplace une série du répertoire raw vers le répertoire archive
#  @param visuNo  numéro de la visu
#  @private
#
proc ::eshel::processgui::moveRawToArchive { visuNo } {
   variable private

   #--- je recupere le nom de la serie dans la table des series
   set selection [$private(serieTable)  curselection]
   #--- je retourne immediatemment si aucun item n'est selectionne
   if { $selection == "" } {
      tk_messageBox -title "$::caption(eshel,title) - $::caption(eshel,process,serie)" -type ok \
         -message $::caption(eshel,process,selectSeries) -icon error
      return
   }

   #--- je procede en deux temps car les index des series changent a chaque deplacement de serie
   #--- je recupere les serieId avant de deplacer
   set serieIdList ""
   foreach serieIndex $selection {
      #--- je recupere l'ID de la serie
      lappend serieIdList [$private(serieTable) cellcget $serieIndex,SERIESID -text]
   }
   #--- je deplace les series
   foreach serieId $serieIdList {
      set catchResult [catch {
         #--- je deplace les fichiers vers le repertoire ARCHIVE
         ::eshel::process::moveRawToArchive $serieId
      }]
      if { $catchResult !=0 } {
         ::tkutil::displayErrorInfo $::caption(eshel,title)
      }
   }

   #--- je rafraichis l'affichage des listes
   set catchResult [catch {
      #--- je refraichis le contenu des tables des fichiers bruts
      copyRawToTable
      #--- je refraichis le contenu des tables des archives
      copyArchiveToTable
      #--- je supprime la roadmap (actualiser la roadmap prendrait trop de temps)
      ::eshel::process::deleteRoadmap
      ::eshel::processgui::copyRoadmapToTable
   }]
   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }

}

#------------------------------------------------------------
## @brief modifie les mots clés
#  @param visuNo  numéro de la visu
#  @private
#
proc ::eshel::processgui::editKeyword { visuNo } {
   variable private

   #--- je recupere les index des fichiers selectionnes dans la table
   set fileIndexes [$private(fileTable)  curselection]
   #--- je retourne immediatemment si aucun item n'est selectionne
   if { [llength $fileIndexes] < 1 } {
      tk_messageBox -title "$::caption(eshel,title) - $::caption(eshel,process,serie)" \
         -type ok -message $::caption(eshel,process,selectFiles) -icon error
      return
   }

   #--- j'affiche la fenetre de mise a jour des mots cles
   set result [::eshel::makeseries::run $private(This) $visuNo $private(fileTable) $fileIndexes]

   if { $result == 0 } {
      #--- j'abandonne la saisie
      return
   }

   #--- j'enregistre les mots cles modifies
   ::eshel::processgui::copyTableToNightlog

   #--- je recupere les noms de fichiers
   set fileNames ""
   foreach fileIndex $fileIndexes  {
      lappend fileNames [$private(fileTable) cellcget $fileIndex,FILENAME -text]
   }

   #--- je constitue la serie
   set catchResult [catch {
      #--- je constitue la serie
      ::eshel::process::makeSerie $fileNames
      #--- je refraichis le contenu des tables
      copyRawToTable
      #--- je demande la confirmation de l'enregistrement des mots cles dans les images
      ::eshel::process::updateFileKeywords
   }]
   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }
}

#------------------------------------------------------------
## @brief défait une série
#  @details les fichiers de la série sont deplacés dans la table des
#   fichiers non identifiés
#  @private
#
proc ::eshel::processgui::unmakeSerie { } {
   variable private

   ###if { $private(modifiedTable) == 1 } {
   ###   copyTableToNightlog
   ###}

   #--- je recupere le nom de la serie
   set serieIndex [$private(serieTable)  curselection]
   #--- je retourne immediatemment si aucun item n'est selectionne
   if { "$serieIndex" == "" } {
      tk_messageBox -title "$::caption(eshel,title) - $::caption(eshel,process,serie)" -type ok \
         -message $::caption(eshel,process,selectSeries) -icon error
      return
   }
   set serieId [$private(serieTable) cellcget $serieIndex,SERIESID -text]

   #--- je supprime la serie
   set catchResult [catch {
      ::eshel::process::unmakeSerie $serieId
      #--- je refraichis le contenu des tables des fichiers bruts
      copyRawToTable
      #--- je supprime la roadmap (actualiser la roadmap prendrait trop de temps)
      ::eshel::process::deleteRoadmap
      ::eshel::processgui::copyRoadmapToTable
   }]
   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }
}

#------------------------------------------------------------
## @brief lance le traitement
#  @private
#
proc ::eshel::processgui::startScript { } {
   variable private

   set catchResult [catch {
      #--- je lance le script
      ::eshel::process::startScript
   } ]
   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(eshel,title)
   }

}

#------------------------------------------------------------
## @brief lance le traitement
#  @private
#
proc ::eshel::processgui::generateAndStartStartScript { } {
   variable private

   #--- je selectionne l'onglet des traitements
   $private(frm).notebook raise "roadmap"

   #--- je lance la generation et letraitement
   ::eshel::process::startProcess
}

#------------------------------------------------------------
## @brief arrête le traitement
#  @private
#
proc ::eshel::processgui::stopScript { } {
   variable private

   #--- j'arrete le script
   ::eshel::process::stopScript
}

#------------------------------------------------------------
## @brief change l'état des widgets dans les frames
#  @public
#
proc ::eshel::processgui::setFrameState {  } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return 0
   }

   if { $::conf(eshel,processAuto) == 1  } {
      set state "disabled"
   } else {
      switch [::eshel::process::getRoadmapState ] {
         "0" {
            set state "normal"
         }
         "1" {
            set state "running"
         }
         "generate" {
            set state "running"
         }
         "stopping" {
            set state "stopping"
         }
      }
   }

   set roadmapFrame [$private(frm).notebook getframe "roadmap"]
   set rawFrame     [$private(frm).notebook getframe "nightlog"]

   switch $state {
      normal {
         $private(frm).generate           configure -state normal
         $roadmapFrame.button.editScript  configure -state normal
         $roadmapFrame.button.startScript configure -state normal
         $rawFrame.button.makeSerie       configure -state normal
         $rawFrame.button.unmakeSerie     configure -state normal
         $private(frm).generateAndStart   configure -state normal \
            -text $::caption(eshel,process,generateAndStart) \
            -command "::eshel::processgui::generateAndStartStartScript"
      }
      disabled {
         $private(frm).generate           configure -state disabled
         $roadmapFrame.button.editScript  configure -state disabled
         $roadmapFrame.button.startScript configure -state disabled
        $rawFrame.button.makeSerie       configure -state disabled
         $rawFrame.button.unmakeSerie     configure -state disabled
         $private(frm).generateAndStart   configure -state disabled
      }
      running {
         $private(frm).generate           configure -state disabled
         $roadmapFrame.button.editScript  configure -state disabled
         $roadmapFrame.button.startScript configure -state disabled
         $rawFrame.button.makeSerie       configure -state disabled
         $rawFrame.button.unmakeSerie     configure -state disabled
         $private(frm).generateAndStart   configure -state normal \
            -text $::caption(eshel,process,stopScript) \
            -command "::eshel::processgui::stopScript"
      }
      stopping {
         $private(frm).generateAndStart   configure -state disabled
         $roadmapFrame.button.editScript  configure -state disabled
         $roadmapFrame.button.startScript configure -state disabled
         $rawFrame.button.makeSerie       configure -state disabled
         $rawFrame.button.unmakeSerie     configure -state disabled
         $private(frm).generateAndStart   configure -state disabled \
            -text $::caption(eshel,process,stopping) \
            -command ""
      }
   }
   update
}

