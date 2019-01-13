#
# Scrolled_Canvas --
#   Cree un canvas scrollable, ainsi que les deux scrollbars
#   pour le deplacer.
# ref: Brent Welsh, Practical Programming in TCL/TK, rev.2, page 392
#
proc Scrolled_Canvas { c args } {
   frame $c
   eval {canvas $c.canvas \
      -xscrollcommand [list $c.xscroll set] \
      -yscrollcommand [list $c.yscroll set] \
      -highlightthickness 0 \
      -borderwidth 0} $args
   scrollbar $c.xscroll -orient horizontal -command [list $c.canvas xview]
   scrollbar $c.yscroll -orient vertical -command [list $c.canvas yview]
   grid $c.canvas $c.yscroll -sticky news
   grid $c.xscroll -sticky ew
   grid rowconfigure $c 0 -weight 1
   grid columnconfigure $c 0 -weight 1
   return $c.canvas
}

#
#   Transforme des coordonnees ecran en coordonnees canvas. L'argument
#   est une liste de deux entiers, et retourne également une liste de
#   deux entiers.
#
proc screen2Canvas {coord} {
   global zone
   set x [$zone(image1) canvasx [lindex $coord 0]]
   set y [$zone(image1) canvasy [lindex $coord 1]]
   return [list $x $y]
}

#
#   Transforme des coordonnees canvas en coordonnees image. L'argument
#   est une liste de deux entiers, et retourne également une liste de
#   deux entiers.
#
proc canvas2Picture {coord} {
   global zone
   set xx [expr [lindex $coord 0] + 1]
   set point [string first . $xx]
   if {$point!=-1} {
      set xx [string range $xx 0 [incr point -1]]
   }
   set yy [expr $zone(naxis2) - [lindex $coord 1]]
   set point [string first . $yy]
   if {$point!=-1} {
      set yy [string range $yy 0 [incr point -1]]
   }
   return [list $xx $yy]
}

#
# Nouvelle valeur de seuil haut
#
proc changeHiCut1 {foo} {
   set sbh [visu1 cut]
   visu1 cut [list $foo [lindex $sbh 1]]
}

#
# Nouvelle valeur de seuil bas
#
proc changeLoCut1 {foo} {
   set sbh [visu1 cut]
   visu1 cut [list [lindex $sbh 0] $foo]
}

#
# !! Les coordonnees coord sont des coordonnees canvas, et non ecran.
#
proc boxBegin {coord} {
   global infos
   catch {unset infos(box)}
   set infos(box,1) [screen2Canvas $coord]
   set infos(point) [canvas2Picture $infos(box,1)]
}

#
# !! Les coordonnees x et y sont des coordonnees canvas, et non ecran.
#
proc boxDrag {coord} {
   global infos
   global zone
   global color
   catch {$zone(image1) delete $infos(hBox)}
   set x [lindex $coord 0]
   if {$x<0} {set coord [lreplace $coord 0 0 0]}
   if {$x>=$zone(naxis1)} {
      set coord [lreplace $coord 0 0 [expr $zone(naxis1)-1]]
   }
   set y [lindex $coord 1]
   if {$y<0} {set coord [lreplace $coord 1 1 0]}
   if {$y>=$zone(naxis2)} {
      set coord [lreplace $coord 1 1 [expr $zone(naxis2)-1]]
   }
   set infos(box,2) [screen2Canvas $coord]
   set infos(hBox) [eval {$zone(image1) create rect} $infos(box,1) \
                          $infos(box,2) -outline $color(rectangle) -tag selBox]
}

#
# !! Les coordonnees x et y sont des coordonnees canvas, et non ecran.
#
proc boxEnd {coord} {
   global infos
   global zone
   boxDrag $coord
   if { $infos(box,1) == $infos(box,2) } {
      catch {unset infos(box)}
      $zone(image1) delete $infos(hBox)
   } else {
      set coord1 [canvas2Picture $infos(box,1)]
      set coord2 [canvas2Picture $infos(box,2)]
      set x1 [lindex $coord1 0]
      set y1 [lindex $coord1 1]
      set x2 [lindex $coord2 0]
      set y2 [lindex $coord2 1]
      if {$x1>$x2} {
         set a $x1
         set x1 $x2
         set x2 $a
      }
      if {$y1>$y2} {
         set a $y1
         set y1 $y2
         set y2 $a
      }
      catch {unset infos(box)}
      set infos(box) [list $x1 $y1 $x2 $y2]
   }
}

