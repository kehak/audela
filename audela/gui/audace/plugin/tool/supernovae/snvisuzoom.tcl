#
# Fichier : snvisuzoom.tcl
# Description : Creation d'une loupe de visualisation en association avec Sn Visu
# Auteur : Alain KLOTZ
# Mise à jour $Id: snvisuzoom.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

#--- Conventions pour ce script :
#--- Les indices 1 se rapportent a l'image de gauche
#--- Les indices 2 se rapportent a l'image de droite

#--- Chargement des captions
global audace

source [ file join $audace(rep_plugin) tool supernovae snvisuzoom.cap ]

proc snZoom1 { { zoom 3 } } {
   global audace
   global caption
   global conf
   global snvisu
   global zone
   global num

   #---
   if { ! [ info exists conf(snvisuzoom_g,position) ] } { set conf(snvisuzoom_g,position) "+125+340" }

   #---
   if { [ info exists snvisu(geometry_g) ] } {
      set deb [ expr 1 + [ string first + $snvisu(geometry_g) ] ]
      set fin [ string length $snvisu(geometry_g) ]
      set conf(snvisuzoom_g,position) "+[ string range $snvisu(geometry_g) $deb $fin ]"
   }

   #--- Cree la fenetre $audace(base).snZoom1 de niveau le plus haut
   toplevel $audace(base).snZoom1
   wm transient $audace(base).snZoom1 $audace(base).snvisu
   wm deiconify $audace(base).snZoom1
   wm geometry $audace(base).snZoom1 200x200$conf(snvisuzoom_g,position)
   wm resizable $audace(base).snZoom1 0 0
   wm title $audace(base).snZoom1 $caption(snvisuzoom,zoom_main_title)
   wm protocol $audace(base).snZoom1 WM_DELETE_WINDOW {
      ::recupPositionZoom1 ; destroy $audace(base).snZoom1
   }

   #--- Attente affichage
   label $audace(base).snZoom1.label -text $caption(snvisuzoom,wait)
   pack $audace(base).snZoom1.label -pady 20

   #--- Cree le nouveau canevas pour l'image
   snScrolledCanvas $audace(base).snZoom1.image1 right -borderwidth 0 -relief flat \
      -width 150 -height 150 -scrollregion {0 0 0 0}
   $audace(base).snZoom1.image1.canvas configure -borderwidth 0
   $audace(base).snZoom1.image1.canvas configure -relief flat
   set zone(image1_zoom) $audace(base).snZoom1.image1.canvas

   #--- Declare un nouvel objet de visualisation pour afficher le contenu du buffer
   #--- ::visu::create bufNo imageNo [ visuNo ]
   set num(visuZoom1) "2000"
   if {$snvisu(afflog)==0} {
      ::visu::create $num(buffer1) $num(visuZoom1) $num(visuZoom1)
   } else {
      ::visu::create $num(buffer1b) $num(visuZoom1) $num(visuZoom1)
   }

   #--- Cree un widget image dans un canvas pour afficher l'objet de visualisation
   $zone(image1_zoom) create image 0 0 -image imagevisu$num(visuZoom1) -anchor nw -tag img4

   #--- Applique le zoom
   visu$num(visuZoom1) zoom $zoom
   set zone(naxis1_zoom) [expr int($zone(naxis1)*$zoom)]
   set zone(naxis2_zoom) [expr int($zone(naxis2)*$zoom)]
   $zone(image1_zoom) configure -scrollregion [list 0 0 $zone(naxis1_zoom) $zone(naxis2_zoom)]

   #--- La nouvelle fenetre est active
   focus $audace(base).snZoom1

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).snZoom1
}

proc recupPositionZoom1 { } {
   global audace
   global conf
   global snvisu

   set snvisu(geometry_g) [ wm geometry $audace(base).snZoom1 ]
   set deb [ expr 1 + [ string first + $snvisu(geometry_g) ] ]
   set fin [ string length $snvisu(geometry_g) ]
   set conf(snvisuzoom_g,position) "+[ string range $snvisu(geometry_g) $deb $fin ]"
}

proc snZoomDisp1 { { x 1 } { y 1 } { zoom 3 } } {
   global audace
   global zone
   global num
   global snvisu

   set disp "0"
   if {[string length [info commands $audace(base).snZoom1.*]]==0} {
      snZoom1 "3"
      set disp "1"
   }
   set x [expr int($x-200./2./$zoom-$zoom)]
   set y [expr int($y+200./2./$zoom+$zoom)]
   set fracx [expr 1.*$x/$zone(naxis1)]
   set fracy [expr 1.-1.*$y/$zone(naxis2)]
   $audace(base).snZoom1.image1.canvas xview moveto $fracx
   $audace(base).snZoom1.image1.canvas yview moveto $fracy
   if { $disp == "1" } {
      #--- Affichage avec les memes seuils que l'image gauche
      set sh $snvisu(seuil_g_haut)
      set sb $snvisu(seuil_g_bas)
      visu$num(visuZoom1) cut [ list $sh $sb ]
      visu$num(visuZoom1) disp
      destroy $audace(base).snZoom1.label
      pack $audace(base).snZoom1.image1 \
         -in $audace(base).snZoom1 -expand 1 -side top -anchor center -fill both
      update
   }
}

proc snZoom2 { { zoom 3 } } {
   global audace
   global caption
   global conf
   global snvisu
   global zone
   global num

   #---
   if { ! [ info exists conf(snvisuzoom_d,position) ] } { set conf(snvisuzoom_d,position) "+525+340" }

   #---
   if { [ info exists snvisu(geometry_d) ] } {
      set deb [ expr 1 + [ string first + $snvisu(geometry_d) ] ]
      set fin [ string length $snvisu(geometry_d) ]
      set conf(snvisuzoom_d,position) "+[ string range $snvisu(geometry_d) $deb $fin ]"
   }

   #--- Cree la fenetre $audace(base).snZoom2 de niveau le plus haut
   toplevel $audace(base).snZoom2
   wm transient $audace(base).snZoom2 $audace(base).snvisu
   wm deiconify $audace(base).snZoom2
   wm geometry $audace(base).snZoom2 200x200$conf(snvisuzoom_d,position)
   wm resizable $audace(base).snZoom2 0 0
   wm title $audace(base).snZoom2 $caption(snvisuzoom,zoom_main_title_d)
   wm protocol $audace(base).snZoom2 WM_DELETE_WINDOW {
      ::recupPositionZoom2 ; destroy $audace(base).snZoom2
   }

   #--- Attente affichage
   label $audace(base).snZoom2.label -text $caption(snvisuzoom,wait)
   pack $audace(base).snZoom2.label -pady 20

   #--- Cree le nouveau canevas pour l'image
   snScrolledCanvas $audace(base).snZoom2.image2 right -borderwidth 0 -relief flat \
      -width 150 -height 150 -scrollregion {0 0 0 0}
   $audace(base).snZoom2.image2.canvas configure -borderwidth 0
   $audace(base).snZoom2.image2.canvas configure -relief flat
   set zone(image2_zoom) $audace(base).snZoom2.image2.canvas

   #--- Declare un nouvel objet de visualisation pour afficher le contenu du buffer
   #--- ::visu::create bufNo imageNo [ visuNo ]
   set num(visuZoom2) "2001"
   if {$snvisu(afflog)==0} {
      ::visu::create $num(buffer2) $num(visuZoom2) $num(visuZoom2)
   } else {
      ::visu::create $num(buffer2b) $num(visuZoom2) $num(visuZoom2)
   }
   #--- Cree un widget image dans un canvas pour afficher l'objet de visualisation
   $zone(image2_zoom) create image 0 0 -image imagevisu$num(visuZoom2) -anchor nw -tag img5

   #--- Applique le zoom
   visu$num(visuZoom2) zoom $zoom
   set zone(naxis1_zoom_2) [expr int($zone(naxis1_2)*$zoom)]
   set zone(naxis2_zoom_2) [expr int($zone(naxis2_2)*$zoom)]
   $zone(image2_zoom) configure -scrollregion [list 0 0 $zone(naxis1_zoom_2) $zone(naxis2_zoom_2)]

   #--- La nouvelle fenetre est active
   focus $audace(base).snZoom2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).snZoom2
}

proc recupPositionZoom2 { } {
   global audace
   global conf
   global snvisu

   set snvisu(geometry_d) [ wm geometry $audace(base).snZoom2 ]
   set deb [ expr 1 + [ string first + $snvisu(geometry_d) ] ]
   set fin [ string length $snvisu(geometry_d) ]
   set conf(snvisuzoom_d,position) "+[ string range $snvisu(geometry_d) $deb $fin ]"
}

proc snZoomDisp2 { { x 1 } { y 1 } { zoom 3 } } {
   global audace
   global zone
   global num
   global snvisu

   set disp "0"
   if {[string length [info commands $audace(base).snZoom2.*]]==0} {
      snZoom2 "3"
      set disp "1"
   }
   set x [expr int($x-200./2./$zoom-$zoom)]
   set y [expr int($y+200./2./$zoom+$zoom)]
   set fracx [expr 1.*$x/$zone(naxis1_2)]
   set fracy [expr 1.-1.*$y/$zone(naxis2_2)]
   $audace(base).snZoom2.image2.canvas xview moveto $fracx
   $audace(base).snZoom2.image2.canvas yview moveto $fracy
   if { $disp == "1" } {
      #--- Affichage avec les memes seuils que l'image droite
      set sh $snvisu(seuil_d_haut)
      set sb $snvisu(seuil_d_bas)
      visu$num(visuZoom2) cut [ list $sh $sb ]
      visu$num(visuZoom2) disp
      destroy $audace(base).snZoom2.label
      pack $audace(base).snZoom2.image2 \
         -in $audace(base).snZoom2 -expand 1 -side top -anchor center -fill both
      update
   }
}

proc changeHiCutZoom1 { foo } {
   global num

   set sbh [visu$num(visuZoom1) cut]
   visu$num(visuZoom1) cut [list $foo [lindex $sbh 1]]
}

proc changeHiCutZoom2 { foo } {
   global num

   set sbh [visu$num(visuZoom2) cut]
   visu$num(visuZoom2) cut [list $foo [lindex $sbh 1]]
}

