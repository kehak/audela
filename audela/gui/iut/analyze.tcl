proc analyze_auto2 {} {
   global zone objnum
   set fname cor
   set ext .fit
   set rep .
   ::mini_plotxy::zoomOut $zone(graph1).xy
   # --- fabrique l'image monochrome
   for {set plan 1} {$plan<=3} {incr plan} {
      buf$objnum(buf2) load3d ${fname}${ext} $plan
      buf$objnum(buf2) setkwd [list {NAXIS} 2 {int} { number of data axes } { } ]
      buf$objnum(buf2) save i${plan}${ext}
   }         
   ttscript2 "IMA/STACK \"$rep\" \"i\" 1 3 \"$ext\" \"$rep\" \"i\" . \"$ext\" MEAN"
   # ======= Recherche des parametres importants sur X
   buf$objnum(buf2) load i   
   set naxis1 [buf$objnum(buf2) getpixelswidth]
   set naxis2 [buf$objnum(buf2) getpixelsheight]
   # --- profil
   buf$objnum(buf2) imaseries "SORTY percent=3 y1=1 y2=$naxis2 height=1 bitpix=32"
   set xxs ""
   set yys ""
   set xs ""
   set ys ""
   set x 1
   set y 1
   set err [catch {
      lassign [buf$objnum(buf2) getpix [list $x $y]] nplan gray
   } msg ]
   if {($err==1)||($gray=="")} {
      set gray 0
   }
   set gray0 $gray
   set maxi 0
   for {set x 1} {$x<=$naxis1} {incr x} {
      lappend xs $x
      lappend ys $gray0
      set err [catch {
         lassign [buf$objnum(buf2) getpix [list $x $y]] nplan gray
      } msg ]
      if {($err==1)||($gray=="")} {
         set gray 0
      }
      if {$gray>$maxi} {
         set maxi $gray
      }
      lappend xs $x
      lappend ys $gray
      set gray0 $gray
      lappend xxs $x
      lappend yys $gray
   }   
   lappend xs $x
   lappend ys $gray
   plot $xs $ys r+- 1
   # --- derivee
   set dxs ""
   set dys ""
   set ds ""
   for {set x 5} {$x<=[expr $naxis1-5]} {incr x} {
      set y1 [lindex $yys [expr $x-1]]
      set y  [lindex $yys [expr $x]]
      set y2 [lindex $yys [expr $x+1]]
      set d [expr $y*$y*($y2-$y1)/2.]
      lappend dxs $x
      lappend dys $d
      lappend ds [list $x $d]
   }  
   plot $dxs $dys r+- 1
   # --- affine les pics de derives
   set n [llength $dxs]
   set tmp_dys [lindex $dys 0]
   for {set k 1} {$k<=[expr $n-2]} {incr k} {
      set d1 [lindex $dys [expr $k-1]]
      set d  [lindex $dys $k]
      set d2 [lindex $dys [expr $k+1]]
      if {(($d>=$d1)&&($d>=$d2))||(($d<=$d1)&&($d<=$d2))} {
         lappend tmp_dys $d
      } else {
         lappend tmp_dys 0
      }
   }
   lappend tmp_dys [lindex $dys end]
   set dys $tmp_dys 
   set tmp_ds ""
   for {set k 0} {$k<$n} {incr k} {
      set d [lindex $dys $k]
      set x [lindex [lindex $ds $k] 0]
      lappend tmp_ds [list $x $d]
   }
   set ds $tmp_ds
   plot $dxs $dys r+- 1
   # --- recherche xdeb = le premier pic negatif de la derivee
   set dds [lsort -increasing -real -index 1 $ds]
   set ls [lrange $dds 0 0]
   set ls [lsort -increasing -real -index 0 $ls]
   set xdeb [lindex [lindex $ls 0] 0]
   # --- recherche xfin = le premier pic positif de la derivee
   set dds [lsort -decreasing -real -index 1 $ds]
   set ls [lrange $dds 0 0]
   set ls [lsort -increasing -real -index 0 $ls]
   set xfin [lindex [lindex $ls 0] 0]
   console_info "xdeb=$xdeb xfin=$xfin"
   #tk_messageBox -message "toto"
   # ======= Recherche des parametres importants sur Y
   buf$objnum(buf2) load i
   set naxis1 [buf$objnum(buf2) getpixelswidth]
   set naxis2 [buf$objnum(buf2) getpixelsheight]
   # --- profil
   buf$objnum(buf2) imaseries "SORTX percent=3 x1=1 x2=$naxis1 width=1 bitpix=32"
   set xxs ""
   set yys ""
   set xs ""
   set ys ""
   set x 1
   set y 1
   set err [catch {
      lassign [buf$objnum(buf2) getpix [list $y $x]] nplan gray
   } msg ]
   if {($err==1)||($gray=="")} {
      set gray 0
   }
   set gray0 $gray
   set maxi 0
   for {set x 1} {$x<=$naxis2} {incr x} {
      lappend xs $x
      lappend ys $gray0
      set err [catch {
         lassign [buf$objnum(buf2) getpix [list $y $x]] nplan gray
      } msg ]
      if {($err==1)||($gray=="")} {
         set gray 0
      }
      if {$gray>$maxi} {
         set maxi $gray
      }
      lappend xs $x
      lappend ys $gray
      set gray0 $gray
      lappend xxs $x
      lappend yys $gray
   }   
   lappend xs $x
   lappend ys $gray
   plot $xs $ys r+- 1
   # --- derivee
   set dxs ""
   set dys ""
   set ds ""
   for {set x 5} {$x<=[expr $naxis2-5]} {incr x} {
      set y1 [lindex $yys [expr $x-1]]
      set y  [lindex $yys [expr $x]]
      set y2 [lindex $yys [expr $x+1]]
      set d [expr $y*$y*($y2-$y1)/2.]
      lappend dxs $x
      lappend dys $d
      lappend ds [list $x $d]
   }   
   plot $dxs $dys r+- 1
   # --- affine les pics de derives
   set n [llength $dxs]
   set tmp_dys [lindex $dys 0]
   for {set k 1} {$k<=[expr $n-2]} {incr k} {
      set d1 [lindex $dys [expr $k-1]]
      set d  [lindex $dys $k]
      set d2 [lindex $dys [expr $k+1]]
      if {(($d>=$d1)&&($d>=$d2))||(($d<=$d1)&&($d<=$d2))} {
         lappend tmp_dys $d
      } else {
         lappend tmp_dys 0
      }
   }
   lappend tmp_dys [lindex $dys end]
   set dys $tmp_dys 
   set tmp_ds ""
   for {set k 0} {$k<$n} {incr k} {
      set d [lindex $dys $k]
      set x [lindex [lindex $ds $k] 0]
      lappend tmp_ds [list $x $d]
   }
   set ds $tmp_ds
   plot $dxs $dys r+- 1
   # --- recherche ydeb = le premier pic negatif de la derivee
   set dds [lsort -increasing -real -index 1 $ds]
   set ls [lrange $dds 0 0]
   set ls [lsort -increasing -real -index 0 $ls]
   set ydeb [lindex [lindex $ls 0] 0]
   # --- recherche yfin = le premier pic positif de la derivee
   set dds [lsort -decreasing -real -index 1 $ds]
   set ls [lrange $dds 0 0]
   set ls [lsort -increasing -real -index 0 $ls]
   set yfin [lindex [lindex $ls 0] 0]
   console_info "ydeb=$ydeb yfin=$yfin"
   # =========== Calibration de la Geometrie de l'image de la mire
   set hauteur0 400. ; # mm
   set yd 76 ; # pixel
   set yf 338 ; # pixel
   set ymd 119 ; # pixel
   set ymf 287 ; # pixel
   set hauteur [expr $hauteur0*($yf-$yd)/($yfin-$ydeb)]
   set pas0s [list 4 5 6 7 10 13 30 60 90]
   # =========== Cacul des contrastes
   buf$objnum(buf2) load i
   set naxis1 [buf$objnum(buf2) getpixelswidth]
   set naxis2 [buf$objnum(buf2) getpixelsheight]
   set cs ""
   set x1 [expr int($xdeb+0.2*($xfin-$xdeb))]
   set x2 [expr int($xdeb+0.8*($xfin-$xdeb))]
   for {set ky 0} {$ky<[llength $pas0s]} {incr ky} {
      set frac [expr ($ymd-$yd+1.*($ymf-$ymd)/([llength $pas0s]-1)*$ky)/($yf-$yd)]
      set ymilieu [expr $ydeb+$frac*($yfin-$ydeb)]
      set pas [lindex $pas0s $ky]
      set ctot 0
      set ntot 0
      set nny 1
      set y1 [expr int($ymilieu-$nny)]
      set y2 [expr int($ymilieu+$nny)]
      for {set kky $y1} {$kky<=$y2} {incr kky} {
         set y $kky
         #console_info "kky=$kky x1=$x1 x2=$x2 y=$y (frac=$frac)"
         # --- profil pour ce pas
         set dx 0
         set as ""
         set vs ""
         for {set x [expr $x1+$dx]} {$x<=[expr $x2-$dx]} {incr x} {
            set err [catch {
               lassign [buf$objnum(buf2) getpix [list $x $y]] nplan gray
            } msg ]
            if {($err==1)||($gray=="")} {
               set gray 0
            }
            lappend as $x
            lappend vs $gray            
         }
         set n [llength $vs]
         set ls [lsort -increasing -real $vs]
         set kmini [expr int($n*0.05)]
         set kmaxi [expr int($n*0.95)]
         set vmini [lindex $ls $kmini]
         set vmaxi [lindex $ls $kmaxi]
         set err [catch {
            set c [expr ($vmaxi-$vmini)/($vmaxi+$vmini)]
            incr ntot
         } msg]
         if {$err==1} {
            set c 0
         }
         console_info "pas=$pas vmini=$vmini vmaxi=$vmaxi c=$c"
         set ctot [expr $ctot+$c]
      }
      if {$ntot>0} {
         set c [expr 1.*$ctot/$ntot]
      } else {
         set c 0.
      }
      console_info "pas=$pas x1=[format %.0f $x1] x2=[format %.0f $x2] y1=[format %.0f $y1] y2=[format %.0f $y2] c=[format %.4f $c] ($ntot)"
      plot $as $vs r+- 1
      #tk_messageBox -message "x1=[format %.0f $x1] x2=[format %.0f $x2]\ny1=[format %.0f $y1] y2=[format %.0f $y2]\n\npas=$pas c=[format %.4f $c] ($ntot) ky=$ky"
      lappend pass $pas
      lappend cs $c
   }
   #plot $pass $cs ro- 4
   # --- normalisation des contrastes =1 pour la plus basse frequence
   console_info "hauteur estimee = [format %.0f $hauteur] mm"
   set np [llength $pass]
   set logfreqs ""
   set logcnorms ""
   set cnorms ""
   set separations ""
   set cmax [lindex [lsort -decreasing -real $cs] 0]
   # on enleve le premier point qui est affecté de l'aliasing
   for {set kp 0} {$kp<$np} {incr kp} {
      set pas [lindex $pass $kp]
      set c   [lindex $cs $kp]
      set err [catch {
         set cnorm [expr $c/$cmax]
      } msg]
      if {$err==1} {
         set cnorm 1e-3
      }
      if {$cnorm==0} {
         set cnorm 1e-3
      }
      set p [expr -1.*$hauteur] ; # mm
      set pas_ref 30.
      set ncycles_ref 9.
      set long_ref 88. ; # mm
      set fp 4.4 ; # mm
      set q [expr $pas/$pas_ref*$long_ref/$ncycles_ref] ; # mm/cy objet
      set pp [expr 1./(1./$fp+1./$p)]
      set grandissement [expr $pp/$p]
      set qp [expr $grandissement*$q] ; # mm/cy image
      set separation [expr abs(1./$qp)] ; # cy/mm
      lappend separations $separation
      set logfreq [expr log10($separation)] ; # mm/cy
      set logcnorm [expr 20*log10($cnorm)]
      lappend logfreqs $logfreq
      lappend logcnorms $logcnorm
      lappend cnorms $cnorm
   }
   plot $separations $cnorms ro- 4
   #plot $logfreqs $logcnorms ro- 4
   #plot $logfreqs $cnorms ro- 4
   set sortie 0
   set cnorm0 [lindex $cnorms end]
   for {set kp [expr $np-2]} {$kp>=0} {incr kp -1} {
      set cnorm [lindex $cnorms $kp]
      set separation [lindex $separations $kp]
      #console_info "kp=kp sep=[format %.1f $separation] pl/mm cnorm=[format %.2f $cnorm]"
      if {($cnorm0>0.5)&&($cnorm<=0.5)} {
         set sortie 1
         break
      }
      set cnorm0 $cnorm
   }
   if {$sortie==0} {
      set separation [lindex $separations 0]
      console_info "Frequence de coupure > [format %.1f $separation] pl/mm"
   } else {
      set separation0 [lindex $separations [expr $kp]]
      set separation  [lindex $separations [expr $kp+1]]
      set freq [expr (0.5-$cnorm)/($cnorm0-$cnorm)*($separation-$separation0)+$separation0]
      console_info "Frequence de coupure = [format %.1f $freq] pl/mm"
   }
   

}

