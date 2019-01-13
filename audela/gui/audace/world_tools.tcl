#
## @file world_tools.tcl
#  @brief world map tools
#  @author Alain KLOTZ
#  $Id: world_tools.tcl 13458 2016-03-21 13:32:14Z rzachantke $
#  @code
#  source "$audace(rep_install)/gui/audace/world_tools.tcl"
#  Read file "$audace(rep_install)/gui/audace/catalogues/world.dat"
#  Read file "$audace(rep_install)/gui/audace/catalogues/world.inx"
#  world_plotmap : add an world map contours on the current buffer
#  world_shiftmap : Shift the longitude of the first x=0 pixel (use after world_plotmap
#  world_jpegmap : overplot of a blue world map on the current buffer and generate a Jpeg
#  @endcode
#

## @brief add an world map contours on the current buffer
#  @details recourt au fichier "$audace(rep_install)/gui/audace/catalogues/world.txt
#  @param bufNo numéro du buffer, 1 par défaut
#  @param value couleur pour le dessin des contours, 32767 par défaut
#
proc world_plotmap { {bufNo 1} {value 32767} } {
   global audace

   set lon1 0
   set lon2 360
   set lat1 -90
   set lat2 90
   set naxis1 [buf$bufNo getpixelswidth]
   set naxis2 [buf$bufNo getpixelsheight]
   set world_txt "$audace(rep_install)/gui/audace/catalogues/world.txt"
   set fidtxt [open $world_txt r]
   set lignes [split [read $fidtxt] \n]
   close $fidtxt
   #set lignes [lrange $lignes 0 20]
   foreach ligne $lignes {
      set car [string index [string trim $ligne] 0]
      if {$car=="#"} {
         continue
      }
      lassign $ligne lons lats
      set nl [llength $lats]
      if {$nl==0} {
         continue
      }
      #console::affiche_resultat "nl=$nl lons=$lons lats=$lats\n"
      if {$nl==1} {
         set lon [lindex $lons 0]
         set lat [lindex $lats 0]
         set x [expr round( 1.*($lon-$lon1)/($lon2-$lon1)*$naxis1)]
         set y [expr round( 1.*($lat-$lat1)/($lat2-$lat1)*$naxis2)]
         #console::affiche_resultat " 1 x=$x y=$y\n"
         catch {buf$bufNo setpix [list $x $y] $value}
      } else {
         set lon [lindex $lons 0]
         set lat [lindex $lats 0]
         set x1 [expr round( 1.*($lon-$lon1)/($lon2-$lon1)*$naxis1)]
         set y1 [expr round( 1.*($lat-$lat1)/($lat2-$lat1)*$naxis2)]
         incr nl -1
         #console::affiche_resultat " 2 x1=$x1 y1=$y1\n"
         for {set kl 1} {$kl<=$nl} {incr kl} {
            set lon [lindex $lons $kl]
            set lat [lindex $lats $kl]
            set x2 [expr round( 1.*($lon-$lon1)/($lon2-$lon1)*$naxis1)]
            set y2 [expr round( 1.*($lat-$lat1)/($lat2-$lat1)*$naxis2)]
            #console::affiche_resultat " 3 x2=$x2 y2=$y2\n"
            set dx [expr abs($x2-$x1)]
            set dy [expr abs($y2-$y1)]
            #console::affiche_resultat " 4 dx=$dx dy=$dy\n"
            if {$dx==0} {
               #console::affiche_resultat " 5 dx=$dx\n"
               if {$dy==0} {
                  #console::affiche_resultat " 6 dy=$dy => x1=$x1 y1=$y1\n"
                  catch { buf$bufNo setpix [list $x1 $y1] $value }
               } else {
                  if {$y1<=$y2} {
                     set xx1 $x1 ; set xx2 $x2 ; set yy1 $y1 ; set yy2 $y2
                  } else {
                     set xx1 $x2 ; set xx2 $x1 ; set yy1 $y2 ; set yy2 $y1
                  }
                  #console::affiche_resultat " 7 xx1=$xx1 yy1=$yy1 xx2=$xx2 yy2=$yy2\n"
                  for {set yy $yy1} {$yy<=$yy2} {incr yy} {
                     catch { buf$bufNo setpix [list $xx1 $yy] $value }
                  }
               }
            } elseif {$dy==0} {
               if {$x1<=$x2} {
                  set xx1 $x1 ; set xx2 $x2 ; set yy1 $y1 ; set yy2 $y2
               } else {
                  set xx1 $x2 ; set xx2 $x1 ; set yy1 $y2 ; set yy2 $y1
               }
               #console::affiche_resultat " 8 xx1=$xx1 yy1=$yy1 xx2=$xx2 yy2=$yy2\n"
               for {set xx $xx1} {$xx<=$xx2} {incr xx} {
                  catch { buf$bufNo setpix [list $xx $yy1] $value }
               }
            } else {
               if {$dx>$dy} {
                  if {$x1<=$x2} {
                     set xx1 $x1 ; set xx2 $x2 ; set yy1 $y1 ; set yy2 $y2
                  } else {
                     set xx1 $x2 ; set xx2 $x1 ; set yy1 $y2 ; set yy2 $y1
                  }
                  #console::affiche_resultat " 9 xx1=$xx1 yy1=$yy1 xx2=$xx2 yy2=$yy2\n"
                  for {set xx $xx1} {$xx<=$xx2} {incr xx} {
                     set yy [expr round($yy1+1.*($yy2-$yy1)*($xx-$xx1)/($xx2-$xx1))]
                     catch { buf$bufNo setpix [list $xx $yy] $value }
                  }
               } else {
                  if {$y1<=$y2} {
                     set xx1 $x1 ; set xx2 $x2 ; set yy1 $y1 ; set yy2 $y2
                  } else {
                     set xx1 $x2 ; set xx2 $x1 ; set yy1 $y2 ; set yy2 $y1
                  }
                  #console::affiche_resultat " 10 xx1=$xx1 yy1=$yy1 xx2=$xx2 yy2=$yy2\n"
                  for {set yy $yy1} {$yy<=$yy2} {incr yy} {
                     set xx [expr round($xx1+1.*($xx2-$xx1)*($yy-$yy1)/($yy2-$yy1))]
                     catch { buf$bufNo setpix [list $xx $yy] $value }
                  }
               }
            }
            set x1 $x2
            set y1 $y2
         }
      }
   }
}

## @brief Shift the longitude of the first x=0 pixel
#  @details use after world_plotmap
#  @param bufNo numéro du buffer
#  @param dlon décalage de la longitude, 0 par défaut
#
proc world_shiftmap { {bufNo 1} {dlon 0} } {
   global audace

   set lon1 0
   set lon2 360
   set lat1 -90
   set lat2 90
   set naxis1 [buf$bufNo getpixelswidth]
   set naxis2 [buf$bufNo getpixelsheight]
   set dx [expr round( 1.*$dlon/($lon2-$lon1)*$naxis1)]
   for {set y 1} {$y<=$naxis2} {incr y} {
      for {set x 1} {$x<=$naxis1} {incr x} {
         set value [lindex [buf$bufNo getpix [list $x $y]] 1]
         set kx [expr $x+$dx]
         if {$kx>$naxis1} { set kx [expr $kx-$naxis1] }
         if {$kx<1}       { set kx [expr $kx+$naxis1] }
         set xa($kx) $value
      }
      for {set x 1} {$x<=$naxis1} {incr x} {
         set value $xa($x)
         buf$bufNo setpix [list $x $y] $value
      }
   }
}

## @brief overplot of a blue world map on the current buffer and generate a Jpeg
#  @code
#  loadima map2
#  buf1 scale {2 2} 1
#  visu {1 0}
#  world_jpegmap $audace(rep_images)/map2.jpg 1 0
#  loadima $audace(rep_images)/map2.jpg
#  @endcode
#  @param fullnamejpeg chemin complet de l'image jpeg
#  @param bufNo numéro du buffer, 1 par défaut
#  @param dlon décalage de longitude en degrés, 0 par défaut
#
proc world_jpegmap { fullnamejpeg {bufNo 1} {dlon 0} } {
   global audace

   set p $audace(rep_images)
   set e [buf$bufNo extension]
   set cuts [visu1 cut]
   lassign $cuts hicut locut
   if {$dlon!=0} {
      world_shiftmap $bufNo $dlon
   }
   buf$bufNo save $p/r$e
   buf$bufNo save $p/g$e
   buf$bufNo save $p/b$e
   # --- create the world map
   mult 0
   world_plotmap $bufNo 1
   if {$dlon!=0} {
      world_shiftmap $bufNo $dlon
   }
   buf$bufNo save $p/pos$e
   mult -1
   offset 1
   buf$bufNo save $p/neg$e
   # --- sub negative world map to all planes
   foreach plane {r g b} {
      buf$bufNo load $p/${plane}$e
      set operand $p/neg$e
      buf$bufNo imaseries "PROD \"file=$operand\" constant=1"
      buf$bufNo save $p/${plane}$e
   }
   # --- add positive world map to B plane
   buf$bufNo load $p/pos$e
   mult [expr $hicut-$locut]
   buf$bufNo add $p/b$e 0
   buf$bufNo save $p/b$e
   # --- create jpeg
   set quality 100
   fits2colorjpeg $p/r$e $p/g$e $p/b$e $fullnamejpeg $quality $locut $hicut $locut $hicut $locut $hicut
}

