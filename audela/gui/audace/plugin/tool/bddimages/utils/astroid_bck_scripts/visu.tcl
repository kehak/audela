## @file astroid_bck_scripts/visu.tcl
# Routines de visualisation dans une visu de Audace

proc affich_image { fitsfile } {
   global bddconf
   global audace
   set bufno $::bddconf(bufno)
   set errnum [catch {buf$bufno load $fitsfile} msg ]
   set nbvisu [::visu::create $bufno 1]
   #visu$nbvisu zoom 0.5
   #visu$nbvisu clear
   #visu$nbvisu disp
   #$audace(hCanvas) delete cadres
   }



proc affich_rond { listsources catalog color width } {
   
   ::console::affiche_resultat "AFFICH_CATALOG=($catalog, $color, $width) NB=[llength [lindex $listsources 1]]\n"
      
   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]
   foreach s $sources { 
      #gren_info "s =  $s \n"
      foreach cata $s {
         #gren_info "cata =  $cata \n"
         if { [lindex $cata 0]==$catalog } {
            set cm [lindex $cata 1]
            #gren_info "cm =  $cm \n"
            affich_un_rond [lindex $cm 0] [lindex $cm 1] $color $width
            }
         }
      }
   }


proc affich_un_rond { ra dec color width } {

   global audace
   global bddconf
   set bufno $::bddconf(bufno)
        #gren_info "DD =  $ra $dec \n"
       # Affiche un rond vert
       set img_xy [ buf$bufno radec2xy [ list $ra $dec ] ]
       #--- Transformation des coordonnees image en coordonnees canvas
       set can_xy [ ::audace::picture2Canvas $img_xy ]
       set x [lindex $can_xy 0]
       set y [lindex $can_xy 1]
       # gren_info "XY =  $x $y \n"
       set radius 5           
       #--- Dessine l'objet selectionne en vert dans l'image
       $audace(hCanvas) create oval [ expr $x - $radius ] [ expr $y - $radius ] [ expr $x + $radius ] [ expr $y + $radius ] \
           -outline $color -tags cadres -width $width

   }


 proc efface_rond { args } {
      global audace conf bddconf
 
         #--- Efface les reperes des objets
         $audace(hCanvas) delete cadres
      }
