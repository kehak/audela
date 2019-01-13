
proc calcul_gauss { catalist } {
 global voconf
 global ssp_image
 global skybot_list
 global ros
 global gauss_list

  set gauss_list {}




  # --- charge l'image en memoire
  gren_info " On charge l'image en memoire"
  set imagepath "$ros(common,bddimages,dirbase)/$ssp_image(fits_dir)/$ssp_image(fits_filename)"

  set errnum [catch {buf1 load $imagepath} error ]
  if {$errnum==1} {
     gren_info " error=<$error>"
  }


  set gaussfield { gauss_intx gauss_xc gauss_fwhmx gauss_bgx gauss_inty gauss_yc gauss_fwhmy gauss_bgy }

  set resultlist {}
  foreach cata_source $catalist {

    foreach cata $cata_source {
       set namecata [lindex $cata 0]
       if {$namecata == "cador_cata"} {
          set fwhm_sex [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "fwhm_sex"] ]
          set xpos [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "xpos"] ]
          set ypos [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "ypos"] ]
          set delta [ expr 2 * $fwhm_sex ]
          set x0 [ expr int($xpos - $delta) ]
          set y0 [ expr int($ypos - $delta) ]
          set x1 [ expr int($xpos + $delta) ]
          set y1 [ expr int($ypos + $delta) ]
#         set x0 1981
#         set y0 1248
#         set x1 2010
#         set y1 1281         
          
          set valeurs [  buf1 fitgauss [ list $x0 $y0 $x1 $y1 ] ]
          gren_info "delta = $delta"
          gren_info "box = $x0 $y0 $x1 $y1"
          gren_info "valeurs = $valeurs"



          set naxis1 [lindex [buf1 getkwd NAXIS1] 1]
          if {$naxis1=={}} { set naxis1 1 }
          set naxis2 [lindex [buf1 getkwd NAXIS2] 1]
          if {$naxis2=={}} { set naxis2 1 }
          set dif 0.
          set intx  [lindex $valeurs 0]
          set xc    [lindex $valeurs 1]
          set fwhmx [lindex $valeurs 2]
          set bgx   [lindex $valeurs 3]
          set inty  [lindex $valeurs 4]
          set yc    [lindex $valeurs 5]
          set fwhmy [lindex $valeurs 6]
          set bgy   [lindex $valeurs 7]

          if {$naxis1==1} {
             set if0 [ expr $inty*$fwhmy*.601*sqrt(3.14159265) ]
             set leq 0.
             if {$bgy!=0} {
                set leq [expr -$if0/$bgy]
             }
          } elseif {$naxis2==1} {
             set if0 [ expr $intx*$fwhmx*.601*sqrt(3.14159265) ]
             set leq 0.
             if {$bgx!=0} {
                set leq [expr -$if0/$bgx]
             }
          } else {
             set if0 [ expr $fwhmx*$fwhmy*.601*.601*3.14159265 ]
             set if1 [ expr $intx*$if0 ]
             set if2 [ expr $inty*$if0 ]
             set if0 [ expr ($if1+$if2)/2. ]
             set dif [ expr abs($if1-$if0) ]
          }

          if {[expr $if0+$dif]<=0} {
             set dif [expr $if0+1]
          }
          set mag1 [ expr -2.5*log10($if0+$dif) ]
          if {[expr $if0-$dif]<=0} {
             set dif [expr $if0-1]
          }
          set mag2 [ expr -2.5*log10($if0-$dif) ]
          set mag0 [ expr ($mag1+$mag2)/2. ]
          set dmag [ expr abs($mag1-$mag0) ]


          # gauss = intx xc fwhmx bgx inty yc fwhmy bgy
#          gren_info "gauss = $xc $yc $if0 $mag0 $dmag"  
#          set ssp [list "ssp" $gaussfield $gauss]  
#          set row [list [list "skybot" $skybot_fields $row ] [list "common" $fieldscommon $common] ]

          }
       
       
       
       }
       
       
       
       
    }

exit
}

