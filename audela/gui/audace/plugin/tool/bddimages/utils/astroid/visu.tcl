## @file utils/astroid/visu.tcl
# Routines de visualisation dans une visu de Audace

## Affiche une image fits.
# \c fitsfile :: param[in] :: Chaine de caractere du nom du fichier fits

proc affich_image { fitsfile } {
   global bddconf
   global audace
   set errnum [catch {loadima $fitsfile} msg ]
   set bddconf(zoom) [::confVisu::getZoom $bddconf(visuno)]
   ::console::affiche_resultat "ZOOM=$bddconf(zoom)\n"
}



proc affich_rond { listsources catalog color width } {
   
   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]
   foreach s $sources { 
      foreach cata $s {
         if { [lindex $cata 0] == $catalog } {
            set cm [lindex $cata 1]
            set ra [lindex $cm 0]
            set dec [lindex $cm 1]
            if {$ra != "" && $dec != ""} {
               affich_un_rond $ra $dec $color $width
            }
         }
      }
   }

}


proc affich_un_rond { ra dec color width } {

   global audace
   global bddconf
   set bufno $::bddconf(bufno)
   # Affiche un rond vert
   set img_xy [ buf$bufno radec2xy [ list $ra $dec ] ]
   set x [lindex $img_xy 0]
   set y [lindex $img_xy 1]
   #gren_info "affich_un_rond_xy $x $y $color 5 $width\n"
   affich_un_rond_xy $x $y $color 10 $width

}


proc affich_un_rond_xy { x y color radius width } {

   global audace

   set xi [expr $x - $radius]
   set yi [expr $y - $radius]
   set can_xy [ ::audace::picture2Canvas [list $xi $yi] ]
   set cxi [lindex $can_xy 0]
   set cyi [lindex $can_xy 1]

   set xs [expr $x + $radius]
   set ys [expr $y + $radius]
   set can_xy [ ::audace::picture2Canvas [list $xs $ys] ]
   set cxs [lindex $can_xy 0]
   set cys [lindex $can_xy 1]

   $audace(hCanvas) create oval $cxi $cyi $cxs $cys -outline $color -tags cadres -width $width
   
}


proc affich_un_rond_xy_crop { x y color radius width visuNo } {

   global audace

   set xi [expr $x - $radius]
   set yi [expr $y - $radius]
   set can_xy [::confVisu::picture2Canvas $visuNo [list $xi $yi ]]

   set cxi [lindex $can_xy 0]
   set cyi [lindex $can_xy 1]

   set xs [expr $x + $radius]
   set ys [expr $y + $radius]
   set can_xy [::confVisu::picture2Canvas $visuNo [list $xs $ys ]]
   set cxs [lindex $can_xy 0]
   set cys [lindex $can_xy 1]

   $::confVisu::private($visuNo,hCanvas) create oval $cxi $cyi $cxs $cys -outline $color -tags cadres -width $width
}


proc clean_crop { visuNo } {

      $::confVisu::private($visuNo,hCanvas) delete cadres

}


proc efface_rond { args } {
   global audace
   $audace(hCanvas) delete cadres
}


proc affich_un_carre_xy { x1 y1 x2 y2 color } {

   global audace

   set can1_xy [ ::audace::picture2Canvas [list $x1 $y1] ]
   set can2_xy [ ::audace::picture2Canvas [list $x2 $y2] ]

   $audace(hCanvas) create line [lindex $can1_xy 0] [lindex $can1_xy 1] [lindex $can2_xy 0] [lindex $can1_xy 1] -fill "$color" -tags carre -width 1.0
   $audace(hCanvas) create line [lindex $can2_xy 0] [lindex $can1_xy 1] [lindex $can2_xy 0] [lindex $can2_xy 1] -fill "$color" -tags carre -width 1.0
   $audace(hCanvas) create line [lindex $can2_xy 0] [lindex $can2_xy 1] [lindex $can1_xy 0] [lindex $can2_xy 1] -fill "$color" -tags carre -width 1.0
   $audace(hCanvas) create line [lindex $can1_xy 0] [lindex $can2_xy 1] [lindex $can1_xy 0] [lindex $can1_xy 1] -fill "$color" -tags carre -width 1.0
}


proc efface_carre { args } {
   global audace
   $audace(hCanvas) delete carre
}


#
# affich_vecteur
# Trace un vecteur
#
proc affich_vecteur { ra dec dra ddec factor color } {

   global audace 
   #--- coordonnees du centre du vecteur a tracer
   set img0_radec [ list $ra $dec ]
   set img0_xy [ buf$audace(bufNo) radec2xy $img0_radec ]
   set can0_xy [ ::audace::picture2Canvas $img0_xy ]
            
   #--- coordonnees du point final du vecteur
   set img1_radec [ list [expr [lindex $img0_radec 0]+$dra*$factor/3600.0] [expr [lindex $img0_radec 1]+$ddec*$factor/3600.0 ]]
   set img1_xy [ buf$audace(bufNo) radec2xy $img1_radec ]
   set can1_xy [ ::audace::picture2Canvas $img1_xy ]
   
   #--- trace du repere
   $audace(hCanvas) create line [lindex $can0_xy 0] [lindex $can0_xy 1] [lindex $can1_xy 0] [lindex $can1_xy 1] -fill "$color" -tags cadres -width 1.0 -arrow last
}





proc affich_libcata { { cata "" } { limitmag -1 } { color "red" } { width 3 } }  {

   global audace 

   set listcatapossible "USNOA2 TYCHO2 TYCHO2_FAST UCAC2 UCAC3 UCAC4 PPMX PPMXL 2MASS WFIBC GAIA1"

   if { $cata == "" } {
      gren_erreur "USAGE : affich_libcata ?Catalogue? ?limitmag? ?color? ?width? \n"
      gren_erreur "Catalogues possibles : $listcatapossible\n"
      gren_erreur "Parametres optionnels : ?limitmag? ?color? ?width? \n"
      gren_erreur "\n"
      gren_erreur "affich_libcata TYCHO2                     # Affiche les etoiles TYCHO2 dans l'image\n"
      gren_erreur "affich_libcata 2MASS 10                  # Affiche les etoiles du catalogue 2MASS dont la magnitude < 10\n"
      gren_erreur "affich_libcata USNOA2 -1 blue 1      # Affiche par des ronds bleus l USNOA2 sans limitation en magnitude\n"
      gren_erreur "affich_libcata clean                          # Efface les ronds\n"
      return
   }

   if { $cata == "clean" } {
      gren_info "cleanmark\n"
      cleanmark
      return
   }
   gren_info "buf = $audace(bufNo)\n"

   gren_info "catalog = $cata\n"
   gren_info "limitmag = $limitmag\n"
   gren_info "color = $color\n"
   gren_info "width = $width\n"

   set ra  [lindex [ buf$audace(bufNo) getkwd "CRVAL1"] 1]
   set dec [lindex [ buf$audace(bufNo) getkwd "CRVAL2"] 1]

   set naxis1  [lindex [ buf$audace(bufNo) getkwd "NAXIS1"] 1]
   set naxis2  [lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1]
   set scale_x [lindex [ buf$audace(bufNo) getkwd "CDELT1"] 1]
   set scale_y [lindex [ buf$audace(bufNo) getkwd "CDELT2"] 1]
   set mscale  [::math::statistics::max [list [expr abs($scale_x)] [expr abs($scale_y)]]]
   set radius  [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale]

   gren_info "ra = $ra\n"
   gren_info "dec = $dec\n"
   gren_info "radius = $radius\n"

   set ::tools_cata::nb 0
   set cata [string toupper $cata]

   set cmd          ""
   set path         ""
   set commonfields ""
      
   if { $cata == "USNOA2" } {
      set cmd          csusnoa2
      if {[info exists ::tools_cata::catalog_usnoa2]} {
         set path         $::tools_cata::catalog_usnoa2
      } else {
         set path         $audace(rep_userCatalogUsnoa2)
      }
      set commonfields { 5.0 magR 0.5 }
   }
   if { $cata == "TYCHO2" } {
      set cmd          cstycho2
      if {[info exists ::tools_cata::catalog_tycho2]} {
         set path         $::tools_cata::catalog_tycho2
      } else {
         set path         $audace(rep_userCatalogTycho2_fast)
      }
      set commonfields { VT e_VT }
   }
#   if { $cata == "TYCHO2_FAST" } {
#      set cmd          cstycho2_fast
#      if {[info exists ::tools_cata::catalog_tycho2_fast]} {
#         set path         $::tools_cata::catalog_tycho2_fast
#      } else {
#         set path         $audace(rep_userCatalogTycho2_Fast)
#      }
#      set commonfields { RAdeg DEdeg 5.0 VT e_VT }
#   }
   if { $cata == "UCAC2" } {
      set cmd          csucac2
      if {[info exists ::tools_cata::catalog_ucac2]} {
         set path         $::tools_cata::catalog_ucac2
      } else {
         set path         $audace(rep_userCatalogUcac2)
      }
      set commonfields { U2Rmag_mag 0.5 }
   }
   if { $cata == "UCAC3" } {
      set cmd          csucac3
      if {[info exists ::tools_cata::catalog_ucac3]} {
         set path         $::tools_cata::catalog_ucac3
      } else {
         set path         $audace(rep_userCatalogUcac3)
      }
      set commonfields { im2_mag sigmag_mag }
   }
   if { $cata == "UCAC4" } {
      set cmd          csucac4
      if {[info exists ::tools_cata::catalog_ucac4]} {
         set path         $::tools_cata::catalog_ucac4
      } else {
         set path         $audace(rep_userCatalogUcac4)
      }
      set commonfields { im2_mag sigmag_mag }
   }
   if { $cata == "PPMX" } {
      set cmd          csppmx
      if {[info exists ::tools_cata::catalog_ppmx]} {
         set path         $::tools_cata::catalog_ppmx
      } else {
         set path         $audace(rep_userCatalogPpmx)
      }
      set commonfields { Vmag ErrVmag }
   }
   if { $cata == "PPMXL" } {
      set cmd          csppmxl
      if {[info exists ::tools_cata::catalog_ppmxl]} {
         set path         $::tools_cata::catalog_ppmxl
      } else {
         set path         $audace(rep_userCatalogPpmxl)
      }
      set commonfields { magR1 0.5 }
   }
   if { $cata == "2MASS" } {
      set cmd          cs2mass
      if {[info exists ::tools_cata::catalog_2mass]} {
         set path         $::tools_cata::catalog_2mass
      } else {
         set path         $audace(rep_userCatalog2mass)
      }
      set commonfields { jMag jMagError }
   }
   if { $cata == "WFIBC" } {
      set cmd          cswfibc
      if {[info exists ::tools_cata::catalog_wfibc]} {
         set path         $::tools_cata::catalog_wfibc
      } else {
         set path         $audace(rep_userCatalogWFIBC)
      }
      set commonfields { magR error_magR }
   }
   if { $cata == "GAIA1" } {
      set cmd          csgaia1
      if {[info exists ::tools_cata::catalog_gaia1]} {
         set path         $::tools_cata::catalog_gaia1
      } else {
         set path         $audace(rep_userCatalogGaia1)
      }
      set commonfields { phot_g_mean_mag 0.5 }
   }
   if { $cata == "PANSTARRS" } {
#      set err [catch {get_panstarrs $ra $dec $radius -topnum 10000} panstarrs]

      set cmd get_panstarrs
      set path ""
      set commonfields { gmeanapmag gmeanapmagerr }
   }

   if { $cmd == "" } {
      gren_erreur "Probleme $cata non reconnu\n"
      gren_erreur "cata possible : $listcatapossible\n"
      return
   }
   if { $limitmag == -1} {
      gren_info "CMD : $cmd $path $ra $dec $radius\n"
      #set listsources [$cmd $path $ra $dec $radius]
      set listsources [$cmd $ra $dec $radius]
   } else {
      gren_info "CMD : $cmd $path $ra $dec $radius $limitmag 0\n"
      set listsources [$cmd $path $ra $dec $radius $limitmag 0]
   }
   set listsources [::manage_source::set_common_fields $listsources $cata $commonfields]

   set cf [lindex $listsources 0]
   set sources [lindex $listsources 1]
   set newsources ""
   
   foreach s $sources {
   
      set lcf [lindex $s 0 1]
      set ra  [lindex $lcf 0]
      set dec [lindex $lcf 1]

      set img0_radec [ list $ra $dec ]
      set img0_xy [ buf$audace(bufNo) radec2xy $img0_radec ]
      set can0_xy [ ::audace::picture2Canvas $img0_xy ]

      set x [lindex $img0_xy 0]
      set y [lindex $img0_xy 1]
      
      if { $x > 0 && $x<$naxis1 && $y>0 && $y < $naxis2} {
         lappend newsources $s
      } else {
         continue
      }

       
   }
   set listsources [list $cf $newsources]
   gren_info "nb sources = [::manage_source::get_nb_sources_rollup $listsources]\n"
   affich_rond $listsources $cata $color $width

}

