#
## @file visu.tcl
#  @brief outil d'affichage des lignes de contrôles
#  @author Michel PUJOL
#  $Id: visu.tcl 13378 2016-03-15 21:19:06Z rzachantke $
#

## namespace eshel::visu
#  @brief outil d'affichage des lignes de contrôles

namespace eval ::eshel::visu {

}

#------------------------------------------------------------
## @brief affiche le numéro des lignes dans l'image2D
#  @param visuNo    numéro de la fenêtre de profil
#  @param args      paramètres optionels (utilisés seulement par le listener)
#
proc ::eshel::visu::showLineLabel { visuNo args } {
   variable private

   #--- j'efface les libelles des lignes
   hideLineLabel $visuNo

   set fileName [::confVisu::getFileName $visuNo]
   set orderHduNum [::confVisu::getHduNo $visuNo "ORDERS"]
   #--- je cree le listener sur le zoom
   ::confVisu::addZoomListener $visuNo [list ::eshel::visu::showLineLabel $visuNo ]

   #--- je pointe la table des ordres
   set hFile ""
   set catchResult [catch {
      set hCanvas [confVisu::getCanvas $visuNo]
      set hFile [fits open $fileName 0]
      $hFile move $orderHduNum
      #--- je recupere les minOrder et maxOrder
      ###set nbOrder [lindex [lindex [$hFile get keyword "NAXIS2"] 0] 1]
      set nbLine   [::eshel::file::getKeyword $hFile NAXIS2]
      set width    [::eshel::file::getKeyword $hFile WIDTH]
      set x  [expr $width /2 ]
      set bestFwhmValue 99
      set bestFwhmLineNo ""
      set bestItemId ""
      for {set lineNo 1 } { $lineNo <= $nbLine } { incr lineNo } {
         set yc       [lindex [lindex [$hFile get table "yc" $lineNo ] 0] 0]
         set flag     [lindex [lindex [$hFile get table "flag" $lineNo ] 0] 0]
         switch $flag {
            "1" {
               set fwhm [lindex [lindex [$hFile get table "fwhm" $lineNo ] 0] 0]
               set comment "OK. FWHM=$fwhm"
            }
            "-2" {
               set comment "bad geometrical RMS"
               set fwhm ""
            }
            "-3" {
               set comment "too short"
               set fwhm ""
            }
            "-3" {
               set comment "no central y"
               set fwhm ""
            }
            "0" {
               set comment "not valid"
               set fwhm ""
            }
         }
         if { $yc > 0 } {
            if { $flag == 1 } {
               set color yellow
            } else {
               set color red
            }
            set yc [expr $yc + 8 ]
            set linelabel "Line $lineNo $comment"
            set coord [::confVisu::picture2Canvas $visuNo [list $x $yc]]
            set itemId [$hCanvas create text [lindex $coord 0] [lindex $coord 1] -text $linelabel -tag "linelabel line$lineNo" -state normal -fill $color]
            $hCanvas lower orderLabel polydraw
            #--- je verifie si c'est la plus petite FWHM
            if { $fwhm != "" && $fwhm < $bestFwhmValue } {
               set bestFwhmValue $fwhm
               set bestFwhmLineNo $lineNo
               set bestItemId $itemId
            }
         }
      }
      if { $bestItemId != "" } {
         #--- j'affiche en gras l'ordre qui a la meilleur FWHM
        set text [$hCanvas itemcget $bestItemId -text]
        $hCanvas itemconfigure $bestItemId -text ">>> $text <<<"
      }

   }]
   if { $hFile != "" } {
      $hFile close
   }
   if { $catchResult == 1 } {
      error $::errorInfo
   }
   return
}

#------------------------------------------------------------
## @brief masque le numéro des lignes dans l'image2D
#  @param visuNo    numéro de la fenêtre de profil

proc ::eshel::visu::hideLineLabel { visuNo } {
   variable private

   #--- je supprime le listener sur le zoom
   ::confVisu::removeZoomListener $visuNo [list ::eshel::visu::showLineLabel $visuNo ]

   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete linelabel

}

#------------------------------------------------------------
## @brief affiche le numéro des ordres dans l'image2D
#  @param visuNo    numéro de la fenetre de profil
#  @param args   ??
#  @todo commenter le param args
#
proc ::eshel::visu::showOrderLabel { visuNo args } {

   hideOrderLabel $visuNo

   #--- je cree le listener sur le zoom
   ::confVisu::addZoomListener $visuNo [list ::eshel::visu::showOrderLabel $visuNo]

   #--- j'efface les libelles des lignes
   set fileName [::confVisu::getFileName $visuNo]
   set orderHduNum [::confVisu::getHduNo $visuNo "ORDERS"]

   #--- je pointe la table des ordres
   set hFile ""
   set catchResult [catch {
      set hCanvas [confVisu::getCanvas $visuNo]
      set hFile [fits open $fileName 0]
      $hFile move $orderHduNum
      #--- je recupere les minOrder et maxOrder
      set nbOrder    [::eshel::file::getKeyword $hFile NAXIS2]
      set width    [::eshel::file::getKeyword $hFile WIDTH]
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
            $hCanvas lower orderLabel polydraw
         }
      }
   }]
   if { $hFile != "" } {
         $hFile close
   }
   if { $catchResult == 1 } {
      error $::errorInfo
   }

   return
}

#------------------------------------------------------------
## @brief masque le numéro des ordres dans l'image2D
#  @param visuNo numéro de la fenêtre de profil
#
proc ::eshel::visu::hideOrderLabel { visuNo } {
   variable private

   ::confVisu::removeZoomListener $visuNo [list ::eshel::visu::showOrderLabel $visuNo]

   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete orderLabel
}

#------------------------------------------------------------
## @brief affiche le tracé des ordres
#  @param visuNo    numero de la fenetre de profil
#  @param displayAll
#  - 1= affiche les tracés dans toute la fenêtre
#  - 0= affiche la tracé entre les marges
#  @param args      parametres optionels (utilises seulement pas le listener)
#
proc ::eshel::visu::showLineDraw { visuNo { displayAll 0 } args} {
   variable private

   hideLineDraw $visuNo

   set fileName [::confVisu::getFileName $visuNo]
   set orderHduNum [::confVisu::getHduNo $visuNo "ORDERS"]
   #--- je cree le listener sur le zoom
   ::confVisu::addZoomListener $visuNo [list ::eshel::visu::showLineDraw $visuNo ]

   #--- je pointe la table des ordres
   set hFile ""
   set catchResult [catch {
      set hCanvas [confVisu::getCanvas $visuNo]
      set hFile [fits open $fileName 0]
      $hFile move $orderHduNum
      #--- je recupere les parametres de l'image
      set width      [::eshel::file::getKeyword $hFile WIDTH]
      set min_order  [::eshel::file::getKeyword $hFile MIN_ORDER]
      set max_order  [::eshel::file::getKeyword $hFile MAX_ORDER]

      for {set orderNum $min_order } { $orderNum <= $max_order } { incr orderNum } {
         set n [expr $orderNum - $min_order +1 ]
         set flag [string trim [lindex [lindex [$hFile get table "flag" $n ] 0 ] 0]]
         if { $flag ==0 } {
            #--- j'ignore les ordres qui n'ont pas flag=1
            continue
         }
         if { $displayAll == 0 } {
            set minX [string trim [lindex [lindex [$hFile get table "min_x" $n ] 0 ] 0]]
            set maxX [string trim [lindex [lindex [$hFile get table "max_x" $n ] 0 ] 0]]
         } else {
            set minX 5
            set maxX [expr $width - 5]
         }
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

         set coordlist {}
         for { set x $minX } { $x < $maxX } { incr x } {
            #--- je calcule l'ordonnee y
            set y [expr (((($p5 * $x + $p4) * $x + $p3) * $x + $p2) *$x + $p1) * $x + $p0 ]
            set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
            lappend coordlist [lindex $coord 0] [lindex $coord 1]
         }
         if { $flag == 1 } {
            set color yellow
         } else {
            set color red
         }
         if { [llength $coordlist] >= 4 } {
            $hCanvas create line $coordlist -fill $color -dash {2  8} -width 1 -offset center -tag orderLine
            $hCanvas lower orderLine calibrationLine
            $hCanvas lower orderLine polydraw
         } else {
            #--- TODO : traiter le cas ou il n'y qu'un point
         }
      }
   }]
   if { $hFile != "" } {
      $hFile close
   }
   if { $catchResult == 1 } {
      error $::errorInfo
   }

   return
}

#------------------------------------------------------------
## @brief masque le tracé des ordres
#  @param visuNo numero de la fenêtre de profil
#
proc ::eshel::visu::hideLineDraw { visuNo } {
   variable private

   ::confVisu::removeZoomListener $visuNo [list ::eshel::visu::showLineDraw $visuNo ]

   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete orderLine
   return
}

#------------------------------------------------------------
## @brief affiche l'axe de la caméra
#  @param visuNo numéro de la fenêtre de profil
#  @param tangenteList ??
#  @param cameraAxisCoord ??
#  @param referenceAxisCoord ??
#  @todo commenter les param
#
proc ::eshel::visu::showTangenteDraw { visuNo tangenteList cameraAxisCoord referenceAxisCoord} {
   variable private

   hideTangenteDraw  $visuNo

   set private($visuNo,tangenteList) $tangenteList
   set private($visuNo,cameraAxisCoord) $cameraAxisCoord
   set private($visuNo,referenceAxisCoord) $referenceAxisCoord


   #--- je cree le listener sur le zoom
   ::confVisu::addZoomListener $visuNo [list ::eshel::visu::showTangenteDrawListener $visuNo ]

   set hCanvas [confVisu::getCanvas $visuNo]

   ####--- j'affiche des cercles bleus autour des étoiles de l'image
   ###foreach coord $tangenteList {
   ###   set xima  [lindex $coord 0]
   ###   set yima  [lindex $coord 1]
   ###
   ###   #--- je calcule les coordonnees dans le canvas
   ###   set coord [::confVisu::picture2Canvas $visuNo [list $xima $yima ]]
   ###   set xima [lindex $coord 0]
   ###   set yima [lindex $coord 1]
   ###
   ###   #--- je dessine des cercles autour des etoiles
   ###   set radius 7
   ###   $hCanvas create oval [expr $xima-$radius] [expr $yima-$radius] [expr $xima+$radius] [expr $yima+$radius] \
   ###      -fill {} -outline red -width 2 -activewidth 3 -tag "tangente"
   ###}

   set coordMin [::confVisu::picture2Canvas $visuNo [lrange $cameraAxisCoord  0 1 ]]
   set coordMax [::confVisu::picture2Canvas $visuNo [lrange $cameraAxisCoord  2 3 ]]
   set coordList [list [lindex $coordMin 0] [lindex $coordMin 1] [lindex $coordMax 0]  [lindex $coordMax 1]   ]
   $hCanvas create line $coordList -fill orange -width 1 -dash {2 4} -offset center -tag tangente

   set coordMin [::confVisu::picture2Canvas $visuNo [lrange $referenceAxisCoord  0 1 ]]
   set coordMax [::confVisu::picture2Canvas $visuNo [lrange $referenceAxisCoord  2 3 ]]
   set coordList [list [lindex $coordMin 0] [lindex $coordMin 1] [lindex $coordMax 0]  [lindex $coordMax 1]   ]
   $hCanvas create line $coordList -fill orange -width 1 -offset center -tag tangente

   return
}

#------------------------------------------------------------
## @brief cette fonction est appellée par le zoomListener
#  et met à jour l'affichage de la tangente
#  @param visuNo numéro de la fenêtre de profil
#  @param args   arguments du listener
#
proc ::eshel::visu::showTangenteDrawListener { visuNo args } {
   variable private
   if { [info exists private($visuNo,tangenteList) ] } {
      ::eshel::visu::showTangenteDraw $visuNo $private($visuNo,tangenteList) $private($visuNo,cameraAxisCoord) $private($visuNo,referenceAxisCoord)
   }
}

#------------------------------------------------------------
## @brief masque le tracé de la tangente
#  @param visuNo numéro de la fenêtre de profil
#
proc ::eshel::visu::hideTangenteDraw { visuNo } {
   variable private

   ::confVisu::removeZoomListener $visuNo [list ::eshel::visu::showTangenteDraw $visuNo ]
   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete tangente
   return
}

#------------------------------------------------------------
## @brief affiche le marges
#  @param visuNo numéro de la fenêtre de profil
#
proc ::eshel::visu::showMargin { visuNo } {
   variable private


   if { [info exists private($visuNo,leftMarginId)] } {
      hideMargin $visuNo
   }

   #--- j'initialise l'utilitaire polydraw
   ::polydraw::init  $visuNo
   #--- j'interdis l'ajout d'item avec la souris
   ::polydraw::setMouseAddItem $visuNo 0
   #--- j'interdis l'ajout de noeud avec la souris
   ::polydraw::setMouseAddNode $visuNo 0
   #--- j'interdis le deplcement d'une ligne avec la souris
   ::polydraw::setMouseMoveLine $visuNo 0

   #--- j'intilaise les variables locales
   set private($visuNo,leftMarginId)                            ""
   set private($visuNo,rightMarginId)                           ""

   set fileName [::confVisu::getFileName $visuNo]
   set orderHduNum [::confVisu::getHduNo $visuNo "ORDERS"]
   set private($visuNo,fileName) $fileName
   set private($visuNo,orderHduNum) $orderHduNum
   set hFile ""
   set catchResult [catch {
      set hFile [fits open $fileName 0]
      #--- je recupere les parametres du spectre dans la table des ordres
      $hFile move $orderHduNum

      set nbOrder    [::eshel::file::getKeyword $hFile NAXIS2]
      set alpha      [::eshel::file::getKeyword $hFile ALPHA]
      set gamma      [::eshel::file::getKeyword $hFile GAMMA]
      set m          [::eshel::file::getKeyword $hFile M]
      set pixel      [::eshel::file::getKeyword $hFile PIXEL]
      set width      [::eshel::file::getKeyword $hFile WIDTH]
      set dx_ref     [::eshel::file::getKeyword $hFile DX_REF]
      set foclen     [::eshel::file::getKeyword $hFile FOCLEN]
      set min_order  [::eshel::file::getKeyword $hFile MIN_ORDER]
      set max_order  [::eshel::file::getKeyword $hFile MAX_ORDER]


      #--- position des marges dans l'image
      set private($visuNo,leftMarginList)  {0 }
      set private($visuNo,rightMarginList) {0 }
      set private($visuNo,orderListList) {0 }

      #--- position des marges dans le canvas
      set leftMarginCoordList {}
      set rightMarginCoordList {}

      #--- j'affiche un carre autour de chaque ligne
      for {set orderNum $min_order } { $orderNum <= $max_order } { incr orderNum } {
         set n [expr $orderNum - $min_order +1 ]
         set flag  [string trim [lindex [lindex [$hFile get table "FLAG" $n ] 0 ] 0]]
         if { $flag == 1 } {
            lappend private($visuNo,orderListList)  $n

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

            #--- coordonnées de la marge de gauche
            set x [string trim [lindex [lindex [$hFile get table "min_x" $n ] 0] 0]]
            set y [expr (((($p5 * $x + $p4) * $x + $p3) * $x + $p2) *$x + $p1) * $x + $p0 ]
            lappend private($visuNo,leftMarginList) [list $x $y ]
            set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
            lappend leftMarginCoordList [lindex $coord  0] [lindex $coord  1]

            set x [string trim [lindex [lindex [$hFile get table "max_x" $n ] 0] 0]]
            set y [expr (((($p5 * $x + $p4) * $x + $p3) * $x + $p2) *$x + $p1) * $x + $p0 ]

            lappend private($visuNo,rightMarginList) [list $x $y ]
            set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
            lappend rightMarginCoordList [lindex $coord  0] [lindex $coord  1]
         }
      }

      #--- je trace les marges
      #$hCanvas create line $leftMarginCoordList -fill yellow -width 1 -dash {2 4} \
      #   -offset center -tag marginLine
      #$hCanvas create line $rightMarginCoordList -fill yellow -width 1 -dash {2 4} \
      #   -offset center -tag marginLine
###console::disp "leftMarginCoordList=$leftMarginCoordList\n"
###console::disp "rightMarginCoordList=$rightMarginCoordList\n"
      set private($visuNo,leftMarginId) [::polydraw::createLine $visuNo \
         $leftMarginCoordList "::eshel::visu::moveLeftMargin $visuNo" ]
      set private($visuNo,rightMarginId) [::polydraw::createLine $visuNo \
         $rightMarginCoordList "::eshel::visu::moveRightMargin $visuNo" ]

   }]
   if { $hFile != "" } {
      $hFile close
   }

   if { $catchResult == 1 } {
      error $::errorInfo
   }
   return
}

#------------------------------------------------------------
## @brief affiche les marges
#  @param visuNo nuéro de la feneêtre de profil
#
proc ::eshel::visu::hideMargin { visuNo } {
   variable private
   ###console::disp "hideMargin\n"

   if { [info exists private($visuNo,leftMarginId)] } {
      ::polydraw::deleteItem $visuNo $private($visuNo,leftMarginId)
   }
   if { [info exists private($visuNo,leftMarginId)] } {
      ::polydraw::deleteItem $visuNo $private($visuNo,rightMarginId)
   }

   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete marginLine
   ::polydraw::close $visuNo

   array unset private $visuNo,*

   return 1
}

#------------------------------------------------------------
## @brief retourne les marges et le slant des ordres
#  @param visuNo nuémro de a visu
#  @return orderDefinition list [ order min_x max_x slant ]
#
proc ::eshel::visu::getOrderDefinition { visuNo } {
   variable private

   set fileName [::confVisu::getFileName $visuNo]
   set orderHduNum [::confVisu::getHduNo $visuNo "ORDERS"]
   set hFile ""
   set catchResult [catch {
      set hFile [fits open $fileName 0]
      #--- je recupere les parametres du spectre dans la table des ordres
      $hFile move $orderHduNum

      set min_order  [::eshel::file::getKeyword $hFile MIN_ORDER]
      set max_order  [::eshel::file::getKeyword $hFile MAX_ORDER]

      set orderDefinition {}
      #--- je recupere les marges et le slant des ordres
      for {set orderNum $min_order } { $orderNum <= $max_order } { incr orderNum } {
         set n [expr $orderNum - $min_order +1 ]
         set min_x [string trim [lindex [lindex [$hFile get table "min_x" $n ] 0] 0]]
         set max_x [string trim [lindex [lindex [$hFile get table "max_x" $n ] 0] 0]]
         set slant [string trim [lindex [lindex [$hFile get table "slant" $n ] 0] 0]]
         lappend orderDefinition [list $orderNum $min_x $max_x $slant]
      }
   }]
   if { $hFile != "" } {
      $hFile close
   }

   if { $catchResult == 1 } {
      error $::errorInfo
   }
   return $orderDefinition
}


#------------------------------------------------------------
## @brief affiche les marges
#  @param visuNo numéro de la fenêtre de profil
#  @param orderNo ??
#  @param x ??
#  @param y ??
#  @param dx ??
#  @param dy ??
#  @todo commenter les param
#
proc ::eshel::visu::moveLeftMargin { visuNo orderNo x y dx dy } {
   variable private

   ##console::disp "moveMargin orderNo=$orderNo x=$x y=$y dx=$dx dy=$dy\n"

   set hFile ""
   set catchResult [catch {
      set hFile [fits open $private($visuNo,fileName) 0]
      #--- je recupere les parametres du spectre dans la table des ordres
      $hFile move $private($visuNo,orderHduNum)

      set n  [lindex $private($visuNo,orderListList) $orderNo]
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

      #--- je calcule les coordonnees dans l'image
      set coord [::confVisu::canvas2Picture $visuNo [list [expr $x + $dx ] [expr $y + $dy ]] ]
      set x1 [lindex $coord 0]

      #--- je verifie que la marge de gauche reste a gauche de la marge de droite
      set xRight [lindex [lindex $private($visuNo,rightMarginList) $orderNo ] 0]
      if { ([ expr $xRight -$x1 ] > 5 || $dx < 0) && ($x1 > 5) } {
         set y1 [expr (((($p5 * $x1 + $p4) * $x1 + $p3) * $x1 + $p2) *$x1 + $p1) * $x1 + $p0 ]
         set private($visuNo,leftMarginList) [lreplace $private($visuNo,leftMarginList) $orderNo $orderNo [list $x1 $y1]]
         set coord1 [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
         set dy [expr [lindex $coord1 1] - $y]
         ##console::disp "moveMargin x1=$x1 xRight=$xRight dx=$dx\n"
      } else {
         ##console::disp "moveMargin orderNo=$orderNo dx=$dx dy=$dy\n"
         set dx 0
         set dy 0
      }

   }]
   if { $hFile != "" } {
      $hFile close
   }
   if { $catchResult == 1 } {
      error $::errorInfo
   }

   return [list $dx $dy]
}

#------------------------------------------------------------
## @brief affiche le marges
#  @param visuNo : numero de la fenêtre de profil
#  @param orderNo ??
#  @param x ??
#  @param y ??
#  @param dx ??
#  @param dy ??
#  @todo commenter les param
#
proc ::eshel::visu::moveRightMargin { visuNo orderNo x y dx dy } {
   variable private

   ##console::disp "moveMargin orderNo=$orderNo x=$x y=$y dx=$dx dy=$dy\n"

   set hFile ""
   set catchResult [catch {
      set hFile [fits open $private($visuNo,fileName) 0]
      #--- je recupere les parametres du spectre dans la table des ordres
      $hFile move $private($visuNo,orderHduNum)

      set n  [lindex $private($visuNo,orderListList) $orderNo]
      set width      [::eshel::file::getKeyword $hFile WIDTH]
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

      #--- je calcule les coordonnees dans l'image
      set coord [::confVisu::canvas2Picture $visuNo [list [expr $x + $dx ] [expr $y + $dy ]] ]
      set x1 [lindex $coord 0]

      #--- je verifie que la marge de droite reste a droite de la marge de gauche
      set xLeft [lindex [lindex $private($visuNo,leftMarginList) $orderNo ] 0]
      if { ([ expr $x1 - $xLeft] > 5 || $dx > 0)  && ($x1 < [expr $width - 5]) } {
         set y1 [expr (((($p5 * $x1 + $p4) * $x1 + $p3) * $x1 + $p2) *$x1 + $p1) * $x1 + $p0 ]
         set private($visuNo,rightMarginList) [lreplace $private($visuNo,rightMarginList) $orderNo $orderNo [list $x1 $y1]]
         set coord1 [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
         set dy [expr [lindex $coord1 1] - $y]
      } else {
         set dx 0
         set dy 0
      }

   }]
   if { $hFile != "" } {
      $hFile close
   }
   if { $catchResult == 1 } {
      error $::errorInfo
   }

   return [list $dx $dy]
}

#------------------------------------------------------------
## @brief masque le tracé des ordres
#  @param visuNo    numero de la fenetre de profil
#  @param imageLineList ??
#  @param catalogLineList ??
#  @param matchedLineList ??
#  @param referenceCoord  ??
#  @param args paramètres optionels (utilisés seulement par le listener)
#  @todo commenter les param
#
proc ::eshel::visu::showReferenceLine { visuNo imageLineList catalogLineList matchedLineList referenceCoord args} {
   variable private

   hideReferenceLine $visuNo

   set private($visuNo,imageLineList) $imageLineList
   set private($visuNo,catalogLineList) $catalogLineList
   set private($visuNo,matchedLineList) $matchedLineList
   set private($visuNo,referenceCoord) $referenceCoord

   #--- je cree le listener sur le zoom
   ::confVisu::addZoomListener $visuNo [list ::eshel::visu::showReferenceLineZoom $visuNo ]

   set hCanvas [::confVisu::getCanvas $visuNo]
   $hCanvas delete referenceline

   #--- j'affiche des cercles bleus autour des étoiles de l'image
   foreach coord $imageLineList {
      set xima  [lindex $coord 0]
      set yima  [lindex $coord 1]

      #--- je dessine des cercles autour des etoiles
      ###set radius 7
      ###$hCanvas create oval [expr $xima-$radius] [expr $yima-$radius] [expr $xima+$radius] [expr $yima+$radius] \
      ###   -fill {} -outline blue -width 2 -activewidth 3 -tag "referenceline"

      #--- je calcule les ccordonnees de la boite dans le buffer
      set wide_x 12
      set wide_y 12
      set x1 [expr int($xima) - $wide_x/2+ 1]
      set x2 [expr int($xima) + $wide_x/2+ 1]
      set y1 [expr int($yima) - $wide_y/2+ 1]
      set y2 [expr int($yima) + $wide_y/2+ 1]

      #--- je calcule les coordonnees dans le canvas
      set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
      set x1 [lindex $coord 0]
      set y1 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
      set x2 [lindex $coord 0]
      set y2 [lindex $coord 1]
      $hCanvas create rect [list $x1 $y1 $x2 $y2] -outline "#77FF77" -width 1 -offset center -tag "referenceline"
   }

    #--- j'affiche des cercles verts autour des étoiles du catalogue
   foreach coord $catalogLineList {
      set xcat  [lindex $coord 0]
      set ycat  [lindex $coord 1]

      #--- je dessine des cercles autour des etoiles
      ###set radius 7
      ###$hCanvas create oval [expr $xima-$radius] [expr $yima-$radius] [expr $xima+$radius] [expr $yima+$radius] \
      ###   -fill {} -outline green -width 2 -activewidth 3 -tag "referenceline "

      #--- je calcule les ccordonnees de la boite dans le buffer
      set wide_x 12
      set wide_y 12
      set x1 [expr int($xcat) - $wide_x/2+ 1]
      set x2 [expr int($xcat) + $wide_x/2+ 1]
      set y1 [expr int($ycat) - $wide_y/2+ 1]
      set y2 [expr int($ycat) + $wide_y/2+ 1]

      #--- je calcule les coordonnees dans le canvas
      set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
      set x1 [lindex $coord 0]
      set y1 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
      set x2 [lindex $coord 0]
      set y2 [lindex $coord 1]
      $hCanvas create rect [list $x1 $y1 $x2 $y2] -outline "#FF5522" -width 1 -offset center -tag "referenceline"
   }

   #--- je trace des traits rouges entre les étoiles appreillées
   foreach coord $matchedLineList {
      #--- je convertis en coordonnes picture
      set ximapic   [expr [lindex $coord 0] + 1]
      set yimapic   [expr [lindex $coord 1] + 1]
      set xobspic   [expr [lindex $coord 2] + 1]
      set yobspic   [expr [lindex $coord 3] + 1]

      set coord [::confVisu::picture2Canvas $visuNo [list $ximapic $yimapic ]]
      set ximacan  [lindex $coord 0]
      set yimacan  [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $xobspic $yobspic ]]
      set xobscan  [lindex $coord 0]
      set yobscan  [lindex $coord 1]

      $hCanvas create line $ximacan $yimacan $xobscan $yobscan -fill red -width 2 \
         -activewidth 3 -tag "referenceline "
   }

   if { [llength $referenceCoord] == 2 } {
      set xref  [lindex $referenceCoord 0]
      set yref  [lindex $referenceCoord 1]
      #--- je calcule les ccordonnees de la boite dans le buffer
      set wide_x 16
      set wide_y 16
      set x1 [expr int($xref) - $wide_x/2+ 1]
      set x2 [expr int($xref) + $wide_x/2+ 1]
      set y1 [expr int($yref) - $wide_y/2+ 1]
      set y2 [expr int($yref) + $wide_y/2+ 1]

      #--- je calcule les coordonnees dans le canvas
      set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
      set x1 [lindex $coord 0]
      set y1 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
      set x2 [lindex $coord 0]
      set y2 [lindex $coord 1]
      $hCanvas create rect [list $x1 $y1 $x2 $y2] -outline "#77FF77" -width 4 -offset center -tag "referenceline"
   }
   return
}

#------------------------------------------------------------
## @brief masque le tracé des ordres
#  @param visuNo numéro de la fenêtre de profil
#  @param args  parametres optionels (utilisés seulement par le listener)
#
proc ::eshel::visu::showReferenceLineZoom { visuNo args} {
   variable private

   showReferenceLine $visuNo $private($visuNo,imageLineList) \
      $private($visuNo,catalogLineList) \
      $private($visuNo,matchedLineList) \
      $private($visuNo,referenceCoord)

}

#------------------------------------------------------------
## @brief masque le tracé des ordres
#  @param visuNo numéro de la fenêtre de profil
#
proc ::eshel::visu::hideReferenceLine { visuNo } {
   variable private

   ::confVisu::removeZoomListener $visuNo [list ::eshel::visu::showReferenceLineZoom $visuNo]
   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete referenceline
   return
}


#------------------------------------------------------------
## @brief affiche les raies de calibration
#  @param visuNo numéro de la fenêtre de profil
#  @param args arguments du listener
#
proc ::eshel::visu::showCalibrationLine { visuNo args } {
   variable private

   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete calibrationLine

   #--- je cree le listener sur le zoom
   ::confVisu::addZoomListener $visuNo [list ::eshel::visu::showCalibrationLine $visuNo ]

   set fileName [::confVisu::getFileName $visuNo]
   set orderHduNum [::confVisu::getHduNo $visuNo "ORDERS"]
   set lineGapHduNum [::confVisu::getHduNo $visuNo "LINEGAP"]

   set hFile ""
   set catchResult [catch {
      set hFile [fits open $fileName 0]
      #--- je recupere les parametres du spectre dans la table des ordres
      $hFile move $orderHduNum

      set nbOrder    [::eshel::file::getKeyword $hFile NAXIS2]
      set alpha      [::eshel::file::getKeyword $hFile ALPHA]
      set gamma      [::eshel::file::getKeyword $hFile GAMMA]
      set m          [::eshel::file::getKeyword $hFile M]
      set pixel      [::eshel::file::getKeyword $hFile PIXEL]
      set width      [::eshel::file::getKeyword $hFile WIDTH]
      set dx_ref     [::eshel::file::getKeyword $hFile DX_REF]
      set foclen     [::eshel::file::getKeyword $hFile FOCLEN]
      set min_order  [::eshel::file::getKeyword $hFile MIN_ORDER]

      set PI      [expr acos(-1)]
      set alpha   [expr $alpha*$PI/180.0]
      set gamma   [expr $gamma*$PI/180.0]
      set xc      [expr $width / 2 ]

      #--- je recupere la taille de la boite de rechercher wide_x , wide_y
      ###$hFile move $orderHduNum
      ###set wide_x [lindex [lindex [$hFile get table "wide_x" 1 ] 0] 0]
      ###set wide_y [lindex [lindex [$hFile get table "wide_y" 1 ] 0] 0]
      set wide_x 12
      set wide_y 12
      #--- je recupere la liste des raies de calibration
      $hFile move $lineGapHduNum
      set nbLine    [::eshel::file::getKeyword $hFile NAXIS2]

      #--- j'affiche un carre autour de chaque ligne
      $hCanvas delete calibrationLine
      for {set i 1 } { $i <= $nbLine } { incr i } {
         #--- je pointe la table des raies de calibration
         $hFile move $lineGapHduNum
         set orderNum [lindex [lindex [$hFile get table "order" $i ] 0] 0]
         set validLine [lindex [lindex [$hFile get table "valid" $i ] 0] 0]
         set lambda [lindex [lindex [$hFile get table "lambda_obs" $i ] 0] 0]

         if  { $validLine == 1 || $validLine == 2 } {
            #--- je recupere l'abcisse x
            set x [lindex [lindex [$hFile get table  "lambda_calc" $i ] 0] 0]
            $hFile move $orderHduNum
            set n [expr $orderNum - $min_order +1 ]
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
            #--- je calcule les coordonnees de la boite dans le buffer
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

            if { $validLine == 1 } {
               set dash  ""
            } else {
               set dash  "2 4"
            }
            $hCanvas create rect [list $x1 $y1 $x2 $y2] -outline "#FF5522" -width 1  -dash $dash -offset center -tag "calibrationLine $lambda"
         }

         #--- j'affiche un carre vert autour des positions observees des raies
         if  { $validLine == 1 || $validLine == 3 } {
            $hFile move $lineGapHduNum
            set x [lindex [lindex [$hFile get table "lambda_posx" $i ] 0] 0]
            set y [lindex [lindex [$hFile get table "lambda_posy" $i ] 0] 0]

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
            $hCanvas create rect [list $x1 $y1 $x2 $y2] -outline "#77FF77" -width 1 -activewidth 2 -fill {} -dash $dash -offset center -tag "calibrationLine balloonline "
         }
      }
   } ]
   if { $hFile != "" } {
      $hFile close
   }
   if { $catchResult == 1 } {
      error $::errorInfo
   }

}


#------------------------------------------------------------
## @brief masque le tracé des ordres
#  @param visuNo numéro de la fenêtre de profil
#
proc ::eshel::visu::hideCalibrationLine { visuNo } {
   variable private

   ::confVisu::removeZoomListener $visuNo [list ::eshel::visu::showCalibrationLine $visuNo]
   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete calibrationLine
   return
}

#------------------------------------------------------------
## @brief affiche les marges d'aboutement
#  @param visuNo numéro de la fenêtre de profil
#  @param joinMarginWidth largeur de la marge d'aboutement (en angstrom)
#  @return joinMarginList liste des limites { { orderNUm previousJoinMinLambda nextJoinMaxLambda } {...} }
#
proc ::eshel::visu::showJoinMargin { visuNo joinMarginWidth} {
   variable private

   set private($visuNo,joinMarginWidth) $joinMarginWidth

   #--- je cree le listener sur le zoom
   ::confVisu::addZoomListener $visuNo [list ::eshel::visu::showJoinMarginListener $visuNo ]

   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete joinmargin
   set fileName [::confVisu::getFileName $visuNo]
   set orderHduNum [::confVisu::getHduNo $visuNo "ORDERS"]

   #--- je pointe la table des ordres
   set hFile ""
   set catchResult [catch {
      set hFile [fits open $fileName 0]
      $hFile move $orderHduNum
      #--- je recupere les parametres de l'image
      set width      [::eshel::file::getKeyword $hFile WIDTH]
      set nbOrder    [::eshel::file::getKeyword $hFile NAXIS2]
      set alpha      [::eshel::file::getKeyword $hFile ALPHA]
      set gamma      [::eshel::file::getKeyword $hFile GAMMA]
      set m          [::eshel::file::getKeyword $hFile M]
      set pixel      [::eshel::file::getKeyword $hFile PIXEL]
      set width      [::eshel::file::getKeyword $hFile WIDTH]
      set dx_ref     [::eshel::file::getKeyword $hFile DX_REF]
      set foclen     [::eshel::file::getKeyword $hFile FOCLEN]
      set min_order  [::eshel::file::getKeyword $hFile MIN_ORDER]
      set max_order  [::eshel::file::getKeyword $hFile MAX_ORDER]

      set PI      [expr acos(-1)]
      set alpha   [expr $alpha*$PI/180.0]
      set gamma   [expr $gamma*$PI/180.0]
      set xc      [expr $width / 2 ]
      set previousMinLambda 0
      set previousJoinMinMargin { }
      set previousJoinMaxMargin { }
      set nextJoinMinMargin { }
      set nextJoinMaxMargin { }

      set cropLamba [list]

      for {set orderNum $min_order } { $orderNum <= $max_order } { incr orderNum } {
         set lineNo [expr $orderNum - $min_order +1 ]
         set flag [string trim [lindex [lindex [$hFile get table "flag" $lineNo ] 0 ] 0]]
         if { $flag != 1 } {
            #--- j'ignore les ordres qui n'ont pas flag=1
            continue
         }
         set minX [string trim [lindex [lindex [$hFile get table "min_x" $lineNo ] 0 ] 0]]
         set maxX [string trim [lindex [lindex [$hFile get table "max_x" $lineNo ] 0 ] 0]]
         set p0 [string trim [lindex [lindex [$hFile get table "P0" $lineNo ] 0 ] 0]]
         set p1 [string trim [lindex [lindex [$hFile get table "P1" $lineNo ] 0 ] 0]]
         set p2 [string trim [lindex [lindex [$hFile get table "P2" $lineNo ] 0 ] 0]]
         set p3 [string trim [lindex [lindex [$hFile get table "P3" $lineNo ] 0 ] 0]]
         set p4 [string trim [lindex [lindex [$hFile get table "P4" $lineNo ] 0 ] 0]]
         #--- je calcule le polynome d'ordre 5 (ou d'ordre 4 pour l'ancienne version)
         set p5NotFound [catch {
            set p5 [string trim [lindex [lindex [$hFile get table "P5" $lineNo ] 0 ] 0]]
         }]
         if { $p5NotFound != 0 } {
            set p5 0
         }

         #--- je calcule le recouvrement avec l'ordre precedent (vers le rouge)
         if { $orderNum > $min_order } {
            #--- je calcule l'abcisse previousMinX de l'ordre précédent
            set beta [expr asin(($orderNum*$m*$previousMinLambda/10000000.0 - cos($gamma) * sin($alpha))/cos($gamma))]
            set beta2 [expr $beta - $alpha]
            set previousMinX [expr $foclen * $beta2 / $pixel + $xc + $dx_ref]

            #--- je calcule la longueur d'onde maxLambda de l'ordre courant
            set beta2 [expr ( $maxX - $xc - $dx_ref) * $pixel / $foclen]
            set beta  [expr $beta2 + $alpha]
            set maxLambda [expr 10000000.0 * cos($gamma) * (sin($alpha) + sin($beta))/ $orderNum / $m ]

            if { $maxLambda  > $previousMinLambda  } {
               if { [expr  $maxLambda - $previousMinLambda  ]  > $private($visuNo,joinMarginWidth) } {
                  set previousJoinMinLambda [expr ($maxLambda + $previousMinLambda) / 2.0 - $private($visuNo,joinMarginWidth) /2.0 ]
                  set previousJoinMaxLambda [expr ($maxLambda + $previousMinLambda) / 2.0 + $private($visuNo,joinMarginWidth) /2.0 ]
               } else {
                  set previousJoinMinLambda $previousMinLambda
                  set previousJoinMaxLambda $maxLambda
               }

               #--- je calcule les abscisses des deux marges d'aboutement avec l'ordre precedent
               set beta [expr asin(($orderNum*$m*$previousJoinMinLambda/10000000.0 - cos($gamma) * sin($alpha))/cos($gamma))]
               set beta2 [expr $beta - $alpha]
               set x [expr $foclen * $beta2 / $pixel + $xc + $dx_ref]
               set y [expr (((($p5 * $x + $p4) * $x + $p3) * $x + $p2) *$x + $p1) * $x + $p0 ]
               set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
               lappend previousJoinMinMargin [lindex $coord 0] [lindex $coord 1]

               set beta [expr asin(($orderNum*$m*$previousJoinMaxLambda/10000000.0 - cos($gamma) * sin($alpha))/cos($gamma))]
               set beta2 [expr $beta - $alpha]
               set x [expr $foclen * $beta2 / $pixel + $xc + $dx_ref]
               set y [expr (((($p5 * $x + $p4) * $x + $p3) * $x + $p2) *$x + $p1) * $x + $p0 ]
               set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
               lappend previousJoinMaxMargin [lindex $coord 0] [lindex $coord 1]
            } else {
               #--- je selectionne la marge droite maxi
               set previousMinX $width

               #--- je calcule les marges d'aboutement egales au à la limite max de l'ordre
               set beta2 [expr ( $maxX - $xc - $dx_ref) * $pixel / $foclen]
               set beta  [expr $beta2 + $alpha]
               set previousJoinMinLambda  [expr 10000000.0 * cos($gamma) * (sin($alpha) + sin($beta))/ $orderNum / $m ]
               set previousJoinMaxLambda $previousJoinMinLambda

               #lappend nextJoinMaxMargin $maxX $maxX
            }

         } else {
            #--- je selectionne la marge droite maxi
            set previousMinX $width

            #--- je calcule les marges d'aboutement egales au à la limite max de l'ordre
            set beta2 [expr ( $maxX - $xc - $dx_ref) * $pixel / $foclen]
            set beta  [expr $beta2 + $alpha]
            set previousJoinMinLambda  [expr 10000000.0 * cos($gamma) * (sin($alpha) + sin($beta))/ $orderNum / $m ]
            set previousJoinMaxLambda $previousJoinMinLambda

            #lappend nextJoinMaxMargin $maxX $maxX
         }

         #--- je calcule l'abcisse de l'ordre suivant
         if { $orderNum < $max_order } {
            #--- je calcule l'abcisse nextMaxX de l'ordre suivant sur l'ordre courant
            set nextMaxX [string trim [lindex [lindex [$hFile get table "max_x" [expr $lineNo +1] ] 0 ] 0]]
            set beta2 [expr ( $nextMaxX - $xc - $dx_ref) * $pixel / $foclen]
            set beta  [expr $beta2 + $alpha]
            set nextMaxLambda [expr 10000000.0 * cos($gamma) * (sin($alpha) + sin($beta))/ [expr $orderNum + 1] / $m ]
            set beta [expr asin(($orderNum *$m*$nextMaxLambda/10000000.0 - cos($gamma) * sin($alpha))/cos($gamma))]
            set beta2 [expr $beta - $alpha]
            set nextMaxX [expr $foclen * $beta2 / $pixel + $xc + $dx_ref]

            #--- je calcule la longueur d'onde minLambda de l'ordre courant
            set beta2 [expr ( $minX - $xc - $dx_ref) * $pixel / $foclen]
            set beta  [expr $beta2 + $alpha]
            set minLambda [expr 10000000.0 * cos($gamma) * (sin($alpha) + sin($beta))/ $orderNum / $m ]

            if { $nextMaxLambda  > $minLambda  } {
               if { [expr  $nextMaxLambda - $minLambda  ]  > $private($visuNo,joinMarginWidth) } {
                  set nextJoinMinLambda [expr ($nextMaxLambda + $minLambda) / 2.0 - $private($visuNo,joinMarginWidth) /2.0 ]
                  set nextJoinMaxLambda [expr ($nextMaxLambda + $minLambda) / 2.0 + $private($visuNo,joinMarginWidth) /2.0 ]
               } else {
                  set nextJoinMinLambda $minLambda
                  set nextJoinMaxLambda $nextMaxLambda
               }

               #--- je calcule les deux marges d'aboutement avec l'odre precedent
               set beta [expr asin(($orderNum*$m*$nextJoinMinLambda/10000000.0 - cos($gamma) * sin($alpha))/cos($gamma))]
               set beta2 [expr $beta - $alpha]
               set x [expr $foclen * $beta2 / $pixel + $xc + $dx_ref]
               set y [expr (((($p5 * $x + $p4) * $x + $p3) * $x + $p2) *$x + $p1) * $x + $p0 ]
               set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
               lappend nextJoinMinMargin [lindex $coord 0] [lindex $coord 1]

               set beta [expr asin(($orderNum*$m*$nextJoinMaxLambda/10000000.0 - cos($gamma) * sin($alpha))/cos($gamma))]
               set beta2 [expr $beta - $alpha]
               set x [expr $foclen * $beta2 / $pixel + $xc + $dx_ref]
               set y [expr (((($p5 * $x + $p4) * $x + $p3) * $x + $p2) *$x + $p1) * $x + $p0 ]
               set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
               lappend nextJoinMaxMargin [lindex $coord 0] [lindex $coord 1]
            } else {
               set nextMaxX 0

               #--- je calcule les marges d'aboutement egales au à la limite min de l'ordre
               set beta2 [expr ( $minX - $xc - $dx_ref) * $pixel / $foclen]
               set beta  [expr $beta2 + $alpha]
               set nextJoinMinLambda  [expr 10000000.0 * cos($gamma) * (sin($alpha) + sin($beta))/ $orderNum / $m ]
               set nextJoinMaxLambda $nextJoinMinLambda

               #lappend nextJoinMaxMargin $minX $minX
            }

         } else {
            set nextMaxX 0

            #--- je calcule les marges d'aboutement egales au à la limite min de l'ordre
            set beta2 [expr ( $minX - $xc - $dx_ref) * $pixel / $foclen]
            set beta  [expr $beta2 + $alpha]
            set nextJoinMinLambda  [expr 10000000.0 * cos($gamma) * (sin($alpha) + sin($beta))/ $orderNum / $m ]
            set nextJoinMaxLambda $nextJoinMinLambda

            #lappend nextJoinMaxMargin $minX $minX
         }

         ###set coordlist {}
         set previousCoordList {}
         set nextCoordList {}
         for { set x $minX } { $x < $maxX } { incr x } {
            #--- je calcule l'ordonnee y
            set y [expr (((($p5 * $x + $p4) * $x + $p3) * $x + $p2) *$x + $p1) * $x + $p0 ]
            ###set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
            ###lappend coordlist [lindex $coord 0] [lindex $coord 1]
            if { $x >= $previousMinX } {
               set coord [::confVisu::picture2Canvas $visuNo [list $x [expr $y +5] ]]
               lappend previousCoordList [lindex $coord 0] [lindex $coord 1]
            }
            if { $x <= $nextMaxX } {
               set coord [::confVisu::picture2Canvas $visuNo [list $x [expr $y -5] ]]
               lappend nextCoordList [lindex $coord 0] [lindex $coord 1]
            }
         }

         if { [expr $orderNum % 2] == 0 } {
             set prevColor orange
             set nextColor cyan
         } else {
             set prevColor cyan
             set nextColor orange
         }
         set dash  "2 4"

         ###$hCanvas create line $coordlist -fill green -width 2 -offset center -tag orderLine
         if { [llength $previousCoordList ] > 0 } {
            $hCanvas create line $previousCoordList -fill $prevColor -width 2 -dash $dash -offset center -tag joinmargin
         }
         if { [llength $nextCoordList ] > 0 } {
            $hCanvas create line $nextCoordList -fill $nextColor -width 2 -dash $dash -offset center -tag joinmargin
         }
         ##$hCanvas lower joinmargin calibrationLine

         #--- je calcule la longueur d'onde previousMinLambda correspondant a minX
         set beta2 [expr ( $minX -$xc - $dx_ref) * $pixel / $foclen]
         set beta  [expr $beta2 + $alpha]
         set previousMinLambda [expr 10000000.0 * cos($gamma) * (sin($alpha) + sin($beta))/ $orderNum / $m ]


         #--- j'ajoute les limites d'aboutement de cet ordre dans la liste
         lappend cropLamba [list $orderNum $nextJoinMinLambda $previousJoinMaxLambda ]

      } ; # for orderNum

      if { [llength $previousJoinMinMargin ] > 0 } {
         $hCanvas create line $previousJoinMinMargin -fill yellow -width 2 -dash "2 4" -offset center -tag joinmargin
      }
      if { [llength $previousJoinMaxMargin ] > 0 } {
         $hCanvas create line $previousJoinMaxMargin -fill yellow -width 2 -dash "2 4" -offset center -tag joinmargin
      }
      if { [llength $nextJoinMinMargin ] > 0 } {
         $hCanvas create line $nextJoinMinMargin -fill yellow -width 2 -dash "2 4" -offset center -tag joinmargin
      }
      if { [llength $nextJoinMaxMargin ] > 0 } {
         $hCanvas create line $nextJoinMaxMargin -fill yellow -width 2 -dash "2 4" -offset center -tag joinmargin
      }
   }]
   if { $hFile != "" } {
      $hFile close
   }
   if { $catchResult == 1 } {
      error $::errorInfo
   }

   return $cropLamba
}

#------------------------------------------------------------
## @brief ??
#  @param visuNo numéro de la fenêtre de profil
#  @param args paramètres optionels (utilisés seulement pas le listener)
#  @todo commenter le brief
proc ::eshel::visu::showJoinMarginListener { visuNo args} {
   variable private

   showJoinMargin $visuNo $private($visuNo,joinMarginWidth)

}


#------------------------------------------------------------
## @brief masque le tracé des ordres
#  @param visuNo numéro de la fenêtre de profil
#
proc ::eshel::visu::hideJoinMargin { visuNo } {
   variable private

   ::confVisu::removeZoomListener $visuNo [list ::eshel::visu::showJoinMargin $visuNo]
   set hCanvas [confVisu::getCanvas $visuNo]
   $hCanvas delete joinmargin
   return
}


#------------------------------------------------------------
## @brief retourne minOrder et maxOrder
#  @param visuNo numéro de la fenêtre de profil
#
proc ::eshel::visu::getValidOrder { visuNo } {
   variable private

   set fileName [::confVisu::getFileName $visuNo]
   set orderHduNum [::confVisu::getHduNo $visuNo "ORDERS"]

   set hFile ""
   set catchResult [catch {
      set hFile [fits open $fileName 0]
      $hFile move $orderHduNum
      set min_order  [::eshel::file::getKeyword $hFile MIN_ORDER]
      set max_order  [::eshel::file::getKeyword $hFile MAX_ORDER]
   }]

   if { $hFile != "" } {
      $hFile close
   }

   if { $catchResult == 1 } {
      error $::errorInfo
   }

   return [list $min_order $max_order]

}







