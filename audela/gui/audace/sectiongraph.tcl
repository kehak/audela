#
## @file sectiongraph.tcl
#  @brief Affiche une coupe de l'image
#  @author Michel PUJOL
#  @namespace sectiongraph
#  @brief Affiche une coupe de l'image
#  $Id: sectiongraph.tcl 13704 2016-04-14 19:18:52Z rzachantke $
#

namespace eval ::sectiongraph {
}

#------------------------------------------------------------
#  brief initialise le graphe
#  param visuNo numéro de visu
#
proc ::sectiongraph::init { visuNo } {
   variable private
   global conf

   if { [ buf[::confVisu::getBufNo $visuNo] imageready] == "0" } {
      return
   }

   #--- Initialisation de variables
   ::sectiongraph::initConf $visuNo

   #--- je verifie si la variable existe
   if { [info exists private($visuNo,This)] } {
      wm withdraw $private($visuNo,This)
      wm deiconify $private($visuNo,This)
      focus $private($visuNo,This)
      return
   }

   #--- j'initalise les variables de travail
   uplevel #0 blt::vector create sectiongraphX$visuNo sectiongraphYR$visuNo sectiongraphYG$visuNo sectiongraphYB$visuNo -watchunset 1
   #::blt::vector create sectiongraphX$visuNo sectiongraphYR$visuNo sectiongraphYG$visuNo sectiongraphYB$visuNo
   ::polydraw::init $visuNo
   #--- j'interdis l'ajout d'item et de nodes avec la souris
   ::polydraw::setMouseAddItem $visuNo "0"
   ::polydraw::setMouseAddNode $visuNo "0"
   #--- je dessine la ligne de coupe au centre du canvas
   set canvasCenter [::confVisu::getCanvasCenter $visuNo ]
   set x1 [expr [lindex $canvasCenter 0 ] - 20 ]
   set x2 [expr [lindex $canvasCenter 0 ] + 20 ]
   set y [lindex $canvasCenter 1 ]
   set private($visuNo,itemNo) [::polydraw::createLine $visuNo [list $x1 $y $x2 $y ] ]
   #--- je cree la fenetre contenant le graphe
   ::sectiongraph::createToplevel $visuNo
   #--- j'active le rafraichissement automatique sur deplacement de la ligne de coupe
   ::polydraw::addMoveItemListener $visuNo $private($visuNo,itemNo) "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Répertoires"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(sectiongraph,$visuNo,position) définit la position de la fenêtre
#  - conf(sectiongraph,$visuNo,modeRefresh) mode de rafraichissement
#  @param visuNo numéro de la visu
#
proc ::sectiongraph::initConf { visuNo } {
   global conf

   if { ! [ info exists conf(sectiongraph,$visuNo,position) ] }    { set conf(sectiongraph,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(sectiongraph,$visuNo,modeRefresh) ] } { set conf(sectiongraph,$visuNo,modeRefresh) "0" }

}

#------------------------------------------------------------
#  brief configure le bouton pour le rafraichissement
#  param visuNo numéro de visu
#  param args valeurs fournies par le gestionnaire de listener
#
proc ::sectiongraph::configureSectionGraph { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(sectiongraph,$visuNo,modeRefresh) == "0" } {
      $private($visuNo,This).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique
      ::confVisu::removeFileNameListener $visuNo "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"
   } else {
      $private($visuNo,This).frame2.butRefresh configure -state disabled
      #--- je declare le rafraichissement automatique au changement d'image
      ::confVisu::addFileNameListener $visuNo "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"
   }
}

#------------------------------------------------------------
## @brief mise à jour du graphe
#  @param visuNo numéro de visu
#  @param itemNo
#  @param args valeurs fournies par le gestionnaire de listener
#
proc ::sectiongraph::refresh { visuNo itemNo args } {
   variable private

   #--- je recupere les coordonnees de la ligne de coupe
   set box [::polydraw::getCoords $visuNo $itemNo]

   #--- je convertis en coordonnees image
   set pointA [::confVisu::canvas2Picture $visuNo [lrange $box 0 1]]
   set pointZ [::confVisu::canvas2Picture $visuNo [lrange $box 2 3]]
   set x1 [lindex $pointA 0]
   set y1 [lindex $pointA 1]
   set x2 [lindex $pointZ 0]
   set y2 [lindex $pointZ 1]

   #--- je redresse gauche/droite
   if { $x1 > $x2 } {
      set x  $x1
      set x1 $x2
      set x2 $x
   }

   #--- je redresse haut/bas
   if { $y1 > $y2 } {
      set y  $y1
      set y1 $y2
      set y2 $y
   }

   set bufNo     [::confVisu::getBufNo $visuNo]
   set lx        [list ]
   set lyR       [list ]
   set lyG       [list ]
   set lyB       [list ]
   set xDiff     [expr {$x2 - $x1}]
   set yDiff     [expr {$y2 - $y1}]
   #--- je calcule l'hypothenuse et ses ratios horizontaux et verticaux (=echelle de graduation en pixel)
   set numPixels [expr {hypot($xDiff,$yDiff)}]
   if { $numPixels != 0 } {
      set xRatio [expr {$xDiff / $numPixels}]
      set yRatio [expr {$yDiff / $numPixels}]
   } else {
      set xRatio 1
      set yRatio 1
   }
   set width     [buf$bufNo getpixelswidth]
   set height    [buf$bufNo getpixelsheight]

   if { [buf$bufNo getnaxis] == 1 } {
      set height [visu$visuNo thickness]
   }

   if { $width > 0 && $height > 0 } {
      #--- je teste la valeur d'un point pour connaitre le nombre de plan de couleur
      set nbcolor($visuNo) [lindex [buf$bufNo getpix [list 1 1 ] ] 0]
   } else {
      #--- si l'image est vide je considere qu'il n'y a qu'un plan
      set nbcolor($visuNo) 1
   }

   #--- je copie l'intensite des points de la ligne de coupe dans les vecteurs du graphe
   for {set p 0} {$p < $numPixels} {incr p} {
      set x [expr {round($xRatio * $p) + $x1}]
      set y [expr {round($yRatio * $p) + $y1}]
      lappend lx $p
      if { ($x>0) && ($x<=$width) && ($y>0) && ($y<=$height) } {
         lappend lyR [lindex [buf$bufNo getpix [list $x $y ] ] 1]
         if { $nbcolor($visuNo) == 3 } {
            lappend lyG [lindex [buf$bufNo getpix [list $x $y ] ] 2]
            lappend lyB [lindex [buf$bufNo getpix [list $x $y ] ] 3]
         }
      } else {
         #--- si le point est hors de l'image, j'affecte la valeur 0
         lappend lyR 0
         if { $nbcolor($visuNo) == 3 } {
            lappend lyG 0
            lappend lyB 0
         }
      }
   }

   #--- j'affiche le graphe
   sectiongraphX$visuNo set $lx
   if { $nbcolor($visuNo) == 1 } {
      sectiongraphYR$visuNo set $lyR
      #--- j'affiche une courbe monochrome
      $private($visuNo,graph,horz) element configure lineMono -hide no
      #--- je masque les trois autres courbes
      $private($visuNo,graph,horz) element configure color_invariant_lineR -hide yes
      $private($visuNo,graph,horz) element configure color_invariant_lineG -hide yes
      $private($visuNo,graph,horz) element configure color_invariant_lineB -hide yes
   } else {
      sectiongraphYR$visuNo set $lyR
      sectiongraphYG$visuNo set $lyG
      sectiongraphYB$visuNo set $lyB
      #--- j'affiche trois courbes, une rouge, une verte et une bleue
      $private($visuNo,graph,horz) element configure color_invariant_lineR -hide no
      $private($visuNo,graph,horz) element configure color_invariant_lineG -hide no
      $private($visuNo,graph,horz) element configure color_invariant_lineB -hide no
      #--- je masque la courbe monochrome
      $private($visuNo,graph,horz) element configure lineMono -hide yes
   }

   refreshValues $visuNo $nbcolor($visuNo)

}

#------------------------------------------------------------
#  brief calcule la moyenne, la médiane et le sigma
#  param viuNo numéro de la visu
#  param nbColor nb de couleurs
#
proc ::sectiongraph::refreshValues { visuNo nbColor } {
   variable private
   global caption

   #--   raccourci
   set wid $private($visuNo,This).frame3

   if {$nbColor == 3} {
      foreach c [list r g b] color [list R G B] {
         lassign [getMeanMedianSigma sectiongraphY${color}$visuNo] mean median sigma
         ${wid}.$c configure -text [format $caption(sectiongraph,values) $mean $median $sigma]
         pack ${wid}.$c -anchor w -side top -padx 3 -pady 3
      }
      pack forget ${wid}.m
   } else {
      lassign [getMeanMedianSigma sectiongraphYR$visuNo] mean median sigma
      ${wid}.m configure -text [format $caption(sectiongraph,values) $mean $median $sigma]
      pack ${wid}.m -anchor w -side top -padx 3 -pady 3
      pack forget ${wid}.r
      pack forget ${wid}.g
      pack forget ${wid}.b
  }
}


#------------------------------------------------------------
#  brief calcule la moyenne, la médiane et le sigma
#  param vector nom du vecteur graphique à évaluer
#  return liste de la moyenne, de la médiane et du sigma
#
proc ::sectiongraph::getMeanMedianSigma { vector } {

   blt::vector create tempor result -watchunset 1
   $vector dup tempor
   set moyenne [format "%.1f" $tempor(mean)]
   result expr { median(tempor) }
   set mediane [format "%.1f" $result(0)]
   result expr { sdev(tempor) }
   set sigma [format "%.1f" $result(0)]
   blt::vector destroy tempor result

   return [list $moyenne $mediane $sigma]
}

#------------------------------------------------------------
#  brief créé la fenêtre
#
proc ::sectiongraph::createToplevel { visuNo } {
   variable private
   global caption conf

   set base [ ::confVisu::getBase $visuNo ]
   set This "$base.sectiongraph"
   set private($visuNo,This) $This
   set width 400
   set height 200

   #--- je verifie si la fenetre existe deja
   if { [winfo exists $This] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Creation de la fenetre
   toplevel $This
   wm transient $This $base
   wm resizable $This 0 0
   wm title $This "$caption(sectiongraph,title) (visu$visuNo)"
   wm geometry $This $conf(sectiongraph,$visuNo,position)
   wm protocol $This WM_DELETE_WINDOW "::sectiongraph::closeToplevel $visuNo"

   #--- Creation d'une frame
   frame $private($visuNo,This).frame1 -borderwidth 2 -relief raised
   pack $private($visuNo,This).frame1 -side top -fill both -expand 1

   #--- graphe de la coupe
   #  remarque : les couleurs sont configurée par ::confColor::applyColo
   set private($visuNo,graph,horz) [blt::graph $This.horz \
         -title "" \
         -width $width -height $height \
         -takefocus 0 \
         -bd 0 -relief flat \
         -rightmargin 1 -leftmargin 60 \
         -topmargin 1 -bottommargin 25 \
         -plotborderwidth 2 -plotrelief groove \
         -plotpadx 0 -plotpady 0
      ]

   #--- courbe monochrome (associee au vecteur R)
   $private($visuNo,graph,horz) element create lineMono \
      -xdata sectiongraphX$visuNo -ydata sectiongraphYR$visuNo -color $::audace(color,textColor) -symbol ""
   #--- courbes R G B
   $private($visuNo,graph,horz) element create color_invariant_lineR \
      -xdata sectiongraphX$visuNo -ydata sectiongraphYR$visuNo -color red -symbol ""
   $private($visuNo,graph,horz) element create color_invariant_lineG \
      -xdata sectiongraphX$visuNo -ydata sectiongraphYG$visuNo -color green -symbol ""
   $private($visuNo,graph,horz) element create color_invariant_lineB \
      -xdata sectiongraphX$visuNo -ydata sectiongraphYB$visuNo -color blue -symbol ""
   $private($visuNo,graph,horz) legend configure -hide yes
   $private($visuNo,graph,horz) axis configure x -min 0
   $private($visuNo,graph,horz) xaxis configure -title "" -hide no -ticklength 4
   $private($visuNo,graph,horz) x2axis configure -title "" -hide yes
   $private($visuNo,graph,horz) yaxis configure -title "" -hide no -ticklength 4
   $private($visuNo,graph,horz) y2axis configure -title "" -hide yes
   $private($visuNo,graph,horz) grid configure -mapy y -dashes ""
   $private($visuNo,graph,horz) crosshairs on
   $private($visuNo,graph,horz) crosshairs configure -color green
   $private($visuNo,graph,horz) element configure color_invariant_lineR -hide no

   pack $private($visuNo,graph,horz) -in $private($visuNo,This).frame1

   #--   raccourci
   set wid $private($visuNo,This).frame3
   frame $wid -borderwidth 2 -relief raised
      foreach f [list m r g b] color [list black red green blue] {
         set pixels [list [lrepeat 10 $color]]
         set photo [image create photo]
         $photo put $pixels
         button $wid.$f -compound left -image $photo -relief flat \
            -text [format $caption(sectiongraph,values) - - -]
         pack $wid.$f -anchor w -side top -padx 3 -pady 3
      }
   pack $private($visuNo,This).frame3 -after $private($visuNo,This).frame1 -fill both -expand 1

   #--- Creation d'une frame
   frame $private($visuNo,This).frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $private($visuNo,This).frame2.modeRefresh -text "$caption(sectiongraph,refreshAuto)" \
         -variable conf(sectiongraph,$visuNo,modeRefresh) -command "::sectiongraph::configureSectionGraph $visuNo"
      pack $private($visuNo,This).frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir la coupe
      button $private($visuNo,This).frame2.butRefresh -text "$caption(sectiongraph,refreshManuel)" \
         -command "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"
      pack $private($visuNo,This).frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $private($visuNo,This).frame2 -side top -fill both -expand 1

   #--- Rafraichir le graphe
   ::sectiongraph::refresh $visuNo $private($visuNo,itemNo)

   #--- Rafraichir la fenetre
   ::sectiongraph::configureSectionGraph $visuNo

   #--- La fenetre est active
   focus $private($visuNo,This)

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $private($visuNo,This) <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private($visuNo,This)
}

#------------------------------------------------------------
## @brief ferme la fenêtre et libère les ressources associées
#  @param visuNo numéro de la visu
#
proc ::sectiongraph::closeToplevel { visuNo } {
   variable private
   global conf

   if { [info exists private($visuNo,itemNo)] } {
      #--- je supprime les listeners
      ::polydraw::removeMoveItemListener $visuNo $private($visuNo,itemNo) "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"
      ::confVisu::removeFileNameListener $visuNo "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"

      ::polydraw::deleteItem $visuNo $private($visuNo,itemNo)
      ::polydraw::close $visuNo
      blt::vector destroy sectiongraphX$visuNo sectiongraphYR$visuNo sectiongraphYG$visuNo sectiongraphYB$visuNo

      #--- je determine la position de la fenetre
      set geometry [ wm geometry $private($visuNo,This) ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(sectiongraph,$visuNo,position) "+[ string range $geometry $deb $fin ]"

      #--- je supprime la fenetre
      destroy $private($visuNo,This)

      #--- je supprime les variables associees a la visu
      array unset private $visuNo,*
   }
}

