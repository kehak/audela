#
## @file sophiehistogram.tcl
#  @brief Fenêtre affichant l'histogramme des écarts étoile/consigne
#  $Id: sophiehistogram.tcl 13349 2016-03-11 14:45:52Z rzachantke $
#

## namespace sophie::histogram
#  @brief Fenêtre affichant l'histogramme des écarts étoile/consigne

namespace eval ::sophie::histogram {
   variable private

   set private(realTimeFileName) ""
   set private(realTimeVisuNo)   ""

}

#-------------------------------------------------------------
## @brief affiche la fenêtre de l'histogramme
#  @param visuNo numéro de la visu de la fenêtre de l'outil eShel
#  @public
#
proc ::sophie::histogram::run { visuNo } {
   variable private

   set ::caption(sophie,histogram,title)      "Histogramme"
   set ::caption(sophie,alphaDiff)            "Ecart alpha"
   set ::caption(sophie,deltaDiff)            "Ecart delta"
   set ::caption(sophie,histogram,startDate)  "Heure début"
   set ::caption(sophie,histogram,endDate)    "Heure fin"
   set ::caption(sophie,histogram,duration)   "Durée"
   set ::caption(sophie,histogram,pointNb)    "Nb points"
   set ::caption(sophie,histogram,RA)         "RA"
   set ::caption(sophie,histogram,DEC)        "DEC"
   set ::caption(sophie,histogram,AZ)         "Azimut"
   set ::caption(sophie,histogram,EL)         "Hauteur"
   set ::caption(sophie,histogram,clipboard)  "Copie vers presse papier"
   set ::caption(sophie,histogram,clear)      "RAZ affichage"
   set ::caption(sophie,histogram,preference) "Préférences"

   set private($visuNo,alphaDiff,show) 1
   set private($visuNo,deltaDiff,show) 1

   #--- nom du fichier qui est affiche
   set private($visuNo,fileName) ""

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(sophie,histogram,position) ] } { set ::conf(sophie,histogram,position) "300x200+250+75" }
   if { ! [ info exists ::conf(sophie,histogram,step) ] }     { set ::conf(sophie,histogram,step)     0.2 }

   set private($visuNo,this) ".audace.sophieHisto$visuNo"

   if { [winfo exists $private($visuNo,this) ] == 0 } {
      uplevel #0 ::blt::vector create ::sophieHistogramAbcisse
      uplevel #0 ::blt::vector create ::sophieHistogramAlphaDiff
      uplevel #0 ::blt::vector create ::sophieHistogramDeltaDiff

      #--- j'affiche la fenetre
      ::confGenerique::run $visuNo $private($visuNo,this) [namespace current] -modal 0 \
         -geometry $::conf(sophie,histogram,position) \
         -resizable 1
      wm minsize $private($visuNo,this) 440 500

   } else {
      focus $private($visuNo,this)
   }
}

#------------------------------------------------------------
# getLabel
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::sophie::histogram::getLabel { } {
   return $::caption(sophie,histogram,title)
}

#------------------------------------------------------------
# showHelp
#  affiche l'aide de la fenêtre
#------------------------------------------------------------
###proc ::sophie::histogram::showHelp { } {
###   variable private
###
###   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::sophie::getPluginType ] ] \
###      [ ::sophie::getPluginDirectory ] [ ::sophie::getPluginHelp ]
###}
###

#------------------------------------------------------------
# cmdClose
#  recupere la position de l'outil apres appui sur Fermer
#
#------------------------------------------------------------
proc ::sophie::histogram::cmdClose { visuNo } {
   variable private

   if { [info  exists private($visuNo,frm)] } {
      if { [winfo exists $private($visuNo,frm)] } {
         ::blt::vector destroy ::sophieHistogramAbcisse
         ::blt::vector destroy ::sophieHistogramAlphaDiff
         ::blt::vector destroy ::sophieHistogramDeltaDiff

         set index [lsearch $private(realTimeVisuNo) $visuNo]
         if { $index != -1 } {
            #--- je supprime la visu de la liste d'abonnement
            set private(realTimeVisuNo) [lreplace $private(realTimeVisuNo) $index $index]
         }
         set private($visuNo,fileName) ""

         #--- je supprime le menubar et toutes ses entrees
         Menubar_Delete "sohpieHistogram${visuNo}"
         #--- je sauve la taille et la position de la fenetre
         set ::conf(sophie,histogram,position) [winfo geometry [winfo toplevel $private($visuNo,frm) ]]
         destroy [ winfo toplevel $private($visuNo,frm) ]
      }
   }
}

#------------------------------------------------------------
# fillConfigPage { }
#  fenetre de configuration
#------------------------------------------------------------
proc ::sophie::histogram::fillConfigPage { frm visuNo } {
   variable private

   package require BLT

   #--- je cree le menu
   set private($visuNo,menu) "$private($visuNo,this).menubar"
   set menuNo "sohpieHistogram${visuNo}"
   Menu_Setup $menuNo $private($visuNo,menu)
      #--- menu file
      Menu           $menuNo "$::caption(audace,menu,file)"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,charger)..." \
         "::sophie::histogram::onLoadFile $visuNo"
      Menu_Separator $menuNo "$::caption(audace,menu,file)"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,quitter)" \
        "::confGenerique::cmdClose $visuNo [namespace current]"

      #--- menu edition
      Menu           $menuNo "$::caption(audace,menu,display)"
      Menu_Check     $menuNo "$::caption(audace,menu,display)" "$::caption(sophie,alphaDiff)" \
      "::sophie::histogram::private($visuNo,alphaDiff,show)" "::sophie::histogram::onDisplayLine $visuNo"
      Menu_Check     $menuNo "$::caption(audace,menu,display)" "$::caption(sophie,deltaDiff)" \
      "::sophie::histogram::private($visuNo,deltaDiff,show)" "::sophie::histogram::onDisplayLine $visuNo"
      Menu_Separator $menuNo "$::caption(audace,menu,display)"

      #--- menu affichage
      Menu_Command   $menuNo "$::caption(audace,menu,display)" "$::caption(sophie,histogram,clear)" \
      "::sophie::histogram::onClearDisplay $visuNo"
      Menu_Command   $menuNo "$::caption(audace,menu,display)" "$::caption(sophie,histogram,clipboard)" \
      "::sophie::histogram::onCopyClipboard $visuNo"
      Menu_Bind $menuNo $private($visuNo,this) <Control-c> "$::caption(audace,menu,display)" "$::caption(sophie,histogram,clipboard)" \
      "Ctrl-C"
      Menu_Separator $menuNo "$::caption(audace,menu,display)"
      Menu_Command   $menuNo "$::caption(audace,menu,display)" "$::caption(sophie,histogram,preference)" \
      "::sophie::histogram::onRunPreference $visuNo"

    [MenuGet $menuNo $::caption(audace,menu,file)]      configure -tearoff 0
    [MenuGet $menuNo $::caption(audace,menu,display)]   configure -tearoff 0

   #--- Je memorise la reference de la frame
   set private($visuNo,frm)      $frm

   ttk::panedwindow $frm.pane -orient vertical -height 4

   frame $frm.pane.table  -borderwidth 0
      set private($visuNo,referenceTable) $frm.pane.table.table
      scrollbar $frm.pane.table.ysb -command "$private($visuNo,referenceTable) yview"
      scrollbar $frm.pane.table.xsb -command "$private($visuNo,referenceTable) xview" -orient horizontal

      #--- Table des reference
      ::tablelist::tablelist $private($visuNo,referenceTable)           \
         -columns [list 0 $::caption(sophie,histogram,startDate) left   \
                        0 $::caption(sophie,histogram,endDate)   left   \
                        0 $::caption(sophie,histogram,duration)  right  \
                        0 $::caption(sophie,histogram,pointNb)   center \
                        0 $::caption(sophie,histogram,RA)        center \
                        0 $::caption(sophie,histogram,DEC)       center \
                        0 $::caption(sophie,histogram,AZ)        center \
                        0 $::caption(sophie,histogram,EL)        center \
                        0 "limits" center                               \
                  ] \
         -xscrollcommand [list $frm.pane.table.xsb set] \
         -yscrollcommand [list $frm.pane.table.ysb set] \
         -exportselection 0 \
         -selectmode  extended \
         -activestyle none

      #--- je donne un nom a chaque colonne
      #--- j'ajoute l'option -stretchable pour que la colonne s'etire jusqu'au bord droit de la table
      #--- j'ajoute l'option -sortmode dictionary pour le tri soit independant de la casse
      $private($visuNo,referenceTable) columnconfigure 0 -name startDate -sortmode dictionary
      $private($visuNo,referenceTable) columnconfigure 1 -name stopDate
      $private($visuNo,referenceTable) columnconfigure 2 -name duration
      $private($visuNo,referenceTable) columnconfigure 3 -name pointNb
      $private($visuNo,referenceTable) columnconfigure 4 -name ra
      $private($visuNo,referenceTable) columnconfigure 5 -name dec
      $private($visuNo,referenceTable) columnconfigure 6 -name azimut
      $private($visuNo,referenceTable) columnconfigure 7 -name elevation
      $private($visuNo,referenceTable) columnconfigure 8 -name limits  -hide 1

      bind $private($visuNo,referenceTable) <<ListboxSelect>>  [list ::sophie::histogram::onSelectStart $visuNo]

      grid $private($visuNo,referenceTable) -in $frm.pane.table -row 0 -column 0 -sticky ewns
      grid $frm.pane.table.ysb  -in $frm.pane.table  -row 0 -column 1 -sticky nsew
      grid $frm.pane.table.xsb  -in $frm.pane.table  -row 1 -column 0 -sticky ew
      grid rowconfig    $frm.pane.table  0 -weight 1
      grid columnconfig $frm.pane.table  0 -weight 1

   ###pack $frm.pane.table -side top -fill both -expand 1
   $frm.pane add $frm.pane.table  -weight 0

   #--- je cree le graphique
   blt::barchart $frm.pane.graph
   ###pack $frm.pane.graph -side top -fill both -expand 1
   $frm.pane add $frm.pane.graph  -weight 3
   pack $frm.pane -side top -fill both -expand 1
   #--- il faut faire un update de la fenetre avant de creer l'objet BLT
   update
   ::sophie::histogram::configureGraph $visuNo
}

#------------------------------------------------------------
# configureGraph { }
#  configure l'histogramme
#------------------------------------------------------------
proc ::sophie::histogram::configureGraph { visuNo } {
   variable private

   set frm $private($visuNo,frm)
   $frm.pane.graph configure -plotbackground "white"
   $frm.pane.graph crosshairs off
   $frm.pane.graph crosshairs configure -color red -dashes 2
   $frm.pane.graph axis configure x -hide no -title $::caption(sophie,arcsec)
   $frm.pane.graph axis configure x2 -hide true
   $frm.pane.graph axis configure y2 -hide true
   $frm.pane.graph legend configure -hide yes
   $frm.pane.graph grid configure -hide no -dashes { 2 2 }

   $frm.pane.graph legend configure \
      -hide no -position plotarea -anchor nw -font $::conf(conffont,Label) \
      -borderwidth 0 -relief flat

#  -stipple "2" -linewidth 3 -symbol none \
#
   ###blt::bitmap define dot1 {
   ####define dot1_width 8
   ####define dot1_height 8
   ###static unsigned char dot1_bits[] = {
   ###   0x55, 0x00, 0x55, 0x00, 0x55, 0x00, 0x55, 0x00};
   ###} -scale 2.0
   $frm.pane.graph element create alphaDiff -mapy y \
         -xdata ::sophieHistogramAbcisse \
         -ydata ::sophieHistogramAlphaDiff \
         -foreground blue \
         -label $::caption(sophie,alpha)
   $frm.pane.graph element create deltaDiff -mapy y \
         -xdata ::sophieHistogramAbcisse \
         -ydata ::sophieHistogramDeltaDiff \
         -foreground orange \
         -label $::caption(sophie,delta)

}

#------------------------------------------------------------
# onLoadFile
#    ouvre le fichier de trace
#
# @param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::sophie::histogram::onLoadFile { visuNo } {
   variable private

   #--- j'ouvre la fenetre de selection du modele de pointage
   set initialdir $::audace(rep_images)
   set filetypes [ list [ list "Log file" "histo*.log" ] ]
   set parent [winfo toplevel $private($visuNo,frm)]
   set title  "::caption(sophie,histogram,title) $::caption(audace,menu,charger)"

   set fileName [ tk_getOpenFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
   #--- je charge les donnees du modele de pointage
   if { $fileName != "" } {
      set loadDataError [catch {
         displayData $visuNo $fileName
      }]
      if { $loadDataError != 0 } {
         ::tkutil::displayErrorInfo $title
      }
   }
}

#------------------------------------------------------------
## @brief affiche ou masque les courbes
#  @param visuNo numéro de la visu
#
proc ::sophie::histogram::onDisplayLine { visuNo } {
   variable private

   set frm $private($visuNo,frm)
   ###$frm.pane.graph element configure alphaDiff -hide [ expr !$private($visuNo,alphaDiff,show) ]
   ###$frm.pane.graph element configure deltaDiff -hide [ expr !$private($visuNo,deltaDiff,show) ]
   set elementList ""
   if {$private($visuNo,deltaDiff,show) == 1 } {
        lappend elementList "deltaDiff"
   }
   if {$private($visuNo,alphaDiff,show) == 1 } {
     lappend elementList "alphaDiff"
   }
   $frm.pane.graph element show $elementList
}

#------------------------------------------------------------
## @brief copy les données dans le presse papier
#  @param visuNo numéro de la visu
#
proc ::sophie::histogram::onCopyClipboard { visuNo } {
   variable private

   set len [::sophieHistogramAbcisse length]
   set data ""
   for { set i 0 } { $i < $len } {incr i } {
       append data "$::sophieHistogramAbcisse($i)\t$::sophieHistogramAlphaDiff($i)\t$::sophieHistogramDeltaDiff($i)\n"
   }
   clipboard clear
   clipboard append -type STRING $data
}

#------------------------------------------------------------
## @brief efface les données affichées
# @param visuNo numéro de la visu
#
proc ::sophie::histogram::onClearDisplay { visuNo } {
   variable private

   ::sophieHistogramAbcisse set ""
   ::sophieHistogramAlphaDiff set ""
   ::sophieHistogramDeltaDiff set ""
}

#------------------------------------------------------------
## @brief affiche la fenêtre des préférences
#  @param visuNo numéro de la visu
#
proc ::sophie::histogram::onRunPreference { visuNo } {
   variable private

   #--- j'affiche la fenetre
   ::sophie::histogram::preference::run $visuNo
   #--- je configure la nouvelle largeur des barres
   $private($visuNo,frm).pane.graph configure -barwidth $::conf(sophie,histogram,step) -barmode aligned
   displayData $visuNo $private($visuNo,fileName)
}

#------------------------------------------------------------
## @brief affiche la fenêtre des préférences
#  @param visuNo numero de la visu
#
proc ::sophie::histogram::onSelectStart { visuNo } {
   variable private

   set indexList [$private($visuNo,referenceTable) curselection]
   set inputStartList ""
   if { [llength $indexList] == 1 } {
      set rowData [$private($visuNo,referenceTable) get $indexList]
      lappend inputStartList [lindex $rowData 8]
   } else {
      foreach index $indexList {
         #--- je recupere les dates limites START et STOP
         lappend inputStartList [$private($visuNo,referenceTable) cellcget $index,limits -text ]
      }
   }

   displayData $visuNo $private($visuNo,fileName)  $inputStartList

}

#------------------------------------------------------------
# displayData { }
#  affiche l'histogramme a parti d'un fichier
#------------------------------------------------------------
proc ::sophie::histogram::displayData { visuNo fileName { inputStartList "" } } {
   variable private

   if { $fileName == "" } {
      ::sophieHistogramAbcisse set ""
      ::sophieHistogramAlphaDiff set ""
      ::sophieHistogramDeltaDiff set ""
      wm title $private($visuNo,this) "$::caption(sophie,histogram,title) [file tail $fileName]"
      set private($visuNo,fileName) $fileName
   } elseif { [file exists $fileName] } {
      #--- je charge les données du fichier
      set data [loadData $fileName $::conf(sophie,histogram,step) $inputStartList ]

      #--- je copie les données dans la table si c'est un chargement initial
      if { $inputStartList == "" } {

         $private($visuNo,referenceTable)  delete 0 end
         foreach item [lindex $data 3] {
            set startDate [string range [lindex $item 0] 11 end]
            if { [lindex $item 1] != "*" } {
               set stopDate  [string range [lindex $item 1] 11 end]
               set duration  [expr ( [mc_date2jd  [lindex $item 1]] - [mc_date2jd [lindex $item 0 ]] )*24*60 ]
               set minutes   [expr int($duration)]
               set secondes  [expr int(60*($duration - $minutes) ) ]
               set duration  [format "%3d mn %02d s" $minutes $secondes]
            } else {
              set stopDate  "*"
              set duration  ""
            }

            set pointNb   [lindex $item 2]
            set ra        [lindex $item 3]
            set dec       [lindex $item 4]
            set altaz     [mc_radec2altaz $ra $dec $::audace(posobs,observateur,gps) [lindex $item 0]]
            #---  mc_radec2altaz  : Retourne une liste : Azimut, Hauteur, Angle horaire et Angle parallactique.
            set az        [format "%.2f" [lindex $altaz 0]]
            set el        [format "%.2f" [lindex $altaz 1]]
            set limits    [lrange $item 0 1]
            $private($visuNo,referenceTable) insert end [list $startDate $stopDate $duration $pointNb $ra $dec $az $el $limits]
         }
         #--- je selectionne toutes les lignes de la table
         $private($visuNo,referenceTable) selection set 0 end
      }

      #--- je copie les données dans l'histogramme
      ::sophieHistogramAbcisse   set [lindex $data 0]
      ::sophieHistogramAlphaDiff set [lindex $data 1]
      ::sophieHistogramDeltaDiff set [lindex $data 2]
      $private($visuNo,frm).pane.graph configure -barwidth $::conf(sophie,histogram,step) -barmode aligned

      wm title $private($visuNo,this) "$::caption(sophie,histogram,title) [file tail $fileName]"
      set private($visuNo,fileName) $fileName

      #--- j'abonne la visu aux evenements temps réel
      set index [lsearch $private(realTimeVisuNo) $visuNo]
      if { $fileName == [getFileName] } {
          if { $index == -1 } {
             #--- j'ajoute la visu dans la liste d'abonnement
             lappend private(realTimeVisuNo) $visuNo
          }
      } else {
         if { $index != -1 } {
            #--- je supprime la visu de la liste d'abonnement
            set private(realTimeVisuNo) [lreplace $private(realTimeVisuNo) $index $index]
         }
      }
   }
}

#-------------------------------------------------------------
## @brief lit un fichier de log
#  @param fileName nom du fichier de log
#  @param step ??
#  @param inputStartList ??
#  @public
#  @todo commenter les param
#
proc ::sophie::histogram::loadData { fileName step { inputStartList "" } } {
   variable private

   set hFile     ""
   set abcisses  ""
   set xHisto    ""
   set yHisto    ""
   set startList ""

   set catchResult [ catch {
      set hfile [open $fileName r]
      set xMinDiff +9999
      set xMaxDiff -9999
      set yMinDiff +9999
      set yMaxDiff -9999
      set pointList ""
      set lastDataDate ""
      set endDate ""

      gets $hfile line
      seek $hfile 0
      if { [string range $line 0 0 ]  == "\["} {
         #--- c'est un ancien format
         #--- je lis le fichier
         set currentStarDate ""
         while { [gets $hfile line] >= 0} {
            if { [string range $line 0 0 ]  == "\["
               || [string range $line 0 0 ]  == "="
               || [string range $line 0 0 ]  == "-" } {
               continue
            }
            if { [string range $line 0 0 ]  == "-"} {
               continue
            }
            if { [llength $line ] == 3 } {
               if { $currentStarDate == "" } {
                  set currentStarDate [lindex $line 0 ]
               }
               set lastDataDate [lindex $line 0 ]
               set endDate [lindex $line 0 ]
               set xDiff [lindex $line 1 ]
               set yDiff [lindex $line 2 ]
               lappend pointList [ list $xDiff $yDiff ]
               if { $xDiff < $xMinDiff } {
                  set xMinDiff $xDiff
               }
               if { $xDiff > $xMaxDiff } {
                  set xMaxDiff $xDiff
               }
               if { $yDiff < $yMinDiff } {
                  set yMinDiff $yDiff
               }
               if { $yDiff > $yMaxDiff } {
                  set yMaxDiff $yDiff
               }
            }
         }

      } else {
         set currentStarDate ""
         set currentRa       ""
         set currentDec      ""
         set pointNb         0

         #--- je lis le fichier
         while { [gets $hfile line] >= 0} {
            #--- je verifie que l'enregistrement est dans inputStartList
            if { $inputStartList != "" } {
               set included 0
               foreach inputStart $inputStartList {
                  set date [lindex $line 0 ]
                  if { [string compare $date [lindex $inputStart 0]] >= 0 } {
                     if { [lindex $inputStart 1] == "*" } {
                         #--- l'element est dans la liste, j'arrete la recherche
                         set included 1
                         break
                     } else {
                        if { [string compare $date [lindex $inputStart 1]] <= 0 } {
                           #--- l'element est dans la liste, j'arrete la recherche
                           set included 1
                           break
                        }
                     }
                  }
               }
               if { $included == 0 } {
                  #--- l'element n'est pas dans la liste , je passe a l'element suivant
                  continue
               }
            }

            switch [lindex $line 1 ] {
               "DATA"  {
                  incr pointNb
                  if { $currentStarDate == "" } {
                      set currentStarDate [lindex $line 0 ]
                  }
                  if { $currentRa == "" } {
                      set currentRa [lindex $line 6 ]
                      set currentDec [lindex $line 7 ]
                  }
                  set lastDataDate [lindex $line 0 ]
                  set endDate [lindex $line 0 ]
                  set xDiff [lindex $line 2 ]
                  set yDiff [lindex $line 3 ]
                  lappend pointList [ list $xDiff $yDiff ]
                  if { $xDiff < $xMinDiff } {
                     set xMinDiff $xDiff
                  }
                  if { $xDiff > $xMaxDiff } {
                     set xMaxDiff $xDiff
                  }
                  if { $yDiff < $yMinDiff } {
                     set yMinDiff $yDiff
                  }
                  if { $yDiff > $yMaxDiff } {
                     set yMaxDiff $yDiff
                  }
               }
               "START" {
                  if { $currentStarDate == "" } {
                     set currentStarDate [lindex $line 0 ]
                     set lastDataDate ""
                     set currentRa ""
                     set currentDec ""
                     set pointNb 0
                  } else {
                     #--- j'ignore ce START car il n'y a pas de STOP depuis le START precendent
                  }

               }
               "STOP" {
                  if { $currentStarDate != "" } {
                     set currentStopDate [lindex $line 0]
                     lappend startList [list $currentStarDate $currentStopDate $pointNb $currentRa $currentDec]
                     set currentStarDate ""
                     set lastDataDate ""
                     set pointNb 0
                     set currentRa ""
                     set currentDec ""
                  }
               }
            }
         }
      }
      close $hfile
      set hfile ""

      #--- je traite le dernier bloc de données s'il n'est pas terminé par un STOP
      if { $currentStarDate != "" } {
          if { [string compare $lastDataDate $currentStarDate] == 1 } {
             lappend startList [list $currentStarDate "*" $pointNb $currentRa $currentDec ]
          }
      }

      if { $xMinDiff < $yMinDiff } {
         set minAbcisse [expr round(($xMinDiff+$step/2)/$step)*$step]
      } else {
         set minAbcisse [expr round(($yMinDiff+$step/2)/$step)*$step]
      }
      if { $xMaxDiff > $yMaxDiff } {
         set maxAbcisse [expr round(($xMaxDiff+$step/2)/$step)*$step]
      } else {
         set maxAbcisse [expr round(($yMaxDiff+$step/2)/$step)*$step]
      }

      #-- j'initalise les vecteurs des abcisses et des ordonnées
      for { set a $minAbcisse } { $a <= $maxAbcisse } {set a [expr $a + $step] } {
          lappend abcisses $a
          lappend xHisto 0
          lappend yHisto 0
      }

      #--- je calcule l'histogramme
      foreach point $pointList {
         #--- j'incremente l'histogramme alpha
         set abcisse [expr round(([lindex $point 0]+$step/2)/$step)*$step]
         set abcisse [expr round(($abcisse - $minAbcisse) /  $step)]
         lset xHisto $abcisse [expr [lindex $xHisto $abcisse] +1 ]
         #--- j'incremente l'histogramme delta
         set abcisse [expr round(([lindex $point 1]+$step/2)/$step)*$step ]
         set abcisse [expr round(($abcisse - $minAbcisse) /  $step)]
         lset yHisto $abcisse [expr [lindex $yHisto $abcisse] +1 ]
      }
   }]

   if { $catchResult != 0 } {
       if { $hFile != "" } {
          close $hFile
       }
       error $::errorInfo
   }
   return [list $abcisses $xHisto $yHisto $startList]

}

#------------------------------------------------------------
## @brief enregistre l'évènement de début de guidage dans le fichier courant de log
#  @param ra ?
#  @param dec ?
#  @public
#  @todo documenter les param
#
proc ::sophie::histogram::writeGuidingStart {  ra dec } {
   variable private

   set fileName [getFileName 1]
   set date [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]
   catch {
      set hFile [open $fileName  a]
      puts $hFile "$date START $ra $dec"
      close $hFile
   }

   #--- je mets a jour les visus qui affichent le fichier de log courant
   foreach visuNo $private(realTimeVisuNo)  {
      #--- j'ajoute un nouvel item dans la table
      set startDate [string range [lindex $date 0] 11 end]
      set stopDate  "*"
      set duration  ""
      set pointNb   0
      set ra        $ra
      set dec       $dec
      set altaz     [mc_radec2altaz $ra $dec $::audace(posobs,observateur,gps) $date ]
      #---  mc_radec2altaz  : Retourne une liste : Azimut, Hauteur, Angle horaire et Angle parallactique.
      set az        [format "%.2f" [lindex $altaz 0]]
      set el        [format "%.2f" [lindex $altaz 1]]
      set limits    [list $date $stopDate]
      $private($visuNo,referenceTable) insert end [list $startDate $stopDate $duration $pointNb $ra $dec $az $el $limits]
   }
}

#------------------------------------------------------------
## @brief enregistre un évènement de fin de guidage dans le fichier courant de log
#  @public
#
proc ::sophie::histogram::writeGuidingStop { } {
   variable private

   set fileName [getFileName]
   set date [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]
   catch {
      set hFile [open $fileName  a]
      puts $hFile "$date STOP"
      close $hFile
   }

   foreach visuNo $private(realTimeVisuNo)  {
      #--- je mets a jour le dernier element de la table

      #--- je mets a jour la date stop
      set stopDate [string range $date 11 end]
      $private($visuNo,referenceTable) cellconfigure end,stopDate -text $stopDate

      #--- je mets a jour les limites
      set limits    [$private($visuNo,referenceTable) cellcget end,limits -text ]
      set limits    [list [lindex $limits 0] $date]
      $private($visuNo,referenceTable) cellconfigure end,limits -text $limits

      #--- je mets a jour la duree
      set duration  [expr ( [mc_date2jd $date] - [mc_date2jd  [lindex $limits 0 ]] )*24*60 ]
      set minutes   [expr int($duration)]
      set secondes  [expr int(60*($duration - $minutes) ) ]
      set duration  [format "%3d mn %02d s" $minutes $secondes]
      $private($visuNo,referenceTable) cellconfigure end,duration -text $duration

   }

}

#-------------------------------------------------------------
## @brief enregistre un évènement de correction de guidage dans le fichier courant de log
#  @param alphaDiff       écart RA étoile/consigne (arcsec)
#  @param deltaDiff       écart déclinaison étoile/consigne (arcsec)
#  @param alphaCorrection correction envoyée au télescope (arcsec)
#  @param deltaCorrection correction envoyée au télescope (arcsec)
#  @param ra              ascention droite du télescope
#  @param dec             déclinaison du télescope
#  @public
#
proc ::sophie::histogram::writeGuidingInformation { alphaDiff deltaDiff alphaCorrection deltaCorrection ra dec } {
   variable private

   set fileName [getFileName]
   set date [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]
   catch {
      set hFile [open $fileName  a]
      puts $hFile "$date DATA  $alphaDiff $deltaDiff $alphaCorrection $deltaCorrection $ra $dec"
      close $hFile
   }

   #--- j'ajoute la nouvelle valeur dans l'histogramme
   foreach visuNo $private(realTimeVisuNo)  {

      #--- je mets a jour la table
      set pointNb [$private($visuNo,referenceTable) cellcget end,pointNb -text]
      incr pointNb
      $private($visuNo,referenceTable) cellconfigure end,pointNb -text $pointNb

      #--- je mets a jour l'histogramme s'il la periode conrante est affichée

      if { [$private($visuNo,referenceTable) selection includes end] == 1 } {
         set step $::conf(sophie,histogram,step)

         if { [::sophieHistogramAbcisse length] == 0 } {
            ::sophieHistogramAbcisse set { 0 }
            ::sophieHistogramAlphaDiff set { 0 }
            ::sophieHistogramDeltaDiff set { 0 }
         }

         set minAbcisse $::sophieHistogramAbcisse(min)
         set maxAbcisse $::sophieHistogramAbcisse(max)

         if { $alphaDiff  < $deltaDiff } {
            set newMinAbcisse [expr round(($alphaDiff+$step/2) / $step) * $step]
            set newMaxAbcisse [expr round(($deltaDiff+$step/2) / $step) * $step]
         } else {
            set newMinAbcisse [expr round(($deltaDiff+$step/2) / $step) * $step]
            set newMaxAbcisse [expr round(($alphaDiff+$step/2) / $step) * $step]
         }

         #--- j'étends les abcisses si le point est en dehors dde l'intervalle des abcisses exitant
         if { $newMinAbcisse < $minAbcisse } {
            #--- j'ajoute des abcisses à gauche de l'intervalle
            set abcisseList ""
            set alphaList   ""
            set deltaList   ""
            for { set a $newMinAbcisse } { $a < $minAbcisse } {set a [expr $a + $step] } {
                lappend abcisseList $a
                lappend alphaList 0
                lappend deltaList 0
            }
            ::sophieHistogramAbcisse   set [concat $abcisseList [::sophieHistogramAbcisse range 0 end]]
            ::sophieHistogramAlphaDiff set [concat $alphaList [::sophieHistogramAlphaDiff range 0 end]]
            ::sophieHistogramDeltaDiff set [concat $deltaList [::sophieHistogramDeltaDiff range 0 end]]
            set minAbcisse $newMinAbcisse
         }

         if { $newMaxAbcisse > $maxAbcisse } {
            #--- j'ajoute des abcisses à droite de la courbe de l'intervalle
            for { set a [expr $maxAbcisse + $step]  } { $a <= $newMaxAbcisse } {set a [expr $a + $step] } {
               ::sophieHistogramAbcisse append $a
               ::sophieHistogramAlphaDiff append 0
               ::sophieHistogramDeltaDiff append 0
            }
            set maxAbcisse $newMaxAbcisse
         }

         #--- j'incremente les barres des histogrammes
         #--- j'incremente l'histogramme alpha
         set abcisse [expr round(($alphaDiff+$step/2)/$step)*$step]
         set alphaIndex [expr round(($abcisse - $minAbcisse) / $step) ]
         set ::sophieHistogramAlphaDiff($alphaIndex)  [expr $::sophieHistogramAlphaDiff($alphaIndex) + 1]

         #--- j'incremente l'histogramme delta
         set abcisse [expr round(($deltaDiff+$step/2)/$step)*$step]
         set deltaIndex [expr round(($abcisse - $minAbcisse) / $step) ]
         set ::sophieHistogramDeltaDiff($deltaIndex) [expr $::sophieHistogramDeltaDiff($deltaIndex) + 1]
      }
   }
}

#------------------------------------------------------------
## @brief retourne le nom courant du fichier de log
#  @details Si le paramètre update=1 , le nom du fichier est mis à jour en fonction de
#    la date courante et un nouveau fichier est créé dans le répertoire audace(rep_images)
#    s'il n'existe pas.
#  @param update 0=pas de changement du nom du fichier 1=recalcul du nom du fichier
#  @return  nom complet du fichier (avec le répertoire)
#
proc ::sophie::histogram::getFileName { {update 0 } } {
   variable private

   if { $private(realTimeFileName) != ""  && $update == 0 } {
      return $private(realTimeFileName)
   } else {

      #--- Creation du nom de fichier log
      set nom_generique [file join $::audace(rep_images) "histo-ecart-"]
      #--- Heure a partir de laquelle on passe sur un nouveau fichier de log
      if { $::conf(rep_images,refModeAuto) == "0" } {
         set heure_nouveau_fichier "0"
      } else {
         set heure_nouveau_fichier "12"
      }

      set heure_courante [ lindex [ split $::audace(tu,format,hmsint) h ] 0 ]
      if { $heure_courante < $heure_nouveau_fichier } {
         #--- Si on est avant l'heure de changement, je prends la date de la veille
         set formatdate [ clock format [ expr { [ clock seconds ] - 86400 } ] -format "%Y-%m-%d" ]
      } else {
         #--- Sinon, je prends la date du jour
         set formatdate [ clock format [ clock seconds ] -format "%Y-%m-%d" ]
      }
      append fileName $nom_generique $formatdate ".log"

      set catchResult [ catch {
         set hFile [ open $fileName a ]
         puts  -nonewline $hFile ""
         close $hFile
         set private(realTimeFileName) $fileName
      }]

      if { $catchResult ==1 } {
          if { $hFile != "" } {
             close $hFile
          }
          error $::errorInfo
      }

      return $fileName
   }
}

################################################################################
#  fenetre des preferences
################################################################################

## namespace sophie::histogram::preference

namespace eval ::sophie::histogram::preference {

}

#------------------------------------------------------------
## @brief affiche la fenêtre des préférences
#  @param visuNo numéro de la visu de la fenetre
#  @public
#
proc ::sophie::histogram::preference::run { visuNo } {
   variable private

   set ::caption(sophie,histogram,preference,title) "Préférences de l'hitogramme"
   set ::caption(sophie,histogram,preference,step) "Pas des abcisses"

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(sophie,histogram,preference,position) ] }  { set ::conf(sophie,histogram,preference,position) "250x100+250+75" }

   set private($visuNo,this)  ".audace.sophieHisto$visuNo.preference"
   set private($visuNo,apply) 1

   if { [winfo exists $private($visuNo,this) ] == 0 } {
      #--- j'affiche la fenetre
      ::confGenerique::run $visuNo $private($visuNo,this) [namespace current] \
         -geometry $::conf(sophie,histogram,preference,position) \
         -resizable 1 -modal 1
   } else {
      focus $private($visuNo,this)
   }
}

#------------------------------------------------------------
# getLabel
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::sophie::histogram::preference::getLabel { } {
   return $::caption(sophie,histogram,preference,title)
}

#------------------------------------------------------------
#  brief enregistre les valeurs saisies
#  param visuNo numero de la visu
#
proc ::sophie::histogram::preference::cmdApply { visuNo } {
   variable private
   variable widget

   if { [info exists ::sophie::histogram::preference::widget(error,step)] } {
      set errorMessage "$::caption(sophie,histogram,preference,step): $widget(error,step)"
      tk_messageBox -message $errorMessage -icon error -title $::caption(sophie,histogram,preference,title)
      #--- je retourne 0 pour empecher de fermer la fenetre
      set private($visuNo,apply) 0
      return
   }

   set ::conf(sophie,histogram,step) $widget($visuNo,step)
   set private($visuNo,apply) 1
   return
}

#------------------------------------------------------------
#  brief récupère la position de l'outil apràs appui sur Fermer
#  param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::sophie::histogram::preference::cmdClose { visuNo } {
   variable private

   if { $private($visuNo,apply) == 0 } {
      return 0
   }
   #--- je sauve la taille et la position de la fenetre
   set ::conf(sophie,histogram,preference,position) [winfo geometry [winfo toplevel $private($visuNo,frm) ]]
   return
}

#------------------------------------------------------------
#  brief créén la fenêtre de configuration
#  param frm  nom tk de la frame créée par confgene
#  param visuNo numéro de la visu
#
proc ::sophie::histogram::preference::fillConfigPage { frm visuNo } {
   variable private
   variable widget

   #--- Je memorise la reference de la frame
   set private($visuNo,frm) $frm

   #--- j'initialise les variables des widgets
   set widget($visuNo,step) $::conf(sophie,histogram,step)

   frame $frm.form  -borderwidth 0
      #--- date debut
      label $frm.form.stepLabel -text $::caption(sophie,histogram,preference,step)
      pack $frm.form.stepLabel -anchor w -side left -padx 2

      entry $frm.form.stepValue \
         -textvariable ::sophie::histogram::preference::widget($visuNo,step) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0.01 10.0 ::sophie::histogram::preference::widget(error,step) }
      pack $frm.form.stepValue -side left -padx 2

   pack $frm.form -side top -fill x -expand 0 -padx 4 -pady 4
}

