#
# Fichier : eshelvisu.tcl
# Description : Visionneuse d'images eShel
# Auteurs : Michel Pujol
# Mise a jour $Id: eshelvisu.tcl 12655 2016-01-14 20:22:04Z robertdelmas $
#

namespace eval ::eshelvisu {
   global caption
   package provide eshelvisu 1.11

   #--- Chargement des captions pour récuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] eshelvisu.cap ]

}

#------------------------------------------------------------
#  ::eshelvisu::getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::eshelvisu::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "display" }
      display      { return "panel" }
      multivisu    { return 1 }
   }
}

#------------------------------------------------------------
#  ::eshelvisu::getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::eshelvisu::getPluginHelp { } {
   return "eshelvisu.htm"
}

#------------------------------------------------------------
#  ::eshelvisu::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::eshelvisu::getPluginTitle { } {
   return "$::caption(eshelvisu,title)"
}

#------------------------------------------------------------
#  ::eshelvisu::getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::eshelvisu::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le repertoire de plugin
#------------------------------------------------------------
proc ::eshelvisu::getPluginDirectory { } {
   return "eshelvisu"
}

#------------------------------------------------------------
# getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::eshelvisu::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::eshelvisu::deletePluginInstance { visuNo } {
   variable private

   #--- je supprime la fenetre
   if { [info exists private($visuNo,This)] && [winfo exists $private($visuNo,This)] } {
      destroy $private($visuNo,This)
   }
}

#------------------------------------------------------------
# ::eshelvisu::createPluginInstance
#    cree une instance l'outil
#
#------------------------------------------------------------
proc ::eshelvisu::createPluginInstance { base visuNo } {
   variable private
   global conf

   #--- je charge les sources et les variables (pour la premiere instance seulement)
   if { [array get ::eshelvisu::private *,This] == "" } {
      package require Tablelist

      set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory]]
      source [ file join $dir exportfits.tcl ]
      source [ file join $dir exportbess.tcl ]
      source [ file join $dir zipper.tcl ]
   }

   #--- je cree les variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshelvisu,directory) ] }  { set ::conf(eshelvisu,directory)           $::audace(rep_images) }
   #--- indicateur d'affichage des images par type d'image
   if { ! [ info exists ::conf(eshelvisu,enableExtension) ] }  { set ::conf(eshelvisu,enableExtension)     { fit 1  jpg 1 } }
   if { ! [ info exists ::conf(eshelvisu,showAllFiles) ] }     { set ::conf(eshelvisu,showAllFiles)        0 }

   #--- indicateurs d'affichage des colonnes
   if {![info exists conf(eshelvisu,show_column_type)]}    { set conf(eshelvisu,show_column_type)    "0" }
   if {![info exists conf(eshelvisu,show_column_series)]}  { set conf(eshelvisu,show_column_series)  "0" }
   if {![info exists conf(eshelvisu,show_column_date)]}    { set conf(eshelvisu,show_column_date)    "0" }
   if {![info exists conf(eshelvisu,show_column_size)]}    { set conf(eshelvisu,show_column_size)    "0" }

   #--- largeur des colonnes en nombre de caracteres (valeur positive) ou en nombre de pixel (valeur negative)
   if {![info exists conf(eshelvisu,width_column_name)]}   { set conf(eshelvisu,width_column_name)   "-90" }
   if {![info exists conf(eshelvisu,width_column_type)]}   { set conf(eshelvisu,width_column_type)   "-70" }
   if {![info exists conf(eshelvisu,width_column_date)]}   { set conf(eshelvisu,width_column_date)   "-104" }
   if {![info exists conf(eshelvisu,width_column_size)]}   { set conf(eshelvisu,width_column_size)   "-70" }

   if { [lsearch $conf(eshelvisu,enableExtension) "bmp"] == -1 } {
      lappend conf(visio2,enableExtension) "bmp" "0"
   }
   if { [lsearch $conf(eshelvisu,enableExtension) "gif"] == -1 } {
      lappend conf(visio2,enableExtension) "gif" "0"
   }
   if { [lsearch $conf(eshelvisu,enableExtension) "png"] == -1 } {
      lappend conf(visio2,enableExtension) "png" "0"
   }
   if { [lsearch $conf(eshelvisu,enableExtension) "tif"] == -1 } {
      lappend conf(visio2,enableExtension) "tif" "0"
   }

   #--- creation des variables locales
   set private($visuNo,This)                "$base.eshelVisu"
   set private($visuNo,xunit)               "screen coord"
   set private($visuNo,yunit)               "screen coord"
   set private($visuNo,fileName)            ""
   set private($visuNo,previousType)        ""
   set private($visuNo,fileName)            ""
   set private($visuNo,hduName)             ""
   set private($visuNo,orderHduNum)         0
   set private($visuNo,lineHduNum)          0
   set private($visuNo,showOrderLabel)      0
   set private($visuNo,showCalculatedLines) 0
   set private($visuNo,showObservatedLines) 0

   #---  petit raccourci bien utile
   set This $private($visuNo,This)

   frame $This -borderwidth 2 -relief groove

   #--- Frame du titre
   frame $This.titre -borderwidth 2 -relief groove

   #--- Bouton du titre
   Button $This.titre.but -borderwidth 1 \
      -text "$::caption(eshelvisu,help_titre1)\n$::caption(eshelvisu,title)" \
      -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::eshelvisu::getPluginType ] ] \
         [ ::eshelvisu::getPluginDirectory ] [ ::eshelvisu::getPluginHelp ]"
   DynamicHelp::add $This.titre.but -text $::caption(eshelvisu,help,titre)
   pack $This.titre.but -in $This.titre -anchor center -expand 1 -fill x -side top -ipadx 5

   pack $This.titre -in $This -fill x

   #--- Frame de la liste locale
   frame $This.locallist -borderwidth 1 -relief groove
   ::eshelvisu::localTable::createTbl $visuNo $This.locallist
   pack $This.locallist -fill both -expand 1 -anchor n -side top

   #--- Frame SlideShow
   frame $This.slideShow -borderwidth 1 -relief groove

   checkbutton $This.slideShow.check -pady 0 -text "$::caption(eshelvisu,slideshow)" \
            -variable ::eshelvisu::localTable::private($visuNo,slideShowState) \
            -command "::eshelvisu::localTable::setSlideShow $visuNo"
   pack $This.slideShow.check -in $This.slideShow -anchor center -expand 0 -fill none -side left

   set list_combobox [ list "0.5" "1" "2" "3" "5" "10" ]
   ComboBox $This.slideShow.delay \
      -width 3          \
      -height [llength $list_combobox] \
      -relief sunken    \
      -borderwidth 1    \
      -editable 1       \
      -takefocus 1      \
      -textvariable ::eshelvisu::localTable::private($visuNo,slideShowDelay) \
      -values $list_combobox
   $This.slideShow.delay setvalue @1
   pack $This.slideShow.delay -in $This.slideShow -anchor center -expand 0 -fill none -side left

   label $This.slideShow.labdelay -borderwidth 1 -text "s."
   pack $This.slideShow.labdelay -in $This.slideShow -anchor center -expand 0 -fill none -side left
   pack $This.slideShow -fill x -anchor n

   ::confColor::applyColor $This

   #---
   return $private($visuNo,This)
}

#------------------------------------------------------------
# ::eshelvisu::startTool
#    affiche la fenetre de l'outil
#
#------------------------------------------------------------
proc ::eshelvisu::startTool { visuNo } {
   variable private

   #--- je refraichis la liste des fichiers
   ::eshelvisu::localTable::init $visuNo $private($visuNo,This) $::conf(eshelvisu,directory)
   ::eshelvisu::localTable::refresh $visuNo

   #--- je complete la barre d'outils
   set tkToolBar [::confVisu::getToolBar $visuNo]
   if { [winfo exists $tkToolBar.orderLabel ]} {
      return
   }

   #--- j'ajoute les check box dans la toobar
   checkbutton $tkToolBar.orderLabel -text "order" \
         -highlightthickness 0 -variable ::eshelvisu::private($visuNo,showOrderLabel) \
         -command [list ::eshelvisu::showOrderLabel $visuNo]
   pack $tkToolBar.orderLabel -in $tkToolBar -side left -fill none -padx 2
   checkbutton $tkToolBar.calcLine -text "calc" \
         -highlightthickness 0 -variable ::eshelvisu::private($visuNo,showCalculatedLines) \
         -command [list ::eshelvisu::showCalibrationLine $visuNo]
   pack $tkToolBar.calcLine -in $tkToolBar -side left -fill none -padx 2
   checkbutton $tkToolBar.obsLine -text "obs" \
         -highlightthickness 0 -variable ::eshelvisu::private($visuNo,showObservatedLines) \
         -command [list ::eshelvisu::showCalibrationLine $visuNo ]
   pack $tkToolBar.obsLine -in $tkToolBar -side left -fill none -padx 2

   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas bind balloonline  <Enter> [list ::eshelvisu::showBalloon $visuNo %W %x %y %T ]
   ##$hCanvas bind balloonline  <Leave> [list after 1000 $hCanvas delete cballoon]

   #--- je lance la surveillance du chargement des fichiers
   ::confVisu::addFileNameListener $visuNo "::eshelvisu::onLoadFile $visuNo"
   #--- je lance la surveillance de la selection de HDU
   ::confVisu::addHduListener $visuNo "::eshelvisu::onSelectHdu $visuNo"
   #--- je lance la surveillance de la selection de HDU
   ::confVisu::addZoomListener $visuNo "::eshelvisu::onSelectHdu $visuNo"

   #--- je recupere les informations du fichier courant
   onLoadFile $visuNo
   onSelectHdu $visuNo

   ::confColor::applyColor $private($visuNo,This)
   ::confColor::applyColor $tkToolBar
}

#------------------------------------------------------------
# ::eshelvisu::stopTool
#    masque la fenetre de l'outil
#
#------------------------------------------------------------
proc ::eshelvisu::stopTool { visuNo } {
   variable private

   set hCanvas [confVisu::getCanvas $visuNo]

   #--- j'efface les noms des ordres et les marques des raies
   $hCanvas delete orderLabel calibrationLine cballoon
   #--- je supprime les binds
   $hCanvas bind balloonline  <Enter> ""
   $hCanvas bind balloonline  <Leave> ""

   #--- je supprime la surveillance le chargement des fichiers
   ::confVisu::removeFileNameListener $visuNo "::eshelvisu::onLoadFile $visuNo"
   ::confVisu::removeHduListener $visuNo "::eshelvisu::onSelectHdu $visuNo"
   ::confVisu::removeZoomListener $visuNo "::eshelvisu::onSelectHdu $visuNo"

   #--- je supprime les check box dans la toobar
   set tkToolBar [::confVisu::getToolBar $visuNo]
   destroy $tkToolBar.orderLabel
   destroy $tkToolBar.calcLine
   destroy $tkToolBar.obsLine

   #--- j'arrete le diaporama
   ::eshelvisu::localTable::setSlideShow $visuNo 0
   #--- je copie la largeur des colonnes dans conf()
   ::eshelvisu::localTable::saveColumnWidth $visuNo

   #--- je recupere le repertoire courant
   set ::conf(eshelvisu,directory) [::eshelvisu::localTable::getDirectory $visuNo ]
}

#------------------------------------------------------------------------------
# configure
#   affiche la fenetre de configuration
#------------------------------------------------------------------------------
proc ::eshelvisu::configure { visuNo } {
   variable private

   #--- j'affiche la fenetre de configuration
   ::confGenerique::run $visuNo "$private($visuNo,This).confEshelVisu" "::eshelvisu::config" -modal 0

   #--- je refraichis les tables pour prendre en compte la nouvelle config
   localTable::refresh $visuNo
}

#------------------------------------------------------------
#  getLabel
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::eshelvisu::getLabel { visuNo } {
   return "$::caption(eshelvisu,title)"
}

#------------------------------------------------------------
#  onLoadFile
#     recupere le nom du fichier et les numeros de HDU des tables ORDER et LINEGAP
#     met les valeurs dans private($visuNo,orderHduNum et private($visuNo,lineHduNum)
#  Parameters
#    visuNo : numero de visu
#    args   : arguments envoye par le listener
#------------------------------------------------------------
proc ::eshelvisu::onLoadFile { visuNo args } {
   variable private

   set private($visuNo,fileName) [::confVisu::getFileName $visuNo]
   set hduList [::confVisu::getHduList $visuNo]

   #--- je recupere le numero de HDU des ORDRES et LINEGAP
   set private($visuNo,orderHduNum) 0
   set private($visuNo,lineHduNum) 0
   set hduNum 1
   foreach item $hduList {
      set hduName [lindex $item 0 ]
        if { $hduName == "ORDERS" } {
            set private($visuNo,orderHduNum)  $hduNum
         } elseif { $hduName == "LINEGAP" } {
            set private($visuNo,lineHduNum)  $hduNum
         }
      incr hduNum
   }

}

#------------------------------------------------------------
#  onSelectHdu
#     affiche les symboles des raies quand on change de Hdu
#  Parameters
#    visuNo : numero de visu
#    args   : arguments envoye par le listener
#------------------------------------------------------------
proc ::eshelvisu::onSelectHdu { visuNo args } {
   variable private

   #--- je recupere le nom du HDU courant
   set private($visuNo,hduName) [::confVisu::getCurrentHduName $visuNo]
   #--- j'affiche les marques (les marques dependent du nom du HDU
   showOrderLabel $visuNo
   showCalibrationLine $visuNo
}

#------------------------------------------------------------
#  showBalloon
#     ajoute un nouveau point ou selectionne un point existant
#  return :
#------------------------------------------------------------
proc ::eshelvisu::showBalloon {visuNo w x y type } {
   variable private

   ###console::disp "showBalloon current: [$w find withtag current]\n"

   ##foreach {x y x2 y2 } [$w bbox current] break
   ##console::disp "showBalloon apres break\n"
   #if [info exists y] {
   #     set id [$w create text [expr $x +4] $y -text "$lambda  " -tag cballoon]
   #     foreach {x0 y0 x1 y1} [$w bbox $id] break
   #     $w create rect $x0 $y0 $x1 $y1 -fill lightyellow -tag cballoon
   #     $w raise $id
   # }

     set tags [$w itemcget current -tags]
     set lambda [lindex $tags 2]
     if { [$w gettags cballoon$lambda] == "" } {
        set coords [$w bbox current]
        set x0 [lindex $coords 0]
        set y0 [lindex $coords 1]
        set x1 [lindex $coords 0]
        set y1 [lindex $coords 1]

        set id [$w create text [expr ($x1+$x0)/2 +10] [expr $y0 - 8 ] -text " $lambda " -tag cballoon$lambda ]
        foreach {x0 y0 x1 y1} [$w bbox $id] break
        $w create rect $x0 $y0 $x1 $y1 -fill lightyellow -tag cballoon$lambda
        $w raise $id
        ###after 5000 $w delete cballoon$lambda
        after 5000 "::eshelvisu::deleteBaloon $w $lambda"
     } else {
        $w delete cballoon$lambda
     }
}

#------------------------------------------------------------
#  deleteBaloon
#    supprime
#  Parameters
#     visuNo : numero de la fenetre de profil
#------------------------------------------------------------
proc ::eshelvisu::deleteBaloon { w  lambda } {
   if { [winfo exists $w ] } {
      $w delete cballoon$lambda
   }
}

#------------------------------------------------------------
#  showOrderLabel
#    affiche le numero des ordres dans l'image2D
#  Parameters
#     visuNo : numero de la fenetre de profil
#------------------------------------------------------------
proc ::eshelvisu::showOrderLabel { visuNo } {
   variable private

   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete orderLabel

   if { $private($visuNo,showOrderLabel) == 0 ||  ( $private($visuNo,hduName) != "PRIMARY" && $private($visuNo,hduName) != "IMAGE") } {
      return
   }

   #--- je verifie que la table des ordres est presente
   if { $private($visuNo,orderHduNum) == 0 } {
      ##console::affiche_erreur "::eshelvisu::showOrderLabel Order table missing in $private($visuNo,fileName)\n"
      return
   }

   #--- je pointe la table des ordres
   set hFile ""
   set catchResult [catch {
      set hFile [fits open $private($visuNo,fileName) 0]
      $hFile move $private($visuNo,orderHduNum)
      #--- je recupere les minOrder et maxOrder
      ###set nbOrder [lindex [lindex [$hFile get keyword "NAXIS2"] 0] 1]
      set nbOrder    [getKeyword $hFile NAXIS2]
      ###set width [lindex [lindex [$hFile get keyword "WIDTH"] 0] 1]
      set width    [getKeyword $hFile WIDTH]
      set x  [expr $width /2 ]
      for {set n 1 } { $n <= $nbOrder } { incr n } {
         set numOrder [lindex [lindex [$hFile get table "order" $n ] 0] 0]
         set yc       [lindex [lindex [$hFile get table "yc" $n ] 0] 0]
         if { $yc > 0 } {
            set yc [expr $yc + 8 ]
            set centralLambda [$hFile get table "central" $n ]
            set orderlabel "N°$numOrder: $centralLambda"
            set coord [::confVisu::picture2Canvas $visuNo [list $x $yc]]
            $hCanvas create text [lindex $coord 0] [lindex $coord 1] -text $orderlabel -tag orderLabel -state normal -fill yellow
         }
      }
   }]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
   }
   if { $hFile != "" } {
      $hFile close
   }
}


#------------------------------------------------------------
#  showOrderLine
#    affiche le numero des ordres dans l'image2D
#  Parameters
#     visuNo : numero de la fenetre de profil
#------------------------------------------------------------
proc ::eshelvisu::showOrderLine { visuNo } {
   variable private

   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete orderLine

     #--- je verifie que la table des ordres est presente
   if { $private($visuNo,orderHduNum) == 0 } {
      ##console::affiche_erreur "::eshelvisu::showOrderLabel Order table missing in $private($visuNo,fileName)\n"
      return
   }

   #--- je pointe la table des ordres
   set hFile ""
   set catchResult [catch {
      set hFile [fits open $private($visuNo,fileName) 0]
      $hFile move $private($visuNo,orderHduNum)
      #--- je recupere les parametres de l'image
      set width      [getKeyword $hFile WIDTH]
      set nbOrder    [getKeyword $hFile NAXIS2]
      set alpha      [getKeyword $hFile ALPHA]
      set gamma      [getKeyword $hFile GAMMA]
      set m          [getKeyword $hFile M]
      set pixel      [getKeyword $hFile PIXEL]
      set width      [getKeyword $hFile WIDTH]
      set dx_ref     [getKeyword $hFile DX_REF]
      set foclen     [getKeyword $hFile FOCLEN]
      set min_order  [getKeyword $hFile MIN_ORDER]
      set max_order  [getKeyword $hFile MAX_ORDER]

      set PI      [expr acos(-1)]
      set alpha   [expr $alpha*$PI/180.0]
      set gamma   [expr $gamma*$PI/180.0]
      set xc      [expr $width / 2 ]
      set previousMinLambda 0

      for {set orderNum $min_order } { $orderNum <= $max_order } { incr orderNum } {
         set n [expr $orderNum - $min_order +1 ]
         set flag [string trim [lindex [lindex [$hFile get table "flag" $n ] 0 ] 0]]
         if { $flag != 1 } {
            #--- j'ignore les ordres qui n'ont pas flag=1
            continue
         }
         set minX [string trim [lindex [lindex [$hFile get table "min_x" $n ] 0 ] 0]]
         set maxX [string trim [lindex [lindex [$hFile get table "max_x" $n ] 0 ] 0]]
         set p0 [string trim [lindex [lindex [$hFile get table "P0" $n ] 0 ] 0]]
         set p1 [string trim [lindex [lindex [$hFile get table "P1" $n ] 0 ] 0]]
         set p2 [string trim [lindex [lindex [$hFile get table "P2" $n ] 0 ] 0]]
         set p3 [string trim [lindex [lindex [$hFile get table "P3" $n ] 0 ] 0]]
         set p4 [string trim [lindex [lindex [$hFile get table "P4" $n ] 0 ] 0]]
         #--- je calcule le polynome d'ordre 5 (ou d'ordre 4 pour l'ancienne version
         set p5NotFound [catch {
            set p5 [string trim [lindex [lindex [$hFile get table "P5" $n ] 0 ] 0]]
         }]
         if { $p5NotFound != 0 } {
            set p5 0
         }

         #--- je calcule l'abcisse de l'ordre précédent
         if { $orderNum != $min_order } {
            set beta [expr asin(($orderNum*$m*$previousMinLambda/10000000.0 - cos($gamma) * sin($alpha))/cos($gamma))]
            set beta2 [expr $beta - $alpha]
            set previousMinX [expr $foclen * $beta2 / $pixel + $xc + $dx_ref]
         } else {
            set previousMinX $width
         }

         #--- je calcule l'abcisse de l'ordre suivant
         if { $orderNum != $max_order } {
            set nextMaxX [string trim [lindex [lindex [$hFile get table "max_x" [expr $n +1] ] 0 ] 0]]
            set beta2 [expr ( $nextMaxX - $xc - $dx_ref) * $pixel / $foclen]
            set beta  [expr $beta2 + $alpha]
            set nextMaxLambda [expr 10000000.0 * cos($gamma) * (sin($alpha) + sin($beta))/ [expr $orderNum + 1] / $m ]

            set beta [expr asin(($orderNum *$m*$nextMaxLambda/10000000.0 - cos($gamma) * sin($alpha))/cos($gamma))]
            set beta2 [expr $beta - $alpha]
            set nextMaxX [expr $foclen * $beta2 / $pixel + $xc + $dx_ref]
         } else {
            set nextMaxX 0
         }

         set coordlist {}
         set previousCoordList {}
         set nextCoordList {}
         for { set x $minX } { $x < $maxX } { incr x } {
            #--- je calcule l'ordonnee y
            set y [expr (((($p5 * $x + $p4) * $x + $p3) * $x + $p2) *$x + $p1) * $x + $p0 ]
            set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
            lappend coordlist [lindex $coord 0] [lindex $coord 1]
            if { $x >= $previousMinX } {
               lappend previousCoordList [lindex $coord 0] [expr [lindex $coord 1] -5 ]
            }
            if { $x <= $nextMaxX } {
               lappend nextCoordList [lindex $coord 0] [expr [lindex $coord 1] +5 ]
            }
         }
         $hCanvas create line $coordlist -fill green -width 2 -offset center -tag orderLine
         if { [llength $previousCoordList ] > 0 } {
            $hCanvas create line $previousCoordList -fill blue -width 2 -offset center -tag orderLine
         }
         if { [llength $nextCoordList ] > 0 } {
            $hCanvas create line $nextCoordList -fill blue -width 2 -offset center -tag orderLine
         }
         $hCanvas lower  orderLine calibrationLine

         #--- je calcule la longueur d'onde correspondant a maxX
         set beta2 [expr ( $minX -$xc - $dx_ref) * $pixel / $foclen]
         set beta  [expr $beta2 + $alpha]
         set previousMinLambda [expr 10000000.0 * cos($gamma) * (sin($alpha) + sin($beta))/ $orderNum / $m ]
      }
   }]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
   }
   if { $hFile != "" } {
      $hFile close
   }
}


##------------------------------------------------------------
# retourne la valeur d'un mot clef
#
# @param   hFile          handle du fichier fitd
# @param   keywordName    nom du mot clef
#
# @return valeur du mot clef
# @private
#------------------------------------------------------------
proc ::eshelvisu::getKeyword { hFile keywordName} {
   variable private

   #--- je recupere les mots clefs dans le nom contient la valeur keywordName
   #--- cette fonction retourne une liste de triplets { name value description }

   set catchResult [ catch {
      set keywords [$hFile get keyword $keywordName]
   }]
   if { $catchResult !=0 } {
      #--- je transmets l'erreur en ajoutant le nom du mot clé
      error "keyword $keywordName not found\n$::errorInfo"
   }

   #--- je cherche le mot cle qui a exactement le nom requis
   foreach keyword $keywords {
      set name [lindex $keyword 0]
      set value [lindex $keyword 1]
      if { $name == $keywordName } {
         #--- je supprime les apostrophes et les espaces qui entourent la valeur
         set value [string trim [string map {"'" ""} [lindex $keyword 1] ]]
         break
      }
   }
   if { $name != $keywordName } {
      #--- je retourne une erreur si le mot clef n'est pas trouve
      error "keyword $keywordName not found"
   }
   return $value
}

#------------------------------------------------------------
#  showCalibrationLine
#    affiche les raies de calibration
#  Parameters
#     visuNo : numero de la fenetre de profil
#------------------------------------------------------------
proc ::eshelvisu::showCalibrationLine { visuNo } {
   variable private

   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete calibrationLine

   #--- je verifie que la table des ordres est presente
   if { $private($visuNo,orderHduNum) == 0 } {
      ##console::affiche_erreur "::eshelvisu::showCalibrationLine ORDERS table missing in $private($visuNo,fileName)\n"
      return
   }
   if { $private($visuNo,lineHduNum) == 0 } {
      ##console::affiche_erreur "::eshelvisu::showCalibrationLine LINEGAP table missing in $private($visuNo,fileName)\n"
      return
   }

   if { ($private($visuNo,showCalculatedLines) == 0 && $private($visuNo,showObservatedLines)== 0) || $private($visuNo,hduName) != "PRIMARY" } {
      return
   }

   set hFile ""
   set catchResult [catch {
         set hFile [fits open $private($visuNo,fileName) 0]
         #--- je recupere les parametres du spectre dans la table des ordres
         $hFile move $private($visuNo,orderHduNum)

         set nbOrder    [getKeyword $hFile NAXIS2]
         set alpha      [getKeyword $hFile ALPHA]
         set gamma      [getKeyword $hFile GAMMA]
         set m          [getKeyword $hFile M]
         set pixel      [getKeyword $hFile PIXEL]
         set width      [getKeyword $hFile WIDTH]
         set dx_ref     [getKeyword $hFile DX_REF]
         set foclen     [getKeyword $hFile FOCLEN]
         set min_order  [getKeyword $hFile MIN_ORDER]

         set PI      [expr acos(-1)]
         set alpha   [expr $alpha*$PI/180.0]
         set gamma   [expr $gamma*$PI/180.0]
         set xc      [expr $width / 2 ]

         #--- je recupere la taille de la boite de rechercher wide_x , wide_y
         $hFile move $private($visuNo,orderHduNum)
         set wide_x [lindex [lindex [$hFile get table "wide_x" 1 ] 0] 0]
         set wide_y [lindex [lindex [$hFile get table "wide_y" 1 ] 0] 0]
         #--- je recupere la liste des raies de calibration
         $hFile move $private($visuNo,lineHduNum)
         ####set nbLine [lindex [lindex [$hFile get keyword "NAXIS2"] 0] 1]
         set nbLine    [getKeyword $hFile NAXIS2]

         #--- j'affiche un carre autour de chaque ligne
         $hCanvas delete calibrationLine
         for {set i 1 } { $i <= $nbLine } { incr i } {
            #--- je pointe la table des raies de calibration
            $hFile move $private($visuNo,lineHduNum)
            set orderNum [lindex [lindex [$hFile get table "order" $i ] 0] 0]
            ###::console::disp "showCalibrationLine n=$orderNum lambda=$lambda m=$m alpha=$alpha gamma=$gamma foclen=$foclen\n"
            if { $private($visuNo,showCalculatedLines) == 1 } {
               set lambda [lindex [lindex [$hFile get table "lambda_calc" $i ] 0] 0]
               #--- je calcule l'abcisse x
               set beta [expr asin(($orderNum*$m*$lambda/10000000 - cos($gamma) * sin($alpha))/cos($gamma))]
               set beta2 [expr $beta - $alpha]
               set x [expr $foclen * $beta2/$pixel + $xc + $dx_ref]
               if { $lambda == 6242.941 } {
                  ###::console::disp "showCalibrationLine lambda=$lambda gamma=$gamma foclen=$foclen pixel=$pixel xc=$xc m=$m \n"
                  ###::console::disp "showCalibrationLine lambda=$lambda beta=$beta beta2=$beta2 xc=$xc dx_ref=$dx_ref x=$x \n"
               }
               $hFile move $private($visuNo,orderHduNum)
               set n [expr $orderNum - $min_order +1 ]
               ###set min_x [string trim [lindex [lindex [$hFile get table "min_x" $n ] 0] 0]]
               ###set x [expr $x - $min_x]
               #--- je calcule l'ordonnee y
               set y 0
               for { set k 0 } { $k<= 5 } { incr k } {
                  #--- je calcule le polynome d'ordre 5 (ou d'ordre 4 pour l'ancienne version
                  set coeffNotFound [catch {
                     set a [lindex [lindex [$hFile get table "P$k" $n ] 0] 0]
                     set y [expr $y + $a *pow($x - 1.0 , $k)]
                  }]
                  if { $coeffNotFound != 0 } {
                     break
                  }
               }
               set x [ expr int($x+0.5) + 1 ]
               set y [ expr int($y+0.5) + 1 ]
               #--- je calcule les ccordonnees de la boite dans le buffer
               set x1 [expr int($x) - $wide_x/2]
               set x2 [expr int($x) + $wide_x/2]
               set y1 [expr int($y) - $wide_y/2]
               set y2 [expr int($y) + $wide_y/2]

               #--- je calcule les coordonnees dans le canvas
               set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
               set x1 [lindex $coord 0]
               set y1 [lindex $coord 1]
               set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
               set x2 [lindex $coord 0]
               set y2 [lindex $coord 1]
               $hCanvas create rect [list $x1 $y1 $x2 $y2] -outline "#FF5522" -width 1 -offset center -tag "calibrationLine"
            }

            if { $private($visuNo,showObservatedLines) == 1 } {
               $hFile move $private($visuNo,lineHduNum)
               set x [lindex [lindex [$hFile get table "lambda_posx" $i ] 0] 0]
               set y [lindex [lindex [$hFile get table "lambda_posy" $i ] 0] 0]
               set lambda [lindex [lindex [$hFile get table "lambda_obs" $i ] 0] 0]
               set validLine [lindex [lindex [$hFile get table "valid" $i ] 0] 0]

               #--- je calcule les ccordonnees de la boite dans le buffer
               set x1 [expr int($x) - $wide_x/2 ]
               set x2 [expr int($x) + $wide_x/2 ]
               set y1 [expr int($y) - $wide_y/2 ]
               set y2 [expr int($y) + $wide_y/2 ]
               #--- je calcule les coordonnees dans le canvas
               set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
               set x1 [lindex $coord 0]
               set y1 [lindex $coord 1]
               set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
               set x2 [lindex $coord 0]
               set y2 [lindex $coord 1]
               if { $validLine == 1 } {
                  set dash  ""
               } else {
                  set dash  "2 4"
               }
               $hCanvas create rect [list $x1 $y1 $x2 $y2] -outline "#77FF77" -width 1 -activewidth 2 -fill {} -dash $dash -offset center -tag "calibrationLine balloonline $lambda"
            }
         }
   }]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
   }
   if { $hFile != "" } {
      $hFile close
   }
}

#------------------------------------------------------------
#  showHeader
#    affiche les mots clefs du header
#  Parameters
#     profileNo : numero de la fenetre de profil
#------------------------------------------------------------
proc ::eshelvisu::showHeader { visuNo } {
   variable private

   #--- je recupere les mots clefs
   set keywords [ $private($profileNo,fitsHandle) get keyword]
   #--- j'affiche la fenetre des mots clefs
   ::headergui::run $private($profileNo,This) $visuNo $keywords
}

################################################################
# namespace localTable
#    gere la table des fichiers du disque local
################################################################
namespace eval ::eshelvisu::localTable {
}

#------------------------------------------------------------------------------
# localTable::init
#   affiche les fichiers dans la table
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::init { visuNo mainframe directory } {
   variable private

   #--- Types des objets affiches
   #---   bidouille !!! je met un espace au debut de private(parentFolder) et private(folder)
   #---   pour que les repertoires apparaissent en premier par ordre alphabetique
   set private(parentFolder) " $::caption(eshelvisu,table,parentFolder)"
   set private(folder)       " $::caption(eshelvisu,table,folder)"
   set private(fileImage)    "$::caption(eshelvisu,table,image)"
   set private(fileMovie)    "$::caption(eshelvisu,table,movie)"
   set private(file)         "$::caption(eshelvisu,table,file)"
   set private(volume)       "$::caption(eshelvisu,table,volume)"

   set private($visuNo,localtbl)             ""
   set private($visuNo,previousType)         ""
   set private($visuNo,previousFileNameType) ""
   set private($visuNo,currentItemIndex)     "0"
   set private($visuNo,slideShowState)       "0"
   set private($visuNo,slideShowAfterId)     ""
   set private($visuNo,slideShowDelay)       "1"
   set private($visuNo,directory)            "$directory"
   set private($visuNo,genericName)          "image"
   set private($visuNo,newFileName)          ""
   set private($visuNo,firstIndex)           "1"
   set private($visuNo,copy)                 "0"
   set private($visuNo,overwrite)            "0"
   set private($visuNo,itemList)             ""
   set private($visuNo,sortedColumn)         0

   #--- icone directory
   set private(folderIcon) [image create photo folderopen16 -data {
       R0lGODlhEAAQAIYAAPwCBAQCBExKTBQWFOzi1Ozq7ERCRCwqLPz+/PT29Ozu
       7OTm5FRSVHRydIR+fISCfMTCvAQ6XARqnJSKfIx6XPz6/MzKxJTa9Mzq9JzO
       5PTy7OzizJSOhIyCdOTi5Dy65FTC7HS2zMzm7OTSvNTCnIRyVNza3Dw+PASq
       5BSGrFyqzMyyjMzOzAR+zBRejBxqnBx+rHRmTPTy9IyqvDRylFxaXNze3DRu
       jAQ2VLSyrDQ2NNTW1NTS1AQ6VJyenGxqbMTGxLy6vGRiZKyurKyqrKSmpDw6
       PDw6NAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
       LAAAAAAQABAAAAfCgACCAAECg4eIAAMEBQYCB4mHAQgJCgsLDAEGDQGIkw4P
       BQkJBYwQnRESEREIoRMUE6IVChYGERcYGaoRGhsbHBQdHgu2HyAhGSK6qxsj
       JCUmJwARKCkpKsjKqislLNIRLS4vLykw2MkRMRAGhDIJMzTiLzDXETUQ0gAG
       CgU2HjM35N3AkYMdAB0EbCjcwcPCDBguevjIR0jHDwgWLACBECRIBB8GJekQ
       MiRIjhxEIlBMFOBADR9FIhiJ5OnAEQB+AgEAIf5oQ3JlYXRlZCBieSBCTVBU
       b0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBB
       bGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20A
       Ow==
    }]

   fillTable $visuNo
}

#------------------------------------------------------------
#  exportFits
#    enregistre un ou plusieurs HDU dans des fichiers FITS separes
# Parameters
#    profileNo  numero de la fenetre
#  Return
#     rien
#------------------------------------------------------------
proc ::eshelvisu::localTable::exportFits { visuNo } {
   variable private

   set tbl $private($visuNo,tbl)
   set selection [$tbl curselection]

   #--- je constitue la liste des noms des fichiers
   set fileList [list ]
   foreach index $selection {
      set name [string trimleft [$tbl cellcget $index,0 -text]]
      set type [$tbl cellcget $index,1 -text]
      if { $type != "$private(folder)" } {
         lappend fileList [file join $private($visuNo,directory) $name]
      }
   }

   #--- je retourne immediatemment si aucun item n'est selectionne
   if { [llength $fileList ] == 0 } {
      set message "$::caption(eshelvisu,table,selectFileError)"
      tk_messageBox -title $::caption(eshelvisu,title) -type ok -message "$message" -icon error
      return
   }

   #--- les donnees sont dans le HDU courant
   ::eshelvisu::exportfits::run $visuNo $fileList

}

#------------------------------------------------------------
#  exportBess
#    enregistre le HDU dans un fichier FITS
# Parameters
#    profileNo  numero de la fenetre
#  Return
#     rien
#------------------------------------------------------------
proc ::eshelvisu::localTable::exportBess { visuNo } {
   variable private

   set fileName [::confVisu::getFileName $visuNo]
   if { $fileName == "" } {
      set message "$::caption(eshelvisu,table,selectFileError)"
      tk_messageBox -title $::caption(eshelvisu,title) -type ok -message "$message" -icon error
      return
   }

   ::eshelvisu::exportbess::run $visuNo $fileName 1
}

#------------------------------------------------------------
# copyStarNameToClipboard
#    copy les donnees dans le presse papier
#
# @param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::eshelvisu::localTable::copyStarNameToClipboard { visuNo } {
   variable private

   set fileName [::confVisu::getFileName $visuNo]

   set hFile ""
   set catchResult [catch {
      set hFile [fits open $fileName 0]
      #--- je recupere le nom de l'objet
      set objName    [::eshelvisu::getKeyword $hFile OBJNAME]
      clipboard clear
      clipboard append -type STRING [string trim $objName]
   }]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
   }
   if { $hFile != "" } {
      $hFile close
   }

}


#------------------------------------------------------------------------------
# localTable::getDirectory
#   retourne le reperoire courant
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::getDirectory { visuNo } {
   variable private

   return $private($visuNo,directory)
}

#------------------------------------------------------------------------------
# localTable::fillTable
#   affiche les fichiers et sous repertoires dans la table
#   et affiche le nom du repertoire courant dans le titre de la fenetre principale
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::fillTable { visuNo } {
   variable private

   #--- j'affiche les fichiers dans la table
   fillTable2 $visuNo  $private($visuNo,tbl) [getFileList $visuNo $private($visuNo,directory)]

   #--- je trie la table
   set sortorder "-[$private($visuNo,tbl) sortorder]"
   if { $sortorder == "-" } {
      #--- la première fois
      set sortorder "-increasing"
   }
   #--- je tri la table
   $private($visuNo,tbl) sortbycolumn  $private($visuNo,sortedColumn) $sortorder
   #--- j'affiche le nom du repertoire courant
   configureLabelDirectory $visuNo $private($visuNo,labelDirectory)
   #--- je place le focus sur le contenu de la table pour permettre les deplacements
   #--- avec les touches de direction du clavier
   focus [$private($visuNo,tbl) bodypath]
}

#------------------------------------------------------------------------------
# fillTable
#   affiche les noms des fichiers dans la table
#------------------------------------------------------------------------------
 proc ::eshelvisu::localTable::fillTable2 { visuNo tbl files } {
   variable private
   global conf

   #--- je recupere les extensions autorisees dans un tableau
   array set enableExtension $conf(eshelvisu,enableExtension)
   if { [info exists enableExtension(fit)] == 0 } { set enableExtension(fit) 1 }
   if { [info exists enableExtension(raw)] == 0 } { set enableExtension(raw) 1 }
   if { [info exists enableExtension(jpg)] == 0 } { set enableExtension(jpg) 1 }
   if { [info exists enableExtension(bmp)] == 0 } { set enableExtension(bmp) 1 }
   if { [info exists enableExtension(gif)] == 0 } { set enableExtension(gif) 1 }
   if { [info exists enableExtension(png)] == 0 } { set enableExtension(png) 1 }
   if { [info exists enableExtension(tif)] == 0 } { set enableExtension(tif) 1 }

   #--- raz de la liste
   $tbl delete 0 end

   #--- je cree une ligne correspondant au repertoire parent
   lappend item " .." $private(parentFolder) "" ""
   #--- j'insere la ligne dans la table
   $tbl insert end $item
   #--- j'ajoute l'icone
   $tbl cellconfigure end,0 -image $private(folderIcon)

   #--- j'ajoute les lignes correspondant aux fichiers et sous-repertoires
   foreach i [lsort -dictionary $files] {
      set isdir "[lindex $i 0 ]"
      set name  "[lindex $i 1 ]"
      set date  "[lindex $i 2 ]"
      set size  "[lindex $i 3 ]"

      if { $isdir == 1 } {
         # cas d'un repertoire : affiche le nom du repertoire et l'icone private(folderIcon)
         set item {}
         #--- colonne name
         #--- bidouille !!! : j'ajoute un espace au debut du nom du repertoire
         #--- pour que le tri automatique mette les repertoires en premier par ordre alphabetique
         set name " $name"
         #--- colonne type
         set type "$private(folder)"
         #--- colonne date
         if { "$date" != "" && [string is integer $date ] } {
            set date "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]"
         }
         ####--- colonne serie (toujours vide pour un repertoire)
         ###set serie ""
         #--- colonne size (toujours vide pour un repertoire)
         set size ""
         #--- je cree la ligne
         lappend item "$name" "$type" "$date" "$size"
         #--- j'insere la ligne dans la table
         $tbl insert end $item
         #--- j'ajoute l'icone
         $tbl cellconfigure end,0 -image $private(folderIcon)

      } elseif {  [regexp ($conf(extension,defaut)|$conf(extension,defaut).gz)$ [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fit)$                [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fit.gz)$             [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fits)$               [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fits.gz)$            [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fts)$                [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fts.gz)$             [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.jpg|.jpeg)$          [string tolower $name]] && $enableExtension(jpg)==1
               || [regexp (.crw|.nef|.cr2|.dng)$ [string tolower $name]] && $enableExtension(raw)==1
               || [regexp (.bmp)$                [string tolower $name]] && $enableExtension(bmp)==1
               || [regexp (.gif)$                [string tolower $name]] && $enableExtension(gif)==1
               || [regexp (.tif|.tiff)$          [string tolower $name]] && $enableExtension(tif)==1
               || [regexp (.png)$                [string tolower $name]] && $enableExtension(png)==1
               } {

         #--- cas d'une image : ajoute une ligne dans la table avec le nom, type, serie et date du fichier
         #--- colonne name
         set name $name
         #--- colonne type
         set type "$private(fileImage)"
         #--- colonne date
         if { "$date" != "" && [string is integer $date ] } {
            set date "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]"
         }

         ####--- colonne serie
         ####------ 1) je prepare les variables
         ###set serie ""
         ###set serialName ""
         ###set serialInd ""
         ###set rootname [file rootname $name]
         ####------ 2) je supprime les extensions avec une boucle car il peut y avoir plusieurs extensions
         ###while { [string first "." "$rootname" ] != -1 } {
         ###   set rootname [file rootname $rootname]
         ###}
         ####------ 3) je cherche un numero a la fin de rootname => serialind
         ###set result [regexp {([^0-9]*)([0-9]+$)} $rootname match serialName serialInd ]
         ###if { $result == 1 } {
         ###   if { $serialInd != "" } {
         ###      #--- si serialInd n'est pas vide, ce fichier fait partie d'une serie
         ###      set serialName [string range $rootname 0 [expr [string last $serialInd $rootname ] -1 ]]
         ###      #--- je supprime les zeros a gauche pour que serialInd ne soit pas interprete comme une valeur en octal
         ###      if { $serialInd != "0" } {
         ###         set serialInd [string trimleft $serialInd "0" ]
         ###      }
         ###      if { [string is integer $serialInd] && "$serialInd" != ""} {
         ###         set serie [format "%s % 5d" $serialName $serialInd]
         ###      } else {
         ###         console::affiche_erreur "fillTable error serialInd=$serialInd name=$name \n"
         ###      }
         ###   }
         ###} else {
         ###   #--- pas de chiffre trouve a la fin du nom du fichier
         ###   set serie " "
         ###}
         #--- colonne size
         if { [string is integer $size ] } {
            set size [format "%12d" $size]
         }

         #--- je cree la ligne
         set item {}
         lappend item "$name" "$type" "$date" "$size"
         #--- j'ajoute une ligne dans la table
         $tbl insert end $item

      } elseif  { $conf(eshelvisu,showAllFiles)==1 } {
         #--- cas d'un fichier quelconque
         set item {}
         #--- colonne name
         set name $name
         #--- colonne type
         set type "$private(file)"
         #--- colonne date
         set date "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]"
         ####--- colonne serie
         ###set serie ""
         #--- colonne size
         if { [string is integer $size ] } {
            set size [format "%12d" $size]
         }
         #--- je cree la ligne
         lappend item "$name" "$type" "$date" "$size"
         #--- j'ajoute une ligne dans la table
         $tbl insert end $item
      }
   }

   #--- je trie par ordre alphabetique de la colonne selectionnee
   #tablelist::sortByColumn $tbl $private($visuNo,sortedColumn)
   #--- je rafraichis les scrollbars
   ##update
}

# fillVolumeTable
#   affiche la liste des disques dans la table
#------------------------------------------------------------------------------
 proc ::eshelvisu::localTable::fillVolumeTable { visuNo tbl } {
   variable private
   global conf

   #--- raz de la liste
   $tbl delete 0 end

   #--- j'ajoute les lignes correspondant aux fichiers et sous-repertoires
   foreach i [file volumes] {
      #--- colonne name
      set name [file nativename "$i"]
      #--- colonne type
      set type "$private(volume)"
      #--- colonne date
      set date ""
      #--- colonne serie (toujours vide pour un disque)
      set serie ""
      #--- colonne size (toujours vide pour un disque)
      set size ""
      #--- je cree la ligne
      set item {}
      lappend item "$name" "$type" "$serie" "$date" "$size"
      #--- j'insere la ligne dans la table
      $tbl insert end $item
      #--- j'ajoute l'icone
      $tbl cellconfigure end,0 -image $private(folderIcon)
   }
}

#------------------------------------------------------------------------------
# getFileList
#   retourne la liste des fichiers et des sous-repertoires presents
#   dans le repertoire donne en parametre
#   retourne une liste de 4 attributs pour chaque fichier [isdir shortname date size]
#------------------------------------------------------------------------------
 proc ::eshelvisu::localTable::getFileList { visuNo directory } {
   variable private

   set files ""
   foreach fullname [glob -nocomplain -dir $directory *] {
      set isdir [file isdir $fullname]
      set shortname [file tail $fullname]
      set date [file mtime $fullname]
      if { $isdir == 1 } {
         set size ""
      } else {
         set size [file size $fullname]
      }
      lappend files [list "$isdir" "$shortname" "$date" "$size" ]
   }
   return $files
}

#------------------------------------------------------------------------------
# localTable::cmdButton1Click
#   charge l'item selectionne (appelle loadItem)
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::cmdButton1Click { visuNo tbl } {
   variable private

   set selection [$tbl curselection]
   #--- retourne immediatemment si aucun item selectionne
   if { $selection == "" } {
      return
   }
   if { $private($visuNo,slideShowState) == 1 } {
      #--- j'arrete le slideshow
      set private($visuNo,slideShowState) 0
   }
   #--- je charge l'item selectionne
   after idle [list ::eshelvisu::localTable::loadItem $visuNo [lindex $selection 0 ] ]
}

#------------------------------------------------------------------------------
# localTable::cmdButton1DoubleClick
#
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::cmdButton1DoubleClick { visuNo tbl } {
   variable private

   set selection [$tbl curselection]
   #--- retourne immediatemment si aucun item selectionne
   if { "$selection" == "" } {
      return
   }

   if { $private($visuNo,slideShowState) == 1 } {
      #--- j'arrete le slideshow
      set private($visuNo,slideShowState) 0
   }

   #--- je charge l'item selectionne (avec option double-clic)
   after idle [list ::eshelvisu::localTable::loadItem $visuNo [lindex $selection 0 ] 1 ]
}

#------------------------------------------------------------------------------
# cmdSortColumn
#   trie les lignes par ordre alphabetique de la colonne
#   (est appele quand on clique sur le titre de la colonne)
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::cmdSortColumn { visuNo tbl col } {
   variable private
   #--- je memorise le numero de la colonne qui sert au tri car on a a besoin dans fillTable
   set private($visuNo,sortedColumn) $col
   set sens [tablelist::sortByColumn $tbl $col]
}

#------------------------------------------------------------------------------
# localTable::loadItem
#   si simple click :
#    si image : affiche l'image
#    si film  : charge le film et affiche la premiere image
#    si sous-repertoire : efface l'image affichee precedemment
#   sinon double click :
#    si image : affiche l'image
#    si film  : charge le film et affiche la premiere image
#    si sous-repertoire : va dans le repertoire et affiche le contenu (appelle fillTable)
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::loadItem { visuNo index { doubleClick 0 } { hduName "" } } {
   variable private
   global audace conf

   $private($visuNo,tbl) configure -cursor watch
   update

   set catchResult [ catch {
      set tbl $private($visuNo,tbl)

      set name [string trimleft [$tbl cellcget $index,0 -text]]
      set type [$tbl cellcget $index,1 -text]
      set filename [file join "$private($visuNo,directory)" "$name"]

      #--- protection pour éviter de charger plusieurs fois le même fichier
      #--- quand on déplace la souris dans la tablelist avec le bouton gauche appuyé
      if { $filename == [::confVisu::getFileName $visuNo] && $doubleClick == 0 } {
         return
      }

      if { [string first "$private(fileImage)" "$type" ] != -1 } {
         #--- j'affiche l'image
         ::confVisu::loadIma $visuNo $filename $hduName
      } elseif { "$type" == "$private(folder)" || "$type" == "$private(volume)" } {
         if { $doubleClick == 1 } {
            #--- j'affiche le contenu du sous repertoire
            set private($visuNo,directory) [ file join "$private($visuNo,directory)" "$name" ]
            fillTable $visuNo
         }
         set name ""

      } elseif { "$type" == "$private(parentFolder)"} {
         if { $doubleClick == 1 } {
            #--- j'affiche le contenu du repertoire parent
            if { "[file tail $private($visuNo,directory)]" != "" } {
               #--- si on n'est pas à la racine du disque, on monte d'un repertoire
               set private($visuNo,directory) [ file dirname "$private($visuNo,directory)" ]
               fillTable $visuNo
            } else {
               #--- si on est a la racine d'un disque, j'affiche la liste des disques
               fillVolumeTable $visuNo $private($visuNo,tbl)
            }
         }
         #--- je masque le nom pour que ".." n'apparaisse pas dans la barre de titre
         set name ""
      }

      #--- j'affiche le widget dans le canvas
      set private($visuNo,previousType)     "$type"
      set private($visuNo,previousFileName) "$filename"

      set private($visuNo,currentItemIndex) $index

   } ]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
   }

   $private($visuNo,tbl) configure -cursor arrow
}

#------------------------------------------------------------------------------
# localTable::refresh
#   recharge la liste des fichiers dans la table
#   et affiche une image si le parametre filename est renseigne
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::refresh { visuNo { fileName "" } { hduName "" }  } {
   variable private

   set tbl $private($visuNo,tbl)
   #--- je memorise la position verticale courante de la fenetre
   set position [ lindex [$tbl yview ] 0]
   #--- je refraichis la liste des fichiers dans la table
   fillTable $visuNo

   #--- je memorise la position verticale courante de la fenetre
   $tbl yview moveto $position

   #--- j'affiche l'image
   set tbl $private($visuNo,tbl)
   if { "$fileName" != "" } {
      #--- je recupere les noms des fichiers presents
      set files [$tbl getcolumns 0]
      #--- je recherche l'index du fichier
      set index [lsearch -exact $files "$fileName"]
      if { $index != -1 } {
         #--- j'efface la selection courante
         $tbl selection clear 0 end
         #--- je selectione le fichier
         $tbl selection set [list $index]
         #--- je scrolle la table pour voir la ligne selectionnee
         $tbl see $index
         #--- je charge l'item
         loadItem $visuNo $index 0 $hduName
      }
   }

   #--- je nettoie la visu si le fichier courant a ete efface
   set currentFileName [::confVisu::getFileName $visuNo ]
   if { $currentFileName != "" } {
      if { [file exists $currentFileName] == 0 } {
         ::confVisu::clear $visuNo
      }
   }

}

#------------------------------------------------------------------------------
# localTable::selectAll
#   selectionne tous les fichiers dans la table
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::selectAll { visuNo } {
   variable private

   $private($visuNo,tbl) selection set 0 end
}

#------------------------------------------------------------------------------
# localTable::renameFile
#   renomme un fichier ou une liste de fichiers
#
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::renameFile { visuNo } {
   variable private

   #--- j'arrete le diaporama
   set private($visuNo,slideShowState) "0"
   setSlideShow $visuNo

   set tbl $private($visuNo,tbl)
   set selection [$tbl curselection]

   #--- je constitue la liste des noms des fichiers
   set fileList [list ]
   foreach index $selection {
      set name [string trimleft [$tbl cellcget $index,0 -text]]
      set type [$tbl cellcget $index,1 -text]
      if { $type != "$private(folder)" } {
         lappend fileList $name
      }
   }

   #--- je retourne immediatemment si aucun item n'est selectionne
   if { [llength $fileList ] == 0 } {
      set message "$::caption(eshelvisu,table,selectFileError)"
      tk_messageBox -title $::caption(eshelvisu,title) -type ok -message "$message" -icon error
      return
   }

   #--- je copie les parametres  par defaut pour renameDialog
   ::eshelvisu::renameDialog::setProperty $visuNo "fileList" $fileList
   ::eshelvisu::renameDialog::setProperty $visuNo "genericName" $private($visuNo,genericName)
   ::eshelvisu::renameDialog::setProperty $visuNo "newFileName" $private($visuNo,newFileName)
   ::eshelvisu::renameDialog::setProperty $visuNo "firstIndex" $private($visuNo,firstIndex)
   ::eshelvisu::renameDialog::setProperty $visuNo "destinationFolder" $private($visuNo,directory)
   ::eshelvisu::renameDialog::setProperty $visuNo "overwrite" $private($visuNo,overwrite)
   ::eshelvisu::renameDialog::setProperty $visuNo "copy" $private($visuNo,copy)

   #--- j'affiche la fenetre
   set result [::eshelvisu::renameDialog::run $visuNo ]
   if { $result == 1 } {
      #--- je recupere les nouvelles valeurs des parametres
      set private($visuNo,genericName) [::eshelvisu::renameDialog::getProperty $visuNo "genericName"]
      set private($visuNo,newFileName) [::eshelvisu::renameDialog::getProperty $visuNo "newFileName"]
      set private($visuNo,firstIndex)  [::eshelvisu::renameDialog::getProperty $visuNo "firstIndex"]
      set destinationFolder            [::eshelvisu::renameDialog::getProperty $visuNo "destinationFolder"]
      set private($visuNo,copy)        [::eshelvisu::renameDialog::getProperty $visuNo "copy"]
      set private($visuNo,overwrite)   [::eshelvisu::renameDialog::getProperty $visuNo "overwrite"]
      #--- je verifie que le repertoire desitnation existe
      if { [file exists $destinationFolder] == "0" } {
         tk_messageBox -title "$::caption(eshelvisu,title) (visu$visuNo)" -type ok -icon error \
            -message "$::caption(eshelvisu,table,showDirectory) \n$destinationFolder"
         return
      }
      #--- je copie l'index dans la variable a incrementer
      set fileIndex $private($visuNo,firstIndex)
      set confirm "1"
     foreach name $fileList {
         set filename [file join "$private($visuNo,directory)" "$name"]
         if { [llength $fileList] > 1 } {
            set newFileName "$private($visuNo,genericName)$fileIndex[file extension $filename]"
         } else {
            #--- s'il n'y a qu'un fichier, je n'insere pas l'index dans le nom
            set newFileName "$private($visuNo,newFileName)"
         }

         if { $private($visuNo,overwrite) == "0" && [file exists $newFileName]== "1" } {
            tk_messageBox -title "$::caption(eshelvisu,title) (visu$visuNo)" -type ok -icon error \
               -message "$::caption(eshelvisu,title) \n$newFileName "
            break
         }
         if { $confirm == 1 } {
            set choice [tk_dialog .renamefile \
                  "$::caption(eshelvisu,title) (visu$visuNo)" \
                  "$::caption(eshelvisu,rename,renameFileConfirm) \n$name ==> $newFileName" \
                  question 3 "  $::caption(eshelvisu,delete,button0)  " $::caption(eshelvisu,delete,button1) "  $::caption(eshelvisu,delete,button2)  " $::caption(eshelvisu,delete,button3)]
         } else {
            set choice 0
         }

         if { $choice == 0 || $choice == 1} {
            #--- je renomme le fichier
            if { $private($visuNo,copy) == 1 } {
               file copy -force "$filename" "$destinationFolder/$newFileName"
            } else {
               file rename -force "$filename" "$destinationFolder/$newFileName"
            }
            #--- j'incremente l'index
            incr fileIndex
         } elseif { $choice == 2 } {
            #--- non => je ne renomme pas le fichier
         } elseif { $choice == 3 } {
            #--- abandonner
            break
         }
         if { $choice == 1 } {
            #--- OK pour tous => je ne demanderai plus de confirmation pour supprimer chaque fichier
            set confirm 0
         }
      }

      #--- je refraichis la table
      refresh $visuNo
   }
}

#------------------------------------------------------------------------------
# localTable::deleteFile
#   supprime le(s) fichier(s) selectionne(s)
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::deleteFile { visuNo } {
   variable private

   #--- j'arrete le diaporama
   set private($visuNo,slideShowState) "0"
   setSlideShow $visuNo

   set tbl $private($visuNo,tbl)
   set selection [$tbl curselection]
   #--- je retourne immediatemment si aucun item n'est selectionne
   if { "$selection" == "" } {
      set message "$::caption(eshelvisu,table,selectFileError)"
      tk_messageBox -title "$::caption(eshelvisu,title) (visu$visuNo)" -type ok -message "$message" -icon error
      return
   }

   #--- par defaut, je demande une confirmation avant de supprimer chaque fichier
   set confirm 1

   foreach index $selection {
      set name [string trimleft [$tbl cellcget $index,0 -text]]
     set type [$tbl cellcget $index,1 -text]

      if { $type == "$private(folder)" } {
         set dir [ file join "$private($visuNo,directory)" "$name" ]
         set message "$::caption(eshelvisu,table,deleteDirConfirm) \n $dir"
         set choice [tk_messageBox -title "$::caption(eshelvisu,title) (visu$visuNo)" -type okcancel -message "$message" -icon question]

         if { $choice == "ok" } {
            #--- je supprime le repertoire
            file delete -force "$dir"
         }

      } elseif { "$type" == "$private(fileImage)" || "$type" == "$private(fileMovie)" || "$type" == "$private(file)"} {
         set filename [file join "$private($visuNo,directory)" "$name"]

         if { $confirm == 1 } {
            set choice [tk_dialog .deletefile \
               "$::caption(eshelvisu,title) (visu$visuNo)" \
               "$::caption(eshelvisu,table,deleteFileConfirm) $name" \
               {} 3 $::caption(eshelvisu,delete,button0) $::caption(eshelvisu,delete,button1) $::caption(eshelvisu,delete,button2) $::caption(eshelvisu,delete,button3)]
         } else {
            set choice 0
         }

         if { $choice == 0 || $choice == 1} {
            #--- je ferme le fichier
            if { "$type" == "$private(fileMovie)" } {
               ::Movie::close $visuNo
            }
            #--- je supprime le fichier
            file delete "$filename"
            if { $choice == 1 } {
               #--- OK pour tous => je ne demanderai plus de confirmation pour supprimer chaque fichier
               set confirm 0
            }
         } elseif { $choice == 2 } {
            #--- non => je ne supprime pas le fichier
         } elseif { $choice == 3 } {
            #--- abandonner
            break
         }
      }
   }

   #--- je refraichis la table
   refresh $visuNo
}

#------------------------------------------------------------------------------
# localTable::setSlideShow
#   lance/arrete le diaporama
#
#   si le parametre "state" n'est pas fourni,
# Parameters
#   visuNo : numero de la visu
#   state  : 1=demarre le diaporama 0=arrete le diaporama (parametre optionnel)
# return
#   rien
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::setSlideShow { visuNo { state "" } } {
   variable private

   if { $state != "" } {
      set private($visuNo,slideShowState) $state
   }

   if { $private($visuNo,slideShowState) == 1 } {
      #--- je recupere le nombre d'images selectionnees
      set selection [$private($visuNo,tbl) curselection ]
      #--- je verifie que le nombre d'images selectionnées est suffisant (>=2)
      if { [llength $selection] < 2 } {
         #--- erreur, il n'y a moins de 2 images selectionnees
         tk_dialog .tempdialog \
            "$::caption(eshelvisu,title)" \
            "$::caption(eshelvisu,table,slideshowError)" \
            {} \
            0  \
            "OK"
         #--- j'abandonnne le SlideShow
         set private($visuNo,slideShowState) "0"
         return
      } else {
         #--- je lance le SlideShow
         set private($visuNo,slideShowListe) $selection
         set private($visuNo,slideShowAfterId) [after 10 ::eshelvisu::localTable::showNextSlide $visuNo]
      }

   } else {
      set private($visuNo,slideShowState) "0"
      if { "$private($visuNo,slideShowAfterId)" != "" } {
         #--- je tue l'iteration en attente
         after cancel $private($visuNo,slideShowAfterId)
         set private($visuNo,slideShowAfterId) ""
      }
   }
}

#------------------------------------------------------------------------------
# localTable::showNextSlide
#   affiche l'image suivante du diaporama
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::showNextSlide { visuNo { currentitem "0" } } {
   variable private

   #--- si une demande d'arret a deja ete faite, je sors de la boucle
   if { $private($visuNo,slideShowState) == 0 } {
      return

   }
   #--- je recupere les informations de l'item suivante
   set index [lindex $private($visuNo,slideShowListe) $currentitem ]

   loadItem $visuNo $index 1

   #--- j'incremente currentitem
   if { $currentitem < [expr [llength $private($visuNo,slideShowListe)] -1 ] } {
      incr currentitem
   } else {
      set currentitem "0"
   }

   #--- je lance l'iteration suivante
   if { $private($visuNo,slideShowState) == "1" } {
      set result [ catch { set delay [expr round($private($visuNo,slideShowDelay) * 1000) ] } ]
      if { $result != 0 } {
         #--- remplace le delai incorrect
         set delay "1000"
      }
      set private($visuNo,slideShowAfterId) [after $delay ::eshelvisu::localTable::showNextSlide $visuNo $currentitem ]
   }
}

#------------------------------------------------------------------------------
# localTable::saveColumnWidth
#   sauve la largeur des colonnes dans conf()
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::saveColumnWidth { visuNo } {
   variable private
   global conf

   #--- save columns width
   set conf(eshelvisu,width_column_name)   [$private($visuNo,tbl) columncget "name" -width]
   set conf(eshelvisu,width_column_type)   [$private($visuNo,tbl) columncget "type" -width]
   set conf(eshelvisu,width_column_date)   [$private($visuNo,tbl) columncget "date" -width]
   set conf(eshelvisu,width_column_size)   [$private($visuNo,tbl) columncget "size" -width]
}

#------------------------------------------------------------------------------
# showColumn
#   affiche ou masque une colonne
#   et adapte la largeur de la table en fonction des colonnes restant affichees
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::showColumn { visuNo tbl columnIndex } {
   variable private

   switch $columnIndex {
      "name" { set show "1" }
      "type" { set show $::conf(eshelvisu,show_column_type) }
      "date" { set show $::conf(eshelvisu,show_column_date) }
      "size" { set show $::conf(eshelvisu,show_column_size) }
   }
   if { $show == 1 } {
      $tbl columnconfigure $columnIndex -hide 0
   } else {
      $tbl columnconfigure $columnIndex -hide 1
   }

   #--- je recalcule la largeur de la liste
   set width 0
   for {set i 0} {$i < [$tbl columncount] } {incr i } {
      if { [$tbl columncget $i -hide] == 0 } {
         incr width [$tbl columncget $i -width]
      }
      #console::disp "width $i=[$tbl columncget $i -width] \n"
   }
   $tbl configure -width $width
}

#------------------------------------------------------------------------------
# localTable::createTbl
#   affiche la table avec ses scrollbars dans une frame
#   et cree le menu pop-up associe
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::createTbl { visuNo frame } {
   global conf
   variable private

   #--- quelques raccourcis utiles
   set tbl $frame.tbl
   set private($visuNo,tbl) "$tbl"
   set private($visuNo,labelDirectory) "$frame.directory"
   set menu $frame.menu
   set private($visuNo,popupmenu) "$menu"

   #--- repertoire
   label $frame.directory -anchor w -relief raised -bd 1
   #--- pour intercepter les mises a jour du label (equivalent a l'option -textvariable)
   bind $frame.directory <Configure> "::eshelvisu::localTable::configureLabelDirectory $visuNo $frame.directory"

   #--- table des fichiers
   tablelist::tablelist $tbl \
      -columns [ list \
         0 $::caption(eshelvisu,table,column_name)   left  \
         0 $::caption(eshelvisu,table,column_type)   left  \
         0 $::caption(eshelvisu,table,column_date)   left  \
         0 $::caption(eshelvisu,table,column_size)   right \
         ] \
      -labelcommand "::eshelvisu::localTable::cmdSortColumn $visuNo" \
      -xscrollcommand [list $frame.hsb set] -yscrollcommand [list $frame.vsb set] \
      -selectmode extended \
      -exportselection 0 \
      -showarrow 1 \
      -activestyle none

   #--- je fixe le nom et la largeur des colonnes
   $tbl columnconfigure 0 -name "name" -width $conf(eshelvisu,width_column_name)
   $tbl columnconfigure 1 -name "type" -width $conf(eshelvisu,width_column_type)
   $tbl columnconfigure 2 -name "date" -width $conf(eshelvisu,width_column_date)
   $tbl columnconfigure 3 -name "size" -width $conf(eshelvisu,width_column_size)

   #--- j'affiche ou masque les colonnes (la colonne du nom est toujours visible)
   $tbl columnconfigure "name" -hide 0
   $tbl columnconfigure "type" -hide [expr !$conf(eshelvisu,show_column_type) ]
   $tbl columnconfigure "date" -hide [expr !$conf(eshelvisu,show_column_date) ]
   $tbl columnconfigure "size" -hide [expr !$conf(eshelvisu,show_column_size) ]

   #--- bind de la souris et du clavier
   bind $tbl  <<ListboxSelect>> [list ::eshelvisu::localTable::cmdButton1Click $visuNo $tbl]
   bind [$tbl bodypath] <Double-1>  [list ::eshelvisu::localTable::cmdButton1DoubleClick $visuNo $tbl]
   bind [$tbl bodypath] <Button-3>  [list tk_popup $menu %X %Y]
   bind [$tbl bodypath] <Return>    [list ::eshelvisu::localTable::cmdButton1DoubleClick $visuNo $tbl]
   bind [$tbl bodypath] <Key-Delete>    [list ::eshelvisu::localTable::deleteFile $visuNo]
   bind [$tbl bodypath] <Control-Key-A>    [list ::eshelvisu::localTable::selectAll $visuNo]
   bind [$tbl bodypath] <Control-Key-a>    [list ::eshelvisu::localTable::selectAll $visuNo]
   bind [$tbl bodypath] <Key-F5>    [list ::eshelvisu::localTable::refresh $visuNo]

   #--- choix de l'ordre aphabetique en fonction de l'OS ( pour ne pas depayser les habitues)
   if { $::tcl_platform(os) == "Linux" } {
      #--- je classe les fichiers par ordre alphabetique, en tenant compte des majuscules/minuscules
      $tbl columnconfigure 0 -sortmode ascii
   } else {
      #--- je classe les fichiers par ordre alphabetique, sans tenir compte des majuscules/minuscules
      $tbl columnconfigure 0 -sortmode dictionary
   }

   #--- j'adapte la largeur de la liste en fonction des colonnes affichees
   showColumn $visuNo $tbl "name"

   #--- scrollbars verticale et horizontale
   scrollbar $frame.vsb -orient vertical   -command [list $tbl yview]
   scrollbar $frame.hsb -orient horizontal -command [list $tbl xview]

   #--- je place la liste et les scrollbar dans une grille
   grid $frame.directory -row 0 -column 0 -columnspan 2 -sticky ew
   grid $tbl -row 1 -column 0 -sticky nsew
   grid $frame.vsb -row 1 -column 1 -sticky ns
   grid $frame.hsb -row 2 -column 0 -sticky ew
   grid rowconfigure    $frame 1 -weight 1
   grid columnconfigure $frame 0 -weight 1

   #--- pop-up menu associe a la table
   menu $menu -tearoff no
   $menu add command -label $::caption(eshelvisu,refresh) \
      -accelerator "F5" \
      -command "::eshelvisu::localTable::refresh $visuNo"
   $menu add command -label $::caption(eshelvisu,select_all) \
      -accelerator "Ctrl+A" \
      -command "::eshelvisu::localTable::selectAll $visuNo"
   $menu add command -label $::caption(eshelvisu,rename_file)  \
      -command "::eshelvisu::localTable::renameFile $visuNo"
   $menu add command -label $::caption(eshelvisu,delete_file) \
      -accelerator "Delete" \
      -command "::eshelvisu::localTable::deleteFile $visuNo"
   $menu add separator
   $menu add command -label "$::caption(eshelvisu,exportBess) ..." \
      -command "::eshelvisu::localTable::exportBess $visuNo"
   $menu add command -label "$::caption(eshelvisu,exportFits) ..." \
      -command "::eshelvisu::localTable::exportFits $visuNo"
   $menu add command -label "$::caption(eshelvisu,copyStarNameToClipboard)" \
      -command "::eshelvisu::localTable::copyStarNameToClipboard $visuNo"
   $menu add separator
   $menu add checkbutton -label $::caption(eshelvisu,table,column_type)   \
      -variable conf(eshelvisu,show_column_type)       \
      -command "::eshelvisu::localTable::showColumn $visuNo $::eshelvisu::localTable::private($visuNo,tbl) type"
   $menu add checkbutton -label $::caption(eshelvisu,table,column_date)   \
      -variable conf(eshelvisu,show_column_date)       \
      -command "::eshelvisu::localTable::showColumn $visuNo $::eshelvisu::localTable::private($visuNo,tbl) date"
   $menu add checkbutton -label $::caption(eshelvisu,table,column_size)   \
      -variable conf(eshelvisu,show_column_size)       \
      -command "::eshelvisu::localTable::showColumn $visuNo $::eshelvisu::localTable::private($visuNo,tbl) size"

}



#------------------------------------------------------------------------------
# localTable::configureLabelDirectory
#   affiche private($visuNo,directory) dans le label
#     si le label a une taille suffisante, affiche private($visuNo,directory) en entier
#     si le label a une taille insuffisante, affiche la fin de private($visuNo,directory)
#------------------------------------------------------------------------------
proc ::eshelvisu::localTable::configureLabelDirectory { visuNo label } {
   variable private

   set tt $private($visuNo,directory)
   set labelwidth [expr [winfo width $label]-5]
   if { [font measure [$label cget -font] $tt] <= $labelwidth } {
      #--- affiche private($visuNo,directory) en entier
      $label configure -text $tt
   } else {
      while { [string length $tt] > 3 } {
         set tt [string range $tt 1 end]
         if { [font measure [$label cget -font] ...$tt] <= $labelwidth } {
            break
         }
      }
      #--- affiche "..." suivi de la fin de private($visuNo,directory)
      $label configure -text .$tt
   }
}

################################################################
# namespace ::eshelvisu::config
#    fenetre de configuration de l'outil eshelvisu
################################################################
namespace eval ::eshelvisu::config {
}

#------------------------------------------------------------
# ::eshelvisu::config::getLabel
#   retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::eshelvisu::config::getLabel { } {
   return "$::caption(eshelvisu,title)"
}

#------------------------------------------------------------
# ::eshelvisu::config::showHelp
#   affiche l'aide de cet outil
#------------------------------------------------------------
proc ::eshelvisu::config::showHelp { } {
   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::eshelvisu::getPluginType ] ] \
         [ ::eshelvisu::getPluginDirectory ] [ ::eshelvisu::getPluginHelp ] "config"
}

#------------------------------------------------------------
# ::eshelvisu::config::confToWidget { }
#   copie les parametres du tableau conf() dans les variables des widgets
#------------------------------------------------------------
proc ::eshelvisu::config::confToWidget { } {
   variable private
   variable widget
   variable widgetEnableExtension
   global conf

   #--- je mets les extensions dans un array (de-serialisation)
   array set widgetEnableExtension $conf(eshelvisu,enableExtension)

   #--- j'initialise les variables utilisees par le widgets
   set widget(showAllFiles) $conf(eshelvisu,showAllFiles)
}

#------------------------------------------------------------
# ::eshelvisu::config::cmdApply { }
#   copie les variable des widgets dans le tableau conf()
#------------------------------------------------------------
proc ::eshelvisu::config::cmdApply { visuNo } {
   variable private
   variable widget
   variable widgetEnableExtension
   global conf

   set conf(eshelvisu,enableExtension) [array get widgetEnableExtension]
   set conf(eshelvisu,showAllFiles)  $widget(showAllFiles)
}

#------------------------------------------------------------
# ::eshelvisu::config::fillConfigPage { }
#   fenetre de configuration de l'outil
#   return rien
#------------------------------------------------------------
proc ::eshelvisu::config::fillConfigPage { frm visuNo } {
   variable widget
   variable widgetEnableExtension
   global conf

   #--- je memorise la reference de la frame
   set widget(frm) $frm

   #--- j'initialise les variables des widgets
   confToWidget

   frame $frm.extension -borderwidth 1 -relief ridge
   pack $frm.extension -side top -fill both -expand 1

   label $frm.extension.knownfiles -text "$::caption(eshelvisu,config,known_files)" \
      -justify left
   pack $frm.extension.knownfiles -anchor w -side top -padx 5 -pady 0

   #--- fichiers extension par defaut
   if { ( $conf(extension,defaut) == ".jpg" ) || ( $conf(extension,defaut) == ".jpeg" ) || \
      ( $conf(extension,defaut) == ".crw" ) || ( $conf(extension,defaut) == ".nef" ) || \
      ( $conf(extension,defaut) == ".cr2" ) || ( $conf(extension,defaut) == ".dng" ) || \
      ( $conf(extension,defaut) == ".CRW" ) || ( $conf(extension,defaut) == ".NEF" ) || \
      ( $conf(extension,defaut) == ".CR2" ) || ( $conf(extension,defaut) == ".DNG" ) \
       } {

     ### ( $conf(extension,defaut) == ".gif" )  || ( $conf(extension,defaut) == ".bmp" ) || \
     ### ( $conf(extension,defaut) == ".png" )  || ( $conf(extension,defaut) == ".tif" ) || \
     ### ( $conf(extension,defaut) == ".tiff" ) || ( $conf(extension,defaut) == ".avi" ) || \
     ### ( $conf(extension,defaut) == ".mpeg" )

      checkbutton $frm.extension.extdefaut -text "$conf(extension,defaut)" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(defautext)
      pack $frm.extension.extdefaut -anchor w -side top -padx 5 -pady 0
   } else {
      checkbutton $frm.extension.extdefaut -text "$conf(extension,defaut) $conf(extension,defaut).gz" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(defautext)
      pack $frm.extension.extdefaut -anchor w -side top -padx 5 -pady 0
   }

   #--- fichiers fit
   if { $conf(extension,defaut) == ".fit" } {
      checkbutton $frm.extension.extfit -text ".fts .fts.gz .fits .fits.gz" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(fit)
      pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".fts" } {
      checkbutton $frm.extension.extfit -text ".fit .fit.gz .fits .fits.gz" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(fit)
      pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".fits" } {
      checkbutton $frm.extension.extfit -text ".fit .fit.gz .fts .fts.gz" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(fit)
      pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
   } else {
      checkbutton $frm.extension.extfit -text ".fit .fit.gz .fts .fts.gz .fits .fits.gz" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(fit)
      pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
   }

  ### #--- fichiers gif
  ### if { $conf(extension,defaut) != ".gif" } {
  ###    checkbutton $frm.extension.gif -text ".gif" \
  ###        -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(gif)
  ###    pack $frm.extension.gif -anchor w -side top -padx 5 -pady 0
  ### }

  ### #--- fichiers bmp
  ### if { $conf(extension,defaut) != ".bmp" } {
  ###    checkbutton $frm.extension.bmp -text ".bmp" \
  ###        -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(bmp)
  ###    pack $frm.extension.bmp -anchor w -side top -padx 5 -pady 0
  ### }

   #--- fichiers jpg
   if { ( $conf(extension,defaut) != ".jpg" ) && ( $conf(extension,defaut) != ".jpeg" ) } {
      checkbutton $frm.extension.jpg -text ".jpg .jpeg" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(jpg)
      pack $frm.extension.jpg -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".jpg" } {
      checkbutton $frm.extension.jpg -text ".jpeg" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(jpg)
      pack $frm.extension.jpg -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".jpeg" } {
      checkbutton $frm.extension.jpg -text ".jpg" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(jpg)
      pack $frm.extension.jpg -anchor w -side top -padx 5 -pady 0
   }

  ### #--- fichiers png
  ### if { $conf(extension,defaut) != ".png" } {
  ###    checkbutton $frm.extension.png -text ".png" \
  ###        -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(png)
  ###    pack $frm.extension.png -anchor w -side top -padx 5 -pady 0
  ### }

  ### #--- fichiers tif
  ### if { ( $conf(extension,defaut) != ".tif" ) && ( $conf(extension,defaut) != ".tiff" ) } {
  ###    checkbutton $frm.extension.tif -text ".tif .tiff" \
  ###        -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(tif)
  ###    pack $frm.extension.tif -anchor w -side top -padx 5 -pady 0
  ### } elseif { $conf(extension,defaut) == ".tif" } {
  ###    checkbutton $frm.extension.tif -text ".tiff" \
  ###        -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(tif)
  ###    pack $frm.extension.tif -anchor w -side top -padx 5 -pady 0
  ### } elseif { $conf(extension,defaut) == ".tiff" } {
  ###    checkbutton $frm.extension.tif -text ".tif" \
  ###        -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(tif)
  ###    pack $frm.extension.tif -anchor w -side top -padx 5 -pady 0
  ### }

   #--- fichiers raw
   if { ( $conf(extension,defaut) != ".crw" ) && ( $conf(extension,defaut) != ".cr2" ) && \
      ( $conf(extension,defaut) != ".nef" ) && ( $conf(extension,defaut) != ".dng" ) && \
      ( $conf(extension,defaut) != ".CRW" ) && ( $conf(extension,defaut) != ".CR2" ) && \
      ( $conf(extension,defaut) != ".NEF" ) && ( $conf(extension,defaut) != ".DNG" ) } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .dng .CRW .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".crw" } {
      checkbutton $frm.extension.raw -text ".cr2 .nef .dng .CRW .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".cr2" } {
      checkbutton $frm.extension.raw -text ".crw .nef .dng .CRW .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".nef" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .dng .CRW .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".dng" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .CRW .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".CRW" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .dng .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".CR2" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .dng .CRW .NEF .DNG" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".NEF" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .dng .CRW .CR2 .DNG" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".DNG" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .dng .CRW .CR2 .NEF" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   }

   #--- fichiers avi
   if { ( $conf(extension,defaut) != ".avi" ) && ( $conf(extension,defaut) != ".mpeg" ) } {
      checkbutton $frm.extension.avi -text ".avi .mpeg" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(avi)
      pack $frm.extension.avi -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".avi" } {
      checkbutton $frm.extension.avi -text ".mpeg" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(avi)
      pack $frm.extension.avi -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".mpeg" } {
      checkbutton $frm.extension.avi -text ".avi" \
          -highlightthickness 0 -variable ::eshelvisu::config::widgetEnableExtension(avi)
      pack $frm.extension.avi -anchor w -side top -padx 5 -pady 0
   }

  ### if { [package versions Img ]== "" } {
  ###    #--- je decoche les checkbox
  ###    set ::eshelvisu::config::widgetEnableExtension(bmp) 0
  ###    set ::eshelvisu::config::widgetEnableExtension(jpg) 0
  ###    set ::eshelvisu::config::widgetEnableExtension(png) 0
  ###    set ::eshelvisu::config::widgetEnableExtension(tif) 0
  ###    #--- je desactive les checkbox pour qu'on ne puisse pas les cocher
  ###    $frm.extension.bmp configure -state disabled
  ###    $frm.extension.jpg configure -state disabled
  ###    $frm.extension.png configure -state disabled
  ###    $frm.extension.tif configure -state disabled
  ### }

   #--- pas de film si on est sous Linux ou si le package tmci n'est pas present
   if { $::tcl_platform(os) == "Linux" && [package versions tmci ]== "" } {
      #--- je decoche la checkbox
      set ::eshelvisu::config::widgetEnableExtension(avi) 0
      #--- je desactive la checkbox pour qu'on ne puisse pas la cocher
      $frm.extension.avi configure -state disabled
   }

   #--- remarque
   label $frm.extension.remark -text "$::caption(eshelvisu,config,remark1)" \
      -justify left
   pack $frm.extension.remark -anchor w -side top -padx 5 -pady 0

   #--- frame des options
   frame $frm.display -borderwidth 1 -relief ridge
   pack $frm.display -side top -fill both -expand 1

   #--- afficher tous les fichiers
   checkbutton $frm.display.show_all_afiles -text $::caption(eshelvisu,showAllFiles) \
       -highlightthickness 0 -variable ::eshelvisu::config::widget(showAllFiles)
   pack $frm.display.show_all_afiles -anchor w -side top -padx 5 -pady 0
}

#------------------------------------------------------------
# ========== Namespace de la fenetre de renommage des fichiers ========
#
# cette fenetre est modale
# A la fermeture, sa procedure run retourne les valeurs
#   { genericName firstIndex }
#------------------------------------------------------------

namespace eval ::eshelvisu::renameDialog {
}

#------------------------------------------------------------
# config::run
#   affiche la fenetre de renommage
#------------------------------------------------------------
proc ::eshelvisu::renameDialog::run { visuNo } {
   variable private

   set private($visuNo,toplevel) "[confVisu::getBase $visuNo].renameDialog"
   if { [info exists private($visuNo,geometry)] == 0 } {
      set private($visuNo,geometry) "+150+80"
   }

   #--- j'affiche la fenetre de configuration
   if { [winfo exists $private($visuNo,toplevel)] == 0 } {
      set result [::confGenerique::run $visuNo $private($visuNo,toplevel) "::eshelvisu::renameDialog" \
         -modal 1 -resizable 1 -geometry $private($visuNo,geometry)]
   } else {
      focus $private($visuNo,toplevel)
      set result "0"
   }
   return $result
}

#------------------------------------------------------------
# ::eshelvisu::renameDialog::cmdApply
#   copie les valeurs saisies da
#------------------------------------------------------------
proc ::eshelvisu::renameDialog::cmdApply { visuNo } {
   variable private

}

#------------------------------------------------------------
# ::eshelvisu::renameDialog::cmdClose
#   ferme la fenetre de configuration
#------------------------------------------------------------
proc ::eshelvisu::renameDialog::cmdClose { visuNo } {
   variable private

   #--- j'enregistre la position et la dimension de la fenetre de configuration
   set private($visuNo,geometry) [ wm geometry $private($visuNo,toplevel)]
}

#------------------------------------------------------------
# ::eshelvisu::renameDialog::getLabel
#   retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::eshelvisu::renameDialog::getLabel { } {
   return "[::eshelvisu::getPluginTitle]"
}

#------------------------------------------------------------
# ::eshelvisu::renameDialog::fillConfigPage { }
#   fenetre de configuration de la camera
#   return rien
#------------------------------------------------------------
proc ::eshelvisu::renameDialog::fillConfigPage { frm visuNo } {
   variable private

   set private($visuNo,This) $frm

   if { [llength $private($visuNo,fileList)] >  1 } {
      TitleFrame $frm.renameFile -borderwidth 2 -relief ridge -text "$::caption(eshelvisu,rename,renameFile)"
         listbox $frm.renameFile.list -state normal -height 4 -state disabled \
            -listvariable ::eshelvisu::renameDialog::private($visuNo,fileList) \
            -xscrollcommand [list $frm.renameFile.hsb set] \
            -yscrollcommand [list $frm.renameFile.vsb set]
         #--- scrollbars verticale et horizontale
         scrollbar $frm.renameFile.vsb -orient vertical   -command [list $frm.renameFile.list yview]
         scrollbar $frm.renameFile.hsb -orient horizontal -command [list $frm.renameFile.list xview]

         grid $frm.renameFile.list -in [$frm.renameFile getframe] -row 0 -column 0 -sticky nsew
         grid $frm.renameFile.vsb  -in [$frm.renameFile getframe] -row 0 -column 1 -sticky ns
         grid $frm.renameFile.hsb  -in [$frm.renameFile getframe] -row 1 -column 0 -sticky ew
         grid rowconfigure    [$frm.renameFile getframe] 0 -weight 1
         grid columnconfigure [$frm.renameFile getframe] 0 -weight 1
      pack $frm.renameFile -anchor w -side top -fill both -expand 1

      LabelEntry $frm.genericName -label "$::caption(eshelvisu,rename,genericName)" \
         -labeljustify left -justify left -labelwidth 12 \
         -textvariable ::eshelvisu::renameDialog::private($visuNo,genericName)
      pack $frm.genericName -side top -anchor w -padx 10 -pady 2 -fill x -expand 0

      LabelEntry $frm.firstIndex -label "$::caption(eshelvisu,rename,firstIndex)" \
         -labeljustify left -justify right -labelwidth 12 -width 6 \
         -textvariable ::eshelvisu::renameDialog::private($visuNo,firstIndex)
      pack $frm.firstIndex -side top -anchor w -padx 10 -pady 2 -fill none -expand 0
   } else {
      TitleFrame $frm.renameFile -borderwidth 2 -relief ridge -text "$::caption(eshelvisu,rename,renameFile)"
         listbox $frm.renameFile.list -state normal -height 1 -state disabled \
            -listvariable ::eshelvisu::renameDialog::private($visuNo,fileList)
         pack $frm.renameFile.list -in [$frm.renameFile getframe] -side top -anchor w -padx 10 -pady 5 -fill x -expand 0
      pack $frm.renameFile -anchor w -side top -fill x -expand 0

      LabelEntry $frm.newName -label "$::caption(eshelvisu,rename,newName)" \
         -labeljustify left -justify left -labelwidth 12 \
         -textvariable ::eshelvisu::renameDialog::private($visuNo,newFileName)
      pack $frm.newName -side top -anchor w -padx 10 -pady 2 -fill x -expand 0
   }

   frame $frm.destination -borderwidth 1 -relief flat
      LabelEntry $frm.destination.folder -label "$::caption(eshelvisu,rename,destinationFolder)" \
         -labeljustify left -justify left -labelwidth 12 \
         -textvariable ::eshelvisu::renameDialog::private($visuNo,destinationFolder)
      pack $frm.destination.folder -side left -anchor w -padx 10 -pady 2 -fill x -expand 1
      button $frm.destination.explore -text "  ...  " -width 1 \
                  -command "::eshelvisu::renameDialog::explore $visuNo"
      pack $frm.destination.explore -side left -anchor w -padx 4 -pady 2 -fill none -expand 0
   pack $frm.destination -side top -anchor w -pady 2 -fill x -expand 0

   checkbutton $frm.copy -text "$::caption(eshelvisu,rename,copyFile)" \
         -variable ::eshelvisu::renameDialog::private($visuNo,copy)
   pack $frm.copy -side top -anchor w -padx 10 -pady 2 -fill none -expand 0

   checkbutton $frm.overwrite -text "$::caption(eshelvisu,rename,overwrite)" \
         -variable ::eshelvisu::renameDialog::private($visuNo,overwrite)
   pack $frm.overwrite -side top -anchor w -padx 10 -pady 2 -fill none -expand 0

}

#------------------------------------------------------------
# ::eshelvisu::renameDialog::explore
# selectionne un repertoire
#
#------------------------------------------------------------
proc ::eshelvisu::renameDialog::explore { visuNo } {
   variable private

   set directory [ tk_chooseDirectory -title "[::eshelvisu::getPluginTitle] $::caption(eshelvisu,rename,destinationFolder)" \
      -initialdir $private($visuNo,destinationFolder) -parent $private($visuNo,toplevel) ]

   if { $directory != "" } {
      set private($visuNo,destinationFolder) $directory
   }
}

#------------------------------------------------------------
# ::eshelvisu::renameDialog::getProperty
#   retourne la valeur d'une propriété
#------------------------------------------------------------
proc ::eshelvisu::renameDialog::getProperty { visuNo propertyName } {
   variable private

   return $private($visuNo,$propertyName)
}

#------------------------------------------------------------
# ::eshelvisu::renameDialog::setProperty
#
#------------------------------------------------------------
proc ::eshelvisu::renameDialog::setProperty { visuNo propertyName value } {
   variable private

   set private($visuNo,$propertyName) $value
}

